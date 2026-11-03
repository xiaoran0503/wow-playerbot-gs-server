-- mod-register 模块：game_event 表增加 disabled 列
-- 修复 [1054] Unknown column 'disabled' in 'field list' 崩溃
-- RegisterDb.cpp QueryGameEvents() 查询此列用于展示活动开启/关闭状态

ALTER TABLE `game_event`
  ADD COLUMN `disabled` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '1 = disabled, 0 = enabled' AFTER `announce`;
