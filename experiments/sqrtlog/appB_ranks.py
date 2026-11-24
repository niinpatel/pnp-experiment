"""Conjecture 2 check: true flattening ranks of the Appendix B pieces of
Anthropic, "A 2^{o(n)} time algorithm for 3-SAT", App. B (pp.30-33), versus the counted
bounds R^row_s = sum_{i=0}^{2h} p(s+i), R^col_s = sum_{i=0}^{2h} p(2h-s-i) of (54)-(55).

Implementation follows the paper literally:
  V = Q[t1,t2,...], monomial t^mu <-> partition tuple (nonincreasing).
  nabla_{-k} f = t_k f, nabla_k f = k d f/d t_k.
  a[r] for monomial a = t^mu: recursion (O2):
     (t_n a')[r] = sum_{l>=n} C(l-1,n-1) nabla_{-l} a'[r-l] + sum_{k>=1} C(-k-1,n-1) a'[r+k] nabla_k,
     1[r] = [r=0] Id.
  a<i> = sum_{h'} C(h'+h, i) abar_{h'};  Q_s(a,b) = sum_{i=0}^{2h} (-1)^i a<i>[s-h+i] b[h-s-i]  (48)
  y_n = sum_{j=1}^n C(n,j) t_j, a_mu = prod_i (-1)^{mu_i-1} y_{mu_i}, b_mu = (h!/z_mu) t^mu  (Lemma 10)
  A_s(x,y,u,v) = [t^{mu(u)}] Q_s(a_{mu(x)}, b_{mu(v)}) t^{mu(y)}   (53)
Strings x,y,u,v range over ALL p(h) partitions of h (the paper uses the first 2^lambda of them;
restricting to a subset can only lower ranks).

Ranks: exact over Z (= over Q) with flint fmpz_mat for small sizes; for larger sizes rank modulo
two random 62-bit primes (rank mod p <= rank over Q always; equality unless p divides a
particular nonzero minor).  The paper's "factors through c bits" (Def. 1) is over Z, and the
least c with an integer factorization through 2^c terms is >= log2 rank_Q, with equality up to
rounding since a rational rank-r factorization can be scaled to an integer one (bit lengths aside).
"""
import sys, math, random, itertools, functools, time
from fractions import Fraction
import flint

sys.setrecursionlimit(10000)

# ---------------- partitions ----------------
@functools.lru_cache(None)
def partitions(n, maxpart=None):
    if maxpart is None:
        maxpart = n
    if n == 0:
        return [()]
    out = []
    for k in range(min(n, maxpart), 0, -1):
        for rest in partitions(n - k, k):
            out.append((k,) + rest)
    return out


def p(n):
    return len(partitions(n)) if n >= 0 else 0


def gbinom(k, j):
    """generalized binomial C(k, j) for integer k, j>=0; 0 for j<0."""
    if j < 0:
        return 0
    num = 1
    for t in range(j):
        num *= (k - t)
    return num // math.factorial(j)


def add_part(mu, k):
    return tuple(sorted(mu + (k,), reverse=True))


def remove_part(mu, k):
    l = list(mu)
    l.remove(k)
    return tuple(l)


def padd(acc, poly, c=1):
    for m, v in poly.items():
        nv = acc.get(m, 0) + c * v
        if nv:
            acc[m] = nv
        else:
            acc.pop(m, None)


@functools.lru_cache(None)
def mono_op(mu, r, sigma):
    """(t^mu)[r] applied to t^sigma, as dict partition->int. mu: tuple of parts (any order)."""
    E = sum(sigma)
    if E + r < 0:
        return {}
    if len(mu) == 0:
        return {sigma: 1} if r == 0 else {}
    n, rest = mu[0], tuple(sorted(mu[1:], reverse=True))
    out = {}
    # term 1: sum_{l>=n} C(l-1,n-1) t_l * rest[r-l] sigma ; needs E + r - l >= 0
    for l in range(n, E + r + 1):
        c = gbinom(l - 1, n - 1)
        if c == 0:
            continue
        inner = mono_op(rest, r - l, sigma)
        for m, v in inner.items():
            mm = add_part(m, l)
            out[mm] = out.get(mm, 0) + c * v
    # term 2: sum_{k>=1} C(-k-1,n-1) rest[r+k] nabla_k sigma
    for k in set(sigma):
        c = gbinom(-k - 1, n - 1)
        if c == 0:
            continue
        mult = sigma.count(k)
        inner = mono_op(rest, r + k, remove_part(sigma, k))
        for m, v in inner.items():
            out[m] = out.get(m, 0) + c * k * mult * v
    return {m: v for m, v in out.items() if v}


def op(a, r, f):
    """a[r] f for polynomials a, f (dicts)."""
    out = {}
    for ma, ca in a.items():
        for mf, cf in f.items():
            padd(out, mono_op(ma, r, mf), ca * cf)
    return out


def pmul(f, g):
    out = {}
    for m1, c1 in f.items():
        for m2, c2 in g.items():
            m = tuple(sorted(m1 + m2, reverse=True))
            out[m] = out.get(m, 0) + c1 * c2
    return {m: v for m, v in out.items() if v}


def y_poly(n):
    return {(j,): math.comb(n, j) for j in range(1, n + 1)}


def a_mu(mu):
    f = {(): 1}
    for part in mu:
        f = pmul(f, {m: (-1) ** (part - 1) * c for m, c in y_poly(part).items()})
    return f


def z_mu(mu):
    z = 1
    for k in set(mu):
        m = mu.count(k)
        z *= k ** m * math.factorial(m)
    return z


def b_mu(mu, h):
    return {mu: math.factorial(h) // z_mu(mu)}


def a_angle(a, h, i):
    return {m: math.comb(sum(m) + h, i) * c for m, c in a.items() if math.comb(sum(m) + h, i)}


# ---------------- pieces ----------------
def pieces(h, check=True):
    P = partitions(h)
    N = len(P)
    idx = {mu: j for j, mu in enumerate(P)}
    A = {mu: a_mu(mu) for mu in P}
    B = {mu: b_mu(mu, h) for mu in P}
    S = range(-2 * h, 2 * h + 1)
    # T[s][x][y][u][v]
    T = {s: [[[[0] * N for _ in range(N)] for _ in range(N)] for _ in range(N)] for s in S}
    for s in S:
        for xi, mx in enumerate(P):
            for vi, mv in enumerate(P):
                for yi, my in enumerate(P):
                    tot = {}
                    for i in range(2 * h + 1):
                        inner = op(B[mv], h - s - i, {my: 1})
                        if not inner:
                            continue
                        outer = op(a_angle(A[mx], h, i), s - h + i, inner)
                        padd(tot, outer, (-1) ** i)
                    for m, c in tot.items():
                        if m in idx:
                            T[s][xi][yi][idx[m]][vi] = c
    if check:
        hf = math.factorial(h)
        for x, y, u, v in itertools.product(range(N), repeat=4):
            tot = sum(T[s][x][y][u][v] for s in S)
            assert tot == hf * (x == v) * (y == u), ("sum identity fails", h, x, y, u, v, tot)
        # Lemma 9(a): exchanging factor order gives the same piece
        for s in S:
            for xi, mx in enumerate(P):
                for vi, mv in enumerate(P):
                    for yi, my in enumerate(P):
                        tot = {}
                        for i in range(2 * h + 1):
                            inner = op(a_angle(A[mx], h, i), s - h + i, {my: 1})
                            if inner:
                                padd(tot, op(B[mv], h - s - i, inner), (-1) ** i)
                        for ui, mu_ in enumerate(P):
                            assert tot.get(mu_, 0) == T[s][xi][yi][ui][vi], ("Lemma 9a fails", h, s)
    return P, T


def factor_mats(h, s, P, A, B):
    """Explicit factorization (54): A_s[(x,y),(u,v)] = sum_{(i,sigma)} F[(x,y),(i,sigma)] G[(u,v),(i,sigma)]
    with F = (-1)^i [t^sigma] a<i>[s-h+i] t^{mu(y)}, G = [t^{mu(u)}] b[h-s-i] t^sigma, |sigma| = s+i."""
    N = len(P)
    idx = {mu: j for j, mu in enumerate(P)}
    cols = [(i, sg) for i in range(2 * h + 1) if s + i >= 0 for sg in partitions(s + i)]
    cidx = {c: j for j, c in enumerate(cols)}
    F = [[0] * len(cols) for _ in range(N * N)]
    G = [[0] * len(cols) for _ in range(N * N)]
    for i in range(2 * h + 1):
        if s + i < 0:
            continue
        for xi, mx in enumerate(P):
            ai = a_angle(A[mx], h, i)
            for yi, my in enumerate(P):
                for m, c in op(ai, s - h + i, {my: 1}).items():
                    F[xi * N + yi][cidx[(i, m)]] = (-1) ** i * c
        for vi, mv in enumerate(P):
            for sg in partitions(s + i):
                for m, c in op(B[mv], h - s - i, {sg: 1}).items():
                    if m in idx:
                        G[idx[m] * N + vi][cidx[(i, sg)]] = c
    return F, G


def pieces_fast(h):
    P = partitions(h)
    N = len(P)
    A = {mu: a_mu(mu) for mu in P}
    B = {mu: b_mu(mu, h) for mu in P}
    T = {}
    for s in range(-2 * h, 2 * h + 1):
        F, G = factor_mats(h, s, P, A, B)
        if not F[0]:
            M = [[0] * (N * N) for _ in range(N * N)]
        else:
            M = (flint.fmpz_mat(F) * flint.fmpz_mat(G).transpose()).tolist()
        T[s] = [[[[int(M[x * N + y][u * N + v]) for v in range(N)] for u in range(N)]
                 for y in range(N)] for x in range(N)]
    hf = math.factorial(h)
    for x, y, u, v in itertools.product(range(N), repeat=4):
        assert sum(T[s][x][y][u][v] for s in T) == hf * (x == v) * (y == u), "sum identity fails"
    return P, T


def rank_exact(rows):
    if not rows or not rows[0]:
        return 0
    return flint.fmpz_mat(rows).rank()


PRIMES = [4611686018427387847, 4611686018427387817]  # 62-bit primes (checked below)


def rank_modp(rows, pr):
    return flint.nmod_mat(rows, pr).rank()


def flatten(T, N, kind):
    if kind == "row":   # (x,y) | (u,v)
        return [[T[x][y][u][v] for u in range(N) for v in range(N)] for x in range(N) for y in range(N)]
    else:               # (x,u) | (y,v)
        return [[T[x][y][u][v] for y in range(N) for v in range(N)] for x in range(N) for u in range(N)]


def run_appB(h, exact_limit=500):
    t0 = time.time()
    P, T = pieces_fast(h)
    if h <= 4:  # independent direct evaluation of (53), incl. Lemma 9(a) symmetry check
        P2, T2 = pieces(h, check=True)
        assert T2 == T, "direct (53) and factorized (54) disagree"
    N = len(P)
    res = []
    for s in sorted(T):
        Rr = sum(p(s + i) for i in range(2 * h + 1))
        Rc = sum(p(2 * h - s - i) for i in range(2 * h + 1))
        ranks = {}
        for kind in ("row", "col"):
            M = flatten(T[s], N, kind)
            if N * N <= exact_limit:
                ranks[kind] = rank_exact(M)
                assert ranks[kind] == rank_modp(M, PRIMES[0])
            else:
                r1, r2 = rank_modp(M, PRIMES[0]), rank_modp(M, PRIMES[1])
                assert r1 == r2, (h, s, kind, r1, r2)
                ranks[kind] = r1
        res.append((s, min(Rr, N * N), ranks["row"], min(Rc, N * N), ranks["col"]))
    return N, res, time.time() - t0


# ---------------- eight-square cross-validation ----------------
def sigma8(pv, qv):
    p1, p2, p3 = pv
    q1, q2, q3 = qv
    pp, qq = (p1, p2, p3), (q1, q2, q3)
    phi = sum(pp[k] * qq[k2] for k in range(3) for k2 in range(k, 3)) + q1 * p2 * p3 + p1 * q2 * p3 + p1 * p2 * q3
    return -1 if phi % 2 else 1


def bits3(z):
    return ((z >> 2) & 1, (z >> 1) & 1, z & 1)


def RC_block(x, y, u, v):
    X, Y, U, Vv = bits3(x), bits3(y), bits3(u), bits3(v)
    R = sigma8(X, Y) * sigma8(Vv, U) if (x ^ y) == (v ^ u) else 0
    C = sigma8(X, U) * sigma8(Vv, Y) if (x ^ u) == (v ^ y) else 0
    return R, C


def eight_square_check(t):
    """A_i of Definition 5 for lambda = 3t; compare ranks with App. H (p.48) formula
    rank_row(A_i) = sum_{z<=i} C(t,z) (N^2-N)^z N^(t-z), N=8; column: same with t-i."""
    assert all(RC_block(x, y, u, v)[0] + RC_block(x, y, u, v)[1] == 2 * (x == v) * (y == u)
               for x, y, u, v in itertools.product(range(8), repeat=4))
    N = 8 ** t
    blocks = lambda z: [(z >> (3 * j)) & 7 for j in range(t)]
    out = []
    for i in range(t + 1):
        def Ai(x, y, u, v):
            poly = [1]
            for xb, yb, ub, vb in zip(blocks(x), blocks(y), blocks(u), blocks(v)):
                R, C = RC_block(xb, yb, ub, vb)
                new = [0] * (len(poly) + 1)
                for d, c in enumerate(poly):
                    new[d] += c * R
                    new[d + 1] += c * C
                poly = new
            return poly[i]
        rows_row = [[Ai(x, y, u, v) for u in range(N) for v in range(N)] for x in range(N) for y in range(N)]
        rows_col = [[Ai(x, y, u, v) for y in range(N) for v in range(N)] for x in range(N) for u in range(N)]
        rr, rc = rank_modp(rows_row, PRIMES[0]), rank_modp(rows_col, PRIMES[0])
        f = lambda j: sum(math.comb(t, z) * 56 ** z * 8 ** (t - z) for z in range(j + 1))
        out.append((i, rr, f(i), rc, f(t - i)))
    return out


if __name__ == "__main__":
    for pr in PRIMES:
        assert flint.fmpz(pr).is_prime()
    print("== cross-validation: eight-square pieces (Def. 5) vs App. H rank formula ==")
    for t in (1, 2):
        for i, rr, fr, rc, fc in eight_square_check(t):
            print(f"  t={t} i={i}: row rank {rr} (paper {fr}), col rank {rc} (paper {fc})")
            assert rr == fr and rc == fc
    hmax = int(sys.argv[1]) if len(sys.argv) > 1 else 8
    print("\n== Appendix B pieces: counted bound vs true rank ==")
    print("h N=p(h) s | Rrow rank_row | Rcol rank_col | counted log2(Rr*Rc)  true log2(rr*rc)")
    summary = []
    for h in range(2, hmax + 1):
        N, res, dt = run_appB(h)
        worst_c = max(math.log2(Rr) + math.log2(Rc) for s, Rr, rr, Rc, rc in res)
        worst_t = max(math.log2(max(rr, 1)) + math.log2(max(rc, 1)) for s, Rr, rr, Rc, rc in res)
        for s, Rr, rr, Rc, rc in res:
            print(f"{h:2d} {N:4d} {s:4d} | {Rr:6d} {rr:6d} | {Rc:6d} {rc:6d} | "
                  f"{math.log2(Rr)+math.log2(Rc):8.3f} {math.log2(max(rr,1))+math.log2(max(rc,1)):8.3f}")
        lam = math.log2(N)
        summary.append((h, N, worst_c, worst_t, worst_c / (4 * lam), worst_t / (4 * lam), dt))
        print(f"-- h={h}: worst-piece bits counted {worst_c:.3f}, true {worst_t:.3f}; "
              f"rho_counted={worst_c/(4*lam):.4f} rho_rank={worst_t/(4*lam):.4f} (lambda=log2 p(h)={lam:.3f}) [{dt:.1f}s]",
              flush=True)
    print("\nsummary: h N counted_bits true_bits rho_counted rho_rank")
    for row in summary:
        print("  %d %d %.3f %.3f %.4f %.4f" % row[:6])
