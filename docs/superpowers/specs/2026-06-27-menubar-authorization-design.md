# Design Spec: Menu Bar Popover Authorization Request

This document details the interface addition to support SMC helper authorization directly from the macOS status menu bar popover dropdown when the app is unauthorized.

## Accent & Layout Strategy

1. **Conditional Alert Card**:
   * When `viewModel.isAuthorized` is `false`, we will display a compact, orange-themed helper authorization card inside the menu bar popover.
   * To keep popover height consistent, this card will replace the "Middle Section: Fans" (which is empty when unauthorized).
   * Styling will mirror the main application's caution styling (orange background opacity, orange stroke border, solid orange trigger button, black text).

2. **Trigger Action**:
   * The button inside the card will call `viewModel.authorize()`, prompting the user with the standard macOS administrator privileges prompt.

---

## Component-Level Details

### 1. Menu Bar Popover
*   **File**: [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift)
    *   In the body hierarchy, wrap the middle fan rows iteration in an `if-else` check:
        *   `if !viewModel.isAuthorized`: Render the compact Setup warning card with the Action button.
        *   `else`: Render the standard list of fan control rows.
