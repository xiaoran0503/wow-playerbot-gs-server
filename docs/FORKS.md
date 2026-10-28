# FORKS.md — 模块/脚本 fork 清单

> 规则（用户 2026-10-28 指令）：所有"有上游依赖"的 vendored 模块与 Lua，
> 一律"先 fork 上游，再推本地带修改副本"；fork 名被占用且非 fork 时报告处理，
> 不硬试、不删任何已存在仓库；全程不读/不回显/不记录令牌文件。
> fork 目标账号：`xiaoran0503`。SHA 校验标准：fork 默认分支 head SHA == 上游默认分支 head SHA。

## 批次 A：6 个初始模块（完成 ✅，2026-10-28）

fork 上的 SHA 为推送后的 vendor commit（P0 阶段将 vendor 副本推到 fork）。
上游锁定 SHA 见 `docs/VERSIONS.md`。

| 模块 | 上游仓库 URL | Fork 仓库 URL | 默认分支 | 上游锁定 SHA | Fork SHA（推送 commit） |
|------|--------------|---------------|----------|----------------|---------------------------|
| mod-playerbots | https://github.com/mod-playerbots/mod-playerbots | https://github.com/xiaoran0503/mod-playerbots | master | `e88cc4099e69f35126b28942a412ca702d20453b` | `3647d2b374c5e25fe2849b5910b0cfeb8de28001` |
| mod-ale | https://github.com/azerothcore/mod-ale | https://github.com/xiaoran0503/mod-ale | master | `84b85cc55980dbf67d596f3d5cb34ded10c59102` | `48cfd2ba559406eb6889ec9cd870fcb0eae56f19` |
| mod-ah-bot | https://github.com/azerothcore/mod-ah-bot | https://github.com/xiaoran0503/mod-ah-bot | master | `c11d8318cbd8714a9980f9464f78e07d3d48a70a` | `56a0085e7c65fcd4ef24446864e3ac0b705cb9ca` |
| mod-transmog | https://github.com/azerothcore/mod-transmog | https://github.com/xiaoran0503/mod-transmog | master | `327753a05b9024f2a90738bb08e9b8afc2fc9a21` | `6ecd916b427d81480196f147769b04389d6a3dda` |
| mod-random-enchants | https://github.com/azerothcore/mod-random-enchants | https://github.com/xiaoran0503/mod-random-enchants | master | `6d49d64918f1e798490d0139038a33194fd294df` | `67cb4f9add08ff677b1a9e42d27e4a95fef0c9ce` |
| mod-boss-announcer | https://github.com/azerothcore/mod-boss-announcer | https://github.com/xiaoran0503/mod-boss-announcer | master | `3af6e83e976a9a143ded51f4e8afeb69863fb5ec` | `20bfe40c7ae561e6a59ba873f04e7785250db5fa` |

## 批次 B：13 个 wave2 模块（完成 ✅，2026-10-28 / 2026-10-29）

wave2 模块为纯上游 fork（未向 fork 推送任何修改；vendor 修改留在本主仓库内），
fork SHA == 上游 head SHA，全部经 GitHub API 逐条核验 MATCH。
上游来源与 vendor 说明见 `docs/modules-wave2.md`。

| 模块 | 上游仓库 URL | Fork 仓库 URL | 默认分支 | 上游 head SHA = Fork SHA | fork 时间 |
|------|--------------|---------------|----------|---------------------------|-----------|
| mod-dungeon-quests | https://github.com/Hisha/mod-dungeon-quests | https://github.com/xiaoran0503/mod-dungeon-quests | main | `fe6456f89354f1ca8169093b6592f74951087400` | 2026-10-28（前序会话） |
| mod-attunement-skip | https://github.com/dr1s/mod-attunement-skip | https://github.com/xiaoran0503/mod-attunement-skip | master | `c2ee51ffda86acaec8ab6bc749f1c6a8ff02281f` | 2026-10-28（前序会话） |
| mod-junk-to-gold-plus | https://github.com/TrisBits/mod-junk-to-gold-plus | https://github.com/xiaoran0503/mod-junk-to-gold-plus | main | `8409491a5ea8590dc52c76ca0851d4fb2e19975a` | 2026-10-29 07:02 |
| wow-mod-accountwide-pets | https://github.com/buildthehomelab/wow-mod-accountwide-pets | https://github.com/xiaoran0503/wow-mod-accountwide-pets | main | `9af469be6566161934958a463c091e4248527b26` | 2026-10-29 07:03 |
| mod-dungeonmaster | https://github.com/bewarellamas/mod-dungeonmaster | https://github.com/xiaoran0503/mod-dungeonmaster | main | `07638d584a52e916deaf99d36ce4a40799a1065d` | 2026-10-29 07:04 |
| wow-mod-forever-journal | https://github.com/buildthehomelab/wow-mod-forever-journal | https://github.com/xiaoran0503/wow-mod-forever-journal | main | `856ae9548760954d81d1f36d7e7c41b221b68e15` | 2026-10-29 07:05 |
| mod-questie-bridge | https://github.com/Aldori15/mod-questie-bridge | https://github.com/xiaoran0503/mod-questie-bridge | main | `ad6ebd8fd70270992d0d843f0dc8c73ba924be30` | 2026-10-29 07:06 |
| mod-autobalance | https://github.com/azerothcore/mod-autobalance | https://github.com/xiaoran0503/mod-autobalance | master | `1d707cb61a0962ab01e4123681e2d3b66cc558a2` | 2026-10-29 07:07 |
| mod-solocraft | https://github.com/azerothcore/mod-solocraft | https://github.com/xiaoran0503/mod-solocraft | master | `59588838988d1b74111d26670d99d0e649014b93` | 2026-10-29 07:09 |
| mod-aoe-loot | https://github.com/azerothcore/mod-aoe-loot | https://github.com/xiaoran0503/mod-aoe-loot | master | `44486b1aecebd86944ce115972b3c839544903d3` | 2026-10-29 07:10 |
| Acore_RecruitAFriend | https://github.com/55Honey/Acore_RecruitAFriend | https://github.com/xiaoran0503/Acore_RecruitAFriend | master | `d72b80577c05737efb28306cae817f342ecbcf01` | 2026-10-29 07:11 |
| mod-quest-loot-party | https://github.com/pangolp/mod-quest-loot-party | https://github.com/xiaoran0503/mod-quest-loot-party | master | `c3955915c76d5a22a9d25a44482345d368a8de82` | 2026-10-29 07:12 |
| mod-quest-radar | https://github.com/warblups/mod-quest-radar | https://github.com/xiaoran0503/mod-quest-radar | master | `f7ce763e48d1c7db1afcd3611f13cd729c9c1b88` | ⏳ 待重试（fork 创建被限流） |

> 批次 B 执行说明：12/13 个 fork 全部为全新创建，POST fork 后轮询就绪，
> fork 默认分支 head SHA 均与上游 head SHA 逐字节相等（API 核验 MATCH）。
> **mod-quest-radar 例外**：自 2026-10-29 07:13 起多次 POST fork 均返回 HTTP 403
> （约 15 分钟内重试 7+ 次，含 4 分钟以上退避）；核心 API 配额 4925/5000 正常，
> 上游 `allow_forking=true`、未归档、未禁用——判定为 GitHub fork 端点次级限流
> （短时间创建 10 个 fork 触发的长窗口冷却）。重试方式（幂等）：
> `POST /repos/warblups/mod-quest-radar/forks`，随后核验 fork master head SHA
> == `f7ce763e48d1c7db1afcd3611f13cd729c9c1b88`，再把本行状态改为 ✅。

## 无上游/自研脚本（不适用 fork，仅注明）

| 脚本 | 来源 | 说明 |
|------|------|------|
| `custom\lua_scripts\遗产职业强化.lua` | 自研 | 无公开上游，不适用 fork |
| `custom\lua_scripts\掉落物品随机附魔.lua` | 谷神（无公开上游） | 不适用 fork |
| `custom\lua_scripts\RecruitAFriend.lua` | 谷神（无公开上游） | 不适用 fork（与 `Acore_RecruitAFriend` 模块同源，模块已 fork） |
| `custom\lua_scripts\SupMalachite.lua` | 谷神（无公开上游） | 不适用 fork |

---

*更新时间：2026-10-29 · 主仓库 HEAD：be690533*
