# Design Spec: Preset Button Race Condition Fix

This specification outlines the root cause and technical fix for the preset buttons requiring a double press to activate.

## Analysis & Root Cause

1. **Race Condition (Concurrency)**:
   * **Problem**: In both `HeroFanDial.swift` and `MenuBarPopoverView.swift`, clicking a manual speed preset button (e.g. "50%") when the fan is in "Auto" mode initiates two actions back-to-back in the same SwiftUI transaction:
     1. `viewModel.changeFanMode(fanId: fan.id, mode: .forced)`
     2. `viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))`
   * Each of these methods asynchronously spawns a background thread that executes the `smc-helper` process.
   * Because both processes are launched concurrently, they compete to write to the SMC. The second process (`changeFanSpeed`) often loses the race or fails due to hardware write lock conflicts, resulting in the fan speed reverting to `minSpeed` or failing to set. On the second press, since `fan.mode` is already `.forced`, only `changeFanSpeed` is called (avoiding the race) and it succeeds.

2. **Resolution**:
   * `viewModel.changeFanSpeed(fanId: Int, speed: Int)` already handles switching the fan mode to `.forced` and setting the target speed in a single operation.
   * Therefore, we can completely remove the redundant `changeFanMode` invocation when clicking manual presets, resolving the concurrency conflict and making presets activate instantly on the first press.

---

## Component-Level Details

### 1. Main View Quick Presets
*   **File**: [HeroFanDial.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/HeroFanDial.swift)
    *   In `presetButton(title:isAuto:val:)`, remove the redundant check and call to `viewModel.changeFanMode(fanId:mode:)` in the manual preset path.

### 2. Status Popover Quick Presets
*   **File**: [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift)
    *   In `presetButton(title:isAuto:val:)`, remove the redundant check and call to `viewModel.changeFanMode(fanId:mode:)` in the manual preset path.
