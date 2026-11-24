# STATUS: P vs NP attempt (final report, updated 2026-11-24 after the faster-3-SAT attempt)

> **Reviewed and corrected on 2026-11-24 by a second session. Read `REVIEW.md` first.**
> It re-verifies this report, lists what was wrong in it, and ranks follow-ups. Lines changed by
> the review are marked "(review)". The two largest corrections:
> - the Lean theorem below was **not the first** machine check of this bound;
> - the literature survey missed the venues where most follow-up work had been posted. A sweep of
>   those venues was done on the evening of 2026-11-24; `lit/SURVEY.md` §5 and §6 are the result.
> - **Human checking of the 2026 results:** an expert group is examining OpenAI's ETH proof and
>   disclaims certification. In the sources swept, no named expert has said they checked either
>   proof in full or reported a technical error (`lit/SURVEY.md` §6.1).

## Where the work is

- **Branch and location (review):** branch `main` in `/home/nitinpatel278/pnp-experiment`.
  - The first session worked on the branch `worktree-pnp-work`. It was merged into `main` on
    2026-11-24 at 13:09 UTC, and the review session has committed on `main` since.
  - The old worktree under `.claude/worktrees/pnp-work` is stale and can be removed.
- **Second copy:** a git bundle of all branches at `gs://pnp-experiment/pnp-work.bundle`.
  - Restore with `git clone pnp-work.bundle pnp-work` after downloading it.
  - The pinned upstream Lean source is at `gs://pnp-experiment/formal-math-11b6c7e.tar.gz`.
  - The papers that the notes cite by page are at `gs://pnp-experiment/papers-2026-11-24.tar.gz`
    and in `/mnt/data/papers/` (review).

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
   - **`Superlinear.Pieces.countTransferThm` and `Superlinear.Pieces.piecesTransfer` (review):**
     the same transfer from a *counting* machine, and directly from a family of pieces with
     parameter ρ, giving E^NP ⊄ SIZE(ε·n·(log n)^{log₂(1/ρ)}). Conditional: no pieces better than
     the known ones exist, so today it only returns the √log theorem.
   - **Size:** 2464 lines of Lean in 20 modules on top of Anthropic's `eth` development, commit
     11b6c7e: 1918 from the first session and 546 from the review session (541 of them in five
     new modules).
   - **Verification:**
     - a from-scratch rebuild with upstream pinned;
     - exact type match with the Mathlib-only statement files;
     - only the axioms propext, Classical.choice and Quot.sound;
     - `leanchecker` replay of all 20 new modules;
     - the upstream acceptance check, comparator with the independent `nanoda` kernel, accepts
       all five theorems (review; `experiments/enp-superlinear/comparator/README.md`);
     - no sorry, axiom, native_decide, set_option, unsafe or extern in the new files.
     - To re-run: `experiments/enp-superlinear/verify.sh /mnt/data/verify-again`. It needs about 15 GB, and the root disk has only 10 GB.
     - A persistent 250 GB data disk is mounted at `/mnt/data` (added 2026-11-24, in fstab with `nofail`). A built copy is at `/mnt/data/lean/anthropics-formal-math-11b6c7e/eth`; set `XDG_CACHE_HOME=/mnt/data/lean/.cache` when using it.
   - **Novelty (review):** the mathematics is OpenAI's paper-only Corollary 1.4, so it is not new.
     - The machine check is **not the first** either. V. Tulsyan's public repository
       `xennygrimmato/eth-hamiltonicity` has had a Lean proof of the same statement since
       2026-11-04 (`lit/SURVEY.md` §6). The review session built it against the same upstream
       tree: it compiles and is interchangeable with ours. The claim of priority that stood here
       was wrong.
     - What I could not find elsewhere are the transfer theorems.
     - Its distance to P vs NP is large; see `lit/IMPLICATIONS.md` §3.
5. **Where the √log comes from** (`lit/SQRTLOG_BARRIER.md`, sourced).
   - **Formula** (our derivation): the rate exponent is log(1/ρ)/log β. In Anthropic's analysis β = 2 and ρ = 1/√2, which traces back to the Hardy–Ramanujan partition count.
   - **No proven barrier** exists at √log.
   - **Computational check, negative:** I computed exact ranks of the paper's Appendix B pieces for h ≤ 9. They give no gain in ρ (`experiments/sqrtlog/`).
   - **Related prior work (review):** a note of 2026-10-31 (Naves de Brito, hexagon:2610.00692) analyses the same construction but explicitly leaves this rank question out of scope, so the check is not redundant.

## Not attempted (open; judged not achievable or not checkable within this budget)

- A Boolean transfer of the VP≠VNP proof. Paper §2.5 shows where it breaks, and nothing there could be machine-checked.
- Any direct proof attempt at P ≠ NP or P = NP. Every known route faces the relativization, natural-proofs and algebrization barriers. I would not have been able to verify a "proof", and producing an unverifiable one would violate "make no mistakes".
- **Attempted, capped, and ended negative (2026-11-24):** improving the 2^{m/√log m} rate.
  - **Stage 1** (`lit/RHO_SPEC.md`):
    - the Lean rate theorem is parametric in the pieces (`GeneralPieces.thmRunningTime_c_m`). The step from there to an E^NP bound was missing at the time; the review session proved it (`piecesTransfer`);
    - three of Majdoddin's limits (Prop 4.6/4.8, Thm 4.13, Prop 4.24) were re-derived and hold under their hypotheses; his other results were not re-checked (review);
    - three classes of construction escape every proven bound, but none has a known candidate.
  - **Stage 2** (`lit/STAGE2_GRADED.md`): the natural generalizations are worse than Appendix B.
    - Partly anticipated (review): that note already has the power-profile floor, the same two escapes, and an argument that vertex-algebra constructions cannot use narrower windows. It does not have the product-character lemma.
    - Plane partitions and d-dimensional analogues give ρ ≈ 0.79–0.87.
    - Coloured partitions are best at one colour.
    - The trade-off obstructions are partially proved. An adversarial referee (`lit/STAGE2_REFEREE.md`) found both proofs correct **with gaps**, and they do not close Majdoddin's Open problem 1.
  - **Outcome:** no improvement, and no claim of one. The open directions are general Def.-7 pieces whose true rank is far below their bit count, and levels with three or more merges.
  - **A concrete open sub-problem exists (review):** pieces built from Pauli strings at local dimension 8 or more. Others worked on it from 2026-10-30 to about 2026-11-03 and report no construction. See `REVIEW.md` §6.4.

## Caveats

- **Unchecked foundations:** every Lean result here rests on Anthropic's development. Its paper says "no person is known to have checked it" (review). The meaning of the statement files was checked by reading them, not by machine.
- **Builds:** they now live on the persistent disk at `/mnt/data`. The earlier RAM disk at `/mnt/lean` has been released.

## Spend

- **Console checkpoint:** $438 remained on 2026-11-24 at 10:33 UTC, about $51 spent.
- **First session, corrected (review):** **$84.58**, not "about $100". The old `tools/spend.py`
  double-counted and left out advisor calls; the rewritten one gives $50.76 at the console
  checkpoint. Details in `REVIEW.md` §4.
- **Review session:** about $112 for the review (`REVIEW.md` §7.4) and about $68 for the
  literature sweep (`REVIEW.md` §7.6). Project total about $264 of $489, leaving about $225. Run
  `python3 tools/spend.py` for the current figure.
- **Google Cloud:** 2 small Gemini calls, about 10 MB of GCS storage, and a 250 GB persistent disk added by the user.
