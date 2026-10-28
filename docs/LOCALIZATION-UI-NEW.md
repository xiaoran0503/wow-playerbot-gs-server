# wave2 新增模块 玩家可见字符串汉化清单（LOCALIZATION-UI-NEW）

覆盖范围：wave2 新增 14 个模块 + 谷神既有 Lua 抽查。汉化风格沿用本服既有规范：简体中文、UTF-8 无 BOM、与 `custom/lua_scripts`、`sql/localization` 一致。
配套产物：`custom/locale-patches/*.patch`（C++ 源码补丁，git apply 重打）、`sql/localization/05_import_wave2_ui_chinese.sql`（数据面 UPDATE，只写不执行，待模块 SQL 导入完成后统一重放）。
排除模块（另一代理负责，不在本清单）：mod-playerbots / mod-ale / mod-ah-bot / mod-transmog / mod-random-enchants / mod-boss-announcer。

## 逐模块审计与处理结果

| # | 模块 | 玩家可见字符串位置 | 现状 | 汉化方式 | 状态 |
|---|---|---|---|---|---|
| 1 | Acore_RecruitAFriend | Lua（Config.mailText、招募广播、奖励邮件、.raf 玩家命令输出） | 英文 | 脚本汉化后落位 `custom/lua_scripts/RecruitAFriend.lua`；GM 命令保留英文 | 完成 |
| 2 | mod-dungeon-quests | SQL（creature_template 14999991 name/subname）+ 源码 gossip 标签 | 英文 | SQL 两份副本已汉化（含存储过程 BINARY 碰撞检查行同步）；源码 gossip 标签汉化（patch） | 完成；SQL 待 DB 重放 |
| 3 | mod-attunement-skip | C++ `AttunementSkipPlayer.cpp` 邮件主题/正文 | 英文 | 源码汉化 + `custom/locale-patches/mod-attunement-skip.patch`（上游 c2ee51ff） | 完成 |
| 4 | mod-dungeonmaster | SQL（creature_template 197762、npc_text 197760）+ 源码 ~90 条副本菜单标签 | 英文 | SQL 两份副本已汉化（用 zhCN 官方副本名）；源码汉化 + patch（上游 07638d58） | 完成；SQL 待 DB 重放 |
| 5 | mod-junk-to-gold-plus | C++ 7 条 SOLD_FOR_* 出售聊天模板 | 英文 | 源码汉化 + patch（上游 8409491a）；物品链接格式串不动 | 完成 |
| 6 | wow-mod-accountwide-pets | 通读全 src：仅 1 行 LOG_INFO 服务器日志，无聊天/教学消息 | 无玩家可见字符串 | 跳过，无需 patch | 完成（审计确认） |
| 7 | wow-mod-forever-journal | 源码（.journal 命令输出、城镇向导 gossip 菜单 19 分类/职业名/专业等级名/翻页搜索标签）+ SQL（npc_text 9500500-502、spell_dbc 90050 法术名） | 英文 | 源码汉化 + patch（上游 856ae954）；SQL 两份副本已汉化；**398 条 lore 正文（15 个 zone JSON）内容量大，建议后续增量** | 完成（lore 正文延后） |
| 8 | mod-solocraft | C++ 登录广播 + 6 条进本公告（难度补偿/法伤加成/职业平衡权重/经验平衡等） | 英文 | 源码汉化 + patch（上游 59588838） | 完成 |
| 9 | mod-quest-radar | C++ .qr 命令输出 3 条 | 英文 | 源码汉化 + patch（上游 f7ce763e）；客户端插件协议 token 保留；客户端 addon 汉化标注可选（未做） | 完成 |
| 10 | mod-questie-bridge | 无（grep 全 src 无 SendSysMessage 类调用）；数据面为 quest 表任务名（官方英文数据） | 无服务端玩家可见字符串 | 跳过；任务标题汉化方案见下节 | 完成（评估后跳过） |
| 11a | mod-autobalance | C++ `ABPlayerScript.cpp:15` 登录公告（硬编码英文）；其余文本经 ABGetLocaleText 语言表 | 公告英文；语言表已内置 zhCN | 仅硬编码公告汉化 + patch（上游 1d707cb6） | 完成（审计发现与任务预设"无"不符，如实记录） |
| 11b | mod-aoe-loot | SQL module_string（8 条） | 已内置 zhCN/zhTW | 确认即可，无需改 | 完成（确认） |
| 11c | mod-quest-loot-party | SQL module_string（1 条） | 已内置 zhCN/zhTW | 确认即可，无需改 | 完成（确认） |
| 12 | 谷神既有 Lua（SupMalachite.lua / 掉落物品随机附魔.lua / 遗产职业强化.lua / extensions） | Lua SendBroadcastMessage 等 | 已中文 | 抽查确认，无需处理；记录在案 | 完成（抽查） |

## wow-mod-forever-journal lore 正文清单（延后增量）

- 数据位置：`modules/wow-mod-forever-journal/data/lore/*.json`（15 个区域文件），由 `tools/build_lore_sql.py` 生成 `sql/modules/wow-mod-forever-journal/world/mod_forever_journal_lore_*.sql`（两份副本同步）。
- 条目总量：**398 条**（azuremyst 27 / bloodmyst 29 / darkshore 30 / dun_morogh 26 / durotar 22 / elwynn 26 / eversong 28 / ghostlands 34 / loch_modan 24 / mulgore 23 / silverpine 24 / teldrassil 24 / the_barrens 31 / tirisfal 26 / westfall 24）。
- 每条含 title + 2~3 段 lore 正文；正文为 WotLK 前置区域背景叙述，玩家通过客户端 Journal 插件阅读。
- 已汉化：主菜单/搜索/分类/职业/专业等级等展示文本、.journal 命令输出、npc_text 种子、spell_dbc 法术名"城镇向导"。
- **未汉化：398 条 lore title+body，内容量大，建议后续按区域分批增量汉化（改 JSON 后重跑 build_lore_sql.py 再同步两份副本）。**
- FLAG_TAGS（搜索关键词）保留英文：玩家搜索命中的是 creature_template.name（官方英文数据），保留英文与上游检索逻辑一致。

## mod-questie-bridge 任务标题汉化方案（评估，不做全量）

- 审计结论：模块本身是服务端→客户端 Questie 插件的数据桥，无任何玩家可见服务端输出；玩家看到的任务标题来自 DB quest 表（TrinityCore 官方英文数据）。
- 方案 A（客户端插件路线，推荐）：Questie-335 上游已有简体中文翻译资源，随客户端插件包分发即可显示中文任务标题；服务端零改动，不影响机器人/任务引擎。
- 方案 B（DB 翻译表路线）：对 quest 表 title/offerRewardText/RequestItemsText 做 zhCN 覆盖（world DB 加 quest_locale 或等价 UPDATE）。工作量数千条且需对照 zhCN 客户端字幕库（zhCN.MPQ 提取），全量翻译 + 校验成本高，本次不做。
- 建议：先走方案 A；若后续需要 DB 层中文，再立项做 quest 文本翻译工具链（参考 03_update_texts_chinese.sql 的 UPDATE 模式分批灌库）。

## 产物清单

1. `custom/locale-patches/`（8 个 patch，均已通过 `git apply --check -R` 反向校验）：
   - mod-attunement-skip.patch（上游 c2ee51ffda86acaec8ab6bc749f1c6a8ff02281f）
   - mod-dungeonmaster.patch（上游 07638d584a52e916deaf99d36ce4a40799a1065d）
   - mod-junk-to-gold-plus.patch（上游 8409491a5ea8590dc52c76ca0851d4fb2e19975a）
   - mod-solocraft.patch（上游 59588838988d1b74111d26670d99d0e649014b93）
   - mod-quest-radar.patch（上游 f7ce763e48d1c7db1afcd3611f13cd729c9c1b88）
   - wow-mod-forever-journal.patch（上游 856ae9548760954d81d1f36d7e7c41b221b68e15）
   - mod-dungeon-quests.patch（上游 fe6456f89354f1ca8169093b6592f74951087400）
   - mod-autobalance.patch（上游 1d707cb61a0962ab01e4123681e2d3b66cc558a2）
   - 无 patch：wow-mod-accountwide-pets（无改动）、mod-questie-bridge（无改动）、mod-aoe-loot / mod-quest-loot-party（自带 zhCN）
2. `sql/localization/05_import_wave2_ui_chinese.sql`：数据面 UPDATE（creature_template 14999991/197762 名称、npc_text 197760/9500500-502、spell_dbc 90050 法术名）；**只写不执行，待 DB 统一重放**。
3. `custom/lua_scripts/RecruitAFriend.lua`：落位完成（mod-ale `ALE.ScriptPath = lua_scripts` 自动加载）；README 已增补条目。
4. 仓库 SQL 种子两份副本（modules/<mod>/data/sql 与 sql/modules/<mod>）均已同步汉化。

## 待 DB 统一重放的数据面文件（主代理协调）

- `sql/localization/05_import_wave2_ui_chinese.sql`（本代理产出）
- `sql/modules/mod-dungeon-quests/db-world/base/mod_dungeon_quest_guide.sql`（NPC 中文名种子；若导入时已是中文则与 05 互为双保险）
- `sql/modules/mod-dungeonmaster/world/dungeon_npc.sql`、`dungeonmaster_text.sql`
- `sql/modules/wow-mod-forever-journal/world/mod_forever_journal_2026_10_15_00.sql`（npc_text + spell_dbc 法术名）
