# Build seeded initial tuples: (1) b=3: every 8-solution of the pool with one piece dropped; (2) b=4: tensor products of two b=2 4-solutions with one piece dropped.
import numpy as np, itertools
from common import *
rnd = np.random.default_rng(3)
pool = np.load("ls2_b3r8pool_sols.npy")            # (nsol, 8, 3)
init7 = np.array([np.delete(s, i, axis=0) for s in pool for i in range(8)], dtype=np.int32)
np.save("init7.npy", init7); print("init7:", init7.shape)
# b=4 table lookup
z = np.load("subs8.npz"); kdim = z['kdim']; bas = z['bas']; n = 8
key = {}
for i in range(len(kdim)):
    k = int(kdim[i]); key[tuple(int(x) for x in bas[i, :k])] = i
def rref(basis):
    rows = []
    for v in basis:
        for r_ in rows:
            if v & (1 << (r_.bit_length()-1)): v ^= r_
        if v:
            # eliminate new pivot from existing rows
            pb = 1 << (v.bit_length()-1)
            rows = [r_ ^ v if r_ & pb else r_ for r_ in rows]
            rows.append(v); rows.sort(reverse=True)
    return rows
def to_triple(basis, offset, l):
    rows = rref(list(basis)); sub = key[tuple(rows)]; k = len(rows)
    for r_ in rows:
        if offset & (1 << (r_.bit_length()-1)): offset ^= r_
    comp = [int(x) for x in bas[sub, k:n]]
    c = 0
    for i, cv in enumerate(comp):
        if offset & cv: c |= 1 << i; offset ^= cv
    assert offset == 0
    s = 0
    for i, r_ in enumerate(rows):
        if popc(l & r_) & 1: s |= 1 << i
    return (sub, c, s)
pieces2, D2 = flat_pieces(4); sols2 = np.load("b2_all4.npy")
def emb(v, blk):   # 4-bit (a1 a2 b1 b2) -> 8-bit (a1 a2 a3 a4 b1 b2 b3 b4)
    a = (v >> 2) & 3; b_ = v & 3
    return (a << 6) | (b_ << 2) if blk == 0 else (a << 4) | b_
f4 = fvec(4); init15 = []; full16 = []
for t in range(40):
    s1 = sols2[rnd.integers(len(sols2))]; s2 = sols2[rnd.integers(len(sols2))]
    prod = []
    for i in s1:
        for j in s2:
            p, q = pieces2[int(i)], pieces2[int(j)]
            prod.append((tuple(emb(v, 0) for v in p['basis']) + tuple(emb(v, 1) for v in q['basis']), emb(p['offset'], 0) ^ emb(q['offset'], 1), emb(p['l'], 0) ^ emb(q['l'], 1)))
    if t < 3:
        assert exact_solve([piece_vec(8, *pp) for pp in prod], f4) is not None
    tr = [to_triple(*pp) for pp in prod]
    full16.append(tr)
    for i in range(16): init15.append([x for kk, x in enumerate(tr) if kk != i])
np.save("init15.npy", np.array(init15, dtype=np.int32)); np.save("full16.npy", np.array(full16, dtype=np.int32))
print("init15:", np.array(init15).shape, " (tensor products verified exactly as 16-piece representations of f_4)")
