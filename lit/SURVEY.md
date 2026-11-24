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
   - **Verification status:** per its README, formalized in Lean 4 / Mathlib with the standard axioms only and re-checked by the nanoda kernel. I am rebuilding it myself; see experiments/lean-rebuild/. *No human mathematician has checked it*, according to the authors.
   - **Technique:** spectral points (Strassen's asymptotic spectrum; existence comes from Zorn's lemma, so they are non-explicit). The proof splits into a "flat" case and a "contracting" case. The contracting case ends in a diagonalization against "accelerators".
   - **Why it does not reach Boolean circuits (paper §2.5):** two steps look at the *formal polynomial* at each gate. One is the block-multilinear part (lem_balanced); the other is the low-degree part (lem_lowdeg). A Boolean circuit only needs to agree on {0,1}, so it may compute HC + Σ(x_i² − x_i)h_i, whose parts are unrelated.
   - **Barriers:** the authors have *not* analysed relativization or algebrization for their proof.
2. **ETH is false.** Two papers, posted within a day of each other.
   - **Anthropic** [V-primary: formal-math/eth, paper.pdf]: Claude, "A 2^{o(n)} Time Algorithm for 3-SAT", 2026-10-26.
     - **Main theorem:** #k-SAT runs in time 2^{O(min{k² n log log n/√log n, k m/√log m})}. Per its README, machine-checked in Lean against Mathlib's Turing.FinTM2 model. I am rebuilding it myself.
     - **Technique:** contracting tensor networks on the complete graph K_K. The recursion is e(9K^16) ≤ 0.9·e(K) + O(1/K), and it uses an "eight-square identity" decomposition of SWAP (SWAP = I − 2·singlet).
     - **Practicality:** none. There is no improvement over 2^n unless n > 10^{10} (for m = 5n, unless n > 10^{10000}).
     - **Consequences stated in §7:** SETH, NSETH and #ETH are false; Independent Set, Clique, Vertex Cover, Dominating Set and k-Coloring run in 2^{δn}; **E^NP has no linear-size circuits** (via Williams [Wil13, Thm 6.1] and Jahanjou–Miles–Viola [JMV15]).
   - **OpenAI** ("The Exponential Time Hypothesis is False", 2026-10-25) [secondary]. Its Corollary 1.4 reportedly gives **E^NP ⊄ SIZE(c·n·√log n)** infinitely often. That corollary is said to be outside its Lean file [secondary: W. DeMeo blog].
   - **Follow-up, Wu & Wang, arXiv:2611.02560** [secondary: a paraphrase of the abstract page by the fetch tool]:
     - E^NP needs Ω(m√log m / log log m) gates over unbounded AND/OR with binary XOR.
     - It needs Ω(m√log m) gates over binary bases with a linear budget of XOR or symmetric gates.
   - **Other follow-ups** [secondary, titles only]:
     - arXiv:2611.00517, "Limits and constants of OpenAI's claimed ETH refutation".
     - arXiv:2610.41622, crossover points.
     - arXiv:2611.01774, monotone local search.
     - arXiv:2611.06231, "Exhaustive search is hard to beat in constant depth for Hyperclique and OV". Orthogonal Vectors (OV) is **not** refuted.

**My own sketch, not written out; it matches a reported result.** The m-dependence 2^{O(m/√log m)} plus the Tseitin transform gives #CircuitSAT for size-s circuits in 2^{O(s/√log s)}. Feeding this into Williams' E^NP argument gives E^NP ⊄ SIZE(ε n √log n). This holds only if the overhead in Williams Thm 6.1 / JMV stays linear for superlinear sizes, which I have not yet checked. It is reportedly OpenAI's Cor 1.4 [secondary] and the starting point of Wu–Wang, so **it is not new**.

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
- **Family 379, "VP and VNP are different" (2026-11-23).** The border-circuit bound is exp(Ω((log n)^{5/4})) over every field. The two labs' VP ≠ VNP results were independent and concurrent.
- **Family 103:** L = RL = BPL.
- **Family 102:** claims a proof of the Unique Games Conjecture.
- **Family 112:** a language in P that needs 2^{ω(√n)} gates in depth-3 (OR–AND–OR) circuits.
- **Family 108:** a cubic lower bound for permanent vs determinant (border determinantal complexity).
- **Family 107:** a matrix multiplication algorithm with ω ≤ 9/4.
- **Family 136:** a quasilinear PCP for PPAD.
- **Withdrawals** [V-primary: history.md, 2026-10-07]: three Hodge-related manuscripts were withdrawn after a sign error. AI-produced, unformalized claims can therefore be wrong.
- **P vs NP:** grepping CONTENTS.md for "P vs NP", "P ≠ NP" and "P = NP" turns up **no family that claims to resolve it**.
