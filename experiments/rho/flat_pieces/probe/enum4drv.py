import ctypes, numpy as np, time, json, sys, multiprocessing as mp, collections
from common import *
nproc = int(sys.argv[1])
pieces, D = flat_pieces(4); P = len(pieces); f = fvec(2)
D64 = D.astype(np.float64); G = np.ascontiguousarray(D64 @ D64.T); h = np.ascontiguousarray(D64 @ f.astype(np.float64))
vp = ctypes.c_void_p
def work(rng_):
    lo, hi = rng_
    L = ctypes.CDLL('/mnt/data/review/abelian/libenum4.so'); L.enum4.restype = ctypes.c_long
    maxout = 2000000; out = np.zeros((maxout, 4), dtype=np.int32); cnt = np.zeros(4, dtype=np.int64)
    n = L.enum4(vp(G.ctypes.data), vp(h.ctypes.data), ctypes.c_double(16.0), ctypes.c_int(lo), ctypes.c_int(hi), vp(out.ctypes.data), ctypes.c_long(maxout), vp(cnt.ctypes.data))
    assert n <= maxout
    return out[:n].copy(), cnt
if __name__ == "__main__":
    t0 = time.time()
    with mp.Pool(nproc) as pool:
        res = pool.map(work, [(i, i+1) for i in range(P)], chunksize=1)
    sols = np.concatenate([r[0] for r in res]); cnt = sum(r[1] for r in res)
    print("independent triples scanned:", int(cnt[0]), " triples with f in span:", int(cnt[1]), " float hits (4-subsets):", len(sols), " time %.0fs" % (time.time()-t0))
    # exact re-check of every hit (integer Gram determinant of the 5 vectors == 0 and 4 pieces independent)
    from flint import fmpz_mat
    D_ = D.astype(np.int64); bad = 0
    Gi = D_ @ D_.T; hi_ = D_ @ f
    for s in sols:
        idx = list(map(int, s))
        M = [[int(Gi[a, b_]) for b_ in idx] + [int(hi_[a])] for a in idx] + [[int(hi_[b_]) for b_ in idx] + [16]]
        if int(fmpz_mat(5, 5, [x for row in M for x in row]).det()) != 0: bad += 1
    print("hits failing exact check:", bad)
    dims = np.array([p['dim'] for p in pieces])
    prof = collections.Counter(tuple(sorted(dims[s].tolist())) for s in sols)
    print("number of 4-subsets spanning f_2 (exact):", len(sols) - bad, " dimension profiles:", dict(prof))
    np.save("b2_all4.npy", sols)
