# FANUC iRVision 2D Grid Calibration Guide

## Sony XC-56 Camera with R-30iA Controller

**Author:** Barath Kumar JK  
**Date:** January - May 2025  
**System:** FANUC LR Mate 200iC with iRVision

---

## Table of Contents

1. [Equipment Required](#equipment-required)
2. [Pre-Calibration Setup](#pre-calibration-setup)
3. [Camera Calibration (Intrinsic)](#camera-calibration-intrinsic)
4. [Robot-to-Camera Calibration (Extrinsic)](#robot-to-camera-calibration-extrinsic)
5. [Validation Procedure](#validation-procedure)
6. [Troubleshooting](#troubleshooting)
7. [Maintenance Schedule](#maintenance-schedule)

---

## 1. Equipment Required

| Item | Part Number | Notes |
|------|-------------|-------|
| Calibration Grid | A05B-1225-H201 | 9×9 dots, 10mm spacing |
| Grid Holder | - | Flat, rigid surface |
| TCP Calibration Tool | - | Sharp point, known offset |
| Cleaning Supplies | - | Lens cleaner, microfiber |
| Documentation Forms | - | Record calibration data |

---

## 2. Pre-Calibration Setup

### 2.1 Camera Preparation

```
1. Clean camera lens with microfiber cloth
2. Verify lens is securely mounted (8mm C-mount)
3. Check camera cable connections
4. Verify ring light operation (DO[11])
```

### 2.2 Lighting Setup

```
1. Turn on ring light: DO[11]=ON
2. Verify even illumination on work surface
3. Eliminate ambient light interference
4. Check for reflections or hot spots
```

### 2.3 Camera Position

```
Working Distance: 400mm (camera to part surface)
Field of View: ~200mm × 150mm at working distance
Mount Angle: Perpendicular to work surface (±2°)
```

### 2.4 Frame Setup

Before calibration, ensure user frames are defined:

```
MENU → SETUP → FRAMES → User Frame

UF[1]: CONVEYOR_UF
  - Origin at conveyor pick position
  - X along conveyor direction
  - Z up from surface

UF[2]: CNC_UF
  - Origin at CNC fixture center
  - Aligned with machine axes
```

---

## 3. Camera Calibration (Intrinsic)

This calibration corrects lens distortion and establishes pixel-to-mm mapping.

### 3.1 Access Calibration Menu

```
MENU → iRVision → Tools → Calibration → Camera Cal
```

### 3.2 Select Options

```
Camera:          Camera 1
Calibration:     2D Grid
Grid Type:       Standard (9×9)
Dot Spacing:     10.0 mm
```

### 3.3 Position Grid

1. Place calibration grid on flat surface at working distance
2. Grid should fill 70-80% of camera field of view
3. Ensure grid is parallel to image plane
4. Center grid in image

### 3.4 Acquire Calibration Image

```
1. Press [SNAP] to acquire image
2. Wait for auto-detection (green circles on dots)
3. Verify ALL 81 dots are detected
4. If dots missing, adjust lighting/focus
```

### 3.5 Execute Calibration

```
1. Press [CALIBRATE]
2. Wait for processing (~5 seconds)
3. Review results:
   - RMS Error: < 0.5 pixels (REQUIRED)
   - Max Error: < 1.5 pixels
4. Press [SAVE] if acceptable
```

### 3.6 Record Results

| Parameter | Value | Acceptable |
|-----------|-------|------------|
| RMS Error | ___ pixels | < 0.5 |
| Max Error | ___ pixels | < 1.5 |
| Scale X | ___ mm/pixel | ~0.30 |
| Scale Y | ___ mm/pixel | ~0.30 |
| K1 (distortion) | ___ | < 0.1 |

---

## 4. Robot-to-Camera Calibration (Extrinsic)

This calibration establishes the transformation from camera coordinates to robot world coordinates.

### 4.1 Prepare TCP Tool

```
1. Mount calibration tool (sharp point) on gripper
2. Verify tool center point (TCP) is accurate
3. Tool offset should be precisely known
```

### 4.2 Access Robot-Camera Cal

```
MENU → iRVision → Tools → Calibration → Robot-Camera Cal
```

### 4.3 Select Options

```
Camera:          Camera 1
Reference Frame: UF[1] (CONVEYOR_UF)
Calibration:     Grid Touch
Points:          9 (3×3 recommended)
```

### 4.4 Touch Calibration Points

For each calibration point (minimum 4, recommended 9):

```
1. Jog robot TCP to grid dot center
2. Touch dot precisely with TCP point
3. Press [RECORD] to save robot position
4. System automatically snaps image and detects dot
5. Repeat for all calibration points
```

**Point Pattern (9-point):**
```
    1 --- 2 --- 3
    |     |     |
    4 --- 5 --- 6
    |     |     |
    7 --- 8 --- 9
```

### 4.5 Execute Calibration

```
1. After all points recorded, press [CALIBRATE]
2. Wait for computation (~3 seconds)
3. Review results:
   - RMS Error: < 0.3 mm (REQUIRED)
   - Max Error: < 0.5 mm
4. Press [SAVE] if acceptable
```

### 4.6 Record Results

| Parameter | Value | Acceptable |
|-----------|-------|------------|
| RMS Error | ___ mm | < 0.3 |
| Max Error | ___ mm | < 0.5 |
| Transform X | ___ mm | - |
| Transform Y | ___ mm | - |
| Transform Z | ___ mm | - |
| Rotation | ___ deg | - |

---

## 5. Validation Procedure

### 5.1 Prepare Test Parts

```
1. Obtain 5 identical test parts
2. Place at known positions on conveyor
3. Mark positions for repeatability
```

### 5.2 Run Validation Program

```
1. Load program: UTIL_CALIB
2. Place part at Position 1
3. Run vision locate
4. Robot touches part center
5. Measure offset from actual center
6. Repeat for all 5 positions
```

### 5.3 Record Validation Data

| Position | Vision X | Vision Y | Actual X | Actual Y | Error |
|----------|----------|----------|----------|----------|-------|
| 1 (Center) | ___ | ___ | ___ | ___ | ___ mm |
| 2 (+X) | ___ | ___ | ___ | ___ | ___ mm |
| 3 (-X) | ___ | ___ | ___ | ___ | ___ mm |
| 4 (+Y) | ___ | ___ | ___ | ___ | ___ mm |
| 5 (-Y) | ___ | ___ | ___ | ___ | ___ mm |

### 5.4 Acceptance Criteria

```
All positions: Error < 0.5 mm
Average error: < 0.3 mm
Maximum error: < 0.5 mm

If criteria not met:
  - Re-check camera calibration
  - Re-check robot-camera calibration
  - Verify frame alignment
```

---

## 6. Troubleshooting

### 6.1 Camera Calibration Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| Dots not detected | Poor lighting | Adjust ring light intensity |
| Missing edge dots | Grid not in FOV | Reposition grid or camera |
| High RMS error | Grid not flat | Use rigid backing |
| Distortion visible | Wrong lens | Verify 8mm lens installed |

### 6.2 Robot-Camera Cal Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| High position error | TCP offset wrong | Re-calibrate tool frame |
| Inconsistent results | Vibration | Secure camera mount |
| Z errors | Working distance wrong | Measure and adjust |
| Rotation errors | Frame misalignment | Re-define user frame |

### 6.3 Runtime Vision Issues

| Problem | Cause | Solution |
|---------|-------|----------|
| Part not found | Score threshold | Lower to 70% temporarily |
| Large offsets | Calibration drift | Re-calibrate |
| Slow detection | Large search window | Reduce window size |
| False positives | Similar features | Add exclusion zones |

---

## 7. Maintenance Schedule

### Weekly

- [ ] Clean camera lens
- [ ] Verify ring light operation
- [ ] Check cable connections
- [ ] Review vision score logs

### Monthly

- [ ] Run validation procedure
- [ ] Check calibration accuracy
- [ ] Clean calibration grid
- [ ] Update documentation

### Quarterly

- [ ] Full re-calibration (both camera and robot-camera)
- [ ] Replace ring light LEDs if degraded
- [ ] Verify all frame definitions
- [ ] Archive calibration data

### Annual

- [ ] Camera sensor cleaning (professional)
- [ ] Full system validation
- [ ] Documentation review and update

---

## Appendix: Calibration Checklist

```
□ Camera lens cleaned
□ Ring light functional
□ Calibration grid clean and flat
□ Working distance verified (400mm)
□ Camera calibration RMS < 0.5 px
□ Robot-camera cal RMS < 0.3 mm
□ Validation all points < 0.5 mm
□ Results documented
□ Backup saved to USB
□ Date and signature: ________________
```

---

**Document Control:**
- Version: 1.2
- Last Updated: May 2025
- Next Review: November 2025
