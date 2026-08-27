#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
set -a
source "$ROOT/config/build.env"
set +a
rm -rf "$INSTALL_PREFIX"
echo "Removed: $INSTALL_PREFIX"
