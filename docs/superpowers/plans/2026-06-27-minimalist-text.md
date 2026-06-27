# Minimalist & Professional Text Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update all text copy and typography styling across all view components to deliver a minimalist, clean, and professional appearance (Swiss Style).

**Architecture:** We will systematically modify SwiftUI view files, replacing heavy font weights (.black, heavy .bold) with clean, light/medium weights, reducing font sizes where appropriate, and updating verbose copy/tooltips to be extremely concise. We will check the build after each group of edits.

**Tech Stack:** SwiftUI, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.
- Typography updates must focus on `.medium` and `.semibold` weights instead of `.black` or heavy `.bold` fonts.

---

### Task 1: ContentView Navigation Updates
**Files:**
- Modify: `Views/ContentView.swift`

- [ ] **Step 1: Simplify navigation title and button typography**
  Change the title from bold black `"Fan Control"` to medium `"Fan Control"` (size 16) or lowercase `"fan control"`.
  Change navigation items font weights to `.medium` and rename `"Rules Engine"` to `"Rules"`.

  Replace lines 18-22:
  ```swift
                  VStack(alignment: .leading, spacing: 4) {
                      Text("Fan Control")
                          .font(.system(size: 18, weight: .black))
                          .foregroundColor(.white)
                  }
  ```
  with:
  ```swift
                  VStack(alignment: .leading, spacing: 4) {
                      Text("fan control")
                          .font(.system(size: 16, weight: .medium))
                          .foregroundColor(.white.opacity(0.9))
                  }
  ```

  Replace line 29:
  ```swift
                  SidebarButton(title: "Rules Engine", icon: "bolt.fill", isSelected: selectedTab == .rules) {
  ```
  with:
  ```swift
                  SidebarButton(title: "Rules", icon: "bolt.fill", isSelected: selectedTab == .rules) {
  ```

  Replace lines 82-84:
  ```swift
                  Text(title)
                      .font(.system(size: 14, weight: .semibold))
  ```
  with:
  ```swift
                  Text(title)
                      .font(.system(size: 13, weight: .medium))
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success without errors.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "ui: simplify ContentView navigation text and typography"`

---

### Task 2: Overview & Sensor Card Component Updates
**Files:**
- Modify: `Views/OverviewTabView.swift`
- Modify: `Views/CompactSensorCard.swift`
- Modify: `Views/TempMetricCard.swift`

- [ ] **Step 1: Simplify Overview Tab copy and headers**
  Simplify authorization error text and update sensor titles to standard casing.

  In `Views/OverviewTabView.swift`:
  Replace lines 20-22:
  ```swift
                              Text("Helper Authentication Required")
                                  .font(.system(size: 16, weight: .bold))
  ```
  with:
  ```swift
                              Text("Authorization required")
                                  .font(.system(size: 14, weight: .semibold))
  ```

  Replace lines 24-26:
  ```swift
                          Text("You need to authorize Fan Control to adjust fan speeds and read precise hardware sensors.")
                              .font(.system(size: 13))
                              .foregroundColor(.gray)
  ```
  with:
  ```swift
                          Text("Authorize to manage fan speeds and read hardware sensors.")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
  ```

  Replace lines 29-30:
  ```swift
                              Text("Authorize & Enable Fan Adjustments")
                                  .font(.system(size: 13, weight: .bold))
  ```
  with:
  ```swift
                              Text("Authorize")
                                  .font(.system(size: 12, weight: .medium))
  ```

  Replace line 73:
  ```swift
                      CompactSensorCard(title: "BATTERY", temp: viewModel.batteryTemp, iconName: "battery.100.bolt", color: .green)
  ```
  with:
  ```swift
                      CompactSensorCard(title: "Battery", temp: viewModel.batteryTemp, iconName: "battery.100.bolt", color: .green)
  ```

- [ ] **Step 2: Standardize Compact Sensor Card typography**
  In `Views/CompactSensorCard.swift`:
  Replace line 18:
  ```swift
                      .font(.system(size: 12, weight: .bold))
  ```
  with:
  ```swift
                      .font(.system(size: 11, weight: .medium))
  ```

  Replace lines 23-28:
  ```swift
                      Text(String(format: "%.1f°C", t))
                          .font(.system(size: 20, weight: .bold, design: .monospaced))
                  } else {
                      Text(verbatim: "--")
                          .font(.system(size: 20, weight: .bold, design: .monospaced))
  ```
  with:
  ```swift
                      Text(String(format: "%.1f°C", t))
                          .font(.system(size: 18, weight: .medium, design: .monospaced))
                  } else {
                      Text(verbatim: "--")
                          .font(.system(size: 18, weight: .medium, design: .monospaced))
  ```

  Replace line 30:
  ```swift
                      .font(.system(size: 10, weight: .semibold))
  ```
  with:
  ```swift
                      .font(.system(size: 10, weight: .medium))
  ```

- [ ] **Step 3: Standardize Temp Metric Card typography**
  In `Views/TempMetricCard.swift`:
  Replace line 25:
  ```swift
                      .font(.system(size: 9, weight: .bold))
  ```
  with:
  ```swift
                      .font(.system(size: 9, weight: .medium))
  ```

  Replace lines 31-42:
  ```swift
                  if let t = temp {
                      Text(String(format: "%.1f°C", t))
                          .font(.system(size: 14, weight: .bold, design: .monospaced))
                          .foregroundColor(.white)
                          .lineLimit(1)
                          .minimumScaleFactor(0.8)
                  } else {
                      Text("--")
                          .font(.system(size: 14, weight: .bold, design: .monospaced))
                          .foregroundColor(.gray)
                          .lineLimit(1)
                  }
  ```
  with:
  ```swift
                  if let t = temp {
                      Text(String(format: "%.1f°C", t))
                          .font(.system(size: 13, weight: .medium, design: .monospaced))
                          .foregroundColor(.white)
                          .lineLimit(1)
                          .minimumScaleFactor(0.8)
                  } else {
                      Text("--")
                          .font(.system(size: 13, weight: .medium, design: .monospaced))
                          .foregroundColor(.gray)
                          .lineLimit(1)
                  }
  ```

  Replace line 48:
  ```swift
                  .font(.system(size: 9, weight: .bold))
  ```
  with:
  ```swift
                  .font(.system(size: 9, weight: .medium))
  ```

- [ ] **Step 4: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success without errors.

- [ ] **Step 5: Commit changes**
  Run: `git commit -am "ui: make sensor cards and overview tab typography minimalist and clean"`

---

### Task 3: Hero Fan Dial Updates
**Files:**
- Modify: `Views/HeroFanDial.swift`

- [ ] **Step 1: Simplify Fan Dial typography and labels**
  Change Target labels, RPM formatting, preset button fonts, and the fan name style to look much cleaner.

  In `Views/HeroFanDial.swift`:
  Replace line 37:
  ```swift
                          .font(.system(size: 12, weight: .semibold))
  ```
  with:
  ```swift
                          .font(.system(size: 11, weight: .medium))
  ```

  Replace line 41:
  ```swift
                          .font(.system(size: 12, weight: .bold, design: .monospaced))
  ```
  with:
  ```swift
                          .font(.system(size: 11, weight: .medium, design: .monospaced))
  ```

  Replace line 76:
  ```swift
                      .font(.system(size: 18, weight: .black))
  ```
  with:
  ```swift
                      .font(.system(size: 15, weight: .medium))
  ```

  Replace line 154:
  ```swift
                  .font(.system(size: 11, weight: .bold, design: .monospaced))
  ```
  with:
  ```swift
                  .font(.system(size: 10, weight: .medium, design: .monospaced))
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success without errors.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "ui: simplify HeroFanDial typography and layout labels"`

---

### Task 4: Settings Tab Updates
**Files:**
- Modify: `Views/SettingsTabView.swift`

- [ ] **Step 1: Simplify Settings page text**
  Make the settings header, authentication card, and Reset button clean and concise.

  In `Views/SettingsTabView.swift`:
  Replace lines 9-10:
  ```swift
                  Text("Settings")
                      .font(.system(size: 28, weight: .black))
  ```
  with:
  ```swift
                  Text("Settings")
                      .font(.system(size: 20, weight: .semibold))
  ```

  Replace lines 19-21:
  ```swift
                              Text("Helper Authentication Required")
                                  .font(.system(size: 16, weight: .bold))
  ```
  with:
  ```swift
                              Text("Authorization required")
                                  .font(.system(size: 14, weight: .semibold))
  ```

  Replace lines 23-25:
  ```swift
                          Text("You need to authorize Fan Control to adjust fan speeds and read precise hardware sensors.")
                              .font(.system(size: 13))
                              .foregroundColor(.gray)
  ```
  with:
  ```swift
                          Text("Authorize to manage fan speeds and read hardware sensors.")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
  ```

  Replace lines 28-29:
  ```swift
                              Text("Authorize & Enable Fan Adjustments")
                                  .font(.system(size: 13, weight: .bold))
  ```
  with:
  ```swift
                              Text("Authorize")
                                  .font(.system(size: 12, weight: .medium))
  ```

  Replace line 51:
  ```swift
                          .font(.system(size: 16, weight: .bold))
  ```
  with:
  ```swift
                          .font(.system(size: 13, weight: .semibold))
  ```

  Replace lines 57-59:
  ```swift
                          Text("Reset All to Auto")
                              .font(.system(size: 13, weight: .bold))
  ```
  with:
  ```swift
                          Text("Reset to auto")
                              .font(.system(size: 12, weight: .medium))
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success without errors.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "ui: simplify Settings tab copy and typography"`

---

### Task 5: Rules Engine Updates
**Files:**
- Modify: `Views/RulesEngineView.swift`

- [ ] **Step 1: Clean up Rules Engine text**
  Simplify headings, button actions, and rule configuration row typography.

  In `Views/RulesEngineView.swift`:
  Replace lines 14-16:
  ```swift
                          Text("Auto-Trigger Rules Engine")
                              .font(.system(size: 14, weight: .bold))
  ```
  with:
  ```swift
                          Text("Rules engine")
                              .font(.system(size: 13, weight: .semibold))
  ```

  Replace lines 18-20:
  ```swift
                      Text("Automatically override fan speeds when sensors cross temperature thresholds.")
                          .font(.system(size: 11))
  ```
  with:
  ```swift
                      Text("Override fan speeds based on temperature thresholds.")
                          .font(.system(size: 11))
  ```

  Replace lines 46-49:
  ```swift
                              Text("Add Custom Trigger Rule")
                          }
                          .font(.system(size: 12, weight: .bold))
  ```
  with:
  ```swift
                              Text("Add rule")
                          }
                          .font(.system(size: 12, weight: .medium))
  ```

  Replace lines 83-85:
  ```swift
                  Text("If")
                      .font(.system(size: 13))
                      .foregroundColor(.gray)
  ```
  with:
  ```swift
                  Text("if")
                      .font(.system(size: 12))
                      .foregroundColor(.gray)
  ```

  Replace lines 123-125:
  ```swift
                          Text("If temp ≥")
                              .font(.system(size: 13))
                              .foregroundColor(.gray)
  ```
  with:
  ```swift
                          Text("if temp ≥")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
  ```

  Replace lines 127-129:
  ```swift
                          Text("\(Int(rule.thresholdTemp))°C")
                              .font(.system(size: 13, weight: .bold))
  ```
  with:
  ```swift
                          Text("\(Int(rule.thresholdTemp))°C")
                              .font(.system(size: 12, weight: .medium))
  ```

  Replace lines 138-140:
  ```swift
                          Text("Set speed to")
                              .font(.system(size: 13))
                              .foregroundColor(.gray)
  ```
  with:
  ```swift
                          Text("set speed to")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
  ```

  Replace lines 142-144:
  ```swift
                          Text("\(Int(rule.targetSpeedPercent))%")
                              .font(.system(size: 13, weight: .bold))
  ```
  with:
  ```swift
                          Text("\(Int(rule.targetSpeedPercent))%")
                              .font(.system(size: 12, weight: .medium))
  ```

  Replace lines 155-157:
  ```swift
                          Text("Temp range:")
                              .font(.system(size: 13))
                              .foregroundColor(.gray)
  ```
  with:
  ```swift
                          Text("temp range:")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
  ```

  Replace lines 160-162:
  ```swift
                          Text("\(Int(rule.minTemp))°C")
                              .font(.system(size: 12, weight: .bold))
  ```
  with:
  ```swift
                          Text("\(Int(rule.minTemp))°C")
                              .font(.system(size: 11, weight: .medium))
  ```

  Replace lines 168-170:
  ```swift
                          Text("to")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
  ```
  with:
  ```swift
                          Text("to")
                              .font(.system(size: 11))
                              .foregroundColor(.gray)
  ```

  Replace lines 172-174:
  ```swift
                          Text("\(Int(rule.maxTemp))°C")
                              .font(.system(size: 12, weight: .bold))
  ```
  with:
  ```swift
                          Text("\(Int(rule.maxTemp))°C")
                              .font(.system(size: 11, weight: .medium))
  ```

  Replace lines 183-185:
  ```swift
                          Text("Speed range:")
                              .font(.system(size: 13))
                              .foregroundColor(.gray)
  ```
  with:
  ```swift
                          Text("speed range:")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
  ```

  Replace lines 188-190:
  ```swift
                          Text("\(Int(rule.minSpeedPercent))%")
                              .font(.system(size: 12, weight: .bold))
  ```
  with:
  ```swift
                          Text("\(Int(rule.minSpeedPercent))%")
                              .font(.system(size: 11, weight: .medium))
  ```

  Replace lines 200-202:
  ```swift
                          Text("\(Int(rule.maxSpeedPercent))%")
                              .font(.system(size: 12, weight: .bold))
  ```
  with:
  ```swift
                          Text("\(Int(rule.maxSpeedPercent))%")
                              .font(.system(size: 11, weight: .medium))
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success without errors.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "ui: simplify Rules engine copy and typography"`

---

### Task 6: Chart & Menu Bar Dropdown Updates
**Files:**
- Modify: `Views/TempHistoryChartView.swift`
- Modify: `Views/MenuBarPopoverView.swift`

- [ ] **Step 1: Simplify TempHistoryChartView labels and weights**
  In `Views/TempHistoryChartView.swift`:
  Replace lines 33-39:
  ```swift
      var sensorName: String {
          switch sensor {
          case .cpu: return "CPU Die"
          case .gpu: return "GPU proximity"
          case .battery: return "Battery"
          }
      }
  ```
  with:
  ```swift
      var sensorName: String {
          switch sensor {
          case .cpu: return "CPU"
          case .gpu: return "GPU"
          case .battery: return "Battery"
          }
      }
  ```

  Replace lines 77-79:
  ```swift
                      Text("\(sensorName) Temperature History")
                          .font(.system(size: 13, weight: .bold))
  ```
  with:
  ```swift
                      Text("\(sensorName) temperature history")
                          .font(.system(size: 12, weight: .semibold))
  ```

  Replace line 100:
  ```swift
                      Text("No temperature data recorded yet.")
  ```
  with:
  ```swift
                      Text("No temperature data recorded.")
  ```

  Replace lines 111-113:
  ```swift
                      StatItem(title: "CURRENT", value: String(format: "%.1f°C", points.last?.value ?? 0), color: sensorColor)
                      StatItem(title: "AVERAGE", value: String(format: "%.1f°C", statsAvg), color: .white.opacity(0.8))
                      StatItem(title: "MIN / MAX", value: String(format: "%.1f°C / %.1f°C", statsMin, statsMax), color: .white.opacity(0.8))
  ```
  with:
  ```swift
                      StatItem(title: "current", value: String(format: "%.1f°C", points.last?.value ?? 0), color: sensorColor)
                      StatItem(title: "average", value: String(format: "%.1f°C", statsAvg), color: .white.opacity(0.8))
                      StatItem(title: "min / max", value: String(format: "%.1f°C / %.1f°C", statsMin, statsMax), color: .white.opacity(0.8))
  ```

  In `Views/TempHistoryChartView.swift` (StatItem struct):
  Replace lines 245-250:
  ```swift
              Text(title)
                  .font(.system(size: 8, weight: .bold))
                  .foregroundColor(.gray)
              Text(value)
                  .font(.system(size: 12, weight: .bold))
  ```
  with:
  ```swift
              Text(title)
                  .font(.system(size: 8, weight: .medium))
                  .foregroundColor(.gray)
              Text(value)
                  .font(.system(size: 11, weight: .medium))
  ```

- [ ] **Step 2: Simplify Menu Bar Popover styling and labels**
  In `Views/MenuBarPopoverView.swift`:
  Replace line 12:
  ```swift
                  TelemetryCard(temp: viewModel.batteryTemp, label: "BATTERY")
  ```
  with:
  ```swift
                  TelemetryCard(temp: viewModel.batteryTemp, label: "Battery")
  ```

  Replace lines 38-53:
  ```swift
                  .help("Open Fan Control Center")
                  
                  // Sync All Fans
                  Button(action: { 
                      viewModel.linkedFans.toggle()
                  }) {
                      VStack {
                          Image(systemName: "link")
                              .font(.system(size: 14))
                              .foregroundColor(viewModel.linkedFans ? .teal : .primary)
                          Text(viewModel.linkedFans ? "Linked" : "Link Fans").font(.system(size: 8))
                              .foregroundColor(viewModel.linkedFans ? .teal : .primary)
                      }
                  }
                  .buttonStyle(PlainButtonStyle())
                  .help(viewModel.linkedFans ? "Unlink Fans" : "Sync All Fans Together")
                  
                  // Reset to Auto
                  Button(action: { viewModel.resetAll() }) {
                      VStack {
                          Image(systemName: "arrow.counterclockwise")
                              .font(.system(size: 14))
                          Text("Auto").font(.system(size: 8))
                      }
                  }
                  .buttonStyle(PlainButtonStyle())
                  .help("Reset All to Auto")
  ```
  with:
  ```swift
                  .help("Open fan control center")
                  
                  // Sync All Fans
                  Button(action: { 
                      viewModel.linkedFans.toggle()
                  }) {
                      VStack {
                          Image(systemName: "link")
                              .font(.system(size: 14))
                              .foregroundColor(viewModel.linkedFans ? .teal : .primary)
                          Text(viewModel.linkedFans ? "Linked" : "Link fans").font(.system(size: 8))
                              .foregroundColor(viewModel.linkedFans ? .teal : .primary)
                      }
                  }
                  .buttonStyle(PlainButtonStyle())
                  .help(viewModel.linkedFans ? "Unlink fans" : "Link all fans")
                  
                  // Reset to Auto
                  Button(action: { viewModel.resetAll() }) {
                      VStack {
                          Image(systemName: "arrow.counterclockwise")
                              .font(.system(size: 14))
                          Text("Auto").font(.system(size: 8))
                      }
                  }
                  .buttonStyle(PlainButtonStyle())
                  .help("Reset to auto")
  ```

  Replace lines 109-116:
  ```swift
              if let t = temp {
                  Text(String(format: "%.0f°C", t))
                      .font(.system(size: 20, weight: .bold))
              } else {
                  Text(verbatim: "--")
                      .font(.system(size: 20, weight: .bold))
              }
              Text(label)
  ```
  with:
  ```swift
              if let t = temp {
                  Text(String(format: "%.0f°C", t))
                      .font(.system(size: 18, weight: .medium))
              } else {
                  Text(verbatim: "--")
                      .font(.system(size: 18, weight: .medium))
              }
              Text(label)
                  .font(.system(size: 10, weight: .medium))
  ```

  Replace line 138:
  ```swift
                  Text(fan.name).fontWeight(.bold)
  ```
  with:
  ```swift
                  Text(fan.name).fontWeight(.medium)
  ```

  Replace lines 199-201:
  ```swift
                  .font(.system(size: 10, weight: .bold))
                  .foregroundColor(isActive ? .teal : .white)
  ```
  with:
  ```swift
                  .font(.system(size: 9, weight: .medium))
                  .foregroundColor(isActive ? .teal : .white)
  ```

- [ ] **Step 3: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success without errors.

- [ ] **Step 4: Commit changes**
  Run: `git commit -am "ui: simplify chart statistics and menu bar dropdown text/typography"`
