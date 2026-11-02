-- 补齐 ai_playerbot_texts 中缺少中文（text_loc4 = zhCN）的对白
--
-- 背景：官方 base 表 ai_playerbot_texts 的 1739 条对白里，已有 1728 条填好了 text_loc4（中文），
--       只剩下面 9 条是空的（多为后期新增的圣骑士祝福缺材料 RP、虚空幽魂光束挡线喊话）。
--       不补的话，机器人在这几种情况下会说英文。
--
-- 字段映射（见 src/Mgr/Text/PlayerbotTextMgr.cpp）：
--   text     = enUS（基线英文）
--   text_loc1..8 对应 LocaleConstant 1..8：
--     1 koKR  2 frFR  3 deDE  4 zhCN  5 zhTW  6 esES  7 esMX  8 ruRU
--
-- 用法（本服 Updates.EnableDatabases = 0，需手动导入 playerbots 库）：
--   mysql -u root -p acore_playerbots < 2026_10_31_00_ai_playerbot_zhcn_missing.sql
-- 导入后 .reload config 或重启 worldserver 生效（对白只在启动时载入）。

UPDATE `ai_playerbot_texts` SET `text_loc4` = '以圣光之名……我忘了带王者印记。先用 %base_spell 凑合一下吧！'
    WHERE `id` = 1708 AND (`text_loc4` IS NULL OR `text_loc4` = '');

UPDATE `ai_playerbot_texts` SET `text_loc4` = '大自然很慷慨，我的包可不一定……%group_spell 的草药没了。先上 %base_spell！'
    WHERE `id` = 1709 AND (`text_loc4` IS NULL OR `text_loc4` = '');

UPDATE `ai_playerbot_texts` SET `text_loc4` = '奥术粉末用光了……%group_spell 得等一等了。先放 %base_spell！'
    WHERE `id` = 1710 AND (`text_loc4` IS NULL OR `text_loc4` = '');

UPDATE `ai_playerbot_texts` SET `text_loc4` = '哎呀，%group_spell 的材料我没带够。这次就用 %base_spell 吧！'
    WHERE `id` = 1711 AND (`text_loc4` IS NULL OR `text_loc4` = '');

UPDATE `ai_playerbot_texts` SET `text_loc4` = '%player 去挡红光了！'
    WHERE `id` = 1712 AND (`text_loc4` IS NULL OR `text_loc4` = '');

UPDATE `ai_playerbot_texts` SET `text_loc4` = '%player 去挡蓝光了！'
    WHERE `id` = 1713 AND (`text_loc4` IS NULL OR `text_loc4` = '');

UPDATE `ai_playerbot_texts` SET `text_loc4` = '%player 去挡绿光了！'
    WHERE `id` = 1714 AND (`text_loc4` IS NULL OR `text_loc4` = '');

UPDATE `ai_playerbot_texts` SET `text_loc4` = '%player 正在离开蓝光——下一位准备接！'
    WHERE `id` = 1715 AND (`text_loc4` IS NULL OR `text_loc4` = '');

UPDATE `ai_playerbot_texts` SET `text_loc4` = '%player 正在离开绿光——下一位准备接！'
    WHERE `id` = 1716 AND (`text_loc4` IS NULL OR `text_loc4` = '');
