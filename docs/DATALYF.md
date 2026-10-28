# datalyf 地图数据仓库内化记录

## 概览

将谷神地图数据从原件 `E:\缓存\WOW\GS_Server\datalyf` 全量拷贝进仓库，并把所有部署引用从"只读挂载原件"切换为"使用仓库内拷贝"。

- 拷贝时间：2026-10-28 16:16:10 ~ 16:16:29（robocopy 实际复制约 17 秒，含枚举共约 4 分 28 秒）
- 源路径（只读，不再被部署引用）：`E:\缓存\WOW\GS_Server\datalyf`
- 目标路径（仓库内拷贝）：`E:\缓存\WOW\wow-playerbot-server\data\datalyf`

## 校验数字（源与副本一致）

| 指标 | 源 | 目标副本 | 期望 |
|---|---|---|---|
| 文件数 | 22,852 | 22,852 | 22,852 |
| 字节总数 | 3,410,634,376 | 3,410,634,376 | 3,410,634,376 |

- robocopy 退出码：**1**（= 成功复制，无失败文件：Files 22852/22852，FAILED 0，Mismatch 0）
- 校验方法：`Get-ChildItem -Recurse -File -Force` 分别对源与副本枚举，`Measure-Object Length -Sum` 求和字节数，两侧逐一比对。

## 子目录结构（目标副本，均非空）

| 子目录 | 文件数 | 说明 |
|---|---|---|
| maps | 5,819 | 地图（map files） |
| dbc | 493 | DBC 数据表（含 enUS 子目录） |
| vmaps | 12,537 | 模型碰撞 |
| mmaps | 3,987 | 移动寻路 |
| Cameras | 13 | 飞行相机 m2 |

根目录另有 `desktop.ini`（系统隐藏）与 `playerbots.conf=UTF-8.dist`。

## .gitignore 验证

仓库根执行 `git check-ignore data/datalyf` 输出 `data/datalyf`（退出码 0），即该目录已被 `.gitignore` / `.dockerignore` 忽略，不会进入版本库或镜像构建上下文。本任务未改动这两个文件。

## 部署引用切换点清单

| 文件 | 改动行 | 改动内容 |
|---|---|---|
| `docker/docker-compose.yml` | 第 46–47 行 | 挂载行 `${WOW_DATA_DIR:-…\GS_Server\datalyf}` → `${WOW_DATA_DIR:-E:\缓存\WOW\wow-playerbot-server\data\datalyf}`，`:ro` 只读语义保留；注释更新为"使用仓库内 data/datalyf 全量拷贝，不再引用 GS_Server 原件"。YAML 已通过 python yaml.safe_load 校验。 |
| `scripts/deploy-wslc.ps1` | 第 53 行 | `$dataDir` 默认值 `E:\缓存\WOW\GS_Server\datalyf` → `E:\缓存\WOW\wow-playerbot-server\data\datalyf`，行尾注释注明原件不再被引用。 |
| `README.md` | 第 85 行 | "只读挂载自 `E:\缓存\WOW\GS_Server\datalyf`" → "只读挂载自仓库内 `data\datalyf`（已全量拷贝，原件不再被引用）"。 |

## 残留引用排查

在仓库内（排除 `data/datalyf` 与 `.git`）搜索 `datalyf` / `GS_Server`：

- **活动部署引用**：无。所有部署路径均已指向仓库内拷贝。
- **历史来源说明（允许保留）**：
  - `docs/gushen-reference/worldserver.conf:177` — `DataDir = ".\datalyf"`，谷神原件配置快照，仅作汉化参考。
  - `docs/LOCALIZATION.md`、`docs/gushen-reference/README.md`、`custom/lua_scripts/README.md`、`NOTICE`、`README.md` 中关于 GS_Server 的归属/来源说明文字（非数据路径引用）。

## 硬约束执行情况

- 原件仅被 robocopy 只读读取，未做任何写操作。
- 未执行 `git add` / `git commit`（由主代理统一提交）。
- 未改动 `.gitignore` / `.dockerignore`。
