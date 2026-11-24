# usage: python3 excl2drv.py r nproc chunk
# Exhaustive over r-sets of flat pieces on F_2^6 containing an orbit representative p1 of the top-ranked orbit present, such that every
# nondegenerate 4-dim affine W (primal and dual) is missed by at most r-4 pieces [necessary because N(2)=4]; leaves tested by cover + rank mod p.
import sys, ctypes, numpy as np, time, json, multiprocessing as mp
from common import fvec
r = int(sys.argv[1]); nproc = int(sys.argv[2]); chunk = int(sys.argv[3]) if len(sys.argv) > 3 else 200
cap = r - 4
z = np.load("dict3.npz"); missw = np.ascontiguousarray(z['missw']); orb = z['orb']; mp_ = z['mp']; md = z['md']
S = np.ascontiguousarray(z['S']); Sd = np.ascontiguousarray(z['Sd']); D = np.ascontiguousarray(z['D'].astype(np.int8)); f8 = np.ascontiguousarray(fvec(3).astype(np.int8))
P = missw.shape[0]
pc = np.ascontiguousarray((mp_ + md).astype(np.int32))
reps = sorted(set(orb.tolist()))
order = sorted(reps, key=lambda rp: (int(pc[rp]), rp)); rank_of = {rp: i for i, rp in enumerate(order)}
rk = np.array([rank_of[int(o)] for o in orb], dtype=np.int32)
budget = cap * 2240; minpc = int(pc.min())
jobs = []; cands = {}
for rp in reps:
    c1 = np.ascontiguousarray(np.nonzero((rk <= rk[rp]) & (np.arange(P) != rp))[0].astype(np.int32)); cands[rp] = c1
    for lo in range(0, len(c1), chunk): jobs.append((rp, lo, min(lo+chunk, len(c1))))
vp = ctypes.c_void_p
def work(job):
    rp, lo, hi = job
    L = ctypes.CDLL('/mnt/data/review/abelian/libexcl2.so'); L.excl_run.restype = ctypes.c_long
    c1 = cands[rp]
    wk = np.zeros((r+1)*P, dtype=np.int32); maxout = 20000; out = np.zeros((maxout, r), dtype=np.int32); nodes = np.zeros(16, dtype=np.int64)
    n = L.excl_run(vp(missw.ctypes.data), ctypes.c_int(P), vp(pc.ctypes.data), ctypes.c_int(r), ctypes.c_int(cap), ctypes.c_int(budget), ctypes.c_int(minpc),
                   ctypes.c_int(rp), vp(c1.ctypes.data), ctypes.c_int(len(c1)), ctypes.c_int(lo), ctypes.c_int(hi), vp(wk.ctypes.data), vp(out.ctypes.data),
                   ctypes.c_long(maxout), vp(nodes.ctypes.data), vp(S.ctypes.data), vp(Sd.ctypes.data), vp(D.ctypes.data), vp(f8.ctypes.data))
    return rp, int(n), out[:min(n, maxout)].copy(), nodes
if __name__ == "__main__":
    t0 = time.time()
    # self-test of the mod-p rank routine: known 8-solutions must give rank 8 (not 9); random 8-tuples rank 9
    L = ctypes.CDLL('/mnt/data/review/abelian/libexcl2.so')
    sols8 = np.load("ls_b3r8cal_sols.npy").astype(np.int32)
    rs = {int(L.rank_test(vp(D.ctypes.data), vp(f8.ctypes.data), vp(np.ascontiguousarray(s).ctypes.data), ctypes.c_int(8))) for s in sols8}
    rnd = np.random.default_rng(0)
    rr = [int(L.rank_test(vp(D.ctypes.data), vp(f8.ctypes.data), vp(np.ascontiguousarray(rnd.choice(P, 8, replace=False).astype(np.int32)).ctypes.data), ctypes.c_int(8))) for _ in range(200)]
    print("self-test rank mod p: on", len(sols8), "known 8-solutions ->", rs, "; on 200 random 8-tuples -> min", min(rr), "max", max(rr), flush=True)
    tot_nodes = np.zeros(16, dtype=np.int64); surv = []; nsurv = 0
    with mp.Pool(nproc) as pool:
        for k, (rp, n, out, nodes) in enumerate(pool.imap_unordered(work, jobs, chunksize=4)):
            tot_nodes += nodes; nsurv += n; surv.append(out)
            if k % 1000 == 0: print("progress", k, "/", len(jobs), "unexcluded", nsurv, "nodes", tot_nodes.tolist(), "t=%.0f" % (time.time()-t0), flush=True)
    surv = np.concatenate(surv) if surv else np.zeros((0, r), dtype=np.int32)
    summ = dict(r=r, cap=cap, jobs=len(jobs), nodes_by_depth=tot_nodes[:r+1].tolist(), leaves_passing_W_filter=int(tot_nodes[10]),
                leaves_also_covering_G_and_dual=int(tot_nodes[11]), leaves_not_excluded_by_rank_mod_p=int(tot_nodes[12]), stored=int(len(surv)), seconds=round(time.time()-t0, 1))
    print(json.dumps(summ)); json.dump(summ, open(f"excl2_r{r}_summary.json", "w"))
    np.save(f"excl2_r{r}_unexcluded.npy", surv)
