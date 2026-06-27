# Menu Bar Icon Multiple Fans Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modify the menu bar icon status update to evaluate the maximum current speed of all system fans.

**Architecture:** Update `FanControlApp.swift` to calculate maximum RPM from `viewModel.fans` dynamically.

**Tech Stack:** SwiftUI, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Update MenuBarExtra Label in FanControlApp
**Files:**
- Modify: `App/FanControlApp.swift`

- [ ] **Step 1: Replace first-fan speed query with maximum speed calculation**
  In `App/FanControlApp.swift`:
  Replace lines 23-27:
  ```swift
              if let firstFan = viewModel.fans.first {
                  createMenuIcon(speed: firstFan.currentSpeed)
              } else {
                  Image(systemName: "fan.fill")
              }
  ```
  with:
  ```swift
              if !viewModel.fans.isEmpty {
                  let maxSpeed = viewModel.fans.map { $0.currentSpeed }.max() ?? 0
                  createMenuIcon(speed: maxSpeed)
              } else {
                  Image(systemName: "fan.fill")
              }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "feat: update menu bar icon status to reflect the maximum speed of all active fans"`

---

### Task 2: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
