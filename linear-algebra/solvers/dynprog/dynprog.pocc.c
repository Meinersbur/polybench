#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"

/* Default problem size. */
#ifndef TSTEPS
# define TSTEPS 10000
#endif
#ifndef LENGTH
# define LENGTH 50
#endif

/* Default data type is int. */
#ifndef DATA_TYPE
# define DATA_TYPE int
#endif
#ifndef DATA_PRINTF_MODIFIER
# define DATA_PRINTF_MODIFIER "%d "
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
DATA_TYPE out;
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE sum_c[LENGTH][LENGTH][LENGTH];
DATA_TYPE c[LENGTH][LENGTH];
DATA_TYPE W[LENGTH][LENGTH]; //input
#else
DATA_TYPE** c = (DATA_TYPE**)malloc(LENGTH * sizeof(DATA_TYPE*));
DATA_TYPE** w = (DATA_TYPE**)malloc(LENGTH * sizeof(DATA_TYPE*));
DATA_TYPE*** sum_c = (DATA_TYPE***)malloc(LENGTH * sizeof(DATA_TYPE**));
{
  int i, j;
  for (i = 0; i < LENGTH; ++i)
    {
      c[i] = (DATA_TYPE*)malloc(LENGTH * sizeof(DATA_TYPE));
      W[i] = (DATA_TYPE*)malloc(LENGTH * sizeof(DATA_TYPE));
      sum_c[i] = (DATA_TYPE**)malloc(LENGTH * sizeof(DATA_TYPE*));
      for (j = 0; j < LENGTH; ++j)
	sum_c[i][j] = (DATA_TYPE*)malloc(LENGTH * sizeof(DATA_TYPE));
    }
}
#endif

inline
void init_array()
{
  int i, j;

  for (i = 0; i < LENGTH; i++)
    for (j = 0; j < LENGTH; j++)
      W[i][j] = ((DATA_TYPE) i*j + 1) / LENGTH;
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
      fprintf(stderr, DATA_PRINTF_MODIFIER, out);
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int iter, i, j, k;
  int length = LENGTH;
  int tsteps = TSTEPS;

  /* Initialize array. */
  init_array();

  /* Start timer. */
  polybench_start_instruments;


#define ceild(n,d)  ceil(((double)(n))/((double)(d)))
#define floord(n,d) floor(((double)(n))/((double)(d)))
#define max(x,y)    ((x) > (y)? (x) : (y))
#define min(x,y)    ((x) < (y)? (x) : (y))
  register int lbv, ubv, lb, ub, lb1, ub1, lb2, ub2;
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4, c5, c5t, newlb_c5, newub_c5, c6, c6t, newlb_c6, newub_c6, c7, c7t, newlb_c7, newub_c7, c8, c8t, newlb_c8, newub_c8;
#pragma scop
out=0;
for (c1=0;c1<=(tsteps-1);c1++) {
  for (c3=0;c3<=floord((length-2),16);c3++) {
 lb1=max(0,ceild((32*c3-length+1),32));
 ub1=floord((c3-1),2);
#pragma omp parallel for shared(c0,c1,c2,c3,lb1,ub1) private(c4,c5,c6,c7,c8)
 for (c4=lb1; c4<=ub1; c4++) {
      for (c6=(32*c3-32*c4);c6<=min((length-1),(32*c3-32*c4+31));c6++) {
        for (c7=32*c4;c7<=(32*c4+31);c7++) {
          c[c6][c7]=0;
        }
      }
    }
 lb1=ceild(c3,2);
 ub1=min(floord((length-1),32),c3);
#pragma omp parallel for shared(c0,c1,c2,c3,lb1,ub1) private(c4,c5,c6,c7,c8)
 for (c4=lb1; c4<=ub1; c4++) {
      for (c6=(32*c3-32*c4);c6<=min(min((32*c4+30),(length-2)),(32*c3-32*c4+31));c6++) {
        if (c3 == 2*c4) {
          for (c7=16*c3;c7<=c6;c7++) {
            if (c3%2 == 0) {
              c[c6][c7]=0;
            }
          }
        }
        for (c7=max(32*c4,(c6+1));c7<=min((32*c4+31),(length-1));c7++) {
          c[c6][c7]=0;
          sum_c[c6][c7][c6]=0;
        }
      }
      if ((c3 == 2*c4) && (c3 <= floord((length-33),16))) {
        for (c7=16*c3;c7<=(16*c3+31);c7++) {
          if (c3%2 == 0) {
            c[(16*c3+31)][c7]=0;
          }
        }
      }
      if ((c3 == 2*c4) && (c3 >= ceild((length-32),16))) {
        for (c7=16*c3;c7<=(length-1);c7++) {
          if (c3%2 == 0) {
            c[(length-1)][c7]=0;
          }
        }
      }
    }
  }
  if (((length+31))%32 == 0) {
    if (length >= 1) {
      if (((length+15))%16 == 0) {
        if (((length+31))%32 == 0) {
          c[(length-1)][(length-1)]=0;
        }
      }
    }
  }
  if (length >= 3) {
    for (c3=0;c3<=floord((length-2),16);c3++) {
      if (16*c3 == (length-2)) {
        if (((length+30))%32 == 0) {
          c[(length-2)][(length-1)]=sum_c[(length-2)][(length-1)][(length-1)-1]+W[(length-2)][(length-1)];
        }
      }
 lb1=max(ceild(c3,2),ceild((32*c3-length+3),32));
 ub1=min(floord((length-1),32),c3);
#pragma omp parallel for shared(c0,c1,c2,c3,lb1,ub1) private(c4,c5,c6,c7,c8)
 for (c4=lb1; c4<=ub1; c4++) {
        for (c5=(c3-c4);c5<=(c4-1);c5++) {
          for (c6=(32*c3-32*c4);c6<=min((32*c5+30),(32*c3-32*c4+31));c6++) {
            for (c7=32*c4;c7<=min((32*c4+31),(length-1));c7++) {
              for (c8=max(32*c5,(c6+1));c8<=(32*c5+31);c8++) {
                sum_c[c6][c7][c8]=sum_c[c6][c7][c8-1]+c[c6][c8]+c[c8][c7];
              }
            }
          }
        }
        if (32*c4 == (length-1)) {
          if (((length+31))%32 == 0) {
            for (c6=(32*c3-length+1);c6<=(32*c3-length+32);c6++) {
              c[c6][(length-1)]=sum_c[c6][(length-1)][(length-1)-1]+W[c6][(length-1)];
            }
          }
        }
        if (c4 <= floord((length-2),32)) {
          for (c6=(32*c3-32*c4);c6<=min(min((32*c4+29),(length-3)),(32*c3-32*c4+31));c6++) {
            if (c4 >= ceild((c6+2),32)) {
              c[c6][32*c4]=sum_c[c6][32*c4][32*c4-1]+W[c6][32*c4];
            }
            if (c4 <= floord((c6+1),32)) {
              c[c6][(c6+1)]=sum_c[c6][(c6+1)][(c6+1)-1]+W[c6][(c6+1)];
            }
            for (c7=max((32*c4+1),(c6+2));c7<=min((32*c4+31),(length-1));c7++) {
              for (c8=max(32*c4,(c6+1));c8<=(c7-1);c8++) {
                sum_c[c6][c7][c8]=sum_c[c6][c7][c8-1]+c[c6][c8]+c[c8][c7];
              }
              c[c6][c7]=sum_c[c6][c7][c7-1]+W[c6][c7];
            }
          }
          if ((c3 == 2*c4) && (c3 <= floord((length-33),16))) {
            if (c3%2 == 0) {
              c[(16*c3+30)][(16*c3+31)]=sum_c[(16*c3+30)][(16*c3+31)][(16*c3+31)-1]+W[(16*c3+30)][(16*c3+31)];
            }
          }
          if ((c3 == 2*c4) && (c3 >= ceild((length-32),16))) {
            if (c3%2 == 0) {
              c[(length-2)][(length-1)]=sum_c[(length-2)][(length-1)][(length-1)-1]+W[(length-2)][(length-1)];
            }
          }
        }
      }
    }
  }
  if (length == 2) {
    c[0][1]=sum_c[0][1][1 -1]+W[0][1];
  }
  out+=c[0][length-1];
}
#pragma endscop

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  print_array(argc, argv);

  return 0;
}
