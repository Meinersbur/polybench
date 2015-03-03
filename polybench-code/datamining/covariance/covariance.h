/* covariance.h: this file is part of PolyBench/C */

#ifndef _COVARIANCE_H
# define _COVARIANCE_H

/* Default to LARGE_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define LARGE_DATASET
# endif

# if !defined(M) && !defined(N)
/* Define sample dataset sizes. */
#  ifdef MINI_DATASET
#   define M 28
#   define N 32
#  endif 

#  ifdef SMALL_DATASET
#   define M 80
#   define N 100
#  endif 

#  ifdef MEDIUM_DATASET
#   define M 240
#   define N 260
#  endif 

#  ifdef LARGE_DATASET
#   define M 1200
#   define N 1400
#  endif 

#  ifdef EXTRALARGE_DATASET
#   define M 2600
#   define N 3000
#  endif 


#endif /* !(M N) */

# define _PB_M POLYBENCH_LOOP_BOUND(M,m)
# define _PB_N POLYBENCH_LOOP_BOUND(N,n)


# ifndef DATA_TYPE
#  define DATA_TYPE double
#  define DATA_PRINTF_MODIFIER "%0.2lf "
#  define SCALAR_VAL(x) x
#  define SQRT_FUN(x) sqrt(x)
#  define EXP_FUN(x) exp(x)
#  define POW_FUN(x,y) pow(x,y)
# endif



#endif /* !_COVARIANCE_H */

