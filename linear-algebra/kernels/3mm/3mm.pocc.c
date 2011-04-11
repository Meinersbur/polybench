#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"


/* Default problem size. */
#ifndef NI
# define NI 512
#endif
#ifndef NJ
# define NJ 512
#endif
#ifndef NK
# define NK 512
#endif
#ifndef NL
# define NL 512
#endif
#ifndef NM
# define NM 512
#endif


/* Default data type is double (dgemm). */
#ifndef DATA_TYPE
# define DATA_TYPE double
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE A[NI][NK];
DATA_TYPE B[NK][NJ];
DATA_TYPE C[NJ][NM];
DATA_TYPE D[NM][NL];
DATA_TYPE E[NI][NJ];
DATA_TYPE F[NJ][NL];
DATA_TYPE G[NI][NL];
#else
DATA_TYPE** A = (DATA_TYPE**)malloc(NI * sizeof(DATA_TYPE*));
DATA_TYPE** B = (DATA_TYPE**)malloc(NK * sizeof(DATA_TYPE*));
DATA_TYPE** C = (DATA_TYPE**)malloc(NJ * sizeof(DATA_TYPE*));
DATA_TYPE** D = (DATA_TYPE**)malloc(NM * sizeof(DATA_TYPE*));
DATA_TYPE** E = (DATA_TYPE**)malloc(NI * sizeof(DATA_TYPE*));
DATA_TYPE** F = (DATA_TYPE**)malloc(NJ * sizeof(DATA_TYPE*));
DATA_TYPE** G = (DATA_TYPE**)malloc(NI * sizeof(DATA_TYPE*));
{
  int i;
  for (i = 0; i < NI; ++i)
    {
      A[i] = (DATA_TYPE*)malloc(NK * sizeof(DATA_TYPE));
      E[i] = (DATA_TYPE*)malloc(NJ * sizeof(DATA_TYPE));
      G[i] = (DATA_TYPE*)malloc(NL * sizeof(DATA_TYPE));
    }
  for (i = 0; i < NK; ++i)
    B[i] = (DATA_TYPE*)malloc(NJ * sizeof(DATA_TYPE));
  for (i = 0; i < NJ; ++i)
    {
      C[i] = (DATA_TYPE*)malloc(NM * sizeof(DATA_TYPE));
      F[i] = (DATA_TYPE*)malloc(NL * sizeof(DATA_TYPE));
    }
  for (i = 0; i < NM; ++i)
    D[i] = (DATA_TYPE*)malloc(NL * sizeof(DATA_TYPE));
}
#endif


inline
void init_array()
{
  int i, j;

  for (i = 0; i < NI; i++)
    for (j = 0; j < NK; j++)
      A[i][j] = ((DATA_TYPE) i*j)/NI;
  for (i = 0; i < NK; i++)
    for (j = 0; j < NJ; j++)
      B[i][j] = ((DATA_TYPE) i*j + 1)/NJ;
  for (i = 0; i < NJ; i++)
    for (j = 0; j < NM; j++)
      C[i][j] = ((DATA_TYPE) i*j + 2)/NJ;
  for (i = 0; i < NM; i++)
    for (j = 0; j < NL; j++)
      D[i][j] = ((DATA_TYPE) i*j + 2)/NJ;
  for (i = 0; i < NI; i++)
    for (j = 0; j < NJ; j++)
      E[i][j] = ((DATA_TYPE) i*j + 2)/NJ;
  for (i = 0; i < NJ; i++)
    for (j = 0; j < NL; j++)
      F[i][j] = ((DATA_TYPE) i*j + 2)/NJ;
  for (i = 0; i < NI; i++)
    for (j = 0; j < NL; j++)
      G[i][j] = ((DATA_TYPE) i*j + 2)/NJ;
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
      for (i = 0; i < NI; i++) {
	for (j = 0; j < NL; j++) {
	  fprintf(stderr, "%0.2lf ", G[i][j]);
	  if ((i * NI + j) % 80 == 20) fprintf(stderr, "\n");
	}
	fprintf(stderr, "\n");
      }
    }
}


int main(int argc, char** argv)
{
  int i, j, k;
  int ni = NI;
  int nj = NJ;
  int nk = NK;
  int nl = NL;
  int nm = NM;

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
if (ni >= 1) {
  if (nk >= 1) {
 lb1=0;
 ub1=(ni-1);
#pragma omp parallel for shared(lb1,ub1) private(c0,c1,c2,c3,c4,c5,c6)
 for (c0=lb1; c0<=ub1; c0++) {
      // parfor
      for (c1=0;c1<=(c0-1);c1++) {
        G[c0][c1]=0;
      }
      for (c1=c0;c1<=min((ni-1),(c0+nk-1));c1++) {
        G[c0][c1]=0;
        F[(-c0+c1)][c0]=0;
        for (c6=0;c6<=(nk-1);c6++) {
          F[(-c0+c1)][c0]+=C[(-c0+c1)][c6]*D[c6][c0];
        }
        E[c0][(-c0+c1)]=0;
        for (c6=0;c6<=(nk-1);c6++) {
          E[c0][(-c0+c1)]+=A[c0][c6]*B[c6][(-c0+c1)];
        }
        // parfor
        for (c6=0;c6<=c0;c6++) {
          G[c6][(c0-c6)]+=E[c6][(-c0+c1)]*F[(-c0+c1)][(c0-c6)];
        }
      }
      for (c1=(c0+nk);c1<=(ni-1);c1++) {
        G[c0][c1]=0;
        F[(-c0+c1)][c0]=0;
        for (c6=0;c6<=(nk-1);c6++) {
          F[(-c0+c1)][c0]+=C[(-c0+c1)][c6]*D[c6][c0];
        }
        E[c0][(-c0+c1)]=0;
        for (c6=0;c6<=(nk-1);c6++) {
          E[c0][(-c0+c1)]+=A[c0][c6]*B[c6][(-c0+c1)];
        }
      }
      for (c1=ni;c1<=min((c0+ni-1),(c0+nk-1));c1++) {
        F[(-c0+c1)][c0]=0;
        for (c6=0;c6<=(nk-1);c6++) {
          F[(-c0+c1)][c0]+=C[(-c0+c1)][c6]*D[c6][c0];
        }
        E[c0][(-c0+c1)]=0;
        for (c6=0;c6<=(nk-1);c6++) {
          E[c0][(-c0+c1)]+=A[c0][c6]*B[c6][(-c0+c1)];
        }
        // parfor
        for (c6=0;c6<=c0;c6++) {
          G[c6][(c0-c6)]+=E[c6][(-c0+c1)]*F[(-c0+c1)][(c0-c6)];
        }
      }
      for (c1=max(ni,(c0+nk));c1<=(c0+ni-1);c1++) {
        F[(-c0+c1)][c0]=0;
        for (c6=0;c6<=(nk-1);c6++) {
          F[(-c0+c1)][c0]+=C[(-c0+c1)][c6]*D[c6][c0];
        }
        E[c0][(-c0+c1)]=0;
        for (c6=0;c6<=(nk-1);c6++) {
          E[c0][(-c0+c1)]+=A[c0][c6]*B[c6][(-c0+c1)];
        }
      }
      for (c1=(c0+ni);c1<=(c0+nk-1);c1++) {
        // parfor
        for (c6=0;c6<=c0;c6++) {
          G[c6][(c0-c6)]+=E[c6][(-c0+c1)]*F[(-c0+c1)][(c0-c6)];
        }
      }
    }
  }
  if (nk <= 0) {
    // parfor
 lb1=0;
 ub1=(ni-1);
#pragma omp parallel for shared(lb1,ub1) private(c0,c1,c2,c3,c4,c5,c6)
 for (c0=lb1; c0<=ub1; c0++) {
      // parfor
      for (c1=0;c1<=(c0-1);c1++) {
        G[c0][c1]=0;
      }
      // parfor
      for (c1=c0;c1<=(ni-1);c1++) {
        G[c0][c1]=0;
        F[(-c0+c1)][c0]=0;
        E[c0][(-c0+c1)]=0;
      }
      // parfor
      for (c1=ni;c1<=(c0+ni-1);c1++) {
        F[(-c0+c1)][c0]=0;
        E[c0][(-c0+c1)]=0;
      }
    }
  }
  if (nk >= 1) {
    // parfor
 lb1=ni;
 ub1=(2*ni-2);
#pragma omp parallel for shared(lb1,ub1) private(c0,c1,c2,c3,c4,c5,c6)
 for (c0=lb1; c0<=ub1; c0++) {
      for (c1=c0;c1<=(c0+nk-1);c1++) {
        // parfor
        for (c6=(c0-ni+1);c6<=(ni-1);c6++) {
          G[c6][(c0-c6)]+=E[c6][(-c0+c1)]*F[(-c0+c1)][(c0-c6)];
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
