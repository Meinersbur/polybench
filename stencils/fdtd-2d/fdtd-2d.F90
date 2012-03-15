!******************************************************************************
!
!  fdtd-2d.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 50x1000x1000. 
#include "fdtd-2d.h"

      program fdtd2d
      implicit none

      POLYBENCH_1D_ARRAY_DECL(fict,DATA_TYPE,TMAX)
      POLYBENCH_2D_ARRAY_DECL(ex,DATA_TYPE,NY, NX)
      POLYBENCH_2D_ARRAY_DECL(ey,DATA_TYPE,NY, NX)
      POLYBENCH_2D_ARRAY_DECL(hz,DATA_TYPE,NY, NX)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_1D_ARRAY(fict, TMAX)
      POLYBENCH_ALLOC_2D_ARRAY(ex, NY, NX)
      POLYBENCH_ALLOC_2D_ARRAY(ey, NY, NX)
      POLYBENCH_ALLOC_2D_ARRAY(hz, NY, NX)

!     Initialization
      call init_array(TMAX, NX, NY, ex, ey, hz, fict)

!     Kernel Execution
      polybench_start_instruments

      call kernel_fdtd_2d(TMAX, NX, NY, ex, ey, hz, fict)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(NX, NY, ex, ey, hz));


!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(fict)
      POLYBENCH_DEALLOC_ARRAY(ex)
      POLYBENCH_DEALLOC_ARRAY(ey)
      POLYBENCH_DEALLOC_ARRAY(hz)

      contains

        subroutine init_array(tmax, nx, ny, ex, ey, hz, fict)
        implicit none

        integer :: nx, ny, tmax
        DATA_TYPE, dimension(tmax) :: fict
        DATA_TYPE, dimension(ny, nx) :: ex
        DATA_TYPE, dimension(ny, nx) :: ey
        DATA_TYPE, dimension(ny, nx) :: hz
        integer :: i, j
        do i = 1, tmax
          fict(i) = DBLE(i - 1)
        end do
        do i = 1, nx
          do j = 1, ny
            ex(j, i) = (DBLE((i - 1) * (j))) / DBLE(nx)
            ey(j, i) = (DBLE((i - 1) * (j + 1))) / DBLE(ny)
            hz(j, i) = (DBLE((i - 1) * (j + 2))) / DBLE(nx)
          end do
        end do
        end subroutine


        subroutine print_array(nx, ny, ex, ey, hz)
        implicit none

        DATA_TYPE, dimension(ny, nx) :: ex
        DATA_TYPE, dimension(ny, nx) :: ey
        DATA_TYPE, dimension(ny, nx) :: hz
        integer :: nx, ny
        integer :: i, j
        do i = 1, nx
          do j = 1, ny
            write(0, DATA_PRINTF_MODIFIER) ex(j, i)
            write(0, DATA_PRINTF_MODIFIER) ey(j, i)
            write(0, DATA_PRINTF_MODIFIER) hz(j, i)
            if (mod(((i - 1) * nx) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_fdtd_2d(tmax, nx, ny, ex, ey, hz, fict)
        implicit none

        integer :: tmax, nx, ny
        DATA_TYPE, dimension(tmax) :: fict
        DATA_TYPE, dimension(ny, nx) :: ex
        DATA_TYPE, dimension(ny, nx) :: ey
        DATA_TYPE, dimension(ny, nx) :: hz
        integer :: i, j, t

!$pragma scop
        do t = 1, _PB_TMAX
          do j = 1, _PB_NY
            ey(j, 1) = fict(t)
          end do
          do i = 2, _PB_NX
            do j = 1, _PB_NY
              ey(j, i) = ey(j, i) - (0.5D0 * (hz(j, i) - hz(j, i - 1)))
            end do
          end do
          do i = 1, _PB_NX
            do j = 2, _PB_NY
              ex(j, i) = ex(j, i) - (0.5D0 * (hz(j, i) - hz(j - 1, i)))
            end do
          end do
          do i = 1, _PB_NX - 1
            do j = 1, _PB_NY - 1
              hz(j, i) = hz(j, i) - (0.7D0 * (ex(j + 1, i) - ex(j, i)  &
                                           + ey(j, i + 1) - ey(j, i)))
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program
