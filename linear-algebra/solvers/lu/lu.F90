!******************************************************************************
!
!  lu.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 1024. 
#include "lu.h"

      program lu
      implicit none

      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,N, N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, N, N)

!     Initialization
      call init_array(N, a)

!     Kernel Execution
      polybench_start_instruments

      call kernel_lu(N, a)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, a));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)

      contains

        subroutine init_array(n, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        integer :: n
        integer :: i, j

        do i = 1, n
          do j = 1, n
            a(j, i) = (DBLE(i) * DBLE(j)) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        integer :: n
        integer :: i, j
        do i = 1, n
          do j = 1, n
            write(0, DATA_PRINTF_MODIFIER) a(j, i)
            if (mod(((i - 1) * n) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_lu(n, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        integer :: n
        integer :: i, j, k

!$pragma scop
        do k = 1, _PB_N
          do j = k + 1, _PB_N
            a(j, k) = a(j, k) / a(k, k)
          end do
          do i = k + 1, _PB_N
            do j = k + 1, _PB_N
              a(j, i) = a(j, i) - (a(k, i) * a(j, k))
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program
