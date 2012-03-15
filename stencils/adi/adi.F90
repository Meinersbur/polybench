!*****************************************************************************
!                                                                             
!  adi.F90: This file is part of the PolyBench/Fortran 1.0 test suite.          
!                                                                             
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>                   
!  Web address: http://polybench.sourceforge.net                              
!                                                                             
!*****************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 10x1024x1024. 
#include "adi.h"

      program adi
      implicit none

      POLYBENCH_2D_ARRAY_DECL(x,DATA_TYPE,N, N)
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,N, N)
      POLYBENCH_2D_ARRAY_DECL(b,DATA_TYPE,N, N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(x, N, N)
      POLYBENCH_ALLOC_2D_ARRAY(a, N, N)
      POLYBENCH_ALLOC_2D_ARRAY(b, N, N)

!     Initialization
      call init_array(N, x, a, b)

!     Kernel Execution
      polybench_start_instruments

      call kernel_adi(TSTEPS, N, x, a, b)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, x));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(x)
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)

      contains

        subroutine init_array(n, x, a, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: x
        DATA_TYPE, dimension(n, n) :: b
        integer :: n
        integer :: i, j

        do i = 1, n
          do j = 1, n
            x(j, i) = (DBLE((i - 1) * (j)) + 1.0D0) / DBLE(n)
            a(j, i) = (DBLE((i - 1) * (j + 1)) + 2.0D0) / DBLE(n)
            b(j, i) = (DBLE((i - 1) * (j + 2)) + 3.0D0) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, x)
        implicit none

        DATA_TYPE, dimension(n, n) :: x
        integer :: n
        integer :: i, j

        do i = 1, n
          do j = 1, n
            write(0, DATA_PRINTF_MODIFIER) x(j, i)
            if (mod(((i - 1) * n) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_adi(tsteps, n, x, a, b)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n, n) :: x
        DATA_TYPE, dimension(n, n) :: b
        integer :: n, tsteps
        integer :: i1, i2, t

!$pragma scop
        do t = 1, _PB_TSTEPS
          do i1 = 1, _PB_N
            do i2 = 2, _PB_N
              x(i2, i1) = x(i2, i1) - ((x(i2 - 1, i1) * a(i2, i1)) / &
                          b(i2 - 1, i1))
              b(i2, i1) = b(i2, i1) - ((a(i2, i1) * a(i2, i1)) / &
                          b(i2 - 1, i1))
            end do
          end do

          do i1 = 1, _PB_N
            x(_PB_N, i1) = x(_PB_N, i1) / b(_PB_N, i1)
          end do

          do i1 = 1, _PB_N 
            do i2 = 1, _PB_N - 2
              x(_PB_N - i2, i1) = (x(_PB_N - i2, i1) - &
                                    (x(_PB_N - i2 - 1, i1) * &
                                    a(_PB_N - i2 - 1, i1))) / &
                                    b(_PB_N - i2 - 1, i1)
            end do
          end do

          do i1 = 2, _PB_N 
            do i2 = 1, _PB_N 
              x(i2, i1) = x(i2, i1) - x(i2, i1 - 1) * a(i2, i1) / &
                          b(i2, i1 - 1)
              b(i2, i1) = b(i2, i1) - a(i2, i1) * a(i2, i1) / &
                          b(i2, i1 - 1)
              
            end do
          end do

          do i2 = 1, _PB_N
            x(i2, _PB_N) = x(i2, _PB_N) / b(i2, _PB_N)
          end do

          do i1 = 1, _PB_N - 2
            do i2 = 1, _PB_N
              x(i2, _PB_N - i1) = (x(i2, _PB_N - i1) - &
                                    x(i2, _PB_N - i1 - 1) * &
                                    a(i2, _PB_N - i1 - 1)) / &
                                    b(i2, _PB_N - i1)
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program
