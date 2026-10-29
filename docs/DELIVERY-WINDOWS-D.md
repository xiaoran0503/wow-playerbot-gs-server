# WOW 自维护版服务器端 · Windows 成品交付说明

- **交付路径**：`D:\wow_server`
- **构建方式**：GitHub Actions（`windows-latest` + Visual Studio 2022 / MSVC x64，Release）
- **代码仓库**：`https://github.com/xiaoran0503/wow-playerbot-gs-server`
  分支 `feature/upstream-sync-20261029`
- **上游基线**：AzerothCore 官方 `master` @ `993b45959`（2026-10-28）
  + mod-playerbots `master` @ `e88cc4099e`

---

## 一、这次修复了什么

### 1. 启动即闪退（原始问题）

**现象**：双击 `authserver.exe` / `worldserver.exe`，进程瞬间消失，控制台无输出。

**根因**：`std::filesystem::filesystem_error` 未被捕获，直接终止进程。

- 崩溃异常码 `0xE06D7363`（MSVC C++ 异常）。从 minidump 的
  `ThrowInfo → CatchableTypeArray → TypeDescriptor` 解出类型链：
  `filesystem_error` → `system_error` → `_System_error` → `runtime_error` → `exception`。
- 触发链：`DatabaseLoader::AddDatabase` → `PopulateDatabase` → `ApplyFile`
  → `std::filesystem::path` 相关调用抛异常。
- 上游 AzerothCore 的数据库更新器只 `catch (UpdateException&)`，
  而 `filesystem_error` 继承自 `std::system_error`，**不是** `UpdateException`
  的子类 → 异常逃逸所有 catch → `std::terminate` → 进程被杀。

**精确触发条件**（A/B 实测，同一 exe、同一数据库，仅改配置）：

| `MySQLExecutable` 的值 | 结果 |
|---|---|
| `""`（留空） | **崩溃** —— `absolute("")` 对空路径抛 `filesystem_error` |
| 指向不存在的文件 | **崩溃** —— 同样走到对空路径调用 `absolute()` |
| 指向真实存在的 `mysql.exe` | **正常启动** |

**修复**（两层）：

1. **合入官方修复** —— 合并官方 `master` 后，
   `DBUpdaterUtil::CheckExecutable()` 改用 `is_regular_file(p, ec)` /
   `absolute(p, ec)` 的 `error_code` 重载。官方注释原文：
   > `absolute() without an error_code throws (an empty path, a missing working
   > directory), and nothing up to main() catches filesystem_error`
2. **本地再加一层防御** —— `UpdateFetcher` 的 `directory_iterator` 构造与递增、
   `DBUpdater` 的 `is_directory()` / `temp_directory_path()` 全部改用
   `error_code` 重载，并在更新与填充流程里显式 `catch (std::filesystem::filesystem_error)`，
   把「崩溃」降级为「一条明确的错误日志 + 干净退出」。

### 2. 配置文件修正

`MySQLExecutable` 留空时，服务器只会在系统 `PATH` 里找 `mysql`。
本包把 MySQL 放在 `mysql\bin\` 下（不在 PATH），所以**必须**显式指定。
`configs\worldserver.conf` 与 `configs\authserver.conf` 现默认：

```ini
MySQLExecutable = "./mysql/bin/mysql.exe"
```

留空或写错时，服务器会在启动阶段报
`Didn't find any executable MySQL binary at ...` 并停止启动 ——
这是有意为之，避免数据库结构只更新一半。

### 3. 依赖 DLL 补齐

`src/common/Cryptography/OpenSSLCrypto.cpp` 在 Windows 上**硬断言**
`legacy.dll`（OpenSSL 3.x 的 legacy provider）就在 exe 同目录，缺失即启动失败。
原先的打包流程没有把它带上，现已从 runner 的同一份 OpenSSL 安装中取出，
保证与 `libcrypto` / `libssl` 版本一致。

---

## 二、目录结构

```
D:\wow_server\
├─ worldserver.exe            主程序
├─ authserver.exe             主程序
├─ libmysql.dll               MySQL 8.4.9 客户端库（与服务端版本一致）
├─ libcrypto-3-x64.dll        OpenSSL 3.x
├─ libssl-3-x64.dll          OpenSSL 3.x
├─ legacy.dll                 OpenSSL legacy provider（启动断言要求）
├─ configs\                   运行配置（worldserver.conf / authserver.conf）
│  └─ modules\                各模块的 .conf
├─ data\sql\                  SQL 树（base / updates / custom / archive）
├─ modules\                   19 个内置模块
├─ lua_scripts\               ALE (Eluna) Lua 脚本（ALE.ScriptPath 指向此处）
├─ datalyf\                   客户端数据（dbc / maps / vmaps / mmaps / Cameras）
├─ mysql\                     MySQL 8.4.9 服务端（bin / data / share / my.ini）
├─ tools\                     地图提取工具
├─ 启动服务器.bat              一键启动（MySQL → authserver → worldserver）
├─ 启动mysql.bat               只启动 MySQL
├─ 停止服务器.bat              停止全部
└─ Server.log / Auth.log      运行日志
```

---

## 三、启动

**推荐：双击 `启动服务器.bat`**，它会按正确顺序拉起三个进程。

手动启动时的顺序**不能颠倒**：

1. `启动mysql.bat`
2. `authserver.exe`
3. `worldserver.exe`

> **为什么 authserver 要先起？**
> worldserver 启动时会把 realm 标记为 `OFFLINE | VERSION_MISMATCH`（`flag = 3`），
> 直到自己完全就绪才清掉 `VERSION_MISMATCH` 位；而 authserver 查询 realm 用的是
> `WHERE flag <> 3`。所以在 worldserver 仍在运行（或刚被强杀）时启动 authserver，
> 它会因为「所有 realm 都是 flag=3」而拒绝启动，日志报
> `No valid realms specified`。

worldserver 首次初始化约需 1–3 分钟，日志出现 `World initialized` 后即可登录客户端。

---

## 四、数据库完整性核验

核验方法与官方 `UpdateFetcher` 一致：比较 `data/sql/updates/<db>/` 下的
`.sql` 文件集合，与该库 `updates` 表里已应用记录是否吻合。

```bash
# 更新记录是否全部到位
python scripts/verify-db-completeness.py "D:/wow_server/mysql/bin/mysql.exe" "D:/wow_server"

# 表 / 列结构是否完整
python scripts/verify-db-schema.py "D:/wow_server/mysql/bin/mysql.exe" "D:/wow_server"
```

**本次核验结果（四个库全部通过）**：

| 库 | 更新文件 | 已应用记录 | 表结构 | 列结构 |
|---|---|---|---|---|
| `acore_auth` | 15 | 25 | ✅ 22/22 表齐 | ✅ |
| `acore_characters` | 10 | 42 | ✅ 108/108 表齐 | ✅ |
| `acore_world` | 1070 | 3313 | ✅ 309/309 表齐（`spell_proc_event` 已被官方 `2026_10_28_00.sql` 主动 DROP）| ✅ |
| `acore_playerbots` | 36 | 36 | ✅ 29/29 表齐 | ✅ |

`acore_world` 已追平到官方最新的 `2026_10_28_01.sql`。

### 核验中发现并修掉的一个真实缺陷

从旧套件迁移过来的库**不是空的**，所以 `PopulateDatabase` 判定「库非空」而从不
执行 base SQL —— 那些**只存在于 base 文件里、从未被 update 文件覆盖**的表就会缺失。

本次发现 `acore_playerbots` 缺两张表，已用上游 base SQL 补齐：

- `playerbots_speech`
- `playerbots_speech_probability`

补齐脚本已固化为 `scripts/fix-realm-name.sh` 的同类工具，
后续任何「库非空但表缺失」的情况都应按同样方式补跑对应 base 文件。

### realm 名称编码修复

`realmlist.name` 从旧套件迁移过来时是**双重编码**的
（UTF-8 字节先被当作 cp1252 解码，再重新编码存回 UTF-8），
在客户端和日志里显示成 `é­”å…½ä¸–ç•Œ` 这类乱码。

可逆还原：`存储值 → utf-8 解码 → cp1252 编码 → 按 utf-8 解读`，
结果为正确的「魔兽世界」。

```bash
bash scripts/fix-realm-name.sh "D:/wow_server/mysql/bin/mysql.exe" acore_auth
```

---

## 五、依赖版本

| 依赖 | 版本 | 来源 |
|---|---|---|
| MySQL 客户端 / 服务端 | 8.4.9 | 官方 `cdn.mysql.com/archives/mysql-8.4/mysql-8.4.9-winx64.zip` |
| Boost | 1.87.0 (msvc-14.3, x64) | 官方 SourceForge 预编译包 |
| OpenSSL | runner 镜像自带 | `OPENSSL_ROOT_DIR`（含 `legacy.dll`） |
| MySQL C++ 客户端库 | 8.4.9 | 同 MySQL 官方包 |

官方 `DatabaseWorkerPool` 有硬校验
`mysql_get_client_version() == MYSQL_VERSION_ID`，
客户端库与服务端版本必须严格一致（对应官方 wiki 的 ACE00046）。
当前成品已核验：客户端 `8.4.9` == 服务端 `8.4.9` == CI 编译版本。

---

## 六、已知行为（非缺陷）

- **`spell_proc_event` 表不存在**：官方 `2026_10_28_00.sql` 主动 `DROP` 了它，
  数据库比 base SQL 更新，属正常。
- **`realmlist.flag = 3`**：worldserver 运行期间的正常状态，
  它就绪后会自己清掉 `VERSION_MISMATCH` 位。
- **MySQL 8.4 不接受非 ASCII 路径**：basedir / datadir 含中文时
  MySQL 会截断路径并报 `Failed to set datadir to 'E:\data\'`。
  `启动mysql.bat` 用 `subst` 映射纯 ASCII 盘符来规避；
  本次交付路径 `D:\wow_server` 本身是纯 ASCII，可直接运行。
