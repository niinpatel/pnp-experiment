# Report of the computational probe (subagent of the review session, 2026-11-24)

Verbatim return value of the subagent. It is a working report, not a refereed result. The
reviewer's independent re-check of part of it is `recheck.py` / `recheck.out`; what was and was
not re-checked is stated in `REVIEW.md` §8. The scripts in `probe/` are the subagent's, with paths
that point to `/mnt/data/review/abelian/`; its large data files were not copied.

## Outcome

Reduction confirmed exactly at t=1,2. N(2)=4 (exhaustive, exact). N(3) is 7 or 8: r<=6 rigorously excluded (computer-assisted), r=7 not found in 153,756 local-search restarts. b=4: r=15 not found in 76 restarts (weak). Nothing below 2^b for b<=4.

## Details

Conventions: point x=(a,b), a = high b bits, b = low b bits; piece = coef*(-1)^{popcount(l&x)}*1[x in offset+span(basis)]; f=(-1)^{a.b}. All work is in /mnt/data/review/abelian/.

(0) REDUCTION, confirmed (task0.out; exact integer ranks via flint).
- A = sum_q g(q)|Phi_q><Phi_q|, |Phi_q> = N^{-1/2}(X^a Z^b (x) I) sum_x|x,x>, q=(a,b).
- Row rank (rows (x,y), cols (u,v)) = |supp g|.
- Column rank (rows (x,u), cols (y,v)) = |supp ghat_s|, where ghat_s(p) = sum_q g(q)(-1)^{w(p,q)}, w((a,b),(a',b')) = a.b'+a'.b. This is the ordinary WHT with the two halves swapped: ghat_s(a,b) = WHT(g)(b,a). No extra signs when the real Paulis X^aZ^b are used.
- A = N^{-2} sum_p ghat_s(p) (X^aZ^b)(x)(X^aZ^b). The crossing corresponds to g=(-1)^{a.b}, with ghat_s = N*g.
- Tested on 1350 operators at t=1 and 684 at t=2 (random supports of every size, plus combinations of 1-3 flat pieces); all identities hold.
- Integer factorizations in the sense of [A] Def. 1 (eth-raw.txt l.900: integer product with inner dimension 2^c): N*A = sum_q g(q) v_q v_q^T with v_q in {0,+-1}, and N^2*A realigned = sum_p ghat_s(p) vec(R_p)vec(R_p)^T. So the pieces need a scaling d = N^2.
- Single-bit scheme ([A] App. H): R=[x=u][y=v], C=-[x!=y](-1)^x[u!=v](-1)^u, R+C = crossing. Ranks of A_i: row = sum_{z>=i} C(t,z)3^{t-z}, column = sum_{z<=i} C(t,z)3^z, verified exactly for t=1..4. max_i (log row + log col)/(4t) = 0.8654, 0.8912, 0.8949 at t=40, 400, 2000, tending to log2(12)/4 = 0.89624.
- [A] contains no Bell/Pauli/Walsh wording (grep); the Bell-diagonal framing is the orchestrator's.

(1) N(2)=4 (task1.out; int64 Gram determinants, entries <=16).
- 1072 pieces (dims 0..4: 16, 240, 560, 240, 16). No single piece and none of 574,056 pairs spans f.
- All C(1072,3) = 204,746,640 triples: 18,880 dependent (covered by the pair check), 204,727,760 independent, none spans f.
- Certificate: f = 1 - 2*1[a1=b1=1] - 2*1[a2=b2=1] + 4*delta_1111 (N2_certificate.json).
- Extra: exactly 4705 four-subsets span f_2 (b2_all4.npy, exact re-check). Dimension profiles: (0,2,2,4) 1120; (0,2,3,3) 960; (1,1,2,4) 960; (1,1,3,3) 720; (1,2,2,3) 360; (0,3,3,3) 240; (1,1,1,4) 240; (2,2,2,2) 105.

(2) N(3). Count verified: 180,800 pieces (dims 0..6: 64, 4032, 41664, 89280, 41664, 4032, 64).
RIGOROUS (computer-assisted): N(3) >= 7.
- Lemma (hand argument): for each of the 1120 W = w+U, U = P^perp, P a plus-type hyperbolic plane, f|_W is +-character*f_2 and restricted flat pieces are flat or 0. So at least N(2)=4 pieces meet every W. The same holds for Fourier supports, since fhat = 8f (asserted in code). Supports cover G and Fourier supports cover the dual.
- r<=4: a proper support lies in an affine hyperplane disjoint from some W, so N(b) >= N(b-1)+1 (hand argument; machine check at b=3: every proper support misses >=20 W). With N(3)>=7 this gives N(b) >= b+4 for b>=3.
- r=5: exhaustive DFS, first piece = representative of the top-ranked of 23 symmetry orbits. Only 288 pairs have disjoint miss-sets and none extends to a triple. W-count alone suffices.
- r=6: DFS nodes by depth 2..6 = 2,489,785 / 1,880,011,759 / 5,163,355,529 / 987,793,754 / 0. No 6-set passes W-count plus cover (470 s, 30 cores). No leaf was reached, so the rank-mod-p leaf test never fired.
- Symmetry: 28 reflections, 6 twisted translations, Fourier. Each generator permutation maps all 176 known 8-solutions to solutions (6160 images; gens_check.out), and the miss count is constant on orbits.
- Code validation: the first DFS library matched brute force on 30 random mask instances. The final one returned 60/60 known 8-solutions at r=8, matched brute force on 6 sub-dictionaries (7 leaves), and its depth-2/3 node counts matched an independent numpy count for 2 representatives. Its brute-force comparison at r=5,6,7 was vacuous (0 leaves).
NOT FOUND: r=7.
- 79,500 random-start restarts (4 kicks each, 5.85M full-dictionary best-swap scans) and 74,256 seeded restarts (663 certified 8-solutions with one piece deleted, 14 seeds, 3 kicks).
- Minimum residual is exactly 8.0; 98.9% of restarts in the second random run end there.
- Calibration: the same search at r=8 reaches residual 0 in 176/192 and 663/750 restarts (exactly certified). At b=2 it matches the exhaustive result (r=4 found ~100%, r=3 minimum 4.0).
- Bias: found 8-solutions are mostly profile 3^8 (135/176).

(3) b=4 (full dictionary of 256*417,199 pieces scanned by WHT; weak evidence).
- r=16: 5 of 8 random restarts reach residual 0 (exactly certified, all profile 4^16).
- r=15: 60 random restarts (3 kicks) and 16 seeded (tensor products of b=2 solutions minus one piece): none. Minimum residual exactly 16.0 (50 of 60 random restarts end there).

(4) Proof or submultiplicativity.
- No proof of N(b)=2^b. The W-count method is inherently about linear: a b-dimensional piece misses only about a 3*2^-b fraction of the W.
- Evidence for 2^b: min dist^2(f, span of r pieces) = 4^b - r*2^b in every test. Exhaustive and exact at b=2 for r<=3 and at b=3 for r<=3 (375,913,117,098 triples, 0 violations, max captured exactly 24). Local search only for b=3 r=4..7 and b=4 r=15. Conjecture: r flat pieces capture at most r*2^b of |f|^2. This is Eckart-Young when all pieces are rank one in one Lagrangian matrix picture (f is a Hadamard matrix); open otherwise.
- N(b) is the CSS-stabilizer rank of (CZ|++>)^{(x)b}. Stabilizer ranks of magic states are submultiplicative and only linear lower bounds are known (from memory, unchecked), so submultiplicativity at large b cannot be excluded; there is no sign of it for b<=4.

EXTRA, relevant to follow-ups (my own derivations).
- N(b) = 2^{o(b)} would give rho -> 1/2. The criterion r < 2^{0.414b} is sufficient only.
- Union-bound exponent of "power a flat block identity, group by type": rho_U = (1/4b) log2 min_{v>0} [sum_x max_{j: x in A_j} v_j][sum_y max_{j: y in A*_j} 1/v_j]. It reproduces 0.89624 for the single-bit scheme and its tensor square.
- All 4705 minimal b=2 identities: rho_U >= 0.89624, with equality exactly for the 1120 of profile (0,2,2,4). Others: 0.9152, 0.9231, 0.9481, 0.9750, 1.0.
- Sampled only: 11,246 b=2 structures with up to 8 pieces (best 5-piece 0.9133); 663 random b=3 8-solutions (min 0.9308); 509 b=3 solutions forced to contain the constant and a point piece (min 0.9005). Nothing below 0.89624.
- Caveat: rho_U is an upper bound. Cancellation inside type groups occurs in some schemes; the gap was <=0.19 bits for t<=5 with no linear growth seen (type_check2.out). Exactness is not proven.
- For any Bell-diagonal piece g: <f,g>^2 <= sqrt(|supp g||supp ghat|)*|g|^2 (Hoelder twice). So pieces with cost exponent rho need squared norm at least 2^{2(1-rho)t}/m^2 times |f|^2: any rho<1 requires exponentially large cancelling pieces.

## Not done

- r=7 at b=3 is NOT rigorously excluded. The W-count DFS at r=7 was not attempted: I estimate at least 1e16 word-operations for depth 3->4 alone (days on 32 cores), more below. N(3)=8 is heuristic.
- b=4 rests on 76 restarts at r=15 against a 5/8 success rate at r=16. All 16-piece solutions found had profile 4^16, so the search is biased to fibration-like solutions.
- The residual pattern 4^b - r*2^b is exhaustive only for r<=3 at b=2 and b=3; elsewhere it is local-search only. The capture conjecture is unproven.
- The general-b lemma N(b) >= N(b-1)+1 is a hand argument, machine-checked only at b=3. The statement fhat = 8f and the W construction are asserted in code, not independently proved.
- The orchestrator's hand proof of N(2)=4 and the 0.77b counting bound were not seen or checked. The crude bound rho <= 1/2 + log2(r)/(2b) was re-derived by hand only.
- rho_U values are my union-bound formula. They were checked against true ranks only for the single-bit scheme (t<=4 exactly, plus the closed-form limit) and against brute-force group supports for 3 b=2 schemes at t<=5. Only the 4705 minimal b=2 identities are exhaustive; all larger schemes and all b=3 schemes are sampled. Non-flat Bell-diagonal block identities were not searched.
- In [A] I read only Def. 1, Def. 5/Lemma 2, Def. 7, the App. H single-bit passage and the App. B heading/Theorem B statement (rho = 1/sqrt2, O(lambda^2) pieces from polynomial-ring operators). I did not verify the 1/sqrt2 construction, whether App. B pieces are Bell-diagonal, or the pigeonhole floor 1/2.
- [M], [O] and [DL] were not consulted.
- The stabilizer-rank facts in (4) are from memory, not checked against a source.
- The first advisor call timed out; one later call was made and its three requests (wait for runs, validate generators, read Def. 1) were done.
