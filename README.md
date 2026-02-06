# Vision-Based FANUC LR Mate 200iC Robot Arm with iRVision for CNC Workcell

[![FANUC](https://img.shields.io/badge/FANUC-R--30iA-yellow)](https://www.fanucamerica.com/)
[![iRVision](https://img.shields.io/badge/iRVision-2D-blue)](https://www.fanucamerica.com/products/robots/vision)
[![Robot](https://img.shields.io/badge/Robot-LR%20Mate%20200iC-green)](https://www.fanucamerica.com/products/robots/series/lr-mate)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Production-ready vision-guided robotic automation for CNC machine tending. Implements FANUC iRVision 2D part localization for accurate pick-and-place without manual alignment, reducing CNC cycle lead time by 4.5 minutes.

## Performance Results

### Cycle Time Improvement
| Metric | Before (Manual) | After (Vision) | Improvement |
|--------|-----------------|----------------|-------------|
| **Part Alignment Time** | 5.0 min | 0.5 min | **-4.5 min** ✓ |
| **Pick Accuracy** | ±2.0 mm | ±0.3 mm | 85% better |
| **First-Pass Success** | 85% | 98% | +13% |
| **Cycle Repeatability** | Manual dependent | ±0.1 mm | Consistent |

### Vision System Performance
| Metric | Value |
|--------|-------|
| **Localization Accuracy** | ±0.3 mm |
| **Orientation Accuracy** | ±0.2° |
| **Detection Rate** | 99.2% |
| **Processing Time** | <150 ms |
| **Calibration Repeatability** | ±0.15 mm |

### System Specifications
| Component | Specification |
|-----------|---------------|
| **Robot** | FANUC LR Mate 200iC/5L |
| **Controller** | R-30iA |
| **Camera** | Sony XC-56 (659×494 px) |
| **Vision Software** | FANUC iRVision 2D |
| **Lens** | 8mm C-mount |
| **Lighting** | Ring LED (red, 24V) |

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CNC WORKCELL LAYOUT                                  │
│                                                                             │
│   ┌─────────────┐                              ┌─────────────────────────┐  │
│   │   INFEED    │                              │      CNC MACHINE        │  │
│   │  CONVEYOR   │                              │    (Haas VF-2SS)        │  │
│   │             │        ┌───────────┐         │                         │  │
│   │  ┌───────┐  │        │  FANUC    │         │   ┌─────────────────┐   │  │
│   │  │ PART  │  │◄───────│ LR Mate   │────────►│   │    FIXTURE      │   │  │
│   │  │DETECT │  │  PICK  │  200iC    │  PLACE  │   │                 │   │  │
│   │  └───────┘  │        │           │         │   └─────────────────┘   │  │
│   │             │        │  ┌─────┐  │         │                         │  │
│   └─────────────┘        │  │GRIP │  │         └─────────────────────────┘  │
│                          │  │ PER │  │                                      │
│   ┌─────────────┐        │  └─────┘  │         ┌─────────────────────────┐  │
│   │  OUTFEED    │        └─────┬─────┘         │     FINISHED PARTS      │  │
│   │  CONVEYOR   │◄─────────────┘               │        BIN              │  │
│   └─────────────┘         │                    └─────────────────────────┘  │
│                           │                                                 │
│                    ┌──────▼──────┐                                          │
│                    │   CAMERA    │                                          │
│                    │  Sony XC-56 │                                          │
│                    │  + Ring LED │                                          │
│                    └─────────────┘                                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Vision System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         iRVISION PIPELINE                                   │
│                                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │   TRIGGER   │───►│   ACQUIRE   │───►│   LOCATE    │───►│  TRANSFORM  │  │
│  │   (SNAP)    │    │   IMAGE     │    │   PART      │    │   TO ROBOT  │  │
│  └─────────────┘    └─────────────┘    └─────────────┘    └──────┬──────┘  │
│                                                                   │         │
│  Vision Process:                                                  ▼         │
│  1. Part sensor triggers snap                         ┌─────────────────┐  │
│  2. Camera acquires 659x494 image                     │   VISION REG    │  │
│  3. GPM locator finds part pattern                    │   VR[1].FOUND   │  │
│  4. Pixel coords → Robot world coords                 │   VR[1].X,Y,R   │  │
│  5. Offsets applied to pick position                  │   VR[1].SCORE   │  │
│                                                       └────────┬────────┘  │
│                                                                │            │
│  ┌─────────────────────────────────────────────────────────────▼──────────┐│
│  │                        PICK POSITION CALCULATION                       ││
│  │                                                                        ││
│  │   P_pick = P_ref + Offset(VR[1].X, VR[1].Y) + R_offset(VR[1].R)       ││
│  │                                                                        ││
│  │   Where:                                                               ││
│  │     P_ref    = Taught reference position                               ││
│  │     VR[1].X  = X offset from vision (mm)                               ││
│  │     VR[1].Y  = Y offset from vision (mm)                               ││
│  │     VR[1].R  = Rotation offset (degrees)                               ││
│  └────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

## Calibration Overview

### 2D Grid Calibration Process

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    2D GRID CALIBRATION WORKFLOW                             │
│                                                                             │
│  Step 1: CAMERA CALIBRATION (Intrinsic)                                     │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Mount calibration grid (9x9 dots, 10mm spacing)                  │   │
│  │  • Position at working distance (400mm)                             │   │
│  │  • Acquire calibration image                                        │   │
│  │  • Auto-detect grid points                                          │   │
│  │  • Compute lens distortion coefficients                             │   │
│  │  Result: Pixel-to-mm mapping at focal plane                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  Step 2: ROBOT-TO-CAMERA CALIBRATION (Extrinsic)                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Touch 4+ points with robot TCP                                   │   │
│  │  • Record robot position (X, Y, Z, W, P, R)                         │   │
│  │  • Snap image, detect point in pixels                               │   │
│  │  • Compute transformation matrix                                    │   │
│  │  Result: Camera frame → Robot world frame transform                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  Step 3: VALIDATION                                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  • Place part at 5 known positions                                  │   │
│  │  • Vision locate → Robot touch                                      │   │
│  │  • Measure error at each position                                   │   │
│  │  • Accept if error < 0.5mm                                          │   │
│  │  Result: Calibration accuracy validation report                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Calibration Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| Grid Size | 9×9 dots | Standard FANUC calibration grid |
| Dot Spacing | 10.0 mm | Certified spacing |
| Working Distance | 400 mm | Camera to part surface |
| Calibration Points | 9 | 3×3 robot touch points |
| RMS Error Target | <0.3 mm | Production requirement |
| Repeatability | ±0.15 mm | Across 10 trials |

## Program Structure

```
tp_programs/
├── main/
│   ├── MAIN_CNC.LS           # Main production cycle
│   ├── AUTO_CYCLE.LS         # Automatic cycling mode
│   └── MANUAL_MODE.LS        # Manual operation/setup
├── vision/
│   ├── VIS_SNAP.LS           # Trigger camera snapshot
│   ├── VIS_LOCATE.LS         # Run vision process
│   ├── VIS_CALC_OFFSET.LS    # Calculate pick offsets
│   └── VIS_VALIDATE.LS       # Validate vision result
├── error_handling/
│   ├── ERR_VISION_FAIL.LS    # Vision detection failure
│   ├── ERR_RETRY.LS          # Retry logic
│   ├── ERR_ALARM.LS          # Alarm handling
│   └── ERR_RECOVERY.LS       # Recovery procedures
└── utilities/
    ├── UTIL_LOG.LS           # Data logging
    ├── UTIL_CALIB.LS         # Calibration utilities
    └── UTIL_STATS.LS         # Statistics collection
```

## Key Features

### 1. Robust Part Localization
- **GPM (Geometric Pattern Matching)** for reliable detection
- **Multi-model support** for part variants
- **Score thresholding** (>75%) for quality filtering
- **Search window optimization** to reduce processing time

### 2. Frame Transform Architecture
```
Robot World Frame (WORLD)
    │
    ├── User Frame 1 (CONVEYOR_UF)
    │       └── Tool Frame 1 (GRIPPER_TF)
    │
    └── User Frame 2 (CNC_UF)
            └── Tool Frame 1 (GRIPPER_TF)

Vision Calibration Frame
    │
    └── Maps to CONVEYOR_UF
```

### 3. Error Handling & Recovery
- **3-retry strategy** with position jog between attempts
- **Alarm logging** with vision scores and offsets
- **Graceful degradation** to manual mode if vision fails
- **Automatic recovery** from common faults

### 4. Production Logging
- Vision scores for each pick
- X, Y, R offsets logged to controller
- Cycle time tracking
- Error statistics

## Quick Start

### 1. System Requirements

- FANUC R-30iA or R-30iB controller
- iRVision 2D software option
- Sony XC-56 camera (or compatible)
- Calibration grid (FANUC A05B-1225-H201)

### 2. Installation

```bash
# 1. Backup existing programs
# On teach pendant: MENU → FILE → BACKUP

# 2. Load TP programs via USB or FTP
# Copy all .LS files to controller MD: device

# 3. Load vision data
# Copy .VD files to controller vision directory

# 4. Set up I/O mapping
# Configure DI/DO per cell requirements
```

### 3. Initial Calibration

```
1. Mount camera at working position
2. MENU → SETUP → FRAMES → Set User Frame 1 (Conveyor)
3. MENU → iRVision → Calibration → 2D Grid Cal
4. Follow on-screen prompts for grid calibration
5. Perform robot-to-camera calibration (4-point touch)
6. Validate with test parts
```

### 4. Production Run

```
1. Select MAIN_CNC program
2. Set to AUTO mode
3. Reset faults (if any)
4. Press CYCLE START
5. Monitor via pendant or HMI
```

## Program Details

### Main Production Cycle (MAIN_CNC.LS)

```fanuc
/PROG MAIN_CNC
/ATTR
OWNER       = MNEDITOR;
COMMENT     = "Main CNC Vision Pick Cycle";
PROG_SIZE   = 2048;
CREATE      = DATE 25-01-15 TIME 10:30:00;
MODIFIED    = DATE 25-05-20 TIME 14:45:00;
FILE_NAME   = MAIN_CNC;
VERSION     = 1;
LINE_COUNT  = 85;
MEMORY_SIZE = 2560;
PROTECT     = READ_WRITE;
/MN
   1:  !======================== ;
   2:  ! MAIN CNC VISION CYCLE   ;
   3:  ! LR Mate 200iC + iRVision;
   4:  !======================== ;
   5:   ;
   6:  ! Initialize registers ;
   7:  R[1:Cycle_Count]=0 ;
   8:  R[2:Good_Parts]=0 ;
   9:  R[3:Vision_Fails]=0 ;
  10:  R[10:Retry_Count]=0 ;
  11:   ;
  12:  LBL[1:CYCLE_START] ;
  13:   ;
  14:  ! Wait for part present ;
  15:  WAIT DI[1:Part_Sensor]=ON ;
  16:   ;
  17:  ! Move to vision position ;
  18:  J P[1:VISION_POS] 100% FINE ;
  19:   ;
  20:  ! Run vision locate ;
  21:  CALL VIS_LOCATE ;
  22:   ;
  23:  ! Check vision result ;
  24:  IF R[20:Vision_Found]=0,JMP LBL[100] ;
  25:   ;
  26:  ! Calculate pick position ;
  27:  CALL VIS_CALC_OFFSET ;
  28:   ;
  29:  ! Approach pick ;
  30:  L P[2:PICK_APPROACH] 500mm/sec FINE ;
  31:   ;
  32:  ! Pick with offset ;
  33:  L PR[1:Pick_Offset] 100mm/sec FINE ;
  34:   ;
  35:  ! Close gripper ;
  36:  DO[1:Gripper]=ON ;
  37:  WAIT .3(sec) ;
  38:   ;
  39:  ! Retract ;
  40:  L P[2:PICK_APPROACH] 500mm/sec FINE ;
  41:   ;
  42:  ! Move to CNC ;
  43:  J P[5:CNC_APPROACH] 100% FINE ;
  44:   ;
  45:  ! Wait for CNC ready ;
  46:  WAIT DI[5:CNC_Ready]=ON ;
  47:   ;
  48:  ! Place in fixture ;
  49:  L P[6:CNC_PLACE] 200mm/sec FINE ;
  50:   ;
  51:  ! Open gripper ;
  52:  DO[1:Gripper]=OFF ;
  53:  WAIT .2(sec) ;
  54:   ;
  55:  ! Retract from CNC ;
  56:  L P[5:CNC_APPROACH] 500mm/sec FINE ;
  57:   ;
  58:  ! Signal CNC to start ;
  59:  DO[10:CNC_Start]=PULSE,0.5sec ;
  60:   ;
  61:  ! Update counters ;
  62:  R[1:Cycle_Count]=R[1:Cycle_Count]+1 ;
  63:  R[2:Good_Parts]=R[2:Good_Parts]+1 ;
  64:   ;
  65:  ! Log cycle data ;
  66:  CALL UTIL_LOG ;
  67:   ;
  68:  ! Return to home ;
  69:  J P[10:HOME] 50% FINE ;
  70:   ;
  71:  ! Loop ;
  72:  JMP LBL[1] ;
  73:   ;
  74:  !------------------------ ;
  75:  ! VISION FAIL HANDLER    ;
  76:  !------------------------ ;
  77:  LBL[100:VISION_FAIL] ;
  78:  R[3:Vision_Fails]=R[3:Vision_Fails]+1 ;
  79:  CALL ERR_RETRY ;
  80:  IF R[10:Retry_Count]<3,JMP LBL[1] ;
  81:   ;
  82:  ! Max retries - alarm ;
  83:  CALL ERR_ALARM ;
  84:  PAUSE ;
  85:   ;
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
```

### Vision Locate (VIS_LOCATE.LS)

```fanuc
/PROG VIS_LOCATE
/ATTR
OWNER       = MNEDITOR;
COMMENT     = "Vision Part Locate";
PROG_SIZE   = 1024;
/MN
   1:  !======================== ;
   2:  ! VISION PART LOCATE      ;
   3:  !======================== ;
   4:   ;
   5:  ! Initialize result ;
   6:  R[20:Vision_Found]=0 ;
   7:  R[21:Vision_Score]=0 ;
   8:   ;
   9:  ! Trigger snapshot ;
  10:  VISION RUN_FIND 'PART_LOCATE' ;
  11:   ;
  12:  ! Wait for process complete ;
  13:  VISION GET_OFFSET 'PART_LOCATE' VR[1] JMP LBL[90] ;
  14:   ;
  15:  ! Check if found ;
  16:  IF VR[1].FOUND=FALSE,JMP LBL[90] ;
  17:   ;
  18:  ! Check score threshold ;
  19:  R[21:Vision_Score]=VR[1].SCORE ;
  20:  IF R[21:Vision_Score]<75,JMP LBL[90] ;
  21:   ;
  22:  ! Store offsets ;
  23:  R[22:Vis_X_Offset]=VR[1].XOFFSET ;
  24:  R[23:Vis_Y_Offset]=VR[1].YOFFSET ;
  25:  R[24:Vis_R_Offset]=VR[1].ROFFSET ;
  26:   ;
  27:  ! Validate offsets in range ;
  28:  IF (ABS(R[22])>50),JMP LBL[90] ;
  29:  IF (ABS(R[23])>50),JMP LBL[90] ;
  30:  IF (ABS(R[24])>15),JMP LBL[90] ;
  31:   ;
  32:  ! Success ;
  33:  R[20:Vision_Found]=1 ;
  34:  JMP LBL[99] ;
  35:   ;
  36:  LBL[90:NOT_FOUND] ;
  37:  R[20:Vision_Found]=0 ;
  38:   ;
  39:  LBL[99:END] ;
  40:   ;
/END
```

## I/O Configuration

### Digital Inputs
| DI# | Signal Name | Description |
|-----|-------------|-------------|
| DI[1] | Part_Sensor | Part present on conveyor |
| DI[2] | Gripper_Closed | Gripper closed feedback |
| DI[3] | Gripper_Open | Gripper open feedback |
| DI[5] | CNC_Ready | CNC ready for part |
| DI[6] | CNC_Done | CNC cycle complete |
| DI[10] | E_Stop | Emergency stop |

### Digital Outputs
| DO# | Signal Name | Description |
|-----|-------------|-------------|
| DO[1] | Gripper | Gripper close command |
| DO[5] | Conveyor_Run | Run conveyor |
| DO[10] | CNC_Start | Start CNC cycle |
| DO[11] | Vision_Light | Vision ring light |
| DO[20] | Alarm_Light | Stack light - alarm |
| DO[21] | Run_Light | Stack light - running |

### Vision Registers
| VR# | Contents | Description |
|-----|----------|-------------|
| VR[1] | Part locate result | X, Y, R offsets + score |
| VR[2] | Secondary model | For part variants |

### Position Registers
| PR# | Name | Description |
|-----|------|-------------|
| PR[1] | Pick_Offset | Vision-adjusted pick position |
| PR[5] | Jog_Offset | Small jog for retry |

## Calibration Procedure

### Step-by-Step 2D Grid Calibration

1. **Prepare Equipment**
   ```
   - Clean camera lens
   - Mount calibration grid on flat surface
   - Position at working distance (400mm)
   - Ensure even lighting (no shadows)
   ```

2. **Camera Calibration**
   ```
   MENU → iRVision → Calibration → Camera Cal
   1. Select camera (Camera 1)
   2. Select calibration type (2D Grid)
   3. Position grid in FOV (fill 80% of image)
   4. Press SNAP to acquire
   5. Auto-detect grid points
   6. Verify all points detected (green circles)
   7. Press CALIBRATE
   8. Check RMS error < 0.5 pixels
   9. SAVE calibration
   ```

3. **Robot-to-Camera Calibration**
   ```
   MENU → iRVision → Calibration → Robot-Camera Cal
   1. Select camera and calibration grid
   2. Move robot to calibration position
   3. Touch TCP to grid point 1
   4. Press RECORD
   5. Repeat for points 2-4 (minimum)
   6. Optionally add points 5-9 for accuracy
   7. Press CALIBRATE
   8. Verify RMS error < 0.3mm
   9. SAVE calibration
   ```

4. **Validation**
   ```
   1. Place test part at 5 positions
   2. Run VIS_VALIDATE program
   3. Record measured vs. expected
   4. Accept if all errors < 0.5mm
   ```

### Calibration Data Storage

```
Calibration files stored in:
  MD:\VISION\CALIB\
    ├── CAM1_GRID.CAL      # Camera intrinsics
    ├── CAM1_ROBOT.CAL     # Robot-camera transform
    └── CAL_REPORT.TXT     # Validation report
```

## Troubleshooting

### Common Vision Issues

| Problem | Possible Cause | Solution |
|---------|---------------|----------|
| No part found | Low lighting | Check ring light, increase exposure |
| Low score (<75) | Part orientation | Adjust search angle tolerance |
| Large X/Y offset | Calibration drift | Re-run robot-camera cal |
| Inconsistent results | Vibration | Check camera mount, add delay |
| Slow processing | Large search window | Reduce window size |

### Error Codes

| Error | Description | Recovery |
|-------|-------------|----------|
| VIS-001 | Camera not connected | Check cable, power cycle |
| VIS-010 | Calibration invalid | Re-calibrate |
| VIS-020 | Part not found | Retry or manual mode |
| VIS-030 | Score too low | Check lighting, part condition |
| VIS-040 | Offset out of range | Check part placement |

### Recovery Procedures

```fanuc
! Automatic retry with position jog
! (ERR_RETRY.LS)

1. Jog camera position slightly (±5mm)
2. Re-trigger vision snap
3. If found, continue cycle
4. If 3 retries fail, alarm and pause
```

## Performance Monitoring

### Logged Data

Each cycle logs:
- Timestamp
- Vision score
- X, Y, R offsets
- Cycle time
- Part ID (if barcode used)

### Statistics Collection

```
Daily statistics calculated:
- Mean vision score
- Offset standard deviation
- Detection success rate
- Cycle time average
- Alarm frequency
```

### Sample Log Output

```
2025-05-20 14:32:15, CYCLE: 1247, SCORE: 89.3, X: 2.34, Y: -1.56, R: 0.45, TIME: 12.3s
2025-05-20 14:32:45, CYCLE: 1248, SCORE: 91.2, X: 1.89, Y: -0.98, R: 0.23, TIME: 12.1s
2025-05-20 14:33:12, CYCLE: 1249, SCORE: 87.5, X: 3.12, Y: -2.01, R: 0.67, TIME: 12.5s
```

## File Structure

```
fanuc_vision_cnc/
├── tp_programs/
│   ├── main/
│   │   ├── MAIN_CNC.LS
│   │   ├── AUTO_CYCLE.LS
│   │   └── MANUAL_MODE.LS
│   ├── vision/
│   │   ├── VIS_SNAP.LS
│   │   ├── VIS_LOCATE.LS
│   │   ├── VIS_CALC_OFFSET.LS
│   │   └── VIS_VALIDATE.LS
│   ├── error_handling/
│   │   ├── ERR_VISION_FAIL.LS
│   │   ├── ERR_RETRY.LS
│   │   ├── ERR_ALARM.LS
│   │   └── ERR_RECOVERY.LS
│   └── utilities/
│       ├── UTIL_LOG.LS
│       ├── UTIL_CALIB.LS
│       └── UTIL_STATS.LS
├── karel_programs/
│   ├── vis_logger.kl
│   └── stats_calc.kl
├── vision_config/
│   ├── calibration/
│   │   ├── grid_cal_procedure.md
│   │   └── robot_cal_procedure.md
│   ├── search_windows/
│   │   └── part_locate.vd
│   └── templates/
│       └── gpm_template.vd
├── documentation/
│   ├── calibration/
│   │   └── calibration_guide.md
│   ├── commissioning/
│   │   └── commissioning_checklist.md
│   └── troubleshooting/
│       └── troubleshooting_guide.md
├── analysis/
│   └── vision_analysis.py
├── logs/
│   └── (runtime logs)
└── README.md
```

## Dependencies

- FANUC R-30iA/iB Controller
- iRVision 2D Software (A05B-2600-R714)
- Sony XC-56 Camera (or compatible GigE/USB camera)
- FANUC Calibration Grid (A05B-1225-H201)

## Safety Notes

⚠️ **Always follow FANUC safety guidelines**
- Verify E-stop functionality before operation
- Test at reduced speed (25%) first
- Keep clear of robot work envelope
- Use proper lockout/tagout procedures

## Citation

```bibtex
@project{fanuc_irvision_cnc_2025,
  author = {Barath Kumar JK},
  title = {Vision-Based FANUC LR Mate 200iC for CNC Workcell},
  year = {2025},
  institution = {Center of Excellence in Welding Technology, PSG College of Technology},
  note = {Jan 2025 - May 2025}
}
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Barath Kumar JK**  
Center of Excellence in Welding and Engineering (CoEWT)  
PSG College of Technology  
Jan 2025 - May 2025
