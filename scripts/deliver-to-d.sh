#!/usr/bin/env bash
# =============================================================================
#  把 Windows 一键成品交付到 D:\wow_server
#
#  用法：bash scripts/deliver-to-d.sh <CI产出的zip路径>
#
#  步骤：
#    1) 解压 CI 产物（worldserver.exe / authserver.exe / 运行时 DLL / configs）
#    2) 合入本地运行时资源（MySQL 8.4.9 服务端、datalyf 客户端数据、lua_scripts）
#    3) 生成可用的 .conf（从 .conf.dist 复制）
#    4) 关键文件自检
#    5) 启动测试（authserver + worldserver），收集日志
# =============================================================================
set -euo pipefail

ZIP="${1:?用法: deliver-to-d.sh <zip路径>}"
ROOT="E:/缓存/WOW"
OUT="D:/wow_server"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

say() { printf '\n[%s] %s\n' "$1" "$2"; }

say 1/6 "解压 CI 产物：$ZIP"
unzip -q "$ZIP" -d "$WORK"
PKG="$WORK/wow-server"
[ -d "$PKG" ] || { echo "产物结构异常"; ls -R "$WORK" | head -30; exit 1; }

say 2/6 "准备目标目录 $OUT"
mkdir -p "$OUT"

say 3/6 "复制核心程序与运行时 DLL"
cp -r "$PKG/." "$OUT/"

say 4/6 "合入本地运行时资源（MySQL / datalyf / lua_scripts / data / modules）"
# 大目录（datalyf 约 7GB）用 junction 指向 E 盘的运行时备份，
# 避免重复占用磁盘；junction 对服务端完全透明。
link_or_copy() {
  local name="$1" src="$2"
  if [ -d "$src" ]; then
    if [ -e "$OUT/$name" ]; then rm -rf "$OUT/$name" 2>/dev/null || true; fi
    if command -v cmd >/dev/null 2>&1 && cmd //c "mklink /J \"$(cygpath -w "$OUT/$name")\" \"$(cygpath -w "$src")\"" >/dev/null 2>&1; then
      echo "      $name -> junction -> $src"
    else
      cp -r "$src" "$OUT/$name"
      echo "      $name -> copied from $src"
    fi
  fi
}
link_or_copy mysql       "$ROOT/_runtime_backup/mysql"
link_or_copy datalyf     "$ROOT/_runtime_backup/datalyf"
link_or_copy lua_scripts "$ROOT/_runtime_backup/lua_scripts"
# data/ 与 modules/ 跟随代码仓库的最新状态
link_or_copy data        "$ROOT/wow-playerbot-server/data"
link_or_copy modules     "$ROOT/wow-playerbot-server/modules"

say 5/6 "生成运行配置"
cp -f "$OUT/configs/worldserver.conf.dist" "$OUT/configs/worldserver.conf" 2>/dev/null || true
cp -f "$OUT/configs/authserver.conf.dist"  "$OUT/configs/authserver.conf"  2>/dev/null || true
mkdir -p "$OUT/configs/modules"
for f in "$OUT/configs/modules/"*.conf.dist; do
  [ -e "$f" ] || continue
  cp -f "$f" "${f%.dist}"
done

say 6/6 "关键文件自检"
FAIL=0
check() {
  if [ -e "$OUT/$1" ]; then
    printf '      OK   %-34s %s\n' "$1" "$(du -h "$OUT/$1" 2>/dev/null | cut -f1)"
  else
    printf '      MISS %-34s <== 缺失！\n' "$1"; FAIL=1
  fi
}
for f in worldserver.exe authserver.exe libmysql.dll legacy.dll \
         configs/worldserver.conf configs/authserver.conf \
         mysql/bin/mysql.exe mysql/bin/mysqld.exe; do
  check "$f"
done
ls "$OUT"/libcrypto-3*.dll "$OUT"/libssl-3*.dll >/dev/null 2>&1 || { echo "      MISS libcrypto-3/libssl-3"; FAIL=1; }
[ -d "$OUT/data/sql/updates/db_world" ] || { echo "      MISS data/sql/updates/db_world"; FAIL=1; }
[ -d "$OUT/datalyf/maps" ] || { echo "      MISS datalyf/maps"; FAIL=1; }

if [ "$FAIL" -ne 0 ]; then
  echo; echo "自检未通过，交付中止。"; exit 1
fi

echo
echo "================================================================"
echo " 成品已交付到：$OUT"
echo "================================================================"
echo " 启动顺序："
echo "   1) 双击 启动mysql.bat            （启动数据库）"
echo "   2) 双击 authserver.exe           （认证服务）"
echo "   3) 双击 worldserver.exe          （世界服务）"
echo " 停止：双击 停止服务器.bat"
echo " 日志：Server.log / Auth.log / Errors.log / logs\\"
