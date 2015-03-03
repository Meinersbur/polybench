/* nussinov.h: this file is part of PolyBench/C */

#ifndef _NUSSINOV_H
# define _NUSSINOV_H

/* Default to LARGE_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define LARGE_DATASET
# endif

# if !defined(N)
/* Define sample dataset sizes. */
#  ifdef MINI_DATASET
#   define N 60
#  endif 

#  ifdef SMALL_DATASET
#   define N 180
#  endif 

#  ifdef MEDIUM_DATASET
#   define N 500
#  endif 

#  ifdef LARGE_DATASET
#   define N 2500
#  endif 

#  ifdef EXTRALARGE_DATASET
#   define N 5500
#  endif 


#endif /* !(N) */

# define _PB_N POLYBENCH_LOOP_BOUND(N,n)


# ifndef DATA_TYPE
#  define DATA_TYPE int
#  define DATA_PRINTF_MODIFIER "%d "
#  define SCALAR_VAL(x) x
#  define SQRT_FUN(x) sqrt(x)
#  define EXP_FUN(x) exp(x)
#  define POW_FUN(x,y) pow(x,y)
# endif



#endif /* !_NUSSINOV_H */

