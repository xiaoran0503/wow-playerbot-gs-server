-- =============================================================================
-- ahbot_setup.sql — 拍卖行机器人 (mod-ah-bot) 专用账号 + 克隆角色 初始化脚本
-- -----------------------------------------------------------------------------
-- 用途：在本服 wow-mysql (MySQL 8.4, 127.0.0.1:3307) 中为 mod-ah-bot 创建：
--   1) acore_auth.account 专用账号 ahbot（经典 SRP6，无 GM 权限）
--   2) acore_characters.characters 克隆角色（guid=max+1, account=新账号, name=Ahbot）
-- 来源：SRP6 算法复刻自 wow-docker/portal/WoWSimpleRegistration
--       (application/include/functions.php -> calculateSRP6Verifier, 经典分支, 无 strrev)
-- 运行方式（容器内 root 密码取环境变量 MYSQL_ROOT_PASSWORD）：
--   wslc exec -i wow-mysql sh -c 'mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --default-character-set=utf8mb4' < sql/admin/ahbot_setup.sql
-- 注意：本文件含明文密码，仅限本服私有用途，勿外传/勿提交公开仓库。
-- 账号密码（16 位随机，字母+数字，无 GM 权限）：zEAXq8AVMhgMSjjz
-- salt/verifier 即由该用户名(ahbot)+该密码按经典 SRP6 算出，下面 UNHEX() 已还原。
-- 重跑前提：目标库尚无 ahbot 账号（account.username 唯一键冲突）；角色模板 guid=1 需存在。
-- =============================================================================

-- A) 专用账号（salt/verifier 为 32 字节，UNHEX 还原为 binary(32)）
INSERT INTO acore_auth.account (username, salt, verifier, expansion)
VALUES (0x6168626f74,                       -- 'ahbot'
        UNHEX('7d6c639a01e502a873c66d37f7520711d88ebf48422582bd361e95eca4312636'),
        UNHEX('bfccc1bafa7f5b776ca3c5d49180b0ccee3857b7f5017be1c8bd2ad2ea373238'),
        2);

SET @newid = (SELECT id FROM acore_auth.account WHERE username = 0x6168626f74);

-- B) 克隆角色：以 guid=1 整行为模板，覆盖 guid/account/name/online/登录标记/删除标记
SET @newguid = (SELECT MAX(guid) + 1 FROM acore_characters.characters);

CREATE TEMPORARY TABLE acore_characters.tmp_clone AS
SELECT * FROM acore_characters.characters WHERE guid = 1;

UPDATE acore_characters.tmp_clone
   SET guid              = @newguid,
       account           = @newid,
       name              = 0x4168626F74,          -- 'Ahbot'
       online            = 0,
       logout_time       = 0,
       at_login          = 0,
       deleteDate        = NULL,
       deleteInfos_Account = NULL,
       deleteInfos_Name    = NULL;

INSERT INTO acore_characters.characters SELECT * FROM acore_characters.tmp_clone;

-- C) 验证
SELECT CONCAT('ACCOUNT id=', id, ' username=', username, ' expansion=', expansion)
  FROM acore_auth.account WHERE id = @newid;
SELECT CONCAT('CHARACTER guid=', guid, ' account=', account, ' name=', name, ' level=', level)
  FROM acore_characters.characters WHERE guid = @newguid;