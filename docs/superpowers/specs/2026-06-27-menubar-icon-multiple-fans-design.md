# Design Spec: Menu Bar Icon Multiple Fans Update

This specification details changes to how the custom menu bar status icon selects its speed level, ensuring it evaluates speed states from all active system fans instead of only the first fan.

## Technical Strategy

1. **Max-Speed Selection**:
   * On dual-fan Mac models (e.g. MacBook Pro 14"/16"), fans can spin at different speeds. The status menu bar icon should reflect the overall system thermal state by displaying the speed state of the fastest-spinning fan.
   * Update [FanControlApp.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/App/FanControlApp.swift) to retrieve the maximum `currentSpeed` among all fans in `viewModel.fans`:
     ```swift
     let maxSpeed = viewModel.fans.map { $0.currentSpeed }.max() ?? 0
     ```
   * Pass this maximum speed into `createMenuIcon(speed:)` to choose the appropriate cached image state (0, 1, 2, or 3).

---

## Component-Level Details

### 1. App Entry Scene Menu Bar Label
*   **File**: [FanControlApp.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/App/FanControlApp.swift)
    *   Change the label rendering closure of `MenuBarExtra` to query `viewModel.fans.map { $0.currentSpeed }.max()` when the fans list is not empty, instead of checking only `viewModel.fans.first`.
