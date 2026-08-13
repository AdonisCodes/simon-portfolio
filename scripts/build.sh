#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/swift-env.sh"

if [[ -z "${SWIFT_WASM_SDK}" ]]; then
  echo "error: no Swift WASM SDK found. Run: npm run setup"
  exit 1
fi

echo "Building portfolio with ${SWIFT_WASM_SDK}..."
swift package --swift-sdk "${SWIFT_WASM_SDK}" js --use-cdn --product portfolio
