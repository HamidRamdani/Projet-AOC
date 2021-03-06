
!---------------------------------------------------------------------
!---------------------------------------------------------------------

      subroutine subdomain(nx1, ny1, nz1, nx)

!---------------------------------------------------------------------
!---------------------------------------------------------------------

      use lu_data
      use mpinpb

      implicit none

      integer nx1, ny1, nz1, nx

!---------------------------------------------------------------------
!  local variables
!---------------------------------------------------------------------
      integer mm, errorcode


!---------------------------------------------------------------------
!
!   set up the sub-domain sizes
!
!---------------------------------------------------------------------

!---------------------------------------------------------------------
!   original dimensions
!---------------------------------------------------------------------
      nx0 = nx1
      ny0 = ny1
      nz0 = nz1

!---------------------------------------------------------------------
!   x dimension
!---------------------------------------------------------------------
      mm   = mod(nx0,xdim)
      if (row.lt.mm) then
        nx = nx0/xdim + 1
        ipt = row*nx
      else
        nx = nx0/xdim
        ipt = row*nx + mm
      end if

!---------------------------------------------------------------------
!   check the sub-domain size
!---------------------------------------------------------------------
      if ( nx .lt. 3 ) then
         if (myid .eq. root) write (*,2001) nx, ny0, nz0
 2001    format (5x,'SUBDOMAIN SIZE IS TOO SMALL - ',  &
     &        /5x,'ADJUST PROBLEM SIZE OR NUMBER OF PROCESSORS',  &
     &        /5x,'SO THAT NX, NY AND NZ ARE GREATER THAN OR EQUAL',  &
     &        /5x,'TO 3 THEY ARE CURRENTLY', 3I5)
         call error_cond( 0, ' ' )
      end if


!---------------------------------------------------------------------
!   set up the start and end in i extent for all processors
!---------------------------------------------------------------------
      ist = 1
      iend = nx
      if (north.eq.-1) ist = 2
      if (south.eq.-1) iend = nx - 1

      return
      end


