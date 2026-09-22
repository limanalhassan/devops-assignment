#!/usr/bin/env bash
# Builds the starting repository for assignment 02.
set -euo pipefail

REPO="${1:-$HOME/devops-course/git/02-branching}"

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

cat > README.md <<'TXT'
# Notes API

A small service for storing notes.

## Running it

Not written yet.
TXT

cat > app.py <<'TXT'
def main():
    print("notes api")

if __name__ == "__main__":
    main()
TXT

git add .
git commit -q -m "Add project skeleton"

cat >> README.md <<'TXT'

## Configuration

Not written yet.
TXT
git add README.md
git commit -q -m "Add configuration section to README"

echo "Repository ready at $REPO"
echo "It is on branch main with 2 commits."
