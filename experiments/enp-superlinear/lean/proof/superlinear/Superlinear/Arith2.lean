module

public import Superlinear.Arith
public import Superlinear.StatementSqrtLog
import ToTuring.Machine.EndTM
import Mathlib.Tactic

/-! # The arithmetic of the bound ε·n·√(log n), with the clause rate

Write L2(x) = log₂(x+2) and gR(x) = x/√(L2 x), so that M·rPow(1/2)(M) = gR(M) for the clause rate of
the engine (`SatM.rPow (1/2)`).
* `gR_mono`: gR is monotone on [0, ∞) (as `div_sqrt_mono` in Superlinear/Arith.lean).
* `main_bound2`: for M ≤ 15ε(m+1)√(L2 m) + K(m+1) and m large, gR(M) ≤ 15ε(m+1) + η(m+1).
* `threshold2`: the time bound of the host, with the clause bound in place of the bound in n. -/

@[expose] public section

namespace Superlinear

open Real

/-- log₂(x+2). -/
noncomputable def L2 (x : ℝ) : ℝ := Real.logb 2 (x + 2)

/-- x/√(log₂(x+2)). -/
noncomputable def gR (x : ℝ) : ℝ := x / Real.sqrt (L2 x)

theorem L2c_ge {x : ℝ} (hx : 0 ≤ x) : 1 ≤ L2 x := by
  unfold L2
  rw [Real.le_logb_iff_rpow_le one_lt_two (by linarith), Real.rpow_one]
  linarith

theorem L2_mono {x y : ℝ} (hx : 0 ≤ x) (hxy : x ≤ y) : L2 x ≤ L2 y :=
  Real.logb_le_logb_of_le one_lt_two (by linarith) (by linarith)

theorem L2_le_two_mul {x : ℝ} (hx : 0 ≤ x) : L2 x ≤ 2 * (x + 2) := by
  have := logb_le_two_mul (t := x + 2) (by linarith)
  unfold L2; linarith

theorem L2_le_sq {x y : ℝ} (hx : 0 < x) (hxy : x ≤ y) : x ^ 2 * L2 y ≤ y ^ 2 * L2 x := by
  set t := y / x with ht
  have ht1 : 1 ≤ t := by rw [ht, le_div_iff₀ hx]; linarith
  have hy : y = t * x := by rw [ht]; field_simp
  have h1 : L2 y ≤ Real.logb 2 t + L2 x := by
    unfold L2
    rw [← Real.logb_mul (by linarith) (by linarith)]
    exact Real.logb_le_logb_of_le one_lt_two (by linarith) (by rw [hy]; nlinarith)
  have h2 := logb_le_two_mul ht1
  have h3 := L2c_ge hx.le
  have h7 : 0 ≤ t ^ 2 - 1 := by nlinarith
  have h5 : 1 * (t ^ 2 - 1) ≤ (t ^ 2 - 1) * L2 x := by
    rw [mul_comm]; exact mul_le_mul_of_nonneg_left h3 h7
  have h6 : 2 * (t - 1) ≤ t ^ 2 - 1 := by nlinarith
  have h4 : L2 y ≤ t ^ 2 * L2 x := by nlinarith
  rw [hy] at h4 ⊢
  calc x ^ 2 * L2 (t * x) ≤ x ^ 2 * (t ^ 2 * L2 x) := mul_le_mul_of_nonneg_left h4 (sq_nonneg x)
    _ = (t * x) ^ 2 * L2 x := by ring

theorem gR_mono {x y : ℝ} (hx : 0 ≤ x) (hxy : x ≤ y) : gR x ≤ gR y := by
  have hy : 0 ≤ y := hx.trans hxy
  have hLx : 0 < Real.sqrt (L2 x) := Real.sqrt_pos.2 (by linarith [L2c_ge hx])
  have hLy : 0 < Real.sqrt (L2 y) := Real.sqrt_pos.2 (by linarith [L2c_ge hy])
  unfold gR
  rw [div_le_div_iff₀ hLx hLy]
  rcases hx.eq_or_lt with h0 | h0
  · rw [← h0]; simp; positivity
  have h := L2_le_sq h0 hxy
  have e1 : x * Real.sqrt (L2 y) = Real.sqrt (x ^ 2 * L2 y) := by
    rw [Real.sqrt_mul (by positivity), Real.sqrt_sq hx]
  have e2 : y * Real.sqrt (L2 x) = Real.sqrt (y ^ 2 * L2 x) := by
    rw [Real.sqrt_mul (by positivity), Real.sqrt_sq hy]
  rw [e1, e2]
  exact Real.sqrt_le_sqrt h

/-- The clause rate of the engine at M, times M, is gR(M). -/
theorem mul_rPow (M : ℕ) : (M : ℝ) * SatM.rPow (1 / 2) M = gR M := by
  unfold SatM.rPow gR L2
  rw [Real.sqrt_eq_rpow]
  ring

/-- K/√(L2 m) ≤ η for m large. -/
theorem inv_sqrt_small {K η : ℝ} (hK : 0 ≤ K) (hη : 0 < η) : ∃ M : ℕ, ∀ m : ℕ, M ≤ m → K / Real.sqrt (L2 m) ≤ η := by
  refine ⟨⌈(2 : ℝ) ^ ((K / η) ^ 2)⌉₊, fun m hm => ?_⟩
  have hm0 : (0 : ℝ) ≤ m := by positivity
  have h1 : (2 : ℝ) ^ ((K / η) ^ 2) ≤ m := (Nat.ceil_le.1 hm)
  have h2 : (K / η) ^ 2 ≤ L2 m := by
    unfold L2
    rw [Real.le_logb_iff_rpow_le one_lt_two (by linarith)]
    linarith
  have h3 : K / η ≤ Real.sqrt (L2 m) := by
    calc K / η = Real.sqrt ((K / η) ^ 2) := (Real.sqrt_sq (by positivity)).symm
      _ ≤ Real.sqrt (L2 m) := Real.sqrt_le_sqrt h2
  have h4 : 0 < Real.sqrt (L2 m) := Real.sqrt_pos.2 (by linarith [L2c_ge hm0])
  rw [div_le_iff₀ h4]
  rw [div_le_iff₀ hη] at h3
  linarith

/-- For M ≤ 15ε(m+1)√(L2 m) + K(m+1) and m large: gR(M) ≤ 15ε(m+1) + η(m+1). -/
theorem main_bound2 {ε η K : ℝ} (hε : 0 < ε) (hη : 0 < η) (hK : 1 ≤ K) :
    ∃ M : ℕ, ∀ m : ℕ, M ≤ m → ∀ N : ℝ, 0 ≤ N →
      N ≤ 15 * ε * ((m : ℝ) + 1) * Real.sqrt (L2 m) + K * ((m : ℝ) + 1) →
      gR N ≤ 15 * ε * ((m : ℝ) + 1) + η * ((m : ℝ) + 1) := by
  obtain ⟨M, hM⟩ := inv_sqrt_small (K := K) (by linarith) hη
  refine ⟨M, fun m hm N hN0 hNB => ?_⟩
  have hm0 : (0 : ℝ) ≤ m := by positivity
  set R := Real.sqrt (L2 m) with hR
  have hR0 : 0 < R := Real.sqrt_pos.2 (by linarith [L2c_ge hm0])
  set B := 15 * ε * ((m : ℝ) + 1) * R + K * ((m : ℝ) + 1) with hB
  have hmB : (m : ℝ) ≤ B := by
    have : 0 ≤ 15 * ε * ((m : ℝ) + 1) * R := by positivity
    rw [hB]; nlinarith
  have hB0 : 0 ≤ B := hm0.trans hmB
  have h1 := gR_mono hN0 hNB
  have hRB : R ≤ Real.sqrt (L2 B) := Real.sqrt_le_sqrt (L2_mono hm0 hmB)
  have h5 : gR B ≤ B / R := div_le_div_of_nonneg_left hB0 hR0 hRB
  have h6 : B / R = 15 * ε * ((m : ℝ) + 1) + ((m : ℝ) + 1) * (K / R) := by
    rw [hB]; field_simp
  have h7 : K / R ≤ η := hM m hm
  have h8 : ((m : ℝ) + 1) * (K / R) ≤ ((m : ℝ) + 1) * η := mul_le_mul_of_nonneg_left h7 (by positivity)
  linarith

/-- The size bound as a real number. -/
theorem sizeT_le {ε : ℝ} (hε : 0 < ε) (m : ℕ) : (ENP.sizeT ε m : ℝ) ≤ ε * ((m : ℝ) + 1) * Real.sqrt (L2 m) :=
  Nat.floor_le (by positivity)

theorem gates_leT {ε : ℝ} (hε : 0 < ε) (hε1 : ε ≤ 1) {m n : ℕ} (hn : n ≤ ENP.sizeT ε m) : n ≤ 4 * (m + 2) ^ 2 := by
  have hm0 : (0 : ℝ) ≤ m := by positivity
  have hL := L2c_ge hm0
  have hR : Real.sqrt (L2 m) ≤ 2 * ((m : ℝ) + 2) := by
    calc Real.sqrt (L2 m) ≤ Real.sqrt (L2 m ^ 2) := Real.sqrt_le_sqrt (by nlinarith)
      _ = L2 m := Real.sqrt_sq (by linarith)
      _ ≤ 2 * ((m : ℝ) + 2) := L2_le_two_mul hm0
  have h2 : (n : ℝ) ≤ 1 * ((m : ℝ) + 1) * (2 * ((m : ℝ) + 2)) :=
    calc (n : ℝ) ≤ ε * ((m : ℝ) + 1) * Real.sqrt (L2 m) := (Nat.cast_le.2 hn).trans (sizeT_le hε m)
      _ ≤ 1 * ((m : ℝ) + 1) * (2 * ((m : ℝ) + 2)) := by gcongr
  have h4 : 1 * ((m : ℝ) + 1) * (2 * ((m : ℝ) + 2)) ≤ 4 * ((m : ℝ) + 2) ^ 2 := by nlinarith
  have h3 : (n : ℝ) ≤ 4 * ((m : ℝ) + 2) ^ 2 := h2.trans h4
  exact_mod_cast h3

/-- **The time bound of the host, with the clause rate.** ε depends only on q and D. For m ≥ m₀, a
circuit with n ≤ sizeT ε m gates, a formula with Nv ≤ 3n + a₀(m+1) + G variables and M ≤ 5·Nv + 2
clauses, and a pad B within the engine's clause bound on M clauses of width 3: the steps
q·(|x| + B + 1)^q of the machine are at most 2^⌊m/8⌋. -/
theorem threshold2 (q D a₀ : ℕ) : ∃ ε : ℝ, 0 < ε ∧ ε ≤ 1 ∧ ∀ G : ℕ, ∃ m₀ : ℕ, ∀ m : ℕ, m₀ ≤ m → ∀ n Nv M B : ℕ,
    n ≤ ENP.sizeT ε m → Nv ≤ 3 * n + a₀ * (m + 1) + G → M ≤ 5 * Nv + 2 → B ≤ SatM.bound (SatM.rPow (1 / 2)) D 3 M →
    q * ((m + 1 + ((m + n) + 1 + n * (4 + 2 * (m + n)))) + B + 1) ^ q ≤ 2 ^ (m / 8) := by
  set ε : ℝ := 1 / (64 * 45 * ((q : ℝ) + 1) * ((D : ℝ) + 1)) with hεdef
  set η : ℝ := 1 / (64 * 3 * ((q : ℝ) + 1) * ((D : ℝ) + 1)) with hηdef
  have hε : 0 < ε := by positivity
  have hη : 0 < η := by positivity
  have hε1 : ε ≤ 1 := by
    rw [hεdef, div_le_one (by positivity)]
    have : (0 : ℝ) ≤ q := by positivity
    have : (0 : ℝ) ≤ D := by positivity
    nlinarith
  refine ⟨ε, hε, hε1, fun G => ?_⟩
  set K : ℝ := 5 * (a₀ : ℝ) + 5 * G + 2 with hK
  have hK1 : 1 ≤ K := by
    have : (0 : ℝ) ≤ a₀ := by positivity
    have : (0 : ℝ) ≤ G := by positivity
    rw [hK]; linarith
  obtain ⟨M₀, hM₀⟩ := main_bound2 hε hη hK1
  obtain ⟨C₁, hC₁⟩ := Groundwork.exists_pow_le (4 * q) (ε := 1 / 32) (by norm_num)
  obtain ⟨Kf, hKf⟩ : ∃ Kf : ℕ, Kf = q * 200 ^ q * C₁ * (D + 1) ^ q * 2 := ⟨_, rfl⟩
  refine ⟨max M₀ (16 * (Kf + 1)), fun m hm n Nv M B hn hNv hM hB => ?_⟩
  have hmM : M₀ ≤ m := le_of_max_le_left hm
  have hmK : 16 * (Kf + 1) ≤ m := le_of_max_le_right hm
  have hm0 : (0 : ℝ) ≤ m := by positivity
  -- the number of clauses
  have hn1 : (n : ℝ) ≤ ε * ((m : ℝ) + 1) * Real.sqrt (L2 m) := (Nat.cast_le.2 hn).trans (sizeT_le hε m)
  have hM1 : (M : ℝ) ≤ 15 * ε * ((m : ℝ) + 1) * Real.sqrt (L2 m) + K * ((m : ℝ) + 1) := by
    have h1 : (M : ℝ) ≤ 15 * n + 5 * a₀ * ((m : ℝ) + 1) + 5 * G + 2 := by
      have : M ≤ 15 * n + 5 * (a₀ * (m + 1)) + 5 * G + 2 := by omega
      have h' : (M : ℝ) ≤ 15 * n + 5 * (a₀ * ((m : ℝ) + 1)) + 5 * G + 2 := by exact_mod_cast this
      linarith
    have h2 : 15 * (n : ℝ) ≤ 15 * ε * ((m : ℝ) + 1) * Real.sqrt (L2 m) := by
      have := mul_le_mul_of_nonneg_left hn1 (by norm_num : (0 : ℝ) ≤ 15)
      calc 15 * (n : ℝ) ≤ 15 * (ε * ((m : ℝ) + 1) * Real.sqrt (L2 m)) := this
        _ = _ := by ring
    have h3 : 5 * (a₀ : ℝ) * ((m : ℝ) + 1) + 5 * G + 2 ≤ K * ((m : ℝ) + 1) := by
      rw [hK]; have : (0 : ℝ) ≤ G := by positivity
      nlinarith
    linarith
  have hf := hM₀ m hmM M (by positivity) hM1
  -- the pad
  have hBr : (B : ℝ) ≤ D * (2 : ℝ) ^ (3 * D * gR M) := by
    have h1 := (Nat.cast_le (α := ℝ)).2 hB
    unfold SatM.bound at h1
    refine h1.trans ((Nat.floor_le (by positivity)).trans (le_of_eq ?_))
    rw [← mul_rPow M]
    push_cast
    ring_nf
  obtain ⟨Y, hY⟩ : ∃ Y : ℝ, Y = 3 * D * (15 * ε * ((m : ℝ) + 1) + η * ((m : ℝ) + 1)) := ⟨_, rfl⟩
  have hfY : 3 * D * gR M ≤ Y := by rw [hY]; exact mul_le_mul_of_nonneg_left hf (by positivity)
  have hY0 : 0 ≤ Y := by rw [hY]; positivity
  have hqY : (q : ℝ) * Y ≤ (1 / 32) * m + 1 := by
    have h1 : (q : ℝ) * Y = ((q : ℝ) * D / (((q : ℝ) + 1) * ((D : ℝ) + 1))) * (1 / 32) * ((m : ℝ) + 1) := by
      rw [hY, hεdef, hηdef]; field_simp; ring
    have h2 : (q : ℝ) * D / (((q : ℝ) + 1) * ((D : ℝ) + 1)) ≤ 1 := by
      rw [div_le_one (by positivity)]
      have : (0 : ℝ) ≤ q := by positivity
      have : (0 : ℝ) ≤ D := by positivity
      nlinarith
    rw [h1]
    have : (q : ℝ) * D / (((q : ℝ) + 1) * ((D : ℝ) + 1)) * (1 / 32) * ((m : ℝ) + 1) ≤ 1 * (1 / 32) * ((m : ℝ) + 1) := by
      gcongr
    linarith
  obtain ⟨p, hp⟩ : ∃ p : ℝ, p = (2 : ℝ) ^ ((1 / 32 : ℝ) * m) := ⟨_, rfl⟩
  have hp1 : 1 ≤ p := by rw [hp]; exact Real.one_le_rpow one_le_two (by positivity)
  have hBq : ((B : ℝ) + 1) ^ q ≤ ((D : ℝ) + 1) ^ q * (2 * p) := by
    have h2Y : (1 : ℝ) ≤ (2 : ℝ) ^ Y := Real.one_le_rpow one_le_two hY0
    have h1 : (B : ℝ) + 1 ≤ ((D : ℝ) + 1) * (2 : ℝ) ^ Y := by
      have : (2 : ℝ) ^ (3 * D * gR M) ≤ (2 : ℝ) ^ Y := Real.rpow_le_rpow_of_exponent_le one_le_two hfY
      have : (D : ℝ) * (2 : ℝ) ^ (3 * D * gR M) ≤ D * (2 : ℝ) ^ Y := mul_le_mul_of_nonneg_left this (by positivity)
      nlinarith
    have h2 : ((2 : ℝ) ^ Y) ^ q = (2 : ℝ) ^ ((q : ℝ) * Y) := by
      rw [← Real.rpow_natCast, ← Real.rpow_mul (by norm_num), mul_comm]
    have h3 : (2 : ℝ) ^ ((q : ℝ) * Y) ≤ 2 * p := by
      calc (2 : ℝ) ^ ((q : ℝ) * Y) ≤ (2 : ℝ) ^ ((1 / 32) * (m : ℝ) + 1) := Real.rpow_le_rpow_of_exponent_le one_le_two hqY
        _ = 2 * p := by rw [Real.rpow_add two_pos, Real.rpow_one, hp]; ring
    calc ((B : ℝ) + 1) ^ q ≤ (((D : ℝ) + 1) * (2 : ℝ) ^ Y) ^ q := by gcongr
      _ = ((D : ℝ) + 1) ^ q * ((2 : ℝ) ^ Y) ^ q := mul_pow _ _ _
      _ ≤ ((D : ℝ) + 1) ^ q * (2 * p) := by rw [h2]; gcongr
  -- the length of the input
  have hn4 : n ≤ 4 * (m + 2) ^ 2 := gates_leT hε hε1 hn
  obtain ⟨X, hX⟩ : ∃ X, X = m + 1 + ((m + n) + 1 + n * (4 + 2 * (m + n))) := ⟨_, rfl⟩
  rw [← hX]
  have hX1 : X + 1 ≤ 200 * (m + 2) ^ 4 := by rw [hX]; exact input_le hn4
  have hXq : ((X : ℝ) + 1) ^ q ≤ 200 ^ q * (C₁ * p) := by
    have h1 : (X : ℝ) + 1 ≤ 200 * ((m : ℝ) + 2) ^ 4 := by exact_mod_cast hX1
    calc ((X : ℝ) + 1) ^ q ≤ (200 * ((m : ℝ) + 2) ^ 4) ^ q := by gcongr
      _ = 200 ^ q * ((m : ℝ) + 2) ^ (4 * q) := by rw [mul_pow, ← pow_mul]
      _ ≤ 200 ^ q * (C₁ * p) := by rw [hp]; gcongr; exact hC₁ m
  have hfin := CircuitLowerBound.Time.final_le Kf hmK
  rw [← hp, Real.rpow_natCast] at hfin
  have hmain : (q : ℝ) * ((X : ℝ) + B + 1) ^ q ≤ (2 : ℝ) ^ (m / 8) := by
    have hX0 : (0 : ℝ) ≤ X := Nat.cast_nonneg X
    have hB0 : (0 : ℝ) ≤ B := Nat.cast_nonneg B
    have hle : (X : ℝ) + B + 1 ≤ ((X : ℝ) + 1) * ((B : ℝ) + 1) := by
      have := mul_nonneg hX0 hB0
      linarith [show ((X : ℝ) + 1) * ((B : ℝ) + 1) = (X : ℝ) * B + X + B + 1 by ring]
    calc (q : ℝ) * ((X : ℝ) + B + 1) ^ q ≤ (q : ℝ) * (((X : ℝ) + 1) * ((B : ℝ) + 1)) ^ q :=
          mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by linarith) hle q) (Nat.cast_nonneg q)
      _ = (q : ℝ) * (((X : ℝ) + 1) ^ q * ((B : ℝ) + 1) ^ q) := by rw [mul_pow]
      _ ≤ (q : ℝ) * ((200 ^ q * (C₁ * p)) * (((D : ℝ) + 1) ^ q * (2 * p))) := by gcongr
      _ = (Kf : ℝ) * (p * p) := by rw [hKf]; push_cast; ring
      _ ≤ (2 : ℝ) ^ (m / 8) := hfin
  exact_mod_cast hmain

end Superlinear
