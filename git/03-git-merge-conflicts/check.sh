#!/usr/bin/env bash
set -u

REPO="${1:-$HOME/devops-course/git/03-conflicts}"
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $REPO"
echo

if [ ! -d "$REPO" ] || ! git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
  echo "  FAIL  there is no git repository at $REPO"
  echo
  echo "  The checker looks for your work in that exact place. If you built it"
  echo "  somewhere else, put that path on the end of the command."
  echo
  echo "0 passed, 1 failed"; exit 1
fi
cd "$REPO" || exit 1

branch=$(git rev-parse --abbrev-ref HEAD)
[ "$branch" = "main" ] && ok "checked out on main" || no "on branch '$branch', expected main"

if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
  no "a rebase is still in progress"
else
  ok "no rebase left in progress"
fi
if [ -f .git/MERGE_HEAD ]; then
  no "a merge is still in progress"
else
  ok "no merge left in progress"
fi

if git grep -qE '^(<<<<<<<|=======|>>>>>>>)' main -- 2>/dev/null; then
  no "conflict markers are still committed somewhere on main"
else
  ok "no conflict markers anywhere on main"
fi

cfg=$(git show main:config.yml 2>/dev/null || echo "")
if [ -z "$cfg" ]; then
  no "config.yml is not on main"
else
  check_val() {
    if printf '%s\n' "$cfg" | grep -qE "^$1: *$2\s*$"; then
      ok "config.yml has $1: $2"
    else
      got=$(printf '%s\n' "$cfg" | grep -E "^$1:" | head -1)
      no "config.yml should have $1: $2, found '${got:-nothing}'"
    fi
  }
  check_val port 9090
  check_val timeout 60
  check_val workers 4
  check_val retries 3

  dupes=$(printf '%s\n' "$cfg" | grep -cE '^(port|timeout|workers|retries):' || true)
  [ "$dupes" -eq 4 ] && ok "each setting appears exactly once" \
                     || no "expected 4 settings, found $dupes lines, a resolution probably kept both sides"
fi

merges=$(git rev-list --merges --count main 2>/dev/null || echo 0)
if [ "$merges" -eq 1 ]; then
  ok "exactly one merge commit, so part two was rebased not merged"
else
  no "found $merges merge commits on main, expected exactly 1"
fi

if git log --format=%s main | grep -q "Move service to port 9090"; then
  ok "the port change commit is present on main"
else
  no "the port change commit is not on main"
fi

for b in feature/timeouts feature/port-change; do
  if git show-ref --verify --quiet "refs/heads/$b"; then
    no "branch $b still exists"
  else
    ok "branch $b has been deleted"
  fi
done

if [ -f ANSWERS.md ] && [ "$(wc -w < ANSWERS.md | tr -d ' ')" -ge 100 ]; then
  ok "ANSWERS.md has been filled in"
elif [ -f ANSWERS.md ]; then
  no "ANSWERS.md is too short to be a real answer"
else
  no "ANSWERS.md is missing"
fi

[ -z "$(git status --porcelain)" ] && ok "working tree is clean" \
                                   || no "working tree is not clean"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
