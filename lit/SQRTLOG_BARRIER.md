> **Note (orchestrator):** the "0.9 / singlet / 12^λ" figures in the brief came from the condensed description in the README of `anthropics/formal-math/eth`, not from the paper. The paper's own main-text constants are ρ = 11/12 and K ↦ 9K^16. I spot-checked both against the paper text, along with the Hardy–Ramanujan origin. This note was written by a research subagent. Every claim is tied to a page or section of a primary source, or labelled as our derivation or as a conjecture.

# Where the 1/2 in 2^{O(m/√log m)} comes from, and whether it can be raised

Sources: **[A]** Anthropic, *A 2^{o(n)} Time Algorithm for 3-SAT* (Oct 26 2026); **[O]** OpenAI, *The ETH is False* (rev. Oct 25 2026); **[M]** Majdoddin, arXiv:2610.41622v1; **[DL]** Dias–Lima, arXiv:2611.00517v1. Printed page numbers. Script/output: `experiments/sqrtlog/recursion.py`, `recursion.out`.

**Correction to the brief.** The brief's recursion (ρ ≈ 0.9, K ↦ 9K^16) does *not* give √log m; it gives α' = log₂(1/0.9)/4 ≈ 0.038 (below). The extracted text of [A] contains no "0.9", "SWAP = I − 2·singlet" or "12^λ". The main-text recursion is e_ℓ = (11/12 + 2/K)e_{ℓ−1} + 5/K, K_ℓ = 9K_{ℓ−1}^16, K_0 = 64 ([A] (9), p.8). The rate in m uses Theorem A (40) with Appendix B pieces, ρ = 1/√2 ([A] pp.28, 30). A single-bit identity rank-counted at log 12 ≈ 3.58 of 4 bits (ρ ≈ 0.896) is only a remark in App. H (pp.47–48).

## Q1. Anthropic: where the exponent 1/2 arises

**What the source says.** Theorem A ([A] p.28) takes any pieces (Def. 7, p.27: signed decompositions of the crossing with c_row + c_col ≤ 4ρλ + c·log(2λ)) and runs:

- K_{ℓ+1} = g_ℓ², with g_ℓ = 2^{3ℓ+x_0}·K_ℓ.
- e_{ℓ+1} = (ρ + 3ζ_ℓ)·e_ℓ + 3/K_ℓ, with ζ_ℓ = 2^{−ℓ−5}.

It proves log K_ℓ = (3x_0+6)·2^ℓ − O(ℓ) and ½ρ^ℓ ≤ e_ℓ ≤ 0.85ρ^ℓ, so e = O((log K)^{−α'}) with **α' = log₂(1/ρ)**. The top level uses the largest ℓ with K_ℓ ≤ m^{1/9}, so K ≥ m^{1/90}; the cost is 2^{2ekm + O(km^{1−1/90})} (proof of Thm A(c), eq. (45), p.29). §2.7 (p.13) says so directly: "one level squares K ... log K = Θ(2^ℓ)".

**General formula (our derivation).** Suppose:

- log K_{ℓ+1} = β·log K_ℓ + O(ℓ),
- e_{ℓ+1} = ρ_ℓ·e_ℓ + δ(K_ℓ), with ρ_ℓ → ρ summably (as ρ + 3ζ_ℓ does),
- δ(K) = o((log K)^{−α'}).

Then e_ℓ = Θ(ρ^ℓ) and log K_ℓ = Θ(β^ℓ), so

  **e(K) = Θ((log K)^{−α'}), α' = log(1/ρ)/log β, and the running time is 2^{O(k·m/(log m)^{α'})}.**

With β = 2 and ρ = 1/√2 this gives α' = ½. The script reproduces Thm A(a), the p.29 thresholds (log m > 8000, > 1.3·10^5), e₁ ≈ 1.026 and (11) (p.8), and §2.7's α ≈ 0.03, 0.125, ½.

**What each parameter does to α' (script sweep, our derivation).**

- **ρ** is the only lever with β fixed: ρ = 2/3 gives α' = 0.585, ρ = 5/8 gives 0.678, ρ = ½ gives 1.
- **β:** β = 16 cuts α' by 4 (main text). [A] already reaches β = 2 up to polylog factors (Hoeffding balancing, Lemma 8, p.27). For App. B pieces grid shape is no lever (our derivation, heuristic: diagonals dominate; a uniform shift σ = s/h is the worst term by concavity). On an a×b grid, row/column fractions √(2±σ)/2 and equalising e(a)√(2+σ) = e(b)√(2−σ) give **1/e(ab)² = 1/e(a)² + 1/e(b)²** (script: to 5·10^{−6}), so e = Θ((log K)^{−1/2}) for every shape. This parallels [M] Thm 4.13's additive 1/e for ideal pieces: App. B's tradeoff curve is a quarter-circle, the ideal one a line.
- **Additive term:** 3/K, 1/K² and 1/√K leave α' unchanged, because K is doubly exponential in ℓ. Even δ = 1/log K is inert unless α' ≥ 1.
- **Overheads, K ≤ m^{1/9}:** constants only, since log K = Θ(log m) either way ((45), p.29).

**Conclusion (our derivation).** No balancing of costs produces the 1/2: it is log₂(1/ρ) at ρ = 1/√2 with K squared per level, and ρ = 1/√2 = 2^{a−1} with a = ½, the Hardy–Ramanujan exponent in log p(E) ≈ c√E ([A] App. H, (77), p.49: "if it grew like E^a ... ρ = 2^{a−1}"). From actual partition numbers, counted ρ_B falls 0.756 → 0.715 for λ = 20 → 200 (slowly to 0.7071).

## Q2. OpenAI: where (log n)^{1/2+o(1)} comes from

**Interpolation route ([O] §2.6–2.7, pp.12–17).** Cost 2^{O(n[(R/Q)·log(Q/R) + τ·log D + 1/r])} ((2.11)–(2.12), p.13). The interval must cover the bulk of Bin(Q, p), so R ≫ √Q (p.16; tail condition 2e^{−R²/8Q} ≤ τ/3r). Q is capped because D = r^{2Q} ≤ (2n)^{1/128} ((2.10), p.12), so Q ≈ log n/log r. The Taylor term R/Q ≈ √(log r/log n), balanced against 1/r, gives n(log log n)²/√log n (our reading). The 1/2 is a central-limit width.

**Tensor contraction route ([O] App. D, pp.53–63; the headline n/√log n).**

- The mode-monomial count is exp(O(√(M·p_t/D))) = exp(O(M/√u)) ((D.13)–(D.15), p.62), bounded via the coloured-partition generating function ∏(1−e^{−θj})^{−6M/D}: a Hardy–Ramanujan-type count.
- u = ελ/2^d, λ = ⌈log₂ s⌉ ((D.4)–(D.5), p.58). Our reading of why it cannot be larger: L = 2^a and D_arr = r^{2a} must stay ≤ s^{1/1000}, with a = 2Σu_j.
- Σ_d M_d/√u_d is geometric and root-dominated (p.53).
- **Our observation:** both papers' 1/2 rests on a Hardy–Ramanujan-type √, by different mechanisms. In [O] App. D it is a direct count at scale log s; in [A] it enters through ρ = 2^{a−1} and the level count.

## Q3. Do the model limits cover the algorithms, and do they mention √log?

**[M] (Majdoddin; its theorems are taken at face value, not re-checked).**

- **Coverage.** The rewrite-and-merge class (Def. 4.2, p.35) contains [A]'s level (Remark 4.3, p.36). Cor. 4.19 (p.44) covers the recursion as written (one block per string, Thm A's g_ℓ) up to a factor 1 − 8.5·10^{−22}.
- **Main barrier (Thm 4.13, p.41).** Every grid algorithm has e(K) ≥ 1/log₂K: **α' ≤ 1**, not ½. On α' = ½: "no lower bound of this form is proved for them" (p.42). This caps α' = log(1/ρ)/log β; it does not ban β < 2. "Squaring is forced" (p.34) is [M]'s sentence; its "structured merged tables" paragraph (p.47) is labelled *argued*.
- **Non-grid balanced homogeneous two-merge levels.** Thm 4.12 (p.40) gives 1/e ≤ (log₂K)³ (α' ≤ 3). This is what excludes 2^{n^{1−c}}; [M] calls the exponent 3 "an artefact of the proof".
- **Two-merge floor (Prop 4.8, p.37):** ρ ≥ ½.
- **The only √log-specific statement is Prop 4.24 (p.48, proved),** for pieces "in the shape of App. B" (graded space, profile D(E) = log dim V_{≤E}, windows W = H = 2h):
  - any concave profile gives ρ ≥ 2/3;
  - a power profile D = cE^a gives ρ ≥ max(2^{a−1}, 2^{−a}) ≥ 1/√2, with equality only at a = ½, so **App. B is optimal among power profiles**. The 2^{−a} branch comes from the pigeonhole need for some piece of full rank 2^{2λ} (D(4h) ≥ 2λ);
  - a window H = h would give 5/8; going below 1/√2 needs a "kinked profile ... we know no such algebra".
- **As ceilings (our derivation):** α' ≤ ½ for App.-B shape with power profile, ≤ log₂(3/2) ≈ 0.585 with concave profile, ≤ 1 for all grid algorithms.
- **Status of ρ.** The window ρ ∈ [½, 1/√2) is open ([M] Open problem 1, p.50). §4.8 (p.49): d-dimensional grids with line merges are worse, and a success with three or more merges "would be a lever on ρ, i.e. on α′".

**[DL] (Dias–Lima).** The limits (2^{Ω(√tw)} etc.) cover only [O]'s clause-product scheme; the parity form and App. D "escape" hypotheses (H2), (H3) ([DL] §5.1, p.10; §9, p.13). Nothing on the √log exponent. [O] App. D is also outside [M]'s class (Remark 4.3).

**Net.** No proven barrier at √log m exists for either algorithm. The proven ceiling for [A]-type grid recursions is log m (α' ≤ 1).

## Q4. Cheap ideas for raising the rate

**What does not help.** None of the Q1 levers other than ρ (additive term, overheads, size of K, balancing constants, grid shape) moves α' (our derivation and script). The script's β = 1.5 rows are hypothetical.

**Conjecture 1 (open existence question).** There are pieces in the sense of [A] Def. 7 with ρ < 1/√2, with integer factorizations of polynomial bit length computable within 2^{cλ}. *If* so, Thm A(c), stated for arbitrary (ρ, c), gives #k-SAT in 2^{O(km/(log m)^{log₂(1/ρ)})}. Our Lean transfer theorem then gives E^NP ⊄ SIZE(ε·n·(log n)^{log₂(1/ρ)}). ρ = 2/3 would give the exponent 0.585; ideal pieces (ρ = ½) would give n·log n, which Thm 4.13 shows no grid construction can exceed.

**Conjecture 2 (checkable, not checked).** Prop 4.24 bounds *counted bits* (log dim of the space a piece passes through); its proof uses rank only in the pigeonhole step. For the eight-square pieces, the rank count beats the bit count (10.81 vs 11 of 12 bits; [A] App. H, p.47).

- **Open question:** do the true row and column ranks of the App. B pieces A_s give an effective ρ_rank < 1/√2?
- **Concrete check:** implement Q_s(a_µ, b_µ) from [A] App. B (Lemmas 9–10) at small h, compute ranks exactly, and compare log rank_row + log rank_col with D(s+2h) + D(2h−s).
- **Caveats:** small h is dominated by o(λ) terms; ranks need integer factorizations of polynomial bit length ([A] App. G, p.46). Not implemented.

**Bottom line.** Raising the 1/2 in [A]'s framework needs a cheaper crossing decomposition (ρ < 1/√2; [M] Open problem 1), not parameter tuning.
