#include <omp.h>
#include <math.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

#include "instrument.h"

/* Default problem size. */
#ifndef LENGTH
# define LENGTH 64
#endif
#ifndef MAXGRID
# define MAXGRID 6
#endif
#ifndef MAXRGC
# define MAXRGC ((MAXGRID - 1) * (MAXGRID - 1) * MAXGRID)
#endif
#ifndef NITER
# define NITER 100000
#endif

/* Default data type is int. */
#ifndef DATA_TYPE
# define DATA_TYPE int
#endif
#ifndef DATA_PRINTF_MODIFIER
# define DATA_PRINTF_MODIFIER "%d "
#endif

/* Array declaration. Enable malloc if POLYBENCH_TEST_MALLOC. */
DATA_TYPE s;
#ifndef POLYBENCH_TEST_MALLOC
DATA_TYPE sum_tang[MAXGRID][MAXGRID];
DATA_TYPE mean[MAXGRID][MAXGRID];
DATA_TYPE diff[MAXGRID][MAXGRID][LENGTH];
DATA_TYPE sum_diff[MAXGRID][MAXGRID][LENGTH];
DATA_TYPE tangent[MAXRGC]; //input
DATA_TYPE path[MAXGRID][MAXGRID]; //output
#else
DATA_TYPE** sum_tang = (DATA_TYPE**)malloc(MAXGRID * sizeof(DATA_TYPE*));
DATA_TYPE** mean = (DATA_TYPE**)malloc(MAXGRID * sizeof(DATA_TYPE*));
DATA_TYPE** path = (DATA_TYPE**)malloc(MAXGRID * sizeof(DATA_TYPE*));
DATA_TYPE*** diff = (DATA_TYPE***)malloc(MAXGRID * sizeof(DATA_TYPE**));
DATA_TYPE*** sum_diff = (DATA_TYPE***)malloc(MAXGRID * sizeof(DATA_TYPE**));
DATA_TYPE* tangent = (DATA_TYPE*)malloc(MAXRGC * sizeof(DATA_TYPE));
{
  int i, j;
  for (i = 0; i < MAXGRID; ++i)
    {
      sum_tang[i] = (DATA_TYPE*)malloc(MAXGRID * sizeof(DATA_TYPE));
      mean[i] = (DATA_TYPE*)malloc(MAXGRID * sizeof(DATA_TYPE));
      path[i] = (DATA_TYPE*)malloc(MAXGRID * sizeof(DATA_TYPE));
      diff[i] = (DATA_TYPE**)malloc(MAXGRID * sizeof(DATA_TYPE*));
      sum_diff[i] = (DATA_TYPE**)malloc(MAXGRID * sizeof(DATA_TYPE*));
      for (j = 0; j < MAXGRID; ++j)
	{
	  diff[i][j] = (DATA_TYPE**)malloc(LENGTH * sizeof(DATA_TYPE));
	  sum_diff[i][j] = (DATA_TYPE**)malloc(LENGTH * sizeof(DATA_TYPE));
	}
    }
}
#endif

inline
void init_array()
{
  int i;

  for (i = 0; i < MAXRGC; i++)
    tangent[i] = ((DATA_TYPE) i + 42);
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
      fprintf(stderr, DATA_PRINTF_MODIFIER, s);
      fprintf(stderr, "\n");
    }
}


int main(int argc, char** argv)
{
  int t, i, j, cnt;
  int length = LENGTH;
  int maxgrid = MAXGRID;
  int niter = NITER;

  /* Initialize array. */
  init_array();

  /* Start timer. */
  polybench_start_instruments;


  s = 0;
  for (j = 0; j <= maxgrid - 1; j++)
    {
      sum_tang[j][j] = tangent[(maxgrid+1)*j];
      for (i = j + 1; i <= maxgrid - 1; i++)
	sum_tang[j][i] = sum_tang[j][i-1] + tangent[i + maxgrid * j];
    }

#define ceild(n,d)  ceil(((double)(n))/((double)(d)))
#define floord(n,d) floor(((double)(n))/((double)(d)))
#define max(x,y)    ((x) > (y)? (x) : (y))
#define min(x,y)    ((x) < (y)? (x) : (y))
  register int lbv, ubv, lb, ub, lb1, ub1, lb2, ub2;
  register int c0, c0t, newlb_c0, newub_c0, c1, c1t, newlb_c1, newub_c1, c2, c2t, newlb_c2, newub_c2, c3, c3t, newlb_c3, newub_c3, c4, c4t, newlb_c4, newub_c4, c5, c5t, newlb_c5, newub_c5, c6, c6t, newlb_c6, newub_c6;
#pragma scop
if (niter >= 1) {
  if ((length >= 2) && (maxgrid >= 2)) {
    for (c4=0;c4<=(length-1);c4++) {
      diff[0][0][c4]=sum_tang[0][0];
    }
    sum_diff[0][0][0]=diff[0][0][0];
    for (c4=1;c4<=(length-1);c4++) {
      sum_diff[0][0][c4]=sum_diff[0][0][c4-1]+diff[0][0][c4];
    }
    mean[0][0]=sum_diff[0][0][length-1];
    path[0][0]=mean[0][0];
  }
  if ((length >= 2) && (maxgrid == 1)) {
    for (c4=0;c4<=(length-1);c4++) {
      diff[0][0][c4]=sum_tang[0][0];
    }
    sum_diff[0][0][0]=diff[0][0][0];
    for (c4=1;c4<=(length-1);c4++) {
      sum_diff[0][0][c4]=sum_diff[0][0][c4-1]+diff[0][0][c4];
    }
    mean[0][0]=sum_diff[0][0][length-1];
    path[0][0]=mean[0][0];
  }
  if ((length == 1) && (maxgrid >= 2)) {
    diff[0][0][0]=sum_tang[0][0];
    sum_diff[0][0][0]=diff[0][0][0];
    mean[0][0]=sum_diff[0][0][length-1];
    path[0][0]=mean[0][0];
  }
  if ((length == 1) && (maxgrid == 1)) {
    diff[0][0][0]=sum_tang[0][0];
    sum_diff[0][0][0]=diff[0][0][0];
    mean[0][0]=sum_diff[0][0][length-1];
    path[0][0]=mean[0][0];
  }
  if ((length <= 0) && (maxgrid >= 2)) {
    sum_diff[0][0][0]=diff[0][0][0];
    mean[0][0]=sum_diff[0][0][length-1];
    path[0][0]=mean[0][0];
  }
  if ((length <= 0) && (maxgrid == 1)) {
    sum_diff[0][0][0]=diff[0][0][0];
    mean[0][0]=sum_diff[0][0][length-1];
    path[0][0]=mean[0][0];
  }
  if (maxgrid <= 0) {
    for (c0=1;c0<=(2*niter+maxgrid-3);c0+=2) {
      s+=path[maxgrid-1][1];
    }
  }
  if ((length >= 2) && (maxgrid >= 2)) {
    for (c0=1;c0<=(2*niter-1);c0++) {
      if (c0%2 == 0) {
        for (c4=0;c4<=(length-1);c4++) {
          diff[0][0][c4]=sum_tang[0][0];
        }
        sum_diff[0][0][0]=diff[0][0][0];
        for (c4=1;c4<=(length-1);c4++) {
          sum_diff[0][0][c4]=sum_diff[0][0][c4-1]+diff[0][0][c4];
        }
        mean[0][0]=sum_diff[0][0][length-1];
        path[0][0]=mean[0][0];
      }
      if (((c0+1))%2 == 0) {
        for (c4=0;c4<=(length-1);c4++) {
          diff[0][1][c4]=sum_tang[0][1];
        }
        sum_diff[0][1][0]=diff[0][1][0];
        for (c4=1;c4<=(length-1);c4++) {
          sum_diff[0][1][c4]=sum_diff[0][1][c4-1]+diff[0][1][c4];
        }
        mean[0][1]=sum_diff[0][1][length-1];
        path[0][1]=mean[0][1];
        for (c4=0;c4<=(length-1);c4++) {
          diff[1][1][c4]=sum_tang[1][1];
        }
        sum_diff[1][1][0]=diff[1][1][0];
        for (c4=1;c4<=(length-1);c4++) {
          sum_diff[1][1][c4]=sum_diff[1][1][c4-1]+diff[1][1][c4];
        }
        mean[1][1]=sum_diff[1][1][length-1];
        path[1][1]=path[1 -1][1 -1]+mean[1][1];
        s+=path[maxgrid-1][1];
      }
 lb1=ceild((c0+2),2);
 ub1=min(floord((c0+maxgrid-1),2),c0);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4,c5,c6)
 for (c1=lb1; c1<=ub1; c1++) {
        for (c4=0;c4<=(length-1);c4++) {
          diff[0][(-c0+2*c1)][c4]=sum_tang[0][(-c0+2*c1)];
        }
        sum_diff[0][(-c0+2*c1)][0]=diff[0][(-c0+2*c1)][0];
        for (c4=1;c4<=(length-1);c4++) {
          sum_diff[0][(-c0+2*c1)][c4]=sum_diff[0][(-c0+2*c1)][c4-1]+diff[0][(-c0+2*c1)][c4];
        }
        mean[0][(-c0+2*c1)]=sum_diff[0][(-c0+2*c1)][length-1];
        path[0][(-c0+2*c1)]=mean[0][(-c0+2*c1)];
        for (c2=(c0-c1+1);c2<=c1;c2++) {
          for (c4=0;c4<=(length-1);c4++) {
            diff[(-c0+c1+c2)][(-c0+2*c1)][c4]=sum_tang[(-c0+c1+c2)][(-c0+2*c1)];
          }
          sum_diff[(-c0+c1+c2)][(-c0+2*c1)][0]=diff[(-c0+c1+c2)][(-c0+2*c1)][0];
          for (c4=1;c4<=(length-1);c4++) {
            sum_diff[(-c0+c1+c2)][(-c0+2*c1)][c4]=sum_diff[(-c0+c1+c2)][(-c0+2*c1)][c4-1]+diff[(-c0+c1+c2)][(-c0+2*c1)][c4];
          }
          mean[(-c0+c1+c2)][(-c0+2*c1)]=sum_diff[(-c0+c1+c2)][(-c0+2*c1)][length-1];
          path[(-c0+c1+c2)][(-c0+2*c1)]=path[(-c0+c1+c2)-1][(-c0+2*c1)-1]+mean[(-c0+c1+c2)][(-c0+2*c1)];
        }
      }
    }
  }
  if (length >= 2) {
    for (c0=2*niter;c0<=(2*niter+maxgrid-3);c0++) {
 lb1=(c0-niter+1);
 ub1=min(floord((c0+maxgrid-1),2),c0);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4,c5,c6)
 for (c1=lb1; c1<=ub1; c1++) {
        for (c4=0;c4<=(length-1);c4++) {
          diff[0][(-c0+2*c1)][c4]=sum_tang[0][(-c0+2*c1)];
        }
        sum_diff[0][(-c0+2*c1)][0]=diff[0][(-c0+2*c1)][0];
        for (c4=1;c4<=(length-1);c4++) {
          sum_diff[0][(-c0+2*c1)][c4]=sum_diff[0][(-c0+2*c1)][c4-1]+diff[0][(-c0+2*c1)][c4];
        }
        mean[0][(-c0+2*c1)]=sum_diff[0][(-c0+2*c1)][length-1];
        path[0][(-c0+2*c1)]=mean[0][(-c0+2*c1)];
        for (c2=(c0-c1+1);c2<=c1;c2++) {
          for (c4=0;c4<=(length-1);c4++) {
            diff[(-c0+c1+c2)][(-c0+2*c1)][c4]=sum_tang[(-c0+c1+c2)][(-c0+2*c1)];
          }
          sum_diff[(-c0+c1+c2)][(-c0+2*c1)][0]=diff[(-c0+c1+c2)][(-c0+2*c1)][0];
          for (c4=1;c4<=(length-1);c4++) {
            sum_diff[(-c0+c1+c2)][(-c0+2*c1)][c4]=sum_diff[(-c0+c1+c2)][(-c0+2*c1)][c4-1]+diff[(-c0+c1+c2)][(-c0+2*c1)][c4];
          }
          mean[(-c0+c1+c2)][(-c0+2*c1)]=sum_diff[(-c0+c1+c2)][(-c0+2*c1)][length-1];
          path[(-c0+c1+c2)][(-c0+2*c1)]=path[(-c0+c1+c2)-1][(-c0+2*c1)-1]+mean[(-c0+c1+c2)][(-c0+2*c1)];
        }
      }
    }
  }
  if ((length >= 2) && (maxgrid == 1)) {
    for (c0=1;c0<=(2*niter-2);c0++) {
      if (((c0+1))%2 == 0) {
        s+=path[maxgrid-1][1];
      }
      if (c0%2 == 0) {
        for (c4=0;c4<=(length-1);c4++) {
          diff[0][0][c4]=sum_tang[0][0];
        }
        sum_diff[0][0][0]=diff[0][0][0];
        for (c4=1;c4<=(length-1);c4++) {
          sum_diff[0][0][c4]=sum_diff[0][0][c4-1]+diff[0][0][c4];
        }
        mean[0][0]=sum_diff[0][0][length-1];
        path[0][0]=mean[0][0];
      }
    }
  }
  if ((length == 1) && (maxgrid >= 2)) {
    for (c0=1;c0<=(2*niter-1);c0++) {
      if (c0%2 == 0) {
        diff[0][0][0]=sum_tang[0][0];
        sum_diff[0][0][0]=diff[0][0][0];
        mean[0][0]=sum_diff[0][0][length-1];
        path[0][0]=mean[0][0];
      }
      if (((c0+1))%2 == 0) {
        diff[0][1][0]=sum_tang[0][1];
        sum_diff[0][1][0]=diff[0][1][0];
        mean[0][1]=sum_diff[0][1][length-1];
        path[0][1]=mean[0][1];
        diff[1][1][0]=sum_tang[1][1];
        sum_diff[1][1][0]=diff[1][1][0];
        mean[1][1]=sum_diff[1][1][length-1];
        path[1][1]=path[1 -1][1 -1]+mean[1][1];
        s+=path[maxgrid-1][1];
      }
 lb1=ceild((c0+2),2);
 ub1=min(floord((c0+maxgrid-1),2),c0);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4,c5,c6)
 for (c1=lb1; c1<=ub1; c1++) {
        diff[0][(-c0+2*c1)][0]=sum_tang[0][(-c0+2*c1)];
        sum_diff[0][(-c0+2*c1)][0]=diff[0][(-c0+2*c1)][0];
        mean[0][(-c0+2*c1)]=sum_diff[0][(-c0+2*c1)][length-1];
        path[0][(-c0+2*c1)]=mean[0][(-c0+2*c1)];
        for (c2=(c0-c1+1);c2<=c1;c2++) {
          diff[(-c0+c1+c2)][(-c0+2*c1)][0]=sum_tang[(-c0+c1+c2)][(-c0+2*c1)];
          sum_diff[(-c0+c1+c2)][(-c0+2*c1)][0]=diff[(-c0+c1+c2)][(-c0+2*c1)][0];
          mean[(-c0+c1+c2)][(-c0+2*c1)]=sum_diff[(-c0+c1+c2)][(-c0+2*c1)][length-1];
          path[(-c0+c1+c2)][(-c0+2*c1)]=path[(-c0+c1+c2)-1][(-c0+2*c1)-1]+mean[(-c0+c1+c2)][(-c0+2*c1)];
        }
      }
    }
  }
  if (length == 1) {
    for (c0=2*niter;c0<=(2*niter+maxgrid-3);c0++) {
 lb1=(c0-niter+1);
 ub1=min(floord((c0+maxgrid-1),2),c0);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4,c5,c6)
 for (c1=lb1; c1<=ub1; c1++) {
        diff[0][(-c0+2*c1)][0]=sum_tang[0][(-c0+2*c1)];
        sum_diff[0][(-c0+2*c1)][0]=diff[0][(-c0+2*c1)][0];
        mean[0][(-c0+2*c1)]=sum_diff[0][(-c0+2*c1)][length-1];
        path[0][(-c0+2*c1)]=mean[0][(-c0+2*c1)];
        for (c2=(c0-c1+1);c2<=c1;c2++) {
          diff[(-c0+c1+c2)][(-c0+2*c1)][0]=sum_tang[(-c0+c1+c2)][(-c0+2*c1)];
          sum_diff[(-c0+c1+c2)][(-c0+2*c1)][0]=diff[(-c0+c1+c2)][(-c0+2*c1)][0];
          mean[(-c0+c1+c2)][(-c0+2*c1)]=sum_diff[(-c0+c1+c2)][(-c0+2*c1)][length-1];
          path[(-c0+c1+c2)][(-c0+2*c1)]=path[(-c0+c1+c2)-1][(-c0+2*c1)-1]+mean[(-c0+c1+c2)][(-c0+2*c1)];
        }
      }
    }
  }
  if ((length == 1) && (maxgrid == 1)) {
    for (c0=1;c0<=(2*niter-2);c0++) {
      if (((c0+1))%2 == 0) {
        s+=path[maxgrid-1][1];
      }
      if (c0%2 == 0) {
        diff[0][0][0]=sum_tang[0][0];
        sum_diff[0][0][0]=diff[0][0][0];
        mean[0][0]=sum_diff[0][0][length-1];
        path[0][0]=mean[0][0];
      }
    }
  }
  if ((length <= 0) && (maxgrid >= 2)) {
    for (c0=1;c0<=(2*niter-1);c0++) {
      if (c0%2 == 0) {
        sum_diff[0][0][0]=diff[0][0][0];
        mean[0][0]=sum_diff[0][0][length-1];
        path[0][0]=mean[0][0];
      }
      if (((c0+1))%2 == 0) {
        sum_diff[0][1][0]=diff[0][1][0];
        mean[0][1]=sum_diff[0][1][length-1];
        path[0][1]=mean[0][1];
        sum_diff[1][1][0]=diff[1][1][0];
        mean[1][1]=sum_diff[1][1][length-1];
        path[1][1]=path[1 -1][1 -1]+mean[1][1];
        s+=path[maxgrid-1][1];
      }
 lb1=ceild((c0+2),2);
 ub1=min(floord((c0+maxgrid-1),2),c0);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4,c5,c6)
 for (c1=lb1; c1<=ub1; c1++) {
        sum_diff[0][(-c0+2*c1)][0]=diff[0][(-c0+2*c1)][0];
        mean[0][(-c0+2*c1)]=sum_diff[0][(-c0+2*c1)][length-1];
        path[0][(-c0+2*c1)]=mean[0][(-c0+2*c1)];
        for (c2=(c0-c1+1);c2<=c1;c2++) {
          sum_diff[(-c0+c1+c2)][(-c0+2*c1)][0]=diff[(-c0+c1+c2)][(-c0+2*c1)][0];
          mean[(-c0+c1+c2)][(-c0+2*c1)]=sum_diff[(-c0+c1+c2)][(-c0+2*c1)][length-1];
          path[(-c0+c1+c2)][(-c0+2*c1)]=path[(-c0+c1+c2)-1][(-c0+2*c1)-1]+mean[(-c0+c1+c2)][(-c0+2*c1)];
        }
      }
    }
  }
  if (length <= 0) {
    for (c0=2*niter;c0<=(2*niter+maxgrid-3);c0++) {
 lb1=(c0-niter+1);
 ub1=min(floord((c0+maxgrid-1),2),c0);
#pragma omp parallel for shared(c0,lb1,ub1) private(c1,c2,c3,c4,c5,c6)
 for (c1=lb1; c1<=ub1; c1++) {
        sum_diff[0][(-c0+2*c1)][0]=diff[0][(-c0+2*c1)][0];
        mean[0][(-c0+2*c1)]=sum_diff[0][(-c0+2*c1)][length-1];
        path[0][(-c0+2*c1)]=mean[0][(-c0+2*c1)];
        for (c2=(c0-c1+1);c2<=c1;c2++) {
          sum_diff[(-c0+c1+c2)][(-c0+2*c1)][0]=diff[(-c0+c1+c2)][(-c0+2*c1)][0];
          mean[(-c0+c1+c2)][(-c0+2*c1)]=sum_diff[(-c0+c1+c2)][(-c0+2*c1)][length-1];
          path[(-c0+c1+c2)][(-c0+2*c1)]=path[(-c0+c1+c2)-1][(-c0+2*c1)-1]+mean[(-c0+c1+c2)][(-c0+2*c1)];
        }
      }
    }
  }
  if ((length <= 0) && (maxgrid == 1)) {
    for (c0=1;c0<=(2*niter-2);c0++) {
      if (((c0+1))%2 == 0) {
        s+=path[maxgrid-1][1];
      }
      if (c0%2 == 0) {
        sum_diff[0][0][0]=diff[0][0][0];
        mean[0][0]=sum_diff[0][0][length-1];
        path[0][0]=mean[0][0];
      }
    }
  }
  for (c0=max(1,(-2*floord((-2*niter-maxgrid+3),2)+1));c0<=(2*niter-1);c0+=2) {
    s+=path[maxgrid-1][1];
  }
}
#pragma endscop

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  print_array(argc, argv);

  return 0;
}
