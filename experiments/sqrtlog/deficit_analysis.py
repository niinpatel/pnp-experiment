"""Parse appB_scale_*.out and tabulate rank deficits in the UNSATURATED regime (counted R < N^2),
the only regime where a rank-vs-count gap is informative. Usage: python3 deficit_analysis.py FILE..."""
import sys, re, math

rows = []
for fn in sys.argv[1:]:
    h = N = None
    for line in open(fn):
        mh = re.match(r"h=(\d+) N=p\(h\)=(\d+)", line)
        if mh:
            h, N = int(mh.group(1)), int(mh.group(2))
            continue
        mr = re.match(r"\s+(-?\d+) \|\s+(\d+)\s+(\d+)\s+(\d+) \|\s+(\d+)\s+(\d+)\s+(\d+) \|", line)
        if mr and h is not None:
            s, Rr, Rrc, rr, Rc, Rcc, rc = map(int, mr.groups())
            rows.append((h, N, s, Rr, rr, Rc, rc))

print("unsaturated row flattenings (R_row < N^2):  h  s  R_row  rank  deficit  deficit/R  log2(rank)/log2(R)")
for h, N, s, Rr, rr, Rc, rc in rows:
    if Rr < N * N and Rr > 1:
        print(f"  {h:2d} {s:4d} {Rr:7d} {rr:7d} {Rr-rr:6d}   {1-rr/Rr:7.4f}   {math.log2(rr)/math.log2(Rr):7.4f}")

# empirical law (fitted on the data, NOT proved): with k = s + h,
#   deficit = 0 for k < 0,  deficit = sum_{w=0}^{k} p(w) + [k >= 1] for k >= 0
def P(n):
    q = [1] + [0] * max(n, 0)
    for part in range(1, n + 1):
        for j in range(part, n + 1):
            q[j] += q[j - part]
    return q[n] if n >= 0 else 0


ok = bad = 0
for h, N, s, Rr, rr, Rc, rc in rows:
    if Rr < N * N:
        k = s + h
        law = 0 if k < 0 else sum(P(w) for w in range(k + 1)) + (k >= 1)
        if Rr - rr == law:
            ok += 1
        else:
            bad += 1
            print("  law fails:", h, s, Rr, rr, "law deficit", law)
print(f"\nempirical deficit law holds on {ok} unsaturated (h,s) cases, fails on {bad}")
print("\nworst piece per h (max over s of log2 rank_row + log2 rank_col) vs counted, and full 2 log2 N^2:")
for h in sorted(set(r[0] for r in rows)):
    rs = [r for r in rows if r[0] == h]
    N = rs[0][1]
    wc = max(math.log2(min(r[3], N * N)) + math.log2(min(r[5], N * N)) for r in rs)
    wt = max(math.log2(r[4]) + math.log2(r[6]) for r in rs)
    print(f"  h={h:2d} N={N:4d}: counted {wc:7.3f}  true {wt:7.3f}  full {4*math.log2(N):7.3f}")
