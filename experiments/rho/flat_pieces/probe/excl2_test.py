# Validation of libexcl2: (a) brute-force comparison incl. cover conditions on random sub-dictionaries; (b) positive control: known 8-solutions are returned (r=8, cap=4).
import ctypes, numpy as np, itertools
from common import fvec
z = np.load("dict3.npz"); missw = np.ascontiguousarray(z['missw']); S = np.ascontiguousarray(z['S']); Sd = np.ascontiguousarray(z['Sd'])
D = np.ascontiguousarray(z['D'].astype(np.int8)); f8 = np.ascontiguousarray(fvec(3).astype(np.int8)); mp_ = z['mp']; md = z['md']; dimv = z['dim']
P = missw.shape[0]; pc = np.ascontiguousarray((mp_ + md).astype(np.int32))
L = ctypes.CDLL('/mnt/data/review/abelian/libexcl2.so'); L.excl_run.restype = ctypes.c_long; vp = ctypes.c_void_p
def run(r, cap, p1, c1):
    c1 = np.ascontiguousarray(np.array(sorted(c1), dtype=np.int32))
    wk = np.zeros((r+1)*P, dtype=np.int32); out = np.zeros((100000, r), dtype=np.int32); nodes = np.zeros(16, dtype=np.int64)
    n = L.excl_run(vp(missw.ctypes.data), ctypes.c_int(P), vp(pc.ctypes.data), ctypes.c_int(r), ctypes.c_int(cap), ctypes.c_int(cap*2240), ctypes.c_int(int(pc.min())),
                   ctypes.c_int(p1), vp(c1.ctypes.data), ctypes.c_int(len(c1)), ctypes.c_int(0), ctypes.c_int(len(c1)), vp(wk.ctypes.data), vp(out.ctypes.data),
                   ctypes.c_long(100000), vp(nodes.ctypes.data), vp(S.ctypes.data), vp(Sd.ctypes.data), vp(D.ctypes.data), vp(f8.ctypes.data))
    return n, {tuple(x) for x in out[:n].tolist()}, nodes
def unpack(rows):
    return ((rows[:, :, None] >> np.arange(64, dtype=np.uint64)[None, None, :]) & np.uint64(1)).reshape(rows.shape[0], -1).astype(np.int64)
rnd = np.random.default_rng(11); FULL = np.uint64(0xFFFFFFFFFFFFFFFF)
sols8 = np.load("ls_b3r8cal_sols.npy")
# (b) positive control
okb = 0
for s in sols8[:60]:
    s = list(map(int, s)); p1 = s[int(rnd.integers(8))]
    c1 = set(s) - {p1} | set(map(int, rnd.choice(P, 40, replace=False))) - {p1}
    n, got, nodes = run(8, 4, p1, c1)
    if tuple([p1] + sorted(set(s) - {p1})) in got: okb += 1
print("positive control: known 8-solutions returned by DFS (r=8, cap=4):", okb, "/ 60")
# (a) brute force: leaves counted at nodes[11] = pass W filter and cover; compare on sub-dictionaries biased to large/small pieces so that covers exist
oka = True; tot = 0
for trial in range(12):
    r, cap = [(6, 2), (5, 1), (6, 2), (7, 3)][trial % 4]
    base = list(map(int, sols8[int(rnd.integers(len(sols8)))]))
    pool_ = sorted(set(base) | set(map(int, rnd.choice(P, 10, replace=False))) | set(map(int, rnd.choice(np.nonzero((dimv == 0) | (dimv == 6) | (dimv == 5) | (dimv == 1))[0], 6, replace=False))))
    p1 = pool_[int(rnd.integers(len(pool_)))]; c1 = [x for x in pool_ if x != p1]
    n, got, nodes = run(r, cap, p1, c1)
    bits = unpack(missw[pool_]); pos = {x: i for i, x in enumerate(pool_)}
    cnt_leaf = 0
    for comb in itertools.combinations(c1, r-1):
        idx = [p1] + list(comb)
        if bits[[pos[x] for x in idx]].sum(0).max() > cap: continue
        cv = np.bitwise_or.reduce(S[idx]); cd = np.bitwise_or.reduce(Sd[idx])
        if cv == FULL and cd == FULL: cnt_leaf += 1
    tot += cnt_leaf
    if cnt_leaf != int(nodes[11]): oka = False; print("MISMATCH", trial, r, cap, cnt_leaf, int(nodes[11]))
print("brute force == DFS (count of leaves passing W-filter and cover) on 12 sub-dictionaries:", oka, " total leaves compared:", tot)
