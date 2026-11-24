module

public import Superlinear.StatementGeneral
public import CircuitLowerBound.Alg.Time
import ToTuring.Machine.EndTM
import Mathlib.Tactic

/-! # The arithmetic for a general clause rate r with `RateOK r`

`threshold_gen`: the analogue of `threshold2` (Superlinear/Arith2.lean) for any rate r with
`RateOK r`, with the size bound `sizeR r ε` and the time bound `SatM.bound r D 3 M` of the machine
for 3-SAT. Where `threshold2` used the monotonicity of M/√(log₂(M+2)), here the hypothesis
«m·r(m) is monotone» is used; «r is antitone» and «r → 0» replace the bound log₂ log₂/√log₂ → 0;
and m·r(m) ≥ r(1) bounds the number of gates by a polynomial in m. -/

@[expose] public section

namespace Superlinear

open Real ENP

/-- Few gates: n ≤ sizeR r ε m gives n ≤ c·(m+2)² for m ≥ 1, with c = ⌈1/r(1)⌉. -/
theorem gates_le_gen {r : ℕ → ℝ} (hr : RateOK r) {ε : ℝ} (hε : 0 < ε) (hε1 : ε ≤ 1) {m n : ℕ} (hm : 1 ≤ m)
    (hn : n ≤ sizeR r ε m) : n ≤ ⌈1 / r 1⌉₊ * (m + 2) ^ 2 := by
  obtain ⟨hpos, -, hmono, -⟩ := hr
  have h1 : (1 : ℝ) * r 1 ≤ (m : ℝ) * r m := by
    have := hmono hm; simpa using this
  have hr1 := hpos 1
  have hrm := hpos m
  have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hm0 : (0 : ℝ) ≤ m := by linarith
  have h2 : (n : ℝ) ≤ ε * ((m : ℝ) + 1) / r m := (Nat.cast_le.2 hn).trans (Nat.floor_le (by positivity))
  have h3 : 1 / r m ≤ (m : ℝ) * (1 / r 1) := by
    rw [div_le_iff₀ hrm]
    have : (m : ℝ) * (1 / r 1) * r m = (m * r m) / r 1 := by field_simp
    rw [this, le_div_iff₀ hr1]
    linarith
  have hc : 1 / r 1 ≤ (⌈1 / r 1⌉₊ : ℝ) := Nat.le_ceil _
  have h4 : (n : ℝ) ≤ ((m : ℝ) + 1) * ((m : ℝ) * ⌈1 / r 1⌉₊) := by
    calc (n : ℝ) ≤ ε * ((m : ℝ) + 1) / r m := h2
      _ = ε * (((m : ℝ) + 1) * (1 / r m)) := by ring
      _ ≤ 1 * (((m : ℝ) + 1) * ((m : ℝ) * ⌈1 / r 1⌉₊)) := by
          have : 0 ≤ 1 / r m := by positivity
          have h7 : 1 / r m ≤ (m : ℝ) * ⌈1 / r 1⌉₊ := h3.trans (mul_le_mul_of_nonneg_left hc hm0)
          gcongr
      _ = _ := by ring
  have h5 : ((m : ℝ) + 1) * ((m : ℝ) * ⌈1 / r 1⌉₊) ≤ (⌈1 / r 1⌉₊ : ℝ) * ((m : ℝ) + 2) ^ 2 := by
    have : (0 : ℝ) ≤ ⌈1 / r 1⌉₊ := by positivity
    nlinarith
  have h6 : (n : ℝ) ≤ (⌈1 / r 1⌉₊ : ℝ) * ((m : ℝ) + 2) ^ 2 := h4.trans h5
  exact_mod_cast h6

/-- The length of the input of the host, for n ≤ c·(m+2)² gates. -/
theorem input_le_gen {c m n : ℕ} (hc : 1 ≤ c) (hn : n ≤ c * (m + 2) ^ 2) :
    m + 1 + ((m + n) + 1 + n * (4 + 2 * (m + n))) + 1 ≤ 11 * c ^ 2 * (m + 2) ^ 4 := by
  obtain ⟨Z, hZ⟩ : ∃ Z, Z = c * (m + 2) ^ 2 := ⟨_, rfl⟩
  have h1 : m + 2 ≤ Z := by
    rw [hZ]
    calc m + 2 ≤ (m + 2) ^ 2 := by nlinarith
      _ ≤ c * (m + 2) ^ 2 := Nat.le_mul_of_pos_left _ hc
  have hnZ : n ≤ Z := hZ ▸ hn
  have h2 : Z * Z = c ^ 2 * (m + 2) ^ 4 := by rw [hZ]; ring
  have h3 : n * n ≤ Z * Z := Nat.mul_le_mul hnZ hnZ
  have h4 : n * m ≤ Z * Z := Nat.mul_le_mul hnZ (by omega)
  have h5 : Z ≤ Z * Z := Nat.le_mul_self Z
  nlinarith

/-- **The time bound of the host, for a general rate.** ε depends only on q and D. -/
theorem threshold_gen {r : ℕ → ℝ} (hr : RateOK r) (q D a₀ : ℕ) : ∃ ε : ℝ, 0 < ε ∧ ε ≤ 1 ∧ ∀ G : ℕ, ∃ m₀ : ℕ, ∀ m : ℕ, m₀ ≤ m → ∀ n Nv M B : ℕ,
    n ≤ sizeR r ε m → Nv ≤ 3 * n + a₀ * (m + 1) + G → M ≤ 5 * Nv + 2 → B ≤ SatM.bound r D 3 M →
    q * ((m + 1 + ((m + n) + 1 + n * (4 + 2 * (m + n)))) + B + 1) ^ q ≤ 2 ^ (m / 8) := by
  obtain ⟨hpos, hanti, hmono, hlim⟩ := hr
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
  obtain ⟨K, hK⟩ : ∃ K : ℕ, K = 5 * a₀ + 5 * G + 2 := ⟨_, rfl⟩
  have hK1 : (1 : ℝ) ≤ K := by
    have : 1 ≤ K := by omega
    exact_mod_cast this
  -- r(m) ≤ η/K for m large
  obtain ⟨M₁, hM₁⟩ : ∃ M₁ : ℕ, ∀ m, M₁ ≤ m → r m ≤ η / K := by
    rw [Metric.tendsto_atTop] at hlim
    obtain ⟨M₁, h⟩ := hlim (η / K) (by positivity)
    refine ⟨M₁, fun m hm => ?_⟩
    have := h m hm
    rw [Real.dist_eq, sub_zero] at this
    exact (le_abs_self _).trans this.le
  obtain ⟨c, hc⟩ : ∃ c, c = ⌈1 / r 1⌉₊ := ⟨_, rfl⟩
  have hc1 : 1 ≤ c := by rw [hc]; exact Nat.one_le_iff_ne_zero.2 (by have := hpos 1; positivity)
  obtain ⟨C₁, hC₁⟩ := Groundwork.exists_pow_le (4 * q) (ε := 1 / 32) (by norm_num)
  obtain ⟨Kf, hKf⟩ : ∃ Kf : ℕ, Kf = q * (11 * c ^ 2) ^ q * C₁ * (D + 1) ^ q * 2 := ⟨_, rfl⟩
  refine ⟨max (max M₁ 1) (16 * (Kf + 1)), fun m hm n Nv M B hn hNv hM hB => ?_⟩
  have hmM : M₁ ≤ m := le_of_max_le_left (le_of_max_le_left hm)
  have hm1 : 1 ≤ m := le_of_max_le_right (le_of_max_le_left hm)
  have hmK : 16 * (Kf + 1) ≤ m := le_of_max_le_right hm
  have hm0 : (0 : ℝ) ≤ m := by positivity
  have hrm := hpos m
  -- the number of clauses, and M·r(M)
  obtain ⟨Bn, hBn⟩ : ∃ Bn : ℕ, Bn = 15 * sizeR r ε m + K * (m + 1) := ⟨_, rfl⟩
  have hMB : M ≤ Bn := by
    rw [hBn, hK]
    have : Nv ≤ 3 * sizeR r ε m + a₀ * (m + 1) + G := by omega
    nlinarith
  have hmB : m ≤ Bn := by rw [hBn, hK]; nlinarith
  have hf1 : (M : ℝ) * r M ≤ (Bn : ℝ) * r Bn := hmono hMB
  have hf2 : (Bn : ℝ) * r Bn ≤ (Bn : ℝ) * r m := mul_le_mul_of_nonneg_left (hanti hmB) (by positivity)
  have hBr : (Bn : ℝ) ≤ 15 * (ε * ((m : ℝ) + 1) / r m) + K * ((m : ℝ) + 1) := by
    have h1 : (sizeR r ε m : ℝ) ≤ ε * ((m : ℝ) + 1) / r m := Nat.floor_le (by positivity)
    rw [hBn]; push_cast; linarith
  have hf3 : (Bn : ℝ) * r m ≤ 15 * ε * ((m : ℝ) + 1) + η * ((m : ℝ) + 1) := by
    have h1 : (Bn : ℝ) * r m ≤ (15 * (ε * ((m : ℝ) + 1) / r m) + K * ((m : ℝ) + 1)) * r m :=
      mul_le_mul_of_nonneg_right hBr hrm.le
    have h2 : (15 * (ε * ((m : ℝ) + 1) / r m) + K * ((m : ℝ) + 1)) * r m = 15 * ε * ((m : ℝ) + 1) + K * r m * ((m : ℝ) + 1) := by
      field_simp
    have h3 : (K : ℝ) * r m ≤ η := by
      have := hM₁ m hmM
      rw [le_div_iff₀ (by linarith)] at this
      linarith
    have h4 : (K : ℝ) * r m * ((m : ℝ) + 1) ≤ η * ((m : ℝ) + 1) := mul_le_mul_of_nonneg_right h3 (by positivity)
    linarith
  have hf : (M : ℝ) * r M ≤ 15 * ε * ((m : ℝ) + 1) + η * ((m : ℝ) + 1) := hf1.trans (hf2.trans hf3)
  -- the time of the machine for 3-SAT
  have hBr2 : (B : ℝ) ≤ D * (2 : ℝ) ^ (3 * D * ((M : ℝ) * r M)) := by
    have h1 := (Nat.cast_le (α := ℝ)).2 hB
    unfold SatM.bound at h1
    refine h1.trans ((Nat.floor_le (by positivity)).trans (le_of_eq ?_))
    push_cast
    ring_nf
  obtain ⟨Y, hY⟩ : ∃ Y : ℝ, Y = 3 * D * (15 * ε * ((m : ℝ) + 1) + η * ((m : ℝ) + 1)) := ⟨_, rfl⟩
  have hfY : 3 * D * ((M : ℝ) * r M) ≤ Y := by rw [hY]; exact mul_le_mul_of_nonneg_left hf (by positivity)
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
      have : (2 : ℝ) ^ (3 * D * ((M : ℝ) * r M)) ≤ (2 : ℝ) ^ Y := Real.rpow_le_rpow_of_exponent_le one_le_two hfY
      have : (D : ℝ) * (2 : ℝ) ^ (3 * D * ((M : ℝ) * r M)) ≤ D * (2 : ℝ) ^ Y := mul_le_mul_of_nonneg_left this (by positivity)
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
  have hnc : n ≤ c * (m + 2) ^ 2 := hc ▸ gates_le_gen ⟨hpos, hanti, hmono, hlim⟩ hε hε1 hm1 hn
  obtain ⟨X, hX⟩ : ∃ X, X = m + 1 + ((m + n) + 1 + n * (4 + 2 * (m + n))) := ⟨_, rfl⟩
  rw [← hX]
  have hX1 : X + 1 ≤ 11 * c ^ 2 * (m + 2) ^ 4 := by rw [hX]; exact input_le_gen hc1 hnc
  have hXq : ((X : ℝ) + 1) ^ q ≤ ((11 * c ^ 2 : ℕ) : ℝ) ^ q * (C₁ * p) := by
    have h1 : (X : ℝ) + 1 ≤ ((11 * c ^ 2 : ℕ) : ℝ) * ((m : ℝ) + 2) ^ 4 := by exact_mod_cast hX1
    calc ((X : ℝ) + 1) ^ q ≤ (((11 * c ^ 2 : ℕ) : ℝ) * ((m : ℝ) + 2) ^ 4) ^ q := by gcongr
      _ = ((11 * c ^ 2 : ℕ) : ℝ) ^ q * ((m : ℝ) + 2) ^ (4 * q) := by rw [mul_pow, ← pow_mul]
      _ ≤ ((11 * c ^ 2 : ℕ) : ℝ) ^ q * (C₁ * p) := by rw [hp]; gcongr; exact hC₁ m
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
      _ ≤ (q : ℝ) * ((((11 * c ^ 2 : ℕ) : ℝ) ^ q * (C₁ * p)) * (((D : ℝ) + 1) ^ q * (2 * p))) := by gcongr
      _ = (Kf : ℝ) * (p * p) := by rw [hKf]; push_cast; ring
      _ ≤ (2 : ℝ) ^ (m / 8) := hfin
  exact_mod_cast hmain

end Superlinear
