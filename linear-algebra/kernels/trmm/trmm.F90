!******************************************************************************
!
!  trmm.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "trmm.h"

      program trmm
      implicit none

      DATA_TYPE :: alpha
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,NI, NI)
      POLYBENCH_2D_ARRAY_DECL(b,DATA_TYPE,NI, NI)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, NI, NI)
      POLYBENCH_ALLOC_2D_ARRAY(b, NI, NI)

!     Initialization
      call init_array(NI, alpha, a, b)

!     Kernel Execution
      polybench_start_instruments

      call kernel_trmm(NI, alpha, a, b)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(NI, b));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)

      contains

        subroutine init_array(n, alpha, a, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: b
        DATA_TYPE :: alpha
        integer :: n
        integer :: i, j

        alpha = 32412D0
        do i = 1, n
          do j = 1, n
            a(j, i) = (DBLE(i - 1) * DBLE(j - 1)) / DBLE(n)
            b(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: b
        integer :: n
        integer :: i, j
        do i = 1, n
          do j = 1, n
            write(0, DATA_PRINTF_MODIFIER) b(j, i)
            if (mod(((i - 1) * n) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_trmm(ni, alpha, a, b)
        implicit none

        DATA_TYPE, dimension(ni, ni) :: a
        DATA_TYPE, dimension(ni, ni) :: b
        DATA_TYPE :: alpha
        integer :: ni
        integer :: i, j, k

!$pragma scop
        do i = 2, _PB_NI 
          do j = 1, _PB_NI 
            do k = 1, i - 1
              b(j, i) = b(j, i) + (alpha * a(k, i) * b(k, j))
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program

