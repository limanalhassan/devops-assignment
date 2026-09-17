#!/usr/bin/env bash
set -u

WORK="${1:-$HOME/devops-course/linux/04-processes}"
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $WORK"
echo

if [ ! -d "$WORK" ]; then
  echo "  FAIL  there is no folder at $WORK"
  echo
  echo "  Run setup.sh first. If you built your work somewhere else, put that"
  echo "  path on the end of the command."
  echo
  echo "0 passed, 1 failed"; exit 1
fi

# match the running scripts, not an editor or tail that happens to name them
running() { pgrep -f "(^|/)bash .*$1" || true; }

[ -z "$(running 'cpu-burner\.sh')" ] && ok "cpu-burner is not running" \
                                      || no "cpu-burner is still running"
[ -z "$(running 'stubborn\.sh')" ] && ok "stubborn is not running" \
                                    || no "stubborn is still running"

if [ -f "$WORK/stubborn.out" ] && grep -q "ignoring" "$WORK/stubborn.out"; then
  ok "stubborn.out shows a polite signal was tried first"
else
  no "stubborn.out shows no polite signal was ever sent"
fi

pids=$(running 'heartbeat\.sh')
count=$(printf '%s' "$pids" | grep -c . || true)
if [ "$count" -eq 1 ]; then
  ok "exactly one heartbeat is running (PID $pids)"
  ign=$(awk '/^SigIgn:/ {print $2}' "/proc/$pids/status" 2>/dev/null)
  if [ -n "$ign" ] && [ $(( 0x$ign & 1 )) -eq 1 ]; then
    ok "the heartbeat is ignoring SIGHUP, so it was started with nohup"
  else
    no "the heartbeat is not ignoring SIGHUP, so closing its terminal would kill it"
  fi
  if [ -t 0 ] && [ "$(ps -o tty= -p "$pids" | tr -d ' ')" = "$(ps -o tty= -p $$ | tr -d ' ')" ]; then
    no "the heartbeat is attached to this terminal, terminal A was not closed"
  else
    ok "the heartbeat is not attached to this terminal"
  fi
elif [ "$count" -gt 1 ]; then
  no "$count heartbeats are running, expected exactly one"
else
  no "no heartbeat is running"
fi

if [ -f "$WORK/heartbeat.log" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$WORK/heartbeat.log") ))
  [ "$age" -le 15 ] && ok "heartbeat.log was written ${age}s ago" \
                    || no "heartbeat.log has not been written for ${age}s"
else
  no "heartbeat.log does not exist"
fi

A="$WORK/ANSWERS.md"
if [ -f "$A" ]; then
  w=$(wc -w < "$A" | tr -d ' ')
  [ "$w" -ge 180 ] && ok "ANSWERS.md has been filled in ($w words)" \
                   || no "ANSWERS.md has $w words, the questions are not answered"
  for t in SIGTERM SIGKILL parent; do
    grep -qi "$t" "$A" && ok "ANSWERS.md discusses $t" || no "ANSWERS.md does not mention $t"
  done
else
  no "ANSWERS.md is missing from $WORK"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] && { echo; echo "Now stop the heartbeat, it will write forever otherwise."; }
[ "$fail" -eq 0 ] || exit 1
