!******************************************************************************
!
!  symm.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

#include <fpolybench.h>
! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "symm.h"

      program symm
      implicit none

      DATA_TYPE :: alpha, beta
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,NJ, NJ)
      POLYBENCH_2D_ARRAY_DECL(b,DATA_TYPE,NJ, NI)
      POLYBENCH_2D_ARRAY_DECL(c,DATA_TYPE,NJ, NI)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, NJ, NJ)
      POLYBENCH_ALLOC_2D_ARRAY(b, NJ, NI)
      POLYBENCH_ALLOC_2D_ARRAY(c, NJ, NI)

!     Initialization
      call init_array(NI, NJ, alpha, beta, &
                           c, a, b)

!     Kernel Execution
      polybench_start_instruments

      call kernel_symm(NI, NJ, alpha, beta, &
                          c, a, b)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(NI, NJ, c));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)
      POLYBENCH_DEALLOC_ARRAY(c)

      contains

        subroutine init_array(ni, nj, alpha, beta, c, a, b)
        implicit none

        DATA_TYPE, dimension(nj, nj) :: a
        DATA_TYPE, dimension(nj, ni) :: b
        DATA_TYPE, dimension(nj, ni) :: c
        DATA_TYPE :: alpha, beta
        integer :: ni, nj
        integer :: i, j

        alpha = 32412D0
        beta = 2123D0

        do i = 1, ni
          do j = 1, nj
            c(j, i) = ((DBLE((i - 1) * (j - 1)))) / DBLE(ni)
            b(j, i) = ((DBLE((i - 1) * (j - 1)))) / DBLE(ni)
          end do
        end do
        do i = 1, nj
          do j = 1, nj
            a(j, i) = (DBLE((i - 1) * (j - 1))) / DBLE(ni)
          end do
        end do
        end subroutine


        subroutine print_array(ni, nj, c)
        implicit none

        DATA_TYPE, dimension(nj, ni) :: c
        integer :: ni, nj
        integer :: i, j
        do i = 1, ni 
          do j = 1, nj
            write(0, DATA_PRINTF_MODIFIER) c(j, i)
            if (mod(((i - 1) * ni) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_symm(ni, nj, alpha, beta, c, a, b)
        implicit none

        DATA_TYPE, dimension(nj, nj) :: a
        DATA_TYPE, dimension(nj, ni) :: b
        DATA_TYPE, dimension(nj, ni) :: c
        DATA_TYPE :: alpha, beta
        DATA_TYPE :: acc
        integer :: ni, nj
        integer :: i, j, k

!$pragma scop
        do i = 1, _PB_NI
          do j = 1, _PB_NJ
            acc = 0.0D0
              do k = 1, j - 2
                c(j, k) = c(j, k) + (alpha * a(i, k) * b(j, i))
                acc = acc + (b(j, k) * a(i, k))
              end do
            c(j, i) = (beta * c(j, i)) + (alpha * a(i, i) * b(j, i)) + &
                      (alpha * acc)
          end do
        end do
!$pragma endscop
        end subroutine

      end program

