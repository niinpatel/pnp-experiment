# Driver for local search (multiprocess). usage: python3 lsdrv.py b r nproc restarts_per_proc kicks tag [initfile.npy]
import sys, ctypes, numpy as np, time, json, multiprocessing as mp
from common import *
b = int(sys.argv[1]); r = int(sys.argv[2]); nproc = int(sys.argv[3]); nres = int(sys.argv[4]); kicks = int(sys.argv[5]); tag = sys.argv[6]
initf = sys.argv[7] if len(sys.argv) > 7 else None
n = 2*b; NP = 1 << n
if b == 3:
    z = np.load("dict3.npz"); D = z['D']; dimv = z['dim']
else:
    pieces, D = flat_pieces(n); dimv = np.array([p['dim'] for p in pieces])
P = D.shape[0]
D = np.ascontiguousarray(D, dtype=np.int8)
nz = D != 0
start = np.zeros(P+1, dtype=np.int32); start[1:] = np.cumsum(nz.sum(1))
rows, cols = np.nonzero(nz)
pts = np.ascontiguousarray(cols.astype(np.uint8)); sgn = np.ascontiguousarray(D[rows, cols].astype(np.int8))
dimstart = np.ascontiguousarray(np.searchsorted(dimv, np.arange(n+2)).astype(np.int32))
f = np.ascontiguousarray(fvec(b).astype(np.float64))
init = np.ascontiguousarray(np.load(initf).astype(np.int32)) if initf else None
def work(seed):
    L = ctypes.CDLL('/mnt/data/review/abelian/libsearch.so')
    L.ls_run.restype = ctypes.c_long
    resout = np.zeros(nres, dtype=np.float64); maxsol = 20000; sols = np.zeros((maxsol, r), dtype=np.int32); stats = np.zeros(4, dtype=np.int64)
    vp = ctypes.c_void_p
    ns = L.ls_run(vp(D.ctypes.data), ctypes.c_int(P), ctypes.c_int(NP), vp(start.ctypes.data), vp(pts.ctypes.data), vp(sgn.ctypes.data),
                  vp(f.ctypes.data), ctypes.c_int(r), ctypes.c_ulong(seed), ctypes.c_long(nres), ctypes.c_int(kicks),
                  vp(dimstart.ctypes.data), ctypes.c_int(n+1), vp(init.ctypes.data) if init is not None else None,
                  ctypes.c_long(len(init) if init is not None else 0), vp(resout.ctypes.data), vp(sols.ctypes.data), ctypes.c_long(maxsol), vp(stats.ctypes.data))
    return resout, sols[:ns].copy(), int(stats[0])
if __name__ == "__main__":
    t0 = time.time()
    base = int(time.time()*1000) % (2**31)
    with mp.Pool(nproc) as pool:
        out = pool.map(work, [base*7919 + 1000003*(i+1) for i in range(nproc)])
    res = np.concatenate([o[0] for o in out]); sols = np.concatenate([o[1] for o in out]); nswap = sum(o[2] for o in out)
    el = time.time() - t0
    uniq = {tuple(sorted(map(int, s))) for s in sols}
    qs = np.quantile(res, [0, 0.01, 0.1, 0.5, 0.9]) if len(res) else []
    summary = dict(b=b, r=r, restarts=int(len(res)), kicks=kicks, best_swap_scans=nswap, seconds=round(el, 1), zero_residual_restarts=int((res < 1e-10).sum()),
                   distinct_solutions=len(uniq), min_residual=float(res.min()), residual_quantiles_0_1_10_50_90=[float(x) for x in qs],
                   smallest_distinct_residuals=sorted({round(float(x), 6) for x in res})[:8])
    print(json.dumps(summary))
    np.save(f"ls_{tag}_sols.npy", np.array(sorted(uniq), dtype=np.int32).reshape(-1, r))
    json.dump(summary, open(f"ls_{tag}_summary.json", "w"))
