/**
 * 3mm.c: This file is part of the PolyBench 3.0 test suite.
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
#include "3mm.h"


/* Array initialization. */
static
void init_array(int ni, int nj, int nk, int nl, int nm,
		DATA_TYPE POLYBENCH_2D(A,NI,NK),
		DATA_TYPE POLYBENCH_2D(B,NK,NJ),
		DATA_TYPE POLYBENCH_2D(C,NJ,NM),
		DATA_TYPE POLYBENCH_2D(D,NM,NL))
{
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nk; j++)
      A[i][j] = ((DATA_TYPE) i*j) / ni;
  for (i = 0; i < nk; i++)
    for (j = 0; j < nj; j++)
      B[i][j] = ((DATA_TYPE) i*(j+1)) / nj;
  for (i = 0; i < nj; i++)
    for (j = 0; j < nm; j++)
      C[i][j] = ((DATA_TYPE) i*(j+3)) / nl;
  for (i = 0; i < nm; i++)
    for (j = 0; j < nl; j++)
      D[i][j] = ((DATA_TYPE) i*(j+2)) / nk;
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int ni, int nl,
		 DATA_TYPE POLYBENCH_2D(G,NI,NL))
{
  int i, j;

  for (i = 0; i < ni; i++)
    for (j = 0; j < nl; j++) {
	fprintf (stderr, DATA_PRINTF_MODIFIER, G[i][j]);
	if (i % 20 == 0) fprintf (stderr, "\n");
    }
  fprintf (stderr, "\n");
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_3mm(int ni, int nj, int nk, int nl, int nm,
		DATA_TYPE POLYBENCH_2D(E,NI,NJ),
		DATA_TYPE POLYBENCH_2D(A,NI,NK),
		DATA_TYPE POLYBENCH_2D(B,NK,NJ),
		DATA_TYPE POLYBENCH_2D(F,NJ,NL),
		DATA_TYPE POLYBENCH_2D(C,NJ,NM),
		DATA_TYPE POLYBENCH_2D(D,NM,NL),
		DATA_TYPE POLYBENCH_2D(G,NI,NL))
{
  int i, j, k;

#pragma scop
  /* E := A*B */
  for (i = 0; i < ni; i++)
    for (j = 0; j < nj; j++)
      {
	E[i][j] = 0;
	for (k = 0; k < nk; ++k)
	  E[i][j] += A[i][k] * B[k][j];
      }
  /* F := C*D */
  for (i = 0; i < nj; i++)
    for (j = 0; j < nl; j++)
      {
	F[i][j] = 0;
	for (k = 0; k < nm; ++k)
	  F[i][j] += C[i][k] * D[k][j];
      }
  /* G := E*F */
  for (i = 0; i < ni; i++)
    for (j = 0; j < nl; j++)
      {
	G[i][j] = 0;
	for (k = 0; k < nj; ++k)
	  G[i][j] += E[i][k] * F[k][j];
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
  int nm = NM;

  /* Variable declaration/allocation. */
#ifdef POLYBENCH_HEAP_ARRAYS
  /* Heap arrays use variable 'n' for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(E, ni, nj);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(A, ni, nk);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(B, nk, nj);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(F, nj, nl);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(C, nj, nm);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(D, nm, nl);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(G, ni, nl);
  E = POLYBENCH_ALLOC_2D_ARRAY(ni, nj, DATA_TYPE);
  A = POLYBENCH_ALLOC_2D_ARRAY(ni, nk, DATA_TYPE);
  B = POLYBENCH_ALLOC_2D_ARRAY(nk, nj, DATA_TYPE);
  F = POLYBENCH_ALLOC_2D_ARRAY(nj, nl, DATA_TYPE);
  C = POLYBENCH_ALLOC_2D_ARRAY(nj, nm, DATA_TYPE);
  D = POLYBENCH_ALLOC_2D_ARRAY(nm, nl, DATA_TYPE);
  G = POLYBENCH_ALLOC_2D_ARRAY(ni, nl, DATA_TYPE);
#else
  /* Stack arrays use the numerical value 'N' for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(E, NI, NJ);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(A, NI, NK);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(B, NK, NJ);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(F, NJ, NL);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(C, NJ, NM);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(D, NM, NL);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(G, NI, NL);
#endif

  /* Initialize array(s). */
  init_array (ni, nj, nk, nl, nm,
	      POLYBENCH_ARRAY(A),
	      POLYBENCH_ARRAY(B),
	      POLYBENCH_ARRAY(C),
	      POLYBENCH_ARRAY(D));

  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_3mm (ni, nj, nk, nl, nm,
	      POLYBENCH_ARRAY(E),
	      POLYBENCH_ARRAY(A),
	      POLYBENCH_ARRAY(B),
	      POLYBENCH_ARRAY(F),
	      POLYBENCH_ARRAY(C),
	      POLYBENCH_ARRAY(D),
	      POLYBENCH_ARRAY(G));

  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(ni, nl,  POLYBENCH_ARRAY(G)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(E);
  POLYBENCH_FREE_ARRAY(A);
  POLYBENCH_FREE_ARRAY(B);
  POLYBENCH_FREE_ARRAY(F);
  POLYBENCH_FREE_ARRAY(C);
  POLYBENCH_FREE_ARRAY(D);
  POLYBENCH_FREE_ARRAY(G);

  return 0;
}
