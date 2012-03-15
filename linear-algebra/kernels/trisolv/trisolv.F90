!******************************************************************************
!
!  trisolv.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "trisolv.h"

      program trisolv
      implicit none

      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,N, N)
      POLYBENCH_1D_ARRAY_DECL(x,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(c,DATA_TYPE,N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, N, N)
      POLYBENCH_ALLOC_1D_ARRAY(x, N)
      POLYBENCH_ALLOC_1D_ARRAY(c, N)

!     Initialization
      call init_array(N, a, x, c)

!     Kernel Execution
      polybench_start_instruments

      call kernel_trisolv(N,   &
                              a, x, c)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, x));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(x)
      POLYBENCH_DEALLOC_ARRAY(c)

      contains

        subroutine init_array(n, a, x, c)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: c
        DATA_TYPE, dimension(n) :: x
        integer :: n
        integer :: i, j
        do i = 1, n
          c(i) = DBLE(i - 1) / DBLE(n)
          x(i) = DBLE(i - 1) / DBLE(n)
          do j = 1, n
            a(j, i) = (DBLE(i - 1) * DBLE(j - 1)) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, x)
        implicit none

        DATA_TYPE, dimension(n) :: x
        integer :: n
        integer :: i
        do i = 1, n
          write(0, DATA_PRINTF_MODIFIER) x(i)
          if (mod((i - 1), 20) == 0) then
            write(0, *)
          end if
        end do
        end subroutine


        subroutine kernel_trisolv(n , a, x, c)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: c
        DATA_TYPE, dimension(n) :: x
        integer :: n
        integer :: i, j

!$pragma scop
        do i = 1, _PB_N
          x(i) = c(i)
          do j = 1, i - 1
            x(i) = x(i) - (a(j, i) * x(j))
          end do
          x(i) = x(i) / a(i, i)
        end do
!$pragma endscop
        end subroutine

      end program
