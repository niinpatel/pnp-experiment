"""Transfer gap AT E = 2h* for c_n = N[n>=w], N ~ 2^lam * 2/w (h* lands mid-plateau ~1.5w)."""
import math, sys
sys.path.insert(0, '/mnt/data/rho/referee')
from stepped import counts, cumD, S_nats
for lam, w in [(60, 40), (120, 80), (200, 120)]:
    N = int(2 ** lam * 2 // w)
    c = lambda n, N=N, w=w: N if n >= w else 0
    a = counts(c, 4 * w + 4)
    D = cumD(a)
    h = next(E for E in range(len(D)) if D[E] >= lam)
    s2 = S_nats(2 * h, c, 8 * w) / math.log(2)
    print(f"lam={lam} w={w} N=2^{math.log2(N):.1f}: h*={h} D(h*)={D[h]:.1f} D(2h*)={D[2*h]:.1f} "
          f"S(2h*)={s2:.1f} bits gap={s2 - D[2*h]:.1f}  D(2h*)/lam={D[2*h]/lam:.3f}", flush=True)
