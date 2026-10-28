# 现有部分玩家可见字符串中文化清单（任务5）

- 上游 commit: `b31a373e94132f9d362b77e3550d6a0a4defb3c7`
- 范围：6 个既有模块 + 谷神既有 Lua（不含 wave2 新增 14 模块）
- 风格：谷神简体中文（与 `custom/lua_scripts/` 既有中文文案一致）
- 产出：源码 patch（`custom/locale-patches/*.patch`，可 `git apply` 重打）；无 DB 文案改动

---

## 1. mod-boss-announcer（首领公告）

| 项 | 内容 |
|---|---|
| 字符串位置 | `modules/mod-boss-announcer/src/mod_boss_announcer.cpp` |
| 数量级 | ~15 处（团灭公告、击杀公告、登录提示、难度/公会名回退） |
| 样本（改前） | `"... wiped on [boss] (Attempt #N) after Xm Ys."`、`"... has slain [boss] ... Alive: x/y on Heroic [Tank:.. Heal:.. DPS:..]"` |
| 样本（改后） | `"... 的公会 ... 在 [boss] 团灭了，(第 N 次尝试) 历时 X 分 Y 秒。"`、`"... 击杀了 [boss] ... 存活：x/y，难度：英雄/普通 [坦克:.. 治疗:.. 输出:..]"` |
| conf 默认文案 | `custom/conf-seed/etc/modules/mod_boss_announcer.conf` 仅开关，无文案 |
| 处理方式 | 源码中文化 |
| patch | `custom/locale-patches/mod-boss-announcer.patch` |

## 2. mod-transmog（幻化）

| 项 | 内容 |
|---|---|
| 主体菜单文案 | 走 `module_string` / `module_string_locale` 表（ID 1-88），上游 SQL `2026_05_09_migrate_to_module_string.sql` **已带 zhCN** |
| NPC 对话文本 | `npc_text` 601083/601084，上游 SQL `2016_11_17_transmog_texts.sql` **已带 zhCN** |
| 源码硬编码位置 | `modules/mod-transmog/src/cs_transmog.cpp`（GM/玩家反馈，绕过 module_string 的 ~12 处） |
| 样本（改前） | `"has been added to your appearance collection."`、`"The portable transmogrification NPC is disabled."`、`"Transmog configs reloaded."` |
| 样本（改后） | `"已添加到你的外观收藏。"`、`"便携幻化 NPC 已被禁用。"`、`"幻化配置已重新加载。"` |
| DB 表玩家可见文本 | `custom_transmogrification_sets.SetName` 为玩家自定义套装名，非硬编码；`command.help` 为 GM 帮助（SEC_GAMEMASTER），不在玩家可见范围 |
| 处理方式 | 源码硬编码中文化；DB 文案上游已汉化，无 06 脚本改动 |
| patch | `custom/locale-patches/mod-transmog.patch` |

## 3. mod-random-enchants（随机附魔）

| 项 | 内容 |
|---|---|
| 字符串位置 | `modules/mod-random-enchants/src/random_enchants.cpp`（3 条获得提示 + 1 条登录提示默认值） |
| 数量级 | 4 处 |
| 样本（改前） | `"Newly Acquired [item] has received 3 random enchantments!"` |
| 样本（改后） | `"新获得的 [item] 被附加了 3 条随机附魔！"` |
| conf 默认文案 | `custom/conf-seed/etc/modules/random_enchants.conf` 的 `RandomEnchants.OnLoginMessage` 同步改为中文 |
| 处理方式 | 源码 + conf-seed 中文化 |
| patch | `custom/locale-patches/mod-random-enchants.patch` |

## 4. mod-ah-bot（拍卖行机器人）

| 项 | 内容 |
|---|---|
| 字符串位置 | `modules/mod-ah-bot/src/cs_ah_bot.cpp`（`.ahbotoptions` GM 命令，SEC_GAMEMASTER） |
| 数量级 | ~40 处帮助/语法/错误提示 |
| 样本（改前） | `"Syntax is: ahbotoptions buyer $state (0 off 1 on)"`、`"AHBot commands:"`、`"Invalid syntax"`、`"Done"` |
| 样本（改后） | `"用法：ahbotoptions buyer $state（0 关 1 开）"`、`"拍卖行机器人命令："`、`"语法错误"`、`"完成"` |
| 玩家可见性 | 机器人后台挂单/购买逻辑无玩家可见文案；拍卖邮件文案由核心提供；仅 GM 命令反馈 |
| 处理方式 | 源码中文化（GM 命令帮助一并汉化，便于本服管理员） |
| patch | `custom/locale-patches/mod-ah-bot.patch` |

## 5. mod-playerbots（玩家机器人，最大模块）

### 取舍说明
- **bot 闲聊文本主力**：`acore_playerbots.ai_playerbot_texts` 数据库表已汉化 **2268 条**（任务其它环节负责）。
- **源码中 `GetBotTextOrDefault("key", "English fallback", ...)` 的英文回退串**：仅在 DB 缺译文时兜底显示；DB 层已覆盖，源码英文回退串**不逐一汉化**（避免与 DB 译文双份维护、漂移）。
- **本 patch 只处理非 DB 来源、高频/公告/命令反馈类硬编码字符串**：

| 字符串位置 | 内容 |
|---|---|
| `src/Script/Playerbots.cpp` | 登录公告（mod-playerbots 开源归属提示按 GPL 要求保留 URL，包装文案中文化）、`"The server is configured with X bots."` |
| `src/Script/PlayerbotCommandScript.cpp` | `.playerbots account setKey/link/unlink` 用法与反馈（SEC_PLAYER） |
| `src/Bot/PlayerbotMgr.cpp` | 系统禁用提示、`.bot` 命令用法/错误、`initself`/`reload`/`tweak`/`self`/`addclass` 反馈、账号关联/查看/解除反馈（SEC_PLAYER） |
| `src/Ai/Base/Actions/BattleGroundTactics.cpp` | BG 调试命令入口提示（SEC_GAMEMASTER） |

样本（改前→后）：
- `"Playerbot system is currently disabled!"` → `"机器人系统当前已禁用！"`
- `"Usage: .playerbots account setKey <securityKey>"` → `"用法：.playerbots account setKey <安全密钥>"`
- `"SelfBot is now active."` → `"自身机器人已启用。"`
- `"ERROR: Only GM can use this command."` → `"错误：只有管理员才能使用此命令。"`

- patch：`custom/locale-patches/mod-playerbots.patch`

## 6. mod-ale（Eluna 兼容层）

| 项 | 内容 |
|---|---|
| 字符串位置 | `src/LuaEngine/LuaEngine.cpp` 唯一一处 `"Reloading ALE..."`（`ALE.PlayerAnnounceReload` 默认 false，开启后全服公告；GM 文本同步） |
| 其余 | API 层，玩家可见输出不存在 |
| 处理方式 | 该条中文化；其余记录"无" |
| patch | `custom/locale-patches/mod-ale.patch` |

## 7. 谷神既有 Lua（custom/lua_scripts/）

| 文件 | 结论 |
|---|---|
| `SupMalachite.lua` | **已中文**（召唤/传送/专业/附魔等 80+ 条 SendBroadcastMessage/SendAreaTriggerMessage 均为简体中文），不动文件 |
| `掉落物品随机附魔.lua` | 无 Send* 玩家可见调用（被动附魔脚本），记录"无玩家可见文本" |
| `extensions/*` | 扩展脚本，无新增英文玩家可见文案（沿用既有中文） |
| `遗产职业强化.lua` | **已中文**（`【遗产强化】出生被动强化`），不动文件 |

> 注：`RecruitAFriend.lua` 不在本任务点名清单内（其玩家可见串多为中文，GM 帮助串英文），未触碰。

---

## 产物索引

| 产物 | 路径 |
|---|---|
| patch ×6 | `custom/locale-patches/{mod-boss-announcer,mod-random-enchants,mod-transmog,mod-ah-bot,mod-playerbots,mod-ale}.patch` |
| DB 文案脚本 | `sql/localization/06_import_existing_ui_chinese.sql`（**无数据面改动**，仅留档说明） |
| 本清单 | `docs/LOCALIZATION-UI-EXISTING.md` |

## 重打方法
在仓库根 `E:\缓存\WOW\wow-playerbot-server`：
```
git apply custom/locale-patches/mod-boss-announcer.patch
git apply custom/locale-patches/mod-random-enchants.patch
git apply custom/locale-patches/mod-transmog.patch
git apply custom/locale-patches/mod-ah-bot.patch
git apply custom/locale-patches/mod-playerbots.patch
git apply custom/locale-patches/mod-ale.patch
```
（已用 `git apply --check -R` 反向校验全部可干净应用。）
