/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license:
 * https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#include "RegisterDb.h"
#include "Config.h"
#include "GameEventMgr.h"
#include "GameTime.h"
#include "DatabaseEnv.h"
#include "QueryResult.h"
#include "Field.h"
#include "Log.h"
#include <fmt/format.h>
#include <mutex>
#include <utility>

namespace
{
    // JSON 字符串转义
    std::string JsonEscape(std::string const& s)
    {
        std::string out;
        out.reserve(s.size() + 8);
        for (char c : s)
        {
            switch (c)
            {
                case '"':  out += "\\\""; break;
                case '\\': out += "\\\\"; break;
                case '\n': out += "\\n";  break;
                case '\r': out += "\\r";  break;
                case '\t': out += "\\t";  break;
                default:
                    if (static_cast<unsigned char>(c) < 0x20)
                        out += fmt::format("\\u{:04x}", c);
                    else
                        out += c;
            }
        }
        return out;
    }

    // 转义 SQL 字符串字面量
    std::string SqlEscape(std::string const& s)
    {
        std::string esc = s;
        WorldDatabase.EscapeString(esc);
        return esc;
    }

    // 读取并校验物品名称语言（白名单，防注入）。
    // AC 新版 item_template_locale.locale 是字符串（'zhCN'），不是数字。
    std::string ItemLocale()
    {
        std::string loc = sConfigMgr->GetOption<std::string>("Register.ItemLocale", "zhCN");

        static const char* const allowed[] = {
            "enUS", "koKR", "frFR", "deDE", "zhCN", "zhTW", "esES", "esMX", "ruRU"
        };
        for (char const* a : allowed)
            if (loc == a)
                return loc;

        // 非法值回退英文（不 JOIN 本地化表）
        return "enUS";
    }

    // ---------------- 活动名称中文化 ----------------
    // game_event.description 只有英文，且多数活动没有 holiday id 可查 DBC，
    // 因此在代码内做「精确表 + 规则翻译」，不修改数据库。

    bool StartsWith(std::string const& s, std::string const& prefix)
    {
        return s.size() >= prefix.size() && s.compare(0, prefix.size(), prefix) == 0;
    }

    bool EndsWith(std::string const& s, std::string const& suffix)
    {
        return s.size() >= suffix.size() && s.compare(s.size() - suffix.size(), suffix.size(), suffix) == 0;
    }

    std::string Trim(std::string s)
    {
        std::size_t b = s.find_first_not_of(" \t");
        if (b == std::string::npos)
            return "";
        std::size_t e = s.find_last_not_of(" \t");
        return s.substr(b, e - b + 1);
    }

    std::string TranslateMonth(std::string const& m)
    {
        static std::pair<char const*, char const*> const months[] = {
            {"January", "一月"}, {"February", "二月"}, {"March", "三月"}, {"April", "四月"},
            {"May", "五月"}, {"June", "六月"}, {"July", "七月"}, {"August", "八月"},
            {"September", "九月"}, {"October", "十月"}, {"November", "十一月"}, {"December", "十二月"}
        };
        for (auto const& p : months)
            if (m == p.first)
                return p.second;
        return m;
    }

    std::string TranslateZone(std::string const& z)
    {
        static std::pair<char const*, char const*> const zones[] = {
            {"Elwynn Forest", "艾尔文森林"}, {"Mulgore", "莫高雷"}, {"Terokkar Forest", "泰罗卡森林"},
            {"Ironforge", "铁炉堡"}, {"Orgrimmar", "奥格瑞玛"}, {"Winterspring", "冬泉谷"},
            {"Tanaris", "塔纳利斯"}, {"Azshara", "艾萨拉"}, {"Blasted Lands", "诅咒之地"},
            {"Eastern Plaguelands", "东瘟疫之地"}, {"Burning Steppes", "燃烧平原"}
        };
        for (auto const& p : zones)
            if (z == p.first)
                return p.second;
        return z;
    }

    std::string TranslateFaction(std::string const& f)
    {
        if (f == "Alliance") return "联盟";
        if (f == "Horde") return "部落";
        return f;
    }

    std::string TranslateGoods(std::string const& g)
    {
        if (g == "Bars") return "金属锭";
        if (g == "Herbs") return "草药";
        if (g == "Skins") return "皮革";
        if (g == "Bandages") return "绷带";
        if (g == "Cooked Goods") return "烹饪食物";
        return g;
    }

    std::string TranslateTier(std::string const& t)
    {
        if (t == "Initial") return "初始阶段";
        if (StartsWith(t, "Tier ")) return "第 " + t.substr(5) + " 阶段";
        return t;
    }

    // 太阳井高地大门状态
    std::string TranslateSwpGate(std::string const& s)
    {
        if (s == "All Gates Closed") return "大门全部关闭";
        if (s == "First Gate Open") return "第一道门开启";
        if (s == "Second Gate Open") return "第二道门开启";
        if (s == "All Gates Open") return "大门全部开启";
        return s;
    }

    // 阳湾圣殿收复阶段
    std::string TranslateSunwellPhase(std::string const& s)
    {
        static std::pair<char const*, char const*> const phases[] = {
            {"Phase 1", "阶段 1"}, {"Phase 2 Only", "阶段 2（限时）"}, {"Phase 2 Permanent", "阶段 2（永久）"},
            {"Phase No Portal", "传送门关闭"}, {"Phase Portal", "传送门开启"},
            {"Phase 3 Only", "阶段 3（限时）"}, {"Phase 3 Permanent", "阶段 3（永久）"},
            {"Phase No Anvil", "铁砧未修复"}, {"Phase Anvil", "铁砧已修复"},
            {"Phase 4", "阶段 4"},
            {"Phase No Monument", "纪念碑未建"}, {"Phase Monument", "纪念碑建成"},
            {"Phase No Alchemy Lab", "炼金实验室未建"}, {"Phase Alchemy Lab", "炼金实验室建成"},
            {"Phase K'iru", "基鲁"}
        };
        for (auto const& p : phases)
            if (s == p.first)
                return p.second;
        return s;
    }

    // 天灾入侵子项
    std::string TranslateScourge(std::string const& s)
    {
        if (s == "Boss in instance activation") return "副本首领激活";
        if (StartsWith(s, "Attacking "))
            return "进攻 " + TranslateZone(s.substr(10));
        if (s == "50 Invasions Done") return "已完成 50 次入侵";
        if (s == "100 Invasions Done") return "已完成 100 次入侵";
        if (s == "150 Invasions Done") return "已完成 150 次入侵";
        if (s == "Invasions Done") return "入侵完成";
        return s;
    }

    // 安其拉战争物资：<阵营> <物资> <阶段>
    std::string TranslateAhnQiraj(std::string const& s)
    {
        std::string rest = Trim(s);
        std::size_t sp = rest.find(' ');
        if (sp == std::string::npos)
            return s;

        std::string faction = TranslateFaction(rest.substr(0, sp));
        rest = Trim(rest.substr(sp + 1));

        std::string tier;
        std::string goods;
        if (EndsWith(rest, "Initial"))
        {
            tier = TranslateTier("Initial");
            goods = Trim(rest.substr(0, rest.size() - 7));
        }
        else
        {
            std::size_t tierPos = rest.rfind("Tier ");
            if (tierPos == std::string::npos)
                return s;
            tier = TranslateTier(rest.substr(tierPos));
            goods = Trim(rest.substr(0, tierPos));
        }

        return faction + TranslateGoods(goods) + " " + tier;
    }

    // 战场征召
    std::string TranslateBattleground(std::string const& name)
    {
        static std::pair<char const*, char const*> const bgs[] = {
            {"Alterac Valley", "奥特兰克山谷"}, {"Warsong Gulch", "战歌峡谷"},
            {"Arathi Basin", "阿拉希盆地"}, {"Eye of the Storm", "风暴之眼"},
            {"Strand of the Ancients", "远古海滩"}, {"Isle of Conquest", "征服之岛"}
        };
        for (auto const& p : bgs)
            if (name == p.first)
                return p.second;
        return name;
    }

    std::string EventNameZh(std::string const& desc)
    {
        if (desc.empty())
            return desc;

        // 1) 精确匹配：节日与专有活动
        static std::pair<char const*, char const*> const exact[] = {
            {"Midsummer Fire Festival", "仲夏火焰节"},
            {"Winter Veil", "冬幕节"},
            {"Winter Veil: Gifts", "冬幕节：礼物"},
            {"New Year's Eve", "除夕夜"},
            {"Lunar Festival", "农历新年"},
            {"Love is in the Air", "情人节"},
            {"Noblegarden", "贵族花园"},
            {"Children's Week", "儿童周"},
            {"Harvest Festival", "收获节"},
            {"Hallow's End", "万圣节"},
            {"Pilgrim's Bounty", "朝圣者的恩典"},
            {"Brewfest", "美酒节"},
            {"Pirates' Day", "海盗节"},
            {"Day of the Dead", "亡灵节"},
            {"Elemental Invasions", "元素入侵"},
            {"Scourge Invasion", "天灾入侵"},
            {"Gurubashi Arena Booty Run", "古拉巴什竞技场寻宝"},
            {"AQ War Effort", "安其拉战争物资"},
            {"Pyrewood Village", "焚木村"},
            {"Arena Tournament", "竞技场锦标赛"},
            {"Spirit of Competition", "竞争之魂"},
            {"BlizzCon 2007", "2007 暴雪嘉年华"},
            {"Zalazane's Fall", "扎拉赞恩的陨落"},
            {"Fireworks Spectacular", "烟花庆典"},
            {"Hourly Bells", "整点钟声"},
            {"Children of Goldshire", "闪金镇的孩子们"},
            {"Summer seasonal fish", "夏季季节性鱼类"},
            {"Diurnal fishing event", "昼间钓鱼活动"},
            {"Nocturnal fishing event", "夜间钓鱼活动"},
            {"L70ETC BlizzCon Concert", "70级精英乐队：暴雪嘉年华演唱会"},
            {"L70ETC Grim Guzzler Concert", "70级精英乐队：黑铁酒吧演唱会"},
            {"L70ETC World's End Tavern Concert", "70级精英乐队：天涯旅店演唱会"},
            {"Stitches Event", "缝合怪事件"},
            {"Perry Gatner", "派瑞·加特纳"},
            {"Scarlet Oracle", "血色占卜者"},
            {"Evening", "夜幕"},
            {"Leprithus", "雷普利图斯"},
            {"What the Cold Wind Brings...", "寒风带来的……"},
            {"Terokk Boss Event", "泰罗克首领事件"},
            {"Steel Gate Gargoyle Attack", "钢铁之门石像鬼袭击"},
            {"Dalaran: Minigob", "达拉然：米尼格布"},
            {"Wintergrasp Alliance Defence", "冬拥湖：联盟防守"},
            {"Wintergrasp Horde Defence", "冬拥湖：部落防守"},
            {"Venture Bay Alliance Defence", "风险投资港：联盟防守"},
            {"Venture Bay Horde Defence", "风险投资港：部落防守"}
        };
        for (auto const& p : exact)
            if (desc == p.first)
                return p.second;

        // 2) 规则翻译：高度重复的批量活动
        // 统一用运行时前缀长度，避免手数偏移出错。
        auto After = [&desc](char const* prefix) { return desc.substr(std::string(prefix).size()); };
        auto Inner = [&desc](char const* prefix) { std::string s = desc.substr(std::string(prefix).size()); s.pop_back(); return s; };

        if (StartsWith(desc, "Call to Arms: ") && EndsWith(desc, "!"))
            return "战场征召：" + TranslateBattleground(desc.substr(std::string("Call to Arms: ").size(), desc.size() - std::string("Call to Arms: ").size() - 1));

        if (StartsWith(desc, "Arena Season "))
            return "竞技场第 " + After("Arena Season ") + " 赛季";

        if (StartsWith(desc, "Brew of the Month "))
            return "本月美酒：" + TranslateMonth(After("Brew of the Month "));

        if (StartsWith(desc, "Darkmoon Faire Building (") && EndsWith(desc, ")"))
            return "暗月马戏团搭建（" + TranslateZone(Inner("Darkmoon Faire Building (")) + "）";

        if (StartsWith(desc, "Darkmoon Faire (") && EndsWith(desc, ")"))
            return "暗月马戏团（" + TranslateZone(Inner("Darkmoon Faire (")) + "）";

        if (StartsWith(desc, "Brewfest Building (") && EndsWith(desc, ")"))
            return "美酒节搭建（" + TranslateZone(Inner("Brewfest Building (")) + "）";

        if (StartsWith(desc, "Edge of Madness, "))
        {
            std::string who = After("Edge of Madness, ");
            if (who == "Gri'lek") who = "格里雷克";
            else if (who == "Hazza'rah") who = "哈扎拉";
            else if (who == "Renataki") who = "雷纳塔基";
            else if (who == "Wushoolay") who = "乌苏雷";
            return "疯狂之缘：" + who;
        }

        if (StartsWith(desc, "AT Event Trigger (") && EndsWith(desc, ")"))
        {
            std::string inner = Inner("AT Event Trigger (");
            if (inner == "Tirion Speech") inner = "提里昂演讲";
            else if (inner == "Horde Event") inner = "部落事件";
            else if (inner == "Alliance Event") inner = "联盟事件";
            return "事件触发（" + inner + "）";
        }

        if (StartsWith(desc, "Sun's Reach Reclamation "))
            return "阳湾圣殿收复：" + TranslateSunwellPhase(After("Sun's Reach Reclamation "));

        if (StartsWith(desc, "SWP - "))
            return "太阳井高地：" + TranslateSwpGate(After("SWP - "));

        if (StartsWith(desc, "Scourge Invasion - "))
            return "天灾入侵：" + TranslateScourge(After("Scourge Invasion - "));

        if (StartsWith(desc, "Ahn'Qiraj War Effort - "))
            return "安其拉战争物资：" + TranslateAhnQiraj(After("Ahn'Qiraj War Effort - "));

        if (StartsWith(desc, "Stranglethorn Fishing Extravaganza"))
        {
            std::string rest = Trim(After("Stranglethorn Fishing Extravaganza"));
            if (rest.empty()) return "荆棘谷钓鱼大赛";
            if (rest == "Announce") return "荆棘谷钓鱼大赛：公告";
            if (rest == "Fishing Pools") return "荆棘谷钓鱼大赛：鱼群";
            if (rest == "- The Crew") return "荆棘谷钓鱼大赛：船员";
            if (rest == "- Turn-ins") return "荆棘谷钓鱼大赛：交任务";
            return "荆棘谷钓鱼大赛：" + rest;
        }

        if (StartsWith(desc, "Kalu'ak Fishing Derby "))
        {
            std::string rest = After("Kalu'ak Fishing Derby ");
            if (rest == "Turn-ins") return "卡鲁亚克钓鱼大赛：交任务";
            if (rest == "Fishing Pools") return "卡鲁亚克钓鱼大赛：鱼群";
            return "卡鲁亚克钓鱼大赛：" + rest;
        }

        // 3) 未收录：保留英文
        return desc;
    }
}

namespace Acore::Register::Db
{
    std::string QueryAccounts(std::string const& keyword, uint32 limit)
    {
        std::string sql;
        if (keyword.empty())
        {
            sql = fmt::format(
                "SELECT a.id, a.username, a.email, IFNULL(aa.gmlevel,0), a.expansion, a.online, "
                "a.last_ip, a.last_login, a.locked "
                "FROM account a LEFT JOIN account_access aa ON a.id=aa.id AND aa.RealmID=-1 "
                "ORDER BY a.id DESC LIMIT {}", limit);
        }
        else
        {
            std::string kw = SqlEscape(keyword);
            sql = fmt::format(
                "SELECT a.id, a.username, a.email, IFNULL(aa.gmlevel,0), a.expansion, a.online, "
                "a.last_ip, a.last_login, a.locked "
                "FROM account a LEFT JOIN account_access aa ON a.id=aa.id AND aa.RealmID=-1 "
                "WHERE a.username LIKE '%{}%' OR a.id = '{}' "
                "ORDER BY a.id DESC LIMIT {}", kw, kw, limit);
        }

        QueryResult result = LoginDatabase.Query(sql);
        if (!result)
            return "{\"total\":0,\"rows\":[]}";

        std::string json = "{\"total\":" + std::to_string(result->GetRowCount()) + ",\"rows\":[";
        bool first = true;
        do
        {
            Field* f = result->Fetch();
            if (!first) json += ",";
            first = false;
            json += fmt::format(
                "{{\"id\":{},\"username\":\"{}\",\"email\":\"{}\",\"gmlevel\":{},\"expansion\":{},\"online\":{},\"last_ip\":\"{}\",\"last_login\":\"{}\",\"locked\":{}}}",
                f[0].Get<uint32>(), JsonEscape(f[1].Get<std::string>()), JsonEscape(f[2].Get<std::string>()),
                f[3].Get<uint8>(), f[4].Get<uint8>(), f[5].Get<uint8>(),
                JsonEscape(f[6].Get<std::string>()), JsonEscape(f[7].Get<std::string>()), f[8].Get<uint8>());
        } while (result->NextRow());
        json += "]}";
        return json;
    }

    std::string QueryCharacters(uint32 accountId, std::string const& name, uint32 limit)
    {
        std::string sql;
        if (accountId != 0)
        {
            sql = fmt::format(
                "SELECT guid, account, name, race, class, level, money, online, map, zone "
                "FROM characters WHERE account = {} ORDER BY level DESC LIMIT {}", accountId, limit);
        }
        else if (!name.empty())
        {
            std::string n = SqlEscape(name);
            sql = fmt::format(
                "SELECT guid, account, name, race, class, level, money, online, map, zone "
                "FROM characters WHERE name LIKE '%{}%' ORDER BY level DESC LIMIT {}", n, limit);
        }
        else
        {
            sql = fmt::format(
                "SELECT guid, account, name, race, class, level, money, online, map, zone "
                "FROM characters ORDER BY level DESC LIMIT {}", limit);
        }

        QueryResult result = CharacterDatabase.Query(sql);
        if (!result)
            return "{\"total\":0,\"rows\":[]}";

        std::string json = "{\"total\":" + std::to_string(result->GetRowCount()) + ",\"rows\":[";
        bool first = true;
        do
        {
            Field* f = result->Fetch();
            if (!first) json += ",";
            first = false;
            json += fmt::format(
                "{{\"guid\":{},\"account\":{},\"name\":\"{}\",\"race\":{},\"class\":{},\"level\":{},\"money\":{},\"online\":{},\"map\":{},\"zone\":{}}}",
                f[0].Get<uint32>(), f[1].Get<uint32>(), JsonEscape(f[2].Get<std::string>()),
                f[3].Get<uint8>(), f[4].Get<uint8>(), f[5].Get<uint8>(),
                f[6].Get<uint64>(), f[7].Get<uint8>(), f[8].Get<uint16>(), f[9].Get<uint16>());
        } while (result->NextRow());
        json += "]}";
        return json;
    }

    std::string QueryOnline()
    {
        std::string sql =
            "SELECT a.id, a.username, a.last_ip, a.last_login FROM account a WHERE a.online = 1 ORDER BY a.id";

        QueryResult accResult = LoginDatabase.Query(sql);
        std::string accJson = "[";
        bool first = true;
        if (accResult)
        {
            do
            {
                Field* f = accResult->Fetch();
                if (!first) accJson += ",";
                first = false;
                accJson += fmt::format(
                    "{{\"id\":{},\"username\":\"{}\",\"last_ip\":\"{}\",\"last_login\":\"{}\"}}",
                    f[0].Get<uint32>(), JsonEscape(f[1].Get<std::string>()),
                    JsonEscape(f[2].Get<std::string>()), JsonEscape(f[3].Get<std::string>()));
            } while (accResult->NextRow());
        }
        accJson += "]";

        QueryResult chrResult = CharacterDatabase.Query(
            "SELECT guid, account, name, level, map, zone FROM characters WHERE online = 1 ORDER BY account");
        std::string chrJson = "[";
        first = true;
        if (chrResult)
        {
            do
            {
                Field* f = chrResult->Fetch();
                if (!first) chrJson += ",";
                first = false;
                chrJson += fmt::format(
                    "{{\"guid\":{},\"account\":{},\"name\":\"{}\",\"level\":{},\"map\":{},\"zone\":{}}}",
                    f[0].Get<uint32>(), f[1].Get<uint32>(), JsonEscape(f[2].Get<std::string>()),
                    f[3].Get<uint8>(), f[4].Get<uint16>(), f[5].Get<uint16>());
            } while (chrResult->NextRow());
        }
        chrJson += "]";

        return fmt::format("{{\"accounts\":{},\"characters\":{}}}", accJson, chrJson);
    }

    std::string QueryBans()
    {
        QueryResult result = LoginDatabase.Query(
            "SELECT id, bandate, unbandate, bannedby, banreason, active "
            "FROM account_banned ORDER BY bandate DESC LIMIT 200");
        if (!result)
            return "{\"total\":0,\"rows\":[]}";

        std::string json = "{\"total\":" + std::to_string(result->GetRowCount()) + ",\"rows\":[";
        bool first = true;
        do
        {
            Field* f = result->Fetch();
            if (!first) json += ",";
            first = false;
            json += fmt::format(
                "{{\"id\":{},\"bandate\":{},\"unbandate\":{},\"bannedby\":\"{}\",\"reason\":\"{}\",\"active\":{}}}",
                f[0].Get<uint32>(), f[1].Get<uint32>(), f[2].Get<uint32>(),
                JsonEscape(f[3].Get<std::string>()), JsonEscape(f[4].Get<std::string>()), f[5].Get<uint8>());
        } while (result->NextRow());
        json += "]}";
        return json;
    }

    namespace
    {
        std::mutex g_gameEventSnapshotMutex;
        std::string g_gameEventSnapshot = "{\"total\":0,\"serverTime\":0,\"rows\":[]}";
    }

    void RefreshGameEvents()
    {
        // 只能从 world 线程调用：GameEventMgr 的活动集合会在该线程更新。
        GameEventMgr::GameEventDataMap const& events = sGameEventMgr->GetEventMap();
        GameEventMgr::ActiveEvents const& activeEvents = sGameEventMgr->GetActiveEventList();
        time_t const now = GameTime::GetGameTime().count();

        std::string rows = "[";
        bool first = true;
        uint32 total = 0;

        // eventEntry 从 1 开始；0 是保留槽位。
        for (uint16 eventId = 1; eventId < events.size(); ++eventId)
        {
            GameEventData const& event = events[eventId];
            if (!event.isValid())
                continue;

            bool const active = activeEvents.find(eventId) != activeEvents.end();
            uint32 const nextChangeIn = sGameEventMgr->NextCheck(eventId);
            int64 const nextChangeAt = static_cast<int64>(now) + static_cast<int64>(nextChangeIn);

            if (!first)
                rows += ",";
            first = false;
            ++total;

            rows += fmt::format(
                "{{\"eventEntry\":{},\"description\":\"{}\",\"descriptionEn\":\"{}\",\"active\":{},\"status\":\"{}\",\"nextAction\":\"{}\",\"nextChangeAt\":{},\"nextChangeIn\":{},\"startAt\":{},\"endAt\":{},\"occurence\":{},\"length\":{},\"holiday\":{},\"state\":{}}}",
                eventId, JsonEscape(EventNameZh(event.Description)), JsonEscape(event.Description),
                active ? "true" : "false",
                active ? "开启" : "未开启", active ? "stop" : "start", nextChangeAt, nextChangeIn,
                static_cast<int64>(event.Start), static_cast<int64>(event.End),
                event.Occurence, event.Length, static_cast<uint32>(event.HolidayId),
                static_cast<uint32>(event.State));
        }
        rows += "]";

        std::string snapshot = fmt::format("{{\"total\":{},\"serverTime\":{},\"rows\":{}}}",
            total, static_cast<int64>(now), rows);
        std::lock_guard<std::mutex> lock(g_gameEventSnapshotMutex);
        g_gameEventSnapshot = std::move(snapshot);
    }

    std::string QueryGameEvents()
    {
        // HTTP 线程只读快照，完全不访问数据库和 GameEventMgr。
        std::lock_guard<std::mutex> lock(g_gameEventSnapshotMutex);
        return g_gameEventSnapshot;
    }

    std::string QueryItems(std::string const& keyword, uint32 itemClass, uint32 subclass,
                           uint32 quality, uint32 minLevel, uint32 maxLevel,
                           uint32 invType, uint32 page, uint32 limit)
    {
        // 本地化名称：item_template_locale.locale 是字符串（如 'zhCN'），需按白名单取值
        std::string const loc = SqlEscape(ItemLocale());

        std::string where;
        std::vector<std::string> conds;

        if (!keyword.empty())
        {
            std::string kw = SqlEscape(keyword);
            conds.push_back(fmt::format(
                "(t.name LIKE '%{}%' OR l.Name LIKE '%{}%' OR t.entry = '{}')", kw, kw, kw));
        }
        if (itemClass != 0)
            conds.push_back(fmt::format("t.class = {}", itemClass));
        if (subclass != 0)
            conds.push_back(fmt::format("t.subclass = {}", subclass));
        if (quality != 0)
            conds.push_back(fmt::format("t.Quality = {}", quality));
        if (minLevel != 0)
            conds.push_back(fmt::format("t.ItemLevel >= {}", minLevel));
        if (maxLevel != 0)
            conds.push_back(fmt::format("t.ItemLevel <= {}", maxLevel));
        if (invType != 0)
            conds.push_back(fmt::format("t.InventoryType = {}", invType));

        for (size_t i = 0; i < conds.size(); ++i)
            where += (i == 0 ? " WHERE " : " AND ") + conds[i];

        uint32 offset = page * limit;
        std::string sql = fmt::format(
            "SELECT t.entry, t.name, l.Name, t.class, t.subclass, t.Quality, t.ItemLevel, "
            "t.RequiredLevel, t.InventoryType, t.AllowableClass, t.AllowableRace "
            "FROM item_template t "
            "LEFT JOIN item_template_locale l ON l.ID=t.entry AND l.locale='{}' "
            "{} ORDER BY t.ItemLevel DESC, t.entry ASC LIMIT {},{}",
            loc, where, offset, limit);

        QueryResult result = WorldDatabase.Query(sql);
        if (!result)
            return "{\"total\":0,\"rows\":[]}";

        std::string json = "{\"total\":" + std::to_string(result->GetRowCount()) + ",\"rows\":[";
        bool first = true;
        do
        {
            Field* f = result->Fetch();
            if (!first) json += ",";
            first = false;

            // 本地化名称优先，回退英文名
            std::string nameEn = f[1].Get<std::string>();
            std::string localeName = f[2].IsNull() ? "" : f[2].Get<std::string>();
            std::string displayName = localeName.empty() ? nameEn : localeName;

            json += fmt::format(
                "{{\"entry\":{},\"name\":\"{}\",\"nameEn\":\"{}\",\"class\":{},\"subclass\":{},\"quality\":{},\"itemLevel\":{},\"requiredLevel\":{},\"invType\":{},\"allowClass\":{},\"allowRace\":{}}}",
                f[0].Get<uint32>(), JsonEscape(displayName), JsonEscape(nameEn),
                f[3].Get<uint8>(), f[4].Get<uint8>(),
                f[5].Get<uint8>(), f[6].Get<uint32>(), f[7].Get<uint8>(), f[8].Get<uint8>(),
                f[9].Get<int32>(), f[10].Get<int32>());
        } while (result->NextRow());
        json += "]}";
        return json;
    }
}
