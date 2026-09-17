#!/usr/bin/env bash
# Builds the messy folder for linux/02.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/02-files}"

if [ -e "$WORK" ]; then
  echo "Something already exists at $WORK"
  echo "Move it or delete it first, then run this again."
  exit 1
fi

D="$WORK/downloads"
mkdir -p "$D/cache/deep" "$D/unused" "$D/old_projects/project-a/src" \
         "$D/old_projects/project-a/build" "$D/old_projects/project-b/notes"

for i in $(seq -w 1 12); do echo "image data $i" > "$D/photo_0$i.jpg"; done

for day in 01 02 03 04 05 06; do
  for n in 1 2 3; do echo "2026-09-$day INFO request handled ($n)"; done > "$D/app-2026-09-$day.log"
done

awk 'BEGIN {
  x = 7
  for (i = 1; i <= 23817; i++) {
    x = (x * 16807) % 2147483647
    printf "10.0.%d.%d - - [15/Sep/2026:%02d:%02d:%02d +0000] \"GET /api/notes/%d HTTP/1.1\" 200 %d\n",
      x % 8, x % 250 + 1, (i / 1000) % 24, x % 60, (x / 60) % 60, x % 900, 200 + x % 5000
  }
}' > "$D/access.log"

printf 'server {\n    listen 80;\n    server_name notes.local;\n}\n' > "$D/nginx.conf"
printf 'port: 8080\nworkers: 2\n' > "$D/app.yaml"
printf 'DATABASE_URL=postgres://user:changeme@localhost/notes\n' > "$D/.env.example"
echo "not really a pdf" > "$D/Quarterly Report FINAL (2).pdf"

echo "scratch" > "$D/a.tmp"
echo "scratch" > "$D/b.tmp"
echo "scratch" > "$D/cache/c.tmp"
echo "scratch" > "$D/cache/deep/d.tmp"
echo "scratch" > "$D/old_projects/project-a/build/e.tmp"

printf 'print("project a")\n' > "$D/old_projects/project-a/src/main.py"
echo "# Project B" > "$D/old_projects/project-b/README.md"
echo "sk_live_not_a_real_key_7f3a91" > "$D/old_projects/project-b/notes/.api_key"

echo "Ready. Your messy folder is at $D"
