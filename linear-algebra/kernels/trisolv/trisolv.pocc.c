#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"


/* Default problem size. */
#ifndef N
# define N 4000
#endif

/* Default data type is double. */
#ifndef DATA_TYPE
# define DATA_TYPE double
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE A[N][N];
DATA_TYPE x[N];
DATA_TYPE c[N];
#else
DATA_TYPE** A = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE*));
DATA_TYPE* x = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
DATA_TYPE* c = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
{
  int i;
  for (i = 0; i < N; ++i)
    A[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
}
#endif

inline
void init_array()
{
  int i, j;

  for (i = 0; i < N; i++)
    {
      c[i] = ((DATA_TYPE) i) / N;
      for (j = 0; j < N; j++)
	A[i][j] = ((DATA_TYPE) i*j) / N;
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
      for (i = 0; i < N; i++) {
	fprintf(stderr, "%0.2lf ", x[i]);
	if ((2 * i) % 80 == 20) fprintf(stderr, "\n");
      }
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int i, j;
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
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4;

#pragma scop
if (n >= 1) {
  for (c1=0;c1<=floord((n-1),32);c1++) {
    for (c3=32*c1;c3<=min((32*c1+31),(n-1));c3++) {
      x[c3]=c[c3];
    }
  }
  for (c1=-1;c1<=floord((n-1),16);c1++) {
 lb1=max(0,ceild((32*c1-n+1),32));
 ub1=floord((c1-1),2);
#pragma omp parallel for shared(c0,c1,lb1,ub1) private(c2,c3,c4)
 for (c2=lb1; c2<=ub1; c2++) {
      for (c3=(32*c1-32*c2);c3<=min((n-1),(32*c1-32*c2+31));c3++) {
        for (c4=32*c2;c4<=(32*c2+31);c4++) {
          x[c3]=x[c3]-A[c3][c4]*x[c4];
        }
      }
    }
    if (16*c1 == (n-1)) {
      if (((n+31))%32 == 0) {
        x[(n-1)]=x[(n-1)]/A[(n-1)][(n-1)];
      }
    }
    if (c1 <= floord((n-2),16)) {
      if (c1%2 == 0) {
        x[16*c1]=x[16*c1]/A[16*c1][16*c1];
        for (c3=(16*c1+1);c3<=min((16*c1+31),(n-1));c3++) {
          for (c4=16*c1;c4<=(c3-1);c4++) {
            x[c3]=x[c3]-A[c3][c4]*x[c4];
          }
          x[c3]=x[c3]/A[c3][c3];
        }
      }
    }
  }
}
#pragma endscop

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  print_array(argc, argv);

  return 0;
}
