module

public import Superlinear.Smoke
public import CircuitLowerBound.Closed
public import VariableBound.Paper.Rename.Cert
public import SplitSat.Leaf
import Mathlib.Tactic

/-! Smoke test: the host algorithm as a padded function (no machine cut into steps), and its
polynomial-time certificates, and the soundness half of the new `StAlg`. -/

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

end Superlinear
