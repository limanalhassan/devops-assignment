#!/usr/bin/env bash
set -u

REPO="${1:-$HOME/devops-course/02-branching}"
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $REPO"
echo

if [ ! -d "$REPO" ] || ! git -C "$REPO" rev-parse --git-dir >/dev/null 2>&1; then
  echo "  FAIL  no git repository at $REPO"
  echo; echo "0 passed, 1 failed"; exit 1
fi
cd "$REPO" || exit 1

branch=$(git rev-parse --abbrev-ref HEAD)
[ "$branch" = "main" ] && ok "checked out on main" || no "on branch '$branch', expected main"

for f in README.md logging.md health.md; do
  if git cat-file -e "main:$f" 2>/dev/null; then
    ok "$f is committed on main"
  else
    no "$f is not on main"
  fi
done

if git show main:README.md 2>/dev/null | grep -qi "Not written yet" ; then
  no "README.md still contains placeholder text"
else
  ok "README.md placeholder has been replaced"
fi

merges=$(git rev-list --merges --count main 2>/dev/null || echo 0)
[ "$merges" -ge 1 ] && ok "history contains $merges merge commit(s)" \
                    || no "history contains no merge commits"

total=$(git rev-list --count main 2>/dev/null || echo 0)
[ "$total" -ge 7 ] && ok "main has $total commits" \
                   || no "main has $total commits, at least 7 expected"

for b in feature/install-steps feature/logging feature/health-check; do
  if git show-ref --verify --quiet "refs/heads/$b"; then
    no "branch $b still exists"
  else
    ok "branch $b has been deleted"
  fi
done

# The two parallel branches must have been created from the same commit
if [ "$merges" -ge 1 ]; then
  mc=$(git rev-list --merges main | head -1)
  p1=$(git rev-parse "$mc^1"); p2=$(git rev-parse "$mc^2")
  base=$(git merge-base "$p1" "$p2")
  if [ "$base" != "$p1" ] && [ "$base" != "$p2" ]; then
    ok "the merged branches genuinely diverged"
  else
    no "the merge commit's parents did not diverge, the branches were not created in parallel"
  fi
fi

if [ -f ANSWERS.md ] && [ "$(wc -w < ANSWERS.md | tr -d ' ')" -ge 80 ]; then
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
