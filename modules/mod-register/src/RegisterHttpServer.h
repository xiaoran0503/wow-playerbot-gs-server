/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license:
 * https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#ifndef MOD_REGISTER_HTTP_SERVER_H
#define MOD_REGISTER_HTTP_SERVER_H

#include "Define.h"
#include <atomic>
#include <memory>
#include <string>
#include <thread>

// GM 后台 HTTP 服务：Boost.Beast，本地监听，内嵌 HTML。
// 命令走 RegisterCommands（world 线程队列），查询走 RegisterDb（直连数据库）。
namespace Acore::Register
{
    class HttpServer
    {
    public:
        HttpServer() = default;
        ~HttpServer();

        // 绑定地址与端口并启动工作线程。失败返回 false。
        bool Start(std::string const& ip, uint16 port);
        // 停止服务并等待线程退出。
        void Stop();

        bool IsRunning() const { return _running.load(); }

    private:
        void Run();

        std::atomic<bool> _running{false};
        std::atomic<bool> _stopping{false};
        std::string _ip;
        uint16 _port = 0;
        std::unique_ptr<std::thread> _thread;
    };
}

#endif // MOD_REGISTER_HTTP_SERVER_H
