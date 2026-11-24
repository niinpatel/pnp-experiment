I could not write `/mnt/data/review/sweep/github/REPORT.md`: the harness blocks this agent from writing report files, and I did not work around it. The findings are below instead, so this runs well past your 400-word limit. The raw material is on disk under `/mnt/data/review/sweep/github/`: the API dumps and grep logs are in `api/` (start with `grep_counts.txt` and `eh_notes.txt`), the scripts in `scripts/`, and 27 clones in `clones/`. Nothing was executed from a clone.

## The decisive question: does anyone have a rate- or pieces-parametric transfer theorem in Lean?

**Not found.** I grepped the `.lean` files of all 27 clones for the 14 patterns in `scripts/patterns.txt` (including ℕ → ℝ, rPow, CountInRate, Exist ρ, AppRunningTime, IsPieces, RateOK, transfer, DecidedAt, HasCircuits, InENP, CircuitLowerBound). Then, in the 19 clones with Lean files, I kept only files whose blob hash does not occur anywhere in upstream `eth/` at 11b6c7e, and asked which of those mention ENP, DecidedAt, HasCircuits or InENP. The answer is exactly the five files of Tulsyan's `Circuits/` directory (FULL).

- **Tulsyan's files are still fixed at one rate** (FULL, first and last commit both 9e5dfc8, 2026-11-04):
  - `Circuits/LowerBound.lean:32`, `no_circuits_io (…) {sz : ℕ → ℕ} (hAlg : StAlgS sz) : ∀ N₀, ∃ n, N₀ ≤ n ∧ ¬DecidedAt L0 (sz n) n`. It is generic in the circuit size, but its hypothesis `StAlgS` (line 26) is a circuit-analysis algorithm for upstream's L0, not a SAT machine with a rate.
  - The engine is pinned at `Engine.lean:39`, `exists_topM … TopM S pick (SatM.rPow (1 / 2))`.
  - The repository's own note says so, `research/circuit-lower-bounds.md:18`: "the module is **not** parametric in the SAT time."
- **Other Lean E^NP circuit theorems:**
  - Tulsyan: `enp_not_size_n_sqrt_log` (Main.lean:101, unshifted) and `enp_not_hasCircuits_n_sqrt_log` (:121). No almost-everywhere version, no other gate basis, no log log variant in Lean.
  - Upstream itself proves only linear size: `CorCircuits`, `CorCircuitsInf` and `ENP.infinitely_often`. Its `StAlg` hard-wires `C.length ≤ c₀ * (m + 1)`.
- **Rate-parametric transfers exist on paper only:**
  - MJIFmc/eth-2026-notes (Hongming Chen, 2026-11-08), "Fixed-point law" (`fixedpoint-note.tex:154`): 3-SAT in A·2^{V/a(V)} gives E^NP lower bounds through f⁻¹. Its Lean (`LA1_fixedpoint.lean`) is real arithmetic over `a : ℝ → ℝ`, with no machines, E^NP or circuits.
  - jhune-yim/ETH (one commit, 2026-11-25 JST), "Transfer of logarithmic SAT savings" (`ETH.tex:796`), for a family g_β. No Lean.
  - Tulsyan's circuit note remarks that a rate 2^{M/g(M)} gives size εn·g(n), informally.

## anthropics/formal-math issues (FULL, 54 items, 64 comments)

- **No issue claims an error in the eth/ or vp-vnp/ proofs.** No maintainer has replied anywhere: the only comment not marked NONE is dependabot's.
- **#36 (TSavo, a bridge to OpenAI's claim):** carlostoledo1891 independently re-checked the bridge. He also posted a bridge to complexitylib's multitape ETH, a port of eth/ to Lean v4.36.0-rc2 (claimbox `PORT.md`), and an OpenAI-side chain using Daniel Hawkley's bridges in thinkthoughts/math. My hash comparison of that port: 763 files identical, 48 changed, 1 added (PORT.md), and no new theorems.
- **#45:** Siemaszko's question was independently re-derived by LazarusGroves (a gist, 2026-11-23), who reports "We found no error."
- **#50 (3453-315h):** an audit reporting a clean axiom closure.
- **#51:** comments are only "lgtm" plus an "@codex verify." request.
- **#54:** README-only change, no comments.
- **#32–#47, #52 (frintroper):** threads without a mathematical argument; #52 claims vp-vnp "CANNOT work" because Mathlib uses ZFC. No technical content.

## openai/math (FULL)

- Only 5 PRs and no issues; nothing about 378. PR #5 adds 379.
- `history.md`: no withdrawal or erratum since 2026-10-07. The 10-26 entry says a working group led by Impagliazzo, Paturi and Williams will examine the ETH proof.

## Works not in SURVEY.md (grep of SURVEY confirmed each one absent)

- **Repositories:** TSavo/eth-bridge; carlostoledo1891/cert-machine and /claimbox; complexitylib; thinkthoughts/math; LazarusGroves gist; Stratum-Research-Group/LeanProofs; MJIFmc/eth-2026-notes; jhune-yim/ETH; ssenge/eth-corollaries, now ssenge/ResearchResults (its notes list E^NP ⊄ SIZE(c·n√log n), no Lean for it).
- **Hexagon:** 2610.00577 (Anthropic's paper), 00572 (O'Donnell), 00574 (Kominers), 00594 (Bhattacharjee), 00600 (Rudich–Rousseau), 00613 (Li), 00711 (Shunia), 2611.00004 (Nguyen), 00086 (Vega), and Tulsyan's own 2610.00672, 2611.00088, 00090, 00115, 00116.
- **arXiv:** 2611.02548 (Wu–Wang, feedback vertex sets), 2611.02650 (MIT Hardness Group, "ETH is dead, long live SH"), 2611.03636 (Curticapean), 2611.04175 (Li).
- **People and groups:** Szeider's crossover value, and the Impagliazzo–Paturi–Williams working group.

## Corrections to the record

- eth-hamiltonicity now has 280 commits, the latest on 2026-11-24 (VP≠VNP notebooks under `research/next/`). The `Circuits/` files are unchanged since 9e5dfc8.

## Not done

- No code search: it needs authentication.
- Not cloned: tangle-solve/*, kongeskog/formal-math, Hardonian/SAT-Frontier, ono-work, dc8jd2yk6k-jpg/math_2 (cloned but no Lean), Palomar.
- PDFs not read; most research notes listed by title only. `docs/circuit-note.pdf` was not read; I read its source, `circuit-note/main.tex`, in part.
- My negative grep relies on the names ENP, DecidedAt, HasCircuits and InENP. A theorem built on an independent E^NP formalization with different names would be missed.
- API used: 7 core calls (53 left) and 8 search calls.