module

public import Superlinear.General
public import GeneralPieces.ThmRunningTime
public import Superlinear.PiecesRateOK
public import Superlinear.PiecesCountTransfer
import ClauseBound.Alg.End
import Mathlib.Tactic

/-! # From a counting machine to a deciding machine at the same rate

`decidesClauseRate_of_count`: `SatM.CountInRate r → ENP.DecidesClauseRate r` under the side
condition `Absorbs r` (log₂(m+2) ≤ a·m·r(m) for m ≥ 1: a polynomial in m is below 2^{O(m·r(m))}).
The machine is the wrapper of the development (`Wrap.everyMachineCanBeWrapped`) with front end
`id` and last step `Rename.anyBit`; its overhead q·(t + |x| + 1)^q goes into a larger constant by
`absorb`. `absorbs_rPow`: the side condition for `SatM.rPow α`, α ≤ 1.

`cor_of_pieces'`: the corollary for pieces through `Superlinear.generalTransfer` (route B). -/

@[expose] public section

namespace Superlinear.Pieces

open Groundwork Turing ENP CircuitLowerBound VariableBound Superlinear

/-- The side condition of the bridge: log₂(m+2) ≤ a·m·r(m) for all m ≥ 1. -/
def Absorbs (r : ℕ → ℝ) : Prop := ∃ a : ℕ, ∀ m : ℕ, 1 ≤ m → Real.logb 2 ((m : ℝ) + 2) ≤ (a : ℝ) * ((m : ℝ) * r m)

theorem le_bound {r : ℕ → ℝ} {C k m n : ℕ} (h : (n : ℝ) ≤ (C : ℝ) * (2 : ℝ) ^ ((C : ℝ) * k * m * r m)) :
    n ≤ SatM.bound r C k m := Nat.le_floor h

theorem bound_le {r : ℕ → ℝ} {C k m : ℕ} : (SatM.bound r C k m : ℝ) ≤ (C : ℝ) * (2 : ℝ) ^ ((C : ℝ) * k * m * r m) :=
  Nat.floor_le (by positivity)

/-- The overhead of the wrapper goes into the constant. -/
theorem absorb {r : ℕ → ℝ} (ha : Absorbs r) (q C : ℕ) : ∃ C' : ℕ, ∀ m : ℕ, 1 ≤ m →
    q * (SatM.bound r C 3 m + 8 * (3 * m) ^ 2) ^ q ≤ SatM.bound r C' 3 m := by
  obtain ⟨a, ha⟩ := ha
  refine ⟨q * (C + 72) ^ q + q * (3 * C + 2 * a), fun m hm => ?_⟩
  obtain ⟨E, hE⟩ : ∃ E : ℝ, E = (m : ℝ) * r m := ⟨_, rfl⟩
  have hL := one_le_L m
  have haE := ha m hm
  rw [← hE] at haE
  have hm0 : (0 : ℝ) ≤ m := Nat.cast_nonneg m
  have ha0 : (0 : ℝ) ≤ a := Nat.cast_nonneg a
  have hC0 : (0 : ℝ) ≤ C := Nat.cast_nonneg C
  have hE0 : 0 ≤ E := by
    by_contra h
    have : (a : ℝ) * E ≤ 0 := mul_nonpos_of_nonneg_of_nonpos ha0 (not_le.1 h).le
    linarith
  have hpoly : (m : ℝ) + 2 ≤ (2 : ℝ) ^ ((a : ℝ) * E) := (Real.logb_le_iff_le_rpow (by norm_num) (by positivity)).1 haE
  have hB : (SatM.bound r C 3 m : ℝ) ≤ (C : ℝ) * (2 : ℝ) ^ ((3 * C : ℝ) * E) := by
    have h := bound_le (r := r) (C := C) (k := 3) (m := m)
    have e : (C : ℝ) * ((3 : ℕ) : ℝ) * m * r m = (3 * C : ℝ) * E := by rw [hE]; push_cast; ring
    rwa [e] at h
  obtain ⟨P, hP⟩ : ∃ P : ℝ, P = (2 : ℝ) ^ (((3 * C + 2 * a : ℕ) : ℝ) * E) := ⟨_, rfl⟩
  have h1 : (2 : ℝ) ^ ((3 * C : ℝ) * E) ≤ P := by
    rw [hP]
    apply Real.rpow_le_rpow_of_exponent_le (by norm_num)
    push_cast
    nlinarith [mul_nonneg ha0 hE0]
  have h2 : ((m : ℝ) + 2) ^ 2 ≤ P := by
    calc ((m : ℝ) + 2) ^ 2 ≤ ((2 : ℝ) ^ ((a : ℝ) * E)) ^ 2 := pow_le_pow_left₀ (by positivity) hpoly 2
      _ = (2 : ℝ) ^ ((a : ℝ) * E * 2) := by
          rw [← Real.rpow_natCast, ← Real.rpow_mul (by norm_num)]; norm_num
      _ ≤ P := by
          rw [hP]
          apply Real.rpow_le_rpow_of_exponent_le (by norm_num)
          push_cast
          nlinarith [mul_nonneg hC0 hE0]
  have hS : ((SatM.bound r C 3 m + 8 * (3 * m) ^ 2 : ℕ) : ℝ) ≤ ((C + 72 : ℕ) : ℝ) * P := by
    push_cast
    have h3 : (8 : ℝ) * (3 * (m : ℝ)) ^ 2 ≤ 72 * ((m : ℝ) + 2) ^ 2 := by nlinarith
    have h4 := mul_le_mul_of_nonneg_left h1 hC0
    linarith
  have hSq : ((SatM.bound r C 3 m + 8 * (3 * m) ^ 2 : ℕ) : ℝ) ^ q ≤ ((C + 72 : ℕ) : ℝ) ^ q * P ^ q := by
    rw [← mul_pow]
    exact pow_le_pow_left₀ (Nat.cast_nonneg _) hS q
  have hPq : P ^ q = (2 : ℝ) ^ (((q * (3 * C + 2 * a) : ℕ) : ℝ) * E) := by
    rw [hP, ← Real.rpow_natCast, ← Real.rpow_mul (by norm_num)]
    congr 1
    push_cast
    ring
  apply le_bound
  have hX : ((q * (SatM.bound r C 3 m + 8 * (3 * m) ^ 2) ^ q : ℕ) : ℝ) = (q : ℝ) * ((SatM.bound r C 3 m + 8 * (3 * m) ^ 2 : ℕ) : ℝ) ^ q := by
    push_cast; ring
  rw [hX]
  have hle1 : ((q * (C + 72) ^ q : ℕ) : ℝ) ≤ ((q * (C + 72) ^ q + q * (3 * C + 2 * a) : ℕ) : ℝ) := by
    exact_mod_cast Nat.le_add_right _ _
  have hle2 : ((q * (3 * C + 2 * a) : ℕ) : ℝ) ≤ ((q * (C + 72) ^ q + q * (3 * C + 2 * a) : ℕ) : ℝ) := by
    exact_mod_cast Nat.le_add_left _ _
  have hC'0 : (0 : ℝ) ≤ ((q * (C + 72) ^ q + q * (3 * C + 2 * a) : ℕ) : ℝ) := Nat.cast_nonneg _
  have e : ((q * (C + 72) ^ q + q * (3 * C + 2 * a) : ℕ) : ℝ) * ((3 : ℕ) : ℝ) * m * r m
      = 3 * (((q * (C + 72) ^ q + q * (3 * C + 2 * a) : ℕ) : ℝ) * E) := by
    rw [hE]; push_cast; ring
  rw [e]
  calc (q : ℝ) * ((SatM.bound r C 3 m + 8 * (3 * m) ^ 2 : ℕ) : ℝ) ^ q
      ≤ (q : ℝ) * (((C + 72 : ℕ) : ℝ) ^ q * P ^ q) := mul_le_mul_of_nonneg_left hSq (Nat.cast_nonneg q)
    _ = ((q * (C + 72) ^ q : ℕ) : ℝ) * (2 : ℝ) ^ (((q * (3 * C + 2 * a) : ℕ) : ℝ) * E) := by
        rw [hPq]; push_cast; ring
    _ ≤ ((q * (C + 72) ^ q + q * (3 * C + 2 * a) : ℕ) : ℝ) * (2 : ℝ) ^ (3 * (((q * (C + 72) ^ q + q * (3 * C + 2 * a) : ℕ) : ℝ) * E)) := by
        apply mul_le_mul hle1 _ (by positivity) hC'0
        apply Real.rpow_le_rpow_of_exponent_le (by norm_num)
        have h5 := mul_le_mul_of_nonneg_right hle2 hE0
        have h6 := mul_nonneg hC'0 hE0
        linarith

/-- A machine that counts at rate r gives a machine that decides at rate r
(larger constant), if polynomials in m are absorbed. -/
theorem decidesClauseRate_of_count {r : ℕ → ℝ} (ha : Absorbs r) (hc : SatM.CountInRate r) : DecidesClauseRate r := by
  obtain ⟨M, C, hfin, hM⟩ := hc
  obtain ⟨N, q, hNfin, hW⟩ := Wrap.everyMachineCanBeWrapped M hfin id Rename.anyBit PolyT.id' Rename.anyBit_polyT
  obtain ⟨C', hC'⟩ := absorb ha q C
  refine ⟨N, C', hNfin, fun n φ hk hl hocc => ⟨decide (SatK.numSat φ ≠ 0), ?_, ?_⟩⟩
  · rw [decide_eq_true_iff]; exact numSat_ne_zero_iff φ
  · have h5 : Wrap.Outputs M (id (SatM.enc 3 φ)) (SatK.binary n (SatK.numSat φ)) (SatM.bound r C 3 φ.length) :=
      hM 3 n φ (by norm_num) hl hk hocc
    have hlt : SatK.numSat φ < 2 ^ (n + 1) := by rw [← CountKSat.stCntToN]; exact Alg.cntN_lt _ _
    have h2 := hW (SatM.enc 3 φ) _ _ h5
    rw [Rename.anyBit_binary hlt] at h2
    obtain ⟨ev⟩ := h2
    have hlen := ClauseBound.Alg.End.length_enc_succ_le (k := 3) (φ := φ) (by norm_num) hl (ClauseBound.Alg.End.n_le hk hocc)
    refine ⟨⟨ev.toEvalsTo, ev.steps_le_m.trans (le_trans ?_ (hC' φ.length hl))⟩⟩
    apply Nat.mul_le_mul_left
    apply Nat.pow_le_pow_left
    omega

/-- (log₂(m+2))² ≤ 27·m for m ≥ 1. -/
theorem sq_L_le {m : ℕ} (hm : 1 ≤ m) : Real.logb 2 ((m : ℝ) + 2) ^ 2 ≤ 27 * m := by
  have hm' : (1 : ℝ) ≤ m := by exact_mod_cast hm
  obtain ⟨y, hy⟩ : ∃ y : ℝ, y = (m : ℝ) + 2 := ⟨_, rfl⟩
  rw [← hy]
  have hy0 : 0 < y := by linarith
  have hs : 0 < Real.sqrt y := Real.sqrt_pos.2 hy0
  have h1 : Real.log (Real.sqrt y) ≤ Real.sqrt y - 1 := Real.log_le_sub_one_of_pos hs
  rw [Real.log_sqrt hy0.le] at h1
  have hl0 : 0 ≤ Real.log y := Real.log_nonneg (by linarith)
  have h2 : Real.log y ≤ 2 * Real.sqrt y := by linarith
  have hsq : Real.sqrt y ^ 2 = y := Real.sq_sqrt hy0.le
  have h3 : Real.log y ^ 2 ≤ 4 * y := by nlinarith
  have hlog2 : (0.69 : ℝ) < Real.log 2 := by linarith [Real.log_two_gt_d9]
  have hlog2sq : (0.4761 : ℝ) ≤ Real.log 2 ^ 2 := by nlinarith
  unfold Real.logb
  rw [div_pow, div_le_iff₀ (by positivity)]
  nlinarith

/-- The side condition holds for `rPow α`, α ≤ 1. -/
theorem absorbs_rPow {α : ℝ} (h1 : α ≤ 1) : Absorbs (SatM.rPow α) := by
  refine ⟨27, fun m hm => ?_⟩
  have hL := one_le_L m
  have hL0 : 0 < Real.logb 2 ((m : ℝ) + 2) := by linarith
  have hp : 0 < Real.logb 2 ((m : ℝ) + 2) ^ α := Real.rpow_pos_of_pos hL0 α
  have hpl : Real.logb 2 ((m : ℝ) + 2) ^ α ≤ Real.logb 2 ((m : ℝ) + 2) := by
    have h := Real.rpow_le_rpow_of_exponent_le hL h1
    rwa [Real.rpow_one] at h
  have hsq := sq_L_le hm
  unfold SatM.rPow
  rw [mul_one_div, ← mul_div_assoc, le_div_iff₀ hp]
  calc Real.logb 2 ((m : ℝ) + 2) * Real.logb 2 ((m : ℝ) + 2) ^ α
      ≤ Real.logb 2 ((m : ℝ) + 2) * Real.logb 2 ((m : ℝ) + 2) := mul_le_mul_of_nonneg_left hpl hL0.le
    _ = Real.logb 2 ((m : ℝ) + 2) ^ 2 := by ring
    _ ≤ ((27 : ℕ) : ℝ) * m := by push_cast; exact hsq

/-- A counting machine at rate `rPow α`, α ≤ 1, gives a deciding machine at that rate. -/
theorem decidesClauseRate_rPow_gen {α : ℝ} (h1 : α ≤ 1) (hc : SatM.CountInRate (SatM.rPow α)) :
    DecidesClauseRate (SatM.rPow α) :=
  decidesClauseRate_of_count (absorbs_rPow h1) hc

/-- The same corollary through `Superlinear.generalTransfer` and the bridge (second route). -/
theorem cor_of_pieces' (ρ : ℝ) (c : ℕ) (hE : AppRunningTime.Exist ρ c) :
    ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧
      ¬DecidedAt L (sizeR (SatM.rPow (AppRunningTime.alpha' ρ)) ε n) n := by
  obtain ⟨hρ1, hρ2⟩ := GeneralPieces.rho_of_exist hE
  obtain ⟨h0, h1⟩ := alpha'_mem hρ1 hρ2
  exact generalTransfer _ (rateOK_rPow_gen h0 h1)
    (decidesClauseRate_rPow_gen h1 (GeneralPieces.thmRunningTime_c_m ρ c hE))

end Superlinear.Pieces
