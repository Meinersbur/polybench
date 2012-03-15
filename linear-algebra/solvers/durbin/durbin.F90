!******************************************************************************
!
!  durbin.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "durbin.h"

      program durbin
      implicit none

      POLYBENCH_2D_ARRAY_DECL(y,DATA_TYPE,N, N)
      POLYBENCH_2D_ARRAY_DECL(sumArray,DATA_TYPE,N, N)
      POLYBENCH_1D_ARRAY_DECL(beta,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(alpha,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(r,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(outArray,DATA_TYPE,N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(y, N, N)
      POLYBENCH_ALLOC_2D_ARRAY(sumArray, N, N)
      POLYBENCH_ALLOC_1D_ARRAY(beta, N)
      POLYBENCH_ALLOC_1D_ARRAY(alpha, N)
      POLYBENCH_ALLOC_1D_ARRAY(r, N)
      POLYBENCH_ALLOC_1D_ARRAY(outArray, N)

!     Initialization
      call init_array(N, y, sumArray, alpha, beta, r)

!     Kernel Execution
      polybench_start_instruments

      call kernel_durbin(N, y, sumArray, alpha, beta, r, outArray)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, outArray));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(y)
      POLYBENCH_DEALLOC_ARRAY(sumArray)
      POLYBENCH_DEALLOC_ARRAY(beta)
      POLYBENCH_DEALLOC_ARRAY(alpha)
      POLYBENCH_DEALLOC_ARRAY(r)
      POLYBENCH_DEALLOC_ARRAY(outArray)

      contains

        subroutine init_array(n, y, sumArray, alpha, beta, r)
        implicit none

        DATA_TYPE, dimension(n, n) :: y
        DATA_TYPE, dimension(n, n) :: sumArray
        DATA_TYPE, dimension(n) :: beta
        DATA_TYPE, dimension(n) :: alpha
        DATA_TYPE, dimension(n) :: r
        integer :: i, j
        integer :: n

        do i = 1, n
          alpha(i) = i
          beta(i) = (i/n)/DBLE(2.0)
          r(i)  = (i/n)/DBLE(4.0)
          do j = 1, n
            y(j,i) = DBLE(i*j)/DBLE(n)
            sumArray(j,i) = DBLE(i*j)/DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, outArray)
        implicit none

        DATA_TYPE, dimension(n) :: outArray
        integer :: n
        integer :: i
        do i = 1, n
          write(0, DATA_PRINTF_MODIFIER) outArray(i)
          if (mod(i - 1, 20) == 0) then
            write(0, *)
          end if
        end do
        end subroutine

     
        subroutine kernel_durbin(n, y, sumArray, alpha, beta, r,  &
                                                        outArray)
        implicit none
        DATA_TYPE, dimension(n, n) :: y
        DATA_TYPE, dimension(n, n) :: sumArray
        DATA_TYPE, dimension(n) :: beta
        DATA_TYPE, dimension(n) :: alpha
        DATA_TYPE, dimension(n) :: r
        DATA_TYPE, dimension(n) :: outArray
        integer :: i, k, n

!$pragma scop
        y(1, 1) = r(1)
        beta(1) = 1
        alpha(1) = r(1)
        do k = 2, _PB_N
          beta(k) = beta(k - 1) - (alpha(k - 1) * alpha(k - 1) * &
                                   beta(k -1))
          sumArray(k, 1) = r(k)
          do i = 1, k - 1 
            sumArray(k, i + 1) = sumArray(k, i) + &
                                 (r(k - i) * y(k - 1, i))
          end do
          alpha(k) = alpha(k) - (sumArray(k, k) * beta(k))
          do i = 1, k - 1
            y(k, i) = y(k - 1, i) + (alpha(k) * y(k - 1, k - i))
          end do
          y(k, k) = alpha(k)
        end do

        do i = 1, _PB_N
          outArray(i) = y(_PB_N, i)
        end do
!$pragma endscop
        end subroutine

      end program

