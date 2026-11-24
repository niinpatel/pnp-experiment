# Machine-checked superlinear circuit lower bound for E^NP: plan

> **Superseded by `RESULT.md`.** This plan has two errors: the step "Nv ≥ m" is false, and the ε is wrong. The finished proof handles both through a monotonicity lemma for n·r(n) (`Arith.lean`), with ε = 1/(64·54·(q+1)(D+1)).

## Goal

Prove in Lean 4 / Mathlib, building on `anthropics/formal-math/eth` at commit `11b6c7e`, that
`L0` (the E^NP language of that development) is **not** decided by circuits of size
`s(n) = ⌊ε·(n+1)·√(log₂(n+2)) / log₂(log₂(n+4))⌋` for some fixed rational ε > 0.
Without the log log factor, use the clause rate.

Statement shape: the infinitely-often form of `CircuitLowerBoundInfinitelyOftenStatement.lean`,
with `c·(n+1)` replaced by `s(n)`, and ε existential, fixed before the language is
challenged.

## Novelty (as of 2026-11-24)

- **Anthropic:** `eth/` formalizes only `¬HasLinearCircuits L0`, i.e. size c·(n+1).
- **OpenAI:** `openai/math` family 378 formalizes only the counting algorithm
  (`lean/docs/378.md`). Its paper states E^NP ⊄ SIZE(c·n·√log n) (Cor 1.4) without Lean.
- **Wu–Wang** (arXiv:2611.02560) prove bounds for extended bases on paper.

So a Lean proof of a superlinear bound for the full binary basis would be the first
machine check of this claim. The mathematics is not new.

## Paper argument

This is the existing proof in `proof/consequences/CircuitLowerBound/`, with the rate changed.

- **Existing proof:** `StAlg c₀` gives one machine N. On input 1^m 0 y it decodes y as a circuit
  with at most c₀(m+1) gates. It builds a 3-CNF with
  `Nv ≤ 3·n_gates + a₀·(m+1) + G(e)` variables (see `Time.base_le`) and runs a #3-SAT engine
  in time `c·2^{δ·Nv}` with δ = 1/(32(3c₀+a₀+1)). The total is ≤ 2^{⌊m/8⌋} for m ≥ m₀(e).
- **Change:** use an engine with the explicit rate `T(N) ≤ C·2^{C·N·r(N)}`, where
  `r(N) = log log N/√log N` (variables, k = 3), or the clause rate `k·M/√log M`.
- **Gate bound:** n_gates ≤ s(m) ≈ ε·m/r(m).
  - For large m, r is decreasing and Nv ≥ m.
  - Hence `Nv·r(Nv) ≤ Nv·r(m) ≤ 3ε(m+1)(1+o(1)) + (a₀+G)(m+1)·r(m)`.
  - Choose ε = 1/(1000·C), so that C·Nv·r(Nv) ≤ m/32 + o(m).
  - The conclusion `≤ 2^{⌊m/8⌋}` holds from some m₀(e) on.
- **Quantifier order:** ε depends only on the engine constant C, so N is fixed before the
  table e, as `StAlg` requires.

## Risks and open checks

1. **Stepped-level engine.** Is there a Stepped-level engine with the explicit rate, rather
   than only a final Turing machine? See `UniformInKStatement`, `CountKSatRate/`, `rates/`.
2. **Engine preconditions.** Does the host's formula meet the engine's preconditions: every
   variable occurs, no duplicate clauses, n ≥ 4?
3. **Vacuity.** For small n, s(n) = 0. The infinitely-often form avoids vacuity because
   s(n) → ∞.
