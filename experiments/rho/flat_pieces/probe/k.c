typedef unsigned long u64; typedef long i64;
i64 popsum(const u64 *a, i64 n){ i64 s=0; for(i64 i=0;i<n;i++) s+=__builtin_popcountll(a[i]); return s; }
double dsum(const double *a, i64 n){ double s=0; for(i64 i=0;i<n;i++) s+=a[i]*a[i]; return s; }
