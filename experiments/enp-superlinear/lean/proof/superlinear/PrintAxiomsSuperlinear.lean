/-
Prints the axioms behind the superlinear circuit lower bounds and their sanity lemmas:
    lake build Superlinear.Main Superlinear.Sanity Superlinear.MainSqrtLog && lake env lean proof/superlinear/PrintAxiomsSuperlinear.lean
Expected: only propext, Classical.choice and Quot.sound.
-/
import Superlinear.Main
import Superlinear.Sanity
import Superlinear.MainSqrtLog

#print axioms Superlinear.corCircuitsSuperlinInf
#print axioms Superlinear.sizeS_superlinear
#print axioms Superlinear.not_hasCircuits
#print axioms Superlinear.corCircuitsSqrtLogInf
#print axioms Superlinear.sizeT_superlinear
