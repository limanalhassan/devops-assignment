#!/usr/bin/env bash
# Builds a project with broken permissions for linux/03.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/03-permissions}"

if [ -e "$WORK" ]; then
  echo "Something already exists at $WORK"
  echo "Move it or delete it first, then run this again."
  exit 1
fi

P="$WORK/notes-deploy"
mkdir -p "$P/config" "$P/secrets" "$P/public" "$P/shared"

id -nG > "$WORK/.groups-before"

printf '#!/usr/bin/env bash\necho "deploying the notes app"\n' > "$P/deploy.sh"
chmod 644 "$P/deploy.sh"

printf 'port = 8080\nworkers = 2\n' > "$P/config/app.conf"
chmod 644 "$P/config/app.conf"

printf 'DB_PASSWORD=correct-horse-battery-staple\n' > "$P/secrets/db.env"
chmod 666 "$P/secrets/db.env"
chmod 777 "$P/secrets"

printf '<h1>Notes</h1>\n' > "$P/public/index.html"
chmod 600 "$P/public/index.html"
chmod 700 "$P/public"

chmod 755 "$P/shared"

echo "Setting up a file owned by root. You may be asked for your password."
printf 'legacy_mode = true\n' | sudo tee "$P/config/legacy.conf" >/dev/null
sudo chown root:root "$P/config/legacy.conf"
sudo chmod 600 "$P/config/legacy.conf"

echo "Ready. The project is at $P"
