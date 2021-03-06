       subroutine zone_setup(nx, nxmax, ny, nz)

       use bt_data
       use ompnpb

       implicit none

       integer nx(*), nxmax(*), ny(*), nz(*)

       integer           i,  j, zone_no
       integer           id_west, id_east, jd_south, jd_north
       double precision  x_r, y_r, x_smallest, y_smallest

       if (dabs(ratio-1.d0) .gt. 1.d-10) then

!        compute zone stretching only if the prescribed zone size ratio 
!        is substantially larger than unity       

         x_r   = dexp(dlog(ratio)/(x_zones-1))
         y_r   = dexp(dlog(ratio)/(y_zones-1))
         x_smallest = dble(gx_size)*(x_r-1.d0)/(x_r**x_zones-1.d0)
         y_smallest = dble(gy_size)*(y_r-1.d0)/(y_r**y_zones-1.d0)

!        compute tops of intervals, using a slightly tricked rounding
!        to make sure that the intervals are increasing monotonically
!        in size

         do i = 1, x_zones
            x_end(i) = x_smallest*(x_r**i-1.d0)/(x_r-1.d0)+0.45d0
         end do

         do j = 1, y_zones
            y_end(j) = y_smallest*(y_r**j-1.d0)/(y_r-1.d0)+0.45d0
         end do
 
       else

!        compute essentially equal sized zone dimensions

         do i = 1, x_zones
           x_end(i)   = (i*gx_size)/x_zones
         end do

         do j = 1, y_zones
           y_end(j)   = (j*gy_size)/y_zones
         end do

       endif

       x_start(1) = 1
       do i = 1, x_zones
          if (i .ne. x_zones) x_start(i+1) = x_end(i) + 1
          x_size(i)  = x_end(i) - x_start(i) + 1
       end do

       y_start(1) = 1
       do j = 1, y_zones
          if (j .ne. y_zones) y_start(j+1) = y_end(j) + 1
          y_size(j) = y_end(j) - y_start(j) + 1
       end do

       if (npb_verbose .gt. 1) write (*,98)
 98    format(/' Zone sizes:')

       do j = 1, y_zones
         do i = 1, x_zones
           zone_no = (i-1)+(j-1)*x_zones+1
           nx(zone_no) = x_size(i)
           nxmax(zone_no) = nx(zone_no) + 1 - mod(nx(zone_no),2)
           ny(zone_no) = y_size(j)
           nz(zone_no) = gz_size

           id_west  = mod(i-2+x_zones,x_zones)
           id_east  = mod(i,          x_zones)
           jd_south = mod(j-2+y_zones,y_zones)
           jd_north = mod(j,          y_zones)
           iz_west (zone_no) = id_west +  (j-1)*x_zones + 1
           iz_east (zone_no) = id_east +  (j-1)*x_zones + 1
           iz_south(zone_no) = (i-1) + jd_south*x_zones + 1
           iz_north(zone_no) = (i-1) + jd_north*x_zones + 1

           if (npb_verbose .gt. 1) then
             write (*,99) zone_no, nx(zone_no), ny(zone_no),  &
     &                    nz(zone_no)
           endif
         end do
       end do

 99    format(i5,':  ',i5,' x',i5,' x',i5)

       return
       end


       subroutine zone_starts(num_zones, nx, nxmax, ny, nz)

       use bt_data
       use ompnpb

       implicit none

       integer   num_zones
       integer   nx(*), nxmax(*), ny(*), nz(*)

       integer   zone, zone_size
       integer   x_face_size, y_face_size

! ... index start for u & qbc
       do zone = 1, num_zones
          zone_size = nxmax(zone)*ny(zone)*nz(zone)
          x_face_size = (ny(zone)-2)*(nz(zone)-2)*5
          y_face_size = (nx(zone)-2)*(nz(zone)-2)*5

          if (zone .eq. 1) then
             qstart_west(zone) = 1
             start1(zone) = 1
             start5(zone) = 1
          endif
          qstart_east(zone)  = qstart_west(zone) + x_face_size
          qstart_south(zone) = qstart_east(zone) + x_face_size
          qstart_north(zone) = qstart_south(zone)+ y_face_size
          if (zone .ne. num_zones) then
             qstart_west(zone+1) = qstart_north(zone) +  &
     &                             y_face_size
             start1(zone+1) = start1(zone) + zone_size
             start5(zone+1) = start5(zone) + zone_size*5
          else
             if (start1(zone)+zone_size-1 .gt. proc_max_size) then
                write(*,50) zone,proc_max_size,start1(zone)+zone_size-1
                stop
             endif
          endif
   50     format(' Error in size: zone',i5,' proc_max_size',i10,  &
     &          ' access_size',i10)
       enddo

       if (npb_verbose .gt. 1) then
          do zone = 1, num_zones
             write(*,10) zone,start1(zone),start5(zone)
          enddo
       endif
   10  format(' zone=',i5,' start1=',i10,' start5=',i10)

       return
       end
