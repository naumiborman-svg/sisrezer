#!/usr/bin/env bash
# Copy the Godot HTTP bridge into a mtgred/netrunner checkout and wire routes.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="${1:-${NETRUNNER_DIR:-/home/ubuntu/netrunner}}"

if [[ ! -f "$DEST/src/clj/web/api.clj" ]]; then
  echo "Not a netrunner checkout: $DEST" >&2
  exit 1
fi

mkdir -p "$DEST/src/clj/web"
cp "$ROOT/src/clj/web/godot_bridge.clj" "$DEST/src/clj/web/godot_bridge.clj"

python3 - "$DEST/src/clj/web/api.clj" <<'PY'
import pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
changed = False
if "web.godot-bridge" not in text:
    old = "   [web.ws :as ws]))"
    new = "   [web.ws :as ws]\n   [web.godot-bridge :as godot-bridge]))"
    if old not in text:
        raise SystemExit("could not patch require in api.clj")
    text = text.replace(old, new, 1)
    changed = True
if '"/godot"' not in text:
    needle = "                   :put #'admin/banned-message-update-handler}]]]"
    insert = '''                   :put #'admin/banned-message-update-handler}]]
     ["/godot"
      ["/status" {:get #'godot-bridge/status-handler}]
      ["/new" {:get #'godot-bridge/new-handler :post #'godot-bridge/new-handler}]
      ["/state" {:get #'godot-bridge/state-handler}]
      ["/action" {:post #'godot-bridge/action-handler}]]]'''
    if needle not in text:
        raise SystemExit("could not patch routes in api.clj")
    text = text.replace(needle, insert, 1)
    changed = True
if changed:
    path.write_text(text)
    print(f"patched {path}")
else:
    print(f"already wired: {path}")
PY

echo "Bridge installed in $DEST"
echo "Restart the Jinteki server (lein run) so /godot/* is loaded."
