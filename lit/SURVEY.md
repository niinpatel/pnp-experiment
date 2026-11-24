# Literature survey: P vs NP as of 2026-11-24

How claims are labelled:
- **[V-primary]** means I read the primary source myself: the paper PDF, the repository statement file, or the ECCC/arXiv abstract page.
- **[V-listing]** means the title and authors are confirmed in the ECCC 2026 index, but I have not read the paper.
- **[secondary]** means the claim comes only from news, a blog, or a Gemini search summary. Such claims are unverified.

## 0. Headline

P vs NP is **open** as of 2026-11-24. I found no claimed resolution that any expert has accepted. Several arXiv and Zenodo preprints claim a resolution, for example arXiv:2512.11820, arXiv:2508.13166 and a Zenodo record. None has any sign of expert endorsement [secondary, search results].

The two strongest late-2026 results near the problem were both found by AI models, and both explicitly say they do *not* settle P vs NP:

1. **VP ≠ VNP over every field**, by Claude (Anthropic), posted 2026-11-23. [V-primary for content: I read anthropics/formal-math/vp-vnp README, Statement.lean and paper.pdf §1–2. The 11-23 date is from news coverage.]
   - **Result:** every arithmetic circuit for PERM_m (char ≠ 2) or HC_m (any field) has more than m^{c (log m)^{1/3}} gates. The bound also holds for border (approximate) complexity.
   - **Verification status:** per its README, formalized in Lean 4 / Mathlib with the standard axioms only and re-checked by the nanoda kernel. I **rebuilt it**: the standard axioms only (experiments/lean-rebuild/). *No human mathematician has checked it*, according to the authors.
   - **Technique:** spectral points (Strassen's asymptotic spectrum; existence comes from Zorn's lemma, so they are non-explicit). The proof splits into a "flat" case and a "contracting" case. The contracting case ends in a diagonalization against "accelerators".
   - **Why it does not reach Boolean circuits (paper §2.5):** two steps look at the *formal polynomial* at each gate. One is the block-multilinear part (lem_balanced); the other is the low-degree part (lem_lowdeg). A Boolean circuit only needs to agree on {0,1}, so it may compute HC + Σ(x_i² − x_i)h_i, whose parts are unrelated.
   - **Barriers:** the authors have *not* analysed relativization or algebrization for their proof.
2. **ETH is false.** Two papers, posted within a day of each other.
   - **Anthropic** [V-primary: formal-math/eth, paper.pdf]: Claude, "A 2^{o(n)} Time Algorithm for 3-SAT", 2026-10-26.
     - **Main theorem:** #k-SAT runs in time 2^{O(min{k² n log log n/√log n, k m/√log m})}. Per its README, machine-checked in Lean against Mathlib's Turing.FinTM2 model. I **rebuilt it**: the standard axioms only.
     - **Technique:** contracting tensor networks on the complete graph K_K, after writing each crossing of two edges as a signed sum of cheaper "pieces". Three versions exist and should not be mixed up (corrected in review, 2026-11-24; the sentence first written here fused the first two):
       - the README's condensed sketch: a one-bit identity (SWAP = I − 2·singlet) and the recursion e(9K^16) ≤ 0.9·e(K) + O(1/K);
       - the paper's main text: the eight-square identity, with factor 11/12;
       - the stated rate 2^{O(m/√log m)}: Theorem A with the Appendix B pieces (factor 1/√2, K squared per level).
     - **Practicality:** none. For m = 5n clauses there is no improvement over 2^n unless n > 10^{10000}. The bound in n alone gives none unless n > 10^{10^8}. I re-read these figures with `pdftotext -raw`.
     - **Consequences stated in §7:** SETH, NSETH and #ETH are false; Independent Set, Clique, Vertex Cover, Dominating Set and k-Coloring run in 2^{δn}; **E^NP has no linear-size circuits** (via Williams [Wil13, Thm 6.1] and Jahanjou–Miles–Viola [JMV15]).
   - **OpenAI** ("The Exponential Time Hypothesis is False", 2026-10-25) [V-primary: openai/math preprints/…/paper.pdf, plus lean/docs/378.md]. Its Corollary 1.4 gives **E^NP ⊄ SIZE(c·n·√log n)** infinitely often, over fan-in-2 gates, on paper only. Its Lean development covers only the counting algorithm, at rate 2^{O_k(n(log log n)²/√log n)}.
   - **Follow-up, Wu & Wang, arXiv:2611.02560** [secondary: a paraphrase of the abstract page by the fetch tool]:
     - E^NP needs Ω(m√log m / log log m) gates over unbounded AND/OR with binary XOR.
     - It needs Ω(m√log m) gates over binary bases with a linear budget of XOR or symmetric gates.
   - **Other follow-ups** [secondary, titles only]:
     - arXiv:2611.00517, "Limits and constants of OpenAI's claimed ETH refutation".
     - arXiv:2610.41622, crossover points.
     - arXiv:2611.01774, monotone local search.
     - arXiv:2611.06231, "Exhaustive search is hard to beat in constant depth for Hyperclique and OV". Orthogonal Vectors (OV) is **not** refuted.

**From sketch to Lean proof (this session).** The m-dependence 2^{O(m/√log m)}, plus the Tseitin transform (4 clauses per gate), gives SAT for size-s circuits in 2^{O(s/√log s)}. Feeding this into Williams' E^NP argument gives E^NP ⊄ SIZE(ε·n·√log n), infinitely often. This is OpenAI's Cor 1.4 [V-primary], and the Wu–Wang extensions start from it, so **the mathematics is not new**. This session **machine-checked it in Lean**: `Superlinear.corCircuitsSqrtLogInf`; see experiments/enp-superlinear/RESULT.md. It was **not the first** machine check: a public Lean proof of the same statement, also on Anthropic's development, has existed since 2026-11-04 (§6). The overhead question is settled in the formal proof, because the host formula has at most 3·gates + O(m) variables and at most 4·Nv + 1 clauses.

## 1. Other 2025–2026 results near the problem

All entries below are [V-listing] in the ECCC 2026 index (eccc.weizmann.ac.il/year/2026), unless marked otherwise. Only TR26-173 to TR26-339 were in the part of the index I fetched. The one-line summaries come from search snippets; I have not read the papers.

**Boolean circuit size**
- TR26-260, Mishra & Santhanam: an explicit 3.5n − o(n) lower bound for general B_2 circuits. The previous record was 3.1n, from Li–Yang (STOC 2022).

**Threshold and constant-depth circuits**
- TR26-039 [secondary; outside the part of the index I fetched], Chen, Tal & Wang: lower bounds for THR∘THR beyond the quadratic barrier, proved via new circuit-analysis algorithms. This is the algorithms-to-lower-bounds route.
- TR26-248, Chukhin: "Breaking the Parity Barrier for Constant-Depth Circuits".
- TR26-221, Korten: "Top-Down Lower Bounds for All Depths".
- TR26-302, Korten: "Tight Depth Lower Bounds for Stretch Amplification".
- TR26-313, Chukhin, Gajulapalli, Golovnev & Mihajlin: unconditional circuit lower bounds using low-degree PIT.
- TR26-330, Reitwießner: improved bounds for depth-2 threshold circuits computing Andreev's function.

**Exponential-time classes, range avoidance and TFNP**
- TR26-118 [secondary; outside the part of the index I fetched], Ren & Williams: near-maximum circuit lower bounds for exponential time with MA queries, via range avoidance (arXiv:2607.09963).
- TR26-233, Li & Tell: hardness of range avoidance gives "plasticity".
- TR26-270, Li: derandomizing fragments of AM with range avoidance.
- TR26-319, Ghentiyala, Korten & Pitassi: power and limitations of TFNP hierarchies.

**Collapses and witness isolation**
- TR26-328, Hirsch & Volkovich: "The Ultimate Karp–Lipton Collapse".
- TR26-250, Hirsch, Volkovich & Williams: input-oblivious classes in the second level of PH.
- TR26-246, Ben Daniel: constant-probability witness isolation implies NP ⊆ P/poly.

**Space, isolation and unambiguity**
- TR26-323, Hoza: **NL = UL**. This resolves a long-standing open problem.

**Meta-complexity**
- TR26-249, Goldberg, Nanashima & Oliveira: learning, compression and meta-complexity.
- TR26-253, Goldberg, Hu, Lu, Lyu & Oliveira: the gap between average-case and worst-case complexity.
- TR26-290, Goldberg, Hu, Lu, Lyu & Oliveira: asymmetry of nondeterministic computations.
- TR25-203, Hu, Lu & Oliveira: hardness of nondeterministic Kolmogorov complexity [secondary].
- TR26-277, Garlik, Gryaznov, Lu, Santhanam & Tzameret: meta-mathematics of algebraic complexity.

**Proof complexity**
- TR26-316, Alekseev et al.: hard instances for depth-4 PC and AC0[2]-Frege.
- TR26-332, Itsykson & Smirnov: resolution is automatable on Tseitin formulas.
- TR26-196, Li, Ren & Zhong: proof complexity generators inside demi-bits generators.

**Algebraic complexity: determinantal complexity and border depth**
- TR26-218, Kumar & Volk: a quadratic lower bound on determinantal complexity.
- TR26-287, Sheshadri: extends "OpenAI's cubic lower bound for the permanent" (dc(perm_m) = Ω(m³)) to odd characteristic.
- TR26-309, Sheshadri: dc(perm_4) = 15.
- TR26-297, Dey, Dutta & Guo: an exponential top fan-in hierarchy for border depth-4 circuits.

**Algorithms**
- TR26-281, Shpilka: exposition of "OpenAI's matrix multiplication in exponent 9/4".
- arXiv:2610.06783, Alman & Vassilevska Williams: 3SUM in O(n^{1.9992}) and APSP in O(n^{2.99942}). Formalized by Anthropic.

## 2. Barriers any P ≠ NP proof must pass (classical, from memory; standard)

- **Relativization** (Baker, Gill & Solovay 1975). There are oracles A and B with P^A = NP^A and P^B ≠ NP^B.
- **Natural proofs** (Razborov & Rudich 1997). If a lower-bound argument is *constructive* and *large*, and it works against P/poly, then strong PRFs do not exist.
- **Algebrization** (Aaronson & Wigderson 2009). Techniques that algebrize cannot separate P from NP.
- **Locality barrier for hardness magnification** (Chen, Hirahara, Oliveira, Pich, Rajgopal & Santhanam 2020).

Known non-relativizing, non-naturalizing successes:
- Williams' ACC lower bounds: NEXP ⊄ ACC⁰ (2011), then NQP ⊄ ACC⁰ (Murray & Williams 2018).
- The algorithms-to-lower-bounds program that the 2026 E^NP results come from.

## 3. OpenAI `openai/math` catalogue

Label for this section: **[catalogue summary read, paper not read]** unless noted otherwise.
The repository README lists 722 manuscripts in 374 families, produced by an unnamed internal model. About 42% of the top-line results are formalized in Lean.
- **Family 378, "The Exponential Time Hypothesis is False" (2026-10-25).**
  - Claim: #k-SAT in (n+m)^{O_k(1)}·2^{n/(log n)^{1/2+o(1)}}, plus superlinear circuit lower bounds for E^NP.
  - Lean scope [V-primary: lean/docs/378.md]: formalizes only the counting algorithm, at rate 2^{O_k(n (log log n)²/√log n)}. **The E^NP circuit lower bound is not formalized there.**
- **Family 379, "VP and VNP are different" (2026-11-23).** The border-circuit bound is exp(Ω((log n)^{5/4})) over every field. Both labs' VP ≠ VNP manuscripts are dated 2026-11-23. Neither paper I read states whether the work was independent.
- **Family 103:** L = RL = BPL.
- **Family 102:** claims a proof of the Unique Games Conjecture.
- **Family 112:** a language in P that needs 2^{ω(√n)} gates in depth-3 (OR–AND–OR) circuits.
- **Family 108:** a cubic lower bound for permanent vs determinant (border determinantal complexity).
- **Family 107:** a matrix multiplication algorithm with ω ≤ 9/4.
- **Family 136:** a quasilinear PCP for PPAD.
- **Withdrawals** [V-primary: history.md, 2026-10-07]: three Hodge-related manuscripts were withdrawn after a sign error. AI-produced, unformalized claims can therefore be wrong.
- **P vs NP:** grepping CONTENTS.md for "P vs NP", "P ≠ NP" and "P = NP" turns up **no family that claims to resolve it**.

## 4. Unverified P vs NP claims with a Lean veneer (example)

- **Reservoir package `Mintpath/p_ne_np`** (v0.1.0, 2026-07-25). It claims "Machine-verified
  proof (0 sorries, **2 axioms**) that P ≠ NP via exponential circuit lower bounds for
  Hamiltonian Cycle". The registry page does not state the axioms, and the source repository
  returned HTTP 404 when I tried it.
- **Assessment:** this is a Lean proof that uses extra axioms, so it proves nothing until those
  axioms are inspected. I found no sign of expert acceptance. [secondary: registry page]

## 5. Follow-ups on the ETH algorithms

Label for this section: [V-primary: arXiv abstract pages, read via a fetch tool; full papers not read].

- **arXiv:2611.00517**, Dias & Lima, "Limits and Constants of OpenAI's Claimed ETH Refutation" (2026-10-31).
  - If the hidden constant is C = 2, the algorithm only beats 2^n for n ≈ 10^{32} or larger (10^{126} for C = 3); for the tensor route only when log₂(n+m) > 10^9. (Corrected in review: the 10^{32} figure is conditional on C = 2.)
  - The interpolation scheme costs 2^{Ω(√tw)}, and 2^{Ω(√n)} on random 3-CNF above density 3. That limit applies to the scheme, not to the tensor route, which the authors say "escapes these limits".
  - The paper does **not** claim an error in the proof.
- **arXiv:2610.41622**, Majdoddin, "Lowered crossover points of Anthropic's subexponential 3-SAT algorithm" (2026-10-30).
  - Lowers the crossover to about 2^{420} clauses at density 1.
  - Counting assignments that satisfy exactly j clauses runs in 2^{O(m/√log m)}, which refutes the Sparse Max-3-SAT hypothesis.
  - Model-specific limits: no gain below about 2^{6000} variables for *grid* algorithms in a "rewrite-and-merge" class, in the paper's main-term model (corrected in review: for the wider balanced homogeneous two-merge class the threshold is only about 2^{29}); and two balanced homogeneous merges cannot give 2^{n^{1−c}}.
- **Bottom line:** no general lower bound on the exponent is known. Whether 2^{m/√log m} can be improved, which would give stronger E^NP bounds through the Lean theorem of this session, is open.

## 6. Addendum from the review session (2026-11-24): follow-up work this survey missed

The survey above searched arXiv, ECCC and the two labs' repositories. Much of the follow-up work on
the ETH algorithms is elsewhere: on the Hexagon preprint server (hexagonmath.org), in third-party
GitHub repositories and issue threads, and in the Palomar registry of Lean proofs. Majdoddin's
reference list, which the first session had on disk, already pointed to two of these places.

Labels: **[V-primary]** means I fetched the page or file in the review session and read the part
quoted. **[agent-primary]** means a subagent of the review session fetched it and quoted it to me;
I did not re-fetch it.

**A prior Lean proof of the same E^NP theorem.**
- `xennygrimmato/eth-hamiltonicity` (Vaibhav Tulsyan), directory
  `lean-bridge-anthropic/bridge/EthFollowup/Circuits/`, one commit `9e5dfc8` dated 2026-11-04
  [V-primary: five files fetched; commit date from the GitHub API].
  - `enp_not_size_n_sqrt_log_shifted : ∃ L ε, 0 < ε ∧ InENP L ∧ ∀ N, ∃ n ≥ N, ¬DecidedAt L ⌊ε·(n+1)·√log₂(n+2)⌋ n`.
    This is the same statement as `ENP.CorCircuitsSqrtLogInf` here, with the same size function,
    on the same upstream definitions.
  - It also has `no_circuits_io`, generic in the size function, with the same architecture as
    `Superlinear/Chain.lean` here.
  - The five files contain no `sorry` or `axiom`. I built them against the upstream tree used here: they compile; the theorem depends on the three standard axioms only; it uses upstream's `ENP.InENP` and `ENP.DecidedAt`; and Lean accepts it and `ENP.CorCircuitsSqrtLogInf` as interchangeable in both directions (`/mnt/data/review/prior/CheckTulsyan.lean`). I used my own lake setup, not that repository's.
  - **Consequence:** the claim "first machine-checked superlinear circuit lower bound for E^NP"
    in the first session's report is wrong by three weeks.
  - What those five files do not have: a transfer theorem whose hypothesis is an arbitrary 3-SAT
    or #k-SAT Turing machine with a clause rate, or one from a family of pieces. Everything in
    them is fixed at the rate 1/√log [V-primary: grep]. I did not search the rest of that
    repository.

**Limits on the pieces (the ρ question).**
- Carlos Stein Naves de Brito, hexagon:2610.00692 v1 (2026-10-31), "The partition exponent in the
  graded pieces of the Claude 3-SAT algorithm is optimal for pieces of that shape" [V-primary:
  full text read, 5 pages; proofs not checked].
  - Theorem 2.2: a rank count for families of the Appendix-B shape. Corollary 2.3: growth
    exponents α < ½ are impossible. Proposition 3.1: the weight count never goes below
    max(2^{α−1}, 2^{−α}) ≥ 1/√2, with equality only at α = ½.
  - "Rank-tight up to a polynomial factor" there means that the *total* rank budget of all pieces
    exceeds the rank of the crossing only by a factor O(h²). It is not a statement about the rank
    of each piece.
  - Remark 3.2 states what is out of scope: "a family whose pieces had rank far below these
    dimensions … is not covered". It names two escapes: operators of smaller weight than the
    states (weight count down to 2^{−α}), and growth profiles that are not regularly varying. It
    argues that vertex-algebra-type constructions cannot use the first.
  - Section 4: Heisenberg Fock spaces on a sparse set of modes "do not carry Lemma 9".
  - "The floor ρ ≥ 1/2 remains open."
  - **Consequence for the first session's work:**
    - It anticipates `RHO_SPEC.md`'s analysis of the Appendix-B shape, including escape classes
      1 and 2, and the first tier of `STAGE2_GRADED.md`.
    - It does **not** contain the per-piece rank computation (`SQRTLOG_BARRIER.md`, Conjecture
      2), which addresses exactly what the note leaves out of scope, nor Stage 2's
      product-character lemma.
- Vaibhav Tulsyan, hexagon:2611.00149 v1 (2026-11-06), "What the ETH refutations do not give:
  barriers for the counting engines, with machine-checked lemmas" [V-primary: abstract page].
  - ρ ≥ 1/2 for pieces is machine-checked in Lean; on paper, ρ ≥ 3/8 for correlated
    decompositions of full grid levels. Nothing above 1/2.
- `1337isnot1337/integer-factoring`, a repository of about 1230 AI-assisted research notes, last
  commit 2026-11-22 [V-primary: three notes fetched, read in part].
  - `research/pauli-walsh-dictionary.md` (2026-10-30): for pieces that are combinations of
    P ⊗ P over Pauli strings P, the two cut ranks are the support sizes of a function on F_2^{2m}
    and of its Walsh transform; the crossing is the function (−1)^{x·z}; every decomposition has
    Σ_i min(r_i, c_i) ≥ d. One 64-label dictionary is excluded.
  - `research/bell-diagonal-crossings.md` (2026-10-31) reports that symmetric tensor powers of
    such seeds cannot beat 1/√2 at physical dimension 2 or 4 (floors 0.7744 and 0.70713), and
    that at dimension 8 the argument gives only 0.657, so dimension 8 and above are open. The
    note says it has had no independent proof review; I did not check it.
  - `research/beyond-half-research-checkpoint.md` (2026-11-01) reports a formal profile with rate
    below 0.707 for which "no polynomial crossing realizing that profile is known", and an
    actual construction that it says certifies ρ < 18/25. Not checked here.
  - Its README still lists an exponent above 1/2 as not established [agent-primary].

**The sum-of-squares connection.**
- anthropics/formal-math issue #45 (2026-11-07, J. Siemaszko) [V-primary: issue fetched]: Theorem B
  of [A] gives P(N) ≤ N^{√2+o(1)} for Naslund's crossing width, improving the exponent 1.62 of
  Hrubeš (2024) that [A] App. G quotes. A note with a Zenodo DOI is linked, and an independent
  re-derivation was posted on 2026-11-23 [agent-primary]. No expert has replied.
- `Arth-Singh/crossing-lower-bounds`, registered as PALOMAR-2026-11-16-000011 [agent-primary]: Lean
  proofs of linear lower bounds such as P(n) ≥ 4n/3. They do not answer Naslund's question.

**State of the repositories on 2026-11-24** [agent-primary].
- anthropics/formal-math: no commit after 11b6c7e. `eth/` was last changed on 2026-10-27.
- openai/math: `lean/docs/378.md` is unchanged; it still covers only the counting algorithm.
- Majdoddin, arXiv:2610.41622: still v1.
- Palomar has no registered entry for a superlinear E^NP bound. A submission needs Lean
  v4.35.0-rc2 or later, and Anthropic's `eth` is on v4.33.1, so it would need a port.
- No improvement of the rate 2^{O(m/√log m)} and no pieces with ρ < 1/√2 were found anywhere.

**Wu and Wang, arXiv:2611.02560 v1** (2026-11-02) [agent-primary: abstract from the arXiv API,
replacing the paraphrase in §0]. "Circuit Lower Bounds for Extended Gate Bases from Subexponential
Counting": an E^NP language requiring Ω(m√log m / log log m) gates over unbounded AND/OR with
binary XOR, and Ω(m√log m) gates over a bounded binary base with a linear budget of arbitrary XOR
and symmetric gates, both infinitely often.

**Not done in this addendum:** arXiv date-window sweeps (the API rate-limited), ECCC since
2026-10-25, and a full read of any of the items above.
