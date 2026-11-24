# STATUS: P vs NP attempt (final report, updated 2026-11-24 after the faster-3-SAT attempt)

## Where the work is

- **Branch and location:** branch `worktree-pnp-work`, in the worktree at
  `/home/nitinpatel278/pnp-experiment/.claude/worktrees/pnp-work`. It is **not merged into
  `main`**, which still holds only INSTRUCTIONS.md.
- **To view it:** `cd /home/nitinpatel278/pnp-experiment && git log worktree-pnp-work`.
- **To get it onto main yourself:** `git merge worktree-pnp-work`.
- **Second copy:** a git bundle at `gs://pnp-experiment/pnp-work.bundle`.
  - Restore with `git clone pnp-work.bundle pnp-work` after downloading it.
  - The pinned upstream Lean source is at `gs://pnp-experiment/formal-math-11b6c7e.tar.gz`.

## Answer

**P vs NP is not resolved.** I have no proof of P = NP or of P ≠ NP and claim none. As of
2026-11-24 nobody else has an accepted resolution either. The best AI-lab results of late
2026 (VP ≠ VNP; ETH refuted) explicitly do not settle it; `lit/IMPLICATIONS.md` explains why.
Any document here that reads like a resolution claim should be treated as a bug.

## What was done

1. **Literature survey** of the state as of Nov 2026, in `lit/SURVEY.md`. Each claim is labelled with its verification level.
   - The main finding: AI-produced results, formalized in Lean and not yet checked by humans, now include:
     - VP ≠ VNP over every field (Claude/Anthropic and OpenAI, 2026-11-23);
     - ETH refuted, with #3-SAT in 2^{O(m/√log m)} (Claude/Anthropic and OpenAI, Oct 2026);
     - L = BPL, NL = UL, and others.
   - No credible P vs NP resolution exists. I found one Lean "P ≠ NP" package that relies on two extra axioms, and it is flagged in the survey.
2. **Independent rebuild** of Anthropic's Lean proofs of ETH-false and VP≠VNP. Both build, and
   both use only the standard axioms (`experiments/lean-rebuild/README.md`). The comparator was not run.
3. **Implications analysis** in `lit/IMPLICATIONS.md`: what the 2026 results do and do not imply
   for P vs NP.
4. **New, machine-checked in this session:** a superlinear circuit lower bound for E^NP
   (`experiments/enp-superlinear/RESULT.md`).
   - **`Superlinear.corCircuitsSqrtLogInf`:** some language in E^NP has no circuits of size
     ε·n·√(log n) over all fan-in-2 gates, at infinitely many input lengths.
   - **`Superlinear.generalTransfer`:** any 3-SAT Turing machine with clause rate 2^{O(m·r(m))}
     gives E^NP ⊄ SIZE(ε·n/r(n)) infinitely often. It is shown non-vacuous, because the √log
     theorem is derived from it.
   - **`Superlinear.corCircuitsSuperlinInf`:** the first, weaker milestone, with an extra log log n factor.
   - **Size:** 1918 lines of Lean on top of Anthropic's `eth` development, commit 11b6c7e.
   - **Verification:**
     - a from-scratch rebuild with upstream pinned;
     - exact type match with the Mathlib-only statement files;
     - only the axioms propext, Classical.choice and Quot.sound;
     - `leanchecker` replay of all 15 new modules;
     - no sorry, axiom, native_decide, set_option, unsafe or extern in the new files.
     - To re-run: `experiments/enp-superlinear/verify.sh /mnt/data/verify-again`. It needs about 15 GB, and the root disk has only 10 GB.
     - A persistent 250 GB data disk is mounted at `/mnt/data` (added 2026-11-24, in fstab with `nofail`). A built copy is at `/mnt/data/lean/anthropics-formal-math-11b6c7e/eth`; set `XDG_CACHE_HOME=/mnt/data/lean/.cache` when using it.
   - **Novelty:** the mathematics is OpenAI's paper-only Corollary 1.4, so it is not new. To my knowledge this is the **first machine-checked superlinear circuit lower bound for E^NP**.
     Its distance to P vs NP is large; see `lit/IMPLICATIONS.md` §3.
5. **Where the √log comes from** (`lit/SQRTLOG_BARRIER.md`, sourced).
   - **Formula** (our derivation): the rate exponent is log(1/ρ)/log β. In Anthropic's analysis β = 2 and ρ = 1/√2, which traces back to the Hardy–Ramanujan partition count.
   - **No proven barrier** exists at √log.
   - **Computational check, negative:** I computed exact ranks of the paper's Appendix B pieces for h ≤ 9. They give no gain in ρ (`experiments/sqrtlog/`).

## Not attempted (open; judged not achievable or not checkable within this budget)

- A Boolean transfer of the VP≠VNP proof. Paper §2.5 shows where it breaks, and nothing there could be machine-checked.
- Any direct proof attempt at P ≠ NP or P = NP. Every known route faces the relativization, natural-proofs and algebrization barriers. I would not have been able to verify a "proof", and producing an unverifiable one would violate "make no mistakes".
- **Attempted, capped, and ended negative (2026-11-24):** improving the 2^{m/√log m} rate.
  - **Stage 1** (`lit/RHO_SPEC.md`):
    - the Lean rate theorem is parametric in the pieces (`GeneralPieces.thmRunningTime_c_m`), so a new pieces family would plug in;
    - Majdoddin's limits, re-checked line by line, hold under their hypotheses;
    - three classes of construction escape every proven bound, but none has a known candidate.
  - **Stage 2** (`lit/STAGE2_GRADED.md`): the natural generalizations are worse than Appendix B.
    - Plane partitions and d-dimensional analogues give ρ ≈ 0.79–0.87.
    - Coloured partitions are best at one colour.
    - The trade-off obstructions are partially proved. An adversarial referee (`lit/STAGE2_REFEREE.md`) found both proofs correct **with gaps**, and they do not close Majdoddin's Open problem 1.
  - **Outcome:** no improvement, and no claim of one. The open directions are general Def.-7 pieces whose true rank is far below their bit count, and levels with three or more merges.

## Caveats

- **Unchecked foundations:** every Lean result here rests on Anthropic's development, which no human mathematician has checked. The meaning of the statement files was checked by reading them, not by machine.
- **Builds:** they now live on the persistent disk at `/mnt/data`. The earlier RAM disk at `/mnt/lean` has been released.

## Spend

- **Console checkpoint:** $438 remained on 2026-11-24, about $51 spent.
- **After the faster-3-SAT attempt:** about **$100 spent in total**, leaving about $390. This is a calibrated estimate: `tools/spend.py` token counts at Opus 5.5 prices, times 0.7, plus advisor calls.
- **Google Cloud:** 2 small Gemini calls, about 10 MB of GCS storage, and a 250 GB persistent disk added by the user.
