# Open Settings from Menu Bar Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow users to open the Settings tab directly from the menu bar popover dropdown.

**Architecture:** Move active tab state from `ContentView` to `FanViewModel` to allow menu bar popover triggers to focus Settings.

**Tech Stack:** SwiftUI, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Add Tab Navigation State to FanViewModel
**Files:**
- Modify: `ViewModels/FanViewModel.swift`

- [ ] **Step 1: Declare selectedTab property**
  In `ViewModels/FanViewModel.swift`, add `@Published var selectedTab: DashboardTab = .overview` near the top properties.

- [ ] **Step 2: Verify compilation**
  Wait! `DashboardTab` is declared in `ContentView.swift`. Since both are compiled in the same target, this will build cleanly.
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "feat: add selectedTab state to FanViewModel"`

---

### Task 2: Refactor ContentView to use Viewmodel Tab Binding
**Files:**
- Modify: `Views/ContentView.swift`

- [ ] **Step 1: Remove local state and use viewModel bindings**
  In `Views/ContentView.swift`:
  - Remove `@State private var selectedTab: DashboardTab = .overview`
  - Update Sidebar buttons and `switch` statements to bind to `viewModel.selectedTab` instead of local `selectedTab`.

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "refactor: bind ContentView tab selection to FanViewModel"`

---

### Task 3: Enable settings trigger in MenuBarPopoverView
**Files:**
- Modify: `Views/MenuBarPopoverView.swift`

- [ ] **Step 1: Uncomment and wire settings action**
  In `Views/MenuBarPopoverView.swift`:
  Uncomment the Settings button block, assigning it the action to set `viewModel.selectedTab` to `.settings` and launch `openMainWindow()`.

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "feat: enable settings panel launch button inside menu bar popover"`

---

### Task 4: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
