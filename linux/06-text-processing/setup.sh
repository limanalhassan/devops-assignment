#!/usr/bin/env bash
# Generates a day of web and application logs for linux/06.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/06-text}"

# Your work never belongs inside the course files, or you would end up
# committing your answers back to the course repository.
course_root=$(cd "$(dirname "$0")/../.." && pwd)
abs_target=$(realpath -m "$WORK" 2>/dev/null) || case "$WORK" in
  /*) abs_target="$WORK" ;;
  *)  abs_target="$PWD/$WORK" ;;
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

if [ -e "$WORK" ]; then
  echo "Something already exists at $WORK"
  echo "Move it or delete it first, then run this again."
  exit 1
fi
mkdir -p "$WORK"

awk 'BEGIN {
  x = 424242; N = 48213
  for (i = 0; i < N; i++) {
    x = (x * 16807) % 2147483647; r = x % 100
    if (r < 9) ip = "203.0.113.77"
    else { x = (x * 16807) % 2147483647; ip = "10.0." (x % 6) "." ((int(x / 7) % 40) + 2) }
    x = (x * 16807) % 2147483647; p = x % 100
    if (p < 35) path = "/api/notes"
    else if (p < 60) path = "/api/notes/" (x % 500)
    else if (p < 80) path = "/health"
    else if (p < 88) path = "/login"
    else if (p < 95) path = "/static/app.js"
    else path = "/admin"
    x = (x * 16807) % 2147483647; s = x % 100
    if (path == "/admin" && s < 80) status = 401
    else if (s < 2) status = 500
    else if (s < 7) status = 404
    else status = 200
    x = (x * 16807) % 2147483647; bytes = 100 + x % 9000
    hh = int(i * 24 / N); mm = x % 60; ss = int(x / 60) % 60
    printf "%s - - [15/Sep/2026:%02d:%02d:%02d +0000] \"GET %s HTTP/1.1\" %d %d \"-\" \"Mozilla/5.0 (X11; Linux x86_64)\"\n", ip, hh, mm, ss, path, status, bytes
  }
}' > "$WORK/access.log"

awk 'BEGIN {
  x = 99991; N = 9000
  for (i = 0; i < N; i++) {
    x = (x * 16807) % 2147483647
    hh = int(i * 24 / N); mm = x % 60; ss = int(x / 60) % 60
    e = (hh == 14) ? 30 : 3
    x = (x * 16807) % 2147483647; r = x % 100
    if (r < e) {
      lvl = "ERROR"
      if (x % 2) msg = ((x % 3) ? "database timeout after 5000ms" : "Database Timeout after 5000ms")
      else msg = "failed to render note " (x % 700)
    } else if (r < e + 10) { lvl = "WARN"; msg = "slow query took " (200 + x % 800) "ms" }
    else { lvl = "INFO"; msg = "request completed in " (5 + x % 90) "ms" }
    printf "2026-09-15T%02d:%02d:%02dZ %s %s\n", hh, mm, ss, lvl, msg
  }
}' > "$WORK/app.log"

cat > "$WORK/servers.conf" <<'TXT'
# Database hosts for the notes service
primary_db = db-old.internal:5432
replica_db = db-old.internal:5433
migrations_db = db-old.internal:5432

[reporting]
source = db-old.internal
fallback = db-old.internal

[backups]
target = db-old.internal
verify = db-old.internal
TXT

echo "Ready. Logs and config are in $WORK"
