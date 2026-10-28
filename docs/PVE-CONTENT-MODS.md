# AzerothCore 3.3.5a PVE 内容向 Mod / Lua 深挖清单（任务 8）

> 目标服务端：AzerothCore 3.3.5a **Playerbot 分支**（mod-playerbots/mod-playerbots）
> 模块宿主：mod-ale（Eluna Lua Engine fork）
> 调研日期：2026-10-28（UTC+8）
> 本文档只挖**内容类**：自定义任务、任务/奖励/经验增强、自定义副本、新 Boss/世界事件、副本与 Boss 增强、中文社区 Lua 脚本渠道。
> 通用 QoL / 社交 / 经济类（基线 PVE-MODS.md 已覆盖的 25 条）一律不重复列出。

---

## 〇、与 PVE-MODS.md 的去重说明

以下条目**已在基线 PVE-MODS.md 列出**（含已 vendor / 已推荐 / 已避坑），本文档不再重复展开，出现即跳过：

- A 类基线：Hisha/mod-dungeon-quests、dr1s/mod-attunement-skip、55Honey/Acore_RecruitAFriend
- B 类基线：pangolp/mod-quest-loot-party、warblups/mod-quest-radar、Aldori15/mod-questie-bridge
- C 类基线：azerothcore/mod-autobalance、azerothcore/mod-solo-lfg、azerothcore/mod-chromie-xp、Galuur/mangos_solocraft（Lua 版 Solocraft）
- D 类基线：azerothcore/mod-progression-system、azerothcore/mod-zone-difficulty、ngc7052/mod-gauntlet、PrivateDonut/hardcore_mode、Garretonzo/mod-hardcore-high-risk、AzoghMartins/mod-ip-challengesystem、55Honey/Acore_eventScripts
- E 类基线：azerothcore/mod-aoe-loot、TrisBits/mod-junk-to-gold-plus、azerothcore/mod-morphsummon、buildthehomelab/wow-mod-accountwide-pets、bewarellamas/mod-dungeonmaster、azerothcore/mod-guildhouse、buildthehomelab/wow-mod-forever-journal、ornfelt/azerothcore_lua_scripts

**概念重复但需留档的对照项**（不列入正文）：

| 条目 | 处理 |
|---|---|
| azerothcore/mod-solocraft（77★，pushed 2026-09-21，官方 C++ Solocraft） | 与基线 C4（Galuur Lua 版）同概念。想要 C++ 版用这个，**不要用 trickerer/mod-solocraft**（NPCBots 生态，避坑）。二选一 |
| pangolp/mod-groupquests | 与基线 B1（mod-quest-loot-party）同概念（队伍共享任务物品/目标），跳过 |
| Hisha/mod-aq-war-effort、Hisha/mod-war-effort | 与官方 azerothcore/mod-war-effort 重复，选官方 |
| dr1s/mod-playerbots-auto-guild、dr1s/mod-corpse-respawn、warblups/mod-accountwide | 实用向非内容类，不展开 |

---

## 一、新增任务 / 任务线（custom quests）——共 3 条

| # | 名称 | 上游 URL | 功能简述 | PVE 适配度 | Playerbot 兼容性 | 推荐理由 | 现状 | 玩家可见字符串 |
|---|---|---|---|---|---|---|---|---|
| 1-1 | bewarellamas/quest-customquestpack | https://github.com/bewarellamas/quest-customquestpack | 少见的纯自定义任务包（SQL 任务内容），面向私服 | ★★★☆☆ | 纯 SQL 任务入库，不依赖 Eluna hook → mod-ale/SQL 链路兼容；bot 接任务行为按原版 AI 走 | 全网少有的独立"任务包"形态，可直接往库里加任务线 | **停更**（pushed 2023-05-04，2★；ls-remote 验证 OK） | 英文，需汉化 |
| 1-2 | blinkysc/mod-omen-of-clarity | https://github.com/blinkysc/mod-omen-of-clarity | 野性德鲁伊 Faerie Fire 触发 Clearcasting；通过一条 5 步草药任务线 + Keeper Remulos 对话开关实现 | ★★★☆☆ | C++ 模块（需重编）；任务逻辑独立，与 playerbots 无已知冲突钩子 | 罕见的"用任务线承载职业机制改动"样本，独特性高 | 半活跃（pushed 2026-03-07，1★；ls-remote OK） | 英文，需汉化 |
| 1-3 | pangolp/mod-archmage-timear | https://github.com/pangolp/mod-archmage-timear | 把后续版本删掉的"达拉然 Archmage Timear 日常英雄副本任务"加回来 | ★★★★☆ | C++ 模块；恢复原版日常本任务线，bot 进本流程天然契合 | 单人服每天给 playerbots 一个明确的刷本目标；恢复被官方砍掉的内容 | **停更**（pushed 2022-07-03，2★；ls-remote OK） | 英文，需汉化 |

## 二、任务增强 / 奖励 / 经验类——共 8 条（含 1 条谨慎项）

| # | 名称 | 上游 URL | 功能简述 | PVE 适配度 | Playerbot 兼容性 | 推荐理由 | 现状 | 玩家可见字符串 |
|---|---|---|---|---|---|---|---|---|
| 2-1 | azerothcore/mod-congrats-on-level | https://github.com/azerothcore/mod-congrats-on-level | 升到指定等级自动发奖励（金币/物品配置） | ★★★★☆ | C++ 模块；升级奖励与 bot 升级路径无冲突 | 28★ 官方模块，**昨天（2026-10-27）刚 push**，单人服升级正反馈直接 | 活跃（28★，API 验证） | 英文，需汉化 |
| 2-2 | azerothcore/mod-item-level-up | https://github.com/azerothcore/mod-item-level-up | 升级时发放对应等级装备/物品 | ★★★☆☆ | C++ 模块 | 与 2-1 互补：一个发钱一个发装备 | 半停更（10★，pushed 2025-08-02） | 英文，需汉化 |
| 2-3 | 55Honey/Acore_LevelUpReward | https://github.com/55Honey/Acore_LevelUpReward | Lua 版升级奖励，带官方排名 playercounter | ★★★★☆ | **Lua 脚本，mod-ale 直接加载**，无需重编 | 不想动编译链时的首选奖励脚本；18★ 作者代表作 | 停更（pushed 2024-10-02；ls-remote OK） | 英文，需汉化 |
| 2-4 | azerothcore/mod-individual-xp | https://github.com/azerothcore/mod-individual-xp | 玩家自行调整个人经验速率（NPC/命令） | ★★★★☆ | C++ 模块；单人服加速升级最直接的官方方案 | 29★、昨天 push；可按自己节奏拉升级速度 | 活跃（API 验证，pushed 2026-10-27） | 英文，需汉化 |
| 2-5 | azerothcore/mod-dynamic-xp | https://github.com/azerothcore/mod-dynamic-xp | 按等级区间动态配置经验系数 | ★★★☆☆ | C++ 模块 | 平滑"旧世界练级太快/满级后空虚"的经典问题 | 半停更（23★，pushed 2025-11-02） | 英文，需汉化 |
| 2-6 | azerothcore/mod-weekend-xp | https://github.com/azerothcore/mod-weekend-xp | 周末/特定时段双倍经验 | ★★★☆☆ | C++ 模块 | 制造"周末上线"节奏；单人服可常开 | 活跃（23★，pushed 2026-10-18） | 英文，需汉化 |
| 2-7 | quasistatic-setup/azerothcore-custom-modules | https://github.com/quasistatic-setup/azerothcore-custom-modules | **明确 Playerbot-oriented** 的定制集：任务物品掉率、组队效率、离线尸体刷新、回蓝、新手欢迎奖励 | ★★★★☆ | 作者描述原文即 "Playerbot-oriented gameplay tweaks"，按设计兼容 bot 组队 | 本次唯一明确为 playerbots 生态写的模块集，5 天前刚 push | 极新活跃（0★，pushed 2026-10-23；ls-remote OK） | 英文，需汉化 |
| 2-8 | pangolp/mod-assistant | https://github.com/pangolp/mod-assistant | 名字像任务助手，但**仓库无描述、无文档** | ★★☆☆☆ 谨慎 | 未核验 | **别当真当任务助手上**：1★、2022-07 后停更，无 README | 停更（API 验证） | 未知（未读码） |

## 三、新增副本 / 自定义实例——共 3 条

| # | 名称 | 上游 URL | 功能简述 | PVE 适配度 | Playerbot 兼容性 | 推荐理由 | 现状 | 玩家可见字符串 |
|---|---|---|---|---|---|---|---|---|
| 3-1 | Hisha/mod-content-manager | https://github.com/Hisha/mod-content-manager | 自定义内容包**框架**：自动分配 realm-safe ID、生成与服务端同步的 3.3.5a 客户端内容 | ★★★★☆（框架级） | C++ + 客户端内容同步；bot 进本走原版进本逻辑，无已知冲突 | Hisha 2026 新体系底座，后续他的原生内容包（hunts/instance-maps）都挂在这上面 | 极活跃（0★，pushed 2026-10-19；API 验证） | 英文，需汉化 |
| 3-2 | Hisha/mod-native-instance-maps | https://github.com/Hisha/mod-native-instance-maps | 基于 mod-content-manager 的**实例地图内容包**（自定义副本地图） | ★★★☆☆ | 同 3-1；但自定义地图需要客户端 MPQ/VMap 定制 | 方向独特（真·自定义副本），但 0★ 早期项目，工程量大 | 早期（0★，pushed 2026-10-05；首轮 ls-remote 误报 404，经 API + 二次 ls-remote 复核为 OK） | 英文，需汉化 |
| 3-3 | azerothcore/mod-guild-zone-system | https://github.com/azerothcore/mod-guild-zone-system | 自定义公会区域（独立地图/空间） | ★★★☆☆ | C++ 模块 | 单人服可当私人据点；13★ 官方体系内 | 半活跃（13★，pushed 2026-07-14） | 英文，需汉化 |

## 四、新 Boss / 世界事件——共 6 条

| # | 名称 | 上游 URL | 功能简述 | PVE 适配度 | Playerbot 兼容性 | 推荐理由 | 现状 | 玩家可见字符串 |
|---|---|---|---|---|---|---|---|---|
| 4-1 | azerothcore/mod-instanced-worldbosses | https://github.com/azerothcore/mod-instanced-worldbosses | 官方模块：世界 Boss 副本化处理（独立实例化进度） | ★★★★☆ | C++ 模块；世界 Boss 独立实例化避免了"野外 Boss 被刷烂" | 官方内容向模块稀缺品；4★、2026-09 仍在更新 | 活跃（4★；ls-remote OK；README 未深读——raw 访问超时） | 英文，需汉化 |
| 4-2 | 55Honey/Acore_CustomWorldboss | https://github.com/55Honey/Acore_CustomWorldboss | Lua 世界 Boss **生成器**：刷自定义 NPC 并赋予脚本化战斗技能 | ★★★★☆ | **Lua 脚本，mod-ale 直载**，不重编 | 不写 C++ 也能自己造世界 Boss，正好给 playerbots 找新目标 | 停更（2★，pushed 2022-04-15；ls-remote OK） | 英文，需汉化 |
| 4-3 | trickerer/boss_runeworder | https://github.com/trickerer/boss_runeworder | Diablo II 主题自定义 Boss（符文师），面向 TrinityCore/AzerothCore 3.3.5 | ★★★☆☆ | ⚠️ 作者主线是 NPCBots 生态；Boss 脚本本身能否脱离 NPCBots 独立运行**未核验** | 内容独特度高，适合当移植练手素材 | 停更（6★，pushed 2022-01-28；ls-remote OK） | 英文，需汉化 |
| 4-4 | Hisha/mod-living-world | https://github.com/Hisha/mod-living-world | SQL 编写的动态世界：分阶段入侵、路线化 NPC 移动、旅行事件、日历驱动的世界事件 | ★★★★☆ | C++（SQL 内容为主）；世界事件与 bot 机制无冲突钩子 | 独特性最高的一条：把"世界是活的"做成 SQL 可配，赛季感直接拉满 | 活跃（3★，pushed 2026-09-02；ls-remote OK） | 英文，需汉化 |
| 4-5 | Hisha/mod-hunts | https://github.com/Hisha/mod-hunts | 狩猎/猎物系统：猎印（Huntmaster's Seals）货币换装备，配套客户端插件 HuntsUI | ★★★★☆ | C++ + 客户端 addon；独立刷取循环，bot 可参与打怪循环 | 给"杀怪"加了一个自成体系的奖励循环，6★ 且 2026-09 在更 | 活跃（6★；ls-remote OK） | 英文，需汉化 |
| 4-6 | azerothcore/mod-war-effort | https://github.com/azerothcore/mod-war-effort | 官方：安其拉开门战争捐献世界事件复刻 | ★★★☆☆ | C++ 模块 | 经典世界级事件；单人服可当一次性大事件跑 | 活跃（7★，pushed 2026-06-21） | 英文，需汉化 |

## 五、副本与 Boss 增强（难度 / 机制 / 掉落 / 挑战）——共 4 条

| # | 名称 | 上游 URL | 功能简述 | PVE 适配度 | Playerbot 兼容性 | 推荐理由 | 现状 | 玩家可见字符串 |
|---|---|---|---|---|---|---|---|---|
| 5-1 | azerothcore/mod-azerothshard | https://github.com/azerothcore/mod-azerothshard | AzerothShard 私服私有定制**合集**（自定义功能集合） | ★★★★☆ | C++ 模块集；具体子项与 bot 的冲突面**未逐一核验** | 25★，运营级私服沉淀的定制库，可逐个子项挑着用 | 活跃（25★，pushed 2026-09-21） | 英文，需汉化 |
| 5-2 | 55Honey/Acore_ZoneDebuff | https://github.com/55Honey/Acore_ZoneDebuff | Lua：按区域给玩家加 Debuff（模拟旧世界/硬核难度） | ★★★★☆ | **Lua 脚本，mod-ale 直载** | 与基线 mod-zone-difficulty（C++）思路相同但 Lua 轻量版；想怀旧难度可先用它 | 停更（6★，pushed 2023-03-08；ls-remote OK） | 英文，需汉化 |
| 5-3 | azerothcore/mod-rdf-expansion | https://github.com/azerothcore/mod-rdf-expansion | 高等级角色可排旧资料片随机副本 | ★★★☆☆ | C++ 模块；配合 playerbots RDF 可跨资料片刷本 | 80 级也能回去打旧本，内容复用率高 | 半停更（18★，pushed 2025-02-22） | 英文，需汉化 |
| 5-4 | uiwow 整合包：Azerothcore-pbot 无职业随机抽卡 + 挑战模式 | http://uiwow.com/forum.php?mobile=2&mod=viewthread&ordertype=1&tid=38964 | 基于 mod-playerbots 官服端的**整合包**：无职业随机抽卡 + 挑战模式玩法，百度网盘分发 | ★★★☆☆ | 底层即 mod-playerbots 官方端，天然兼容 | 中文社区少见的"挑战模式"现成方案；但是整包非独立 mod | 2026-10-04 发布（搜索快照验证可达）；**需注册论坛 + 网盘下载** | **自带中文** |

## 六、Eluna/ALE Lua 脚本渠道（中文社区）——共 4 条

| # | 名称 | 链接 | 内容 | 状态核验 | 备注 |
|---|---|---|---|---|---|
| 6-1 | AzerothCore 中文论坛 · Eluna & Modules 板块 | https://forum.azerothcore.cn/forum.php?mod=forumdisplay&fid=5 | 中文 Eluna 脚本集散地：含"超级炉石 Lua（带附魔、清除附魔）"等（超级炉石已在你锁定集） | 搜索快照验证板块页可达（最新帖 2026-04-23） | **需注册**浏览下载；帖子多为网盘附件 |
| 6-2 | uiwow.com 魔兽有爱论坛 | http://uiwow.com/forum.php?mod=viewthread&tid=38964（见 5-4） | 大量"服务端+脚本"整合贴，多为百度网盘 | 帖子快照可达（2026-10-04） | **需注册 + 网盘**；资源质量参差，下前看评论 |
| 6-3 | iopq 藏宝湾论坛 | （本次未获取到有效帖子页 URL） | 任务指定渠道之一 | **链接未核验** | 不建议直接从该站下未验脚本（木马风险）；仅作线索，找到帖子需先查毒 |
| 6-4 | AZCore Blog 副本脚本开发实战教程 | https://blog.azcore.top/azerothcore/azerothcore-%E5%89%AF%E6%9C%AC%E8%84%9A%E6%9C%AC%E5%BC%80%E5%8F%91%E5%AE%9E%E6%88%98%EF%BC%9A%E4%BB%8E%E6%99%AE%E9%80%9A%E6%80%AA%E7%89%A9%E5%88%B0-boss-ai-%E7%9A%84%E5%AE%8C%E6%95%B4%E5%AE%9E/ | 自定义副本（shadowdeep_mine，MAP_ID 3000）+ 3 个自定义 Boss AI 的完整 Lua 教程 | 搜索快照验证（2026-07-02） | 是**教程范本**不是现成 mod；可作为自建副本脚本的模板 |

**客户端插件备注**（非服务端 mod，仅记录存在性，ls-remote 已验证 OK）：
- CosmicCuddle/N-Dungeon-Journal（2★，2026-10-18）：客户端副本日志（旧世副本/团本/世界 Boss）
- CosmicCuddle/N-Addon-Collection（1★，2026-10-25）：客户端插件集（Individual Progression + Playerbot 集成）
- stuhby/norg-wow-addons（0★，2026-09-17）：任务路径/副本 Boss 导航客户端插件
- Hisha/HuntsUI、AutoTalentsUI、BankReagentsUI：对应 4-5 / mod-auto-talents / mod-bank-reagents 的客户端插件

---

## 七、重点推荐 Top 7（按独特性 + Playerbot 友好度排序）

1. **quasistatic-setup/azerothcore-custom-modules（2-7）** — 本次唯一明确按 Playerbot 生态写的模块集，任务掉率/组队效率/bot 体验全包，5 天前还在更新。
2. **Hisha/mod-living-world（4-4）** — SQL 驱动的动态世界（入侵/日历事件），独特性最高，赛季感玩法底座。
3. **azerothcore/mod-congrats-on-level（2-1）** — 28★ 官方、昨天 push，升级奖励体验提升最直接。
4. **55Honey/Acore_CustomWorldboss（4-2）** — Lua 自定义世界 Boss 生成器，mod-ale 直载零编译，给 bot 造新目标。
5. **bewarellamas/quest-customquestpack（1-1）** — 全网少有的纯自定义任务包（虽停更），补内容量最直接。
6. **azerothcore/mod-instanced-worldbosses（4-1）** — 官方世界 Boss 副本化，野外 Boss 不被刷烂。
7. **pangolp/mod-archmage-timear（1-3）** — 恢复被砍的日常英雄本任务线，给 bot 日常刷本一个固定目标。

## 八、避坑清单

| 条目 | 一句话理由 |
|---|---|
| **azerothcore/mod-npc-beast-trainer** | **404（已用 ls-remote 实证）**：任务里猜测的名字不存在；实际是 azerothcore/mod-npc-beastmaster（32★，2026-05，NPC 驯服野兽服务，QoL 向，非内容扩展） |
| **UltraNix 用户账号** | GitHub 用户整体 404（API 实证）；其历史 fork 一律不可追 |
| **dr1s/tw-mod-* 系列** | Tortoise WoW（1.16.x R60 客户端）专用，**WotLK 3.3.5a 不可用**；dr1s 的非 tw- 前缀模块才是本端适用 |
| **trickerer 全家桶（mod-solocraft / AzerothCore-wotlk-with-NPCBots / boss_runeworder 依赖链）** | NPCBots 生态，与 mod-playerbots 钩子重叠，双装必崩（基线已述，重申）；boss_runeworder（4-3）仅建议"只读移植" |
| **pangolp/mod-assistant（2-8）** | 无 README 无描述停更，别当任务助手上 |
| **Hisha/mod-native-instance-maps（3-2）** | 0★ 早期：自定义客户端地图需 MPQ/VMap 定制，工程量极大，验证期勿上 |
| **iopq 藏宝湾直下脚本** | 链接未核验 + 未杀毒，木马风险；仅作线索 |
| **mod-progression-system / mod-zone-difficulty（基线 D1/D2）** | 若再启用，bot 会被进度锁限制装备/副本权限——是特性，但要把 bot 默认装备纳入进度表（基线已述） |

## 九、URL 验证统计

- **GitHub API 验证（返回 pushed_at / stargazers_count）**：7 位作者仓库列表（55Honey、liyunfan1223、Hisha、warblups、dr1s、trickerer、pangolp）、azerothcore 组织两页（mod-* 全量约 120 个）、8 个指定 repo 详情、6 组关键词 search（custom quest / world boss / custom dungeon / challenge / custom boss / quest reward / instance maps）。
- **git ls-remote 验证（20 个仓库批量）**：18 个 OK；首轮 2 个 404 复核——`Hisha/mod-native-instance-maps` 系网络误报（API + 二次 ls-remote 确认**存在**）；`azerothcore/mod-npc-beast-trainer` 复核确认为**真 404**。
- **中文网页验证**：forum.azerothcore.cn fid=5 板块、uiwow tid=38964 帖、blog.azcore.top 教程均经搜索快照确认可达；iopq 藏宝湾**链接未核验**。
- **API 限流**：全程未触发 60 次/小时上限（未排队等待即完成）；raw.githubusercontent 单次抓取超时，对应条目已如实标注"README 未深读"。

## 十、汉化备注（供后续汉化工作流）

- **全部 GitHub 系条目（第一~五节 28 条）玩家可见字符串均为英文**，无一自带中文，后续需走汉化工作流（NPC 名/任务文本/奖励邮件/系统消息）。
- Hisha、quasistatic-setup、blinkysc 等 2025-2026 新作者**无任何中文化痕迹**，不要指望现成中文包。
- **自带中文**的只有中文渠道产物：uiwow 整合包（5-4）、forum.azerothcore.cn 板块脚本（6-1）。
- 优先汉化顺序建议：先 Top 7（尤其 4-2 Lua 生成器的 NPC 名、1-3 的日常本任务文本、4-4 的世界事件广播）。
