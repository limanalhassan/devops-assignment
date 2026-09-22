#!/usr/bin/env bash
# Puts a small, crashable web service in place for linux/05.
set -euo pipefail

WORK="${1:-$HOME/devops-course/linux/05-services}"

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

if [ -e "$WORK" ]; then
  echo "Something already exists at $WORK"
  echo "Move it or delete it first, then run this again."
  exit 1
fi
mkdir -p "$WORK"

cat > "$WORK/pinger.py" <<'TXT'
#!/usr/bin/env python3
"""A tiny web service. Visit / for a reply, visit /crash to kill it."""
import os
import socket
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8085


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/crash":
            print("crash requested, exiting with status 1", flush=True)
            os._exit(1)
        body = f"pong from {socket.gethostname()}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print("request: " + (fmt % args), flush=True)


print(f"pinger listening on port {PORT}", flush=True)
HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
TXT

echo "linux/05" > "$WORK/.course-exercise"
echo "Ready. The service is at $WORK/pinger.py"
