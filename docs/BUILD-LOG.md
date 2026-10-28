# CI 编译监控日志（BUILD-LOG）

> 仓库：https://github.com/xiaoran0503/wow-playerbot-gs-server（mod-playerbots/azerothcore-wotlk 的 fork）
> 用途：记录 GitHub Actions 双构建（Linux Docker 三镜像 + Windows 服务端 zip）的触发、失败根因、修复动作与最终状态。自动跟踪、按日志证据修复。

## 时间线

### 2026-10-28 · fork 推送成功，CI 首次触发

- 本地 HEAD 推送 main 成功（b734ff8f 起，含 wave2 全部提交）；push 自动触发两条 workflow。

### run 40668860444 / 40668860450（sha dec451aa，首推 b734ff8f 前的旧提交）→ failure

| workflow | run | 失败步骤 | 根因 |
|---|---|---|---|
| build-push | 40668860444 | Log in to Docker Hub | **DOCKERHUB_USERNAME/DOCKERHUB_TOKEN secrets 未配置**（仓库 Actions secrets 为空） |
| windows-build-package | 40668860450 | CMake configure | **`-G "Visual Studio 17 2022"` 在 windows-latest 报 "could not find any instance of Visual Studio"** |

修复动作（commit 90e6568c）：
1. `build-windows.yml`：CMake 去掉显式 `-G "Visual Studio 17 2022"`，只保留 `-A x64`，让 CMake 自动探测 VS 生成器（与上游 `./acore.sh compiler build` 行为一致）。
2. `build.yml`：Docker Hub 登录与推送条件化——未配置 secrets 时跳过登录、构建镜像导出为 tar artifact（`wow-images-tar`）上传，避免 CI 卡死在登录；配置后恢复 `--push` 直推。

### run 40670858844（sha 90e6568c，含上述修复）→ failure（无 job）

- 症状：run 秒失败、**无 job 列表**（workflow 解析失败）。
- 根因（本地 PyYAML 校验通过，排除 YAML 语法；对照 GitHub Actions 特有规则）：**`if:` 条件中不允许引用 `secrets` 上下文**（secrets 仅可用于 job/workflow env 与 step 的 run/with）。首次修复把 `if: ${{ secrets.DOCKERHUB_USERNAME != '' }}` 放进 step if，触发 GitHub 解析拒绝。

修复动作（commit da28de78）：
- 把判断提升到 workflow 级 `env.HAS_DOCKERHUB: ${{ secrets.DOCKERHUB_USERNAME != '' }}`（env 中允许 secrets），步骤 `if: env.HAS_DOCKERHUB == 'true'`、bash 分支 `[ "$HAS_DOCKERHUB" == "true" ]` 引用 env，不再直接触碰 secrets 上下文。
- 同时 90e6568c 的 windows run（40670860391）被新推送按 concurrency 顶掉（cancelled），属预期。

### run 40671549325 / 40671549208（sha da28de78，secrets 修复后）→ Linux failure / Windows 继续

- **build-push（40671549325）failure**，失败步骤：Build & push。
- 根因（编译错误，日志证据）：`modules/mod-dungeon-quests/src/mod_dungeon_quests_loader.cpp:8:35: fatal error: unknown type name 'src'`。
  - wave2 vendor 时为 mod-dungeon-quests 添加的 loader shim 注释里写了 `modules/*/src/`——其中的 `*/` 序列**提前终止了 C 块注释**，其后文字被当作代码（`src/ ...` 被解析为类型声明），编译失败。
- 修复动作（commit a4ea4ec8）：把注释改写成 `modules/<folder>/src/`，消除 `*/` 序列；并全局 Grep 确认无其他模块存在同类 `modules/*/` 注释陷阱。推送后重新触发 CI。

（继续补充轮询结果……）

### run 40675349685 / 40675349497（sha a4ea4ec8，loader 注释修复后）

- **build-push（40675349685）→ SUCCESS ✅**（2026-10-28 11:44 UTC 完成）
  - 编译通过：authserver / worldserver / db-import 三目标构建成功。
  - 无 DOCKERHUB secrets → 导出 `images/wow-{authserver,worldserver,db-import}-20261028-a4ea4ec8.tar` + image-manifest artifact（wow-images-tar 672MB）。
  - 本地镜像名：`local/wow-<target>:20261028-a4ea4ec8`；运行版 Docker 版将 docker load + tag 为 local/wow-<target>:latest 使用。
- **windows-build-package（40675349497）**：编译中（待补充结果）。

### run 40675349497（windows-build-package，sha a4ea4ec8）→ failure

- **Windows 构建失败**。失败步骤：build（MSVC 编译阶段），编译推进至 mod_forever_journal_loader.cpp 后进程 exit 1。
- 根因（编译错误，日志证据）：
  ```
  modules\mod-dungeon-quests\src\DungeonQuestMgr.cpp(26,17): error C2062: type 'char' unexpected
  modules\mod-dungeon-quests\src\DungeonQuestMgr.cpp(29,23): error C2143: syntax error: missing ';' before ':'
  modules\mod-dungeon-quests\src\DungeonQuestMgr.cpp(29,30): error C2059: syntax error: ')'
  ```
  - `SetsOverlap()` 内 `auto const& small = left.size() <= right.size() ? left : right;` 用 **auto + 三元表达式**——Linux GCC 接受，**MSVC 对 `auto` 推导条件表达式引用性不兼容**，26 行推导失败导致 29 行 range-for 连锁报错。
- 修复动作（commit d1e9ed3b）：DungeonQuestMgr.cpp 中该两行改为**显式类型** `std::unordered_set<uint32> const&`；并 Grep 全仓库 modules 确认其余 2 处同类 `auto const& ... ? :`（mod-playerbots TravelMgr.cpp:4398 / ICCActions_LK.cpp:3042）在本次 Windows 编译中未被报错，暂不动。推送后重新触发 CI。

### run 40702002471（windows-build-package，sha d1e9ed3b）→ failure（真根因定位）

- **d1e9ed3b 推送后 Windows 仍红**：拉该 run 的真实 job 日志（job 122863994672；注意上一组织者给的 job 122772776414 实际是 a4ea4ec8 旧 run 的 job，报错行号也对应旧文件），新报错行号整体后移 1 行（因加了注释行）：
  ```
  DungeonQuestMgr.cpp(27,39): error C2062: type 'char' unexpected
  DungeonQuestMgr.cpp(30,23): error C2143: missing ';' before ':'
  DungeonQuestMgr.cpp(30,30): error C2059: ')'
  ```
- **真根因（上一轮"auto 三元推导"诊断错误）**：27 行第 39 列正是标识符 `small`。Windows SDK `<rpcndr.h>`（经 windows.h 拉入）里有 **`#define small char`**（MIDL base type，见 MS Developer Community 确认）。于是 `std::unordered_set<uint32> const& small = ...` 预处理后变成 `... const& char = ...` → C2062；紧随的 range-for `for (uint32 value : small)` 变成 `: char` → C2143/C2059 连锁。同一函数里的 `big`/`left`/`right` 不是宏故不报错，这也解释了为何仅 `small` 触发。Linux glibc 头文件无此宏，故 GCC 一直能过。
- 修复动作（本轮 commit，见 git log）：把 `small`/`big` 两个局部变量改名为 `smallSet`/`bigSet`（注释同步更新为 rpcndr.h 宏说明）；全仓库 Grep `\bsmall\b` 确认其余命中均在注释/字符串中，无第二个真实标识符冲突。推送后重新触发 CI。

### 2026-10-28 · 运行版 Docker 联调修复（与 CI 并行，基于容器日志证据）

- **worldserver 反复重启（RestartCount≈27）的根因链**（全部在运行版容器内定位并修复）：
  1. **DBUpdater 被 mod-dungeon-quests 的 `base/mod_dungeon_quest_guide.sql` 卡死**：该文件为模块作者的手动脚本（DELIMITER + CREATE PROCEDURE），DBUpdater 内部执行器不支持，`Applying of file ... failed` 中断世界库更新流程 → 后续模块 updates（含 mod-random-enchants 建表）未应用 → 启动期 ASSERT `Table 'acore_world.item_enchantment_random_tiers' doesn't exist`（MySQLConnection.cpp:641）→ worldserver 退出重启。**修复**：手动以 mysql 客户端执行该脚本建表（`mod_dungeon_quest_override` 表），并将运行版挂载副本改名为 `*.skip` 移出扫描目录；同时把全部 11 个含 data/sql 模块的目录挂载进容器（此前仅挂 mod-playerbots），DBUpdater 应用全模块 updates 后**四库 up-to-date、世界加载、ready、AHBot 运行、稳定 8 分钟以上**。
  2. **lua 报错刷屏**：`遗产职业强化.lua:49: attempt to index local 'player' (a number value)`——ALE 回调首参为 event 号（number），谷神脚本按 Eluna 习惯写的函数签名缺 event 参数导致错位；且脚本注册的 Eluna 事件 27/42（评级/减伤）在 mod-ale 枚举中语义不同（27=UPDATE_ZONE、42=COMMAND）。**修复**：函数签名统一加 `event` 首参；升级事件改用 ALE 的 13（2 在 ALE 为角色删除）；评级/减伤注册移除（ALE 无等价事件）。仓库 custom/lua_scripts 与运行版同步。
  3. **MMAP 数据版本不匹配**：datalyf 为 v16 提取数据、新 core 期望 v20，`MMAP:loadMap` 逐 tile 报错刷屏（非致命）。worldserver.conf `MoveMaps.Enable = 0` 临时禁用（地图数据重提取后再恢复），vmap 同前已禁。
  4. **容器挂载可写**：configs 目录改为可写挂载（entrypoint `.write-test` 权限检查）。
  5. **conf 命名/内容修复**：模块 conf 按 mod_ 前缀命名（aoe_loot→mod_aoe_loot 等）；mod_ale.conf/transmog.conf 孤立裸字符串行补全。
- **结果**：Docker 版运行验收达成——worldserver `ready...`、auth 20241 / world 20242 端口开放、AHBot 循环运行、Playerbots.log 持续增长、容器稳定运行超过历史崩溃周期。
