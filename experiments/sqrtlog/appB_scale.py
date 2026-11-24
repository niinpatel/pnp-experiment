"""Scalable rank computation for the App. B pieces, straight from the paper's factorizations
(54) (row split) and (55) (column split): rank(A_s) = rank(F G^T) with F, G the explicit factors.
Usage: python3 appB_scale.py test            # cross-checks vs the direct tensor for h<=5
       python3 appB_scale.py run H1 H2 [S]   # h in [H1,H2], s in [-S,S] (default all s)
"""
import sys, time, itertools, math
import flint
import appB_ranks as m
from appB_ranks import partitions, p, a_angle, op, PRIMES


def factor_mats_col(h, s, P, A, B):
    """(55): A_s[(x,u),(y,v)] = sum_{(i,sigma), |sigma|=2h-s-i} F'[(x,u),(i,sigma)] G'[(y,v),(i,sigma)],
    F' = (-1)^i [t^{mu(u)}] a<i>[s-h+i] t^sigma,  G' = [t^sigma] b[h-s-i] t^{mu(y)}."""
    N = len(P)
    idx = {mu: j for j, mu in enumerate(P)}
    cols = [(i, sg) for i in range(2 * h + 1) if 2 * h - s - i >= 0 for sg in partitions(2 * h - s - i)]
    cidx = {c: j for j, c in enumerate(cols)}
    F = [[0] * len(cols) for _ in range(N * N)]
    G = [[0] * len(cols) for _ in range(N * N)]
    for i in range(2 * h + 1):
        w = 2 * h - s - i
        if w < 0:
            continue
        for xi, mx in enumerate(P):
            ai = a_angle(A[mx], h, i)
            for sg in partitions(w):
                for mm, c in op(ai, s - h + i, {sg: 1}).items():
                    if mm in idx:
                        F[xi * N + idx[mm]][cidx[(i, sg)]] = (-1) ** i * c
        for vi, mv in enumerate(P):
            for yi, my in enumerate(P):
                for mm, c in op(B[mv], h - s - i, {my: 1}).items():
                    G[yi * N + vi][cidx[(i, mm)]] = c
    return F, G


def rank_of_product(F, G, exact=False):
    if not F or not F[0]:
        return 0
    if exact:
        return (flint.fmpz_mat(F) * flint.fmpz_mat(G).transpose()).rank()
    rs = [(flint.nmod_mat(F, pr) * flint.nmod_mat(G, pr).transpose()).rank() for pr in PRIMES]
    assert rs[0] == rs[1], rs
    return rs[0]


def run_scalable(h, s_list, exact=False, crosscheck=False):
    P = partitions(h)
    N = len(P)
    A = {mu: m.a_mu(mu) for mu in P}
    B = {mu: m.b_mu(mu, h) for mu in P}
    if crosscheck:
        _, T = m.pieces_fast(h)
    out = []
    for s in s_list:
        t0 = time.time()
        Fr, Gr = m.factor_mats(h, s, P, A, B)
        Fc, Gc = factor_mats_col(h, s, P, A, B)
        if crosscheck:  # tensor from (55) must equal tensor from (54): Lemma 9(a)
            Mc = (flint.fmpz_mat(Fc) * flint.fmpz_mat(Gc).transpose()).tolist() if Fc[0] else None
            for x, y, u, v in itertools.product(range(N), repeat=4):
                val = int(Mc[x * N + u][y * N + v]) if Mc else 0
                assert val == T[s][x][y][u][v], ("(55) != (54)", h, s)
        rr = rank_of_product(Fr, Gr, exact)
        rc = rank_of_product(Fc, Gc, exact)
        if exact:
            assert rr == rank_of_product(Fr, Gr) and rc == rank_of_product(Fc, Gc), "mod-p rank != exact rank"
        Rr = sum(p(s + i) for i in range(2 * h + 1))
        Rc = sum(p(2 * h - s - i) for i in range(2 * h + 1))
        out.append((s, Rr, rr, Rc, rc, time.time() - t0))
    return N, out


def report(h, N, out):
    lam = math.log2(N)
    cap = N * N
    print(f"h={h} N=p(h)={N} lambda=log2 N={lam:.3f} (full rank N^2={cap})")
    print("    s |  R_row  min(R,N^2) rank_row |  R_col  min(R,N^2) rank_col | counted_bits true_bits | sec")
    wc = wt = 0.0
    for s, Rr, rr, Rc, rc, dt in out:
        cb = math.log2(min(Rr, cap)) + math.log2(min(Rc, cap))
        tb = math.log2(max(rr, 1)) + math.log2(max(rc, 1))
        wc, wt = max(wc, cb), max(wt, tb)
        print(f"  {s:3d} | {Rr:6d} {min(Rr,cap):6d} {rr:6d} | {Rc:6d} {min(Rc,cap):6d} {rc:6d} | {cb:8.3f} {tb:8.3f} | {dt:6.1f}")
    print(f"  worst piece: counted {wc:.3f} bits (rho_counted={wc/(4*lam):.4f}), "
          f"true {wt:.3f} bits (rho_rank={wt/(4*lam):.4f})", flush=True)


if __name__ == "__main__":
    if sys.argv[1] == "test":
        for h in (2, 3, 4, 5):
            N, out = run_scalable(h, range(-2 * h, 2 * h + 1), exact=True, crosscheck=True)
            _, res, _ = m.run_appB(h)
            assert [(o[0], o[2], o[4]) for o in out] == [(r[0], r[2], r[4]) for r in res], h
            print(f"h={h}: factorized ranks == direct-tensor ranks; (55)==(54); exact==mod p: OK", flush=True)
    elif sys.argv[1] == "srange":  # srange H S1 S2 : one h, s in [S1, S2]
        h, s1, s2 = map(int, sys.argv[2:5])
        N, out = run_scalable(h, range(s1, s2 + 1), exact=(h <= 6))
        report(h, N, out)
    else:
        h1, h2 = int(sys.argv[2]), int(sys.argv[3])
        for h in range(h1, h2 + 1):
            S = int(sys.argv[4]) if len(sys.argv) > 4 else 2 * h
            N, out = run_scalable(h, range(-S, S + 1), exact=(h <= 6))
            report(h, N, out)
