# Local search with some pieces held fixed.  usage: python3 ls3drv.py b r nproc restarts kicks tag  "basis;offset;l" ["basis;offset;l" ...]
#   basis = comma-separated ints (empty for a point), e.g. "32,16,8,4,2,1;0;0" = constant 1 on F_2^6 ; ";63;0" = delta at point 63
import sys, ctypes, numpy as np, time, json, multiprocessing as mp
from common import *
b = int(sys.argv[1]); r = int(sys.argv[2]); nproc = int(sys.argv[3]); nres = int(sys.argv[4]); kicks = int(sys.argv[5]); tag = sys.argv[6]
n = 2*b; NP = 1 << n
z = np.load(f"subs{n}.npz"); kdim = np.ascontiguousarray(z['kdim']); bas = np.ascontiguousarray(z['bas']); nsub = len(kdim)
key = {tuple(int(x) for x in bas[i, :int(kdim[i])]): i for i in range(nsub)}
def rref(basis):
    rows = []
    for v in basis:
        for r_ in rows:
            if v & (1 << (r_.bit_length()-1)): v ^= r_
        if v:
            pb = 1 << (v.bit_length()-1)
            rows = [r_ ^ v if r_ & pb else r_ for r_ in rows]
            rows.append(v); rows.sort(reverse=True)
    return rows
def to_triple(basis, offset, l):
    rows = rref(list(basis)); sub = key[tuple(rows)]; k = len(rows)
    for r_ in rows:
        if offset & (1 << (r_.bit_length()-1)): offset ^= r_
    comp = [int(x) for x in bas[sub, k:n]]; c = 0
    for i, cv in enumerate(comp):
        if offset & cv: c |= 1 << i; offset ^= cv
    assert offset == 0
    s = 0
    for i, r_ in enumerate(rows):
        if popc(l & r_) & 1: s |= 1 << i
    return (sub, c, s)
fixed = []
for spec in sys.argv[7:]:
    bs, off, l = spec.split(';')
    fixed.append(to_triple([int(x) for x in bs.split(',') if x], int(off), int(l)))
fixed = np.ascontiguousarray(np.array(fixed, dtype=np.int32).reshape(-1, 3)); nfix = len(fixed)
dimstart = np.ascontiguousarray(np.searchsorted(kdim, np.arange(n+2)).astype(np.int32))
f = np.ascontiguousarray(fvec(b).astype(np.float64))
def work(seed):
    L = ctypes.CDLL('/mnt/data/review/abelian/libsearch3.so'); L.ls3_run.restype = ctypes.c_long
    resout = np.zeros(nres, dtype=np.float64); maxsol = 5000; sols = np.zeros((maxsol, r, 3), dtype=np.int32); stats = np.zeros(4, dtype=np.int64)
    vp = ctypes.c_void_p
    ns = L.ls3_run(ctypes.c_int(nfix), vp(fixed.ctypes.data), ctypes.c_int(n), ctypes.c_int(nsub), vp(kdim.ctypes.data), vp(bas.ctypes.data), vp(dimstart.ctypes.data), vp(f.ctypes.data),
                   ctypes.c_int(r), ctypes.c_ulong(seed), ctypes.c_long(nres), ctypes.c_int(kicks), None, ctypes.c_long(0),
                   vp(resout.ctypes.data), vp(sols.ctypes.data), ctypes.c_long(maxsol), None, vp(stats.ctypes.data))
    return resout, sols[:ns].copy(), int(stats[0])
if __name__ == "__main__":
    t0 = time.time(); base = int(time.time()*1000) % (2**31)
    with mp.Pool(nproc) as pool: out = pool.map(work, [base*7919 + 1000003*(i+1) for i in range(nproc)], chunksize=1)
    res = np.concatenate([o[0] for o in out]); sols = np.concatenate([o[1] for o in out])
    print(json.dumps(dict(b=b, r=r, nfix=nfix, restarts=int(len(res)), zero_residual=int((res < 1e-10).sum()), min_residual=float(res.min()),
                          smallest_residuals=sorted({round(float(x), 5) for x in res})[:6], seconds=round(time.time()-t0, 1))))
    np.save(f"ls3_{tag}_sols.npy", sols)
