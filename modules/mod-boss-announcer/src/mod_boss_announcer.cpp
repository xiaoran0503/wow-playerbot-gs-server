//by SymbolixDEV
//Reworked by Talamortis
//Improved Attempt + Wipe + Fight Timer System

#include "Chat.h"
#include "Config.h"
#include "Group.h"
#include "GroupMgr.h"
#include "InstanceScript.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "WorldSessionMgr.h"
#include <unordered_map>
#include <ctime>
#include <sstream>

static std::unordered_map<uint32, std::unordered_map<uint32, uint32>> BossAttempts;
static std::unordered_map<uint32, std::unordered_map<uint32, time_t>> BossFightStartTime;

static bool removeAura, BossAnnouncerEnable, BossAnnounceToPlayerOnLogin;
static bool BossAnnounceWipe;

class BossAttemptTracker : public UnitScript
{
public:
    BossAttemptTracker() : UnitScript("BossAttemptTracker") {}

    void OnUnitEnterCombat(Unit* unit, Unit* /*victim*/) override
    {
        if (!BossAnnouncerEnable)
            return;

        Creature* creature = unit->ToCreature();
        if (!creature)
            return;

        if (!creature->GetMap()->IsRaid() || !creature->IsDungeonBoss())
            return;

        uint32 instanceId = creature->GetInstanceId();
        uint32 bossEntry = creature->GetEntry();

        if (BossAttempts[instanceId][bossEntry] == 0)
            BossAttempts[instanceId][bossEntry] = 1;

        BossFightStartTime[instanceId][bossEntry] = time(nullptr);
    }

    void OnUnitEnterEvadeMode(Unit* unit, uint8 /*evadeReason*/) override
    {
        if (!BossAnnouncerEnable || !BossAnnounceWipe)
            return;

        Creature* creature = unit->ToCreature();
        if (!creature)
            return;

        if (!creature->GetMap()->IsRaid() || !creature->IsDungeonBoss())
            return;

        uint32 instanceId = creature->GetInstanceId();
        uint32 bossEntry = creature->GetEntry();

        if (creature->IsAlive() && BossAttempts[instanceId][bossEntry] > 0)
        {
            uint32 attempt = BossAttempts[instanceId][bossEntry];

            time_t startTime = BossFightStartTime[instanceId][bossEntry];
            uint32 duration = uint32(time(nullptr) - startTime);

            uint32 minutes = duration / 60;
            uint32 seconds = duration % 60;

            Map* map = creature->GetMap();

            std::string leaderName = "未知";
            std::string guildName = "无公会";

            for (auto const& itr : map->GetPlayers())
            {
                Player* member = itr.GetSource();
                if (!member)
                    continue;

                if (member->GetGroup())
                    leaderName = member->GetGroup()->GetLeaderName();
                else
                    leaderName = member->GetName();

                if (member->GetGuild())
                    guildName = member->GetGuildName();

                break;
            }

            std::ostringstream wipeMsg;

            wipeMsg << "|cff00ffff" << leaderName
                << "|r 的公会 |cff00ff00" << guildName
                << "|r 在 |cffff0000["
                << creature->GetName()
                << "]|r 团灭了，"
                << "|cffffff00(第 " << attempt << " 次尝试)|r "
                << "历时 " << minutes << " 分 "
                << seconds << " 秒。";

            sWorldSessionMgr->SendServerMessage(SERVER_MSG_STRING, wipeMsg.str().c_str());

            BossAttempts[instanceId][bossEntry]++;
        }
    }
};

class Boss_Announcer : public PlayerScript
{
public:
    Boss_Announcer() : PlayerScript("Boss_Announcer", {
        PLAYERHOOK_ON_LOGIN,
        PLAYERHOOK_ON_CREATURE_KILL
        }) {
    }

    void OnPlayerLogin(Player* player)
    {
        if (BossAnnouncerEnable && BossAnnounceToPlayerOnLogin)
            ChatHandler(player->GetSession()).SendSysMessage(
                "本服已运行 |cff4CFF00BossAnnouncer |r模块（团灭与首领击杀公告）。");
    }

    void OnPlayerCreatureKill(Player* player, Creature* boss)
    {
        if (!BossAnnouncerEnable)
            return;

        if (!boss->GetMap()->IsRaid() || !boss->IsDungeonBoss())
            return;

        Map* map = player->GetMap();

        uint32 instanceId = boss->GetInstanceId();
        uint32 bossEntry = boss->GetEntry();

        uint32 attemptCount = BossAttempts[instanceId][bossEntry];
        if (attemptCount == 0)
            attemptCount = 1;

        time_t startTime = BossFightStartTime[instanceId][bossEntry];
        uint32 duration = uint32(time(nullptr) - startTime);

        uint32 minutes = duration / 60;
        uint32 seconds = duration % 60;

        std::string p_name = player->GetGroup() ?
            player->GetGroup()->GetLeaderName() :
            player->GetName();

        std::string g_name = player->GetGuild() ?
            player->GetGuildName() :
            "无公会";

        std::string boss_name = boss->GetName();

        std::string raidSize = map->Is25ManRaid() ? "25" : "10";
        std::string mode = map->IsHeroic() ?
            "|cffff0000英雄|r" :
            "|cff00ff00普通|r";

        uint32 Alive_players = 0;
        uint32 Tanks = 0;
        uint32 Healers = 0;
        uint32 DPS = 0;

        for (auto const& itr : map->GetPlayers())
        {
            Player* member = itr.GetSource();
            if (!member)
                continue;

            if (member->IsGameMaster())
                continue;

            if (member->IsAlive())
                Alive_players++;

            if (member->HasHealSpec())
                Healers++;
            else if (member->HasTankSpec())
                Tanks++;
            else
                DPS++;

            if (removeAura)
            {
                uint32 buff = member->GetTeamId() == TEAM_ALLIANCE ? 57723 : 57724;
                if (member->HasAura(buff))
                    member->RemoveAura(buff);
            }
        }

        std::ostringstream stream;

        stream << "|cff00ffff" << p_name
            << "|r 的公会 |cff00ff00" << g_name
            << "|r 击杀了 |cffff0000["
            << boss_name << "]|r "
            << "|cffffff00(第 " << attemptCount << " 次尝试)|r "
            << "历时 " << minutes << " 分 "
            << seconds << " 秒。"
            << "存活：|cff00ff00"
            << Alive_players << "/" << raidSize
            << "|r，难度：" << mode
            << " |cff3399ff[坦克：" << Tanks
            << " 治疗：" << Healers
            << " 输出：" << DPS << "]|r";

        sWorldSessionMgr->SendServerMessage(SERVER_MSG_STRING, stream.str().c_str());

        // Reset boss data after kill
        BossAttempts[instanceId].erase(bossEntry);
        BossFightStartTime[instanceId].erase(bossEntry);
    }
};

class Boss_Announcer_World : public WorldScript
{
public:
    Boss_Announcer_World() : WorldScript("Boss_Announcer_World",
        {
            WORLDHOOK_ON_BEFORE_CONFIG_LOAD
        }) {
    }

    void OnBeforeConfigLoad(bool /*reload*/) override
    {
        SetInitialWorldSettings();
    }

    void SetInitialWorldSettings()
    {
        removeAura = sConfigMgr->GetOption<bool>("Boss.Announcer.RemoveAuraUponKill", false);
        BossAnnouncerEnable = sConfigMgr->GetOption<bool>("Boss.Announcer.Enable", true);
        BossAnnounceToPlayerOnLogin = sConfigMgr->GetOption<bool>("Boss.Announcer.Announce", true);
        BossAnnounceWipe = sConfigMgr->GetOption<bool>("Boss.Announcer.AnnounceWipe", true);
    }
};

void AddBoss_AnnouncerScripts()
{
    new Boss_Announcer_World;
    new Boss_Announcer;
    new BossAttemptTracker;
}
