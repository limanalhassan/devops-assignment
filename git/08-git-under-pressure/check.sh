#!/usr/bin/env bash
set -u

ROOT="${1:-$HOME/devops-course/08-pressure}"
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }
hdr(){ printf '\n%s\n' "$1"; }
ANS="$ROOT/ANSWERS.md"

echo "Checking $ROOT"

# ---------------- Scenario A ----------------
hdr "Scenario A: bisect"
A="$ROOT/bisect"
if [ -d "$A/.git" ]; then
  cd "$A" || exit 1
  guilty=$(git log --format='%H %s' --all | awk '/normalise VAT rate representation/{print $1; exit}')
  short=$(git rev-parse --short "$guilty" 2>/dev/null || echo "________")

  if [ -f .git/BISECT_START ]; then
    no "a bisect session is still in progress"
  else
    ok "bisect session was ended properly"
  fi

  if [ -f bisect.log ] && grep -qc 'git bisect' bisect.log >/dev/null 2>&1; then
    n=$(grep -c 'bisect' bisect.log || echo 0)
    if [ "$n" -ge 5 ]; then
      ok "bisect.log records a real bisect session ($n entries)"
    else
      no "bisect.log has only $n bisect entries, the search was not actually run"
    fi
  else
    no "bisect.log is missing or does not contain a bisect session"
  fi

  if [ -f "$ANS" ] && grep -qi "$short" "$ANS"; then
    ok "answers name the correct guilty commit"
  else
    no "answers do not name the commit that introduced the failure"
  fi

  if command -v python3 >/dev/null 2>&1; then
    if python3 test_rates.py 2>&1 | grep -q PASS; then
      ok "the VAT test passes"
    else
      no "the VAT test still fails"
    fi
  else
    echo "  SKIP  python3 not installed"
  fi

  if git log --format=%s -1 | grep -qE '^(feat|fix|docs|chore|refactor|test|ci)(\([a-z0-9._-]+\))?: .+'; then
    ok "the fix commit uses a conventional message"
  else
    no "the fix commit message is not conventional"
  fi
else
  no "no repository at $A"
fi

# ---------------- Scenario B ----------------
hdr "Scenario B: purged credential"
B="$ROOT/secret"
SECRET="wJalrXUtnFEMIK7MDENGbPxRfiCYEXAMPLEKEY"
if [ -d "$B/.git" ]; then
  cd "$B" || exit 1

  if git log --all -p 2>/dev/null | grep -q "$SECRET"; then
    no "the secret is still reachable in history"
  else
    ok "the secret is not in any reachable commit"
  fi

  if git rev-parse --verify --quiet refs/original/refs/heads/main >/dev/null 2>&1 \
     || [ -d .git/refs/original ]; then
    no "filter-branch backup refs still exist and still contain the secret"
  else
    ok "filter-branch backup refs have been removed"
  fi

  if git fsck --unreachable 2>/dev/null | grep -q 'unreachable blob'; then
    unre=0
    while read -r _ _ objid; do
      if git cat-file -p "$objid" 2>/dev/null | grep -q "$SECRET"; then unre=1; break; fi
    done < <(git fsck --unreachable 2>/dev/null | grep 'unreachable blob')
    if [ "$unre" -eq 1 ]; then
      no "the secret survives in an unreachable object, it was never garbage collected"
    else
      ok "no unreachable object contains the secret"
    fi
  else
    ok "no unreachable objects left behind"
  fi

  if git cat-file -e main:.env 2>/dev/null; then
    no ".env is still tracked on main"
  else
    ok ".env is not tracked"
  fi

  # history must survive
  if git show-ref --verify --quiet refs/heads/release/1.0; then
    ok "release/1.0 still exists"
  else
    no "release/1.0 was destroyed"
  fi
  n=$(git rev-list --count main 2>/dev/null || echo 0)
  if [ "$n" -ge 10 ]; then
    ok "main still has $n commits, history was preserved"
  else
    no "main has only $n commits, the history was flattened instead of filtered"
  fi
  steps=$(git show main:README.md 2>/dev/null | grep -c '^step ' || echo 0)
  if [ "$steps" -eq 7 ]; then
    ok "README.md still has all 7 documentation steps"
  else
    no "README.md has $steps steps, expected 7"
  fi

  if [ -f "$ANS" ] && grep -qi "rotat\|revoke\|new key\|invalidat" "$ANS"; then
    ok "answers address rotating the credential"
  else
    no "answers do not mention rotating or revoking the credential, which is the part that matters"
  fi
else
  no "no repository at $B"
fi

# ---------------- Scenario C ----------------
hdr "Scenario C: rescue"
C="$ROOT/rescue"
if [ -d "$C/.git" ]; then
  cd "$C" || exit 1

  tip=$(git log -1 --format=%s main 2>/dev/null || echo "")
  if [ "$tip" = "feat: add billing export" ]; then
    ok "main is back at 'feat: add billing export'"
  else
    no "main tip is '$tip', expected 'feat: add billing export'"
  fi
  n=$(git rev-list --count main 2>/dev/null || echo 0)
  [ "$n" = "8" ] && ok "main has all 8 commits" || no "main has $n commits, expected 8"

  if git show-ref --verify --quiet refs/heads/release/2.0; then
    ok "release/2.0 has been recreated"
    rtip=$(git log -1 --format=%s release/2.0)
    [ "$rtip" = "docs: prepare 2.0 release notes" ] \
      && ok "release/2.0 is at the right commit" \
      || no "release/2.0 tip is '$rtip', expected 'docs: prepare 2.0 release notes'"
    rn=$(git rev-list --count release/2.0 2>/dev/null || echo 0)
    [ "$rn" = "10" ] && ok "release/2.0 has all 10 commits" \
                     || no "release/2.0 has $rn commits, expected 10"
    lines=$(git show release/2.0:ledger.md 2>/dev/null | wc -l | tr -d ' ')
    [ "$lines" = "10" ] && ok "ledger.md on release/2.0 has its full contents" \
                        || no "ledger.md on release/2.0 has $lines lines, expected 10"
  else
    no "release/2.0 was not recreated"
  fi

  if [ -f "$ANS" ]; then
    for h in "Scenario A" "Scenario B" "Scenario C"; do
      grep -qi "$h" "$ANS" && ok "answers cover $h" || no "answers have no $h section"
    done
    if [ "$(wc -w < "$ANS" | tr -d ' ')" -ge 300 ]; then
      ok "answers are substantial enough"
    else
      no "answers are too short, the five questions are not answered"
    fi
  else
    no "$ANS is missing"
  fi
else
  no "no repository at $C"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
