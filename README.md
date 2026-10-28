# wow-playerbot-server — 私人 AzerothCore 3.3.5a Playerbot 服务端（Docker + GitHub Actions）

基于 **mod-playerbots/azerothcore-wotlk 的 Playerbot 分支**自建的私人魔兽服务端仓库：
GitHub Actions 编译 → Docker 镜像 → MySQL 8.4 容器栈运行，同步谷神（GS_Server）机器人中文汉化
（名字池 / 说话文本 / 自定义策略 / Lua / 配置），并迁移既有存档。

- 仓库根：`E:\缓存\WOW\wow-playerbot-server`
- 上游与模块锁定版本：见 [docs/VERSIONS.md](docs/VERSIONS.md)
- 数据库迁移记录：见 [docs/MIGRATION.md](docs/MIGRATION.md)
- 谷神汉化同步说明：见 [docs/LOCALIZATION.md](docs/LOCALIZATION.md)
- PVE 玩法调研清单：见 [docs/PVE-MODS.md](docs/PVE-MODS.md)

---

## 1. 组件与架构

| 组件 | 内容 |
|---|---|
| 核心 | AzerothCore 3.3.5a **Playerbot 分支**（含 bot 引擎核心改动；与官方 master 内容近同步） |
| 模块（6 个，vendor 进 `modules/`） | **mod-playerbots**（玩家机器人，独立模块，与 Playerbot 分支配套）、mod-ale（Lua 引擎，Eluna 的官方继承版）、mod-ah-bot（拍卖行机器人）、mod-transmog（幻化）、mod-random-enchants（随机附魔）、mod-boss-announcer（BOSS 公告） |
| Lua 脚本 | 谷神 **SupMalachite.lua**（超级炉石菜单）、**掉落物品随机附魔.lua**、Eluna 扩展库（`custom/lua_scripts/`，由 mod-ale 加载） |
| 数据库 | **MySQL 8.4 LTS**（上游官方 compose 同款；最新上游二进制硬拒 MariaDB，故不用 MariaDB） |
| 门户 | 可选（compose `profile: full` 才启动，默认不带） |

已明确不用：mod-eluna（停更，换 mod-ale）、anticheat、1v1arena、pvpscript。

## 2. 仓库结构

```
wow-playerbot-server/
├── .github/workflows/          # build.yml(编译推镜像) + sync-upstream.yml(定时上游同步)
├── docker/                     # Dockerfile(多阶段) + docker-compose.yml + .env.example
├── modules/                    # 6 个 vendor 模块（无 .git，随快照合并策略刷新）
├── custom/
│   ├── lua_scripts/            # 谷神 Lua + Eluna 扩展（mod-ale 加载）
│   └── conf-seed/              # 私有配置种子 + gen-conf-seed.ps1 + KEYMAP-REPORT.md
├── sql/localization/           # 谷神汉化导入 SQL（名字池/说话文本/自定义策略）
├── scripts/                    # deploy-wslc.ps1 / smoke-test.ps1 / migrate-mysql.ps1 / sync-upstream.ps1
├── docs/                       # VERSIONS / MIGRATION / LOCALIZATION / PVE-MODS / gushen-reference
├── NOTICE                      # 第三方资产许可归属
└── README.md
```

> 根目录的 `docker-compose.yml` 是上游官方文件（来自分支快照），本项目实际编排在 `docker/docker-compose.yml`。

## 3. 版本锁定（快照日 2026-10-28）

| 组件 | 上游 | 分支 | HEAD |
|---|---|---|---|
| 核心 | mod-playerbots/azerothcore-wotlk | Playerbot | `3f2969ddb0da42b48b4fca050c02b19163ba1e20`（2026-10-22） |
| mod-playerbots | mod-playerbots/mod-playerbots | master | `e88cc4099e69f35126b28942a412ca702d20453b` |
| mod-ale | azerothcore/mod-ale | master | `84b85cc55980dbf67d596f3d5cb34ded10c59102` |
| mod-ah-bot | azerothcore/mod-ah-bot | master | `c11d8318cbd8714a9980f9464f78e07d3d48a70a` |
| mod-transmog | azerothcore/mod-transmog | master | `327753a05b9024f2a90738bb08e9b8afc2fc9a21` |
| mod-random-enchants | azerothcore/mod-random-enchants | master | `6d49d64918f1e798490d0139038a33194fd294df` |
| mod-boss-announcer | azerothcore/mod-boss-announcer | master | `3af6e83e976a9a143ded51f4e8afeb69863fb5ec` |

SQL 层：分支快照自带全量 `data/sql/base` 与 `data/sql/updates/{db_auth,db_characters,db_world}`，
模块自带 `modules/mod-playerbots/data/sql/{characters,playerbots,world}`。

## 4. 快速开始

### 前置
- 本机：`wslc` + `wslc-mirror`（镜像拉取走 docker.1ms.run 加速站），`pwsh`。
- GitHub 仓库 Secrets（推远程后配置）：`DOCKERHUB_USERNAME`、`DOCKERHUB_TOKEN`（Docker Hub Access Token，Read/Write）。

### 编译（GitHub Actions，本机不编译）
`build.yml` 触发：push `main` / 手动 dispatch / 每日 02:00 UTC 定时重建。
产物：Docker Hub 镜像 `<账号>/wow-{authserver,worldserver,db-import}`，tag=`YYYYMMDD-<sha8>` + `latest`；
每次构建上传 `image-manifest.txt` artifact 供部署核对。

### 部署
```powershell
# 1) 配置
Copy-Item docker\.env.example docker\.env   # 填密码/镜像地址/数据目录等
# 2) 部署（wslc 逐容器；默认复用 wow-mysql，门户默认不启动）
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\deploy-wslc.ps1
#    可选：-WithPortal(起门户) -StopOldStack(先停旧栈) -SkipPull(跳过拉镜像)
# 3) 冒烟
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts\smoke-test.ps1
```
有 docker compose 的环境也可用 `docker/docker-compose.yml`（等效）。

端口：auth **20241** / world **20242** / MySQL 宿主机 **3307** / 门户 **8081**。
数据目录（maps/dbc/vmaps/mmaps）只读挂载自 `E:\缓存\WOW\GS_Server\datalyf`（`WOW_DATA_DIR` 可改）。

### 全新安装（无迁移数据）
```powershell
docker compose -f docker\docker-compose.yml --profile fresh-install run --rm db-import
# 然后以 AC_UPDATES_ENABLE_DATABASES=0 启动 authserver/worldserver
```

## 5. 数据库迁移（已完成，记录见 docs/MIGRATION.md）

- 备份：`E:\缓存\WOW\_migration\mariadb-acore-full-20261028.sql`（364.13 MiB，SHA256 `254D2BF9AFF46973666442BD6AF7363BA294AA577B855E80FF5620D59C10D6C7`，四库全量）。
- 导入：MySQL 8.4 容器 `wow-mysql`（127.0.0.1:3307，卷 `wow-mysql-data`），四库表数 23/117/316/30 与 dump 逐项一致。
- 数据在位（2026-10-28 实测）：账号 **54**（SRP6 salt/verifier 32 字节完整）、角色 **566**、公会 **2**（29 成员）、
  realmlist 1（魔兽世界 / 127.0.0.1:20242 / gamebuild 12340）；世界库基准 creature_template 29951 / item_template 46098 / quest_template 9464。
- **schema 差异处理**：旧栈 schema 停在 07-04 快照（world updates 表 2763 条、最新 `2026_07_03`）；
  新栈 schema 由 **worldserver 首次启动时 DBUpdater 自动追平**（`Updates.EnableDatabases=7` / `AutoSetup=1`，
  官方机制逐文件记入 updates 表），迁移期不做手工灌补丁（理由与首启复核清单见 MIGRATION.md）。
- 回滚：旧栈容器与卷（wow-mariadb/wow-wowserver/wow-portal + wow-mariadb-data）保留未动。
- 验证口径：登录级验证需等 CI 产出新二进制后首启完成（DB 级证据已齐）。

## 6. 谷神汉化同步（详情见 docs/LOCALIZATION.md）

| 资产 | 状态 |
|---|---|
| Lua 脚本（SupMalachite / 掉落物品随机附魔 / Eluna 扩展） | 已入 `custom/lua_scripts/`（字节校验一致） |
| playerbots 配置汉化 | `custom/conf-seed/etc/modules/playerbots.conf`（894 键全集；谷神 522 键→477 键映射成功、
  95 处谷神调优值落地、45 键未映射均已说明；WorldBuff 36 条旧键由新 `Playerbots.WorldBuffMatrix` 完全取代；
  随机机器人 1000/1200） |
| 机器人中文名字池 | 已导入 `acore_characters.playerbots_names`：100,000 → **201,000**（中文 100,999 = 谷神 10 万 + 补充 1,000） |
| 公会/竞技场队名 | 目标库与谷神逐字一致，无需导入 |
| bot 中文说话文本 | `acore_playerbots.ai_playerbot_texts`：2,525 → **3,126**（中文 2,268 行 UPDATE） |
| 自定义策略 | `playerbots_custom_strategy`：7 → **90**（谷神策略补入） |
| 配置参考（worldserver/authserver/模块 GBK 转 UTF-8） | `docs/gushen-reference/` |

导入脚本（可重放）：`sql/localization/01..04*.sql`；导入前目标表快照在 `.wow-build-tmp\gs-sql-pre-import-backup\`。
未导入项及理由（孤儿运行时数据等）见 `sql/localization/README.md`。

## 7. 维护

- **同步上游**：`pwsh -File scripts\sync-upstream.ps1`（只提交不推送；`-Push` 才推 origin）。
  逻辑：fetch Playerbot 分支 depth-1 → reset --soft → 刷新 6 模块 vendor → 重生成 conf-seed → 提交。
  CI 侧 `sync-upstream.yml` 每日 03:00 UTC 自动执行同逻辑并 push main（可切换 PR 模式）。
- **定时重建**：`build.yml` 每日 02:00 UTC 自动重编译推镜像；也可手动 dispatch。
- 上游改配置键名时，对照各模块 `conf/*.conf.dist` 核对 `custom/conf-seed/gen-conf-seed.ps1` 的私有键表。

## 8. PVE 玩法调研

见 [docs/PVE-MODS.md](docs/PVE-MODS.md)（另有 HTML 版 `docs/PVE-MODS.html`）：25 条候选
（追加任务 3 / 任务增强 3 / 单人易玩 4 / 有趣独特 7 / 实用工具 8），每条含已验证上游地址、PVE 适配度、
维护状态与推荐理由，并给出 5 件推荐组合与 11 条避坑要点。

## 9. 许可证与归属

核心与模块均为上游开源工程（AzerothCore AGPL/GPL 系），本仓库保留各上游 LICENSE 与来源标注；
谷神私有资产（SupMalachite.lua 等）为社区散件、来源本地 GS_Server，归属说明见 [NOTICE](NOTICE)。

## 10. 已知限制 / 待办

1. 远程尚未推送（待提供 GitHub owner/name 后 `git remote add origin` + push），CI 首跑与登录级验证待推送后进行。
2. 根目录 `docker-compose.yml` 为上游官方文件（未使用），勿混淆。
3. 首启 worldserver 会自动应用上游 SQL 补丁追平 schema（约数分钟），之后按 MIGRATION.md 复核清单验证。
4. 谷神随机机器人初始值 1000/1200 按原版保留；如机器性能吃紧，改 `Playerbots.MinRandomBots/MaxRandomBots`。
