#!/usr/bin/env bash
# Clean-room check of the superlinear E^NP lower bound.
# Fresh copy of anthropics/formal-math pinned at commit 11b6c7e, overlay ONLY the new
# files from experiments/enp-superlinear/lean/, build, and print axioms.
# Usage: verify.sh BUILD_DIR   (BUILD_DIR should be on a volume with ~15 GB free)
set -u
BUILD=$1
HERE=$(dirname "$(readlink -f "$0")")
ROOT=$(readlink -f "$HERE/../..")
export PATH="$HOME/.elan/bin:$PATH"; export XDG_CACHE_HOME="$BUILD/.cache"
mkdir -p "$BUILD"
python3 "$ROOT/tools/fetch_tarball.py" anthropics/formal-math "$BUILD" 11b6c7e || exit 1
SRC=$(ls -d "$BUILD"/anthropics-formal-math-*/ | head -1); echo "source tree: $SRC"
case "$SRC" in *11b6c7e*) ;; *) echo "ERROR: source is not commit 11b6c7e"; exit 1;; esac
cp -r "$HERE/lean/proof/superlinear" "$SRC/eth/proof/"
grep -q "name = \"superlinear\"" "$SRC/eth/lakefile.toml" || printf '\n[[lean_lib]]\nname = "superlinear"\nsrcDir = "proof/superlinear"\nglobs = ["Superlinear.+"]\n' >> "$SRC/eth/lakefile.toml"
cd "$SRC/eth"
cat > proof/superlinear/CheckType.lean <<'EOF'
import Superlinear.Main
import Superlinear.Sanity
import Superlinear.MainSqrtLog
import Superlinear.General
import Superlinear.PiecesMain
-- The final theorem has exactly the type of the Mathlib-only statement.
example : ENP.CorCircuitsSuperlinInf := Superlinear.corCircuitsSuperlinInf
#check @Superlinear.corCircuitsSuperlinInf
#print axioms Superlinear.corCircuitsSuperlinInf
#print axioms Superlinear.sizeS_superlinear
example : ENP.CorCircuitsSqrtLogInf := Superlinear.corCircuitsSqrtLogInf
#check @Superlinear.corCircuitsSqrtLogInf
#print axioms Superlinear.corCircuitsSqrtLogInf
#print axioms Superlinear.sizeT_superlinear
example : ENP.GeneralTransfer := Superlinear.generalTransfer
#check @Superlinear.generalTransfer
#print axioms Superlinear.generalTransfer
#print axioms Superlinear.corCircuitsSqrtLogInf_of_general
-- Non-vacuity of the general hypothesis, at the √log rate:
#check (Superlinear.rateOK_rPow : ENP.RateOK (SatM.rPow (1 / 2)))
#check (Superlinear.decidesClauseRate_rPow : ENP.DecidesClauseRate (SatM.rPow (1 / 2)))
-- Added 2026-11-24 (review session): a counting rate, or a family of pieces, gives the bound.
example : ENP.CountTransfer := Superlinear.Pieces.countTransferThm
#check @Superlinear.Pieces.countTransferThm
#print axioms Superlinear.Pieces.countTransferThm
example : ENP.PiecesTransfer := Superlinear.Pieces.piecesTransfer
#check @Superlinear.Pieces.piecesTransfer
#print axioms Superlinear.Pieces.piecesTransfer
#print axioms Superlinear.Pieces.piecesTransfer'
-- Non-vacuity of the pieces statement (it gives the sqrt-log theorem at the Appendix B pieces):
#check (Superlinear.Pieces.sqrtLog_of_pieces : ENP.CorCircuitsSqrtLogInf)
#print axioms Superlinear.Pieces.sqrtLog_of_pieces
#check @Superlinear.Pieces.range_of_exist
EOF
lake exe cache get > "$BUILD/cache.log" 2>&1
lake build superlinear 2>&1 | tail -3
echo "=== build exit ${PIPESTATUS[0]}"
lake env lean proof/superlinear/CheckType.lean
echo "=== check exit $?"
grep -rn "sorry\|^axiom\|native_decide\|implemented_by\|set_option\|unsafe\|opaque\|extern\|macro\|elab" proof/superlinear --include=*.lean | grep -v CheckType || echo "no sorry/axiom/native_decide/implemented_by/set_option/unsafe/opaque/extern/macro/elab in new files"
# Replay every new module's declarations through the kernel again (leanchecker; non-fresh mode, imports from .olean).
for m in Statement StatementSqrtLog StatementGeneral StatementPieces Engine Arith Arith2 ArithGen Host Host2 FormC Chain Main MainSqrtLog Sanity General PiecesRateOK PiecesCountTransfer PiecesBridge PiecesMain; do
  lake env leanchecker "Superlinear.$m" && echo "leanchecker Superlinear.$m OK" || echo "leanchecker Superlinear.$m FAILED"
done
