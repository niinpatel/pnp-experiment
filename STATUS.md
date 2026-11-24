# STATUS: P vs NP attempt (always reads as the final report so far)

**Where the work is:** branch `worktree-pnp-work`, at
`/home/nitinpatel278/pnp-experiment/.claude/worktrees/pnp-work`. It is not merged into `main`.
To see it: `cd /home/nitinpatel278/pnp-experiment && git log worktree-pnp-work`.

## Answer so far

**P vs NP is not resolved, here or anywhere else as of 2026-11-24.** I have no proof of either
P = NP or P ≠ NP, and I make no claim to one. Any document in this repository that looks
like such a claim should be treated as a bug.

## Done

1. Literature survey of the state as of Nov 2026, with each claim labelled by verification level:
   `lit/SURVEY.md`. The main facts:
   - AI-produced, Lean-formalized results, not yet checked by humans:
     - **VP ≠ VNP** over every field (Claude/Anthropic).
     - **ETH refuted**: #3-SAT in 2^{O(m/√log m)} (Claude/Anthropic and OpenAI, Oct 2026).
   - Consequence: E^NP lacks linear-size circuits; per OpenAI, it lacks circuits of size c·n√log n.
   - None of these touches Boolean P vs NP. The VP≠VNP paper explains exactly where its proof
     breaks for Boolean circuits.

2. Independent rebuild of Anthropic's Lean proofs of ETH-false and VP≠VNP. **Both build, and they use
   only the standard axioms** (`experiments/lean-rebuild/README.md`). The comparator was not run.
3. `lit/IMPLICATIONS.md`: why none of the 2026 results settles P vs NP.

4. **New result, machine-checked in this session:** E^NP has no circuits of size
   **ε·n·√(log n)**, infinitely often, over all fan-in-2 gates
   (`Superlinear.corCircuitsSqrtLogInf`). A first milestone proved the weaker
   ε·n·√(log n)/log log n.
   - **Lean development:** 1918 lines, on top of Anthropic's `eth` development (commit 11b6c7e).
   - **Theorem names:** `Superlinear.corCircuitsSqrtLogInf` (main), `Superlinear.corCircuitsSuperlinInf`
     (the first milestone, with the log log factor), and `Superlinear.generalTransfer`.
   - **Also proved:** a reusable **general transfer theorem** (`Superlinear.generalTransfer`): any
     3-SAT Turing machine running in 2^{O(m·r(m))} gives E^NP ⊄ SIZE(ε·n/r(n)) infinitely often.
   - **Checked:** a from-scratch rebuild against upstream pinned at 11b6c7e passes, using only the
     standard axioms. `leanchecker` replays all 15 new modules, and non-vacuity lemmas are proved.
   - **Novelty:** the mathematics is known on paper (it matches OpenAI's Cor 1.4, c·n·√log n). To my knowledge this is the **first machine-checked superlinear circuit
     lower bound for E^NP**.
   - **Details:** `experiments/enp-superlinear/RESULT.md`.

## In progress

- Nothing is running. The log log factor was removed within the cap.

5. `lit/SQRTLOG_BARRIER.md` traces where the 1/2 in 2^{m/√log m} comes from.
   - **Formula** (our derivation from the paper): the rate exponent is α' = log(1/ρ)/log β. Anthropic has β = 2 and ρ = 1/√2, and the 1/√2 traces back to the Hardy–Ramanujan partition count.
   - **No proven barrier** exists at 1/2. Majdoddin shows that grid algorithms are capped at α' ≤ 1.
   - **The only lever** is cheaper "pieces", with ρ < 1/√2. Through `generalTransfer`, that would give E^NP ⊄ SIZE(n·(log n)^{log₂(1/ρ)}). This is a conjecture; nothing was proved.
   - **Computational check, negative.** Exact ranks of the paper's Appendix B pieces for h ≤ 9 fall
     only slightly below the paper's counted bounds, and the gap shrinks with h. A fitted law,
     which is not proved, gives no improvement to ρ. Scripts are in `experiments/sqrtlog/`.

## Explicitly not attempted (open, beyond this budget)

- Improving the #SAT rate past 2^{m/√log m}, which would give stronger E^NP bounds.
- Transferring the VP≠VNP proof to Boolean circuits. Paper §2.5 explains why it breaks;
  `lit/IMPLICATIONS.md` §1 discusses it.

## Spend log (rough, self-estimated from session token counts at guessed prices; advisor calls not counted)

- About $117 by the end of the first Lean result (2026-11-24, ~09:00 UTC). Gemini: 2 small calls.
- After the general theorem (2026-11-24, ~10:00 UTC), at published Opus 5.5 prices ($4/$20 per Mtok, cache reads $0.20, cache writes about $5): about $47 of this session's tokens, including subagents (`tools/spend.py` token counts). Advisor calls (Fable 5.2) are not in the logs, so estimate about $10–15 more. **Total about $60 of the $489 budget.**
