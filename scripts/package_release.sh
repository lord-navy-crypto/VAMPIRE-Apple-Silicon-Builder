#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

./scripts/repo_self_check.sh

VERSION="$(tr -d '[:space:]' < VERSION)"
NAME="VAMPIRE_Apple_Silicon_Builder_v${VERSION}"
OUTDIR="$ROOT/release"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$OUTDIR" "$TMP/$NAME"

rsync -a \
  --exclude '.git' \
  --exclude '.DS_Store' \
  --exclude 'logs/*' \
  --exclude 'release/*' \
  "$ROOT/" "$TMP/$NAME/"
mkdir -p "$TMP/$NAME/logs"
touch "$TMP/$NAME/logs/.gitkeep"

cd "$TMP"
ditto -c -k --keepParent "$NAME" "$OUTDIR/$NAME.zip"
shasum -a 256 "$OUTDIR/$NAME.zip" > "$OUTDIR/$NAME.zip.sha256"

echo "Created: $OUTDIR/$NAME.zip"
echo "Checksum: $OUTDIR/$NAME.zip.sha256"
