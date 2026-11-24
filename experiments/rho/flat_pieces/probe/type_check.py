# Check, for b=2 minimal schemes, that the support of a type-group (sum of all products of the given type) equals the union of the
# supports of its terms, in the primal and in the Fourier domain, for t=2,3 blocks (no cancellation => exponent formula is exact there).
import numpy as np, itertools, collections
from common import *
pieces, D = flat_pieces(4); sols = np.load("b2_all4.npy"); f2 = fvec(2)
H = np.array([[1 - 2*(popc(x & y) & 1) for y in range(16)] for x in range(16)], dtype=np.int64)
rnd = np.random.default_rng(7)
dims = np.array([p['dim'] for p in pieces])
# one scheme of every dimension profile + random ones
byprof = {}
for s in sols: byprof.setdefault(tuple(sorted(dims[s].tolist())), s)
test = list(byprof.values()) + [sols[i] for i in rnd.integers(0, len(sols), 12)]
allok = True; ncls = 0
for s in test:
    vecs = [D[int(i)].astype(object) for i in s]
    coef = exact_solve([D[int(i)].astype(np.int64) for i in s], f2)
    den = np.lcm.reduce([c.denominator for c in coef]); ci = [int(c * den) for c in coef]
    g = [ci[j] * D[int(s[j])].astype(np.int64) for j in range(4)]           # integer pieces, sum = den * f
    gh = [v @ H for v in g]
    for t in (2, 3):
        groups = collections.defaultdict(lambda: [0, 0, 0, 0])
        for arr in itertools.product(range(4), repeat=t):
            ty = tuple(sorted(arr))
            v = g[arr[0]]; vh = gh[arr[0]]
            for a in arr[1:]: v = np.multiply.outer(v, g[a]).reshape(-1); vh = np.multiply.outer(vh, gh[a]).reshape(-1)
            G_ = groups[ty]
            G_[0] = G_[0] + v; G_[1] = G_[1] + vh
            G_[2] = (G_[2] | (v != 0)); G_[3] = (G_[3] | (vh != 0))
        for ty, (sv, svh, un, unh) in groups.items():
            ncls += 1
            if (sv != 0).sum() != un.sum() or (svh != 0).sum() != unh.sum():
                allok = False; print("cancellation: scheme", s.tolist(), "t", t, "type", ty, (sv != 0).sum(), un.sum(), (svh != 0).sum(), unh.sum())
print("type-groups checked:", ncls, " over", len(test), "schemes; support of group == union of term supports (primal and Fourier) in all:", allok)
