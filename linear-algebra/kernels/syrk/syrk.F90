!******************************************************************************
!
!  syrk.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "syrk.h"

      program syrk
      implicit none

      DATA_TYPE :: alpha
      DATA_TYPE :: beta
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,NJ, NI)
      POLYBENCH_2D_ARRAY_DECL(c,DATA_TYPE,NI, NI)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, NJ, NI)
      POLYBENCH_ALLOC_2D_ARRAY(c, NI, NI)

!     Initialization
      call init_array(NI, NJ, alpha, beta, c, a)

!     Kernel Execution
      polybench_start_instruments

      call kernel_syrk(NI, NJ, alpha, beta,  &
                              c, a)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(NI, c));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(c)

      contains

        subroutine init_array(ni, nj, alpha, beta, c, a)
        implicit none

        DATA_TYPE, dimension(ni, ni) :: a
        DATA_TYPE, dimension(nj, ni) :: c
        DATA_TYPE :: alpha , beta
        integer :: nj, ni
        integer :: i, j

        alpha = 32412
        beta = 2123

        do i = 1, ni
          do j = 1, nj
            a(j, i) = (DBLE(i - 1) * DBLE(j - 1)) / DBLE(ni)
          end do
          do j = 1, ni
            c(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(ni)
          end do
        end do
        end subroutine


        subroutine print_array(ni, c)
        implicit none

        DATA_TYPE, dimension(ni, ni) :: c
        integer :: ni
        integer :: i, j
        do i = 1, ni
          do j = 1, ni
            write(0, DATA_PRINTF_MODIFIER) c(j, i)
            if (mod(((i - 1) * ni) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_syrk(ni, nj, alpha, beta, c, a)
        implicit none

        DATA_TYPE, dimension(ni, ni) :: a
        DATA_TYPE, dimension(nj, ni) :: c
        DATA_TYPE :: alpha , beta
        integer :: nj, ni
        integer :: i, j, k

!$pragma scop
        do i = 1, _PB_NI
          do j = 1, _PB_NI
            c(j, i) = c(j, i) * beta
          end do
        end do
        do i = 1, _PB_NI
          do j = 1, _PB_NI
            do k = 1, _PB_NJ
              c(j, i) = c(j, i) + (alpha * a(k, i) * a(k, j))
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program
