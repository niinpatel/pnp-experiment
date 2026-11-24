module

public import Superlinear.Host
public import Superlinear.FormC
public import Superlinear.Arith2
public import Superlinear.Chain
import Mathlib.Tactic

/-! # The algorithm of the circuit lower bound, with the clause rate of the engine

As Superlinear/Host.lean, with one change in the formula handed to the engine: the clauses
xᵥ ∨ ¬xᵥ for all v < Nv + 1 are added and the result is deduplicated (`fml2`). Then every
variable occurs (the clause rate asks for that), the formula is satisfiable exactly when the
formula of the host is, it has no clause twice, and it has at most (4·Nv + 1) + (Nv + 1) clauses
(`FormC.lean`). The count of the engine is not the count of the host formula, but it is 0 exactly
when the host formula is unsatisfiable, which is all the host asks.

* `stAlgT`: `StAlgGen (sizeT ε)` for some ε > 0. -/

@[expose] public section

namespace Superlinear

open Groundwork Groundwork.Prog Turing ENP CircuitLowerBound VariableBound VariableBound.Decide

/-- The clauses xᵥ ∨ ¬xᵥ for v < n. -/
def taut (n : ℕ) : Cnf := (List.range n).map fun v => [(v, true), (v, false)]

/-- The formula with one spare variable and all the clauses xᵥ ∨ ¬xᵥ, deduplicated. -/
def fml2 (p : List Unit × Cnf) : List Unit × Cnf := (p.1 ++ [()], (p.2 ++ taut (p.1.length + 1)).dedup)

/-- The code of the formula handed to the engine. -/
def hostEnc2 (F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf) (fb : List Unit → Bool) (x : List Bool) : List Bool :=
  Rename.encN (List.replicate 3 ()) (fml2 (Alg.pre F fb x))

/-- The exponent of the pad. -/
def hostE2 (e : List Bool → ℕ) (F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf) (fb : List Unit → Bool) (x : List Bool) : ℕ :=
  e (hostEnc2 F fb x)

/-- The host: the engine on the code, then «is the count 0?». -/
def hostB2 (A : List Bool × PaddedDescent.F.U → List Bool) (F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf) (fb : List Unit → Bool)
    (p : List Bool × List Unit) : List Bool :=
  [Alg.isZ (A (hostEnc2 F fb p.1, p.2))]

theorem hostEnc2_polyT {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : PolyT F) (hb : PolyT fb) : PolyT (hostEnc2 F fb) := by
  have hp := Alg.pre_polyT stCertSched hF hb
  unfold hostEnc2 fml2 taut
  exact Rename.encN_polyT (by fun_prop) (by fun_prop)

theorem hostE2_polyT {e : List Bool → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (he : PolyT e) (hF : PolyT F) (hb : PolyT fb) : PolyT (hostE2 e F fb) := by
  have := hostEnc2_polyT hF hb
  unfold hostE2
  fun_prop

theorem hostB2_polyT {A : List Bool × PaddedDescent.F.U → List Bool} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hA : PolyT A) (hF : PolyT F) (hb : PolyT fb) : PolyT (hostB2 A F fb) := by
  have := hostEnc2_polyT hF hb
  have := Alg.isZ_polyT
  unfold hostB2
  fun_prop

theorem mem_taut {n : ℕ} {D : List (ℕ × Bool)} : D ∈ taut n ↔ ∃ v, v < n ∧ D = [(v, true), (v, false)] := by
  unfold taut
  simp only [List.mem_map, List.mem_range]
  constructor
  · rintro ⟨v, hv, rfl⟩; exact ⟨v, hv, rfl⟩
  · rintro ⟨v, hv, rfl⟩; exact ⟨v, hv, rfl⟩

/-- Adding the clauses xᵥ ∨ ¬xᵥ and deduplicating does not change satisfiability. -/
theorem sat_fml2 (ψ : Cnf) (n : ℕ) : Sat (ψ ++ taut n).dedup ↔ Sat ψ := by
  constructor
  · rintro ⟨a, ha⟩
    exact ⟨a, fun D hD => ha D (List.mem_dedup.2 (List.mem_append_left _ hD))⟩
  · rintro ⟨a, ha⟩
    refine ⟨a, fun D hD => ?_⟩
    rcases List.mem_append.1 (List.mem_dedup.1 hD) with hD | hD
    · exact ha D hD
    · obtain ⟨v, -, rfl⟩ := mem_taut.1 hD
      cases h : a v
      · exact ⟨(v, false), by simp, h⟩
      · exact ⟨(v, true), by simp, h⟩

/-- The formula handed to the engine as a 3-CNF on Nv + 1 variables: its code, «count 0 iff the host
formula is unsatisfiable», all variables occur, and at least one and at most |ψ| + Nv + 1 clauses. -/
theorem hostEnc2_spec {a₀ : ℕ} {g : MCode → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : Alg.FormOK a₀ g F) (x : List Bool) :
    ∃ φ : Sat3.CNF ((Alg.pre F fb x).1.length + 1), SatK.IsKCNF 3 φ ∧ hostEnc2 F fb x = SatM.enc 3 φ ∧
      (SatK.numSat φ = 0 ↔ ¬Sat (Alg.pre F fb x).2) ∧ SatM.AllOccur φ ∧ 1 ≤ φ.length ∧
      φ.length ≤ (Alg.pre F fb x).2.length + (Alg.pre F fb x).1.length + 1 := by
  obtain ⟨h1, -⟩ := Alg.shaped_pre (fb := fb) hF x
  have hshape : ∀ D ∈ ((Alg.pre F fb x).2 ++ taut ((Alg.pre F fb x).1.length + 1)).dedup,
      D.length ≤ 3 ∧ ∀ l ∈ D, l.1 < (Alg.pre F fb x).1.length + 1 := by
    intro D hD
    rcases List.mem_append.1 (List.mem_dedup.1 hD) with hD | hD
    · exact ⟨(h1 D hD).1, fun l hl => Nat.lt_succ_of_lt ((h1 D hD).2 l hl)⟩
    · obtain ⟨v, hv, rfl⟩ := mem_taut.1 hD
      refine ⟨by simp, fun l hl => ?_⟩
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hl
      rcases hl with rfl | rfl <;> exact hv
  obtain ⟨φ, hk, hφ⟩ := SplitSat.exists_instance hshape (List.nodup_dedup _)
  have hlen : φ.length = (((Alg.pre F fb x).2 ++ taut ((Alg.pre F fb x).1.length + 1)).dedup).length := by
    rw [← hφ]; simp [Decode.toN]
  have hmem : ∀ v, v < (Alg.pre F fb x).1.length + 1 →
      [(v, true), (v, false)] ∈ ((Alg.pre F fb x).2 ++ taut ((Alg.pre F fb x).1.length + 1)).dedup := fun v hv =>
    List.mem_dedup.2 (List.mem_append_right _ (mem_taut.2 ⟨v, hv, rfl⟩))
  refine ⟨φ, hk, ?_, ?_, ?_, ?_, ?_⟩
  · rw [← Rename.encN_toN, hφ, hostEnc2, fml2]
    congr 2
    exact List.eq_replicate_iff.2 ⟨by simp, fun _ _ => rfl⟩
  · rw [← CountKSat.stCntToN, hφ]
    exact (Alg.cntN_eq_zero_iff fun D hD => (hshape D hD).2).trans (not_congr (sat_fml2 _ _))
  · intro i
    have hm := hmem i.val i.isLt
    rw [← hφ] at hm
    unfold Decode.toN at hm
    obtain ⟨C, hC, hCe⟩ := List.mem_map.1 hm
    have h2 : (i.val, true) ∈ C.map fun l => (l.1.val, l.2) := by rw [hCe]; simp
    obtain ⟨l, hl, hle⟩ := List.mem_map.1 h2
    exact ⟨C, hC, l, hl, Fin.ext (congrArg Prod.fst hle)⟩
  · rw [hlen]
    exact List.length_pos_of_mem (hmem 0 (by omega))
  · rw [hlen]
    refine (List.dedup_sublist _).length_le.trans ?_
    simp [taut]
    omega

/-- What the host puts out: «the formula of x is unsatisfiable». -/
theorem hostB2_eq {rn rm : ℕ → ℝ} {A : List Bool × PaddedDescent.F.U → List Bool} {e : List Bool → ℕ} (hA : Decide.Alg rn rm A e)
    {a₀ : ℕ} {g : MCode → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : Alg.FormOK a₀ g F) (x : List Bool) :
    ∃ b : Bool, hostB2 A F fb (x, PaddedDescent.pad (hostE2 e F fb x)) = [b] ∧ (b = true ↔ ¬Sat (Alg.pre F fb x).2) := by
  obtain ⟨φ, hk, henc, hz, -⟩ := hostEnc2_spec (fb := fb) hF x
  have hc := hA.correct 3 _ φ (by norm_num) hk (PaddedDescent.pad (hostE2 e F fb x)) (by simp [PaddedDescent.pad, hostE2, henc])
  have hlt : SatK.numSat φ < 2 ^ ((Alg.pre F fb x).1.length + 1 + 1) := by
    rw [← CountKSat.stCntToN]; exact Alg.cntN_lt _ _
  unfold hostB2
  rw [henc, hc]
  exact ⟨_, rfl, (Alg.isZ_binary hlt).trans hz⟩

/-- The machine accepts only where `Phi m` is satisfiable. -/
theorem sound2 {rn rm : ℕ → ℝ} {A : List Bool × PaddedDescent.F.U → List Bool} {e : List Bool → ℕ} (hA : Decide.Alg rn rm A e)
    {a₀ : ℕ} {g : MCode → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : Alg.FormOK a₀ g F) (hb : Alg.FlipOK fb) {N : TM2ComputableAux Bool Bool} {t : List Bool → ℕ}
    (hN : ∀ x : List Bool, Nonempty (TM2OutputsInTime N.tm (x.map N.inputAlphabet.invFun)
      (some ((hostB2 A F fb (x, PaddedDescent.pad (hostE2 e F fb x))).map N.outputAlphabet.invFun)) (t x))) :
    ∀ m T : ℕ, Acc N m T → Sat (Phi m) := by
  rintro m T ⟨y, ⟨ev⟩⟩
  obtain ⟨ev'⟩ := hN (unary m ++ y)
  have h5 := Alg.outputs_unique ev ev'
  obtain ⟨b, hbe, hbi⟩ := hostB2_eq (fb := fb) hA hF (unary m ++ y)
  rw [hbe] at h5
  simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at h5
  have h6 : b = true := (N.outputAlphabet.symm.injective h5).symm
  have h7 := Alg.sat_Phi_of_pre hF hb _ (hbi.1 h6)
  rwa [Parse.ones_unary_append] at h7

/-- **The algorithm**, with the clause rate of the engine: `StAlgGen (sizeT ε)` for some ε > 0. The
machine depends on (A, e, F, fb) only, and ε on the constants q (of the machine) and D (of the
engine, bound in m) only. -/
theorem stAlgT : ∃ ε : ℝ, 0 < ε ∧ StAlgGen (sizeT ε) := by
  obtain ⟨A, e, hA⟩ := exists_alg
  obtain ⟨a₀, g, F, hFp, hF, hcl⟩ := stFormC
  obtain ⟨fb, hbp, hb⟩ := stFlip
  have hb' : Alg.FlipOK fb := hb
  obtain ⟨N, q, hfin, hN⟩ := CountKSatRate.stPaddedW (hostE2 e F fb) (hostB2 A F fb) (hostE2_polyT hA.polyE hFp hbp) (hostB2_polyT hA.polyA hFp hbp)
  obtain ⟨D, hD⟩ := hA.timeM 1
  obtain ⟨ε, hε, -, hth⟩ := threshold2 q D a₀
  refine ⟨ε, hε, N, hfin, sound2 hA hF hb' hN, fun e' => ?_⟩
  obtain ⟨m₀, hm₀⟩ := hth (g e')
  refine ⟨max m₀ 1, fun m hm he hpos C hCl hC => ?_⟩
  obtain ⟨y, hy, hns, hNv⟩ := Alg.exists_guess hF hb' stNorm (le_of_max_le_right hm) hpos C hC
  rw [he] at hNv
  obtain ⟨ev⟩ := hN (unary m ++ y)
  obtain ⟨b, hbe, hbi⟩ := hostB2_eq (fb := fb) hA hF (unary m ++ y)
  obtain rfl : b = true := hbi.2 hns
  rw [hbe] at ev
  obtain ⟨φ, hk, henc, -, hocc, hl1, hl2⟩ := hostEnc2_spec (fb := fb) hF (unary m ++ y)
  have hcls := pre_clauses hcl fb (unary m ++ y)
  have hM : φ.length ≤ 5 * (Alg.pre F fb (unary m ++ y)).1.length + 2 := by omega
  have hpad : 2 ^ hostE2 e F fb (unary m ++ y) ≤ SatM.bound (SatM.rPow (1 / 2)) D 3 φ.length := by
    have h1 := hD 3 _ φ (by norm_num) hl1 hk hocc
    simp only [one_mul, pow_one] at h1
    unfold hostE2
    rw [henc]
    omega
  have h8 := hm₀ m (le_of_max_le_left hm) C.length _ _ _ hCl hNv hM hpad
  have h9 : (unary m ++ y).length = m + 1 + ((m + C.length) + 1 + C.length * (4 + 2 * (m + C.length))) := by
    rw [List.length_append, hy]
    simp [unary]
  rw [← h9] at h8
  exact ⟨y, ⟨⟨ev.toEvalsTo, ev.steps_le_m.trans h8⟩⟩⟩

end Superlinear
