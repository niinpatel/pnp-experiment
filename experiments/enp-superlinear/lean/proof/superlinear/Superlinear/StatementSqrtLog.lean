module

public import CircuitLowerBoundInfinitelyOftenStatement
public import Mathlib.Analysis.SpecialFunctions.Log.Base
public import Mathlib.Analysis.SpecialFunctions.Sqrt

/-! # The statement: a language in E^NP without circuits of size ε·n·√(log n), infinitely often

Definitions only (no theorem, no proof). Same imports and same conventions as
`Superlinear/Statement.lean` (which is left as it is): `ENP.Lang`, `ENP.InENP`, and
`ENP.DecidedAt L s n` («some circuit with at most s gates decides L on the words of length n», the
restriction of `ENP.HasCircuits` to one length) come unchanged from
`CircuitLowerBoundStatement.lean` and `CircuitLowerBoundInfinitelyOftenStatement.lean`.

`sizeT ε n = ⌊ε · (n+1) · √(log₂(n+2))⌋` (log₂(n+2) ≥ 1 for all n). It grows faster than every
linear function (`Superlinear.sizeT_superlinear`), and faster than `ENP.sizeS ε` by the factor
log₂ log₂(n+4).

`CorCircuitsSqrtLogInf`: there are a language L in E^NP and a real ε > 0 such that for every N there
is a length n ≥ N at which no circuit with at most `sizeT ε n` gates decides L on the words of
length n. -/

@[expose] public section

namespace ENP

/-- The size bound ⌊ε·(n+1)·√(log₂(n+2))⌋. -/
noncomputable def sizeT (ε : ℝ) (n : ℕ) : ℕ :=
  ⌊ε * ((n : ℝ) + 1) * Real.sqrt (Real.logb 2 ((n : ℝ) + 2))⌋₊

/-- Some language in E^NP is, for some ε > 0, not decided by circuits with at most `sizeT ε n` gates
at infinitely many lengths n. -/
def CorCircuitsSqrtLogInf : Prop :=
  ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ ¬DecidedAt L (sizeT ε n) n

end ENP
