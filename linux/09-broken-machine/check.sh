#!/usr/bin/env bash
set -u

WORK="${1:-$HOME/devops-course/linux/09-incident}"
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $WORK"
echo

if [ ! -f "$WORK/.incident-start" ]; then
  echo "  FAIL  the incident has not been set up at $WORK"
  echo
  echo "  Run setup.sh first. If you built your work somewhere else, put that"
  echo "  path on the end of the command."
  echo
  echo "0 passed, 1 failed"; exit 1
fi

echo "The inventory API"
[ "$(systemctl is-active inventory 2>/dev/null)" = "active" ] && ok "inventory is running" \
                                                            || no "inventory is not running"
[ "$(systemctl is-enabled inventory 2>/dev/null)" = "enabled" ] && ok "inventory is still enabled" \
                                                              || no "inventory is not enabled"
curl -s --max-time 5 localhost:8090 2>/dev/null | grep -q "inventory ok" \
  && ok "http://localhost:8090 answers" || no "http://localhost:8090 does not answer"
u=$(systemctl show inventory -p User --value 2>/dev/null)
[ "$u" = "inventory" ] && ok "inventory still runs as the inventory user" \
                       || no "inventory now runs as '${u:-root}', not as the inventory user"
m=$(stat -c %a /etc/inventory/inventory.conf 2>/dev/null || echo missing)
if [ "$m" = "missing" ]; then
  no "/etc/inventory/inventory.conf is missing"
elif [ "${m: -1}" = "0" ]; then
  ok "the inventory config is not readable by everyone ($m)"
else
  no "the inventory config is $m, which lets every user on the machine read the password"
fi

echo; echo "The CPU"
if grep -rsh 'cache-warm' /etc/cron.d /etc/crontab 2>/dev/null | grep -qv '^[[:space:]]*#'; then
  no "a schedule still starts cache-warm"
else
  ok "nothing is scheduled to start cache-warm any more"
fi
[ -z "$(pgrep -f '/usr/local/bin/cache-warm' || true)" ] && ok "cache-warm is not running" \
                                                         || no "cache-warm is still running"

echo; echo "The disk"
held=0
for fd in /proc/[0-9]*/fd/*; do
  t=$(readlink "$fd" 2>/dev/null) || continue
  case "$t" in */log-shipper/buffer.dat*deleted*) held=1; break ;; esac
done
[ "$held" -eq 0 ] && ok "no process is holding the deleted 400MB file" \
                  || no "a process is still holding a deleted file open"

echo; echo "The report"
R="$WORK/INCIDENT.md"
if [ -f "$R" ]; then
  for h in "Summary" "Timeline" "Root cause" "Fix" "Prevention"; do
    grep -qiE "^##[[:space:]]+$h" "$R" && ok "INCIDENT.md has a $h section" || no "INCIDENT.md has no '## $h' heading"
  done
  for t in inventory cron deleted; do
    grep -qi "$t" "$R" && ok "INCIDENT.md covers $t" || no "INCIDENT.md does not mention $t"
  done
  grep -qE '[0-2][0-9]:[0-5][0-9]' "$R" && ok "the timeline has real times" || no "the timeline has no times in it"
  w=$(wc -w < "$R" | tr -d ' ')
  [ "$w" -ge 350 ] && ok "INCIDENT.md is a real report ($w words)" \
                   || no "INCIDENT.md has $w words, too short to be useful to the next person"
else
  no "INCIDENT.md is missing from $WORK"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] && echo "Incident started at $(cat "$WORK/.incident-start"), closed at $(date '+%Y-%m-%d %H:%M:%S')."
[ "$fail" -eq 0 ] || exit 1
