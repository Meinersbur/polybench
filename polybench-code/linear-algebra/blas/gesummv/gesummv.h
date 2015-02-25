#ifndef _GESUMMV_H
# define _GESUMMV_H

/* Default to LARGE_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define LARGE_DATASET
# endif

# if !defined(N)
/* Define sample dataset sizes. */
#  ifdef MINI_DATASET
#   define N 30
#  endif 

#  ifdef SMALL_DATASET
#   define N 90
#  endif 

#  ifdef MEDIUM_DATASET
#   define N 250
#  endif 

#  ifdef LARGE_DATASET
#   define N 1300
#  endif 

#  ifdef EXTRALARGE_DATASET
#   define N 2800
#  endif 


#endif /* !(N) */

# define _PB_N POLYBENCH_LOOP_BOUND(N,n)


# ifndef DATA_TYPE
#  define DATA_TYPE double
#  define DATA_PRINTF_MODIFIER "%0.2lf "
#  define SCALAR_VAL(x) x
#  define SQRT_FUN(x) sqrt(x)
#  define EXP_FUN(x) exp(x)
#  define POW_FUN(x,y) pow(x,y)
# endif



#endif /* !_GESUMMV_H */

