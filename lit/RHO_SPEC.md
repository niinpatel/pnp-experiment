# RHO_SPEC: what "ρ < 1/√2" means, what excludes it, what is left (Stage 1)

Sources: **[A]** Anthropic paper (`eth-raw.txt`; printed pages). **[M]** Majdoddin, arXiv:2610.41622v1 (printed pages). **Lean**: `/mnt/data/lean/anthropics-formal-math-11b6c7e/eth/proof/`. Scripts: `/mnt/data/rho/scripts/` (`profiles.py/.out`, `Ax.lean`).

**Verdict.** The target is one precise, Lean-pluggable object: Def.-7 pieces with ρ < 1/√2. Three classes of such objects escape every proven bound. **None contains a known candidate.** One correction to `SQRTLOG_BARRIER.md`: "App B is optimal among power profiles" holds only with windows W, H ≥ 2h.

## 1. Exact objective

**Def. 7 ([A] p.27).** Fix a real ½ ≤ ρ < 1 and an integer c ≥ 1. For **every** λ ≥ 1 there are an integer d ≥ 1, a finite set I ⊂ ℤ and functions A_i : ({0,1}^λ)^4 → ℤ with:
- **(a)** Σ_{i∈I} A_i = d·[x=v][y=u].
- **(b)** A_i factors through c_i^row bits across (x,y)|(u,v) and through c_i^col bits across (x,u)|(y,v). Def. 1 (p.14) asks for integer factors and inner dimension 2^c, so c ≥ ⌈log₂ rank_ℚ⌉. **For every i: c_i^row + c_i^col ≤ 4ρλ + c·log(2λ).**
- **(c)** |I| ≤ (2λ)^c. All of d, I, the A_i and the factor values are below 2^{(2λ)^c}. One algorithm computes them, together with I, c^row and c^col, within 2^{cλ} operations.
- WLOG c^row, c^col ≤ 2λ, at the price c → c+2 (p.27).

**Only large λ matters (our derivation).** The trivial factorization (2λ + 2λ bits) meets (b) whenever c·log(2λ) ≥ 4(1−ρ)λ. Finitely many λ are therefore free, and ρ is effectively limsup_λ max_i (c^row_i + c^col_i)/4λ.

**Rate theorem: Theorem A (pp.28–29), α′ = log₂(1/ρ).**
- The recursion (40) is K_{ℓ+1} = (2^{3ℓ+x₀}K_ℓ)² and e_{ℓ+1} = (ρ+3ζ_ℓ)e_ℓ + 3/K_ℓ.
- ρ enters only through (41): U = min(U_row, U_col) ≤ N(ρ + 1/g) + (c/4)g⁴·log(2λ), using min ≤ average per rectangle. Lemma 8(ii) is then applied.
- The conclusions are:
  - (a) ½ρ^ℓ ≤ e_ℓ ≤ 0.85ρ^ℓ;
  - (c) #k-SAT in time 2^{O(km/(log m)^{α′})};
  - (d) 3-SAT in time 2^{O(n/(log n)^{α′/10})}.

## 2. Lean: parametric for counting; the last mile to E^NP is missing

- **Def. 7 in Lean.** `AppRunningTime.IsPieces ρ c P A val` (`statements/AppRunningTimeStatement.lean:49`) is Def. 7 with programs `PiecesF`, clause by clause (`rho_ge`, `sum`, `row`, `col`, `caps`, `card`, `size_*`). Its time clauses use `PolyT`/`Unary` with a pad of 2^{cλ}. `Exist ρ c := ∃ P A val, IsPieces ρ c P A val` (:87).
- **The rate theorem.** `GeneralPieces.thmRunningTime_c_m : ∀ ρ c, AppRunningTime.Exist ρ c → SatM.CountInRate (SatM.rPow (AppRunningTime.alpha' ρ))`. I checked it with `#check` and `#print axioms` (`Ax.lean`); the only axioms are propext, Classical.choice and Quot.sound.
  Here `alpha' ρ = logb 2 (1/ρ)`, `rPow α m = 1/(log₂(m+2))^α`, and `CountInRate r` means one TM2 machine counts #k-SAT within ⌊C·2^{C·k·m·r(m)}⌋ steps.
- **Generic front end.** `DefGenPieces.of_par_realizes` (`rates/GeneralPieces/DefGenPieces/Conv.lean:70`) turns programs satisfying `Par`/`Keeps`/`Realizes` into `IsPieces`.
- **Transfer.** `Superlinear.generalTransfer : ∀ r, RateOK r → DecidesClauseRate r → E^NP ⊄ i.o.-SIZE(⌊ε(n+1)/r(n)⌋)`; its axioms are clean.
- **Missing (from a grep of `superlinear/`).**
  - `rateOK_rPow` (`General.lean:116`) is proved for α = ½ only.
  - `decidesClauseRate_rPow` (:142) is also α = ½ only. It goes through `RecursionWithPieces.tiedAllCal.decides`, which is tied to the App-B pieces (`IsPiecesB`).
  - There is no generic `CountInRate r → DecidesClauseRate r`. The two bounds agree at k = 3.
- **What a machine-checked E^NP ⊄ i.o.-SIZE(ε·n·(log n)^{α′}) needs.**
  1. `Exist ρ c` for the new pieces: programs, PolyT proofs, the identity, the factorizations, and `caps` for all λ.
  2. `RateOK (rPow α)` for 0 < α ≤ 1. This is routine, from ln(1+x) ≥ x/(1+x).
  3. Count-to-decide glue: either a TM post-composition with "count ≠ 0", or `TiedAt` generalized to any `IsPieces`.

  Items 2 and 3 are engineering (conjecture). Item 1 is the problem itself.

## 3. Certificate format

1. **(F1) An infinite family with closed-form bounds**, like App B's (56). Checked by proof, or in Lean as §2 item 1. A computation at a fixed λ certifies nothing (§1).
2. **(F2) A finite block identity, powered** (our derivation, generalizing Lemma 2 / Def. 5).
   - **Identity:** Σ_{j∈J} B_j = D·cross on b-bit strings, with explicit integer factorizations of total cost a_j = c_j^row + c_j^col.
   - **Powering:** take λ = tb and group terms by type n ∈ ℕ^J (poly(t) pieces). Naming the positions costs log multinomial(t; n) bits per direction. This gives Def. 7 with **ρ ≤ max_p [2H(p) + Σ p_j a_j]/(4b) ≤ (max_j a_j + 2 log|J|)/(4b)**.
   - **Sanity check:** eight squares (b = 3, a = 9, |J| = 2) give 11/12, which is Lemma 2's value ([A] App H p.47).
   - **Checking:** exact arithmetic on 2^{4b} entries. Bit lengths stay polynomial because the factors are products of per-block factors.
   - **Necessary conditions (our derivation).**
     - Pigeonhole ([M] Prop 4.6) gives some a_j ≥ 2b − log|J|.
     - Splitting each B_j into rank-one terms in its cheaper direction gives Σ_j 2^{min(c_j^row, c_j^col)} ≥ P(N) ≥ s ≥ N. Here P(N) is the least number of terms of row- or column-rank 1 summing to the crossing, s the least number of products in a sum-of-squares identity; [A] App G p.46 quotes P(N) ≥ s from [HWY11], and App H p.47 quotes s ≥ N.
     - Hence **two-piece identities have ρ ≥ ¾ − O(1/b)**. F2 needs at least 3 pieces, at least one of them with both costs ≳ b.

**Correction to the brief.** "Fixed-size identities give only 11/12 or ≈0.896" describes the *known* identities only ([A] App H pp.47–48):

| Identity | ρ | How counted |
|---|---|---|
| eight squares | 11/12 | naming count, certified (Lemma 2) |
| eight squares | ≈0.90 | rank count |
| four squares | 7.58/8 | rank count |
| single bit | log 12/4 ≈ 0.896 | rank count |

- **Rank counts are not shown to be Def.-7 certificates.** Def. 7(c) needs integer factorizations of polynomial bit length. Generic elimination gives entries of up to ≈2^{2λ} bits (our derivation). [A] App G p.46 says the same of Hrubeš's ≈0.905.
- **No theorem stops a finite identity from beating 1/√2.** Finite App-B instances do not do it: ρ_B(λ) falls to 1/√2 from above (0.756 at λ = 20, 0.715 at λ = 200). So graded families reach 1/√2 *only in the limit*.

## 4. Exclusion map (re-checked line by line)

| Result | Hypotheses | Conclusion | Check |
|---|---|---|---|
| **Prop 4.6, 4.8** ([M] p.37) | 4.6: any identity with \|I\| pieces. 4.8: C meets 2 groups of each of 2 merges; fractions θ and 1−θ of the blocks take the 4.6 pieces for S₁ and S₂. If m = λ, the fractions are taken over the configurations of a type (homogeneity). | 4.6: some piece has log-rank ≥ rm − log\|I\|. 4.8: the mixed term pays ≥ θr₁ and ≥ (1−θ)r₂, so the rectangle gives ρ ≥ ½. | Correct. The ρ here is the **per-merge fraction paid by a mixed term**. For Def. 7's per-piece sum, ½ is simply Prop 4.6 plus c^col ≥ 0 ([A] p.48), and it is built into Lean (`rho_ge`). |
| **Thm 4.13** (p.41) | (i) Only a×b grid levels: rows and columns are the merges; configurations are row edges, column edges and rectangles. (ii) Per-block identities with λ/m → ∞; the single-block case is Cor 4.19 (p.44), loss < 10⁻²¹. (iii) Cost model (L5): a term costs at least the solution of its merged instance, which depends only on its weights. (iv) Base exponent ≥ 1/log₂n. | f(ab) ≤ f(a) + f(b), so **α′ ≤ 1** | Re-derived: equalizing gives x₁x₂/(x₁+x₂) because i₁+i₂+t = 1; the boundary case uses concavity of log. Correct. **Model-internal**: it binds this class of algorithms, not machines. Independent of ρ. |
| **Prop 4.24** (p.48) | (S1) Graded V, D(E) = log₂ dim V_{≤E}, D(h) ≥ λ. (S2) A_s factors through V_{≤s+H} row-wise and through V_{≤W−s} column-wise. This is a rank upper bound, used only in the pigeonhole step D(W+H) ≥ 2λ − o(λ). (S3) **Counted** bits ≥ D(window) − o(λ); this constrains the factorization, not the rank. (S4) D concave on [h, W+H]. (S5) (W+H)/2 ≥ µh. (S6) log\|I\| = o(λ). | ρ_B ≥ ½(1 + (µ−1)/(2µ−1)); µ = 2 gives 2/3 | Correct. It uses only the symmetric piece s*, so a min(row, col) refinement of Def. 7 is no escape either. |

**Prop 4.24's remarks, checked numerically (`profiles.out`; our derivation).**
1. **Power profile D = cE^a.**
   - With W, H ≥ 2h: ρ ≥ max(2^{a−1}, 2^{−a}) ≥ 1/√2. Correct.
   - With free windows, pigeonhole gives only **ρ ≥ 2^{−a}**, attained at µ = 2^{1/a−1}: 0.595 for a = ¾ and ½ for a = 1.
   - At a = ½, pigeonhole forces µ ≥ 2, so **for the partition profile no choice of windows helps**.
   - This corrects `SQRTLOG_BARRIER.md` Q3: "α′ ≤ ½ for power profiles" needs W, H ≥ 2h; otherwise the ceiling is α′ ≤ a. The 2^{−a} branch is the case a < ½, where pigeonhole forces windows above 2h.
2. **"H = h gives 5/8"** (µ = 3/2). This is a **floor**. At the counting level it is attained only by a D that is affine on [h, 3h]; the script gives exactly 0.625. A power profile needs a ≥ log₃2 for this, and its best value is 0.6458. With the partition profile (√3 < 2), H = h is impossible.
3. **What forces 2h.** It is not a hypothesis of Prop 4.24, where µ is free. It comes from App B's construction:
   - (48) has 2h+1 products with weights C(H, i), where H = wt a + wt b (Lemma 9 proof, p.30; App H p.49);
   - the labels have weight h (Lemma 10).
   - (Conjecture.) In vertex-algebra constructions the scalar a[−h]b is the vacuum term, at pole order wt a + wt b. So µ < 2 needs labels from a space other than the states.

## 5. Escape list (ranked by "Theorem A and the Lean chain apply unchanged")

| # | Class | Hypothesis violated | What must be achieved | Plausibility |
|---|---|---|---|---|
| 1 | App-B shape with **µ < 2, a > ½** | App B's window 2h | (2µ)^a ≥ 2 and µ^a < √2 (e.g. a = ¾, µ ∈ [1.26, 1.59)). Needs analogues of Lemmas 9 and 10, labels cheaper than states, and a state profile steeper than √E. A steeper profile at µ = 2 alone is worse (2^{a−1}). | Low. Steep profiles lose the two-order factorization (fermions: ρ → 1, [M] p.48). Modular characters give log dim ~ C√E (conjecture, Cardy), so the algebra must be non-modular. |
| 2 | **Kinked profile**, µ = 2 | (S4) or power form | Concave case: D(2h)/D(h) ∈ [4/3, √2) together with D(4h) ≥ 2λ, giving ρ ∈ [2/3, 1/√2). A step profile reaches ½, but that just restates ideal pieces. | Low. [M] knows no such algebra (p.48). |
| 3 | **Def.-7 pieces outside the shape**: arbitrary 4-leg families, F2 identities, rank far below counted bits | (S1)–(S3) | max_i(c^row + c^col) < 2.83λ. Constrained only by Prop 4.6, the P(N) condition and Prop 4.22 (third split). This is [M] Open problem 1 (p.50). | Unknown. Our App-B rank check was negative. Search is infeasible at b ≳ 8. |
| 4 | **≥ 3 merges / hyperedge pieces** | (L3), grid | Needs a new Theorem A; the Lean is not parametric here | The floors are only argued ([M] §4.8) |
| 5 | **Non-grid; OpenAI App D** | grid / [M]'s class | Non-grid two-merge levels are still capped by Thm 4.12 (α′ ≤ 3, p.40). App D is another mechanism. | Off-target for ρ |

**Bottom line.** Classes 1–3 escape every proven bound. Prop 4.24 is the only √log-specific result, and Thm 4.13 caps α′ at 1. No candidate object is known. **Recommendation:** end the attempt here, unless someone supplies either a graded algebra with non-modular growth and a two-order factorization (classes 1–2), or an F2 identity (class 3).
