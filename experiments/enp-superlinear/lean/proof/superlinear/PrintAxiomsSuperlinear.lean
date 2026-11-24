/-
Prints the axioms behind the superlinear circuit lower bounds and their sanity lemmas:
    lake build superlinear && lake env lean proof/superlinear/PrintAxiomsSuperlinear.lean
Expected: only propext, Classical.choice and Quot.sound.
-/
import Superlinear.Main
import Superlinear.Sanity
import Superlinear.MainSqrtLog
import Superlinear.General
import Superlinear.PiecesMain

#print axioms Superlinear.corCircuitsSuperlinInf
#print axioms Superlinear.sizeS_superlinear
#print axioms Superlinear.not_hasCircuits
#print axioms Superlinear.corCircuitsSqrtLogInf
#print axioms Superlinear.sizeT_superlinear
#print axioms Superlinear.generalTransfer
#print axioms Superlinear.corCircuitsSqrtLogInf_of_general
#print axioms Superlinear.Pieces.countTransferThm
#print axioms Superlinear.Pieces.piecesTransfer
#print axioms Superlinear.Pieces.piecesTransfer'
#print axioms Superlinear.Pieces.sqrtLog_of_pieces
