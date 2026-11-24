# STAGE 2 referee report

This report checks two claims in `STAGE2_GRADED.md` against [A] (App. B pp.30–33, App. H pp.48–49) and [M] Prop 4.24 (`/mnt/data/rho/dl/maj/m.txt` l.2605). Scripts and outputs are in `/mnt/data/rho/referee/`.

## Claim 1: Lemma V / Theorem G (class L)

**(a) Statement.** Assume:
- V is a ℤ≥0-graded vertex algebra and M is a V-module with lowest weight 0;
- H ≥ the locality order of every pair (a_x, b_v) on M;
- Q_s is the weight-preserving coefficient of (ω₁−ω₂)^H Y(a,ω₁)Y(b,ω₂);
- Σ_s Q_s(a_x,b_v) = d[x=v]·Id on all of M, with d ≠ 0.

Under these assumptions, **Lemma V** says 2^λ ≤ (H+1)·dim M_{≤⌊H/2⌋}.

**Theorem G** adds three hypotheses:
- (i) the piece A_{s*} is present;
- (ii) the 2^λ dual-paired states lie in M_{≤h_y};
- (iii) every piece's counted bits are ≥ log dim(window) − o(λ).

It concludes ρ_counted ≥ D_M(h*_M+⌊H/2⌋)/(2λ) − o(1).

**(b) Steps.**
- Tops on M_E are E+r₀ and E−r₀+H, summing to 2E+H. On M₀ there are H+1 terms, each with min(top) ≤ ⌊H/2⌋. Rank subadditivity then gives **Lemma V, a correct rank bound**.
- App. B is in class L with H = 2h. Its labels a_µ(x) are inhomogeneous and (48) uses H = h′+h per component, but the tops do not depend on h′, so H_max works.
- Theorem G is correct arithmetic given (i)–(iii).

**(d) Gaps.**
- **G1. Counted ρ, not Def.-7 ρ.**
  - (iii) is App. B's accounting: (54)–(55) charge the dimension of the intermediate space. Def. 7 only needs log rank.
  - Nothing lower-bounds rank(A_{s*}). Lemma V bounds a different matrix, at M₀.
  - So "narrower windows are impossible" is proved, but "class-L pieces cannot beat 1/√2" is not. Tier 1's "(proved)" needs this qualifier.
- **G2. H must be poly(λ).**
  - The document's "H+1 ≤ |I|" argues the wrong way: the H+1 terms live on M₀, and pieces that vanish on the states can be dropped from I.
  - H ≤ 2^{o(λ)} must therefore be assumed. Otherwise the 2log(H+1) loss eats λ.
- **G0. Class L is narrower than the App.-B shape.** It is App. B plus a module-wide identity. Theorem B only uses Lemma 9(c) at E = h, and Def. 7 needs the identity only on the states. Lemma V evaluates at M₀, where no state lives, so tier 1 closes only this subclass. This is the load-bearing hypothesis.
- **G3. §4's sentence about zero modes is false.** It claims "a scalar on all of M must come from the vacuum term".
  - Counterexample: the Heisenberg Fock module π_μ with μ ≠ 0, where α₀ = μ·Id. This refutes the sentence, not the existence of pieces.
  - Lemma V never uses the vacuum, so ★ with η = h*_M stands. The vacuum branch and the (C3) multiplicity bullet do not cover such scalars.
  - Repair: the rank argument only sees the cyclic submodule V·w, so η = max_w h*_{V·w} holds with no vacuum hypothesis.
- **G4. ★ does not exclude the "Remaining" set.** If dim M₀ ≈ 2^λ (e.g. M = π_μ ⊗ U), then h*_M = 0 and ★ gives only ½. I constructed no labels for this case. The G3 repair removes the issue.
- **G5. Unstated:** one common H (or H_max).
- **(C1)/(C2)** use [M] 4.6 and 4.24. The 4.24 text matches.

**(e) Verdict: CORRECT WITH GAPS (G0–G5).** Lemma V is sound. Theorem G is sound for counted ρ under App.-B accounting. The §4 zero-mode sentence is false but repairable.

## Claim 2: Lemma L and ρ ≥ 1/√2 for product characters

**(a) Statement.** Let c_n ≥ 0 be nondecreasing, F(θ) = Σc_n f(θn) and S(E) = inf_{θ>0}(θE+F(θ)). Then:
- θF is nonincreasing;
- S(tE) ≥ √t·S(E) for t ≥ 1;
- S(E₁+E₂)² ≥ S(E₁)²+S(E₂)².

The claimed consequence is D(2h*) ≥ √2λ − o(λ), hence ρ ≥ 1/√2 − o(1).

**(b) Steps, checked by hand.**
- Step 1: each term is j^{−2}·x e^{−(w−1)x}/(e^x−1), decreasing for w ≥ 1. Correct.
- Steps 2–3 and Chernoff: correct.

**Lemma L is correct.** It has one hidden hypothesis, that F is finite somewhere. For c_n = 2^{n²} (admissible) S ≡ ∞, so the lemma says nothing.

**(c) The transfer is false.** The document conjectures ln dim V_{≤E} ≥ S(E) − o(λ) at E = 2h*, with the sketch "o(λ) whenever h* → ∞". Take c_n = N·[n≥w], i.e. N generators of weight w. This is nondecreasing and λ-dependent, which the summary explicitly covers.

At E = 2w−1 (h* = w → ∞) the gap S − D is 55, 114 and 233 bits at λ = 60, 120, 240, which defeats the sketch. With N ≈ 2^{λ+1}/w (h* ≈ 1.5w), the gap at E = 2h* itself is 46, 103 and 180 bits at λ = 60, 120, 200, i.e. 0.77λ to 0.90λ (`plateau.out`). That refutes the conjecture as stated. `legendre_check.py` never tests such plateaus.

**The conclusion is not refuted.**
- In that family D(2h*)/λ = 2.00.
- A random search over 1–3-step nondecreasing c_n with heights up to 2^{1.2λ} (700 draws at λ = 60 and 100, skipping those with 4h* > 600, exact counts) gave a minimum D(2h*)/λ of 1.48 and 1.50. Nothing fell below √2.

**(d) Coverage.**
- "Strongly freely generated ⇒ c_n nondecreasing" is correct. The (C3) bullet states ρ ≥ 1/√2 − o(1) without the "conditional" caveat that the Bottom line carries.
- The multiplicity bullet also depends on G3.

**(e) Verdict: CORRECT WITH GAPS.**
- Lemma L is CORRECT once F < ∞ is added.
- ρ ≥ 1/√2 − o(1) for product characters is **unproven**. Its stated bridge is **incorrect** for λ-dependent c_n, where there is an Ω(λ) gap at 2h*.
- The exact-count claim survives every test, but it needs another proof: either a direct combinatorial bound on counts, or a transfer restricted to λ-independent c_n.
- Tier 2's "closed … at any λ-dependent rank" should be downgraded to a conjecture.
