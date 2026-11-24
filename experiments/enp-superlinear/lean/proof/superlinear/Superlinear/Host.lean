module

public import Superlinear.Engine
public import Superlinear.Arith
public import CircuitLowerBound.Closed
public import VariableBound.Paper.Rename.Cert
public import SplitSat.Leaf
import Mathlib.Tactic

/-! # The algorithm of the circuit lower bound, with the engine of the explicit rate

The machine of `CircuitLowerBound.StAlg` is built here without a machine cut into steps: the host is
a padded function. On input x it writes the formula `Alg.pre F fb x` of the existing proof
(proof/consequences/CircuitLowerBound/Alg/Machine.lean) as the code of a 3-CNF on Nv + 1
variables (`hostEnc`; one spare variable so that n ≥ 1), and answers «the count is 0» by the
algorithm A of the explicit rate with the pad of 2^(e (hostEnc x)) units (`hostB`, `hostE`). The
padding machine `CountKSatRate.stPaddedW` makes one Turing machine of it.

* `sound`: the machine accepts 1^m 0 y only if `Phi m` is satisfiable.
* `StAlgS ε`: `CircuitLowerBound.StAlg` with the size bound c₀·(m+1) replaced by `sizeS ε m`.
* `stAlgS`: `StAlgS ε` for some ε > 0. The machine depends on (A, e, F, fb) only, and ε on the
  constants q (of the machine) and D (of the engine) only; both are fixed before the table e. -/

@[expose] public section

namespace Superlinear

open Groundwork Groundwork.Prog Turing ENP CircuitLowerBound VariableBound VariableBound.Decide

/-- The host formula, written as the code of a 3-CNF on Nv + 1 variables (one spare variable so
that n ≥ 1). -/
def hostEnc (F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf) (fb : List Unit → Bool) (x : List Bool) : List Bool :=
  Rename.encN (List.replicate 3 ()) ((Alg.pre F fb x).1 ++ [()], (Alg.pre F fb x).2)

/-- The exponent of the pad of the host. -/
def hostE (e : List Bool → ℕ) (F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf) (fb : List Unit → Bool) (x : List Bool) : ℕ := e (hostEnc F fb x)

/-- The host: the engine on the code, then «is the count 0?». -/
def hostB (A : List Bool × PaddedDescent.F.U → List Bool) (F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf) (fb : List Unit → Bool) (p : List Bool × List Unit) : List Bool :=
  [Alg.isZ (A (hostEnc F fb p.1, p.2))]

theorem hostEnc_polyT {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : PolyT F) (hb : PolyT fb) : PolyT (hostEnc F fb) := by
  have hp := Alg.pre_polyT stCertSched hF hb
  unfold hostEnc
  exact Rename.encN_polyT (by fun_prop) (by fun_prop)

theorem hostE_polyT {e : List Bool → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (he : PolyT e) (hF : PolyT F) (hb : PolyT fb) : PolyT (hostE e F fb) := by
  have := hostEnc_polyT hF hb
  unfold hostE
  fun_prop

theorem hostB_polyT {A : List Bool × PaddedDescent.F.U → List Bool} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hA : PolyT A) (hF : PolyT F) (hb : PolyT fb) : PolyT (hostB A F fb) := by
  have := hostEnc_polyT hF hb
  have := Alg.isZ_polyT
  unfold hostB
  fun_prop

/-- The host formula as a 3-CNF on Nv + 1 variables, with its code and its count. -/
theorem hostEnc_spec {a₀ : ℕ} {g : MCode → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : Alg.FormOK a₀ g F) (x : List Bool) :
    ∃ φ : Sat3.CNF ((Alg.pre F fb x).1.length + 1), SatK.IsKCNF 3 φ ∧ hostEnc F fb x = SatM.enc 3 φ ∧
      (SatK.numSat φ = 0 ↔ ¬Sat (Alg.pre F fb x).2) := by
  obtain ⟨h1, h2⟩ := Alg.shaped_pre (fb := fb) hF x
  obtain ⟨φ, hk, hφ⟩ := SplitSat.exists_instance (k := 3) (n := (Alg.pre F fb x).1.length + 1)
    (fun D hD => ⟨(h1 D hD).1, fun l hl => Nat.lt_succ_of_lt ((h1 D hD).2 l hl)⟩) h2
  refine ⟨φ, hk, ?_, ?_⟩
  · rw [← Rename.encN_toN, hφ, hostEnc]
    congr 2
    exact List.eq_replicate_iff.2 ⟨by simp, fun _ _ => rfl⟩
  · rw [← CountKSat.stCntToN, hφ]
    exact Alg.cntN_eq_zero_iff fun D hD l hl => Nat.lt_succ_of_lt ((h1 D hD).2 l hl)

/-- What the host puts out: «the formula of x is unsatisfiable». -/
theorem hostB_eq {rn rm : ℕ → ℝ} {A : List Bool × PaddedDescent.F.U → List Bool} {e : List Bool → ℕ} (hA : Decide.Alg rn rm A e)
    {a₀ : ℕ} {g : MCode → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : Alg.FormOK a₀ g F) (x : List Bool) :
    ∃ b : Bool, hostB A F fb (x, PaddedDescent.pad (hostE e F fb x)) = [b] ∧ (b = true ↔ ¬Sat (Alg.pre F fb x).2) := by
  obtain ⟨φ, hk, henc, hz⟩ := hostEnc_spec (fb := fb) hF x
  have hc := hA.correct 3 _ φ (by norm_num) hk (PaddedDescent.pad (hostE e F fb x)) (by simp [PaddedDescent.pad, hostE, henc])
  have hlt : SatK.numSat φ < 2 ^ ((Alg.pre F fb x).1.length + 1 + 1) := by
    rw [← CountKSat.stCntToN]; exact Alg.cntN_lt _ _
  unfold hostB
  rw [henc, hc]
  exact ⟨_, rfl, (Alg.isZ_binary hlt).trans hz⟩

/-- The soundness half of the new `StAlg`: a padded machine for the host accepts only where `Phi m`
is satisfiable. -/
theorem sound {rn rm : ℕ → ℝ} {A : List Bool × PaddedDescent.F.U → List Bool} {e : List Bool → ℕ} (hA : Decide.Alg rn rm A e)
    {a₀ : ℕ} {g : MCode → ℕ} {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} {fb : List Unit → Bool}
    (hF : Alg.FormOK a₀ g F) (hb : Alg.FlipOK fb) {N : TM2ComputableAux Bool Bool} {t : List Bool → ℕ}
    (hN : ∀ x : List Bool, Nonempty (TM2OutputsInTime N.tm (x.map N.inputAlphabet.invFun)
      (some ((hostB A F fb (x, PaddedDescent.pad (hostE e F fb x))).map N.outputAlphabet.invFun)) (t x))) :
    ∀ m T : ℕ, Acc N m T → Sat (Phi m) := by
  rintro m T ⟨y, ⟨ev⟩⟩
  obtain ⟨ev'⟩ := hN (unary m ++ y)
  have h5 := Alg.outputs_unique ev ev'
  obtain ⟨b, hbe, hbi⟩ := hostB_eq (fb := fb) hA hF (unary m ++ y)
  rw [hbe] at h5
  simp only [List.map_cons, List.map_nil, List.cons.injEq, and_true] at h5
  have h6 : b = true := (N.outputAlphabet.symm.injective h5).symm
  have h7 := Alg.sat_Phi_of_pre hF hb _ (hbi.1 h6)
  rwa [Parse.ones_unary_append] at h7

/-- `CircuitLowerBound.StAlg` with the size bound `sizeS ε m` in place of c₀·(m+1): ONE machine N:
(1) if N accepts 1^m 0 y, then `Phi m` is satisfiable; (2) for every table e there is m₀ such that
for all m ≥ m₀ on a chain of e: if a circuit with at most `sizeS ε m` gates computes a satisfying
assignment of `Phi m`, then N accepts 1^m 0 y for some y within 2^(m/8) steps. -/
def StAlgS (ε : ℝ) : Prop := ∃ N : TM2ComputableAux Bool Bool, (∀ k, Finite (N.tm.Γ k)) ∧
  (∀ m T : ℕ, Acc N m T → Sat (Phi m)) ∧
  ∀ e : MCode, ∃ m₀ : ℕ, ∀ m : ℕ, m₀ ≤ m → codeOf (nu m) = e → pos m ≤ top (nu m) →
    ∀ C : Circuit, C.length ≤ ENP.sizeS ε m → (∀ D ∈ Phi m, ∃ l ∈ D, eval C (toWord m l.1) = l.2) → Acc N m (2 ^ (m / 8))

/-- **The algorithm**, with the engine of the explicit rate: `StAlgS ε` for some ε > 0. -/
theorem stAlgS : ∃ ε : ℝ, 0 < ε ∧ StAlgS ε := by
  obtain ⟨A, e, hA⟩ := exists_alg
  obtain ⟨a₀, g, F, hFp, hF⟩ := stForm
  obtain ⟨fb, hbp, hb⟩ := stFlip
  have hF' : Alg.FormOK a₀ g F := hF
  have hb' : Alg.FlipOK fb := hb
  obtain ⟨N, q, hfin, hN⟩ := CountKSatRate.stPaddedW (hostE e F fb) (hostB A F fb) (hostE_polyT hA.polyE hFp hbp) (hostB_polyT hA.polyA hFp hbp)
  obtain ⟨D, hD⟩ := hA.timeN 1
  obtain ⟨ε, hε, -, hth⟩ := threshold q D a₀
  refine ⟨ε, hε, N, hfin, sound hA hF' hb' hN, fun e' => ?_⟩
  obtain ⟨m₀, hm₀⟩ := hth (g e')
  refine ⟨max m₀ 1, fun m hm he hpos C hCl hC => ?_⟩
  obtain ⟨y, hy, hns, hNv⟩ := Alg.exists_guess hF' hb' stNorm (le_of_max_le_right hm) hpos C hC
  rw [he] at hNv
  obtain ⟨ev⟩ := hN (unary m ++ y)
  obtain ⟨b, hbe, hbi⟩ := hostB_eq (fb := fb) hA hF' (unary m ++ y)
  obtain rfl : b = true := hbi.2 hns
  rw [hbe] at ev
  -- the pad is within the bound of the engine on Nv + 1 variables
  obtain ⟨φ, hk, henc, -⟩ := hostEnc_spec (fb := fb) hF' (unary m ++ y)
  have hpad : 2 ^ hostE e F fb (unary m ++ y) ≤ SatM.boundNK (SatK.rN 1 (1 / 2)) D 3 ((Alg.pre F fb (unary m ++ y)).1.length + 1) := by
    have h1 := hD 3 _ φ (by norm_num) (by omega) hk
    simp only [one_mul, pow_one] at h1
    unfold hostE
    rw [henc]
    omega
  have h8 := hm₀ m (le_of_max_le_left hm) C.length _ _ hCl hNv hpad
  have h9 : (unary m ++ y).length = m + 1 + ((m + C.length) + 1 + C.length * (4 + 2 * (m + C.length))) := by
    rw [List.length_append, hy]
    simp [unary]
  rw [← h9] at h8
  exact ⟨y, ⟨⟨ev.toEvalsTo, ev.steps_le_m.trans h8⟩⟩⟩

end Superlinear
