module

public import Superlinear.StatementPieces
public import Superlinear.PiecesRateOK
public import Superlinear.PiecesCountTransfer
public import Superlinear.PiecesBridge
import GeneralPieces.Main
import GeneralPieces.Num.Asymptotic
import Mathlib.Tactic

/-! # A counting rate, or a family of pieces, gives a circuit lower bound for E^NP

The theorems whose statements are in `Superlinear/StatementPieces.lean`:
* `countTransfer : ENP.CountTransfer` (proved in `PiecesCountTransfer.lean`);
* `piecesTransfer : ENP.PiecesTransfer`, from `countTransfer`, the regularity of the rates
  1/(log₂(m+2))^α for 0 < α ≤ 1 (`PiecesRateOK.lean`) and the development's rate theorem
  `GeneralPieces.thmRunningTime_c_m`; `piecesTransfer'` is a second proof through
  `Superlinear.generalTransfer` and the count-to-decide bridge (`PiecesBridge.lean`).

Sanity: `sqrtLog_of_pieces` (the statement is not vacuous: at the pieces of Appendix B it is
`ENP.CorCircuitsSqrtLogInf`), `range_of_exist` (the hypothesis forces ½ ≤ ρ < 1 and 0 < α' ≤ 1),
`sizeR_rPow_gen` (the size bound written out), `rateOK_not_absorbs` (the side condition of the
general bridge does not follow from `RateOK`). -/

@[expose] public section

namespace Superlinear.Pieces

open ENP

/-- Any clause rate for #k-SAT gives a circuit lower bound for E^NP. -/
theorem countTransferThm : CountTransfer := fun r hr hc => countTransfer r hr hc

/-- Pieces with parameters (ρ, c) give a circuit lower bound for E^NP with exponent log₂(1/ρ). -/
theorem piecesTransfer : PiecesTransfer := cor_of_pieces

/-- Second proof, through `Superlinear.generalTransfer` and the count-to-decide bridge. -/
theorem piecesTransfer' : PiecesTransfer := cor_of_pieces'

/-- The size bound, written out: ⌊ε·(n+1)·(log₂(n+2))^α⌋. -/
theorem sizeR_rPow_gen (α ε : ℝ) (n : ℕ) :
    sizeR (SatM.rPow α) ε n = ⌊ε * ((n : ℝ) + 1) * Real.logb 2 ((n : ℝ) + 2) ^ α⌋₊ := by
  unfold sizeR SatM.rPow
  rw [div_div_eq_mul_div, div_one]

/-- The range of the hypothesis: pieces exist only for ½ ≤ ρ < 1, and then 0 < α' ≤ 1. -/
theorem range_of_exist {ρ : ℝ} {c : ℕ} (hE : AppRunningTime.Exist ρ c) :
    (1 / 2 ≤ ρ ∧ ρ < 1) ∧ 0 < AppRunningTime.alpha' ρ ∧ AppRunningTime.alpha' ρ ≤ 1 :=
  ⟨GeneralPieces.rho_of_exist hE, alpha'_mem (GeneralPieces.rho_of_exist hE).1 (GeneralPieces.rho_of_exist hE).2⟩

/-- Non-vacuity: at the pieces of Appendix B (ρ = 1/√2) the statement is that of
`Superlinear/StatementSqrtLog.lean`. -/
theorem sqrtLog_of_pieces : CorCircuitsSqrtLogInf := by
  obtain ⟨c, P, A, val, h, -⟩ := AppRunningTime.thmHalfPieces
  obtain ⟨L, hL, ε, hε, hh⟩ := piecesTransfer (1 / Real.sqrt 2) c ⟨P, A, val, h⟩
  have hα : AppRunningTime.alpha' (1 / Real.sqrt 2) = 1 / 2 := GeneralPieces.Asymptotic.alpha_half
  rw [hα] at hh
  refine ⟨L, hL, ε, hε, fun N => ?_⟩
  obtain ⟨n, hn, hd⟩ := hh N
  rw [Superlinear.sizeR_rPow] at hd
  exact ⟨n, hn, hd⟩

/-- `RateOK` alone does not give the side condition of the general bridge: r(m) = 1/(m+1). -/
theorem rateOK_not_absorbs : ∃ r : ℕ → ℝ, RateOK r ∧ ¬Absorbs r := by
  refine ⟨fun m => 1 / ((m : ℝ) + 1), ⟨fun m => by positivity, fun a b hab => ?_, fun a b hab => ?_, ?_⟩, ?_⟩
  · have h : (a : ℝ) ≤ b := by exact_mod_cast hab
    exact one_div_le_one_div_of_le (by positivity) (by linarith)
  · have h : (a : ℝ) ≤ b := by exact_mod_cast hab
    have ha : (0 : ℝ) ≤ a := Nat.cast_nonneg a
    show (a : ℝ) * (1 / ((a : ℝ) + 1)) ≤ (b : ℝ) * (1 / ((b : ℝ) + 1))
    rw [mul_one_div, mul_one_div, div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith
  · exact tendsto_one_div_add_atTop_nhds_zero_nat
  · rintro ⟨a, ha⟩
    have h := ha (2 ^ (a + 1)) Nat.one_le_two_pow
    have ha0 : (0 : ℝ) ≤ a := Nat.cast_nonneg a
    have hpow : (0 : ℝ) < (2 : ℝ) ^ (a + 1) := by positivity
    have e : (2 : ℝ) ^ ((a : ℝ) + 1) = (2 : ℝ) ^ (a + 1) := by
      rw [← Real.rpow_natCast]; push_cast; rfl
    have h1 : (a : ℝ) + 1 ≤ Real.logb 2 (((2 ^ (a + 1) : ℕ) : ℝ) + 2) := by
      rw [Real.le_logb_iff_rpow_le (by norm_num) (by positivity), e]
      push_cast
      linarith
    have h2 : ((2 ^ (a + 1) : ℕ) : ℝ) * (1 / (((2 ^ (a + 1) : ℕ) : ℝ) + 1)) ≤ 1 := by
      rw [mul_one_div, div_le_one (by positivity)]
      linarith
    have h3 := mul_le_mul_of_nonneg_left h2 ha0
    linarith

end Superlinear.Pieces
