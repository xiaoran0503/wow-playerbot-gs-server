# scripts/ — 仓库维护脚本

本目录配合 `.github/workflows/` 的两个工作流，构成「编译 + 上游同步」三件套。

## 1. `sync-upstream.ps1` — 本机上游同步（pwsh 7）

把上游 `mod-playerbots/azerothcore-wotlk` 的 **Playerbot 分支**快照与 `modules/` 下 6 个 vendor 模块的最新代码拉进本仓库。

```powershell
# 仅本地提交（默认；远程未配置 origin 时也用它）
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/sync-upstream.ps1

# 提交后直接推送 origin/main（会触发 Actions 重新编译）
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/sync-upstream.ps1 -Push
```

做的事：

1. `git fetch upstream Playerbot --depth=1` + `git reset --soft upstream/Playerbot`（本地私有提交保留为新提交）；
2. 刷新 6 个模块：`mod-playerbots`（固定 `master`）、`mod-ale`、`mod-ah-bot`、`mod-transmog`、`mod-random-enchants`、`mod-boss-announcer`（跟随各自默认分支）—— clone depth-1 → 删 `.git` → 覆盖 `modules/<名>`；
3. 若 `custom/conf-seed/gen-conf-seed.ps1` 存在则调用重生成配置种子；
4. `git add -A` → 有变更才提交；带 `-Push` 才推送 `origin/main`。

前置 remote：

- `upstream` = https://github.com/mod-playerbots/azerothcore-wotlk.git （已配置）
- `origin` = 自有仓库（推送前需 `git remote add origin <自有仓库地址>`）

## 2. `.github/workflows/sync-upstream.yml` — CI 定时同步

每日 03:00 UTC（北京时间 11:00）自动跑同一个 `sync-upstream.ps1 -Push`，直推 `main` 后再触发一次构建。默认直通 push；备选 PR 模式（gh CLI + `GH_TOKEN` secret）已在文件内注释说明。

## 3. `.github/workflows/build.yml` — CI 编译并推送镜像

push main / 手动 / 每日 02:00 UTC 触发，Buildx 编出 `wow-authserver`、`wow-worldserver`、`wow-db-import` 三个镜像推到 Docker Hub（tag = `YYYYMMDD-<sha8>` + `latest`），并上传镜像清单 artifact。需要仓库 Secrets：`DOCKERHUB_USERNAME`、`DOCKERHUB_TOKEN`。
