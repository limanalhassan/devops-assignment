#!/usr/bin/env bash
# Run this from inside your clone of your fork.
set -u

# Which folder to check: the one you name, otherwise the folder you are
# standing in (or one above it) if it looks like this exercise, otherwise
# the usual place.
course_root=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)
{ [ -d "$course_root/linux" ] && [ -d "$course_root/git" ]; } || course_root=/nonexistent
looks_like() { [ -d "$1/.git" ] && [ -d "$1/linux" ] && [ -d "$1/git" ]; }
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
else REPO="$PWD"; how="the usual place"; fi
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $REPO ($how)"
echo

if ! git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
  echo "  FAIL  $REPO is not a git repository"
  echo
  echo "  Stand inside your clone of your fork and put a dot on the end of the"
  echo "  command, or put the path to your clone there instead."
  echo
  echo "0 passed, 1 failed"; exit 1
fi
cd "$REPO" || exit 1

origin=$(git remote get-url origin 2>/dev/null || echo "")
upstream=$(git remote get-url upstream 2>/dev/null || echo "")

[ -n "$origin" ]   && ok "remote 'origin' exists"   || no "remote 'origin' is missing"
[ -n "$upstream" ] && ok "remote 'upstream' exists" || no "remote 'upstream' is missing"

if [ -n "$origin" ] && [ -n "$upstream" ]; then
  if [ "$origin" != "$upstream" ]; then
    ok "origin and upstream point at different repositories"
  else
    no "origin and upstream are the same URL, origin should be your fork"
  fi
fi

case "$origin" in
  git@*|ssh://*) ok "origin uses SSH" ;;
  https://*)     no "origin uses HTTPS, the task asked for SSH" ;;
  *)             no "origin URL is not recognisable: $origin" ;;
esac

branch=$(git rev-parse --abbrev-ref HEAD)
if printf '%s' "$branch" | grep -qE '^[a-z0-9-]+/git-05$'; then
  ok "branch '$branch' follows the naming pattern"
else
  no "branch '$branch' does not match <your-name>/git-05 in lowercase"
fi

student="${branch%%/*}"
sub="submissions/$student"
[ -d "$sub" ] && ok "$sub exists" || no "$sub does not exist"
[ -f "$sub/about.md" ] && ok "$sub/about.md exists" || no "$sub/about.md is missing"

if [ -f "$sub/about.md" ] && [ "$(wc -w < "$sub/about.md" | tr -d ' ')" -ge 60 ]; then
  ok "about.md has real content"
elif [ -f "$sub/about.md" ]; then
  no "about.md is too short"
fi

n_linux=$(find "$sub/linux" -name ANSWERS.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$n_linux" -ge 8 ]; then
  ok "$n_linux Linux ANSWERS.md files are in $sub/linux"
else
  no "found $n_linux ANSWERS.md files under $sub/linux, expected 8"
fi
if find "$sub/linux" -name INCIDENT.md 2>/dev/null | grep -q .; then
  ok "the linux/09 incident report is included"
else
  no "INCIDENT.md from linux/09 is not in $sub/linux"
fi

if [ -f "$sub/ANSWERS.md" ] && [ "$(wc -w < "$sub/ANSWERS.md" | tr -d ' ')" -ge 150 ]; then
  ok "ANSWERS.md has been filled in"
elif [ -f "$sub/ANSWERS.md" ]; then
  no "ANSWERS.md is too short, the questions are not answered"
else
  no "$sub/ANSWERS.md is missing"
fi

if git rev-parse --verify --quiet "origin/$branch" >/dev/null; then
  ok "branch has been pushed to origin"
  if [ "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$branch")" ]; then
    ok "the pushed branch is up to date with your local commits"
  else
    no "you have local commits that have not been pushed"
  fi
else
  no "branch has not been pushed to origin"
fi

if git rev-parse --verify --quiet upstream/main >/dev/null; then
  ok "upstream/main has been fetched"
  behind=$(git rev-list --count main..upstream/main 2>/dev/null || echo "?")
  if [ "$behind" = "0" ]; then
    ok "your main is in sync with upstream/main"
  else
    no "your main is $behind commit(s) behind upstream/main"
  fi
else
  no "upstream has never been fetched"
fi

# Work must be on the branch, not committed straight onto main
if git rev-parse --verify --quiet upstream/main >/dev/null; then
  own=$(git rev-list --count upstream/main..main 2>/dev/null || echo 0)
  [ "$own" = "0" ] && ok "no commits were made directly on main" \
                   || no "$own commit(s) were made directly on main instead of the branch"
fi

[ -z "$(git status --porcelain | grep -vE '^\?\? (check|setup)\.sh$')" ] && ok "working tree is clean" \
                                   || no "working tree is not clean"

echo
echo "$pass passed, $fail failed"
echo
echo "Not checked here: the pull request itself, and whether you responded to"
echo "review by pushing to the same branch. Your instructor confirms those."
[ "$fail" -eq 0 ] || exit 1
