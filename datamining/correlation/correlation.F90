!******************************************************************************
!
!  correlation.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "correlation.h"

      program correlation
      implicit none

      DATA_TYPE :: FLOAT_N
      POLYBENCH_2D_ARRAY_DECL(dat ,DATA_TYPE, N, M)
      POLYBENCH_2D_ARRAY_DECL(symmat ,DATA_TYPE, M, M)
      POLYBENCH_1D_ARRAY_DECL(stddev ,DATA_TYPE, M)
      POLYBENCH_1D_ARRAY_DECL(mean ,DATA_TYPE, M)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(dat, N, M)
      POLYBENCH_ALLOC_2D_ARRAY(symmat, M, M)
      POLYBENCH_ALLOC_1D_ARRAY(stddev, M)
      POLYBENCH_ALLOC_1D_ARRAY(mean, M)

!     Initialization
      call init_array(M, N, FLOAT_N, dat)

!     Kernel Execution
      polybench_start_instruments

      call kernel_correlation(M, N, FLOAT_N, dat, symmat,  &
                                  mean, stddev)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(M, symmat));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(dat)
      POLYBENCH_DEALLOC_ARRAY(symmat)
      POLYBENCH_DEALLOC_ARRAY(stddev)
      POLYBENCH_DEALLOC_ARRAY(mean)

      contains

        subroutine init_array(m, n, float_n, dat)
        implicit none

        DATA_TYPE, dimension(N, M) :: dat
        DATA_TYPE :: float_n
        integer :: m, n
        integer :: i, j

        float_n = 1.2D0
        do i = 1, m 
          do j = 1, n
            dat(j, i) = (DBLE(i - 1) * DBLE(j - 1)) / DBLE(m)
          end do
        end do
        end subroutine


        subroutine print_array(m, symmat)
        implicit none
 
        DATA_TYPE, dimension(N, M) :: symmat
        integer :: m
        integer :: i, j
        do i = 1, m
          do j = 1, m
            write(0, DATA_PRINTF_MODIFIER) symmat(j, i)
            if (mod(((i - 1) * m) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_correlation(m, n, float_n, dat, symmat, &
                                           mean, stddev)
        implicit none

        DATA_TYPE, dimension(n,m) :: dat
        DATA_TYPE, dimension(m,m) :: symmat
        DATA_TYPE, dimension(m) :: stddev 
        DATA_TYPE, dimension(m) :: mean
        DATA_TYPE :: float_n, EPS
        integer :: m, n
        integer :: i, j, j1, j2

        EPS = 0.1D0
!$pragma scop
!       Determine mean of column vectors of input data matrix
        do j = 1, _PB_M
          mean(j) = 0.0D0
          do i = 1, _PB_N
            mean(j) = mean(j) + dat(j, i)
          end do
          mean(j) = mean(j) / float_n
        end do

!       Determine standard deviations of column vectors of data matrix.
        do j = 1, _PB_M
          stddev(j) = 0.0D0
          do i = 1, _PB_N
            stddev(j) = stddev(j) + (dat(j, i) - mean(j)) * (dat(j, i) - &
                        mean(j))
          end do
          stddev(j) = stddev(j) / float_n
          stddev(j) = sqrt(stddev(j))
          if (stddev(j) <= EPS) then
            stddev(j) = 1.0D0
          endif
        end do

!       Center and reduce the column vectors.
        do i = 1, _PB_N
          do j = 1, _PB_M
            dat(j, i) = dat(j, i) - mean(j)
            dat(j, i) = dat(j, i) / (sqrt(float_n) * stddev(j))
          end do
        end do

!       Calculate the m * m correlation matrix.
        do j1 = 1, _PB_M - 1 
          symmat(j1, j1) = 1.0D0
          do j2 = j1 + 1, _PB_M 
            symmat(j2, j1) = 0.0D0
            do i = 1, _PB_N
             symmat(j2, j1) = symmat(j2, j1) + (dat(j1, i) * dat(j2, i))
            end do
            symmat(j1, j2) = symmat(j2, j1)
          end do
        end do
        symmat(_PB_M, _PB_M) = 1.0D0
!$pragma endscop
        end subroutine

      end program
