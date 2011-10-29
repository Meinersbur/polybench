/**
 * 2mm.c: This file is part of the PolyBench 3.0 test suite.
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
#include "2mm.h"


/* Array initialization. */
static
void init_array(int ni, int nj, int nk, int nl,
		DATA_TYPE *alpha,
		DATA_TYPE *beta,
		DATA_TYPE POLYBENCH_2D(A,NI,NK),
		DATA_TYPE POLYBENCH_2D(B,NK,NJ),
		DATA_TYPE POLYBENCH_2D(C,NL,NJ),
		DATA_TYPE POLYBENCH_2D(D,NI,NL))
{
  int i, j;

  *alpha = 32412;
  *beta = 2123;
  for (i = 0; i < ni; i++)
    for (j = 0; j < nk; j++)
      A[i][j] = ((DATA_TYPE) i*j) / ni;
  for (i = 0; i < nk; i++)
    for (j = 0; j < nj; j++)
      B[i][j] = ((DATA_TYPE) i*(j+1)) / nj;
  for (i = 0; i < nl; i++)
    for (j = 0; j < nj; j++)
      C[i][j] = ((DATA_TYPE) i*(j+3)) / nl;
  for (i = 0; i < ni; i++)
    for (j = 0; j < nl; j++)
      D[i][j] = ((DATA_TYPE) i*(j+2)) / nk;
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int ni, int nl,
		 DATA_TYPE POLYBENCH_2D(D,NI,NL))
{
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nl; j++) {
	fprintf (stderr, DATA_PRINTF_MODIFIER, D[i][j]);
	if (i % 20 == 0) fprintf (stderr, "\n");
    }
  fprintf (stderr, "\n");
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_2mm(int ni, int nj, int nk, int nl,
		DATA_TYPE alpha,
		DATA_TYPE beta,
		DATA_TYPE POLYBENCH_2D(tmp,NI,NJ),
		DATA_TYPE POLYBENCH_2D(A,NI,NK),
		DATA_TYPE POLYBENCH_2D(B,NK,NJ),
		DATA_TYPE POLYBENCH_2D(C,NL,NJ),
		DATA_TYPE POLYBENCH_2D(D,NI,NL))
{
  int i, j, k;

#pragma scop
  /* D := alpha*A*B*C + beta*D */
  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++)
      {
	tmp[i][j] = 0;
	for (k = 0; k < nk; ++k)
	  tmp[i][j] += alpha * A[i][k] * B[k][j];
      }
  for (i = 0; i < ni; i++)
    for (j = 0; j < nl; j++)
      {
	D[i][j] *= beta;
	for (k = 0; k < nj; ++k)
	  D[i][j] += tmp[i][k] * C[k][j];
      }
#pragma endscop

}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int ni = NI;
  int nj = NJ;
  int nk = NK;
  int nl = NL;

  /* Variable declaration/allocation. */
  DATA_TYPE alpha;
  DATA_TYPE beta;
#ifdef POLYBENCH_HEAP_ARRAYS
  /* Heap arrays use variable 'n' for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(tmp, ni, nj);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(A, ni, nk);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(B, nk, nj);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(C, nl, nj);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(D, ni, nl);
  tmp = POLYBENCH_ALLOC_2D_ARRAY(ni, nj, DATA_TYPE);
  A = POLYBENCH_ALLOC_2D_ARRAY(ni, nk, DATA_TYPE);
  B = POLYBENCH_ALLOC_2D_ARRAY(nk, nj, DATA_TYPE);
  C = POLYBENCH_ALLOC_2D_ARRAY(nl, nj, DATA_TYPE);
  D = POLYBENCH_ALLOC_2D_ARRAY(ni, nl, DATA_TYPE);
#else
  /* Stack arrays use the numerical value 'N' for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(tmp,NI,NJ);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(A,NI,NK);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(B,NK,NJ);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(C,NL,NJ);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(D,NI,NL);
#endif

  /* Initialize array(s). */
  init_array (ni, nj, nk, nl, &alpha, &beta,
	      POLYBENCH_ARRAY(A),
	      POLYBENCH_ARRAY(B),
	      POLYBENCH_ARRAY(C),
	      POLYBENCH_ARRAY(D));

  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_2mm (ni, nj, nk, nl,
	      alpha, beta,
	      POLYBENCH_ARRAY(tmp),
	      POLYBENCH_ARRAY(A),
	      POLYBENCH_ARRAY(B),
	      POLYBENCH_ARRAY(C),
	      POLYBENCH_ARRAY(D));

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(ni, nl,  POLYBENCH_ARRAY(D)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(tmp);
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(D);

  return 0;
}
