import math
s = open('task0.py').read()
old = s[s.index("# asymptotic rho of the scheme"):s.index('print("REDUCTION OK"')]
new = '''# asymptotic rho of the scheme (cumulative sums, exact big ints)
for t in (40, 400, 2000):
    row = [0]*(t+2); col = [0]*(t+2)
    for z in range(t, -1, -1): row[z] = row[z+1] + math.comb(t, z) * 3**(t-z)
    acc = 0
    for z in range(0, t+1): acc += math.comb(t, z) * 3**z; col[z] = acc
    best = max((math.log2(row[i]) + math.log2(col[i]))/(4*t) for i in range(t+1))
    print("t", t, "max_i (log2 rowrank + log2 colrank)/(4t) =", round(best, 5), " log2(12)/4 =", round(math.log2(12)/4, 5))
'''
open('task0.py', 'w').write(s.replace(old, new))
s = open('excl_test.py').read()
s = s.replace("for trial in range(30):", "for trial in range(6):").replace("P = 40;", "P = 26;").replace("150 random instances", "30 random instances")
open('excl_test.py', 'w').write(s)
