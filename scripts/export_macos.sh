#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/dist/Jinteki-macos-universal.zip"
mkdir -p "$ROOT/dist"
godot --headless --path "$ROOT" --import --quit
godot --headless --path "$ROOT" --export-release "macOS" "$OUT"
echo "Exported $OUT"
ls -lh "$OUT"
