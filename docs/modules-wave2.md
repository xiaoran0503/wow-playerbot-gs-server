# Modules Wave 2 — Vendor & Compatibility Notes

Vendor pass for four additional AzerothCore modules on top of the wave-1 stack
(`mod-ale`, `mod-playerbots`). Each entry below records the upstream source, pinned
HEAD, structure conclusion, compatibility verdict, collected SQL, and conf seed.

Loader-name convention (core `modules/CMakeLists.txt`): the static script loader
calls `Add<FolderNameWithDashesAsUnderscores>Scripts()`. A folder `foo-bar` therefore
requires a symbol `Addfoo_barScripts()`. Modules whose upstream folder does not match
the vendored folder name had their loader function renamed at vendor time (noted per module).

---

## 1. mod-junk-to-gold-plus — one-click junk vending

- **Upstream:** https://github.com/TrisBits/mod-junk-to-gold-plus
- **HEAD:** `8409491a5ea8590dc52c76ca0851d4fb2e19975a` (branch `main`)
- **Last commit:** 2026-08-03 — actively maintained.
- **Vendored to:** `modules/mod-junk-to-gold-plus`
- **Structure:** old-style (AzerothCore native glob). Ships `include.sh` + `src/mod_junk_to_gold_plus.cpp`; no module-level `CMakeLists.txt`. Core auto-globs `modules/*/src/**`.
  - Loader symbol in source: `Addmod_junk_to_gold_plusScripts()` — **matches** folder name `mod-junk-to-gold-plus` (→ `mod_junk_to_gold_plus`). No rename needed.
- **What it does:** chat/sell-hook module that auto-sells grey "junk" items when a vendor is opened (with optional sale chat spam).
- **Compatibility:**
  - No Eluna / Lua dependency (server includes only `Chat.h/Config.h/Player.h/ScriptMgr.h`). No `mod-ale` needed.
  - No playerbots conflict point: it hooks the vendor interaction for the human player; bots manage their own inventory via playerbots and do not open NPC vendor gossip the way this module listens. No shared global hooks, no LFG/teleport touch.
  - No DB schema change; no compile dependency beyond core.
- **SQL:** none shipped. Nothing to apply.
- **Conf seed:** `custom/conf-seed/etc/modules/mod_junk_to_gold_plus.conf`
  - Master switch: `JunkToGoldPlus.Enable = 1` (enabled).
  - `JunkToGoldPlus.EnableSaleChat = 1`.
- **Player-visible text:** none in SQL (chat strings are compiled in English in the .cpp; trivial to localize later if desired).
- **Notes:** clean, small, low-risk. Drop-in.

---

## 2. wow-mod-accountwide-pets — account-shared companion pets

- **Upstream:** https://github.com/buildthehomelab/wow-mod-accountwide-pets
- **HEAD:** `9af469be6566161934958a463c091e4248527b26` (branch `main`)
- **Last commit:** 2026-10-26 — very actively maintained.
- **Vendored to:** `modules/wow-mod-accountwide-pets`
- **Structure:** no `include.sh`, no module-level `CMakeLists.txt`; ships `src/` (`AccountWidePets.cpp` + `mod_accountwide_pets_loader.cpp`). Core still auto-globs `src/**`.
  - Upstream loader symbol: `Addmod_accountwide_petsScripts()` (written for upstream folder `mod-accountwide-pets`).
  - **Renamed at vendor time** to `Addwow_mod_accountwide_petsScripts()` to match vendored folder `wow-mod-accountwide-pets` (→ `wow_mod_accountwide_pets`). Comment in the loader updated accordingly.
- **What it does:** when one character on an account learns a companion (non-combat) pet, the module records it in an `accountwide_pets` table and teaches it to the account's other characters on next login. Shares the table with warblups/mod-accountwide (pets subset split out).
- **Compatibility:**
  - No Eluna / Lua server-side. Pure C++ core script. No `mod-ale` dependency.
  - **Playerbots coexistence — explicitly designed in:** the module detects bot sessions at compile time via `WorldSession::IsHeadless()` (newer AC) / `IsBot()` (older playerbots forks) and **skips bots both ways** — bots neither record pets nor receive taught pets. The code comment calls this out by name ("With thousands of random bots, teaching them pets on every login would only cost time"). No conflict with playerbots' own pet/summon AI.
  - Touches the pet data plane only through its own `accountwide_pets` table + login spell-teach path; it does not modify playerbots' companion memory.
- **SQL:** `sql/modules/wow-mod-accountwide-pets/characters/mod_accountwide_pets_2026_09_25_00.sql` → apply to **characters** DB. Creates `accountwide_pets(account_id, spell)` if absent. Pure DDL.
- **Conf seed:** `custom/conf-seed/etc/modules/mod_accountwide_pets.conf`
  - `AccountWidePets.Enable = 1` (master switch, enabled).
  - `AccountWidePets.RespectItemRestrictions = 1` (keep faction/race-locked pets on their faction).
- **Player-visible text:** none (pure DDL + silent spell learning). No localization needed.
- **Notes:** clean, modern, bot-aware. Drop-in.

---

## 3. mod-dungeonmaster — gossip dungeon/raid teleporter NPC

- **Upstream:** https://github.com/bewarellamas/mod-dungeonmaster
- **HEAD:** `07638d584a52e916deaf99d36ce4a40799a1065d` (branch `main`)
- **Last commit:** 2024-12-07 — **stale (~22 months inactive)**, single merged PR since. Functional but unmaintained; treat as legacy.
- **Vendored to:** `modules/mod-dungeonmaster`
- **Structure:** old-style. `include.sh` + `src/DM_loader.cpp` + `src/Dungeonmaster.cpp`. No module CMakeLists.
  - Loader symbol: `Addmod_dungeonmasterScripts()` — **matches** folder `mod-dungeonmaster`. No rename.
- **What it does:** registers one creature `CreatureScript("npc_dungeonmaster")` (NPC "Dungeon Dan", entry 197762). On gossip it presents a nested menu of dungeons/raids by expansion; selecting one looks up `areatrigger_teleport` and calls `player->TeleportTo(map,x,y,z,o)` on the **clicking human player**.
- **Compatibility — LFG conflict verdict (the key question):**
  - **No conflict with playerbots' LFG.** The module does not touch the LFG system at all: no `LFGScripts`, no queue/proposal/role-check hooks, no LFG teleport, no group-forming, no bot AI. It is a manual, per-click portal NPC that calls the low-level `Player::TeleportTo()` for the human who opened the gossip.
  - playerbots' LFG operates in a completely separate layer (bot AI queuing bots through the real LFG system and teleporting groups into instances). They share only the generic `Player::TeleportTo()` core method, with no shared state or hook. No symbol collision, no double-teleport.
  - No Eluna/Lua. Standard gossip headers (`ScriptedGossip.h`, `GossipDef.h`) — should compile against current AC.
  - **Caveats (legacy, not blocking but flag):**
    1. `TeleportToDungeon()` dereferences the `areatrigger_teleport` pointer **without a null check**; the enum passed is a *map id* (e.g. RFC=2230) rather than a guaranteed areatrigger entry. If a given id has no row in `areatrigger_teleport`, this is a null-pointer dereference crash. Operators should verify the menu entries resolve; consider adding a null guard if it crashes.
    2. The shipped `conf` is the AC module-skeleton boilerplate (`MyModule.Enable`) and the **cpp never reads sConfigMgr** — there is no real runtime on/off switch; the NPC is live as soon as the module compiles in.
    3. `sql/world/base/dungeon_npc.sql` uses a long `creature_template` column list plus the newer `creature_template_model` table; verify it applies cleanly against the current world DB schema (it may need column adjustments).
- **SQL:** `sql/modules/mod-dungeonmaster/world/` → apply to **world** DB.
  - `dungeon_npc.sql` — creature_template + model for "Dungeon Dan" (entry 197762, ScriptName `npc_dungeonmaster`).
  - `dungeonmaster_text.sql` — **npc_text ID 197760, English gossip line (player-visible → 需汉化)**: "You want to go to a dungeon? ... not responsible for any death or dismemberment ...".
- **Conf seed:** `custom/conf-seed/etc/modules/mod_dungeonmaster.conf`
  - Switch `MyModule.Enable = 1` set in seed — **non-functional placeholder** (module has no config read; see caveat).
- **Notes:** vendored as-is for the convenience portal NPC. If the areatrigger null-deref proves unstable at runtime, either guard it or remove the offending menu entries; it does not affect the rest of the stack.

---

## 4. wow-mod-forever-journal — retail-style Journal addon (server + client)

- **Upstream:** https://github.com/buildthehomelab/wow-mod-forever-journal
- **HEAD:** `856ae9548760954d81d1f36d7e7c41b221b68e15` (branch `main`)
- **Last commit:** 2026-10-27 — very actively maintained.
- **Vendored to:** `modules/wow-mod-forever-journal`
- **Structure:** no `include.sh`, no module CMakeLists. Server side = `src/` (8 .cpp + Journal.h). Ships a **client Lua addon** under `addon/Journal/`, lore JSON under `data/lore/`, and helper scripts under `tools/`.
  - Upstream loader symbol: `Addmod_forever_journalScripts()`.
  - **Renamed at vendor time** to `Addwow_mod_forever_journalScripts()` to match folder `wow-mod-forever-journal` (→ `wow_mod_forever_journal`).
- **What it does:** builds a retail-style in-game Journal at startup from realm data (DungeonEncounter/LFGDungeons DBCs, instance_encounters, creature/loot templates, quests, achievements). Dungeons/Raids tabs (bosses, abilities, loot with drop chance, quests, lockouts), Collections (mounts/pets/toys), Quests by zone/class/profession, a Directory of service NPCs (`.find` + "Town Guide" spell), and a Lore codex that fills as characters explore. Talks to the client addon over custom `WorldPacket`s.
- **Compatibility:**
  - No server-side Eluna/Lua — the Lua is purely the **client-side addon**; the C++ server uses only standard AC headers (`ChatCommand.h`, `ObjectMgr.h`, `InstanceSaveMgr.h`, `SmartScriptMgr.h`, `WorldPacket.h`, etc.). No `mod-ale` requirement for the server half.
  - **Playerbots:** bot-aware — `Journal.Directory.LearnSpell` teaches the Town Guide spell to characters at login but **explicitly excludes bots**. Read-only over existing world tables; it creates its own `mod_forever_journal_*` tables. No LFG/teleport/group AI overlap with playerbots.
  - Command surface: registers `.find` and `.journal ...`. Does **not** collide with playerbots' `.bot ...` commands.
  - **Build-time caveat:** `Journal.Directory.Enable` warns "never build alongside mod-npc-finder (duplicate `.find` command)". We do not ship mod-npc-finder, so no conflict. It also optionally integrates with mod-individual-progression (`Journal.EraLocks`) — not installed here, harmless.
  - The client addon (`addon/Journal/`) must be distributed to players separately (it is not auto-installed; `sql/portalkeeper_addon.optional.sql` is only for realms using buildthehomelab/Portalkeeper + mod-realm-config, which we do not).
- **SQL:**
  - `sql/modules/wow-mod-forever-journal/characters/` → **characters** DB: `mod_forever_journal_lore_2026_10_16_00.sql` (creates `mod_forever_journal_lore_known`, `mod_forever_journal_book_read`).
  - `sql/modules/wow-mod-forever-journal/world/` → **world** DB: base tables/seed (`mod_forever_journal_2026_10_06_00`, `_2026_10_14_00/01`, `_2026_10_15_00`, `_2026_10_16_00`), per-zone lore seed (~18 `_lore_<zone>.sql`), and `mod_forever_journal_script_spells.sql`.
  - `sql/modules/wow-mod-forever-journal/uninstall/` → teardown scripts (characters + world).
  - `sql/modules/wow-mod-forever-journal/portalkeeper_addon.optional.sql` → **optional only**, for Portalkeeper/mod-realm-config realms; not applied here.
  - Player-visible text: lore/quest/zone names are data-driven (English seeds in world SQL). Largely read-from-DBC/loot, not chat-string localized; mark for optional Chinese lore tuning later.
- **Conf seed:** `custom/conf-seed/etc/modules/mod_forever_journal.conf`
  - Master switch `Journal.Enable = 1` (enabled). Build-time at startup; most options need a restart to take effect.
  - Other tabs default on: `Journal.Rares=1`, `Journal.Collections.Enable=1`, `Journal.Quests.Enable=1`, `Journal.Directory.Enable=1`, `Journal.Lore.Enable=1`; `Journal.Directory.LearnSpell=1` (bots excepted).
- **Notes:** largest module in this wave. Modern and bot-aware; mainly DB-seed + read-heavy at startup. Ship the client addon to players separately for full effect.

---

## 5. mod-questie-bridge — live server-state bridge to the Questie-335 addon

- **Upstream:** https://github.com/Aldori15/mod-questie-bridge
- **HEAD:** `ad6ebd8fd70270992d0d843f0dc8c73ba924be30` (branch `main`)
- **Last commit:** 2026-10-09 — actively maintained (WotLK 3.3.5).
- **Vendored to:** `modules/mod-questie-bridge`
- **Structure:** old-style native glob. No module `CMakeLists.txt`, no `include.sh`; ships `src/loader.cpp` + 13 `.cpp/.h`. Core auto-globs `modules/*/src/**`.
  - Loader symbol: `Addmod_questie_bridgeScripts()` — **matches** folder `mod-questie-bridge`. No rename.
- **What it does:** exposes live WotLK server state to the Questie quest-helper addon (holidays/fishing tourney/Scourge Invasion/Quel'Danas unlocks, daily/weekly quest pools, ICC weekly quests, Wintergrasp control, weekly/monthly reset deadlines, zone phase-dependent questgiver positions, moving questgiver/transport markers, and live quest XP/rep/money rates). The human player must also install the matching [Questie-335](https://github.com/Aldori15/Questie) addon; `/qserver` confirms the link.
- **Data plane / player-visible surface:** read-only over existing worldstate / quest-pool / phase / NPC-position data. It does **not** install SQL and does not change quest rewards, requirements, or reset timers; players without the addon are unaffected.
- **Compatibility:**
  - No Eluna/Lua (pure C++). No mod-ale dependency.
  - No playerbots conflict: it pushes data to the client addon only on behalf of a logged-in human session; bots are headless and run no Questie addon. Worldstate/pool reads are shared-read, not write. No LFG/group/loot hooks.
- **SQL:** none.
- **Conf seed:** `custom/conf-seed/etc/modules/questie_bridge.conf`
  - Master switch `QuestieBridge.Enabled = 1` (enabled); all sub-features (`Events/WorldStates/Progress/Kaluak/QuestPools/Wintergrasp/ICC/Resets/Phases/Patrols/QuestXP/QuestReputation/QuestMoney`) default 1. Reloadable via `.reload config`.
- **Player-visible text:** none in SQL (addon-side strings live in the client addon, not the server).
- **Notes:** optional addon companion; safe to leave on. Function is inert for players who do not run the addon.

---

## 6. mod-autobalance — classic instance player-count stat scaling

- **Upstream:** https://github.com/azerothcore/mod-autobalance (official)
- **HEAD:** `1d707cb61a0962ab01e4123681e2d3b66cc558a2` (branch `master`)
- **Last commit:** 2026-10-07 — actively maintained.
- **Vendored to:** `modules/mod-autobalance`
- **Structure:** old-style. `include.sh` (empty) + `src/` (~30 files). No module CMakeLists.
  - Loader symbol: `Addmod_autobalanceScripts()` — **matches** folder `mod-autobalance`. No rename.
- **What it does:** scales enemy health/mana/armor/damage (and optionally CC duration and XP/money) inside dungeons/raids based on the number of players present, plus dynamic level scaling. Lets a small group (or solo+followers) enter content tuned for larger groups.
- **Compatibility / playerbots co-tuning (the key point):**
  - No Eluna/Lua. Standard AC map/creature/unit scripts.
  - **Player count includes bots.** Bots inherit `Player` and are present in the map, so a human + N bots already drives AutoBalance's player-count curve — this is the desired behavior for a playerbots setup. With defaults `AutoBalance.MinPlayers = 1`, a 1-human + 5-bot heroic dungeon is treated as ~6 players and scaled accordingly.
  - **Tuning knobs for playerbots (in `autobalance.conf`):**
    - `AutoBalance.Enable.Global = 1` master on.
    - `AutoBalance.MinPlayers = 1` / `AutoBalance.MinPlayers.Heroic = 1` / `.Raid = 1` — floor at 1 so solo+bot groups still scale down correctly.
    - `AutoBalance.playerCountDifficultyOffset = 0` — if bots over-inflate perceived group size, nudge this negative to compensate; start at 0 and measure.
    - `AutoBalance.RewardScaling.Method = "dynamic"` and `AutoBalance.RewardScaling.XP = 1` — XP/money already scale with applied enemy multiplier, so XP is not trivially farmed by buffed groups.
    - `AutoBalance.Enable.5M/10M/25M/40M/... = 1` per-size toggles default on; turn off sizes you never run.
  - No direct hook overlap with mod-playerbots' loot or combat AI; it only reads map player counts and mutates creature stat modifiers.
- **SQL:** none shipped.
- **Conf seed:** `custom/conf-seed/etc/modules/autobalance.conf`
  - Master `AutoBalance.Enable.Global = 1` (enabled); per-difficulty enables default 1. See tuning knobs above for the playerbot联调 keys.
- **Player-visible text:** none in SQL (login announcement string compiled in English; `AutoBalanceAnnounce.enable = 1`).
- **Notes:** official AC module. The main operator decision is how much the bot-driven player count should count toward scaling; verify in a live dungeon before tuning inflection/stat multipliers.

---

## 7. mod-solocraft — solo-character stat scaling in instances (replaces Galuur Lua port)

- **Upstream chosen (C++ port):** https://github.com/azerothcore/mod-solocraft (official)
- **HEAD:** `59588838988d1b74111d26670d99d0e649014b93` (branch `master`)
- **Last commit:** 2026-09-21 — actively maintained.
- **Vendored to:** `modules/mod-solocraft`
- **Structure:** old-style. `include.sh` + `src/` (`Solocraft.cpp`, `SC_loader.cpp`, `utils/`).
  - Loader symbol: `Addmod_solocraftScripts()` — **matches** folder `mod-solocraft`. No rename.
- **What it does:** buffs the entering player's stats/spell power in dungeons/raids as if they had a full group, with per-instance difficulty, per-class balance weights, and XP balancing. WotLK-aware (includes Death Knight and all WotLK dungeons/raids incl. ICC).
- **Replacement decision (important):** the originally specified **Galuur/mangos_solocraft** Lua script (`087454e4ffee37e5ee8f4025a6d9e597424a572e`, "Create LICENSE" 2026-03-02) was evaluated as **not runnable under mod-ale** and was NOT vendored:
  1. Its entire mechanic rests on `player:AddPctStatModifier(stat, type, amount, apply)` — a MaNGOS-Zero-Eluna-specific extension. Static audit of `modules/mod-ale/src/LuaEngine/methods/PlayerMethods.h` + `UnitMethods.h` found **no such binding** (mod-ale exposes `GetStat`, `GetPowerType`, but no Lua-callable stat-percent modifier). The buff would be a no-op / runtime error.
  2. It is written for **MaNGOS Zero / Vanilla 1.12**: class table omits Death Knight, and the instance table lists only vanilla maps. This repo is WotLK 3.3.5, so even if the API existed, WotLK content would be unscaled.
  3. Event IDs used (Login=3, Logout=4, GiveXP=12, MapChange=28, MapPlayerLeave=22) do coincidentally match mod-ale's `Hooks.h` enum, so the registration side is fine — but the missing stat API is a hard blocker.
  - Per task rule, replaced with the **official AzerothCore C++ port** (this entry). Deliberately **not** trickerer/mod-solocraft, which targets NPCBots and would conflict with playerbots.
- **Compatibility:**
  - No Eluna/Lua. Standard C++.
  - Playerbots: solocraft buffs the entering human by group size. Bots in the human's group count toward group size, so the buff automatically weakens as more followers join — desired. No loot/combat-AI hook overlap.
  - Note overlap with mod-autobalance: both scale difficulty in instances. They can coexist (autobalance scales enemy stats downward for small groups; solocraft buffs the player upward). If both feel too generous together, lower `SoloCraft.Stats.Mult`/`SoloCraft.Spellpower.Mult` or set `AutoBalance.Enable.Global = 0` for the solo path.
- **SQL:**
  - `sql/modules/mod-solocraft/db-characters__mod_solo_craft.sql` → **characters** DB: creates `custom_solocraft_character_stats(GUID, Difficulty, GroupSize, SpellPower, Stats, NoXP)`.
  - `sql/modules/mod-solocraft/db-world__mod_solo_craft.sql` → **world** DB: inserts custom `spell_dbc` row Id 150000 ("Solocraft Mod Stats Percentage", internal aura used to apply buffs). Not player-facing flavor text.
- **Conf seed:** `custom/conf-seed/etc/modules/solocraft.conf`
  - Master `Solocraft.Enable = 1` (enabled), `Solocraft.Announce = 1`.
  - `SoloCraft.Stats.Mult = 100.0`, `SoloCraft.Spellpower.Mult = 1.0`, `Solocraft.XP.Enabled = 1`, `Solocraft.XPBal.Enabled = 1`. Per-class weights all 100.
- **Player-visible text:** login/buff broadcast strings are compiled in English (e.g. "[Solocraft] ..."). No SQL-localized strings; trivial to localize later.
- **Notes:** Galuur Lua kept only as reference under `.wow-build-tmp/fetch/mangos_solocraft/` (scratch, gitignored).

---

## 8. mod-aoe-loot — one-click area loot over nearby corpses

- **Upstream:** https://github.com/azerothcore/mod-aoe-loot (official)
- **HEAD:** `44486b1aecebd86944ce115972b3c839544903d3` (branch `master`)
- **Last commit:** 2026-10-10 — actively maintained.
- **Vendored to:** `modules/mod-aoe-loot`
- **Structure:** old-style. `include.sh` + `src/` (`aoe_loot.cpp/.h`, `aoe_loot_loader.cpp`).
  - Loader symbol: `Addmod_aoe_lootScripts()` — **matches** folder `mod-aoe-loot`. No rename.
- **What it does:** when the human opens a corpse (CMSG_LOOT), it merges loot from all nearby lootable corpses within range into that one window (stacks regular items, pulls quest items directly to bags, sums gold), with quality sorting and group/roll/master-loot safety checks. Per-player toggle via `.aoeloot on/off`.
- **Compatibility / playerbots co-tuning (the key point):**
  - No Eluna/Lua. Hooks client loot packets (`CMSG_LOOT`, `CMSG_LOOT_RELEASE`, `CMSG_AUTOSTORE_LOOT_ITEM`) only.
  - **Bots are unaffected by design:** playerbots loot via internal C++ (they do not emit CMSG_LOOT from a client), so aoe-loot only intercepts the human's loot clicks. Result: the human gets one-click pickup over a pack of mobs (including group-cleared corpses the bots helped kill), while bots continue their own loot AI. No double-looting — merged rows are marked `is_looted` and corpses are cleared via `AllLootRemovedFromCorpse()`.
  - **Tuning knobs (in `aoe_loot.conf`):**
    - `AOELoot.Enable = 1` master on.
    - `AOELoot.Range = 55.0` — merge radius (5–100). Lower if it vacuum-distant corpses in packed pulls.
    - `AOELoot.Group = 1` — only merge when in a group (recommended with playerbots, since you are usually grouped with bots).
    - `AOELoot.MailEnable = 0` — when on, overflow items that don't fit bags are mailed; leave 0 unless bag space is a common complaint.
  - Group-loot/round-robin/master-loot rows are explicitly reserved (`IsReservedByGroupLootRules`) so bot-group loot rules are not bypassed.
- **SQL:** `sql/modules/mod-aoe-loot/db-world__aoe_loot_module_string.sql` → **world** DB: seeds `module_string` / `module_string_locale` for the `.aoeloot` login and toggle messages.
  - **Player-visible text — already localized:** ships built-in `zhCN` (and zhTW) translations for all 8 module strings; no extra Chinese translation needed.
- **Conf seed:** `custom/conf-seed/etc/modules/aoe_loot.conf`
  - `AOELoot.Enable = 1`, `AOELoot.Message = 1`, `AOELoot.Range = 55.0`, `AOELoot.Group = 1`, `AOELoot.MailEnable = 0`.
- **Notes:** official AC module. Synergizes well with playerbots' AoE pulls — the human no longer clicks every corpse individually.

---

## Wave-2 cross-cutting note (gitignore)

- Vendored modules are untracked by design; `.gitignore` already carries wave-2 negation rules for `mod-questie-bridge`, `mod-autobalance`, `mod-aoe-loot` (lines 173–175).
- **`mod-solocraft` is currently ignored** (matched by `/modules/*` at `.gitignore:8` with no `!modules/mod-solocraft/` negation). Per task scope I did **not** edit `.gitignore`; the orchestrator should add `!modules/mod-solocraft/` alongside the other wave-2 entries when committing.

---

# Wave 2 (batch B) — quest / dungeon-guide / attunement modules

Vendored 2026-10-28 by the second wave agent. Same conventions as the entries
above: shallow clone, `.git` removed, moved into `modules/`, SQL mirrored under
`sql/modules/<name>/` preserving relative structure, conf dist copied verbatim
into `custom/conf-seed/etc/modules/` (all enable switches already ship at their
documented enabled value; left as-is).

## 5. mod-dungeon-quests — dungeon quest guide NPC

- **Upstream:** https://github.com/Hisha/mod-dungeon-quests
- **HEAD:** `fe6456f89354f1ca8169093b6592f74951087400` (branch `main`)
- **Last commit:** 2026-09-11 — actively maintained.
- **Vendored to:** `modules/mod-dungeon-quests`
- **Structure:** modern `src/` layout (`DungeonQuestMgr.*`, `mod_dungeon_quests.cpp`,
  `npc_dungeon_quest_guide.cpp`, `loader.h`). Repo root also ships a legacy-style
  `CMakeLists.txt` using the old `AC_ADD_SCRIPT` / `AC_ADD_SCRIPT_LOADER
  ("DungeonQuests") mechanism — that file is **inert in this core** (this fork
  never includes per-module `CMakeLists.txt`; only optional `<module>.cmake`).
- **Loader-name check:** upstream `src/loader.h` declares only
  `AddDungeonQuestsScripts()`, which does **not** match the core-generated
  `Addmod_dungeon_questsScripts()`. **Adaptation applied without touching
  upstream files:** added vendor shim `src/mod_dungeon_quests_loader.cpp` that
  `#include "loader.h"` and forwards `Addmod_dungeon_questsScripts()` →
  `AddDungeonQuestsScripts()`. Without it the module fails to link.
- **What it does:** a gossip-only NPC "Expedition Coordinator" (custom entry
  14999991, display 24969) spawned at dungeon entrances. At startup it
  auto-discovers which world quests belong to each non-raid dungeon map and
  caches the mapping; talking to the guide lists eligible quests for the map
  you are standing in, applying the core's normal CanTakeQuest/CanAddQuest
  eligibility, plus an "Accept All" button.
- **Compatibility:**
  - Pure AC WotLK API (Config/ObjectMgr/QuestDef/ScriptedGossip/WorldScript/
    CommandScript). No Eluna, no boost, no other module dependency.
  - **No playerbots conflict** — convenience gossip NPC only; does not touch
    quest-item sharing, LFG, or instance entry logic.
  - Requires standard world-DB `creature_template_model` table.
- **SQL:** `sql/modules/mod-dungeon-quests/db-world/base/` (world DB)
  - `mod_dungeon_quest_guide.sql` — stored-procedure reconcile: inserts NPC
    entry 14999991 + display + 66 guide spawns on 51 maps. Run while
    worldserver is stopped; procedure needs CREATE/ALTER ROUTINE + EXECUTE.
  - `mod_dungeon_quest_override.sql` — creates empty override table (no data).
  - **Player-visible text (needs i18n):** NPC name `Dungeon Quest Guide`,
    subname `Expedition Coordinator` (hardcoded English in SQL).
- **Conf seed:** `custom/conf-seed/etc/modules/mod-dungeon-quests.conf`
  (verbatim dist copy). Master switch **`DungeonQuests.Enable = 1`** (enabled);
  `DungeonQuests.Debug = 0`, `DungeonQuests.EnableAcceptAll = 1`.

## 6. mod-attunement-skip — auto raid-attunement items / quests

- **Upstream:** https://github.com/dr1s/mod-attunement-skip
- **HEAD:** `c2ee51ffda86acaec8ab6bc749f1c6a8ff02281f` (branch `master`)
- **Last commit:** 2026-05-23 — actively maintained.
- **Vendored to:** `modules/mod-attunement-skip`
- **Structure:** modern `src/` only (no root CMakeLists.txt, no include.sh):
  `AttunementSkip.*`, `AttunementSkipPlayer.cpp`, `AttunementSkip_loader.cpp`.
- **Loader-name check:** `Addmod_attunement_skipScripts()` — **matches** folder
  name. No adaptation.
- **What it does:** on login and level-up, mails level 60/70 raid-attunement
  items (Drakefire Amulet, Onyxia Scale Cloak, Key to Karazhan, Tempest Key,
  Medallion of Karabor) and auto-completes attunement quests (Naxx40 ×3, SSC
  Cudgel of Kar'desh, Hyjal Vials of Eternity). Items/quest IDs hardcoded in
  `src/AttunementSkip.h`.
- **Compatibility:**
  - Standard PlayerScript hooks (`OnPlayerLogin`, `OnPlayerLevelChanged`),
    MailDraft, quest auto-complete. No Eluna, no boost.
  - README presents it as a companion for `mod-individual-progression`, but it
    works standalone. **No playerbots build conflict**; note bot characters
    also fire `OnPlayerLevelChanged` and would likewise receive the
    mail/quest completion (harmless, expected).
- **SQL:** 无 (module ships no SQL; item/quest IDs are hardcoded).
- **Conf seed:** `custom/conf-seed/etc/modules/mod-attunement-skip.conf`
  (verbatim dist copy). Master switch **`AttunementSkip.Enable = 1`** (enabled);
  per-item / per-quest toggles all `= 1`.
- **Player-visible text (needs i18n):** mail subject `Your Attunement Items`
  and body hardcoded English in `AttunementSkipPlayer.cpp`.

## 7. Acore_RecruitAFriend — Recruit-A-Friend Eluna script

- **Upstream:** https://github.com/55Honey/Acore_RecruitAFriend
- **HEAD:** `d72b80577c05737efb28306cae817f342ecbcf01` (branch `master`)
- **Last commit:** 2025-02-26 — dormant (~20 months, under the 2-year stale
  line; Lua feature, low risk).
- **Vendored to:** `modules/Acore_RecruitAFriend/`
- **Structure:** **pure Eluna Lua** — single `RecruitAFriend.lua` at repo root
  (+ README/license/icon). **No `src/` directory**, so the core's
  `GetModuleSourceList` ignores it at CMake time (by design).
- **Loader-name check:** N/A — not compiled.
- **What it does:** account-linking RvF system: bind recruiter/recruit account
  pairs (`.bindraf` via GM/SOAP, `.raf summon`, `.raf help`), rewards the
  recruiter when the recruit levels.
- **Compatibility:**
  - **Requires Eluna = mod-ale**, already vendored. Script header states
    "requires ElunaLua module" and "add this script to ../lua_scripts/".
  - Uses Eluna custom DB schema `ac_eluna`. Website (acore-cms) integration
    for account-creation binding is optional.
  - **No playerbots conflict** (account-linking / summon feature).
  - **Runtime deployment note:** vendoring the source under `modules/` does
    **not** auto-load it — the `.lua` must be reachable by Eluna at runtime
    (copy into `bin/lua_scripts/` or `custom/lua_scripts/` per this layout).
- **SQL:** 无 (no .sql shipped; `ac_eluna` schema managed by Eluna side).
- **Conf seed:** 无独立 .conf — all options are the inline `Config` table at
  the top of `RecruitAFriend.lua` (customDbName, rewards, min GM rank = 3…).
- **Player-visible text (needs i18n):** `.raf` replies / reward messages are
  inline English/Chinese strings inside `RecruitAFriend.lua`.

## 8. mod-quest-loot-party — quest-item group loot

- **Upstream:** https://github.com/pangolp/mod-quest-loot-party
- **HEAD:** `c3955915c76d5a22a9d25a44482345d368a8de82` (branch `master`)
- **Last commit:** 2026-10-12 — actively maintained.
- **Vendored to:** `modules/mod-quest-loot-party`
- **Structure:** legacy-style `include.sh` + `src/` (`QLP_loader.cpp`,
  `qlp_main.cpp`) — natively supported via the `src/` glob.
- **Loader-name check:** `Addmod_quest_loot_partyScripts()` — **matches**.
  No adaptation.
- **What it does:** when quest loot is filled, normal-quality quest items are
  marked `freeforall` so every party member with the quest active can loot it;
  login announcement via module_string.
- **Compatibility:**
  - Hooks `PlayerScript::OnPlayerBeforeFillQuestLootItem` (from AC PR
    azerothcore/azerothcore-wotlk#16509). **Verified already present in this
    core:** `PlayerScript.h:461` virtual, `PlayerScript.cpp:390-392` dispatch,
    `ScriptMgr.h:370`, call site `LootMgr.cpp:669`. Upstream README's "blocked
    on PR" caveat does not apply here.
  - No Eluna, no boost. **No playerbots build conflict**; the hook also runs
    for bot party members — that is the intended group-loot behavior.
- **SQL:** `sql/modules/mod-quest-loot-party/db-world/base/qlp_2026_04_19_00.sql`
  (world DB) — inserts `module_string` id=1 + 8-locale `module_string_locale`
  row; **already includes zhCN** (`此服务器正在运行 Quest Loot Party 模块`).
  This is the module's only player-visible text.
- **Conf seed:** `custom/conf-seed/etc/modules/mod-quest-loot-party.conf`
  (verbatim dist copy). Master switch **`QuestParty.Enable = true`** (enabled);
  announcement `QuestParty.Message = true`.

## 9. mod-quest-radar — quest objective radar (server + client addon)

- **Upstream:** https://github.com/warblups/mod-quest-radar
- **HEAD:** `f7ce763e48d1c7db1afcd3611f13cd729c9c1b88` (branch `master`)
- **Last commit:** 2026-09-12 — actively maintained.
- **Vendored to:** `modules/mod-quest-radar`
- **Structure:** legacy-style `include.sh` + `src/` (`QuestRadar.*`,
  `QuestRadarLoader.cpp`), plus bundled **client addon** under
  `client-addon/QuestRadar/` (and `server-module-variant/`) and `scrn/`
  screenshots. C++ side natively supported via the `src/` glob.
- **Loader-name check:** `Addmod_quest_radarScripts()` — **matches** (upstream
  author documents the naming rule in a comment). No adaptation.
- **What it does:** reads world tables `quest_poi` / `quest_poi_points`,
  announces nearby quest objectives on quest accept and via `.questradar` /
  `.qr` player commands, and bridges CHAT_MSG_ADDON (`LANG_ADDON`) to the
  bundled minimap addon.
- **Compatibility:**
  - Standard WorldScript/PlayerScript/CommandScript; no Eluna, no boost, no
    other module. **No playerbots conflict** (read-only quest data + chat/
    addon messaging; does not alter quest state).
- **SQL:** 无 (`data/sql/db-world/` holds only `.gitkeep`; relies on stock
  `quest_poi` data already in the world DB).
- **Conf seed:** `custom/conf-seed/etc/modules/mod-quest-radar.conf` (verbatim
  dist copy). Master switch **`QuestRadar.Enable = 1`** (enabled);
  `AnnounceOnAccept = 1`, `MaxObjectivesShown = 3`, `AddonSyncEnabled = 1`.
- **Player-visible text (needs i18n):** chat announce format strings and `.qr`
  replies hardcoded English in `QuestRadar.cpp` / `QuestRadarLoader.cpp`.
- **Notes:** `client-addon/` ships inside the module for reference; players
  who want minimap icons must install that addon client-side.

### Batch B summary

| # | Module | HEAD | Last update | Layout | Loader | Eluna | Playerbots | SQL | Enable key |
|---|---|---|---|---|---|---|---|---|---|
| 5 | mod-dungeon-quests | `fe6456f` | 2026-09-11 | src/ (+inert legacy CMakeLists) | **NO → shim added** (`src/mod_dungeon_quests_loader.cpp`) | no | none | 2 files, `sql/modules/mod-dungeon-quests/db-world/base/` | `DungeonQuests.Enable = 1` |
| 6 | mod-attunement-skip | `c2ee51f` | 2026-05-23 | src/ only | yes | no | none (bots also receive mail) | 无 | `AttunementSkip.Enable = 1` |
| 7 | Acore_RecruitAFriend | `d72b805` | 2025-02-26 (dormant ~20 mo) | pure Lua, no src/ | N/A | **required (mod-ale present)** | none | 无 | 无（Lua 内联 Config） |
| 8 | mod-quest-loot-party | `c395591` | 2026-10-12 | include.sh + src/ | yes | no | none; hook already in core (PR #16509 merged) | 1 file, `sql/modules/mod-quest-loot-party/db-world/base/` | `QuestParty.Enable = true` |
| 9 | mod-quest-radar | `f7ce763` | 2026-09-12 | include.sh + src/ (+client addon) | yes | no | none | 无 | `QuestRadar.Enable = 1` |

---

## SQL 安装状态（2026-10-28 导入 wow-mysql / acore_*）

目标容器 `wow-mysql`（mysql:8.4.13，127.0.0.1:3307）。导入前已对 acore_world / acore_characters 做全库 mysqldump 快照至
`E:\缓存\WOW\.wow-build-tmp\wave2-sql-pre-backup\`（world 79.3 MB / characters 1.6 MB，SHA256 见 `docs/SQL-IMPORT.md`）。
完整逐文件结果、表数前后对比、异常决策见 **`docs/SQL-IMPORT.md`**。

### 逐模块 SQL 导入状态

| 模块 | SQL 文件 | 目标库 | 状态 | 表变化 / 备注 |
|---|---|---|---|---|
| mod-dungeon-quests | `mod_dungeon_quest_guide.sql` + `mod_dungeon_quest_override.sql` | acore_world | ✅ | 存储过程创建→调用→按设计 DROP；creature_template entry 14999991 就位；`mod_dungeon_quest_override` 空表 |
| mod-quest-loot-party | `qlp_2026_04_19_00.sql` | acore_world | ✅ | module_string +1、locale +8（含 zhCN） |
| mod-solocraft | `db-characters__mod_solo_craft.sql` | acore_characters | ✅ | `custom_solocraft_character_stats` |
| mod-solocraft | `db-world__mod_solo_craft.sql` | acore_world | ✅ | spell_dbc Id=150000 |
| mod-aoe-loot | `db-world__aoe_loot_module_string.sql` | acore_world | ✅ | module_string +8、locale +64（含 zhCN）；首导遇 collation 错误，会话级 `SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci` 解决，未改 schema |
| wow-mod-accountwide-pets | `mod_accountwide_pets_2026_09_25_00.sql` | acore_characters | ✅ | `accountwide_pets(account_id, spell)` |
| mod-dungeonmaster | `dungeon_npc.sql` | acore_world | ⛔ 跳过 | `creature_template.scale` 列在迁移后 schema 不存在，按约束不硬改 schema |
| mod-dungeonmaster | `dungeonmaster_text.sql` | acore_world | ✅ | npc_text ID=197760 |
| wow-mod-forever-journal | characters/`mod_forever_journal_lore_2026_10_16_00.sql` | acore_characters | ✅ | `mod_forever_journal_lore_known` + `mod_forever_journal_book_read` |
| wow-mod-forever-journal | world/ 5 个基表 update（2026_10_06/14_00/14_01/15/16） | acore_world | ✅ | 12 个 `mod_forever_journal_*` 表 + seed |
| wow-mod-forever-journal | world/ 15 个 `lore_<zone>.sql` | acore_world | ✅ | lore 398 条、lore_trigger 1101 条 |
| wow-mod-forever-journal | world/`mod_forever_journal_script_spells.sql` | acore_world | ✅ | `mod_forever_journal_script_spell` 4629 行 |
| wow-mod-forever-journal | `portalkeeper_addon.optional.sql` | — | ⛔ 不导入 | 仅 Portalkeeper 环境（任务指定） |
| mod-ah-bot | `mod_auctionhousebot.sql` | acore_world | ✅ | DROP+CREATE，3 行默认 AH 配置 |
| mod-ah-bot | `auctionhousebot_professionItems.sql` | acore_world | ✅ | 3660 行（CREATE 报表已存在，INSERT 正常入库） |
| mod-ah-bot | `z_filter_disabled_and_trash.sql` | acore_world | ✅ | INSERT IGNORE → `mod_auctionhousebot_disabled_items` 11866 行（仅追加模块黑名单，不动既有 world 数据） |
| mod-attunement-skip | 无 SQL | — | — | 模块不发 SQL（item/quest ID 硬编码） |
| Acore_RecruitAFriend | 无 SQL | — | — | 纯 Eluna Lua，无 SQL |
| mod-quest-radar | 无 SQL | — | — | 依赖既有 `quest_poi` 数据 |
| mod-questie-bridge | 无 SQL | — | — | 只读 worldstate，不发 SQL |
| mod-autobalance | 无 SQL | — | — | 模块不发 SQL |
| mod-junk-to-gold-plus | 无 SQL | — | — | 模块不发 SQL |

### 导入前后表数 / 关键行数

| 指标 | 导入前 | 导入后 | Δ |
|---|---:|---:|---:|
| acore_world 表数 | 316 | 329 | +13 |
| acore_characters 表数 | 117 | 121 | +4 |
| acore_auth 表数 | 23 | 23 | 0 |
| acore_playerbots 表数 | 30 | 30 | 0 |
| world.module_string | 59 | 68 | +9 |
| world.module_string_locale | 420 | 492 | +72 |
| characters.playerbots_names（既有汉化） | 201,000 | 201,000 | 0 |
| playerbots.ai_playerbot_texts（既有汉化） | 3,126 | 3,126 | 0 |
| playerbots.playerbots_custom_strategy（既有汉化） | 90 | 90 | 0 |

### 异常摘要

1. **mod-aoe-loot collation**：`utf8mb4_unicode_ci` vs `utf8mb4_0900_ai_ci` 冲突，会话级 `SET NAMES ... COLLATE` 解决，未改 schema。
2. **mod-dungeonmaster dungeon_npc.sql 跳过**：迁移后 `creature_template` 无 `scale` 列，按约束不硬改 schema；NPC 对话文本（npc_text 197760）已导入。
3. **mod-ah-bot professionItems**：CREATE TABLE 报表已存在（基线空表），INSERT 正常入库 3660 行。

编码：全部 SQL 为 UTF-8 无 BOM，无 GBK 转码。详细记录见 `docs/SQL-IMPORT.md`。