# 版本锁定清单（VERSIONS）

本文件锁定仓库基线与所有 vendor 模块的版本，用于可复现构建与审计。
更新时间：2026-10-28（基线拉取日期见下）。

## 1. 核心（Core）基线

| 项 | 值 |
|---|---|
| 仓库 | https://github.com/mod-playerbots/azerothcore-wotlk |
| 远端名 | `upstream` |
| 分支 | `Playerbot` |
| HEAD SHA | `3f2969ddb0da42b48b4fca050c02b19163ba1e20` |
| 提交日期 | 2026-10-22 17:32:24 -0700 |
| 提交信息 | Merge pull request #267 from mod-playerbots/test-staging — Test staging |
| 拉取方式 | `git fetch --depth=1 upstream Playerbot`，检出为本地 `main` |

> 说明：本仓库 `main` 分支即上述 Playerbot 分支快照（浅克隆，depth=1），上游快照本身构成初始提交。

## 2. Vendor 模块（modules/）

以下模块均以 `git clone --depth=1 <repo> master` 拉取后删除 `.git` 并移入 `modules/`，版本以实际拉取的 HEAD 为准。

| 模块 | 仓库 | 分支 | HEAD SHA | CMakeLists.txt |
|---|---|---|---|---|
| mod-ale | https://github.com/azerothcore/mod-ale.git | master | `84b85cc55980dbf67d596f3d5cb34ded10c59102` | 有（根目录） |
| mod-ah-bot | https://github.com/azerothcore/mod-ah-bot.git | master | `c11d8318cbd8714a9980f9464f78e07d3d48a70a` | 无（旧式 include.sh 结构） |
| mod-transmog | https://github.com/azerothcore/mod-transmog.git | master | `327753a05b9024f2a90738bb08e9b8afc2fc9a21` | 无（旧式 include.sh 结构） |
| mod-random-enchants | https://github.com/azerothcore/mod-random-enchants.git | master | `6d49d64918f1e798490d0139038a33194fd294df` | 无（旧式 include.sh 结构） |
| mod-boss-announcer | https://github.com/azerothcore/mod-boss-announcer.git | master | `3af6e83e976a9a143ded51f4e8afeb69863fb5ec` | 无（旧式 include.sh 结构） |

> 注意：除 mod-ale 外，其余 4 个模块的上游 master 根目录未提供 `CMakeLists.txt`，
> 为旧式 `include.sh` + `src/` 结构（已通过 GitHub API 核对上游 master 根目录确认，非本地缺失）。
> 集成阶段若 CMake 模块加载器要求 `modules/<名>/CMakeLists.txt`，需由集成阶段补齐 shim。

## 3. Playerbots 集成位置（重要）

经在本快照树内核查：**Playerbot 分支核心树本身并未内建 playerbots 模块源码**。

- `src/server/scripts/` 下**没有** `playerbots` 目录；`src/server/` 下无任何 `*playerbot*` 目录。
- `data/sql/` 下**没有** playerbots 相关目录。
- 全树仅 `.github/workflows/core-build-playerbots.yml` 一处引用 playerbot。
- 该 CI 工作流（第 42–48 行）显示：构建时会把**独立仓库** `mod-playerbots/mod-playerbots`
  （Playerbot 分支对应其 `master` 分支）额外检出到 `modules/mod-playerbots`。

结论：playerbots 并非分支内建，而是以独立模块形式存在于
`https://github.com/mod-playerbots/mod-playerbots`（目标路径 `modules/mod-playerbots`）。
本快照未 vendor 该模块（不在本次 5 模块清单内），由后续阶段按需补入。

配置模板与键命名：本快照核心树的 `conf/dist/` 下**不存在** playerbot 配置模板，
也检索不到 `AiPlayerbot.*` 键——这些由独立的 `mod-playerbots` 模块自身提供（该模块未在本树内，未核实到具体文件路径）。
后续汉化配置迁移时，需先 vendor `mod-playerbots` 后再定位其 conf 模板与键命名风格。

## 4. SQL 更新目录结构

```
data/sql/
├── base/                 # 三库基础建表脚本（auth/characters/world）
├── create/               # 初始建库脚本
├── updates/
│   ├── db_auth/          # auth 库增量更新（本次快照 16 个文件）
│   ├── db_characters/    # characters 库增量更新（11 个文件）
│   ├── db_world/         # world 库增量更新（1040 个文件）
│   ├── pending_db_auth/
│   ├── pending_db_characters/
│   └── pending_db_world/
├── archive/  old/        # 归档/历史脚本
└── custom/               # 自定义脚本（默认被 .gitignore 忽略）
```

本仓库自增 SQL 放在 `sql/localization/`（本地化补丁）与各模块自带的 `sql/` 目录。

## 5. 如何刷新上游

刷新上游基线与模块版本由后续 `scripts/sync-upstream.ps1` 负责（此处仅占位说明）；
执行后需回写本文件第 1、2 节的 SHA 与日期。
