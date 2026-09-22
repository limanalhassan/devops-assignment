#!/usr/bin/env bash
set -u

# Which folder to check: the one you name, otherwise the folder you are
# standing in (or one above it) if it looks like this exercise, otherwise
# the usual place.
course_root=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)
{ [ -d "$course_root/linux" ] && [ -d "$course_root/git" ]; } || course_root=/nonexistent
looks_like() { [ -f "$1/hello.sh" ] || [ -f "$1/first.txt" ]; }
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
else WORK="$HOME/devops-course/linux/01-terminal"; how="the usual place"; fi
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $WORK ($how)"
echo

if [ "$(uname -s)" != "Linux" ]; then
  echo "  FAIL  this is not running on Linux"
  echo
  echo "  You are in your computer's own terminal, not in Ubuntu. On a Mac, run"
  echo "  'multipass shell devops' first and run the checker again from inside."
  echo
  echo "0 passed, 1 failed"
  exit 1
fi
ok "running on Linux"

if [ ! -d "$WORK" ]; then
  echo "  FAIL  there is no folder at $WORK"
  echo
  echo "  If your work is somewhere else, go into that folder and run the"
  echo "  checker from there, or put the folder's path on the end of the command."
  echo
  echo "$pass passed, 1 failed"
  exit 1
fi
ok "the folder $WORK exists"

[ -f "$WORK/first.txt" ] && ok "first.txt exists" || no "first.txt is missing"

if [ -f "$WORK/notes.md" ]; then
  [ -s "$WORK/notes.md" ] && ok "notes.md has something in it" || no "notes.md is empty"
else
  no "notes.md is missing"
fi

if [ -f "$WORK/ANSWERS.md" ]; then
  words=$(wc -w < "$WORK/ANSWERS.md" | tr -d ' ')
  if [ "$words" -ge 70 ]; then
    ok "ANSWERS.md has been filled in ($words words)"
  else
    no "ANSWERS.md has only $words words, the four questions are not answered"
  fi
  for term in pwd absolute relative; do
    grep -qi "$term" "$WORK/ANSWERS.md" && ok "ANSWERS.md discusses $term" \
                                        || no "ANSWERS.md does not mention $term"
  done
else
  no "ANSWERS.md is missing"
fi

if [ -f "$WORK/hello.sh" ]; then
  out=$(bash "$WORK/hello.sh" 2>&1)
  if printf '%s' "$out" | grep -qi "ready"; then
    ok "hello.sh runs and prints: $out"
  else
    no "hello.sh ran but did not print a line containing 'ready'"
  fi
  [ -x "$WORK/hello.sh" ] && ok "hello.sh is executable" \
                          || no "hello.sh is not executable"
else
  no "hello.sh is missing"
fi

for tool in git python3 nano curl; do
  command -v "$tool" >/dev/null 2>&1 && ok "$tool is installed" || no "$tool is not installed"
done

if [ -d "$HOME/devops-course/course/.git" ] && [ -d "$HOME/devops-course/course/linux" ]; then
  ok "the course files are at ~/devops-course/course"
else
  no "the course files are not at ~/devops-course/course"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] && { echo; echo "You can use a terminal. Go on to linux/02."; }
[ "$fail" -eq 0 ] || exit 1
