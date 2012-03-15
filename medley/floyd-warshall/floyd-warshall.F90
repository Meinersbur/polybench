!******************************************************************************
!
!  floyd-warshall.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 1024. 
#include "floyd-warshall.h"

      program floyd_warshall
      implicit none

      POLYBENCH_2D_ARRAY_DECL(path,DATA_TYPE,N,N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(path, N, N)

!     Initialization
      call init_array(N, path)

!     Kernel Execution
      polybench_start_instruments

      call kernel_floyd_warshall(N, path)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, path));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(path)

      contains

        subroutine init_array(n, path)
        implicit none

        DATA_TYPE, dimension(n,n) :: path
        integer :: i, j, n 

        do i=1, n
          do j=1, n
            path(j, i) = (DBLE(i * j))/ DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, path)
        implicit none

        DATA_TYPE, dimension(n, n) :: path
        integer :: i, j, n

        do i=1, n
          do j=1, n
             write(0, DATA_PRINTF_MODIFIER) path(j,i) 

             if (mod(((i - 1) * n) + j - 1, 20) == 0) then
               write(0, *)
             end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_floyd_warshall(n, path)
        implicit none

        DATA_TYPE, dimension(n,n) :: path
        integer :: n
        integer :: i, j, k

!$pragma scop
        do k=1, _PB_N
          do i=1, _PB_N
            do j=1, _PB_N
               if( path(j, i) .GE. path(k, i) + path(j, k) ) then
                 path(j, i) = path(k, i) + path(j, k)
               end if
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program
