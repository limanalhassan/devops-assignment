#!/usr/bin/env bash
set -u

# Which folder to check: the one you name, otherwise the folder you are
# standing in (or one above it) if it looks like this exercise, otherwise
# the usual place.
course_root=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)
{ [ -d "$course_root/linux" ] && [ -d "$course_root/git" ]; } || course_root=/nonexistent
looks_like() { grep -qx linux/02 "$1/.course-exercise" 2>/dev/null || [ -d "$1/downloads" ] || [ -d "$1/organised" ]; }
pick_here() {
  local d="$PWD" i
  for i in 1 2 3 4; do
    case "$d" in "$course_root"|"$course_root"/*) return 1 ;; esac
    if looks_like "$d"; then printf '%s\n' "$d"; return 0; fi
    [ "$d" = / ] && return 1
    d=$(dirname "$d")
  done
  return 1
}
if [ $# -ge 1 ]; then WORK="$1"; how="the folder you named"
elif WORK=$(pick_here); then how="the folder you are in"
else WORK="$HOME/devops-course/linux/02-files"; how="the usual place"; fi
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $WORK ($how)"
echo

if [ ! -d "$WORK" ]; then
  echo "  FAIL  there is no folder at $WORK"
  echo
  echo "  Run setup.sh first. If your work is somewhere else, go into that"
  echo "  folder and run the checker from there, or put its path on the end."
  echo
  echo "0 passed, 1 failed"; exit 1
fi
cd "$WORK" || exit 1

O=organised
for d in images logs configs documents; do
  [ -d "$O/$d" ] && ok "$O/$d exists" || no "$O/$d is missing"
done

n=$(find "$O/images" -maxdepth 1 -name '*.jpg' 2>/dev/null | wc -l | tr -d ' ')
[ "$n" = "12" ] && ok "all 12 photos are in $O/images" || no "$O/images has $n photos, expected 12"
left=$(find downloads -name '*.jpg' 2>/dev/null | wc -l | tr -d ' ')
[ "$left" = "0" ] && ok "no photos left in downloads" || no "$left photos are still in downloads"

n=$(find "$O/logs" -maxdepth 1 -name 'app-*.log' 2>/dev/null | wc -l | tr -d ' ')
[ "$n" = "6" ] && ok "all 6 app logs are in $O/logs" || no "$O/logs has $n app logs, expected 6"
[ -f "$O/logs/access.log" ] && ok "access.log is in $O/logs" || no "access.log is not in $O/logs"

for f in nginx.conf app.yaml .env.example; do
  [ -f "$O/configs/$f" ] && ok "$f is in $O/configs" || no "$f is not in $O/configs"
done

[ -f "$O/documents/Quarterly Report FINAL (2).pdf" ] \
  && ok "the quarterly report is in $O/documents" \
  || no "the quarterly report is not in $O/documents"

[ -e downloads/unused ] && no "downloads/unused still exists" || ok "downloads/unused has been removed"

t=$(find . -name '*.tmp' 2>/dev/null | wc -l | tr -d ' ')
[ "$t" = "0" ] && ok "every .tmp file is gone" || no "$t .tmp files remain"

for f in downloads/old_projects/project-a/src/main.py downloads/old_projects/project-b/README.md \
         downloads/old_projects/project-b/notes/.api_key; do
  [ -f "$f" ] && ok "$f was left alone" || no "$f is missing, something other than .tmp files was deleted or moved"
done

if [ -d backup/organised ]; then
  if diff -r "$O" backup/organised >/dev/null 2>&1; then
    ok "backup/organised is identical to organised"
  else
    no "backup/organised differs from organised"
  fi
else
  no "backup/organised is missing"
fi

if [ -L latest.log ]; then
  ok "latest.log is a symbolic link"
  target=$(readlink -f latest.log)
  if [ "$target" = "$WORK/$O/logs/app-2026-09-06.log" ]; then
    ok "latest.log points at the newest log"
  else
    no "latest.log points at $target"
  fi
else
  no "latest.log is missing or is not a symbolic link"
fi

if [ -f ANSWERS.md ]; then
  lines=$(wc -l < "$O/logs/access.log" 2>/dev/null | tr -d ' ')
  if [ -n "$lines" ] && grep -q "$lines" ANSWERS.md; then
    ok "ANSWERS.md has the correct line count for access.log"
  else
    no "ANSWERS.md does not contain the correct line count for access.log"
  fi
  grep -q "old_projects/project-b/notes/.api_key" ANSWERS.md \
    && ok "ANSWERS.md has the path to .api_key" \
    || no "ANSWERS.md does not contain the full path to .api_key"
  w=$(wc -w < ANSWERS.md | tr -d ' ')
  [ "$w" -ge 120 ] && ok "ANSWERS.md questions have been answered" \
                   || no "ANSWERS.md has $w words, the questions are not answered"
else
  no "ANSWERS.md is missing"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
