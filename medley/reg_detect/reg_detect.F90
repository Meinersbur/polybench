!******************************************************************************
!
!  reg_detect.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 50. 
#include "reg_detect.h"

      program regdetect
      implicit none

      POLYBENCH_2D_ARRAY_DECL(sumTang ,DATA_TYPE, MAXGRID, MAXGRID)
      POLYBENCH_2D_ARRAY_DECL(mean ,DATA_TYPE, MAXGRID, MAXGRID)
      POLYBENCH_3D_ARRAY_DECL(diff,DATA_TYPE,LENGTH,MAXGRID,MAXGRID)
      POLYBENCH_3D_ARRAY_DECL(sumDiff,DATA_TYPE,LENGTH,MAXGRID,MAXGRID)
      POLYBENCH_2D_ARRAY_DECL(path ,DATA_TYPE, MAXGRID, MAXGRID)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(sumTang, MAXGRID, MAXGRID)
      POLYBENCH_ALLOC_2D_ARRAY(mean, MAXGRID, MAXGRID)
      POLYBENCH_ALLOC_3D_ARRAY(diff,LENGTH,MAXGRID,MAXGRID)
      POLYBENCH_ALLOC_3D_ARRAY(sumDiff,LENGTH,MAXGRID,MAXGRID)
      POLYBENCH_ALLOC_2D_ARRAY(path, MAXGRID, MAXGRID)

!     Initialization
      call init_array(MAXGRID, sumTang, mean, path)

!     Kernel Execution
      polybench_start_instruments

      call kernel_reg_detect(NITER, MAXGRID, LENGTH,  &
                                sumTang, mean, path, diff, sumDiff)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(MAXGRID, path));

!     Deallocation of Arrays
      POLYBENCH_DEALLOC_ARRAY(sumTang)
      POLYBENCH_DEALLOC_ARRAY(mean)
      POLYBENCH_DEALLOC_ARRAY(diff)
      POLYBENCH_DEALLOC_ARRAY(sumDiff)
      POLYBENCH_DEALLOC_ARRAY(path)

      contains

        subroutine init_array(maxgrid, sumTang, mean, path)
        implicit none

        integer :: maxgrid 
        DATA_TYPE, dimension (maxgrid, maxgrid) :: sumTang, mean, path
        integer :: i, j
        do i = 1, maxgrid
         do j = 1, maxgrid 
            sumTang(j, i) = i * j
            mean(j, i) = ( i - j ) / (maxgrid)
            path(j, i) = (( i - 1 ) * ( j - 2 )) / (maxgrid)
         end do
        end do
        end subroutine


        subroutine print_array(maxgrid, path)
        implicit none

        integer :: i, j, maxgrid
        DATA_TYPE, dimension (maxgrid, maxgrid) :: path
        do i = 1, maxgrid
          do j = 1, maxgrid
            write(0, DATA_PRINTF_MODIFIER) path(j, i)
            if (mod(((i - 1) * maxgrid) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_reg_detect(niter, maxgrid, length, &
                              sumTang, mean, path, diff, sumDiff)
        implicit none

        integer :: maxgrid, niter, length
        DATA_TYPE, dimension (maxgrid, maxgrid) :: sumTang, mean, path
        DATA_TYPE, dimension (length, maxgrid, maxgrid) :: sumDiff, diff
        integer :: i, j, t, cnt

!$pragma scop
        do t = 1, _PB_NITER
          do j = 1, _PB_MAXGRID
            do i = j, _PB_MAXGRID
              do cnt = 1, _PB_LENGTH
                diff(cnt, i, j) = sumTang(i, j)
              end do
            end do
          end do

          do j = 1, _PB_MAXGRID
            do i = j, _PB_MAXGRID
              sumDiff(1, i, j) = diff(1, i, j)
              do cnt = 2, _PB_LENGTH
                sumDiff(cnt, i, j) = sumDiff(cnt - 1, i, j) + &
                                     diff(cnt, i, j)
              end do
              mean(i, j) = sumDiff(_PB_LENGTH, i, j)
            end do
          end do

          do i = 1, _PB_MAXGRID
            path(i, 1) = mean(i, 1)
          end do

          do j = 2, _PB_MAXGRID
            do i = j, _PB_MAXGRID
              path(i, j) = path(i - 1, j - 1) + mean(i, j)
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program
