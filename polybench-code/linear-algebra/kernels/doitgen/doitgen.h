/* doitgen.h: this file is part of PolyBench/C */

#ifndef _DOITGEN_H
# define _DOITGEN_H

/* Default to LARGE_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(MEDIUM_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define LARGE_DATASET
# endif

# if !defined(NQ) && !defined(NR) && !defined(NP)
/* Define sample dataset sizes. */
#  ifdef MINI_DATASET
#   define NQ 8
#   define NR 10
#   define NP 12
#  endif 

#  ifdef SMALL_DATASET
#   define NQ 20
#   define NR 25
#   define NP 30
#  endif 

#  ifdef MEDIUM_DATASET
#   define NQ 40
#   define NR 50
#   define NP 60
#  endif 

#  ifdef LARGE_DATASET
#   define NQ 140
#   define NR 150
#   define NP 160
#  endif 

#  ifdef EXTRALARGE_DATASET
#   define NQ 220
#   define NR 250
#   define NP 270
#  endif 


#endif /* !(NQ NR NP) */

# define _PB_NQ POLYBENCH_LOOP_BOUND(NQ,nq)
# define _PB_NR POLYBENCH_LOOP_BOUND(NR,nr)
# define _PB_NP POLYBENCH_LOOP_BOUND(NP,np)


# ifndef DATA_TYPE
#  define DATA_TYPE double
#  define DATA_PRINTF_MODIFIER "%0.2lf "
#  define SCALAR_VAL(x) x
#  define SQRT_FUN(x) sqrt(x)
#  define EXP_FUN(x) exp(x)
#  define POW_FUN(x,y) pow(x,y)
# endif



#endif /* !_DOITGEN_H */

