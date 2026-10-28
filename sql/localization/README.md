# sql/localization — 谷神数据库中文素材导入脚本

> 目标库：`wow-mysql`（MySQL 8.4，127.0.0.1:3307，容器 `wow-mysql`）
> 导入日期：2026-10-28。执行前已对目标表做 mysqldump 快照（见报告备份目录）。
> 原则：只 INSERT / UPDATE，不 DELETE / DROP；英文旧池保留。

## 文件清单与执行顺序

| 顺序 | 文件 | 目标库.表 | 内容 |
|---|---|---|---|
| 1 | `01_import_names_gs_chinese.sql` | acore_characters.playerbots_names | 谷神 100,000 个中文名，name_id 重映射 0..99999 → 100000..199999 |
| 2 | `02_import_names_supplementary.sql` | acore_characters.playerbots_names | 补充中文名 1,000 个，name_id 200000..200999 |
| 3 | `03_update_texts_chinese.sql` | acore_playerbots.ai_playerbot_texts | 谷神中文说话文本按 (name, 行序) 配对 UPDATE；谷神独有 name 组 INSERT |
| 4 | `04_import_custom_strategy_extra.sql` | acore_playerbots.playerbots_custom_strategy | 谷神自定义策略第 8..90 行（目标已有默认 7 行，跳过重复） |

## 三方 schema 对比结论

| 表 | 谷神导出 schema | 目标库现状 schema | 差异处理 |
|---|---|---|---|
| playerbots_names | name_id int PK, name varchar(12), gender tinyint，UNIQUE(name,gender)，MyISAM | name_id int PK, name **varchar(255)**, gender tinyint，无 UNIQUE(name,gender) | 直接 INSERT；目标表更宽，中文名 2-4 字符无压力 |
| playerbots_guild_names | 400 行 | 400 行，首末行逐字一致 | **跳过导入**（目标已是谷神数据） |
| playerbots_arena_team_names | 300 行 | 300 行，首末行逐字一致 | **跳过导入** |
| ai_playerbot_texts | id smallint AI, name/text/say_type/reply_type/text_loc1..8 | 与谷神完全一致 | 列同名直接映射；只 UPDATE `text` 列为中文，loc 列保留上游 fr/de/kr/es 翻译 |
| playerbots_custom_strategy | id AI, name, idx, owner, action_line | 与谷神一致 | 跳过前 7 行（目标已有默认值），追加第 8..90 行 |

## 合并决策

### 名字池（playerbots_names）
- 目标原有 100,000 行英文旧池（name_id 0..99999）——**保留不删**（硬约束：不 DELETE）。
- 谷神中文名 99,999 个（+1 个 AHbot）重映射到 100000..199999 追加。
- 补充中文名 1,000 个（常见姓氏×常见单/双字名组合，中性、避开真实名人与敏感词）写入 200000..200999。
- 结果：201,000 行，其中中文 100,999 行；随机机器人取名时中英文混合概率约 1:1。
- gender 字段实为「种族+性别」编码（0..17），随谷神原值导入，分布保持谷神比例。

### 说话文本（ai_playerbot_texts）
- 目标 2,525 行英文默认文本；谷神 2,290 行中文。
- 按 `name` 分组、按 id 行序 1:1 配对，UPDATE 目标行的 `text` 列为谷神中文；谷神多出的行 INSERT。
- `text_loc1..8`（上游法/德/韩/西翻译）不动；`say_type/reply_type` 不动。
- 导入后：3,126 行（2,525 + 601 新增），其中中文 2,268 行。

### 自定义策略（playerbots_custom_strategy）
- 目标已有默认 7 行（与谷神前 7 行一致）；追加谷神第 8..90 行共 83 行。

### 不导入的表（已评估）
| 表 | 行数 | 不导入原因 |
|---|---|---|
| playerbots_random_bots | 7,275 | 运行时状态表（bot 调度事件），guid 引用的是谷神机器人账号，本服不存在对应角色，导入即孤儿数据；由 mod 随玩随建 |
| playerbots_db_store | 934 | 同上，按 guid 存机器人设置；本服 bot guid 体系不同，导入会污染既有角色的机器人设置 |
| ai_playerbot_texts_chance / playerbots_speech_probability | 3 / 3 | 概率调优表，目标已存在且数值一致（目标多 1 行 missing_group_buff_reagent=100，为上游新增），无需导入 |
| playerbots_speech | 209 | 旧版英文嘲讽文本表，目标已有同构数据，无汉化增量 |

## 导入后行数核对

| 表 | 导入前 | 导入后 |
|---|---:|---:|
| acore_characters.playerbots_names | 100,000 | 201,000 |
| acore_characters.playerbots_guild_names | 400 | 400（未动） |
| acore_characters.playerbots_arena_team_names | 300 | 300（未动） |
| acore_playerbots.ai_playerbot_texts | 2,525 | 3,126 |
| acore_playerbots.playerbots_custom_strategy | 7 | 90 |
| acore_playerbots.playerbots_db_store | 0 | 0（未动） |
| acore_playerbots.playerbots_random_bots | 289 | 289（未动） |

## 首启 DBUpdater 追平说明

- 本服 `Playerbots.Updates.EnableDatabases=1`（见 custom/conf-seed/etc/modules/playerbots.conf），worldserver 首启会跑 mod 的 pending updates。
- 本导入在 DBUpdater 追平后的 schema 上执行；updater 只做 DDL/增量补丁，不清基础表数据，**无需重跑导入**。
- 若未来 updater 某版本对 texts/names 表做结构迁移，重跑本目录脚本即可（脚本幂等：INSERT 新 id、UPDATE 按 id 配对，重复执行不会产生重复行）。
