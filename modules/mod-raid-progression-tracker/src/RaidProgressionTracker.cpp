/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#include "ConfigValueCache.h"
#include "Creature.h"
#include "DatabaseEnv.h"
#include "Group.h"
#include "Map.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "WorldSession.h"

#include <unordered_set>

// Content categories persisted in the `content_type` column. Plain integers so
// more categories can be added later without a schema change.
enum RptContentType : uint8
{
    RPT_DUNGEON    = 0,
    RPT_RAID       = 1,
    RPT_WORLDBOSS  = 2
};

// Unified difficulty encoding persisted in the `difficulty` column. Unlike the
// raw per-expansion Difficulty enum (which overlaps: dungeon Normal and raid
// 10-man are both 0), this is a single flat scale so dungeon/raid sizes never
// collide and the armory can label kills unambiguously.
enum RptDifficulty : uint8
{
    RPT_DIFF_5MAN      = 0,
    RPT_DIFF_5MAN_HC   = 1,
    RPT_DIFF_10MAN     = 2,
    RPT_DIFF_20MAN     = 3,
    RPT_DIFF_25MAN     = 4,
    RPT_DIFF_40MAN     = 5,
    RPT_DIFF_10MAN_HC  = 6,
    RPT_DIFF_25MAN_HC  = 7,
};

enum class RptConfig
{
    ENABLE,
    CREDIT_ENTIRE_GROUP,
    TRACK_DUNGEONS,
    TRACK_RAIDS,
    TRACK_WORLD_BOSSES,
    REQUIRE_BOSS_FLAG,
    INCLUDE_BOTS,
    WORLD_BOSS_CREDIT_RADIUS,

    NUM_CONFIGS,
};

class RptConfigData : public ConfigValueCache<RptConfig>
{
public:
    RptConfigData() : ConfigValueCache(RptConfig::NUM_CONFIGS) { }

    void BuildConfigCache() override
    {
        SetConfigValue<bool>(RptConfig::ENABLE, "RaidTracker.Enable", true);
        SetConfigValue<bool>(RptConfig::CREDIT_ENTIRE_GROUP, "RaidTracker.CreditEntireGroup", true);
        SetConfigValue<bool>(RptConfig::TRACK_DUNGEONS, "RaidTracker.TrackDungeons", true);
        SetConfigValue<bool>(RptConfig::TRACK_RAIDS, "RaidTracker.TrackRaids", true);
        SetConfigValue<bool>(RptConfig::TRACK_WORLD_BOSSES, "RaidTracker.TrackWorldBosses", true);
        SetConfigValue<bool>(RptConfig::REQUIRE_BOSS_FLAG, "RaidTracker.RequireBossFlag", true);
        SetConfigValue<bool>(RptConfig::INCLUDE_BOTS, "RaidTracker.IncludeBots", true);
        SetConfigValue<float>(RptConfig::WORLD_BOSS_CREDIT_RADIUS, "RaidTracker.WorldBossCreditRadius", 200.0f);
    }
};

static RptConfigData rptConfig;

// Creature entries that are boss "kill credit" creatures, preloaded from
// instance_encounters (all expansions). Used as a detection fallback for any
// instanced encounter creature that lacks the dungeon-boss flag.
static std::unordered_set<uint32> rptEncounterCreatureEntries;

// Creature entries curated by this module's world SQL. This catches scripted
// encounters whose death/credit handling does not line up with core boss flags.
static std::unordered_set<uint32> rptTrackedBossNpcEntries;

static bool RptIsEnabled()
{
    return rptConfig.GetConfigValue<bool>(RptConfig::ENABLE);
}

// Clean-core builds have no concept of a "bot"; NPCbots are creatures and never
// appear in a player group's member iteration. This is the integration point for
// Playerbots: a sessionless player is treated as bot/AI controlled.
static bool RptIsBotControlled(Player* player)
{
    return player->GetSession() == nullptr;
}

// Returns the tracked content type for the kill, or -1 when it should be ignored.
static int RptResolveContentType(Creature* killed)
{
    Map* map = killed->GetMap();
    if (!map)
        return -1;

    if (rptConfig.GetConfigValue<bool>(RptConfig::TRACK_RAIDS) && map->IsRaid())
        return RPT_RAID;

    if (rptConfig.GetConfigValue<bool>(RptConfig::TRACK_DUNGEONS) && map->IsNonRaidDungeon())
        return RPT_DUNGEON;

    if (rptConfig.GetConfigValue<bool>(RptConfig::TRACK_WORLD_BOSSES) && map->IsWorldMap())
    {
        // isWorldBoss() tests CREATURE_TYPE_FLAG_BOSS_MOB, the flag retail world
        // bosses (Kazzak, Azuregos, the Emerald dragons, ...) are tagged with.
        // The `rank` field is only a visual/respawn hint and is unreliable here.
        if (killed->isWorldBoss())
            return RPT_WORLDBOSS;
    }

    return -1;
}

static bool RptIsTrackableBoss(Creature* killed, int contentType)
{
    // World bosses already qualified by their world-boss flag.
    if (contentType == RPT_WORLDBOSS)
        return true;

    CreatureTemplate const* tmpl = killed->GetCreatureTemplate();
    if (!tmpl)
        return false;

    if (!rptConfig.GetConfigValue<bool>(RptConfig::REQUIRE_BOSS_FLAG))
        return true;

    if (killed->IsDungeonBoss())
        return true;

    if (killed->isWorldBoss())
        return true;

    return rptEncounterCreatureEntries.find(tmpl->Entry) != rptEncounterCreatureEntries.end()
        || rptTrackedBossNpcEntries.find(tmpl->Entry) != rptTrackedBossNpcEntries.end();
}

static bool RptIsEligibleMember(Player* member, Creature* boss, int contentType)
{
    if (!member)
        return false;

    // Must be in the same Map instance (same pointer) as the boss.
    if (member->GetMap() != boss->GetMap())
        return false;

    if (member->IsGameMaster())
        return false;

    if (!rptConfig.GetConfigValue<bool>(RptConfig::INCLUDE_BOTS) && RptIsBotControlled(member))
        return false;

    // For world bosses the whole continent shares the map, so require proximity.
    if (contentType == RPT_WORLDBOSS)
    {
        float radius = rptConfig.GetConfigValue<float>(RptConfig::WORLD_BOSS_CREDIT_RADIUS);
        if (radius > 0.0f && !member->IsWithinDist(boss, radius))
            return false;
    }

    return true;
}

// Translates the raw map difficulty into the flat RptDifficulty scale.
static uint8 RptResolveDifficulty(Map* map, int contentType)
{
    Difficulty raw = map->GetDifficulty();

    if (contentType == RPT_DUNGEON)
        return (raw == DUNGEON_DIFFICULTY_HEROIC) ? RPT_DIFF_5MAN_HC : RPT_DIFF_5MAN;

    if (contentType == RPT_RAID)
    {
        // mod-individual-progression hosts the 40-man Classic versions of
        // Naxxramas (map 533) and Onyxia's Lair (map 249) on a Heroic slot of
        // the shared WotLK map. Those maps have no real Heroic mode, so any
        // Heroic-slot kill there is the 40-man Classic encounter.
        uint32 mapId = map->GetId();
        if ((mapId == 533 || mapId == 249) && raw >= RAID_DIFFICULTY_10MAN_HEROIC)
            return RPT_DIFF_40MAN;

        // Vanilla raids predate the 10/25 system; their player cap distinguishes
        // 40-man (MC/BWL/AQ40/...) from 20-man (Zul'Gurub/Ruins of Ahn'Qiraj).
        if (InstanceMap* instance = map->ToInstanceMap())
        {
            uint32 maxPlayers = instance->GetMaxPlayers();
            if (maxPlayers >= 40)
                return RPT_DIFF_40MAN;
            if (maxPlayers == 20)
                return RPT_DIFF_20MAN;
        }

        switch (raw)
        {
            case RAID_DIFFICULTY_10MAN_NORMAL: return RPT_DIFF_10MAN;
            case RAID_DIFFICULTY_25MAN_NORMAL: return RPT_DIFF_25MAN;
            case RAID_DIFFICULTY_10MAN_HEROIC: return RPT_DIFF_10MAN_HC;
            case RAID_DIFFICULTY_25MAN_HEROIC: return RPT_DIFF_25MAN_HC;
            default:                           return RPT_DIFF_10MAN;
        }
    }

    // World bosses have no difficulty; store a neutral value (the armory matches
    // world-boss kills regardless of difficulty).
    return RPT_DIFF_5MAN;
}

static void RptRecordKill(uint32 playerGuid, int contentType, uint16 mapId, uint32 bossEntry, uint8 difficulty)
{
    CharacterDatabase.Execute(
        "INSERT INTO raid_progression_tracker "
        "(player_guid, content_type, map_id, boss_entry, difficulty, kill_count, first_kill_time, last_kill_time) "
        "VALUES ({}, {}, {}, {}, {}, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()) "
        "ON DUPLICATE KEY UPDATE kill_count = kill_count + 1, last_kill_time = UNIX_TIMESTAMP()",
        playerGuid, uint32(contentType), uint32(mapId), bossEntry, uint32(difficulty));
}

static void RptHandleBossKill(Player* killer, Creature* killed)
{
    if (!killer || !killed)
        return;

    if (!RptIsEnabled())
        return;

    int contentType = RptResolveContentType(killed);
    if (contentType < 0)
        return;

    if (!RptIsTrackableBoss(killed, contentType))
        return;

    Map* map = killed->GetMap();
    uint16 mapId = uint16(map->GetId());
    uint8 difficulty = RptResolveDifficulty(map, contentType);
    uint32 bossEntry = killed->GetEntry();

    Group* group = rptConfig.GetConfigValue<bool>(RptConfig::CREDIT_ENTIRE_GROUP) ? killer->GetGroup() : nullptr;
    if (!group)
    {
        if (RptIsEligibleMember(killer, killed, contentType))
            RptRecordKill(killer->GetGUID().GetCounter(), contentType, mapId, bossEntry, difficulty);
        return;
    }

    for (GroupReference* itr = group->GetFirstMember(); itr; itr = itr->next())
    {
        Player* member = itr->GetSource();
        if (!RptIsEligibleMember(member, killed, contentType))
            continue;

        RptRecordKill(member->GetGUID().GetCounter(), contentType, mapId, bossEntry, difficulty);
    }
}

static void RptLoadEncounterCreatures()
{
    rptEncounterCreatureEntries.clear();

    // creditType 0 == ENCOUNTER_CREDIT_KILL_CREATURE
    QueryResult result = WorldDatabase.Query("SELECT creditEntry FROM instance_encounters WHERE creditType = 0");
    if (!result)
        return;

    do
    {
        Field* fields = result->Fetch();
        uint32 creditEntry = fields[0].Get<uint32>();
        if (creditEntry)
            rptEncounterCreatureEntries.insert(creditEntry);
    } while (result->NextRow());
}

static void RptLoadTrackedBossNpcs()
{
    rptTrackedBossNpcEntries.clear();

    QueryResult result = WorldDatabase.Query("SELECT DISTINCT npc_entry FROM raid_tracker_boss_npc");
    if (!result)
        return;

    do
    {
        Field* fields = result->Fetch();
        uint32 npcEntry = fields[0].Get<uint32>();
        if (npcEntry)
            rptTrackedBossNpcEntries.insert(npcEntry);
    } while (result->NextRow());
}

class RaidProgressionTrackerPlayer : public PlayerScript
{
public:
    RaidProgressionTrackerPlayer() : PlayerScript("RaidProgressionTrackerPlayer", {
        PLAYERHOOK_ON_CREATURE_KILL,
        PLAYERHOOK_ON_CREATURE_KILLED_BY_PET
    }) { }

    void OnPlayerCreatureKill(Player* killer, Creature* killed) override
    {
        RptHandleBossKill(killer, killed);
    }

    void OnPlayerCreatureKilledByPet(Player* petOwner, Creature* killed) override
    {
        RptHandleBossKill(petOwner, killed);
    }
};

class RaidProgressionTrackerWorld : public WorldScript
{
public:
    RaidProgressionTrackerWorld() : WorldScript("RaidProgressionTrackerWorld", {
        WORLDHOOK_ON_BEFORE_CONFIG_LOAD,
        WORLDHOOK_ON_STARTUP
    }) { }

    void OnBeforeConfigLoad(bool reload) override
    {
        rptConfig.Initialize(reload);
    }

    void OnStartup() override
    {
        RptLoadEncounterCreatures();
        RptLoadTrackedBossNpcs();
    }
};

void AddRaidProgressionTrackerScripts()
{
    new RaidProgressionTrackerPlayer();
    new RaidProgressionTrackerWorld();
}
