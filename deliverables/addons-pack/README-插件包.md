# WoW 3.3.5a 直接可用插件包

解压即用：把本 zip 解压到 **魔兽世界客户端根目录**（即和 `Wow.exe`、`Data` 同级的目录），zip 内第一层就是 `Interface\`，解压后直接合并到 `Interface\AddOns\`。

适用客户端：**魔兽世界 3.3.5a（客户端 Interface 版本 30300，build 12340，巫妖王之怒客户端）**。

---

## 一、安装步骤

1. 关闭游戏。
2. 解压本 zip 到客户端根目录（与 `Wow.exe` 同级）。
   - 解压后结构：`<客户端根目录>\Interface\AddOns\<插件文件夹>\...`
   - 若 `Interface\AddOns` 里已有同名插件，合并/覆盖即可。
3. 启动游戏，角色选择界面左下角点 **「插件 / AddOns」**。
4. 勾选右上角 **「过期插件 / Load out of date AddOns」**（本包所有插件主 .toc 的 Interface 均为 30300，正常不应报过期）。
5. 进游戏输入 `/eline`（ElvUI）、`/dbm`、`/wa` 等命令配置。

> 本包纯 `Interface\AddOns` 客户端插件，不含反破解/修改客户端内容。

---

## 二、服务端模块 ↔ 客户端插件配对表

| 服务端模块 | 需要的客户端插件 | 本包是否附带 | 来源 |
|---|---|---|---|
| `mod-questie-bridge`（任务桥接） | **Questie-335** | ✅ 已附 | 本地 AddOns 复用 |
| `mod-quest-radar`（任务雷达） | **QuestRadar** | ✅ 已附（内嵌 Astrolabe） | 服务端模块源码 |
| `wow-mod-forever-journal`（副本/手册） | **Journal** | ✅ 已附 | 服务端模块源码 |
| **playerbots 机器人聊天频道** | **LFGForwarder** | ✅ 已附 | 本地 AddOns 复用 |
| `mod-transmog`（幻化） | 无客户端插件 | — | 核查 `modules\mod-transmog\` 不带客户端目录，纯服务端 |
| `mod-autobalance`（动态平衡） | 无需插件 | — | 纯服务端模块 |
| `mod-ah-bot`（拍卖行机器人） | 无需插件（可用 Auctionator 浏览） | — | 纯服务端模块 |

---

## 三、插件清单（本包收录，共 28 个逻辑插件 / 95 个文件夹）

### A. 服务端配套插件（来自服务端模块源码）
| 插件 | 版本 | 用途 |
|---|---|---|
| QuestRadar | 0.9.0 | 小地图任务目标雷达 |
| Journal | 2.5.5 | 副本/任务/商人/典籍总览（Shift-J） |

### B1. 本机 AddOns 目录复用（来源 `E:\缓存\WOW\AddOns`）
| 插件套件 | 版本 | 用途 |
|---|---|---|
| Questie-335 | 9.5.1 | 任务助手（配 questie-bridge） |
| DBM 全家（Core/GUI/计时条 + 全副本模块 + DBM-VPVV 普通话语音包 + 秋落整合 GUI） | Core 9.2.25 / VPVV 3.3.5 | Boss 技能计时与警报 |
| Details! | 335 版 | 伤害/治疗统计（替代 Recount） |
| Omen | 3.0.9 | 仇恨/威胁计量 |
| WeakAuras 全家（WeakAuras/Options/ModelPaths/Archive） | 4.0.0 | 触发/计时/护盾自定义监视 |
| Atlas 全家（Atlas + 副本位/野外团 + AtlasLoot + 5 数据模块 + AtlasLootFu + AtlasQuest） | Atlas 1.17.0 / AtlasLoot 5.11.04 / AtlasQuest 4.4.3 | 地图/掉落/任务查询浏览器 |
| Auctionator | 2.6.3 | 拍卖行增强（配合 ahbot） |
| Postal | 3.3.2 | 邮箱增强（替代 PostalEnhanced） |
| Pawn | 1.3.11 | 装备价值评分 |
| ZygorTalentAdvisor | 2.0.240 | 天赋推荐（=Talented） |
| BlizzMove | v0.7 | 移动原生框体 |
| ElvUI 全家（ElvUI 核心 + 14 个附加/美化模块） | ElvUI 6.08 | 整体界面替换（替代 SUF+Bartender4） |
| LFGForwarder | 0.1 | 自动组队/机器人频道转发 |
| Decursive | 2.5.1 | 一键驱散 |
| _NPCScan | 3.3.5.5 | 稀有怪物扫描报警 |
| Immersion | 1.4.14 | 剧情/任务对话增强 |
| ImprovedLootFrame | 3.7.7 | 掉落窗口增强 |
| MBB | — | 小地图按钮收起 |
| Mendeleev | 3.0 | 物品出处提示 |
| YssBossLoot | v1.0.4 | Boss 掉落一览 |
| SimpleRaidTargetIcons | 1.08 | 团队标记增强 |
| Duowan 全家（Duowan 核心 + LearningAid/NPCMark/RatingSummary/TheBurningTrade/RangeDisplay） | — | 多玩基础库与任务/商人/交易/距离提示 |

### B2. 已下载保留的社区插件（GitHub 开源，锁版本）
| 插件套件 | 版本 | 用途 |
|---|---|---|
| TomTom | 1.3.0 | 导航箭头/坐标路点 |
| OmniCC（+Config） | 3.0 | 冷却数字 |
| TidyPlates 全家（+ThreatPlates 等 5 样式） | 6.5.0 / ThreatPlates 5.7 | 姓名板 |
| GatherMate2（+Data） | 1.0.8 / 1.4.0 | 采集点记录 |

---

## 四、注意事项

- **中文**：DBM 含 VV 普通话语音包；多玩（Duowan）全家、Questie、Recount 类插件内置 zhCN 本地化，客户端语言设为中文即自动中文。
- **库依赖**：Ace3、LibStub、LibSharedMedia、Astrolabe 等均内嵌在各插件目录，无需单独安装。
- **Questie flavor**：本地 Questie-335 文件夹名即对应 `Questie-335.toc`（Interface 30300），已删除 TBC/Classic/正式服 flavor 的多余 .toc，确保 3.3.5a 客户端只加载正确版本。
- **ElvUI**：为整套界面替换，与其他单位框体/动作条插件互斥；本包已按要求不装 SUF/Bartender4。
- **MapTeleport（地图传送）**：已随包携带，但**需要 GM 账号权限**，且**不支持副本传送**（仅主城/大陆定点）。普通玩家/正式游玩时可在角色选择-插件列表里手动禁用它。

---

## 五、许可证声明

本包仅打包开源/公开分发插件，版权归原作者，遵循各自许可证（LGPLv2.1/GPLv2/BSD 等，以插件目录 LICENSE 或原仓库为准）。
- A 类随服务端仓库分发，见仓库 LICENSE/NOTICE。
- B1 本机复用项版权归各插件原作者；B2 下载项来源 URL 见 **`插件来源清单.md`**。
- 本包仅做版本选择、.toc 校验、目录整理与说明，不做二次修改/破解。
