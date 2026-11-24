# Test of "energy capture" pattern: min over r flat pieces of dist^2(f_b, span) versus 4^b - r*2^b.
# b=2: exhaustive and exact for r=1,2,3 (ratios of integer Gram determinants).  b=3: local search (heuristic upper bounds on the min).
import numpy as np, math, subprocess, json
from fractions import Fraction
from common import *
pieces, D = flat_pieces(4); P = len(pieces); f = fvec(2); D64 = D.astype(np.int64)
G = D64 @ D64.T; h = D64 @ f; ff = 16; Gii = np.diag(G)
# r=1
best1 = min(Fraction(int(ff*Gii[i] - h[i]*h[i]), int(Gii[i])) for i in range(P))
# r=2
det2 = Gii[:, None]*Gii[None, :] - G*G
det3f = (Gii[:, None]*Gii[None, :]*ff + 2*G*h[:, None]*h[None, :] - Gii[:, None]*h[None, :]**2 - Gii[None, :]*h[:, None]**2 - ff*G*G)
iu = np.triu_indices(P, 1)
ratio = det3f[iu] / det2[iu]; k = int(np.argmin(ratio)); best2 = Fraction(int(det3f[iu][k]), int(det2[iu][k]))
# r=3
best3 = None
for i in range(P - 2):
    a = Gii[i]; J = np.arange(i+1, P)
    b = G[i, J][:, None]; c = G[i, J][None, :]; d = Gii[J][:, None]; e = G[np.ix_(J, J)]; g_ = Gii[J][None, :]
    hi = h[i]; hj = h[J][:, None]; hk = h[J][None, :]
    det3 = a*(d*g_ - e*e) - b*(b*g_ - e*c) + c*(b*e - d*c)
    A11 = d*g_ - e*e; A12 = c*e - b*g_; A13 = b*e - c*d; A22 = a*g_ - c*c; A23 = b*c - a*e; A33 = a*d - b*b
    det4 = det3*ff - (A11*hi*hi + A22*hj*hj + A33*hk*hk + 2*(A12*hi*hj + A13*hi*hk + A23*hj*hk))
    up = np.triu(np.ones((len(J), len(J)), dtype=bool), 1) & (det3 != 0)
    if not up.any(): continue
    rt = np.where(up, det4 / np.where(det3 == 0, 1, det3), np.inf)
    idx = np.unravel_index(np.argmin(rt), rt.shape)
    cand = Fraction(int(det4[idx]), int(det3[idx]))
    if best3 is None or cand < best3: best3 = cand
print("b=2 exhaustive exact min dist^2(f, span of r pieces): r=1:", best1, " r=2:", best2, " r=3:", best3, "  (4^b - r 2^b = 12, 8, 4)")
