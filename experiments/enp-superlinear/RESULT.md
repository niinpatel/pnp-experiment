# Result: a machine-checked superlinear circuit lower bound for E^NP

## Theorem (Lean 4, Mathlib, standard axioms only)

`Superlinear.corCircuitsSuperlinInf : ENP.CorCircuitsSuperlinInf`

**In words:** some language L is in E^NP, i.e. decidable in time 2^{O(n)} with a SAT oracle. For some real ε > 0 and for infinitely many n, no Boolean circuit decides L on length-n inputs if it has at most

    sizeS ε n = ⌊ ε·(n+1)·√(log₂(n+2)) / log₂(log₂(n+4)) ⌋

gates. The circuits may use any 2-input gate.

**Not vacuous:** `Superlinear.sizeS_superlinear` proves that for every ε > 0 and every K, eventually K·(n+1) ≤ sizeS ε n. So the bound beats every linear bound, and it implies the previously formalized linear result.

## Status of the claim

- **The mathematics is not new.** It is the standard Williams-style "algorithms to lower bounds" consequence of the explicit #3-SAT rate 2^{O(n log log n/√log n)}. OpenAI's ETH paper (Oct 2026, Cor 1.4) states the n√log n version on paper.
- **What is new is the machine check.** As of 2026-11-24, to my knowledge, no Lean formalization of any superlinear bound for E^NP existed. Anthropic's development proves only the linear one, and OpenAI's Lean covers only the algorithm (`openai/math` lean/docs/378.md).
- **What it rests on:** Anthropic's `formal-math/eth` development (commit 11b6c7e), which itself has not been checked by a human mathematician.

## What is in this directory

- `lean/proof/superlinear/Superlinear/`: 780 new lines.
  - `Statement.lean`: definitions only. It imports Mathlib and the development's two Mathlib-only statement files.
  - `Engine.lean`: extracts the explicit-rate engine.
  - `Arith.lean`: monotonicity of n·r(n) and the time bound.
  - `Host.lean`: the nondeterministic host algorithm as a padded machine.
  - `Main.lean`: the diagonal chain argument in its infinitely-often form.
  - `Sanity.lean`: the non-vacuity lemma.
- `lean/lakefile.toml`: the original lakefile plus one `[[lean_lib]] superlinear` stanza. No original file is modified.
- `verify.sh` and `verify-output.log`: a clean-room check. The script takes a fresh copy of formal-math, overlays only these files, builds, checks that the final theorem has exactly the statement's type, and prints its axioms.
  - Result: `[propext, Classical.choice, Quot.sound]`.
  - The new files contain no `sorry`, `axiom`, `native_decide` or `implemented_by`.

## Caveats for a reviewer

- **The statement relies on another file's definitions.** `Statement.lean` uses `InENP`, `DecidedAt`, `Circuit` and `eval` from the original development's statement files. I read them myself, and they match the textbook notions: a deterministic oracle machine with time 2^{c(n+1)} and a SAT oracle, and circuits over the full binary basis.
- **ε is existential, not explicit.** It depends on the constants of the padding machine and the engine.
- **Infinitely often only.** The bound holds at infinitely many lengths, which is the standard form for this kind of result.
- **No second-kernel check.** The original development uses Comparator/nanoda; I did not set that up here. `#print axioms` runs inside Lean with the library loaded.

## Who did the work

The Lean proof was written by a Claude subagent in this session. It was independently rebuilt and checked by the orchestrating session, as described above.
