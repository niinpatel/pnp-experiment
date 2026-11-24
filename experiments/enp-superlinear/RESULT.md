# Result: a machine-checked superlinear circuit lower bound for E^NP

## Headline (strongest form)

`Superlinear.corCircuitsSqrtLogInf : ENP.CorCircuitsSqrtLogInf`

**In words:** some language L is in E^NP. For some ε > 0 and for infinitely many n, no circuit over the full fan-in-2 basis with at most ⌊ε·(n+1)·√(log₂(n+2))⌋ gates decides L at length n.

- **Relation to the literature:** this matches OpenAI's paper-only Corollary 1.4, c·n·√log n.
- **Non-vacuity:** `sizeT_superlinear` proves it.
- **Supporting files** (statement in `StatementSqrtLog.lean`):
  - `FormC.lean` bounds the clause count: Tseitin gives 4 clauses per gate.
  - `Host2.lean` makes every variable occur by adding the clauses x ∨ ¬x.
  - `Arith2.lean` contains the asymptotics.
  - `Chain.lean` contains the diagonal chain argument for a general size function.
  - `MainSqrtLog.lean` proves the theorem.
- **Scale:** 1488 lines measured with `wc -l`: 780 for the first milestone, 694 for the √log form, and the 14-line axioms script.
- **Earlier result:** the weaker n·√log n / log log n version below was the first milestone, and the new theorem implies it (`corCircuitsSuperlinInf_of_sqrtLog`).
- **Clean-room check:** `verify.sh` checks both theorems; see `verify-output.log`.

## General transfer theorem (reusable)

`Superlinear.generalTransfer : ENP.GeneralTransfer` (statement in `StatementGeneral.lean`)

**In words:** let r be any rate that is positive, antitone, tends to 0, and has m·r(m) monotone. Suppose some Mathlib Turing machine with finite alphabets decides 3-SAT within ⌊C·2^{3C·m·r(m)}⌋ steps, measured in the number m of clauses. The condition applies to formulas with at least one clause, no repeated clause, and every variable occurring. Then some language in E^NP has, for some ε > 0, no circuits of size ⌊ε·(n+1)/r(n)⌋ at infinitely many n.

**Why it matters:** any future faster 3-SAT algorithm, supplied as a Turing machine, gives a machine-checked E^NP lower bound immediately.

**Non-vacuous:** `corCircuitsSqrtLogInf_of_general` derives the √log theorem from it. It instantiates r(m) = 1/√log₂(m+2) using the development's own deciding machine.

**Size:** 427 new lines (`StatementGeneral`, `ArithGen`, `General`). The library now has 1918 lines in total.

## First milestone (weaker, kept)

## Theorem (Lean 4, Mathlib, standard axioms only)

`Superlinear.corCircuitsSuperlinInf : ENP.CorCircuitsSuperlinInf`

**In words:** some language L is in E^NP, i.e. decidable in time 2^{O(n)} with a SAT oracle. For some real ε > 0 and for infinitely many n, no Boolean circuit decides L on length-n inputs if it has at most

    sizeS ε n = ⌊ ε·(n+1)·√(log₂(n+2)) / log₂(log₂(n+4)) ⌋

gates. The circuits may use any 2-input gate.

**Not vacuous:** `Superlinear.sizeS_superlinear` proves that for every ε > 0 and every K, eventually K·(n+1) ≤ sizeS ε n. So the bound beats every linear bound, and it implies the previously formalized linear result.

## Status of the claim

- **The mathematics is not new.** It is the standard Williams-style "algorithms to lower bounds" consequence of the explicit #3-SAT rate 2^{O(n log log n/√log n)}. OpenAI's ETH paper (Oct 2026, Cor 1.4, which I read in the PDF) states the stronger c·n·√log n version on paper. The first milestone was weaker by a log log n factor; the headline theorem above removes that factor.
- **What is new is the machine check.** As of 2026-11-24, to my knowledge, no Lean formalization of any superlinear bound for E^NP existed. Anthropic's development proves only the linear one, and OpenAI's Lean covers only the algorithm (`openai/math` lean/docs/378.md).
- **What it rests on:** Anthropic's `formal-math/eth` development (commit 11b6c7e), which itself has not been checked by a human mathematician.

## What is in this directory

- `lean/proof/superlinear/Superlinear/`: 780 lines for the first milestone (the files below) and 694 for the √log form (StatementSqrtLog, FormC, Chain, Arith2, Host2, MainSqrtLog). Together with `PrintAxiomsSuperlinear.lean` (14 lines) that makes 1488.
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
- **Kernel checking.**
  - `leanchecker` replays the declarations of all 15 new modules through the Lean kernel, and every module exits 0. It runs in non-fresh mode, with imports taken from .olean files.
  - Not set up: Comparator, and the independent nanoda kernel that the original development uses.
  - A grep of the new files finds no `set_option`, `unsafe`, `opaque`, `extern`, `macro`/`elab`, `sorry`, `axiom`, `native_decide` or `implemented_by`.
- **The clean-room build was run twice.**
  - First run: in a tmpfs that reused the build directory of an earlier check.
  - Second run: fully from scratch, in an empty directory, with upstream pinned at 11b6c7e. A copy of that tarball is at `gs://pnp-experiment/formal-math-11b6c7e.tar.gz`.
  - Both runs passed. `verify-output.log` is from the second.

## Who did the work

The Lean proof was written by a Claude subagent in this session. It was independently rebuilt and checked by the orchestrating session, as described above.
