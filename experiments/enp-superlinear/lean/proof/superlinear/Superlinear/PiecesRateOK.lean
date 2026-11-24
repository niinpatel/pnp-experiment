module

public import Superlinear.StatementGeneral
import Mathlib.Tactic

/-! # `ENP.RateOK (SatM.rPow α)` for 0 < α ≤ 1

`rPow α m = 1 / (log₂(m+2))^α`. The four conjuncts of `RateOK`:
positive, antitone, m·r(m) monotone, r → 0. Only the third needs α ≤ 1; only the fourth needs
0 < α. -/

@[expose] public section

namespace Superlinear.Pieces

open ENP

/-- a·ln(b+2) ≤ b·ln(a+2) for 0 ≤ a ≤ b: ln(x+2)/x is antitone. -/
theorem mul_log_le {a b : ℝ} (ha : 0 ≤ a) (hab : a ≤ b) : a * Real.log (b + 2) ≤ b * Real.log (a + 2) := by
  have ha2 : 0 < a + 2 := by linarith
  have hb2 : 0 < b + 2 := by linarith
  have h1 : Real.log ((b + 2) / (a + 2)) ≤ (b + 2) / (a + 2) - 1 := Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div hb2.ne' ha2.ne'] at h1
  have h2 : 1 - (a + 2)⁻¹ ≤ Real.log (a + 2) := Real.one_sub_inv_le_log_of_pos ha2
  have h3 : (b + 2) / (a + 2) - 1 = (b - a) / (a + 2) := by field_simp; ring
  have h3' : a / (a + 2) ≤ 1 - (a + 2)⁻¹ := by
    have : 1 - (a + 2)⁻¹ = (a + 1) / (a + 2) := by field_simp; ring
    rw [this]
    exact div_le_div_of_nonneg_right (by linarith) ha2.le
  have hba : 0 ≤ b - a := by linarith
  have h4 : a * ((b - a) / (a + 2)) ≤ (b - a) * Real.log (a + 2) := by
    calc a * ((b - a) / (a + 2)) = (b - a) * (a / (a + 2)) := by ring
      _ ≤ (b - a) * Real.log (a + 2) := mul_le_mul_of_nonneg_left (by linarith) hba
  have h5 : a * Real.log (b + 2) ≤ a * (Real.log (a + 2) + (b - a) / (a + 2)) :=
    mul_le_mul_of_nonneg_left (by linarith) ha
  have h6 : a * (Real.log (a + 2) + (b - a) / (a + 2)) = a * Real.log (a + 2) + a * ((b - a) / (a + 2)) := by ring
  have h7 : (b - a) * Real.log (a + 2) = b * Real.log (a + 2) - a * Real.log (a + 2) := by ring
  linarith

/-- 1 ≤ log₂(m+2). -/
theorem one_le_L (m : ℕ) : 1 ≤ Real.logb 2 ((m : ℝ) + 2) := by
  have hm : (0 : ℝ) ≤ m := Nat.cast_nonneg m
  have h : Real.logb 2 2 ≤ Real.logb 2 ((m : ℝ) + 2) := Real.logb_le_logb_of_le (by norm_num) (by norm_num) (by linarith)
  rwa [Real.logb_self_eq_one (by norm_num)] at h

/-- log₂(a+2) ≤ log₂(b+2) for a ≤ b. -/
theorem L_mono {a b : ℕ} (hab : a ≤ b) : Real.logb 2 ((a : ℝ) + 2) ≤ Real.logb 2 ((b : ℝ) + 2) := by
  have ha : (0 : ℝ) ≤ a := Nat.cast_nonneg a
  have h : (a : ℝ) ≤ b := by exact_mod_cast hab
  exact Real.logb_le_logb_of_le (by norm_num) (by linarith) (by linarith)

/-- a·log₂(b+2) ≤ b·log₂(a+2) for naturals a ≤ b. -/
theorem mul_L_le {a b : ℕ} (hab : a ≤ b) : (a : ℝ) * Real.logb 2 ((b : ℝ) + 2) ≤ (b : ℝ) * Real.logb 2 ((a : ℝ) + 2) := by
  have ha : (0 : ℝ) ≤ a := Nat.cast_nonneg a
  have h : (a : ℝ) ≤ b := by exact_mod_cast hab
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have key := mul_log_le ha h
  unfold Real.logb
  rw [← mul_div_assoc, ← mul_div_assoc]
  exact div_le_div_of_nonneg_right key h2.le

theorem rPow_pos (α : ℝ) (m : ℕ) : 0 < SatM.rPow α m := by
  unfold SatM.rPow
  have := one_le_L m
  have : 0 < Real.logb 2 ((m : ℝ) + 2) ^ α := Real.rpow_pos_of_pos (by linarith) α
  positivity

/-- `RateOK (rPow α)` for 0 < α ≤ 1. -/
theorem rateOK_rPow_gen {α : ℝ} (h0 : 0 < α) (h1 : α ≤ 1) : RateOK (SatM.rPow α) := by
  refine ⟨rPow_pos α, fun a b hab => ?_, fun a b hab => ?_, ?_⟩
  · unfold SatM.rPow
    have ha := one_le_L a
    have hp : 0 < Real.logb 2 ((a : ℝ) + 2) ^ α := Real.rpow_pos_of_pos (by linarith) α
    exact one_div_le_one_div_of_le hp (Real.rpow_le_rpow (by linarith) (L_mono hab) h0.le)
  · show (a : ℝ) * SatM.rPow α a ≤ (b : ℝ) * SatM.rPow α b
    unfold SatM.rPow
    have hLa := one_le_L a
    have hLb := one_le_L b
    have hLa0 : 0 < Real.logb 2 ((a : ℝ) + 2) := by linarith
    have hLb0 : 0 < Real.logb 2 ((b : ℝ) + 2) := by linarith
    have hpa : 0 < Real.logb 2 ((a : ℝ) + 2) ^ α := Real.rpow_pos_of_pos hLa0 α
    have hpb : 0 < Real.logb 2 ((b : ℝ) + 2) ^ α := Real.rpow_pos_of_pos hLb0 α
    have ha : (0 : ℝ) ≤ a := Nat.cast_nonneg a
    have key := mul_L_le hab
    have hq : 1 ≤ Real.logb 2 ((b : ℝ) + 2) / Real.logb 2 ((a : ℝ) + 2) := (one_le_div hLa0).2 (L_mono hab)
    have hpow := Real.rpow_le_rpow_of_exponent_le hq h1
    rw [Real.rpow_one, Real.div_rpow hLb0.le hLa0.le, div_le_iff₀ hpa] at hpow
    rw [mul_one_div, mul_one_div, div_le_div_iff₀ hpa hpb]
    have h8 : (a : ℝ) * (Real.logb 2 ((b : ℝ) + 2) / Real.logb 2 ((a : ℝ) + 2)) ≤ b := by
      rw [← mul_div_assoc, div_le_iff₀ hLa0]
      exact key
    calc (a : ℝ) * Real.logb 2 ((b : ℝ) + 2) ^ α
        ≤ (a : ℝ) * (Real.logb 2 ((b : ℝ) + 2) / Real.logb 2 ((a : ℝ) + 2) * Real.logb 2 ((a : ℝ) + 2) ^ α) :=
          mul_le_mul_of_nonneg_left hpow ha
      _ = (a : ℝ) * (Real.logb 2 ((b : ℝ) + 2) / Real.logb 2 ((a : ℝ) + 2)) * Real.logb 2 ((a : ℝ) + 2) ^ α := by ring
      _ ≤ (b : ℝ) * Real.logb 2 ((a : ℝ) + 2) ^ α := mul_le_mul_of_nonneg_right h8 hpa.le
  · have hA : Filter.Tendsto (fun m : ℕ => (m : ℝ) + 2) Filter.atTop Filter.atTop :=
      Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop
    have hB : Filter.Tendsto (fun m : ℕ => Real.logb 2 ((m : ℝ) + 2)) Filter.atTop Filter.atTop :=
      (Real.tendsto_logb_atTop (by norm_num)).comp hA
    have hC : Filter.Tendsto (fun m : ℕ => Real.logb 2 ((m : ℝ) + 2) ^ α) Filter.atTop Filter.atTop :=
      (tendsto_rpow_atTop h0).comp hB
    have hD := hC.inv_tendsto_atTop
    refine hD.congr fun m => ?_
    simp [SatM.rPow]

end Superlinear.Pieces
