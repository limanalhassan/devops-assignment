#!/usr/bin/env bash
# Builds the starting repository for assignment 07.
set -euo pipefail

REPO="${1:-$HOME/devops-course/git/07-team}"

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

cat > .gitignore <<'TXT'
__pycache__/
*.pyc
TXT

cat > auth.py <<'TXT'
def check_token(token):
    return token == "expected"
TXT

cat > README.md <<'TXT'
# Notes API

## Endpoints

    GET  /notes        list notes
    POST /notes        create a note
    GET  /healthz      liveness probe
TXT

git add -A
git commit -q -m "Add auth stub and endpoint documentation"

# A colleague's branch, waiting for your review. It has problems.
git checkout -q -b feature/user-auth

cat > auth.py <<'TXT'
import hashlib

DB_PASSWORD = "Pr0d-N0tes-Db!2024"


def hash_password(raw):
    return hashlib.md5(raw.encode()).hexdigest()


def check_token(token):
    # print("token is", token)
    try:
        user, sig = token.split(".")
        return hash_password(user) == sig
    except:
        pass


def login(user, raw_password):
    return user + "." + hash_password(raw_password)
TXT
git add -A; git commit -q -m "stuff"

cat > README.md <<'TXT'
# Notes API

## Endpoints

    GET  /notes        list notes
    POST /notes        create a note
    GET  /health       liveness probe
TXT
git add -A; git commit -q -m "update readme"

git checkout -q main

echo "Repository ready at $REPO"
echo "Branch feature/user-auth is waiting for your review."
