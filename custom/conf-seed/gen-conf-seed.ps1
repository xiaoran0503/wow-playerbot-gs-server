# gen-conf-seed.ps1 — 从模块 dist + 谷神汉化配置生成套件私有配置种子
# 用法: powershell -File gen-conf-seed.ps1   (PS 5.1; 在本目录 custom/conf-seed 下运行)
# 产物: custom/conf-seed/etc/  (worldserver.conf / authserver.conf / modules/*.conf)
# 原则:
#   1. playerbots.conf 做键名迁移: 谷神 AiPlayerbot.X -> 基线 Playerbots.X, 保留谷神中文注释与调优值;
#      谷神没有的新键保留模块默认值; 连接串/端口类由 docker env (AC_*) 接管, 不写死.
#   2. 其余模块: 从模块 dist 起, 只替换已存在的私有键, 未命中打印警告.
#   3. worldserver/authserver: 从上游 dist 起, 回填 wow-private 已定私有值.
# 注意: 所有产物写为 UTF-8 无 BOM.
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$outDir   = Join-Path $PSScriptRoot "etc"
$modOut   = Join-Path $outDir "modules"
New-Item -ItemType Directory -Force -Path $modOut | Out-Null

function Write-Utf8NoBom([string]$path, [string[]]$lines) {
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllLines($path, [string[]]$lines, $enc)
}

# ============================================================================
# Part 1: playerbots.conf — 谷神 AiPlayerbot.* -> 基线 Playerbots.* 迁移
# ============================================================================
function Build-PlayerbotsSeed {
  $gsPath   = "E:\缓存\WOW\.wow-build-tmp\gs-configs\playerbots.conf=UTF-8.dist"
  $basePath = Join-Path $repoRoot "modules\mod-playerbots\conf\playerbots.conf.dist"
  $outPath  = Join-Path $modOut "playerbots.conf"

  $gsLines  = Get-Content -LiteralPath $gsPath -Encoding UTF8
  $baseLines = Get-Content -LiteralPath $basePath -Encoding UTF8

  # --- 1a. 解析谷神: newKey -> @{ comments=[...]; value='...' } ---
  # 归一化: AiPlayerbot.X / AIPlayerbot.X(谷神笔误大写I) -> Playerbots.X; 其余同名键直接保留
  $gsMap = [ordered]@{}
  for ($i = 0; $i -lt $gsLines.Count; $i++) {
    $line = $gsLines[$i]
    if ($line -match '^\s*([A-Za-z0-9_.]+)\s*=\s*(.*)$') {
      $oldKey = $Matches[1]; $val = $Matches[2]
      $newKey = $null
      if ($oldKey -match '^(?:Ai|AI)Playerbot\.(.+)$') { $newKey = "Playerbots." + $Matches[1] }
      else { $newKey = $oldKey }   # PlayerbotsDatabaseInfo / PlayerbotsDatabase.* / Playerbots.Updates.*
      # 收集该键上方紧邻的中文注释块(连续 # 行, 遇空行停止)
      $comments = New-Object System.Collections.Generic.List[string]
      $j = $i - 1
      while ($j -ge 0 -and $gsLines[$j] -match '^\s*#') { [void]$comments.Add($gsLines[$j]); $j-- }
      $comments.Reverse()
      $gsMap[$newKey] = @{ comments = $comments.ToArray(); value = $val; oldKey = $oldKey }
    }
  }

  # --- 1b. 基线键集合 ---
  $baseKeys = @{}
  foreach ($l in $baseLines) { if ($l -match '^\s*([A-Za-z0-9_.]+)\s*=\s*(.*)$') { $baseKeys[$Matches[1]] = $Matches[2] } }

  # --- 1c. 不覆盖取值的键(决策见 KEYMAP-REPORT) ---
  $noOverride = @(
    'Playerbots.Updates.EnableDatabases',  # 谷神=0(生产手动管schema); 全新部署需 mod DBUpdater 首启追平 -> 保留基线 1
    'PlayerbotsDatabaseInfo'                # 连接串由 docker env AC_PLAYERBOTSDATABASEINFO 接管
  )

  # --- 1d. 行走基线行生成输出 ---
  $out = New-Object System.Collections.Generic.List[string]
  [void]$out.Add('# =============================================================================')
  [void]$out.Add('# playerbots.conf — 套件私有种子(由 gen-conf-seed.ps1 自动生成, 请勿手改本文件)')
  [void]$out.Add('# 基线: modules/mod-playerbots/conf/playerbots.conf.dist (894 键)')
  [void]$out.Add('# 取值: 谷神 AiPlayerbot.* 调优值按同名映射为 Playerbots.*, 中文注释随行;')
  [void]$out.Add('#       谷神未覆盖的新键保留基线默认值; 连接串/端口由 docker env 接管.')
  [void]$out.Add('# 映射明细: custom/conf-seed/KEYMAP-REPORT.md')
  [void]$out.Add('# =============================================================================')
  [void]$out.Add('')

  $i = 0
  $mappedCount = 0; $valueDiffCount = 0
  $valueDiffs = New-Object System.Collections.Generic.List[string]
  while ($i -lt $baseLines.Count) {
    $line = $baseLines[$i]
    if ($line -match '^\s*([A-Za-z0-9_.]+)\s*=\s*(.*)$') {
      $key = $Matches[1]; $baseVal = $Matches[2]
      if ($gsMap.Contains($key)) {
        $g = $gsMap[$key]
        $mappedCount++
        # 决定取值
        if ($noOverride -contains $key) { $emitVal = $baseVal.Trim() } else { $emitVal = $g.value.Trim() }
        if ($emitVal -ne $baseVal.Trim()) {
          $valueDiffCount++
          [void]$valueDiffs.Add(("{0} : 基线[{1}] -> 谷神[{2}]" -f $key, $baseVal.Trim(), $emitVal))
        }
        # 输出(谷神中文注释块, 若有)
        if ($g.comments.Count -gt 0) { foreach ($c in $g.comments) { [void]$out.Add($c) } }
        [void]$out.Add(("{0} = {1}" -f $key, $emitVal))
        [void]$out.Add('')
        $i++
        # 吃掉基线紧随的空行, 避免双空行
        if ($i -lt $baseLines.Count -and $baseLines[$i] -match '^\s*$') { $i++ }
      } else {
        [void]$out.Add($line); $i++
      }
    } else {
      [void]$out.Add($line); $i++
    }
  }

  Write-Utf8NoBom $outPath $out.ToArray()

  # --- 1e. 未映射谷神键清单 ---
  $unmapped = New-Object System.Collections.Generic.List[string]
  foreach ($k in $gsMap.Keys) { if (-not $baseKeys.ContainsKey($k)) { [void]$unmapped.Add(("{0}  (谷神原键 {1})" -f $k, $gsMap[$k].oldKey)) } }

  Write-Host "[playerbots] 输出: $outPath"
  Write-Host ("[playerbots] 映射键数: {0} (其中取值与基线不同: {1}); 未映射谷神键: {2}" -f $mappedCount, $valueDiffCount, $unmapped.Count)
  return @{
    mapped = $mappedCount; valueDiffs = $valueDiffs.ToArray(); unmapped = $unmapped.ToArray(); outPath = $outPath
  }
}

# --- 执行 playerbots 迁移, 收集映射报告数据 ---
$pb = Build-PlayerbotsSeed

# ============================================================================
# Part 2: 其余模块 — dist + 私有键值回填
# ============================================================================
$private = @{
  "mod_ahbot" = @{
    "AuctionHouseBot.EnableSeller" = "0"; "AuctionHouseBot.EnableBuyer" = "0";
    "AuctionHouseBot.Account" = "0"; "AuctionHouseBot.GUID" = "0"; "AuctionHouseBot.ItemsPerCycle" = "200";
    "AuctionHouseBot.ConsiderOnlyBotAuctions" = "0"; "AuctionHouseBot.DuplicatesCount" = "0";
    "AuctionHouseBot.DivisibleStacks" = "0"; "AuctionHouseBot.VendorItems" = "0";
    "AuctionHouseBot.VendorTradeGoods" = "0"; "AuctionHouseBot.LootItems" = "1";
    "AuctionHouseBot.LootTradeGoods" = "1"; "AuctionHouseBot.OtherItems" = "0"; "AuctionHouseBot.MarketResetThreshold" = "25"
  }
  "mod_ale" = @{
    "ALE.Enabled" = "true"; "ALE.TraceBack" = "false"; "ALE.ScriptPath" = "lua_scripts";
    "ALE.PlayerAnnounceReload" = "false"; "ALE.RequirePaths" = ""; "ALE.RequireCPaths" = "";
    "ALE.AutoReload" = "false"; "ALE.AutoReloadInterval" = "1"; "ALE.BytecodeCache" = "true";
    "Appender.ALELog" = "2,5,0,ALE.log,w"; "Appender.ALEConsole" = '1,4,0,"0 9 0 3 5 0"';
    "Logger.ALE" = "4,ALELog ALEConsole"
  }
  "mod_boss_announcer" = @{
    "Boss.Announcer.Enable" = "1"; "Boss.Announcer.Announce" = "1"; "Boss.Announcer.RemoveAuraUponKill" = "0"; "Boss.Announcer.AnnounceWipe" = "1"
  }
  "random_enchants" = @{}   # 谷神无对应调优文件, 保留模块默认
  "transmog" = @{
    "Transmogrification.Enable" = "1"; "Transmogrification.ShowSetDisclaimer" = "0";
    "Transmogrification.UseCollectionSystem" = "1"; "Transmogrification.UseVendorInterface" = "0";
    "Transmogrification.AllowHiddenTransmog" = "1"; "Transmogrification.HiddenTransmogIsFree" = "1";
    "Transmogrification.TrackUnusableItems" = "1"; "Transmogrification.RetroActiveAppearances" = "1";
    "Transmogrification.ResetRetroActiveAppearancesFlag" = "0"; "Transmogrification.EnableTransmogInfo" = "1";
    "Transmogrification.TransmogNpcText" = "601083"; "Transmogrification.Allowed" = "";
    "Transmogrification.NotAllowed" = ""; "Transmogrification.EnablePortable" = "1";
    "Transmogrification.EnableSortByQualityAndName" = "1"; "Transmogrification.ScaledCostModifier" = "1.0";
    "Transmogrification.CopperCost" = "0"; "Transmogrification.RequireToken" = "0"; "Transmogrification.TokenEntry" = "49426";
    "Transmogrification.TokenAmount" = "1"; "Transmogrification.AllowPoor" = "0"; "Transmogrification.AllowCommon" = "0";
    "Transmogrification.AllowUncommon" = "1"; "Transmogrification.AllowRare" = "1"; "Transmogrification.AllowEpic" = "1"
  }
}

function Apply-Private([string]$distPath, [string]$seedPath, [hashtable]$kv, [string]$tag) {
  if (-not (Test-Path -LiteralPath $distPath)) { Write-Warning "[$tag] dist 不存在: $distPath"; return }
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.AddRange([string[]](Get-Content -LiteralPath $distPath -Encoding UTF8))
  $missing = @()
  foreach ($k in $kv.Keys) {
    $pattern = '^(\s*' + [regex]::Escape($k) + '\s*=\s*)(.*)$'
    $hit = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
      if ($lines[$i] -match $pattern) {
        $val = $kv[$k]; $origVal = $Matches[2]
        if ($origVal -match '^\s*"' -and $val -notmatch '^"') { $val = '"' + $val + '"' }
        $lines[$i] = $Matches[1] + $val; $hit = $true; break
      }
    }
    if (-not $hit) { $missing += $k }
  }
  Write-Utf8NoBom $seedPath $lines.ToArray()
  Write-Host "[$tag] 已生成: $seedPath"
  if ($missing.Count -gt 0) { Write-Warning "[$tag] 未命中键: $($missing -join ', ')" }
}

# 模块 dist 位置表 (repo 模块目录 -> dist 文件名)
$modDist = @{
  "mod_ahbot"         = "mod-ah-bot\conf\mod_ahbot.conf.dist"
  "mod_ale"           = "mod-ale\conf\mod_ale.conf.dist"
  "mod_boss_announcer"= "mod-boss-announcer\conf\mod_boss_announcer.conf.dist"
  "random_enchants"   = "mod-random-enchants\conf\random_enchants.conf.dist"
  "transmog"          = "mod-transmog\conf\transmog.conf.dist"
}
foreach ($m in $private.Keys) {
  $dist = Join-Path $repoRoot ("modules\" + $modDist[$m])
  $seed = Join-Path $modOut ("$m.conf")
  Apply-Private $dist $seed $private[$m] $m
}

# ============================================================================
# Part 3: worldserver / authserver
# ============================================================================
$wsDist = Join-Path $repoRoot "src\server\apps\worldserver\worldserver.conf.dist"
$wsSeed = Join-Path $outDir "worldserver.conf"
$wsPrivate = @{
  "EnableLoginAfterDC" = "1"; "EnablePlayerSettings" = "0"; "EnableLowLevelRegenBoost" = "1";
  "Updates.Redundancy" = "1"; "Updates.ArchivedRedundancy" = "0"; "Updates.AllowRehash" = "1";
  "Updates.CleanDeadRefMaxCount" = "3"; "Updates.ExceptionShutdownDelay" = "10000"; "MaxPlayerLevel" = "80"
}
Apply-Private $wsDist $wsSeed $wsPrivate "worldserver"

$auDist = Join-Path $repoRoot "src\server\apps\authserver\authserver.conf.dist"
$auSeed = Join-Path $outDir "authserver.conf"
if (Test-Path -LiteralPath $auDist) {
  $auLines = Get-Content -LiteralPath $auDist -Encoding UTF8
  Write-Utf8NoBom $auSeed ([string[]]$auLines)
  Write-Host "[authserver] 已复制 dist 为种子"
}

Write-Host "完成。种子目录: $outDir"
