import ctypes, numpy as np, time, json, sys, multiprocessing as mp
from fractions import Fraction
from common import fvec
nproc = int(sys.argv[1])
z = np.load("dict3.npz"); S = np.ascontiguousarray(z['S']); N = np.ascontiguousarray(z['Ng']); D = z['D'].astype(np.int64); orb = z['orb']
P = len(S); f = fvec(3); h = np.ascontiguousarray((D @ f).astype(np.int64)); Gii = (D*D).sum(1)
reps = sorted(set(orb.tolist()))
# r=1 and r=2 (numpy, exact integers)
print("r=1: max captured energy =", max(Fraction(int(h[i]**2), int(Gii[i])) for i in reps), "(bound 8)")
best2 = Fraction(0); viol2 = 0; eq2 = 0
for i in reps:
    Gi = D @ D[i]; det = Gii[i]*Gii - Gi*Gi; quad = h[i]**2*Gii - 2*h[i]*h*Gi + h**2*Gii[i]
    ok = det > 0
    viol2 += int((quad[ok] > 16*det[ok]).sum()); eq2 += int((quad[ok] == 16*det[ok]).sum())
    k = np.argmax(np.where(ok, quad/np.where(ok, det, 1), -1)); best2 = max(best2, Fraction(int(quad[k]), int(det[k])))
print("r=2: pairs (rep, any): violations of captured <= 16:", viol2, " equalities:", eq2, " max captured:", best2)
vp = ctypes.c_void_p
def work(job):
    i, lo, hi_ = job
    L = ctypes.CDLL('/mnt/data/review/abelian/libenergy3.so')
    Gi = np.ascontiguousarray((D @ D[i]).astype(np.int64)); out = np.zeros(8, dtype=np.int64)
    L.energy3(vp(S.ctypes.data), vp(N.ctypes.data), vp(h.ctypes.data), ctypes.c_int(P), ctypes.c_int(i), ctypes.c_int(lo), ctypes.c_int(hi_), ctypes.c_long(24), vp(Gi.ctypes.data), vp(out.ctypes.data))
    return out
if __name__ == "__main__":
    # self-test of the C inner product / determinant on random triples against numpy
    t0 = time.time(); jobs = []
    # chunk j so that work is balanced (inner loop length P-j)
    edges = [0]; tot = P*(P-1)//2; acc = 0; target = tot/600
    for j in range(P):
        acc += P-1-j
        if acc >= target: edges.append(j+1); acc = 0
    if edges[-1] != P: edges.append(P)
    for i in reps:
        for a, b in zip(edges[:-1], edges[1:]): jobs.append((i, a, b))
    tot_out = np.zeros(8, dtype=np.int64); best = Fraction(0)
    with mp.Pool(nproc) as pool:
        for k, out in enumerate(pool.imap_unordered(work, jobs, chunksize=4)):
            tot_out[[0, 1, 2, 5]] += out[[0, 1, 2, 5]]
            if out[4] > 0: best = max(best, Fraction(int(out[3]), int(out[4])))
            if k % 3000 == 0: print("progress", k, "/", len(jobs), "t=%.0f" % (time.time()-t0), flush=True)
    summ = dict(independent_triples_examined=int(tot_out[0]), dependent_triples_skipped=int(tot_out[5]), violations_of_captured_le_24=int(tot_out[1]),
                equalities=int(tot_out[2]), max_captured=str(best), seconds=round(time.time()-t0, 1))
    print("r=3:", json.dumps(summ)); json.dump(summ, open("energy3_summary.json", "w"))
