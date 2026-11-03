/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license:
 * https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#include "RegisterHttpServer.h"
#include "RegisterCommands.h"
#include "RegisterDb.h"
#include "RegisterHtml.h"
#include "AccountMgr.h"
#include "Config.h"
#include "Log.h"

#include <boost/asio/io_context.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/version.hpp>
#include <fmt/format.h>
#include <ctime>
#include <iomanip>
#include <map>
#include <mutex>
#include <sstream>

namespace beast = boost::beast;
namespace http  = beast::http;
namespace asio  = boost::asio;
using tcp = asio::ip::tcp;

namespace Acore::Register
{
    namespace
    {
        // ---- 会话管理 ----
        // 简单内存会话：token -> {accountId, 过期时间戳}
        struct Session
        {
            uint32 accountId = 0;
            int64  expire = 0; // unix 秒
        };

        std::mutex g_sessionMutex;
        std::map<std::string, Session> g_sessions;

        std::string NewToken(uint32 accountId, int64 ttl)
        {
            // 用账号ID+时间生成一个简单 token（本地服务，安全性要求适度）
            static uint64 counter = 0;
            int64 now = static_cast<int64>(time(nullptr));
            std::string token = fmt::format("{:x}-{:x}-{:x}", accountId, now, ++counter);
            {
                std::lock_guard<std::mutex> lock(g_sessionMutex);
                g_sessions[token] = { accountId, now + ttl };
            }
            return token;
        }

        bool ValidateSession(std::string const& token, uint32& accountId)
        {
            if (token.empty())
                return false;
            std::lock_guard<std::mutex> lock(g_sessionMutex);
            auto it = g_sessions.find(token);
            if (it == g_sessions.end())
                return false;
            int64 now = static_cast<int64>(time(nullptr));
            if (now > it->second.expire)
            {
                g_sessions.erase(it);
                return false;
            }
            accountId = it->second.accountId;
            return true;
        }

        // ---- 权限检查 ----
        bool IsAdminAllowed(uint32 accountId)
        {
            uint32 minLevel = sConfigMgr->GetOption<uint32>("Register.MinGmLevel", 2);
            if (AccountMgr::GetSecurity(accountId) < minLevel)
                return false;

            std::string allowed = sConfigMgr->GetOption<std::string>("Register.AdminAccount", "");
            if (allowed.empty())
                return true;

            std::string name;
            if (!AccountMgr::GetName(accountId, name))
                return false;

            // 逗号分隔白名单
            std::stringstream ss(allowed);
            std::string item;
            while (std::getline(ss, item, ','))
            {
                // 去空格
                item.erase(0, item.find_first_not_of(" \t"));
                item.erase(item.find_last_not_of(" \t") + 1);
                if (!item.empty() && item == name)
                    return true;
            }
            return false;
        }

        // ---- 解析查询参数 ----
        std::map<std::string, std::string> ParseQuery(std::string const& target)
        {
            std::map<std::string, std::string> params;
            auto qpos = target.find('?');
            if (qpos == std::string::npos)
                return params;
            std::string query = target.substr(qpos + 1);
            std::stringstream ss(query);
            std::string pair;
            while (std::getline(ss, pair, '&'))
            {
                auto eq = pair.find('=');
                if (eq == std::string::npos)
                    params[pair] = "";
                else
                    params[pair.substr(0, eq)] = pair.substr(eq + 1);
            }
            return params;
        }

        std::string UrlDecode(std::string const& s)
        {
            std::string out;
            out.reserve(s.size());
            for (size_t i = 0; i < s.size(); ++i)
            {
                if (s[i] == '%' && i + 2 < s.size())
                {
                    int v;
                    std::stringstream ss;
                    ss << std::hex << s.substr(i + 1, 2);
                    ss >> v;
                    out += static_cast<char>(v);
                    i += 2;
                }
                else if (s[i] == '+')
                    out += ' ';
                else
                    out += s[i];
            }
            return out;
        }

        uint32 GetUint(std::map<std::string, std::string> const& p, std::string const& k, uint32 def = 0)
        {
            auto it = p.find(k);
            if (it == p.end() || it->second.empty())
                return def;
            try { return static_cast<uint32>(std::stoul(it->second)); }
            catch (...) { return def; }
        }

        std::string GetStr(std::map<std::string, std::string> const& p, std::string const& k, std::string const& def = "")
        {
            auto it = p.find(k);
            if (it == p.end())
                return def;
            return UrlDecode(it->second);
        }

        // 从请求头提取 Authorization: Bearer <token>
        std::string ExtractToken(http::request<http::string_body> const& req)
        {
            auto it = req.find(http::field::authorization);
            if (it == req.end())
                return "";
            std::string v = std::string(it->value());
            const std::string prefix = "Bearer ";
            if (v.rfind(prefix, 0) == 0)
                return v.substr(prefix.size());
            return "";
        }

        // ---- 响应助手 ----
        http::response<http::string_body> MakeJson(std::string const& body, http::status st = http::status::ok)
        {
            http::response<http::string_body> res{st, 11};
            res.set(http::field::content_type, "application/json; charset=utf-8");
            res.set(http::field::cache_control, "no-store");
            res.body() = body;
            res.prepare_payload();
            return res;
        }

        http::response<http::string_body> MakeHtml(std::string const& body, http::status st = http::status::ok)
        {
            http::response<http::string_body> res{st, 11};
            res.set(http::field::content_type, "text/html; charset=utf-8");
            res.set(http::field::cache_control, "no-store");
            res.body() = body;
            res.prepare_payload();
            return res;
        }

        http::response<http::string_body> MakeText(std::string const& body, http::status st = http::status::ok)
        {
            http::response<http::string_body> res{st, 11};
            res.set(http::field::content_type, "text/plain; charset=utf-8");
            res.body() = body;
            res.prepare_payload();
            return res;
        }

        // ---- 路由处理 ----
        // 返回 JSON 接口响应
        http::response<http::string_body> HandleApi(
            std::string const& path, std::map<std::string, std::string> const& params,
            http::request<http::string_body> const& req, uint32 accountId)
        {
            (void)accountId; // 权限已在入口统一校验

            // 登录
            if (path == "/api/login")
            {
                std::string username = GetStr(params, "username");
                std::string password = GetStr(params, "password");
                if (username.empty() || password.empty())
                    return MakeJson("{\"ok\":false,\"msg\":\"用户名或密码为空\"}");

                uint32 id = AccountMgr::GetId(username);
                if (!id || !AccountMgr::CheckPassword(id, password))
                    return MakeJson("{\"ok\":false,\"msg\":\"账号或密码错误\"}");

                if (!IsAdminAllowed(id))
                    return MakeJson("{\"ok\":false,\"msg\":\"账号权限不足\"}");

                int64 ttl = sConfigMgr->GetOption<int64>("Register.SessionTimeout", 3600);
                std::string token = NewToken(id, ttl);
                return MakeJson(fmt::format("{{\"ok\":true,\"token\":\"{}\"}}", token));
            }

            // 以下接口需要会话
            uint32 sessId = 0;
            if (!ValidateSession(ExtractToken(req), sessId))
                return MakeJson("{\"ok\":false,\"msg\":\"未登录或会话已过期\"}", http::status::unauthorized);

            // 账号查询
            if (path == "/api/accounts")
            {
                std::string kw = GetStr(params, "kw");
                uint32 limit = GetUint(params, "limit", 100);
                return MakeJson(Db::QueryAccounts(kw, limit));
            }

            // 角色查询
            if (path == "/api/characters")
            {
                uint32 account = GetUint(params, "account");
                std::string name = GetStr(params, "name");
                return MakeJson(Db::QueryCharacters(account, name));
            }

            // 在线状态
            if (path == "/api/online")
                return MakeJson(Db::QueryOnline());

            // 封禁列表
            if (path == "/api/bans")
                return MakeJson(Db::QueryBans());

            // 活动列表
            if (path == "/api/events")
                return MakeJson(Db::QueryGameEvents());

            // 物品检索
            if (path == "/api/items")
            {
                std::string kw = GetStr(params, "kw");
                uint32 cls = GetUint(params, "class");
                uint32 sub = GetUint(params, "subclass");
                uint32 quality = GetUint(params, "quality");
                uint32 minLv = GetUint(params, "minLevel");
                uint32 maxLv = GetUint(params, "maxLevel");
                uint32 invType = GetUint(params, "invType");
                uint32 page = GetUint(params, "page");
                return MakeJson(Db::QueryItems(kw, cls, sub, quality, minLv, maxLv, invType, page));
            }

            // 命令执行（通用）：POST /api/command  body 为 JSON {"command":"..."}
            if (path == "/api/command")
            {
                std::string cmd = GetStr(params, "cmd");
                if (cmd.empty())
                    return MakeJson("{\"ok\":false,\"msg\":\"命令为空\"}");

                std::string output;
                bool ok = ExecuteCommand(cmd, output);
                return MakeJson(fmt::format("{{\"ok\":{},\"output\":\"{}\"}}",
                    ok ? "true" : "false", output));
            }

            return MakeJson("{\"ok\":false,\"msg\":\"未知接口\"}", http::status::not_found);
        }

        http::response<http::string_body> HandleRequest(http::request<http::string_body> const& req)
        {
            std::string target(req.target());
            auto params = ParseQuery(target);
            std::string path = target.substr(0, target.find('?'));

            // 登录页 / 主页直接返回内嵌 HTML
            if (req.method() == http::verb::get && path == "/")
                return MakeHtml(Html::IndexPage());

            // API
            if (path.rfind("/api/", 0) == 0)
                return HandleApi(path, params, req, 0);

            // 404
            return MakeText("Not Found", http::status::not_found);
        }

        // 每个连接的会话处理
        class HttpSession : public std::enable_shared_from_this<HttpSession>
        {
        public:
            HttpSession(tcp::socket socket) : _socket(std::move(socket)) {}

            void Start()
            {
                ReadRequest();
            }

        private:
            tcp::socket _socket;
            beast::flat_buffer _buffer{8192};
            http::request<http::string_body> _req;

            void ReadRequest()
            {
                auto self = shared_from_this();
                http::async_read(_socket, _buffer, _req,
                    [self](beast::error_code ec, std::size_t)
                    {
                        if (ec == http::error::end_of_stream)
                            return self->Close();
                        if (ec)
                            return self->Close();

                        self->SendResponse(HandleRequest(self->_req));
                    });
            }

            void SendResponse(http::response<http::string_body>&& msg)
            {
                auto sp = std::make_shared<http::response<http::string_body>>(std::move(msg));
                auto self = shared_from_this();
                http::async_write(_socket, *sp,
                    [self, sp](beast::error_code ec, std::size_t)
                    {
                        self->_socket.shutdown(tcp::socket::shutdown_send, ec);
                    });
            }

            void Close()
            {
                beast::error_code ec;
                _socket.shutdown(tcp::socket::shutdown_send, ec);
            }
        };

        // 监听器
        class HttpListener : public std::enable_shared_from_this<HttpListener>
        {
        public:
            HttpListener(asio::io_context& ioc, tcp::endpoint endpoint)
                : _ioc(ioc), _acceptor(ioc)
            {
                beast::error_code ec;
                _acceptor.open(endpoint.protocol(), ec);
                if (ec)
                    return;
                _acceptor.set_option(asio::socket_base::reuse_address(true), ec);
                _acceptor.bind(endpoint, ec);
                if (ec)
                    return;
                _acceptor.listen(asio::socket_base::max_listen_connections, ec);
            }

            bool IsOpen() const { return _acceptor.is_open(); }

            void StartAccept()
            {
                DoAccept();
            }

        private:
            asio::io_context& _ioc;
            tcp::acceptor _acceptor;

            void DoAccept()
            {
                _acceptor.async_accept(_ioc,
                    [self = shared_from_this()](beast::error_code ec, tcp::socket socket)
                    {
                        if (!ec)
                            std::make_shared<HttpSession>(std::move(socket))->Start();
                        else
                            return;
                        self->DoAccept();
                    });
            }
        };
    }

    // ================= HttpServer 实现 =================

    HttpServer::~HttpServer()
    {
        Stop();
    }

    bool HttpServer::Start(std::string const& ip, uint16 port)
    {
        _ip = ip;
        _port = port;
        _running.store(true);
        _stopping.store(false);
        _thread = std::make_unique<std::thread>(&HttpServer::Run, this);
        return true;
    }

    void HttpServer::Stop()
    {
        if (!_running.load())
            return;
        _stopping.store(true);
        _running.store(false);
        if (_thread && _thread->joinable())
            _thread->join();
        _thread.reset();
    }

    void HttpServer::Run()
    {
        try
        {
            asio::io_context ioc;
            tcp::endpoint endpoint(asio::ip::make_address(_ip), _port);
            auto listener = std::make_shared<HttpListener>(ioc, endpoint);

            if (!listener->IsOpen())
            {
                LOG_ERROR("mod.register", "RegisterHttp: 无法绑定 {}:{}", _ip, _port);
                _running.store(false);
                return;
            }

            listener->StartAccept();
            LOG_INFO("mod.register", "RegisterHttp: GM 后台已启动 http://{}:{}", _ip, _port);

            ioc.run();
        }
        catch (std::exception const& e)
        {
            LOG_ERROR("mod.register", "RegisterHttp: 异常 {}", e.what());
            _running.store(false);
        }
    }
}
