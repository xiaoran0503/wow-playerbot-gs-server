#!/usr/bin/env bash
# =============================================================================
#  组装 Windows 一键成品包
#
#  输入：GitHub Actions 产出的 wow-windows-<date>-<sha8>.zip（wow-server/ 目录）
#        + 本地已有的运行时资源（MySQL 8.4.9 服务端、datalyf 数据、lua_scripts）
#  输出：E:\缓存\WOW\自维护版服务器端\  （完整可运行成品）
#
#  用法：bash scripts/assemble-windows-package.sh <zip路径>
# =============================================================================
set -euo pipefail

ZIP="${1:?用法: assemble-windows-package.sh <zip路径>}"
ROOT="E:/缓存/WOW"
OUT="$ROOT/自维护版服务器端"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "[1/7] 解压 CI 产物..."
unzip -q "$ZIP" -d "$WORK"

PKG="$WORK/wow-server"
[ -d "$PKG" ] || { echo "产物结构异常：找不到 $PKG"; ls -R "$WORK" | head -30; exit 1; }

echo "[2/7] 备份现有成品..."
if [ -d "$OUT" ]; then
  BK="$ROOT/_backup_server_$(date +%Y%m%d_%H%M%S)"
  mv "$OUT" "$BK"
  echo "      已备份到 $BK"
fi
mkdir -p "$OUT"

echo "[3/7] 复制核心程序与运行时 DLL..."
cp -r "$PKG/." "$OUT/"

echo "[4/7] 复制 MySQL 8.4.9 服务端..."
cp -r "$ROOT/_runtime_backup/mysql" "$OUT/mysql"

echo "[5/7] 复制游戏数据（datalyf）与 lua 脚本..."
if [ -d "$ROOT/_runtime_backup/datalyf" ]; then
  cp -r "$ROOT/_runtime_backup/datalyf" "$OUT/datalyf"
fi
if [ -d "$ROOT/_runtime_backup/lua_scripts" ]; then
  cp -r "$ROOT/_runtime_backup/lua_scripts" "$OUT/lua_scripts"
fi

echo "[6/7] 生成运行配置（.conf.dist -> .conf）..."
cp "$OUT/configs/worldserver.conf.dist" "$OUT/configs/worldserver.conf"
cp "$OUT/configs/authserver.conf.dist"  "$OUT/configs/authserver.conf"
mkdir -p "$OUT/configs/modules"
for f in "$OUT/configs/modules/"*.conf.dist; do
  [ -e "$f" ] || continue
  cp "$f" "${f%.dist}"
done

echo "[7/7] 校验产物..."
FAIL=0
for f in worldserver.exe authserver.exe libmysql.dll legacy.dll configs/worldserver.conf configs/authserver.conf; do
  if [ -e "$OUT/$f" ]; then
    printf "      OK   %-32s %s\n" "$f" "$(du -h "$OUT/$f" | cut -f1)"
  else
    printf "      MISS %-32s <== 缺失！\n" "$f"
    FAIL=1
  fi
done
# OpenSSL 3.x 的库名带版本后缀，通配检查
ls "$OUT"/libcrypto-3*.dll "$OUT"/libssl-3*.dll >/dev/null 2>&1 || { echo "      MISS libcrypto-3/libssl-3"; FAIL=1; }
[ "$FAIL" -eq 0 ] && echo "      全部关键文件就位。" || { echo "      产物不完整！"; exit 1; }

echo
echo "成品已就位：$OUT"
