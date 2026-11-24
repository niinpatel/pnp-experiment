// Exhaustive DFS over r-sets of flat pieces on F_2^6 such that every W (bit) is missed by at most cap of them,
// plus exact leaf tests: (i) supports cover G and Fourier supports cover G^; (ii) rank over F_p of [g_1..g_r, f] (p = 2^31-1): full rank r+1 => f not in Q-span.
typedef unsigned long u64; typedef long i64;
void *memset(void *d, int c, u64 n){ unsigned char *p=(unsigned char*)d; while(n--) *p++=(unsigned char)c; return d; }
void *memcpy(void *d, const void *s, u64 n){ unsigned char *p=(unsigned char*)d; const unsigned char *q=(const unsigned char*)s; while(n--) *p++=*q++; return d; }
#define NW 35
#define MAXR 8
#define MAXCAP 4
#define PR 2147483647UL
typedef struct { const u64 *mask; int P, r, cap; const int *pc; int budget, minpc; int *work; int *out; i64 maxout, nout; i64 *nodes;
                 const u64 *S, *Sd; const signed char *D; const signed char *f; int chosen[MAXR]; } ctx_t;
static int rank_modp(const ctx_t *c){   // rank of the (r+1) x 64 matrix [g_chosen ; f] over F_p
  int R=c->r+1; u64 M[MAXR+1][64];
  for(int i=0;i<c->r;i++){ const signed char *d=c->D+(i64)c->chosen[i]*64; for(int x=0;x<64;x++) M[i][x]= d[x]==0?0:(d[x]>0?1:PR-1); }
  for(int x=0;x<64;x++) M[c->r][x]= c->f[x]>0?1:PR-1;
  int rank=0;
  for(int col=0; col<64 && rank<R; col++){
    int piv=-1; for(int i=rank;i<R;i++) if(M[i][col]){piv=i;break;}
    if(piv<0) continue;
    if(piv!=rank) for(int x=0;x<64;x++){ u64 t=M[piv][x]; M[piv][x]=M[rank][x]; M[rank][x]=t; }
    u64 pv=M[rank][col];
    for(int i=rank+1;i<R;i++){ u64 a=M[i][col]; if(!a) continue;
      for(int x=col;x<64;x++) M[i][x]=(M[i][x]*pv%PR + (PR-a)*M[rank][x]%PR)%PR; }
    rank++;
  }
  return rank;
}
static void leaf(ctx_t *c){
  c->nodes[10]++;
  u64 cv=0, cd=0; for(int i=0;i<c->r;i++){ cv|=c->S[c->chosen[i]]; cd|=c->Sd[c->chosen[i]]; }
  if(~cv || ~cd) return;
  c->nodes[11]++;
  if(rank_modp(c)==c->r+1) return;
  c->nodes[12]++;
  if(c->nout<c->maxout){ for(int i=0;i<c->r;i++) c->out[c->nout*c->r+i]=c->chosen[i]; } c->nout++;
}
static void rec(ctx_t *c, int d, const int *cand, int ncand, u64 L[MAXCAP+1][NW], int tot, u64 cv, u64 cd){
  int *next = c->work + (i64)d * c->P;
  for(int ii=0; ii<ncand; ii++){
    int p = cand[ii];
    if(ncand-ii < c->r-d) break;
    int tot2 = tot + c->pc[p];
    if(tot2 + (c->r-d-1)*c->minpc > c->budget) continue;
    const u64 *m = c->mask + (i64)p*NW;
    u64 L2[MAXCAP+1][NW];
    for(int w=0;w<NW;w++){
      for(int k=c->cap; k>=2; k--) L2[k][w] = L[k][w] | (L[k-1][w] & m[w]);
      L2[1][w] = L[1][w] | m[w];
    }
    c->chosen[d]=p; c->nodes[d+1]++;
    if(d+1==c->r){ leaf(c); continue; }
    u64 cv2=cv|c->S[p], cd2=cd|c->Sd[p];
    u64 X=~cv2, Xd=~cd2; int last=(d+2==c->r);
    if(last && (i64)__builtin_popcountll(X)*(i64)__builtin_popcountll(Xd) > 64) continue;   // one piece left: 2^k>=|X|, 2^(6-k)>=|X^|
    int nn=0; const u64 *top=L2[c->cap];
    for(int jj=ii+1; jj<ncand; jj++){
      int q=cand[jj];
      if(last && ((c->S[q]&X)!=X || (c->Sd[q]&Xd)!=Xd)) continue;
      const u64 *mq = c->mask + (i64)q*NW; int ok=1;
      for(int w=0;w<NW;w++) if(mq[w]&top[w]){ok=0;break;}
      if(ok) next[nn++]=q;
    }
    if(nn >= c->r-d-1) rec(c, d+1, next, nn, L2, tot2, cv2, cd2);
  }
}
i64 excl_run(const u64 *mask, int P, const int *pc, int r, int cap, int budget, int minpc, int p1,
             const int *cand1, int ncand1, int i2lo, int i2hi, int *work, int *out, i64 maxout, i64 *nodes,
             const u64 *S, const u64 *Sd, const signed char *D, const signed char *f){
  ctx_t c; c.mask=mask; c.P=P; c.r=r; c.cap=cap; c.pc=pc; c.budget=budget; c.minpc=minpc; c.work=work; c.out=out; c.maxout=maxout; c.nout=0; c.nodes=nodes;
  c.S=S; c.Sd=Sd; c.D=D; c.f=f;
  u64 L[MAXCAP+1][NW]; const u64 *m1=mask+(i64)p1*NW;
  for(int k=0;k<=MAXCAP;k++) for(int w=0;w<NW;w++) L[k][w]=0;
  for(int w=0;w<NW;w++) L[1][w]=m1[w];
  c.chosen[0]=p1;
  int *c1 = work + (i64)(r)*P;
  for(int i2=i2lo; i2<i2hi && i2<ncand1; i2++){
    int p=cand1[i2];
    const u64 *m=mask+(i64)p*NW;
    if(cap==1){ int ok=1; for(int w=0;w<NW;w++) if(m[w]&m1[w]){ok=0;break;} if(!ok) continue; }
    int tot2=pc[p1]+pc[p];
    if(tot2+(r-2)*minpc>budget) continue;
    u64 L2[MAXCAP+1][NW];
    for(int w=0;w<NW;w++){ for(int k=cap;k>=2;k--) L2[k][w]=L[k][w]|(L[k-1][w]&m[w]); L2[1][w]=L[1][w]|m[w]; }
    c.chosen[1]=p; nodes[2]++;
    int nn=0; const u64 *top=L2[cap];
    for(int jj=i2+1; jj<ncand1; jj++){
      const u64 *mq=mask+(i64)cand1[jj]*NW; int ok=1;
      for(int w=0;w<NW;w++) if(mq[w]&top[w]){ok=0;break;}
      if(ok) c1[nn++]=cand1[jj];
    }
    if(nn>=r-2) rec(&c, 2, c1, nn, L2, tot2, S[p1]|S[p], Sd[p1]|Sd[p]);
  }
  return c.nout;
}
// standalone: rank mod p of [g_idx[0..r-1]; f]  (for self-test from python)
int rank_test(const signed char *D, const signed char *f, const int *idx, int r){
  ctx_t c; c.D=D; c.f=f; c.r=r; for(int i=0;i<r;i++) c.chosen[i]=idx[i]; return rank_modp(&c);
}
