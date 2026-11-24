# Task 1: N(2) = 4, exhaustive, exact integer arithmetic (Gram determinants in int64, |entries| <= 16 so no overflow).
import numpy as np, itertools, json, time, math
from common import *
t0 = time.time()
n = 4
pieces, D = flat_pieces(n)
P = len(pieces)
print("number of flat pieces on F_2^4 up to scalar:", P, " by dim:", {k: sum(1 for p in pieces if p['dim'] == k) for k in range(n+1)})
assert len({r.tobytes() for r in D}) == P
f = fvec(2)
D64 = D.astype(np.int64)
G = D64 @ D64.T            # Gram
h = D64 @ f                # <g_i, f>
ff = int(f @ f)            # 16
# r = 1: f proportional to a piece?
r1 = [i for i in range(P) if (np.abs(D64[i]) == 1).all() and (abs(h[i]) == 16)]
print("r=1 solutions:", len(r1))
# r = 2: 3x3 Gram determinant of (g_i, g_j, f) == 0  <=> dependent (distinct pieces up to scalar are independent)
Gii = np.diag(G)
det2 = Gii[:, None]*Gii[None, :] - G*G
offdiag = ~np.eye(P, dtype=bool)
assert (det2[offdiag] > 0).all(), "two distinct pieces dependent?"
det3f = (Gii[:, None]*Gii[None, :]*ff + 2*G*h[:, None]*h[None, :] - Gii[:, None]*h[None, :]**2 - Gii[None, :]*h[:, None]**2 - ff*G*G)
iu = np.triu_indices(P, 1)
print("pairs:", len(iu[0]), " pairs with f in span:", int((det3f[iu] == 0).sum()))
# r = 3: for i<j<k with det Gram(g_i,g_j,g_k) != 0 : det Gram(g_i,g_j,g_k,f) != 0 ?
ntrip = 0; ndep = 0; nhit = 0; hits = []
for i in range(P - 2):
    # arrays over (j,k), j,k > i
    a = Gii[i]; J = np.arange(i+1, P)
    b = G[i, J][:, None]; c = G[i, J][None, :]            # G_ij, G_ik
    d = Gii[J][:, None]; e = G[np.ix_(J, J)]; g_ = Gii[J][None, :]   # G_jj, G_jk, G_kk
    hi = h[i]; hj = h[J][:, None]; hk = h[J][None, :]
    # M3 = [[a,b,c],[b,d,e],[c,e,g]]
    det3 = a*(d*g_ - e*e) - b*(b*g_ - e*c) + c*(b*e - d*c)
    # adj(M3) (symmetric)
    A11 = d*g_ - e*e; A12 = c*e - b*g_; A13 = b*e - c*d
    A22 = a*g_ - c*c; A23 = b*c - a*e; A33 = a*d - b*b
    quad = (A11*hi*hi + A22*hj*hj + A33*hk*hk + 2*(A12*hi*hj + A13*hi*hk + A23*hj*hk))
    det4 = det3*ff - quad
    up = np.triu(np.ones((len(J), len(J)), dtype=bool), 1)
    ntrip += int(up.sum())
    dep = (det3 == 0) & up; ndep += int(dep.sum())
    hit = (det4 == 0) & (det3 != 0) & up
    if hit.any():
        nhit += int(hit.sum())
        for jj, kk in zip(*np.nonzero(hit)): hits.append((i, int(J[jj]), int(J[kk])))
print("triples examined:", ntrip, "(= C(1072,3) =", math.comb(P, 3), ")  dependent triples (covered by pair check):", ndep,
      " independent triples with f in span:", nhit, " time %.1fs" % (time.time() - t0))
# sanity of the determinant test itself: plant f' = g_1 + 2 g_5 - g_900 and check the same formula flags it (on a sample)
def det4_of(vs):
    M = np.array([[int(u @ v) for v in vs] for u in vs], dtype=object)
    from flint import fmpz_mat
    return int(fmpz_mat(4, 4, [int(x) for x in M.reshape(-1)]).det())
fp = D64[1] + 2*D64[5] - D64[900]
print("self-test: det Gram(g1,g5,g900,g1+2g5-g900) =", det4_of([D64[1], D64[5], D64[900], fp]), " det Gram(g1,g5,g900,f) =", det4_of([D64[1], D64[5], D64[900], f]))
# exhibit 4 pieces: tensor square of f_1 = 1 - 2 delta_{(1,1)}.  coordinates x = a1 a2 b1 b2 (bits 3,2,1,0)
sol = [dict(basis=(8, 4, 2, 1), offset=0, l=0),          # constant 1
       dict(basis=(4, 1), offset=0b1010, l=0),          # a1=b1=1
       dict(basis=(8, 2), offset=0b0101, l=0),          # a2=b2=1
       dict(basis=(), offset=0b1111, l=0)]
vecs = [piece_vec(n, s['basis'], s['offset'], s['l']) for s in sol]
coef = exact_solve(vecs, f)
print("4-piece representation coefficients (exact):", coef)
for s, c in zip(sol, coef): s['coef'] = str(c)
json.dump(dict(n=4, convention="x=(a,b), a=high 2 bits, b=low 2 bits; piece = coef * (-1)^{popcount(l&x)} * 1[x in offset+span(basis)]; f=(-1)^{a.b}",
               pieces=sol, exhaustive=dict(num_flat_pieces=P, pairs_with_f_in_span=int((det3f[iu] == 0).sum()), triples=ntrip,
               dependent_triples=ndep, independent_triples_with_f_in_span=nhit)), open("N2_certificate.json", "w"), indent=1)
print("N(2) = 4 CONFIRMED" if (len(r1) == 0 and (det3f[iu] == 0).sum() == 0 and nhit == 0 and coef is not None and ntrip == math.comb(P, 3)) else "N(2)=4 NOT confirmed")
