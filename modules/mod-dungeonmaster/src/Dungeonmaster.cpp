/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license: https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#include "ScriptMgr.h"
#include "Player.h"
#include "Config.h"
#include "Chat.h"
#include "ObjectMgr.h"
#include "GossipDef.h"
#include "ScriptedGossip.h"

enum zones
{
    DUNGEON_EK = 1,
    DUNGEON_KAL = 2,
    DUNGEON_BC = 3,
    DUNGEON_WOTLK = 4,
    RAID_CLASS = 5,
    RAID_BC = 6,
    RAID_WOTLK = 7

};

enum dungeon
{
    //Classic Dungeons
    RFC = 2230,     //Ragefire Chasm
    VC = 78,        //Deadmines
    WC = 228,       //Wailing Caverns
    SFK = 145,      //Shadowfang Keep
    Stocks = 101,   //Stormwind Stockade
    BFD = 257,      //Blackfathom Deeps
    Gnomer = 324,   //Gnomergan
    SM_GY = 45,     //Scarlet Monastery Graveyard
    SM_Lib = 614,   //Scarlet Monastery Library
    SM_Arm = 612,   //Scarlet Monastery Armory
    SM_Cath = 610,  //Scarlet Monastery Cathedral
    RFK = 244,      //Razorfen Kraul
    MaraP = 3126,   //Maraudon Purple Crystals
    MaraO = 3133,   //Maraudon Orange Crystals
    RFD = 442,      //Razorfen Downs
    DM_W = 3187,    //Dire Maul West
    DM_E = 3183,    //Dire Maul East
    DM_N = 3189,    //Dire Maul North VERIFY
    Scholo = 2567,  //Scholomance
    Ulda = 286,     //Uldaman
    ZF = 924,       //Zul'Farrak
    Strat_L = 2216, //Stratholme Live
    Strat_UD = 2214,//Stratholme Undead
    BRD = 1466,     //Blackrock Depths
    ST = 446,       //Sunken Temple
    BRS = 1468,     //Blackrock Spire (LBRS and UBRS)


    //Classic Raids
    AQ20 = 4008,    //Ruins of Ahn'Qiraj
    AQ40 = 4010,    //Ahn'Qiraj
    MC = 3528,      //Molten Core
    BWL = 3726,     //Blackwing Lair
    ZG = 3928,      //Zul'Gurub

    //Burning Crusade Dungeons
    Ramps = 4150,   //Hellfire Ramparts
    BF = 4152,      //Blood Furnace
    SP = 4365,      //Slave Pens
    UB = 4363,      //Underbog
    MT = 4405,      //Mana Tombs
    AC = 4404,      //Auchenai Crypts
    Durn = 4321,    //Caverns of Time: Old Hillsbrad
    Seth = 4406,    //Sethekk Halls
    SL = 4407,      //Shadow Labyrinth
    SH = 4151,      //Shattered Halls
    Bot = 4467,     //Botanica
    Mech = 4469,    //Mechanar
    SV = 4364,      //Steamvault
    MGT = 4887,     //Magisters' Terrace
    BM = 4320,      //Caverns of Time: Black Morass
    Arca = 4468,     //Arcatraz

    //Burning Crusage Raids
    Kara = 4131,    //Karazan
    Gruul = 4535,   //Gruul's Lair
    Mags = 4153,    //Magtheridon's Lair
    SSC = 4416,     //Serpentshrine Cavern
    TK = 4470,      //Tempest Keep, The Eye
    Hyjal = 4319,   //Caverns of Time: Mount Hyjal
    BT = 4598,      //Black Temple
    SWP = 4889,     //Sunwell Plateau
    ZA = 4738,      //Zul'Aman

    //Wrath Dungeons
    UK = 4745,      //Utgarde Keep
    Nex = 4983,     //Nexus
    AZN = 5117,     //Azjol-Nerub
    ANK = 5215,     //Ahn'kahet
    DTK = 4998,     //Drak'Tharon Keep
    VH = 5209,      //Violet Hold
    GD = 5206,      //Gundrak
    HOS = 5010,     //Halls of Stone
    HOL = 5093,     //Halls of Lightning
    UP = 4747,      //Utgarde Pinnacle
    Occ = 5246,     //The Oculus
    COS = 5150,     //Caverns of Time: Culling of Stratholme
    TOC = 5505,     //Trial of the Champion
    HOR = 5636,     //Halls of Reflection
    POS = 5637,     //Pit of Sauron
    FOS = 5635,     //Forge of Souls

    //Wrath Raids
    Naxx = 5191,    //Naxxramas
    OS = 5243,      //Obsidian Sanctum
    VOA = 5258,     //Vault of Archavon
    EOE = 5290,     //Eye of Eternity
    ULD = 5379,     //Ulduar
    TC = 5503,      //Trial of the Crusader
    Ony = 2848,     //Onyxia
    RS = 5869,      //Ruby Sanctum
    ICC = 5670      //Icecrown Citadel

    //Vault = 107 stormwind vault (unused)
};

uint32 gossip_text = 197760;

// Add player scripts
class DungeonMaster : public CreatureScript
{
public:
    DungeonMaster() : CreatureScript("npc_dungeonmaster") { }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        player->PlayerTalkClass->ClearMenus();

        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "东部王国地下城", GOSSIP_SENDER_MAIN, DUNGEON_EK);
        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "卡利姆多地下城", GOSSIP_SENDER_MAIN, DUNGEON_KAL);
        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "燃烧的远征地下城", GOSSIP_SENDER_MAIN, DUNGEON_BC);
        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "巫妖王之怒地下城", GOSSIP_SENDER_MAIN, DUNGEON_WOTLK);
        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "经典旧世团队副本", GOSSIP_SENDER_MAIN, RAID_CLASS);
        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "燃烧的远征团队副本", GOSSIP_SENDER_MAIN, RAID_BC);
        AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "巫妖王之怒团队副本", GOSSIP_SENDER_MAIN, RAID_WOTLK);



        SendGossipMenuFor(player, gossip_text, creature->GetGUID());
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 Sender, uint32 areaid)
    {
        player->PlayerTalkClass->ClearMenus();
        if (areaid < 20)
        {
            switch (areaid)
            {
            case DUNGEON_EK:
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "死亡矿井", GOSSIP_SENDER_MAIN, VC);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "影牙城堡", GOSSIP_SENDER_MAIN, SFK);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "暴风城监狱", GOSSIP_SENDER_MAIN, Stocks);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "诺莫瑞根", GOSSIP_SENDER_MAIN, Gnomer);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "血色修道院：墓地", GOSSIP_SENDER_MAIN, SM_GY);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "血色修道院：图书馆", GOSSIP_SENDER_MAIN, SM_Lib);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "血色修道院：武器库", GOSSIP_SENDER_MAIN, SM_Arm);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "血色修道院：大教堂", GOSSIP_SENDER_MAIN, SM_Cath);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "通灵学院", GOSSIP_SENDER_MAIN, Scholo);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "奥达曼", GOSSIP_SENDER_MAIN, Ulda);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "斯坦索姆（生者）", GOSSIP_SENDER_MAIN, Strat_L);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "斯坦索姆（亡灵）", GOSSIP_SENDER_MAIN, Strat_UD);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "黑石深渊", GOSSIP_SENDER_MAIN, BRD);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "沉没的神庙", GOSSIP_SENDER_MAIN, ST);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "黑石塔", GOSSIP_SENDER_MAIN, BRS);
                break;

            case DUNGEON_KAL:
                //dm w e n, zf
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "怒焰裂谷", GOSSIP_SENDER_MAIN, RFC);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "哀嚎洞穴", GOSSIP_SENDER_MAIN, WC);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "黑暗深渊", GOSSIP_SENDER_MAIN, BFD);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "剃刀沼泽", GOSSIP_SENDER_MAIN, RFK);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "玛拉顿（橙门）", GOSSIP_SENDER_MAIN, MaraO);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "玛拉顿（紫门）", GOSSIP_SENDER_MAIN, MaraP);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "剃刀高地", GOSSIP_SENDER_MAIN, RFD);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "厄运之槌（西）", GOSSIP_SENDER_MAIN, DM_W);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "厄运之槌（东）", GOSSIP_SENDER_MAIN, DM_E);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "厄运之槌（北）", GOSSIP_SENDER_MAIN, DM_N);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "祖尔法拉克", GOSSIP_SENDER_MAIN, ZF);
                break;

            case RAID_CLASS:
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "熔火之心", GOSSIP_SENDER_MAIN, MC);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "黑翼之巢", GOSSIP_SENDER_MAIN, BWL);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "安其拉废墟", GOSSIP_SENDER_MAIN, AQ20);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "安其拉神殿", GOSSIP_SENDER_MAIN, AQ40);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "祖尔格拉布", GOSSIP_SENDER_MAIN, ZG);
                break;

            case DUNGEON_BC:
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "地狱火城墙", GOSSIP_SENDER_MAIN, Ramps);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "鲜血熔炉", GOSSIP_SENDER_MAIN, BF);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "奴隶围栏", GOSSIP_SENDER_MAIN, SP);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "幽暗沼泽", GOSSIP_SENDER_MAIN, UB);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "法力陵墓", GOSSIP_SENDER_MAIN, MT);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "奥金尼地穴", GOSSIP_SENDER_MAIN, AC);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "时光之穴：旧希尔斯布莱德丘陵", GOSSIP_SENDER_MAIN, Durn);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "塞泰克大厅", GOSSIP_SENDER_MAIN, Seth);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "暗影迷宫", GOSSIP_SENDER_MAIN, SL);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "破碎大厅", GOSSIP_SENDER_MAIN, SH);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "生态船", GOSSIP_SENDER_MAIN, Bot);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "能源舰", GOSSIP_SENDER_MAIN, Mech);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "蒸汽地窟", GOSSIP_SENDER_MAIN, SV);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "魔导师平台", GOSSIP_SENDER_MAIN, MGT);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "时光之穴：黑色沼泽", GOSSIP_SENDER_MAIN, BM);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "禁魔监狱", GOSSIP_SENDER_MAIN, Arca);
                break;

            case RAID_BC:
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "卡拉赞", GOSSIP_SENDER_MAIN, Kara);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "格鲁尔的巢穴", GOSSIP_SENDER_MAIN, Gruul);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "玛瑟里顿的巢穴", GOSSIP_SENDER_MAIN, Mags);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "毒蛇神殿", GOSSIP_SENDER_MAIN, SSC);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "风暴要塞：之眼", GOSSIP_SENDER_MAIN, TK);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "时光之穴：海加尔山", GOSSIP_SENDER_MAIN, Hyjal);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "黑暗神殿", GOSSIP_SENDER_MAIN, BT);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "太阳之井高地", GOSSIP_SENDER_MAIN, SWP);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "祖阿曼", GOSSIP_SENDER_MAIN, ZA);
                break;

            case DUNGEON_WOTLK:
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "乌特加德城堡", GOSSIP_SENDER_MAIN, UK);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "魔枢", GOSSIP_SENDER_MAIN, Nex);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "艾卓-尼鲁布", GOSSIP_SENDER_MAIN, AZN);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "安卡赫特：古代王国", GOSSIP_SENDER_MAIN, ANK);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "达克萨隆要塞", GOSSIP_SENDER_MAIN, DTK);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "紫罗兰监狱", GOSSIP_SENDER_MAIN, VH);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "古达克", GOSSIP_SENDER_MAIN, GD);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "岩石大厅", GOSSIP_SENDER_MAIN, HOS);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "闪电大厅", GOSSIP_SENDER_MAIN, HOL);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "乌特加德之巅", GOSSIP_SENDER_MAIN, UP);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "奥核之眼", GOSSIP_SENDER_MAIN, Occ);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "时光之穴：净化斯坦索姆", GOSSIP_SENDER_MAIN, COS);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "冠军的试炼", GOSSIP_SENDER_MAIN, TOC);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "映像大厅", GOSSIP_SENDER_MAIN, HOR);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "萨隆矿坑", GOSSIP_SENDER_MAIN, POS);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "灵魂熔炉", GOSSIP_SENDER_MAIN, FOS);
                break;

            case RAID_WOTLK:
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "纳克萨玛斯", GOSSIP_SENDER_MAIN, Naxx);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "黑曜石圣殿", GOSSIP_SENDER_MAIN, OS);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "阿尔卡冯的宝库", GOSSIP_SENDER_MAIN, VOA);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "永恒之眼", GOSSIP_SENDER_MAIN, EOE);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "奥杜尔", GOSSIP_SENDER_MAIN, ULD);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "十字军的试炼", GOSSIP_SENDER_MAIN, TC);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "奥妮克希亚的巢穴", GOSSIP_SENDER_MAIN, Ony);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "红玉圣殿", GOSSIP_SENDER_MAIN, RS);
                AddGossipItemFor(player, GOSSIP_ICON_BATTLE, "冰冠堡垒", GOSSIP_SENDER_MAIN, ICC);
                break;
            }
            SendGossipMenuFor(player, gossip_text, creature->GetGUID());
        }





        if (areaid > 20)
        {
            CloseGossipMenuFor(player);
            TeleportToDungeon(player, areaid);

        }

        return true;
    }

    void TeleportToDungeon(Player* player, uint32 areaid)
    {
        AreaTriggerTeleport const* area = sObjectMgr->GetAreaTriggerTeleport(areaid);

        uint32 mapid = area->target_mapId;
        float x = area->target_X;
        float y = area->target_Y;
        float z = area->target_Z;
        float orientation = area->target_Orientation;


        player->TeleportTo(mapid, x, y, z, orientation, 0, nullptr, mapid == player->GetMapId());

    }

};

// Add all scripts in one
void AddMyPlayerScripts()
{
    new DungeonMaster();
}
