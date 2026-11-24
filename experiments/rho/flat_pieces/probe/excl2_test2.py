# non-vacuous brute-force validation of libexcl2 at r=8, cap=4 on sub-dictionaries containing known solutions
import ctypes, numpy as np, itertools
from common import fvec
z = np.load("dict3.npz"); missw = np.ascontiguousarray(z['missw']); S = np.ascontiguousarray(z['S']); Sd = np.ascontiguousarray(z['Sd'])
D = np.ascontiguousarray(z['D'].astype(np.int8)); f8 = np.ascontiguousarray(fvec(3).astype(np.int8)); mp_ = z['mp']; md = z['md']
P = missw.shape[0]; pc = np.ascontiguousarray((mp_ + md).astype(np.int32))
L = ctypes.CDLL('/mnt/data/review/abelian/libexcl2.so'); L.excl_run.restype = ctypes.c_long; vp = ctypes.c_void_p
def unpack(rows):
    return ((rows[:, :, None] >> np.arange(64, dtype=np.uint64)[None, None, :]) & np.uint64(1)).reshape(rows.shape[0], -1).astype(np.int64)
rnd = np.random.default_rng(21); FULL = np.uint64(0xFFFFFFFFFFFFFFFF); sols8 = np.load("ls_b3r8cal_sols.npy")
ok = True; tot = 0; totsol = 0
for trial in range(6):
    a = list(map(int, sols8[int(rnd.integers(len(sols8)))])); b_ = list(map(int, sols8[int(rnd.integers(len(sols8)))]))
    pool_ = sorted(set(a) | set(b_) | set(map(int, rnd.choice(P, 3, replace=False))))
    p1 = a[0]; c1 = np.ascontiguousarray(np.array([x for x in pool_ if x != p1], dtype=np.int32))
    r, cap = 8, 4
    wk = np.zeros((r+1)*P, dtype=np.int32); out = np.zeros((100000, r), dtype=np.int32); nodes = np.zeros(16, dtype=np.int64)
    n = L.excl_run(vp(missw.ctypes.data), ctypes.c_int(P), vp(pc.ctypes.data), ctypes.c_int(r), ctypes.c_int(cap), ctypes.c_int(cap*2240), ctypes.c_int(int(pc.min())),
                   ctypes.c_int(p1), vp(c1.ctypes.data), ctypes.c_int(len(c1)), ctypes.c_int(0), ctypes.c_int(len(c1)), vp(wk.ctypes.data), vp(out.ctypes.data),
                   ctypes.c_long(100000), vp(nodes.ctypes.data), vp(S.ctypes.data), vp(Sd.ctypes.data), vp(D.ctypes.data), vp(f8.ctypes.data))
    bits = unpack(missw[pool_]); pos = {x: i for i, x in enumerate(pool_)}
    leaf = 0; insp = 0
    for comb in itertools.combinations(c1.tolist(), r-1):
        idx = [p1] + list(comb)
        if bits[[pos[x] for x in idx]].sum(0).max() > cap: continue
        if np.bitwise_or.reduce(S[idx]) == FULL and np.bitwise_or.reduce(Sd[idx]) == FULL:
            leaf += 1
            M = np.vstack([D[idx].astype(np.float64), f8.astype(np.float64)[None, :]])
            if np.linalg.matrix_rank(M) < 9: insp += 1
    tot += leaf; totsol += insp
    if leaf != int(nodes[11]) or insp != n: ok = False; print("MISMATCH", trial, leaf, int(nodes[11]), insp, n)
print("brute force == DFS at r=8,cap=4 on 6 sub-dictionaries:", ok, " leaves compared:", tot, " f-in-span leaves compared:", totsol)
