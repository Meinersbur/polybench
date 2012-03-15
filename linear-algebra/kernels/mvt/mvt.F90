!******************************************************************************
!
!  mvt.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "mvt.h"

      program mvt
      implicit none

      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,N, N)
      POLYBENCH_1D_ARRAY_DECL(x1,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(y1,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(x2,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(y2,DATA_TYPE,N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, N, N)
      POLYBENCH_ALLOC_1D_ARRAY(x1, N)
      POLYBENCH_ALLOC_1D_ARRAY(y1, N)
      POLYBENCH_ALLOC_1D_ARRAY(x2, N)
      POLYBENCH_ALLOC_1D_ARRAY(y2, N)

!     Initialization
      call init_array(N, x1, x2, y1, y2, a)

!     Kernel Execution
      polybench_start_instruments

      call kernel_mvt(N, x1, x2, &
                              y1, y2, a)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, x1, x2));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(x1)
      POLYBENCH_DEALLOC_ARRAY(y1)
      POLYBENCH_DEALLOC_ARRAY(x2)
      POLYBENCH_DEALLOC_ARRAY(y2)

      contains

        subroutine init_array(n, x1, x2, y1, y2, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: x1
        DATA_TYPE, dimension(n) :: y1
        DATA_TYPE, dimension(n) :: x2
        DATA_TYPE, dimension(n) :: y2
        integer :: n
        integer :: i, j

        do i = 1, n
          x1(i) = DBLE(i - 1) / DBLE(n)
          x2(i) = (DBLE(i - 1) + 1.0D0) / DBLE(n)
          y1(i) = (DBLE(i - 1) + 3.0D0) / DBLE(n)
          y2(i) = (DBLE(i - 1) + 4.0D0) / DBLE(n)
          do j = 1, n
            a(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, x1, x2)
        implicit none

        DATA_TYPE, dimension(n) :: x1
        DATA_TYPE, dimension(n) :: x2
        integer :: n
        integer :: i
        do i = 1, n
          write(0, DATA_PRINTF_MODIFIER) x1(i)
          write(0, DATA_PRINTF_MODIFIER) x2(i)
          if (mod((i - 1), 20) == 0) then
            write(0, *)
          end if
        end do
        write(0, *)
        end subroutine


        subroutine kernel_mvt(n, x1, x2, y1, y2, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: x1
        DATA_TYPE, dimension(n) :: y1
        DATA_TYPE, dimension(n) :: x2
        DATA_TYPE, dimension(n) :: y2
        integer :: n
        integer :: i, j

!$pragma scop
        do i = 1, _PB_N
          do j = 1, _PB_N
            x1(i) = x1(i) + (a(j, i) * y1(j))
          end do
        end do
        do i = 1, _PB_N
          do j = 1, _PB_N 
            x2(i) = x2(i) + (a(i, j) * y2(j))
          end do
        end do
!$pragma endscop
        end subroutine

      end program
