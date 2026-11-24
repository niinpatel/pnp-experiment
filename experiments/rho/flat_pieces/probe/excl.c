// Exhaustive DFS over r-sets of pieces such that every W (bit) is missed by at most cap of them.
typedef unsigned long u64; typedef long i64;
void *memset(void *d, int c, u64 n){ unsigned char *p=(unsigned char*)d; while(n--) *p++=(unsigned char)c; return d; }
void *memcpy(void *d, const void *s, u64 n){ unsigned char *p=(unsigned char*)d; const unsigned char *q=(const unsigned char*)s; while(n--) *p++=*q++; return d; }
#define NW 35
#define MAXR 8
#define MAXCAP 4
typedef struct { const u64 *mask; int P, r, cap; const int *pc; int budget, minpc; int *work; int *out; i64 maxout, nout; i64 *nodes; int chosen[MAXR]; } ctx_t;
static void rec(ctx_t *c, int d, const int *cand, int ncand, u64 L[MAXCAP+1][NW], int tot){
  // d pieces chosen; cand = admissible next pieces (already compatible with L[cap]), sorted ascending
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
    if(d+1==c->r){ if(c->nout<c->maxout){ for(int i=0;i<c->r;i++) c->out[c->nout*c->r+i]=c->chosen[i]; } c->nout++; continue; }
    // filter remaining candidates
    int nn=0; const u64 *top=L2[c->cap];
    int anytop=0; for(int w=0;w<NW;w++) if(top[w]){anytop=1;break;}
    if(!anytop){ // nothing to filter: next = cand[ii+1..]
      rec(c, d+1, cand+ii+1, ncand-ii-1, L2, tot2); continue; }
    for(int jj=ii+1; jj<ncand; jj++){
      const u64 *mq = c->mask + (i64)cand[jj]*NW; int ok=1;
      for(int w=0;w<NW;w++) if(mq[w]&top[w]){ok=0;break;}
      if(ok) next[nn++]=cand[jj];
    }
    if(nn >= c->r-d-1) rec(c, d+1, next, nn, L2, tot2);
  }
}
// p1 fixed; second piece ranges over cand1[i2lo..i2hi) (cand1 = allowed pieces, ascending); deeper pieces come later in cand1.
i64 excl_run(const u64 *mask, int P, const int *pc, int r, int cap, int budget, int minpc, int p1,
             const int *cand1, int ncand1, int i2lo, int i2hi, int *work, int *out, i64 maxout, i64 *nodes){
  ctx_t c; c.mask=mask; c.P=P; c.r=r; c.cap=cap; c.pc=pc; c.budget=budget; c.minpc=minpc; c.work=work; c.out=out; c.maxout=maxout; c.nout=0; c.nodes=nodes;
  u64 L[MAXCAP+1][NW]; const u64 *m1=mask+(i64)p1*NW;
  for(int k=0;k<=MAXCAP;k++) for(int w=0;w<NW;w++) L[k][w]=0;
  for(int w=0;w<NW;w++) L[1][w]=m1[w];
  c.chosen[0]=p1;
  int *c1 = work + (i64)(r)*P;  // filtered copy for level 1 (cap==1 needs filtering against m1)
  for(int i2=i2lo; i2<i2hi && i2<ncand1; i2++){
    int p=cand1[i2];
    const u64 *m=mask+(i64)p*NW;
    if(cap==1){ int ok=1; for(int w=0;w<NW;w++) if(m[w]&m1[w]){ok=0;break;} if(!ok) continue; }
    int tot2=pc[p1]+pc[p];
    if(tot2+(r-2)*minpc>budget) continue;
    u64 L2[MAXCAP+1][NW];
    for(int w=0;w<NW;w++){ for(int k=cap;k>=2;k--) L2[k][w]=L[k][w]|(L[k-1][w]&m[w]); L2[1][w]=L[1][w]|m[w]; }
    c.chosen[1]=p; nodes[2]++;
    if(r==2){ c.nout++; continue; }
    int nn=0; const u64 *top=L2[cap];
    for(int jj=i2+1; jj<ncand1; jj++){
      const u64 *mq=mask+(i64)cand1[jj]*NW; int ok=1;
      for(int w=0;w<NW;w++) if(mq[w]&top[w]){ok=0;break;}
      if(ok) c1[nn++]=cand1[jj];
    }
    if(nn>=r-2) rec(&c, 2, c1, nn, L2, tot2);
  }
  return c.nout;
}
