#!/usr/bin/env bash
set -u

WORK="${1:-$HOME/devops-course/linux/03-permissions}"
P="$WORK/notes-deploy"
ME=$(id -un)
pass=0; fail=0
ok() { printf '  PASS  %s\n' "$1"; pass=$((pass+1)); }
no() { printf '  FAIL  %s\n' "$1"; fail=$((fail+1)); }

echo "Checking $WORK"
echo

if [ ! -d "$P" ]; then
  echo "  FAIL  there is no project at $P"
  echo
  echo "  Run setup.sh first. If you built your work somewhere else, put that"
  echo "  path on the end of the command."
  echo
  echo "0 passed, 1 failed"; exit 1
fi

mode() {
  local got; got=$(stat -c '%a' "$P/$1" 2>/dev/null || echo missing)
  if [ "$got" = "$2" ]; then ok "$1 is $2"; else no "$1 is $got, expected $2"; fi
}
mode deploy.sh 750
mode secrets/db.env 600
mode secrets 700
mode public/index.html 644
mode public 755

owner=$(stat -c '%U:%G' "$P/config/legacy.conf" 2>/dev/null || echo missing)
mygroup=$(id -gn)
if [ "$owner" = "$ME:$mygroup" ]; then
  ok "config/legacy.conf now belongs to $ME"
else
  no "config/legacy.conf is owned by $owner"
fi

if getent group deployers >/dev/null; then
  ok "the deployers group exists"
  if getent group deployers | cut -d: -f4 | tr ',' '\n' | grep -qx "$ME"; then
    ok "$ME is a member of deployers"
  else
    no "$ME is not a member of deployers"
  fi
else
  no "the deployers group does not exist"
fi

if [ -f "$WORK/.groups-before" ]; then
  now=" $(id -nG "$ME") "
  lost=""
  for g in $(cat "$WORK/.groups-before"); do
    case "$now" in *" $g "*) ;; *) lost="$lost $g" ;; esac
  done
  if [ -z "$lost" ]; then
    ok "you are still in every group you started in"
  else
    no "you are no longer in these groups:$lost"
  fi
fi

sg=$(stat -c '%G' "$P/shared" 2>/dev/null || echo missing)
[ "$sg" = "deployers" ] && ok "shared belongs to the deployers group" || no "shared belongs to group $sg"
mode shared 2775

if [ -f "$P/shared/release-notes.txt" ]; then
  rg=$(stat -c '%G' "$P/shared/release-notes.txt")
  [ "$rg" = "deployers" ] && ok "release-notes.txt inherited the deployers group" \
                          || no "release-notes.txt belongs to group $rg"
else
  no "shared/release-notes.txt is missing"
fi

A="$WORK/ANSWERS.md"
if [ -f "$A" ]; then
  w=$(wc -w < "$A" | tr -d ' ')
  [ "$w" -ge 200 ] && ok "ANSWERS.md has been filled in ($w words)" \
                   || no "ANSWERS.md has $w words, the questions are not answered"
  for t in 644 755 600 umask; do
    grep -qi "$t" "$A" && ok "ANSWERS.md discusses $t" || no "ANSWERS.md does not mention $t"
  done
else
  no "ANSWERS.md is missing from $WORK"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
