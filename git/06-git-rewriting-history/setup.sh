#!/usr/bin/env bash
# Builds the starting repository for assignment 06.
set -euo pipefail

REPO="${1:-$HOME/devops-course/git/06-rewriting}"

# Your work never belongs inside the course files, or you would end up
# committing your answers back to the course repository.
course_root=$(cd "$(dirname "$0")/../.." && pwd)
abs_target=$(realpath -m "$REPO" 2>/dev/null) || case "$REPO" in
  /*) abs_target="$REPO" ;;
  *)  abs_target="$PWD/$REPO" ;;
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
