"""HEURISTIC extrapolation only. Assumes the empirical deficit law fitted in deficit_analysis.py
(rank_row(s) = R_row(s) - sum_{w<=s+h} p(w) - [s+h>=1], rank_col(s) = rank_row(-s)) holds for all h,
ignores the N^2 cap, and compares the implied worst-piece rho with the counted rho of (54)-(55):
rho = max_s (log2 r_row + log2 r_col) / (4 log2 p(h)). Both tend to 1/sqrt2 only slowly (lower-order terms)."""
import math

H = 3000
pp = [1] + [0] * (4 * H + 1)
for part in range(1, 4 * H + 2):
    for j in range(part, 4 * H + 2):
        pp[j] += pp[j - part]
cum = [0] * (4 * H + 2)
acc = 0
for w in range(4 * H + 2):
    acc += pp[w]
    cum[w] = acc


def C(n):
    return cum[n] if n >= 0 else 0


print("   h   rho_counted   rho_rank_law   (log2 R - log2 rank) at s=0")
for h in (8, 16, 32, 64, 128, 256, 512, 1024, 2048, 3000):
    lam = math.log2(pp[h])
    best_c = best_r = 0.0
    for s in range(-2 * h, 2 * h + 1):
        Rr, Rc = C(s + 2 * h), C(2 * h - s)
        rr = Rr - (C(s + h) + (s + h >= 1) if s + h >= 0 else 0)
        rc = Rc - (C(-s + h) + (-s + h >= 1) if -s + h >= 0 else 0)
        best_c = max(best_c, math.log2(Rr) + math.log2(Rc))
        best_r = max(best_r, math.log2(max(rr, 1)) + math.log2(max(rc, 1)))
    gap0 = math.log2(C(2 * h)) - math.log2(C(2 * h) - C(h) - 1)
    print(f"{h:5d}   {best_c/(4*lam):.5f}       {best_r/(4*lam):.5f}        {gap0:.2e}")
print("1/sqrt2 =", 2 ** -0.5)
