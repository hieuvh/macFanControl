# Design Spec: Minimalist & Professional App Text

This document outlines the changes to text copy and typography styling across all views in the MacFanControl application to establish a minimalist and professional look (Swiss Style).

## Key Themes
1. **Softened Weights**: Replace all high-contrast heavy weights (e.g. `.black` or heavy `.bold` fonts) with `.medium` or `.semibold` weights.
2. **Concise Copy**: Simplify verbose descriptions and button text. Remove exclamation marks and extra descriptions where the actions are self-explanatory.
3. **Consistent Casing**: Standardize labels to clean sentence-case or selective uppercase (rather than harsh all-caps titles).
4. **Clean Sizing**: Reduce title sizes slightly (e.g., Settings header from `28` to `20`) to blend better with native macOS system components.

---

## Component-Level Details

### 1. Main Navigation & Shell
*   **File**: [ContentView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/ContentView.swift)
    *   Change Title "Fan Control" to `"fan control"` or `"Fan Control"` in lowercase/clean styling with font weight `.medium` (size 16) instead of `.black` (size 18).
    *   Change sidebar navigation buttons:
        *   "Rules Engine" label -> "Rules"
        *   Sidebar button title weight from `.semibold` to `.medium`

### 2. Overview Tab
*   **File**: [OverviewTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/OverviewTabView.swift)
    *   Authentication alert card:
        *   "Helper Authentication Required" -> "Authorization required"
        *   "You need to authorize Fan Control to adjust fan speeds and read precise hardware sensors." -> "Authorize to manage fan speeds and read hardware sensors."
        *   Button "Authorize & Enable Fan Adjustments" -> "Authorize"
    *   Sensor card titles: "BATTERY" -> "Battery"

### 3. Fan Controls & Dial
*   **File**: [HeroFanDial.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/HeroFanDial.swift)
    *   Slider label "Target" -> Change weight from `.semibold` to `.medium`
    *   Speed display value (e.g., `\(Int(sliderVal)) RPM`) -> Change weight from `.bold` to `.medium`
    *   Presets buttons ("Auto", "20%", etc.) -> Change weight from `.bold` to `.medium`
    *   Fan Name title -> Change from `size: 18, weight: .black` to `size: 15, weight: .medium`

*   **File**: [CompactSensorCard.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/CompactSensorCard.swift)
    *   Temperature text -> Change from `size: 20, weight: .bold` to `size: 18, weight: .medium`
    *   Sensor Title -> Change from `weight: .semibold` to `weight: .medium`
    *   Chevron down -> Change from `weight: .bold` to `weight: .medium`

### 4. Settings Tab
*   **File**: [SettingsTabView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/SettingsTabView.swift)
    *   Title "Settings" -> Change from `size: 28, weight: .black` to `size: 20, weight: .semibold`
    *   Authentication alert card (same as Overview):
        *   "Helper Authentication Required" -> "Authorization required"
        *   "You need to authorize Fan Control to adjust fan speeds and read precise hardware sensors." -> "Authorize to manage fan speeds and read hardware sensors."
        *   Button "Authorize & Enable Fan Adjustments" -> "Authorize"
    *   Section title "Global Controls" -> Change from `size: 16, weight: .bold` to `size: 14, weight: .semibold`
    *   Button "Reset All to Auto" -> "Reset to auto" with weight `.medium` instead of `.bold`

### 5. Rules Tab
*   **File**: [RulesEngineView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/RulesEngineView.swift)
    *   Header "Auto-Trigger Rules Engine" -> "Rules engine"
    *   Header font size/weight -> Change from `size: 14, weight: .bold` to `size: 13, weight: .semibold`
    *   Description "Automatically override fan speeds when sensors cross temperature thresholds." -> "Override fan speeds based on temperature thresholds."
    *   "Add Custom Trigger Rule" -> "Add rule"
    *   Rule Row View elements:
        *   "If" -> "if"
        *   "If temp ≥" -> "if temp ≥"
        *   "Set speed to" -> "set speed to"
        *   "Temp range:" -> "temp range:"
        *   "to" -> "to"
        *   "Speed range:" -> "speed range:"
        *   Slider values weight -> Change from `.bold` to `.medium`

### 6. Mini Temperature & Chart Components
*   **File**: [TempMetricCard.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/TempMetricCard.swift)
    *   Title text -> Change from `weight: .bold` to `weight: .medium`
    *   Temperature text -> Change from `size: 14, weight: .bold` to `size: 13, weight: .medium`
    *   Chevron -> Change from `weight: .bold` to `weight: .medium`

*   **File**: [TempHistoryChartView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/TempHistoryChartView.swift)
    *   Sensor names: "CPU Die" -> "CPU", "GPU proximity" -> "GPU", "Battery" -> "Battery"
    *   Header: `"\(sensorName) Temperature History"` -> `"\(sensorName) history"` or `"\(sensorName) temperature history"`
    *   Header styling -> Change weight from `.bold` to `.semibold`
    *   "No temperature data recorded yet." -> "No temperature data recorded."
    *   Stats labels: "CURRENT" -> "current", "AVERAGE" -> "average", "MIN / MAX" -> "min / max"
    *   Stats values -> Change weight from `.bold` to `.medium`

### 7. Menu Bar Dropdown
*   **File**: [MenuBarPopoverView.swift](file:///Users/hieuvh/Developer/projects/MacFanControl/Views/MenuBarPopoverView.swift)
    *   TelemetryCard label: "BATTERY" -> "Battery"
    *   TelemetryCard value -> Change weight from `.bold` to `.medium` (size 18 instead of 20)
    *   MenuBarFanRow title -> Change weight from `.bold` to `.medium`
    *   Presets button -> Change weight from `.bold` to `.medium` (size 9 instead of 10)
    *   Help tooltips: "Reset All to Auto" -> "Reset to auto", "Sync All Fans Together" -> "Link fans"
