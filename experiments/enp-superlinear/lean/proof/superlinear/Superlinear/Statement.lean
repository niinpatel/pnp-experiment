module

public import CircuitLowerBoundInfinitelyOftenStatement
public import Mathlib.Analysis.SpecialFunctions.Log.Base
public import Mathlib.Analysis.SpecialFunctions.Sqrt

/-! # The statement: a language in E^NP without circuits of size ε·n·√(log n)/log log n, infinitely often

Definitions only (no theorem, no proof). It imports `CircuitLowerBoundInfinitelyOftenStatement.lean`
and, through it, `CircuitLowerBoundStatement.lean`, and two Mathlib files (logarithms to a base,
square roots). From the two statement files it uses,
unchanged:
* `ENP.Lang` (a language: a predicate on bit strings),
* `ENP.Circuit` and `ENP.eval` (circuits over all binary gates, the value is the last wire),
* `ENP.InENP` (decided in time 2^{O(n)} by an oracle machine with an oracle for SAT),
* `ENP.DecidedAt L s n`: some circuit with at most s gates decides L on the words of length n. This
  is the restriction of `ENP.HasCircuits L s` to the one length n: `HasCircuits L s` is
  `∀ n, DecidedAt L (s n) n`.

## The size bound

`sizeS ε n = ⌊ε · (n+1) · √(log₂(n+2)) / log₂(log₂(n+4))⌋`. For n ≥ 0 we have log₂(n+4) ≥ 2, so the
denominator is at least 1 and the bound is well defined. It grows faster than every linear function
c·(n+1) (`Superlinear.sizeS_superlinear` in `Superlinear/Sanity.lean`).

## The statement

`CorCircuitsSuperlinInf`: there are a language L in E^NP and a real ε > 0 such that for every N there
is a length n ≥ N at which no circuit with at most `sizeS ε n` gates decides L on the words of length
n. In particular `¬HasCircuits L (sizeS ε)`; the infinitely-often form is stronger, and for a fixed
ε it does not follow from that form for free (finitely many lengths cannot be paid for by a larger
constant). -/

@[expose] public section

namespace ENP

/-- The size bound ⌊ε·(n+1)·√(log₂(n+2)) / log₂(log₂(n+4))⌋. -/
noncomputable def sizeS (ε : ℝ) (n : ℕ) : ℕ :=
  ⌊ε * ((n : ℝ) + 1) * Real.sqrt (Real.logb 2 ((n : ℝ) + 2)) / Real.logb 2 (Real.logb 2 ((n : ℝ) + 4))⌋₊

/-- Some language in E^NP is, for some ε > 0, not decided by circuits with at most `sizeS ε n` gates
at infinitely many lengths n. -/
def CorCircuitsSuperlinInf : Prop :=
  ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ ¬DecidedAt L (sizeS ε n) n

end ENP
