!******************************************************************************
!
!  cholesky.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "cholesky.h"

      program cholesky
      implicit none

      POLYBENCH_2D_ARRAY_DECL(a ,DATA_TYPE, N, N)
      POLYBENCH_1D_ARRAY_DECL(p ,DATA_TYPE, N)
      DATA_TYPE x
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, N, N)
      POLYBENCH_ALLOC_1D_ARRAY(p, N)

!     Initialization
      call init_array(N, p, a)

!     Kernel Execution
      polybench_start_instruments

      call kernel_cholesky(N, p, a)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, a));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(p)

      contains

        subroutine init_array(n, p, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: p
        integer :: n
        integer :: i, j
        do i = 1, n
          p(i) = 1.0D0  / n
          do j = 1, n
            a(j, i) =  1.0D0 / n
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
        end subroutine


        subroutine kernel_cholesky(n, p, a)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: p
        DATA_TYPE :: x
        integer :: n
        integer :: i, j, k

!$pragma scop
        do i = 1, _PB_N
          x = a(i, i)
          do j = 1, i - 1
            x = x - a(j, i) * a(j, i)
          end do
          p(i) = 1.0D0 / sqrt(x)
          do j = i + 1, _PB_N
            x = a(j, i)
            do k = 1, i - 1
              x = x - (a(k, j) * a(k, i))
            end do
            a(i, j) = x * p(i)
          end do
        end do
!$pragma endscop
        end subroutine

      end program
