module

public import Superlinear.Host2
public import Superlinear.Sanity
import Mathlib.Tactic

/-! # The circuit lower bound ε·n·√(log n) for E^NP

* `corCircuitsSqrtLogInf`: the statement of `Superlinear/StatementSqrtLog.lean`, from `stAlgT`
  (the engine with the clause rate) and the chain argument `no_circuits_gen`.
* `sizeT_superlinear`: for every ε > 0 and every K, `K·(n+1) ≤ sizeT ε n` for all large n (the
  statement is not vacuous).
* `sizeS_le_sizeT`: `sizeS ε n ≤ sizeT ε n`, so this bound implies `CorCircuitsSuperlinInf`
  (`corCircuitsSuperlinInf_of_sqrtLog`). -/

public section

namespace Superlinear

open ENP CircuitLowerBound

/-- **The circuit lower bound ε·n·√(log n) for E^NP, infinitely often.** There are a language in
E^NP (the language `L0` of proof/consequences/CircuitLowerBound) and ε > 0 such that, for infinitely
many lengths n, no circuit with at most ⌊ε·(n+1)·√(log₂(n+2))⌋ gates decides it on the words of
length n. -/
theorem corCircuitsSqrtLogInf : CorCircuitsSqrtLogInf :=
  let ⟨ε, hε, hAlg⟩ := stAlgT
  ⟨L0, stENP, ε, hε, no_circuits_gen stTab stCode stChain stVars stGreedy hAlg⟩

/-- For every ε > 0 and every K, `K·(n+1) ≤ sizeT ε n` for all large n. -/
theorem sizeT_superlinear {ε : ℝ} (hε : 0 < ε) (K : ℕ) : ∃ N₀ : ℕ, ∀ n : ℕ, N₀ ≤ n → K * (n + 1) ≤ sizeT ε n := by
  obtain ⟨M, hM⟩ := inv_sqrt_small (K := (K : ℝ)) (by positivity) hε
  refine ⟨M, fun n hn => ?_⟩
  have hn0 : (0 : ℝ) ≤ n := by positivity
  have hR0 : 0 < Real.sqrt (L2 n) := Real.sqrt_pos.2 (by linarith [L2c_ge hn0])
  have h1 : (K : ℝ) ≤ ε * Real.sqrt (L2 n) := by
    have := hM n hn
    rw [div_le_iff₀ hR0] at this
    linarith
  apply Nat.le_floor
  show ((K * (n + 1) : ℕ) : ℝ) ≤ ε * ((n : ℝ) + 1) * Real.sqrt (L2 n)
  push_cast
  have : (0 : ℝ) < (n : ℝ) + 1 := by linarith
  nlinarith

/-- `sizeS ε n ≤ sizeT ε n`: the bound of `StatementSqrtLog.lean` is at least the one of
`Statement.lean`. -/
theorem sizeS_le_sizeT {ε : ℝ} (hε : 0 < ε) (n : ℕ) : sizeS ε n ≤ sizeT ε n := by
  apply Nat.floor_le_floor
  have hn0 : (0 : ℝ) ≤ n := by positivity
  have hQ := L2_ge hn0
  have hX : 0 ≤ ε * ((n : ℝ) + 1) * Real.sqrt (Real.logb 2 ((n : ℝ) + 2)) := by positivity
  change ε * ((n : ℝ) + 1) * Real.sqrt (Real.logb 2 ((n : ℝ) + 2)) / Real.logb 2 (LL n) ≤ _
  exact div_le_self hX hQ

/-- The bound ε·n·√(log n) implies the bound ε·n·√(log n)/log log n. -/
theorem corCircuitsSuperlinInf_of_sqrtLog (h : CorCircuitsSqrtLogInf) : CorCircuitsSuperlinInf := by
  obtain ⟨L, hL, ε, hε, h⟩ := h
  refine ⟨L, hL, ε, hε, fun N => ?_⟩
  obtain ⟨n, hn, hd⟩ := h N
  exact ⟨n, hn, fun ⟨C, hC, hCd⟩ => hd ⟨C, hC.trans (sizeS_le_sizeT hε n), hCd⟩⟩

end Superlinear
