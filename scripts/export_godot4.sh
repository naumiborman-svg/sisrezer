#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
mkdir -p "$DIST"

PROJ_ZIP="$DIST/Jinteki-godot4-project.zip"
rm -f "$PROJ_ZIP"
(
	cd "$ROOT"
	zip -rq "$PROJ_ZIP" \
		project.godot icon.svg icon.svg.import .gitignore README.md OPEN_IN_GODOT4.txt export_presets.cfg \
		assets data scenes scripts tests
)
unzip -l "$PROJ_ZIP" | grep -E 'project.godot|title.tscn|cards.json|ai.gd' >/dev/null
test -f "$PROJ_ZIP"

godot --headless --path "$ROOT" --import --quit
PCK="$DIST/Jinteki.pck"
godot --headless --path "$ROOT" --export-pack "macOS" "$PCK"

echo "Project zip: $PROJ_ZIP"
ls -lh "$PROJ_ZIP" "$PCK"
