# mod-ah-bot（拍卖行机器人）启用记录

> 仅限本服私有用途。本文含专用账号明文密码，请勿外传、勿提交公开仓库。

## 1. 结果摘要

| 项目 | 值 |
|---|---|
| 数据库容器 | wow-mysql（MySQL 8.4，127.0.0.1:3307） |
| 账号用户名 | ahbot |
| 账号 id | **56** |
| 账号 expansion | 2（默认，与门户注册账号一致） |
| 账号密码 | **zEAXq8AVMhgMSjjz**（16 位随机，字母+数字，无 GM/SEC_PLAYER 权限） |
| 角色名 | Ahbot |
| 角色 GUID | **567** |
| 角色 account | 56（与上面账号 id 一致） |
| 角色来源 | 克隆自 characters.guid=1（整行复制，覆盖 guid/account/name） |

配置文件：custom/conf-seed/etc/modules/mod_ahbot.conf（Account=56，GUID=567）。

## 2. mod-ah-bot 源码结论（Account / GUID 到底是什么）

引用出处均在 modules/mod-ah-bot/src/：

- **AuctionHouseBot.Account = acore_auth.account.id（数字账号 id，不是用户名）**。
  AuctionHouseBotWorldScript.cpp 第 31 行读取 AuctionHouseBot.Account，第 46 行执行
  SELECT guid FROM characters WHERE account = {account}——即 bot 只认“该账号 id 下的角色”。
- **AuctionHouseBot.GUID = acore_characters.characters.guid（角色 GUID），且该角色行必须真实存在、且其 account 列等于上面的账号 id**。
  WorldScript 第 57-78 行：若 GUID=0，则该账号下所有角色都当 bot；若指定 GUID，则只在查询结果里匹配到该 guid 才启用。匹配不到则第 89-93 行报错 “no characters registered”，bot 不启用。
- **bot 不走 realmd 登录**：AuctionHouseBot.cpp 第 1029-1034 行在内存里直接 new 一个
  WorldSession（会话名硬编码 “AuctionHouseBot” + 账号 id）和 Player，再 Initialize(_id) 按 guid 加载角色。
  因此该账号**不需要能在客户端登录**，密码仅用于满足 account 表 SRP6 非空约束；角色名在 DB 里叫什么不影响 bot（会话名是程序内造的）。
- **邮件**：AuctionHouseBotMailScript.cpp 第 30-38 行——凡是发给 bot guid 的拍卖邮件，直接 sendMail=false 并删除购得物品。bot 角色不需要真实收件箱。
- **Seller / Buyer 开关**：EnableSeller=1 挂单卖货，EnableBuyer=1 收购玩家挂单，二者独立。

## 3. 建号方式（SRP6，复刻门户）

复刻 wow-docker/portal/WoWSimpleRegistration/application/include/functions.php::calculateSRP6Verifier（经典分支，server_core!=5，无 strrev）：

- g = 7；N = 894B645E89E1535BBDAD5B8B290650530801B18EBFBF5E8FAB3C82872A3E9BB7
- salt = 32 字节随机；
- h1 = SHA1( uppercase(用户名 + ':' + 密码) )；h2 = SHA1( salt + h1 )；
- x = h2 按小端解释为整数；verifier = g^x mod N，按小端导出并 NUL 右填充到 32 字节。
- 写入 account.salt / account.verifier（binary(32)），SQL 里用 UNHEX('<hex>') 还原。

本栈 acore_auth.account **无 srp_version 列**（经典 SRP6），与门户固定 srp6_version=0 一致。

## 4. 克隆角色方式

INSERT INTO acore_characters.characters SELECT ...，取 MAX(guid)+1=567，account=56，name='Ahbot'。
该表除 PK(guid) 外无 (guid,account) 唯一键、name 仅普通索引；NOT NULL 无默认列（taximask、innTriggerId）由整行复制自动带过。
只克隆 characters 主行，不复制 character_inventory/skills、guild_member、arena、calendar 等关联表（bot 不需要，邮件也被拦截）。

## 5. 配置键（mod_ahbot.conf，最终值）

| 键 | 值 | 说明 |
|---|---|---|
| AuctionHouseBot.EnableSeller | 1 | 卖货端开启 |
| AuctionHouseBot.EnableBuyer | 1 | 收购端开启 |
| AuctionHouseBot.Account | 56 | acore_auth.account.id |
| AuctionHouseBot.GUID | 567 | acore_characters.characters.guid（account=56） |
| AuctionHouseBot.UseBuyPriceForSeller | 0 | 默认，按 SellPrice |
| AuctionHouseBot.UseBuyPriceForBuyer | 0 | 默认，按 SellPrice |
| AuctionHouseBot.UseMarketPriceForSeller | 0 | 默认关闭（启用市场价需 mod_auctionhousebot 世界表数据与调参，保持默认） |
| AuctionHouseBot.MarketResetThreshold | 25 | 默认 |
| AuctionHouseBot.ItemsPerCycle | 200 | 默认 |

其余过滤/分类键全部保持 conf.dist 默认值。

## 6. 世界库 SQL（本次仅记录，未导入）

模块自带 SQL 全部在 modules/mod-ah-bot/data/sql/db-world/（世界库 acore_world）：
mod_auctionhousebot.sql（各 AH 配额/价格表）、uctionhousebot_professionItems.sql、z_filter_disabled_and_trash.sql。
若 worldserver 日志提示缺少 mod_auctionhousebot 表，再把这三个导入 acore_world。本服 auth/characters 库无需任何表结构变更。

## 7. 启用 / 验证步骤

1. 把填好的 mod_ahbot.conf 部署到 worldserver 的 tc/modules/（与现有模块配置同目录）。
2. 重启 worldserver（或 .reload config）。
3. 日志应出现 Initialize AuctionHouseBot...，且不再出现 “no characters registered for account 56”。
4. SQL 验证：
   - SELECT id,username,expansion FROM acore_auth.account WHERE id=56; -> 56 / ahbot / 2
   - SELECT guid,account,name,level,online FROM acore_characters.characters WHERE guid=567; -> 567 / 56 / Ahbot / 1 / 0

## 8. 相关文件

- 可重放脚本：sql/admin/ahbot_setup.sql
- 备份快照：.wow-build-tmp/ahbot-pre-backup/acore_auth.account.sql、core_characters.characters.sql（动表前 mysqldump）