#!/usr/bin/env bash
# Starts an undocumented service for linux/08 to go and find.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/08-network}"

if [ -e "$WORK" ]; then
  echo "Something already exists at $WORK"
  echo "Move it or delete it first, then run this again."
  exit 1
fi
mkdir -p "$WORK"

echo "This setup starts a service as the administrator. You may be asked for your password."

ports=(5190 6044 7311 8472 9123)
port=${ports[$((RANDOM % ${#ports[@]}))]}
token=$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')

sudo mkdir -p /opt/metrics-agent
echo "$token" | sudo tee /opt/metrics-agent/token.txt >/dev/null
sudo chown -R nobody:nogroup /opt/metrics-agent
sudo chmod 750 /opt/metrics-agent
sudo chmod 640 /opt/metrics-agent/token.txt

sudo tee /etc/systemd/system/metrics-agent.service >/dev/null <<UNIT
[Unit]
Description=Metrics agent
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server $port --bind 127.0.0.1 --directory /opt/metrics-agent
User=nobody
Group=nogroup
Restart=always

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now metrics-agent >/dev/null 2>&1

echo "Ready. Something new is listening on this machine. Nobody wrote down where."
