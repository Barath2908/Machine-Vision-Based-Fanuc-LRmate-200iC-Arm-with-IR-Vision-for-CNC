# CNC Workcell Commissioning Checklist

## FANUC LR Mate 200iC with iRVision

**Project:** Vision-Based CNC Machine Tending  
**Author:** Barath Kumar JK  
**Date:** January - May 2025

---

## Pre-Commissioning Requirements

### Documentation Review
- [ ] System layout drawings reviewed
- [ ] Electrical schematics verified
- [ ] Pneumatic diagrams available
- [ ] Safety assessment completed
- [ ] Risk assessment signed off

### Equipment Verification
- [ ] Robot model: LR Mate 200iC/5L confirmed
- [ ] Controller: R-30iA with iRVision option
- [ ] Camera: Sony XC-56 installed
- [ ] Gripper: Pneumatic parallel jaw
- [ ] Conveyor: Variable speed with sensor

---

## Phase 1: Mechanical Setup

### Robot Installation
- [ ] Robot mounted and leveled
- [ ] Base bolts torqued to spec (M12: 85 Nm)
- [ ] Axis limits verified
- [ ] Emergency stops installed
- [ ] Guard fencing complete

### End Effector
- [ ] Gripper mounted on J6
- [ ] Pneumatic connections made
- [ ] Gripper opens/closes manually
- [ ] Finger spacing verified for part

### Camera Mounting
- [ ] Camera bracket installed
- [ ] Camera at 400mm working distance
- [ ] Camera perpendicular to work surface
- [ ] Cable routed and secured
- [ ] Ring light mounted and connected

### Conveyor Setup
- [ ] Conveyor aligned with robot
- [ ] Part sensor positioned
- [ ] Belt speed calibrated
- [ ] Part stops/guides installed

---

## Phase 2: Electrical Setup

### Robot Controller
- [ ] Main power connected (3-phase 480V or 200V)
- [ ] Controller powered on
- [ ] No fault lights
- [ ] Teach pendant functional
- [ ] Battery backup OK

### I/O Wiring

**Digital Inputs:**
| Signal | Terminal | Wire Color | Tested |
|--------|----------|------------|--------|
| DI[1] Part Sensor | TB1-1 | Brown | [ ] |
| DI[2] Gripper Closed | TB1-2 | Blue | [ ] |
| DI[3] Gripper Open | TB1-3 | Green | [ ] |
| DI[5] CNC Ready | TB1-5 | Yellow | [ ] |
| DI[6] CNC Done | TB1-6 | Orange | [ ] |
| DI[10] E-Stop | TB1-10 | Red | [ ] |

**Digital Outputs:**
| Signal | Terminal | Wire Color | Tested |
|--------|----------|------------|--------|
| DO[1] Gripper | TB2-1 | Brown | [ ] |
| DO[5] Conveyor | TB2-5 | Blue | [ ] |
| DO[10] CNC Start | TB2-10 | Yellow | [ ] |
| DO[11] Vision Light | TB2-11 | White | [ ] |
| DO[20] Alarm Light | TB2-20 | Red | [ ] |
| DO[21] Run Light | TB2-21 | Green | [ ] |

### I/O Testing
- [ ] All inputs read correctly on pendant
- [ ] All outputs toggle correctly
- [ ] E-stop chain verified (opens SOP)
- [ ] Safety scanner functional
- [ ] Light curtain functional

---

## Phase 3: Robot Programming

### Frame Setup

**Tool Frame (UTOOL[1]):**
- [ ] TCP calibrated (3-point method)
- [ ] Orientation set for gripper
- [ ] Payload data entered

**User Frames:**
- [ ] UF[1] CONVEYOR - defined at pick area
- [ ] UF[2] CNC - defined at CNC fixture

### Position Teaching

**Required Positions:**
- [ ] P[1] VISION_POS - camera viewing position
- [ ] P[2] PICK_APPROACH - 100mm above pick
- [ ] P[3] PICK_POS - part grasp position
- [ ] P[5] CNC_APPROACH - outside CNC door
- [ ] P[6] CNC_PLACE - fixture load position
- [ ] P[10] HOME - safe home position

### Program Loading
- [ ] All .LS files loaded from USB
- [ ] KAREL programs compiled and loaded
- [ ] Programs verified in program list
- [ ] Register names assigned (R[], PR[])

---

## Phase 4: Vision Setup

### Camera Calibration
- [ ] Camera calibration completed
- [ ] RMS error < 0.5 pixels
- [ ] Calibration saved

### Robot-Camera Calibration
- [ ] 9-point calibration completed
- [ ] RMS error < 0.3 mm
- [ ] Calibration saved

### Vision Process Setup

**PART_LOCATE Process:**
- [ ] Model trained on part
- [ ] Search window defined
- [ ] Score threshold set (75%)
- [ ] Offset outputs configured
- [ ] Process saved

### Vision Validation
- [ ] Test at center position: Error ___ mm
- [ ] Test at +X position: Error ___ mm
- [ ] Test at -X position: Error ___ mm
- [ ] Test at +Y position: Error ___ mm
- [ ] Test at -Y position: Error ___ mm
- [ ] All errors < 0.5 mm: [ ] PASS / [ ] FAIL

---

## Phase 5: Integration Testing

### Manual Mode Testing

**Sequence Test:**
1. [ ] Move to VISION_POS
2. [ ] Trigger vision - part found
3. [ ] Move to PICK_APPROACH
4. [ ] Move to PICK_POS with offset
5. [ ] Close gripper - sensor confirms
6. [ ] Retract to PICK_APPROACH
7. [ ] Move to CNC_APPROACH
8. [ ] Move to CNC_PLACE
9. [ ] Open gripper - sensor confirms
10. [ ] Retract to CNC_APPROACH
11. [ ] Return to HOME

### Error Handling Test
- [ ] Vision fail - retry works
- [ ] Vision fail - max retries triggers alarm
- [ ] Gripper timeout - alarm triggers
- [ ] CNC not ready - alarm triggers
- [ ] E-stop - robot stops safely

### Cycle Time Test
| Run | Time (sec) | Notes |
|-----|------------|-------|
| 1 | ___ | |
| 2 | ___ | |
| 3 | ___ | |
| 4 | ___ | |
| 5 | ___ | |
| Avg | ___ | Target: <15 sec |

---

## Phase 6: Production Validation

### First Article Inspection
- [ ] Part picked successfully
- [ ] Part placed in CNC fixture
- [ ] CNC machining completed
- [ ] Part quality acceptable
- [ ] No robot interference

### 100-Cycle Test
- [ ] 100 cycles completed
- [ ] Success rate: ___% (Target: >95%)
- [ ] Average vision score: ___
- [ ] No unexpected stops
- [ ] Cycle time consistent

### Operator Training
- [ ] Start/stop procedure
- [ ] Error recovery procedure
- [ ] Manual mode operation
- [ ] Basic troubleshooting
- [ ] Safety procedures

---

## Phase 7: Documentation & Handoff

### Documentation Complete
- [ ] As-built drawings updated
- [ ] Program listings printed
- [ ] Calibration data recorded
- [ ] Maintenance schedule created
- [ ] Spare parts list provided

### Backup Created
- [ ] Full controller backup to USB
- [ ] Vision data backed up
- [ ] KAREL programs backed up
- [ ] Backup stored offsite

### Training Complete
- [ ] Operators trained
- [ ] Maintenance staff trained
- [ ] Training records signed
- [ ] Contact information provided

---

## Sign-Off

### Commissioning Complete

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Integrator | | | |
| Customer Eng | | | |
| Safety Officer | | | |
| Production Mgr | | | |

### Notes/Exceptions:

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

**Document Version:** 1.0  
**Created:** January 2025  
**Last Updated:** May 2025
