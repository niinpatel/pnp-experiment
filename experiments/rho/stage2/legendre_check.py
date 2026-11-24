"""Stage 2: sanity checks for the Legendre lemma (STAGE2_GRADED.md, Lemma L).
F(th) = ln Z(th) = sum_n c_n f(th n), f(t) = -ln(1-e^{-t});  S(E) = min_th (th E + F(th)) >= ln dim V_{<=E} (Chernoff).
Claims checked numerically: (i) th*F(th) nonincreasing for nondecreasing c_n; (ii) S(2E) >= sqrt2 S(E);
(iii) S - ln dim V_{<=E} is O(log E) (so D = S(1+o(1)) in the ranges used)."""
import math, sys
import numpy as np
sys.path.insert(0, '/mnt/data/rho/stage2')
from graded_profiles import exact_counts, log2int


def F(th, c, K):
    n = np.arange(1, K + 1)
    return float(np.sum(c(n) * -np.log1p(-np.exp(-th * n))))


def S(E, c, K):
    g = lambda th: th * E + F(th, c, K)   # convex in th
    lo, hi = math.exp(-12), math.exp(5)
    for _ in range(200):
        m1, m2 = lo + (hi - lo) / 3, hi - (hi - lo) / 3
        if g(m1) < g(m2):
            hi = m2
        else:
            lo = m1
    return g((lo + hi) / 2)


fams = [("c=1", lambda n: np.ones_like(n, dtype=float), lambda k: 1, 20000),
        ("c=24", lambda n: 24.0 * np.ones_like(n, dtype=float), lambda k: 24, 4000),
        ("c=2^20", lambda n: float(2 ** 20) * np.ones_like(n, dtype=float), lambda k: 2 ** 20, 200),
        ("c=n (MacMahon)", lambda n: n.astype(float), lambda k: k, 3000)]
for name, cv, ci, N in fams:
    K = 200000
    ths = np.exp(np.linspace(-9, 4, 300))
    tf = np.array([t * F(t, cv, K) for t in ths])
    mono = bool(np.all(np.diff(tf) <= 1e-9 * np.abs(tf[:-1]) + 1e-12))
    a = exact_counts(ci, N)
    acc, lnD = 0, []
    for v in a:
        acc += v
        lnD.append(log2int(acc) * math.log(2))
    print(f"{name}: th*F(th) nonincreasing on grid: {mono}")
    for E in [N // 64, N // 16, N // 4, N // 2]:
        if E < 2:
            continue
        s1, s2 = S(E, cv, K), S(2 * E, cv, K) if 2 * E <= N else None
        gap = s1 - lnD[E]
        line = f"   E={E:6d} S(E)={s1:10.3f} lnD(E)={lnD[E]:10.3f} gap={gap:7.3f} (ln E={math.log(E):.2f})"
        if s2 is not None:
            line += f"  S(2E)/S(E)={s2 / s1:.4f}  D(2E)/D(E)={lnD[2 * E] / lnD[E]:.4f}"
        print(line, flush=True)
