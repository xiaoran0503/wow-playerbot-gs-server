/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license:
 * https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#include "RegisterCommands.h"
#include "IWorld.h"
#include "World.h"

namespace Acore::Register
{
    bool ExecuteCommand(std::string const& command, std::string& output, std::chrono::seconds timeout)
    {
        if (command.empty())
        {
            output = "空命令。";
            return false;
        }

        if (World::IsStopped())
        {
            output = "服务器正在关闭。";
            return false;
        }

        auto con = std::make_shared<RegisterCommand>();
        con->m_self = con;

        // 命令在 world 线程执行，通过回调回填结果
        sWorld->QueueCliCommand(new CliCommandHolder(
            con.get(),
            command.c_str(),
            &RegisterCommand::Print,
            &RegisterCommand::CommandFinished));

        std::future<void> finished = con->m_finishedPromise.get_future();
        while (finished.wait_for(std::chrono::seconds(1)) != std::future_status::ready)
        {
            if (World::IsStopped())
            {
                output = "命令中止：服务器正在关闭。";
                return false;
            }
            if (timeout.count() > 0 && --timeout <= std::chrono::seconds(0))
            {
                output = "命令执行超时。";
                return false;
            }
        }

        output = con->GetPrintBuffer();
        return con->HasCommandSucceeded();
    }
}
