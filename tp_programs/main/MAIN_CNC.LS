/PROG MAIN_CNC
/ATTR
OWNER       = MNEDITOR;
COMMENT     = "Main CNC Vision Pick-Place Cycle";
PROG_SIZE   = 3072;
CREATE      = DATE 25-01-15 TIME 10:30:00;
MODIFIED    = DATE 25-05-20 TIME 14:45:00;
FILE_NAME   = MAIN_CNC;
VERSION     = 1;
LINE_COUNT  = 145;
MEMORY_SIZE = 4096;
PROTECT     = READ_WRITE;
TCD:  STACK_SIZE = 0,
      TASK_PRIORITY = 50,
      TIME_SLICE = 0,
      BUSY_LAMP_OFF = 0,
      ABORT_REQUEST = 0,
      PAUSE_REQUEST = 0;
DEFAULT_GROUP = 1,*,*,*,*;
/MN
   1:  !================================ ;
   2:  ! MAIN CNC VISION PICK-PLACE     ;
   3:  ! FANUC LR Mate 200iC + iRVision ;
   4:  ! Author: Barath Kumar JK        ;
   5:  ! Date: Jan-May 2025             ;
   6:  !================================ ;
   7:   ;
   8:  !-------------------------------- ;
   9:  ! INITIALIZATION                  ;
  10:  !-------------------------------- ;
  11:  R[1:Cycle_Count]=0 ;
  12:  R[2:Good_Parts]=0 ;
  13:  R[3:Vision_Fails]=0 ;
  14:  R[4:Total_Retries]=0 ;
  15:  R[10:Retry_Count]=0 ;
  16:  R[50:Cycle_Time]=0 ;
  17:   ;
  18:  ! Set user frames ;
  19:  UFRAME_NUM=1 ;
  20:  UTOOL_NUM=1 ;
  21:   ;
  22:  ! Turn on status light ;
  23:  DO[21:Run_Light]=ON ;
  24:  DO[20:Alarm_Light]=OFF ;
  25:   ;
  26:  ! Move to home position ;
  27:  J P[10:HOME] 50% FINE ;
  28:   ;
  29:  !-------------------------------- ;
  30:  ! MAIN CYCLE LOOP                 ;
  31:  !-------------------------------- ;
  32:  LBL[1:CYCLE_START] ;
  33:   ;
  34:  ! Start cycle timer ;
  35:  TIMER[1]=START ;
  36:   ;
  37:  ! Reset retry counter ;
  38:  R[10:Retry_Count]=0 ;
  39:   ;
  40:  !................................ ;
  41:  ! WAIT FOR PART                   ;
  42:  !................................ ;
  43:  LBL[5:WAIT_PART] ;
  44:  WAIT DI[1:Part_Sensor]=ON TIMEOUT,LBL[5] ;
  45:   ;
  46:  ! Small delay for part to settle ;
  47:  WAIT .3(sec) ;
  48:   ;
  49:  !................................ ;
  50:  ! VISION SEQUENCE                 ;
  51:  !................................ ;
  52:  LBL[10:VISION_SEQ] ;
  53:   ;
  54:  ! Move to vision position ;
  55:  J P[1:VISION_POS] 100% FINE ;
  56:   ;
  57:  ! Turn on vision lighting ;
  58:  DO[11:Vision_Light]=ON ;
  59:  WAIT .1(sec) ;
  60:   ;
  61:  ! Run vision locate ;
  62:  CALL VIS_LOCATE ;
  63:   ;
  64:  ! Turn off vision light ;
  65:  DO[11:Vision_Light]=OFF ;
  66:   ;
  67:  ! Check vision result ;
  68:  IF R[20:Vision_Found]=0,JMP LBL[100] ;
  69:   ;
  70:  !................................ ;
  71:  ! PICK SEQUENCE                   ;
  72:  !................................ ;
  73:   ;
  74:  ! Calculate pick position with offset ;
  75:  CALL VIS_CALC_OFFSET ;
  76:   ;
  77:  ! Approach pick position ;
  78:  L P[2:PICK_APPROACH] 500mm/sec FINE ;
  79:   ;
  80:  ! Move to pick with vision offset ;
  81:  L PR[1:Pick_Offset] 100mm/sec FINE ;
  82:   ;
  83:  ! Close gripper ;
  84:  DO[1:Gripper]=ON ;
  85:  WAIT DI[2:Gripper_Closed]=ON+TIMEOUT,LBL[110] ;
  86:   ;
  87:  ! Verify grip (optional force check) ;
  88:  WAIT .2(sec) ;
  89:   ;
  90:  ! Retract from pick ;
  91:  L P[2:PICK_APPROACH] 500mm/sec FINE ;
  92:   ;
  93:  !................................ ;
  94:  ! PLACE IN CNC SEQUENCE           ;
  95:  !................................ ;
  96:   ;
  97:  ! Switch to CNC user frame ;
  98:  UFRAME_NUM=2 ;
  99:   ;
 100:  ! Move to CNC approach ;
 101:  J P[5:CNC_APPROACH] 100% FINE ;
 102:   ;
 103:  ! Wait for CNC door open and ready ;
 104:  WAIT DI[5:CNC_Ready]=ON TIMEOUT,LBL[120] ;
 105:   ;
 106:  ! Enter CNC and place part ;
 107:  L P[6:CNC_PLACE] 200mm/sec FINE ;
 108:   ;
 109:  ! Open gripper ;
 110:  DO[1:Gripper]=OFF ;
 111:  WAIT DI[3:Gripper_Open]=ON+TIMEOUT,LBL[110] ;
 112:   ;
 113:  ! Small settle time ;
 114:  WAIT .15(sec) ;
 115:   ;
 116:  ! Retract from CNC ;
 117:  L P[5:CNC_APPROACH] 500mm/sec FINE ;
 118:   ;
 119:  ! Signal CNC to start cycle ;
 120:  DO[10:CNC_Start]=PULSE,0.5sec ;
 121:   ;
 122:  !................................ ;
 123:  ! CYCLE COMPLETE                  ;
 124:  !................................ ;
 125:   ;
 126:  ! Stop timer and record ;
 127:  TIMER[1]=STOP ;
 128:  R[50:Cycle_Time]=TIMER[1]MS ;
 129:   ;
 130:  ! Update counters ;
 131:  R[1:Cycle_Count]=R[1:Cycle_Count]+1 ;
 132:  R[2:Good_Parts]=R[2:Good_Parts]+1 ;
 133:   ;
 134:  ! Log cycle data ;
 135:  CALL UTIL_LOG ;
 136:   ;
 137:  ! Switch back to conveyor frame ;
 138:  UFRAME_NUM=1 ;
 139:   ;
 140:  ! Return to home ;
 141:  J P[10:HOME] 50% FINE ;
 142:   ;
 143:  ! Loop to next cycle ;
 144:  JMP LBL[1] ;
 145:   ;
 146:  !================================ ;
 147:  ! ERROR HANDLING LABELS           ;
 148:  !================================ ;
 149:   ;
 150:  !-------------------------------- ;
 151:  ! LBL 100: Vision Detection Fail  ;
 152:  !-------------------------------- ;
 153:  LBL[100:VISION_FAIL] ;
 154:  R[3:Vision_Fails]=R[3:Vision_Fails]+1 ;
 155:  R[10:Retry_Count]=R[10:Retry_Count]+1 ;
 156:  R[4:Total_Retries]=R[4:Total_Retries]+1 ;
 157:   ;
 158:  ! Check retry limit ;
 159:  IF R[10:Retry_Count]>=3,JMP LBL[105] ;
 160:   ;
 161:  ! Retry with small jog ;
 162:  CALL ERR_RETRY ;
 163:  JMP LBL[10] ;
 164:   ;
 165:  LBL[105:MAX_RETRIES] ;
 166:  ! Max retries exceeded - alarm ;
 167:  CALL ERR_ALARM(1) ;
 168:  PAUSE ;
 169:  JMP LBL[1] ;
 170:   ;
 171:  !-------------------------------- ;
 172:  ! LBL 110: Gripper Timeout        ;
 173:  !-------------------------------- ;
 174:  LBL[110:GRIPPER_FAIL] ;
 175:  CALL ERR_ALARM(2) ;
 176:  PAUSE ;
 177:  JMP LBL[1] ;
 178:   ;
 179:  !-------------------------------- ;
 180:  ! LBL 120: CNC Not Ready Timeout  ;
 181:  !-------------------------------- ;
 182:  LBL[120:CNC_TIMEOUT] ;
 183:  CALL ERR_ALARM(3) ;
 184:  PAUSE ;
 185:  JMP LBL[1] ;
 186:   ;
/POS
P[1:VISION_POS]{
   GP1:
    UF : 1, UT : 1,
    J1=    0.000 deg, J2=   -30.000 deg, J3=   30.000 deg,
    J4=    0.000 deg, J5=  -45.000 deg, J6=    0.000 deg
};
P[2:PICK_APPROACH]{
   GP1:
    UF : 1, UT : 1,     CONFIG : 'N U T, 0, 0, 0',
    X =   350.000 mm, Y =     0.000 mm, Z =   150.000 mm,
    W =   180.000 deg, P =    0.000 deg, R =    0.000 deg
};
P[3:PICK_POS]{
   GP1:
    UF : 1, UT : 1,     CONFIG : 'N U T, 0, 0, 0',
    X =   350.000 mm, Y =     0.000 mm, Z =    25.000 mm,
    W =   180.000 deg, P =    0.000 deg, R =    0.000 deg
};
P[5:CNC_APPROACH]{
   GP1:
    UF : 2, UT : 1,     CONFIG : 'N U T, 0, 0, 0',
    X =   400.000 mm, Y =   200.000 mm, Z =   200.000 mm,
    W =   180.000 deg, P =    0.000 deg, R =    0.000 deg
};
P[6:CNC_PLACE]{
   GP1:
    UF : 2, UT : 1,     CONFIG : 'N U T, 0, 0, 0',
    X =   400.000 mm, Y =   200.000 mm, Z =    50.000 mm,
    W =   180.000 deg, P =    0.000 deg, R =    0.000 deg
};
P[10:HOME]{
   GP1:
    UF : 0, UT : 1,
    J1=    0.000 deg, J2=    0.000 deg, J3=    0.000 deg,
    J4=    0.000 deg, J5=  -90.000 deg, J6=    0.000 deg
};
/END
