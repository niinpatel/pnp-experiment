# Counting-level checks of Majdoddin Prop 4.24 (shape of App. B). lam normalised to 1, h=1.
import math
def rhoB(D, W, H, n=4001):
    # max over s in [-H,W] of (D(s+H)+D(W-s))/4 ; caller checks D(W+H)>=2 (pigeonhole)
    best=0
    for k in range(n):
        s=-H+(W+H)*k/(n-1)
        best=max(best,(D(s+H)+D(W-s))/4)
    return best
pw=lambda a:(lambda E: max(E,0)**a)            # D(E)=E^a, D(1)=1
print("App B a=1/2, W=H=2:", rhoB(pw(.5),2,2), 1/math.sqrt(2))
for a in [math.log(2,3),0.7,0.8,1.0]:
    print("H=1,W=2,a=%.4f pigeon_ok=%s rho=%.4f"%(a,3**a>=2-1e-12,rhoB(pw(a),2,1)))
print("H=1,W=2,a=0.5 pigeon_ok=%s"%(3**0.5>=2))
kink=lambda E: (E if E<=1 else 1+(E-1)/3) if E>=0 else 0
print("kinked concave W=H=2, D(4)=",kink(4)," rho=",rhoB(kink,2,2))
k2=lambda E: (E if E<=1 else 1+(E-1)/2) if E>=0 else 0
print("kinked H=1,W=2, D(3)=",k2(3)," rho=",rhoB(k2,2,1))
for a in [0.5,0.6,0.75,1.0]:
    mu=2**(1/a-1); print("a=%.2f mu*=%.3f rho=%.4f 2^-a=%.4f"%(a,mu,rhoB(pw(a),mu,mu),2**-a))
step=lambda E: 0 if E<0 else (E if E<1 else (1 if E<4-1e-9 else 2))
print("step profile W=H=2 rho=",rhoB(step,2,2))
