!******************************************************************************
!
!  doitgen.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "doitgen.h"

      program doitgen
      implicit none

      POLYBENCH_3D_ARRAY_DECL(a,DATA_TYPE,NP, NQ, NR)
      POLYBENCH_3D_ARRAY_DECL(sumA,DATA_TYPE,NP, NQ, NR)
      POLYBENCH_2D_ARRAY_DECL(cFour,DATA_TYPE,NP, NP)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_3D_ARRAY(a,NP,NQ,NR)
      POLYBENCH_ALLOC_3D_ARRAY(sumA,NP,NQ,NR)
      POLYBENCH_ALLOC_2D_ARRAY(cFour,NP,NP)

!     Initialization
      call init_array(NR, NQ, NP, a, cFour)

!     Kernel Execution
      polybench_start_instruments
 
      call kernel_doitgen(NR, NQ, NP,  &
                              a, cFour, sumA)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(a, NR, NQ, NP));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(sumA)
      POLYBENCH_DEALLOC_ARRAY(cFour)

      contains

        subroutine init_array(nr, nq, np, a, cFour)
        implicit none

        DATA_TYPE, dimension(np, nq, nr) :: a
        DATA_TYPE, dimension(np, np) :: cFour
        integer :: nr, nq, np
        integer :: i, j, k

        do i = 1, nr
          do j = 1, nq
            do k = 1, np
              a(k, j, i) = ((DBLE(i - 1) * DBLE(j - 1)) + DBLE(k - 1)) / &
                           DBLE(np)
            end do
          end do
        end do
        do i = 1, np
          do j = 1, np
            cFour(j, i) = (DBLE(i - 1) * DBLE(j - 1)) / np
          end do
        end do
        end subroutine


        subroutine print_array(a, nr, nq, np)
        implicit none

        DATA_TYPE, dimension(np, nq, nr) :: a
        integer :: nr, nq, np
        integer :: i, j, k
        do i = 1, nr
          do j = 1, nq
            do k = 1, np
              write(0, DATA_PRINTF_MODIFIER) a(k, j, i)
              if (mod((i - 1), 20) &
                  == 0) then
                write(0, *)
              end if
            end do
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_doitgen(nr, nq, np , &
                                a, cFour, sumA)
        implicit none

        DATA_TYPE, dimension(np, nq, nr) :: a
        DATA_TYPE, dimension(np, nq, nr) :: sumA
        DATA_TYPE, dimension(np, np) :: cFour
        integer :: nr, nq, np
        integer :: r, s, p, q

!$pragma scop
        do r = 1, _PB_NR
          do q = 1, _PB_NQ
            do p = 1, _PB_NP
              sumA(p, q, r) = 0.0D0
              do s = 1, _PB_NP
                sumA(p, q, r) = sumA(p, q, r) + (a(s, q, r) * &
                                    cFour(p, s))
              end do
            end do
            do p = 1, _PB_NP
              a(p, q, r) = sumA(p, q, r)
            end do
          end do
        end do
!$pragma endscop
        end subroutine

      end program
