#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
if [[ ! -d node_modules/jsdom ]]; then
  npm install --omit=dev
fi
export CHIRIBOGA_PORT="${CHIRIBOGA_PORT:-1043}"
exec node host.js
