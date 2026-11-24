# (a) unit test of the C DFS against brute force on random instances; (b) check lemma on known 8-solutions.
import ctypes, numpy as np, itertools, random
L = ctypes.CDLL('/mnt/data/review/abelian/libexcl.so'); L.excl_run.restype = ctypes.c_long
vp = ctypes.c_void_p
rnd = np.random.default_rng(5)
def crun(mask, pc, r, cap, p1, c1, budget, minpc):
    P = mask.shape[0]; wk = np.zeros((r+1)*P, dtype=np.int32); out = np.zeros((100000, r), dtype=np.int32); nodes = np.zeros(10, dtype=np.int64)
    n = L.excl_run(vp(mask.ctypes.data), ctypes.c_int(P), vp(pc.ctypes.data), ctypes.c_int(r), ctypes.c_int(cap), ctypes.c_int(budget), ctypes.c_int(minpc),
                   ctypes.c_int(p1), vp(c1.ctypes.data), ctypes.c_int(len(c1)), ctypes.c_int(0), ctypes.c_int(len(c1)), vp(wk.ctypes.data), vp(out.ctypes.data),
                   ctypes.c_long(100000), vp(nodes.ctypes.data))
    return n, {tuple(x) for x in out[:n].tolist()}
allok = True
for trial in range(6):
    P = 26; nbits = 2240; dens = [0.02, 0.05, 0.1][trial % 3]
    bits = rnd.random((P, nbits)) < dens
    mask = np.zeros((P, 35), dtype=np.uint64)
    for w in range(35):
        mask[:, w] = (bits[:, 64*w:64*w+64].astype(np.uint64) << np.arange(64, dtype=np.uint64)[None, :]).sum(1, dtype=np.uint64)
    pc = np.ascontiguousarray(bits.sum(1).astype(np.int32))
    for r, cap in ((4, 1), (5, 1), (5, 2), (6, 2), (6, 3)):
        p1 = int(rnd.integers(P)); c1 = np.ascontiguousarray(np.array([i for i in range(P) if i != p1], dtype=np.int32))
        budget = cap*nbits; minpc = int(pc.min())
        n, S = crun(np.ascontiguousarray(mask), pc, r, cap, p1, c1, budget, minpc)
        brute = set()
        for comb in itertools.combinations(c1.tolist(), r-1):
            cnt = bits[[p1] + list(comb)].sum(0)
            if cnt.max() <= cap: brute.add((p1,) + comb)
        if S != brute or n != len(brute): allok = False; print("MISMATCH", trial, r, cap, n, len(brute))
print("C DFS == brute force on 30 random instances:", allok)
# (b) known 8-solutions satisfy: every W (primal+dual) met by >= 4 pieces
z = np.load("dict3.npz"); missw = z['missw']; sols = np.load("ls_b3r8cal_sols.npy")
def unpack(rows):
    return ((rows[:, :, None] >> np.arange(64, dtype=np.uint64)[None, None, :]) & np.uint64(1)).reshape(rows.shape[0], -1).astype(np.int64)
mx = 0; mn_meet = 99
for s in sols:
    cnt = unpack(missw[s]).sum(0); mx = max(mx, int(cnt.max())); mn_meet = min(mn_meet, 8 - int(cnt.max()))
print("known 8-piece solutions:", len(sols), " max number of pieces missing a W:", mx, " min number meeting a W:", mn_meet, "(lemma requires >= 4)")
import collections
dimv = z['dim']
print("dimension profiles of LS 8-solutions:", collections.Counter(tuple(sorted(dimv[s].tolist())) for s in sols).most_common(12))
