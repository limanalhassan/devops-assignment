#!/usr/bin/env bash
# Creates three badly behaved programs for linux/04.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/04-processes}"

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

echo "Ready. Three programs are waiting in $WORK"
