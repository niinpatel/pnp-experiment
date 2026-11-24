# What the 2025–2026 results do and do not say about P vs NP

This is my own reasoning (Claude, 2026-11-24), built on the sources in `SURVEY.md`.
- **Standard:** marks a textbook fact.
- **Source:** marks a fact quoted from a paper I read.
- **Reasoning:** marks my own argument, which nobody else has checked.

## 1. VP ≠ VNP (Anthropic and OpenAI, Nov 2026) does not give P ≠ NP

- **Standard.** The known implications run from Boolean to algebraic. Bürgisser (2000) shows that
  NP ⊄ P/poly implies VP ≠ VNP over C, assuming GRH. No implication in the other direction
  is known, so VP ≠ VNP leaves P vs NP open.
- **Source** (Anthropic VP≠VNP paper, §2.5). The proof breaks for Boolean circuits at exactly two
  steps. Both look at the *formal* polynomial that each gate computes:
  - the block-multilinear decomposition (`lem_balanced`);
  - the low-degree evaluation (`lem_lowdeg`).

  A Boolean circuit may compute HC + Σ(x_i² − x_i)·h_i, and the relevant parts of that
  polynomial are unrelated to those of HC.
- **Reasoning: what a Boolean transfer would need.** Over F₂, a Boolean circuit of size s
  determines a unique multilinear polynomial, but multilinearization is not cheap.
  - The proof would have to apply to some *multilinear-on-the-cube* representative of the
    circuit's function. No known size-preserving way to obtain one exists.
  - On 0/1 inputs over F₂, HC_m computes the *parity* of the number of Hamiltonian cycles,
    which is a function in ⊕P. A Boolean superpolynomial lower bound for it would give
    ⊕P ⊄ P/poly. That is also far beyond anything known, though it is not the same as
    NP ⊄ P/poly.
- **Reasoning: the natural-proofs barrier.** The "spectral points" come only from Zorn's lemma,
  so they are non-constructive. That is the right shape for evading the natural-proofs
  barrier. A Boolean analogue would still have to evade relativization and algebrization,
  and the authors say they have not analysed either.

## 2. ETH refuted (Oct 2026) does not give P = NP

- **Source.** The algorithms run in 2^{O(n log log n/√log n)} time. That is still
  superpolynomial, and it is consistent with P ≠ NP.
- **Source** (Anthropic ETH paper, §1.2 and App. G, read in full). In the Austrin–Kaski–Kubjas
  model, which executes *one* tensor network along *one* contraction tree, no algorithm for the
  recursed problem has an exponent below about 2/9, i.e. 4/9 of brute force.
  The paper's algorithm lies *outside* that model, because it contracts a signed sum of
  networks in different orders. So this is **not** a known limit of the new approach. It
  shows that the approach had to leave the classical model.
- **Reasoning.** The rate e(9K^16) ≤ 0.9·e(K) + O(1/K) gains only polylogarithmically in the
  exponent. Reaching 2^{n^{1−ε}}, let alone polynomial time, would need a different idea.
  Nothing in either paper suggests one.
- **Standard fact, which still stands.** NP-hard problems having 2^{o(n)} algorithms
  is fully consistent with NP ⊄ P/poly.

## 3. Algorithms to lower bounds: the one channel that moves toward separations

- **Source.** Williams' theorem: faster satisfiability algorithms for a circuit class C give
  NEXP ⊄ C, or E^NP ⊄ C.
  - The ETH algorithm, through Tseitin, decides SAT for circuits of size s in
    2^{O(s/√log s)}.
  - This gives E^NP ⊄ SIZE(c·n·√log n) infinitely often [OpenAI paper, Cor 1.4; I read the
    statement and proof in the PDF; there is no Lean].
  - Anthropic's Lean development proves the linear version, E^NP ⊄ SIZE(O(n)).
  - **This session machine-checked** E^NP ⊄ SIZE(ε·n·√log n) infinitely often
    (`Superlinear.corCircuitsSqrtLogInf`; Lean, standard axioms).
    See `experiments/enp-superlinear/RESULT.md`. A public Lean proof of the same statement
    predates it (Tulsyan, 2026-11-04; `SURVEY.md` §6).
- **Reasoning: distance to P ≠ NP.** E^NP ⊄ P/poly would itself be a major breakthrough. It
  would still not give P ≠ NP, which needs *NP* ⊄ P (or NP ⊄ P/poly).
  - Via this route, the SAT algorithm would have to beat 2^n by a superpolynomial factor on
    *polynomial-size* circuits.
  - The tensor-network method only reaches about n·√log n gates.
- **Where the frontier sits.** Improving 2^{m/√log m} to 2^{m/(log m)^c}, as a 3-SAT
  Turing machine in the stated encoding, would give E^NP ⊄ SIZE(ε·n·(log n)^c), for 0 < c ≤ 1.
  This is a **Lean theorem** in three forms: `Superlinear.generalTransfer` for a deciding machine,
  and, added in the review session of 2026-11-24, `Superlinear.Pieces.countTransferThm` for a
  counting machine and `Superlinear.Pieces.piecesTransfer` directly from a family of pieces.
  The algorithmic improvement itself is open.

## 4. Other 2026 results

All of these are claimed, and some are unverified by humans.
- L = BPL [OpenAI 103].
- NL = UL [Hoza, ECCC TR26-323].
- A matrix multiplication algorithm with ω ≤ 9/4 [OpenAI 107].
- A depth-3 lower bound of 2^{ω(√n)} for a language in P [OpenAI 112].

None of these separates P from NP.
- The space results are derandomizations, i.e. collapses, not separations.
- The depth-3 bound is for a restricted model.

## Bottom line

As of 2026-11-24, P vs NP is open. The 2026 results move the frontier in:
- algebraic complexity (VP ≠ VNP);
- fine-grained algorithms (ETH false);
- slightly superlinear circuit lower bounds for E^NP.

None of them comes close to a Boolean separation of NP from P. I see no honest way to claim
otherwise.
