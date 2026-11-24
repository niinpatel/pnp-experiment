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

## In progress

- Independent rebuild of the Lean proofs for `eth/` and `vp-vnp/`, with logs in
  `experiments/lean-rebuild/`.
- Reading the frontier from primary sources: the OpenAI ETH paper and the Nov 2026 follow-ups.
  The goal is to pick one bounded, machine-checkable original contribution.

## Spend log (rough, self-estimated)

- 2026-11-24 session 1: survey phase. Gemini (Vertex) calls: 2 small ones.
