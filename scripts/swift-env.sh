#!/usr/bin/env bash
set -euo pipefail

# Prefer a swift.org toolchain with WebAssembly support (Xcode's swift cannot build wasm).
for toolchain in \
  swift-6.2.3-RELEASE \
  swift-6.2.1-RELEASE \
  swift-6.1-RELEASE \
  swift-wasm-6.0.2-RELEASE; do
  toolchain_bin="$HOME/Library/Developer/Toolchains/${toolchain}.xctoolchain/usr/bin"
  if [[ -x "${toolchain_bin}/swift" ]]; then
    export PATH="${toolchain_bin}:${PATH}"
    export SWIFT_ORG_TOOLCHAIN="${toolchain}"
    break
  fi
done

if ! command -v swift >/dev/null 2>&1; then
  echo "error: swift not found. Install a swift.org toolchain with WebAssembly support."
  echo "See https://book.swiftwasm.org/getting-started/setup.html"
  exit 1
fi

if [[ -z "${SWIFT_ORG_TOOLCHAIN:-}" ]]; then
  echo "error: no swift.org toolchain found in ~/Library/Developer/Toolchains."
  echo "Install one from https://www.swift.org/install/ (e.g. swift-6.2.3-RELEASE)."
  echo "Xcode's swift cannot build WebAssembly targets."
  exit 1
fi

# Pick the best installed wasm SDK for this host swift.
if swift sdk list 2>/dev/null | grep -q "swift-6.2.3-RELEASE_wasm"; then
  export SWIFT_WASM_SDK="swift-6.2.3-RELEASE_wasm"
elif swift sdk list 2>/dev/null | grep -q "6.1-RELEASE-wasm32-unknown-wasi"; then
  export SWIFT_WASM_SDK="6.1-RELEASE-wasm32-unknown-wasi"
else
  export SWIFT_WASM_SDK=""
fi
