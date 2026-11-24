// Freestanding local search: find r flat pieces whose span contains f (least-squares residual 0).
typedef unsigned long u64; typedef long i64;
void *memset(void *d, int c, u64 n){ unsigned char *p=(unsigned char*)d; while(n--) *p++=(unsigned char)c; return d; }
void *memcpy(void *d, const void *s, u64 n){ unsigned char *p=(unsigned char*)d; const unsigned char *q=(const unsigned char*)s; while(n--) *p++=*q++; return d; }
static inline u64 rng(u64 *s){ u64 x=*s; x^=x<<13; x^=x>>7; x^=x<<17; *s=x; return x; }
#define MAXR 16
#define MAXNP 256
#define KV 16
static int build(const signed char *D, int NP, const int *tuple, int r, int skip, const double *f, double Q[MAXR][MAXNP], double *fr, double *res){
  int m=0;
  for(int j=0;j<r;j++){ if(j==skip) continue;
    double v[MAXNP]; const signed char *d = D + (i64)tuple[j]*NP;
    for(int x=0;x<NP;x++) v[x]=d[x];
    for(int pass=0; pass<2; pass++)
      for(int k=0;k<m;k++){ double s=0; for(int x=0;x<NP;x++) s+=v[x]*Q[k][x]; for(int x=0;x<NP;x++) v[x]-=s*Q[k][x]; }
    double nn=0; for(int x=0;x<NP;x++) nn+=v[x]*v[x];
    if(nn<1e-9) continue;
    nn=1.0/__builtin_sqrt(nn); for(int x=0;x<NP;x++) Q[m][x]=v[x]*nn; m++;
  }
  for(int x=0;x<NP;x++) fr[x]=f[x];
  for(int pass=0; pass<2; pass++)
    for(int k=0;k<m;k++){ double s=0; for(int x=0;x<NP;x++) s+=fr[x]*Q[k][x]; for(int x=0;x<NP;x++) fr[x]-=s*Q[k][x]; }
  double rr=0; for(int x=0;x<NP;x++) rr+=fr[x]*fr[x]; *res=rr; return m;
}
static int best_swap(int P, int NP, const int *start, const unsigned char *pts, const signed char *sgn,
                     double Q[MAXR][MAXNP], int m, const double *fr, u64 *seed, double *bestscore){
  static __thread double V[MAXNP][KV];
  int K = (m+1<=8)?8:KV;
  for(int x=0;x<NP;x++){ for(int k=0;k<K;k++) V[x][k]=0.0; for(int k=0;k<m;k++) V[x][k]=Q[k][x]; V[x][K-1]=fr[x]; }
  // column K-1 holds fr; columns 0..m-1 hold Q (m <= K-1)
  double best=-1.0; int bp=-1; u64 nt=0;
  for(int p=0;p<P;p++){
    double acc[KV]; for(int k=0;k<K;k++) acc[k]=0.0;
    int t0=start[p], t1=start[p+1];
    for(int t=t0;t<t1;t++){ const double *vx=V[pts[t]]; if(sgn[t]>0){ for(int k=0;k<K;k++) acc[k]+=vx[k]; } else { for(int k=0;k<K;k++) acc[k]-=vx[k]; } }
    double den=(double)(t1-t0); for(int k=0;k<K-1;k++) den-=acc[k]*acc[k];
    if(den<1e-7) continue;
    double sc=acc[K-1]*acc[K-1]/den;
    if(sc>best+1e-9){ best=sc; bp=p; nt=1; }
    else if(sc>best-1e-9){ nt++; if(rng(seed)%nt==0){ bp=p; if(sc>best) best=sc; } }
  }
  *bestscore=best; return bp;
}
static int randpiece(int P, const int *dimstart, int ndim, u64 *seed){
  if(rng(seed)&1) return (int)(rng(seed)%(u64)P);
  int k=(int)(rng(seed)%(u64)ndim); int a=dimstart[k], b=dimstart[k+1];
  return a+(int)(rng(seed)%(u64)(b-a));
}
static double descend(const signed char *D, int P, int NP, const int *start, const unsigned char *pts, const signed char *sgn,
                      const double *f, int r, int *tuple, u64 *seed, int maxsweeps, i64 *nswap){
  static __thread double Q[MAXR][MAXNP]; double fr[MAXNP]; double res, cur, sc;
  build(D,NP,tuple,r,-1,f,Q,fr,&res);
  for(int sweep=0; sweep<maxsweeps; sweep++){
    int perm[MAXR]; for(int i=0;i<r;i++) perm[i]=i;
    for(int i=r-1;i>0;i--){ int j=(int)(rng(seed)%(u64)(i+1)); int t=perm[i]; perm[i]=perm[j]; perm[j]=t; }
    int improved=0;
    for(int ii=0; ii<r; ii++){ int i=perm[ii];
      int m=build(D,NP,tuple,r,i,f,Q,fr,&cur);
      if(cur<1e-10) return cur;           // already solved by the other r-1 pieces
      int bp=best_swap(P,NP,start,pts,sgn,Q,m,fr,seed,&sc); (*nswap)++;
      if(bp<0) continue;
      double nr=cur-sc;
      if(nr<res-1e-10) improved=1;
      tuple[i]=bp; res=nr;
      if(res<1e-10) return res;
    }
    if(!improved) break;
  }
  build(D,NP,tuple,r,-1,f,Q,fr,&res);
  return res;
}
// returns number of solutions stored. resout[restart] = best residual of that restart.  init (optional, n_init tuples of r) seeds restarts cyclically.
i64 ls_run(const signed char *D, int P, int NP, const int *start, const unsigned char *pts, const signed char *sgn,
           const double *f, int r, u64 seed, i64 nrestarts, int kicks, const int *dimstart, int ndim,
           const int *init, i64 n_init, double *resout, int *sols, i64 maxsol, i64 *stats){
  i64 nsol=0, nswap=0; if(seed==0) seed=88172645463325252UL;
  for(int w=0;w<20;w++) rng(&seed);
  for(i64 it=0; it<nrestarts; it++){
    int tuple[MAXR], cand[MAXR];
    if(init && n_init>0){ const int *src=init+(it%n_init)*r; for(int i=0;i<r;i++) tuple[i]=src[i]; }
    else for(int i=0;i<r;i++) tuple[i]=randpiece(P,dimstart,ndim,&seed);
    double res=descend(D,P,NP,start,pts,sgn,f,r,tuple,&seed,60,&nswap);
    for(int kk=0; kk<kicks && res>=1e-10; kk++){
      for(int i=0;i<r;i++) cand[i]=tuple[i];
      int nk=1+(int)(rng(&seed)%2);
      for(int z=0;z<nk;z++) cand[rng(&seed)%(u64)r]=randpiece(P,dimstart,ndim,&seed);
      double r2=descend(D,P,NP,start,pts,sgn,f,r,cand,&seed,60,&nswap);
      if(r2<=res+1e-12){ res=r2; for(int i=0;i<r;i++) tuple[i]=cand[i]; }
    }
    resout[it]=res;
    if(res<1e-10 && nsol<maxsol){ for(int i=0;i<r;i++) sols[nsol*r+i]=tuple[i]; nsol++; }
  }
  stats[0]=nswap; return nsol;
}
