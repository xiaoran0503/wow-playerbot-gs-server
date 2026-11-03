/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license:
 * https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#include "RegisterHttpServer.h"
#include "RegisterDb.h"
#include "Config.h"
#include "Log.h"
#include "ScriptMgr.h"

namespace
{
    Acore::Register::HttpServer g_httpServer;
    bool g_enabled = false;

    class RegisterWorldScript : public WorldScript
    {
    public:
        RegisterWorldScript() : WorldScript("RegisterWorldScript",
            { WORLDHOOK_ON_STARTUP, WORLDHOOK_ON_UPDATE, WORLDHOOK_ON_SHUTDOWN }) { }

        void OnStartup() override
        {
            g_enabled = sConfigMgr->GetOption<bool>("Register.Enable", false);
            if (!g_enabled)
            {
                LOG_INFO("mod.register", "GM 后台未启用（Register.Enable = 0）");
                return;
            }

            std::string ip = sConfigMgr->GetOption<std::string>("Register.IP", "127.0.0.1");
            uint16 port = sConfigMgr->GetOption<uint16>("Register.Port", 8090);

            // 首次快照在 world 线程生成；HTTP 线程只读取该缓存。
            Acore::Register::Db::RefreshGameEvents();

            if (g_httpServer.Start(ip, port))
                LOG_INFO("mod.register", "GM 后台服务启动于 {}:{}", ip, port);
            else
                LOG_ERROR("mod.register", "GM 后台服务启动失败");
        }

        void OnUpdate(uint32 diff) override
        {
            if (!g_enabled)
                return;

            _eventSnapshotTimer += diff;
            if (_eventSnapshotTimer >= 1000)
            {
                _eventSnapshotTimer = 0;
                Acore::Register::Db::RefreshGameEvents();
            }
        }

        void OnShutdown() override
        {
            g_httpServer.Stop();
        }

    private:
        uint32 _eventSnapshotTimer = 0;
    };
}

void AddRegisterScripts()
{
    new RegisterWorldScript();
}
