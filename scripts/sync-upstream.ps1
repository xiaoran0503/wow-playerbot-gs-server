# sync-upstream.ps1 — 同步上游 Playerbot 分支 + 刷新 6 个 vendor 模块 + 重生成 conf-seed
#
# 用法（本机 pwsh 7，在仓库根或任意目录执行均可）：
#   仅本地提交（推荐日常首次使用，push 交给人）：
#     pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/sync-upstream.ps1
#   提交后直接推送到 origin/main：
#     pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/sync-upstream.ps1 -Push
#
# GitHub Actions (sync-upstream.yml) 在 ubuntu runner 上同样调用本脚本，并带 -Push 直通。
#
# remote 约定：
#   upstream = https://github.com/mod-playerbots/azerothcore-wotlk.git （官方 Playerbot 分支）
#   origin   = 自有仓库（尚未配置时 -Push 只会提示并跳过 push）
#
# 本脚本跨平台：Windows 用 PATH 里的 git（兜底 E:\PortableGit），Linux runner 直接用 PATH 的 git。
[CmdletBinding()]
param(
    [switch]$Push   # 带上则提交后 push 到 origin/main；不带则只本地提交（本机默认）
)

$ErrorActionPreference = "Stop"

# --- 0. 定位 git 与仓库根 ---
function Resolve-Git {
    $cmd = Get-Command git -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $fallback = Join-Path "E:\PortableGit" "cmd\git.exe"
    if (Test-Path -LiteralPath $fallback) { return $fallback }
    throw "找不到 git：请安装 git 到 PATH，或确认 $fallback 存在"
}
$git = Resolve-Git

$root = Split-Path $PSScriptRoot -Parent
Push-Location $root
try {
    Write-Host "== 0/4 仓库根：$root =="

    # --- 1/4 拉取上游 Playerbot 分支（depth-1），软重置并入工作区 ---
    # 软重置：上游快照差异进入暂存区，本地私有提交（docker/、custom/、.github 等）保留为新提交
    Write-Host "== 1/4 拉取上游 upstream/Playerbot (depth=1) =="
    $hasUpstream = & $git remote get-url upstream 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $hasUpstream) {
        Write-Warning "未配置 upstream remote，跳过上游合并（仅刷新模块）。可执行: git remote add upstream https://github.com/mod-playerbots/azerothcore-wotlk.git"
    } else {
        & $git fetch upstream Playerbot --depth=1
        if ($LASTEXITCODE -ne 0) { throw "git fetch upstream Playerbot 失败" }
        & $git reset --soft upstream/Playerbot
        if ($LASTEXITCODE -ne 0) { throw "git reset --soft upstream/Playerbot 失败" }
        Write-Host "  已软重置到上游 Playerbot 最新提交"
    }

    # --- 2/4 刷新 6 个 vendor 模块 ---
    # 流程：git clone --depth=1 到临时目录 → 删除 .git → 覆盖 modules/<名>
    # URL/分支写死在这里；模块上游调整时只改这张表。
    #   mod-playerbots 固定 master（与官方 .github/workflows/core-build-playerbots.yml 的分支映射一致）
    #   azerothcore/* 五个模块跟随各自默认分支（不 pin，避免上游改名后拉不到）
    Write-Host "== 2/4 刷新 6 个 vendor 模块 =="
    $mods = @(
        @{ Name = "mod-playerbots";     Url = "https://github.com/mod-playerbots/mod-playerbots.git";   Branch = "master" },
        @{ Name = "mod-ale";            Url = "https://github.com/azerothcore/mod-ale.git";             Branch = $null },
        @{ Name = "mod-ah-bot";         Url = "https://github.com/azerothcore/mod-ah-bot.git";          Branch = $null },
        @{ Name = "mod-transmog";       Url = "https://github.com/azerothcore/mod-transmog.git";        Branch = $null },
        @{ Name = "mod-random-enchants"; Url = "https://github.com/azerothcore/mod-random-enchants.git"; Branch = $null },
        @{ Name = "mod-boss-announcer"; Url = "https://github.com/azerothcore/mod-boss-announcer.git";  Branch = $null }
    )
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("wow-mod-refresh-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    $modulesDir = Join-Path $root "modules"
    foreach ($m in $mods) {
        $src = Join-Path $tmp $m.Name
        if ($m.Branch) {
            & $git clone --depth=1 --branch $m.Branch $m.Url $src
        } else {
            & $git clone --depth=1 $m.Url $src
        }
        if ($LASTEXITCODE -ne 0) { Write-Warning ("模块 {0} 克隆失败，跳过" -f $m.Name); continue }
        Remove-Item -LiteralPath (Join-Path $src ".git") -Recurse -Force
        $dst = Join-Path $modulesDir $m.Name
        if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Recurse -Force }
        Move-Item -LiteralPath $src -Destination $dst
        Write-Host ("  已刷新: {0}" -f $m.Name)
    }
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue

    # --- 3/4 重生成私有配置种子（脚本存在才执行，不存在则跳过） ---
    $genSeed = Join-Path (Join-Path $root "custom") (Join-Path "conf-seed" "gen-conf-seed.ps1")
    if (Test-Path -LiteralPath $genSeed) {
        Write-Host "== 3/4 重新生成 conf-seed =="
        & pwsh -NoProfile -ExecutionPolicy Bypass -File $genSeed
        if ($LASTEXITCODE -ne 0) { throw "gen-conf-seed.ps1 执行失败" }
    } else {
        Write-Host "== 3/4 custom/conf-seed/gen-conf-seed.ps1 不存在，跳过配置种子重生成 =="
    }

    # --- 4/4 收集变更并提交；-Push 时推送 origin/main ---
    Write-Host "== 4/4 提交变更 =="
    & $git add -A
    & $git diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  没有任何变更，无需提交。"
    } else {
        & $git commit -m "chore: sync upstream Playerbot + refresh 6 vendor modules + regen conf-seed"
        if ($LASTEXITCODE -ne 0) { throw "git commit 失败" }
        Write-Host "  已提交。"
    }

    if ($Push) {
        $hasOrigin = & $git remote get-url origin 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $hasOrigin) {
            Write-Warning "未配置 origin remote（自有仓库），跳过 push。请先执行: git remote add origin <自有仓库地址>"
        } else {
            & $git push origin main
            if ($LASTEXITCODE -ne 0) { throw "git push origin main 失败" }
            Write-Host "  已推送到 origin/main，将触发 GitHub Actions build.yml 重新编译。"
        }
    } else {
        Write-Host "  未带 -Push：仅本地提交。确认无误后手动执行: git push origin main"
    }
} finally {
    Pop-Location
}
