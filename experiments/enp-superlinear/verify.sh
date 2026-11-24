#!/usr/bin/env bash
# Clean-room check of the superlinear E^NP lower bound.
# Fresh copy of anthropics/formal-math (default branch; developed against commit 11b6c7e), overlay ONLY the new
# files from experiments/enp-superlinear/lean/, build, and print axioms.
# Usage: verify.sh BUILD_DIR   (BUILD_DIR should be on a volume with ~15 GB free)
set -u
BUILD=$1
HERE=$(dirname "$(readlink -f "$0")")
ROOT=$(readlink -f "$HERE/../..")
export PATH="$HOME/.elan/bin:$PATH"; export XDG_CACHE_HOME="$BUILD/.cache"
mkdir -p "$BUILD"
python3 "$ROOT/tools/fetch_tarball.py" anthropics/formal-math "$BUILD" || exit 1
SRC=$(ls -d "$BUILD"/anthropics-formal-math-*/ | head -1); echo "source tree: $SRC"
cp -r "$HERE/lean/proof/superlinear" "$SRC/eth/proof/"
cp "$HERE/lean/lakefile.toml" "$SRC/eth/lakefile.toml"
cd "$SRC/eth"
cat > proof/superlinear/CheckType.lean <<'EOF'
import Superlinear.Main
import Superlinear.Sanity
-- The final theorem has exactly the type of the Mathlib-only statement.
example : ENP.CorCircuitsSuperlinInf := Superlinear.corCircuitsSuperlinInf
#check @Superlinear.corCircuitsSuperlinInf
#print axioms Superlinear.corCircuitsSuperlinInf
#print axioms Superlinear.sizeS_superlinear
EOF
lake exe cache get > "$BUILD/cache.log" 2>&1
lake build superlinear 2>&1 | tail -3
echo "=== build exit ${PIPESTATUS[0]}"
lake env lean proof/superlinear/CheckType.lean
echo "=== check exit $?"
grep -rn "sorry\|^axiom\|native_decide\|implemented_by" proof/superlinear || echo "no sorry/axiom/native_decide/implemented_by in new files"
