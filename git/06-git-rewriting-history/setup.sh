#!/usr/bin/env bash
# Builds the starting repository for assignment 06.
set -euo pipefail

REPO="${1:-$HOME/devops-course/06-rewriting}"

if [ -e "$REPO" ]; then
  echo "Something already exists at $REPO"
  echo "Move it or delete it first, then run this again."
  exit 1
fi

mkdir -p "$REPO"
cd "$REPO"
git init -q -b main

cat > app.py <<'TXT'
def health():
    return "ok"
TXT
cat > README.md <<'TXT'
# Notes API
TXT
git add -A; git commit -q -m "Add health endpoint"

git tag -a v1.0.0 -m "First release" 2>/dev/null || git tag v1.0.0

# A messy feature branch, the kind people actually produce
git checkout -q -b feature/search

cat >> app.py <<'TXT'


def search(notes, term):
    return [n for n in notes if term in n]
TXT
git add -A; git commit -q -m "wip"

cat >> app.py <<'TXT'
        # placeholder
TXT
git add -A; git commit -q -m "wip 2"

grep -v '# placeholder' app.py > app.py.tmp && mv app.py.tmp app.py
git add -A; git commit -q -m "oops remove placeholder"

echo "print('debugging search')" > debug.txt
git add -A; git commit -q -m "add debug file"

cat >> README.md <<'TXT'

## Search

Pass a list of notes and a search term.
TXT
git add -A; git commit -q -m "docs"

cat >> app.py <<'TXT'


def search_count(notes, term):
    return len(search(notes, term))
TXT
git add -A; git commit -q -m "fix typo in search count helper"

git tag pre-cleanup

# A hotfix branch that is not ready to merge as a whole
git checkout -q main
git checkout -q -b hotfix/log-level main
cat > logging.conf <<'TXT'
level = info
TXT
git add -A; git commit -q -m "Set default log level to info"
cat >> README.md <<'TXT'

Internal note: do not ship this line.
TXT
git add -A; git commit -q -m "Add internal scratch note"

git checkout -q feature/search

echo "Repository ready at $REPO"
echo "You are on feature/search. It has six commits and most of them are rubbish."
echo "Do not delete the tag 'pre-cleanup', the checker uses it."
