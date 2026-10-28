# =============================================================================
# migrate-mysql.ps1 — 数据库迁移: 已有 MariaDB/ACore dump -> 全新 MySQL 8.4 (wslc)
# -----------------------------------------------------------------------------
# 用法:
#   pwsh -File scripts/migrate-mysql.ps1
#   pwsh -File scripts/migrate-mysql.ps1 -DumpPath D:\path\to\dump.sql
#
# 前置:
#   - wslc 可用; 已 wslc-mirror pull mysql:8.4
#   - dump 文件已放在宿主机 (默认 E:\缓存\WOW\_migration\mariadb-acore-full-20261028.sql)
#
# 行为:
#   - 新建 wow-mysql 容器 (卷 wow-mysql-data 若存在会被复用, 不删数据卷)
#   - 容器内流式导入 dump (大文件不走宿主管道)
#   - 重建 wow_user 账号并授权 4 库 (含 acore_playerbots)
#   - 完成后由 worldserver 启动时自动追平上游 SQL 补丁
# =============================================================================
param(
  [string]$DumpPath = "E:\缓存\WOW\_migration\mariadb-acore-full-20261028.sql",
  [string]$EnvFile  = ""
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

$rootPass = Get-EnvValue "WOW_DB_ROOT_PASSWORD" "root-migrate-pass-2026"
$userPass = Get-EnvValue "WOW_DB_PASSWORD" "wow-migrate-pass-2026"
$dbUser   = Get-EnvValue "WOW_DB_USER" "wow_user"
$dbPort   = Get-EnvValue "WOW_DB_HOST_PORT" "3307"

if (-not (Test-Path -LiteralPath $DumpPath)) { throw "dump 不存在: $DumpPath" }
$dumpSize = (Get-Item -LiteralPath $DumpPath).Length / 1MB
Write-Host "dump: $DumpPath ($([math]::Round($dumpSize,1)) MB)"

# dump 所在目录 (容器内挂载为只读)
$dumpDir  = Split-Path -Parent $DumpPath
$dumpName = Split-Path -Leaf $DumpPath

Write-Host "== 1/5 确保网络与 mysql:8.4 镜像 =="
wslc network inspect wow-net *> $null; if ($LASTEXITCODE -ne 0) { wslc network create wow-net | Out-Null }
wslc-mirror pull mysql:8.4 2>&1 | Select-Object -Last 1

Write-Host "== 2/5 启动 MySQL 8.4 (宿主机端口 $dbPort) =="
# 注意: 这里 rm -f 重建容器但保留 wow-mysql-data 卷 (数据不丢)
wslc rm -f wow-mysql 2>$null | Out-Null
wslc run -d --name wow-mysql --network wow-net -p "$dbPort`:3306" `
  -e "MYSQL_ROOT_PASSWORD=$rootPass" -v wow-mysql-data:/var/lib/mysql mysql:8.4 | Out-Null

Write-Host "== 3/5 等待数据库就绪 =="
$ok = $false
for ($i = 0; $i -lt 60; $i++) {
  Start-Sleep -Seconds 3
  $ping = wslc exec wow-mysql mysqladmin ping -uroot -p"$rootPass" --silent 2>$null
  if ($ping -match "mysqld is alive") { $ok = $true; break }
}
if (-not $ok) { throw "MySQL 8.4 60 秒内未就绪, 请查 wslc logs wow-mysql" }

Write-Host "== 4/5 导入 dump (容器内流式, 大文件不走宿主管道) =="
wslc run --rm --network wow-net -v "${dumpDir}:/migrate:ro" mysql:8.4 `
  sh -c "mysql -h wow-mysql -uroot -p'$rootPass' < /migrate/$dumpName"
if ($LASTEXITCODE -ne 0) { throw "导入失败" }

Write-Host "== 5/5 重建 wow_user 账号并授权 (4 库含 playerbots) =="
wslc exec wow-mysql mysql -uroot -p"$rootPass" -e "
CREATE USER IF NOT EXISTS '$dbUser'@'%' IDENTIFIED BY '$userPass';
GRANT ALL PRIVILEGES ON acore_auth.* TO '$dbUser'@'%';
GRANT ALL PRIVILEGES ON acore_characters.* TO '$dbUser'@'%';
GRANT ALL PRIVILEGES ON acore_world.* TO '$dbUser'@'%';
GRANT ALL PRIVILEGES ON acore_playerbots.* TO '$dbUser'@'%';
FLUSH PRIVILEGES;
"

Write-Host "== 校验 =="
wslc exec wow-mysql mysql -uroot -p"$rootPass" -e "
SHOW DATABASES;
SELECT COUNT(*) AS accounts FROM acore_auth.account;
SELECT COUNT(*) AS chars FROM acore_characters.characters;
SELECT COUNT(*) AS creatures FROM acore_world.creature_template;
"
Write-Host "迁移完成。新栈 worldserver 启动后将自动追平上游数据库补丁。" -ForegroundColor Green
