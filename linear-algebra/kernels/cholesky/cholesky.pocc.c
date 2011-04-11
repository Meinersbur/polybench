#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"

#ifndef N
# define N 1024
#endif

/* Default data type is double. */
#ifndef DATA_TYPE
# define DATA_TYPE double
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
DATA_TYPE x;
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE a[N][N];
DATA_TYPE p[N];
#else
DATA_TYPE** a = (DATA_TYPE**) malloc((N) * sizeof(DATA_TYPE*));
DATA_TYPE* p = (DATA_TYPE*) malloc ((N) * sizeof(DATA_TYPE));
{
  int i;
  for (i = 0; i < nx; ++i)
    a[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
}
#endif


inline
void init_array()
{
    int i, j;

    for (i = 0; i < N; i++)
      {
	p[i] = M_PI * i;
        for (j = 0; j < N; j++)
	  a[i][j] = M_PI * i + 2 * j;
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
	  for (j = 0; j < N; j++) {
	    fprintf(stderr, "%0.2lf ", a[i][j]);
	    if ((i * N + j) % 80 == 20) fprintf(stderr, "\n");
	  }
	  fprintf(stderr, "\n");
	}
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
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4, c5, c5t, newlb_c5, newub_c5, c6, c6t, newlb_c6, newub_c6, c7, c7t, newlb_c7, newub_c7;
#pragma scop
if (n >= 1) {
  for (c0=0;c0<=(n-1);c0++) {
    x=a[c0][c0];
    for (c1=0;c1<=(c0-1);c1++) {
      x=x-a[c0][c1]*a[c0][c1];
    }
    p[c0]=1.0/sqrt(x);
    if (c0 >= 1) {
      for (c1=(c0+1);c1<=(n-1);c1++) {
        x=a[c0][c1];
        for (c2=0;c2<=(c0-1);c2++) {
          x=x-a[c1][c2]*a[c0][c2];
        }
        a[c1][c0]=x*p[c0];
      }
    }
    if (c0 == 0) {
      for (c1=1;c1<=(n-1);c1++) {
        x=a[0][c1];
        a[c1][0]=x*p[0];
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
