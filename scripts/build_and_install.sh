#!/bin/zsh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$ROOT/config/build.env"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: missing $CONFIG"
  exit 1
fi

set -a
source "$CONFIG"
set +a

ts() { date '+%H:%M:%S'; }
say() { echo "[$(ts)] $*"; }

run_live() {
  local label="$1"
  shift
  say "BEGIN: $label"
  "$@" &
  local pid=$!
  local elapsed=0
  while kill -0 "$pid" 2>/dev/null; do
    sleep "$HEARTBEAT_SECONDS"
    if kill -0 "$pid" 2>/dev/null; then
      elapsed=$((elapsed + HEARTBEAT_SECONDS))
      say "WORKING: $label (${elapsed}s elapsed; pid=$pid)"
    fi
  done
  if wait "$pid"; then
    say "DONE: $label"
  else
    local rc=$?
    say "FAILED: $label (exit=$rc)"
    return "$rc"
  fi
}

ARCH="$(uname -m)"
say "Detected architecture: $ARCH"
if [[ "$ARCH" != "arm64" ]]; then
  say "ERROR: this builder is Apple Silicon arm64 only."
  exit 2
fi

say "Checking Apple Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  say "Command Line Tools are missing."
  xcode-select --install || true
  say "After installation finishes, launch START.command again."
  exit 3
fi
say "Command Line Tools: $(xcode-select -p)"

for cmd in git make clang++ sed file otool codesign tee; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    say "ERROR: required command not found: $cmd"
    exit 4
  fi
done

say "Compiler: $(clang++ --version | head -n 1)"
say "Git: $(git --version)"

if [[ "$BUILD_JOBS" == "auto" ]]; then
  JOBS="$(sysctl -n hw.logicalcpu 2>/dev/null || echo 4)"
else
  JOBS="$BUILD_JOBS"
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
WORK="$HOME/Library/Caches/vampire-apple-silicon-builder/work-$STAMP"
SRC="$WORK/vampire"
SMOKE="$WORK/smoke"
LOG="$ROOT/logs/build-$STAMP.log"
mkdir -p "$SRC" "$ROOT/logs"

exec > >(tee -a "$LOG") 2>&1

echo
echo "============================================================"
echo "VAMPIRE Apple Silicon Builder v0.1.3"
echo "============================================================"
say "Architecture : $ARCH"
say "Repository   : $VAMPIRE_REPOSITORY"
say "Pinned ref   : $VAMPIRE_REF"
say "Install path : $INSTALL_PREFIX"
say "Build jobs   : $JOBS"
say "Heartbeat    : ${HEARTBEAT_SECONDS}s"
say "Smoke test   : $RUN_SMOKE_TEST"
say "Log          : $LOG"
echo

say "STAGE 1/10: initialize local source directory"
cd "$SRC"
git init
git remote add origin "$VAMPIRE_REPOSITORY"

say "STAGE 2/10: download pinned VAMPIRE source"
if ! run_live "git fetch $VAMPIRE_REF" git fetch --depth 1 --progress origin "$VAMPIRE_REF"; then
  say "Direct commit fetch failed; retrying normal fetch of main"
  run_live "git fetch fallback main" git fetch --depth 1 --progress origin main
  git checkout --detach "$VAMPIRE_REF"
else
  git checkout --detach FETCH_HEAD
fi

COMMIT="$(git rev-parse HEAD)"
say "Resolved source commit: $COMMIT"

if [[ "$COMMIT" != "$VAMPIRE_REF" ]]; then
  say "ERROR: resolved commit does not match pinned ref"
  exit 9
fi

if [[ ! -f makefile ]]; then
  say "ERROR: upstream makefile not found"
  exit 10
fi

say "STAGE 3/10: inspect upstream LLVM target"
grep -n '^LLVM=' makefile || true
grep -n '^LLVM_CFLAGS=' makefile || true
grep -n '^LLVM_LDFLAGS=' makefile || true
grep -n '^serial-llvm:' makefile || true

say "STAGE 4/10: select Apple clang++ for upstream LLVM target"
cp makefile makefile.upstream
sed -i '' 's/^LLVM=g++ /LLVM=clang++ /' makefile
grep -n '^LLVM=' makefile || true

if ! grep -q '^LLVM=clang++ ' makefile; then
  say "ERROR: compiler substitution did not apply"
  exit 10
fi

say "STAGE 5/10: clean previous object files"
make clean || true

say "STAGE 6/10: compile VAMPIRE serial-llvm"
run_live "make serial-llvm" make serial-llvm -j"$JOBS"

if [[ ! -x vampire-serial ]]; then
  say "ERROR: vampire-serial was not produced"
  exit 11
fi

say "STAGE 7/10: verify native Apple Silicon architecture"
INFO="$(file vampire-serial)"
echo "$INFO"
if ! echo "$INFO" | grep -q 'arm64'; then
  say "ERROR: built binary is not arm64"
  exit 12
fi
say "Linked libraries:"
otool -L vampire-serial || true

say "STAGE 8/10: install into user-local prefix"
rm -rf "$INSTALL_PREFIX"
mkdir -p "$INSTALL_PREFIX/bin" "$INSTALL_PREFIX/examples" "$INSTALL_PREFIX/licenses" "$INSTALL_PREFIX/build-info"
cp vampire-serial "$INSTALL_PREFIX/bin/vampire-serial"
cp input "$INSTALL_PREFIX/examples/input"
cp Co.mat "$INSTALL_PREFIX/examples/Co.mat"
cp license "$INSTALL_PREFIX/licenses/license" 2>/dev/null || true
cp BSD_licence "$INSTALL_PREFIX/licenses/BSD_licence" 2>/dev/null || true
cp readme.md "$INSTALL_PREFIX/build-info/upstream-readme.md" 2>/dev/null || true
cp makefile.upstream "$INSTALL_PREFIX/build-info/makefile.upstream"
cp makefile "$INSTALL_PREFIX/build-info/makefile.apple-silicon"

cat > "$INSTALL_PREFIX/bin/vampire" <<'EOF'
#!/bin/zsh
HERE="$(cd "$(dirname "$0")" && pwd)"
exec "$HERE/vampire-serial" "$@"
EOF
chmod +x "$INSTALL_PREFIX/bin/vampire"
codesign --force --sign - "$INSTALL_PREFIX/bin/vampire-serial" >/dev/null 2>&1 || true

CLANG_VERSION="$(clang++ --version | head -n 1)"
cat > "$INSTALL_PREFIX/build-info/source.lock" <<EOF
repository=$VAMPIRE_REPOSITORY
requested_ref=$VAMPIRE_REF
resolved_commit=$COMMIT
architecture=$ARCH
compiler=$CLANG_VERSION
build_target=serial-llvm
builder_version=0.1.3
built_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

PROFILE="$HOME/.zprofile"
PATH_LINE='export PATH="$HOME/.local/vampire-apple-silicon/bin:$PATH"'
touch "$PROFILE"
if ! grep -Fq "$PATH_LINE" "$PROFILE"; then
  printf '\n%s\n' "$PATH_LINE" >> "$PROFILE"
fi

say "STAGE 9/10: installation verification"
"$ROOT/scripts/verify_install.sh"

say "STAGE 10/10: official sample smoke test"
if [[ "$RUN_SMOKE_TEST" == "1" ]]; then
  rm -rf "$SMOKE"
  mkdir -p "$SMOKE"
  cp "$INSTALL_PREFIX/examples/input" "$SMOKE/input"
  cp "$INSTALL_PREFIX/examples/Co.mat" "$SMOKE/Co.mat"
  cd "$SMOKE"
  if run_live "VAMPIRE sample simulation" "$INSTALL_PREFIX/bin/vampire-serial"; then
    if [[ -f "$SMOKE/output" ]]; then
      say "SMOKE PASS: sample simulation exited successfully and produced output"
      cp "$SMOKE/output" "$INSTALL_PREFIX/build-info/smoke-output.txt"
      cp "$SMOKE/log" "$INSTALL_PREFIX/build-info/smoke-log.txt" 2>/dev/null || true
    else
      say "SMOKE FAIL: process exited successfully but no output file was produced"
      exit 30
    fi
  else
    say "SMOKE FAIL: official sample simulation returned nonzero status"
    exit 31
  fi
else
  say "Smoke test disabled by configuration"
fi

echo
echo "============================================================"
echo "SUCCESS"
echo "============================================================"
say "Installed at: $INSTALL_PREFIX"
say "Pinned/verified commit: $COMMIT"
say "Build log: $LOG"
say "Open a new Terminal and run: vampire"
echo
open "$INSTALL_PREFIX" >/dev/null 2>&1 || true
