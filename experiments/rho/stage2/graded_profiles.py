"""Stage 2: counted rho of App.-B-shape pieces for free-field vertex algebras with character
prod_n (1-q^n)^{-c_n}.  Convention = experiments/sqrtlog/recursion.py appB_profile:
D(E)=log2 sum_{j<=E} dim V_j, h least with D(h)>=lam, windows W=H=2h (forced, see STAGE2_GRADED.md),
rho = max_s [D(2h+s)+D(2h-s)]/(4 lam).  Also reports doubling ratio D(2h)/D(h) and 2^(a-1).
Counts = exp(sum_n sigma(n) q^n / n), sigma(n)=sum_{k|n} k c_k
(exact integers via flint fmpq_series.exp)."""
import math, sys
import numpy as np


def exact_counts(c, N):
    """exact dim V_n (n<=N) of prod_k (1-q^k)^{-c_k} via flint fmpq_series exp of sum sigma(n) q^n/n."""
    import flint
    flint.ctx.cap = N + 2
    sig = [0] * (N + 2)
    for k in range(1, N + 2):
        ck = c(k)
        if ck:
            for m in range(k, N + 2, k):
                sig[m] += k * ck
    s = flint.fmpq_series([0] + [flint.fmpq(int(sig[n]), n) for n in range(1, N + 2)], prec=N + 2)
    e = s.exp()
    return [int(e[i]) for i in range(N + 1)]


def log2int(x):
    b = x.bit_length()
    if b <= 60:
        return math.log2(x)
    return (b - 60) + math.log2(x >> (b - 60))


def cumD_of(c, N):
    a = exact_counts(c, N)
    out, acc = [], 0
    for v in a:
        acc += v
        out.append(log2int(acc))
    return np.array(out)


def rho_counted(D, lam):
    hs = np.nonzero(D >= lam)[0]
    if len(hs) == 0:
        return None
    h = int(hs[0])
    if 4 * h >= len(D):
        return None
    best = max(D[2 * h + s] + D[2 * h - s] for s in range(-2 * h, 2 * h + 1))
    return h, best / (4 * lam), D[2 * h] / D[h]


if __name__ == "__main__":
    fams = [("partitions c=1 (control)", lambda k: 1, 0.5, 50000),
            ("3-coloured c=3", lambda k: 3, 0.5, 20000),
            ("24-coloured c=24", lambda k: 24, 0.5, 8000),
            ("MacMahon c_n=n (plane partitions)", lambda k: k, 2 / 3, 7000),
            ("c_n=C(n+1,2) (d=3 free-field)", lambda k: k * (k + 1) // 2, 3 / 4, 3000),
            ("c_n=C(n+2,3) (d=4 free-field)", lambda k: k * (k + 1) * (k + 2) // 6, 4 / 5, 2000)]
    lams = [20, 50, 100, 200, 400, 800]
    for name, c, a, N in fams:
        D = cumD_of(c, N)
        print(f"\n{name}: limit 2^(a-1) = {2 ** (a - 1):.4f} (a={a:.3f})", flush=True)
        for lam in lams:
            r = rho_counted(D, lam)
            if r is None:
                break
            h, rho, dr = r
            print(f"  lam={lam:4d} h={h:6d} rho_counted={rho:.4f} D(2h)/D(h)={dr:.4f} "
                  f"(ratio/2={dr / 2:.4f})", flush=True)
    print("\nrank-N Heisenberg (N-coloured partitions), N free (may depend on lam): min over N")
    for lam in [50, 100, 200, 400]:
        best = None
        for N in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 4096, 16384,
                  2 ** 16, 2 ** 20, 2 ** 24, 2 ** 30, 2 ** 40]:
            M = 400
            while True:
                D = cumD_of(lambda k: N, M)
                r = rho_counted(D, lam)
                if r is not None:
                    break
                M *= 2
            h, rho, dr = r
            print(f"  lam={lam:4d} N={N:14d} h={h:6d} rho={rho:.4f} D(2h)/D(h)={dr:.4f}", flush=True)
            if best is None or rho < best[1]:
                best = (N, rho)
        print(f"  -> lam={lam}: min rho over N = {best[1]:.4f} at N={best[0]}", flush=True)
