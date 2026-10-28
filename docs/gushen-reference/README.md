# docs/gushen-reference — 谷神整合服参考文档

> 只读参考资料区。**这些文件不参与运行**，仅供配置迁移、汉化对照与历史回溯。
> 运行时配置种子在 `custom/conf-seed/etc/`。

## 来源

全部来自谷神整合服（GS_Server）服务端配置汉化版：

- 源根：`E:\缓存\WOW\.wow-build-tmp\gs-configs\`（只读原件）
- 拷贝日期：2026-10-28

## 文件清单与原始编码

| 文件 | 原始编码 | 落库编码 | 说明 |
|---|---|---|---|
| `worldserver.conf` | UTF-8 无 BOM | UTF-8 无 BOM（原样） | 谷神世界服务器配置汉化版 |
| `authserver.conf` | UTF-8 无 BOM | UTF-8 无 BOM（原样） | 谷神登录服务器配置汉化版 |
| `modules/playerbots.conf.dist` | UTF-8 无 BOM | UTF-8 无 BOM（原样） | 谷神 playerbots 模块配置汉化版（AiPlayerbot.* 键名） |
| `modules/playerbots.conf.dist.backup` | **GBK** | UTF-8 无 BOM（转码） | 谷神 playerbots 旧版配置备份 |
| `modules/mod_ahbot.conf.dist` | **GBK** | UTF-8 无 BOM（转码） | 谷神拍卖行机器人模块配置 |
| `modules/mod_eluna.conf.dist` | **GBK** | UTF-8 无 BOM（转码） | 谷神 Eluna 模块配置 |
| `modules/random_enchants.conf.dist` | **GBK** | UTF-8 无 BOM（转码） | 谷神掉落随机附魔模块配置 |
| `modules/transmog.conf.dist` | **GBK** | UTF-8 无 BOM（转码） | 谷神幻化模块配置 |
| `LUA说明.txt` | UTF-8 无 BOM | UTF-8 无 BOM（原样） | 谷神 Lua 脚本中文使用须知 |
| `超级炉石和随机附魔解压在此文件夹.zip` | ZIP 二进制 | 原样 | 两个 Lua 脚本原始压缩包（已解压核对哈希一致） |

## 编码说明

- 5 个 modules 文件在谷神盘上为 **GBK (CP936)**，直接按 UTF-8 打开会乱码；
  本目录已统一转码为 **UTF-8 无 BOM**，中文注释已抽验正常。
- `playerbots.conf.dist`（谷神版，AiPlayerbot.* 键）与 `playerbots.conf=UTF-8.dist`
  内容近乎一致（仅 3 行差异），键名迁移分析以后者为准，见
  `custom/conf-seed/KEYMAP-REPORT.md`。

## 与运行配置的关系

| 本目录（参考） | 对应产物（运行） |
|---|---|
| `modules/playerbots.conf.dist`（谷神 AiPlayerbot.*） | `custom/conf-seed/etc/modules/playerbots.conf`（已迁移为 Playerbots.*，477 键映射） |
| `worldserver.conf` / `authserver.conf`（谷神） | `custom/conf-seed/etc/worldserver.conf` / `authserver.conf`（基线 dist + 私有值回填） |
| `modules/mod_*.conf.dist`（谷神） | `custom/conf-seed/etc/modules/*.conf`（模块 dist + wow-private 私有值） |
