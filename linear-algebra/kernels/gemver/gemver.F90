!******************************************************************************
!
!  gemver.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "gemver.h"

      program gemver
      implicit none

      DATA_TYPE :: alpha
      DATA_TYPE :: beta
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,N, N)
      POLYBENCH_1D_ARRAY_DECL(u1,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(u2,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(v1,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(v2,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(w,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(x,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(y,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(z,DATA_TYPE,N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, N, N)
      POLYBENCH_ALLOC_1D_ARRAY(u1, N)
      POLYBENCH_ALLOC_1D_ARRAY(u2, N)
      POLYBENCH_ALLOC_1D_ARRAY(v1, N)
      POLYBENCH_ALLOC_1D_ARRAY(v2, N)
      POLYBENCH_ALLOC_1D_ARRAY(w, N)
      POLYBENCH_ALLOC_1D_ARRAY(x, N)
      POLYBENCH_ALLOC_1D_ARRAY(y, N)
      POLYBENCH_ALLOC_1D_ARRAY(z, N)

!     Initialization
      call init_array(N,  &
           alpha, beta, a, u1, u2, v1, v2, w, x, y, z)

!     Kernel Execution
      polybench_start_instruments

      call kernel_gemver(N, alpha, beta, &
                              a, u1, v1, u2, v2, &
                              w, x, y, z)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, w));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(u1)
      POLYBENCH_DEALLOC_ARRAY(u2)
      POLYBENCH_DEALLOC_ARRAY(v1)
      POLYBENCH_DEALLOC_ARRAY(v2)
      POLYBENCH_DEALLOC_ARRAY(w)
      POLYBENCH_DEALLOC_ARRAY(x)
      POLYBENCH_DEALLOC_ARRAY(y)
      POLYBENCH_DEALLOC_ARRAY(z)

      contains

        subroutine init_array(n, alpha, beta,  &
                 a, u1, u2, v1, v2, w, x, y, z)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: u1
        DATA_TYPE, dimension(n) :: u2
        DATA_TYPE, dimension(n) :: v1
        DATA_TYPE, dimension(n) :: v2
        DATA_TYPE, dimension(n) :: w
        DATA_TYPE, dimension(n) :: x
        DATA_TYPE, dimension(n) :: y
        DATA_TYPE, dimension(n) :: z
        DATA_TYPE :: alpha, beta
        integer :: n
        integer :: i, j
        alpha = 43532.0D0
        beta = 12313.0D0

        do i = 1, n
          u1(i) = DBLE(i - 1)
          u2(i) = DBLE(i / n) / 2.0D0
          v1(i) = DBLE(i / n) / 4.0D0
          v2(i) = DBLE(i / n) / 6.0D0
          y(i) = DBLE(i / n) / 8.0D0
          z(i) = DBLE(i / n) / 9.0D0
          x(i) = 0.0D0
          w(i) = 0.0D0
          do j = 1, n
            a(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, w)
        implicit none

        DATA_TYPE, dimension(n) :: w
        integer :: n
        integer :: i, j
        do i = 1, n
          write(0, DATA_PRINTF_MODIFIER) w(i)
          if (mod(i - 1, 20) == 0) then
            write(0, *)
          end if
        end do
        write(0, *)
        end subroutine
       

        subroutine kernel_gemver(n, alpha, beta,  &
                                      a, u1, v1, u2, v2, &
                                      w, x, y, z)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: u1
        DATA_TYPE, dimension(n) :: u2
        DATA_TYPE, dimension(n) :: v1
        DATA_TYPE, dimension(n) :: v2
        DATA_TYPE, dimension(n) :: w
        DATA_TYPE, dimension(n) :: x
        DATA_TYPE, dimension(n) :: y
        DATA_TYPE, dimension(n) :: z
        DATA_TYPE :: alpha, beta
        integer :: n
        integer :: i, j

!$pragma scop
        do i = 1, _PB_N
          do j = 1, _PB_N
            a(j, i) = a(j, i) + (u1(i) * v1(j)) + (u2(i) * v2(j))
          end do
        end do
        do i = 1, _PB_N
          do j = 1, _PB_N
            x(i) = x(i) + (beta * a(i, j) * y(j))
          end do
        end do
        do i = 1, _PB_N
          x(i) = x(i) + z(i)
        end do
        do i = 1, _PB_N
          do j = 1, _PB_N
            w(i) = w(i) + (alpha * a(j, i) * x(j))
          end do
        end do
!$pragma endscop
        end subroutine

      end program

