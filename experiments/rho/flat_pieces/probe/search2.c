// Freestanding local search over ALL flat pieces of F_2^n (n<=8), scanning by fast Walsh-Hadamard transform per affine subspace.
// piece = (sub, c, s): subspace index, coset index (combination c of complement basis), character index s (sign (-1)^{popcount(s&i)} at point off^span_i).
typedef unsigned long u64; typedef long i64; typedef unsigned char u8;
void *memset(void *d, int c, u64 n){ unsigned char *p=(unsigned char*)d; while(n--) *p++=(unsigned char)c; return d; }
void *memcpy(void *d, const void *s, u64 n){ unsigned char *p=(unsigned char*)d; const unsigned char *q=(const unsigned char*)s; while(n--) *p++=*q++; return d; }
static inline u64 rng(u64 *s){ u64 x=*s; x^=x<<13; x^=x>>7; x^=x<<17; *s=x; return x; }
#define MAXR 16
#define MAXNP 256
typedef struct { int n, NP, nsub; const u8 *kdim; const u8 *bas; const int *dimstart; const double *f; } prob_t;
typedef struct { int sub, c, s; } piece_t;
static inline int comb(const u8 *b, int nb, int c){ int x=0; for(int i=0;i<nb;i++) if((c>>i)&1) x^=b[i]; return x; }
static void piece_vec(const prob_t *pr, piece_t p, double *v){
  int k=pr->kdim[p.sub]; const u8 *b=pr->bas+(i64)p.sub*8; int off=comb(b+k, pr->n-k, p.c);
  for(int x=0;x<pr->NP;x++) v[x]=0.0;
  for(int i=0;i<(1<<k);i++){ int x=off^comb(b,k,i); v[x]=(__builtin_popcount(p.s&i)&1)?-1.0:1.0; }
}
static int build(const prob_t *pr, const piece_t *tuple, int r, int skip, double Q[MAXR][MAXNP], double *fr, double *res){
  int m=0, NP=pr->NP;
  for(int j=0;j<r;j++){ if(j==skip) continue;
    double v[MAXNP]; piece_vec(pr,tuple[j],v);
    for(int pass=0; pass<2; pass++)
      for(int k=0;k<m;k++){ double s=0; for(int x=0;x<NP;x++) s+=v[x]*Q[k][x]; for(int x=0;x<NP;x++) v[x]-=s*Q[k][x]; }
    double nn=0; for(int x=0;x<NP;x++) nn+=v[x]*v[x];
    if(nn<1e-9) continue;
    nn=1.0/__builtin_sqrt(nn); for(int x=0;x<NP;x++) Q[m][x]=v[x]*nn; m++;
  }
  for(int x=0;x<NP;x++) fr[x]=pr->f[x];
  for(int pass=0; pass<2; pass++)
    for(int k=0;k<m;k++){ double s=0; for(int x=0;x<NP;x++) s+=fr[x]*Q[k][x]; for(int x=0;x<NP;x++) fr[x]-=s*Q[k][x]; }
  double rr=0; for(int x=0;x<NP;x++) rr+=fr[x]*fr[x]; *res=rr; return m;
}
#define DEFSCAN(NAME,K) \
static piece_t NAME(const prob_t *pr, double Q[MAXR][MAXNP], int m, const double *fr, u64 *seed, double *bestscore){ \
  double V[MAXNP][K]; double W[MAXNP][K]; int n=pr->n, NP=pr->NP; \
  for(int x=0;x<NP;x++){ for(int k=0;k<K;k++) V[x][k]=0.0; for(int k=0;k<m;k++) V[x][k]=Q[k][x]; V[x][K-1]=fr[x]; } \
  double best=-1.0; piece_t bp; bp.sub=-1; bp.c=0; bp.s=0; u64 nt=0; int span[MAXNP]; \
  for(int sub=0; sub<pr->nsub; sub++){ \
    int k=pr->kdim[sub]; int M=1<<k; const u8 *b=pr->bas+(i64)sub*8; \
    span[0]=0; for(int i=1;i<M;i++) span[i]=span[i&(i-1)]^b[__builtin_ctz(i)]; \
    int nc=1<<(n-k); double dM=(double)M; \
    for(int c=0;c<nc;c++){ int off=comb(b+k,n-k,c); \
      for(int i=0;i<M;i++){ const double *src=V[off^span[i]]; for(int j=0;j<K;j++) W[i][j]=src[j]; } \
      for(int h=1;h<M;h<<=1) for(int i=0;i<M;i+=2*h) for(int t=i;t<i+h;t++){ double *a=W[t], *bb=W[t+h]; \
        for(int j=0;j<K;j++){ double u=a[j], w=bb[j]; a[j]=u+w; bb[j]=u-w; } } \
      for(int s=0;s<M;s++){ const double *a=W[s]; double q=0; for(int j=0;j<K-1;j++) q+=a[j]*a[j]; double den=dM-q; \
        if(den<1e-7) continue; double sc=a[K-1]*a[K-1]/den; \
        if(sc>best+1e-9){ best=sc; bp.sub=sub; bp.c=c; bp.s=s; nt=1; } \
        else if(sc>best-1e-9){ nt++; if(rng(seed)%nt==0){ bp.sub=sub; bp.c=c; bp.s=s; if(sc>best) best=sc; } } } \
    } } \
  *bestscore=best; return bp; }
DEFSCAN(scan8,8)
DEFSCAN(scan16,16)
static piece_t randpiece(const prob_t *pr, u64 *seed){
  piece_t p; int n=pr->n;
  if(rng(seed)&1) p.sub=(int)(rng(seed)%(u64)pr->nsub);
  else { int k=(int)(rng(seed)%(u64)(n+1)); int a=pr->dimstart[k], b=pr->dimstart[k+1]; p.sub=a+(int)(rng(seed)%(u64)(b-a)); }
  int k=pr->kdim[p.sub]; p.c=(int)(rng(seed)%(u64)(1<<(n-k))); p.s=(int)(rng(seed)%(u64)(1<<k)); return p;
}
static double descend(const prob_t *pr, int r, piece_t *tuple, u64 *seed, int maxsweeps, i64 *nscan){
  double Q[MAXR][MAXNP]; double fr[MAXNP]; double res, cur, sc;
  build(pr,tuple,r,-1,Q,fr,&res);
  for(int sweep=0; sweep<maxsweeps; sweep++){
    int perm[MAXR]; for(int i=0;i<r;i++) perm[i]=i;
    for(int i=r-1;i>0;i--){ int j=(int)(rng(seed)%(u64)(i+1)); int t=perm[i]; perm[i]=perm[j]; perm[j]=t; }
    int improved=0;
    for(int ii=0; ii<r; ii++){ int i=perm[ii];
      int m=build(pr,tuple,r,i,Q,fr,&cur);
      if(cur<1e-10) return cur;
      piece_t bp = (m+1<=8) ? scan8(pr,Q,m,fr,seed,&sc) : scan16(pr,Q,m,fr,seed,&sc); (*nscan)++;
      if(bp.sub<0) continue;
      double nr=cur-sc;
      if(nr<res-1e-10) improved=1;
      tuple[i]=bp; res=nr;
      if(res<1e-10) return res;
    }
    if(!improved) break;
  }
  build(pr,tuple,r,-1,Q,fr,&res);
  return res;
}
// init: optional n_init tuples (r*3 ints each).  sols: r*3 ints per solution. finals (optional): final tuple of every restart (r*3 ints each).
i64 ls2_run(int n, int nsub, const u8 *kdim, const u8 *bas, const int *dimstart, const double *f, int r, u64 seed, i64 nrestarts, int kicks,
            const int *init, i64 n_init, double *resout, int *sols, i64 maxsol, int *finals, i64 *stats){
  prob_t pr; pr.n=n; pr.NP=1<<n; pr.nsub=nsub; pr.kdim=kdim; pr.bas=bas; pr.dimstart=dimstart; pr.f=f;
  i64 nsol=0, nscan=0; if(seed==0) seed=88172645463325252UL;
  for(int w=0;w<20;w++) rng(&seed);
  for(i64 it=0; it<nrestarts; it++){
    piece_t tuple[MAXR], cand[MAXR];
    if(init && n_init>0){ const int *src=init+(it%n_init)*r*3; for(int i=0;i<r;i++){ tuple[i].sub=src[3*i]; tuple[i].c=src[3*i+1]; tuple[i].s=src[3*i+2]; } }
    else for(int i=0;i<r;i++) tuple[i]=randpiece(&pr,&seed);
    double res=descend(&pr,r,tuple,&seed,60,&nscan);
    for(int kk=0; kk<kicks && res>=1e-10; kk++){
      for(int i=0;i<r;i++) cand[i]=tuple[i];
      int nk=1+(int)(rng(&seed)%2);
      for(int z=0;z<nk;z++) cand[rng(&seed)%(u64)r]=randpiece(&pr,&seed);
      double r2=descend(&pr,r,cand,&seed,60,&nscan);
      if(r2<=res+1e-12){ res=r2; for(int i=0;i<r;i++) tuple[i]=cand[i]; }
    }
    resout[it]=res;
    if(finals) for(int i=0;i<r;i++){ finals[(it*r+i)*3]=tuple[i].sub; finals[(it*r+i)*3+1]=tuple[i].c; finals[(it*r+i)*3+2]=tuple[i].s; }
    if(res<1e-10 && nsol<maxsol){ for(int i=0;i<r;i++){ sols[(nsol*r+i)*3]=tuple[i].sub; sols[(nsol*r+i)*3+1]=tuple[i].c; sols[(nsol*r+i)*3+2]=tuple[i].s; } nsol++; }
  }
  stats[0]=nscan; return nsol;
}
