#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"


/* Default problem size. */
#ifndef M
# define M 512
#endif
#ifndef N
# define N 512
#endif

/* Default data type is double. */
#ifndef DATA_TYPE
# define DATA_TYPE double
#endif
#ifndef DATA_PRINTF_MODIFIER
# define DATA_PRINTF_MODIFIER "%0.2lf "
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
DATA_TYPE nrm;
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE A[M][N];
DATA_TYPE R[M][N];
DATA_TYPE Q[M][N];
#else
DATA_TYPE** A = (DATA_TYPE**)malloc(M * sizeof(DATA_TYPE*));
DATA_TYPE** R = (DATA_TYPE**)malloc(M * sizeof(DATA_TYPE*));
DATA_TYPE** Q = (DATA_TYPE**)malloc(M * sizeof(DATA_TYPE*));
{
  int i;
  for (i = 0; i < M; ++i)
    {
      A[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
      R[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
      Q[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
    }
}
#endif

inline
void init_array()
{
  int i, j;

  for (i = 0; i < M; i++)
    for (j = 0; j < N; j++)
      A[i][j] = ((DATA_TYPE) i*j) / M;
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
      for (i = 0; i < M; i++)
	for (j = 0; j < N; j++) {
	  fprintf(stderr, DATA_PRINTF_MODIFIER, A[i][j]);
	  if ((i * M + j) % 80 == 20) fprintf(stderr, "\n");
	}
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int i, j, k;
  int m = M;
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
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4, c5, c5t, newlb_c5, newub_c5, c6, c6t, newlb_c6, newub_c6, c7, c7t, newlb_c7, newub_c7, c8, c8t, newlb_c8, newub_c8, c9, c9t, newlb_c9, newub_c9, c10, c10t, newlb_c10, newub_c10;
#pragma scop
if (n >= 1) {
  // parfor
  for (c1=0;c1<=(n-2);c1++) {
    // parfor
    for (c3=ceild((c1+2),32);c3<=floord((n+31),32);c3++) {
      // parfor
      for (c7=max((c1+1),(32*c3-32));c7<=min((32*c3-1),(n-1));c7++) {
        R[c1][c7]=0;
      }
    }
  }
  for (c1=0;c1<=(n-1);c1++) {
    nrm=0;
    for (c3=3;c3<=floord((m+95),32);c3++) {
      for (c7=(32*c3-96);c7<=min((32*c3-65),(m-1));c7++) {
        nrm+=A[c7][c1]*A[c7][c1];
      }
    }
    R[c1][c1]=sqrt(nrm);
    // parfor
    for (c3=1;c3<=floord((m+31),32);c3++) {
      // parfor
      for (c7=(32*c3-32);c7<=min((32*c3-1),(m-1));c7++) {
        Q[c7][c1]=A[c7][c1]/R[c1][c1];
      }
    }
    if ((c1 <= (n-2)) && (m >= 1)) {
      // parfor
      for (c3=ceild((c1-30),32);c3<=floord((n-1),32);c3++) {
        for (c6=0;c6<=floord((m-1),32);c6++) {
          // parfor
          for (c7=max(32*c3,(c1+1));c7<=min((32*c3+31),(n-1));c7++) {
            for (c10=32*c6;c10<=min((32*c6+31),(m-1));c10++) {
              R[c1][c7]+=Q[c10][c1]*A[c10][c7];
            }
          }
        }
        // parfor
        for (c6=0;c6<=floord((m-1),32);c6++) {
          // parfor
          for (c7=max(32*c3,(c1+1));c7<=min((32*c3+31),(n-1));c7++) {
            // parfor
            for (c10=32*c6;c10<=min((32*c6+31),(m-1));c10++) {
              A[c10][c7]=A[c10][c7]-Q[c10][c1]*R[c1][c7];
            }
          }
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
