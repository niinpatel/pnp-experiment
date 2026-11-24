module

public import CircuitLowerBound.Closed
import all CircuitLowerBound.Circ.Form
import Mathlib.Tactic

/-! # The formula of the host has at most 4·Nv + 1 clauses

The formula `CircuitLowerBound.Form.F B` of `stForm_of` (proof/consequences/CircuitLowerBound/Circ/Form.lean)
is the deduplicated Tseitin formula of a circuit K (four clauses per gate) and one unit clause, on
nF + |K| variables. So it has at most 4·(number of variables) + 1 clauses (`clauses_F`).
`stFormC`: `StForm` with this clause bound added; the proof repeats the ten lines of `stForm_of` for
the same F (it needs `import all` of Form.lean to unfold F, as other files of the development do). `pre_clauses`: the bound for every formula `Alg.pre F fb x` of the host. -/

@[expose] public section

namespace Superlinear

open ENP Groundwork CircuitLowerBound CircuitLowerBound.Form

theorem length_tseitin (n : ℕ) (K : List GateD) : (tseitin n K).length = 4 * K.length := by
  unfold tseitin
  rw [List.length_flatMap]
  simp [gateCl, List.sum_replicate, mul_comm]

theorem clauses_F (B : MCode × List Unit × ℕ → List GateD × List ℕ) (q : (MCode × List Unit × ℕ) × List GateD) :
    (F B q).2.length ≤ 4 * (F B q).1.length + 1 := by
  unfold F
  simp only [List.length_replicate]
  refine (List.dedup_sublist _).length_le.trans ?_
  rw [List.length_append, length_tseitin]
  simp

/-- `StForm` with the bound on the number of clauses. -/
def StFormC : Prop := ∃ (a₀ : ℕ) (g : MCode → ℕ) (F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf), PolyT F ∧
  Alg.FormOK a₀ g F ∧ ∀ q, (F q).2.length ≤ 4 * (F q).1.length + 1

theorem stFormC : StFormC := by
  obtain ⟨a₀, g, B, hB, hspec⟩ := stClauseCirc
  refine ⟨a₀ + 1, fun e => g e + rb e + 5, F B, F_polyT B hB, fun e L P C hFit hC => ?_, clauses_F B⟩
  obtain ⟨hG, hlen, ho, hoN, hval⟩ := hspec e L P hFit
  have hs := form_spec hFit hG ho hoN hval hC
  have hn := nF_eq hFit
  have hle : nb e L ≤ rb e + L := hn ▸ min_le_right _ _
  simp only [F, cK, List.length_replicate, hn]
  refine ⟨hs.1, ?_, hs.2⟩
  rw [length_check, Nat.add_mul, Nat.one_mul]
  omega

/-- Every formula of the host has at most 4·Nv + 1 clauses. -/
theorem pre_clauses {F : (MCode × List Unit × ℕ) × List GateD → List Unit × Cnf} (hC : ∀ q, (F q).2.length ≤ 4 * (F q).1.length + 1)
    (fb : List Unit → Bool) (x : List Bool) : (Alg.pre F fb x).2.length ≤ 4 * (Alg.pre F fb x).1.length + 1 := by
  rcases Alg.pre_cases F fb x with ⟨_, _, _, e⟩ | ⟨_, _, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, e⟩ | ⟨_, _, e⟩ | ⟨_, e⟩ <;> rw [e]
  · exact hC _
  all_goals simp

end Superlinear
