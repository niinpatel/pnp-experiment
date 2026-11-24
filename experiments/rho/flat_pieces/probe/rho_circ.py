# usage: python3 rho_circ.py b solsfile.npy [nproc]   -- exact type-grouping exponent for LS-found representations (zero-coefficient pieces dropped)
import sys, numpy as np, collections, json, multiprocessing as mp
from common import *
from rho_eval import rho_bounds, supports
b = int(sys.argv[1]); fn = sys.argv[2]; nproc = int(sys.argv[3]) if len(sys.argv) > 3 else 2
n = 2*b; NP = 1 << n
z = np.load(f"subs{n}.npz"); kdim = z['kdim']; bas = z['bas']
def to_param(sub, c, s):
    k = int(kdim[sub]); B = [int(x) for x in bas[sub]]
    off = 0
    for i in range(n-k):
        if (c >> i) & 1: off ^= B[k+i]
    l = next(l for l in range(NP) if all((popc(l & B[i]) & 1) == ((s >> i) & 1) for i in range(k)))
    return (tuple(B[:k]), off, l)
fv = fvec(b)
def ev(sol):
    ps = [to_param(*map(int, t)) for t in sol]
    ps = list(dict.fromkeys(ps))
    coef = exact_solve([piece_vec(n, *p) for p in ps], fv)
    if coef is None: return None
    keep = [p for p, c in zip(ps, coef) if c != 0]
    sp = [supports(n, *p) for p in keep]
    lo, up, _ = rho_bounds([s[0] for s in sp], [s[1] for s in sp], b, iters=1500, tol=1e-4)
    return (len(keep), tuple(sorted(len(p[0]) for p in keep)), round(lo, 4), round(up, 4), tuple(sorted(sp)))
if __name__ == "__main__":
    sols = np.load(fn)
    if len(sols) > 3000: sols = sols[:3000]
    with mp.Pool(nproc) as pool: out = [o for o in pool.map(ev, list(sols), chunksize=8) if o is not None]
    uniq = {o[4]: o for o in out}
    tab = collections.defaultdict(list)
    for o in uniq.values(): tab[(o[0], o[1])].append((o[2], o[3]))
    print(f"{fn}: {len(sols)} solutions, {len(uniq)} distinct support-structures")
    rows = sorted(tab.items(), key=lambda kv: min(u for _, u in kv[1]))
    for (r_, prof), v in rows[:14]:
        print("  r_eff", r_, "dims", prof, "count", len(v), "rho upper min/max", min(u for _, u in v), max(u for _, u in v), "lower min", min(l for l, _ in v))
    allup = [u for v in tab.values() for _, u in v]; alllo = [l for v in tab.values() for l, _ in v]
    print("  MIN rho (upper bound):", min(allup), " min lower bound:", min(alllo), " #profiles:", len(tab))
