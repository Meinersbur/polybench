#ifndef _GEMM_H
# define _GEMM_H

/* Default to LARGE_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define LARGE_DATASET
# endif

# if !defined(NI) && !defined(NJ) && !defined(NK)
/* Define sample dataset sizes. */
#  ifdef MINI_DATASET
#   define NI 20
#   define NJ 25
#   define NK 30
#  endif 

#  ifdef SMALL_DATASET
#   define NI 60
#   define NJ 70
#   define NK 80
#  endif 

#  ifdef MEDIUM_DATASET
#   define NI 200
#   define NJ 220
#   define NK 240
#  endif 

#  ifdef LARGE_DATASET
#   define NI 1000
#   define NJ 1100
#   define NK 1200
#  endif 

#  ifdef EXTRALARGE_DATASET
#   define NI 2000
#   define NJ 2300
#   define NK 2600
#  endif 


#endif /* !(NI NJ NK) */

# define _PB_NI POLYBENCH_LOOP_BOUND(NI,ni)
# define _PB_NJ POLYBENCH_LOOP_BOUND(NJ,nj)
# define _PB_NK POLYBENCH_LOOP_BOUND(NK,nk)


# ifndef DATA_TYPE
#  define DATA_TYPE double
#  define DATA_PRINTF_MODIFIER "%0.2lf "
#  define SCALAR_VAL(x) x
#  define SQRT_FUN(x) sqrt(x)
#  define EXP_FUN(x) exp(x)
#  define POW_FUN(x,y) pow(x,y)
# endif



#endif /* !_GEMM_H */

