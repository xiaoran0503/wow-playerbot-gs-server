#!/usr/bin/env python3
"""Verify AzerothCore database completeness the way the core does.

The core's UpdateFetcher keeps a table `updates` with one row per applied SQL
file (name + hash). On startup it compares that set against the files present
in data/sql/updates/<db>/ and applies whatever is missing.

So "is the database complete" == "is every file on disk already recorded in
`updates`". This script does exactly that comparison for each database and
reports the missing files.
"""
import os
import subprocess
import sys

MYSQL = sys.argv[1] if len(sys.argv) > 1 else r"X:\mysql\bin\mysql.exe"
ROOT = sys.argv[2] if len(sys.argv) > 2 else r"E:\缓存\WOW\自维护版服务器端"

DBS = [
    ("acore_auth", "db_auth"),
    ("acore_characters", "db_characters"),
    ("acore_world", "db_world"),
    ("acore_playerbots", None),  # module db, dir handled separately
]


def mysql(db, sql):
    out = subprocess.run(
        [MYSQL, "--user=acore", "--password=acore", "--host=127.0.0.1",
         "--port=3306", db, "-N", "-B", "-e", sql],
        capture_output=True, text=True, errors="replace")
    return [l for l in out.stdout.splitlines() if l.strip()]


def list_sql(dirpath):
    if not os.path.isdir(dirpath):
        return []
    return sorted(f for f in os.listdir(dirpath) if f.lower().endswith(".sql"))


def main():
    print("=" * 78)
    print("AzerothCore 数据库完整性核验")
    print("判定标准（与核心 UpdateFetcher 一致）：data/sql/updates/<db>/ 下每个 .sql")
    print("文件都已在该库的 updates 表中留有记录。")
    print("=" * 78)

    total_missing = 0
    for db, subdir in DBS:
        # where the update files live
        if db == "acore_playerbots":
            updir = os.path.join(ROOT, "modules", "mod-playerbots", "data", "sql", "playerbots", "updates")
        else:
            updir = os.path.join(ROOT, "data", "sql", "updates", subdir)

        files = list_sql(updir)
        applied = set(mysql(db, "SELECT name FROM updates;"))
        missing = [f for f in files if f not in applied]

        print()
        print("### %s" % db)
        print("  更新目录 : %s" % updir)
        print("  磁盘文件 : %d 个" % len(files))
        print("  updates 表: %d 条已应用记录" % len(applied))
        if not files:
            print("  [!] 更新目录不存在或没有 .sql —— 无法核验")
            total_missing += 1
            continue
        if not missing:
            newest = files[-1]
            print("  [OK] 全部已应用，结构完整。最新的文件: %s" % newest)
        else:
            print("  [缺失] %d 个文件尚未应用:" % len(missing))
            for m in missing[:12]:
                print("        - %s" % m)
            if len(missing) > 12:
                print("        ... 共 %d 个" % len(missing))
            total_missing += len(missing)

    print()
    print("=" * 78)
    if total_missing == 0:
        print("结论：四个数据库的更新记录与磁盘 SQL 文件完全一致，结构完整、无遗漏。")
    else:
        print("结论：共 %d 项待处理（缺失的更新文件）。核心启动时会自动应用它们，"
              "前提是 MySQLExecutable 指向可用的 mysql.exe。" % total_missing)
    print("=" * 78)


if __name__ == "__main__":
    main()
