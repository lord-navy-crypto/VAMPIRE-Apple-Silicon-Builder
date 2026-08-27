#!/bin/zsh
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$HOME/Desktop/VAMPIRE_Apple_Silicon_Diagnostics.txt"
{
  echo "VAMPIRE Apple Silicon Builder v0.1.3 diagnostics"
  echo "Generated: $(date)"
  echo
  echo "ARCH"
  uname -m
  echo
  echo "SYSTEM"
  sw_vers
  echo
  echo "XCODE"
  xcode-select -p 2>&1
  echo
  echo "CLANG"
  clang++ --version 2>&1
  echo
  echo "GIT"
  git --version 2>&1
  echo
  echo "MAKE"
  make --version 2>&1 | head -n 3
  echo
  echo "LATEST BUILD LOG"
  LATEST="$(ls -t "$ROOT"/logs/build-*.log 2>/dev/null | head -n 1 || true)"
  if [[ -n "$LATEST" ]]; then
    echo "$LATEST"
    tail -n 300 "$LATEST"
  else
    echo "No build log found."
  fi
  echo
  echo "INSTALLED SOURCE LOCK"
  cat "$HOME/.local/vampire-apple-silicon/build-info/source.lock" 2>/dev/null || true
  echo
  echo "SMOKE OUTPUT"
  tail -n 80 "$HOME/.local/vampire-apple-silicon/build-info/smoke-output.txt" 2>/dev/null || true
} > "$OUT"
echo "Diagnostics written to: $OUT"
open -R "$OUT" >/dev/null 2>&1 || true
