# Exact asymptotic exponent of the "power a flat block identity and group by type" scheme.
# Pieces j with primal supports A_j (subsets of G, |G|=4^b) and Fourier supports A*_j.  A type-group with type distribution p has
#   log2(row rank)/t -> h(p) = max{ H(X) : (J,X), J~p, X in A_J },  log2(col rank)/t -> h*(p) (same with A*),   [upper bounds; = if no cancellation]
#   rho = max_p (h(p)+h*(p)) / (4b) = min_{q,q*} max_j [ log2 1/min_{A_j} q + log2 1/min_{A*_j} q* ] / (4b).
# rho_bounds returns (lower, upper): lower = (h+h*)(p) for an explicit p, upper = max_j cost_j(q,q*) for explicit q,q*.
import numpy as np
def _maxent(p, U, bits, full):
    r = len(p); psum = bits @ p
    Rem = np.uint64(full); Rp = (1 << r) - 1
    Tidx = np.arange(1, 1 << r)
    dens_pt = {}
    levels = []
    while Rp:
        ok = (Tidx & ~Rp) == 0
        cnt = np.bitwise_count(U[Tidx] & Rem).astype(np.float64)
        ps = np.where(ok, (bits[Tidx] * ((np.array([(Rp >> j) & 1 for j in range(r)], dtype=np.float64))[None, :])) @ p, -1.0)
        with np.errstate(divide='ignore', invalid='ignore'):
            dens = np.where(ok & (cnt > 0), ps / cnt, np.where(ok & (ps > 0), np.inf, -1.0))
        md = dens.max()
        if not np.isfinite(md): raise RuntimeError("uncovered mass")
        sel = Tidx[dens >= md * (1 - 1e-12) - 1e-300]
        Ts = 0
        for t in sel: Ts |= int(t)
        newpts = np.uint64(U[Ts]) & Rem
        levels.append((newpts, md))
        Rem = Rem & ~newpts; Rp &= ~Ts
    return levels
def rho_bounds(A, Ad, b, iters=4000, tol=2e-5):
    """A, Ad: lists of python-int bitmasks over the 4^b points. Returns (lower, upper, p)."""
    r = len(A); npts = 4**b; full = (1 << npts) - 1
    assert npts <= 64
    def prep(M):
        U = np.zeros(1 << r, dtype=np.uint64)
        for T in range(1, 1 << r):
            low = (T & -T).bit_length() - 1
            U[T] = np.uint64(int(U[T & (T-1)]) | M[low])
        return U
    bits = np.array([[(T >> j) & 1 for j in range(r)] for T in range(1 << r)], dtype=np.float64)
    U = prep(A); Ud = prep(Ad)
    Aa = np.array(A, dtype=np.uint64); Ada = np.array(Ad, dtype=np.uint64)
    def side(p, Um, Ma):
        lev = _maxent(p, Um, bits, full)
        H = 0.0; g = np.zeros(r)
        for pts, d in lev:
            c = int(np.bitwise_count(pts))
            if d > 0: H -= c * d * np.log2(d)
        # g_j = log2 1/min_{A_j} m : the lowest density level intersecting A_j
        for j in range(r):
            mn = min(d for pts, d in lev if (pts & Ma[j]) != 0)
            g[j] = np.log2(1.0 / max(mn, 1e-300))
        return H, g
    p = np.full(r, 1.0 / r); best_lo = -1; best_up = 1e9; best_p = p.copy()
    for it in range(iters):
        pp = np.maximum(p, 1e-12); pp /= pp.sum()
        H1, g1 = side(pp, U, Aa); H2, g2 = side(pp, Ud, Ada)
        lo = H1 + H2; g = g1 + g2; up = g.max()
        if lo > best_lo: best_lo = lo; best_p = pp.copy()
        best_up = min(best_up, up)
        if best_up - best_lo < tol * 4 * b: break
        eta = 0.5 / np.sqrt(1 + it)
        p = pp * np.exp2(eta * (g - g.max())); p /= p.sum()
    return best_lo / (4*b), best_up / (4*b), best_p
def supports(n, basis, offset, l):
    """primal support mask and Fourier support mask (standard dot product) of chi_l 1_{offset+span(basis)}"""
    S = {0}
    for v in basis: S |= {s ^ v for s in S}
    A = sum(1 << (s ^ offset) for s in S)
    perp = [y for y in range(1 << n) if all(bin(y & v).count('1') % 2 == 0 for v in basis)]
    Ad = sum(1 << (y ^ l) for y in perp)
    return A, Ad
if __name__ == "__main__":
    import math, itertools
    # b=1: pieces 1 and delta_{11}
    A1, D1 = supports(2, (1, 2), 0, 0); A2, D2 = supports(2, (), 3, 0)
    print("b=1 scheme {1, delta}:", rho_bounds([A1, A2], [D1, D2], 1)[:2], " log2(12)/4 =", math.log2(12)/4)
    # b=2 tensor square (4 pieces), coordinates a1 a2 b1 b2
    ps = [((8, 4, 2, 1), 0, 0), ((4, 1), 0b1010, 0), ((8, 2), 0b0101, 0), ((), 0b1111, 0)]
    sp = [supports(4, *q) for q in ps]
    print("b=2 tensor square of {1, delta}:", rho_bounds([s[0] for s in sp], [s[1] for s in sp], 2)[:2])
    # b=2 Lagrangian fibration: cosets of L = {(0,b)} : pieces delta_a (x) chi_a
    ps = [((2, 1), a << 2, a) for a in range(4)]
    sp = [supports(4, *q) for q in ps]
    print("b=2 fibration a -> delta_a x chi_a:", rho_bounds([s[0] for s in sp], [s[1] for s in sp], 2)[:2])
