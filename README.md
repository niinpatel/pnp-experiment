# pnp-experiment

An experiment run 2026-11-24 to 2026-11-28: a Claude Code agent on a cloud VM was told
"solve P vs NP" and given a fixed budget ($489 of Anthropic API credits, a small Google Cloud
budget, about four days). This repository is everything it produced, including an independent
review of its own work by a second session.

**P vs NP is not resolved here.** Nothing in this repository claims a proof of P = NP or P ≠ NP.
Any sentence that reads like such a claim is a bug.

## Where to start

1. [`REVIEW.md`](REVIEW.md) is an independent check of the first session's work by a second
   session (Claude Fable 5.2). It says what holds up, what was wrong, and what it cost.
2. [`STATUS.md`](STATUS.md) is the first session's final report (Claude Opus 5.5), corrected in
   place by the review.
3. [`INSTRUCTIONS.md`](INSTRUCTIONS.md) is the original task prompt.

## What came out of it

- **A literature survey** of P vs NP and the AI-produced complexity results of late 2026
  ([`lit/SURVEY.md`](lit/SURVEY.md)). Every claim in it is labelled with how it was verified.
  The raw reports from the literature sweep are in [`lit/sweep/`](lit/sweep/).
- **What those results do and do not imply for P vs NP**
  ([`lit/IMPLICATIONS.md`](lit/IMPLICATIONS.md)).
- **Rebuilds** of Anthropic's Lean proofs refuting ETH and proving VP ≠ VNP. Both build and use
  only the standard axioms ([`experiments/lean-rebuild/`](experiments/lean-rebuild/)).
- **A machine-checked circuit lower bound:** some language in E^NP has no circuits of size
  ε·n·√(log n) at infinitely many input lengths
  ([`experiments/enp-superlinear/`](experiments/enp-superlinear/)). This is 2464 lines of Lean in
  20 modules on top of `anthropics/formal-math@11b6c7e`. It was checked by a from-scratch rebuild,
  an axiom audit, `leanchecker` replay, and the upstream comparator with the independent `nanoda`
  kernel.
  - *Novelty:* the mathematics is a corollary in OpenAI's ETH paper, so it is not new. The Lean
    proof is not the first either: V. Tulsyan's `xennygrimmato/eth-hamiltonicity` proved the same
    statement three weeks earlier
    ([`experiments/enp-superlinear/prior-check/`](experiments/enp-superlinear/prior-check/)). The
    review could not find the transfer theorems (`Superlinear.generalTransfer`,
    `Superlinear.Pieces.piecesTransfer`, `countTransferThm`) anywhere else.
- **An attempt to beat the 2^{m/√log m} 3-SAT rate. It ended negative.** The notes are in
  [`lit/RHO_SPEC.md`](lit/RHO_SPEC.md), [`lit/STAGE2_GRADED.md`](lit/STAGE2_GRADED.md),
  [`lit/STAGE2_REFEREE.md`](lit/STAGE2_REFEREE.md) and
  [`lit/SQRTLOG_BARRIER.md`](lit/SQRTLOG_BARRIER.md). The code and outputs are under
  [`experiments/rho/`](experiments/rho/) and [`experiments/sqrtlog/`](experiments/sqrtlog/).

## Layout

| Path | Contents |
|---|---|
| `lit/` | Survey, implications, research notes, literature sweep reports |
| `experiments/enp-superlinear/` | Lean library `Superlinear`, statement files, `verify.sh`, comparator check, prior-proof check |
| `experiments/lean-rebuild/` | Logs from rebuilding Anthropic's `eth` and `vp-vnp` proofs |
| `experiments/rho/`, `experiments/sqrtlog/` | Computational probes (Python and C) with their outputs |
| `tools/` | Search helpers (Gemini, GitHub), GCS upload and backup, Lean build setup, `spend.py` cost tracker |
| `review-raw-2026-11-24.tar.gz` | Raw scratch of the review session: probe runs, auditor drafts, search outputs. Third-party material has been removed |

## Re-checking the Lean result

```sh
experiments/enp-superlinear/verify.sh /path/to/empty/dir
```

This downloads the pinned upstream, overlays the new modules, builds, and checks statements and
axioms. It needs about 15 GB of disk and a Lean toolchain (elan). The comparator check is
described in
[`experiments/enp-superlinear/comparator/README.md`](experiments/enp-superlinear/comparator/README.md).

## Caveats

- Every Lean result rests on Anthropic's `eth` development, which its authors say no person is
  known to have checked in full.
- The research notes outside the Lean files are AI-written and not peer-reviewed. Each is
  labelled with its verification level; read the labels.
- Paths like `/mnt/data/...` and `gs://pnp-experiment/...` refer to the original VM and bucket,
  which are not public.
