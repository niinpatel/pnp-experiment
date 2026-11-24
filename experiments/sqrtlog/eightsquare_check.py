"""Cross-validation of the rank routine on a case where [A] states exact ranks:
eight-square pieces A_i of Definition 5 (p.17), lambda = 3t, N = 8^t. [A] App. H (p.48):
row rank of A_i = sum_{z<=i} C(t,z) (N0^2-N0)^z N0^(t-z) with N0 = 8; column: same with t-i.
The flattening of a blockwise tensor product is the Kronecker product of the block flattenings
(up to a simultaneous row/column permutation, which preserves rank)."""
import itertools, math
import numpy as np
import flint
from appB_ranks import RC_block, PRIMES

R4 = np.zeros((8, 8, 8, 8), dtype=np.int64)
C4 = np.zeros((8, 8, 8, 8), dtype=np.int64)
for x, y, u, v in itertools.product(range(8), repeat=4):
    R4[x, y, u, v], C4[x, y, u, v] = RC_block(x, y, u, v)
assert ((R4 + C4) == 2 * np.einsum('xv,yu->xyuv', np.eye(8, dtype=np.int64), np.eye(8, dtype=np.int64))).all()

flat = {"row": lambda T: T.reshape(64, 64),                      # (x,y)|(u,v)
        "col": lambda T: T.transpose(0, 2, 1, 3).reshape(64, 64)}  # (x,u)|(y,v)

for t in (1, 2, 3):
    if t == 3:
        break  # 262144 x 262144: too large
    for i in range(t + 1):
        ranks = {}
        for kind, f in flat.items():
            M = np.zeros((64 ** t, 64 ** t), dtype=np.int64)
            for Q in itertools.combinations(range(t), i):
                K = np.ones((1, 1), dtype=np.int64)
                for j in range(t):
                    K = np.kron(K, f(C4 if j in Q else R4))
                M += K
            ranks[kind] = flint.nmod_mat(M.tolist(), PRIMES[0]).rank()
        fr = sum(math.comb(t, z) * 56 ** z * 8 ** (t - z) for z in range(i + 1))
        fc = sum(math.comb(t, z) * 56 ** z * 8 ** (t - z) for z in range(t - i + 1))
        print(f"t={t} i={i}: row rank {ranks['row']} (paper {fr}); col rank {ranks['col']} (paper {fc})")
        assert ranks["row"] == fr and ranks["col"] == fc
print("eight-square cross-validation: OK")
