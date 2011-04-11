#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"

/* Default problem size. */
#ifndef TSTEPS
# define TSTEPS 20
#endif
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
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE A[N][N];
#else
DATA_TYPE** A = (DATA_TYPE**)malloc(N * sizeof(DATA_TYPE*));
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
    for (j = 0; j < N; j++)
      A[i][j] = ((DATA_TYPE) i*j + 10) / N;
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
	for (j = 0; j < N; j++) {
	  fprintf(stderr, DATA_PRINTF_MODIFIER, A[i][j]);
	  if ((i * N + j) % 80 == 20) fprintf(stderr, "\n");
	}
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int t, i, j;
  int tsteps = TSTEPS;
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
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4, c5, c5t, newlb_c5, newub_c5;

#pragma scop
if ((n >= 3) && (tsteps >= 1)) {
  for (c0=0;c0<=floord((2*tsteps+n-4),32);c0++) {
 lb1=max(ceild(c0,2),ceild((32*c0-tsteps+1),32));
 ub1=min(min(floord((tsteps+n-3),32),floord((32*c0+n+29),64)),c0);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4,c5)
 for (c1=lb1; c1<=ub1; c1++) {
      for (c2=max(ceild((64*c1-n-28),32),c0);c2<=min(min(min(min(floord((tsteps+n-3),16),floord((32*c0-32*c1+n+29),16)),floord((32*c0+n+60),32)),floord((64*c1+n+59),32)),floord((32*c1+tsteps+n+28),32));c2++) {
        for (c3=max(max(max((32*c0-32*c1),(32*c1-n+2)),(16*c2-n+2)),(-32*c1+32*c2-n-29));c3<=min(min(min(min((32*c1+30),(16*c2+14)),(tsteps-1)),(32*c0-32*c1+31)),(-32*c1+32*c2+30));c3++) {
          for (c4=max(max(32*c1,(c3+1)),(32*c2-c3-n+2));c4<=min(min((32*c1+31),(32*c2-c3+30)),(c3+n-2));c4++) {
            for (c5=max(32*c2,(c3+c4+1));c5<=min((32*c2+31),(c3+c4+n-2));c5++) {
              A[(-c3+c4)][(-c3-c4+c5)]=(A[(-c3+c4)-1][(-c3-c4+c5)-1]+A[(-c3+c4)-1][(-c3-c4+c5)]+A[(-c3+c4)-1][(-c3-c4+c5)+1]+A[(-c3+c4)][(-c3-c4+c5)-1]+A[(-c3+c4)][(-c3-c4+c5)]+A[(-c3+c4)][(-c3-c4+c5)+1]+A[(-c3+c4)+1][(-c3-c4+c5)-1]+A[(-c3+c4)+1][(-c3-c4+c5)]+A[(-c3+c4)+1][(-c3-c4+c5)+1])/9.0;
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
