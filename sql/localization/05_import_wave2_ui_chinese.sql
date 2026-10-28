-- ============================================================
-- wave2 新增模块 数据面玩家可见文本 简体中文化 (UPDATE 层)
-- 覆盖: mod-dungeon-quests NPC名 / mod-dungeonmaster NPC名+npc_text / wow-mod-forever-journal npc_text+spell_dbc法术名
-- 风格: 沿用 sql/localization/03_update_texts_chinese.sql (SET NAMES utf8mb4 + UPDATE ... WHERE id=N)
-- 幂等: 重复执行结果一致; 与各模块种子 SQL 内的中文行互为双保险
-- 注意: 本文件只写不执行, 待模块 SQL 导入完成后由主代理统一重放
-- ============================================================
SET NAMES utf8mb4;

-- ---- mod-dungeon-quests: NPC "Dungeon Quest Guide" / "Expedition Coordinator" ----
-- 种子 SQL 已同步汉化; 此处 UPDATE 保证未重导种子的库也是中文
UPDATE `creature_template` SET `name`='地下城任务向导', `subname`='远征协调员' WHERE `entry`=14999991;

-- ---- mod-dungeonmaster: NPC "Dungeon Dan" / "Dungeonmaster" + npc_text 对白 ----
UPDATE `creature_template` SET `name`='地下城大师丹', `subname`='副本传送师' WHERE `entry`=197762;
UPDATE `npc_text` SET `text0_0`='想下副本？我走遍了全世界，能把你送到任何想去的地方。至于去了你不该去的地方而发生的伤亡，本人概不负责。',
                     `text0_1`='想下副本？我走遍了全世界，能把你送到任何想去的地方。至于去了你不该去的地方而发生的伤亡，本人概不负责。'
WHERE `ID`=197760;

-- ---- wow-mod-forever-journal: 城镇向导 npc_text 3 行 + spell_dbc 90050 法术名 ----
UPDATE `npc_text` SET `text0_0`='你想去哪里，$n？可以按名称、头衔或区域搜索任何人，也可以从下面选择你需要的服务。',
                     `text0_1`='你想去哪里，$n？可以按名称、头衔或区域搜索任何人，也可以从下面选择你需要的服务。'
WHERE `ID`=9500500;
UPDATE `npc_text` SET `text0_0`='选择一个地点，即可在地图上为你标记。距离最近的排在最前面。',
                     `text0_1`='选择一个地点，即可在地图上为你标记。距离最近的排在最前面。'
WHERE `ID`=9500501;
UPDATE `npc_text` SET `text0_0`='找不到这样的人。试试名称的一部分、头衔（如"炼金训练师"）或区域。',
                     `text0_1`='找不到这样的人。试试名称的一部分、头衔（如"炼金训练师"）或区域。'
WHERE `ID`=9500502;
UPDATE `spell_dbc` SET `Name_Lang_enUS`='城镇向导' WHERE `ID`=90050;

-- ---- 其余 wave2 模块说明 ----
-- mod-attunement-skip: 邮件主题/正文在 C++ 源码 (custom/locale-patches/mod-attunement-skip.patch), 无 DB 文本
-- mod-junk-to-gold-plus: 出售聊天模板在 C++ 源码 (patch), 无 DB 文本
-- wow-mod-accountwide-pets: 无玩家可见字符串 (审计确认, 仅服务器日志)
-- mod-solocraft: 登录广播/进本公告在 C++ 源码 (patch), 无 DB 文本
-- mod-quest-radar: .qr 命令输出在 C++ 源码 (patch), 无 DB 文本
-- mod-questie-bridge: 无玩家可见字符串; 任务标题为官方英文 quest 数据, 汉化方案见 docs/LOCALIZATION-UI-NEW.md
-- mod-autobalance: 登录公告在 C++ 源码 (patch); 其余文本经 ABGetLocaleText 已内置 zhCN
-- mod-aoe-loot / mod-quest-loot-party: module_string 已内置 zhCN, 无需处理
-- Acore_RecruitAFriend: Lua 脚本 (custom/lua_scripts/RecruitAFriend.lua), 无 DB 文本
-- 谷神既有 Lua: SupMalachite.lua / 掉落物品随机附魔.lua / 遗产职业强化.lua 抽查已中文, 无需处理
