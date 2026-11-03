/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license:
 * https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#ifndef MOD_REGISTER_COMMANDS_H
#define MOD_REGISTER_COMMANDS_H

#include "Define.h"
#include <chrono>
#include <future>
#include <mutex>
#include <string>

// 命令执行通道：把 GM/CLI 命令排队到 world 线程执行，并同步等待结果。
// 与 ACSoap 的 SOAPCommand 同一套模式（见 ACSoap.h / ACSoap.cpp）。
class RegisterCommand
{
public:
    RegisterCommand() : m_success(false) {}

    void AppendToPrintBuffer(std::string_view msg)
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_printBuffer += msg;
    }

    void SetCommandSuccess(bool val)
    {
        m_success = val;
        m_finishedPromise.set_value();
    }

    bool HasCommandSucceeded() const { return m_success; }

    std::string GetPrintBuffer() const
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_printBuffer;
    }

    static void Print(void* callbackArg, std::string_view msg)
    {
        static_cast<RegisterCommand*>(callbackArg)->AppendToPrintBuffer(msg);
    }

    static void CommandFinished(void* callbackArg, bool success)
    {
        RegisterCommand* con = static_cast<RegisterCommand*>(callbackArg);
        con->SetCommandSuccess(success);
        // world 线程已处理完，释放 keep-alive 引用
        con->m_self.reset();
    }

    bool m_success;
    std::string m_printBuffer;
    std::promise<void> m_finishedPromise;
    // keep-alive：命令被排队后 world 线程仍持有裸指针，需引用计数保活
    std::shared_ptr<RegisterCommand> m_self;
    mutable std::mutex m_mutex;
};

namespace Acore::Register
{
    // 执行一条命令并返回其输出；超时/关服时返回空结果并置失败。
    // command 不带点号前缀（如 "account set gmlevel foo 3 -1"）。
    bool ExecuteCommand(std::string const& command, std::string& output,
                        std::chrono::seconds timeout = std::chrono::seconds(30));
}

#endif // MOD_REGISTER_COMMANDS_H
