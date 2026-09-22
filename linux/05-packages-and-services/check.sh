#!/usr/bin/env bash
set -u

# Which folder to check: the one you name, otherwise the folder you are
# standing in (or one above it) if it looks like this exercise, otherwise
# the usual place.
course_root=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)
{ [ -d "$course_root/linux" ] && [ -d "$course_root/git" ]; } || course_root=/nonexistent
looks_like() { grep -qx linux/05 "$1/.course-exercise" 2>/dev/null || [ -f "$1/pinger.py" ]; }
pick_here() {
  local d="$PWD" i
  for i in 1 2 3 4; do
    case "$d" in "$course_root"|"$course_root"/*) return 1 ;; esac
    if looks_like "$d"; then printf '%s\n' "$d"; return 0; fi
    [ "$d" = / ] && return 1
    d=$(dirname "$d")
  done
  return 1
}
if [ $# -ge 1 ]; then WORK="$1"; how="the folder you named"
elif WORK=$(pick_here); then how="the folder you are in"
else WORK="$HOME/devops-course/linux/05-services"; how="the usual place"; fi
UNIT=/etc/systemd/system/pinger.service
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $WORK ($how)"
echo

if [ ! -d "$WORK" ]; then
  echo "  FAIL  there is no folder at $WORK"
  echo
  echo "  Run setup.sh first. If your work is somewhere else, go into that"
  echo "  folder and run the checker from there, or put its path on the end."
  echo
  echo "0 passed, 1 failed"; exit 1
fi

if ! command -v systemctl >/dev/null || [ ! -d /run/systemd/system ]; then
  echo "  FAIL  this machine is not running systemd"
  echo
  echo "  Read the Before you start section of the README."
  echo
  echo "0 passed, 1 failed"; exit 1
fi

installed() { [ "$(dpkg-query -W -f='${Status}' "$1" 2>/dev/null)" = "install ok installed" ]; }

installed nginx && ok "nginx is installed" || no "nginx is not installed"
installed tree && ok "tree is installed" || no "tree is not installed"
[ "$(systemctl is-active nginx 2>/dev/null)" = "active" ] && ok "nginx is running" || no "nginx is not running"
[ "$(systemctl is-enabled nginx 2>/dev/null)" = "enabled" ] && ok "nginx is enabled" || no "nginx is not enabled"
curl -s --max-time 5 localhost 2>/dev/null | grep -qi nginx && ok "nginx answers on port 80" \
                                                          || no "nothing answers like nginx on port 80"

if [ -f "$UNIT" ]; then
  ok "$UNIT exists"
  grep -qE '^ExecStart=.*/pinger\.py' "$UNIT" && ok "the unit runs pinger.py" \
                                               || no "the unit's ExecStart does not run pinger.py"
  grep -qE '^ExecStart=/' "$UNIT" && ok "ExecStart uses a full path" \
                                   || no "ExecStart does not start with a full path"
  grep -qE '^Restart=(always|on-failure)' "$UNIT" && ok "the unit restarts on failure" \
                                                   || no "the unit has no Restart setting that restarts after a crash"
  grep -qE '^WantedBy=' "$UNIT" && ok "the unit has an [Install] target" \
                                 || no "the unit has no WantedBy, so it cannot be enabled"
else
  no "$UNIT does not exist"
fi

[ "$(systemctl is-active pinger 2>/dev/null)" = "active" ] && ok "pinger is running" || no "pinger is not running"
[ "$(systemctl is-enabled pinger 2>/dev/null)" = "enabled" ] && ok "pinger is enabled" || no "pinger is not enabled"

pid=$(systemctl show pinger -p MainPID --value 2>/dev/null)
if [ -n "$pid" ] && [ "$pid" != "0" ]; then
  u=$(ps -o user= -p "$pid" | tr -d ' ')
  [ "$u" != "root" ] && ok "pinger runs as $u, not root" || no "pinger runs as root"
fi

curl -s --max-time 5 localhost:8085 2>/dev/null | grep -q pong && ok "pinger answers on port 8085" \
                                                              || no "nothing answers on port 8085"

r=$(systemctl show pinger -p NRestarts --value 2>/dev/null)
if [ -n "$r" ] && [ "$r" -ge 1 ] 2>/dev/null; then
  ok "systemd has restarted pinger $r time(s) since boot"
else
  no "systemd has not restarted pinger since the last boot, it has not been crashed under systemd"
fi

A="$WORK/ANSWERS.md"
if [ -f "$A" ]; then
  w=$(wc -w < "$A" | tr -d ' ')
  [ "$w" -ge 200 ] && ok "ANSWERS.md has been filled in ($w words)" \
                   || no "ANSWERS.md has $w words, the questions are not answered"
  for t in enable journalctl daemon-reload; do
    grep -qi "$t" "$A" && ok "ANSWERS.md discusses $t" || no "ANSWERS.md does not mention $t"
  done
else
  no "ANSWERS.md is missing from $WORK"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
