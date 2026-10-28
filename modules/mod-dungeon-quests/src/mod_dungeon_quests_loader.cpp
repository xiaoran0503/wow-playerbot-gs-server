/*
 * Vendor shim added during wave-2 vendoring (2026-10-28).
 *
 * Upstream mod-dungeon-quests was written for the legacy AzerothCore module
 * mechanism (its root CMakeLists.txt uses AC_ADD_SCRIPT / AC_ADD_SCRIPT_LOADER
 * "DungeonQuests", and src/loader.h only defines AddDungeonQuestsScripts()).
 *
 * This core auto-globs modules/*/src/ and expects an entry point literally
 * named Add<folder name, '-' -> '_'>Scripts() (see modules/CMakeLists.txt
 * -> ConfigureScriptLoader). For folder "mod-dungeon-quests" that symbol is
 * Addmod_dungeon_questsScripts(), which upstream never declares.
 *
 * This translation unit is the missing wrapper: it includes the upstream
 * loader.h (which no other translation unit includes) and forwards to the
 * upstream entry. No upstream file is modified.
 */

#include "loader.h"

void Addmod_dungeon_questsScripts()
{
    AddDungeonQuestsScripts();
}
