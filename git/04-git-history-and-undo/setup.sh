#!/usr/bin/env bash
# Builds the starting repository for assignment 04.
set -euo pipefail

REPO="${1:-$HOME/devops-course/git/04-history}"

if [ -e "$REPO" ]; then
  echo "Something already exists at $REPO"
  echo "Move it or delete it first, then run this again."
  exit 1
fi

mkdir -p "$REPO"
cd "$REPO"
git init -q -b main

c() { git add -A; GIT_AUTHOR_NAME="$2" GIT_AUTHOR_EMAIL="$3" git commit -q -m "$1"; }

cat > .gitignore <<'TXT'
__pycache__/
*.pyc
TXT

cat > pricing.py <<'TXT'
def apply_discount(price, percent):
    return price - (price * percent / 100)
TXT
c "Add pricing module" "Ada Mensah" "ada@example.com"

cat > test_pricing.py <<'TXT'
from pricing import apply_discount

def run():
    cases = [(100, 10, 90.0), (50, 50, 25.0), (200, 0, 200.0)]
    for price, percent, expected in cases:
        got = apply_discount(price, percent)
        if got != expected:
            print(f"FAIL apply_discount({price}, {percent}) = {got}, expected {expected}")
            return 1
    print("PASS")
    return 0

if __name__ == "__main__":
    raise SystemExit(run())
TXT
c "Add pricing tests" "Ada Mensah" "ada@example.com"

cat > README.md <<'TXT'
# Pricing service

Calculates discounts for the notes API billing page.
TXT
c "Add README" "Kwame Boateng" "kwame@example.com"

cat > pricing.py <<'TXT'
def apply_discount(price, percent):
    discount = price * percent / 100
    return price + discount
TXT
c "Refactor discount calculation" "Kwame Boateng" "kwame@example.com"

cat >> pricing.py <<'TXT'


def format_currency(amount):
    return f"GHS {amount:.2f}"
TXT
c "Add currency formatting" "Ada Mensah" "ada@example.com"

cat >> README.md <<'TXT'

Amounts are formatted in GHS.
TXT
c "Document currency formatting" "Ada Mensah" "ada@example.com"

cat >> pricing.py <<'TXT'


def apply_tax(amount, rate):
    return amount * (1 + rate / 100)
TXT
c "Add tax helper" "Yaa Owusu" "yaa@example.com"

cat >> README.md <<'TXT'

Tax is applied after any discount.
TXT
c "Document tax behaviour" "Yaa Owusu" "yaa@example.com"

echo "Repository ready at $REPO"
echo "There are 8 commits on main. One of them broke something."
