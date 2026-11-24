# exact type-grouping exponent rho for every 4-piece representation of f_2 (all 4705), using rho_eval.
import numpy as np, collections, json, multiprocessing as mp
from common import *
from rho_eval import rho_bounds, supports
pieces, D = flat_pieces(4)
sup = [supports(4, p['basis'], p['offset'], p['l']) for p in pieces]
# check supports against D and Fourier transform
H = np.array([[1 - 2*(popc(x & y) & 1) for y in range(16)] for x in range(16)])
for i in range(0, len(pieces), 37):
    assert sup[i][0] == sum(1 << x for x in range(16) if D[i, x] != 0)
    assert sup[i][1] == sum(1 << y for y in range(16) if (D[i].astype(int) @ H)[y] != 0)
sols = np.load("b2_all4.npy")
def ev(s):
    lo, up, p = rho_bounds([sup[i][0] for i in s], [sup[i][1] for i in s], 2)
    return lo, up
if __name__ == "__main__":
    with mp.Pool(30) as pool: out = pool.map(ev, [list(map(int, s)) for s in sols], chunksize=20)
    lo = np.array([o[0] for o in out]); up = np.array([o[1] for o in out])
    dims = np.array([p['dim'] for p in pieces])
    print("max gap upper-lower:", float((up-lo).max()))
    tab = collections.defaultdict(list)
    for s, l, u in zip(sols, lo, up): tab[tuple(sorted(dims[s].tolist()))].append(round(float(u), 4))
    for k in sorted(tab): print(k, len(tab[k]), sorted(collections.Counter(tab[k]).items()))
    print("min rho over all 4705 minimal b=2 schemes:", float(up.min()), " (single-bit scheme: 0.89624)")
    json.dump(dict(min_rho=float(up.min()), by_profile={str(k): sorted(collections.Counter(v).items()) for k, v in tab.items()}), open("rho_b2_all4.json", "w"))
