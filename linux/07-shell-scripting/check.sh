#!/usr/bin/env bash
set -u

WORK="${1:-$HOME/devops-course/linux/07-scripting}"
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $WORK"
echo

if [ ! -f "$WORK/flaky.sh" ]; then
  echo "  FAIL  the sample files are not in $WORK"
  echo
  echo "  Run setup.sh first. If you built your work somewhere else, put that"
  echo "  path on the end of the command."
  echo
  echo "0 passed, 1 failed"; exit 1
fi

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

# run SCRIPT ARGS... : sets OUT, ERR, RC. Never lets a script hang the checker.
run() {
  timeout 30 bash "$@" </dev/null >"$T/out" 2>"$T/err"; RC=$?
  OUT=$(cat "$T/out"); ERR=$(cat "$T/err")
}

# ---------------- greet.sh ----------------
echo "greet.sh"
G="$WORK/greet.sh"
if [ -f "$G" ]; then
  run "$G" Ama
  [ "$RC" -eq 0 ] && [ "$OUT" = "Hello, Ama" ] && ok "greet.sh Ama prints 'Hello, Ama' and exits 0" \
                                                || no "greet.sh Ama printed '$OUT' and exited $RC"
  run "$G"
  [ "$RC" -eq 1 ] && ok "greet.sh with no name exits 1" || no "greet.sh with no name exited $RC, expected 1"
  [ -z "$OUT" ] && ok "greet.sh with no name prints nothing to standard output" \
                || no "greet.sh with no name printed to standard output"
  printf '%s' "$ERR" | grep -qi usage && ok "greet.sh with no name prints usage to standard error" \
                                      || no "greet.sh with no name does not print usage to standard error"
else
  no "greet.sh is missing"
fi

# ---------------- check_config.sh ----------------
echo; echo "check_config.sh"
CC="$WORK/check_config.sh"
if [ -f "$CC" ]; then
  mk() { printf '%b' "$2" > "$T/$1"; }
  mk ok.conf        '# fine\nport=8080\n\nworkers=4\nenvironment=prod\n'
  mk tricky.conf    '# port=abc\n#workers=0\nport=443\nworkers=12\nenvironment=staging\n'
  mk edge.conf      'port=65535\nworkers=1\nenvironment=dev\n'
  mk missing.conf   'port=8080\n'
  mk bad.conf       'port=99999\nworkers=0\nenvironment=production\n'
  mk words.conf     'port=80a\nworkers=two\nenvironment=dev\n'
  mk zero.conf      'port=0\nworkers=3\nenvironment=prod\n'

  for f in ok tricky edge; do
    run "$CC" "$T/$f.conf"
    [ "$RC" -eq 0 ] && [ "$OUT" = "OK" ] && ok "$f.conf is valid: prints OK and exits 0" \
                                         || no "$f.conf should be valid, got exit $RC and output '$OUT'"
  done

  run "$CC" "$T/missing.conf"
  if [ "$RC" -eq 1 ] && [ -z "$OUT" ]; then ok "missing.conf exits 1 with nothing on standard output"
  else no "missing.conf exited $RC with output '$OUT', expected 1 and nothing"; fi
  printf '%s' "$ERR" | grep -qi workers && printf '%s' "$ERR" | grep -qi environment \
    && ok "missing.conf reports both missing keys" \
    || no "missing.conf does not report both workers and environment as missing"

  run "$CC" "$T/bad.conf"
  [ "$RC" -eq 1 ] && ok "bad.conf exits 1" || no "bad.conf exited $RC, expected 1"
  miss=""
  for k in port workers environment; do printf '%s' "$ERR" | grep -qi "$k" || miss="$miss $k"; done
  [ -z "$miss" ] && ok "bad.conf reports every problem, not just the first" \
                 || no "bad.conf does not report a problem with:$miss"

  run "$CC" "$T/words.conf"
  [ "$RC" -eq 1 ] && printf '%s' "$ERR" | grep -qi port && printf '%s' "$ERR" | grep -qi workers \
    && ok "words.conf rejects values that are not whole numbers" \
    || no "words.conf should reject port=80a and workers=two"

  run "$CC" "$T/zero.conf"
  [ "$RC" -eq 1 ] && ok "zero.conf rejects port 0" || no "zero.conf should reject port 0, exited $RC"

  run "$CC" "$T/does-not-exist.conf"
  [ "$RC" -eq 2 ] && ok "a missing file exits 2" || no "a missing file exited $RC, expected 2"
  printf '%s' "$ERR" | grep -q "not found" && ok "a missing file reports 'not found' on standard error" \
                                           || no "a missing file does not report 'not found' on standard error"
  run "$CC"
  [ "$RC" -eq 2 ] && ok "no argument exits 2" || no "no argument exited $RC, expected 2"
else
  no "check_config.sh is missing"
fi

# ---------------- retry.sh ----------------
echo; echo "retry.sh"
R="$WORK/retry.sh"
if [ -f "$R" ]; then
  run "$R" 3 true
  [ "$RC" -eq 0 ] && ok "a command that succeeds exits 0" || no "retry.sh 3 true exited $RC"
  printf '%s' "$ERR" | grep -q failed && no "a command that succeeds still reported a failure" \
                                      || ok "a command that succeeds reports no failures"

  run "$R" 2 false
  [ "$RC" -eq 1 ] && ok "a command that always fails exits with its own code" || no "retry.sh 2 false exited $RC, expected 1"
  n=$(printf '%s\n' "$ERR" | grep -c "failed" || true)
  [ "$n" -eq 2 ] && ok "two attempts report two failures" || no "two attempts reported $n failures"

  run "$R" 2 bash -c 'exit 7'
  [ "$RC" -eq 7 ] && ok "exits with the command's last exit code (7)" || no "retry.sh 2 bash -c 'exit 7' exited $RC, expected 7"

  rm -f "$T/flaky-state"
  start=$(date +%s)
  run "$R" 5 bash "$WORK/flaky.sh" "$T/flaky-state"
  took=$(( $(date +%s) - start ))
  [ "$RC" -eq 0 ] && ok "flaky.sh eventually succeeds and retry.sh exits 0" || no "retry.sh 5 flaky.sh exited $RC"
  [ "$(cat "$T/flaky-state" 2>/dev/null)" = "3" ] && ok "retry.sh stopped as soon as it succeeded" \
                                                  || no "flaky.sh ran $(cat "$T/flaky-state" 2>/dev/null) times, expected exactly 3"
  [ "$took" -ge 2 ] && ok "retry.sh waited between attempts" || no "retry.sh did not wait between attempts"

  start=$(date +%s)
  run "$R" 3 false
  took=$(( $(date +%s) - start ))
  [ "$took" -le 3 ] && ok "retry.sh does not wait after the last attempt" \
                    || no "3 attempts took ${took}s, so it waits after the last one"

  mkdir -p "$T/a folder with spaces"
  run "$R" 2 ls "$T/a folder with spaces"
  [ "$RC" -eq 0 ] && ok "arguments containing spaces are passed through intact" \
                  || no "a folder name with spaces broke, arguments are not passed through intact"

  for bad in "abc true" "0 true" "3"; do
    run "$R" $bad
    [ "$RC" -eq 2 ] && ok "'retry.sh $bad' is rejected with exit 2" || no "'retry.sh $bad' exited $RC, expected 2"
  done
else
  no "retry.sh is missing"
fi

# ---------------- backup.sh ----------------
echo; echo "backup.sh"
BK="$WORK/backup.sh"
if [ -f "$BK" ]; then
  mkdir -p "$T/src/sample-data/inner"; echo one > "$T/src/sample-data/a.txt"; echo two > "$T/src/sample-data/inner/b.txt"
  run "$BK" "$T/src/sample-data" "$T/dest/nested"
  [ "$RC" -eq 0 ] && ok "a backup exits 0" || no "a backup exited $RC"
  [ -d "$T/dest/nested" ] && ok "missing destination folders are created" || no "the destination folder was not created"
  if [ -f "$OUT" ]; then
    ok "it prints the path of the archive"
    printf '%s' "$(basename "$OUT")" | grep -qE '^sample-data-[0-9]{8}-[0-9]{6}\.tar\.gz$' \
      && ok "the archive name follows <folder>-YYYYMMDD-HHMMSS.tar.gz" \
      || no "the archive is named $(basename "$OUT")"
    tar -tzf "$OUT" 2>/dev/null | grep -q 'sample-data/inner/b.txt' \
      && ok "the archive contains the folder and everything inside it" \
      || no "the archive does not contain sample-data/inner/b.txt"
  else
    no "it did not print the path of an archive that exists, printed '$OUT'"
  fi

  D="$T/rot"; mkdir -p "$D"
  for ts in 20200101-000000 20210101-000000 20220101-000000 20230101-000000; do
    : > "$D/sample-data-$ts.tar.gz"; touch -d "${ts:0:4}-01-01" "$D/sample-data-$ts.tar.gz"
  done
  : > "$D/other-20190101-000000.tar.gz"
  run "$BK" "$T/src/sample-data" "$D"
  n=$(ls "$D"/sample-data-*.tar.gz 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" -eq 3 ] && ok "only the three newest archives are kept" || no "$n sample-data archives are left, expected 3"
  [ -f "$D/sample-data-20200101-000000.tar.gz" ] && no "the oldest archive was not deleted" \
                                                 || ok "the oldest archives were deleted"
  [ -f "$OUT" ] && ok "the new archive survived the clean up" || no "the new archive was deleted by its own clean up"
  [ -f "$D/other-20190101-000000.tar.gz" ] && ok "another folder's archive was left alone" \
                                           || no "an archive belonging to a different folder was deleted"

  mkdir -p "$T/src/my data"; echo x > "$T/src/my data/x.txt"
  run "$BK" "$T/src/my data" "$T/spaced"
  [ "$RC" -eq 0 ] && [ -f "$OUT" ] && ok "a source folder with spaces in its name works" \
                                   || no "a source folder with spaces in its name broke"

  run "$BK" "$T/nope" "$T/d2"
  [ "$RC" -eq 2 ] && ok "a missing source exits 2" || no "a missing source exited $RC, expected 2"
  run "$BK"
  [ "$RC" -eq 2 ] && ok "no arguments exits 2" || no "no arguments exited $RC, expected 2"
else
  no "backup.sh is missing"
fi

# ---------------- answers ----------------
echo
A="$WORK/ANSWERS.md"
if [ -f "$A" ]; then
  w=$(wc -w < "$A" | tr -d ' ')
  [ "$w" -ge 250 ] && ok "ANSWERS.md has been filled in ($w words)" \
                   || no "ANSWERS.md has $w words, the questions are not answered"
  grep -q 'pipefail' "$A" && ok "ANSWERS.md discusses set -euo pipefail" || no "ANSWERS.md does not mention pipefail"
else
  no "ANSWERS.md is missing from $WORK"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
