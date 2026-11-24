import sys, ctypes, numpy as np, time, json
r = int(sys.argv[1]); cap = r - 4; nchunk = int(sys.argv[2])
z = np.load("dict3.npz"); missw = np.ascontiguousarray(z['missw']); orb = z['orb']; mp_ = z['mp']; md = z['md']; dimv = z['dim']
P = missw.shape[0]; pc = np.ascontiguousarray((mp_ + md).astype(np.int32))
reps = sorted(set(orb.tolist()))
order = sorted(reps, key=lambda rp: (int(pc[rp]), rp)); rank_of = {rp: i for i, rp in enumerate(order)}
rk = np.array([rank_of[int(o)] for o in orb], dtype=np.int32)
L = ctypes.CDLL('/mnt/data/review/abelian/libexcl.so'); L.excl_run.restype = ctypes.c_long; vp = ctypes.c_void_p
rnd = np.random.default_rng(1)
wk = np.zeros((r+1)*P, dtype=np.int32); out = np.zeros((1000, r), dtype=np.int32)
tot_est = 0
for rp in reps:
    c1 = np.ascontiguousarray(np.nonzero((rk <= rk[rp]) & (np.arange(P) != rp))[0].astype(np.int32))
    ts = []; nd = np.zeros(10, dtype=np.int64); ns = 0
    for lo in rnd.integers(0, len(c1), size=3):
        nodes = np.zeros(10, dtype=np.int64); t0 = time.time()
        n = L.excl_run(vp(missw.ctypes.data), ctypes.c_int(P), vp(pc.ctypes.data), ctypes.c_int(r), ctypes.c_int(cap), ctypes.c_int(cap*2240), ctypes.c_int(int(pc.min())),
                       ctypes.c_int(rp), vp(c1.ctypes.data), ctypes.c_int(len(c1)), ctypes.c_int(int(lo)), ctypes.c_int(int(lo)+nchunk), vp(wk.ctypes.data), vp(out.ctypes.data),
                       ctypes.c_long(1000), vp(nodes.ctypes.data))
        ts.append(time.time()-t0); nd += nodes; ns += n
    est = np.mean(ts)/nchunk*len(c1); tot_est += est
    print(f"rep {rp} dim {dimv[rp]} pc {pc[rp]} ncand {len(c1)} times {[round(t,2) for t in ts]} nodes {nd[:r+1].tolist()} surv {ns} est_cpu_s {est:.0f}", flush=True)
print("total estimated cpu-seconds:", round(tot_est))
