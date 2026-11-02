/*
**  Written by MtgCore
**  Rewritten by Poszer & Talamortis https://github.com/poszer/ & https://github.com/talamortis/
**  AzerothCore +2019 http://www.azerothcore.org/
**  Cleaned and made into a module by Micrah https://github.com/milestorme/
*/

#include "npc_services.h"
#include "Chat.h"

bool NpcServices::OnGossipHello(Player* player, Creature* creature)
{
    // Restore Health and Mana
    AddGossipItemFor(player, 10, "|TInterface\\icons\\Spell_Nature_Regenerate:40:40:-18|t 恢复生命与法力", GOSSIP_SENDER_MAIN, 1);
    // 重置副本
    AddGossipItemFor(player, 10, "|TInterface\\icons\\Achievement_BG_winAB_underXminutes:40:40:-18|t 重置副本", GOSSIP_SENDER_MAIN, 2);
    // 重置冷却
    AddGossipItemFor(player, 10, "|TInterface\\icons\\SPELL_HOLY_BORROWEDTIME:40:40:-18|t 重置冷却", GOSSIP_SENDER_MAIN, 3);
    // Leave Combat
    AddGossipItemFor(player, 10, "|TInterface\\icons\\Achievement_BG_AB_defendflags:40:40:-18|t 脱离战斗", GOSSIP_SENDER_MAIN, 4);
    // 移除虚弱
    AddGossipItemFor(player, 10, "|TInterface\\icons\\Spell_Shadow_DeathScream:40:40:-18|t 移除虚弱", GOSSIP_SENDER_MAIN, 5);
    // 修理装备
    AddGossipItemFor(player, 10, "|TInterface\\icons\\INV_Hammer_24:40:40:-18|t 修理装备", GOSSIP_SENDER_MAIN, 6);
    // 重置天赋
    AddGossipItemFor(player, 10, "|TInterface\\icons\\Achievement_WorldEvent_Lunar:40:40:-18|t 重置天赋", GOSSIP_SENDER_MAIN, 7);
    // Open Bank
    AddGossipItemFor(player, 10, "|TInterface/Icons/INV_Misc_Bag_07:40:40:-18|t 银行", GOSSIP_SENDER_MAIN, 8);
    // Open Mailbox
    AddGossipItemFor(player, 10, "|TInterface/Icons/INV_Letter_11:40:40:-18|t 邮箱", GOSSIP_SENDER_MAIN, 9);
    // Learn Dualspec
    AddGossipItemFor(player, 10, "|TInterface/Icons/achievement_general:40:40:-18|t 学习双天赋", GOSSIP_SENDER_MAIN, 10);

    SendGossipMenuFor(player, 1, creature->GetGUID());
    return true;
}

bool NpcServices::OnGossipSelect(Player* player, Creature* /*creature*/, uint32 /*sender*/, uint32 action)
{
    player->PlayerTalkClass->ClearMenus();

    switch (action)
    {
        case 1: // 恢复生命与法力
            CloseGossipMenuFor(player);
            if (player->IsInCombat())
            {
                CloseGossipMenuFor(player);
                ChatHandler(player->GetSession()).SendNotification("你正处于战斗中！");
                return false;
            }
            else if (player->getPowerType() == POWER_MANA)
                player->SetPower(POWER_MANA, player->GetMaxPower(POWER_MANA));

            player->SetHealth(player->GetMaxHealth());
            ChatHandler(player->GetSession()).SendNotification("|cffFFFF00NPC 服务 \n |cffFFFFFF生命值与法力值已恢复！");
            player->CastSpell(player, 31726);
            break;

        case 2: // 重置副本
            CloseGossipMenuFor(player);
            for (uint8 i = 0; i < MAX_DIFFICULTY; ++i)
            {
                BoundInstancesMap const& m_boundInstances = sInstanceSaveMgr->PlayerGetBoundInstances(player->GetGUID(), Difficulty(i));
                for (BoundInstancesMap::const_iterator itr = m_boundInstances.begin(); itr != m_boundInstances.end();)
                {
                    if (itr->first != player->GetMapId())
                    {
                        sInstanceSaveMgr->PlayerUnbindInstance(player->GetGUID(), itr->first, Difficulty(i), true, player);
                        itr = m_boundInstances.begin();
                    }
                    else
                        ++itr;
                }
            }

           ChatHandler(player->GetSession()).SendNotification("|cffFFFF00NPC 服务 \n |cffFFFFFF副本已重置！");
            player->CastSpell(player, 59908);
            return true;
            break;

        case 3: // 重置冷却
            CloseGossipMenuFor(player);
            if (player->IsInCombat())
            {
                CloseGossipMenuFor(player);
                ChatHandler(player->GetSession()).SendNotification("你正处于战斗中！");
                return false;
            }

            player->RemoveAllSpellCooldown();
            ChatHandler(player->GetSession()).SendNotification("|cffFFFF00NPC 服务 \n |cffFFFFFF冷却已重置！");
            player->CastSpell(player, 31726);
            break;

        case 4: // Leave Combat
            CloseGossipMenuFor(player);
            player->CombatStop();
            ChatHandler(player->GetSession()).SendNotification("|cffFFFF00NPC 服务 \n |cffFFFFFF已脱离战斗！");
            player->CastSpell(player, 31726);
            break;

        case 5: // 移除虚弱
            CloseGossipMenuFor(player);
            if (player->HasAura(15007))
                player->RemoveAura(15007);
            ChatHandler(player->GetSession()).SendNotification("|cffFFFF00NPC 服务 \n |cffFFFFFF虚弱已移除！");
            player->CastSpell(player, 31726);
            break;

        case 6: // 修理装备
            CloseGossipMenuFor(player);
            player->DurabilityRepairAll(false, 0, false);
            ChatHandler(player->GetSession()).SendNotification("|cffFFFF00NPC 服务 \n |cffFFFFFF装备已修理完毕！");
            player->CastSpell(player, 31726);
            break;

        case 7: // 重置天赋
            CloseGossipMenuFor(player);
            player->resetTalents(true);
            player->SendTalentsInfoData(false);
            ChatHandler(player->GetSession()).SendNotification("|cffFFFF00NPC 服务 \n |cffFFFFFF天赋已重置！");
            player->CastSpell(player, 31726);
            break;

        case 8:	// BANK
            CloseGossipMenuFor(player);
            player->GetSession()->SendShowBank(player->GetGUID());
            break;

        case 9: // MAIL
            CloseGossipMenuFor(player);
            player->GetSession()->SendShowMailBox(player->GetGUID());
            break;

        case 10: // Learn Dual Talent Specialization
            CloseGossipMenuFor(player);
            if (player->IsInCombat())
            {
                CloseGossipMenuFor(player);
                ChatHandler(player->GetSession()).SendNotification("你正处于战斗中！");
                return false;
            }

            player->learnSpell(63644);
            player->CastSpell(player, 31726);
            player->CastSpell(player, 63624);
            player->learnSpell(63645);
            player->UpdateSpecCount(2);
            ChatHandler(player->GetSession()).SendNotification("|cffFFFF00NPC 服务 \n |cffFFFFFF已成功学习双天赋！");
            return true;
            break;

    }
    return true;
}
