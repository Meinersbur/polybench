!******************************************************************************
!
!  dynprog.F90: This file is part of the PolyBench/Fortran 1.0 test suite.
! 
!  Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
!  Web address: http://polybench.sourceforge.net
!
!******************************************************************************

! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 50. 
#include "dynprog.h"

      program dynprog
      implicit none

      DATA_TYPE :: output
      POLYBENCH_3D_ARRAY_DECL(sumC ,DATA_TYPE, LENGTH, LENGTH, LENGTH)
      POLYBENCH_2D_ARRAY_DECL(c ,DATA_TYPE, LENGTH, LENGTH)
      POLYBENCH_2D_ARRAY_DECL(w ,DATA_TYPE, LENGTH, LENGTH)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_3D_ARRAY(sumC, LENGTH, LENGTH, LENGTH)
      POLYBENCH_ALLOC_2D_ARRAY(c, LENGTH, LENGTH)
      POLYBENCH_ALLOC_2D_ARRAY(w, LENGTH, LENGTH)


!     Initialization
      call init_array(LENGTH, c, w)

!     Kernel Execution
      polybench_start_instruments

      call kernel_dynprog(TSTEPS, LENGTH, c, w, sumC, output)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(output));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(sumC)
      POLYBENCH_DEALLOC_ARRAY(c)
      POLYBENCH_DEALLOC_ARRAY(w)

      contains

        subroutine init_array(length, c, w)
        implicit none

        DATA_TYPE, dimension(length, length) :: w, c
        integer :: i, j
        integer length

        do i = 1, length
          do j = 1, length
            c(j, i) = mod((i-1)*(j-1), 2)
            w(j, i) = (DBLE((i - 1) - (j - 1))) / DBLE(length)
          end do
        end do
        end subroutine


        subroutine print_array(output)
        implicit none

        DATA_TYPE :: output
        write(0, DATA_PRINTF_MODIFIER) output
        write(0, *)
        end subroutine


        subroutine kernel_dynprog(tsteps , length, c, w, sumC, output)
        implicit none

        DATA_TYPE, dimension(length, length) :: w, c
        DATA_TYPE, dimension(length, length, length) :: sumC
        integer :: i, j, iter, k
        integer :: length, tsteps
        DATA_TYPE :: output

!$pragma scop
        output = 0

        do iter = 1, _PB_TSTEPS
          do i = 1, _PB_LENGTH
            do j = 1, _PB_LENGTH
              c(j, i) = 0
            end do
          end do

          do i = 1, _PB_LENGTH - 1
            do j = i + 1, _PB_LENGTH 
              sumC(i, j, i) = 0
              do k = i + 1, j - 1
                sumC(k, j, i) = sumC(k - 1, j, i) + c(k, i) + c(j, k)
              end do
              c(j, i) = sumC(j - 1, j, i) + w(j, i)
            end do
          end do
          output = output + c(_PB_LENGTH, 1)
        end do
!$pragma endscop
        end subroutine

      end program
