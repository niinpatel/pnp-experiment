module

public import Superlinear.StatementGeneral
public import AppRunningTimeStatement

/-! # The statements: a counting rate, or a family of pieces, gives a circuit lower bound for E^NP

Definitions only (no theorem, no proof). It imports `Superlinear/StatementGeneral.lean` (the size
bound `ENP.sizeR r ε n = ⌊ε·(n+1)/r(n)⌋`, the regularity `ENP.RateOK r`, and through it `ENP.Lang`,
`ENP.InENP`, `ENP.DecidedAt`, `SatM.CountInRate`, `SatM.rPow`) and the statement file
`AppRunningTimeStatement.lean` of the development, which states Definition 7 of the paper («pieces»)
as `AppRunningTime.IsPieces ρ c P A val` and `AppRunningTime.Exist ρ c := ∃ P A val, IsPieces ρ c P A val`,
with `AppRunningTime.alpha' ρ = log₂(1/ρ)`. Unlike the other statement files used here, that file
does NOT import Mathlib alone: its programs `PiecesF` come from the development's
`ClauseBound.Gen.Defs`. Whoever relies on `PiecesTransfer` must read `IsPieces` there.

## `CountTransfer`

`ENP.GeneralTransfer` (StatementGeneral.lean) with a machine that COUNTS in place of one that
decides: for every rate r with `RateOK r`, if one Mathlib Turing machine counts the satisfying
assignments of every k-CNF with m ≥ 1 clauses in which every variable occurs within
⌊C·2^{C·k·m·r(m)}⌋ steps (`SatM.CountInRate r`, the form in which the development states its rates),
then some language in E^NP is, for some ε > 0, not decided by circuits with at most ⌊ε·(n+1)/r(n)⌋
gates at infinitely many lengths n.

## `PiecesTransfer`

For all ρ and c: if pieces in the sense of Definition 7 exist with parameters (ρ, c), then some
language in E^NP is, for some ε > 0, not decided by circuits with at most
⌊ε·(n+1)·(log₂(n+2))^{α'}⌋ gates at infinitely many lengths n, where α' = log₂(1/ρ)
(`sizeR (rPow α') ε n` is this floor: `Superlinear.Pieces.sizeR_rPow_gen`).

What it does not say. `IsPieces` forces ½ ≤ ρ < 1, so 0 < α' ≤ 1 and the bound is never above
ε·n·log n. The only pieces known (Appendix B of the paper, ρ = 1/√2) give α' = ½, which is
`ENP.CorCircuitsSqrtLogInf`. The statement is conditional: it is of use only if pieces with
ρ < 1/√2 are found, and none is known. -/

@[expose] public section

namespace ENP

/-- Every rate with `RateOK` at which #k-SAT is counted in the number of clauses (one machine for
all k) gives a language in E^NP without circuits of size ⌊ε·(n+1)/r(n)⌋ at infinitely many
lengths, for some ε > 0. -/
def CountTransfer : Prop :=
  ∀ r : ℕ → ℝ, RateOK r → SatM.CountInRate r →
    ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧ ¬DecidedAt L (sizeR r ε n) n

/-- Pieces with parameters (ρ, c) give a language in E^NP without circuits of size
⌊ε·(n+1)·(log₂(n+2))^{log₂(1/ρ)}⌋ at infinitely many lengths, for some ε > 0. -/
def PiecesTransfer : Prop :=
  ∀ (ρ : ℝ) (c : ℕ), AppRunningTime.Exist ρ c →
    ∃ L : Lang, InENP L ∧ ∃ ε : ℝ, 0 < ε ∧ ∀ N : ℕ, ∃ n : ℕ, N ≤ n ∧
      ¬DecidedAt L (sizeR (SatM.rPow (AppRunningTime.alpha' ρ)) ε n) n

end ENP
