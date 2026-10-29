#!/usr/bin/env bash
# =============================================================================
#  修复/补齐数据库账号与库，使服务端能正常跑起来
#
#  背景：
#   1) 官方 data/sql/create/create_mysql.sql 要求单独建 'acore'@'localhost'
#      并授权 acore_world / acore_characters / acore_auth。从旧套件迁移过来的
#      库通常只有 'acore'@'%'，于是 localhost 的连接拿不到权限，日志里刷
#      "Unhandled MySQL errno 1142 / 1044"。
#   2) custom/lua_scripts/RecruitAFriend.lua 用独立库 ac_eluna 存战友招募数据，
#      脚本自己会 CREATE DATABASE，但 acore 用户没有建库权限。
#
#  用法：bash scripts/fix-db-permissions.sh [mysql客户端路径]
# =============================================================================
set -euo pipefail

MYSQL="${1:-mysql/bin/mysql.exe}"
ROOT_USER="${DB_ROOT_USER:-root}"
ROOT_PASS="${DB_ROOT_PASSWORD:-}"
HOST="${DB_HOST:-127.0.0.1}"
PORT="${DB_PORT:-3306}"

args=(--user="$ROOT_USER" --host="$HOST" --port="$PORT")
[ -n "$ROOT_PASS" ] && args+=(--password="$ROOT_PASS")

run() { "$MYSQL" "${args[@]}" "$@" ; }

echo "== 1/3 按官方 create_mysql.sql 重建 'acore'@'localhost' 并授权 =="
run < "$(dirname "$0")/../data/sql/create/create_mysql.sql" 2>/dev/null \
  || echo "  （create_mysql.sql 执行有告警，可忽略；下面会单独补授权）"

echo "== 2/3 补齐 'acore'@'localhost' 对四个库的权限 =="
run -e "
GRANT ALL PRIVILEGES ON \`acore_world\`.*      TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON \`acore_characters\`.* TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON \`acore_auth\`.*       TO 'acore'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON \`acore_playerbots\`.* TO 'acore'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"

echo "== 3/3 建 ac_eluna 库（RecruitAFriend.lua 用）并授权 =="
run -e "
CREATE DATABASE IF NOT EXISTS \`ac_eluna\` DEFAULT CHARACTER SET UTF8MB4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON \`ac_eluna\`.* TO 'acore'@'%';
GRANT ALL PRIVILEGES ON \`ac_eluna\`.* TO 'acore'@'localhost';
FLUSH PRIVILEGES;
"

echo
echo "== 结果 =="
run -e "SHOW GRANTS FOR 'acore'@'localhost';"
run -e "SHOW DATABASES;"
