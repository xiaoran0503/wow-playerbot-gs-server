-- mod-brawlers-guild —— 中文（zhCN / zhTW）本地化补充
--
-- 原模块只有英文硬编码在 creature_template / quest_template / item_template /
-- gameobject_template 里，没有提供任何 *_locale 行。此文件补齐中文，客户端语言为
-- zhCN / zhTW 时生效（服务端 worldserver.conf 的 DBC.Locale 需对应）。
--
-- 编号来源：NPCs.sql 的 @ID = 200000，Misc.sql 的 @Quests = 90000、@GoID = 900000。
-- 幂等：先 DELETE 再 INSERT，可重复执行。

-- ---------------------------------------------------------------
-- 任务 90000「Into the Arena!」
-- ---------------------------------------------------------------
DELETE FROM `quest_template_locale` WHERE `ID` = 90000 AND `locale` IN ('zhCN', 'zhTW');
INSERT IGNORE INTO `quest_template_locale` (`ID`, `locale`, `Title`, `Details`, `Objectives`, `EndText`, `CompletedText`, `VerifiedBuild`) VALUES
(90000, 'zhCN', '走入竞技场！', '去和 Helix 谈谈，他会告诉你搏击俱乐部到底是怎么回事。', '去和 Helix 谈谈，他会告诉你搏击俱乐部到底是怎么回事。', '', '去和 Helix 谈谈，他会告诉你搏击俱乐部到底是怎么回事。', 0),
(90000, 'zhTW', '走入競技場！', '去和 Helix 談談，他會告訴你搏擊俱樂部到底是怎麼回事。', '去和 Helix 談談，他會告訴你搏擊俱樂部到底是怎麼回事。', '', '去和 Helix 談談，他會告訴你搏擊俱樂部到底是怎麼回事。', 0);

DELETE FROM `quest_offer_reward_locale` WHERE `ID` = 90000 AND `locale` IN ('zhCN', 'zhTW');
INSERT IGNORE INTO `quest_offer_reward_locale` (`ID`, `locale`, `RewardText`, `VerifiedBuild`) VALUES
(90000, 'zhCN', '你一定是冲着搏击俱乐部来的吧？$B$B我跟你说，这可不是给胆小的人准备的。那些比赛打得相当惨烈，但报酬绝对对得起你身上掉的肉。$B$B听说艾泽拉斯最硬的一批拳手都是从这扇门里走出来的。$B$B还有传言说，最近刚来了一位新的挑战者，在地下拳场已经闹出了不小的动静。$B$B谁知道他们会给擂台带来什么花样？$B$B祝你好运吧，朋友。你会需要的。', 0),
(90000, 'zhTW', '你一定是衝著搏擊俱樂部來的吧？$B$B我跟你說，這可不是給膽小的人準備的。那些比賽打得相當慘烈，但報酬絕對對得起你身上掉的肉。$B$B聽說艾澤拉斯最硬的一批拳手都是從這扇門裡走出來的。$B$B還有傳言說，最近剛來了一位新的挑戰者，在地下拳場已經鬧出了不小的動靜。$B$B誰知道他們會給擂台帶來什麼花樣？$B$B祝你好運吧，朋友。你會需要的。', 0);

-- ---------------------------------------------------------------
-- 物品 43003「Brawler's Gold」
-- ---------------------------------------------------------------
DELETE FROM `item_template_locale` WHERE `ID` = 43003 AND `locale` IN ('zhCN', 'zhTW');
INSERT IGNORE INTO `item_template_locale` (`ID`, `locale`, `Name`, `Description`, `VerifiedBuild`) VALUES
(43003, 'zhCN', '搏击金币', '颁发给搏击俱乐部的胜者。可在搏击金币兑换商人处换取乱斗卡牌以及其他能改变战局的物品。', 0),
(43003, 'zhTW', '搏擊金幣', '頒發給搏擊俱樂部的勝者。可在搏擊金幣兌換商人處換取亂鬥卡牌以及其他能改變戰局的物品。', 0);

-- ---------------------------------------------------------------
-- NPC（entry 200000-200008）。人名保留原文，只译称号与描述性名称。
-- ---------------------------------------------------------------
DELETE FROM `creature_template_locale` WHERE `entry` BETWEEN 200000 AND 200008 AND `locale` IN ('zhCN', 'zhTW');
INSERT IGNORE INTO `creature_template_locale` (`entry`, `locale`, `Name`, `Title`, `VerifiedBuild`) VALUES
(200000, 'zhCN', 'Helix', '搏击俱乐部', 0),
(200001, 'zhCN', 'Selena', '搏击俱乐部', 0),
(200002, 'zhCN', 'El Rato', '搏击俱乐部', 0),
(200003, 'zhCN', '搏击俱乐部医师', '', 0),
(200004, 'zhCN', '竞技场观众', '', 0),
(200005, 'zhCN', '竞技场观众', '', 0),
(200006, 'zhCN', '地精烟花坦克', '', 0),
(200007, 'zhCN', 'Jesse', '', 0),
(200008, 'zhCN', 'Chip', '赌徒', 0),
(200000, 'zhTW', 'Helix', '搏擊俱樂部', 0),
(200001, 'zhTW', 'Selena', '搏擊俱樂部', 0),
(200002, 'zhTW', 'El Rato', '搏擊俱樂部', 0),
(200003, 'zhTW', '搏擊俱樂部醫師', '', 0),
(200004, 'zhTW', '競技場觀眾', '', 0),
(200005, 'zhTW', '競技場觀眾', '', 0),
(200006, 'zhTW', '哥布林煙火坦克', '', 0),
(200007, 'zhTW', 'Jesse', '', 0),
(200008, 'zhTW', 'Chip', '賭徒', 0);

-- ---------------------------------------------------------------
-- 场景物件（entry 900000-900003）
-- ---------------------------------------------------------------
DELETE FROM `gameobject_template_locale` WHERE `entry` BETWEEN 900000 AND 900003 AND `locale` IN ('zhCN', 'zhTW');
INSERT IGNORE INTO `gameobject_template_locale` (`entry`, `locale`, `name`, `castBarCaption`, `VerifiedBuild`) VALUES
(900000, 'zhCN', '巨石', '正在使用', 0),
(900001, 'zhCN', '巨石', '正在使用', 0),
(900002, 'zhCN', '灼热石柱', '正在使用', 0),
(900003, 'zhCN', '贵宾传送器', '正在使用', 0),
(900000, 'zhTW', '巨石', '正在使用', 0),
(900001, 'zhTW', '巨石', '正在使用', 0),
(900002, 'zhTW', '灼熱石柱', '正在使用', 0),
(900003, 'zhTW', '貴賓傳送器', '正在使用', 0);
