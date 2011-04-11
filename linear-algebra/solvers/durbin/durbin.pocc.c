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

/* Default data type is int. */
#ifndef DATA_TYPE
# define DATA_TYPE int
#endif
#ifndef DATA_PRINTF_MODIFIER
# define DATA_PRINTF_MODIFIER "%d "
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE y[N][N];
DATA_TYPE sum[N][N];
DATA_TYPE beta[N];
DATA_TYPE alpha[N];
DATA_TYPE r[N]; //input
DATA_TYPE out[N]; //output
#else
DATA_TYPE** y = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE*));
DATA_TYPE** sum = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE*));
DATA_TYPE* beta = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
DATA_TYPE* alpha = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
DATA_TYPE* r = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
DATA_TYPE* out = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
{
  int i;
  for (i = 0; i < N; ++i)
    {
      y[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
      sum[i] = (DATA_TYPE*)malloc(N * sizeof(DATA_TYPE));
    }
}
#endif

inline
void init_array()
{
  int i;

  for (i = 0; i < N; i++)
    r[i] = i * M_PI;
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
	fprintf(stderr, DATA_PRINTF_MODIFIER, r[i]);
	if (i%80 == 20) fprintf(stderr, "\n");
      }
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int i, k;
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
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4, c5, c5t, newlb_c5, newub_c5, c6, c6t, newlb_c6, newub_c6;
#pragma scop
y[0][0]=r[0];
beta[0]=1;
alpha[0]=r[0];
// parfor
for (c1=1;c1<=(n-1);c1++) {
  sum[0][c1]=r[c1];
}
// parfor
for (c1=1;c1<=(n-1);c1++) {
  sum[0 +1][c1]=sum[0][c1]+r[c1-(0)-1]*y[0][c1-1];
  beta[c1]=beta[c1-1]-alpha[c1-1]*alpha[c1-1]*beta[c1-1];
  // parfor
  for (c2=1;c2<=(c1-1);c2++) {
    sum[c2+1][c1]=sum[c2][c1]+r[c1-(c2)-1]*y[c2][c1-1];
  }
  alpha[c1]=-sum[c1][c1]*beta[c1];
  y[c1][c1]=alpha[c1];
  // parfor
  for (c2=c1;c2<=(2*c1-1);c2++) {
    y[(-c1+c2)][c1]=y[(-c1+c2)][c1-1]+alpha[c1]*y[c1-((-c1+c2))-1][c1-1];
  }
}
// parfor
for (c1=0;c1<=(n-1);c1++) {
  out[c1]=y[c1][N-1];
}
#pragma endscop

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  print_array(argc, argv);

  return 0;
}
