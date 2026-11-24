# Does cancellation inside type-groups change the exponent?  For three b=2 schemes and t=2..5 blocks compare, over all types,
# max_type log2(|supp| * |supp^|) for the true group sums versus the union-of-supports bound.
import numpy as np, itertools, collections, math
from common import *
pieces, D = flat_pieces(4); f2 = fvec(2)
H = np.array([[1 - 2*(popc(x & y) & 1) for y in range(16)] for x in range(16)], dtype=np.int64)
def find(basis, offset, l):
    v = piece_vec(4, basis, offset, l)
    for i in range(len(pieces)):
        if (D[i] == v).all() or (D[i] == -v).all(): return i
schemes = {"tensor square {1,d1,d2,d1d2}": [find((8, 4, 2, 1), 0, 0), find((4, 1), 0b1010, 0), find((8, 2), 0b0101, 0), find((), 15, 0)],
           "(0,2,2,4) with cancellation": [1, 683, 789, 1059], "(0,3,3,3)": [0, 821, 838, 855]}
for name, s in schemes.items():
    coef = exact_solve([D[int(i)].astype(np.int64) for i in s], f2)
    den = int(np.lcm.reduce([c.denominator for c in coef])); ci = [int(c * den) for c in coef]
    g = [ci[j] * D[int(s[j])].astype(np.int64) for j in range(4)]; gh = [v @ H for v in g]
    print(name, "pieces", s, "dims", [pieces[i]['dim'] for i in s], "coefs", [str(c) for c in coef])
    for t in (2, 3, 4, 5):
        groups = {}
        for arr in itertools.product(range(4), repeat=t):
            ty = tuple(sorted(arr))
            v = g[arr[0]]; vh = gh[arr[0]]
            for a in arr[1:]: v = np.multiply.outer(v, g[a]).reshape(-1); vh = np.multiply.outer(vh, gh[a]).reshape(-1)
            if ty not in groups: groups[ty] = [np.zeros(16**t, dtype=np.int64), np.zeros(16**t, dtype=np.int64), np.zeros(16**t, dtype=bool), np.zeros(16**t, dtype=bool)]
            G_ = groups[ty]; G_[0] += v; G_[1] += vh; G_[2] |= (v != 0); G_[3] |= (vh != 0)
        true_cost = max(math.log2(int((sv != 0).sum())) + math.log2(int((svh != 0).sum())) for sv, svh, un, unh in groups.values())
        union_cost = max(math.log2(int(un.sum())) + math.log2(int(unh.sum())) for sv, svh, un, unh in groups.values())
        ncanc = sum(1 for sv, svh, un, unh in groups.values() if (sv != 0).sum() != un.sum() or (svh != 0).sum() != unh.sum())
        print(f"   t={t}: types {len(groups)}, with cancellation {ncanc};  max cost true {true_cost:.3f} bits ({true_cost/(8*t):.4f}), union bound {union_cost:.3f} bits ({union_cost/(8*t):.4f}), gap {union_cost-true_cost:.3f} bits")
