# Menu Bar UI Design Spec

## Overview
Improve the MacFanControl menu bar UI/UX by transitioning from a basic macOS text menu to a rich, interactive popover window. This allows users to view system temperatures and adjust fan speeds directly without opening the main application window.

## Architecture & Data Flow
1. **App Entry Point (`FanControlApp.swift`)**
   - Modify the `MenuBarExtra` style to `.menuBarExtraStyle(.window)`.
   - Remove the existing `Group` of basic `Button`s.
   - Inject a new `MenuBarPopoverView` and pass the existing shared `FanViewModel`.

2. **New Component: `MenuBarPopoverView.swift`**
   - A dedicated SwiftUI view representing the content of the menu bar popover.
   - Subscribes to the same `FanViewModel` used by the main `ContentView`.
   - Any changes to `FanViewModel.fans` or `FanViewModel.[sensor]Temp` will immediately propagate to the popover UI.

3. **Interactions**
   - **Target Speed Adjustments:** Moving a slider directly invokes `viewModel.changeFanSpeed(fanId: Int, speed: Int)`.
   - **Mode Toggles:** Switching a fan from Auto to Manual (or vice versa) invokes `viewModel.changeFanMode(fanId: Int, mode: Int)`.
   - **Navigation:** Quick action buttons execute `NSApp.activate` and window visibility toggles to show the main Fan Control Center.

## UI Layout ("Detailed Mini-Dashboard")
The layout mirrors the primary application's aesthetic but scaled for a compact popover context.

### Top Section: Telemetry
A horizontal grid of three cards for real-time sensor metrics:
- **CPU Temp:** Displayed prominently with value and label.
- **GPU Temp:** Displayed next to CPU.
- **Battery Temp:** Displayed next to GPU.

### Middle Section: Fan Controls
A vertical list corresponding to each fan in the system:
- **Fan Info Row:** Displays the Fan Name (e.g., Left Fan) and current active RPM.
- **Mode Toggle:** A small Auto/Manual switch or button.
- **Speed Slider:** A visual slider bound between `minSpeed` and `maxSpeed`.
- **Linked Fans:** If `viewModel.linkedFans` is true, adjusting one fan's slider inherently adjusts all fans (via `viewModel.changeFanSpeed`'s internal linked logic).

### Bottom Section: Quick Actions
- A subtle divider.
- "Open Fan Control Center" button to summon the main window.
- "Reset All to Auto" button.
- "Quit" button to terminate the application.

## Open Questions & Review
- The design relies on the existing shared `FanViewModel`. It's assumed the `FanViewModel` handles throttling of SMC writes if the user drags the slider rapidly. If not, we may need a local throttled state in the slider component. (To be handled during implementation).
