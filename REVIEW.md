# REVIEW of the first thread (2026-11-24): what holds, what does not, retrospective, follow-ups

Written by a second session (Claude Fable 5.2) on 2026-11-24, reviewing the work of the first
session (Claude Opus 5.5, commits `d8314fd..3f0021c`). `STATUS.md` is the first thread's own
report; this file is the independent check of it.

Labels used below:
- **Re-run** means I executed it again in this session and saw the output.
- **Read** means I read the source or the statement myself.
- **Agent** means a subagent of this session did the check; I say where its evidence is.
- **Judgement** means my opinion.

## 1. Bottom line

- **P vs NP is unresolved, and the first thread never claimed otherwise.** Nothing in this review
  changes that.
- **Its one theorem is correct.** I rebuilt it from scratch, and it now also passes the upstream
  acceptance check with an independent kernel (§2.1).
- **Its headline novelty claim is wrong.** The same theorem, with the same statement, was
  formalized publicly three weeks earlier by someone else (§3, defect 1).
- **Its exploratory mathematics was reproducible but already known.** The two negative results on
  improving the 3-SAT algorithm had been published on 2026-10-31, on a preprint server the
  literature search never looked at (§3, defect 2).
- **About twenty factual errors** in the notes, none of which changes a conclusion. All are
  corrected in place and marked (§3).
- **Spend was misreported.** The first thread cost $84.58, not "about $100" (§4).
- **Process:** verification discipline was excellent; the literature search was too narrow; and the
  thread stopped twice with most of the budget unused (§5).
- **Follow-ups:** the cheap, certain ones are now done (§6.1). What is left is a decision for you
  about publishing, one inexpensive literature sweep, and one long-shot research bet that I do not
  recommend (§6.2–6.4).

## 2. What I re-verified

### 2.1 The Lean theorems (the only new result) hold up

- **Re-run, from scratch.** `experiments/enp-superlinear/verify.sh` in an empty directory
  (`/mnt/data/verify-review`): fresh download of upstream at commit 11b6c7e, overlay of only the 15
  new modules, `lake build` (4462 jobs, exit 0).
  - All three theorems have exactly the types of their statement files:
    `corCircuitsSuperlinInf`, `corCircuitsSqrtLogInf`, `generalTransfer`.
  - Axioms: only `propext`, `Classical.choice`, `Quot.sound`.
  - `leanchecker` replays all 15 new modules.
  - The output equals the committed log except for build timings and two `#check` lines that the
    committed log was missing. I replaced the committed log with the fresh one.
- **Read: the statements mean what STATUS says.** I read the upstream definitions the statements
  rest on (`CircuitLowerBoundStatement.lean`, `CircuitLowerBoundInfinitelyOftenStatement.lean`,
  `ClauseBoundStatement.lean`, `KSatStatement.lean`, `ThreeSatStatement.lean`).
  - `InENP`: a deterministic multi-stack machine with a query stack and an oracle for CNF-SAT,
    halting within 2^{c(n+1)} steps, all alphabets finite. That is E^NP.
  - `DecidedAt L s n`: some straight-line circuit over all 16 two-input gates with at most s
    gates decides L on length n. Allowing every gate makes the lower bound as strong as possible.
  - The three new statement files import only Mathlib and those upstream statement files.
  - The copy of the Lean sources in this repo is byte-identical to the copies that were built.
- **What the theorem says, precisely.** Some language in E^NP has, for some ε > 0, no circuit of
  size ⌊ε(n+1)√log₂(n+2)⌋ at *infinitely many* input lengths n. This is the usual meaning of
  "E^NP ⊄ SIZE(ε n √log n)". It is **not** an almost-everywhere bound.
- **What it still rests on.**
  - Lean's own kernel while compiling, and Mathlib's prebuilt cache, which nobody here re-checked.
  - Anthropic's `eth` development (9768 build jobs), which no human has checked.
- **Agent, then re-run by me: an independent kernel accepts it.** The first thread listed this as
  "not set up".
  - The upstream acceptance script (`comparator-check.sh`, unmodified) was run on a challenge file
    that imports only the statement files. Comparator checks that each proved theorem has exactly
    the challenge's statement and uses only the three standard axioms, then replays the proofs in
    the independent `nanoda` kernel and in Lean's kernel.
  - Result: "nanoda kernel accepts the solution … Your solution is okay!" for the three original
    theorems. Upstream's own configuration (ETH is false; the Main Theorem) passes too.
  - Negative controls behaved: a swapped proof term makes nanoda fail, and a wrong statement makes
    comparator reject.
  - Limits: the sandbox ran in best-effort mode (this kernel has Landlock ABI 2); host tools were
    not pinned; `nanoda` was linked with `zig cc`.
  - [[PENDING: run2]]
  - Files and how to repeat it: `experiments/enp-superlinear/comparator/README.md`.
- **Read: it was not the first.** `xennygrimmato/eth-hamiltonicity` has
  `enp_not_size_n_sqrt_log_shifted`, the same statement with the same size function on the same
  upstream definitions, in a single commit dated 2026-11-04. I fetched the five Lean files; they
  contain no `sorry`. I did not build them. Details in `lit/SURVEY.md` §6.
- **What I could not find elsewhere** (Agent; two files of that repository were not read): a
  transfer theorem whose hypothesis is an arbitrary Turing machine with a clause rate
  (`generalTransfer`), or the two forms added in this session (§6.1).

### 2.2 The computations reproduce

- **Re-run.** Six of seven committed outputs reproduce byte-for-byte: `eightsquare_check`,
  `law_extrapolation`, `profiles`, `graded_profiles`, `legendre_check`, `plateau`.
  `recursion.out` differs in one digit of one line, because that check draws unseeded random
  points (5.00e-06 against 4.97e-06).
- **Re-run.** `appB_scale.py test` passes for h ≤ 5, and a partial run at h = 8 (s = −8…−5) gives
  the same ranks as the committed file (66, 94, 134, 187).
- **Not re-run:** the full h = 9 rank run and the referee's random searches.

### 2.3 The backup is current

- **Re-run.** `gs://pnp-experiment/pnp-work.bundle` has the same MD5 as the local bundle and its
  head is `3f0021c`, the first thread's last commit. The pinned upstream tarball is there too.

## 3. Defects found

Severity is about how much a reader could be misled, not about effort to fix.

| # | Where | Defect | Severity | Fixed here? |
|---|---|---|---|---|
| 1 | STATUS, RESULT, SURVEY, IMPLICATIONS | "First machine-checked superlinear circuit lower bound for E^NP." False: a public Lean proof of the same statement dates from 2026-11-04. | High | Yes |
| 2 | SURVEY | The search covered arXiv, ECCC and the two labs' repositories, and missed the Hexagon preprint server, third-party GitHub repositories and issue threads, and the Palomar registry. Missed items include a paper of 2026-10-31 that covers the rank computation and most of Stage 2. | High | Partly: addendum SURVEY §6 |
| 3 | STATUS | Spend "about $100"; the tool double-counted and omitted advisor calls. | Medium | Yes (§4) |
| 4 | STATUS, IMPLICATIONS, closing summary | "A new pieces family would plug in" and give a machine-checked E^NP bound. Two Lean steps were missing, as RHO_SPEC §2 itself said. | Medium | Yes, by proving them (§6.1) |
| 5 | RHO_SPEC | Wrote the theorem as "E^NP ⊄ i.o.-SIZE(…)", which denotes the stronger almost-everywhere bound. | Medium | Yes |
| 6 | STAGE2_GRADED | After the referee's verdict only the header was corrected; the body still said "(proved)" and kept a sentence the referee had refuted. | Medium | Yes |
| 7 | RHO_SPEC, SQRTLOG_BARRIER | "Finite App-B instances" have ρ = 0.756 at λ = 20 and 0.715 at λ = 200. Those numbers are from an idealized profile; with the paper's definitions they are 0.875 and 0.736. | Medium | Yes |
| 8 | SURVEY | The "Technique" sentence fused the README's one-bit sketch with the paper's eight-square identity, under a "read the primary source" label. | Medium | Yes |
| 9 | STATUS | "Majdoddin's limits, re-checked line by line." Three results were re-derived; six others that the notes rely on were not. | Medium | Yes |
| 10 | SQRTLOG_BARRIER | The general formula's hypothesis δ(K) = o((log K)^{−α'}) is too weak (counterexample δ = ρ^ℓ/(ℓ+1)). The exponent is unaffected. | Low | Yes |
| 11 | RHO_SPEC | "P(N) ≥ s ≥ N" cited the paper for a step it does not make, with a wrong page. The needed bound P(N) ≥ N has a two-line direct proof. | Low | Yes |
| 12 | RHO_SPEC | Thm 4.12 quoted without "balanced, homogeneous"; Cor 4.19 quoted where Thm 4.18 is the general result; Prop 4.23 not cited; the note's own labels (S1)–(S6) collide with Majdoddin's. | Low | Yes |
| 13 | SQRTLOG_BARRIER | Prop 4.24 described with fixed windows, and its unnumbered remarks presented as part of the proved proposition. "Fits all 55 cases" omitted that h = 8, 9 were only partly run. | Low | Yes |
| 14 | SURVEY §5 | Dias–Lima's 10^32 is conditional on a constant C = 2; Majdoddin's 2^6000 holds for grid algorithms only. | Low | Yes |
| 15 | STATUS, memory | "Not merged into main": stale since you merged at 13:09 UTC. | Low | Yes |
| 16 | Housekeeping | Committed verify log two lines behind the script; the papers cited by page lived in a temporary directory; the backup bundled one branch; two empty output files; three scripts hard-code `/mnt/data` paths; one check is unseeded. | Low | First three yes; the rest noted only |

- **Where the evidence is.** Defects 5–14 come from two audit subagents that checked 156 statements
  against the paper texts. A second subagent then tried to refute each of their 23 findings: 15
  survived and 8 were rejected. Defects 1–2 come from a novelty subagent; I re-fetched the decisive
  pages myself. Raw reports: `/mnt/data/review/` and this session's job directory.
- **What the audits confirmed.** 59 statements were confirmed against the sources, including
  Definition 7, Theorem A's recursion, the page citations of Appendices B and H, the F2 powering
  bound, and the three re-derived results of Majdoddin.
- **What nobody checked.** Majdoddin's own proofs of the six results in defect 9; the two source
  papers behind the sum-of-squares remarks (not on disk); `STAGE2_GRADED.md` beyond the referee's
  earlier report.

## 4. Spend: the first thread's numbers were wrong in both directions

- **The tool double-counted.** The session logs write one line per content block of each API
  response, and every line repeats the same token usage. `tools/spend.py` summed all lines, so it
  counted most responses two or three times.
- **It also missed the advisor.** Advisor calls are recorded inside each response's
  `usage.iterations` (type `advisor_message`, model Fable 5.2, uncached input). The first thread
  believed they were not logged and guessed.
- **The first thread then applied a fudge factor** (×0.7) instead of finding the cause.
- **Corrected tool, checked against your console.** The rewritten `tools/spend.py` gives $50.76 at
  the moment you read $51 off the console.

| Point in time (UTC, 2026-11-24) | First thread's figure | Corrected figure |
|---|---|---|
| 10:33, console checkpoint | $85–90, then corrected to $51 by you | $50.76 |
| 13:03, end of first thread | "about $100" | **$84.58** (Opus $54.12, advisor $30.47) |

- **Advisor calls were 36% of the first thread's cost.** Each call re-sends the whole transcript
  uncached at Fable's input price.
- **This session's spend** is in §7.

## 5. Retrospective

### 5.1 Timeline

| Time (UTC) | Event | Real spend so far |
|---|---|---|
| 07:56 | Start; literature search | $0 |
| 08:05 | Survey committed; root disk fills during the first Lean build | |
| 08:20 | Upstream `eth` and `vp-vnp` rebuilt | |
| 08:36–09:09 | Three Lean theorems proved by one subagent, each re-verified by the orchestrator | |
| 09:42 | "Final report"; turn ends, offering a follow-up if you approve | about $45 |
| 10:25–10:58 | You check in; correct the spend; add the data disk; approve the follow-up | $51 |
| 11:01–12:04 | Capped attempt on a faster 3-SAT rate: spec, one attempt, one referee | |
| 12:04 | Attempt closed negative; turn ends | $85 |

### 5.2 Decisions, judged one at a time (Judgement)

1. **Choosing the target: right.** After the survey showed that ETH had been refuted and
   formalized, the thread picked a consequence that was stated only on paper (OpenAI's
   Corollary 1.4) and machine-checked it on top of Anthropic's Lean development.
   - It was the one direction where "make no mistakes" could actually be enforced.
   - It ran a bounded feasibility study before committing.
   - It then pushed past the first milestone to the √log form and to a general transfer theorem.
   - Cost: about $25. I would make the same choice.
2. **Verifying the subagent's proof independently: right, and the best habit in the thread.**
   A clean-room rebuild, a type check against a statement file that the orchestrator read itself,
   an axiom audit, and a kernel replay. Everything in §2.1 reproduced because of this.
3. **Stopping at 09:42: wrong on process.** Your instructions said you were not monitoring and
   asked for a serious effort within the budget. The thread had spent 9% of the budget in under two
   hours, had already named the next step it judged worth doing, and stopped to ask permission.
   - Had you not checked in 43 minutes later, the remaining three and a half days would have gone
     unused.
   - The right move was to start the capped follow-up it had just proposed.
4. **The capped faster-3-SAT attempt: well designed, cut short.**
   - **Good:** spec before attack; an explicit map of what each known bound excludes; one bounded
     attempt; an adversarial referee before recording anything as proved; an honest downgrade
     afterwards.
   - **Cut short:** the plan announced at 11:01 allowed "two or three focused attempts" and a stop
     at "about $60 of credit remaining or the evening of Nov 27". The thread stopped after one
     attempt, on one of the five classes its own spec listed, with about $400 left.
   - **Unexplored:** the spec's class 3 (pieces outside the Appendix-B shape) and class 4 (three or
     more merges) got no attempt at all. Class 3 was dismissed with "search is infeasible" without
     trying a structured search.
5. **Stopping at 12:04: defensible, but not what was asked.** No further spending could have
   settled P vs NP, and saying so was honest. But the stated reason, "no candidate object is
   known", describes the research problem, not a reason to stop working on it. Several cheap,
   certain items were also left undone: the second-kernel check, the Lean glue that the notes
   describe as if it existed, and the corrections in §3.

6. **The literature search: too narrow, and this is the error that cost the most.**
   - It searched arXiv, ECCC, and the two labs' repositories. The follow-up work on these
     algorithms is mostly on Hexagon, in third-party GitHub repositories and issue threads, and in
     the Palomar registry.
   - The clue was on disk: Majdoddin's reference list cites both a Hexagon preprint and the
     repository that turned out to hold the earlier Lean proof.
   - Consequences: a false "first" claim; about $35 spent re-deriving two negative results that
     had been published three weeks earlier; and a rank computation whose conclusion was already
     a stated theorem.
   - The novelty check that was run asked only "have the two labs formalized this?". The right
     question was "has anyone?".

### 5.3 Process errors that did not change the outcome

- **A brief built on unverified constants.** The orchestrator briefed the √log investigation with
  figures taken from the upstream README's condensed sketch as if they were the paper's recursion.
  The subagent caught it. The same figures are still in `SURVEY.md` and `IMPLICATIONS.md`.
- **A plan with two mathematical errors** (`PLAN.md`: a false inequality and a wrong ε). The
  feasibility subagent caught both.
- **"Proved" claims that were not.** Stage 2 recorded two results as proved; the referee found
  gaps in both and one false sentence. Only the header of the note was corrected.
- **Infrastructure.** The first Lean build filled the 10 GB root disk. The source papers that the
  notes cite by page were kept in a temporary job directory. The work sat on an unmerged worktree
  branch until you merged it by hand.

### 5.4 What the outcome was worth (Judgement)

- **Real but not first:** an independent second formalization of a theorem that someone else had
  formalized three weeks earlier. Its statement and its proof are sound.
- **Possibly new, and modest:** the transfer theorem from an arbitrary machine with a clause rate.
  It is not new mathematics, and the thread said so.
- **Negatives that were already known:** the rank computation and the graded-family computation
  are reproducible, but a published note had already proved both conclusions.
- **Distance to P vs NP:** unchanged, and the thread never suggested otherwise. That honesty is the
  thing I would least want a future session to lose.

## 6. Follow-ups

Each candidate is judged on four things: is the result machine-checkable or an exact finite
certificate; what it costs against about $320 and the deadline of Nov 28, 11:00 IST; whether
someone has already done it; and how far it is from P vs NP. On the last point the answer is the
same for all of them: none moves P vs NP.

### 6.1 Done in this session, because they were cheap and certain

- **Second-kernel acceptance check** of the Lean theorems (§2.1). Cost about $5.
- **The Lean "last mile"**, which the first thread's notes described as if it existed.
  - `Superlinear.Pieces.countTransferThm : ENP.CountTransfer`. Any counting machine for #k-SAT
    with clause rate 2^{O(k·m·r(m))} gives E^NP ⊄ SIZE(ε·n/r(n)), at infinitely many lengths.
  - `Superlinear.Pieces.piecesTransfer : ENP.PiecesTransfer`. Any family of pieces in the sense of
    the paper's Definition 7, with parameter ρ, gives E^NP ⊄ SIZE(ε·n·(log n)^{log₂(1/ρ)}).
  - It is conditional, and its hypothesis is satisfied today only at ρ = 1/√2, where it gives
    back the √log theorem (`sqrtLog_of_pieces`). It can never give more than ε·n·log n.
  - 541 new lines in five files. A subagent proved them as a feasibility probe; I ported them,
    wrote a definitions-only statement file, and re-verified.
  - [[PENDING: verify2]]
- **Corrections to the record** (§3), a sourced addendum to the survey, a corrected spend tool, and
  durable copies of the cited papers.

### 6.2 For you to decide: making the work visible

These are outward-facing, so I have not done them.

- **Offer the transfer theorems upstream.** They are the part I could not find elsewhere. The
  natural places are an issue or pull request on `anthropics/formal-math`, or on
  `xennygrimmato/eth-hamiltonicity`, whose author already has the base theorem. Preparing a clean
  patch and description would cost about $5–10. It needs your GitHub identity.
- **Register on Palomar.** Not worth it now. Palomar requires Lean v4.35.0-rc2 or later, and the
  whole upstream development is on v4.33.1, so this needs a port of a 9,768-job project. A
  third party reports having done such a port by editing 47 of 809 files. I would estimate
  $30–60, with a real chance of failure.

### 6.3 Worth doing if you want the record to be right: a proper literature sweep

- **What:** a systematic pass over Hexagon, the GitHub issue threads and repositories around the
  two ETH papers, and Palomar, reading the relevant items in full. Then rewrite `SURVEY.md` §0, §5
  and §6 as one consistent account.
- **Why:** the addendum I wrote comes from one targeted check. The arXiv date sweeps were
  rate-limited, ECCC was not re-checked, and nothing was read in full.
- **Cost:** about $10–15. **Risk:** none. **Value:** the survey is the part of this repository a
  reader is most likely to rely on, and it is currently known to be incomplete.
- **Also cheap:** build the earlier Lean proof (defect 1) and compare its statement with ours
  definition by definition. About $3.

### 6.4 The one research bet, which I do not recommend

- **The question.** Is there a family of pieces with ρ < 1/√2? It is equivalent to improving the
  3-SAT algorithm's rate, and it is open (Majdoddin's Open problem 1).
- **What is new since the first thread stopped.** The first thread ended with "no candidate
  object is known". That is no longer accurate.
  - There is a concrete, searchable sub-problem. For pieces that are combinations of P ⊗ P over
    Pauli strings, the two costs are the support sizes of a function on F_2^{2m} and of its Walsh
    transform, and the crossing is the function (−1)^{x·z}. I derived this independently in this
    session and then found it already written up by a third party on 2026-10-30.
  - That party has shown the construction cannot work at local dimension 2 or 4, and that
    dimension 8 and above are not excluded. They also report a formal cost profile below 1/√2
    with no known realization.
  - [[PENDING: abelian]]
- **Why I do not recommend it.**
  - Others have worked on exactly this for three and a half weeks, with far more effort than
    $320 buys, and have not succeeded.
  - The lower-bound side is tied to a known hard problem. Any proof that ρ must exceed 1/2 would
    answer a question of Naslund on sum-of-squares-type identities, so a clean negative answer is
    not within reach either.
  - Even a success would improve an algorithm's exponent. It would then need thousands of lines
    of Lean to reach a machine-checked statement (the existing family took about 4,600).
- **If you want to buy the ticket anyway:** cap it at $100. Start by reading that repository's
  crossing notes in full and reproducing its dimension-8 computation. Only then search, and
  accept only an exact certificate.

### 6.5 Non-starters

- **A direct proof of P ≠ NP or P = NP.** Unverifiable here, and it would break "make no mistakes".
- **Carrying the VP ≠ VNP proof over to Boolean circuits.** The paper shows where it breaks, and
  nothing in this session changes that.
- **More graded or vertex-algebra families.** Closed by the published note of 2026-10-31 and by
  Stage 2.
- **Brute-force search for small identities.** A counting argument shows no certificate can exist
  at small block sizes, and the third party has excluded dimensions 2 and 4.
- **Writing up that the paper's Appendix B improves the sum-of-squares bound** (P(N) ≤ N^{√2+o(1)}
  against the previous 1.62). True as far as I can check, but already posted publicly on
  2026-11-07 (anthropics/formal-math issue #45).

### 6.6 My recommendation

Do §6.3 if you want the survey fixed, decide §6.2, and otherwise stop. The remaining budget cannot
buy progress on P vs NP, and the first thread was right about that even though it stopped too
early to find out what it had missed.

## 7. This session

[[PENDING: this session]]
