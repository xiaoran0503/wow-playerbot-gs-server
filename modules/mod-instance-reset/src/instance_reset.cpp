#include "instance_reset.h"

/*
* This method is used to override the npc_text
* Without resorting to the database, since it is a module.
* And we want to avoid adding information that is not blizzlike.
*/
void GossipSetText(Player* player, std::string message, uint32 textID)
{
    WorldPacket data(SMSG_NPC_TEXT_UPDATE, 100);
    data << textID;
    for (uint8 i = 0; i < MAX_GOSSIP_TEXT_OPTIONS; ++i)
    {
        data << float(0);
        data << message;
        data << message;
        data << uint32(0);
        data << uint32(0);
        data << uint32(0);
        data << uint32(0);
        data << uint32(0);
        data << uint32(0);
        data << uint32(0);
    }
    player->GetSession()->SendPacket(&data);
}

/*
* 多语言文案助手。
* 依据客户端 DBC 语言返回对应文案；frFR / deDE / koKR 等无译文的语种一律回退英文，
* 与模块原有行为保持一致，避免出现空白提示。
*/
static std::string GetLocalizedText(Player* player, char const* enUS, char const* zhCN, char const* zhTW, char const* esES, char const* ruRU)
{
    switch (player->GetSession()->GetSessionDbLocaleIndex())
    {
        case LOCALE_zhCN:
            return zhCN;
        case LOCALE_zhTW:
            return zhTW;
        case LOCALE_esES:
        case LOCALE_esMX:
            return esES;
        case LOCALE_ruRU:
            return ruRU;
        default:
            return enUS;
    }
}

void InstanceResetAnnouncer::OnPlayerLogin(Player* player)
{
    if (sConfigMgr->GetOption<bool>("instanceReset.Announcer", true))
    {
        std::string message = GetLocalizedText(player,
            "This server is running the |cff4CFF00Instance Reset |rmodule.",
            "本服务器正在运行 |cff4CFF00副本重置 |r模块。",
            "本伺服器正在執行 |cff4CFF00副本重置 |r模組。",
            "Este servidor está ejecutando el módulo |cff4CFF00Instance reset|r",
            "Этот сервер использует модуль |cff4CFF00Перезапуск подземелий|r.");

        ChatHandler(player->GetSession()).SendSysMessage(message);
    }
}

bool InstanceReset::OnGossipHello(Player* player, Creature* creature)
{
    ClearGossipMenuFor(player);
    std::string gossipText = GetLocalizedText(player,
        "I would like to remove my instance saves.",
        "我想清除我的副本进度保存。",
        "我想清除我的副本進度紀錄。",
        "Me gustaría reiniciar mis ids de instancias.",
        "Я бы хотел удалить мои сохраненные подземелья.");
    std::string message = GetLocalizedText(player,
        "Greetings $n. This is an npc that allows you to reset instance ids, allowing you to re-enter, without the need to wait for the reset time to expire. It was developed by the AzerothCore community.",
        "你好，$n。这个 NPC 可以重置你的副本 ID，让你不必等到重置时间到期就能重新进入。由 AzerothCore 社区开发。",
        "你好，$n。這個 NPC 可以重置你的副本 ID，讓你不必等到重置時間到期就能重新進入。由 AzerothCore 社群開發。",
        "Saludos $n. Este es un npc que te permite reiniciar los ids de las instancias, permitiéndote volver a entrar, sin la necesidad de esperar a que se cumpla el tiempo para el reinicio. Fue desarrollado por la comunidad de AzerothCore.",
        "Приветствую, $n. Этот персонаж может удалить список посещенных подземелий, позволив Вам повторно их посетить не дожидаясь времени планового перезапуска. Разработан в AzerothCore community.");

    if (enable)
    {
        switch (transactionType)
        {
            case 0:
            {
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, gossipText, GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 1);
                break;
            }

            case 1:
            {
                if (player->HasItemCount(token, count, true))
                    AddGossipItemFor(player, GOSSIP_ICON_CHAT, gossipText, GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 1);
                else
                    creature->Whisper(GetLocalizedText(player,
                        "You do not have the required items or token.",
                        "你没有所需的物品或徽记。",
                        "你沒有所需的物品或徽記。",
                        "No tienes los objetos o la ficha necesarios.",
                        "У вас нет необходимых предметов или жетона."), LANG_UNIVERSAL, player);
                break;
            }

            case 2:
            {
                if (player->GetMoney() >= money)
                    AddGossipItemFor(player, GOSSIP_ICON_CHAT, gossipText, GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 1);
                else
                    creature->Whisper(GetLocalizedText(player,
                        "You don't have enough money.",
                        "你的钱不够。",
                        "你的錢不夠。",
                        "No tienes suficiente dinero.",
                        "У вас недостаточно денег."), LANG_UNIVERSAL, player);
                break;
            }

            case 3:
            {
                if ((player->HasItemCount(token, count, true)) && ((player->GetMoney() >= money)))
                    AddGossipItemFor(player, GOSSIP_ICON_CHAT, gossipText, GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 1);
                else
                    creature->Whisper(GetLocalizedText(player,
                        "The reset requires a token and money.",
                        "重置需要徽记和金钱。",
                        "重置需要徽記和金錢。",
                        "El reinicio requiere una ficha y dinero.",
                        "Для перезапуска нужны жетон и деньги."), LANG_UNIVERSAL, player);
                break;
            }

            default:
                break;
        }
    }

    GossipSetText(player, message, DEFAULT_GOSSIP_MESSAGE);
    SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
    return true;
}

bool InstanceReset::OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action)
{
    ClearGossipMenuFor(player);
    uint32 diff = 2;

    if (action == GOSSIP_ACTION_INFO_DEF + 1)
    {
        if (!(sConfigMgr->GetOption<bool>("instanceReset.NormalModeOnly", true)))
            diff = MAX_DIFFICULTY;

        for (uint8 i = 0; i < diff; ++i)
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

        std::string creatureWhisper = GetLocalizedText(player,
            "Your instances have been reset.",
            "你的副本进度已被重置。",
            "你的副本進度已被重置。",
            "Sus instancias han sido restablecidas.",
            "Ваши подземелья перезагружены.");

        creature->Whisper(creatureWhisper, LANG_UNIVERSAL, player);

        switch (transactionType)
        {
            case 0: break;

            case 1:
            {
                player->DestroyItemCount(token, count, true);
                break;
            }

            case 2:
            {
                player->ModifyMoney(-money);
                break;
            }

            case 3:
            {
                player->DestroyItemCount(token, count, true);
                player->ModifyMoney(-money);
                break;
            }

            default:
                break;
        }

        CloseGossipMenuFor(player);
    }

    return true;
}

void InstanceResetWorldConfig::OnBeforeConfigLoad(bool /*reload*/)
{
    enable = sConfigMgr->GetOption<bool>("instanceReset.Enable", true);
    transactionType = sConfigMgr->GetOption<uint32>("instanceReset.TransactionType", 0);
    token = sConfigMgr->GetOption<uint32>("instanceReset.TokenID", 49426);
    count = sConfigMgr->GetOption<uint16>("instanceReset.TokenCount", 26);
    money = sConfigMgr->GetOption<uint32>("instanceReset.MoneyCount", 10000000);
}
