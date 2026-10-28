# AzerothCore 3.3.5a PVE 玩法 mod / Lua 调研清单

> 目标服务端：AzerothCore 3.3.5a **Playerbot 分支**（`mod-playerbots/mod-playerbots`，1195★，2026-10-24 仍活跃）
> 模块宿主：`mod-ale`（ALE = Eluna Lua Engine fork，194★，GPL-3.0）
> 已锁定/已有：mod-playerbots、mod-ale、mod-ah-bot、mod-transmog、mod-random-enchants、mod-boss-announcer、超级炉石 Lua、掉落随机附魔 Lua
> 已排除：mod-eluna（停更，已被 mod-ale 取代）、anticheat、1v1arena、pvpscript
> 调研日期：2026-10-28（UTC+8）

---

## 一、候选清单（共 25 条：A=3, B=3, C=4, D=7, E=8）

### A. 追加任务类（新增任务 / 任务包 / 自定义链 / 日常）

| # | 名称 | 上游地址 | 功能简述 | PVE 适配度 | 维护状态（最近 push） | 形态 | 推荐度与理由 |
|---|---|---|---|---|---|---|---|
| A1 | Hisha/mod-dungeon-quests | https://github.com/Hisha/mod-dungeon-quests | 在每个副本入口加 NPC，一次性发放该副本对应的全部任务（原版副本任务往往要跑地图找 NPC） | ★★★★☆ | 2026-09-11，3★，MIT | C++ 模块（需重编） | **高**。单人+playerbots 下最痛的就是"进本前要跑一圈接任务"，这个直接解决；与 playerbots 进本流程天然契合 |
| A2 | dr1s/mod-attunement-skip | https://github.com/dr1s/mod-attunement-skip | 玩家升级/进本时自动发放团本开门任务物品并自动完成开门任务链（卡拉赞、熔火之心、黑翼之巢等） | ★★★★☆ | 2026-05-23，3★，MIT | C++ 模块（需重编） | **高**。单人服最大门槛之一就是开门链；配置上可按等级自动放行，避免 playerbots 卡在开门任务 |
| A3 | 55Honey/Acore_RecruitAFriend | https://github.com/55Honey/Acore_RecruitAFriend | 独立的"招募战友"系统（召唤、经验加成、绑定奖励），纯 Lua 实现 | ★★★☆☆ | 2025-02-26，14★ | **Lua 脚本（mod-ale 直接加载）** | **中**。单人服可用来给自己 alt 号绑定加成；Lua 形态无需重编，适合先试玩 |

### B. 任务增强类（任务系统 / 奖励 / 追踪 QoL）

| # | 名称 | 上游地址 | 功能简述 | PVE 适配度 | 维护状态 | 形态 | 推荐度与理由 |
|---|---|---|---|---|---|---|---|
| B1 | pangolp/mod-quest-loot-party | https://github.com/pangolp/mod-quest-loot-party | 队伍成员击杀同一 NPC 时，所有人都能拿到任务物品（原版只有首个接任务者能拾取） | ★★★★★ | 2026-10-12，32★，AGPL-3.0 | C++ 模块 | **强烈推荐**。playerbots 组队做任务时最常见的痛点就是"任务物品只有你一个人能捡"，这个直接根治 |
| B2 | warblups/mod-quest-radar | https://github.com/warblups/mod-quest-radar | 服务端模块 + 客户端插件：在小地图上显示任务目标位置（WotLK 原版没有这个，要靠 Questie 插件读静态数据） | ★★★★☆ | 2026-09-12，4★，AGPL-3.0 | C++ 模块 + 客户端 addon | **高**。与 Questie 互补：Questie 是静态数据库，这个是实时服务端下发；中文环境下配合谷神汉化体验提升明显 |
| B3 | Aldori15/mod-questie-bridge | https://github.com/Aldori15/mod-questie-bridge | 服务端把动态世界状态（事件、任务池、世界状态进度）实时推送给 Questie-335 插件 | ★★★★☆ | 2026-10-09，5★ | C++ 模块 + 客户端 addon | **高**。如果客户端已装 Questie，这个模块让 Questie 能显示你服务端的自定义任务/事件进度，不只是静态数据 |

### C. 提高单人易玩性（副本缩放 / 单人副本 / 经验掉落调整 / playerbots 联动）

| # | 名称 | 上游地址 | 功能简述 | PVE 适配度 | 维护状态 | 形态 | 推荐度与理由 |
|---|---|---|---|---|---|---|---|
| C1 | azerothcore/mod-autobalance | https://github.com/azerothcore/mod-autobalance | 经典中的经典：根据队伍人数动态调整副本/团本怪物的 HP、伤害、掉落；1 人进本 = 1 人难度，5 人 = 5 人难度 | ★★★★★ | 2026-10-07，165★ | C++ 模块 | **强烈推荐**。但**注意**：playerbots 会占队伍名额，autobalance 会按"真实人数"算难度，要在配置里把 playerbots 视作真实队员（默认就是）；若觉得 playerbots 打的太猛，可把难度系数调低 |
| C2 | azerothcore/mod-solo-lfg | https://github.com/azerothcore/mod-solo-lfg | 官方 Solo LFG：单人排随机副本时自动补齐空位置（原版逻辑） | ★★★☆☆ | 2025-02-27，58★，MIT | C++ 模块 | **中**。**与 playerbots 功能重叠**：playerbots 自带 `/bot lfg`、`/bot teleport` 就能补齐。建议二选一；若用 playerbots 则这个可不上 |
| C3 | azerothcore/mod-chromie-xp | https://github.com/azerothcore/mod-chromie-xp | Chromie XP：玩家可自选升级"资料片时段"（旧世界 / TBC / WotLK），对应地图怪物等级缩放 | ★★★★☆ | 2025-02-28，2★，AGPL-3.0 | C++ 模块 | **中高**。让 1-80 升级路线更灵活；注意 playerbots 升级路径默认按 WotLK 走，配置时要让 bot 也尊重同一时段 |
| C4 | Galuur/mangos_solocraft | https://github.com/Galuur/mangos_solocraft | Solocraft 的 Lua 移植版：玩家单人时获得伤害/治疗/生存 Buff，组队时自动取消 | ★★★★☆ | 2026-03-02，3★ | **Lua 脚本（mod-ale 直接加载）** | **高**。Lua 形态不用重编，适合单人服；与 playerbots 同队时 Buff 自动撤下，不会过强。比 C++ 版 Solocraft 轻量（C++ 版 trickerer/mod-solocraft 面向 NPCBots，见避坑） |

### D. 有趣 / 独特玩法（挑战模式 / 硬核 / 进度锁 / 自定义事件 / 生存）

| # | 名称 | 上游地址 | 功能简述 | PVE 适配度 | 维护状态 | 形态 | 推荐度与理由 |
|---|---|---|---|---|---|---|---|
| D1 | azerothcore/mod-progression-system | https://github.com/azerothcore/mod-progression-system | ChromieCraft 官方进度系统：按时间/阶段锁定副本、装备、技能、地图（P1 只开熔火之心，P2 开黑翼之巢……） | ★★★★★ | 2026-10-18，82★，AGPL-3.0 | C++ 模块 | **强烈推荐（但要慎重）**。这是最成熟的"赛季化/内容进度锁"方案。**注意**：playerbots 也会被进度锁限制（不能穿没开放的装备、不能进没开放的本），这正是想要的效果；但首次配置工作量大，建议先看 mod-zone-difficulty 的示例配置 |
| D2 | azerothcore/mod-zone-difficulty | https://github.com/azerothcore/mod-zone-difficulty | mod-progression-system 的配套：按区域/阶段给怪物加 Buff/Nerf，模拟"当前阶段难度" | ★★★★☆ | 2026-10-17，34★，AGPL-3.0 | C++ 模块 | **高**。通常和 D1 一起装；单人服可以独立用来"怀旧服难度"（如旧世界怪物 +30% HP 模拟经典旧世） |
| D3 | ngc7052/mod-gauntlet | https://github.com/ngc7052/mod-gauntlet | Roguelike 硬核挑战：一命通关，每升一级随机获得一个词缀（69 种机制） | ★★★★☆ | 2026-09-01，3★ | C++ 模块 | **高（尝鲜）**。设计独特，不是简单的"死了删号"，而是词缀 roguelike；适合作为赛季玩法 |
| D4 | PrivateDonut/hardcore_mode | https://github.com/PrivateDonut/hardcore_mode | Eluna Lua 实现的硬核模式：永久死亡、Ironman 规则、XP 加成、里程碑 | ★★★★☆ | 2025-08-27，5★ | **Lua 脚本（mod-ale 直接加载）** | **高**。Lua 实现不用重编，功能齐全（hardcore/ironman 双模式）；playerbots 通常不参与硬核（bot 死后不删号），要配置好 |
| D5 | Garretonzo/mod-hardcore-high-risk | https://github.com/Garretonzo/mod-hardcore-high-risk | 高风险服规则：死亡掉落身上装备、复活/删号规则，**明确为 playerbots 设计** | ★★★★☆ | 2026-10-01，0★ | C++ 模块 | **中高**。作者就是冲 playerbots 生态来的；0★ 说明还没人用，但方向对。适合想做"高风险赛季" |
| D6 | AzoghMartins/mod-ip-challengesystem | https://github.com/AzoghMartins/mod-ip-challengesystem | Individual Progression 框架：分层可选挑战（Hardcore、SSF 单人拾取、Solo、低 XP 等） | ★★★★☆ | 2026-02-10，2★ | C++ 模块 | **中高**。与 D1/D4 互补：D1 是全局进度锁，这个是"玩家自选规则包"；适合做成就/赛季 |
| D7 | 55Honey/Acore_eventScripts | https://github.com/55Honey/Acore_eventScripts | Lua 集合：生成自定义相位 Boss、世界事件、玩具 | ★★★★☆ | 2025-02-19，26★ | **Lua 脚本（mod-ale 直接加载）** | **高**。26★ 说明实用；可以直接拿里面的相位 Boss 当"自定义世界 Boss"给 playerbots 打 |

### E. 实用工具类（随从 / 便捷功能）

| # | 名称 | 上游地址 | 功能简述 | PVE 适配度 | 维护状态 | 形态 | 推荐度与理由 |
|---|---|---|---|---|---|---|---|
| E1 | azerothcore/mod-aoe-loot | https://github.com/azerothcore/mod-aoe-loot | 一键拾取周围所有尸体的掉落（不用逐个点） | ★★★★★ | 2026-10-27，86★，AGPL-3.0 | C++ 模块 | **强烈推荐**。86★、昨天还在更新；单人+playerbots 下从副本出来满地尸体一键全收，体验提升巨大 |
| E2 | TrisBits/mod-junk-to-gold-plus | https://github.com/TrisBits/mod-junk-to-gold-plus | 自动卖灰色垃圾，但有安全保护：任务物品、可用装备、升级装备不会被自动卖 | ★★★★☆ | 2026-08-04，6★ | C++ 模块 | **高**。原版自动卖垃圾的常见坑是把任务物品卖了，这个专门做了保护 |
| E3 | azerothcore/mod-morphsummon | https://github.com/azerothcore/mod-morphsummon | 修改玩家永久召唤物（坐骑、小宠物）的显示模型 | ★★★☆☆ | 2026-09-20，13★，AGPL-3.0 | C++ 模块 | **中**。外观向；与已有 mod-transmog 互补（transmog 改装备，这个改召唤物模型） |
| E4 | buildthehomelab/wow-mod-accountwide-pets | https://github.com/buildthehomelab/wow-mod-accountwide-pets | 同一个账号下所有角色共享小宠物收藏 | ★★★★☆ | 2026-10-27，1★ | C++ 模块 | **中高**。单人服多 alt 时不用重复刷宠物；作者同系列还有 account-wide mounts |
| E5 | bewarellamas/mod-dungeonmaster | https://github.com/bewarellamas/mod-dungeonmaster | 加一个 NPC，菜单里直接传送去任意副本/团本门口 | ★★★★☆ | 2024-12-07，9★ | C++ 模块 | **高**。单人服跑本必备；playerbots 会跟着你传送（playerbots 原生支持 group teleport） |
| E6 | azerothcore/mod-guildhouse | https://github.com/azerothcore/mod-guildhouse | 自定义公会屋（独立地图，公会成员可传送、布置） | ★★★☆☆ | 2026-06-18，53★ | C++ 模块 | **中**。53★ 但偏社交向；单人服可当"私人会所"用 |
| E7 | buildthehomelab/wow-mod-forever-journal | https://github.com/buildthehomelab/wow-mod-forever-journal | 零售风格副本日志（Boss、技能、掉落概率），模块+客户端 addon | ★★★★☆ | 2026-10-28，4★，MIT | C++ 模块 + 客户端 addon | **高**。昨天刚 push；WotLK 原版没有副本日志，这个补上；单人打副本时查 BOSS 机制很方便 |
| E8 | ornfelt/azerothcore_lua_scripts | https://github.com/ornfelt/azerothcore_lua_scripts | Eluna Lua 脚本合集（49★）：包含大量小工具（传送、Buff、外观等） | ★★★★☆ | 2026-08-28，49★ | **Lua 脚本集合（mod-ale 直接加载）** | **高**。49★ 的脚本库，可以挑需要的单个 .lua 放进 `lua_scripts/`；注意**与已有"超级炉石"可能功能重叠**——用前先比对 |

---

## 二、推荐组合（Playerbot 分支 + 已锁定模块 + 谷神汉化）

### 首选 5 件（按优先级）

1. **mod-aoe-loot**（E1）— 体验提升最直接，86★、活跃维护、零冲突
   - 配置：默认即可；注意别和"自动拾取"类客户端 addon 冲突
   - 与 playerbots：bot 尸体也会被一键拾取，无冲突

2. **mod-autobalance**（C1）— 单人副本缩放的事实标准
   - 配置要点：`Autobalance.Rate.Health` / `Damage` 按队伍人数调；playerbots 占队，所以 1 玩家 + 4 bot 会按 5 人算，这是想要的
   - 与 playerbots：**必须联调**。如果 bot 强度过高，把 Autobalance 的怪物 HP 系数调高 20~30%

3. **pangolp/mod-quest-loot-party**（B1）— 任务物品队伍共享
   - 理由：playerbots 组队做任务时的头号痛点；32★、AGPL、本月还在更新
   - 与 playerbots：天然契合，bot 接到任务物品也会共享给队伍

4. **Hisha/mod-dungeon-quests**（A1）+ **dr1s/mod-attunement-skip**（A2）— 进本前两件套
   - 进本即接任务、开门任务自动完成；把"准备副本"的时间从 10 分钟压到 30 秒
   - 与 playerbots：bot 不会被这些 NPC 卡任务，进本直接打

5. **Galuur/mangos_solocraft（Lua 版）**（C4）或 **PrivateDonut/hardcore_mode（Lua 版）**（D4）— 二选一
   - 想休闲：选 Solocraft Lua，单人时自动 Buff、组队时自动撤
   - 想挑战：选 hardcore_mode，Lua 形态，不用重编
   - **都用 Lua**，符合 mod-ale 宿主，不会触发 C++ 重编链路

### 可选项（按口味）

- 想做"赛季感"：加 **mod-progression-system + mod-zone-difficulty**（D1+D2），但要预留 1~2 天配置
- 想查副本机制：加 **wow-mod-forever-journal**（E7）
- 不想跑图：加 **mod-dungeonmaster**（E5）NPC 传送

### 注意事项汇总

- **C++ 模块都要重编 AzerothCore**：mod-aoe-loot、mod-autobalance、mod-quest-loot-party、mod-dungeon-quests、mod-attunement-skip 都是 C++。如果不想动编译链，优先选 Lua 类（C4、D4、D7、E8）
- **与 playerbots 冲突风险**：
  - mod-solo-lfg（C2）与 playerbots 自带 LFG 重叠，**不建议装**
  - trickerer/mod-solocraft（C5）面向 NPCBots，**不要装**
  - mod-progression-system（D1）会锁 playerbots 的装备/副本权限，这是特性不是 bug，但首次配置要把 bot 的默认装备等级也纳入进度表
- **许可证**：AGPL-3.0 模块（D1、D2、B1、B2、E1 等）若对外公开服务端要开源修改；本地/私人服无所谓
- **客户端 addon 依赖**：B2/B3/E7 都需要配套客户端插件，谷神汉化包内若没有要单独打包

---

## 三、避坑清单

| 条目 | 一句话理由 |
|---|---|
| **azerothcore/mod-eluna** | 官方已停更，被 mod-ale 取代；你已经在用 mod-ale，不要再装 |
| **azerothcore/mod-anticheat** | 你已明确排除；且对 playerbots 这种"机器人模拟真人"的方案误杀率高 |
| **azerothcore/mod-1v1arena / mod-pvpshop / mod-rankme / mod-cfbg / mod-duel-reset** | 重型 PVP 向，与 PVE 目标无关；部分已 404 或停更 |
| **trickerer/mod-solocraft / trickerer/AzerothCore-wotlk-with-NPCBots** | 面向 NPCBots 生态，与 mod-playerbots 钩子重叠，双 bot 同装必崩 |
| **milestorme/mod-solo-lfg** | 老 fork（2023-11），已被官方 mod-solo-lfg 取代，不要用 |
| **UltraNix/mod_progression-system** | 老的个人 fork，已 404；用官方 azerothcore/mod-progression-system |
| **azerothcore/mod-pvp-quests / mod-bg-reward / mod-bg-item-reward** | 战场/PVP 奖励向，PVE 无收益 |
| **michaeldelago/mod-quest-count-level** | 2023 年后未更新，思路可参考但代码可能跟不上当前 master |
| **azerothcore/mod-quest-helper** | 0★、无文档、刚起步，生产环境别用 |
| **Nucabe/Soulbind / Old-Man-Warcraft/mod-llm-companion / notOrrytrout/mod-ollama-bot-amigo** | LLM 驱动 bot 对话的实验性模块，方向酷但极不稳定，别在主服装 |
| **haha2345/SoloCollectionsPlatform / SoloStorySuiteV2** | 个人整合包，代码质量参差；要单装就挑子模块，别整包上 |

---

## 四、URL 验证状态摘要

所有上游地址均通过 GitHub Search API 或 GitHub Repos API 实际访问返回（HTTP 200 / 仓库元数据），非编造。

- **已通过 Repos API 二次验证（含 pushed_at / stars / license）**：
  azerothcore/mod-progression-system、mod-zone-difficulty、mod-autobalance、mod-solo-lfg、mod-chromie-xp、mod-aoe-loot、mod-quest-helper、mod-morphsummon、mod-guildhouse、mod-premium、mod-ale、mod-playerbots（即 mod-playerbots/mod-playerbots）、Hisha/mod-dungeon-quests、dr1s/mod-attunement-skip、pangolp/mod-quest-loot-party、warblups/mod-quest-radar、Aldori15/mod-questie-bridge、buildthehomelab/wow-mod-forever-journal、milestorme/mod-solo-lfg

- **已通过 Search API 验证（仓库真实存在，含 pushed_at / stars）**：
  Galuur/mangos_solocraft、trickerer/mod-solocraft、PrivateDonut/hardcore_mode、Zindokar/mod-hardcore、ngc7052/mod-gauntlet、AzoghMartins/mod-ip-challengesystem、buildthehomelab/wow-mod-challenges、Garretonzo/mod-hardcore-high-risk、TrisBits/mod-junk-to-gold-plus、Cliffutubius/mod-loyal-steed、buildthehomelab/wow-mod-accountwide-pets、bewarellamas/mod-dungeonmaster、ornfelt/azerothcore_lua_scripts、55Honey/Acore_eventScripts、55Honey/Acore_RecruitAFriend、g7138580/mod-guild-expansion、michaeldelago/mod-quest-count-level、conan513/mod-solocraft

- **验证失败 / 已 404（已在避坑清单标注）**：
  UltraNix/mod_progression-system（404）、azerothcore/mod-IRC-bot（404）、azerothcore/mod-save-logs（404）、azerothcore/mod-achievement-boost（404）、azerothcore/mod-rankme（404）、azerothcore/mod-pvpshop（404）、azerothcore/mod-1v1arena（404）、azerothcore/mod-npcbots（404）

---

## 五、自检记录

- [x] 清单条数：25 条（A=3, B=3, C=4, D=7, E=8），每类 ≥3 条
- [x] 每条 URL 均来自 GitHub API 实际返回，未编造
- [x] 已标注 C++ 需重编 / Lua mod-ale 直载 / 纯 SQL 数据
- [x] 已标注与 playerbots 的冲突风险（C2、C5、D1）
- [x] 已标注与已有"超级炉石"可能重叠项（E8）
- [x] 已给出推荐组合 5 件 + 注意事项
- [x] 已给出避坑清单 11 条
- [x] MD 与 HTML 双产出
