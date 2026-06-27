# Design Spec: Modern & Consistent Colors Redesign

This document outlines the color palette changes across all views in the MacFanControl application to achieve a consistent, modern cool-toned look.

## Core Palette
1. **Primary Accent (Teal)**: All interactive buttons, sliders, active tab selections, and main toggles (including the Rules Engine toggle) will use Teal.
2. **Hardware Indicators**:
   - **CPU**: Soft Orange (`Color.orange`)
   - **GPU**: Soft Indigo (`Color.indigo` - changed from Purple for a cleaner cool-toned aesthetic)
   - **Battery**: Soft Green (`Color.green`)
3. **Muted Warnings**: Replace bright orange warning cards with neutral, dark cards featuring a simple orange exclamation icon, preventing visual clutter.

---

## Component-Level Details

### 1. App Shell & Navigation
*   **File**: [ContentView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/ContentView.swift)
    *   No changes needed; sidebar already uses Teal for selections.

### 2. Overview Tab
*   **File**: [OverviewTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/OverviewTabView.swift)
    *   **Authorization Card**:
        *   Background: change from `Color.orange.opacity(0.1)` to `Color.white.opacity(0.03)`
        *   Border: change from `Color.orange.opacity(0.3)` to `Color.white.opacity(0.1)`
        *   Button: change from solid Orange to neutral gray/white (`Color.white.opacity(0.1)` background with `Color.white` text).
    *   **Sensor Indicators**:
        *   GPU Sensor card accent color: change from `.purple` to `.indigo`.

### 3. Settings Tab
*   **File**: [SettingsTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/SettingsTabView.swift)
    *   **Authorization Card**:
        *   Align with OverviewTabView changes (neutral gray/white styling).

### 4. Rules Engine Tab
*   **File**: [RulesEngineView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/RulesEngineView.swift)
    *   **Rules Toggle**: change switch toggle tint from `.purple` to `.teal`.
    *   **Active Rules Border**: change card border when enabled from `.purple.opacity(0.2)` to `.teal.opacity(0.2)`.
    *   **Add Rule Button**: change button text, icon, and background tint from `.purple` to `.teal`.
    *   **Rule Row Elements**:
        *   Row active toggle tint: change from `.green` to `.teal`.
        *   Threshold mode sliders: change accent color from `.purple` to `.teal`.

### 5. Charts & Telemetry
*   **File**: [TempHistoryChartView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/TempHistoryChartView.swift)
    *   GPU sensor color: change from `.purple` to `.indigo`.

*   **File**: [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift)
    *   GPU Telemetry card color: change from `.purple` to `.indigo`.
