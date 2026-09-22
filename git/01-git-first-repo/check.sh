#!/usr/bin/env bash
# Checks assignment 01. Run from anywhere.
set -u

# Which folder to check: the one you name, otherwise the folder you are
# standing in (or one above it) if it looks like this exercise, otherwise
# the usual place.
course_root=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)
{ [ -d "$course_root/linux" ] && [ -d "$course_root/git" ]; } || course_root=/nonexistent
looks_like() { [ -d "$1/.git" ]; }
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
if [ $# -ge 1 ]; then REPO="$1"; how="the folder you named"
elif REPO=$(pick_here); then how="the folder you are in"
else REPO="$HOME/devops-course/git/01-first-repo"; how="the usual place"; fi
pass=0; fail=0
ok()  { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no()  { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $REPO ($how)"
echo

if [ ! -d "$REPO" ]; then
  echo "  FAIL  there is no folder at $REPO"
  echo
  echo "  If your work is somewhere else, go into that folder and run the"
  echo "  checker from there, or put the folder's path on the end of the command."
  echo
  echo "0 passed, 1 failed"
  exit 1
fi

cd "$REPO" || exit 1

if git rev-parse --git-dir >/dev/null 2>&1; then
  ok "directory is a git repository"
else
  no "directory is not a git repository"
  echo; echo "$pass passed, $((fail+1)) failed"; exit 1
fi

name=$(git config user.name || true)
email=$(git config user.email || true)
[ -n "$name" ]  && ok "user.name is set ($name)"   || no "user.name is not set"
[ -n "$email" ] && ok "user.email is set ($email)" || no "user.email is not set"
editor=$(git config --global core.editor || true)
[ -n "$editor" ] && ok "core.editor is set ($editor)" || no "core.editor is not set"

count=$(git rev-list --count HEAD 2>/dev/null || echo 0)
[ "$count" -ge 4 ] && ok "history has $count commits" \
                   || no "history has $count commits, at least 4 expected"

# Commit message quality
badsubj=0; dupsubj=0
subjects=$(git log --format=%s)
while IFS= read -r s; do
  [ ${#s} -gt 50 ] && badsubj=$((badsubj+1))
  case "$s" in *.) badsubj=$((badsubj+1));; esac
done <<< "$subjects"
[ "$badsubj" -eq 0 ] && ok "commit subjects are under 50 chars and have no trailing full stop" \
                     || no "$badsubj commit subject(s) are too long or end with a full stop"

uniq_count=$(printf '%s\n' "$subjects" | sort -u | wc -l | tr -d ' ')
total_count=$(printf '%s\n' "$subjects" | wc -l | tr -d ' ')
[ "$uniq_count" = "$total_count" ] && ok "every commit message is distinct" \
                                   || no "some commit messages are repeated"

[ -f notes.md ] && ok "notes.md exists" || no "notes.md is missing"
[ -f ANSWERS.md ] && ok "ANSWERS.md exists" || no "ANSWERS.md is missing"
if [ -f ANSWERS.md ] && [ "$(wc -w < ANSWERS.md | tr -d ' ')" -ge 40 ]; then
  ok "ANSWERS.md has been filled in"
elif [ -f ANSWERS.md ]; then
  no "ANSWERS.md is too short to be a real answer"
fi

[ -f .gitignore ] && ok ".gitignore exists" || no ".gitignore is missing"
[ -f secrets.txt ] && ok "secrets.txt exists on disk" || no "secrets.txt was not created"
[ -f app.log ] && ok "app.log exists on disk" || no "app.log was not created"

git check-ignore -q secrets.txt 2>/dev/null && ok "secrets.txt is ignored" \
                                            || no "secrets.txt is not ignored"
git check-ignore -q app.log 2>/dev/null && ok "app.log is ignored" \
                                        || no "app.log is not ignored"

# Pattern rather than exact filename for logs
: > .check_tmp_debug.log
if git check-ignore -q .check_tmp_debug.log 2>/dev/null; then
  ok "log files are ignored by pattern, not just by name"
else
  no "a new .log file is not ignored, so the rule is not a pattern"
fi
rm -f .check_tmp_debug.log

if git ls-files --error-unmatch secrets.txt >/dev/null 2>&1; then
  no "secrets.txt is tracked, ignoring it after committing does not work"
else
  ok "secrets.txt is not tracked"
fi

if [ -z "$(git status --porcelain | grep -vE '^\?\? (check|setup)\.sh$')" ]; then
  ok "working tree is clean"
else
  no "working tree is not clean, something is uncommitted or unignored"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
