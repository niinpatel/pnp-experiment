// b=3: exhaustive exact check of the "energy capture" bound for triples: for all independent triples {i,j,k} of flat pieces (i = orbit representative),
// ||P_span f||^2 = quad/det3 <= 24 ?  (integers: quad <= 24*det3).  Also returns the max ratio as (quad, det3).
typedef unsigned long u64; typedef long i64;
void *memset(void *d, int c, u64 n){ unsigned char *p=(unsigned char*)d; while(n--) *p++=(unsigned char)c; return d; }
void *memcpy(void *d, const void *s, u64 n){ unsigned char *p=(unsigned char*)d; const unsigned char *q=(const unsigned char*)s; while(n--) *p++=*q++; return d; }
static inline i64 ip(u64 Sa, u64 Na, u64 Sb, u64 Nb){ u64 c=Sa&Sb; return (i64)__builtin_popcountll(c) - 2*(i64)__builtin_popcountll((Na^Nb)&c); }
// out: [0]=#triples examined (det3>0), [1]=#violations (quad > bound*det3), [2]=#equalities, [3]=best quad, [4]=best det3, [5]=#dependent triples
void energy3(const u64 *S, const u64 *N, const i64 *h, int P, int i, int jlo, int jhi, i64 bound, const i64 *Gi /*P: <g_i,g_k>*/, i64 *out){
  i64 a=(i64)__builtin_popcountll(S[i]); i64 hi=h[i];
  i64 bq=out[3], bd=out[4]; if(bd==0){ bq=0; bd=1; }
  i64 nex=0, nviol=0, neq=0, ndep=0;
  for(int j=jlo;j<jhi;j++){ if(j==i) continue;
    u64 Sj=S[j], Nj=N[j]; i64 b=Gi[j], d=(i64)__builtin_popcountll(Sj), hj=h[j];
    i64 A33=a*d-b*b;
    for(int k=j+1;k<P;k++){ if(k==i) continue;
      i64 c=Gi[k], g=(i64)__builtin_popcountll(S[k]), e=ip(Sj,Nj,S[k],N[k]), hk=h[k];
      i64 A11=d*g-e*e, A12=c*e-b*g, A13=b*e-c*d, A22=a*g-c*c, A23=b*c-a*e;
      i64 det3=a*A11+b*A12+c*A13;
      if(det3<=0){ ndep++; continue; }
      i64 quad=A11*hi*hi+A22*hj*hj+A33*hk*hk+2*(A12*hi*hj+A13*hi*hk+A23*hj*hk);
      nex++;
      i64 lim=bound*det3;
      if(quad>lim) nviol++; else if(quad==lim) neq++;
      if(quad*bd>bq*det3){ bq=quad; bd=det3; }
    }
  }
  out[0]+=nex; out[1]+=nviol; out[2]+=neq; out[3]=bq; out[4]=bd; out[5]+=ndep;
}
