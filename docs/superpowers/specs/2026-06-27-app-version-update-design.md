# Design Spec: Version 3.0 Update & Info Display

This specification details the task of updating the application version to 3.0 and adding a clean version display section in the settings tab.

## Technical Strategy

1. **Info.plist Update**:
   * Modify the bundle builder script [build.sh](file:///Users/hieuvh/Developer/projects/MacFanControl/build.sh) to write `3.0` for `CFBundleShortVersionString`.

2. **Settings Tab Display**:
   * Add a version footer at the bottom of [SettingsTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/SettingsTabView.swift).
   * Retrieve the version dynamically using `Bundle.main.infoDictionary` to ensure it always matches the compiled bundle metadata.
   * Render the text using a clean, monospaced style aligned to the center.

---

## Component-Level Details

### 1. Build script
*   **File**: [build.sh](file:///Users/hieuvh/Developer/projects/MacFanControl/build.sh)
    *   Change `CFBundleShortVersionString` value from `2.0` to `3.0`.

### 2. Settings tab
*   **File**: [SettingsTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/SettingsTabView.swift)
    *   Append a center-aligned `HStack` containing version and build info beneath the global controls container.
