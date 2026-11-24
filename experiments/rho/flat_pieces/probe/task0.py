# Task 0: sanity check of the Bell-diagonal reduction at t=1,2 (and scheme pieces to t=4), exact ranks via flint.
import itertools, random, math
import numpy as np
from flint import fmpz_mat
random.seed(1)

def rank_exact(M):
    M = np.asarray(M)
    return fmpz_mat(M.shape[0], M.shape[1], [int(v) for v in M.reshape(-1)]).rank()

X = np.array([[0,1],[1,0]], dtype=np.int64); Z = np.array([[1,0],[0,-1]], dtype=np.int64); I2 = np.eye(2, dtype=np.int64)
def kron_list(ms):
    out = np.array([[1]], dtype=np.int64)
    for m in ms: out = np.kron(out, m)
    return out
def pauli(a, b):  # real Pauli X^a Z^b on t qubits, a,b bit tuples
    return kron_list([np.linalg.matrix_power(X, ai) @ np.linalg.matrix_power(Z, bi) for ai, bi in zip(a, b)])

def run(t, trials):
    N = 2**t
    pts = [(a, b) for a in itertools.product((0,1), repeat=t) for b in itertools.product((0,1), repeat=t)]
    idx = {p: i for i, p in enumerate(pts)}
    phi = np.eye(N, dtype=np.int64).reshape(N*N)       # unnormalised |Phi+> = sum_x |x,x>, norm^2 = N
    bell = [np.kron(pauli(a, b), np.eye(N, dtype=np.int64)) @ phi for (a, b) in pts]   # (R_q x I)|Phi+>
    # orthogonality
    Gm = np.array([[int(u @ v) for v in bell] for u in bell]); assert (Gm == N*np.eye(N*N, dtype=np.int64)).all()
    proj = [np.outer(v, v) for v in bell]  # N * projector
    def omega(p, q): return (sum(x*y for x, y in zip(p[0], q[1])) + sum(x*y for x, y in zip(p[1], q[0]))) % 2
    def dot(p, q):   return (sum(x*y for x, y in zip(p[0], q[0])) + sum(x*y for x, y in zip(p[1], q[1]))) % 2
    def op_from_g(g):   # returns N*A as integer matrix, A = sum_q g(q)|Phi_q><Phi_q| (normalised projectors)
        return sum(int(g[i]) * proj[i] for i in range(N*N))
    def realign(A):     # A[(x,y),(u,v)] -> R[(x,u),(y,v)]
        return A.reshape(N, N, N, N).transpose(0, 2, 1, 3).reshape(N*N, N*N)
    def sft(g):         # symplectic Fourier transform  ghat_s(p) = sum_q g(q) (-1)^{omega(p,q)}
        return np.array([sum(int(g[idx[q]]) * (-1)**omega(p, q) for q in pts) for p in pts])
    def wht(g):         # standard WHT ghat(p) = sum_q g(q) (-1)^{p.q}
        return np.array([sum(int(g[idx[q]]) * (-1)**dot(p, q) for q in pts) for p in pts])
    # SWAP check
    SW = np.zeros((N*N, N*N), dtype=np.int64)
    for x in range(N):
        for y in range(N): SW[x*N+y, y*N+x] = 1          # entry [(x,y),(u,v)] = [x=v][y=u]
    fb = np.array([(-1)**(sum(x*y for x, y in zip(a, b)) % 2) for (a, b) in pts])
    assert (op_from_g(fb) == N*SW).all(), "SWAP is not the Bell-diagonal operator of f"
    assert (sft(fb) == N*fb).all()
    ok = True; nt = 0
    def check(g):
        nonlocal ok, nt
        A = op_from_g(g)
        rr = rank_exact(A); cr = rank_exact(realign(A))
        gs = sft(g); gw = wht(g)
        # relabelling: sft(g)(a,b) = wht(g)(b,a)
        relab = all(gs[idx[(a, b)]] == gw[idx[(b, a)]] for (a, b) in pts)
        # explicit expansion A = (1/N^2) sum_p sft(g)(p) R_p x R_p   -> N*A*N = sum ...
        E = sum(int(gs[idx[p]]) * np.kron(pauli(*p), pauli(*p)) for p in pts)
        good = (rr == np.count_nonzero(g)) and (cr == np.count_nonzero(gs)) and relab and (E == N*A).all()
        ok &= good; nt += 1
        return rr, cr, int(np.count_nonzero(g)), int(np.count_nonzero(gs))
    # random supports of every size, random integer values
    for s in range(0, N*N+1):
        for _ in range(trials):
            g = np.zeros(N*N, dtype=np.int64)
            for i in random.sample(range(N*N), s): g[i] = random.choice([-3,-2,-1,1,2,3,5])
            check(g)
    # flat pieces and random combos of few flat pieces (small Fourier supports)
    n = 2*t
    vecs = list(range(1, 2**n))
    def span(basis):
        S = {0}
        for bv in basis: S |= {s ^ bv for s in S}
        return S
    def flat():
        k = random.randint(0, n); basis = []
        while len(basis) < k:
            v = random.choice(vecs)
            if v not in span(basis): basis.append(v)
        off = random.randrange(2**n); l = random.randrange(2**n)
        g = np.zeros(N*N, dtype=np.int64)
        for s in span(basis):
            xx = s ^ off; g[xx] = (-1)**(bin(xx & l).count('1') % 2)
        return g
    stats = []
    for _ in range(40*trials):
        g = sum(random.choice([-2,-1,1,2,3]) * flat() for _ in range(random.randint(1, 3)))
        stats.append(check(g))
    print(f"t={t}: {nt} operators tested, all four identities hold: {ok}; sample (rowrank, colrank, |supp g|, |supp ghat|):", stats[:6])
    return ok

ok1 = run(1, 30); ok2 = run(2, 12)

# single-bit scheme of [A] App. H:  [x=v][y=u] = [x=u][y=v] - [x!=y](-1)^x [u!=v](-1)^u
R1 = np.zeros((4,4), dtype=np.int64); C1 = np.zeros((4,4), dtype=np.int64); S1 = np.zeros((4,4), dtype=np.int64)
for x, y, u, v in itertools.product((0,1), repeat=4):
    R1[2*x+y, 2*u+v] = int(x == u and y == v)
    C1[2*x+y, 2*u+v] = -int(x != y) * (-1)**x * int(u != v) * (-1)**u
    S1[2*x+y, 2*u+v] = int(x == v and y == u)
assert (R1 + C1 == S1).all()
print("single-bit identity R + C = crossing: OK; ranks row/col: R", rank_exact(R1), rank_exact(R1.reshape(2,2,2,2).transpose(0,2,1,3).reshape(4,4)),
      " C", rank_exact(C1), rank_exact(C1.reshape(2,2,2,2).transpose(0,2,1,3).reshape(4,4)))
def tens(ms):   # tensor product of t two-site operators, regrouped as [(x,y),(u,v)] with x=(x1..xt) etc.
    t = len(ms)
    T = ms[0].reshape(2,2,2,2)
    for m in ms[1:]:
        T = np.tensordot(T, m.reshape(2,2,2,2), axes=0)
    # axes: (x1,y1,u1,v1,x2,y2,u2,v2,...) -> (x1..xt,y1..yt,u1..ut,v1..vt)
    perm = [4*s+0 for s in range(t)] + [4*s+1 for s in range(t)] + [4*s+2 for s in range(t)] + [4*s+3 for s in range(t)]
    return T.transpose(perm).reshape(4**t, 4**t)
allok = True
for t in range(1, 5):
    N = 2**t; rows = []
    tot = np.zeros((4**t, 4**t), dtype=np.int64)
    for i in range(t+1):
        A = np.zeros((4**t, 4**t), dtype=np.int64)
        for Q in itertools.combinations(range(t), i):
            A += tens([C1 if s in Q else R1 for s in range(t)])
        tot += A
        rr = rank_exact(A); cr = rank_exact(A.reshape(N,N,N,N).transpose(0,2,1,3).reshape(N*N,N*N))
        prr = sum(math.comb(t, z) * 3**(t-z) for z in range(i, t+1))    # number of Bell-points with >= i singlet coordinates
        pcr = sum(math.comb(t, z) * 3**z for z in range(0, i+1))        # Fourier points with <= i nonzero coordinates
        allok &= (rr == prr and cr == pcr)
        rows.append((i, rr, cr, prr, pcr, round((math.log2(rr)+math.log2(cr))/(4*t), 4)))
    SWt = tens([S1]*t)
    assert (tot == SWt).all()
    print(f"t={t}: sum A_i = crossing OK; (i, rowrank, colrank, predicted row, predicted col, (c_row+c_col)/4t):", rows)
print("scheme ranks match sum_{z>=i} C(t,z)3^(t-z) and sum_{z<=i} C(t,z)3^z:", allok)
# asymptotic rho of the scheme (cumulative sums, exact big ints)
for t in (40, 400, 2000):
    row = [0]*(t+2); col = [0]*(t+2)
    for z in range(t, -1, -1): row[z] = row[z+1] + math.comb(t, z) * 3**(t-z)
    acc = 0
    for z in range(0, t+1): acc += math.comb(t, z) * 3**z; col[z] = acc
    best = max((math.log2(row[i]) + math.log2(col[i]))/(4*t) for i in range(t+1))
    print("t", t, "max_i (log2 rowrank + log2 colrank)/(4t) =", round(best, 5), " log2(12)/4 =", round(math.log2(12)/4, 5))
print("REDUCTION OK" if (ok1 and ok2 and allok) else "REDUCTION FAILED")
