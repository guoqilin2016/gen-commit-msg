#!/usr/bin/env bash
set -euo pipefail

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
if [ -z "${branch}" ]; then
  echo "错误：无法获取分支名" 1>&2
  exit 1
fi

key=$(printf '%s' "$branch" | grep -oE '[A-Z]+-[0-9]+' | head -n1 || true)
if [ -z "${key}" ]; then
  echo "错误：分支名不包含工单号（如 SPLOP-123）" 1>&2
  exit 1
fi

diff=$(git diff --unified=0)
if [ -z "${diff}" ]; then
  echo "错误：无改动，无法生成提交信息" 1>&2
  exit 1
fi

names=$(printf '%s\n' "$diff" | awk '
  BEGIN { file=""; line=0 }
  /^\+\+\+ / {
    file=$2
    sub(/^b\//, "", file)
    if (file == "/dev/null") file=""
    next
  }
  /^@@/ {
    # @@ -a,b +c,d @@
    if (match($0, /\+[0-9]+/)) {
      line=substr($0, RSTART+1, RLENGTH-1)
      if (file != "" && file ~ /\.go$/) {
        cmd="test -f \"" file "\""
        if (system(cmd) == 0) {
          cmd="awk -v n=" line " \"NR<=n{if ($0 ~ /^func /) last=$0} END{print last}\" \"" file "\""
          cmd | getline raw
          close(cmd)
          gsub(/^func[[:space:]]+/, "", raw)
          sub(/^\([^)]*\)[[:space:]]+/, "", raw)
          sub(/\(.*/, "", raw)
          if (raw != "") names[raw]=1
        }
      }
    }
    next
  }
  END {
    first=1
    for (n in names) {
      if (!first) printf(",")
      printf("%s", n)
      first=0
    }
    printf("\n")
  }
')

printf "KEY=%s\n" "$key"
printf "NAMES=%s\n" "$names"
printf "DIFF=<<EOF\n"
printf '%s\n' "$diff"
printf "EOF\n"
