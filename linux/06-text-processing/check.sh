#!/usr/bin/env bash
set -u

WORK="${1:-$HOME/devops-course/linux/06-text}"
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $WORK"
echo

if [ ! -f "$WORK/access.log" ] || [ ! -f "$WORK/app.log" ]; then
  echo "  FAIL  the logs are not in $WORK"
  echo
  echo "  Run setup.sh first. If you built your work somewhere else, put that"
  echo "  path on the end of the command."
  echo
  echo "0 passed, 1 failed"; exit 1
fi
cd "$WORK" || exit 1

# The correct answers, computed from the files themselves
e1=$(wc -l < access.log | tr -d ' ')
e2=$(awk '$9 == 500' access.log | wc -l | tr -d ' ')
e3=$(awk '{print $1}' access.log | sort | uniq -c | sort -rn | awk 'NR==1 {print $2}')
e4=$(awk '{print $1}' access.log | sort -u | wc -l | tr -d ' ')
e5=$(awk '{print $7}' access.log | sort | uniq -c | sort -rn | awk 'NR==1 {print $2}')
e6=$(awk '{s += $10} END {printf "%d", s}' access.log)
e7=$(awk '$2 == "ERROR" {print substr($1, 12, 2)}' app.log | sort | uniq -c | sort -rn | awk 'NR==1 {print $2}')
e8=$(grep -ci "database timeout" app.log)

if [ -f answers.txt ]; then
  ok "answers.txt exists"
  i=1
  for expected in "$e1" "$e2" "$e3" "$e4" "$e5" "$e6" "$e7" "$e8"; do
    got=$(grep -E "^q$i=" answers.txt | head -1 | cut -d= -f2- | tr -d ' \r')
    if [ -z "$got" ]; then
      no "q$i has no answer"
    elif [ "$got" = "$expected" ]; then
      ok "q$i is correct"
    else
      no "q$i is wrong"
    fi
    i=$((i+1))
  done
else
  no "answers.txt is missing"
fi

if [ -f pipelines.sh ]; then
  n=$(grep -cvE '^[[:space:]]*(#|$)' pipelines.sh || true)
  [ "$n" -ge 8 ] && ok "pipelines.sh has a command for each question" \
                 || no "pipelines.sh has $n commands, expected one for each of the 8 questions"
  out=$(bash pipelines.sh 2>/dev/null); rc=$?
  [ "$rc" -eq 0 ] && ok "pipelines.sh runs without error" || no "pipelines.sh exits with status $rc"
  missing=0
  for v in "$e1" "$e2" "$e3" "$e5" "$e6" "$e8"; do
    printf '%s\n' "$out" | grep -qF -- "$v" || missing=$((missing+1))
  done
  [ "$missing" -eq 0 ] && ok "pipelines.sh prints the answers" \
                       || no "pipelines.sh output is missing $missing of the answers"
else
  no "pipelines.sh is missing"
fi

if [ -f errors.log ]; then
  want=$(grep -c ' ERROR ' app.log)
  have=$(wc -l < errors.log | tr -d ' ')
  other=$(grep -vc ' ERROR ' errors.log || true)
  if [ "$have" = "$want" ] && [ "$other" = "0" ]; then
    ok "errors.log has exactly the $want ERROR lines"
  else
    no "errors.log has $have lines, $other of them not ERROR lines, expected $want ERROR lines"
  fi
else
  no "errors.log is missing"
fi

if [ -f servers.conf ]; then
  old=$(grep -c 'db-old\.internal' servers.conf || true)
  new=$(grep -c 'db-new\.internal' servers.conf || true)
  total=$(wc -l < servers.conf | tr -d ' ')
  [ "$old" = "0" ] && ok "no db-old.internal left in servers.conf" || no "$old db-old.internal left in servers.conf"
  [ "$new" = "7" ] && ok "all 7 hosts now say db-new.internal" || no "$new lines say db-new.internal, expected 7"
  [ "$total" = "12" ] && ok "servers.conf still has all 12 lines" || no "servers.conf has $total lines, expected 12"
  grep -q '^\[reporting\]$' servers.conf && grep -q '^# Database hosts' servers.conf \
    && ok "the other lines in servers.conf are untouched" \
    || no "lines other than the hostnames were changed"
else
  no "servers.conf is missing"
fi

if [ -f ANSWERS.md ]; then
  w=$(wc -w < ANSWERS.md | tr -d ' ')
  [ "$w" -ge 150 ] && ok "ANSWERS.md has been filled in ($w words)" \
                   || no "ANSWERS.md has $w words, the questions are not answered"
  grep -qi "sort" ANSWERS.md && ok "ANSWERS.md discusses sort" || no "ANSWERS.md does not mention sort"
else
  no "ANSWERS.md is missing"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
