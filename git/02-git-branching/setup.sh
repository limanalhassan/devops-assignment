#!/usr/bin/env bash
# Builds the starting repository for assignment 02.
set -euo pipefail

REPO="${1:-$HOME/devops-course/git/02-branching}"

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
