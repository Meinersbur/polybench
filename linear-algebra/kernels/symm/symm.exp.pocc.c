#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"


/* Default problem size. */
#ifndef N
# define N 512
#endif
#ifndef M
# define M 512
#endif

/* Default data type is double (dsymm). */
#ifndef DATA_TYPE
# define DATA_TYPE double
#endif
#ifndef DATA_PRINTF_MODIFIER
# define DATA_PRINTF_MODIFIER "%0.2lf "
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
DATA_TYPE alpha;
DATA_TYPE beta;
DATA_TYPE acc;
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE A[N][N];
DATA_TYPE B[M][N];
DATA_TYPE C[M][N];
#else
DATA_TYPE** A = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE*));
DATA_TYPE** B = (DATA_TYPE**)malloc(M * sizeof(DATA_TYPE*));
DATA_TYPE** C = (DATA_TYPE**)malloc(M * sizeof(DATA_TYPE*));
{
  int i;
  for (i = 0; i < N; ++i)
    A[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
  for (i = 0; i < M; ++i)
    {
      B[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
      C[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
    }
}
#endif

inline
void init_array()
{
  int i, j;

  alpha = 12435;
  beta = 4546;
  for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
      A[i][j] = ((DATA_TYPE) i*j) / N;
  for (i = 0; i < M; i++)
    for (j = 0; j < N; j++)
      {
	B[i][j] = ((DATA_TYPE) i*j + 1) / N;
	C[i][j] = ((DATA_TYPE) i*j + 2) / N;
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
      for (i = 0; i < M; i++)
	for (j = 0; j < N; j++) {
	  fprintf(stderr, DATA_PRINTF_MODIFIER, C[i][j]);
	if ((i * N + j) % 80 == 20) fprintf(stderr, "\n");
      }
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int i, j, k;
  int n = N;
  int m = M;

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
if ((m >= 1) && (n >= 1)) {
 lb1=0;
 ub1=(m-1);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4)
 for (c1=lb1; c1<=ub1; c1++) {
    for (c2=0;c2<=(n-1);c2++) {
      acc[c1][c2]=0;
    }
  }
 lb1=0;
 ub1=min(1,(n-1));
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4)
 for (c1=lb1; c1<=ub1; c1++) {
    for (c2=0;c2<=(m-1);c2++) {
      C[c2][c1]=beta*C[c2][c1]+alpha*A[c2][c2]*B[c2][c1]+alpha*acc[c2][c1];
    }
  }
 lb1=2;
 ub1=(n-1);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4)
 for (c1=lb1; c1<=ub1; c1++) {
    for (c2=0;c2<=min((c1-2),(m-1));c2++) {
      for (c3=0;c3<=(c1-2);c3++) {
        acc[c2][c1]+=B[c3][c1]*A[c3][c2];
      }
      for (c3=c1;c3<=(c1+c2-1);c3++) {
        C[c2][c1]+=alpha*A[c2][(-c1+c3)]*B[(-c1+c3)][c1];
      }
      C[c2][c1]+=alpha*A[c2][c2]*B[c2][c1];
      C[c2][c1]=beta*C[c2][c1]+alpha*A[c2][c2]*B[c2][c1]+alpha*acc[c2][c1];
      for (c3=(c1+c2+1);c3<=(c1+m-1);c3++) {
        C[c2][c1]+=alpha*A[c2][(-c1+c3)]*B[(-c1+c3)][c1];
      }
    }
    for (c2=m;c2<=(c1-2);c2++) {
      for (c3=c1;c3<=(c1+m-1);c3++) {
        C[c2][c1]+=alpha*A[c2][(-c1+c3)]*B[(-c1+c3)][c1];
      }
    }
    for (c2=(c1-1);c2<=(m-1);c2++) {
      for (c3=0;c3<=(c1-2);c3++) {
        acc[c2][c1]+=B[c3][c1]*A[c3][c2];
      }
      C[c2][c1]=beta*C[c2][c1]+alpha*A[c2][c2]*B[c2][c1]+alpha*acc[c2][c1];
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
