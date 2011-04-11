#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"


/* Default problem size. */
#ifndef N
# define N 1024
#endif

/* Default data type is double. */
#ifndef DATA_TYPE
# define DATA_TYPE double
#endif
#ifndef DATA_PRINTF_MODIFIER
# define DATA_PRINTF_MODIFIER "%0.2lf "
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
DATA_TYPE w;
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE a[N+1][N+1];
DATA_TYPE x[N+1];
DATA_TYPE y[N+1];
DATA_TYPE b[N+1];
#else
DATA_TYPE** a = (DATA_TYPE**)malloc((N + 1) * sizeof(DATA_TYPE*));
DATA_TYPE* x = (DATA_TYPE*)malloc((N + 1) * sizeof(DATA_TYPE));
DATA_TYPE* y = (DATA_TYPE*)malloc((N + 1) * sizeof(DATA_TYPE));
DATA_TYPE* b = (DATA_TYPE*)malloc((N + 1) * sizeof(DATA_TYPE));
{
  int i;
  for (i = 0; i <= N; ++i)
    a[i] = (DATA_TYPE*)malloc((N + 1) * sizeof(DATA_TYPE));
}
#endif

inline
void init_array()
{
  int i, j;

  for (i = 0; i <= N; i++)
    {
      x[i] = ((DATA_TYPE) i + 1) / N;
      b[i] = ((DATA_TYPE) i + 2) / N;
      for (j = 0; j <= N; j++)
	a[i][j] = ((DATA_TYPE) i*j + 1) / N;
    }
}

/* Define the live-out variables. Code is not executed unless
   POLYBENCH_DUMP_ARRAYS is defined. */
inline
void print_array(int argc, char** argv)
{
  int i, j;
#ifndef POLYBENCH_DUMP_ARRAYS
  if (argc > 42 && ! strcmp(argv[0], ""))
#endif
    {
      for (i = 0; i <= N; i++) {
	fprintf(stderr, DATA_PRINTF_MODIFIER, x[i]);
	if (i % 80 == 20) fprintf(stderr, "\n");
      }
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int i, j, k;
  int n = N;

  /* Initialize array. */
  init_array();

  /* Start timer. */
  polybench_start_instruments;

#define ceild(n,d)  ceil(((double)(n))/((double)(d)))
#define floord(n,d) floor(((double)(n))/((double)(d)))
#define max(x,y)    ((x) > (y)? (x) : (y))
#define min(x,y)    ((x) < (y)? (x) : (y))
  register int lbv, ubv, lb, ub, lb1, ub1, lb2, ub2;
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4, c5, c5t, newlb_c5, newub_c5, c6, c6t, newlb_c6, newub_c6, c7, c7t, newlb_c7, newub_c7, c8, c8t, newlb_c8, newub_c8, c9, c9t, newlb_c9, newub_c9, c10, c10t, newlb_c10, newub_c10, c11, c11t, newlb_c11, newub_c11, c12, c12t, newlb_c12, newub_c12, c13, c13t, newlb_c13, newub_c13;
#pragma scop
if (n >= 1) {
  for (c9=1;c9<=n;c9++) {
    w=a[c9][0];
    a[c9][0]=w/a[0][0];
  }
  for (c9=1;c9<=n;c9++) {
    w=a[0 +1][c9];
    w=w-a[0 +1][0]*a[0][c9];
    a[0 +1][c9]=w;
  }
}
for (c5=1;c5<=(n-1);c5++) {
  for (c9=(c5+1);c9<=n;c9++) {
    w=a[c9][c5];
    for (c10=0;c10<=(c5-1);c10++) {
      w=w-a[c9][c10]*a[c10][c5];
    }
    a[c9][c5]=w/a[c5][c5];
  }
  for (c9=(c5+1);c9<=n;c9++) {
    w=a[c5+1][c9];
    for (c10=0;c10<=c5;c10++) {
      w=w-a[c5+1][c10]*a[c10][c9];
    }
    a[c5+1][c9]=w;
  }
}
for (c5=1;c5<=n;c5++) {
  y[c5]=w;
}
x[n]=y[n]/a[n][n];
for (c5=1;c5<=n;c5++) {
  w=b[c5];
}
b[0]=1.0;
y[0]=b[0];
for (c5=1;c5<=n;c5++) {
  for (c9=0;c9<=(c5-1);c9++) {
    w=w-a[c5][c9]*y[c9];
  }
}
for (c5=0;c5<=(n-1);c5++) {
  w=y[n-1-(c5)];
}
for (c5=0;c5<=(n-1);c5++) {
  for (c9=(-c5+n);c9<=n;c9++) {
    w=w-a[n-1-c5][c9]*x[c9];
  }
  x[n-1-c5]=w/a[n-1-(c5)][n-1-(c5)];
}
#pragma endscop

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  print_array(argc, argv);

  return 0;
}
