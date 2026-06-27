# Memory & Battery Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement dynamic polling intervals based on window/popover state and cache custom SwiftUI menu bar icon image rendering.

**Architecture:** We will optimize SMC polling intervals in `FanViewModel` and avoid redundant drawing operations in `FanControlApp`.
- `FanViewModel`: Add `isAppWindowVisible` and `isMenuBarPopoverVisible` flags. Dynamic timer interval: 1.5s (interactive), 5.0s (background rules enabled), 30.0s (background rules disabled).
- `ContentView` & `MenuBarPopoverView`: Set the flags in `.onAppear`/`.onDisappear`.
- `FanControlApp`: Add a static image cache for the 4 distinct rendering states (0, 1, 2, 3) of the custom menu bar icon.

**Tech Stack:** SwiftUI, AppKit, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Dynamic Polling Rate in FanViewModel
**Files:**
- Modify: `ViewModels/FanViewModel.swift`

- [ ] **Step 1: Add visibility properties and updateTimerFrequency logic**
  In `ViewModels/FanViewModel.swift`, define properties for tracking view visibility and change interval dynamically.

  Replace lines 17-18:
  ```swift
      @Published var isPollingActive: Bool = false
      
      private var isFetchingStatus: Bool = false
  ```
  with:
  ```swift
      @Published var isPollingActive: Bool = false
      
      private var isFetchingStatus: Bool = false
      
      var isAppWindowVisible: Bool = false {
          didSet {
              updateTimerFrequency()
          }
      }
      
      var isMenuBarPopoverVisible: Bool = false {
          didSet {
              updateTimerFrequency()
          }
      }
      
      private var currentInterval: TimeInterval = 1.5
  ```

  Replace lines 119-125:
  ```swift
      func startPolling() {
          timer?.invalidate()
          timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
              self?.updateStatus()
          }
          updateStatus()
      }
  ```
  with:
  ```swift
      func startPolling() {
          updateTimerFrequency()
          updateStatus()
      }
      
      private func updateTimerFrequency() {
          let newInterval: TimeInterval
          if isAppWindowVisible || isMenuBarPopoverVisible {
              newInterval = 1.5
          } else if isRulesEngineEnabled {
              newInterval = 5.0
          } else {
              newInterval = 30.0
          }
          
          if timer == nil || abs(currentInterval - newInterval) > 0.01 {
              currentInterval = newInterval
              timer?.invalidate()
              timer = Timer.scheduledTimer(withTimeInterval: newInterval, repeats: true) { [weak self] _ in
                  self?.updateStatus()
              }
          }
      }
  ```

  Replace lines 26-29 (rules enablement didset):
  ```swift
      @Published var isRulesEngineEnabled: Bool = false {
          didSet {
              UserDefaults.standard.set(isRulesEngineEnabled, forKey: "isRulesEngineEnabled")
              if !isRulesEngineEnabled && wasRuleApplied {
  ```
  with:
  ```swift
      @Published var isRulesEngineEnabled: Bool = false {
          didSet {
              UserDefaults.standard.set(isRulesEngineEnabled, forKey: "isRulesEngineEnabled")
              updateTimerFrequency()
              if !isRulesEngineEnabled && wasRuleApplied {
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "perf: implement dynamic polling interval in FanViewModel"`

---

### Task 2: View Visibility Tracking
**Files:**
- Modify: `Views/ContentView.swift`
- Modify: `Views/MenuBarPopoverView.swift`

- [ ] **Step 1: Set window visibility state in ContentView**
  In `Views/ContentView.swift`:
  Replace lines 64-67:
  ```swift
          .background(WindowAccessor { window in
              window.delegate = MainWindowDelegate.shared
          })
      }
  ```
  with:
  ```swift
          .background(WindowAccessor { window in
              window.delegate = MainWindowDelegate.shared
          })
          .onAppear {
              viewModel.isAppWindowVisible = true
          }
          .onDisappear {
              viewModel.isAppWindowVisible = false
          }
      }
  ```

- [ ] **Step 2: Set popover visibility state in MenuBarPopoverView**
  In `Views/MenuBarPopoverView.swift`:
  Replace lines 89-91:
  ```swift
          }
          .frame(width: 320)
      }
  ```
  with:
  ```swift
          }
          .frame(width: 320)
          .onAppear {
              viewModel.isMenuBarPopoverVisible = true
          }
          .onDisappear {
              viewModel.isMenuBarPopoverVisible = false
          }
      }
  ```

- [ ] **Step 3: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 4: Commit changes**
  Run: `git commit -am "perf: track window and popover visibility to optimize background timer"`

---

### Task 3: Menu Bar Icon Image Caching
**Files:**
- Modify: `App/FanControlApp.swift`

- [ ] **Step 1: Add cache object and use cached image reference in createMenuIcon**
  In `App/FanControlApp.swift`:
  Define `MenuIconCache` and update `createMenuIcon`.

  Replace lines 32-63:
  ```swift
      @MainActor
      private func createMenuIcon(speed: Int) -> Image {
          let view = HStack(spacing: 2) {
              Image(systemName: "fan.fill")
                  .font(.system(size: 14))
                  .foregroundColor(.white)
              
              VStack(spacing: 2) {
                  RoundedRectangle(cornerRadius: 4)
                      .fill(speed >= 5500 ? Color.red : Color.gray.opacity(0.2))
                      .frame(width: 4, height: 4)
                  
                  RoundedRectangle(cornerRadius: 4)
                      .fill(speed >= 3500 ? Color.yellow : Color.gray.opacity(0.2))
                      .frame(width: 4, height: 4)
  
                  RoundedRectangle(cornerRadius: 4)
                      .fill(speed > 0 ? Color.green : Color.gray.opacity(0.2))
                      .frame(width: 4, height: 4)
              }
              .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
          }
          
          let renderer = ImageRenderer(content: view)
          renderer.scale = NSApplication.shared.windows.first?.backingScaleFactor ?? 2.0
          
          if let nsImage = renderer.nsImage {
              return Image(nsImage: nsImage)
          }
          
          return Image(systemName: "fan.fill")
      }
  ```
  with:
  ```swift
      struct MenuIconCache {
          @MainActor static var cache: [Int: Image] = [:]
      }
      
      @MainActor
      private func createMenuIcon(speed: Int) -> Image {
          let state: Int
          if speed >= 5500 {
              state = 3
          } else if speed >= 3500 {
              state = 2
          } else if speed > 0 {
              state = 1
          } else {
              state = 0
          }
          
          if let cached = MenuIconCache.cache[state] {
              return cached
          }
          
          let view = HStack(spacing: 2) {
              Image(systemName: "fan.fill")
                  .font(.system(size: 14))
                  .foregroundColor(.white)
              
              VStack(spacing: 2) {
                  RoundedRectangle(cornerRadius: 4)
                      .fill(state >= 3 ? Color.red : Color.gray.opacity(0.2))
                      .frame(width: 4, height: 4)
                  
                  RoundedRectangle(cornerRadius: 4)
                      .fill(state >= 2 ? Color.yellow : Color.gray.opacity(0.2))
                      .frame(width: 4, height: 4)
  
                  RoundedRectangle(cornerRadius: 4)
                      .fill(state >= 1 ? Color.green : Color.gray.opacity(0.2))
                      .frame(width: 4, height: 4)
              }
              .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
          }
          
          let renderer = ImageRenderer(content: view)
          renderer.scale = 2.0
          
          if let nsImage = renderer.nsImage {
              let img = Image(nsImage: nsImage)
              MenuIconCache.cache[state] = img
              return img
          }
          
          return Image(systemName: "fan.fill")
      }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "perf: cache rendered menu bar icons to eliminate main thread rendering overhead"`

---

### Task 4: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
