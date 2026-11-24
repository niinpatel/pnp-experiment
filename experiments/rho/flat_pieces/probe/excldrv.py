# usage: python3 excldrv.py r nproc [chunk]
# Exhaustive: all r-sets of flat pieces on F_2^6 (one piece = orbit representative of the top-ranked orbit present) such that
# every nondegenerate 4-dim affine W (primal: supports; dual: Fourier supports) is missed by at most r-4 pieces.
import sys, ctypes, numpy as np, time, json, multiprocessing as mp
r = int(sys.argv[1]); nproc = int(sys.argv[2]); chunk = int(sys.argv[3]) if len(sys.argv) > 3 else 200
cap = r - 4
z = np.load("dict3.npz"); missw = np.ascontiguousarray(z['missw']); orb = z['orb']; mp_ = z['mp']; md = z['md']
P = missw.shape[0]
pc = np.ascontiguousarray((mp_ + md).astype(np.int32))
reps = sorted(set(orb.tolist()))
# rank orbits: most constraining (largest miss count) first = highest rank
order = sorted(reps, key=lambda rp: (int(pc[rp]), rp))        # ascending miss count
rank_of = {rp: i for i, rp in enumerate(order)}
rk = np.array([rank_of[int(o)] for o in orb], dtype=np.int32)
budget = cap * 2240; minpc = int(pc.min())
jobs = []
cands = {}
for rp in reps:
    c1 = np.ascontiguousarray(np.nonzero((rk <= rk[rp]) & (np.arange(P) != rp))[0].astype(np.int32))
    cands[rp] = c1
    for lo in range(0, len(c1), chunk): jobs.append((rp, lo, min(lo+chunk, len(c1))))
def work(job):
    rp, lo, hi = job
    L = ctypes.CDLL('/mnt/data/review/abelian/libexcl.so'); L.excl_run.restype = ctypes.c_long
    c1 = cands[rp]; vp = ctypes.c_void_p
    wk = np.zeros((r+1)*P, dtype=np.int32); maxout = 200000; out = np.zeros((maxout, r), dtype=np.int32); nodes = np.zeros(10, dtype=np.int64)
    n = L.excl_run(vp(missw.ctypes.data), ctypes.c_int(P), vp(pc.ctypes.data), ctypes.c_int(r), ctypes.c_int(cap), ctypes.c_int(budget), ctypes.c_int(minpc),
                   ctypes.c_int(rp), vp(c1.ctypes.data), ctypes.c_int(len(c1)), ctypes.c_int(lo), ctypes.c_int(hi), vp(wk.ctypes.data), vp(out.ctypes.data),
                   ctypes.c_long(maxout), vp(nodes.ctypes.data))
    return rp, int(n), out[:min(n, maxout)].copy(), nodes
if __name__ == "__main__":
    t0 = time.time()
    tot_nodes = np.zeros(10, dtype=np.int64); surv = []; nsurv = 0; per_rep = {}
    with mp.Pool(nproc) as pool:
        for k, (rp, n, out, nodes) in enumerate(pool.imap_unordered(work, jobs, chunksize=1)):
            tot_nodes += nodes; nsurv += n; surv.append(out); per_rep[rp] = per_rep.get(rp, 0) + n
            if k % 2000 == 0: print("progress", k, "/", len(jobs), "survivors", nsurv, "nodes", tot_nodes[:r+1].tolist(), "t=%.0f" % (time.time()-t0), flush=True)
    surv = np.concatenate(surv) if surv else np.zeros((0, r), dtype=np.int32)
    print(json.dumps(dict(r=r, cap=cap, jobs=len(jobs), nodes_by_depth=tot_nodes[:r+1].tolist(), survivors=nsurv, stored=int(len(surv)),
                          survivors_per_rep={int(k): int(v) for k, v in per_rep.items() if v}, seconds=round(time.time()-t0, 1))))
    np.save(f"excl_r{r}_survivors.npy", surv)
