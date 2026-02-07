/PROG VIS_CALC_OFFSET
/ATTR
OWNER       = MNEDITOR;
COMMENT     = "Calculate Pick Offset from Vision";
PROG_SIZE   = 1024;
CREATE      = DATE 25-01-22 TIME 14:00:00;
MODIFIED    = DATE 25-05-15 TIME 09:20:00;
FILE_NAME   = VIS_CALC_OFFSET;
VERSION     = 1;
LINE_COUNT  = 55;
MEMORY_SIZE = 1536;
PROTECT     = READ_WRITE;
/MN
   1:  !================================ ;
   2:  ! CALCULATE PICK OFFSET          ;
   3:  ! Applies vision offsets to      ;
   4:  ! reference pick position        ;
   5:  ! Author: Barath Kumar JK        ;
   6:  !================================ ;
   7:   ;
   8:  !-------------------------------- ;
   9:  ! START WITH REFERENCE POSITION  ;
  10:  !-------------------------------- ;
  11:   ;
  12:  ! Copy reference pick position to PR[1] ;
  13:  PR[1:Pick_Offset]=P[3:PICK_POS] ;
  14:   ;
  15:  !-------------------------------- ;
  16:  ! APPLY X OFFSET                 ;
  17:  !-------------------------------- ;
  18:   ;
  19:  ! Add vision X offset (mm) ;
  20:  PR[1,1:Pick_Offset]=PR[1,1:Pick_Offset]+R[22:Vis_X_Offset] ;
  21:   ;
  22:  !-------------------------------- ;
  23:  ! APPLY Y OFFSET                 ;
  24:  !-------------------------------- ;
  25:   ;
  26:  ! Add vision Y offset (mm) ;
  27:  PR[1,2:Pick_Offset]=PR[1,2:Pick_Offset]+R[23:Vis_Y_Offset] ;
  28:   ;
  29:  !-------------------------------- ;
  30:  ! APPLY ROTATION OFFSET          ;
  31:  !-------------------------------- ;
  32:   ;
  33:  ! Add rotation offset to R (W, P, R = X, Y, Z rotation) ;
  34:  ! R[24] is rotation about Z axis ;
  35:  PR[1,6:Pick_Offset]=PR[1,6:Pick_Offset]+R[24:Vis_R_Offset] ;
  36:   ;
  37:  !-------------------------------- ;
  38:  ! APPLY FIXED OFFSETS (GRIPPER)  ;
  39:  !-------------------------------- ;
  40:   ;
  41:  ! Apply any fixed gripper offsets ;
  42:  ! These compensate for TCP errors ;
  43:  PR[1,1:Pick_Offset]=PR[1,1:Pick_Offset]+R[30:X_Fixed_Off] ;
  44:  PR[1,2:Pick_Offset]=PR[1,2:Pick_Offset]+R[31:Y_Fixed_Off] ;
  45:   ;
  46:  !-------------------------------- ;
  47:  ! LOG FINAL POSITION             ;
  48:  !-------------------------------- ;
  49:   ;
  50:  ! Store final offsets for logging ;
  51:  R[40:Final_X]=PR[1,1:Pick_Offset] ;
  52:  R[41:Final_Y]=PR[1,2:Pick_Offset] ;
  53:  R[42:Final_R]=PR[1,6:Pick_Offset] ;
  54:   ;
/POS
P[3:PICK_POS]{
   GP1:
    UF : 1, UT : 1,     CONFIG : 'N U T, 0, 0, 0',
    X =   350.000 mm, Y =     0.000 mm, Z =    25.000 mm,
    W =   180.000 deg, P =    0.000 deg, R =    0.000 deg
};
/END
