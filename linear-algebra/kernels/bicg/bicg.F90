!******************************************************************************
!
!  bicg.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "bicg.h"

      program bicg
      implicit none

      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,NY, NX)
      POLYBENCH_1D_ARRAY_DECL(r,DATA_TYPE,NX)
      POLYBENCH_1D_ARRAY_DECL(s,DATA_TYPE,NY)
      POLYBENCH_1D_ARRAY_DECL(p,DATA_TYPE,NY)
      POLYBENCH_1D_ARRAY_DECL(q,DATA_TYPE,NX)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, NY, NX)
      POLYBENCH_ALLOC_1D_ARRAY(r, NX)
      POLYBENCH_ALLOC_1D_ARRAY(s, NY)
      POLYBENCH_ALLOC_1D_ARRAY(p, NY)
      POLYBENCH_ALLOC_1D_ARRAY(q, NX)

!     Initialization
      call init_array(NX, NY, a, r, p)

!     Kernel Execution
      polybench_start_instruments

      call kernel_bicg(NX, NY,  &
                              a, s, q, p, r)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(NX, NY, s, q));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(r)
      POLYBENCH_DEALLOC_ARRAY(s)
      POLYBENCH_DEALLOC_ARRAY(p)
      POLYBENCH_DEALLOC_ARRAY(q)


      contains

        subroutine init_array(nx, ny, a, r, p)
        implicit none

        double precision :: M_PI
        parameter(M_PI = 3.14159265358979323846D0)
        DATA_TYPE, dimension(ny, nx) :: a
        DATA_TYPE, dimension(nx) :: r
        DATA_TYPE, dimension(ny) :: p
        integer :: nx, ny
        integer :: i, j

        do i = 1, ny
          p(i) = DBLE(i - 1) * M_PI
        end do

        do i = 1, nx
          r(i) = DBLE(i - 1) * M_PI
          do j = 1, ny
            a(j, i) = (DBLE(i - 1) * DBLE(j)) / nx
          end do
        end do
        end subroutine


        subroutine print_array(nx, ny, s, q)
        implicit none

        DATA_TYPE, dimension(ny) :: s
        DATA_TYPE, dimension(nx) :: q
        integer :: nx,ny
        integer :: i
        do i = 1, ny
          write(0, DATA_PRINTF_MODIFIER) s(i)
          if (mod(i - 1, 80) == 0) then
            write(0, *)
          end if
        end do

        do i = 1, nx
          write(0, DATA_PRINTF_MODIFIER) q(i)
          if (mod(i - 1, 80) == 0) then
            write(0, *)
          end if
        end do
        write(0, *)
        end subroutine
      

        subroutine kernel_bicg(nx, ny, a, s, q, p, r)
        implicit none

        DATA_TYPE, dimension(ny, nx) :: a
        DATA_TYPE, dimension(nx) :: r
        DATA_TYPE, dimension(nx) :: q
        DATA_TYPE, dimension(ny) :: p
        DATA_TYPE, dimension(ny) :: s
        integer :: nx,ny
        integer :: i,j

!$pragma scop
        do i = 1, _PB_NY
          s(i) = 0.0D0
        end do

        do i = 1, _PB_NX
          q(i) = 0.0D0
          do j = 1, _PB_NY
            s(j) = s(j) + (r(i) * a(j, i))
            q(i) = q(i) + (a(j, i) * p(j))
          end do
        end do
!$pragma endscop
        end subroutine

      end program
