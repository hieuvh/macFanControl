# Design Spec: Launch at Startup Setting

This specification details the technical design for adding a "Launch at startup" option to the Settings tab, utilizing the modern macOS `SMAppService` API.

## Technical Strategy

1. **ServiceManagement Integration**:
   * Use macOS 13.0's `SMAppService.mainApp` to register or unregister the main application bundle to launch at login. This is the modern, battery-efficient, and sandbox-compatible API.
   * `SMAppService` manages registration dynamically without requiring custom launch helper binaries or modifications to the login items file list.

2. **View Model & Settings Binding**:
   * Add a `@Published var launchAtStartup: Bool` property to `FanViewModel`.
   * Bind the toggle in `SettingsTabView` directly to this property.
   * Upon initialization of the view model, check `SMAppService.mainApp.status` to reflect the correct system setting state in the UI toggle.

---

## Component-Level Details

### 1. View Model Status & Register Logic
*   **File**: [FanViewModel.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/ViewModels/FanViewModel.swift)
    *   Import `ServiceManagement`.
    *   Add `@Published var launchAtStartup: Bool` with a `didSet` observer calling `setLaunchAtStartup(enabled:)`.
    *   Add helper methods `checkLaunchAtStartupStatus()` and `setLaunchAtStartup(enabled:)` using `SMAppService`.
    *   Call `checkLaunchAtStartupStatus()` in `init()`.

### 2. Settings View Toggle
*   **File**: [SettingsTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/SettingsTabView.swift)
    *   Add a new `Toggle("Launch at startup", isOn: $viewModel.launchAtStartup)` inside the "Global controls" section.
