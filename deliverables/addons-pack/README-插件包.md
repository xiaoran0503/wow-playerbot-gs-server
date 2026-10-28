# WoW 3.3.5a 直接可用插件包（最终版）

解压即用：把本 zip 解压到 **魔兽世界客户端根目录**（与 `Wow.exe`、`Data` 同级），zip 第一层就是 `Interface\`，解压后合并到 `Interface\AddOns\`。
适用客户端：**3.3.5a（Interface 30300，build 12340）**。本包插件**默认全部启用**。

---

## 一、安装步骤

1. 关闭游戏 → 解压本 zip 到客户端根目录。
2. 进游戏，角色选择界面左下角「插件 / AddOns」，确认列表里插件均已勾选；如有「过期插件」勾选右上角即可（本包主 .toc 均为 30300，正常不报过期）。
3. 进游戏用 `/dbm`、`/wa`、`/questie` 等命令配置。

> 包内已附 23 个 `Blizzard_*` 原生 UI 目录（成就/拍卖/天赋/日历/战斗日志等），安装后与客户端同名目录对齐。说明：这些目录在本机仅含 `.pub` 调试符号文件、无可加载 .toc，属调试补全；真正的原生界面模块在客户端 MPQ 内，本包不改动客户端本体。

---

## 二、服务端模块 ↔ 客户端插件配对表

| 服务端模块 | 需要插件 | 本包 |
|---|---|---|
| mod-questie-bridge | Questie-335 | ✅ |
| mod-quest-radar | QuestRadar | ✅ |
| wow-mod-forever-journal | Journal | ✅ |
| playerbots 机器人聊天频道 | LFGForwarder | ✅ |
| mod-transmog / autobalance / ahbot | 无需客户端插件（纯服务端） | — |

---

## 三、插件清单（默认全部启用）

### A. 服务端配套（2）
QuestRadar（任务雷达）、Journal（副本/任务/典籍总览 Shift-J）

### B. 推荐核心组（17）
Questie-335（任务助手）、DBM 全家（Core/GUI/计时条 + 全副本模块 + **VV 普通话语音包** + 整合 GUI）、Details!（伤害统计）、Omen（仇恨）、Atlas/AtlasLoot/AtlasQuest 全家（地图+掉落+任务查询，含 AtlasLootFu）、WeakAuras 全家（WeakAuras/Options/ModelPaths/Archive）、LFGForwarder（机器人频道转发）、MapTeleport（地图传送）、Postal（邮箱）、Auctionator（拍卖，配合 ahbot）、MBB（小地图按钮收起）、ImprovedLootFrame（掉落窗）、SimpleRaidTargetIcons（团队标记）、Decursive（一键驱散）、BlizzMove（移动框体）、_NPCScan（稀有扫描）

### C. 用户点名可选组（默认启用，可按需在插件列表关）（13）
Pawn（装备评分）、Mendeleev（物品出处）、YssBossLoot（Boss 掉落）、ExplorerCoords（坐标记录）、ZygorTalentAdvisor（天赋推荐=Talented）、Focuser（焦点）、GearScoreLite（装备评分）、MySlot（配置存档）、NiceDamage（伤害反馈）、Parrot（浮动战斗文字）、SpellReplay（施法回放）、TradeTabs（交易标签）、Duowan 全家（Duowan 基础库 + LearningAid/NPCMark/RatingSummary/TheBurningTrade/RangeDisplay）

### D. 保留默认启用（1）
Immersion（任务剧情对话增强；如需简洁任务日志可在插件列表关闭）

---

## 四、特别标注

- **MapTeleport（地图传送）**：需要 **GM 账号权限**，且**不支持副本传送**（仅主城/大陆定点，Alt+左键传送）。普通玩家/正式游玩时建议在插件列表手动禁用。
- **ElvUI 全家**：本版按用户要求**整体排除、不打包**（用户明确不启用）。如需使用，请自行从 `E:\缓存\WOW\AddOns` 复制 ElvUI 及 ElvUI_* 目录。
- **中文**：DBM 含 VV 普通话语音包；Duowan 全家、Questie 等内置 zhCN，客户端语言设为中文即自动中文。
- **库依赖**：Ace3/LibStub/Astrolabe 等均内嵌，无需另装。

---

## 五、许可证
本包仅打包开源/公开分发插件，版权归原作者，遵循各自许可证（LGPLv2.1/GPLv2/BSD 等）。来源与上游核查见同目录 **`插件来源清单.md`**。
