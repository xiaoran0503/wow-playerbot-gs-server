# custom/lua_scripts — 本服 Eluna Lua 脚本目录

本目录为 mod-ale（Eluna Lua Engine）运行期脚本目录，由 `mod_ale.conf.dist` 中
`ALE.ScriptPath = lua_scripts` 指向。文件一律 **UTF-8 无 BOM**，字节原样来自
谷神整合服（GS_Server）资产，未做转码。

## 文件清单与用途

| 文件 | 大小 | 用途 |
|---|---:|---|
| `SupMalachite.lua` | 93204 B | 「超级炉石/传送石」主脚本。绑定物品 entry **6948**，注册 `RegisterItemGossipEvent(1=Show, 2=Select)`。Gossip 菜单含：副本传送（Instances 表约 70 组 {地图ID,难度}）、随身 NPC 召唤（商业技能训练师 28700~28742、职业雕文商、经验锁定 35364/35365、幻化大师 90003、自定义 190001 等）、附魔、设家、GM 专用。全文中文对话文本与硬编码 entry。 |
| `RecruitAFriend.lua` | — | 「战友招募」脚本（上游 Acore_RecruitAFriend，commit d72b8057）。玩家命令 `.raf list/summon/unbind/help`、招募链接广播、奖励邮件（主题/正文）已汉化简体中文；GM 命令 `.bindraf/.forcebindraf/.raf lookup` 保留英文原文（运营端工具）。落位本目录后由 mod-ale 自动加载。 |
| `掉落物品随机附魔.lua` | 3674 B | 掉落随机附魔。`RegisterPlayerEvent(32, OnLoot)`；按稀有度概率从 `item_enchantment_random_tiers` 表随机 roll 1~4 个附魔槽，对 WEAPON(类2)/ARMOR(类4) 调 `item:SetEnchantment`。 |
| `extensions/_Misc.ext` | 493 B | Eluna `.ext` 预加载：`math.randomseed`；`require("StackTracePlus")` 并把 `debug.traceback` 替换为增强堆栈。 |
| `extensions/ObjectVariables.ext` | 3179 B | Eluna `.ext` 预加载：为 Map/Player/Creature/GameObject 注入 `SetData/GetData` 运行期会话数据存储，登出/对象删除/地图销毁时自动清数据。 |
| `extensions/StackTracePlus/StackTracePlus.ext` | 12081 B | StackTracePlus 增强堆栈跟踪库本体（`.ext` 形式供 Eluna 预加载）。 |
| `extensions/StackTracePlus/LICENSE` | 1077 B | MIT 许可证原文（© 2010 Ignacio Burgueño；其中 "Burgueño" 的 ñ 为 Latin-1 单字节，保留原样）。 |
| `extensions/StackTracePlus/README.md` | 4209 B | StackTracePlus 使用文档。 |

## 来源与许可归属

- **SupMalachite.lua / 掉落物品随机附魔.lua**：谷神整合版/社区散件，收集于网络，
  无独立上游仓库，随 GS_Server 资产带入，本仓库自行维护。原始压缩包与中文须知
  （`LUA说明.txt`）归档于 `docs/gushen-reference/`。注意谷神自带说明：脚本收集于
  网络、大多未测试；无效/报错/致服崩的脚本应删除；不会改则建议禁用 Lua。
- **extensions/_Misc.ext / ObjectVariables.ext**：属 Eluna Lua Engine 生态扩展，
  GPLv3，与本仓库 mod-ale 模块同许可体系。
- **extensions/StackTracePlus/**：StackTracePlus © 2010 Ignacio Burgueño，
  MIT License，上游 https://github.com/ignacio/StackTracePlus 。

完整归属见仓库根目录 `NOTICE`。

## 启用前提

- 需启用 mod-ale（`ALE.Enabled = true`，见 `custom/conf-seed/etc/modules/mod_ale.conf`）。
- SupMalachite.lua 依赖物品 entry 6948 在世界数据库中存在；`掉落物品随机附魔.lua`
  依赖 `item_enchantment_random_tiers` 表（由 mod-random-enchants 提供）。
- 两个脚本目前为原样收录，尚未按本服数据做 entry 校准；如报怪先看 worldserver
  日志中 Eluna 段，必要时按 `LUA说明.txt` 原则删除对应脚本。
