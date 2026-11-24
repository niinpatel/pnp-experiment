#!/usr/bin/env bash
# Fetch anthropics/formal-math and rebuild the eth/ and vp-vnp/ Lean projects independently.
# Usage: setup_lean_build.sh BUILD_DIR LOG_DIR
set -u
BUILD=$1; LOGS=$2
HERE=$(dirname "$(readlink -f "$0")")
mkdir -p "$BUILD" "$LOGS"
python3 "$HERE/fetch_tarball.py" anthropics/formal-math "$BUILD" > "$LOGS/fetch.log" 2>&1
if [ ! -x "$HOME/.elan/bin/elan" ]; then
  curl -sSf "https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh" -o "$BUILD/elan-init.sh"
  bash "$BUILD/elan-init.sh" -y --default-toolchain none > "$LOGS/elan.log" 2>&1
fi
export PATH="$HOME/.elan/bin:$PATH"
SRC=$(ls -d "$BUILD"/anthropics-formal-math-*/ | head -1)
echo "source: $SRC" > "$LOGS/summary.log"
for proj in eth vp-vnp; do
  cd "$SRC/$proj" || continue
  { echo "=== $proj start $(date -u)"; cat lean-toolchain
    lake exe cache get
    /usr/bin/time -v lake build
    echo "=== build exit $?"
    lake env lean scripts/PrintAxioms.lean
    echo "=== axioms exit $? end $(date -u)"
  } > "$LOGS/$proj.log" 2>&1
  { echo "--- $proj"; grep -E "^===|depends on axioms|error|Maximum resident|Elapsed" "$LOGS/$proj.log" | tail -20; } >> "$LOGS/summary.log"
done
echo DONE >> "$LOGS/summary.log"
