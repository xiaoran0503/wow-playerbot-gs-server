#!/usr/bin/env bash
# =============================================================================
#  从 GitHub Actions 下载 Windows 成品包
#
#  用法：bash scripts/fetch-windows-artifact.sh [run_id]
#         不带参数则自动找最近一次成功的 build-windows.yml 运行
# =============================================================================
set -euo pipefail

REPO="xiaoran0503/wow-playerbot-gs-server"
WORKFLOW="build-windows.yml"
DEST="E:/缓存/WOW/_ci_artifacts"
mkdir -p "$DEST"

TOKEN=$(printf "protocol=https\nhost=github.com\n\n" | git credential fill 2>/dev/null | grep '^password=' | cut -d= -f2-)
[ -n "$TOKEN" ] || { echo "拿不到 GitHub 凭据"; exit 1; }

api() { curl -s -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" "$@"; }

RUN="${1:-}"
if [ -z "$RUN" ]; then
  RUN=$(api "https://api.github.com/repos/$REPO/actions/runs?workflow_id=$WORKFLOW&per_page=20" \
        | python -c "
import json,sys
runs=[r for r in json.load(sys.stdin).get('workflow_runs',[]) if r.get('conclusion')=='success']
print(runs[0]['id'] if runs else '')
")
  [ -n "$RUN" ] || { echo "没有找到成功的构建运行"; exit 1; }
fi

echo "使用 run_id = $RUN"

ART_ID=$(api "https://api.github.com/repos/$REPO/actions/runs/$RUN/artifacts" \
         | python -c "
import json,sys
for a in json.load(sys.stdin).get('artifacts',[]):
    if a['name']=='wow-windows':
        print(a['id']); break
")
[ -n "$ART_ID" ] || { echo "该运行没有 wow-windows artifact"; exit 1; }

ZIP="$DEST/wow-windows-$RUN.zip"
echo "下载 artifact $ART_ID ..."
curl -sL -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" \
     "https://api.github.com/repos/$REPO/actions/artifacts/$ART_ID/zip" -o "$ZIP"

echo "已下载: $ZIP ($(du -h "$ZIP" | cut -f1))"
echo
echo "下一步：bash scripts/deliver-to-d.sh \"$ZIP\""
