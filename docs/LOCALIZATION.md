# LOCALIZATION — 谷神汉化整合说明

> 本服从谷神整合服（GS_Server）迁移中文资产：Lua 脚本、配置键名迁移、
> 数据库中文素材（名字池 / 公会名 / 竞技场队名 / 说话文本 / 自定义策略）。
> 阶段 A（配置与 Lua）与阶段 B（数据库导入）均已完成。

## 1. 同步范围与落点

| 类别 | 内容 | 落点 | 状态 |
|---|---|---|---|
| Lua 脚本 | SupMalachite.lua（超级炉石，物品 entry 6948）、掉落物品随机附魔.lua、Eluna extensions | `custom/lua_scripts/` | ✅ |
| 配置种子 | playerbots.conf 键名迁移（AiPlayerbot.* → Playerbots.*，477 键）、6 模块 + worldserver/authserver | `custom/conf-seed/` | ✅ |
| 参考文档 | 谷神 worldserver/authserver/模块 conf（GBK→UTF-8） | `docs/gushen-reference/` | ✅ |
| 数据库名字池 | 谷神中文名 10 万 + 补充 1000 + 英文旧池保留 | `acore_characters.playerbots_names` | ✅ |
| 公会名 / 竞技场队名 | 已确认目标与谷神逐字一致，跳过导入 | `acore_characters.*` | ✅（无操作） |
| 说话文本 | ai_playerbot_texts 中文 UPDATE/INSERT | `acore_playerbots.ai_playerbot_texts` | ✅ |
| 自定义策略 | 追加谷神策略第 8..90 行 | `acore_playerbots.playerbots_custom_strategy` | ✅ |

## 2. 来源

- Lua / 配置：`E:\缓存\WOW\GS_Server\`（只读原件），暂存 `.wow-build-tmp\gs-lua\`、`gs-configs\`。
- 数据库导出：`.wow-build-tmp\gs-sql\`（10 个 SQL + names-all.txt）。
- 目标库：`wow-mysql`（MySQL 8.4，127.0.0.1:3307，容器 `wow-mysql`）。

## 3. 许可与归属

见仓库根 `NOTICE`：
- StackTracePlus © 2010 Ignacio Burgueño，MIT；
- `_Misc.ext` / `ObjectVariables.ext` 属 Eluna Lua Engine，GPLv3；
- SupMalachite.lua / 掉落物品随机附魔.lua 为谷神整合版/社区散件，无独立上游，自行维护；
- 数据库中文素材为谷神库导出，随本服体系使用。

## 4. 三方 schema 对比结论

| 表 | 谷神导出 | 目标库现状 | 处理 |
|---|---|---|---|
| playerbots_names | name_id int PK, name varchar(12), gender tinyint，UNIQUE(name,gender) | name_id int PK, name varchar(255)，无 UNIQUE(name,gender) | 谷神名重映射 100000+ 追加 |
| playerbots_guild_names | 400 行 | 400 行首末行逐字一致 | 跳过 |
| playerbots_arena_team_names | 300 行 | 300 行首末行逐字一致 | 跳过 |
| ai_playerbot_texts | id smallint AI + name/text/say_type/reply_type/text_loc1..8 | 完全一致 | 按 name+行序配对 UPDATE 中文 text，loc 列保留上游翻译 |
| playerbots_custom_strategy | id AI, name, idx, owner, action_line | 一致 | 追加第 8..90 行 |

## 5. 导入行数对比

| 表 | 导入前 | 导入后 |
|---|---:|---:|
| acore_characters.playerbots_names | 100,000 | **201,000**（中文 100,999） |
| acore_characters.playerbots_guild_names | 400 | 400（未动） |
| acore_characters.playerbots_arena_team_names | 300 | 300（未动） |
| acore_playerbots.ai_playerbot_texts | 2,525 | **3,126**（中文 2,268） |
| acore_playerbots.playerbots_custom_strategy | 7 | **90** |
| acore_playerbots.playerbots_db_store | 0 | 0（未导入，见 §6） |
| acore_playerbots.playerbots_random_bots | 289 | 289（未导入，见 §6） |

现场快照（导入前 mysqldump）：`.wow-build-tmp\gs-sql-pre-import-backup\`。

## 6. 关键决策记录

1. **英文旧池保留**：目标原有 10 万英文名不 DELETE（硬约束）；追加 10 万谷神中文名 + 1000 补充名。随机取名中英概率约 1:1，后续如需纯中文氛围，由运维自行决定缩减英文池。
2. **说话文本只更新 `text` 列**：`text_loc1..8` 保留上游法/德/韩/西翻译，不被谷神旧翻译覆盖。
3. **运行时状态表不导入**：`playerbots_random_bots`（7,275 行）与 `playerbots_db_store`（934 行）按 guid 引用谷神机器人账号，本服角色体系不同，导入即孤儿数据；由 mod 随玩随建。
4. **概率调优表不导入**：`ai_playerbot_texts_chance` / `playerbots_speech_probability` 目标已有同值数据（目标多 1 行上游新增），无增量。
5. **DBUpdater 追平**：本服 `Playerbots.Updates.EnableDatabases=1`，worldserver 首启跑 mod 增量补丁；updater 只做 DDL/增量、不清基础表，**导入无需重跑**；脚本幂等，未来 schema 迁移后重跑即可。

## 7. 相关文件索引

- 配置迁移报告：`custom/conf-seed/KEYMAP-REPORT.md`
- 导入脚本与决策明细：`sql/localization/README.md`
- Lua 脚本说明：`custom/lua_scripts/README.md`
- 参考文档：`docs/gushen-reference/README.md`
