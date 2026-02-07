/PROG VIS_SNAP
/ATTR
OWNER       = MNEDITOR;
COMMENT     = "Trigger Camera Snapshot";
PROG_SIZE   = 512;
CREATE      = DATE 25-01-18 TIME 08:00:00;
MODIFIED    = DATE 25-05-10 TIME 09:00:00;
FILE_NAME   = VIS_SNAP;
VERSION     = 1;
LINE_COUNT  = 25;
MEMORY_SIZE = 768;
PROTECT     = READ_WRITE;
/MN
   1:  !================================ ;
   2:  ! TRIGGER CAMERA SNAPSHOT        ;
   3:  ! For manual testing/debugging   ;
   4:  ! Author: Barath Kumar JK        ;
   5:  !================================ ;
   6:   ;
   7:  ! Turn on vision light ;
   8:  DO[11:Vision_Light]=ON ;
   9:   ;
  10:  ! Wait for light to stabilize ;
  11:  WAIT .15(sec) ;
  12:   ;
  13:  ! Trigger snapshot ;
  14:  VISION SNAP 'PART_LOCATE' ;
  15:   ;
  16:  ! Wait for image acquisition ;
  17:  WAIT .1(sec) ;
  18:   ;
  19:  ! Turn off light ;
  20:  DO[11:Vision_Light]=OFF ;
  21:   ;
  22:  ! Display message ;
  23:  MESSAGE[Snapshot acquired] ;
  24:   ;
/END
