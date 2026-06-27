# Launch at Startup Option Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a toggle in the Settings tab to control launching the application at macOS startup/login using `SMAppService`.

**Architecture:** Integrate ServiceManagement into `FanViewModel` and bind a Toggle switch to it in `SettingsTabView`.

**Tech Stack:** SwiftUI, ServiceManagement, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Update FanViewModel to support launch at startup status
**Files:**
- Modify: `ViewModels/FanViewModel.swift`

- [ ] **Step 1: Add imports and startup check/toggle logic**
  In `ViewModels/FanViewModel.swift`:
  - Import `ServiceManagement`.
  - Add `@Published var launchAtStartup: Bool` with a `didSet` observer.
  - Implement helper methods `checkLaunchAtStartupStatus()` and `setLaunchAtStartup(enabled:)`.
  - Call `checkLaunchAtStartupStatus()` in `init()`.

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "feat: implement launch at startup logic in FanViewModel using SMAppService"`

---

### Task 2: Add launch at startup Toggle to Settings Tab
**Files:**
- Modify: `Views/SettingsTabView.swift`

- [ ] **Step 1: Add launch toggle next to linked fans toggle**
  In `Views/SettingsTabView.swift`:
  Inside "Global controls" section, add a `Toggle` for `viewModel.launchAtStartup` with a `.teal` tint switch style.

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "feat: add launch at startup toggle to SettingsTabView"`

---

### Task 3: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
