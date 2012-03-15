!******************************************************************************
!
!  gemm.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "gemm.h"

      program gemm
      implicit none

      DATA_TYPE :: alpha
      DATA_TYPE :: beta
      POLYBENCH_2D_ARRAY_DECL(c,DATA_TYPE,NJ, NI)
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,NK, NI)
      POLYBENCH_2D_ARRAY_DECL(b,DATA_TYPE,NJ, NK)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(c, NJ, NI)
      POLYBENCH_ALLOC_2D_ARRAY(a, NK, NI)
      POLYBENCH_ALLOC_2D_ARRAY(b, NJ, NK)

!     Initialization
      call init_array(NI, NJ, NK,  &
                           alpha, beta, c, a, b)

!     Kernel Execution
      polybench_start_instruments

      call kernel_gemm(NI, NJ, NK, alpha, beta,  &
                              c, a, b)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(NI, NJ, c));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(c)
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)

      contains

        subroutine init_array(ni, nj, nk, alpha, beta, c, a, b)
        implicit none

        DATA_TYPE, dimension(nk, ni) :: a
        DATA_TYPE, dimension(nj, nk) :: b
        DATA_TYPE, dimension(nj, ni) :: c
        DATA_TYPE :: alpha, beta
        integer :: ni, nj, nk
        integer :: i, j

        alpha = 32412
        beta = 2123

        do i = 1, ni
          do j = 1, nj
            c(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(ni)
          end do
        end do
        do i = 1, ni
          do j = 1, nk
            a(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(ni)
          end do
        end do
        do i = 1, nk
          do j = 1, nj
            b(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(ni)
          end do
        end do
        end subroutine


        subroutine print_array(ni, nj, c)
        implicit none

        DATA_TYPE, dimension(nj, ni) :: c
        integer :: ni, nj
        integer :: i, j
        do i = 1, ni
          do j = 1, nj
            write(0, DATA_PRINTF_MODIFIER) c(j, i)
            if (mod(((i - 1) * ni) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_gemm(ni, nj, nk, alpha, beta, c, a, b)
        implicit none

        DATA_TYPE, dimension(nk, ni) :: a
        DATA_TYPE, dimension(nj, nk) :: b
        DATA_TYPE, dimension(nj, ni) :: c
        DATA_TYPE :: alpha, beta
        integer :: ni, nj, nk
        integer :: i, j, k

!$pragma scop
        do i = 1, _PB_NI
          do j = 1, _PB_NJ
            c(j, i) = c(j, i) * beta
            do k  = 1, _PB_NK
              c(j, i) = c(j, i) + (alpha * a(k, i) * b(j, k))
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program
