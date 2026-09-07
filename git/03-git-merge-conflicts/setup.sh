#!/usr/bin/env bash
# Builds the starting repository for assignment 03, including the conflicts.
set -euo pipefail

REPO="${1:-$HOME/devops-course/03-conflicts}"

if [ -e "$REPO" ]; then
  echo "Something already exists at $REPO"
  echo "Move it or delete it first, then run this again."
  exit 1
fi

mkdir -p "$REPO"
cd "$REPO"
git init -q -b main

cat > config.yml <<'TXT'
# Notes API configuration

# Port the service listens on
port: 8080

# Seconds before an upstream request is abandoned
timeout: 30

# Number of worker processes
workers: 2
TXT

cat > README.md <<'TXT'
# Notes API

Configuration lives in config.yml.
TXT

git add .
git commit -q -m "Add service configuration"

BASE=$(git rev-parse HEAD)

# Branch one: someone raised the timeout and added retries
git checkout -q -b feature/timeouts "$BASE"
cat > config.yml <<'TXT'
# Notes API configuration

# Port the service listens on
port: 8080

# Seconds before an upstream request is abandoned
timeout: 60

# Number of worker processes
workers: 2

# How many times to retry a failed upstream call
retries: 3
TXT
git add config.yml
git commit -q -m "Raise timeout and add retry setting"

# Branch two: someone moved the service to a different port
git checkout -q -b feature/port-change "$BASE"
cat > config.yml <<'TXT'
# Notes API configuration

# Port the service listens on
port: 9090

# Seconds before an upstream request is abandoned
timeout: 30

# Number of worker processes
workers: 2
TXT
git add config.yml
git commit -q -m "Move service to port 9090"

# Meanwhile main moved on
git checkout -q main
cat > config.yml <<'TXT'
# Notes API configuration

# Port the service listens on
port: 8000

# Seconds before an upstream request is abandoned
timeout: 45

# Number of worker processes
workers: 4
TXT
git add config.yml
git commit -q -m "Tune port, timeout and worker count"

echo "Repository ready at $REPO"
echo "Branches: main, feature/timeouts, feature/port-change"
echo "All three have edited config.yml. Two of them will fight."
