# Balanced Overview Tab Layout Design

## Goal
Constrain the maximum width of the Overview Tab content to ensure it stays compact, balanced, and centered on wide desktop windows, while remaining fully responsive when the window is shrunk.

## Problem Context
Currently, the `OverviewTabView` scales infinitely horizontally. On a large external display, this causes the Hero Fan dials and the compact sensor cards to stretch awkwardly to the edges of the window, leaving massive amounts of empty space and reducing visual cohesion.

## Implementation Details

### 1. View Containment
The primary `VStack` within `OverviewTabView` will be constrained using SwiftUI frame modifiers:

```swift
ScrollView {
    VStack(spacing: 24) {
        // ... all overview content ...
    }
    .padding(32)
    .frame(maxWidth: 800)        // 1. Restrict maximum width
    .frame(maxWidth: .infinity)  // 2. Center within the ScrollView's full width
}
```

### 2. Layout Behavior
* **Wide Windows (>800px):** The content stops growing at 800px and sits perfectly centered in the window. The margins grow dynamically.
* **Narrow Windows (<800px):** The `maxWidth: 800` acts as a soft constraint, allowing the content to shrink responsively alongside the window. The fans' `LazyHGrid` horizontal scroll view and the sensors' `LazyVGrid` wrap normally.

## Verification
- Resize the main window to be extremely wide. The Overview tab content should remain centered at 800px.
- Shrink the window below 800px. The content should shrink gracefully without clipping.
