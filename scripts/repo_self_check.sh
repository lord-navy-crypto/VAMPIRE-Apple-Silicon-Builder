#!/bin/zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

required=(
  README.md
  LICENSE
  THIRD_PARTY_NOTICES.md
  CHANGELOG.md
  config/build.env
  START.command
  scripts/build_and_install.sh
  scripts/verify_install.sh
  scripts/collect_diagnostics.sh
  scripts/uninstall.sh
)

for f in "${required[@]}"; do
  [[ -f "$f" ]] || { echo "FAIL: missing $f"; exit 1; }
done

zsh -n START.command
for f in scripts/*.sh; do
  zsh -n "$f"
done

REF="$(grep '^VAMPIRE_REF=' config/build.env | cut -d= -f2-)"
if ! printf '%s\n' "$REF" | grep -Eq '^[0-9a-f]{40}$'; then
  echo "FAIL: VAMPIRE_REF must be a pinned 40-character Git commit SHA"
  exit 2
fi

if find . -type f \( -name 'vampire-serial' -o -name 'vampire-parallel' -o -name '*.dylib' -o -name '*.so' \) -print | grep -q .; then
  echo "FAIL: compiled VAMPIRE/native binary detected in repository"
  exit 3
fi

if [[ ! -x START.command ]]; then
  echo "FAIL: START.command is not executable"
  exit 4
fi

for f in scripts/*.sh; do
  [[ -x "$f" ]] || { echo "FAIL: $f is not executable"; exit 5; }
done

echo "PASS: repository structure"
echo "PASS: zsh syntax"
echo "PASS: pinned upstream commit $REF"
echo "PASS: no compiled VAMPIRE binary bundled"
echo "PASS: executable permissions"
echo "REPOSITORY SELF-CHECK PASS"
