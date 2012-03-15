!******************************************************************************
!
!  ludcmp.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 1024. 
#include "ludcmp.h"

      program ludcmp
      implicit none

      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,N + 1, N + 1)
      POLYBENCH_1D_ARRAY_DECL(x,DATA_TYPE,N + 1)
      POLYBENCH_1D_ARRAY_DECL(y,DATA_TYPE,N + 1)
      POLYBENCH_1D_ARRAY_DECL(b,DATA_TYPE,N + 1)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, N + 1, N + 1)
      POLYBENCH_ALLOC_1D_ARRAY(x, N + 1)
      POLYBENCH_ALLOC_1D_ARRAY(y, N + 1)
      POLYBENCH_ALLOC_1D_ARRAY(b, N + 1)

!     Initialization
      call init_array(N, a, b, x, y)

!     Kernel Execution
      polybench_start_instruments

      call kernel_ludcmp(N, a, b, x, y)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, x));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(x)
      POLYBENCH_DEALLOC_ARRAY(y)
      POLYBENCH_DEALLOC_ARRAY(b)

      contains

        subroutine init_array(n, a, b, x, y)
        implicit none

        DATA_TYPE, dimension(n + 1, n + 1) :: a
        DATA_TYPE, dimension(n + 1) :: x
        DATA_TYPE, dimension(n + 1) :: b
        DATA_TYPE, dimension(n + 1) :: y
        integer :: n
        integer :: i, j

        do i = 1, n  + 1
          x(i) = DBLE(i)
          y(i) = (i/n/2.0D0) + 1.0D0
          b(i) = (i/n/2.0D0) + 42.0D0
          do j = 1, n + 1
            a(j, i) = (DBLE(i) * DBLE(j)) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, x)
        implicit none

        DATA_TYPE, dimension(n + 1) :: x
        integer :: n
        integer :: i
        do i = 1, n + 1
          write(0, DATA_PRINTF_MODIFIER) x(i)
          if (mod(i - 1, 20) == 0) then
            write(0, *)
          end if
        end do
        end subroutine


        subroutine kernel_ludcmp(n, a, b, x, y)
        implicit none

        DATA_TYPE, dimension(n + 1, n + 1) :: a
        DATA_TYPE, dimension(n + 1) :: x
        DATA_TYPE, dimension(n + 1) :: b
        DATA_TYPE, dimension(n + 1) :: y
        DATA_TYPE :: w
        integer :: n
        integer :: i, j, k

!$pragma scop
        b(1) = 1.0D0
        do i = 1, _PB_N 
          do j = i + 1, _PB_N + 1
            w = a(i, j)
            do k = 1, i - 1
              w = w - (a(k, j) * a(i, k))
            end do
            a(i, j) = w / a(i, i)
          end do
          do j = i + 1, _PB_N + 1
            w = a(j, i + 1)
            do k = 1, i
              w = w - (a(k, i + 1) * a(j, k))
            end do
            a(j, i + 1) = w
          end do
        end do
        y(1) = b(1)
        do i = 2, _PB_N + 1
          w = b(i)
          do j = 1, i - 1
            w = w - (a(j, i) * y(j))
          end do
          y(i) = w
        end do
        x(_PB_N + 1) = y(_PB_N + 1) / a(_PB_N + 1, _PB_N + 1)
        do i = 1, _PB_N 
          w = y(_PB_N + 1 - i)
          do j = _PB_N + 2 - i, _PB_N + 1
            w = w - (a(j, _PB_N + 1 - i) * x(j))
          end do
          x(_PB_N + 1 - i) = w / a(_PB_N + 1 - i, _PB_N + 1 - i)
        end do
!$pragma endscop
        end subroutine

      end program
