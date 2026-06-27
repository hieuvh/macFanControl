# Design Spec: Open Settings from Menu Bar

This specification details the design for enabling the "Settings" button in the menu bar popover to launch the main application window and focus the settings tab directly.

## Technical Strategy

1. **State Relocation (Tab Navigation Binding)**:
   * Currently, `selectedTab` is local `@State` inside `ContentView.swift`.
   * To enable external control, move `selectedTab` into `FanViewModel` as a `@Published` property of type `DashboardTab`.
   * Refactor tab selection links inside `ContentView.swift` to bind to `viewModel.selectedTab`.

2. **Menu Bar Settings Button**:
   * Uncomment and adapt the settings button inside the bottom action toolbar of [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift).
   * Update the button's action handler:
     1. Set `viewModel.selectedTab` to `.settings`.
     2. Invoke `openMainWindow()` to bring the settings view to the front.

---

## Component-Level Details

### 1. View Model Tab State
*   **File**: [FanViewModel.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/ViewModels/FanViewModel.swift)
    *   Add `@Published var selectedTab: DashboardTab = .overview`.

### 2. Main Shell Navigation Refactoring
*   **File**: [ContentView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/ContentView.swift)
    *   Remove `@State private var selectedTab: DashboardTab`.
    *   Update sidebar buttons and content switch statements to utilize `viewModel.selectedTab`.

### 3. Menu Bar Popover Button
*   **File**: [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift)
    *   Uncomment the Settings button.
    *   Assign the action block:
        ```swift
        viewModel.selectedTab = .settings
        openMainWindow()
        ```
