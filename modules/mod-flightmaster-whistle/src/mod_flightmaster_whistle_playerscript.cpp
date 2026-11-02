/*
 * Credits: silviu20092
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Chat.h"
#include "flightmaster_whistle.h"

class mod_flightmaster_whistle_playerscript : public PlayerScript
{
public:
    mod_flightmaster_whistle_playerscript() : PlayerScript("mod_flightmaster_whistle_playerscript",
        {
            PLAYERHOOK_ON_LOGIN,
        })
    {
    }

    void OnPlayerLogin(Player* player) override
    {
        if (sFlightmasterWhistle->GetEnabled()
            && sFlightmasterWhistle->GetAddWhistleOnLogin()
            && !sFlightmasterWhistle->IsBot(player)
            && player->GetLevel() >= sFlightmasterWhistle->GetMinPlayerLevel())
        {
            if (!player->HasItemCount(FlightmasterWhistle::WHISTLE_ITEM_ID, 1, true))
            {
                if (player->AddItem(FlightmasterWhistle::WHISTLE_ITEM_ID, 1))
                    ChatHandler(player->GetSession()).PSendSysMessage("你收到了飞行管理员哨子！使用它可以传送到最近的飞行管理员处。");
            }
        }
    }
};

void AddSC_mod_flightmaster_whistle_playerscript()
{
    new mod_flightmaster_whistle_playerscript();
}
