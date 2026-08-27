#!/bin/zsh
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
echo "[$(date '+%H:%M:%S')] Launcher started"
echo "[$(date '+%H:%M:%S')] Package: $HERE"
exec "$HERE/scripts/build_and_install.sh"
