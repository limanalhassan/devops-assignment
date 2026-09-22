#!/usr/bin/env bash
# Sample inputs for the scripts you write in linux/07.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/07-scripting}"

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
mkdir -p "$WORK/configs" "$WORK/sample-data/notes"

cat > "$WORK/configs/good.conf" <<'TXT'
# Notes API settings
port=8080

workers=4
environment=prod
TXT

cat > "$WORK/configs/missing.conf" <<'TXT'
port=8080
TXT

cat > "$WORK/configs/bad.conf" <<'TXT'
port=99999
workers=0
environment=production
TXT

cat > "$WORK/configs/tricky.conf" <<'TXT'
# port=not-a-number
#workers=0

port=443
workers=12
environment=staging
TXT

cat > "$WORK/flaky.sh" <<'TXT'
#!/usr/bin/env bash
# Fails the first two times it is run, then succeeds.
# Remembers how many times it has run in the file given as $1.
state="${1:?usage: flaky.sh <statefile>}"
count=$(cat "$state" 2>/dev/null || echo 0)
count=$((count + 1))
echo "$count" > "$state"
if [ "$count" -lt 3 ]; then
  echo "flaky: failing on run $count" >&2
  exit 1
fi
echo "flaky: succeeded on run $count"
TXT

echo "first note" > "$WORK/sample-data/notes/1.txt"
echo "second note" > "$WORK/sample-data/notes/2.txt"
echo "settings" > "$WORK/sample-data/settings.conf"

echo "Ready. Sample inputs are in $WORK"
