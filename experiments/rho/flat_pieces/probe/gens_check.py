# Validate the symmetry generators used for orbit reduction: (a) each generator permutation maps every known 8-piece solution to a set whose
# span contains f (rank mod p of [g's; f] = 8, and exact rational solve on a sample); (b) mp+md constant on orbits; (c) generators are permutations.
import pickle, ctypes, numpy as np
from common import *
z = np.load("dict3.npz"); D = np.ascontiguousarray(z['D'].astype(np.int8)); orb = z['orb']; mp_ = z['mp']; md = z['md']; P = D.shape[0]
gens = pickle.load(open("gens3.pkl", "rb"))['gens']
f8 = np.ascontiguousarray(fvec(3).astype(np.int8)); f = fvec(3)
L = ctypes.CDLL('/mnt/data/review/abelian/libexcl2.so'); vp = ctypes.c_void_p
sols = np.load("ls_b3r8cal_sols.npy").astype(np.int32)
bad = 0; tested = 0; exact_ok = 0; exact_n = 0; notperm = 0
for name, pm in gens:
    if len(np.unique(pm)) != P: notperm += 1
    for si, s in enumerate(sols):
        img = np.ascontiguousarray(pm[s].astype(np.int32)); tested += 1
        rk = int(L.rank_test(vp(D.ctypes.data), vp(f8.ctypes.data), vp(img.ctypes.data), ctypes.c_int(8)))
        if rk != 8: bad += 1
        if si < 3:
            exact_n += 1
            if exact_solve([D[int(i)].astype(np.int64) for i in img], f) is not None: exact_ok += 1
pc = mp_ + md
const_pc = all(len(set(pc[orb == r].tolist())) == 1 for r in set(orb.tolist()))
swap = all({(int(a), int(b)) for a, b in zip(mp_[orb == r], md[orb == r])} <= {(int(mp_[r]), int(md[r])), (int(md[r]), int(mp_[r]))} for r in set(orb.tolist()))
print(f"generators: {len(gens)} ({sum(1 for n_, _ in gens if n_.startswith('refl'))} reflections, {sum(1 for n_, _ in gens if n_.startswith('trans'))} twisted translations, 1 Fourier); non-permutations: {notperm}")
print(f"images of {len(sols)} known 8-solutions under each generator: {tested} tested, rank!=8 (f not in span mod p): {bad}; exact rational solve OK on sample: {exact_ok}/{exact_n}")
print("mp+md constant on every orbit:", const_pc, "; (mp,md) on each orbit equals the representative's pair up to swap:", swap)
