> **Referee verdict (independent adversarial check; `lit/STAGE2_REFEREE.md`): both claims are CORRECT WITH GAPS.**
> - **Theorem G** bounds the App.-B *bit count*, not Def.-7 ρ, which needs only log rank. "Class L" also needs the identity on all of M, while Def. 7 needs it only on the states. So it rules out a **subclass** of constructions, not Majdoddin's Open problem 1.
> - **A false sentence in §4.** It says a scalar on all of M must come from the vacuum term; the Heisenberg Fock module π_μ is a counterexample. The fix is to run Lemma V on V·w.
> - **H must be assumed poly(λ).**
> - **Lemma L** needs F < ∞. Its bridge to exact counts is false for λ-dependent c_n, so "ρ ≥ 1/√2 for all product characters" is **unproven**. In numeric tests the conclusion still held, with a minimum D(2h*)/λ of 1.48 > √2.
> - **Read the bottom line below as:** no gain found in these families, and the obstructions are partially proved. It is not a theorem that the class is closed.

# STAGE 2: graded generalizations of App. B pieces (RHO_SPEC escape classes #1, #2)

Sources: **[A]** `eth-raw.txt`, **[M]** arXiv:2610.41622 (printed pages). Scripts and outputs: `/mnt/data/rho/stage2/`, copied to `experiments/rho/stage2/`.

**Summary, in three tiers.** The class is "class L" (§2): vertex-algebra pieces whose identity holds on the whole module.
1. **Escape class #1 (μ < 2) is closed in class L (proved).** This assumes the balanced piece is present and bits are counted ([M] (S3)). Evaluating the identity on a lowest-weight vector forces μ ≥ 2, so steeper profiles pay ρ ≥ 2^{a−1} > 1/√2. Plane partitions give 0.794.
2. **Class #2 (kinks) is closed for product characters ∏(1−q^n)^{−c_n} with c_n nondecreasing.** This covers all strongly freely generated bosonic algebras, at any λ-dependent rank and with multiplicity spaces. The proof is at the Legendre level (Lemma L); the one-sided saddle-point transfer is a conjecture, checked numerically.
3. **Open:** kinked characters of other vertex algebras, and everything outside class L (§4). No candidate is known.

## 1. Mechanism

- **The objects** ([A] p.30, p.49). The strings are partitions of h, which index the monomial basis of V_h in the Heisenberg Fock space V = Q[t₁,t₂,…]. The a[r] of (47) are the field modes.
- **Lemma 9 is locality, and its sum is an OPE coefficient** (our derivation, standard VOA facts).
  - For H ≥ N(a,b) (the locality order), (ω₁−ω₂)^H Y(a,ω₁)Y(b,ω₂) = (ω₁−ω₂)^H Y(b,ω₂)Y(a,ω₁) = Σ_{j∈ℤ, j<H} Y(a_{(j)}b, ω₂)(ω₁−ω₂)^{H−1−j}.
  - Q_s, (48), collects the weight-preserving products; its two forms are Lemma 9(a).
  - At ω₁ = ω₂ the sum over s keeps only j = H−1. This gives the zero mode of c = a_{(H−1)}b, of weight wt a + wt b − H.
  - App. B takes H = wt a + wt b, so that c ∈ V₀ = Q·1 is a scalar on **every** module (Lemma 9(c)).
  - A smaller H leaves o(c) for a positive-weight c. That can be scalar on a single weight space (e.g. c = ω, o(ω) = L₀), but not on all of M. See §4.
- **Lemma 10** ([A] p.32) diagonalizes the pairing a⊛b := a_{(H−1)}b on V_h. Its y_n trick makes a_µ[−h] act as ∏∇_{µᵢ}, so all coefficients have poly(λ) bits, as Def. 7(c) requires. Bare nondegeneracy would give 2^λ-bit denominators.
- **Where the profile enters** ([A] (54)–(56), (77)).
  - Product i passes through V_{s+i} in the a-first order and through V_{2h−s−i} in the b-first order.
  - So c_row ≈ D(2h+s) and c_col ≈ D(2h−s), with D(E) = log₂ dim V_{≤E}.
  - Tops sum to 2·wt(y) + H.

## 2. Class L and the trade-off theorem (our derivation)

**Class L.** The ingredients are:
- V, a ℤ_{≥0}-graded vertex algebra over Q with finite-dimensional pieces;
- M, a graded V-module with lowest weight 0;
- labels a_x, b_v and 2^λ states in M_{≤h_y};
- pieces A_s = ⟨u*|Q_s(a_x,b_v)|y⟩, built as in (48) with some exponent H;
- the natural factorizations through intermediate weight spaces, with counted bits ≥ D_M(window) − o(λ).

**Hypothesis:** Σ_s Q_s(a_x,b_v) = d[x=v]·Id **on all of M**, with d ≠ 0. App. B satisfies it with the vacuum term. Since the s-range has at most H+1 values, H+1 ≤ |I| ≤ (2λ)^c. Let h*_X = min{E : D_X(E) ≥ λ − 2log₂(H+1)}.

**Bookkeeping.** On M_E, the products in Q_s have a-first tops E + s + const and b-first tops E − s − const + H. Each pair of tops sums to 2E + H, as in App. B.

**Lemma V.** D_M(⌊H/2⌋) ≥ λ − 2log₂(H+1).

*Proof.*
1. Take w ∈ M₀ and w* with w*(w) = 1. The (x,v)-matrix Σ_s w*(Q_s w) = d·I has rank 2^λ.
2. By Lemma 9(a) each s-term may be factored in its cheaper order. That passes through M_{≤min(tops)} ⊆ M_{≤⌊H/2⌋}.
3. At most H+1 values of s contribute, so rank subadditivity gives 2^λ ≤ (H+1)·dim M_{≤⌊H/2⌋}. ∎

For App. B the lemma reads D(h) ≥ λ, which is tight. If the scalar is the vacuum term, the identity also holds on V itself, and with w = 𝟙 the lemma gives D_V(⌊H/2⌋) ≥ λ − 2log₂(H+1) as well.

**Theorem G.** In class L, suppose the piece at the balanced shift s* is present, as in App. B and [M] Prop 4.24. Then

  **ρ ≥ D_M(h*_M + η) / (2λ) − o(1),** with η = h*_M, or η = max(h*_M, h*_V) under the vacuum hypothesis.  (★)

In M's own profile this means μ ≥ 2: **escape class #1 is empty in class L.**

*Proof.*
1. At s*, both window tops are ≥ h_y + ⌊H/2⌋.
2. The states need D_M(h_y) ≥ λ, so h_y ≥ h*_M.
3. Lemma V gives ⌊H/2⌋ ≥ η.
4. Hence c_row + c_col ≥ 2D_M(h*_M+η) − o(λ). ∎

**Corollaries.**
- **(C1) Power profile D_M = cE^a.**
  - ρ ≥ 2^{a−1}.
  - If a < ½, pigeonhole ([M] Prop 4.6: D_M(2h_y+H) ≥ 2λ) forces windows beyond 2h*, and then ρ ≥ 2^{−a} ([M] Prop 4.24).
  - So **ρ ≥ 1/√2**, with equality only at a = ½. This is [A] (77)'s ρ = 2^{a−1}, with the 2h window now shown to be forced.
- **(C2) Concave D_M:** ρ ≥ 2/3, from [M] Prop 4.24 at μ = 2. The window [2/3, 1/√2) is class #2.
- **(C3) Product characters.**
  - Setting: M's character is ∏_n(1−q^n)^{−c_n}, c_n nondecreasing, possibly λ-dependent. This holds for strongly freely generated bosonic algebras (a weight-w generator gives every mode n ≥ w), e.g. universal Virasoro, affine and W-algebras, Heisenberg of any rank, and generalized free fields.
  - Then ★ with η = h*_M and Lemma L give **ρ ≥ 1/√2 − o(1)**.
  - Multiplicity spaces M = V⊗U with log₂ dim U = κλ, under the vacuum hypothesis: D_M = κλ + D_V. Lemma L gives D_V(h*_M + h*_V) ≥ λ√((1−κ)²+1) − o(λ), so 2ρ ≥ κ + √((1−κ)²+1) ≥ √2.

**Lemma L (Legendre lemma; proved).**
- Definitions: F(θ) = ln Z(θ) = Σ c_n f(θn) with f(t) = −ln(1−e^{−t}), and S(E) = min_θ(θE + F(θ)). Chernoff gives ln dim V_{≤E} ≤ S(E).
- **Claim:** if c_n is nondecreasing, then θF(θ) is nonincreasing, S(E)/√E is nondecreasing, and S(E₁+E₂)² ≥ S(E₁)² + S(E₂)².

*Proof.*
1. Write c_n = Σ_{w≤n} m_w with m_w ≥ 0, and expand f(t) = Σ_j e^{−tj}/j. Then θF(θ) = Σ_w m_w Σ_j j^{−2} g_w(θj), where g_w(x) = x e^{−(w−1)x}/(e^x−1) is decreasing. So θF is nonincreasing.
2. For t ≥ 1, the substitution θ = φ/√t gives S(tE) = min_φ(√tφE + F(φ/√t)) ≥ √t·S(E).
3. The squared form follows from S(E₁+E₂)²/(E₁+E₂) ≥ S(Eᵢ)²/Eᵢ for each i. ∎

**Transfer (conjecture).** Only the one-sided bound ln dim V_{≤E} ≥ S(E) − o(λ) at E = 2h* is used; Chernoff supplies the other direction.
- *Sketch, not verified:* tilting plus Chebyshev gives ≥ S(E) − 4θ√F″(θ) − O(1). That is o(λ) whenever h* → ∞. For bounded h* the ratio D(2h)/D(h) → 2 directly.
- *Numerics* (`legendre_check.out`), for c ≡ 1, 24, 2^20 and c_n = n: S − ln dim V_{≤E} lies between 1.5 and 4 nats, and D(2E)/D(E) > S(2E)/S(E) ≥ √2.

## 3. Candidates

Counted ρ uses App.-B windows (forced by §2): ρ = max_s[D(2h+s)+D(2h−s)]/(4λ), D cumulative, h least with D(h) ≥ λ. Exact integer counts (`graded_profiles.out`); the control row reproduces RHO_SPEC's 0.756 and 0.715.

| family (character) | a | λ=20 | λ=100 | λ=200 | λ=400 | 2^{a−1} |
|---|---|---|---|---|---|---|
| partitions = App. B (control) | ½ | 0.756 | 0.721 | 0.715 | 0.712 | 0.707 |
| 24-coloured (rank-24 Heisenberg) | ½ | 0.844 | 0.771 | 0.747 | 0.732 | 0.707 |
| plane partitions (MacMahon, c_n = n) | 2/3 | 0.850 | 0.808 | 0.801 | 0.798 | 0.794 |
| c_n = C(n+1,2) ("d = 3") | 3/4 | 0.911 | 0.851 | 0.846 | – | 0.841 |
| c_n = C(n+2,3) ("d = 4") | 4/5 | 0.941 | 0.880 | 0.871 | – | 0.871 |
| rank N(λ), min over 18 values of N ∈ [1, 2^40] | ½ | – | 0.721 | 0.715 | 0.712 | – |

- **(a) Plane partitions.** They are the monomial basis of the free-field algebra with one generalized free field per weight w ≥ 1, where a^{(w)}(z)a^{(w)}(ζ) ~ (z−ζ)^{−2w}. The character is MacMahon's, which is also the vacuum character of W_{1+∞} at generic c.
  - The identity generalizes verbatim, since it is locality with the vacuum term.
  - The windows are 2h. ρ ≥ 2^{−1/3} − o(1) ≈ 0.794. **Worse.**
  - Attaining that value needs a Lemma-10 analogue with poly(λ)-bit coefficients; a per-field y_n-type change of generators is plausible (conjecture).
- **(b) d-dimensional analogues.** True d-dimensional partitions have no product formula for d ≥ 3. The realizable object is c_n = C(n+d−2, d−1), with a = d/(d+1). ρ ≥ 2^{−1/(d+1)} → 1. **Worse.**
- **(c) Multipartitions (control).** a = ½. A λ-dependent rank, the natural way to manufacture a kink, never helps: the optimum is N = 1 for each λ ∈ {50, 100, 200, 400}, and Lemma L covers every N because F is linear in N. **No gain.**
- **(d) Others.**
  - *Rational quotients and lattice VOAs:* modular characters, with C√E·(1+o(1)) growth, so the ratio → √2 and ρ → 1/√2 at best. This is not proved for every such algebra.
  - *Fermions* ([M] p.48): the finite exterior algebra gives ρ → 1, the infinite free fermion has the partition profile.

## 4. Obstruction, and what is outside

**Obstruction (proved in class L).**
- A scalar on all of M must come from the vacuum term, i.e. from a module-wide identity.
- Lemma V then forces the label exponent H ≥ 2h*_M, so μ ≥ 2.
- Faster growth only raises D_M(2h*)/D_M(h*) ≈ 2^a: [M] Prop 4.24's 2^{a−1} branch. The 2^{−a} branch needs μ < 2 and is unreachable.

**Remaining in class L (conjecture: empty).** A module with D_M(h*_M + η) < √2·λ, i.e. log-dimension growing by less than √2× when the weight doubles past h*. Product characters are excluded by (C3), modular ones heuristically. No example is known, here or in [M] p.48.

**Outside class L (not analysed).**
1. **Identity scalar only on M_{h_y}.** Labels with H < wt a + wt b whose zero mode o(a_{(H−1)}b) is scalar on M_{h_y} only. Lemma V then fails on M₀. For c = ω the saving is 2 weights, which is harmless. For large-weight c we see no exclusion.
2. **Braided locality:** twisted modules and intertwining operators.
3. **True rank far below the counted bits:** RHO_SPEC class #3, [M] Open problem 1. The App. B rank check found no gain.

**Bottom line.** **No ρ < 1/√2 in class L via faster growth.** Windows of width 2h* are forced, so steeper profiles cost 2^{a−1}. Kinks are excluded for all product characters, conditional on the one-sided saddle-point transfer. α′ = ½ stands unless one of the open items above produces a construction.
