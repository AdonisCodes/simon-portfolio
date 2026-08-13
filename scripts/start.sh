#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

npm install
bash scripts/ensure-wasm-sdk.sh
bash scripts/build.sh

echo ""
echo "Serving at http://localhost:8080"
echo "Stats page: http://localhost:8080/stats"
echo ""

npx serve . -l 8080 -s
