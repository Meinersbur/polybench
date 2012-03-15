!******************************************************************************
!
!  2mm.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "2mm.h"

      program two_mm
      implicit none

      POLYBENCH_2D_ARRAY_DECL(tmp ,DATA_TYPE, NJ, NI)
      POLYBENCH_2D_ARRAY_DECL(a ,DATA_TYPE, NK, NI) 
      POLYBENCH_2D_ARRAY_DECL(b ,DATA_TYPE, NJ, NK) 
      POLYBENCH_2D_ARRAY_DECL(c ,DATA_TYPE, NL, NJ) 
      POLYBENCH_2D_ARRAY_DECL(d ,DATA_TYPE, NL, NI) 
      DATA_TYPE :: alpha, beta
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(tmp, NJ, NI)
      POLYBENCH_ALLOC_2D_ARRAY(a, NK, NI)
      POLYBENCH_ALLOC_2D_ARRAY(b, NJ, NK)
      POLYBENCH_ALLOC_2D_ARRAY(c, NL, NJ)
      POLYBENCH_ALLOC_2D_ARRAY(d, NL, NI)

!     Initialization
      call init_array(alpha, beta, a, b, c, d, NI, NJ,  &
                                             NK, NL)

!     Kernel Execution
      polybench_start_instruments

      call kernel_2mm(alpha, beta, tmp, a, b, c, d,  &
                                  NI, NJ, NK, NL)


      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(d, NI, NL));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(tmp)
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)
      POLYBENCH_DEALLOC_ARRAY(c)
      POLYBENCH_DEALLOC_ARRAY(d)

      contains

        subroutine init_array(alpha, beta, a, b, c ,d, ni, nj,  &
             nk, nl)
        implicit none

        DATA_TYPE, dimension(nk, ni) :: a
        DATA_TYPE, dimension(nj, nk) :: b
        DATA_TYPE, dimension(nl, nj) :: c
        DATA_TYPE, dimension(nl, ni) :: d
        DATA_TYPE :: alpha, beta
        integer :: ni, nj, nk, nl
        integer :: i, j

        alpha = 32412;
        beta = 2123; 

        do i = 1, ni
          do j = 1, nk
            a(j,i) = DBLE((i-1) * (j-1)) / ni
          end do
        end do

        do i = 1, nk
          do j = 1, nj
            b(j,i) = (DBLE((i-1) * (j)))/ nj
          end do
        end do

        do i = 1, nl
          do j = 1, nj
            c(j,i) = (DBLE(i-1) * (j+2))/ nl
          end do
        end do

        do i = 1, ni
          do j = 1, nl
            d(j,i) = (DBLE(i-1) * (j+1))/ nk
          end do
        end do
        end subroutine


        subroutine print_array(d, ni, nl)
        implicit none

        DATA_TYPE, dimension(nl, ni) :: d
        integer :: nl, ni
        integer :: i, j
        do i = 1, ni
          do j = 1, nl
            write(0, DATA_PRINTF_MODIFIER) d(j,i) 

            if (mod(((i - 1) * ni) + j - 1, 20) == 0) then
              write(0, *)
            end if

          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_2mm(alpha, beta, tmp, a, b, c, d,  &
                                              ni, nj, nk, nl)
        implicit none

        DATA_TYPE, dimension(nj, ni) :: tmp
        DATA_TYPE, dimension(nk, ni) :: a
        DATA_TYPE, dimension(nj, nk) :: b
        DATA_TYPE, dimension(nl, nj) :: c
        DATA_TYPE, dimension(nl, ni) :: d
        DATA_TYPE :: alpha, beta
        integer :: ni, nj, nk, nl
        integer :: i, j, k

!$pragma scop
        do i = 1, _PB_NI
          do j = 1, _PB_NJ
            tmp(j,i) = 0.0
            do k = 1, _PB_NK
              tmp(j,i) = tmp(j,i) + alpha * a(k,i) * b(j,k)
            end do
          end do
        end do

        do i = 1, _PB_NI
          do j = 1, _PB_NL
            d(j,i) = d(j,i) * beta
            do k = 1, _PB_NJ
              d(j,i) = d(j,i) + tmp(k,i) * c(j,k)
            end do
          end do
        end do
!$pragma endscop
        end subroutine 

      end program
