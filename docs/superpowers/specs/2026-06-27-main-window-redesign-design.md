# Main App Window Redesign Design Spec

## Overview
Redesign the main Fan Control Center (`ContentView`) to move away from a single vertical scroll feed into a premium, modern dashboard. The app will adopt a "Custom Glassmorphic" aesthetic with a sidebar navigation structure to better organize the growing feature set (fans, rules, settings).

## Architectural Structure
The main window will be split into two primary areas:
1. **Sidebar Navigation (Left):** A slim navigation column.
   - Tabs: Overview, Rules Engine, Settings.
2. **Main Content Area (Right):** The active view based on sidebar selection.

## Aesthetic Direction: Custom Glassmorphic Premium
- **Window Style:** Borderless, hidden title bar (`HiddenTitleBarWindowStyle`).
- **Backgrounds:** Deep dark backgrounds (e.g., `#0F1218`) contrasted with vibrant, blurred "glowing orbs" (teal, orange) positioned behind frosted glass panels (`.ultraThinMaterial` or custom blur).
- **Elements:** Heavily rounded panels, no hard edges. Clean typography using Apple's system fonts but styled to look like a premium pro tool.

## Key Views

### 1. Overview Tab
The default landing page.
- **Hero Fan Section:** The primary fan is featured prominently at the top in a massive, dramatic circular dial displaying current RPM, Target RPM, and percentage.
- **Compact Sensors Grid:** Below the hero fan, critical telemetry (CPU Temp, GPU Temp, Battery Temp, and any secondary fans) are displayed in smaller, compact glass cards.

### 2. Rules Engine Tab
- Moves the `RulesEngineView` out of the main scroll feed into its own dedicated space.
- Allows for complex rules configuration without cluttering the basic fan controls.

### 3. Settings / Global Controls
- Houses the "Authorization Required" setup.
- Global toggles like "Sync All Fans Together" and "Reset All to Auto".

## Implementation Strategy
- **Refactoring `ContentView.swift`:** Will be converted to hold the state for the selected sidebar tab and the sidebar UI itself.
- **New Components:**
  - `OverviewTabView`: The new hero fan layout.
  - `HeroFanDial`: A new massive circular progress/gauge view for the primary fan.
  - `CompactSensorCard`: Redesigned `TempMetricCard` to fit the glassmorphic aesthetic.
- **Routing:** A simple enum `DashboardTab { case overview, rules, settings }` will drive the main content area.

## Tradeoffs & Considerations
- **Window Resizing:** A dashboard layout requires thoughtful minimum width/height constraints so the sidebar and hero fan don't get squished.
- **Performance:** Extensive use of `backdrop-filter` (blur) and background gradients can impact rendering performance. We must ensure blurs are applied efficiently and not overused in scrolling lists.

## Verification
- Ensure the app launches in the new Dashboard view.
- Verify that navigating between Overview, Rules, and Settings works instantly.
- Verify the glowing orbs and glassmorphic panels render correctly in Dark Mode.
