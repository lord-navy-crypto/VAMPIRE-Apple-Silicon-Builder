#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
set -a
source "$ROOT/config/build.env"
set +a
BIN="$INSTALL_PREFIX/bin/vampire-serial"

echo "[$(date '+%H:%M:%S')] VERIFY: $BIN"
[[ -x "$BIN" ]] || { echo "VERIFY FAIL: binary missing"; exit 20; }

INFO="$(file "$BIN")"
echo "$INFO"
echo "$INFO" | grep -q 'arm64' || { echo "VERIFY FAIL: not arm64"; exit 21; }

echo
echo "Linked libraries:"
otool -L "$BIN" || true

echo
echo "Source lock:"
cat "$INSTALL_PREFIX/build-info/source.lock"

echo
echo "VERIFY PASS"
