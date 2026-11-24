"""Referee checks for STAGE2_GRADED.md Lemma L / transfer, on stepped (lambda-dependent) nondecreasing c_n.
Exact dim V_n of prod_n (1-q^n)^{-c_n} via Euler transform with Python ints.
Reports: h* = min E with D(E) >= lam (D = log2 cumulative), r = D(2h*)/lam (need >= sqrt2),
counted rho (App.-B windows), and S(E) - ln dimV_{<=E} at chosen E (transfer gap)."""
import math, random, sys


def counts(c, Emax):
    sig = [0] * (Emax + 1)
    for d in range(1, Emax + 1):
        cd = c(d)
        if cd:
            for m in range(d, Emax + 1, d):
                sig[m] += d * cd
    a = [1] + [0] * Emax
    for n in range(1, Emax + 1):
        s = 0
        for k in range(1, n + 1):
            s += sig[k] * a[n - k]
        assert s % n == 0
        a[n] = s // n
    return a


def log2i(x):
    b = x.bit_length()
    return math.log2(x) if b <= 60 else (b - 60) + math.log2(x >> (b - 60))


def cumD(a):
    out, acc = [], 0
    for v in a:
        acc += v
        out.append(log2i(acc))
    return out


def S_nats(E, c, K):
    # min_theta theta*E + sum_n c_n * -ln(1-e^{-theta n}), n<=K (truncation only lowers F; fine for K >> E)
    def g(th):
        tot = th * E
        for n in range(1, K + 1):
            cn = c(n)
            if cn:
                x = th * n
                if x > 700:
                    break
                tot += cn * -math.log1p(-math.exp(-x)) if x > 1e-12 else float('inf')
        return tot
    lo, hi = 1e-6, 50.0
    for _ in range(120):
        m1, m2 = lo + (hi - lo) / 3, hi - (hi - lo) / 3
        if g(m1) < g(m2):
            hi = m2
        else:
            lo = m1
    return g((lo + hi) / 2)


def analyse(c, lam, Emax):
    a = counts(c, Emax)
    D = cumD(a)
    hs = [E for E in range(len(D)) if D[E] >= lam]
    if not hs:
        return None
    h = hs[0]
    if 4 * h > Emax:
        return None
    r = D[2 * h] / lam
    rho = max(D[2 * h + s] + D[2 * h - s] for s in range(-2 * h, 2 * h + 1)) / (4 * lam)
    return h, r, rho, D


if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "gap":
        # transfer gap for c_n = N [n >= w]
        for lam, w in [(60, 40), (120, 80), (240, 160)]:
            N = 2 ** lam
            c = lambda n, N=N, w=w: N if n >= w else 0
            a = counts(c, 2 * w + 2)
            D = cumD(a)
            for E in [w, 2 * w - 1, 2 * w]:
                s = S_nats(E, c, 4 * w)
                print(f"lam={lam} w={w} E={E}: S/ln2={s / math.log(2):8.2f} bits, D={D[E]:8.2f} bits, gap={s / math.log(2) - D[E]:7.2f} bits")
    elif mode == "search":
        lam = int(sys.argv[2]); trials = int(sys.argv[3]); seed = int(sys.argv[4])
        random.seed(seed)
        worst = None
        for t in range(trials):
            k = random.randint(1, 3)
            ws = sorted(random.sample(range(1, 120), k))
            ls = sorted(random.uniform(0, 1.2 * lam) for _ in range(k))
            ms = [max(1, int(2 ** l)) for l in ls]
            if random.random() < 0.5:
                ws[0] = 1
            def c(n, ws=ws, ms=ms):
                v = 0
                for wi, mi in zip(ws, ms):
                    if n >= wi:
                        v = mi
                return v
            Emax = 600
            res = analyse(c, lam, Emax)
            if res is None:
                continue
            h, r, rho, _ = res
            if worst is None or r < worst[0]:
                worst = (r, rho, h, ws, [round(l, 1) for l in ls])
                print(f"new worst r=D(2h*)/lam={r:.4f} rho={rho:.4f} h*={h} steps w={ws} log2 c={worst[4]}", flush=True)
        print("final worst", worst)
    elif mode == "fam":
        lam = int(sys.argv[2])
        print(f"c_n = N[n>=w], lam={lam}")
        for beta in [0.3, 0.5, 0.7, 0.9, 1.0]:
            for w in [5, 20, 60]:
                N = max(1, int(2 ** (beta * lam)))
                res = analyse(lambda n: N if n >= w else 0, lam, 1500)
                if res:
                    h, r, rho, _ = res
                    print(f"  beta={beta} w={w}: h*={h} r={r:.4f} rho={rho:.4f}", flush=True)
        print(f"c_n = 1 (n<w), N (n>=w), lam={lam}")
        for beta in [0.3, 0.5, 0.7, 0.9]:
            for w in [5, 20, 60, 150]:
                N = max(1, int(2 ** (beta * lam)))
                res = analyse(lambda n: N if n >= w else 1, lam, 2500)
                if res:
                    h, r, rho, _ = res
                    print(f"  beta={beta} w={w}: h*={h} r={r:.4f} rho={rho:.4f}", flush=True)
