# Design Spec: Reusable Authorization Card Component

This specification details the refactoring of warning alert blocks in the MacFanControl application into a single, reusable SwiftUI view component to enforce the DRY (Don't Repeat Yourself) principle.

## Component Design

1. **AuthorizationRequiredCard**:
   * Create a new file [AuthorizationRequiredCard.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/AuthorizationRequiredCard.swift) inside the `Views` folder.
   * Parameterize the view with a `compact: Bool` flag (defaulting to `false`) to support the two visual formats used across the app layout:
     * **Standard (compact = false)**: Spacing `16`, padding `16`, icon size `20`, corner radius `12`, button padding `10/16` and button corner radius `8`. Used in main dashboard/settings tabs.
     * **Compact (compact = true)**: Spacing `10`, padding `12`, icon size `14`, corner radius `8`, button padding `6/12` and button corner radius `6`. Used in the status menu bar popover dropdown.

---

## Component-Level Details

### 1. Reusable View
*   **File**: [AuthorizationRequiredCard.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/AuthorizationRequiredCard.swift) [NEW]
    *   Expose `viewModel: FanViewModel` and `compact: Bool`.
    *   Build standard card structure.

### 2. View Refactoring
*   **File**: [OverviewTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/OverviewTabView.swift)
    *   Replace inline VStack warn block with `AuthorizationRequiredCard(viewModel: viewModel)`.

*   **File**: [SettingsTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/SettingsTabView.swift)
    *   Replace inline VStack warn block with `AuthorizationRequiredCard(viewModel: viewModel)`.

*   **File**: [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift)
    *   Replace inline VStack warn block with `AuthorizationRequiredCard(viewModel: viewModel, compact: true).padding(.horizontal)`.
