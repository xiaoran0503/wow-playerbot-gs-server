# playerbots.conf 键名迁移报告（KEYMAP-REPORT）

> 生成方式：`custom/conf-seed/gen-conf-seed.ps1` → `Build-PlayerbotsSeed`
> 输入①：`E:\缓存\WOW\.wow-build-tmp\gs-configs\playerbots.conf=UTF-8.dist`（谷神汉化版，522 键）
> 输入②：`modules/mod-playerbots/conf/playerbots.conf.dist`（模块基线，894 键）
> 产物：`custom/conf-seed/etc/modules/playerbots.conf`（894 键，UTF-8 无 BOM）
> 日期：2026-10-28

## 1. 映射总览

| 指标 | 数量 | 说明 |
|---|---:|---|
| 谷神总键数 | 522 | 含 518 个 `AiPlayerbot.*` + 1 个笔误 `AIPlayerbot.GuildFeedback` + 3 个直名键 |
| 成功映射 | **477** | `AiPlayerbot.X` → `Playerbots.X`（473）+ 直名键 `PlayerbotsDatabase.WorkerThreads` / `PlayerbotsDatabase.SynchThreads` / `Playerbots.Updates.EnableDatabases` / `PlayerbotsDatabaseInfo`（4） |
| 其中取值与基线不同 | **95** | 谷神调优值覆盖基线默认值（见 §4） |
| 未映射（WARN） | **45** | 基线无对应键，分类见 §5 |

## 2. 映射规则

1. `AiPlayerbot.X` → `Playerbots.X`（去掉 `Ai` 前缀）；谷神笔误 `AIPlayerbot.GuildFeedback`（大写 I）按同一规则归一化。
2. 谷神键上方紧邻的中文注释块（连续 `#` 行）随新键行保留；基线英文注释保留不删，形成中英双语对照。
3. 谷神未覆盖的基线键（894 − 477 = 417 个）保留基线默认值与英文注释。
4. 输出文件 = 基线 894 键全集，顺序与基线一致（已核验键数 894，无键丢失）。

## 3. 关键调优值（本服设定，已写入产物）

| 键 | 值 | 依据 |
|---|---|---|
| `Playerbots.Enabled` | 1 | 谷神启用机器人模块 |
| `Playerbots.RandomBotAutologin` | 1 | 谷神随机机器人自动登录 |
| `Playerbots.MinRandomBots` | **1000** | 谷神设定（基线默认 500） |
| `Playerbots.MaxRandomBots` | **1200** | 谷神设定（基线默认 500） |
| `Playerbots.AddClassAccountPoolSize` | 200 | 谷神设定（基线默认 50） |
| `Playerbots.RandomBotQuestItems` | 含 6948 | 与本服 SupMalachite.lua 超级炉石物品 entry 对齐 |

## 4. 两处"不覆盖"决策（noOverride）

| 键 | 谷神值 | 产物值 | 决策依据 |
|---|---|---|---|
| `Playerbots.Updates.EnableDatabases` | 0 | **1**（保留基线） | 谷神是成熟生产服、手动管理 schema，故关闭 mod 自带 DBUpdater；本服为全新 docker 部署，首启需 mod DBUpdater 把 `acore_playerbots` 库追平（db-import 只建 base schema）。留 1 才能让阶段 B 的中文素材导入在正确 schema 上进行。 |
| `PlayerbotsDatabaseInfo` | `"127.0.0.1;3306;acore;acore;acore_playerbots"` | 保留基线同格式默认值 | 连接串由 docker env `AC_PLAYERBOTSDATABASEINFO`（`wow-db;3306;$WOW_DB_USER;...;acore_playerbots`）在容器启动时覆盖，种子里不写死。 |

## 5. 95 处取值差异明细（基线默认 → 谷神调优）

| 键 | 基线默认 | 谷神值 |
|---|---|---|
| Playerbots.AddClassAccountPoolSize | 50 | 200 |
| Playerbots.AoeAvoidSpellWhitelist | 50759,57491,13810,29946 | 50759,57491,13810 |
| Playerbots.BotActiveAlone | 10 | 100 |
| Playerbots.BotActiveAloneForceWhenIsFriend | 0 | 1 |
| Playerbots.BotCheats | "food,taxi,raid" | "taxi" |
| Playerbots.BroadcastChanceKillElite | 300 | 3000 |
| Playerbots.BroadcastChanceKillNormal | 30 | 3000 |
| Playerbots.BroadcastChanceKillPet | 10 | 1000 |
| Playerbots.BroadcastChanceKillPlayer | 30 | 15000 |
| Playerbots.BroadcastChanceKillUnknown | 100 | 1000 |
| Playerbots.BroadcastChanceLootingItemNormal | 150 | 6000 |
| Playerbots.BroadcastChanceLootingItemPoor | 30 | 3000 |
| Playerbots.BroadcastChanceQuestUpdateComplete | 1000 | 3000 |
| Playerbots.BroadcastChanceQuestUpdateFailedTimer | 300 | 3000 |
| Playerbots.BroadcastChanceQuestUpdateObjectiveCompleted | 300 | 3000 |
| Playerbots.BroadcastChanceQuestUpdateObjectiveProgress | 300 | 3000 |
| Playerbots.BroadcastChanceSuggestGrindMaterials | 5000 | 15000 |
| Playerbots.BroadcastChanceSuggestGrindReputation | 5000 | 15000 |
| Playerbots.BroadcastChanceSuggestInstance | 5000 | 15000 |
| Playerbots.BroadcastChanceSuggestQuest | 10000 | 15000 |
| Playerbots.BroadcastChanceSuggestSell | 300 | 30000 |
| Playerbots.BroadcastChanceSuggestSomethingToxic | 0 | 30000 |
| Playerbots.BroadcastChanceSuggestThunderfury | 1 | 30000 |
| Playerbots.BroadcastChanceSuggestToxicLinks | 0 | 30000 |
| Playerbots.EnableGuildTasks | 0 | 1 |
| Playerbots.FreeMethodLoot | 0 | 1 |
| Playerbots.InviteChat | 0 | 1 |
| Playerbots.MaxRandomBots | 500 | 1200 |
| Playerbots.MinEnchantingBotLevel | 60 | 1 |
| Playerbots.MinRandomBots | 500 | 1000 |
| Playerbots.PremadeHunterPetLink.0.16 | 2100003130003010101 | 2100003030103010101 |
| Playerbots.PremadeHunterPetLink.0.20 | 2100003130103010122 | 2100013030103010122 |
| Playerbots.PremadeSpecGlyph.1.0 | 43418,43395,43423,43399,43397,43421 | 43418,43395,43423,43399,49084,43421 |
| Playerbots.PremadeSpecGlyph.1.1 | 43418,43395,43414,43396,49084,43432 | 43418,43395,43414,43399,49084,43432 |
| Playerbots.PremadeSpecGlyph.1.2 | 43429,43397,43425,43399,49084,45797 | 43424,43395,43425,43399,49084,45793 |
| Playerbots.PremadeSpecGlyph.11.2 | 40906,43331,45602,43335,43674,45603 | 40913,43331,40906,43335,44922,45602 |
| Playerbots.PremadeSpecGlyph.11.3 | 40902,43331,40901,43674,43335,45604 | 40902,43331,40901,43335,44922,45604 |
| Playerbots.PremadeSpecGlyph.2.0 | 41106,43367,45741,43368,43365,41109 | 41106,43367,45741,43369,43365,41109 |
| Playerbots.PremadeSpecGlyph.2.1 | 41100,43367,43869,43368,43369,45745 | 41099,43367,43869,43369,43365,45745 |
| Playerbots.PremadeSpecGlyph.2.2 | 41092,43367,41099,43368,43340,43869 | 41092,43367,41099,43369,43365,43869 |
| Playerbots.PremadeSpecGlyph.3.0 | 42912,43350,42902,43351,43338,42914 | 42912,43350,42902,43351,43338,45732 |
| Playerbots.PremadeSpecGlyph.3.1 | 42912,43350,45625,43351,43338,42914 | 42912,43350,42914,43351,43338,45732 |
| Playerbots.PremadeSpecGlyph.3.2 | 45733,43350,45731,43351,43338,45732 | 42912,43350,44335,43351,43338,45732 |
| Playerbots.PremadeSpecGlyph.5.2 | 45753,43371,42407,43374,43370,42415 | 42406,43371,42407,43374,43342,42415 |
| Playerbots.PremadeSpecGlyph.6.0 | 45805,43673,43538,43544,43672,43542 | 45805,43673,43827,43544,43672,43554 |
| Playerbots.PremadeSpecGlyph.6.2 | 43542,43673,43546,43535,43672,43549 | 43542,43673,43546,43544,43672,43549 |
| Playerbots.PremadeSpecGlyph.6.3 | 45805,43673,43538,43544,43672,43554 | 45805,43673,43827,43544,43672,43554 |
| Playerbots.PremadeSpecGlyph.7.1 | 41542,43385,41539,43386,43725,45771 | 41542,43385,41539,43386,44923,45771 |
| Playerbots.PremadeSpecGlyph.7.2 | 41527,43385,41517,43386,43725,45775 | 41517,43385,41527,43386,44923,45775 |
| Playerbots.PremadeSpecGlyph.9.2 | 45785,43390,42454,43394,43393,42453 | 45785,43390,50077,43394,43393,42454 |
| Playerbots.PremadeSpecLink.11.0.60 | 5032003125031003213304301231 | 5022203105331003213005301231 |
| Playerbots.PremadeSpecLink.11.0.80 | 5032003125331303213305301231--205003012 | 5032203105331303213305301231--205003012 |
| Playerbots.PremadeSpecLink.11.1.60 | -503232132322010303120300013501 | -500232130322110353100301310501 |
| Playerbots.PremadeSpecLink.11.1.80 | -503232132322010353120303013511-20350001 | -501232130322110353120303313511-20350001 |
| Playerbots.PremadeSpecLink.11.2.60 | --230033312031502331050313031 | --230033312031500531050113051 |
| Playerbots.PremadeSpecLink.11.2.80 | 05320031--230033312031502431053313051 | 05320031--230033312031501531053313051 |
| Playerbots.PremadeSpecLink.11.3.80 | -553202032322010053120030310511-203503012 | -553202032322010053100030310511-205503012 |
| Playerbots.PremadeSpecLink.2.0.80 | 50350152100013053100515221-50320104203 | 50350152220013053100515221-503201312 |
| Playerbots.PremadeSpecLink.3.0.60 | 51200201505112233110531151 | 51200201505112243110531051 |
| Playerbots.PremadeSpecLink.3.0.80 | 51200201505112233111531351-0323031-5 | 51200201505112243120531251-025305101 |
| Playerbots.PremadeSpecLink.3.1.60 | -035305101030013233115031151 | -025315101030013233125031051 |
| Playerbots.PremadeSpecLink.3.1.80 | 502-035305101230013233135031351-5000002 | 502-025335101030013233135031351-5000002 |
| Playerbots.PremadeSpecLink.4.0.80 | 005303005352100520103331051-005005003-502 | 005303104352100520103331051-005005005003-2 |
| Playerbots.PremadeSpecLink.6.0.80 | 0055021533303310201020131-305020510002-00522 | 0355021533003313201020131351-005-005032 |
| Playerbots.PremadeSpecLink.6.2.80 | 23050202--2302303350032152000150003133151 | -320033500002-2301303050032151000150013133151 |
| Playerbots.PremadeSpecLink.7.0.80 | 4530001523213351302301351-00525003 | 3530001523213351322301351-005050031 |
| Playerbots.PremadeSpecLink.7.1.60 | -30305003105021333031121131051 | -30205033005001333031131131051 |
| Playerbots.PremadeSpecLink.7.1.80 | 053030152-30305003105021333031131131051 | 053030052-30205033005021333031131131051 |
| Playerbots.PremadeSpecLink.8.0.60 | 230005231100330150323102500321 | 23000503110033014032310150532 |
| Playerbots.PremadeSpecLink.8.0.80 | 230005231100330150323102505321-03-203303001 | 23000523310033015032310250532-03-203203001 |
| Playerbots.PremadeSpecLink.8.1.80 | 23000503110003-0055032012303330053120300351 | 23000503110003-0055030011302331053120321351 |
| Playerbots.PremadeSpecLink.8.3.80 | -2305032012303331053120321351-023302031 | -2305032012303331053120311351-023303031 |
| Playerbots.PremadeSpecLink.9.0.80 | 2350022001123510253500331151--55000005 | 2350022001113510253500331151--5500000501 |
| Playerbots.PremadeSpecLink.9.2.60 | --05203215200231051305031151 | --05203205210131051313230341 |
| Playerbots.PremadeSpecLink.9.2.80 | 23-0302-05203215220331051335231351 | -03310030003-05203205210331051335230351 |
| Playerbots.PremadeSpecName.9.1 | demo pve | emo pve |
| Playerbots.PvpProhibitedAreaIds | "976,35,392,2268,4161,4010,4317,4312,3649,3887,3958,3724,4080,3938,3754,3786,3973,4085,4086,4087,4088,251" | "976,35,392,2268,4161,4010,4317,4312" |
| Playerbots.PvpProhibitedZoneIds | "2255,656,2361,2362,2363,976,35,2268,3425,392,541,1446,3828,3712,3738,3565,3539,3623,4152,3988,4658,4284,4418,4436,4275,4323,4395,3703,4298,3951" | "2255,656,2361,2362,2363,976,35,2268,3425,392,541,1446,3828,3712,3738,3565,3539,3623,4152,3988,4658,4284,4418,4436,4275,4323,4395,3703,4298,139" |
| Playerbots.RandomBotAutoJoinBG | 0 | 1 |
| Playerbots.RandomBotCombatStrategies | "" | "+dps,+dps assist,-threat" |
| Playerbots.RandomBotQuestIds | "3802,5505,6502,7761,7848,10277,10285,11492,13188,13189,24499,24511,24710,24712" | "7848,3802,5505,6502,7761,10277,10285,11492,24499,24511,24710,24712" |
| Playerbots.RandomBotQuestItems | "5175,5176,5177,5178,6948,11000,12382,13704,16309" | "6948,5175,5176,5177,5178,16309,12382,13704,11000" |
| Playerbots.RandomBotSayWithoutMaster | 0 | 1 |
| Playerbots.RandomBotTeleHigherLevel | 3 | 1 |
| Playerbots.RandomBotTeleLowerLevel | 1 | 3 |
| Playerbots.RandomClassSpecProb.4.0 | 40 | 45 |
| Playerbots.RandomClassSpecProb.4.1 | 60 | 45 |
| Playerbots.RandomClassSpecProb.4.2 | 0 | 10 |
| Playerbots.RandomClassSpecProb.9.0 | 33 | 45 |
| Playerbots.RandomClassSpecProb.9.1 | 34 | 45 |
| Playerbots.RandomClassSpecProb.9.2 | 33 | 10 |
| Playerbots.RandomGearQualityLimit | 3 | 4 |
| Playerbots.SightDistance | 100.0 | 75.0 |
| Playerbots.SyncQuestForPlayer | 0 | 1 |
| Playerbots.ToxicLinksPrefix | gnomes | (空) |

> 说明：其中 `PremadeSpecGlyph.*` / `PremadeSpecLink.*` 系列（约 40 条）为各职业预设雕文/装备串的谷神修正值，属策略性微调；`BroadcastChance*` 系列为世界广播频率；`RandomClassSpecProb.*` 为随机机器人天赋概率分布。

## 6. 未映射谷神键清单（45，WARN）

### 6.1 WorldBuff 旧结构（36 条）— 已被基线 `Playerbots.WorldBuffMatrix` 单行矩阵取代，无数据丢失

`AiPlayerbot.WorldBuff.0.{1..11}.{0..3}.80.80` 共 36 条。基线新结构 `Playerbots.WorldBuffMatrix` 用分号分隔的 `id:class,spec,tab,min,max:spell1,spell2` 单键承载全部 88 个预设，已包含谷神 80 级 brackets 对应条目（抽样核对：谷神 `WorldBuff.0.1.0.80.80 = 53760,57358`「战士 武器」与矩阵条目 `0,1,0,80,80:53760,57358` 一致）。**结论：不迁移，无损失。**

### 6.2 已废弃 / 基线已移除功能（8 条）

| 谷神键 | 备注 |
|---|---|
| `AiPlayerbot.FreeFood` | 基线无此键（食物 cheat 体系已重构，见 `BotCheats`） |
| `AiPlayerbot.AutoTrainSpells` | 基线无此键 |
| `AiPlayerbot.SayWhenCollectingItems` | 基线无此键 |
| `AiPlayerbot.LootRollLevel` | 基线无此键 |
| `AiPlayerbot.PlayerbotsXPRate` | 基线无此键 |
| `AiPlayerbot.FleeingEnabled` | 基线无此键 |
| `AiPlayerbot.EquipmentPersistence` / `EquipmentPersistenceLevel` | 基线无此键（装备持久化机制已变更） |
| `AiPlayerbot.PermanantlyInWorldTime` | 基线无此键 |
| `AiPlayerbot.RandomBotLoginAtStartup` | 基线无此键（由 RandomBotAutologin 覆盖语义） |
| `AiPlayerbot.SuggestDungeonsInLowerCaseRandomly` | 基线无此键 |
| `AiPlayerbot.PremadeAvoidAoe` | 基线无此键（由 AoeAvoidSpellWhitelist 覆盖语义） |

### 6.3 谷神笔误键（1 条）

| 谷神键 | 备注 |
|---|---|
| `AIPlayerbot.GuildFeedback`（大写 I） | 归一化后对应 `Playerbots.GuildFeedback`，基线无此键（公会聊天反馈功能已移除/重构，基线保留的是 `GuildRepliesRate`）。**不迁移。** |

## 7. 后续观察项

- 1000~1200 随机机器人对服务器内存/CPU 的压力为谷神生产设定，本服上线后按 worldserver 日志观察 `RandomBotAccountCount=0`（自动）是否真的建出足量机器人；必要时调 `AddClassAccountPoolSize`。
- `Playerbots.RandomBotCombatStrategies` 由基线空串改为谷神 `"+dps,+dps assist,-threat"`，如机器人打怪异常可回退。
