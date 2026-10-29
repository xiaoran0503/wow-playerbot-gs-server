#!/usr/bin/env bash
# =============================================================================
#  修复 realmlist 表里的 realm 名称编码
#
#  背景：从群晖套件 / 旧版一键包迁移过来的数据库，realmlist.name 往往是
#  双重编码的（UTF-8 字节先被当成 cp1252 解码，再重新编码存回 UTF-8）。
#  表现为客户端 / 日志里 realm 名显示成 "é­”å…½ä¸–ç•Œ" 这种乱码。
#
#  本脚本按"反向一次"的方式还原：存储值 -> utf-8 解码 -> cp1252 编码
#  -> 得到原始字节 -> 按 utf-8 解读 -> 真正的中文名。
#
#  用法：bash scripts/fix-realm-name.sh [mysql客户端路径] [库名]
# =============================================================================
set -euo pipefail

MYSQL="${1:-mysql/bin/mysql.exe}"
DB="${2:-acore_auth}"

echo "== 检查 realmlist.name 编码 =="
"$MYSQL" --default-character-set=utf8mb4 --user=acore --password=acore \
    --host=127.0.0.1 --port=3306 "$DB" \
    -e "SELECT id, name, HEX(name) AS hex FROM realmlist;" 2>/dev/null

python - "$MYSQL" "$DB" <<'PYEOF'
import subprocess
import sys

mysql, db = sys.argv[1], sys.argv[2]


def q(sql, raw=False):
    args = [mysql, "--default-character-set=utf8mb4", "--user=acore",
            "--password=acore", "--host=127.0.0.1", "--port=3306", db, "-N", "-B", "-e", sql]
    out = subprocess.run(args, capture_output=True, text=True, errors="replace")
    return out.stdout if raw else [l for l in out.stdout.splitlines() if l.strip()]


rows = q("SELECT id, HEX(name) FROM realmlist;")
fixed = 0
for line in rows:
    parts = line.split("\t")
    if len(parts) < 2:
        continue
    realm_id, hexname = parts[0], parts[1]
    try:
        stored = bytes.fromhex(hexname)
    except ValueError:
        continue
    try:
        once = stored.decode("utf-8")
        raw = once.encode("cp1252")
        name = raw.decode("utf-8")
    except (UnicodeDecodeError, UnicodeEncodeError):
        print("  realm %s: 编码正常或无法自动还原，跳过" % realm_id)
        continue

    if name == once:
        print("  realm %s: 编码正常，跳过" % realm_id)
        continue

    q("UPDATE realmlist SET name = CONVERT(_binary 0x%s USING utf8mb4) WHERE id = %s;"
      % (raw.hex().upper(), realm_id))
    print("  realm %s: 已还原 -> %s" % (realm_id, name))
    fixed += 1

print()
print("共修复 %d 条。" % fixed)
PYEOF

echo
echo "== 修复后 =="
"$MYSQL" --default-character-set=utf8mb4 --user=acore --password=acore \
    --host=127.0.0.1 --port=3306 "$DB" \
    -e "SELECT id, name FROM realmlist;" 2>/dev/null
