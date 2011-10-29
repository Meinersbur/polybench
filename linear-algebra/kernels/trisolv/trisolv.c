/**
 * trisolv.c: This file is part of the PolyBench 3.0 test suite.
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
/* Default data type is double, default size is 4000. */
#include "trisolv.h"


/* Array initialization. */
static
void init_array(int n,
		DATA_TYPE POLYBENCH_2D(A,N,N),
		DATA_TYPE POLYBENCH_1D(x,N),
		DATA_TYPE POLYBENCH_1D(c,N))
{
  int i, j;

  for (i = 0; i < n; i++)
    {
      c[i] = x[i] = ((DATA_TYPE) i) / n;
      for (j = 0; j < n; j++)
	A[i][j] = ((DATA_TYPE) i*j) / n;
    }
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int n,
		 DATA_TYPE POLYBENCH_1D(x,N))

{
  int i;

  for (i = 0; i < n; i++) {
    fprintf (stderr, DATA_PRINTF_MODIFIER, x[i]);
    if (i % 20 == 0) fprintf (stderr, "\n");
  }
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_trisolv(int n,
		    DATA_TYPE POLYBENCH_2D(A,N,N),
		    DATA_TYPE POLYBENCH_1D(x,N),
		    DATA_TYPE POLYBENCH_1D(c,N))
{
  int i, j;

#pragma scop
  for (i = 0; i < n; i++)
    {
      x[i] = c[i];
      for (j = 0; j <= i - 1; j++)
        x[i] = x[i] - A[i][j] * x[j];
      x[i] = x[i] / A[i][i];
    }
#pragma endscop

}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int n = N;

  /* Variable declaration/allocation. */
#ifdef POLYBENCH_HEAP_ARRAYS
  /* Heap arrays use variable 'n' for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(A, n, n);
  DATA_TYPE POLYBENCH_1D_ARRAY_DECL(x, n);
  DATA_TYPE POLYBENCH_1D_ARRAY_DECL(c, n);
  A = POLYBENCH_ALLOC_2D_ARRAY(n, n, DATA_TYPE);
  x = POLYBENCH_ALLOC_1D_ARRAY(n, DATA_TYPE);
  c = POLYBENCH_ALLOC_1D_ARRAY(n, DATA_TYPE);
#else
  /* Stack arrays use the numerical value 'N' for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(A, N, N);
  DATA_TYPE POLYBENCH_1D_ARRAY_DECL(x, N);
  DATA_TYPE POLYBENCH_1D_ARRAY_DECL(c, N);
#endif


  /* Initialize array(s). */
  init_array (n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(x), POLYBENCH_ARRAY(c));

  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_trisolv (n, POLYBENCH_ARRAY(A), POLYBENCH_ARRAY(x), POLYBENCH_ARRAY(c));

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(n, POLYBENCH_ARRAY(x)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(x);
  POLYBENCH_FREE_ARRAY(c);

  return 0;
}
