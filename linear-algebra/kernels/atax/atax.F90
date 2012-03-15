!******************************************************************************
!
!  atax.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "atax.h"

      program atax
      implicit none

      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,NY, NX)
      POLYBENCH_1D_ARRAY_DECL(x,DATA_TYPE,NY)
      POLYBENCH_1D_ARRAY_DECL(y,DATA_TYPE,NY)
      POLYBENCH_1D_ARRAY_DECL(tmp,DATA_TYPE,NX)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, NY, NX)
      POLYBENCH_ALLOC_1D_ARRAY(x, NY)
      POLYBENCH_ALLOC_1D_ARRAY(y, NX)
      POLYBENCH_ALLOC_1D_ARRAY(tmp, NY)

!     Initialization
      call init_array(a, x, NX, NY)

!     Kernel Execution
      polybench_start_instruments

      call kernel_atax(NX, NY, a, x, y, tmp)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(y, NY));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(x)
      POLYBENCH_DEALLOC_ARRAY(y)
      POLYBENCH_DEALLOC_ARRAY(tmp)

      contains

        subroutine init_array(a, x, nx, ny)
        implicit none

        double precision :: M_PI
        parameter(M_PI = 3.14159265358979323846D0)
        DATA_TYPE, dimension(ny, nx) :: a
        DATA_TYPE, dimension(ny) :: x
        integer :: nx, ny
        integer :: i, j
        do i = 1, ny
          x(i) = DBLE(i - 1) * M_PI
          do j = 1, ny
            a(j, i) = (DBLE((i - 1) * (j))) / nx
          end do
        end do
        end subroutine


        subroutine print_array(y, ny)
        implicit none

        DATA_TYPE, dimension(ny) :: y
        integer :: ny
        integer :: i
        do i = 1, ny
          write(0, DATA_PRINTF_MODIFIER) y(i)
          if (mod(i - 1, 20) == 0) then
            write(0, *)
          end if
        end do
        write(0, *)
        end subroutine


        subroutine kernel_atax(nx, ny, a, x, y, tmp)
        implicit none

        DATA_TYPE, dimension(ny, nx) :: a
        DATA_TYPE, dimension(ny) :: x
        DATA_TYPE, dimension(ny) :: y
        DATA_TYPE, dimension(nx) :: tmp
        integer nx, ny, i, j

!$pragma scop
        do i = 1, _PB_NY
          y(i) = 0.0D0
        end do

        do i = 1, _PB_NX 
          tmp(i) = 0.0D0
          do j = 1, _PB_NY
            tmp(i) = tmp(i) + (a(j, i) * x(j))
          end do
          do j = 1, _PB_NY
            y(j) = y(j) + a(j, i) * tmp(i)
          end do
        end do
!$pragma endscop
        end subroutine

      end program
