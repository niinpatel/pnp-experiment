module

public import Superlinear.Main
import Mathlib.Tactic

/-! # Sanity checks on the statement

* `sizeS_superlinear`: for every ε > 0 and every K, `sizeS ε n ≥ K·(n+1)` for all large n. So the
  size bound of `CorCircuitsSuperlinInf` is genuinely superlinear, and the statement is not vacuous
  (for instance it is not satisfied by a size bound that is 0 or linear).
* `not_hasCircuits`: the corollary in the form of `ENP.HasCircuits` of
  `CircuitLowerBoundStatement.lean`: some language in E^NP does not have circuits of size
  `sizeS ε` for some ε > 0.
* `corCircuits_of_superlin`: the superlinear statement implies the linear one, `ENP.CorCircuits`. -/

public section

namespace Superlinear

open ENP

/-- For every ε > 0 and every K, `K·(n+1) ≤ sizeS ε n` for all large n. -/
theorem sizeS_superlinear {ε : ℝ} (hε : 0 < ε) (K : ℕ) : ∃ N₀ : ℕ, ∀ n : ℕ, N₀ ≤ n → K * (n + 1) ≤ sizeS ε n := by
  obtain ⟨M, hM⟩ := ratio_small (η := ε / (2 * K + 2)) (by positivity)
  refine ⟨M, fun n hn => ?_⟩
  have hn0 : (0 : ℝ) ≤ n := by positivity
  have hL := LL_ge hn0
  have hQ := L2_ge hn0
  have hR0 : 0 < Real.sqrt (LL n) := Real.sqrt_pos.2 (by linarith)
  -- √(log₂(n+2)) ≥ √(LL n)/2
  have h1 : LL n / 4 ≤ Real.logb 2 ((n : ℝ) + 2) := by
    have h2 : LL n ≤ Real.logb 2 (2 * ((n : ℝ) + 2)) := Real.logb_le_logb_of_le one_lt_two (by linarith) (by linarith)
    rw [Real.logb_mul (by norm_num) (by linarith), Real.logb_self_eq_one one_lt_two] at h2
    linarith
  have h3 : Real.sqrt (LL n) / 2 ≤ Real.sqrt (Real.logb 2 ((n : ℝ) + 2)) := by
    have h4 : Real.sqrt (LL n / 4) = Real.sqrt (LL n) / 2 := by
      rw [Real.sqrt_div' _ (by norm_num : (0 : ℝ) ≤ 4), show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
    rw [← h4]
    exact Real.sqrt_le_sqrt h1
  -- √(LL n)/log₂(LL n) ≥ (2K+2)/ε
  have h5 : Real.logb 2 (LL n) / Real.sqrt (LL n) ≤ ε / (2 * K + 2) := hM n hn
  have h6 : (2 * K + 2) / ε * Real.logb 2 (LL n) ≤ Real.sqrt (LL n) := by
    rw [div_le_iff₀ hR0] at h5
    rw [div_mul_eq_mul_div, div_le_iff₀ hε]
    have : (0 : ℝ) < 2 * K + 2 := by positivity
    calc (2 * (K : ℝ) + 2) * Real.logb 2 (LL n) ≤ (2 * K + 2) * (ε / (2 * K + 2) * Real.sqrt (LL n)) := by gcongr
      _ = Real.sqrt (LL n) * ε := by field_simp
  apply Nat.le_floor
  have h7 : ((K * (n + 1) : ℕ) : ℝ) = (K : ℝ) * ((n : ℝ) + 1) := by push_cast; ring
  show ((K * (n + 1) : ℕ) : ℝ) ≤ ε * ((n : ℝ) + 1) * Real.sqrt (Real.logb 2 ((n : ℝ) + 2)) / Real.logb 2 (LL n)
  rw [h7, le_div_iff₀ (by linarith)]
  have h8 : (K : ℝ) * Real.logb 2 (LL n) ≤ ε * Real.sqrt (Real.logb 2 ((n : ℝ) + 2)) := by
    have h9 : (2 * K + 2) / ε * Real.logb 2 (LL n) ≤ 2 * Real.sqrt (Real.logb 2 ((n : ℝ) + 2)) := by linarith
    have h10 : ε * ((2 * K + 2) / ε * Real.logb 2 (LL n)) = (2 * K + 2) * Real.logb 2 (LL n) := by field_simp
    have h11 := mul_le_mul_of_nonneg_left h9 hε.le
    rw [h10] at h11
    nlinarith
  have : (0 : ℝ) < (n : ℝ) + 1 := by linarith
  nlinarith

/-- The corollary in the form of `ENP.HasCircuits`: some language in E^NP does not have circuits of
size `sizeS ε` for some ε > 0. -/
theorem not_hasCircuits : ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ¬HasCircuits L (sizeS ε) := by
  obtain ⟨L, hL, ε, hε, h⟩ := corCircuitsSuperlinInf
  refine ⟨L, hL, ε, hε, fun hc => ?_⟩
  obtain ⟨n, -, hn⟩ := h 0
  exact hn (hc n)

/-- The superlinear statement implies the linear one of `CircuitLowerBoundStatement.lean`. -/
theorem corCircuits_of_superlin (h : CorCircuitsSuperlinInf) : CorCircuits := by
  obtain ⟨L, hL, ε, hε, h⟩ := h
  refine ⟨L, hL, fun ⟨c, hc⟩ => ?_⟩
  obtain ⟨N₀, hN₀⟩ := sizeS_superlinear hε c
  obtain ⟨n, hn, hd⟩ := h N₀
  obtain ⟨C, hC, hCd⟩ := hc n
  exact hd ⟨C, hC.trans (hN₀ n hn), hCd⟩

end Superlinear
