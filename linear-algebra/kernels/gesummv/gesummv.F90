!******************************************************************************
!
!  gesummv.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "gesummv.h"

      program gesummv
      implicit none

      DATA_TYPE :: alpha
      DATA_TYPE :: beta
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,N, N)
      POLYBENCH_2D_ARRAY_DECL(b,DATA_TYPE,N, N)
      POLYBENCH_1D_ARRAY_DECL(x,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(y,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(tmp,DATA_TYPE,N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, N, N)
      POLYBENCH_ALLOC_2D_ARRAY(b, N, N)
      POLYBENCH_ALLOC_1D_ARRAY(x, N)
      POLYBENCH_ALLOC_1D_ARRAY(y, N)
      POLYBENCH_ALLOC_1D_ARRAY(tmp, N)

!     Initialization
      call init_array(N, alpha, beta, a, b, x)

!     Kernel Execution
      polybench_start_instruments

      call kernel_gesummv(N, alpha, beta, &
                              a, b, tmp, x, y)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, y));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)
      POLYBENCH_DEALLOC_ARRAY(x)
      POLYBENCH_DEALLOC_ARRAY(y)
      POLYBENCH_DEALLOC_ARRAY(tmp)

      contains

        subroutine init_array(n, alpha, beta, a, b, x)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: b
        DATA_TYPE, dimension(n) :: x
        DATA_TYPE :: alpha, beta
        integer :: n
        integer :: i, j

        alpha = 43532.0D0
        beta = 12313.0D0

        do i = 1, n
          x(i) = DBLE(i - 1) / DBLE(n)
          do j = 1, n
            a(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(n)
            b(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, y)
        implicit none

        DATA_TYPE, dimension(n) :: y
        integer :: n
        integer :: i
        do i = 1, n
          write(0, DATA_PRINTF_MODIFIER) y(i)
          if (mod(i - 1, 20) == 0) then
            write(0, *)
          end if
        end do
        end subroutine


        subroutine kernel_gesummv(n, alpha, beta, &
                                a, b, tmp, x, y)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: b
        DATA_TYPE, dimension(n) :: x, y, tmp
        DATA_TYPE :: alpha, beta
        integer :: n
        integer :: i, j

!$pragma scop
        do i = 1, _PB_N
          tmp(i) = 0.0D0
          y(i) = 0.0D0
          do j = 1, _PB_N
            tmp(i) = (a(j, i) * x(j)) + tmp(i)
            y(i) = (b(j, i) * x(j)) + y(i)
          end do
          y(i) = (alpha * tmp(i)) + (beta * y(i))
        end do
!$pragma endscop
        end subroutine

      end program
