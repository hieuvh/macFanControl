# Preset Button Race Condition Fix Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate redundant `changeFanMode` calls when clicking preset speed buttons to fix the concurrency write conflict race.

**Architecture:** Refactor `presetButton` implementations in `HeroFanDial` and `MenuBarPopoverView` to call `changeFanSpeed` directly, allowing it to perform unified mode/speed writes.

**Tech Stack:** SwiftUI, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Fix Preset Action in HeroFanDial
**Files:**
- Modify: `Views/HeroFanDial.swift`

- [ ] **Step 1: Simplify manual preset action block**
  In `Views/HeroFanDial.swift`:
  Replace lines 144-150:
  ```swift
                  } else {
                      sliderVal = val
                      if fan.mode != .forced {
                          viewModel.changeFanMode(fanId: fan.id, mode: .forced)
                      }
                      viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                  }
  ```
  with:
  ```swift
                  } else {
                      sliderVal = val
                      viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                  }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "fix: remove redundant changeFanMode in HeroFanDial manual presets to prevent concurrency race"`

---

### Task 2: Fix Preset Action in MenuBarPopoverView
**Files:**
- Modify: `Views/MenuBarPopoverView.swift`

- [ ] **Step 1: Simplify manual preset action block**
  In `Views/MenuBarPopoverView.swift`:
  Replace lines 200-206:
  ```swift
                  } else {
                      sliderVal = val
                      if fan.mode != .forced {
                          viewModel.changeFanMode(fanId: fan.id, mode: .forced)
                      }
                      viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                  }
  ```
  with:
  ```swift
                  } else {
                      sliderVal = val
                      viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                  }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "fix: remove redundant changeFanMode in MenuBarPopoverView manual presets to prevent concurrency race"`

---

### Task 3: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
