#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/swift-env.sh"

if [[ -n "${SWIFT_WASM_SDK}" ]]; then
  echo "Using Swift WASM SDK: ${SWIFT_WASM_SDK}"
  exit 0
fi

echo "No Swift WASM SDK found. Installing swift-6.2.3-RELEASE_wasm..."

swift sdk install \
  "https://download.swift.org/swift-6.2.3-release/wasm-sdk/swift-6.2.3-RELEASE/swift-6.2.3-RELEASE_wasm.artifactbundle.tar.gz" \
  --checksum "394040ecd5260e68bb02f6c20aeede733b9b90702c2204e178f3e42413edad2a"

source "$(dirname "$0")/swift-env.sh"

if [[ -z "${SWIFT_WASM_SDK}" ]]; then
  echo "error: Swift WASM SDK install did not succeed."
  exit 1
fi

echo "Installed Swift WASM SDK: ${SWIFT_WASM_SDK}"
