/*
 * Copyright (C) 2008-2012 TrinityCore <http://www.trinitycore.org/>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

/* ScriptData
Name: ah_bot_commandscript
%Complete: 100
Comment: All ah_bot related commands
Category: commandscripts
EndScriptData */

#include "ScriptMgr.h"
#include "Chat.h"
#include "AuctionHouseBot.h"
#include "Config.h"

#if AC_COMPILER == AC_COMPILER_GNU
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#endif

using namespace Acore::ChatCommands;

class ah_bot_commandscript : public CommandScript
{
private:
    static ItemQualities stringToItemQualities(const char* name, int length)
    {
        // 
        // Translates a string into ItemQualities enum
        // 

        if (strncmp(name, "grey", length) == 0)
        {
            return ITEM_QUALITY_POOR;
        }

        if (strncmp(name, "white", length) == 0)
        {
            return ITEM_QUALITY_NORMAL;
        }

        if (strncmp(name, "green", length) == 0)
        {
            return ITEM_QUALITY_UNCOMMON;
        }

        if (strncmp(name, "blue", length) == 0)
        {
            return ITEM_QUALITY_RARE;
        }

        if (strncmp(name, "purple", length) == 0)
        {
            return ITEM_QUALITY_EPIC;
        }

        if (strncmp(name, "orange", length) == 0)
        {
            return ITEM_QUALITY_LEGENDARY;
        }

        if (strncmp(name, "yellow", length) == 0)
        {
            return ITEM_QUALITY_ARTIFACT;
        }

        return static_cast<ItemQualities>(-1); // Invalid
    }

public:
    ah_bot_commandscript() : CommandScript("ah_bot_commandscript")
    {

    }

    std::vector<ChatCommand> GetCommands() const override
    {
        static std::vector<ChatCommand> commandTable =
        {
            { "ahbotoptions", HandleAHBotOptionsCommand, SEC_GAMEMASTER, Console::Yes }
        };

        return commandTable;
    }

    static bool HandleAHBotOptionsCommand(ChatHandler* handler, const char*args)
    {
        uint32 ahMapID = 0;
        char*  opt     = strtok((char*)args, " ");

        if (!opt)
        {
            handler->PSendSysMessage("语法错误");
            handler->PSendSysMessage("输入 ahbotoptions help 查看选项列表。");

            return false;
        }

        //
        // Commands which does not requires an AH
        //

        int l = strlen(opt);

        if (strncmp(opt, "buyer", l) == 0)
        {
            char* param1 = strtok(NULL, " ");

            if (!param1)
            {
                handler->PSendSysMessage("用法：ahbotoptions buyer $state（0 关 1 开）");
                return false;
            }

            for (AuctionHouseBot* bot: gBots)
            {
                bot->Commands(AHBotCommand::buyer, 0, 0, param1);
            }

            return true;
        }
        else if (strncmp(opt, "seller", l) == 0)
        {
            char* param1 = strtok(NULL, " ");

            if (!param1)
            {
                handler->PSendSysMessage("用法：ahbotoptions seller $state（0 关 1 开）");
                return false;
            }

            for (AuctionHouseBot* bot: gBots)
            {
                bot->Commands(AHBotCommand::seller, 0, 0, param1);
            }

            return true;
        }
        else if (strncmp(opt, "usemarketprice", l) == 0)
        {
            char* param1 = strtok(NULL, " ");

            if (!param1)
            {
                handler->PSendSysMessage("用法：ahbotoptions useMarketPrice $state（0 关 1 开）");
                return false;
            }

            for (AuctionHouseBot* bot : gBots)
            {
                bot->Commands(AHBotCommand::useMarketPrice, 0, 0, param1);
            }

            return true;
        }

        //
        // Retrieve the auction house type
        //

        char* ahMapIdStr = strtok(NULL, " ");

        if (ahMapIdStr)
        {
            ahMapID = uint32(strtoul(ahMapIdStr, NULL, 0));

            switch (ahMapID)
            {
                case 2:
                case 6:
                case 7:
                    break;
                default:
                    opt = NULL;
                    break;
            }
        }

        //
        // Syntax check
        //

        if (!opt)
        {
            handler->PSendSysMessage("语法错误；拍卖行 ID 必须为 2、6 或 7");
            return false;
        }

        //
        // Commands that do requires an AH id to be performed
        //

        if (strncmp(opt, "help", l) == 0)
        {
            handler->PSendSysMessage("拍卖行机器人命令：");
            handler->PSendSysMessage("buyer - 启用/关闭购买机器人");
            handler->PSendSysMessage("seller - 启用/关闭出售机器人");
            handler->PSendSysMessage("usemarketprice - 启用/关闭按市场价出售");
            handler->PSendSysMessage("ahexpire - 清除所有机器人挂单");
            handler->PSendSysMessage("minitems - 设置最低挂单数");
            handler->PSendSysMessage("maxitems - 设置最高挂单数");
            handler->PSendSysMessage("percentages - 设置各品质出售比例");
            handler->PSendSysMessage("minprice - 设置最低价格");
            handler->PSendSysMessage("maxprice - 设置最高价格");
            handler->PSendSysMessage("minbidprice - 设置买家最低出价倍率");
            handler->PSendSysMessage("maxbidprice - 设置买家最高出价倍率");
            handler->PSendSysMessage("maxstack - 设置最大堆叠");
            handler->PSendSysMessage("buyerprice - 设置买家出价策略");
            handler->PSendSysMessage("bidinterval - 设置买家出价间隔");
            handler->PSendSysMessage("bidsperinterval - 设置每次间隔出价数量");

            return true;
        }
        else if (strncmp(opt, "ahexpire", l) == 0)
        {
            if (!ahMapIdStr)
            {
                handler->PSendSysMessage("用法：ahbotoptions ahexpire $ahMapID（2、6 或 7）");
                return false;
            }

            for (AuctionHouseBot* bot: gBots)
            {
                bot->Commands(AHBotCommand::ahexpire, ahMapID, 0, NULL);
            }
        }
        else if (strncmp(opt, "minitems", l) == 0)
        {
            char* param1 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1)
            {
                handler->PSendSysMessage("用法：ahbotoptions minitems $ahMapID（2、6 或 7）$minItems");
                return false;
            }

            for (AuctionHouseBot* bot : gBots)
            {
                bot->Commands(AHBotCommand::minitems, ahMapID, 0, param1);
            }
        }
        else if (strncmp(opt, "maxitems", l) == 0)
        {
            char* param1 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1)
            {
                handler->PSendSysMessage("用法：ahbotoptions maxitems $ahMapID（2、6 或 7）$maxItems");
                return false;
            }

            for (AuctionHouseBot* bot: gBots)
            {
                bot->Commands(AHBotCommand::maxitems, ahMapID, 0, param1);
            }
        }
        else if (strncmp(opt, "percentages", l) == 0)
        {
            char* param1  = strtok(NULL, " ");
            char* param2  = strtok(NULL, " ");
            char* param3  = strtok(NULL, " ");
            char* param4  = strtok(NULL, " ");
            char* param5  = strtok(NULL, " ");
            char* param6  = strtok(NULL, " ");
            char* param7  = strtok(NULL, " ");
            char* param8  = strtok(NULL, " ");
            char* param9  = strtok(NULL, " ");
            char* param10 = strtok(NULL, " ");
            char* param11 = strtok(NULL, " ");
            char* param12 = strtok(NULL, " ");
            char* param13 = strtok(NULL, " ");
            char* param14 = strtok(NULL, " ");

            if (!ahMapIdStr || !param14)
            {
                handler->PSendSysMessage("用法：ahbotoptions percentages $ahMapID（2、6 或 7）$1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14");
                handler->PSendSysMessage("1 灰色材料 2 白色材料 3 绿色材料 4 蓝色材料 5 紫色材料");
                handler->PSendSysMessage("6 橙色材料 7 黄色材料 8 灰色装备 9 白色装备 10 绿色装备 11 蓝色装备");
                handler->PSendSysMessage("12 紫色装备 13 橙色装备 14 黄色装备");

                return false;
            }

            uint32 greytg       = uint32(strtoul(param1 , NULL, 0));
            uint32 whitetg      = uint32(strtoul(param2 , NULL, 0));
            uint32 greentg      = uint32(strtoul(param3 , NULL, 0));
            uint32 bluetg       = uint32(strtoul(param4 , NULL, 0));
            uint32 purpletg     = uint32(strtoul(param5 , NULL, 0));
            uint32 orangetg     = uint32(strtoul(param6 , NULL, 0));
            uint32 yellowtg     = uint32(strtoul(param7 , NULL, 0));
            uint32 greyi        = uint32(strtoul(param8 , NULL, 0));
            uint32 whitei       = uint32(strtoul(param9 , NULL, 0));
            uint32 greeni       = uint32(strtoul(param10, NULL, 0));
            uint32 bluei        = uint32(strtoul(param11, NULL, 0));
            uint32 purplei      = uint32(strtoul(param12, NULL, 0));
            uint32 orangei      = uint32(strtoul(param13, NULL, 0));
            uint32 yellowi      = uint32(strtoul(param14, NULL, 0));

            uint32 totalPercent = greytg + whitetg + greentg + bluetg + purpletg + orangetg + yellowtg + greyi + whitei + greeni + bluei + purplei + orangei + yellowi;

            if (totalPercent == 0 || totalPercent != 100)
            {
                handler->PSendSysMessage("所有比例之和必须等于 100%%");

                return false;
            }

            char param[100] = { 0 };

            strcat(param, param1);
            strcat(param, " ");
            strcat(param, param2);
            strcat(param, " ");
            strcat(param, param3);
            strcat(param, " ");
            strcat(param, param4);
            strcat(param, " ");
            strcat(param, param5);
            strcat(param, " ");
            strcat(param, param6);
            strcat(param, " ");
            strcat(param, param7);
            strcat(param, " ");
            strcat(param, param8);
            strcat(param, " ");
            strcat(param, param9);
            strcat(param, " ");
            strcat(param, param10);
            strcat(param, " ");
            strcat(param, param11);
            strcat(param, " ");
            strcat(param, param12);
            strcat(param, " ");
            strcat(param, param13);
            strcat(param, " ");
            strcat(param, param14);

            for (AuctionHouseBot* bot: gBots)
            {
                bot->Commands(AHBotCommand::percentages, ahMapID, 0, param);
            }
        }
        else if (strncmp(opt, "minprice", l) == 0)
        {
            char* param1 = strtok(NULL, " ");
            char* param2 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1 || !param2)
            {
                handler->PSendSysMessage("用法：ahbotoptions minprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$price");
                return false;
            }

            auto quality = stringToItemQualities(param1, l);

            if (quality != static_cast<ItemQualities>(-1))
            {
                for (AuctionHouseBot* bot: gBots)
                {
                    bot->Commands(AHBotCommand::minprice, ahMapID, quality, param2);
                }
            }
            else
            {
                handler->PSendSysMessage("用法：ahbotoptions minprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$price");
                return false;
            }
        }
        else if (strncmp(opt, "maxprice", l) == 0)
        {
            char* param1 = strtok(NULL, " ");
            char* param2 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1 || !param2)
            {
                handler->PSendSysMessage("用法：ahbotoptions maxprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$price");
                return false;
            }

            auto quality = stringToItemQualities(param1, l);

            if (quality != static_cast<ItemQualities>(-1))
            {
                for (AuctionHouseBot* bot: gBots)
                {
                    bot->Commands(AHBotCommand::maxprice, ahMapID, quality, param2);
                }
            }
            else
            {
                handler->PSendSysMessage("用法：ahbotoptions maxprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$price");
                return false;
            }
        }
        else if (strncmp(opt, "minbidprice", l) == 0)
        {
            char* param1 = strtok(NULL, " ");
            char* param2 = strtok(NULL, " ");

            if (!ahMapIdStr || !param2 || !param2)
            {
                handler->PSendSysMessage("用法：ahbotoptions minbidprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$price");
                return false;
            }

            uint32 minBidPrice = uint32(strtoul(param2, NULL, 0));

            if (minBidPrice < 1 || minBidPrice > 100)
            {
                handler->PSendSysMessage("最低出价倍率必须在 1 到 100 之间");
                return false;
            }

            auto quality = stringToItemQualities(param1, l);

            if (quality != static_cast<ItemQualities>(-1))
            {
                for (AuctionHouseBot* bot: gBots)
                {
                    bot->Commands(AHBotCommand::minbidprice, ahMapID, quality, param2);
                }
            }
            else
            {
                handler->PSendSysMessage("用法：ahbotoptions minbidprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$price");
                return false;
            }
        }
        else if (strncmp(opt, "maxbidprice", l) == 0)
        {
            char* param1 = strtok(NULL, " ");
            char* param2 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1 || !param2)
            {
                handler->PSendSysMessage("用法：ahbotoptions maxbidprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$price");
                return false;
            }

            uint32 maxBidPrice = uint32(strtoul(param2, NULL, 0));

            if (maxBidPrice < 1 || maxBidPrice > 100)
            {
                handler->PSendSysMessage("最高出价倍率必须在 1 到 100 之间");
                return false;
            }

            auto quality = stringToItemQualities(param1, l);

            if (quality != static_cast<ItemQualities>(-1))
            {
                for (AuctionHouseBot* bot: gBots)
                {
                    bot->Commands(AHBotCommand::maxbidprice, ahMapID, quality, param2);
                }
            }
            else
            {
                handler->PSendSysMessage("用法：ahbotoptions maxbidprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$price");
                return false;
            }
        }
        else if (strncmp(opt, "maxstack",l) == 0)
        {
            char* param1 = strtok(NULL, " ");
            char* param2 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1 || !param2)
            {
                handler->PSendSysMessage("用法：ahbotoptions maxstack $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$value");
                return false;
            }

            // uint32 maxStack = uint32(strtoul(param2, NULL, 0));
            // if (maxStack < 0)
            // {
            //     handler->PSendSysMessage("maxstack can't be a negative number.");
            //    return false;
            // }

            auto quality = stringToItemQualities(param1, l);

            if (quality != static_cast<ItemQualities>(-1))
            {
                for (AuctionHouseBot* bot: gBots)
                {
                    bot->Commands(AHBotCommand::maxstack, ahMapID, quality, param2);
                }
            }
            else
            {
                handler->PSendSysMessage("用法：ahbotoptions maxstack $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple/orange/yellow）$value");
                return false;
            }
        }
        else if (strncmp(opt, "buyerprice", l) == 0)
        {
            char* param1 = strtok(NULL, " ");
            char* param2 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1 || !param2)
            {
                handler->PSendSysMessage("用法：ahbotoptions buyerprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple）$price");
                return false;
            }

            auto quality = stringToItemQualities(param1, l);

            if (quality != static_cast<ItemQualities>(-1))
            {
                for (AuctionHouseBot* bot: gBots)
                {
                    bot->Commands(AHBotCommand::buyerprice, ahMapID, quality, param2);
                }
            }
            else
            {
                handler->PSendSysMessage("用法：ahbotoptions buyerprice $ahMapID（2、6 或 7）$color（grey/white/green/blue/purple）$price");
                return false;
            }
        }
        else if (strncmp(opt, "bidinterval", l) == 0)
        {
            char* param1 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1)
            {
                handler->PSendSysMessage("用法：ahbotoptions bidinterval $ahMapID（2、6 或 7）$interval（分钟）");
                return false;
            }

            for (AuctionHouseBot* bot: gBots)
            {
                bot->Commands(AHBotCommand::bidinterval, ahMapID, 0, param1);
            }
        }
        else if (strncmp(opt, "bidsperinterval", l) == 0)
        {
            char* param1 = strtok(NULL, " ");

            if (!ahMapIdStr || !param1)
            {
                handler->PSendSysMessage("用法：ahbotoptions bidsperinterval $ahMapID（2、6 或 7）$bids");
                return false;
            }

            for (AuctionHouseBot* bot: gBots)
            {
                bot->Commands(AHBotCommand::bidsperinterval, ahMapID, 0, param1);
            }
        }
        else
        {
            handler->PSendSysMessage("语法错误");
            handler->PSendSysMessage("输入 ahbotoptions help 查看选项列表。");
            return false;
        }

        handler->PSendSysMessage("完成");
        return true;
    }
};

void AddAHBotCommandScripts()
{
    new ah_bot_commandscript();
}
