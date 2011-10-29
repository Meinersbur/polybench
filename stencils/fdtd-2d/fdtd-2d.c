/**
 * fdtd-2d.c: This file is part of the PolyBench 3.0 test suite.
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
/* Default data type is double, default size is 50x1000x1000. */
#include "fdtd-2d.h"


/* Array initialization. */
static
void init_array (int nx,
		 int ny,
		 DATA_TYPE POLYBENCH_2D(ex,NX,NY),
		 DATA_TYPE POLYBENCH_2D(ey,NX,NY),
		 DATA_TYPE POLYBENCH_2D(hz,NX,NY),
		 DATA_TYPE POLYBENCH_1D(_fict_,NY))
{
  int i, j;

  for (i = 0; i < ny; i++)
    _fict_[i] = (DATA_TYPE) i;
  for (i = 0; i < nx; i++)
    for (j = 0; j < ny; j++)
      {
	ex[i][j] = ((DATA_TYPE) i*(j+1)) / nx;
	ey[i][j] = ((DATA_TYPE) i*(j+2)) / ny;
	hz[i][j] = ((DATA_TYPE) i*(j+3)) / nx;
      }
}


/* DCE code. Must scan the entire live-out data.
   Can be used also to check the correctness of the output. */
static
void print_array(int nx,
		 int ny,
		 DATA_TYPE POLYBENCH_2D(ex,NX,NY),
		 DATA_TYPE POLYBENCH_2D(ey,NX,NY),
		 DATA_TYPE POLYBENCH_2D(hz,NX,NY))
{
  int i, j;

  for (i = 0; i < NX; i++)
    for (j = 0; j < NY; j++) {
      fprintf(stderr, DATA_PRINTF_MODIFIER, ex[i][j]);
      fprintf(stderr, DATA_PRINTF_MODIFIER, ey[i][j]);
      fprintf(stderr, DATA_PRINTF_MODIFIER, hz[i][j]);
      if ((i * NX + j) % 20 == 0) fprintf(stderr, "\n");
    }
  fprintf(stderr, "\n");
}


/* Main computational kernel. The whole function will be timed,
   including the call and return. */
static
void kernel_fdtd_2d(int tmax,
		    int nx,
		    int ny,
		    DATA_TYPE POLYBENCH_2D(ex,NX,NY),
		    DATA_TYPE POLYBENCH_2D(ey,NX,NY),
		    DATA_TYPE POLYBENCH_2D(hz,NX,NY),
		    DATA_TYPE POLYBENCH_1D(_fict_,NY))
{
  int t, i, j;

#pragma scop

  for(t = 0; t < tmax; t++)
    {
      for (j = 0; j < ny; j++)
	ey[0][j] = _fict_[t];
      for (i = 1; i < nx; i++)
	for (j = 0; j < ny; j++)
	  ey[i][j] = ey[i][j] - 0.5*(hz[i][j]-hz[i-1][j]);
      for (i = 0; i < nx; i++)
	for (j = 1; j < ny; j++)
	  ex[i][j] = ex[i][j] - 0.5*(hz[i][j]-hz[i][j-1]);
      for (i = 0; i < nx - 1; i++)
	for (j = 0; j < ny - 1; j++)
	  hz[i][j] = hz[i][j] - 0.7*  (ex[i][j+1] - ex[i][j] +
				       ey[i+1][j] - ey[i][j]);
    }

#pragma endscop
}


int main(int argc, char** argv)
{
  /* Retrieve problem size. */
  int tmax = TMAX;
  int nx = NX;
  int ny = NY;

  /* Variable declaration/allocation. */
#ifdef POLYBENCH_HEAP_ARRAYS
  /* Heap arrays use the variable(s) for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(ex,nx,ny);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(ey,nx,ny);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(hz,nx,ny);
  DATA_TYPE POLYBENCH_1D_ARRAY_DECL(_fict_,ny);
  ex = POLYBENCH_ALLOC_2D_ARRAY(nx, ny, DATA_TYPE);
  ey = POLYBENCH_ALLOC_2D_ARRAY(nx, ny, DATA_TYPE);
  hz = POLYBENCH_ALLOC_2D_ARRAY(nx, ny, DATA_TYPE);
  _fict_ = POLYBENCH_ALLOC_1D_ARRAY(ny, DATA_TYPE);
#else
  /* Stack arrays use the numerical value(s) for the size. */
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(ex,NX,NY);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(ey,NX,NY);
  DATA_TYPE POLYBENCH_2D_ARRAY_DECL(hz,NX,NY);
  DATA_TYPE POLYBENCH_1D_ARRAY_DECL(_fict_,NY);
#endif

  /* Initialize array(s). */
  init_array (nx, ny,
	      POLYBENCH_ARRAY(ex),
	      POLYBENCH_ARRAY(ey),
	      POLYBENCH_ARRAY(hz),
	      POLYBENCH_ARRAY(_fict_));

  /* Start timer. */
  polybench_start_instruments;

  /* Run kernel. */
  kernel_fdtd_2d (tmax, nx, ny,
		  POLYBENCH_ARRAY(ex),
		  POLYBENCH_ARRAY(ey),
		  POLYBENCH_ARRAY(hz),
		  POLYBENCH_ARRAY(_fict_));


  /* Stop and print timer. */
  polybench_stop_instruments;
  polybench_print_instruments;

  /* Prevent dead-code elimination. All live-out data must be printed
     by the function call in argument. */
  polybench_prevent_dce(print_array(nx, ny, POLYBENCH_ARRAY(ex), 
				    POLYBENCH_ARRAY(ey), 
				    POLYBENCH_ARRAY(hz)));

  /* Be clean. */
  POLYBENCH_FREE_ARRAY(ex);
  POLYBENCH_FREE_ARRAY(ey);
  POLYBENCH_FREE_ARRAY(hz);
  POLYBENCH_FREE_ARRAY(_fict_);

  return 0;
}
