!******************************************************************************
!
!  jacobi-1d-imper.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 100x10000. 
#include "jacobi-1d-imper.h"

      program jacobi1d
      implicit none

      POLYBENCH_1D_ARRAY_DECL(a,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(b,DATA_TYPE,N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_1D_ARRAY(a, N)
      POLYBENCH_ALLOC_1D_ARRAY(b, N)

!     Initialization
      call init_array(N, a, b)

!     Kernel Execution
      polybench_start_instruments

      call kernel_jacobi1d(TSTEPS, N, a, b)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, a));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)

      contains

        subroutine init_array(n, a, b)
        implicit none

        DATA_TYPE, dimension(n) :: a
        DATA_TYPE, dimension(n) :: b
        integer :: n
        integer :: i

        do i = 1, n
          a(i) = (DBLE(i-1) + 2.0D0) / n
          b(i) = (DBLE(i-1) + 3.0D0) / n
        end do
        end subroutine


        subroutine print_array(n, a)
        implicit none

        DATA_TYPE, dimension(n) :: a
        integer :: n
        integer :: i

        do i = 1, n
          write(0, DATA_PRINTF_MODIFIER) a(i)
          if (mod(i - 1, 20) == 0) then
            write(0, *)
          end if
        end do
        write(0, *)
        end subroutine


        subroutine kernel_jacobi1d(tsteps, n, a, b)
        implicit none

        DATA_TYPE, dimension(n) :: a
        DATA_TYPE, dimension(n) :: b
        integer :: n, tsteps
        integer :: i, t, j
!$pragma scop
        do t = 1, _PB_TSTEPS
          do i = 2, _PB_N - 1
            b(i) = 0.33333D0 * (a(i - 1) + a(i) + a(i + 1))
          end do

          do j = 2, _PB_N -1
            a(j) = b(j)
          end do
        end do
!$pragma endscop
        end subroutine

      end program
