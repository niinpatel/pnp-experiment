"""Sanity checks for where the exponent 1/2 in 2^{O(m/sqrt(log m))} comes from.

All recursions are tracked in x = log2 K (K itself overflows).
Sources: Anthropic, "A 2^{o(n)} time algorithm for 3-SAT" (Oct 2026):
  main text (6)-(11), p.7-8; Theorem A (40) and end of Appendix A, p.28-29.
Majdoddin arXiv:2610.41622, Prop. 4.24 (p.48).
"""
import math


def thmA(rho, x0=18, L=14):
    """Theorem A (40): K0=2^x0, zeta_l=2^{-l-5}, g_l=2^{3l+x0} K_l, K_{l+1}=g_l^2,
    e0=1/2, e_{l+1}=(rho+3 zeta_l) e_l + 3/K_l."""
    x, e, out = x0, 0.5, []
    for l in range(L):
        out.append((l, x, e))
        zeta = 2.0 ** (-l - 5)
        e = (rho + 3 * zeta) * e + 3 * 2.0 ** (-x)
        x = 2 * (3 * l + x0 + x)
    return out


def check_thmA():
    for rho in (11 / 12, 2 ** -0.5):
        x0 = 18
        for l, x, e in thmA(rho, x0):
            closed = (3 * x0 + 6) * 2 ** l - 6 * l - 2 * x0 - 6
            assert x == closed, (l, x, closed)
            assert 0.5 * rho ** l <= e <= 0.85 * rho ** l + 1e-15, (rho, l, e)
    # end of App. A: k=3, rho=1/sqrt2: need 2^l > (k r)^2, log m >= 9 log K_l >= 9(60*2^l-6l-42)
    for r, l_claim, logm_claim in ((1, 4, 8000), (5, 8, 1.3e5)):
        l = next(l for l in range(40) if 2 ** l > (3 * r) ** 2)
        bound = 9 * (60 * 2 ** l - 6 * l - 42)
        assert l == l_claim and bound > logm_claim, (r, l, bound)
        print(f"  App.A end: r={r}: l>={l}, log2 m >= {bound}  (paper: l>={l_claim}, >{logm_claim:g})")
    print("Theorem A(a) closed form and 1/2 rho^l <= e_l <= 0.85 rho^l: OK")


def check_main_text():
    """(9): K0=64, K_l=9K_{l-1}^16, e_l=(11/12+2/K)e_{l-1}+5/K; (11) e_l<=1.12(11/12)^l."""
    x, e = 6.0, 1.0
    for l in range(1, 8):
        K_inv = 2.0 ** (-x)
        e = (11 / 12 + 2 * K_inv) * e + 5 * K_inv
        x = math.log2(9) + 16 * x
        if l == 1:
            print(f"  main text e1 = {e:.4f} (paper: 11/12+7/64 = {11/12+7/64:.4f})")
        assert e <= 1.12 * (11 / 12) ** l + 1e-12
    print("main-text bound (11) e_l <= 1.12 (11/12)^l: OK")


def general(rho, c, delta, x0=18.0, L=30, b=0.0):
    """x_{l+1} = c x_l + b ;  e_{l+1} = rho e_l + delta(x_l). Returns list of (x, e)."""
    x, e, out = x0, 0.5, []
    for _ in range(L):
        out.append((x, e))
        e = rho * e + delta(x)
        x = c * x + b
    return out


def fitted_alpha(traj, skip=10):
    (x1, e1), (x2, e2) = traj[skip], traj[-1]
    return -(math.log(e2) - math.log(e1)) / (math.log(x2) - math.log(x1))


def sweep():
    print("\nalpha' = -dlog e / dlog log K, fitted vs formula log(1/rho)/log c")
    print(f"{'rho':>8} {'c':>4} {'additive':>14} {'fit':>8} {'formula':>8}")
    adds = {
        "3/K": lambda x: 3 * 2.0 ** (-x) if x < 1000 else 0.0,
        "1/K^2": lambda x: 2.0 ** (-2 * x) if x < 1000 else 0.0,
        "1/sqrt(K)": lambda x: 2.0 ** (-x / 2) if x < 2000 else 0.0,
        "1/log K": lambda x: 1.0 / x,
    }
    for rho in (11 / 12, 0.9, 2 ** -0.5, 2 / 3, 5 / 8, 0.5):
        for c in (16, 2, 1.5):
            for name, d in adds.items():
                if name in ("1/K^2", "1/sqrt(K)") and not (c == 2 and rho == 2 ** -0.5):
                    continue
                if name == "1/log K" and c != 2:
                    continue
                L = 18 if c == 16 else 60
                tr = general(rho, c, d, L=L, b=0)
                tr = [(x, e) for x, e in tr if math.isfinite(x)]
                f = fitted_alpha(tr, skip=len(tr) // 2)
                print(f"{rho:8.4f} {c:4} {name:>14} {f:8.4f} {math.log(1/rho)/math.log(c):8.4f}")


def appB_profile(lam_list=(20, 50, 100, 200, 400, 800)):
    """Counted rho of App. B pieces in Majdoddin's 'shape' (Prop. 4.24): D(E)=log2 sum_{j<=E} p(j),
    h least with D(h)>=lam, W=H=2h, rho_B = max_s [D(s+2h)+D(2h-s)]/(4 lam). Ignores o(lam) terms."""
    N = 40000
    p = [0] * (N + 1)
    p[0] = 1
    for part in range(1, N + 1):
        for n in range(part, N + 1):
            p[n] += p[n - part]
    cum, D = 0, []
    for n in range(N + 1):
        cum += p[n]
        D.append(math.log2(cum))
    print("\nApp. B counted rho in Majdoddin's shape (tends to 1/sqrt2 = 0.7071):")
    for lam in lam_list:
        h = next(E for E in range(N) if D[E] >= lam)
        if 4 * h > N:
            break
        best = max(D[s + 2 * h] + D[2 * h - s] for s in range(-2 * h, 2 * h + 1))
        print(f"  lam={lam:5d} h={h:6d} rho_B={best/(4*lam):.4f}")


def power_profiles():
    print("\nPower profile D(E)=c E^a: rho_B >= max(2^(a-1), 2^(-a)) (Majdoddin Prop 4.24) -> alpha'=log2(1/rho)")
    for a in (0.25, 1 / 3, 0.4, 0.5, 0.6, 2 / 3, 0.75):
        rho = max(2 ** (a - 1), 2 ** (-a))
        print(f"  a={a:.3f}: rho>={rho:.4f}, alpha'<={math.log2(1/rho):.4f}")
    for rho, why in ((2 / 3, "concave-profile floor"), (5 / 8, "window H=h"), (0.5, "ideal pieces")):
        print(f"  rho={rho:.4f} ({why}): alpha' = {math.log2(1/rho):.4f}")


def grid_shape_check():
    """(our derivation, heuristic) a x b grid, rectangle diagonals dominate (t ~ 1), App. B pieces
    with counted row/col fractions R=sqrt(2+sig)/2, C=sqrt(2-sig)/2 (sig=s/h in [-2,2]).
    Worst term (uniform sig is worst by concavity) costs max_sig min(x1 R, x2 C), x1=e(a), x2=e(b).
    Claim: 1/e(ab)^2 = 1/e(a)^2 + 1/e(b)^2, so e(K)=Theta(1/sqrt(log K)) for every grid shape."""
    import random
    worst = 0.0
    for _ in range(200):
        x1, x2 = random.uniform(0.01, 1), random.uniform(0.01, 1)
        v = max(min(x1 * math.sqrt(2 + s) / 2, x2 * math.sqrt(2 - s) / 2)
                for s in [-2 + 4 * i / 200000 for i in range(200001)])
        worst = max(worst, abs(1 / v ** 2 - (1 / x1 ** 2 + 1 / x2 ** 2)) / (1 / v ** 2))
    print(f"\ngrid-shape check: max rel. error of 1/e(ab)^2 = 1/e(a)^2+1/e(b)^2 over 200 random (x1,x2): {worst:.2e}")


if __name__ == "__main__":
    check_thmA()
    check_main_text()
    sweep()
    power_profiles()
    appB_profile()
    grid_shape_check()
