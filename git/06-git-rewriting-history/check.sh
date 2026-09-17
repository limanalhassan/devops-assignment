#!/usr/bin/env bash
set -u

REPO="${1:-$HOME/devops-course/git/06-rewriting}"
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

if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
  no "a rebase is still in progress"
else
  ok "no rebase left in progress"
fi

if ! git rev-parse --verify --quiet pre-cleanup >/dev/null; then
  no "the tag 'pre-cleanup' was deleted, the checker needs it"
else
  ok "the pre-cleanup tag is intact"
fi

# --- part one, the cleaned branch ---
if git show-ref --verify --quiet refs/heads/feature/search; then
  ok "feature/search exists"
  base=$(git rev-parse v1.0.0 2>/dev/null || echo "")
  n=$(git rev-list --count "${base}..feature/search" 2>/dev/null || echo "?")
  if [ "$n" = "3" ]; then
    ok "feature/search has exactly 3 commits since v1.0.0"
  else
    no "feature/search has $n commits since v1.0.0, expected 3"
  fi

  subs=$(git log --format=%s "${base}..feature/search" 2>/dev/null)
  if printf '%s' "$subs" | grep -qiE '^(wip|oops|docs|fix typo|add debug)'; then
    no "the original messy commit messages are still there"
  else
    ok "commit messages have been rewritten"
  fi

  if git cat-file -e feature/search:debug.txt 2>/dev/null; then
    no "debug.txt is still in the tree on feature/search"
  else
    ok "debug.txt has been dropped"
  fi

  # nothing else lost: compare against the pre-cleanup snapshot
  if git rev-parse --verify --quiet pre-cleanup >/dev/null; then
    changed=$(git diff --name-only pre-cleanup feature/search 2>/dev/null | grep -v '^debug.txt$' | grep -v '^app.py$' || true)
    if [ -z "$changed" ]; then
      ok "no files other than debug.txt were lost in the rebase"
    else
      no "these files differ from the pre-cleanup snapshot: $(printf '%s' "$changed" | tr '\n' ' ')"
    fi
    for fn in "def search(" "def search_count("; do
      if git show feature/search:app.py 2>/dev/null | grep -qF "$fn"; then
        ok "app.py still contains ${fn%(*}"
      else
        no "app.py lost ${fn%(*} during the rebase"
      fi
    done
    if git show feature/search:app.py 2>/dev/null | grep -q "placeholder"; then
      no "the placeholder line is back in app.py"
    else
      ok "the placeholder line is not in the final app.py"
    fi
  fi
else
  no "feature/search does not exist"
fi

# --- part two, cherry-pick ---
if git cat-file -e main:logging.conf 2>/dev/null; then
  ok "logging.conf is on main"
else
  no "logging.conf is not on main, the fix was not cherry-picked"
fi

if git show main:README.md 2>/dev/null | grep -q "do not ship this line"; then
  no "the internal scratch note reached main, the whole branch was brought over"
else
  ok "the internal scratch note did not reach main"
fi

if [ "$(git rev-list --merges --count main 2>/dev/null || echo 0)" -ge 1 ]; then
  parents=$(git rev-list --merges main | while read -r m; do git rev-parse "$m^2"; done)
  if printf '%s' "$parents" | grep -q "$(git rev-parse hotfix/log-level 2>/dev/null || echo nomatch)"; then
    no "hotfix/log-level was merged into main instead of cherry-picked"
  else
    ok "hotfix/log-level was not merged into main"
  fi
fi

# --- part three, merge and tag ---
if git merge-base --is-ancestor feature/search main 2>/dev/null; then
  ok "feature/search has been merged into main"
else
  no "feature/search has not been merged into main"
fi

newtag=$(git tag --list 'v*' | grep -v '^v1\.0\.0$' | head -1)
if [ -z "$newtag" ]; then
  no "no new version tag was created"
else
  ok "new tag $newtag exists"
  if [ "$newtag" = "v1.1.0" ]; then
    ok "$newtag is the correct semantic version bump for new functionality"
  else
    no "$newtag is not the right bump, new backwards compatible functionality is a minor version"
  fi
  if [ "$(git cat-file -t "$newtag" 2>/dev/null)" = "tag" ]; then
    ok "$newtag is an annotated tag"
  else
    no "$newtag is a lightweight tag, an annotated one was asked for"
  fi
fi

if [ -f ANSWERS.md ] && [ "$(wc -w < ANSWERS.md | tr -d ' ')" -ge 180 ]; then
  ok "ANSWERS.md has been filled in"
elif [ -f ANSWERS.md ]; then
  no "ANSWERS.md is too short, the questions are not answered"
else
  no "ANSWERS.md is missing"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
