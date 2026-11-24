# b=3 infrastructure: dictionary of flat pieces on F_2^6, W-structures, miss masks, symmetry orbits.
import numpy as np, time, itertools, pickle
from common import *
t0 = time.time()
b = 3; n = 6; NP = 64
pieces, D = flat_pieces(n)
P = len(pieces)
print("flat pieces on F_2^6 up to scalar:", P, " by dim:", {k: sum(1 for p in pieces if p['dim'] == k) for k in range(n+1)}, "time %.1f" % (time.time()-t0))
assert P == 180800 and len({r.tobytes() for r in D}) == P
f = fvec(3)
def q(x): return popc((x >> 3) & x & 7) & 1
def sw(x): return ((x >> 3) | ((x & 7) << 3))
def B(x, y): return popc(x & sw(y)) & 1
for x in range(64):
    for y in range(64): assert q(x ^ y) == q(x) ^ q(y) ^ B(x, y)
# pack helpers (bit x <-> point x)
w64 = (np.uint64(1) << np.arange(64, dtype=np.uint64))
def pack(M):   # boolean (m,64) -> uint64 (m,)
    return (M.astype(np.uint64) * w64[None, :]).sum(axis=1, dtype=np.uint64)
def keys_of(Dm):   # normalised (support, negmask) keys for sign matrix rows (any nonzero scalar multiples of flat pieces)
    S = pack(Dm != 0); Ng = pack(Dm < 0)
    low = S & (~S + np.uint64(1))
    flip = (Ng & low) != 0
    Ng = np.where(flip, Ng ^ S, Ng)
    return S, Ng
S, Ng = keys_of(D)
index = {(int(s), int(g)): i for i, (s, g) in enumerate(zip(S, Ng))}
assert len(index) == P
# Hadamard transform  ghat(y) = sum_x g(x) (-1)^{x.y}
H = np.array([[1 - 2*(popc(x & y) & 1) for y in range(64)] for x in range(64)], dtype=np.int32)
Dh = D.astype(np.int32) @ H
assert ((f @ H) == 8*f).all()
Sd = pack(Dh != 0)           # dual supports
dimv = np.array([p['dim'] for p in pieces])
assert (np.array([popc(int(s)) for s in Sd]) == 2**(6 - dimv)).all()
# symmetry generators as permutations of piece indices
def perm_from(Dm):
    s_, g_ = keys_of(Dm)
    return np.array([index[(int(a), int(c))] for a, c in zip(s_, g_)], dtype=np.int64)
gens = []
for hvec in range(1, 64):
    if q(hvec) == 1:    # reflection x -> x + B(x,h) h
        sig = np.array([x ^ (hvec if B(x, hvec) else 0) for x in range(64)])
        assert all(q(int(sig[x])) == q(x) for x in range(64))
        gens.append(('refl%d' % hvec, perm_from(D[:, sig])))
for i in range(6):
    c = 1 << i
    sig = np.array([x ^ c for x in range(64)]); tw = np.array([1 - 2*B(x, c) for x in range(64)], dtype=np.int8)
    assert all(f[x ^ c] == f[x]*f[c]*tw[x] for x in range(64))
    gens.append(('trans%d' % i, perm_from(D[:, sig] * tw[None, :])))
four = perm_from(Dh)
gens_nof = list(gens)
gens.append(('fourier', four))
def orbits(gs):
    par = np.arange(P)
    def find(x):
        while par[x] != x:
            par[x] = par[par[x]]; x = par[x]
        return x
    for name, pm in gs:
        for i in range(P):
            a, c = find(i), find(int(pm[i]))
            if a != c: par[max(a, c)] = min(a, c)
    return np.array([find(i) for i in range(P)])
orb_nof = orbits(gens_nof); orb = orbits(gens)
print("orbits without Fourier:", len(set(orb_nof)), " with Fourier:", len(set(orb)), "time %.1f" % (time.time()-t0))
# W structures: U = P^perp for hyperbolic planes P={0,e,f,e+f} with q(e)=q(f)=0,B(e,f)=1
Us = set()
for e in range(1, 64):
    for g in range(1, 64):
        if q(e) == 0 and q(g) == 0 and B(e, g) == 1:
            U = tuple(sorted(x for x in range(64) if B(x, e) == 0 and B(x, g) == 0))
            Us.add(U)
Us = sorted(Us); assert len(Us) == 280
Ws = []
for U in Us:
    assert sum(1 for x in U if q(x) == 0) == 10 and len(U) == 16
    seen = set()
    for w in range(64):
        if w in seen: continue
        cos = [w ^ u for u in U]; seen.update(cos)
        Ws.append(sum(1 << x for x in cos))
assert len(Ws) == 1120
Wa = np.array(Ws, dtype=np.uint64)
missP = (S[:, None] & Wa[None, :]) == 0      # P x 1120 : piece support misses W
missD = (Sd[:, None] & Wa[None, :]) == 0     # dual support misses W
miss = np.concatenate([missP, missD], axis=1)   # P x 2240
mp = missP.sum(1); md = missD.sum(1)
# every proper affine hyperplane misses some W  (lemma N(b) >= N(b-1)+1)
hyp = [i for i in range(P) if pieces[i]['dim'] == 5]
assert all(mp[i] > 0 for i in hyp); print("every piece of dim 5 (hence every proper support) misses >=1 W: OK; min over dim<=5 of primal miss count:", int(mp[dimv <= 5].min()))
print("orbit table (rep, dim, orbit size, primal miss /1120, dual miss /1120):")
reps = sorted(set(orb))
for rp in reps:
    print("  ", rp, int(dimv[rp]), int((orb == rp).sum()), int(mp[rp]), int(md[rp]))
print("min total miss:", int((mp+md).min()), " -> r=5 needs sum of 5 totals <= 2240")
# pack miss masks to 35 uint64 words
missw = np.zeros((P, 35), dtype=np.uint64)
for wd in range(35):
    missw[:, wd] = pack(miss[:, 64*wd:64*wd+64])
np.savez("dict3.npz", D=D, S=S, Ng=Ng, Sd=Sd, dim=dimv, offset=np.array([p['offset'] for p in pieces]), l=np.array([p['l'] for p in pieces]),
         basis=np.array([list(p['basis']) + [0]*(6-len(p['basis'])) for p in pieces]), orb=orb, orb_nof=orb_nof, four=four, Wa=Wa, missw=missw, mp=mp, md=md)
pickle.dump(dict(gens=gens), open("gens3.pkl", "wb"))
print("saved; total time %.1f" % (time.time()-t0))
