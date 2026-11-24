# Independent numpy cross-check of DFS node counts (depth 2 and 3) on real data for two orbit representatives, r=6, cap=2.
import ctypes, numpy as np
from common import fvec
z = np.load("dict3.npz"); missw = np.ascontiguousarray(z['missw']); S = np.ascontiguousarray(z['S']); Sd = np.ascontiguousarray(z['Sd']); orb = z['orb']
D = np.ascontiguousarray(z['D'].astype(np.int8)); f8 = np.ascontiguousarray(fvec(3).astype(np.int8)); mp_ = z['mp']; md = z['md']
P = missw.shape[0]; pc = np.ascontiguousarray((mp_ + md).astype(np.int32))
reps = sorted(set(orb.tolist())); order = sorted(reps, key=lambda rp: (int(pc[rp]), rp)); rank_of = {rp: i for i, rp in enumerate(order)}
rk = np.array([rank_of[int(o)] for o in orb], dtype=np.int32)
L = ctypes.CDLL('/mnt/data/review/abelian/libexcl2.so'); L.excl_run.restype = ctypes.c_long; vp = ctypes.c_void_p
def unpack(rows):
    return ((rows[:, :, None] >> np.arange(64, dtype=np.uint64)[None, None, :]) & np.uint64(1)).reshape(rows.shape[0], -1).astype(np.float32)
for rp in (52288, 52289):
    r, cap = 6, 2
    c1 = np.ascontiguousarray(np.nonzero((rk <= rk[rp]) & (np.arange(P) != rp))[0].astype(np.int32))
    wk = np.zeros((r+1)*P, dtype=np.int32); out = np.zeros((1000, r), dtype=np.int32); nodes = np.zeros(16, dtype=np.int64)
    n = L.excl_run(vp(missw.ctypes.data), ctypes.c_int(P), vp(pc.ctypes.data), ctypes.c_int(r), ctypes.c_int(cap), ctypes.c_int(cap*2240), ctypes.c_int(int(pc.min())),
                   ctypes.c_int(rp), vp(c1.ctypes.data), ctypes.c_int(len(c1)), ctypes.c_int(0), ctypes.c_int(len(c1)), vp(wk.ctypes.data), vp(out.ctypes.data),
                   ctypes.c_long(1000), vp(nodes.ctypes.data), vp(S.ctypes.data), vp(Sd.ctypes.data), vp(D.ctypes.data), vp(f8.ctypes.data))
    M = unpack(missw[c1]); m1 = unpack(missw[[rp]])[0]
    C = (M * m1[None, :]) @ M.T            # C[i,j] = |m1 & m_i & m_j|
    ok = (C == 0)
    n3 = 0
    for i in range(len(c1)):
        nn = int(ok[i, i+1:].sum())
        if nn >= r-2: n3 += nn - (r-3)
    print(f"rep {rp}: candidates {len(c1)}; C nodes depth2 {int(nodes[2])} depth3 {int(nodes[3])}; numpy depth2 {len(c1)} depth3 {n3}; match {int(nodes[2]) == len(c1) and int(nodes[3]) == n3}; C nodes all {nodes[:7].tolist()} leaves {int(nodes[10])}")
