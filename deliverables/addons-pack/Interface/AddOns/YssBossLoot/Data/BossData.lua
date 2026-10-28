
local _, YssBossLoot = ...

local L = LibStub("AceLocale-3.0"):GetLocale("YssBossLoot", true)
local BZ = LibStub("LibBabble-Zone-3.0.01", true):GetLookupTable()


------------------------------------------------------------
-------------------------Map Types--------------------------
------------------------------------------------------------
YssBossLoot.MapTypes = {
	['Dungeon'] = L['Dungeon'],
	['Raid'] = L['Raid'],
	['Battlegrounds'] = BATTLEGROUNDS,
}

YssBossLoot.Ext = {
	"经典旧世副本",
	"外域副本",
	"诺森德副本",
}

------------------------------------------------------------
-------------------------Map Levels--------------------------
------------------------------------------------------------
YssBossLoot.MapLevels = {
	["Dungeon"] = {
		["诺森德副本"] = {
			["The Culling of Stratholme"] = "79|80";
			["Azjol-Nerub"] = "73|73";
			["Halls of Reflection"] = "79|80";
			["Drak'Tharon Keep"] = "74|76";
			["Trial of the Champion"] = "79|80";
			["Utgarde Keep"] = "69|72";
			["Halls of Stone"] = "77|79";
			["Pit of Saron"] = "79|80";
			["The Forge of Souls"] = "79|80";
			["Utgarde Pinnacle"] = "79|80";
			["The Oculus"] = "79|80";
			["Ahn'kahet: The Old Kingdom"] = "73|75";
			["The Nexus"] = "71|73";
			["The Violet Hold"] = "75|77";
			["Halls of Lightning"] = "79|80";
			["Gundrak"] = "76|78";
		};
		["外域副本"] = {
			["The Steamvault"] = "67|75";
			["Shadow Labyrinth"] = "67|75";
			["Auchenai Crypts"] = "65|67";
			["The Blood Furnace"] = "61|63";
			["Hellfire Ramparts"] = "59|62";
			["The Shattered Halls"] = "67|75";
			["Old Hillsbrad Foothills"] = "66|68";
			["Mana-Tombs"] = "64|66";
			["Sethekk Halls"] = "67|68";
			["The Botanica"] = "67|75";
			["The Underbog"] = "63|65";
			["The Mechanar"] = "67|75";
			["The Slave Pens"] = "62|64";
			["The Black Morass"] = "68|75";
			["The Arcatraz"] = "68|75";
			["Magisters' Terrace"] = "70|70";
		};
		["经典旧世副本"] = {
			["Dire Maul"] = "55|65";
			["The Stockade"] = "22|25";
			["Blackrock Spire"] = "57|63";
			["Razorfen Downs"] = "34|37";
			["The Deadmines"] = "17|20";
			["Scarlet Monastery"] = "32|35";
			["Scholomance"] = "55|65";
			["Ragefire Chasm"] = "15|16";
			["Blackfathom Deeps"] = "21|24";
			["Shadowfang Keep"] = "18|21";
			["Razorfen Kraul"] = "24|27";
			["Gnomeregan"] = "25|28";
			["Wailing Caverns"] = "17|20";
			["Uldaman"] = "37|40";
			["Sunken Temple"] = "47|50";
			["Blackrock Depths"] = "53|56";
			["Stratholme"] = "55|65";
			["Maraudon"] = "45|48";
			["Zul'Farrak"] = "43|47";
		};
	};
	["Raid"] = {
		["诺森德副本"] = {
			["Ulduar"] = "80|83";
			["Icecrown Citadel"] = "80|83";
			["The Obsidian Sanctum"] = "80|83";
			["Vault of Archavon"] = "80|83";
			["The Ruby Sanctum"] = "80|83";
			["Onyxia's Lair"] = "80|83";
			["Naxxramas"] = "80|83";
			["Trial of the Crusader"] = "80|83";
			["The Eye of Eternity"] = "80|83";
		};
		["外域副本"] = {
			["The Eye"] = "70|73";
			["Serpentshrine Cavern"] = "70|73";
			["Gruul's Lair"] = "70|73";
			["Karazhan"] = "70|73";
			["Magtheridon's Lair"] = "70|73";
			["Black Temple"] = "70|73";
			["Zul'Aman"] = "70|73";
			["Hyjal Summit"] = "70|73";
			["Sunwell Plateau"] = "70|73";
		};
		["经典旧世副本"] = {
			["Blackwing Lair"] = "60|63";
			["Zul'Gurub"] = "57|63";
			["Ruins of Ahn'Qiraj"] = "60|63";
			["Temple of Ahn'Qiraj"] = "60|63";
			["Molten Core"] = "60|63";
		};
	};
	["Battlegrounds"] = {
		["Strand of the Ancients"] = "71|80";
		["Arathi Basin"] = "20|80";
		["Warsong Gulch"] = "10|80";
		["Isle of Conquest"] = "71|80";
		["Eye of the Storm"] = "61|80";
		["Alterac Valley"] = "51|80";
	};
}

------------------------------------------------------------
----------------------Map Zone ID's--------------------------
------------------------------------------------------------
YssBossLoot.IDs = {}
YssBossLoot.IDs.Dungeon = {
	["The Culling of Stratholme"] = 521,
	["Azjol-Nerub"] = 533,
	["Halls of Reflection"] = 603,
	["Drak'Tharon Keep"] = 534,
	["Trial of the Champion"] = 542,
	["Utgarde Keep"] = 523,
	["Halls of Stone"] = 526,
	["Pit of Saron"] = 602,
	["The Forge of Souls"] = 601,
	["Utgarde Pinnacle"] = 524,
	["The Oculus"] = 528,
	["Ahn'kahet: The Old Kingdom"] = 522,
	["The Nexus"] = 520,
	["The Violet Hold"] = 536,
	["Halls of Lightning"] = 525,
	["Gundrak"] = 530,
	["The Steamvault"] = 727,
	["Shadow Labyrinth"] = 724,
	["Auchenai Crypts"] = 722,
	["The Blood Furnace"] = 725,
	["Hellfire Ramparts"] = 797,
	["The Shattered Halls"] = 710,
	["Old Hillsbrad Foothills"] = 734,
	["Mana-Tombs"] = 732,
	["Sethekk Halls"] = 723,
	["The Botanica"] = 729,
	["The Underbog"] = 726,
	["The Mechanar"] = 730,
	["The Slave Pens"] = 728,
	["The Black Morass"] = 733,
	["The Arcatraz"] = 731,
	["Magisters' Terrace"] = 798,
	["Dire Maul"] = 699,
	["The Stockade"] = 690,
	["Blackrock Spire"] = 721,
	["Razorfen Downs"] = 760,
	["The Deadmines"] = 756,
	["Scarlet Monastery"] = 762,
	["Scholomance"] = 763,
	["Ragefire Chasm"] = 680,
	["Blackfathom Deeps"] = 688,
	["Shadowfang Keep"] = 764,
	["Razorfen Kraul"] = 761,
	["Gnomeregan"] = 691,
	["Wailing Caverns"] = 749,
	["Uldaman"] = 692,
	["Sunken Temple"] = 687,
	["Blackrock Depths"] = 704,
	["Stratholme"] = 765,
	["Maraudon"] = 750,
	["Zul'Farrak"] = 686,
	
}

YssBossLoot.IDs.Raid = {
	["Ulduar"] = 529,
	["Icecrown Citadel"] = 604,
	["The Obsidian Sanctum"] = 531,
	["Vault of Archavon"] = 532,
	["The Ruby Sanctum"] = 609,
	["Onyxia's Lair"] = 718,
	["Naxxramas"] = 535,
	["Trial of the Crusader"] = 543,
	["The Eye of Eternity"] = 527,
	["The Eye"] = 782,
	["Serpentshrine Cavern"] = 780,
	["Gruul's Lair"] = 776,
	["Karazhan"] = 799,
	["Magtheridon's Lair"] = 779,
	["Black Temple"] = 796,
	["Hyjal Summit"] = 775,
	["Sunwell Plateau"] = 789,
	["Blackwing Lair"] = 755,
	["Ruins of Ahn'Qiraj"] = 717,
	["Temple of Ahn'Qiraj"] = 766,
	["Molten Core"] = 696,
    ["Zul'Aman"] = 781,
	["Zul'Gurub"] = 309,
}

YssBossLoot.IDs.Battlegrounds = {
	["Alterac Valley"] = 401,
	["Arathi Basin"] = 461,
	["Eye of the Storm"] = 482,
	["Strand of the Ancients"] = 512,
	["Warsong Gulch"] = 443,
	["Isle of Conquest"] = 540,
}

YssBossLoot.IDs.type = {}
YssBossLoot.IDs.rDungeon = {}
for k, v in pairs(YssBossLoot.IDs.Dungeon) do
	YssBossLoot.IDs.rDungeon[v] = k
	YssBossLoot.IDs.type[v] = 'Dungeon'
end
YssBossLoot.IDs.rRaid = {}
for k, v in pairs(YssBossLoot.IDs.Raid) do
	YssBossLoot.IDs.rRaid[v] = k
	YssBossLoot.IDs.type[v] = 'Raid'
end
YssBossLoot.IDs.rBattlegrounds = {}
for k, v in pairs(YssBossLoot.IDs.Battlegrounds) do
	YssBossLoot.IDs.rBattlegrounds[v] = k
	YssBossLoot.IDs.type[v] = 'Battlegrounds'
end

------------------------------------------------------------
----------------------Map Levels----------------------------
------------------------------------------------------------
YssBossLoot.Levels = {}
YssBossLoot.Levels.Dungeon = {
	["Ahn'kahet: The Old Kingdom"] = 2,
	["Azjol-Nerub"] = {3,2,1},
	["Drak'Tharon Keep"] = 2,
	["Gundrak"] = 1,
	["Halls of Lightning"] = 2,
	["Halls of Stone"] = 1,
	["The Culling of Stratholme"] = {0,1},
	["The Nexus"] = 1,
	["The Oculus"] = 4,
	["The Violet Hold"] = 1,
	["Utgarde Keep"] = 3,
	["Utgarde Pinnacle"] = 2,
	["Trial of the Champion"] = 1,
	["The Forge of Souls"] = 1,
	["Pit of Saron"] = 0,
	["Halls of Reflection"] = 1,
}

YssBossLoot.Levels.Raid = {
	["Icecrown Citadel"] = 8,
	["Naxxramas"] = {5,1,2,3,4,6},
	["The Eye of Eternity"] = 1,
	["The Obsidian Sanctum"] = 0,
	["The Ruby Sanctum"] = 0,
	["Ulduar"] = {0,1,2,4,3,5},
	["Vault of Archavon"] = 1,
	["Trial of the Crusader"] = 2,
}

YssBossLoot.Levels.Battlegrounds = {
	["Alterac Valley"] = 0,
	["Arathi Basin"] = 0,
	["Eye of the Storm"] = 0,
	["Strand of the Ancients"] = 0,
	["Warsong Gulch"] = 0,
	["Isle of Conquest"] = 0,
}

------------------------------------------------------------
-------------------------Map Bosses-------------------------
------------------------------------------------------------
YssBossLoot.Bosses = {}
YssBossLoot.Bosses.Dungeon = { -- format is maplevel1:map1X:map1Y|maplevel2:map2X:map2Y...
	["Hellfire Ramparts"] = {
		["Watchkeeper Gargolmar"]="1:7310:3130",
		["Omor the Unscarred"]="1:3900:2020",
		["Vazruden"]="1:3550:8250",
	},
        ["The Blood Furnace"] = {
		["The Maker"]="1:3840:4160",
		["Broggok"]="1:4320:2140",
		["Keli'dan the Breaker"]="1:5850:4110",
	},
        ["The Slave Pens"] = {
		["Ahune"]="1:3120:5010",
		["Mennu the Betrayer"]="1:4880:2650",
		["Rokmar the Crackler"]="1:5780:4040",
		["Quagmirran"]="1:8190:7690",
	},
        ["The Underbog"] = {
		["Hungarfen"]="1:6920:9000",
		["Ghaz'an"]="1:7830:2860",
		["Swamplord Musel'ek"]="1:4150:2420",
		["The Black Stalker"]="1:2470:4530",
	},
        ["Mana-Tombs"] = {
		["Pandemonius"]="1:4800:2910",
		["Tavarok"]="1:6080:7350",
		["Nexus-Prince Shaffar"]="1:3260:4880",
	},
        ["Auchenai Crypts"] = {
		["Shirrak the Dead Watcher"]="2:4620:6700",
		["Exarch Maladaar"]="2:7380:4950",
	},
        ["Old Hillsbrad Foothills"] = {
		["Lieutenant Drake"]="0:7520:6600",
		["Captain Skarloc"]="0:6930:6910",
		["Epoch Hunter"]="0:5050:3190",
	},
        ["The Steamvault"] = {
		["Hydromancer Thespia"]="1:5420:1330",
		["Mekgineer Steamrigger"]="1:3390:8210",
		["Warlord Kalithresh"]="1:7640:4370",
	},
        ["The Shattered Halls"] = {
		["Grand Warlock Nethekurse"]="1:3330:6160",
		["Blood Guard Porung"]="1:2970:1510",
		["Warbringer O'mrogg"]="1:5380:3430",
		["Warchief Kargath Bladefist"]="1:6730:5450",
	},
        ["The Mechanar"] = {
		["Gatewatcher Gyro-Kill"]="1:4590:5780",
		["Gatewatcher Iron-Hand"]="1:6110:4040",
		["Mechano-Lord Capacitus"]="1:5120:3150",
		["Nethermancer Sepethrea"]="2:4760:1950",
		["Pathaleon the Calculator"]="2:2690:6130",
	},
        ["The Botanica"] = {
		["Commander Sarannis"]="1:4450:2250",
		["High Botanist Freywinn"]="1:2410:2270",
		["Thorngrin the Tender"]="1:0690:4790",
		["Laj"]="1:3410:8630",
		["Warp Splinter"]="1:3410:3650",
	},
        ["Shadow Labyrinth"] = {
		["Ambassador Hellmaw"]="1:2190:3900",
		["Blackheart the Inciter"]="1:2680:7050",
		["Grandmaster Vorpil"]="1:5340:5380",
		["Murmur"]="1:8090:3890",
	},
        ["Sethekk Halls"] = {
		["Darkweaver Syth"]="1:4880:6770",
		["Anzu"]="2:3210:5450",
		["Talon King Ikiss"]="2:3260:2760",
	},
        ["The Black Morass"] = {
		["Medivh"]="0:4790:7430",
	},
        ["The Arcatraz"] = {
		["Zereketh the Unbound"]="1:5910:2360",
		["Wrath-Scryer Soccothrates"]="2:1980:7840",
		["Dalliah the Doomsayer"]="2:3600:7810",
		["Harbinger Skyriss"]="3:6160:3030",
		["Warden Mellichar"]="3:6020:3050",
	},
        ["Magisters' Terrace"] = {
		["Selin Fireheart"]="2:4260:2220",
		["Vexallus"]="2:8350:2640",
		["Priestess Delrissa"]="1:3960:5590",
		["Kael'thas Sunstrider"]="1:0830:5000",
	},
	["Ahn'kahet: The Old Kingdom"] = {
		["Amanitar"]="1:6685:7842",
		["Elder Nadox"]="1:6928:2744",
		["Herald Volazj"]="1:2362:5056|2:3992:5117",
		["Jedoga Shadowseeker"]="1:4827:7343|2:6749:7586",
		["Prince Taldaram"]="1:6279:4959",
	},
	["Drak'Tharon Keep"] = {
		["King Dred"]="1:6093:8657",
		["Novos the Summoner"]="1:6960:4740",
		["The Prophet Tharon'ja"]="2:4754:1345",
		["Trollgore"]="1:5663:1795",
	},
	["Azjol-Nerub"] = {
		["Krik'thir the Gatewatcher"]="3:5027:4470",
		["Hadronox"]="2:4335:5919",
		["Anub'arak"]="1:6203:4839",
	},
	["Gundrak"] = {
		["Drakkari Colossus"]="1:4649:6540",
		["Eck the Ferocious"]="1:2532:7015",
		["Gal'darah"]="1:4657:2781",
		["Moorabi"]="1:3959:4934",
		["Slad'ran"]="1:5372:4886",
	},
	["Halls of Lightning"] = {
		["General Bjarngrim"]="1:4357:3705",
		["Ionar"]="2:6101:7757",
		["Loken"]="2:1924:5202",
		["Volkhan"]="2:3765:2124",
	},
	["Halls of Stone"] = {
		["Krystallus"]="1:4000:6066",
		["Maiden of Grief"]="1:5014:8621",
		["Sjonnir The Ironshaper"]="1:4989:1333",
		["The Tribunal of Ages"]="1:8477:7623",
	},
	["The Culling of Stratholme"] = {
		["Chrono-Lord Epoch"]="2:6571:2550",
		["Infinite Corruptor"]="2:5176:4156",
		["Mal'Ganis"]="2:3229:4606",
		["Meathook"]="2:6166:4898",
		["Salramm the Fleshcrafter"]="2:4681:6017",
	},
	["The Nexus"] = {
		["Anomalus"]="1:6149:2185",
		["Commanders"]="1:1899:5080",
		["Grand Magus Telestra"]="1:2751:4022",
		["Keristrasza"]="1:3611:6771",
		["Ormorok the Tree-Shaper"]="1:5622:7282",
	},
	["The Oculus"] = {
		["Drakos the Interrogator"]="1:4892:7586",
		["Ley-Guardian Eregos"]="4:4714:2087",
		["Mage-Lord Urom"]="3:7066:2756",
		["Varos Cloudstrider"]="2:4608:1917",
	},
	["The Violet Hold"] = {
		["Cyanigosa"]="1:4576:5579",
		["Erekem"]="1:2459:6297",
		["Ichoron"]="1:5598:3961",
		["Lavanthor"]="1:6271:7635",
		["Moragg"]="1:7033:5190",
		["Xevozz"]="1:3343:4691",
		["Zuramat the Obliterator"]="1:2840:3486",
	},
	["Utgarde Keep"] = {
		["Skarvald the Constructor"]="2:5825:6139",
		["Ingvar the Plunderer"]="3:7228:3803",
		["Prince Keleseth"]="1:2881:6272",
	},
	["Utgarde Pinnacle"] = {
		["Gortok Palehoof"]="2:6060:6893",
		["King Ymiron"]="2:4097:5348",
		["Skadi the Ruthless"]="2:6863:3645",
		["Svala Sorrowgrave"]="1:3619:6990",
	},
	["Trial of the Champion"] = {
		["Grand Champions"] = "1:5103:6424",
		["Eadric the Pure"] = "1:6003:5274",
		["Argent Confessor Paletress"] = "1:4203:5274",
		["The Black Knight"] = "1:5103:4124",
	},
	["The Forge of Souls"] = {
		["Bronjahm"] = "1:4349:4995",
		["Devourer of Souls"] = "1:4365:1260",
	},
	["Pit of Saron"] = {
		["Forgemaster Garfrost"] = "0:6766:5518",
		["Krick and Ick"] = "0:4738:4034",
		["Scourgelord Tyrannus"] = "0:4414:2623",
	},
	["Halls of Reflection"] = {
		["The Lich King"] = "1:1007:2756",
		["Marwyn"] = "1:4284:6285",
		["Falric"] = "1:3497:7501",
	},
        ["Blackrock Spire"] = {
		["War Master Voone"] = "1:5232:5486",
		["Bannok Grimaxe"] = "1:4850:5600",
		["Shadow Hunter Vosh'gajin"] = "2:5545:6967",
		["Mother Smolderweb"] = "2:6184:7425",
		["Highlord Omokk"] = "3:3862:5891",
		["Crystal Fang"] = "3:4650:6940",
		["Spirestone Butcher"] = "3:5100:5770",
		["Spirestone Battle Lord"] = "3:4820:5740",
		["Urok Doomhowl"] = "4:4536:5539",
		["Halycon"] = "5:3805:8373",--
		["Ghok Bashguud"] = "5:3500:6750",--
		["Quartermaster Zigris"] = "5:5403:8469",
		["Pyroguard Emberseer"] = "6:3023:2705",
		["Overlord Wyrmthalak"] = "6:5600:5560",
		["General Drakkisath"] = "7:3492:5006",
		["Warchief Rend Blackhand"] = "7:4863:2556", -- Gyth
		["The Beast"] = "7:6432:3142",
		["Solakar Flamewreath"] = "6:3780:3810",
		["Jed Runewatcher"] = "7:3970:2360",
		["Goraluk Anvilcrack"] = "7:2850:2660",
		["Lord Valthalak"] = "7:6150:3710",
		["Spirestone Lord Magus"] = "3:4170:5630",
		["Mor Grayhoof"] = "1:5220:6080",
		["Gizrul the Slavener"] = "5:4100:8340",
		["Burning Felguard"] = "3:6650:5420",
	},
	["Dire Maul"] = {
		["Guard Slip'kik"] = "1:2640:5731",
		["King Gordok"] = "1:3180:2663",
		["Captain Kromcrush"] = "1:3187:4996",
		["Guard Fengus"] = "1:4955:7808",
		["Stomper Kreeg"] = "1:6092:6839",
		["Guard Mol'dar"] = "1:6944:7574",
		["Illyanna Ravenoak"] = "2:2079:7829",
		["Tendris Warpwood"] = "2:3329:5347",
		["Magister Kalendris"] = "3:3379:4463",
		["Immol'thar"] = "4:3492:5752",
		["Prince Tortheldrin"] = "4:6212:2332",
		["Zevrim Thornhoof"] = "5:4387:4772",
		["Hydrospawn"] = "6:5360:7137",
		["Alzzin the Wildshaper"] = "6:5644:2865",
		["Lethtendris"] = "6:5765:7403",
	},
	["Scholomance"] = {
		["Kirtonos the Herald"] = "2:4960:780",
		["Marduk Blackpool"] = "2:4440:6390",
		["Rattlegore"] = "3:3040:6260",
		["Jandice Barov"] = "3:5417:1470",
		["Lorekeeper Polkelt"] = "3:7200:1190",
		["Instructor Malicia"] = "3:7270:8090",
		["Doctor Theolen Krastinov"] = "3:9560:4590",
		["Ras Frostwhisper"] = "4:4060:9320",
		["Lady Illucia Barov"] = "4:6700:620",
		["The Ravenian"] = "4:6760:5220",
		["Lord Alexei Barov"] = "4:8430:3080",
		["Blood Steward of Kirtonos"] = "1:7890:7160",
		["Vectus"] = "2:4830:6620",
		["Darkmaster Gandling"] = "4:6730:3090",
		["Death Knight Darkreaver"] = "3:3150:7050",
		["Kormok"] = "4:4050:7870",
	},
	["Stratholme"] = {
		["Cannon Master Willey"] = "1:0417:5092",
		["Balnazzar"] = "1:2036:8192",
		["Hearthsinger Forresten"] = "1:6200:2590",--1:8470:4540|
		["Fras Siabi"] = "1:5540:6940",
		["Crimson Hammersmith"] = "1:1170:4700",
		["Archivist Galford"] = "1:2718:7489",
		["Malor the Zealous"] = "1:2981:4080",
		["Timmy the Cruel"] = "1:3940:3350",
		["Baron Rivendare"] = "2:3911:2045",
		["Ramstein the Gorger"] = "2:4522:2002",
		["Magistrate Barthilas"] = "2:5673:1565",--|2:6530:7550
		["Nerub'enkan"] = "2:5715:4623",
		["Maleki the Pallid"] = "2:6766:2173",
		["Baroness Anastari"] = "2:7413:4538",
		["Stonespine"] = "2:6200:2510",
		["Skul"] = "1:5750:6950",--|1:7660:5090
		["Stratholme Courier"] = "1:5570:6490",
		["The Unforgiven"] = "1:7100:2180",
		["Postmaster Malown"] = "1:4950:1840",
		["Sothos and Jarien"] = "1:1410:7640",
		["Black Guard Swordsmith"] = "2:7400:5330",

	},
	["Blackrock Depths"] = {
		["Bael'Gar"] = "1:2562:5294",
		["Lord Roccor"] = "1:5610:6090",
		["High Interrogator Gerstahn"] = "1:4756:9236",
		["Ring of Law"] = "1:5062:6317|2:5048:9012",
		["Pyromancer Loregrain"] = "1:5602:6700",
		["Lord Incendius"] = "1:5658:3110",
		["Fineous Darkvire"] = "1:6340:2080",
		["Golem Lord Argelmach"] = "2:3641:6487",
		["General Angerforge"] = "2:3663:8288",
		["Hurley Blackbreath"] = "2:4977:6359",
		--["The Seven"] = "2:5353:2471",
		["Ambassador Flamelash"] = "2:5396:4857",
		["Warder Stilgiss"] = "2:6070:6730",
		["Magmus"] = "2:8023:1161",
		["Emperor Dagran Thaurissan"] = "2:9160:1171",
	},
	["Sunken Temple"] = {
		["Avatar of Hakkar"] = "1:2413:4559",
		["Spawn of Hakkar"] = "3:4970:3260",
		["Morphaz"] = "1:4991:8692",
		["Hazzas"] = "1:4500:8685",
		["Shade of Eranikus"] = "1:6653:8778",
		["Jammal'an the Prophet"] = "1:7604:3770",
		["Ogom the Wretched"] = "1:7840:3770",
		["Gasher"] = "1:5510:5890",
		["Hukku"] = "1:5500:3240",
		["Loro"] = "1:6020:4560",
		["Mijan"] = "1:4480:3260",
		["Zolo"] = "1:4500:5900",
		["Zul'Lor"] = "1:3980:4580",
		["Dreamscythe"] = "1:4550:4550",
		["Weaver"] = "1:5450:4550",
		["Atal'alarion"] = "3:5000:6040",
	},
	["Maraudon"] = {
		["Razorlash"] = "1:1631:3408",
		["Noxxion"] = "1:3592:1011",
		["Lord Vyletongue"] = "1:3783:7105",
		["Tinkerer Gizlock"] = "2:4840:6860",
		["Celebras the Cursed"] = "2:2448:1395",
		["Princess Theradras"] = "2:2590:7872",
		["Landslide"] = "2:4117:4911",
		["Rotgrip"] = "2:3330:7710",
		["Veng"] = "1:4500:1770",
		["Meshlok the Harvester"] = "1:2350:6730",
		["Maraudos"] = "1:5050:5210",
	},
	["Zul'Farrak"] = {
		["Nekrum Gutchewer"] = "0:2938:1704",
		["Hydromancer Velratha"] = "0:3130:4112",
		["Chief Ukorz Sandscalp"] = "0:4400:3520",
		["Witch Doctor Zum'rah"] = "0:4415:1768",
		["Antu'sul"] = "0:6432:2769",
		["Theka the Martyr"] = "0:5260:2620",
		["Sergeant Bly"] = "0:2360:1770",
	},
	["Uldaman"] = {
		["Revelosh"] = "1:5325:7254",
		["The Lost Dwarves"] = "1:5857:9214",
		["Ironaya"] = "1:3698:7393",
		["Obsidian Sentinel"] = "1:2889:6018",
		["Ancient Stone Keeper"] = "1:4749:4420",
		["Galgann Firehammer"] = "1:2661:3249",
		["Grimlok"] = "1:2200:2599",
		["Archaedas"] = "2:5523:5070",
	},
	["Razorfen Downs"] = {
		["Tuten'kash"] = "1:5914:3408",
		["Mordresh Fire Eye"] = "1:8577:4687",
		["Glutton"] = "1:3464:6668",
		["Amnennar the Coldbringer"] = "1:4437:6040",
		["Plaguemaw the Rotting"] = "1:4680:2170",
		["Ragglesnout"] = "1:5290:6720",
	},
	["Scarlet Monastery"] = {
		["Interrogator Vishas"] = "1:7214:5965",
		["Bloodmage Thalnos"] = "1:2434:5624",
		["Houndmaster Loksey"] = "2:2945:8437",
		["Arcanist Doan"] = "2:8343:7446",
		["Herod"] = "3:7860:1086",
		["Scarlet Trainee"] = "3:8560:1986",
		["High Inquisitor Fairbanks"] = "4:5545:2514",
		["High Inquisitor Whitemane"] = "4:4920:1672",
		["Scarlet Commander Mograine"] = "4:4898:2780",
		["Fallen Champion"] = "1:3590:6630",
		["Azshir the Sleepless"] = "1:2830:4340",
		["Ironspine"] = "1:5170:6790",
		["Headless Horseman"] = "1:3170:6170",
	},
	["Gnomeregan"] = {
		["Viscous Fallout"] = "2:7583:4655",
		["Grubbis"] = "1:7750:6680",
		["Electrocutioner 6000"] = "2:2420:6807",
		["Crowd Pummeler 9-60"] = "3:4316:8799",
		["Mekgineer Thermaplugg"] = "4:3130:2961",
		["Dark Iron Ambassador"] = "4:2810:4990",
	},
	["Razorfen Kraul"] = {
		["Roogug"] = "1:6580:4620",
		["Aggem Thorncurse"] = "1:8059:5177",
		["Death Speaker Jargba"] = "1:8740:4160",
		["Overlord Ramtusk"] = "1:5736:3099",
		["Agathelos the Raging"] = "1:790:6820",
		["Charlga Razorflank"] = "1:2185:3089",
		["Blind Hunter"] = "1:1050:3050",
		["Earthcaller Halmgar"] = "1:4870:4580",
	},
	["The Stockade"] = {
		["Dextren Ward"] = "1:2172:2641",
		["Targorr the Dread"] = "1:5005:2130",
		["Hamhock"] = "1:7832:4559",
		["Bazil Thredd"] = "1:8670:5220",
		["Kam Deepfury"] = "1:6930:2850",
		["Bruegal Ironknuckle"] = "1:2900:4370",
	},
	["Blackfathom Deeps"] = {
		["Aku'mai"] = "2:8574:8651",
		["Ghamoo-ra"] = "1:3286:6042",
		["Lorgus Jett"] = "2:3520:4710",
		["Baron Aquanis"] = "2:4080:7200",
		["Old Serra'kis"] = "2:5260:7490",
		["Lady Sarevess"] = "1:1132:3983",
		["Gelihast"] = "1:5434:5704",
		["Twilight Lord Kelris"] = "2:5274:8207",
	},
	["Shadowfang Keep"] = {
		["Rethilgore"] = "1:6666:7236",
		["Fenrus the Devourer"] = "4:5730:4350",
		["Commander Springvale"] = "1:2794:6011",
		["Wolf Master Nandos"] = "6:5910:5300",
		["Baron Silverlaine"] = "2:3026:7679",
		["Razorclaw the Butcher"] = "2:4800:2850",
		["Odo the Blindwatcher"] = "7:5640:8020",
		["Archmage Arugal"] = "6:6400:2000",
		["Deathsworn Captain"] = "7:6300:5260",
		["Valentine's Day Pharmacist"] = "1:4430:5340",
		["Fel Steed"] = "1:3390:6280",
		["Arugal's Voidwalker"] = "4:5430:5370",
	},
	["The Deadmines"] = {
		["Mr. Smite"] = "2:5640:2680",
		["Cookie"] = "2:6353:3751",
		["Captain Greenskin"] = "2:5753:3751",
		["Edwin VanCleef"] = "2:6053:4501",
		["Gilnid"] = "1:6120:6170|2:1238:7584",
		["Sneed"] = "1:4432:8661",
		["Sneed's Shredder"] = "1:5032:8661",
		["Rhahk'Zor"] = "1:3638:6148",
		["Miner Johnson"] = "1:5220:5040",
	},
	["Wailing Caverns"] = {
		["Lord Serpentis"] = "1:6150:5367",
		["Verdan the Everliving"] = "1:5512:4653",
		["Mutanus the Devourer"] = "1:3438:1384",
		["Skum"] = "1:9282:7900",
		["Lady Anacondra"] = "1:3050:4340",
		["Lord Cobrahn"] = "1:1589:5672",
		["Lord Pythas"] = "1:8567:2898",
		["Kresh"] = "1:3850:3490",
		["Deviate Faerie Dragon"] = "1:6620:3460",
	},
	["Ragefire Chasm"] = {
		["Jergosh the Invoker"] = "1:3300:8450",
		["Taragaman the Hungerer"] = "1:4075:5778",
		["Oggleflint"] = "1:5610:3800",
		["Bazzalan"] = "1:4195:8651",
	},
	

}

YssBossLoot.Bosses.Raid = {
	["Icecrown Citadel"] = {
		["Lord Marrowgar"] = "1:3896:6002",
		["Lady Deathwhisper"] = "1:3896:8671",
		["Deathbringer Saurfang"] = "3:5134:2192",
		["Icecrown Gunship Battle"] ="2:4530:5471",--
		["Blood Prince Council"] = "5:5184:1444",--??
		["Blood-Queen Lana'thel"] = "6:5114:4396",--
		["Valithria Dreamwalker"] = "5:7668:7386",--
		["Sindragosa"] = "4:3656:2338",
		["Rotface"] = "5:1980:4196",
		["Festergut"] = "5:1980:6550",
		["Professor Putricide"] = "5:1324:5366",
		["The Lich King"] = "7:4984:5292",
	},
	["The Eye of Eternity"] = {
		["Malygos"] = "1:3853:5000",
	},
	["The Obsidian Sanctum"] = {
		["Sartharion"] = "0:5051:4779",
		["Tenebron"] = "0:4157:4818",
		["Shadron"] = "0:5198:3321",
		["Vesperon"] = "0:5303:6198",
	},
	["The Ruby Sanctum"] = {
		["Halion"] = "0:4925:5388",
		["Saviana Ragefire"] = "0:3647:5367",
		["General Zarithrian"] = "0:4953:8021",
		["Baltharus the Warborn"] = "0:6573:5388",
	},
	["Vault of Archavon"] = {
		["Archavon the Stone Watcher"] = "1:4912:1716",
		["Emalon the Storm Watcher"] = "1:6255:5528",
		["Koralon the Flame Watcher"] = "1:3596:5541",
		["Toravon the Ice Watcher"] = "1:6255:3676",
	},
	["Naxxramas"] = {
		["Patchwerk"] = "1:5395:4216|5:4311:2656",
		["Grobbulus"] = "1:6166:5275|5:4737:3241",
		["Gluth"] = "1:4584:4423|5:3863:2771",
		["Thaddius"] = "1:2645:1503|5:2792:1158",

		["Anub'Rekhan"] = "2:3059:4703|5:5517:2933",
		["Grand Widow Faerlina"] = "2:4397:3620|5:6257:2335",
		["Maexxna"] = "2:6847:1552|5:7610:1193",

		["Instructor Razuvious"] = "3:4268:4581|5:3647:6783",
		["Gothik the Harvester"] = "3:6741:5980|5:5135:7625",
		["The Four Horsemen"] = "3:3019:7696|5:2895:8658",

		["Noth the Plaguebringer"] = "4:3465:5664|5:5692:7394",
		["Heigan the Unclean"] = "4:4973:4581|5:6599:6742",
		["Loatheb"] = "4:7569:2866|5:8162:5710",

		["Sapphiron"] = "6:5663:6759",
		["Kel'Thuzad"] = "6:3659:2270",
	},
	["Ulduar"] = {
		["Flame Leviathan"] = "1:4925:3888",
		["Razorscale"] = "1:5436:2683",
		["Ignis the Furnace Master"] = "1:3830:2671",
		["XT-002 Deconstructor"] = "1:4852:1455",

		["Assembly of Iron"] = "2:1550:5701",
		["Kologarn"] = "2:3724:1248",
		["Algalon the Observer"] = "2:7917:4630",

		["Auriaya"] = "3:5119:5701",
		["Hodir"] = "3:6693:6406",
		["Thorim"] = "3:7187:4873",
		["Freya"] = "3:5322:2306",

		["Mimiron"] = "5:4357:4143",

		["General Vezax"] = "4:5687:6066",
		["Yogg-Saron Battle"] = "4:6806:4070|6:5395:6467",
	},
	["Trial of the Crusader"] = {
		["The Northrend Beasts"] = "1:5103:6424",
		["Lord Jaraxxus"] = "1:4203:5274",
		["Faction Champions"] = "1:6003:5274",
		["The Twin Val'kyr"] = "1:5103:4124",
		["Anub'arak"] = "2:5306:3535",
		["Argent Crusade Tribute Chest"] = "1:550:8650|2:550:8650",
	},
        ["Temple of Ahn'Qiraj"] = {
		["The Bug Family"] = "1:2843:4966",
		["Ouro"] = "1:3032:8157",
		["Princess Huhuran"] = "1:4341:5018",
		["Battleguard Sartura"] = "1:4453:3371",
		["Fankriss the Unyielding"] = "1:6216:2268",
		["Emperor Vek'lor"] = "1:6160:6530",
		["Emperor Vek'nilash"] = "1:6260:7370",
		["Viscidus"] = "1:7217:1807",
		["The Prophet Skeram"] = "2:4592:5165",
		["C'Thun"] = "3:5698:6289",
	},
	["Ruins of Ahn'Qiraj"] = {
		["Moam"] = "0:3291:3664",
		["Ossirian the Unscarred"] = "0:4320:6950",
		["Kurinnaxx"] = "0:5593:3591",
		["General Rajaxx"] = "0:5845:4945",
		["Ayamiss the Hunter"] = "0:6167:9028",
		["Buru the Gorger"] = "0:6993:6226",
	},
	["Molten Core"] = {
		["Garr"] = "1:3095:7002",
		["Gehennas"] = "1:3333:4893",
		["Shazzrah"] = "1:5243:7779",
		["Baron Geddon"] = "1:5516:8482",
		["Ragnaros"] = "1:5586:5471",
		["Lucifron"] = "1:6587:3801",
		["Magmadar"] = "1:6895:2384",
		["Golemagg the Incinerator"] = "1:6853:5858",
		["Majordomo Executus"] = "1:8392:6593",
		["Sulfuron Harbinger"] = "1:8273:8304",
	},
	["Blackwing Lair"] = {
		["Vaelastrasz the Corrupt"] = "1:3312:2783",
		["Razorgore the Untamed"] = "1:4173:6047",
		["Ebonroc"] = "3:3480:2121",
		["Firemaw"] = "3:4620:4305",
		["Broodlord Lashlayer"] = "3:5019:6184",
		["Flamegor"] = "4:3543:3759",
		["Chromaggus"] = "4:3942:7233",
		["Nefarian"] = "4:7028:7275",
	},
	["Zul'Gurub"] = {
		["High Priestess Jeklik"] = "0:3890:7440",
		["High Priest Venoxis"] = "0:5080:5420",
		["Bloodlord Mandokir"] = "0:6019:8003",
		["Gri'lek"] = "0:5973:4644",
		["High Priestess Arlokk"] = "0:4759:2481",
		["Jin'do the Hexxer"] = "0:3157:2481",
		["Hakkar"] = "0:4986:3984",
		["High Priestess Mar'li"] = "0:4840:7740",
		["High Priest Thekal"] = "0:6210:3450",
		["Gahz'ranka"] = "0:5690:3460",
	},
	["Zul'Aman"] = {
		["Akil'zon"] = "0:3501:2284",
		["Nalorakk"] = "0:4097:7684",
		["Jan'alai"] = "0:5544:7103",
		["Halazzi"] = "0:5804:2362",
		["Hex Lord Malacrass"] = "0:7131:5336",
		["Zul'jin"] = "0:9069:5314",
	},
	["The Eye"] = {
		["Al'ar"] = "1:5010:5880",
		["Void Reaver"] = "1:2630:4910",
		["High Astromancer Solarian"] = "1:7390:4900",
		["Kael'thas Sunstrider"] = "1:4990:1430",
	},
	["Sunwell Plateau"] = {
		["M'uru"] = "2:4670:2380|0:6410:3220",
		["Kil'jaeden"] = "2:4600:6200|0:6370:5210",
		["Kalecgos"] = "1:3060:5110|0:3060:5110",
		["Brutallus"] = "1:6600:8630|0:6600:8630",
		["Felmyst"] = "1:6170:8810|0:6170:8810",

		["The Eredar Twins"] = "1:6410:3220|0:6410:3220"
--		["Lady Sacrolash"] = "1:6410:2520|0:6410:2520",
--		["Grand Warlock Alythess"] = "1:6410:3220|0:6410:3220",
	},
	["Serpentshrine Cavern"] = {
		["Hydross the Unstable"] = "1:3640:8480",
		["The Lurker Below"] = "1:4000:5860",
		["Leotheras the Blind"] = "1:4150:2570",
		["Fathom-Lord Karathress"] = "1:5040:1730",
		["Morogrim Tidewalker"] = "1:5950:2640",
		["Lady Vashj"] = "1:7210:5890",
	},
	["Magtheridon's Lair"] = {
		["Magtheridon"] = "1:6900:7410",
	},
	["Karazhan"] = {
		["Attumen the Huntsman"] = "1:4530:8220",
		["Moroes"] = "3:2700:6350",

		["Shadikith the Glider"] = "1:6700:3100",
		["Rokad the Ravager"] = "1:7450:2000",
		["Hyakiss the Lurker"] = "1:4840:3710",

		["Romulo"] = "4:1790:1850",
		["Julianne"] = "4:1790:2650",
		["The Big Bad Wolf"] = "4:1790:3450",
		["The Crone"] = "4:1790:4250",

		["Maiden of Virtue"] = "4:8340:4980",
		["Nightbane"] = "6:4690:9160",
		["The Curator"] = "9:4940:3630",
		["Dust Covered Chest"] = "14:3600:6200",
		["Shade of Aran"] = "10:7170:2620",
		["Terestian Illhoof"] = "11:5260:6970",
		["Netherspite"] = "13:3600:4170",
		["Prince Malchezaar"] = "17:5150:3120",
	},
	["Hyjal Summit"] = {
		["Archimonde"] = "0:7680:3390",
		["Rage Winterchill"] = "0:1150:6290",
		["Anetheron"] = "0:820:6860",
		["Kaz'rogal"] = "0:5560:3760",
		["Azgalor"] = "0:5510:4570",
	},
	["Gruul's Lair"] = {
		["High King Maulgar"] = "1:5510:5750",
		["Gruul the Dragonkiller"] = "1:2020:2860",
	},
	["Black Temple"] = {
		["High Warlord Naj'entus"] = "2:4410:1880",--一进门是第二层地图
		["Supremus"] = "1:6650:4720",
		["Shade of Akama"] = "3:4090:8870",
		["Teron Gorefiend"] = "5:3930:1220",
		["Gurtogg Bloodboil"] = "4:5390:4680",
		["Essence of Anger"] = "4:6160:8530",
		["Mother Shahraz"] = "6:6720:3690",
		["Illidari Council"] = "7:4710:4370",
		["Illidan Stormrage"] = "8:5260:7030",
	},
	["Onyxia's Lair"] = {
		["Onyxia"] = "1:6720:3080",
	},
}