module

public import RecursionWithPieces.Main
public import VariableBound.Paper.Rename.Code
public import CountKSatRate.Pad
public import CircuitLowerBound.Alg.Time
public import CountKSat.InOut
import Mathlib.Tactic

/-! Smoke test: the explicit-rate padded algorithm and the padding machine are reachable. -/

public section

namespace Superlinear

open Groundwork Groundwork.Prog Turing VariableBound VariableBound.Decide

/-- The explicit-rate algorithm, as a function-level padded descent object. -/
theorem exists_alg : ∃ (A : List Bool × PaddedDescent.F.U → List Bool) (e : List Bool → ℕ),
    Alg (SatK.rN 1 (1 / 2)) (SatM.rPow (1 / 2)) A e :=
  let ⟨_, _, _, _, h⟩ := RecursionWithPieces.tiedAllCal
  ⟨_, _, h.alg⟩

/-- The padding machine is available. -/
theorem padded : CountKSatRate.StPaddedW := CountKSatRate.stPaddedW

example {k n : ℕ} (φ : Sat3.CNF n) :
    VariableBound.Rename.encN (List.replicate k ()) (List.replicate n (), Groundwork.Decode.toN φ) = SatM.enc k φ :=
  VariableBound.Rename.encN_toN k φ

example : CountKSat.StCntToN := CountKSat.stCntToN

end Superlinear
