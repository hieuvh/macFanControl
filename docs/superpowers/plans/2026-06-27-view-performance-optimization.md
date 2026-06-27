# View Performance & Memory Optimization Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up unused view code, pause timeline animations when windows/popovers are hidden, and optimize SwiftUI charts state evaluation.

**Architecture:**
- Delete `Views/TempMetricCard.swift`.
- Update `SpinningFanView` and its parent layouts to pass and react to window/popover visibility states, halting the timeline execution.
- Single-pass array traversals inside `TempHistoryChartView` to optimize CPU during hover events.

**Tech Stack:** SwiftUI, Charts, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Delete Unused Views/TempMetricCard.swift
**Files:**
- Delete: `Views/TempMetricCard.swift`

- [ ] **Step 1: Delete TempMetricCard.swift**
  Run: `rm Views/TempMetricCard.swift`

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "cleanup: remove unused orphaned TempMetricCard view file"`

---

### Task 2: Update SpinningFanView to support isActive parameter
**Files:**
- Modify: `Views/SpinningFanView.swift`

- [ ] **Step 1: Update view definition and timeline pausing condition**
  In `Views/SpinningFanView.swift`:
  Replace lines 4-9:
  ```swift
  struct SpinningFanView: View, Animatable {
      var currentSpeed: Double
      let maxSpeed: Double
      var size: CGFloat = 80 // Default size for main app
      @State private var angle: Double = 0.0
  ```
  with:
  ```swift
  struct SpinningFanView: View, Animatable {
      var currentSpeed: Double
      let maxSpeed: Double
      var size: CGFloat = 80 // Default size for main app
      var isActive: Bool = true
      @State private var angle: Double = 0.0
  ```

  Replace line 16:
  ```swift
          TimelineView(.animation(paused: currentSpeed == 0)) { timeline in
  ```
  with:
  ```swift
          TimelineView(.animation(paused: currentSpeed == 0 || !isActive)) { timeline in
  ```

- [ ] **Step 2: Verify compilation**
  Wait! The parent files (HeroFanDial, MenuBarPopoverView) still call `SpinningFanView(...)` but since `isActive` has a default value of `true`, this will build fine.
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "perf: add isActive toggle to SpinningFanView to pause background animation updates"`

---

### Task 3: Bind View Visibility to SpinningFanView
**Files:**
- Modify: `Views/HeroFanDial.swift`
- Modify: `Views/MenuBarPopoverView.swift`

- [ ] **Step 1: Feed visibility state in HeroFanDial**
  In `Views/HeroFanDial.swift`:
  Let's find the `SpinningFanView` line and pass `isActive: viewModel.isAppWindowVisible`.
  Let's check the lines around 25-30:
  ```swift
                  SpinningFanView(currentSpeed: animatableSpeed, maxSpeed: Double(fan.maxSpeed))
  ```
  with:
  ```swift
                  SpinningFanView(currentSpeed: animatableSpeed, maxSpeed: Double(fan.maxSpeed), isActive: viewModel.isAppWindowVisible)
  ```

- [ ] **Step 2: Feed visibility state in MenuBarPopoverView**
  In `Views/MenuBarPopoverView.swift`:
  Let's find the `SpinningFanView` line and pass `isActive: viewModel.isMenuBarPopoverVisible`.
  Let's check the lines around 145-155 (which is inside MenuBarFanRow):
  ```swift
                  SpinningFanView(currentSpeed: animatableSpeed, maxSpeed: Double(fan.maxSpeed), size: 24)
  ```
  with:
  ```swift
                  SpinningFanView(currentSpeed: animatableSpeed, maxSpeed: Double(fan.maxSpeed), size: 24, isActive: viewModel.isMenuBarPopoverVisible)
  ```

- [ ] **Step 3: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 4: Commit changes**
  Run: `git commit -am "perf: bind app window and popover visibility to SpinningFanView active status"`

---

### Task 4: Optimize TempHistoryChartView Rendering Stats
**Files:**
- Modify: `Views/TempHistoryChartView.swift`

- [ ] **Step 1: Perform stats calculation in a single pass**
  In `Views/TempHistoryChartView.swift`:
  Replace lines 58-68:
  ```swift
          let points = history
              .compactMap { record -> ChartPoint? in
                  if let val = valueForSensor(record) {
                      return ChartPoint(time: record.timestamp, value: val)
                  }
                  return nil
              }
          
          let statsMin = points.map { $0.value }.min() ?? 0
          let statsMax = points.map { $0.value }.max() ?? 0
          let statsAvg = points.isEmpty ? 0 : points.map { $0.value }.reduce(0, +) / Double(points.count)
  ```
  with:
  ```swift
          var statsMin: Double = 0
          var statsMax: Double = 0
          var statsAvg: Double = 0
          
          let points = history.compactMap { record -> ChartPoint? in
              if let val = valueForSensor(record) {
                  return ChartPoint(time: record.timestamp, value: val)
              }
              return nil
          }
          
          if !points.isEmpty {
              var minVal = points[0].value
              var maxVal = points[0].value
              var sumVal: Double = 0
              for pt in points {
                  if pt.value < minVal { minVal = pt.value }
                  if pt.value > maxVal { maxVal = pt.value }
                  sumVal += pt.value
              }
              statsMin = minVal
              statsMax = maxVal
              statsAvg = sumVal / Double(points.count)
          }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "perf: implement O(N) single-pass statistics calculation in TempHistoryChartView"`

---

### Task 5: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
