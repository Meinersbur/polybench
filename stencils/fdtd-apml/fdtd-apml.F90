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
! Default data type is double, default size is 256x256x256. 
#include "fdtd-apml.h"

      program fdtdapml
      implicit none

      DATA_TYPE :: ch
      DATA_TYPE :: mui
      POLYBENCH_3D_ARRAY_DECL(ex,DATA_TYPE,CXM+1,CYM+1,CZ+1)
      POLYBENCH_3D_ARRAY_DECL(ey,DATA_TYPE,CXM+1,CYM+1,CZ+1)
      POLYBENCH_3D_ARRAY_DECL(bza,DATA_TYPE,CXM+1,CYM+1,CZ+1)
      POLYBENCH_3D_ARRAY_DECL(hz,DATA_TYPE,CXM+1,CYM+1,CZ+1)
      POLYBENCH_2D_ARRAY_DECL(clf ,DATA_TYPE, CXM + 1, CYM + 1)
      POLYBENCH_2D_ARRAY_DECL(tmp ,DATA_TYPE, CXM + 1, CYM + 1)
      POLYBENCH_2D_ARRAY_DECL(ry ,DATA_TYPE, CYM + 1, CZ + 1)
      POLYBENCH_2D_ARRAY_DECL(ax ,DATA_TYPE, CYM + 1, CZ + 1)
      POLYBENCH_1D_ARRAY_DECL(cymh ,DATA_TYPE, CYM + 1)
      POLYBENCH_1D_ARRAY_DECL(cyph ,DATA_TYPE, CYM + 1)
      POLYBENCH_1D_ARRAY_DECL(cxmh ,DATA_TYPE, CXM + 1)
      POLYBENCH_1D_ARRAY_DECL(cxph ,DATA_TYPE, CXM + 1)
      POLYBENCH_1D_ARRAY_DECL(czm ,DATA_TYPE, CZ + 1)
      POLYBENCH_1D_ARRAY_DECL(czp ,DATA_TYPE, CZ + 1)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_3D_ARRAY(ex,CXM+1,CYM+1,CZ+1)
      POLYBENCH_ALLOC_3D_ARRAY(ey,CXM+1,CYM+1,CZ+1)
      POLYBENCH_ALLOC_3D_ARRAY(bza,CXM+1,CYM+1,CZ+1)
      POLYBENCH_ALLOC_3D_ARRAY(hz,CXM+1,CYM+1,CZ+1)
      POLYBENCH_ALLOC_2D_ARRAY(clf,CXM+1,CYM+1)
      POLYBENCH_ALLOC_2D_ARRAY(tmp,CXM+1,CYM+1)
      POLYBENCH_ALLOC_2D_ARRAY(ry,CYM+1,CZ+1)
      POLYBENCH_ALLOC_2D_ARRAY(ax,CYM+1,CZ+1)
      POLYBENCH_ALLOC_1D_ARRAY(cymh,CYM+1)
      POLYBENCH_ALLOC_1D_ARRAY(cyph,CYM+1)
      POLYBENCH_ALLOC_1D_ARRAY(cxmh,CXM+1)
      POLYBENCH_ALLOC_1D_ARRAY(cxph,CXM+1)
      POLYBENCH_ALLOC_1D_ARRAY(czm,CZ+1)
      POLYBENCH_ALLOC_1D_ARRAY(czp,CZ+1)

!     Initialization
      call init_array(CZ, CXM, CYM, &
                          mui, ch, ax, ry, ex, ey, &
                          hz, czm, czp, cxmh, cxph, &
                          cymh, cyph)

!     Kernel Execution
      polybench_start_instruments

      call kernel_fdtd_apml(CZ, CXM, CYM, mui, ch, &
                       ax, ry, clf, tmp, bza, ex, ey,  &
                       hz, czm, czp, cxmh, cxph, cymh, cyph)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(CZ, CXM, CYM , Bza, Ex, Ey, Hz))

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(ex)
      POLYBENCH_DEALLOC_ARRAY(ey)
      POLYBENCH_DEALLOC_ARRAY(bza)
      POLYBENCH_DEALLOC_ARRAY(hz)
      POLYBENCH_DEALLOC_ARRAY(clf)
      POLYBENCH_DEALLOC_ARRAY(tmp)
      POLYBENCH_DEALLOC_ARRAY(ry)
      POLYBENCH_DEALLOC_ARRAY(ax)
      POLYBENCH_DEALLOC_ARRAY(cymh)
      POLYBENCH_DEALLOC_ARRAY(cyph)
      POLYBENCH_DEALLOC_ARRAY(cxmh)
      POLYBENCH_DEALLOC_ARRAY(cxph)
      POLYBENCH_DEALLOC_ARRAY(czm)
      POLYBENCH_DEALLOC_ARRAY(czp)

      contains

        subroutine init_array(cz, cxm, cym, mui, ch, ax, ry, ex, ey, hz, &
                                       czm, czp, cxmh, cxph, cymh, cyph)
        implicit none

        integer :: cz, cym, cxm
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: ex
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: ey
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: hz
        DATA_TYPE, dimension(cym + 1, cz + 1) :: ry
        DATA_TYPE, dimension(cym + 1, cz + 1) :: ax
        DATA_TYPE, dimension(cym + 1) :: cymh
        DATA_TYPE, dimension(cym + 1) :: cyph
        DATA_TYPE, dimension(cxm + 1) :: cxmh
        DATA_TYPE, dimension(cxm + 1) :: cxph
        DATA_TYPE, dimension(cz + 1) :: czm
        DATA_TYPE, dimension(cz + 1) :: czp
        DATA_TYPE :: mui, ch
        integer :: i, j, k

        mui = 2341
        ch = 42
        do i = 1, cz + 1
          czm(i) = (DBLE(i - 1) + 1.0D0) / DBLE(cxm)
          czp(i) = (DBLE(i - 1) + 2.0D0) / DBLE(cxm)
        end do
        do i = 1, cxm + 1
          cxmh(i) = (DBLE(i - 1) + 3.0D0) / DBLE(cxm)
          cxph(i) = (DBLE(i - 1) + 4.0D0) / DBLE(cxm)
        end do
        do i = 1, cym + 1
          cymh(i) = (DBLE(i - 1) + 5.0D0) / DBLE(cxm)
          cyph(i) = (DBLE(i - 1) + 6.0D0) / DBLE(cxm)
        end do
        do i = 1, cz + 1
          do j = 1, cym + 1
            ry(j, i) = ((DBLE(i - 1) * DBLE(j)) + 10.0D0) / &
                       DBLE(cym)
            ax(j, i) = ((DBLE(i - 1) * DBLE(j + 1)) + 11.0D0) / &
                       DBLE(cym)
            do k = 1, cxm + 1
              ex(k, j, i) = ((DBLE(i - 1) * DBLE(j + 2)) + DBLE(k - 1) + &
                             1.0D0) / DBLE(cxm)
              ey(k, j, i) = ((DBLE(i - 1) * DBLE(j + 3)) + DBLE(k - 1) + &
                             2.0D0) / DBLE(cym)
              hz(k, j, i) = ((DBLE(i - 1) * DBLE(j + 4)) + DBLE(k - 1) + &
                             3.0D0) / DBLE(cz)
            end do
          end do
        end do
        end subroutine


        subroutine print_array(cz, cxm, cym, bza, ex, ey, hz)
        implicit none

        integer :: cz, cxm, cym
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: bza
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: ex
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: ey
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: hz
        integer :: i, j, k

        do i = 1, cz + 1
          do j = 1, cym + 1
            do k = 1, cxm + 1
              write(0, DATA_PRINTF_MODIFIER) bza(k, j, i)
              write(0, DATA_PRINTF_MODIFIER) ex(k, j, i)
              write(0, DATA_PRINTF_MODIFIER) ey(k, j, i)
              write(0, DATA_PRINTF_MODIFIER) hz(k, j, i)
              if (mod(((i - 1) * cxm) + j - 1, 20) == 0) then
                write(0, *)
              end if
            end do
          end do
        end do
        write(0, *)
        end subroutine


        subroutine kernel_fdtd_apml(cz, cxm, cym, mui, ch, &
                               ax, ry, clf, tmp, bza, ex, ey, &
                               hz, czm, czp, cxmh, cxph, cymh, cyph)
        implicit none
        integer :: cz, cym, cxm
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: ex
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: ey
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: hz
        DATA_TYPE, dimension(cym + 1, cz + 1) :: clf
        DATA_TYPE, dimension(cym + 1, cz + 1) :: ry
        DATA_TYPE, dimension(cym + 1, cz + 1) :: ax
        DATA_TYPE, dimension(cym + 1) :: cymh
        DATA_TYPE, dimension(cym + 1) :: cyph
        DATA_TYPE, dimension(cxm + 1) :: cxmh
        DATA_TYPE, dimension(cxm + 1) :: cxph
        DATA_TYPE, dimension(cz + 1) :: czm
        DATA_TYPE, dimension(cz + 1) :: czp
        DATA_TYPE, dimension(cxm + 1, cym + 1) :: tmp
        DATA_TYPE, dimension(cxm + 1, cym + 1, cz + 1) :: bza
        DATA_TYPE :: mui, ch
        integer :: ix, iy, iz

!$pragma scop
        do iz = 1, _PB_CZ
          do iy = 1, _PB_CYM 
            do ix = 1, _PB_CXM 
              clf(iy, iz) = ex(ix, iy, iz) - ex(ix, iy + 1, iz) + &
                            ey(ix + 1, iy, iz) - ey(ix, iy, iz)
              tmp(iy, iz) = ((cymh(iy) / cyph(iy)) * bza(ix, iy, iz)) - &
                            ((ch / cyph(iy)) * clf(iy, iz))
              hz(ix, iy, iz) = ((cxmh(ix) / cxph(ix)) * hz(ix, iy, iz)) &
                            + ((mui * czp(iz) / cxph(ix)) * tmp(iy, iz)) &
                               - ((mui * czm(iz) / cxph(ix)) * &
                                  bza(ix, iy, iz))
              bza(ix, iy, iz) = tmp(iy, iz)
            end do
            clf(iy, iz) = ex(_PB_CXM + 1, iy, iz) - &
                          ex(_PB_CXM + 1, iy + 1, iz) + &
                          ry(iy, iz) - ey(_PB_CXM + 1, iy, iz)
            tmp(iy, iz) = ((cymh(iy) / cyph(iy)) * &
                           bza(_PB_CXM + 1, iy, iz)) - ((ch / cyph(iy))  &
                           * clf(iy, iz))
            hz(_PB_CXM + 1, iy, iz) = ((cxmh(_PB_CXM + 1) / &
                                         cxph(_PB_CXM + 1)) * &
                                        hz(_PB_CXM + 1, iy, iz)) + &
                                       ((mui * czp(iz) / &
                                        cxph(_PB_CXM + 1)) * &
                                        tmp(iy, iz)) - &
                                       ((mui * czm(iz) / &
                                        cxph(_PB_CXM + 1)) * &
                                        bza(_PB_CXM + 1, iy, iz))
            bza(_PB_CXM + 1, iy, iz) = tmp(iy, iz)

          do ix = 1, _PB_CXM 
            clf(iy, iz) = ex(ix, _PB_CYM + 1, iz) - ax(ix, iz) + &
                          ey(ix + 1, _PB_CYM + 1, iz) - &
                          ey(ix, _PB_CYM + 1, iz)
            tmp(iy, iz) = ((cymh(_PB_CYM + 1) / cyph(iy)) * &
                           bza(ix, iy, iz)) - ((ch / cyph(iy)) * &
                           clf(iy, iz))
            hz(ix, _PB_CYM + 1, iz) = ((cxmh(ix) / cxph(ix)) * &
                                        hz(ix, _PB_CYM + 1, iz)) + &
                                       ((mui * czp(iz) / cxph(ix)) * &
                                        tmp(iy, iz)) - &
                                       ((mui * czm(iz) / cxph(ix)) * &
                                        bza(ix, _PB_CYM + 1, iz))
            bza(ix, _PB_CYM + 1, iz) = tmp(iy, iz)
          end do
          clf(iy, iz) = ex(_PB_CXM + 1, _PB_CYM + 1, iz) - &
                        ax(_PB_CXM + 1, iz) + ry(_PB_CYM + 1, iz) - &
                        ey(_PB_CXM + 1, _PB_CYM + 1, iz)
          tmp(iy, iz) = ((cymh(_PB_CYM + 1) / cyph(_PB_CYM + 1)) * &
                         bza(_PB_CXM + 1, _PB_CYM + 1, iz)) - &
                         ((ch / cyph(_PB_CYM + 1)) * clf(iy, iz))
          hz(_PB_CXM + 1, _PB_CYM + 1, iz) = &
            ((cxmh(_PB_CXM + 1) / cxph(_PB_CXM + 1)) * &
             hz(_PB_CXM + 1, _PB_CYM + 1, iz)) + &
             ((mui * czp(iz) / cxph(_PB_CXM + 1)) * tmp(iy, iz)) - &
             ((mui * czm(iz) / cxph(_PB_CXM + 1)) * &
              bza(_PB_CXM + 1, _PB_CYM + 1, iz))
          bza(_PB_CXM + 1, _PB_CYM + 1, iz) = tmp(iy, iz)
          end do
        end do

!$pragma endscop
        end subroutine

      end program
