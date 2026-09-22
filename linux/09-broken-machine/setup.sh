#!/usr/bin/env bash
# Breaks this machine in three ways for linux/09. Do not read this file until you are done.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/09-incident}"

# Your work never belongs inside the course files, or you would end up
# committing your answers back to the course repository.
course_root=$(cd "$(dirname "$0")/../.." && pwd)
abs_target=$(realpath -m "$WORK" 2>/dev/null) || case "$WORK" in
  /*) abs_target="$WORK" ;;
  *)  abs_target="$PWD/$WORK" ;;
esac
case "$abs_target" in
  "$course_root"|"$course_root"/*)
    echo "Refusing to build this exercise inside the course files."
    echo
    echo "  you asked for:       $abs_target"
    echo "  the course lives in: $course_root"
    echo
    echo "Keep your work separate, so it never gets mixed into the course."
    echo "Run it with no path at all to use the usual place:"
    echo "  bash $0"
    exit 1
    ;;
esac
ME=$(id -un)

if [ -e "$WORK" ]; then
  echo "Something already exists at $WORK"
  echo "Move it or delete it first, then run this again."
  exit 1
fi
mkdir -p "$WORK"

echo "Preparing the incident. You will be asked for your password."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq cron >/dev/null
sudo systemctl enable --now cron >/dev/null 2>&1

# 1. a service that cannot read its own config
id inventory >/dev/null 2>&1 || sudo useradd --system --no-create-home --shell /usr/sbin/nologin inventory
sudo mkdir -p /opt/inventory /etc/inventory
sudo tee /opt/inventory/server.py >/dev/null <<'PY'
#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer

settings = {}
with open("/etc/inventory/inventory.conf") as f:
    for line in f:
        if "=" in line:
            k, v = line.strip().split("=", 1)
            settings[k] = v

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"inventory ok\n"
        self.send_response(200)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

HTTPServer(("127.0.0.1", int(settings["port"])), Handler).serve_forever()
PY
printf 'port=8090\ndb_password=inv-prod-2026-rotate-me\n' | sudo tee /etc/inventory/inventory.conf >/dev/null
sudo chown root:root /etc/inventory/inventory.conf
sudo chmod 600 /etc/inventory/inventory.conf
sudo tee /etc/systemd/system/inventory.service >/dev/null <<'UNIT'
[Unit]
Description=Inventory API
After=network.target
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
ExecStart=/usr/bin/python3 /opt/inventory/server.py
User=inventory
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT
sudo systemctl daemon-reload
sudo systemctl enable inventory >/dev/null 2>&1
sudo systemctl start inventory >/dev/null 2>&1 || true

# 2. disk space held by a file that no longer exists
sudo tee /usr/local/bin/log-shipper >/dev/null <<'PY'
#!/usr/bin/env python3
import time
buffer = open("/var/tmp/log-shipper/buffer.dat", "rb")
while True:
    time.sleep(3600)
PY
sudo chmod 755 /usr/local/bin/log-shipper
mkdir -p /var/tmp/log-shipper
fallocate -l 400M /var/tmp/log-shipper/buffer.dat
nohup /usr/local/bin/log-shipper >/dev/null 2>&1 &
sleep 2
rm -f /var/tmp/log-shipper/buffer.dat

# 3. something that keeps coming back
sudo tee /usr/local/bin/cache-warm >/dev/null <<'SH'
#!/usr/bin/env bash
end=$((SECONDS + 55))
while [ "$SECONDS" -lt "$end" ]; do :; done
SH
sudo chmod 755 /usr/local/bin/cache-warm
echo '* * * * * root /usr/local/bin/cache-warm' | sudo tee /etc/cron.d/cache-warm >/dev/null
sudo chmod 644 /etc/cron.d/cache-warm

date '+%Y-%m-%d %H:%M:%S' > "$WORK/.incident-start"
echo
echo "linux/09" > "$WORK/.course-exercise"
echo "The machine is now broken. Read the ticket in the README and start the clock."
