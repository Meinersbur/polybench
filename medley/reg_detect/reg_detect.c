/**
 * reg_detect.c: This file is part of the PolyBench 3.0 test suite.
 *
 *
 * Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://polybench.sourceforge.net
 */
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>

/* Include polybench common header. */
#include <polybench.h>

/* Include benchmark-specific header. */
/* Default data type is int, default size is 50. */
#include "reg_detect.h"


/* Array initialization. */
static
void init_array(int maxgrid,
		DATA_TYPE POLYBENCH_2D(sum_tang,MAXGRID,MAXGRID),
		DATA_TYPE POLYBENCH_2D(mean,MAXGRID,MAXGRID),
		DATA_TYPE POLYBENCH_2D(path,MAXGRID,MAXGRID))
{
  int i, j;

  for (i = 0; i < maxgrid; i++)
    for (j = 0; j < maxgrid; j++) {
      sum_tang[i][j] = (DATA_TYPE)((i+1)*(j+1));
      mean[i][j] = ((DATA_TYPE) i-j) / maxgrid;
      path[i][j] = ((DATA_TYPE) i*(j-1)) / maxgrid;
    }
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(DATA_TYPE s)
{
  fprintf (stderr, DATA_PRINTF_MODIFIER, s);
  fprintf (stderr, "\n");
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_reg_detect(int niter, int maxgrid, int length,
		       DATA_TYPE POLYBENCH_2D(sum_tang,MAXGRID,MAXGRID),
		       DATA_TYPE POLYBENCH_2D(mean,MAXGRID,MAXGRID),
		       DATA_TYPE POLYBENCH_2D(path,MAXGRID,MAXGRID),
		       DATA_TYPE POLYBENCH_3D(diff,MAXGRID,MAXGRID,LENGTH),
		       DATA_TYPE POLYBENCH_3D(sum_diff,MAXGRID,MAXGRID,LENGTH),
		       DATA_TYPE *s)
{
  int t, i, j, cnt;

  DATA_TYPE s_l = 0;

#pragma scop
  for (t = 0; t < niter; t++)
    {
      for (j = 0; j <= maxgrid - 1; j++)
	for (i = j; i <= maxgrid - 1; i++)
	  for (cnt = 0; cnt <= length - 1; cnt++)
	    diff[j][i][cnt] = sum_tang[j][i];

      for (j = 0; j <= maxgrid - 1; j++)
        {
	  for (i = j; i <= maxgrid - 1; i++)
            {
	      sum_diff[j][i][0] = diff[j][i][0];
	      for (cnt = 1; cnt <= length - 1; cnt++)
		sum_diff[j][i][cnt] = sum_diff[j][i][cnt - 1] + diff[j][i][cnt];
	      mean[j][i] = sum_diff[j][i][length - 1];
            }
        }

      for (i = 0; i <= maxgrid - 1; i++)
	path[0][i] = mean[0][i];

      for (j = 1; j <= maxgrid - 1; j++)
	for (i = j; i <= maxgrid - 1; i++)
	  path[j][i] = path[j - 1][i - 1] + mean[j][i];
      s_l += path[maxgrid - 1][1];
    }
#pragma endscop

  *s = s_l;
}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int niter = NITER;
  int maxgrid = MAXGRID;
  int length = LENGTH;

  /* Variable declaration/allocation. */
  DATA_TYPE s;
#ifdef POLYBENCH_HEAP_ARRAYS
  /* Heap arrays use variable 'n' for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(sum_tang, maxgrid, maxgrid);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(mean, maxgrid, maxgrid);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(path, maxgrid, maxgrid);
  DATA_TYPE POLYBENCH_3D_ARRAY_DECL(diff, maxgrid, maxgrid, length);
  DATA_TYPE POLYBENCH_3D_ARRAY_DECL(sum_diff, maxgrid, maxgrid, length);
  sum_tang = POLYBENCH_ALLOC_2D_ARRAY(maxgrid, maxgrid, DATA_TYPE);
  mean = POLYBENCH_ALLOC_2D_ARRAY(maxgrid, maxgrid, DATA_TYPE);
  path = POLYBENCH_ALLOC_2D_ARRAY(maxgrid, maxgrid, DATA_TYPE);
  diff = POLYBENCH_ALLOC_3D_ARRAY(maxgrid, maxgrid, length, DATA_TYPE);
  sum_diff = POLYBENCH_ALLOC_3D_ARRAY(maxgrid, maxgrid, length, DATA_TYPE);
#else
  /* Stack arrays use the numerical value 'N' for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(sum_tang, MAXGRID, MAXGRID);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(mean, MAXGRID, MAXGRID);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(path, MAXGRID, MAXGRID);
  DATA_TYPE POLYBENCH_3D_ARRAY_DECL(diff, MAXGRID, MAXGRID, LENGTH);
  DATA_TYPE POLYBENCH_3D_ARRAY_DECL(sum_diff, MAXGRID, MAXGRID, LENGTH);
#endif

  /* Initialize array(s). */
  init_array (maxgrid,
	      POLYBENCH_ARRAY(sum_tang),
	      POLYBENCH_ARRAY(mean),
	      POLYBENCH_ARRAY(path));

  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_reg_detect (niter, maxgrid, length,
		     POLYBENCH_ARRAY(sum_tang),
		     POLYBENCH_ARRAY(mean),
		     POLYBENCH_ARRAY(path),
		     POLYBENCH_ARRAY(diff),
		     POLYBENCH_ARRAY(sum_diff),
		     &s);

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(s));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(sum_tang);
  POLYBENCH_FREE_ARRAY(mean);
  POLYBENCH_FREE_ARRAY(path);
  POLYBENCH_FREE_ARRAY(diff);
  POLYBENCH_FREE_ARRAY(sum_diff);

  return 0;
}
