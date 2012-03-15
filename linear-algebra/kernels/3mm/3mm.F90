!******************************************************************************
!
!  3mm.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "3mm.h"

      program three_mm
      implicit none

      POLYBENCH_2D_ARRAY_DECL(a ,DATA_TYPE, NK, NI)
      POLYBENCH_2D_ARRAY_DECL(b ,DATA_TYPE, NJ, NK)
      POLYBENCH_2D_ARRAY_DECL(c ,DATA_TYPE, NM, NJ)
      POLYBENCH_2D_ARRAY_DECL(d ,DATA_TYPE, NL, NM)
      POLYBENCH_2D_ARRAY_DECL(e ,DATA_TYPE, NJ, NI)
      POLYBENCH_2D_ARRAY_DECL(f ,DATA_TYPE, NL, NJ)
      POLYBENCH_2D_ARRAY_DECL(g ,DATA_TYPE, NL, NI)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, NK, NI)
      POLYBENCH_ALLOC_2D_ARRAY(b, NJ, NK)
      POLYBENCH_ALLOC_2D_ARRAY(c, NM, NJ)
      POLYBENCH_ALLOC_2D_ARRAY(d, NL, NM)
      POLYBENCH_ALLOC_2D_ARRAY(e, NJ, NI)
      POLYBENCH_ALLOC_2D_ARRAY(f, NL, NJ)
      POLYBENCH_ALLOC_2D_ARRAY(g, NL, NI)

!     Initialization
      call init_array(NI, NJ, NK, NL, NM, &
                           a, b, c, d)

!     Kernel Execution
      polybench_start_instruments

      call kernel_3mm(NI, NJ, NK, NL, NM, &
                          e, a, b, f, c, d, g)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(NI, NL, g));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(b)
      POLYBENCH_DEALLOC_ARRAY(c)
      POLYBENCH_DEALLOC_ARRAY(d)
      POLYBENCH_DEALLOC_ARRAY(e)
      POLYBENCH_DEALLOC_ARRAY(f)
      POLYBENCH_DEALLOC_ARRAY(g)

      contains

        subroutine init_array(ni, nj, nk, nl, nm, a, b, c , d)
        implicit none

        DATA_TYPE, dimension(nk, ni) :: a
        DATA_TYPE, dimension(nj, nk) :: b
        DATA_TYPE, dimension(nm, nj) :: c
        DATA_TYPE, dimension(nl, nm) :: d
        integer :: ni, nj, nk, nl, nm
        integer :: i, j

        do i = 1, ni
          do j = 1, nk
            a(j,i) = DBLE(i-1) * DBLE(j-1) / ni
          end do
        end do

        do i = 1, nk
          do j = 1, nj
            b(j,i) = (DBLE(i-1) * DBLE(j))/ nj
          end do
        end do

        do i = 1, nj
          do j = 1, nm
            c(j,i) = (DBLE(i-1) * DBLE(j+2))/ nl
          end do
        end do

        do i = 1, nm
          do j = 1, nl
            d(j,i) = (DBLE(i-1) * DBLE(j+1))/ nk
          end do
        end do
        end subroutine


        subroutine print_array(ni, nl, g)
        implicit none

        DATA_TYPE, dimension(nl, ni) :: g
        integer :: ni, nl
        integer :: i, j
        do i = 1, ni
          do j = 1, nl
            write(0, DATA_PRINTF_MODIFIER) g(j,i) 
            if (mod(((i - 1) * ni) + j - 1, 20) == 0) then
              write(0, *)
            end if
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_3mm(ni, nj, nk, nl, nm, e, a, b, f, c, d, g)
        implicit none

        DATA_TYPE, dimension(nk, ni) :: a
        DATA_TYPE, dimension(nj, nk) :: b
        DATA_TYPE, dimension(nm, nj) :: c
        DATA_TYPE, dimension(nl, nm) :: d
        DATA_TYPE, dimension(nj, ni) :: e
        DATA_TYPE, dimension(nl, nj) :: f
        DATA_TYPE, dimension(nl, ni) :: g
        integer :: ni, nj, nk, nl, nm
        integer :: i, j, k

!$pragma scop
        ! E := A*B
        do i = 1, _PB_NI
          do j = 1, _PB_NJ
            e(j,i) = 0.0
            do k = 1, _PB_NK
              e(j,i) = e(j,i) + a(k,i) * b(j,k)
            end do
          end do
        end do

        ! F := C*D
        do i = 1, _PB_NJ
          do j = 1, _PB_NL
            f(j,i) = 0.0
            do k = 1, _PB_NM
              f(j,i) = f(j,i) + c(k,i) * d(j,k)
            end do
          end do
        end do

        ! G := E*F
        do i = 1, _PB_NI
          do j = 1, _PB_NL
            g(j,i) = 0.0
            do k = 1, _PB_NJ
              g(j,i) = g(j,i) + e(k,i) * f(j,k)
            end do
          end do
        end do
!$pragma endscop

        end subroutine

      end program
