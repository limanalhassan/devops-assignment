#!/usr/bin/env bash
set -u

REPO="${1:-$HOME/devops-course/git/04-history}"
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

# The bug commit, located by subject so the hash does not have to be hard coded
# exact subject match, otherwise the revert commit's own subject matches too
bug=$(git log --format='%H%x09%s' main | awk -F'\t' '$2 == "Refactor discount calculation" {print $1; exit}')
if [ -z "$bug" ]; then
  no "the original bug commit is missing from history, it was rewritten rather than reverted"
else
  ok "the original bug commit is still in history"
fi

if [ -f ANSWERS.md ]; then
  short=$(git rev-parse --short=7 "$bug" 2>/dev/null || echo "_______")
  if grep -qi "$short" ANSWERS.md; then
    ok "ANSWERS.md names the correct bug commit"
  else
    no "ANSWERS.md does not contain the hash of the commit that introduced the bug"
  fi
  if grep -qi "kwame" ANSWERS.md; then
    ok "ANSWERS.md names the author of that commit"
  else
    no "ANSWERS.md does not name the author of the bug commit"
  fi
  if [ "$(wc -w < ANSWERS.md | tr -d ' ')" -ge 120 ]; then
    ok "ANSWERS.md questions have been answered"
  else
    no "ANSWERS.md is too short, the questions are not answered"
  fi
else
  no "ANSWERS.md is missing"
fi

if git log --format=%s main | grep -qi '^Revert '; then
  ok "a revert commit exists"
else
  no "no revert commit found, the bad commit was undone some other way"
fi

if command -v python3 >/dev/null 2>&1; then
  out=$(python3 test_pricing.py 2>&1)
  if printf '%s' "$out" | grep -q PASS; then
    ok "pricing tests pass"
  else
    no "pricing tests fail: $(printf '%s' "$out" | head -1)"
  fi
  if python3 -c "import pricing,sys; sys.exit(0 if hasattr(pricing,'format_currency') and hasattr(pricing,'apply_tax') else 1)" 2>/dev/null; then
    ok "format_currency and apply_tax both survived the fix"
  else
    no "the revert removed later work, format_currency or apply_tax is gone"
  fi
else
  echo "  SKIP  python3 not installed, cannot run the pricing tests"
fi

if git log --format=%s main | grep -qiE '^wip$'; then
  no "a commit called 'wip' is still in the history"
else
  ok "no 'wip' commit left in history"
fi

bodies=$(git log --format=%b main | tr -d '[:space:]')
[ -n "$bodies" ] && ok "at least one commit carries a message body" \
                 || no "no commit has a message body, the amend in step 12 was not done"

if git show-ref --verify --quiet refs/heads/feature/scratch; then
  ok "branch feature/scratch has been recovered"
  subj=$(git log -1 --format=%s feature/scratch)
  if [ "$subj" = "Add experimental rounding helper" ]; then
    ok "feature/scratch points at the recovered commit"
  else
    no "feature/scratch exists but points at '$subj', not the recovered commit"
  fi
else
  no "branch feature/scratch was not recovered"
fi

if [ -z "$(git stash list)" ]; then
  ok "stash list is empty"
else
  no "there is still something in the stash"
fi

[ -z "$(git status --porcelain)" ] && ok "working tree is clean" \
                                   || no "working tree is not clean"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
