# 配置汉化说明（任务 7）

对 `custom/conf-seed/etc/authserver.conf` 与 `custom/conf-seed/etc/worldserver.conf` 的**全部选项**追加/替换中文注释。
**只改注释行，绝不改任何键值**；键值集合与改动前完全一致（已 diff 校验：改动前后仅注释行差异）。

## 输出文件

| 文件 | 字节数 | 行数 | 总选项数 | 谷神沿用 | 自行补译 |
|---|---|---|---|---|---|
| `custom/conf-seed/etc/authserver.conf` | 16107 | 416 | 36 | 0 | 34 块 |
| `custom/conf-seed/etc/worldserver.conf` | 169028 | 4808 | 591 | 414 块 | 53 块 |

> 注：选项按"键值行"计数。多个连续键共享同一注释块时（如 `LoginDatabaseInfo / WorldDatabaseInfo / CharacterDatabaseInfo`），注释块归首个键所有，后续键为"连续键"。
> worldserver 467 个独立注释块覆盖 591 个键；其中 Playerbots 相关键仅 `Appender.Playerbots` 1 个（playerbots 模块本体的键在 `custom/conf-seed/etc/modules/` 下，未改动）。

## 翻译来源与标注规则

1. **谷神沿用**：与 `docs/gushen-reference/worldserver.conf` 同名键对照，谷神端已译为中文的，直接沿用谷神译文（`说明：/重要提示：/示例：/默认值：/范围：/注意：`）。不标注。
2. **自行补译**：谷神没有的新键（`Updates.*`、`Trial.*`、`Cluster.*`、`Playerbots` 日志、`Metric.InfluxDB.*`、`Wintergrasp.*`、`Battleground.Override.*`、`ChatFilter.*`、`Respawn.*`、`Debug.LFG`、`InfiniteAmmo.*`、`CAIS.*`、`LFG.*`、`DungeonFinder.*`、`Mail.*`、`Achievement.*`、`PlayerSave.*`、`ValidateSkillLearnedBySpells`、`TaxiFlightSpeed`、`LogSpamReports`、`ChatLog.Enable`、`Network.UseSocketActivation`、`Updates.ExceptionShutdownDelay` 等），按上游英文语义自行补译，行内标注 **（自行补译）**。
3. **authserver.conf**：谷神端 `authserver.conf` 无任何中文（纯英文默认版），故全部 36 个选项均为自行补译。

## 补译样例

- `Trial.Restriction.Queue`：说明——强制试玩账号排队进入世界会话，即使其账号标志本应赋予免排队特权。RBAC_PERM_SKIP_QUEUE 权限和断线宽限时间仍然生效。
- `Cluster.Enabled`：说明——启用/禁用集群模式。安全：集群模式下 ToCloud9 网关是可信的认证边界；worldserver 会跳过会话密钥摘要校验、数据包加密、Warden、IP/国家锁定、封禁与最低安全等级校验及登录角色归属检查，端口必须只允许网关访问。
- `ChatFilter.Whisper / Say / Yell / Emote`：屏蔽包含 `chat_filter` 表任意词条的聊天消息（子串匹配，忽略大小写）；官方正版仅启用悄悄话过滤。
- `Updates.ExceptionShutdownDelay`：发生致命异常（例如 SQL 更新失败）后等待多少毫秒再关服；10000=10 秒，0=立即关服。
- `Metric.InfluxDB.Connection`：InfluxDB 连接设置；v1 只填 Connection，v2 需填 v2/Org/Bucket/Token。

## 保留英文的场景

以下内容保留英文，属于合理保留：

1. **文件头部 EXAMPLE CONFIG 模板**（authserver 第 22–25 行）：`Description: Brief description what the variable is doing.` 等——这是配置格式示例文档，不是实际选项。
2. **谷神端自身未翻译的行**：worldserver 中 `Metric.OverallStatusInterval` 块的 `Description: Skips sending statistics...` 等 1–2 行，谷神端原文即为英文，沿用未改。
3. **谷神模块区段**：`WipeGunshipBlizzlike.*`、`Minigob.Manabonk.*`、`Calculate.*.*`、`DailyRBGArenaPoints.*`、`MunchingBlizzlike.*`、`Daze.Enabled`、`Debug.Battleground`、`Respawn.Dynamic*` 等自定义模块键——谷神端译文保留英文标签（`Description:/Default:`）+ 中文正文，本次原样沿用谷神格式。
4. **区段横幅**：`# MYSQL SETTINGS`、`# CUSTOM`、`# CLUSTER SETTINGS`、`# LOGGING SYSTEM SETTINGS` 等节标题横幅保持英文。

## 验证结果

- **键值一致性**：改动前后所有非注释行（键值行 + `[section]`）逐行比对完全一致；worldserver 592 行、authserver 37 行 non-comment 行 identical。
- **UTF-8 无 BOM**：两个文件头 3 字节均非 `EF BB BF`；严格 UTF-8 解码通过。
- **换行风格**：保持原文件 CRLF（`\r\n`），与原文件一致。
- **未触碰**：`custom/conf-seed/etc/modules/` 下任何模块 conf、`GS_Server/configs/` 原件、`conf/*.dist` 上游基线。
- **未 git add/commit**。
