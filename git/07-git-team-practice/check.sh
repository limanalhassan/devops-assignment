#!/usr/bin/env bash
set -u

REPO="${1:-$HOME/devops-course/07-team}"
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

cleanup() {
  rm -f .check_probe_secret.txt .check_msg_good .check_msg_bad .check_msg_long 2>/dev/null
  git reset -q >/dev/null 2>&1 || true
}
trap cleanup EXIT

# --- part one, the review ---
if [ -f REVIEW.md ]; then
  ok "REVIEW.md exists"
  r=$(tr '[:upper:]' '[:lower:]' < REVIEW.md)
  found=0
  probe() {
    if printf '%s' "$r" | grep -q "$1"; then ok "review mentions $2"; found=$((found+1));
    else no "review does not mention $2"; fi
  }
  probe "password\|secret\|credential" "the hardcoded database password"
  probe "md5" "the use of MD5 for password hashing"
  probe "except" "the bare except that swallows errors"
  probe "health" "the endpoint rename breaking the documented contract"
  if printf '%s' "$r" | grep -q "none\|null\|returns nothing\|neither\|no return"; then
    ok "review identifies the implicit None return"
  else
    no "review does not identify the path where check_token returns nothing"
  fi
  if [ "$(wc -w < REVIEW.md | tr -d ' ')" -ge 120 ]; then
    ok "review has enough substance to be useful to the author"
  else
    no "review is too short to be a real review"
  fi
else
  no "REVIEW.md is missing"
fi

# --- part two, hooks ---
hp=$(git config core.hooksPath || echo "")
[ "$hp" = ".githooks" ] && ok "core.hooksPath is set to .githooks" \
                        || no "core.hooksPath is '$hp', expected .githooks"

CM=".githooks/commit-msg"
if [ -x "$CM" ]; then
  ok "commit-msg hook exists and is executable"

  printf 'feat(auth): add token validation\n' > .check_msg_good
  printf 'updated some stuff\n' > .check_msg_bad
  printf 'feat(auth): %s\n' "$(head -c 90 /dev/zero | tr '\0' 'x')" > .check_msg_long

  if "$CM" .check_msg_good >/dev/null 2>&1; then
    ok "commit-msg accepts a conventional message"
  else
    no "commit-msg rejects a valid conventional message"
  fi
  if "$CM" .check_msg_bad >/dev/null 2>&1; then
    no "commit-msg accepts 'updated some stuff', it is not enforcing the convention"
  else
    ok "commit-msg rejects a non-conventional message"
  fi
  if "$CM" .check_msg_long >/dev/null 2>&1; then
    no "commit-msg accepts a subject longer than 72 characters"
  else
    ok "commit-msg rejects an over-long subject"
  fi
else
  no ".githooks/commit-msg is missing or not executable"
fi

PC=".githooks/pre-commit"
if [ -x "$PC" ]; then
  ok "pre-commit hook exists and is executable"
  printf 'aws_key = "AKIAIOSFODNN7EXAMPLE"\n' > .check_probe_secret.txt
  git add -f .check_probe_secret.txt >/dev/null 2>&1
  if "$PC" >/dev/null 2>&1; then
    no "pre-commit allows a staged AWS access key through"
  else
    ok "pre-commit blocks a staged AWS access key"
  fi
  git reset -q >/dev/null 2>&1
  rm -f .check_probe_secret.txt
else
  no ".githooks/pre-commit is missing or not executable"
fi

# --- CODEOWNERS ---
if [ -f .github/CODEOWNERS ]; then
  ok ".github/CODEOWNERS exists"
  grep -q "auth.py" .github/CODEOWNERS && ok "CODEOWNERS has a rule for auth.py" \
                                       || no "CODEOWNERS has no rule for auth.py"
  grep -qE '@[A-Za-z0-9_-]+' .github/CODEOWNERS && ok "CODEOWNERS names at least one owner" \
                                                || no "CODEOWNERS names no GitHub user or team"
else
  no ".github/CODEOWNERS is missing"
fi

# --- the mentee's own commits must satisfy their own hook ---
bad=0
while IFS= read -r s; do
  printf '%s\n' "$s" | grep -qE '^(feat|fix|docs|chore|refactor|test|ci)(\([a-z0-9._-]+\))?: .+' || bad=$((bad+1))
done < <(git log --format=%s main --not "$(git rev-list --max-parents=0 main)" 2>/dev/null | head -20)
if [ "$bad" -le 2 ]; then
  ok "your own commits follow the convention"
else
  no "$bad of your commits do not follow Conventional Commits"
fi

if [ -f ANSWERS.md ] && [ "$(wc -w < ANSWERS.md | tr -d ' ')" -ge 200 ]; then
  ok "ANSWERS.md has been filled in"
elif [ -f ANSWERS.md ]; then
  no "ANSWERS.md is too short, the questions are not answered"
else
  no "ANSWERS.md is missing"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
