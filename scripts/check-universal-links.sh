#!/usr/bin/env bash
#
# Verifies the AutoZone Universal Link routes:
#   - /.well-known/apple-app-site-association (and /apple-app-site-association)
#     must return HTTP 200, Content-Type application/json, no redirects,
#     and contain the AutoZone app ID.
#   - /w must return HTTP 200 with the SPA shell (text/html).
#
# Usage:
#   scripts/check-universal-links.sh [base-url]
#
# Examples:
#   scripts/check-universal-links.sh                          # checks https://simonferns.com
#   scripts/check-universal-links.sh http://localhost:8080    # checks a local server
set -euo pipefail

BASE_URL="${1:-https://simonferns.com}"
APP_ID="J9GLPBP73D.com.adoniscodes.zonerun"
FAILURES=0

check_aasa() {
  local path="$1"
  local url="${BASE_URL}${path}"
  local headers body status content_type

  headers="$(curl -sS -o /tmp/aasa-body.$$ -D - "${url}")" || {
    echo "FAIL ${path}: request failed"
    FAILURES=$((FAILURES + 1))
    return
  }
  body="$(cat /tmp/aasa-body.$$)"
  rm -f /tmp/aasa-body.$$

  status="$(printf '%s' "${headers}" | head -1 | awk '{print $2}')"
  content_type="$(printf '%s' "${headers}" | grep -i '^content-type:' | tr -d '\r' | awk '{print $2}')"

  if [[ "${status}" != "200" ]]; then
    echo "FAIL ${path}: expected HTTP 200 without redirects, got ${status}"
    FAILURES=$((FAILURES + 1))
  elif [[ "${content_type}" != application/json* ]]; then
    echo "FAIL ${path}: expected Content-Type application/json, got '${content_type}'"
    FAILURES=$((FAILURES + 1))
  elif [[ "${body}" != *"${APP_ID}"* ]]; then
    echo "FAIL ${path}: body does not contain ${APP_ID}"
    FAILURES=$((FAILURES + 1))
  else
    echo "OK   ${path} (200, application/json, contains ${APP_ID})"
  fi
}

check_workout_page() {
  local path="/w"
  local url="${BASE_URL}${path}"
  local status

  status="$(curl -sS -o /dev/null -w '%{http_code}' "${url}")" || {
    echo "FAIL ${path}: request failed"
    FAILURES=$((FAILURES + 1))
    return
  }

  if [[ "${status}" != "200" ]]; then
    echo "FAIL ${path}: expected HTTP 200, got ${status}"
    FAILURES=$((FAILURES + 1))
  else
    echo "OK   ${path} (200)"
  fi
}

echo "Checking Universal Link routes on ${BASE_URL}"
check_aasa "/.well-known/apple-app-site-association"
check_aasa "/apple-app-site-association"
check_workout_page

if [[ "${FAILURES}" -gt 0 ]]; then
  echo "${FAILURES} check(s) failed."
  exit 1
fi

echo "All checks passed."
