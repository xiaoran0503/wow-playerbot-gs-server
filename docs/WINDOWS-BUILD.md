# Windows 版服务端构建说明（build-windows.yml）

与 `build.yml`（Linux Docker 镜像版）并行存在、互不影响。本机不编译，一切编译在 GitHub Actions 的 `windows-latest` runner 上完成。

## 1. 选型理由：为什么是「镜像自带 VS2022 + 直下 Boost/MySQL」而不是 vcpkg

调研结论按权威度排序：

1. **本仓库自带的上游 CI 配方就是事实标准**：`.github/workflows/windows_build.yml` 是 AzerothCore 官方维护的 Windows 构建 workflow，它的注释明确记录了踩坑过程——
   > "We fetch these directly instead of via chocolatey, whose pinned packages keep breaking on CI (VS detection failures and slproweb removing old OpenSSL installers)."

   即：**chocolatey / vcpkg 在 GitHub Windows runner 上反复坏**（VS 检测失败、安装源下架、vcpkg 编 Boost 要 30~60 分钟）。因此官方 CI 选择直下预编译包。本 workflow 直接沿用这份已验证配方，只去掉与本仓库无关的 mod-playerbots 独立 checkout（本仓库已把 19 个模块全部 vendored 在 `modules/`），并加上打包步骤。

2. **官方 wiki**（https://www.azerothcore.org/wiki/windows-requirements 、https://www.azerothcore.org/wiki/windows-core-installation ）要求：CMake ≥ 3.27、Visual Studio 2022 (17.x)、Boost ≥ 1.78、MySQL ≥ 5.7 客户端、OpenSSL。`windows-latest` runner 镜像已预装 CMake + VS2022 (MSVC) + OpenSSL，只缺 Boost 与 MySQL 客户端两样。

3. **cmake 参数出处**：`apps/compiler/includes/functions.sh` 的 Windows(msys) 分支——`-DMYSQL_INCLUDE_DIR=C:\tools\mysql\current\include -DMYSQL_LIBRARY=C:\tools\mysql\current\lib\mysqlclient.lib`，以及统一的 `-DSCRIPTS -DMODULES -DTOOLS_BUILD -DCMAKE_BUILD_TYPE`。本 workflow 与之逐一对齐。

### 依赖来源 URL（全部在 Actions 内下载，本机不下载）

| 依赖 | 来源 | 落地位置 |
|---|---|---|
| Boost 1.87.0 msvc-14.3 64bit 预编译包 | https://downloads.sourceforge.net/project/boost/boost-binaries/1.87.0/boost_1_87_0-msvc-14.3-64.exe | `C:\local\boost_1_87_0`（= `BOOST_ROOT`） |
| MySQL 8.4.9 客户端（zip，只链接用，不装服务端） | https://cdn.mysql.com/archives/mysql-8.4/mysql-8.4.9-winx64.zip | `C:\tools\mysql\current` |
| OpenSSL / VS2022 / CMake | runner 镜像自带 | `OPENSSL_ROOT_DIR` 自动探测 |

注意两个 UA 坑（沿用上游配方）：Boost 必须发**非浏览器 UA**（否则 SourceForge 返回 HTML 页），MySQL CDN 必须发**浏览器 UA**（否则 Oracle 返回错误页）。

## 2. 用法

触发方式（与 build.yml 解耦）：

- **push 到 `main`** → 自动跑
- **Actions 页面手动 Run workflow**（`workflow_dispatch`）

无需任何 Secret（不推 Docker Hub，只出 artifact）。

产物在该次 run 的 **Artifacts → `wow-windows`**，文件名 `wow-windows-<UTC日期YYYYMMDD>-<git-sha8>.zip`（tag 规则与 build.yml 一致）。

## 3. zip 内容清单（解压后 `wow-server\` 目录）

| 路径 | 内容 | 来源 |
|---|---|---|
| `worldserver.exe` / `authserver.exe` | 服务端主程序（Release, 静态链接脚本与 19 个模块） | `build\bin\Release\` |
| `tools\mapextractor.exe` | 提取 dbc/maps/vmaps | `build\bin\Release\` |
| `tools\vmap4extractor.exe` / `vmap4assembler.exe` | vmaps 提取/组装 | 同上 |
| `tools\mmaps_generator.exe` | mmaps 生成（最耗时） | 同上 |
| `libmysql.dll` | MySQL 客户端动态库 | `C:\tools\mysql\current\lib\` |
| `libcrypto-*.dll` / `libssl-*.dll` | OpenSSL 动态库 | runner 镜像 OpenSSL 安装目录 `bin\` |
| `boost_*-vc143-*.dll`（一批） | Boost filesystem/program_options/dll 等运行时库 | `C:\local\boost_1_87_0\lib64-msvc-14.3\` |
| `configs\worldserver.conf.dist` | 世界服务端配置（中文注释版模板） | `custom\conf-seed\etc\worldserver.conf` 改名 |
| `configs\authserver.conf.dist` | 登录服务端配置（中文注释版） | `custom\conf-seed\etc\authserver.conf` 改名 |
| `configs\modules\*.conf.dist` | 19 个模块配置模板（playerbots.conf 等） | `custom\conf-seed\etc\modules\*.conf` 批量改名 |
| `README-windows.txt` | 包内部署说明 | workflow 运行时生成 |

**关键路径语义**（已核对 `src/common/Configuration/Config.cpp` 第 704-712 行）：Windows 版 core 写死从**工作目录下的 `configs\` 子目录**读 `worldserver.conf` / `authserver.conf`，模块配置在 `configs\modules\`——不是 `conf\`、也不是 exe 同目录。用户首次运行前把 `*.conf.dist` 复制改名成 `*.conf` 即可。

## 4. 与 Linux 镜像版（build.yml）的差异

| 维度 | Linux 镜像版 | Windows 打包版 |
|---|---|---|
| 运行环境 | Docker 容器（ubuntu） | 用户本机 Windows |
| 产物 | Docker 镜像（authserver/worldserver/db-import） | 一个 zip（exe+DLL+配置模板） |
| 依赖形态 | 系统包/mysqlclient 静态进镜像 | 运行时 DLL 随包分发 |
| 配置目录 | 容器内 `/opt/azerothcore/etc/` | `工作目录\configs\`（Windows 硬编码） |
| 模块 | 6+ vendor 模块，与本 zip 同源 | 同样的 19 个模块，静态编进 exe |
| 数据库 | db-import 镜像导入 | 需用户自备 MySQL 8.x + 导 sql/ |
| 地图数据 | 镜像外挂载 | zip 不含，用户用包内 `tools\` 自行从 3.3.5a 客户端提取 |

## 5. 推送后需触发验证的步骤（本 workflow 未在本机跑过编译）

1. `git push origin main` 后到仓库 **Actions** 页确认出现 `windows-build-package` 运行。
2. 重点观察三处：
   - **Install Boost & MySQL client**：下载是否过 size 兜底（>50MB 校验）；缓存命中时该步秒过。
   - **CMake configure**：BOOST_ROOT / MySQL 路径是否被找到（若报找不到 boost，查 `C:\local\boost_1_87_0` 是否有 `boost\version.hpp`）。
   - **Build**：全量编译 + 19 模块预计 40~70 分钟，属正常。
3. 成功后下载 Artifact `wow-windows` 解压，先在本机双击 `authserver.exe` 看是否因缺 DLL 闪退（闪退即按 README 装 VC++ 2015-2022 Redistributable），再核对 `configs\` 目录结构与本文件第 3 节清单一致。
