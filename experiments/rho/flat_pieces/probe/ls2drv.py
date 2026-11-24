# WHT-based local search over all flat pieces of F_2^{2b}.  usage: python3 ls2drv.py b r nproc restarts_per_proc kicks tag [init.npy]
import sys, ctypes, numpy as np, time, json, os, pickle, multiprocessing as mp
from common import *
b = int(sys.argv[1]); r = int(sys.argv[2]); nproc = int(sys.argv[3]); nres = int(sys.argv[4]); kicks = int(sys.argv[5]); tag = sys.argv[6]
initf = sys.argv[7] if len(sys.argv) > 7 else None
n = 2*b; NP = 1 << n
def subspace_table(n):
    fn = f"subs{n}.npz"
    if os.path.exists(fn):
        z = np.load(fn); return z['kdim'], z['bas']
    # enumerate subspaces by RREF matrices: choose pivot columns, free entries arbitrary
    import itertools
    out = []
    for k in range(n+1):
        for piv in itertools.combinations(range(n), k):
            # rows i has leading 1 at column piv[i]; free positions: columns c > piv[i], c not in piv
            free = [(i, c) for i in range(k) for c in range(piv[i]+1, n) if c not in piv]
            comp = [1 << (n-1-c) for c in range(n) if c not in piv]     # unit vectors at non-pivot columns: complement basis
            for bits in range(1 << len(free)):
                rows = [1 << (n-1-piv[i]) for i in range(k)]
                for t, (i, c) in enumerate(free):
                    if (bits >> t) & 1: rows[i] |= 1 << (n-1-c)
                out.append((k, rows + comp + [0]*(8-n)))
    kdim = np.array([o[0] for o in out], dtype=np.uint8); bas = np.array([o[1] for o in out], dtype=np.uint8)
    np.savez(fn, kdim=kdim, bas=bas); return kdim, bas
kdim, bas = subspace_table(n)
kdim = np.ascontiguousarray(kdim); bas = np.ascontiguousarray(bas)
nsub = len(kdim)
dimstart = np.ascontiguousarray(np.searchsorted(kdim, np.arange(n+2)).astype(np.int32))
f = np.ascontiguousarray(fvec(b).astype(np.float64))
init = np.ascontiguousarray(np.load(initf).astype(np.int32)) if initf else None
def to_param(sub, c, s):
    k = int(kdim[sub]); B = [int(x) for x in bas[sub]]
    off = 0
    for i in range(n-k):
        if (c >> i) & 1: off ^= B[k+i]
    # linear form l with l.B[i] = s_i  (brute force over l)
    l = next(l for l in range(NP) if all((popc(l & B[i]) & 1) == ((s >> i) & 1) for i in range(k)))
    return dict(basis=tuple(B[:k]), offset=off, l=l, dim=k)
def work(seed):
    global init
    if init is not None:
        init = np.ascontiguousarray(init[np.random.default_rng(seed % (2**32)).permutation(len(init))])
    L = ctypes.CDLL('/mnt/data/review/abelian/libsearch2.so'); L.ls2_run.restype = ctypes.c_long
    resout = np.zeros(nres, dtype=np.float64); maxsol = 5000; sols = np.zeros((maxsol, r, 3), dtype=np.int32); stats = np.zeros(4, dtype=np.int64)
    finals = np.zeros((nres, r, 3), dtype=np.int32)
    vp = ctypes.c_void_p
    ns = L.ls2_run(ctypes.c_int(n), ctypes.c_int(nsub), vp(kdim.ctypes.data), vp(bas.ctypes.data), vp(dimstart.ctypes.data), vp(f.ctypes.data),
                   ctypes.c_int(r), ctypes.c_ulong(seed), ctypes.c_long(nres), ctypes.c_int(kicks),
                   vp(init.ctypes.data) if init is not None else None, ctypes.c_long(len(init) if init is not None else 0),
                   vp(resout.ctypes.data), vp(sols.ctypes.data), ctypes.c_long(maxsol), vp(finals.ctypes.data), vp(stats.ctypes.data))
    return resout, sols[:ns].copy(), int(stats[0]), finals
if __name__ == "__main__":
    t0 = time.time()
    # self-check of subspace table: count and distinctness for small n
    from math import prod
    def gbin(n_, k_): return prod((2**(n_-i)-1) for i in range(k_)) // prod((2**(i+1)-1) for i in range(k_))
    assert nsub == sum(gbin(n, k) for k in range(n+1)), nsub
    base = int(time.time()*1000) % (2**31)
    with mp.Pool(nproc) as pool:
        out = pool.map(work, [base*7919 + 1000003*(i+1) for i in range(nproc)], chunksize=1)
    res = np.concatenate([o[0] for o in out]); sols = np.concatenate([o[1] for o in out]); nscan = sum(o[2] for o in out)
    finals = np.concatenate([o[3] for o in out])
    el = time.time() - t0
    # exact certification of every reported solution
    fv = fvec(b); cert = []; ncert = 0
    for sol in sols[:200]:
        ps = [to_param(*map(int, t)) for t in sol]
        vecs = [piece_vec(n, p['basis'], p['offset'], p['l']) for p in ps]
        coef = exact_solve(vecs, fv)
        if coef is not None:
            ncert += 1
            cert.append([dict(basis=list(p['basis']), offset=p['offset'], l=p['l'], dim=p['dim'], coef=str(cf)) for p, cf in zip(ps, coef)])
    qs = np.quantile(res, [0, 0.01, 0.1, 0.5, 0.9]) if len(res) else []
    summary = dict(b=b, r=r, restarts=int(len(res)), kicks=kicks, scans=nscan, seconds=round(el, 1), zero_residual_restarts=int((res < 1e-10).sum()),
                   solutions_stored=int(len(sols)), exactly_certified_of_first_200=ncert, min_residual=float(res.min()),
                   residual_quantiles_0_1_10_50_90=[round(float(x), 6) for x in qs], smallest_distinct_residuals=sorted({round(float(x), 5) for x in res})[:10])
    print(json.dumps(summary))
    np.save(f"ls2_{tag}_sols.npy", sols); np.save(f"ls2_{tag}_res.npy", res); np.save(f"ls2_{tag}_finals.npy", finals)
    json.dump(dict(summary=summary, convention="x=(a,b), a=high b bits, b=low b bits; piece = coef*(-1)^{popcount(l&x)}*1[x in offset+span(basis)]", certified=cert[:50]),
              open(f"ls2_{tag}_summary.json", "w"))
