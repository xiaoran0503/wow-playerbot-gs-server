# Raid Progression Tracker

An AzerothCore module that records per-character boss kills across **dungeons**, **raids** and **world bosses**, for all expansions. Each kill is upserted into a characters-database table with a `content_type` so progression can be queried per category.

## What it tracks

On every boss kill the module credits each eligible group member with one row per `(player, boss, difficulty)`:

- `content_type` - `0` = dungeon, `1` = raid, `2` = world boss (the column is a plain `TINYINT`, so more categories can be added later)
- `map_id`, `boss_entry`, `difficulty`, `kill_count`, `first_kill_time`, `last_kill_time`

Detection:

- **Dungeons** (`map->IsNonRaidDungeon()`) - Classic/TBC/WotLK 5-mans, Normal (`difficulty 0`) and Heroic (`difficulty 1`).
- **Raids** (`map->IsRaid()`) - including the [mod-individual-progression](https://github.com/ZhengPeiRu21/mod-individual-progression) 40-man Classic Onyxia/Naxxramas, which run on the same maps at `RAID_DIFFICULTY_10MAN_HEROIC` (`difficulty 2`) with dedicated boss entries (e.g. Onyxia 40 = `301000`).
- **World bosses** (`map->IsWorldMap()` + world-boss rank) - Azuregos, Lord Kazzak, Doomwalker, the emerald dragons, etc. Group members must be within `WorldBossCreditRadius` of the boss to be credited.

A boss is identified by the dungeon-boss flag, world-boss rank, membership in `instance_encounters`, or membership in the module's `raid_tracker_boss_npc` table (preloaded at startup). The whole group present in the same instance is credited (last hit and pet kills both count); GMs are skipped.

## Configuration

See `conf/raid_progression_tracker.conf.dist`:

- `RaidTracker.Enable`
- `RaidTracker.CreditEntireGroup`
- `RaidTracker.TrackDungeons`, `RaidTracker.TrackRaids`, `RaidTracker.TrackWorldBosses`
- `RaidTracker.RequireBossFlag`
- `RaidTracker.WorldBossCreditRadius`
- `RaidTracker.IncludeBots`

## Installation

1. Clone into `azerothcore/modules/`.
2. Re-run CMake and rebuild the worldserver.
3. The table in `data/sql/db-characters/raid_progression_tracker.sql` is applied automatically by the module SQL updater (or import it manually into the characters database).
4. Copy `conf/raid_progression_tracker.conf.dist` to your config directory as `raid_progression_tracker.conf` if you want to override defaults.

## Building / testing

Disable PCH and compile (`-DNOPCH=1`) to catch missing headers.
