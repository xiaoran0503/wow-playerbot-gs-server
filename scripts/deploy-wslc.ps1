# =============================================================================
# deploy-wslc.ps1 — Playerbot 分支私服栈部署 (wslc, 本机无 compose 子命令,
#                  逐容器镜像起栈; 适配 6 个 vendor 模块)
# -----------------------------------------------------------------------------
# 用法:
#   pwsh -File scripts/deploy-wslc.ps1                 # 完整部署(拉镜像+起栈, 不含门户)
#   pwsh -File scripts/deploy-wslc.ps1 -SkipPull       # 跳过镜像拉取(本地已有镜像)
#   pwsh -File scripts/deploy-wslc.ps1 -StopOldStack   # 先停旧栈(端口冲突时用)
#   pwsh -File scripts/deploy-wslc.ps1 -WithPortal    # 额外构建并启动注册门户
#
# 前置:
#   - docker/.env 已填写 (参考 docker/.env.example)
#   - 数据目录 WOW_DATA_DIR 存在且含 maps/vmaps/mmaps/dbc/Cameras
#   - 全新库: 先 `docker compose --profile fresh-install run --rm db-import`
#             或 scripts/migrate-mysql.ps1 导入历史 dump
#
# 行为说明:
#   - wow-mysql 默认复用已有容器(数据卷 wow-mysql-data 保留, 不重建);
#     仅当容器不存在时才新建
#   - wow-authserver / wow-worldserver 每次按配置重建(rm -f 后 run)
#   - portal 默认不部署, 需 -WithPortal 才本地构建并起
# =============================================================================
param(
  [switch]$SkipPull,
  [switch]$StopOldStack,
  [switch]$WithPortal,
  [string]$EnvFile = ""
)

$ErrorActionPreference = "Stop"

# 仓库根 = 本脚本所在目录的上一级 (scripts/..)
$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrEmpty($EnvFile)) {
  $EnvFile = Join-Path $repoRoot "docker\.env"
}

# 从 .env 读键值 (简单解析, 不引入额外模块)
function Get-EnvValue([string]$key, [string]$def) {
  if (Test-Path -LiteralPath $EnvFile) {
    $line = Get-Content -LiteralPath $EnvFile |
      Where-Object { $_ -match "^\s*$key\s*=" } |
      Select-Object -First 1
    if ($line) { return ($line -split '=', 2)[1].Trim().Trim('"') }
  }
  return $def
}

$rootPass = Get-EnvValue "WOW_DB_ROOT_PASSWORD" ""
$userPass = Get-EnvValue "WOW_DB_PASSWORD" ""
$dbUser   = Get-EnvValue "WOW_DB_USER" "wow_user"
$dbPort   = Get-EnvValue "WOW_DB_HOST_PORT" "3307"
$dataDir  = Get-EnvValue "WOW_DATA_DIR" "E:\缓存\WOW\GS_Server\datalyf"
$authImg  = Get-EnvValue "WOW_AUTHSERVER_IMAGE" ""
$worldImg = Get-EnvValue "WOW_WORLDSERVER_IMAGE" ""
$dbImg    = Get-EnvValue "WOW_DBIMPORT_IMAGE" ""
$authPort = Get-EnvValue "WOW_AUTH_PORT" "20241"
$worldPort= Get-EnvValue "WOW_WORLD_PORT" "20242"
$serverAddr = Get-EnvValue "WOW_SERVER_ADDR" "127.0.0.1"
$realmName  = Get-EnvValue "WOW_REALM_NAME" "魔兽世界"
$portalTitle= Get-EnvValue "PORTAL_TITLE" "魔兽世界"
$portalPort = Get-EnvValue "PORTAL_PORT" "8081"

if (-not $rootPass -or -not $userPass) { throw ".env 未填数据库密码 (WOW_DB_ROOT_PASSWORD / WOW_DB_PASSWORD)" }
if (-not $authImg -or -not $worldImg) { throw ".env 未填镜像引用 (WOW_AUTHSERVER_IMAGE / WOW_WORLDSERVER_IMAGE)" }
if (-not (Test-Path -LiteralPath $dataDir)) { throw "数据目录不存在: $dataDir" }

# 可选: 停止旧栈 (端口冲突时使用)
if ($StopOldStack) {
  Write-Host "== 停止旧栈 =="
  wslc stop wow-mariadb wow-wowserver wow-portal wow-mysql wow-authserver wow-worldserver 2>$null | Out-Null
}

Write-Host "== 网络与镜像 =="
wslc network inspect wow-net *> $null; if ($LASTEXITCODE -ne 0) { wslc network create wow-net | Out-Null }
if (-not $SkipPull) {
  wslc-mirror pull mysql:8.4 2>&1 | Select-Object -Last 1
  wslc-mirror pull $authImg 2>&1 | Select-Object -Last 1
  wslc-mirror pull $worldImg 2>&1 | Select-Object -Last 1
}

# ---------------------------------------------------------------------------
# MySQL 8.4: 已有容器则复用(卷保留), 不存在才新建
# ---------------------------------------------------------------------------
Write-Host "== MySQL 8.4 =="
wslc inspect wow-mysql *> $null
if ($LASTEXITCODE -eq 0) {
  Write-Host "  复用已有 wow-mysql 容器 (保留 wow-mysql-data 卷)"
  wslc start wow-mysql | Out-Null
} else {
  Write-Host "  wow-mysql 不存在, 新建容器 (卷 wow-mysql-data 首次创建)"
  wslc run -d --name wow-mysql --network wow-net -p "$dbPort`:3306" `
    -e "MYSQL_ROOT_PASSWORD=$rootPass" -v wow-mysql-data:/var/lib/mysql mysql:8.4 | Out-Null
}

Write-Host "  等待 MySQL 就绪 ..."
$ok = $false
for ($i = 0; $i -lt 60; $i++) {
  Start-Sleep -Seconds 3
  $ping = wslc exec wow-mysql mysqladmin ping -uroot -p"$rootPass" --silent 2>$null
  if ($ping -match "mysqld is alive") { $ok = $true; break }
}
if (-not $ok) { throw "MySQL 未就绪, 请查: wslc logs wow-mysql" }
Write-Host "  MySQL ready" -ForegroundColor Green

# ---------------------------------------------------------------------------
# auth / world 公共环境变量与挂载 (4 库 + playerbots 模块库)
# ---------------------------------------------------------------------------
$commonEnv = @(
  "-e", "AC_DISABLE_INTERACTIVE=1",
  "-e", "AC_LOGIN_DATABASE_INFO=wow-mysql;3306;$dbUser;$userPass;acore_auth",
  "-e", "AC_WORLD_DATABASE_INFO=wow-mysql;3306;$dbUser;$userPass;acore_world",
  "-e", "AC_CHARACTER_DATABASE_INFO=wow-mysql;3306;$dbUser;$userPass;acore_characters",
  "-e", "AC_PLAYERBOTSDATABASEINFO=wow-mysql;3306;$dbUser;$userPass;acore_playerbots",
  "-e", "AC_REALMSERVER_PORT=20241",
  "-e", "AC_WORLDSERVER_PORT=20242",
  "-e", "AC_DATA_DIR=/azerothcore/env/dist/data",
  "-e", "AC_LOGS_DIR=/azerothcore/env/dist/logs"
)
$commonVol = @(
  "-v", "wow-config:/azerothcore/env/dist/etc",
  "-v", "wow-logs:/azerothcore/env/dist/logs",
  "-v", "${dataDir}:/azerothcore/env/dist/data:ro"
)

Write-Host "== authserver =="
wslc rm -f wow-authserver 2>$null | Out-Null
wslc run -d --name wow-authserver --network wow-net -p "$authPort`:20241" @commonEnv @commonVol $authImg | Out-Null

Write-Host "== worldserver (启动后自动追平上游 DB 补丁, 首次需数分钟) =="
wslc rm -f wow-worldserver 2>$null | Out-Null
wslc run -d --name wow-worldserver --network wow-net -p "$worldPort`:20242" @commonEnv @commonVol $worldImg | Out-Null

# ---------------------------------------------------------------------------
# 门户: 默认不部署, 仅 -WithPortal 才构建并起
# ---------------------------------------------------------------------------
if ($WithPortal) {
  $portalDir = Join-Path $repoRoot "docker\portal"
  if (-not (Test-Path -LiteralPath $portalDir)) {
    Write-Warning "portal 目录不存在: $portalDir , 跳过门户"
  } else {
    Write-Host "== portal (本地构建 nginx+php) =="
    Push-Location $portalDir
    try {
      wslc build -t wow-portal:latest .
      if ($LASTEXITCODE -ne 0) { throw "portal 镜像构建失败" }
    } finally { Pop-Location }
    wslc rm -f wow-portal 2>$null | Out-Null
    wslc run -d --name wow-portal --network wow-net -p "$portalPort`:80" `
      -e "WOW_DB_HOST=wow-mysql" -e "WOW_DB_PORT=3306" `
      -e "WOW_DB_USER=$dbUser" -e "WOW_DB_PASSWORD=$userPass" `
      -e "WOW_SERVER_ADDR=$serverAddr" -e "WOW_AUTH_PORT=20241" `
      -e "WOW_REALM_NAME=$realmName" -e "PORTAL_TITLE=$portalTitle" `
      wow-portal:latest | Out-Null
  }
} else {
  Write-Host "== portal 跳过 (未加 -WithPortal; 需要时重跑: pwsh -File $PSCommandPath -WithPortal) =="
}

Write-Host ""
Write-Host "== 部署完成 ==" -ForegroundColor Green
Write-Host "  auth  : 127.0.0.1:$authPort"
Write-Host "  world : 127.0.0.1:$worldPort"
Write-Host "  db    : 127.0.0.1:$dbPort (宿主机)"
if ($WithPortal) { Write-Host "  portal: http://127.0.0.1:$portalPort" }
Write-Host "  观察日志: wslc logs -f wow-worldserver  (首次启动应用 SQL 补丁)"
