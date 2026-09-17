#!/usr/bin/env bash
set -u

WORK="${1:-$HOME/devops-course/linux/08-network}"
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

entry=$(getent passwd deploy || true)
if [ -n "$entry" ]; then
  ok "the deploy user exists"
  [ "$(echo "$entry" | cut -d: -f6)" = "/home/deploy" ] && ok "deploy's home is /home/deploy" \
                                                        || no "deploy's home is $(echo "$entry" | cut -d: -f6)"
  [ "$(echo "$entry" | cut -d: -f7)" = "/bin/bash" ] && ok "deploy's shell is bash" \
                                                     || no "deploy's shell is $(echo "$entry" | cut -d: -f7)"
  [ -d /home/deploy ] && ok "/home/deploy exists" || no "/home/deploy does not exist"
else
  no "the deploy user does not exist"
fi

[ "$(dpkg-query -W -f='${Status}' openssh-server 2>/dev/null)" = "install ok installed" ] \
  && ok "openssh-server is installed" || no "openssh-server is not installed"

if [ -f "$HOME/.ssh/id_ed25519" ] && [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  ok "your ed25519 key pair exists"
  [ "$(stat -c %a "$HOME/.ssh/id_ed25519")" = "600" ] && ok "your private key is 600" \
                                                       || no "your private key is $(stat -c %a "$HOME/.ssh/id_ed25519")"
else
  no "~/.ssh/id_ed25519 and id_ed25519.pub do not both exist"
fi

who=$(timeout 15 ssh -o BatchMode=yes -o PasswordAuthentication=no -o StrictHostKeyChecking=accept-new \
      -o ConnectTimeout=5 deploy@localhost whoami 2>/dev/null)
[ "$who" = "deploy" ] && ok "ssh deploy@localhost works with your key and no password" \
                      || no "ssh deploy@localhost with key only did not log in as deploy"

port=$(systemctl cat metrics-agent.service 2>/dev/null | grep '^ExecStart=' | grep -oE 'http\.server [0-9]+' | awk '{print $2}')
A="$WORK/ANSWERS.md"
if [ -z "$port" ]; then
  no "the mystery service is not installed, run setup.sh"
elif [ -f "$A" ]; then
  token=$(curl -s --max-time 5 "http://127.0.0.1:$port/token.txt" | tr -d '\n')
  grep -q "$port" "$A" && ok "ANSWERS.md names the mystery port" || no "ANSWERS.md does not contain the mystery service's port"
  grep -q "metrics-agent" "$A" && ok "ANSWERS.md names the service" || no "ANSWERS.md does not name the systemd service"
  if [ -n "$token" ] && grep -q "$token" "$A"; then ok "ANSWERS.md has the token"
  else no "ANSWERS.md does not contain the token the service serves"; fi
fi

if [ -f "$A" ]; then
  w=$(wc -w < "$A" | tr -d ' ')
  [ "$w" -ge 250 ] && ok "ANSWERS.md has been filled in ($w words)" \
                   || no "ANSWERS.md has $w words, the questions are not answered"
  grep -qi "bad ownership or modes" "$A" && ok "ANSWERS.md quotes the SSH server's refusal" \
                                         || no "ANSWERS.md does not include the log line from step 11"
else
  no "ANSWERS.md is missing from $WORK"
fi

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ] || exit 1
