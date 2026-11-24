// b=2: enumerate all 4-subsets {i<j<k<l} of the 1072 flat pieces with f in their span (floating point with tolerance; exact re-check in python).
typedef unsigned long u64; typedef long i64;
void *memset(void *d, int c, u64 n){ unsigned char *p=(unsigned char*)d; while(n--) *p++=(unsigned char)c; return d; }
void *memcpy(void *d, const void *s, u64 n){ unsigned char *p=(unsigned char*)d; const unsigned char *q=(const unsigned char*)s; while(n--) *p++=*q++; return d; }
#define P 1072
i64 enum4(const double *G /*P*P gram*/, const double *h /*P*/, double ff, int ilo, int ihi, int *out, i64 maxout, i64 *cnt){
  i64 nout=0; double a[P], b[P], c[P];
  for(int i=ilo;i<ihi;i++){
    double n1=__builtin_sqrt(G[i*P+i]); double fa=h[i]/n1;
    for(int l=0;l<P;l++) a[l]=G[i*P+l]/n1;
    for(int j=i+1;j<P;j++){
      double n2s=G[j*P+j]-a[j]*a[j]; if(n2s<1e-9) continue; double n2=__builtin_sqrt(n2s);
      double fb=(h[j]-a[j]*fa)/n2;
      for(int l=0;l<P;l++) b[l]=(G[j*P+l]-a[j]*a[l])/n2;
      for(int k=j+1;k<P;k++){
        double n3s=G[k*P+k]-a[k]*a[k]-b[k]*b[k]; if(n3s<1e-9) continue; double n3=__builtin_sqrt(n3s);
        double fc=(h[k]-a[k]*fa-b[k]*fb)/n3;
        double nf=ff-fa*fa-fb*fb-fc*fc;
        cnt[0]++;
        if(nf<1e-9){ cnt[1]++; continue; }   // f already in span of a triple (should never happen)
        const double *Gk=G+(i64)k*P;
        for(int l=k+1;l<P;l++){
          double cl=(Gk[l]-a[k]*a[l]-b[k]*b[l])/n3;
          double den=G[l*P+l]-a[l]*a[l]-b[l]*b[l]-cl*cl;
          double s=h[l]-a[l]*fa-b[l]*fb-cl*fc;
          double d=s*s-nf*den;
          if(d>-1e-7 && d<1e-7 && den>1e-7){ if(nout<maxout){ out[4*nout]=i; out[4*nout+1]=j; out[4*nout+2]=k; out[4*nout+3]=l; } nout++; }
        }
      }
    }
  }
  return nout;
}
