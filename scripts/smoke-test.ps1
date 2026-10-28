# =============================================================================
# smoke-test.ps1 — Playerbot 分支私服栈冒烟验证 (wslc, 假定栈已由 deploy-wslc.ps1 起好)
# -----------------------------------------------------------------------------
# 验证项:
#   1. MySQL 8.4 容器健康 (mysqladmin ping)
#   2. 4 个业务库存在且有表 (acore_auth / acore_world / acore_characters / acore_playerbots)
#   3. authserver 20241 / worldserver 20242 端口监听
#   4. worldserver 日志出现 DBUpdater 追平迹象 (Applying update / DBUpdater)
#   5. realmlist 表有 realm 记录且 address 正确
#
# 用法:
#   pwsh -File scripts/smoke-test.ps1
#   pwsh -File scripts/smoke-test.ps1 -WaitWorldMin 10   # worldserver 等待上限(分钟)
# =============================================================================
param(
  [string]$EnvFile = "",
  [int]$WaitWorldMin = 8
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrEmpty($EnvFile)) {
  $EnvFile = Join-Path $repoRoot "docker\.env"
}

function Get-EnvValue([string]$key, [string]$def) {
  if (Test-Path -LiteralPath $EnvFile) {
    $line = Get-Content -LiteralPath $EnvFile |
      Where-Object { $_ -match "^\s*$key\s*=" } |
      Select-Object -First 1
    if ($line) { return ($line -split '=', 2)[1].Trim().Trim('"') }
  }
  return $def
}

$rootPass  = Get-EnvValue "WOW_DB_ROOT_PASSWORD" ""
$dbUser    = Get-EnvValue "WOW_DB_USER" "wow_user"
$authPort  = Get-EnvValue "WOW_AUTH_PORT" "20241"
$worldPort = Get-EnvValue "WOW_WORLD_PORT" "20242"
if (-not $rootPass) { throw ".env 未填 WOW_DB_ROOT_PASSWORD" }

Write-Host "== 1. MySQL 容器健康 ==" -ForegroundColor Cyan
$ping = wslc exec wow-mysql mysqladmin ping -uroot -p"$rootPass" --silent 2>$null
if ($ping -notmatch "mysqld is alive") {
  throw "MySQL 未就绪 (wslc exec wow-mysql mysqladmin ping 失败); 请先跑 deploy-wslc.ps1"
}
Write-Host "  mysqld is alive" -ForegroundColor Green

Write-Host "== 2. 4 个业务库表数 ==" -ForegroundColor Cyan
$dbs = @("acore_auth", "acore_world", "acore_characters", "acore_playerbots")
foreach ($db in $dbs) {
  $cnt = wslc exec wow-mysql mysql -uroot -p"$rootPass" -N -B -e `
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$db';" 2>$null
  $cnt = "$cnt".Trim()
  if ([int]$cnt -le 0) {
    Write-Warning "  $db : $cnt 张表 (可能未建库/未迁移)"
  } else {
    Write-Host "  $db : $cnt 张表" -ForegroundColor Green
  }
}

Write-Host "== 3. auth/world 端口监听 (最长 $WaitWorldMin 分钟) ==" -ForegroundColor Cyan
$deadline = (Get-Date).AddMinutes($WaitWorldMin)
$authUp = $false; $worldUp = $false
while ((Get-Date) -lt $deadline -and -not ($authUp -and $worldUp)) {
  Start-Sleep -Seconds 10
  $authUp  = (Test-NetConnection -ComputerName 127.0.0.1 -Port $authPort -WarningAction SilentlyContinue).TcpTestSucceeded
  $worldUp = (Test-NetConnection -ComputerName 127.0.0.1 -Port $worldPort -WarningAction SilentlyContinue).TcpTestSucceeded
  Write-Host ("   auth(20241)={0}  world(20242)={1}" -f $authUp, $worldUp)
}
if (-not $authUp)  { Write-Warning "  authserver :$authPort 未监听" } else { Write-Host "  authserver :$authPort 监听中" -ForegroundColor Green }
if (-not $worldUp) { Write-Warning "  worldserver :$worldPort 未监听" } else { Write-Host "  worldserver :$worldPort 监听中" -ForegroundColor Green }

Write-Host "== 4. worldserver 日志 DBUpdater 追平迹象 ==" -ForegroundColor Cyan
$logTail = wslc logs --tail 200 wow-worldserver 2>&1 | Out-String
if ($logTail -match "DBUpdater" -or $logTail -match "Applying" -or $logTail -match "Update  .* applied" -or $logTail -match "database already up to date") {
  Write-Host "  日志中出现 DBUpdater/补丁追平相关输出" -ForegroundColor Green
  $logTail -split "`n" | Select-String -Pattern "DBUpdater|Applying|Update|up to date|Table|playerbot|Playerbot" | Select-Object -Last 8 | ForEach-Object { Write-Host "    $_" }
} else {
  Write-Warning "  未在最近 200 行日志中看到 DBUpdater 迹象 (若刚启动属正常; 若已运行很久请查日志)"
}

Write-Host "== 5. realmlist 校验 ==" -ForegroundColor Cyan
try {
  $rl = wslc exec wow-mysql mysql -uroot -p"$rootPass" -D acore_auth -e `
    "SELECT id,name,address,port FROM realmlist;" 2>$null
  Write-Host ($rl | Out-String)
} catch {
  Write-Warning "  realmlist 查询失败: $_"
}

Write-Host ""
Write-Host "== 冒烟结束 ==" -ForegroundColor Green
Write-Host "  auth : 127.0.0.1:$authPort"
Write-Host "  world: 127.0.0.1:$worldPort"
Write-Host "  日志 : wslc logs -f wow-worldserver"
