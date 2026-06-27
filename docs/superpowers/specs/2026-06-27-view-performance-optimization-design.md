# Design Spec: View Performance & Memory Optimization

This specification outlines technical optimizations in the SwiftUI view layer of the MacFanControl application to reduce memory consumption, eliminate orphaned files, and prevent background CPU rendering cycles.

## Optimization Strategy

1. **Delete Unused/Orphaned Views**:
   * **Problem**: `TempMetricCard.swift` is an orphaned file that was replaced by `CompactSensorCard.swift` in a previous design iteration.
   * **Solution**: Delete `Views/TempMetricCard.swift` to clean up the codebase.

2. **Pause Hidden Timeline Animations (CPU & Battery)**:
   * **Problem**: `SpinningFanView` uses `TimelineView(.animation)` which ticks at 60Hz/120Hz to spin the vector fan icon. Even when the app window is closed and hidden in the background, or when the menu bar popover is closed, the view hierarchy remains in memory, causing the timeline to keep ticking, mutating `@State angle`, and wasting battery.
   * **Solution**: Add an `isActive` boolean parameter to `SpinningFanView` and use it to pause the timeline when the respective view container is hidden:
     * Pause the dial fan animation in the main window when `viewModel.isAppWindowVisible` is `false`.
     * Pause the menu bar fan row animation when `viewModel.isMenuBarPopoverVisible` is `false`.

3. **Single-Pass Array Calculations (CPU & Memory)**:
   * **Problem**: `TempHistoryChartView` executes 4 separate `.map` / `.reduce` iterations over the entire history array on every single body render (including hover states, which occur on every pixel of mouse movements). This causes excessive allocations and overhead.
   * **Solution**: Refactor statistics calculations into a single O(N) pass, avoiding redundant array mapping allocations and O(N) traversals.

---

## Component-Level Details

### 1. Orphaned View Cleanup
*   **File**: [TempMetricCard.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/TempMetricCard.swift) [DELETE]
    *   Delete the file from the workspace.

### 2. Timeline Animation Pausing
*   **File**: [SpinningFanView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/SpinningFanView.swift)
    *   Add `var isActive: Bool = true`.
    *   Update timeline configuration: `.animation(paused: currentSpeed == 0 || !isActive)`.
*   **File**: [HeroFanDial.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/HeroFanDial.swift)
    *   Pass `viewModel.isAppWindowVisible` to `SpinningFanView`.
*   **File**: [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift)
    *   Pass `viewModel.isMenuBarPopoverVisible` to `SpinningFanView`.

### 3. Chart Computation Refactoring
*   **File**: [TempHistoryChartView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/TempHistoryChartView.swift)
    *   Refactor `points`, `statsMin`, `statsMax`, and `statsAvg` logic to compute values inside a single loop iteration.
