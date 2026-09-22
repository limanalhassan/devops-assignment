#!/usr/bin/env bash
# Builds the three scenarios for assignment 08.
set -euo pipefail

ROOT="${1:-$HOME/devops-course/git/08-pressure}"

# Your work never belongs inside the course files, or you would end up
# committing your answers back to the course repository.
course_root=$(cd "$(dirname "$0")/../.." && pwd)
abs_target=$(realpath -m "$ROOT" 2>/dev/null) || case "$ROOT" in
  /*) abs_target="$ROOT" ;;
  *)  abs_target="$PWD/$ROOT" ;;
esac
case "$abs_target" in
  "$course_root"|"$course_root"/*)
    echo "Refusing to build this exercise inside the course files."
    echo
    echo "  you asked for:       $abs_target"
    echo "  the course lives in: $course_root"
    echo
    echo "Keep your work separate, so it never gets mixed into the course."
    echo "Run it with no path at all to use the usual place:"
    echo "  bash $0"
    exit 1
    ;;
esac

if [ -e "$ROOT" ]; then
  echo "Something already exists at $ROOT"
  echo "Move it or delete it first, then run this again."
  exit 1
fi
mkdir -p "$ROOT"

############################################
# Scenario A: find the commit that broke it
############################################
A="$ROOT/bisect"
mkdir -p "$A"; cd "$A"
git init -q -b main

cat > rates.py <<'TXT'
VAT_RATE = 15


def with_vat(amount):
    return amount * (1 + VAT_RATE / 100)
TXT

cat > test_rates.py <<'TXT'
from rates import with_vat

expected = 115.0
got = with_vat(100)
if abs(got - expected) > 0.001:
    print(f"FAIL with_vat(100) = {got}, expected {expected}")
    raise SystemExit(1)
print("PASS")
raise SystemExit(0)
TXT

cat > CHANGELOG.md <<'TXT'
# Changelog
TXT

cat > .gitignore <<'TXT'
__pycache__/
*.pyc
TXT

git add -A; git commit -q -m "chore: add rates module and test"

for i in $(seq 1 60); do
  if [ "$i" -eq 37 ]; then
    # the commit that breaks it, hidden among sixty plausible ones
    sed -i.bak 's/^VAT_RATE = 15$/VAT_RATE = 0.15/' rates.py && rm -f rates.py.bak
    echo "- normalise VAT rate to a fraction" >> CHANGELOG.md
    git add -A; git commit -q -m "refactor: normalise VAT rate representation"
  else
    echo "- change number $i" >> CHANGELOG.md
    git add -A; git commit -q -m "chore: changelog entry $i"
  fi
done

############################################
# Scenario B: a credential in published history
############################################
B="$ROOT/secret"
mkdir -p "$B"; cd "$B"
git init -q -b main

cat > app.py <<'TXT'
def main():
    print("notes api")
TXT
cat > README.md <<'TXT'
# Notes API deployment
TXT
git add -A; git commit -q -m "chore: add service skeleton"

cat > deploy.sh <<'TXT'
#!/usr/bin/env bash
scp app.py deploy@notes-prod:/srv/notes/
TXT
git add -A; git commit -q -m "ci: add deploy script"

cat > .env <<'TXT'
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMIK7MDENGbPxRfiCYEXAMPLEKEY
DB_PASSWORD=n0tes-prod-2024
TXT
git add -A; git commit -q -m "ci: add deployment environment file"

for i in 1 2 3 4; do
  echo "step $i" >> README.md
  git add -A; git commit -q -m "docs: deployment step $i"
done

git rm -q --cached .env >/dev/null
cat > .gitignore <<'TXT'
.env
TXT
git add -A; git commit -q -m "chore: stop tracking the env file"

for i in 5 6 7; do
  echo "step $i" >> README.md
  git add -A; git commit -q -m "docs: deployment step $i"
done

git checkout -q -b release/1.0
echo "release notes" >> README.md
git add -A; git commit -q -m "docs: add release notes"
git checkout -q main

############################################
# Scenario C: someone destroyed the branch
############################################
C="$ROOT/rescue"
mkdir -p "$C"; cd "$C"
git init -q -b main

for n in "add invoice model" "add invoice storage" "add invoice listing" "add invoice search" "add invoice export"; do
  echo "$n" >> ledger.md
  git add -A; git commit -q -m "feat: $n"
done

echo "reconciliation" >> ledger.md
git add -A; git commit -q -m "feat: add ledger reconciliation"
echo "audit trail" >> ledger.md
git add -A; git commit -q -m "feat: add audit trail"
echo "billing export" >> ledger.md
git add -A; git commit -q -m "feat: add billing export"

git checkout -q -b release/2.0
echo "freeze" >> ledger.md
git add -A; git commit -q -m "chore: freeze 2.0 scope"
echo "notes" >> ledger.md
git add -A; git commit -q -m "docs: prepare 2.0 release notes"

# The damage
git checkout -q main
git reset -q --hard HEAD~3
git branch -q -D release/2.0

echo "Three scenarios are ready under $ROOT"
echo
echo "  bisect/  a test passes at the first commit and fails at the last"
echo "  secret/  a credential was committed and later deleted"
echo "  rescue/  someone reset main and deleted a release branch"
echo
echo "Start the clock."
