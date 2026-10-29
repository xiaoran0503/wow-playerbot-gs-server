#!/usr/bin/env python3
"""Check that the live database schema matches what the SQL tree defines.

Two angles:

1) Table level - every table the base/update SQL creates must exist in the
   database, and the database must not be missing any of them.
2) Column level - for the tables the newest update files touch, the columns
   those files add must be present.

This is the "is the structure complete" half of the upgrade check; the
"are all updates applied" half lives in verify-db-completeness.py.
"""
import os
import re
import subprocess
import sys

MYSQL = sys.argv[1] if len(sys.argv) > 1 else r"X:\mysql\bin\mysql.exe"
ROOT = sys.argv[2] if len(sys.argv) > 2 else r"E:\缓存\WOW\自维护版服务器端"

DBS = [
    ("acore_auth", os.path.join(ROOT, "data", "sql", "base", "db_auth"),
     os.path.join(ROOT, "data", "sql", "updates", "db_auth")),
    ("acore_characters", os.path.join(ROOT, "data", "sql", "base", "db_characters"),
     os.path.join(ROOT, "data", "sql", "updates", "db_characters")),
    ("acore_world", os.path.join(ROOT, "data", "sql", "base", "db_world"),
     os.path.join(ROOT, "data", "sql", "updates", "db_world")),
    ("acore_playerbots",
     os.path.join(ROOT, "modules", "mod-playerbots", "data", "sql", "playerbots", "base"),
     os.path.join(ROOT, "modules", "mod-playerbots", "data", "sql", "playerbots", "updates")),
]


def mysql(db, sql):
    out = subprocess.run(
        [MYSQL, "--default-character-set=utf8mb4", "--user=acore", "--password=acore",
         "--host=127.0.0.1", "--port=3306", db, "-N", "-B", "-e", sql],
        capture_output=True, text=True, errors="replace")
    return [l for l in out.stdout.splitlines() if l.strip()]


def sql_files(d):
    if not os.path.isdir(d):
        return []
    return [os.path.join(d, f) for f in sorted(os.listdir(d)) if f.lower().endswith(".sql")]


CREATE_TABLE = re.compile(
    r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?`?([A-Za-z0-9_]+)`?", re.IGNORECASE)
# ALTER TABLE ... ADD COLUMN `x`  -- must not match ADD INDEX / ADD KEY / ADD UNIQUE
ALTER_ADD = re.compile(
    r"ALTER\s+TABLE\s+`?([A-Za-z0-9_]+)`?\s+ADD\s+(COLUMN\s+)?`?([A-Za-z0-9_]+)`?",
    re.IGNORECASE)
ADD_KEYWORDS = {"index", "key", "unique", "primary", "foreign", "constraint", "fulltext", "spatial"}
# A table that a later update file drops on purpose is not a missing table.
DROP_TABLE = re.compile(
    r"DROP\s+TABLE\s+(?:IF\s+EXISTS\s+)?`?([A-Za-z0-9_]+)`?", re.IGNORECASE)


def tables_in_sql(files):
    """Tables a base file creates."""
    tables = set()
    for f in files:
        try:
            txt = open(f, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for m in CREATE_TABLE.finditer(txt):
            tables.add(m.group(1))
    return tables


def dropped_tables(files):
    """Tables an update file drops on purpose."""
    out = set()
    for f in files:
        try:
            txt = open(f, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for m in DROP_TABLE.finditer(txt):
            out.add(m.group(1))
    return out


def added_columns(files):
    """(table, column) pairs that update files add."""
    out = set()
    for f in files:
        try:
            txt = open(f, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for m in ALTER_ADD.finditer(txt):
            table, has_column_kw, name = m.group(1), m.group(2), m.group(3)
            # "ADD INDEX foo (...)" / "ADD KEY foo" name a key, not a column.
            if not has_column_kw and name.lower() in ADD_KEYWORDS:
                continue
            out.add((table, name))
    return out


def main():
    print("=" * 78)
    print("AzerothCore 数据库结构完整性核验")
    print("角度 1：base SQL 里 CREATE TABLE 的表是否都存在")
    print("角度 2：update SQL 里 ADD COLUMN 的列是否都存在")
    print("=" * 78)

    problems = 0
    for db, base_dir, upd_dir in DBS:
        print()
        print("### %s" % db)

        base_files = sql_files(base_dir)
        upd_files = sql_files(upd_dir)
        if not base_files:
            print("  [!] base 目录缺失: %s" % base_dir)
            problems += 1
            continue

        want_tables = tables_in_sql(base_files)
        intentionally_dropped = dropped_tables(upd_files)
        have = set(mysql(db, "SELECT table_name FROM information_schema.tables "
                             "WHERE table_schema = '%s';" % db))
        missing = sorted(want_tables - have - intentionally_dropped)
        dropped = sorted((want_tables - have) & intentionally_dropped)
        print("  base 定义的表 : %d" % len(want_tables))
        print("  库中实际表     : %d" % len(have))
        if dropped:
            print("  [已按更新移除] %d 个: %s" % (len(dropped), ", ".join(dropped[:6])))
        if missing:
            print("  [缺失表] %d 个:" % len(missing))
            for t in missing[:10]:
                print("        - %s" % t)
            if len(missing) > 10:
                print("        ... 共 %d 个" % len(missing))
            problems += len(missing)
        else:
            print("  [OK] base 表全部存在（或已被官方更新主动移除）")

        want_cols = added_columns(upd_files)
        if want_cols:
            missing_cols = []
            for tbl, col in sorted(want_cols):
                r = mysql(db, "SELECT COUNT(*) FROM information_schema.columns "
                              "WHERE table_schema='%s' AND table_name='%s' AND column_name='%s';"
                              % (db, tbl, col))
                if not r or r[0] == "0":
                    missing_cols.append("%s.%s" % (tbl, col))
            if missing_cols:
                print("  [缺失列] %d 个: %s" % (len(missing_cols), ", ".join(missing_cols[:8])))
                problems += len(missing_cols)
            else:
                print("  [OK] update 新增列全部就位（检查了 %d 个）" % len(want_cols))

    print()
    print("=" * 78)
    if problems == 0:
        print("结论：四个数据库的表结构与列结构均完整，与 SQL 树定义一致。")
    else:
        print("结论：发现 %d 处结构缺失，需要补跑对应的 base/update SQL。" % problems)
    print("=" * 78)


if __name__ == "__main__":
    main()
