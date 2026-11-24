module

public import Superlinear.Statement
public import SparsifyThenCount.PlanUsed
public import CircuitLowerBound.Alg.Time
import ToTuring.Machine.EndTM
import Mathlib.Tactic

/-! # The arithmetic of the superlinear bound

Write LL(x) = log₂(x+4) and fR(x) = x·log₂(LL x)/√(LL x), so that n·rN(n) = fR(n) for the rate rN
of the engine (`SatK.rN 1 (1/2)`).
* `fR_mono`: fR is monotone on [0, ∞) (no derivatives: x/√(LL x) is monotone because
  LL(tx) ≤ t²·LL(x) for t ≥ 1, and log₂ ∘ LL is monotone).
* `main_bound`: for N ≤ 3ε(m+1)√(LL m)/log₂(LL m) + K(m+1) and m large, fR(N) ≤ 6ε(m+1) + η(m+1).
* `threshold`: the time bound of the host, the analogue of `CircuitLowerBound.Time.exists_threshold`.
-/

@[expose] public section

namespace Superlinear

open Real Filter

/-- log₂(x+4). -/
noncomputable def LL (x : ℝ) : ℝ := Real.logb 2 (x + 4)

/-- x·log₂(log₂(x+4))/√(log₂(x+4)). -/
noncomputable def fR (x : ℝ) : ℝ := x * Real.logb 2 (LL x) / Real.sqrt (LL x)

theorem LL_ge {x : ℝ} (hx : 0 ≤ x) : 2 ≤ LL x := by
  unfold LL
  rw [Real.le_logb_iff_rpow_le one_lt_two (by linarith), Real.rpow_two]
  linarith

theorem LL_mono {x y : ℝ} (hx : 0 ≤ x) (hxy : x ≤ y) : LL x ≤ LL y :=
  Real.logb_le_logb_of_le one_lt_two (by linarith) (by linarith)

theorem L2_ge {x : ℝ} (hx : 0 ≤ x) : 1 ≤ Real.logb 2 (LL x) := by
  rw [Real.le_logb_iff_rpow_le one_lt_two (by linarith [LL_ge hx]), Real.rpow_one]
  exact LL_ge hx

theorem logb_le_two_mul {t : ℝ} (ht : 1 ≤ t) : Real.logb 2 t ≤ 2 * (t - 1) := by
  have h1 := Real.log_le_sub_one_of_pos (by linarith : 0 < t)
  have h2 : (1 / 2 : ℝ) < Real.log 2 := by have := Real.log_two_gt_d9; linarith
  have h3 : 0 ≤ Real.log t := Real.log_nonneg ht
  rw [Real.logb, div_le_iff₀ (by linarith)]
  nlinarith

theorem LL_le_two_mul {x : ℝ} (hx : 0 ≤ x) : LL x ≤ 2 * (x + 4) := by
  have := logb_le_two_mul (t := x + 4) (by linarith)
  unfold LL; linarith

/-- LL(y) ≤ (y/x)²·LL(x) for 0 < x ≤ y. -/
theorem LL_le_sq {x y : ℝ} (hx : 0 < x) (hxy : x ≤ y) : x ^ 2 * LL y ≤ y ^ 2 * LL x := by
  set t := y / x with ht
  have ht1 : 1 ≤ t := by rw [ht, le_div_iff₀ hx]; linarith
  have hy : y = t * x := by rw [ht]; field_simp
  have h1 : LL y ≤ Real.logb 2 t + LL x := by
    unfold LL
    rw [← Real.logb_mul (by linarith) (by linarith)]
    exact Real.logb_le_logb_of_le one_lt_two (by linarith) (by rw [hy]; nlinarith)
  have h2 := logb_le_two_mul ht1
  have h3 := LL_ge hx.le
  have h7 : 0 ≤ t ^ 2 - 1 := by nlinarith
  have h5 : 2 * (t ^ 2 - 1) ≤ (t ^ 2 - 1) * LL x := by
    rw [mul_comm]; exact mul_le_mul_of_nonneg_left h3 h7
  have h6 : t - 1 ≤ t ^ 2 - 1 := by nlinarith
  have h4 : LL y ≤ t ^ 2 * LL x := by nlinarith
  rw [hy] at h4 ⊢
  calc x ^ 2 * LL (t * x) ≤ x ^ 2 * (t ^ 2 * LL x) := mul_le_mul_of_nonneg_left h4 (sq_nonneg x)
    _ = (t * x) ^ 2 * LL x := by ring

theorem div_sqrt_mono {x y : ℝ} (hx : 0 ≤ x) (hxy : x ≤ y) : x / Real.sqrt (LL x) ≤ y / Real.sqrt (LL y) := by
  have hy : 0 ≤ y := hx.trans hxy
  have hLx : 0 < Real.sqrt (LL x) := Real.sqrt_pos.2 (by linarith [LL_ge hx])
  have hLy : 0 < Real.sqrt (LL y) := Real.sqrt_pos.2 (by linarith [LL_ge hy])
  rw [div_le_div_iff₀ hLx hLy]
  rcases hx.eq_or_lt with h0 | h0
  · rw [← h0]; simp; positivity
  have h := LL_le_sq h0 hxy
  have e1 : x * Real.sqrt (LL y) = Real.sqrt (x ^ 2 * LL y) := by
    rw [Real.sqrt_mul (by positivity), Real.sqrt_sq hx]
  have e2 : y * Real.sqrt (LL x) = Real.sqrt (y ^ 2 * LL x) := by
    rw [Real.sqrt_mul (by positivity), Real.sqrt_sq hy]
  rw [e1, e2]
  exact Real.sqrt_le_sqrt h

theorem fR_eq (x : ℝ) : fR x = x / Real.sqrt (LL x) * Real.logb 2 (LL x) := by
  unfold fR; ring

theorem fR_mono {x y : ℝ} (hx : 0 ≤ x) (hxy : x ≤ y) : fR x ≤ fR y := by
  rw [fR_eq, fR_eq]
  have h1 := div_sqrt_mono hx hxy
  have h2 : Real.logb 2 (LL x) ≤ Real.logb 2 (LL y) :=
    Real.logb_le_logb_of_le one_lt_two (by linarith [LL_ge hx]) (LL_mono hx hxy)
  have hy0 : 0 ≤ y := hx.trans hxy
  exact mul_le_mul h1 h2 (by linarith [L2_ge hx]) (by positivity)

/-- The rate of the engine at n, times n, is fR(n). -/
theorem mul_rN (n : ℕ) : (n : ℝ) * SatK.rN 1 (1 / 2) n = fR n := by
  unfold SatK.rN fR LL
  rw [pow_one, Real.sqrt_eq_rpow]
  ring

/-- log₂(LL m)/√(LL m) tends to 0. -/
theorem ratio_small {η : ℝ} (hη : 0 < η) : ∃ M : ℕ, ∀ m : ℕ, M ≤ m → Real.logb 2 (LL m) / Real.sqrt (LL m) ≤ η := by
  have h := SparsifyThenCount.stRateZero
  unfold SparsifyThenCount.StRateZero at h
  rw [Metric.tendsto_atTop] at h
  obtain ⟨M, hM⟩ := h η hη
  refine ⟨M, fun m hm => ?_⟩
  have h1 := hM m hm
  rw [Real.dist_eq, sub_zero] at h1
  have h2 : SatK.rN 1 (1 / 2) m = Real.logb 2 (LL m) / Real.sqrt (LL m) := by
    unfold SatK.rN LL; rw [pow_one, Real.sqrt_eq_rpow]
  rw [← h2]
  exact (le_abs_self _).trans h1.le

theorem two_rpow_four : (2 : ℝ) ^ (4 : ℝ) = 16 := by
  rw [show (4 : ℝ) = ((4 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]; norm_num

/-- For N ≤ 3ε(m+1)√(LL m)/log₂(LL m) + K(m+1) and m large: fR(N) ≤ 6ε(m+1) + η(m+1). The threshold
depends on ε, η, K. -/
theorem main_bound {ε η K : ℝ} (hε : 0 < ε) (hε1 : ε ≤ 1) (hη : 0 < η) (hK : 1 ≤ K) :
    ∃ M : ℕ, ∀ m : ℕ, M ≤ m → ∀ N : ℝ, 0 ≤ N →
      N ≤ 3 * ε * ((m : ℝ) + 1) * Real.sqrt (LL m) / Real.logb 2 (LL m) + K * ((m : ℝ) + 1) →
      fR N ≤ 6 * ε * ((m : ℝ) + 1) + η * ((m : ℝ) + 1) := by
  obtain ⟨M₁, hM₁⟩ := ratio_small (η := η / (2 * K)) (by positivity)
  refine ⟨max M₁ (max 12 (⌈K⌉₊ + 3)), fun m hm N hN0 hNB => ?_⟩
  have hm1 : M₁ ≤ m := le_of_max_le_left hm
  have hm12 : (12 : ℝ) ≤ m := by exact_mod_cast (le_of_max_le_left (le_of_max_le_right hm))
  have hmK : K + 3 ≤ (m : ℝ) := by
    have h1 : ⌈K⌉₊ + 3 ≤ m := le_of_max_le_right (le_of_max_le_right hm)
    have h2 : K ≤ (⌈K⌉₊ : ℝ) := Nat.le_ceil K
    have h3 : ((⌈K⌉₊ + 3 : ℕ) : ℝ) ≤ m := by exact_mod_cast h1
    push_cast at h3; linarith
  have hm0 : (0 : ℝ) ≤ m := by positivity
  set Lm := LL m with hLm
  set Q := Real.logb 2 Lm with hQ
  set R := Real.sqrt Lm with hR
  have hL4 : 4 ≤ Lm := by
    rw [hLm, LL, Real.le_logb_iff_rpow_le one_lt_two (by linarith), two_rpow_four]; linarith
  have hQ2 : 2 ≤ Q := by
    rw [hQ, Real.le_logb_iff_rpow_le one_lt_two (by linarith), Real.rpow_two]; linarith
  have hR0 : 0 < R := Real.sqrt_pos.2 (by linarith)
  have hRL : R ≤ Lm := by
    calc R ≤ Real.sqrt (Lm ^ 2) := Real.sqrt_le_sqrt (by nlinarith)
      _ = Lm := Real.sqrt_sq (by linarith)
  have hL2 : Lm ≤ 2 * ((m : ℝ) + 4) := LL_le_two_mul hm0
  set B := 3 * ε * ((m : ℝ) + 1) * R / Q + K * ((m : ℝ) + 1) with hB
  have hT0 : 0 ≤ 3 * ε * ((m : ℝ) + 1) * R / Q := by positivity
  have hTle : 3 * ε * ((m : ℝ) + 1) * R / Q ≤ 6 * ((m : ℝ) + 4) ^ 2 := by
    rw [div_le_iff₀ (by linarith)]
    have h1 : 3 * ε * ((m : ℝ) + 1) * R ≤ 3 * 1 * ((m : ℝ) + 4) * (2 * ((m : ℝ) + 4)) := by
      gcongr <;> linarith
    nlinarith
  have hmB : (m : ℝ) ≤ B := by rw [hB]; nlinarith
  have hB0 : 0 ≤ B := hm0.trans hmB
  have h1 := fR_mono hN0 hNB
  -- LL B ≥ LL m
  have hLB1 : Lm ≤ LL B := LL_mono hm0 hmB
  -- LL B ≤ 3·LL m
  have hB4 : B + 4 ≤ (K + 7) * ((m : ℝ) + 4) ^ 2 := by
    rw [hB]; nlinarith
  have hLB2 : LL B ≤ 3 * Lm := by
    have h2 : LL B ≤ Real.logb 2 ((K + 7) * ((m : ℝ) + 4) ^ 2) :=
      Real.logb_le_logb_of_le one_lt_two (by linarith) hB4
    rw [Real.logb_mul (by linarith) (by positivity), Real.logb_pow] at h2
    have h3 : Real.logb 2 (K + 7) ≤ Lm := Real.logb_le_logb_of_le one_lt_two (by linarith) (by linarith)
    have h4 : Real.logb 2 ((m : ℝ) + 4) = Lm := rfl
    rw [h4] at h2
    push_cast at h2
    linarith
  have hQB : Real.logb 2 (LL B) ≤ 2 * Q := by
    have h2 : Real.logb 2 (LL B) ≤ Real.logb 2 (3 * Lm) :=
      Real.logb_le_logb_of_le one_lt_two (by linarith) hLB2
    rw [Real.logb_mul (by norm_num) (by linarith)] at h2
    have h3 : Real.logb 2 3 ≤ 2 := by
      rw [Real.logb_le_iff_le_rpow one_lt_two (by norm_num), Real.rpow_two]; norm_num
    linarith
  have hRB : R ≤ Real.sqrt (LL B) := Real.sqrt_le_sqrt hLB1
  have h5 : fR B ≤ B * (2 * Q) / R := by
    unfold fR
    exact div_le_div₀ (by positivity) (mul_le_mul_of_nonneg_left hQB hB0) hR0 hRB
  have h6 : B * (2 * Q) / R = 6 * ε * ((m : ℝ) + 1) + 2 * K * ((m : ℝ) + 1) * (Q / R) := by
    rw [hB]; field_simp; ring
  have h7 : Q / R ≤ η / (2 * K) := hM₁ m hm1
  have h8 : 2 * K * ((m : ℝ) + 1) * (Q / R) ≤ 2 * K * ((m : ℝ) + 1) * (η / (2 * K)) :=
    mul_le_mul_of_nonneg_left h7 (by positivity)
  have h9 : 2 * K * ((m : ℝ) + 1) * (η / (2 * K)) = η * ((m : ℝ) + 1) := by field_simp
  linarith

/-- The size bound as a real number: sizeS ε m ≤ ε(m+1)√(LL m)/log₂(LL m). -/
theorem sizeS_le {ε : ℝ} (hε : 0 < ε) (m : ℕ) :
    (ENP.sizeS ε m : ℝ) ≤ ε * ((m : ℝ) + 1) * Real.sqrt (LL m) / Real.logb 2 (LL m) := by
  have hm0 : (0 : ℝ) ≤ m := by positivity
  have hQ := L2_ge hm0
  have h1 : Real.sqrt (Real.logb 2 ((m : ℝ) + 2)) ≤ Real.sqrt (LL m) :=
    Real.sqrt_le_sqrt (Real.logb_le_logb_of_le one_lt_two (by linarith) (by linarith))
  unfold ENP.sizeS
  refine (Nat.floor_le ?_).trans ?_
  · have : 0 < Real.logb 2 (Real.logb 2 ((m : ℝ) + 4)) := by unfold LL at hQ; linarith
    positivity
  · change ε * ((m : ℝ) + 1) * Real.sqrt (Real.logb 2 ((m : ℝ) + 2)) / Real.logb 2 (LL m) ≤ _
    gcongr

theorem sqrt_div_le {m : ℕ} : Real.sqrt (LL m) / Real.logb 2 (LL m) ≤ 2 * ((m : ℝ) + 4) := by
  have hm0 : (0 : ℝ) ≤ m := by positivity
  have hQ1 := L2_ge hm0
  have hL2 := LL_ge hm0
  have hR : Real.sqrt (LL m) ≤ LL m := by
    calc Real.sqrt (LL m) ≤ Real.sqrt (LL m ^ 2) := Real.sqrt_le_sqrt (by nlinarith)
      _ = LL m := Real.sqrt_sq (by linarith)
  have h2 := LL_le_two_mul hm0
  rw [div_le_iff₀ (by linarith)]
  calc Real.sqrt (LL m) ≤ 2 * ((m : ℝ) + 4) := hR.trans h2
    _ = 2 * ((m : ℝ) + 4) * 1 := by ring
    _ ≤ 2 * ((m : ℝ) + 4) * Real.logb 2 (LL m) := by gcongr

theorem gates_le {ε : ℝ} (hε : 0 < ε) (hε1 : ε ≤ 1) {m n : ℕ} (hn : n ≤ ENP.sizeS ε m) : n ≤ 4 * (m + 2) ^ 2 := by
  have hn1 : (n : ℝ) ≤ ε * ((m : ℝ) + 1) * Real.sqrt (LL m) / Real.logb 2 (LL m) :=
    (Nat.cast_le.2 hn).trans (sizeS_le hε m)
  have h2 : (n : ℝ) ≤ 1 * ((m : ℝ) + 1) * (2 * ((m : ℝ) + 4)) := by
    calc (n : ℝ) ≤ ε * ((m : ℝ) + 1) * Real.sqrt (LL m) / Real.logb 2 (LL m) := hn1
      _ = ε * ((m : ℝ) + 1) * (Real.sqrt (LL m) / Real.logb 2 (LL m)) := by ring
      _ ≤ 1 * ((m : ℝ) + 1) * (2 * ((m : ℝ) + 4)) := by
        have := sqrt_div_le (m := m)
        have : 0 ≤ Real.sqrt (LL m) / Real.logb 2 (LL m) := by
          have := L2_ge (x := m) (by positivity); positivity
        gcongr
  have h4 : 1 * ((m : ℝ) + 1) * (2 * ((m : ℝ) + 4)) ≤ 4 * ((m : ℝ) + 2) ^ 2 := by
    have : (0 : ℝ) ≤ m := by positivity
    nlinarith
  have h3 : (n : ℝ) ≤ 4 * ((m : ℝ) + 2) ^ 2 := h2.trans h4
  exact_mod_cast h3

theorem input_le {m n : ℕ} (hn : n ≤ 4 * (m + 2) ^ 2) : m + 1 + ((m + n) + 1 + n * (4 + 2 * (m + n))) + 1 ≤ 200 * (m + 2) ^ 4 := by
  have h1 : m + 2 ≤ (m + 2) ^ 2 := by nlinarith
  have h2 : n * n ≤ 16 * (m + 2) ^ 4 := by
    calc n * n ≤ (4 * (m + 2) ^ 2) * (4 * (m + 2) ^ 2) := Nat.mul_le_mul hn hn
      _ = 16 * (m + 2) ^ 4 := by ring
  have h3 : n * (m + 2) ≤ 4 * (m + 2) ^ 4 := by
    calc n * (m + 2) ≤ (4 * (m + 2) ^ 2) * (m + 2) ^ 2 := Nat.mul_le_mul hn h1
      _ = 4 * (m + 2) ^ 4 := by ring
  have h4 : (m + 2) ^ 2 ≤ (m + 2) ^ 4 := Nat.pow_le_pow_right (by omega) (by omega)
  nlinarith

/-- **The time bound of the host.** ε depends only on q and D (the constants of the machine and of
the engine); the threshold m₀ also on a₀ and G. For m ≥ m₀, a circuit with n ≤ sizeS ε m gates, a
formula with Nv ≤ 3n + a₀(m+1) + G variables and a pad B within the engine's bound on Nv + 1
variables: the steps q·(|x| + B + 1)^q of the machine are at most 2^⌊m/8⌋. -/
theorem threshold (q D a₀ : ℕ) : ∃ ε : ℝ, 0 < ε ∧ ε ≤ 1 ∧ ∀ G : ℕ, ∃ m₀ : ℕ, ∀ m : ℕ, m₀ ≤ m → ∀ n Nv B : ℕ,
    n ≤ ENP.sizeS ε m → Nv ≤ 3 * n + a₀ * (m + 1) + G → B ≤ SatM.boundNK (SatK.rN 1 (1 / 2)) D 3 (Nv + 1) →
    q * ((m + 1 + ((m + n) + 1 + n * (4 + 2 * (m + n)))) + B + 1) ^ q ≤ 2 ^ (m / 8) := by
  set ε : ℝ := 1 / (64 * 54 * ((q : ℝ) + 1) * ((D : ℝ) + 1)) with hεdef
  set η : ℝ := 1 / (64 * 9 * ((q : ℝ) + 1) * ((D : ℝ) + 1)) with hηdef
  have hε : 0 < ε := by positivity
  have hη : 0 < η := by positivity
  have hε1 : ε ≤ 1 := by
    rw [hεdef, div_le_one (by positivity)]
    have : (0 : ℝ) ≤ q := by positivity
    have : (0 : ℝ) ≤ D := by positivity
    nlinarith
  refine ⟨ε, hε, hε1, fun G => ?_⟩
  set K : ℝ := (a₀ : ℝ) + G + 2 with hK
  have hK1 : 1 ≤ K := by
    have : (0 : ℝ) ≤ a₀ := by positivity
    have : (0 : ℝ) ≤ G := by positivity
    rw [hK]; linarith
  obtain ⟨M, hM⟩ := main_bound hε hε1 hη hK1
  obtain ⟨C₁, hC₁⟩ := Groundwork.exists_pow_le (4 * q) (ε := 1 / 32) (by norm_num)
  obtain ⟨Kf, hKf⟩ : ∃ Kf : ℕ, Kf = q * 200 ^ q * C₁ * (D + 1) ^ q * 2 := ⟨_, rfl⟩
  refine ⟨max M (16 * (Kf + 1)), fun m hm n Nv B hn hNv hB => ?_⟩
  have hmM : M ≤ m := le_of_max_le_left hm
  have hmK : 16 * (Kf + 1) ≤ m := le_of_max_le_right hm
  have hm0 : (0 : ℝ) ≤ m := by positivity
  set Lm := LL m with hLm
  set Q := Real.logb 2 Lm with hQ
  have hQ1 : 1 ≤ Q := L2_ge hm0
  have hL2 : 2 ≤ Lm := LL_ge hm0
  -- the number of gates
  have hn1 : (n : ℝ) ≤ ε * ((m : ℝ) + 1) * Real.sqrt Lm / Q :=
    (Nat.cast_le.2 hn).trans (sizeS_le hε m)
  -- the number of variables, plus one
  obtain ⟨n', hn'⟩ : ∃ n', n' = Nv + 1 := ⟨_, rfl⟩
  have hn'1 : (n' : ℝ) ≤ 3 * ε * ((m : ℝ) + 1) * Real.sqrt Lm / Q + K * ((m : ℝ) + 1) := by
    have h1 : (n' : ℝ) ≤ 3 * n + a₀ * ((m : ℝ) + 1) + G + 1 := by
      have : n' ≤ 3 * n + a₀ * (m + 1) + G + 1 := by omega
      exact_mod_cast this
    have h2 : 3 * (n : ℝ) ≤ 3 * ε * ((m : ℝ) + 1) * Real.sqrt Lm / Q := by
      have := mul_le_mul_of_nonneg_left hn1 (by norm_num : (0 : ℝ) ≤ 3)
      calc 3 * (n : ℝ) ≤ 3 * (ε * ((m : ℝ) + 1) * Real.sqrt Lm / Q) := this
        _ = _ := by ring
    have h3 : (a₀ : ℝ) * ((m : ℝ) + 1) + G + 1 ≤ K * ((m : ℝ) + 1) := by
      rw [hK]; have : (0 : ℝ) ≤ G := by positivity
      nlinarith
    linarith
  have hf := hM m hmM n' (by positivity) hn'1
  -- the pad
  have hBr : (B : ℝ) ≤ D * (2 : ℝ) ^ (9 * D * fR n') := by
    have h1 := (Nat.cast_le (α := ℝ)).2 hB
    rw [← hn'] at h1
    unfold SatM.boundNK at h1
    refine h1.trans ((Nat.floor_le (by positivity)).trans (le_of_eq ?_))
    rw [← mul_rN n']
    push_cast
    ring_nf
  set Y : ℝ := 9 * D * (6 * ε * ((m : ℝ) + 1) + η * ((m : ℝ) + 1)) with hY
  have hfY : 9 * D * fR n' ≤ Y := mul_le_mul_of_nonneg_left hf (by positivity)
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
    have h2Y : (1 : ℝ) ≤ (2 : ℝ) ^ Y := Real.one_le_rpow one_le_two (by positivity)
    have h1 : (B : ℝ) + 1 ≤ ((D : ℝ) + 1) * (2 : ℝ) ^ Y := by
      have : (2 : ℝ) ^ (9 * D * fR n') ≤ (2 : ℝ) ^ Y := Real.rpow_le_rpow_of_exponent_le one_le_two hfY
      have : (D : ℝ) * (2 : ℝ) ^ (9 * D * fR n') ≤ D * (2 : ℝ) ^ Y := mul_le_mul_of_nonneg_left this (by positivity)
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
  have hn4 : n ≤ 4 * (m + 2) ^ 2 := gates_le hε hε1 hn
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
