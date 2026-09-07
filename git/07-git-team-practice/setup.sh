#!/usr/bin/env bash
# Builds the starting repository for assignment 07.
set -euo pipefail

REPO="${1:-$HOME/devops-course/07-team}"

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
