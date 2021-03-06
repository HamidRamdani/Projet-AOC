
!---------------------------------------------------------------------
!---------------------------------------------------------------------

        subroutine verify(no_time_steps, verified, num_zones,  &
     &                    rho_i, us, vs, ws, qs, square,  &
     &                    rhs, forcing, u, nx, nxmax, ny, nz,  &
     &                    proc_zone_id, proc_num_zones)

!---------------------------------------------------------------------
!---------------------------------------------------------------------

!---------------------------------------------------------------------
!  verification routine                         
!---------------------------------------------------------------------

        use, intrinsic :: ieee_arithmetic, only : ieee_is_nan

        use bt_data
        use ompnpb

        implicit none

        integer zone, num_zones
        double precision rho_i(*), us(*), vs(*), ws(*), qs(*),  &
     &                   square(*), rhs(*), forcing(*), u(*)

        double precision xcrref(5),xceref(5),xcrdif(5),xcedif(5),  &
     &                   epsilon, xce(5), xcr(5), dtref,  &
     &                   xce_sub(5), xcr_sub(5)
        integer m, no_time_steps, niterref, iz, nthreads
        integer nx(*), nxmax(*), ny(*), nz(*),  &
     &          proc_zone_id(*), proc_num_zones
        logical verified
        save xce, xcr

!---------------------------------------------------------------------
!   tolerance level
!---------------------------------------------------------------------
        epsilon = 1.0d-08

!$omp master
        do m = 1, 5
          xcr(m) = 0.d0
          xce(m) = 0.d0
        end do
!$omp end master
!$omp barrier

!---------------------------------------------------------------------
!   compute the error norm and the residual norm, and exit if not printing
!---------------------------------------------------------------------

        do iz = 1, proc_num_zones
          zone = proc_zone_id(iz)
          call error_norm (xce_sub, u(start5(zone)),  &
     &                     nx(zone), nxmax(zone), ny(zone), nz(zone))
          call compute_rhs(rho_i(start1(zone)), us(start1(zone)),  &
     &                     vs(start1(zone)), ws(start1(zone)),  &
     &                     qs(start1(zone)), square(start1(zone)),  &
     &                     rhs(start5(zone)), forcing(start5(zone)),  &
     &                     u(start5(zone)),  &
     &                     nx(zone), nxmax(zone), ny(zone), nz(zone)) 

          call rhs_norm   (xcr_sub, rhs(start5(zone)),  &
     &                     nx(zone), nxmax(zone), ny(zone), nz(zone))

          do m = 1, 5
!$omp atomic
            xcr(m) = xcr(m) + xcr_sub(m) / dt 
!$omp atomic
            xce(m) = xce(m) + xce_sub(m)
          end do
        end do

!$omp barrier

!$omp master
        verified = .true.

        do m = 1,5
           xcrref(m) = 1.0
           xceref(m) = 1.0
        end do

!---------------------------------------------------------------------
!    reference data for class S
!---------------------------------------------------------------------
        if ( class .eq. 'S' ) then
           dtref = 1.0d-2
           niterref = 60

!---------------------------------------------------------------------
!  Reference values of RMS-norms of residual.
!---------------------------------------------------------------------
           xcrref(1) = 0.1047687395830d+04
           xcrref(2) = 0.9419911314792d+02
           xcrref(3) = 0.2124737403068d+03
           xcrref(4) = 0.1422173591794d+03
           xcrref(5) = 0.1135441572375d+04

!---------------------------------------------------------------------
!  Reference values of RMS-norms of solution error.
!---------------------------------------------------------------------
           xceref(1) = 0.1775416062982d+03
           xceref(2) = 0.1875540250835d+02
           xceref(3) = 0.3863334844506d+02
           xceref(4) = 0.2634713890362d+02
           xceref(5) = 0.1965566269675d+03

!---------------------------------------------------------------------
!    reference data for class W
!---------------------------------------------------------------------
        elseif ( class .eq. 'W' ) then
           dtref = 0.8d-3
           niterref = 200

!---------------------------------------------------------------------
!  Reference values of RMS-norms of residual.
!---------------------------------------------------------------------
           xcrref(1) = 0.5562611195402d+05
           xcrref(2) = 0.5151404119932d+04
           xcrref(3) = 0.1080453907954d+05
           xcrref(4) = 0.6576058591929d+04
           xcrref(5) = 0.4528609293561d+05

!---------------------------------------------------------------------
!  Reference values of RMS-norms of solution error.
!---------------------------------------------------------------------
           xceref(1) = 0.7185154786403d+04
           xceref(2) = 0.7040472738068d+03
           xceref(3) = 0.1437035074443d+04
           xceref(4) = 0.8570666307849d+03
           xceref(5) = 0.5991235147368d+04

!---------------------------------------------------------------------
!    reference data for class A
!---------------------------------------------------------------------
        elseif ( class .eq. 'A' ) then
           dtref = 0.8d-3
           niterref = 200

!---------------------------------------------------------------------
!  Reference values of RMS-norms of residual.
!---------------------------------------------------------------------
           xcrref(1) = 0.5536703889522d+05
           xcrref(2) = 0.5077835038405d+04
           xcrref(3) = 0.1067391361067d+05
           xcrref(4) = 0.6441179694972d+04
           xcrref(5) = 0.4371926324069d+05

!---------------------------------------------------------------------
!  Reference values of RMS-norms of solution error.
!---------------------------------------------------------------------
           xceref(1) = 0.6716797714343d+04
           xceref(2) = 0.6512687902160d+03
           xceref(3) = 0.1332930740128d+04
           xceref(4) = 0.7848302089180d+03
           xceref(5) = 0.5429053878818d+04

!---------------------------------------------------------------------
!    reference data for class B
!---------------------------------------------------------------------
        elseif ( class .eq. 'B' ) then
           dtref = 3.0d-4
           niterref = 200

!---------------------------------------------------------------------
!  Reference values of RMS-norms of residual.
!---------------------------------------------------------------------
           xcrref(1) = 0.4461388343844d+06
           xcrref(2) = 0.3799759138035d+05
           xcrref(3) = 0.8383296623970d+05
           xcrref(4) = 0.5301970201273d+05
           xcrref(5) = 0.3618106851311d+06

!---------------------------------------------------------------------
!  Reference values of RMS-norms of solution error.
!---------------------------------------------------------------------
           xceref(1) = 0.4496733567600d+05
           xceref(2) = 0.3892068540524d+04
           xceref(3) = 0.8763825844217d+04
           xceref(4) = 0.5599040091792d+04
           xceref(5) = 0.4082652045598d+05

!---------------------------------------------------------------------
!    reference data class C
!---------------------------------------------------------------------
        elseif ( class .eq. 'C' ) then
           dtref = 1.0d-4
           niterref = 200

!---------------------------------------------------------------------
!  Reference values of RMS-norms of residual.
!---------------------------------------------------------------------
           xcrref(1) = 0.3457703287806d+07
           xcrref(2) = 0.3213621375929d+06
           xcrref(3) = 0.7002579656870d+06
           xcrref(4) = 0.4517459627471d+06
           xcrref(5) = 0.2818715870791d+07

!---------------------------------------------------------------------
!  Reference values of RMS-norms of solution error.
!---------------------------------------------------------------------
           xceref(1) = 0.2059106993570d+06
           xceref(2) = 0.1680761129461d+05
           xceref(3) = 0.4080731640795d+05
           xceref(4) = 0.2836541076778d+05
           xceref(5) = 0.2136807610771d+06

!---------------------------------------------------------------------
!    reference data class D
!---------------------------------------------------------------------
        elseif ( class .eq. 'D' ) then
           dtref = 2.0d-5
           niterref = 250

!---------------------------------------------------------------------
!  Reference values of RMS-norms of residual.
!---------------------------------------------------------------------
           xcrref(1) = 0.4250417034981d+08
           xcrref(2) = 0.4293882192175d+07
           xcrref(3) = 0.9121841878270d+07
           xcrref(4) = 0.6201357771439d+07
           xcrref(5) = 0.3474801891304d+08

!---------------------------------------------------------------------
!  Reference values of RMS-norms of solution error.
!---------------------------------------------------------------------
           xceref(1) = 0.9462418484583d+06
           xceref(2) = 0.7884728947105d+05
           xceref(3) = 0.1902874461259d+06
           xceref(4) = 0.1361858029909d+06
           xceref(5) = 0.9816489456253d+06

!---------------------------------------------------------------------
!    reference data class E
!---------------------------------------------------------------------
        elseif ( class .eq. 'E' ) then
           dtref = 4.0d-6
           niterref = 250

!---------------------------------------------------------------------
!  Reference values of RMS-norms of residual.
!---------------------------------------------------------------------
           xcrref(1) = 0.5744815962469d+09
           xcrref(2) = 0.6088696479719d+08
           xcrref(3) = 0.1276325224438d+09
           xcrref(4) = 0.8947040105616d+08
           xcrref(5) = 0.4726115284807d+09

!---------------------------------------------------------------------
!  Reference values of RMS-norms of solution error.
!---------------------------------------------------------------------
           xceref(1) = 0.4114447054461d+07
           xceref(2) = 0.3570776728190d+06
           xceref(3) = 0.8465106191458d+06
           xceref(4) = 0.6147182273817d+06
           xceref(5) = 0.4238908025163d+07

!---------------------------------------------------------------------
!    reference data class F
!---------------------------------------------------------------------
        elseif ( class .eq. 'F' ) then
           dtref = 1.0d-6
           niterref = 250

!---------------------------------------------------------------------
!  Reference values of RMS-norms of residual.
!---------------------------------------------------------------------
           xcrref(1) = 0.6524078317845d+10
           xcrref(2) = 0.7020439279514d+09
           xcrref(3) = 0.1467588422194d+10
           xcrref(4) = 0.1042973064137d+10
           xcrref(5) = 0.5411102201141d+10

!---------------------------------------------------------------------
!  Reference values of RMS-norms of solution error.
!---------------------------------------------------------------------
           xceref(1) = 0.1708795375347d+08
           xceref(2) = 0.1514359936802d+07
           xceref(3) = 0.3552878359250d+07
           xceref(4) = 0.2594549582184d+07
           xceref(5) = 0.1749809607845d+08

           if (no_time_steps .eq. 25) then

           niterref = 25
           xcrref(1) = 0.3565049484400d+11
           xcrref(2) = 0.3752029586145d+10
           xcrref(3) = 0.7805935552197d+10
           xcrref(4) = 0.5685995438056d+10
           xcrref(5) = 0.2908811276266d+11

           xceref(1) = 0.1805995755490d+08
           xceref(2) = 0.1632306899424d+07
           xceref(3) = 0.3778610439036d+07
           xceref(4) = 0.2749319818549d+07
           xceref(5) = 0.1814401049296d+08

           endif
        else
           dtref = 0.0d0
           niterref = 0
           verified = .false.
        endif

!---------------------------------------------------------------------
!    Compute the difference of solution values and the known reference values.
!---------------------------------------------------------------------
        do m = 1, 5
           
           xcrdif(m) = dabs((xcr(m)-xcrref(m))/xcrref(m)) 
           xcedif(m) = dabs((xce(m)-xceref(m))/xceref(m))
           
        enddo

!---------------------------------------------------------------------
!    Output the comparison of computed results to known cases.
!---------------------------------------------------------------------

        write(*, 1990) class
 1990   format(' Verification being performed for class ', a)
        write (*,2000) epsilon
 2000   format(' accuracy setting for epsilon = ', E20.13)
        if (dabs(dt-dtref) .gt. epsilon) then  
           verified = .false.
           write (*,1000) dtref
 1000      format(' DT does not match the reference value of ',  &
     &              E15.8)
        else if (no_time_steps .ne. niterref) then
           verified = .false.
           write (*,1002) niterref
 1002      format(' NITER does not match the reference value of ',  &
     &              I5)
        endif

        write (*,2001) 

 2001   format(' Comparison of RMS-norms of residual')
        do m = 1, 5
           if ((.not.ieee_is_nan(xcrdif(m))) .and.  &
     &         xcrdif(m) .le. epsilon) then
              write (*,2011) m,xcr(m),xcrref(m),xcrdif(m)
           else 
              verified = .false.
              write (*,2010) m,xcr(m),xcrref(m),xcrdif(m)
           endif
        enddo

        write (*,2002)

 2002   format(' Comparison of RMS-norms of solution error')
        
        do m = 1, 5
           if ((.not.ieee_is_nan(xcedif(m))) .and.  &
     &         xcedif(m) .le. epsilon) then
              write (*,2011) m,xce(m),xceref(m),xcedif(m)
           else
              verified = .false.
              write (*,2010) m,xce(m),xceref(m),xcedif(m)
           endif
        enddo
        
 2010   format(' FAILURE: ', i2, E20.13, E20.13, E20.13)
 2011   format('          ', i2, E20.13, E20.13, E20.13)
        
        if (verified) then
           write(*, 2020)
 2020      format(' Verification Successful')
        else
           write(*, 2021)
 2021      format(' Verification failed')
        endif
!$omp end master

        return


        end
