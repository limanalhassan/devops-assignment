#!/usr/bin/env bash
# Creates three badly behaved programs for linux/04.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/04-processes}"

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

cat > "$WORK/cpu-burner.sh" <<'TXT'
#!/usr/bin/env bash
# Does nothing useful, as fast as it possibly can.
while :; do :; done
TXT

cat > "$WORK/stubborn.sh" <<'TXT'
#!/usr/bin/env bash
# Refuses to stop when asked nicely.
here="$(cd "$(dirname "$0")" && pwd)"
trap 'echo "$(date +%T) got a polite signal, ignoring it" >> "$here/stubborn.out"' TERM INT
while :; do sleep 1; done
TXT

cat > "$WORK/heartbeat.sh" <<'TXT'
#!/usr/bin/env bash
# Writes the time every two seconds. Something is supposed to keep this alive.
here="$(cd "$(dirname "$0")" && pwd)"
while :; do date +%T >> "$here/heartbeat.log"; sleep 2; done
TXT

echo "linux/04" > "$WORK/.course-exercise"
echo "Ready. Three programs are waiting in $WORK"
