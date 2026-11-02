#include "mod_starterguild.h"
#include "GuildMgr.h"
#include "Log.h"
#include <fmt/format.h>

void StarterGuild::OnPlayerLogin(Player* player)
{
    if (sConfigMgr->GetOption<bool>("StarterGuild.Enable", true))
        if (sConfigMgr->GetOption<bool>("StarterGuild.Announce", true))
            ChatHandler(player->GetSession()).SendSysMessage("本服务器正在运行 |cff4CFF00StarterGuild |r 模块。");
}

void StarterGuild::OnPlayerLevelChanged(Player* player, uint8 previousLevel)
{
    if (sConfigMgr->GetOption<bool>("StarterGuild.Enable", true))
    {
        auto level = sConfigMgr->GetOption<uint8>("StarterGuild.Level", 0);

        if (level > 0 && !player->GetGuild() && (player->GetLevel() == level || (player->GetLevel() > level && previousLevel < level)))
            AddPlayerToGuild(player);
    }
}

void StarterGuild::OnPlayerFirstLogin(Player* player)
{
    if (sConfigMgr->GetOption<bool>("StarterGuild.Enable", true) &&
        ((sConfigMgr->GetOption<uint8>("StarterGuild.Level", 0) == 0) || player->GetLevel() >= sConfigMgr->GetOption<uint8>("StarterGuild.Level", 0)))
        AddPlayerToGuild(player);
}

void StarterGuild::AddPlayerToGuild(Player* player)
{
    auto const GUILD_ID_HORDE = sConfigMgr->GetOption<uint32>("StarterGuild.Horde", 1);
    auto const GUILD_ID_ALLIANCE = sConfigMgr->GetOption<uint32>("StarterGuild.Alliance", 2);

    auto const GUILD_WELCOME_TEXT_HORDE = sConfigMgr->GetOption<std::string>("StarterGuild.HordeWelcomeText", "Lok’tar ogar！欢迎加入部落新手公会 {GUILD}，{PLAYER}。");
    auto const GUILD_WELCOME_TEXT_ALLIANCE =
        sConfigMgr->GetOption<std::string>("StarterGuild.AllianceWelcomeText", "欢迎加入联盟新手公会 {GUILD}，{PLAYER}。为了联盟！");

    Guild* guild = sGuildMgr->GetGuildById(player->GetTeamId() == TEAM_ALLIANCE ? GUILD_ID_ALLIANCE : GUILD_ID_HORDE);

    // If a guild is present, assign the character to the guild; otherwise skip assignment.
    if (!guild)
    {
        ChatHandler(player->GetSession()).SendSysMessage("公会不存在。");
        return;
    }

    if (guild->GetMemberCount() > guildMemberCount)
    {
        ChatHandler(player->GetSession()).SendSysMessage("该公会成员数已超上限。");
        return;
    }

    if (!guild->AddMember(player->GetGUID()))
    {
        LOG_ERROR("starterguild",
            "Failed to add player {} (GUID {}) to guild {} (ID {}).",
            player->GetPlayerName(),
            player->GetGUID().ToString(),
            guild->GetName(),
            guild->GetId());
        ChatHandler(player->GetSession()).SendSysMessage("加入公会失败。");
        return;
    }

    // Inform the player they have joined the guild
    std::string welcome_text = player->GetTeamId() == TEAM_ALLIANCE ? GUILD_WELCOME_TEXT_ALLIANCE : GUILD_WELCOME_TEXT_HORDE;
    std::string guild_name = guild->GetName();
    std::string player_name = player->GetPlayerName();

    welcome_text = fmt::format(fmt::runtime(welcome_text), fmt::arg("GUILD", guild_name), fmt::arg("PLAYER", player_name));

    ChatHandler(player->GetSession()).SendSysMessage(welcome_text);
}
