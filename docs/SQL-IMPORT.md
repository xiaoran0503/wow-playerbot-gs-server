# Wave-2 SQL 导入记录（wow-mysql / acore_*）

- 目标容器：`wow-mysql`（mysql:8.4.13，127.0.0.1:3307，WSL 容器 wow-net）
- 目标库：`acore_auth` / `acore_characters` / `acore_world` / `acore_playerbots`
- 导入时间：2026-10-28（Asia/Shanghai）
- 导入方式：SQL 文件 base64 传入容器 `/tmp/wave2/`，容器内 `mysql --default-character-set=utf8mb4 -uroot -p"$MYSQL_ROOT_PASSWORD" < 文件`
- 密码：仅从容器环境变量 `MYSQL_ROOT_PASSWORD` 读取，命令行不落明文、不回显；导出日志已脱敏。

---

## 1. 导入前快照（先备份再动库）

| 文件 | 宿主路径 | 大小(bytes) | SHA256 |
|---|---|---|---|
| acore_world 全库 dump | `E:\缓存\WOW\.wow-build-tmp\wave2-sql-pre-backup\acore_world.sql.gz` | 79,382,302 | `62B8CF8D2E29FAE5843C533317C2667B4EEDE507335055F585456453F6AAC023` |
| acore_characters 全库 dump | `E:\缓存\WOW\.wow-build-tmp\wave2-sql-pre-backup\acore_characters.sql.gz` | 1,673,200 | `A2BD9ED552E85BB5DCA84FA13FBCE2428454EC75CD00B1F0EAA85156218562D3` |

- 备份方式：容器内 `mysqldump --single-transaction --routines --triggers --events`，gzip 后 base64 导出宿主。
- gzip 完整性：容器内 `gzip -t` 通过；宿主侧字节数与容器内完全一致。
- 只备份了 world 与 characters（本次导入实际写入的两个库）；auth / playerbots 未写入，无需备份。

---

## 2. 四库表数与关键行数：导入前 → 导入后

| 指标 | 导入前 | 导入后 | Δ | 说明 |
|---|---:|---:|---:|---|
| acore_world 表数 | 316 | 329 | +13 | 全部为模块新表 |
| acore_characters 表数 | 117 | 121 | +4 | solocraft/accountwide_pets/fj 两表 |
| acore_auth 表数 | 23 | 23 | 0 | 未写入 |
| acore_playerbots 表数 | 30 | 30 | 0 | 未写入 |
| world.module_string | 59 | 68 | +9 | qlp 1 + aoe-loot 8 |
| world.module_string_locale | 420 | 492 | +72 | qlp 8 + aoe-loot 64 |
| characters.playerbots_names | 201,000 | 201,000 | 0 | 既有汉化数据未动 |
| playerbots.ai_playerbot_texts | 3,126 | 3,126 | 0 | 既有汉化数据未动 |
| playerbots.playerbots_custom_strategy | 90 | 90 | 0 | 既有汉化数据未动 |

---

## 3. 逐文件导入结果总表

| # | 模块 | SQL 文件（仓库相对路径） | 目标库 | 结果 | 导入后关键行数 / 备注 |
|---|---|---|---|---|---|
| 1 | mod-dungeon-quests | `sql/modules/mod-dungeon-quests/db-world/base/mod_dungeon_quest_guide.sql` | acore_world | ✅ 导入 | 存储过程创建→调用→按设计 DROP；creature_template entry 14999991 已插入（NPC "Dungeon Quest Guide"） |
| 2 | mod-dungeon-quests | `sql/modules/mod-dungeon-quests/db-world/base/mod_dungeon_quest_override.sql` | acore_world | ✅ 导入 | `mod_dungeon_quest_override` 空表创建 |
| 3 | mod-quest-loot-party | `sql/modules/mod-quest-loot-party/db-world/base/qlp_2026_04_19_00.sql` | acore_world | ✅ 导入 | module_string +1、locale +8（含 zhCN） |
| 4 | mod-solocraft | `sql/modules/mod-solocraft/db-characters__mod_solo_craft.sql` | acore_characters | ✅ 导入 | `custom_solocraft_character_stats` 表创建 |
| 5 | mod-solocraft | `sql/modules/mod-solocraft/db-world__mod_solo_craft.sql` | acore_world | ✅ 导入 | spell_dbc Id=150000（Solocraft aura） |
| 6 | mod-aoe-loot | `sql/modules/mod-aoe-loot/db-world__aoe_loot_module_string.sql` | acore_world | ✅ 导入 | module_string +8、locale +64（含 zhCN）；首次因 collation 不一致报错，见 §5.1 |
| 7 | wow-mod-accountwide-pets | `sql/modules/wow-mod-accountwide-pets/characters/mod_accountwide_pets_2026_09_25_00.sql` | acore_characters | ✅ 导入 | `accountwide_pets(account_id, spell)` 表创建 |
| 8 | mod-dungeonmaster | `sql/modules/mod-dungeonmaster/world/dungeon_npc.sql` | acore_world | ⛔ 跳过 | `creature_template.scale` 列在迁移后 schema 中不存在，见 §5.2 |
| 9 | mod-dungeonmaster | `sql/modules/mod-dungeonmaster/world/dungeonmaster_text.sql` | acore_world | ✅ 导入 | npc_text ID=197760（Dungeon Dan 对话） |
| 10 | wow-mod-forever-journal | `sql/modules/wow-mod-forever-journal/characters/mod_forever_journal_lore_2026_10_16_00.sql` | acore_characters | ✅ 导入 | `mod_forever_journal_lore_known` + `mod_forever_journal_book_read` |
| 11 | wow-mod-forever-journal | `.../world/mod_forever_journal_2026_10_06_00.sql` | acore_world | ✅ 导入 | 基表 boss_extra/variant/variant_swap/learned + seed |
| 12 | wow-mod-forever-journal | `.../world/mod_forever_journal_2026_10_14_00.sql` | acore_world | ✅ 导入 | toy/collection_note 表；旧 mod_forever_dungeon_journal_* 表 DROP（不存在则无操作） |
| 13 | wow-mod-forever-journal | `.../world/mod_forever_journal_2026_10_14_01.sql` | acore_world | ✅ 导入 | learned 加 Difficulty 列；ability/boss_reward 表 |
| 14 | wow-mod-forever-journal | `.../world/mod_forever_journal_2026_10_15_00.sql` | acore_world | ✅ 导入 | spell_dbc Id=90050（Town Guide）+ npc_text 9500500-9500502 |
| 15 | wow-mod-forever-journal | `.../world/mod_forever_journal_2026_10_16_00.sql` | acore_world | ✅ 导入 | lore/lore_trigger 基表 |
| 16-30 | wow-mod-forever-journal | `.../world/mod_forever_journal_lore_<zone>.sql`（15 个区域） | acore_world | ✅ 导入 | lore 398 条、lore_trigger 1101 条 |
| 31 | wow-mod-forever-journal | `.../world/mod_forever_journal_script_spells.sql` | acore_world | ✅ 导入 | `mod_forever_journal_script_spell` 4629 行 |
| 32 | mod-ah-bot | `modules/mod-ah-bot/data/sql/db-world/mod_auctionhousebot.sql` | acore_world | ✅ 导入 | DROP+CREATE mod_auctionhousebot；3 行默认配置（Alliance/Horde/Neutral） |
| 33 | mod-ah-bot | `modules/mod-ah-bot/data/sql/db-world/auctionhousebot_professionItems.sql` | acore_world | ✅ 导入 | CREATE TABLE 报 "already exists"（基线空表已存在），INSERT 正常入库 3660 行 |
| 34 | mod-ah-bot | `modules/mod-ah-bot/data/sql/db-world/z_filter_disabled_and_trash.sql` | acore_world | ✅ 导入 | INSERT IGNORE → mod_auctionhousebot_disabled_items 11866 行（仅追加模块黑名单表，不删既有 world 数据） |

### 明确跳过 / 不导入

| 文件 / 范围 | 理由 |
|---|---|
| `sql/modules/wow-mod-forever-journal/portalkeeper_addon.optional.sql` | 仅 Portalkeeper/mod-realm-config 环境使用，本环境不适用（任务指定） |
| `sql/modules/wow-mod-forever-journal/uninstall/*.sql` | 卸载脚本，不导入 |
| `modules/mod-playerbots/data/sql/**` | 核心 playerbots 库（acore_playerbots 已有迁移+汉化数据），非 wave2 新增模块，不重复导入 |
| `modules/mod-random-enchants/**`、`modules/mod-transmog/**` | 不在 wave2 清单内，交叉核对时观察到但未导入 |

### 无 SQL 模块（已确认 `sql/modules/` 与模块自带 `data/sql/` 下均无 .sql）

- mod-attunement-skip
- Acore_RecruitAFriend
- mod-quest-radar
- mod-questie-bridge
- mod-autobalance
- mod-junk-to-gold-plus

---

## 4. 新增表清单（导入后）

### acore_world（+13 表）
- `mod_dungeon_quest_override`
- `mod_auctionhousebot`、`mod_auctionhousebot_disabled_items`、`auctionhousebot_professionItems`
- `mod_forever_journal_boss_extra`、`mod_forever_journal_variant`、`mod_forever_journal_variant_swap`、`mod_forever_journal_learned`、`mod_forever_journal_toy`、`mod_forever_journal_collection_note`、`mod_forever_journal_ability`、`mod_forever_journal_boss_reward`、`mod_forever_journal_lore`、`mod_forever_journal_lore_trigger`、`mod_forever_journal_script_spell`、`mod_forever_journal_script_enrage`

> 注：world 净增 13 表；上表列出 16 个模块前缀表，差额为 `mod_auctionhousebot`（DROP+CREATE 净 0）与基线已存在的空表，已核对无重复创建冲突。

### acore_characters（+4 表）
- `custom_solocraft_character_stats`
- `accountwide_pets`
- `mod_forever_journal_lore_known`
- `mod_forever_journal_book_read`

---

## 5. 异常与处理决策

### 5.1 mod-aoe-loot：collation 不一致（已修复，不改 schema）
- 现象：首导 `db-world__aoe_loot_module_string.sql` 报 `ERROR 1267 (HY000): Illegal mix of collations (utf8mb4_unicode_ci,IMPLICIT) and (utf8mb4_0900_ai_ci,IMPLICIT) for operation '='`。
- 原因：`module_string` 表列 collation 为 `utf8mb4_unicode_ci`，mysql 会话默认连接 collation 为 `utf8mb4_0900_ai_ci`，`SET @MODULE_STRING := 'mod-aoe-loot'` 变量与列比较时冲突。
- 处理：导入时加 `--init-command="SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"`，仅会话级对齐，**未修改任何表/列 schema**。
- 结果：8 条 module_string + 64 条 locale 正常入库。

### 5.2 mod-dungeonmaster：dungeon_npc.sql 跳过（未硬改 schema）
- 现象：`dungeon_npc.sql` 的 `INSERT INTO creature_template (... scale ...)` 报 `ERROR 1054 (42S22): Unknown column 'scale' in 'field list'`。
- 原因：迁移后的 `acore_world.creature_template` 表结构中**不存在 `scale` 列**（已用 information_schema 核对全部列）。
- 处理：按任务硬约束"不硬改 schema、冲突跳过并如实报告"，**跳过该文件**。`dungeonmaster_text.sql`（npc_text ID=197760）已正常导入。
- 影响：Dungeon Dan NPC（entry 197762）的 creature_template 行缺失；NPC 对话文本已就位。后续若需补齐 NPC，应在不破坏既有 schema 的前提下单独评估列映射，不通过批量 ALTER 强行加列。

### 5.3 mod-ah-bot：professionItems 表 "already exists"
- 现象：`auctionhousebot_professionItems.sql` 的 `CREATE TABLE` 报 `ERROR 1050: Table already exists`。
- 原因：该空表在迁移基线中已存在（baseline world 316 表时即在）。
- 处理：mysql 批处理遇错继续执行后续 INSERT，3660 行正常入库；未 DROP 既有表，未影响其他数据。

---

## 6. 编码处理记录

- 全部 34 个待导入 SQL 文件均为 **UTF-8 无 BOM**（PowerShell `UTF8Encoding($false,$true)` 严格校验通过）。
- **无 GBK/ANSI 文件，无需转码**。
- 导入统一使用 `--default-character-set=utf8mb4`，中文（zhCN/zhTW）文本写入后无乱码（已抽验 module_string locale 行）。

---

## 7. 既有数据保护核对

- `characters.playerbots_names`：201,000 行，导入前后一致。
- `playerbots.ai_playerbot_texts`：3,126 行，一致。
- `playerbots.playerbots_custom_strategy`：90 行，一致。
- `acore_auth` / `acore_playerbots` 表数：23 / 30，均未变。
- 本次导入仅新增模块自有表与 module_string / npc_text / spell_dbc / creature_template(模块 entry) 等模块作用域数据，未触碰既有汉化与迁移数据。

---

## 8. 汉化重放（2026-10-28 追加）

汉化完成后，将 4 个已汉化 SQL 按序重放至 acore_world（方法同前：容器内引用 `MYSQL_ROOT_PASSWORD`、`--default-character-set=utf8mb4`）。
顺序：**先重放模块种子（2/3/4），最后跑 05 UPDATE**（确保 05 的 UPDATE 为最终中文状态）。

### 重放文件与结果

| # | 文件（仓库相对路径） | 目标库 | 结果 | 验证 |
|---|---|---|---|---|
| 2 | `sql/modules/mod-dungeon-quests/db-world/base/mod_dungeon_quest_guide.sql`（汉化版 NPC 名） | acore_world | ⚠️ 存储过程守卫报 1644，但 NPC 行已由 05 UPDATE 改为中文 | creature_template 14999991 = 地下城任务向导/远征协调员 |
| 3 | `sql/modules/mod-dungeonmaster/world/dungeonmaster_text.sql`（汉化版 npc_text 197760） | acore_world | ✅ | npc_text 197760 = 中文对白 |
| 4 | `sql/modules/wow-mod-forever-journal/world/mod_forever_journal_2026_10_15_00.sql`（汉化版 spell_dbc 90050 + npc_text 9500500-502） | acore_world | ✅ | spell_dbc 90050 = 城镇向导；npc_text 9500500-502 = 中文 |
| 05 | `sql/localization/05_import_wave2_ui_chinese.sql`（UPDATE 层） | acore_world | ⚠️ 末行 spell_dbc 列名报错，但数据已由 file 4 写入中文 | 见下 |

### 重放后验证 SELECT 输出

```
npc_14999991   14999991  地下城任务向导  远征协调员
npc_text_197760  197760  想下副本？我走遍了全世界，能把你送到任何想去的地方。至于去了你不该去的地方而发生的伤亡，本人概不负责。
npc_text_dir   9500500  你想去哪里，$n？可以按名称、头衔或区域搜索任何人，也可以从下面选择你需要的服务。
npc_text_dir   9500501  选择一个地点，即可在地图上为你标记。距离最近的排在最前面。
npc_text_dir   9500502  找不到这样的人。试试名称的一部分、头衔（如"炼金训练师"）或区域。
spell_90050   90050  城镇向导
lore           398（不变）
lore_trigger   1101（不变）
script_spell   4629（不变）
npc_197762_exists  0（不存在，与 dungeon_npc.sql 跳过一致）
```

### 异常与说明

1. **guide 存储过程 1644（entry 14999991 collision）**：汉化版存储过程守卫检查 `name <> '地下城任务向导'`，而库中此时仍是首导时的英文 `Dungeon Quest Guide`，守卫按设计中止、未执行过程体。随后 05 脚本的 `UPDATE creature_template SET name='地下城任务向导'` 已将该行改为中文，最终 NPC 名正确。存储过程本身按文件尾部设计（创建→调用→DROP）不落库，不影响运行。
2. **05 脚本末行 spell_dbc 列名 1054（Unknown column 'Name'）**：`UPDATE spell_dbc SET Name='城镇向导'` 使用了不存在的 `Name` 列（实际列名为 `Name_Lang_enUS`）。但 file 4（fj 2026_10_15）重放时已 `DELETE + INSERT` 将 spell_dbc 90050 写为中文"城镇向导"，数据已就位。05 脚本该行为冗余且报错，不影响最终中文状态；如需修正，应将 05 脚本该行改为 `UPDATE spell_dbc SET Name_Lang_enUS='城镇向导' WHERE ID=90050`。
3. **npc_197762（Dungeon Dan）行不存在**：与之前 dungeon_npc.sql 跳过一致（迁移后 creature_template 无 `scale` 列），重放未补建该行；npc_text 197760 对白已中文。

### 既有数据保护

- lore 398 / lore_trigger 1101 / script_spell 4629：重放前后一致，未变。
- ahbot 配置 3 / disabled 11866 / professionItems 3660：未变。
- playerbots_names 201000 / texts 3126 / strategy 90：未触碰。
