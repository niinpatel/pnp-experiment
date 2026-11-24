module

public import RecursionWithPieces.Main
public import VariableBound.Paper.Rename.Code
public import CountKSatRate.Pad
public import CircuitLowerBound.Alg.Time
public import CountKSat.InOut
import Mathlib.Tactic

/-! # The engine with the explicit rate, and the padding machine

* `exists_alg`: the algorithm (A, e) of `RecursionWithPieces.tiedAllCal` for the rates
  rN(n) = log₂ log₂(n+4)/√(log₂(n+4)) and 1/√(log₂(m+2)), in the sense of
  `VariableBound.Decide.Alg`: A is a polynomial-time function of (input, pad), correct on the code of
  every k-CNF when the pad has at least 2^(e x) units, and the steps of the padding machine are
  within the bound in n.
* `padded`: the padding machine `CountKSatRate.stPaddedW`.
The two `example`s check the facts that the host uses: the code `Rename.encN` of a formula is
`SatM.enc`, and the count `cntN` is `SatK.numSat`. -/

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
