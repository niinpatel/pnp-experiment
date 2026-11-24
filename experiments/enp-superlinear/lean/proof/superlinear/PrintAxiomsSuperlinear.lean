/-
Prints the axioms behind the superlinear circuit lower bound and its sanity lemma:
    lake build Superlinear.Main Superlinear.Sanity && lake env lean proof/superlinear/PrintAxiomsSuperlinear.lean
Expected: only propext, Classical.choice and Quot.sound.
-/
import Superlinear.Main
import Superlinear.Sanity

#print axioms Superlinear.corCircuitsSuperlinInf
#print axioms Superlinear.sizeS_superlinear
#print axioms Superlinear.not_hasCircuits
