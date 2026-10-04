#!/usr/bin/env bash
set -euo pipefail

# Prefer a swift.org toolchain with WebAssembly support (Xcode's swift cannot build wasm).
if [[ "$(uname -s)" == "Darwin" ]]; then
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
else
  # Linux CI/Docker images ship a swift.org toolchain on PATH (e.g. swift:6.1-jammy).
  if ! command -v swift >/dev/null 2>&1; then
    echo "error: swift not found on PATH. Install a swift.org toolchain with WebAssembly support."
    echo "See https://book.swiftwasm.org/getting-started/setup.html"
    exit 1
  fi

  export SWIFT_ORG_TOOLCHAIN="${SWIFT_ORG_TOOLCHAIN:-linux-path}"
fi

pick_wasm_sdk_from_list() {
  local sdk_list="$1"
  local candidate

  # Prefer newest known SDK names first; `swift sdk list` may include a
  # `.artifactbundle` suffix depending on platform/version.
  for candidate in \
    swift-6.2.3-RELEASE_wasm \
    swift-wasm-6.1-RELEASE-wasm32-unknown-wasi \
    6.1-RELEASE-wasm32-unknown-wasi; do
    if grep -Fq "${candidate}" <<<"${sdk_list}"; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done

  return 1
}

sdk_list="$(swift sdk list 2>/dev/null || true)"
if [[ -n "${sdk_list}" ]] && picked_sdk="$(pick_wasm_sdk_from_list "${sdk_list}")"; then
  export SWIFT_WASM_SDK="${picked_sdk}"
else
  export SWIFT_WASM_SDK=""
fi
