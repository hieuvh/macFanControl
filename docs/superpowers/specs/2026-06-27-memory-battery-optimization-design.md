# Design Spec: Memory & Battery Efficiency Optimization

This specification outlines the technical design for optimizing CPU usage, memory allocations, and battery consumption in the MacFanControl macOS application.

## Optimization Strategy

1. **Menu Bar Icon Render Caching (Battery & CPU)**:
   * **Problem**: The app currently re-renders the custom SwiftUI menu bar icon using `ImageRenderer` on the main thread every 1.5 seconds whenever the first fan's speed updates. Rendering a view hierarchy into a bitmap is extremely expensive and causes continuous background CPU overhead.
   * **Solution**: Since the custom icon only has 4 distinct visual states (Offline, Low, High, Max speed levels), we will cache the rendered `Image` objects in a `@MainActor`-bound static dictionary. Once rendered, the cached images will be reused, dropping main-thread rendering CPU usage to 0%.

2. **Dynamic Polling Rate (Battery & CPU)**:
   * **Problem**: The app always polls 29 SMC keys every 1.5 seconds, even when it is in the background or hidden. Waking up the CPU constantly to query hardware ports drains the battery.
   * **Solution**: Adjust the polling interval dynamically based on whether the user is actively viewing the application:
     * **High Rate (1.5s)**: Active when either the main application window is open or the menu bar extra popover is visible.
     * **Medium Rate (5.0s)**: Active when in the background, but the Rules Engine is enabled (for safety and rules evaluation).
     * **Low Rate (30.0s)**: Active when in the background and the Rules Engine is disabled (simply to record history logs every 30 seconds).

---

## Component-Level Details

### 1. View Model & Polling Logic
*   **File**: [FanViewModel.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/ViewModels/FanViewModel.swift)
    *   Add `isAppWindowVisible` and `isMenuBarPopoverVisible` properties.
    *   Add `updateTimerFrequency()` method that recalculates the optimal polling interval (1.5s, 5s, or 30s) and resets the timer accordingly.
    *   Call `updateTimerFrequency()` in the `didSet` block of `isRulesEngineEnabled` and the new visibility parameters.

### 2. View Life-Cycle Observers
*   **File**: [ContentView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/ContentView.swift)
    *   Add `.onAppear` and `.onDisappear` blocks on the main root view to update `viewModel.isAppWindowVisible`.

*   **File**: [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift)
    *   Add `.onAppear` and `.onDisappear` blocks on the main root view to update `viewModel.isMenuBarPopoverVisible`.

### 3. App Entry Point & Menu Icon Cache
*   **File**: [FanControlApp.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/App/FanControlApp.swift)
    *   Introduce `MenuIconCache` struct containing a `@MainActor` static cache dictionary.
    *   Optimize `createMenuIcon(speed: Int)` to fetch from the cache first based on the 4 visual states (Offline, Low, High, Max) before executing a draw command.
