# FORKS.md — 模块/脚本 fork 清单

> 规则（用户 2026-10-28 指令）：所有"有上游依赖"的 vendored 模块与 Lua，
> 一律"先 fork 上游，再推本地带修改副本"；fork 名被占用且非 fork 时报告处理，
> 不硬试、不删任何已存在仓库；全程不读/不回显/不记录令牌文件。
> 上游清单以 `docs\VERSIONS.md` 与 `modules\` 目录为准。

## 批次 A：6 个初始模块（完成 ✅）

| 模块 | 上游 URL | Fork URL | 默认分支 | 推送 commit | 本地修改 |
|------|----------|----------|----------|-------------|----------|
| mod-playerbots | https://github.com/mod-playerbots/mod-playerbots | https://github.com/xiaoran0503/mod-playerbots | master | `3647d2b374c5e25fe2849b5910b0cfeb8de28001` | 仅 vendor，无后续修改 |
| mod-ale | https://github.com/azerothcore/mod-ale | https://github.com/xiaoran0503/mod-ale | master | `48cfd2ba559406eb6889ec9cd870fcb0eae56f19` | 仅 vendor，无后续修改 |
| mod-ah-bot | https://github.com/azerothcore/mod-ah-bot | https://github.com/xiaoran0503/mod-ah-bot | master | `56a0085e7c65fcd4ef24446864e3ac0b705cb9ca` | 仅 vendor，无后续修改 |
| mod-transmog | https://github.com/azerothcore/mod-transmog | https://github.com/xiaoran0503/mod-transmog | master | `6ecd916b427d81480196f147769b04389d6a3dda` | 仅 vendor，无后续修改 |
| mod-random-enchants | https://github.com/azerothcore/mod-random-enchants | https://github.com/xiaoran0503/mod-random-enchants | master | `67cb4f9add08ff677b1a9e42d27e4a95fef0c9ce` | 仅 vendor，无后续修改 |
| mod-boss-announcer | https://github.com/azerothcore/mod-boss-announcer | https://github.com/xiaoran0503/mod-boss-announcer | master | `20bfe40c7ae561e6a59ba873f04e7785250db5fa` | 仅 vendor，无后续修改 |

> 批次 A 执行说明：6 个 fork 均为全新创建（初始查询全部 404，POST forks 返回 202 后
> 轮询就绪，全部 `fork=true`）；每次 push 均在首次尝试成功；每个模块的
> `git log --oneline -5 -- modules/mod-xxx` 仅显示 vendor 提交 `ba510347` 及更早
> 初始快照 `9adb6102`，无后续提交 → 全部标注"仅 vendor"。
> 主仓库未做任何 `git add`/`commit`，HEAD 保持原状；临时目录已清理。

## 批次 B：14 个新增模块 + Lua（待 CI 绿后执行 ⏳）

> 批次 B 子代理（s_000p4eSOW8p）在暂停指令时被终止，**已创建的 fork 保留**；
> 恢复后以 `docs\modules-wave2.md` 与 `docs\VERSIONS.md` 清单为准逐项核验。

（待补全：14 模块 fork URL / 分支 / 推送 sha / 是否有本地修改）

## 无上游/自研脚本（不适用 fork，仅注明）

| 脚本 | 来源 | 说明 |
|------|------|------|
| `custom\lua_scripts\遗产职业强化.lua` | 自研 | 无公开上游，不适用 fork |
| `custom\lua_scripts\掉落物品随机附魔.lua` | 谷神（无公开上游） | 不适用 fork |
| `custom\lua_scripts\RecruitAFriend.lua` | 谷神（无公开上游） | 不适用 fork |
| `custom\lua_scripts\SupMalachite.lua` | 谷神（无公开上游） | 不适用 fork |

---

*生成时间：2026-10-28 · 主仓库 HEAD：a4ea4ec8（CI 修复轮）*
