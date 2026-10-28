# MySQL 8.4 迁移记录（只读审计版）

- 审计日期：2026-10-28
- 审计范围：对新栈 MySQL 8.4 容器 `wow-mysql`（mysql:8.4，宿主机 127.0.0.1:3307，数据卷 `wow-mysql-data`）仅执行 SELECT，未做任何写入；未触碰旧栈容器。
- 凭证说明：root 密码仅从容器环境变量 `MYSQL_ROOT_PASSWORD` 现场读取并在会话内使用，本文档不记录任何密码明文。

---

## 1. 迁移路径全记录

| 项目 | 内容 |
|---|---|
| 来源 | 旧栈 wow-docker 栈（mariadb:10.11，容器 `wow-mariadb` 运行中），即「07-04 快照」schema |
| 备份方式 | 旧栈全库导出（mysqldump --databases 四库），产物：`E:\缓存\WOW\_migration\mariadb-acore-full-20261028.sql` |
| 备份大小 | 381,819,202 字节（364.13 MiB），文件最后写入时间 2026-10-28 13:56:09 |
| 备份 SHA256 | `254D2BF9AFF46973666442BD6AF7363BA294AA577B855E80FF5620D59C10D6C7` |
| 导入方式 | 在 `wow-mysql` 容器内以 stdin 流式重放 dump 语句（CREATE DATABASE → USE → CREATE TABLE → 逐批 INSERT），等价于在新实例上完整重建四库 |
| 新栈镜像 | mysql:8.4（实测版本 8.4.13） |

### 备份完整性核对

dump 内 `CREATE DATABASE` 共 4 个（均为 utf8mb4 / utf8mb4_general_ci）：

```
`acore_auth` / `acore_characters` / `acore_world` / `acore_playerbots`
```

dump 内 `CREATE TABLE` 计数（按 USE 块流式统计）与在线库 `information_schema.tables` 实测完全一致：

| 库 | dump 中 CREATE TABLE 数 | 在线库表数（2026-10-28 实测） |
|---|---|---|
| acore_auth | 23 | 23 |
| acore_characters | 117 | 117 |
| acore_world | 316 | 316 |
| acore_playerbots | 30 | 30 |

---

## 2. 当前数据在位状态（DB 级实测数字）

### 2.1 acore_auth.account（账号）

- 总数：**54**
- salt / verifier 长度抽查：全部 54 行一致，salt=32 字节、verifier=32 字节（SRP6 二进制列存储；即传输层 16 进制 64 字符，符合预期）
- expansion 取值分布：**2 × 54 行**（全部为 WotLK 3.3.5a，expansion=2）
- 末尾账号（脱敏，仅前 2 字符）：id=52 `RN***`、id=53 `RN***`、id=54 `SM***`（id=54 邮箱 SMOKE@EXAMPLE.COM）

### 2.2 acore_characters.characters（角色）

- 总数：**566**
- 等级分布：

| level | 数量 |
|---|---|
| 1 | 512 |
| 2 | 1 |
| 55 | 53 |

（512 个 1 级角色与 playerbots 机器人名字库规模相符；53 个 55 级为老栈练到半级的真人/老角色。）
- 抽查角色（脱敏）：guid=564 `Eg***`（lv1）、guid=565 `Ba***`（lv1）、guid=566 `Al***`（lv55）

### 2.3 acore_characters.guild（公会）

- 总数：**2**

| guildid | 公会名（脱敏） | 成员数（guild_member 分组） |
|---|---|---|
| 5 | Wa*** | 14 |
| 6 | Sa*** | 15 |

- guild_member 总计 29 行（14+15，对账一致）

### 2.4 acore_auth.realmlist

- 行数：**1**
- 字段值：id=1，name=`魔兽世界`，address=`127.0.0.1`，port=`20242`，gamebuild=`12340`（WotLK 3.3.5a 正式 build）

### 2.5 世界内容基准（acore_world）

| 表 | 行数 |
|---|---|
| creature_template | 29,951 |
| item_template | 46,098 |
| quest_template | 9,464 |

与 TrinityCore 3.3.5a 官方基准量级一致，确认世界库完整导入。

### 2.6 playerbots 数据

- `acore_characters.playerbots_names` 精确计数：**100,000 行**
- 注：playerbots_names 物理上位于 acore_characters 库（非 acore_playerbots 库）；acore_playerbots 库共 30 张表

### 2.7 updates 表快照边界

**acore_world.updates：总行数 2,763**，最新 10 条（文件名 + 时间戳）：

| 文件名 | 时间戳 |
|---|---|
| z_filter_disabled_and_trash.sql | 2026-10-28 05:31:27 |
| charsections_dbc.sql | 2026-10-28 05:31:27 |
| 2025_08_27_03.sql | 2026-10-28 05:31:27 |
| playerbots_rpg_races.sql | 2026-10-28 05:31:27 |
| rev_1782957767680699900.sql | 2026-10-28 05:31:27 |
| emotetextsound_dbc.sql | 2026-10-28 05:31:27 |
| 2026_07_03_02.sql | 2026-10-28 05:31:26 |
| 2026_07_03_03.sql | 2026-10-28 05:31:26 |
| 2026_07_02_03.sql | 2026-10-28 05:31:26 |
| 2026_07_03_01.sql | 2026-10-28 05:31:26 |

**acore_characters.updates：总行数 28**，最新 10 条（文件名 + 时间戳）：

| 文件名 | 时间戳 |
|---|---|
| 2026_06_24_00.sql | 2026-10-28 05:31:23 |
| 2025_09_25_01_playerbots_guild_tabard_fix.sql | 2026-10-28 05:31:23 |
| anticheat.sql | 2026-10-28 05:31:23 |
| playerbots_arena_team_names.sql | 2026-10-28 05:31:23 |
| playerbots_names.sql | 2026-10-28 05:31:23 |
| trasmorg.sql | 2026-10-28 05:31:23 |
| playerbots_guild_names.sql | 2026-10-28 05:31:23 |
| pvpscript_pk.sql | 2026-10-28 05:31:23 |
| 2026_06_01_00.sql | 2026-06-01 14:33:31 |
| 2026_04_12_00.sql | 2026-06-01 14:33:31 |

**快照边界判定（以文件名为准，不以 timestamp 为准）：**
- 世界库：最新版本化补丁文件为 `2026_07_03_01/02/03.sql`，即旧栈 schema 快照 ≈ **2026-07-03/04**；
- 角色库：最新版本化补丁为 `2026_06_24_00.sql`。
- 说明：两张 updates 表中绝大多数行的 timestamp 均为 2026-10-28 05:31（即本次 dump 构建窗口），仅 acore_characters.updates 保留 2 行历史时间戳（2026-06-01、2026-04-12），因此 timestamp 列不能作为旧栈实际打补丁的时间依据。

---

## 3. schema 差异处理方式（如实记录）

- **旧栈 schema**：07-04 快照（见上节 updates 文件名边界）。
- **新栈**：Playerbot 分支 HEAD，本次迁移**未手工灌入任何 SQL 补丁**。
- **追平机制**：等 GitHub Actions 产出新二进制后，worldserver 首次启动时由 TC 官方 DBUpdater 自动追平——配置 `Updates.EnableDatabases=7`、`AutoSetup=1`，DBUpdater 逐文件比对 updates 表、缺失则执行并落表。
- **迁移期不手工灌补丁的理由**：
  1. DBUpdater 自带「已应用则跳过」的版本核对，手工灌补丁极易与 updates 表状态错位，造成二次执行或漏执行；
  2. 官方机制可重复、可审计（每步都有文件级记录落到 updates 表）；
  3. 当前新栈库内尚未产生任何写入，回滚与重来成本为零。
- **首启后需复核清单**：
  1. worldserver 启动日志无补丁执行失败 / 表结构报错；
  2. 四库 updates 表新增行数与预期补丁数一致；
  3. account=54、characters=566、guild=2、playerbots_names=100,000 复核不变；
  4. 登录实测（见下节）。

## 4. 验证结论

- **DB 级证据（已完成）**：账号 54（salt/verifier 完整、expansion=2）、角色 566（等级分布合理）、公会 2（成员合计 29）、bot 名字库 100,000、世界三表模板行数与 3.3.5a 基准一致；dump↔在线表数 23/117/316/30 逐项相符。
- **登录级验证（待办）**：需等 GitHub Actions 产出新二进制后首启 worldserver/authserver，实测账号登录、角色列表、世界在线。

## 5. 回滚方案

- 旧栈容器 `wow-mariadb` / `wow-wowserver` / `wow-portal` 与数据卷 `wow-mariadb-data` **保留未动**，旧栈数据原样可回。
- 新栈仅 `wow-mysql` 容器 + `wow-mysql-data` 卷，监听 127.0.0.1:3307，与旧栈 3306 无端口冲突。
- 回退动作：直接 `wslc stop wow-mysql`（及新栈其他容器）即可恢复旧栈全部服务；本次迁移对新库零写入（全程仅 SELECT），回滚无数据代价。
- 若未来新栈已产生新数据需回滚：先确认 3307 端口释放，再按旧栈原命令拉起即可。
