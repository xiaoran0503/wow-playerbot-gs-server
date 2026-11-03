/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license:
 * https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#ifndef MOD_REGISTER_DB_H
#define MOD_REGISTER_DB_H

#include "Define.h"
#include <string>
#include <vector>

namespace Acore::Register::Db
{
    // 单条账号信息
    struct AccountRow
    {
        uint32 id = 0;
        std::string username;
        std::string email;
        uint8 gmlevel = 0;
        uint8 expansion = 0;
        uint8 online = 0;
        std::string lastIp;
        std::string lastLogin;
        uint8 locked = 0;
    };

    // 单条角色信息
    struct CharacterRow
    {
        uint32 guid = 0;
        uint32 account = 0;
        std::string name;
        uint8 race = 0;
        uint8 cls = 0;
        uint8 level = 0;
        uint64 money = 0; // 铜币
        uint8 online = 0;
        uint16 map = 0;
        uint16 zone = 0;
    };

    // 单条物品信息
    struct ItemRow
    {
        uint32 entry = 0;
        std::string name;
        uint8 itemClass = 0;
        uint8 subclass = 0;
        uint8 quality = 0;
        uint32 itemLevel = 0;
        uint8 requiredLevel = 0;
        uint8 inventoryType = 0;
        int32 allowableClass = -1;
        int32 allowableRace = -1;
    };

    // 单条封禁信息
    struct BanRow
    {
        uint32 id = 0;
        uint32 bandate = 0;
        uint32 unbandate = 0;
        std::string bannedby;
        std::string reason;
        uint8 active = 0;
    };

    // ---- 查询接口（均返回 JSON 字符串，供 HTTP 直接响应） ----

    // 账号：按关键词（用户名/ID）模糊查询，keyword 为空则返回前 limit 条
    std::string QueryAccounts(std::string const& keyword, uint32 limit = 100);
    // 角色：按账号ID/角色名查询
    std::string QueryCharacters(uint32 accountId, std::string const& name, uint32 limit = 100);
    // 在线状态：账号在线 + 角色在线
    std::string QueryOnline();
    // 封禁列表
    std::string QueryBans();
    // 在 world 线程调用：从 AzerothCore 运行时活动管理器刷新状态快照。
    void RefreshGameEvents();
    // HTTP 线程只读取缓存快照，避免与 world 线程并发访问 GameEventMgr。
    std::string QueryGameEvents();

    // 物品检索：多条件筛选
    //   keyword      名称/ID 模糊
    //   itemClass    物品大类（0=全部）
    //   subclass     子类（0=全部）
    //   quality      品质（0=全部）
    //   minLevel/maxLevel 物品等级区间（0=不限）
    //   invType      装备栏位（0=全部）
    //   limit/page   分页
    std::string QueryItems(std::string const& keyword, uint32 itemClass, uint32 subclass,
                           uint32 quality, uint32 minLevel, uint32 maxLevel,
                           uint32 invType, uint32 page, uint32 limit = 50);
}

#endif // MOD_REGISTER_DB_H
