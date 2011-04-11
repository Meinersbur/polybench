#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"

/* Default problem size. */
#ifndef M
# define M 1920
#endif
#ifndef N
# define N 1080
#endif
#ifndef T
# define T 1920
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
DATA_TYPE tot[4];
DATA_TYPE Gauss[4];
DATA_TYPE g_tmp_image[N][M];
DATA_TYPE g_acc1[N][M][4];
DATA_TYPE g_acc2[N][M][4];
DATA_TYPE in_image[N][M]; //input
DATA_TYPE gauss_image[N][M]; //output
#else
DATA_TYPE** g_tmp_image = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE*));
DATA_TYPE** in_image = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE*));
DATA_TYPE** gauss_image = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE*));
DATA_TYPE*** g_acc1 = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE**));
DATA_TYPE*** g_acc2 = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE**));
{
  int i, j;
  for (i = 0; i < N; ++i)
    {
      g_tmp_image[i] = (DATA_TYPE*)malloc(M * sizeof(DATA_TYPE));
      in_image[i] = (DATA_TYPE*)malloc(M * sizeof(DATA_TYPE));
      gauss_image[i] = (DATA_TYPE*)malloc(M * sizeof(DATA_TYPE));
      g_acc1[i] = (DATA_TYPE**)malloc(M * sizeof(DATA_TYPE*));
      g_acc2[i] = (DATA_TYPE**)malloc(M * sizeof(DATA_TYPE*));
      for (j = 0; j < M; ++j)
	{
	  g_acc1[i][j] = (DATA_TYPE*)malloc(4 * sizeof(DATA_TYPE));
	  g_acc2[i][j] = (DATA_TYPE*)malloc(4 * sizeof(DATA_TYPE));
	}
    }
}
#endif

inline
void init_array()
{
  int i, j;

  for (i = 0; i < N; i++)
    for (j = 0; j < M; j++)
      in_image[i][j] = ((DATA_TYPE) i*j) / M;
  for (i = 0; i < 4; i++)
      Gauss[i] = i;
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
      for (i = 0; i < N; i++)
	for (j = 0; j < M; j++) {
	  fprintf(stderr, DATA_PRINTF_MODIFIER, gauss_image[i][j]);
	  if ((i * N + j) % 80 == 20) fprintf(stderr, "\n");
	}
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int x, y, k;
  int t = T;
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
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4, c5, c5t, newlb_c5, newub_c5, c6, c6t, newlb_c6, newub_c6;
#pragma scop
if ((m >= 3) && (n >= 3)) {
  // parfor
  for (c4=2;c4<=(n+m-4);c4++) {
    // parfor
 lb1=max(1,(c4-n+2));
 ub1=min((c4-1),(m-2));
#pragma omp parallel for shared(c0,c1,c2,c3,c4,lb1,ub1) private(c5,c6)
 for (c5=lb1; c5<=ub1; c5++) {
      g_acc2[(c4-c5)][c5][0]=0;
    }
  }
}
if ((m >= 1) && (n >= 4)) {
  // parfor
  for (c4=1;c4<=(n+m-4);c4++) {
    // parfor
 lb1=max(0,(c4-n+3));
 ub1=min((c4-1),(m-1));
#pragma omp parallel for shared(c0,c1,c2,c3,c4,lb1,ub1) private(c5,c6)
 for (c5=lb1; c5<=ub1; c5++) {
      g_acc1[(c4-c5)][c5][0]=0;
    }
  }
}
if ((m >= 1) && (n >= 4)) {
  // parfor
  for (c4=1;c4<=(n+m-4);c4++) {
    // parfor
 lb1=max(0,(c4-n+3));
 ub1=min((c4-1),(m-1));
#pragma omp parallel for shared(c0,c1,c2,c3,c4,lb1,ub1) private(c5,c6)
 for (c5=lb1; c5<=ub1; c5++) {
      for (c6=(t-1);c6<=(t+1);c6++) {
        g_acc1[(c4-c5)][c5][c6+2-t]=g_acc1[(c4-c5)][c5][c6+1-t]+in_image[(c4-c5)+c6-t][c5]*Gauss[c6-t+1];
      }
    }
  }
}
tot[0]=0;
// parfor
for (c4=(t-1);c4<=(t+1);c4++) {
  tot[c4+2-t]=tot[c4+1-t]+Gauss[c4-t+1];
}
// parfor
for (c4=(t-1);c4<=(t+1);c4++) {
  tot[c4+2-t]=tot[c4+1-t]+Gauss[c4-t+1];
}
if ((m >= 1) && (n >= 4)) {
  // parfor
  for (c4=1;c4<=(n+m-4);c4++) {
    // parfor
 lb1=max(0,(c4-n+3));
 ub1=min((c4-1),(m-1));
#pragma omp parallel for shared(c0,c1,c2,c3,c4,lb1,ub1) private(c5,c6)
 for (c5=lb1; c5<=ub1; c5++) {
      g_tmp_image[(c4-c5)][c5]=g_acc1[(c4-c5)][c5][3]/tot[3];
    }
  }
}
if ((m >= 3) && (n >= 3)) {
  // parfor
  for (c4=2;c4<=(n+m-4);c4++) {
    // parfor
 lb1=max(1,(c4-n+2));
 ub1=min((c4-1),(m-2));
#pragma omp parallel for shared(c0,c1,c2,c3,c4,lb1,ub1) private(c5,c6)
 for (c5=lb1; c5<=ub1; c5++) {
      // parfor
      for (c6=(t-1);c6<=(t+1);c6++) {
        g_acc2[(c4-c5)][c5][c6+2-t]=g_acc2[(c4-c5)][c5][c6+1-t]+g_tmp_image[(c4-c5)][c5+c6-t]*Gauss[c6-t+1];
      }
    }
  }
}
if ((m >= 3) && (n >= 3)) {
  // parfor
  for (c4=2;c4<=(n+m-4);c4++) {
    // parfor
 lb1=max(1,(c4-n+2));
 ub1=min((c4-1),(m-2));
#pragma omp parallel for shared(c0,c1,c2,c3,c4,lb1,ub1) private(c5,c6)
 for (c5=lb1; c5<=ub1; c5++) {
      gauss_image[(c4-c5)][c5]=g_acc2[(c4-c5)][c5][3]/tot[3];
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
