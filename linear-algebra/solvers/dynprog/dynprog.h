/**
 * dynprog.h: This file is part of the PolyBench 1.0/Fortran test suite.
 *
 * Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://polybench.sourceforge.net
 */
#ifndef DYNPROG_H
# define DYNPROG_H

/* Default to STANDARD_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define STANDARD_DATASET
# endif

/* Do not define anything if the user manually defines the size. */
# if !defined(TSTEPS) && !defined(LENGTH)
/* Define the possible dataset sizes. */
#  ifdef MINI_DATASET
#   define TSTEPS 10
#   define LENGTH 32
#  endif

#  ifdef SMALL_DATASET
#   define TSTEPS 100
#   define LENGTH 50
#  endif

#  ifdef STANDARD_DATASET /* Default if unspecified. */
#   define TSTEPS 10000
#   define LENGTH 50
#  endif

#  ifdef LARGE_DATASET
#   define TSTEPS 1000
#   define LENGTH 500
#  endif

#  ifdef EXTRALARGE_DATASET
#   define TSTEPS 10000
#   define LENGTH 500
#  endif
# endif /* !N */

# define _PB_TSTEPS POLYBENCH_LOOP_BOUND(TSTEPS,tsteps)
# define _PB_LENGTH POLYBENCH_LOOP_BOUND(LENGTH,length)

# ifndef DATA_TYPE
#  define DATA_TYPE integer
#  define DATA_PRINTF_MODIFIER "(i0,1x)", advance='no'
# endif


#endif /* !DYNPROG */
