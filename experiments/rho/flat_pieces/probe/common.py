# Common: flat pieces on F_2^n (n=2b), f_b, exact helpers.
# Points x in F_2^n are ints 0..2^n-1; x = (a,b) with a = high b bits, b = low b bits; f(x) = (-1)^{a.b}.
import numpy as np
from fractions import Fraction

def popc(x): return bin(x).count('1')
def fvec(b):
    n = 2*b; mask = (1 << b) - 1
    return np.array([(-1)**(popc((x >> b) & x & mask) % 2) for x in range(1 << n)], dtype=np.int64)

def all_subspaces(n):
    """all linear subspaces of F_2^n as sorted tuples of elements; returns dict dim -> list of (elements tuple, basis tuple)"""
    seen = {(0,): ()}
    frontier = [((0,), ())]
    while frontier:
        new = []
        for els, basis in frontier:
            S = set(els)
            for v in range(1, 1 << n):
                if v in S: continue
                els2 = tuple(sorted(S | {s ^ v for s in S}))
                if els2 not in seen:
                    seen[els2] = basis + (v,)
                    new.append((els2, basis + (v,)))
        frontier = new
    out = {}
    for els, basis in seen.items():
        out.setdefault(len(basis), []).append((els, basis))
    return out

def flat_pieces(n):
    """All flat pieces chi_l * 1_{x0+V} up to scalar.  Returns list of dicts(basis, offset, l, dim) and int8 matrix D (rows = pieces,
    normalised: value +1 at the smallest support point)."""
    subs = all_subspaces(n)
    par = np.array([[popc(l & x) & 1 for x in range(1 << n)] for l in range(1 << n)], dtype=np.int8)  # par[l,x] = l.x
    pieces = []; rows = []
    for k in sorted(subs):
        for els, basis in subs[k]:
            els_a = np.array(els)
            # distinct restrictions of characters to V: l modulo V^perp ; pick smallest l for each restriction
            pat = par[:, els_a]                         # 2^n x |V|
            seenpat = {}
            for l in range(1 << n):
                key = pat[l].tobytes()
                if key not in seenpat: seenpat[key] = l
            reps_l = sorted(seenpat.values())
            assert len(reps_l) == len(els)
            done = set()
            for x0 in range(1 << n):
                if x0 in done: continue
                coset = [x0 ^ e for e in els]; done.update(coset)
                cos_a = np.array(coset)
                for l in reps_l:
                    g = np.zeros(1 << n, dtype=np.int8)
                    g[cos_a] = 1 - 2*par[l, cos_a]
                    if g[min(coset)] < 0: g = -g          # normalise
                    pieces.append(dict(basis=tuple(basis), offset=x0, l=l, dim=k)); rows.append(g)
    return pieces, np.array(rows, dtype=np.int8)

def piece_vec(n, basis, offset, l):
    S = {0}
    for v in basis: S |= {s ^ v for s in S}
    g = np.zeros(1 << n, dtype=np.int64)
    for s in S:
        x = s ^ offset; g[x] = (-1)**(popc(x & l) & 1)
    return g

def exact_solve(vecs, f):
    """Exact rational solve: is f in span(vecs)? returns list of Fractions (coefficients) or None. vecs: list of int vectors."""
    from flint import fmpq_mat, fmpq
    m = len(vecs); N = len(f)
    A = fmpq_mat(N, m + 1, [fmpq(int(vecs[j][i])) if j < m else fmpq(int(f[i])) for i in range(N) for j in range(m + 1)])
    R, rk = A.rref()
    # f in span iff no pivot in last column
    piv = []
    r = 0
    for c in range(m + 1):
        if r < rk and R[r, c] != 0:
            # pivot at (r,c) if all entries left are zero
            piv.append(c); r += 1
    if m in piv: return None
    coef = [Fraction(0)] * m
    for r_, c in enumerate(piv):
        v = R[r_, m]; coef[c] = Fraction(int(v.p), int(v.q))
    # verify
    for i in range(N):
        assert sum(coef[j] * int(vecs[j][i]) for j in range(m)) == int(f[i])
    return coef
