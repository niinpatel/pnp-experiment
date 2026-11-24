module

public import CircuitLowerBoundInfinitelyOftenStatement
public import ClauseBoundStatement

/-! # The statement: any rate for 3-SAT in the number of clauses gives a circuit lower bound for E^NP

Definitions only (no theorem, no proof). It imports two statement files of the development, which
import Mathlib alone:
* `CircuitLowerBoundInfinitelyOftenStatement.lean` (and through it `CircuitLowerBoundStatement.lean`):
  `ENP.Lang`, `ENP.InENP`, `ENP.DecidedAt` (some circuit with at most s gates decides L on the words
  of length n);
* `ClauseBoundStatement.lean` (and through it `CountKSatStatement.lean`, `KSatStatement.lean`,
  `ThreeSatStatement.lean`): formulas `Sat3.CNF n`, `Sat3.Satisfiable`, `SatK.IsKCNF k φ` (at most k
  literals per clause, no clause written twice), `SatM.AllOccur φ` (every variable occurs),
  the code `SatM.enc k φ` (1ᵏ 0, then 1ⁿ 0, then k slots per clause), and the time bound
  `SatM.bound r C k m = ⌊C·2^{C·k·m·r(m)}⌋`.

## What a user supplies (the hypothesis `DecidesClauseRate r`)

A Turing machine of Mathlib (`Turing.TM2ComputableAux Bool Bool`, finite alphabets) and a constant
C such that, on the code `SatM.enc 3 φ` of every 3-CNF φ (at most 3 literals per clause, no clause
written twice) with at least one clause in which every variable occurs, the machine halts within
⌊C·2^{3C·m·r(m)}⌋ steps (m = the number of clauses) with the one-bit output «φ is satisfiable».
This is the shape of the bound in m of `SatM.CountUniformInRate` (UniformInKStatement.lean), at width
3, with a decision instead of a count.

## Regularity of the rate (`RateOK r`)

r(m) > 0 for all m; r is antitone; m·r(m) is monotone; r(m) → 0. For example r(m) = 1/√(log₂(m+2))
(`SatM.rPow (1/2)`), the rate proved in this development.

## The conclusion

`sizeR r ε n = ⌊ε·(n+1)/r(n)⌋`. `GeneralTransfer`: for every rate r with `RateOK r` and
`DecidesClauseRate r`, some language in E^NP is, for some ε > 0, not decided by circuits with at most
`sizeR r ε n` gates at infinitely many lengths n. With r = `SatM.rPow (1/2)`, `sizeR r ε` is
`ENP.sizeT ε` of `StatementSqrtLog.lean`. -/

@[expose] public section

namespace ENP

open Turing

/-- The size bound ⌊ε·(n+1)/r(n)⌋. -/
noncomputable def sizeR (r : ℕ → ℝ) (ε : ℝ) (n : ℕ) : ℕ := ⌊ε * ((n : ℝ) + 1) / r n⌋₊

/-- Regularity of the rate: positive, antitone, m·r(m) monotone, tending to 0. -/
def RateOK (r : ℕ → ℝ) : Prop :=
  (∀ m, 0 < r m) ∧ Antitone r ∧ Monotone (fun m : ℕ => (m : ℝ) * r m) ∧ Filter.Tendsto r Filter.atTop (nhds 0)

/-- One machine with finite alphabets and one constant C: on the code of every 3-CNF φ with
m ≥ 1 clauses, no clause twice, in which every variable occurs, it halts within ⌊C·2^{3C·m·r(m)}⌋
steps with the bit «φ is satisfiable». -/
def DecidesClauseRate (r : ℕ → ℝ) : Prop :=
  ∃ (M : TM2ComputableAux Bool Bool) (C : ℕ), (∀ i, Finite (M.tm.Γ i)) ∧
    ∀ (n : ℕ) (φ : Sat3.CNF n), SatK.IsKCNF 3 φ → 1 ≤ φ.length → SatM.AllOccur φ →
      ∃ b : Bool, (b = true ↔ Sat3.Satisfiable φ) ∧
        Nonempty (TM2OutputsInTime M.tm ((SatM.enc 3 φ).map M.inputAlphabet.invFun) (some ([b].map M.outputAlphabet.invFun))
          (SatM.bound r C 3 φ.length))

/-- Every rate with `RateOK` at which 3-SAT is decided in the number of clauses gives a language in
E^NP without circuits of size ⌊ε·(n+1)/r(n)⌋ at infinitely many lengths, for some ε > 0. -/
def GeneralTransfer : Prop :=
  ∀ r : ℕ → ℝ, RateOK r → DecidesClauseRate r →
    ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ ¬DecidedAt L (sizeR r ε n) n

end ENP
