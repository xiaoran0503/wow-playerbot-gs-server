# mod-register

AzerothCore 模块：内置 GM 后台管理面板（Boost.Beast HTTP 服务，本地执行）。

## 功能

- **账号管理**：查询账号、修改 GM 权限等级（gmlevel 0-3）
- **角色管理**：查询角色、改名、重置天赋
- **物品发放**：按名称/ID/大类/品质/装备栏位/物品等级多条件检索物品，游戏内邮件发放
- **金币发放**：游戏内邮件发放金币
- **在线状态**：账号与角色在线列表
- **封禁/解封**：账号封禁与解封
- **服务器活动**：game_event 活动开启/关闭
- **维护**：通过 `.pdump write` / `.pdump load` 导出导入账号

## 技术方案

- HTTP 服务：Boost.Beast + Boost.Asio（AzerothCore 已依赖 Boost 1.92），监听本机。
- 命令执行：`sWorld->QueueCliCommand(new CliCommandHolder(...))` 在 world 线程队列执行 GM 命令，
  通过 promise 同步等待结果（与 ACSoap 同模式），**无需 SOAP/RA**。
- 数据查询：直接访问 `LoginDatabase` / `CharacterDatabase` / `WorldDatabase`。
- 前端：HTML 单页内嵌为 C++ 字符串，fetch 调用 `/api/*` JSON 接口。

## 配置

见 `conf/mod_register.conf.dist`，关键项：

| 键 | 默认 | 说明 |
|----|------|------|
| `Register.Enable` | 0 | 是否启用 |
| `Register.IP` | 127.0.0.1 | 监听地址（保持本机） |
| `Register.Port` | 8090 | 监听端口 |
| `Register.MinGmLevel` | 2 | 登录所需最低权限 |
| `Register.AdminAccount` | 空 | 白名单账号（逗号分隔，空=不限） |

## 使用

1. 启用模块后重启 worldserver。
2. 浏览器访问 `http://127.0.0.1:8090`。
3. 用 gmlevel ≥ 2 的游戏账号登录。

## 安全

- 服务默认监听 `127.0.0.1`，**不要**做公网端口映射（HTTP 明文）。
- 登录走游戏账号密码校验（SRP6），会话 token 内存缓存、可配超时。
- 所有命令经 world 线程队列执行，与游戏内 GM 命令等价。

## 编译

模块为静态模块，`src/*.cpp` 自动纳入 worldserver 编译。首次编译前确认
`Register.Enable = 1`，或在 CMake 时模块已启用（`MODULES=static`）。

## License

GNU AGPL v3，同 AzerothCore。
