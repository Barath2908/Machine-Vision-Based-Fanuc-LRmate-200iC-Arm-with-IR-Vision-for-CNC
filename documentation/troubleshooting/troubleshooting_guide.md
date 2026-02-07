# FANUC iRVision Troubleshooting Guide

## CNC Workcell Vision System

**Author:** Barath Kumar JK  
**Date:** January - May 2025

---

## Quick Reference: Error Codes

| Code | Description | Severity | Action |
|------|-------------|----------|--------|
| VIS-001 | Camera not connected | Critical | Check cables |
| VIS-010 | Calibration invalid | Critical | Re-calibrate |
| VIS-020 | Part not found | Warning | Retry/check part |
| VIS-030 | Score too low | Warning | Check lighting |
| VIS-040 | Offset out of range | Warning | Check placement |
| VIS-050 | Process timeout | Error | Check camera |
| UALM[1] | Vision max retries | Error | Check system |
| UALM[2] | Gripper timeout | Error | Check pneumatics |
| UALM[3] | CNC not ready | Error | Check CNC |

---

## 1. Vision Detection Failures

### Symptom: Part Not Found (R[20]=0)

**Possible Causes:**

1. **Insufficient Lighting**
   ```
   Check:
   - Ring light ON (DO[11]=ON)
   - Light intensity sufficient
   - No shadows on part
   - No reflections/glare
   
   Fix:
   - Verify DO[11] output
   - Check LED power supply (24V)
   - Adjust exposure in vision setup
   - Add/remove ambient light blocking
   ```

2. **Part Out of Search Window**
   ```
   Check:
   - Part position on conveyor
   - Search window size in vision process
   
   Fix:
   - Expand search window (MENU → iRVision → Process → PART_LOCATE → Search)
   - Verify conveyor stop position
   - Check part sensor timing
   ```

3. **Model Not Matching**
   ```
   Check:
   - Part orientation vs trained model
   - Part surface condition (dirty, shiny)
   - Different part variant
   
   Fix:
   - Re-train model with current part
   - Add additional models for variants
   - Clean part surface
   - Adjust angle tolerance in locator
   ```

4. **Camera Focus Issue**
   ```
   Check:
   - Image sharpness on pendant
   - Working distance correct (400mm)
   
   Fix:
   - Adjust lens focus ring
   - Verify camera mounting distance
   - Check for camera vibration
   ```

### Symptom: Low Vision Score (<75%)

**Diagnostic Steps:**

1. View live image on pendant:
   ```
   MENU → iRVision → Camera → Camera 1 → LIVE
   ```

2. Check image quality:
   - Good contrast between part and background
   - Clear edge definition
   - No blur or motion artifacts

3. Run vision process manually:
   ```
   MENU → iRVision → Process → PART_LOCATE → RUN
   ```

4. Review score and match quality

**Solutions by Score Range:**

| Score | Issue | Solution |
|-------|-------|----------|
| 60-75% | Marginal match | Improve lighting, clean part |
| 40-60% | Poor match | Re-train model or check part |
| <40% | No match | Wrong part or major issue |

---

## 2. Offset Errors

### Symptom: Large X or Y Offset (>10mm)

**Possible Causes:**

1. **Calibration Drift**
   ```
   Check:
   - Days since last calibration
   - Robot collision history
   - Camera mounting looseness
   
   Fix:
   - Run VIS_VALIDATE to confirm
   - Re-run robot-camera calibration
   - Tighten camera mount
   ```

2. **Part Placement Variation**
   ```
   Check:
   - Conveyor alignment
   - Part guides/fixtures
   - Part sensor position
   
   Fix:
   - Adjust conveyor guides
   - Verify part stops
   - Check part orientation on conveyor
   ```

3. **Frame Definition Error**
   ```
   Check:
   - User frame alignment
   - Vision frame in process setup
   
   Fix:
   - Verify UF[1] definition
   - Re-teach frame origin points
   ```

### Symptom: Large R Offset (>5°)

**Possible Causes:**

1. **Part Rotation on Conveyor**
   ```
   Check:
   - Part guidance on conveyor
   - Conveyor belt alignment
   
   Fix:
   - Add part orientation guides
   - Check conveyor belt tracking
   ```

2. **Model Training Issue**
   ```
   Check:
   - Model angle tolerance setting
   - Training image orientation
   
   Fix:
   - Increase angle search range
   - Re-train with multiple orientations
   ```

---

## 3. Camera Issues

### Symptom: No Image / Black Screen

**Diagnostic Steps:**

1. Check camera power:
   ```
   - Verify 12V power to camera
   - Check power LED on camera (if present)
   - Measure voltage at camera connector
   ```

2. Check video connection:
   ```
   - Inspect camera cable for damage
   - Verify cable connection at controller
   - Check camera input card in controller
   ```

3. Test camera:
   ```
   MENU → iRVision → Camera → Camera 1 → TEST
   ```

### Symptom: Noisy/Grainy Image

**Solutions:**

1. Increase lighting intensity
2. Reduce camera gain (MENU → iRVision → Camera → Settings)
3. Increase exposure time
4. Check for electrical interference
5. Replace camera cable if shielding damaged

### Symptom: Image Distortion

**Solutions:**

1. Re-run camera calibration
2. Check lens mounting (tighten)
3. Verify correct lens installed (8mm)
4. Inspect lens for damage/debris

---

## 4. Program Errors

### UALM[1]: Vision Max Retries

**This alarm triggers when:**
- 3 consecutive vision attempts fail
- Score below threshold for all attempts

**Recovery:**

1. Press RESET on pendant
2. Check part presence on conveyor
3. Manually verify vision:
   ```
   MENU → iRVision → Process → PART_LOCATE → RUN
   ```
4. If vision works, press CYCLE START
5. If vision fails, troubleshoot detection

### UALM[2]: Gripper Timeout

**This alarm triggers when:**
- Gripper doesn't reach closed/open position within timeout
- DI[2] or DI[3] doesn't turn ON

**Recovery:**

1. Check air pressure (>4 bar)
2. Manually cycle gripper:
   ```
   Pendant → I/O → Digital → DO[1] → Toggle
   ```
3. Check for obstruction in gripper
4. Verify proximity sensors
5. Check pneumatic solenoid

### UALM[3]: CNC Not Ready

**This alarm triggers when:**
- DI[5] (CNC_Ready) doesn't turn ON
- CNC door not open or machine in fault

**Recovery:**

1. Check CNC machine status
2. Clear any CNC alarms
3. Verify CNC door is open
4. Check interlock signals
5. Reset CNC if needed

---

## 5. Calibration Issues

### Symptom: High RMS Error in Camera Cal (>0.5 pixels)

**Solutions:**

1. Clean calibration grid
2. Ensure grid is flat (use rigid backing)
3. Position grid to fill 70-80% of FOV
4. Eliminate reflections on grid
5. Verify grid dot spacing is correct (10mm)

### Symptom: High RMS Error in Robot-Camera Cal (>0.3mm)

**Solutions:**

1. Use sharp TCP calibration tool
2. Touch grid dots precisely (center)
3. Use more calibration points (9 instead of 4)
4. Verify TCP calibration is accurate
5. Check for robot backlash

### Symptom: Validation Errors >0.5mm

**Solutions:**

1. Re-run complete calibration sequence
2. Verify working distance is consistent
3. Check user frame definition
4. Test at same height as production parts
5. Account for gripper deflection

---

## 6. Recovery Procedures

### Full System Reset

```
1. Press E-STOP
2. Wait 5 seconds
3. Release E-STOP
4. Press RESET on pendant
5. Select MAIN_CNC program
6. Move to HOME position (hold SHIFT + FWD)
7. Release at P[10:HOME]
8. Clear any remaining faults
9. Set to AUTO mode
10. Press CYCLE START
```

### Vision System Reset

```
1. Power cycle camera:
   - Set DO[11]=OFF (light off)
   - Wait 2 seconds
   - Set DO[11]=ON (light on)
   
2. Re-initialize vision:
   MENU → iRVision → Initialize → Camera 1
   
3. Test vision:
   MENU → iRVision → Process → PART_LOCATE → RUN
```

### Calibration Recovery

```
If calibration data is lost or corrupt:

1. Load backup from USB:
   MENU → FILE → LOAD → Vision Data
   
2. Or re-calibrate:
   - Camera calibration (10 minutes)
   - Robot-camera calibration (15 minutes)
   - Validation (10 minutes)
```

---

## 7. Preventive Maintenance

### Daily Checks

- [ ] Clean camera lens if needed
- [ ] Verify ring light operation
- [ ] Check vision score in log (>85% average)
- [ ] Review any retry events

### Weekly Checks

- [ ] Run VIS_VALIDATE program
- [ ] Check calibration accuracy
- [ ] Clean calibration grid
- [ ] Review offset trends in log

### Monthly Checks

- [ ] Full validation at 5 positions
- [ ] Check camera mounting
- [ ] Inspect cables for wear
- [ ] Review and archive logs

---

## 8. Contact Information

**System Integrator:**
- Company: [Your Company]
- Phone: [Phone Number]
- Email: [Email]

**FANUC Technical Support:**
- Phone: 1-888-FANUC-US
- Web: https://www.fanucamerica.com/support

---

**Document Version:** 1.0  
**Last Updated:** May 2025
