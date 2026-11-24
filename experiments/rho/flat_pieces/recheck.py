"""Independent exact re-check (reviewer's own code, not the subagent's) of:
 (1) the dictionary size and N(2) = 4 on F_2^4: no 1, 2 or 3 flat pieces span f(a,b) = (-1)^{a.b};
     the 4-piece certificate does;
 (2) the lemma behind the subagent's N(3) >= 7 exclusion: on each of the 1120 affine subspaces
     W = w + P^perp (P a plus-type hyperbolic plane of F_2^6), f restricted to W is, up to a sign and
     a character, a plus-type bent function on a 4-dimensional space;
 (3) the dictionary size on F_2^6 and the 8-piece tensor certificate there.
Exact arithmetic throughout (Python ints / flint fmpz)."""
import itertools, sys
import numpy as np
import flint

def popc(x): return bin(x).count("1")

def subspaces(n):
    """all linear subspaces of F_2^n as sorted tuples of ints"""
    seen = {(0,)}
    frontier = [(0,)]
    while frontier:
        nxt = []
        for S in frontier:
            Sset = set(S)
            for v in range(1, 1 << n):
                if v in Sset: continue
                T = tuple(sorted(Sset | {s ^ v for s in S}))
                if T not in seen:
                    seen.add(T); nxt.append(T)
        frontier = nxt
    return sorted(seen, key=lambda t: (len(t), t))

def pieces(n):
    """all flat pieces c*(-1)^{l.x}*1_A up to scalar, as (support bitmask, value vector tuple)"""
    out = {}
    for S in subspaces(n):
        Sset = set(S)
        cosets = {tuple(sorted(s ^ o for s in S)) for o in range(1 << n)}
        for A in cosets:
            a0 = A[0]
            for l in range(1 << n):
                vec = [0] * (1 << n)
                for x in A:
                    vec[x] = (-1) ** popc(l & (x ^ a0))      # normalised: +1 at the first point of A
                out[tuple(vec)] = None
    return list(out.keys())

def f_bent(b):
    n = 2 * b
    return [(-1) ** popc((x >> b) & (x & ((1 << b) - 1))) for x in range(1 << n)]

def wht(v):
    v = np.array(v, dtype=np.int64); h = 1
    while h < len(v):
        for i in range(0, len(v), 2 * h):
            a = v[i:i + h].copy(); c = v[i + h:i + 2 * h].copy()
            v[i:i + h] = a + c; v[i + h:i + 2 * h] = a - c
        h *= 2
    return v

def in_span(vs, f):
    M = flint.fmpz_mat([list(v) for v in vs])
    M2 = flint.fmpz_mat([list(v) for v in vs] + [list(f)])
    return M.rank() == M2.rank()

# ---------- (1) b = 2
P = pieces(4); f = f_bent(2)
print("b=2: number of flat pieces up to scalar:", len(P), "(subagent and orchestrator: 1072)")
full = (1 << 16) - 1
smask = np.array([sum(1 << x for x in range(16) if v[x]) for v in P], dtype=np.int64)
fmask = np.array([sum(1 << x for x in range(16) if w != 0) if False else sum(1 << x for x, w in enumerate(wht(v)) if w != 0) for v in P], dtype=np.int64)
assert all(w != 0 for w in wht(f)), "fhat must be nowhere zero"
# r = 1, 2: exact, no prefilter
r1 = sum(in_span([v], f) for v in P)
r2 = 0
for i in range(len(P)):
    for j in range(i + 1, len(P)):
        if (smask[i] | smask[j]) == full and (fmask[i] | fmask[j]) == full:   # necessary: f and fhat nowhere zero
            r2 += in_span([P[i], P[j]], f)
# r = 3: necessary cover conditions as a prefilter (both domains), then exact rank test
cand = 0; r3 = 0
for i in range(len(P)):
    for j in range(i + 1, len(P)):
        su = smask[i] | smask[j]; fu = fmask[i] | fmask[j]
        ks = np.nonzero(((su | smask[j + 1:]) == full) & ((fu | fmask[j + 1:]) == full))[0]
        for k in ks:
            cand += 1
            r3 += in_span([P[i], P[j], P[j + 1 + int(k)]], f)
print(f"b=2: single pieces spanning f: {r1}; pairs: {r2}; triples passing both cover conditions: {cand}, of which spanning f: {r3}")
ind = lambda cond: [1 if cond(x) else 0 for x in range(16)]
a1 = lambda x: (x >> 3) & 1; a2 = lambda x: (x >> 2) & 1; b1 = lambda x: (x >> 1) & 1; b2 = lambda x: x & 1
cert = [1 - 2 * (a1(x) & b1(x)) - 2 * (a2(x) & b2(x)) + 4 * (a1(x) & b1(x) & a2(x) & b2(x)) for x in range(16)]
print("b=2: certificate 1 - 2[a1=b1=1] - 2[a2=b2=1] + 4[all four = 1] equals f:", cert == f)
print("=> N(2) = 4" if (r1 == 0 and r2 == 0 and r3 == 0 and cert == f) else "=> N(2) NOT confirmed")

# ---------- (2) lemma for b = 3
b = 3; n = 6; f3 = f_bent(3)
q = lambda x: popc((x >> b) & (x & 7)) & 1
B = lambda x, y: q(x ^ y) ^ q(x) ^ q(y)
planes = set()
for x in range(1, 64):
    for y in range(1, 64):
        if q(x) == 0 and q(y) == 0 and B(x, y) == 1:
            planes.add(tuple(sorted((0, x, y, x ^ y))))
print("b=3: plus-type hyperbolic planes:", len(planes), "(expected 280)")
bad = 0; nW = 0
for Pl in planes:
    U = [u for u in range(64) if all(B(u, p) == 0 for p in Pl)]
    assert len(U) == 16
    for w in {min(w ^ u for u in U) for w in range(64)}:
        nW += 1
        # f(w+u) f(w) (-1)^{B(w,u)} should equal (-1)^{q(u)} on U, and q|U must be plus type (10 zeros)
        ok = all(f3[w ^ u] * f3[w] * (-1) ** B(w, u) == (-1) ** q(u) for u in U)
        zeros = sum(1 for u in U if q(u) == 0)
        rad = [u for u in U if all(B(u, v) == 0 for v in U)]
        if not (ok and zeros == 10 and rad == [0]): bad += 1
print(f"b=3: affine subspaces W checked: {nW} (expected 1120); failures of the restriction lemma: {bad}")

# ---------- (3) b = 3 dictionary size and tensor certificate
ns = {}
for S in subspaces(6):
    d = len(S).bit_length() - 1
    ns[d] = ns.get(d, 0) + (64 // len(S)) * len(S)       # cosets x characters distinct on the coset
print("b=3: flat pieces up to scalar by dimension:", dict(sorted(ns.items())), "total", sum(ns.values()), "(subagent: 180,800)")
pi = lambda x, i: ((x >> (3 + i)) & 1) & ((x >> i) & 1)
cert3 = [(1 - 2 * pi(x, 0)) * (1 - 2 * pi(x, 1)) * (1 - 2 * pi(x, 2)) for x in range(64)]
print("b=3: 8-piece tensor certificate prod_i (1 - 2[a_i=b_i=1]) equals f:", cert3 == f3)
