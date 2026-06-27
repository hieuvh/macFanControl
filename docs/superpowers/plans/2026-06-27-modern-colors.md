# Modern & Consistent Colors Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign interface colors across all view modules to establish a cohesive aesthetic unified under a Teal accent, changing GPU labels to Indigo and replacing bright orange boxes with muted warnings.

**Architecture:** We will modify the color definitions in SwiftUI views. Specifically:
- Authorization alerts: Background white opacity 0.03, border white opacity 0.1, buttons white opacity 0.1.
- GPU sensor: Change `.purple` to `.indigo` in Overview, Charts, and Menu Bar popover.
- Rules Engine: Change Toggle tint, border stroke, add rule button accent, list item active toggle tint, and slider accents from `.purple`/`.green` to `.teal`.

**Tech Stack:** SwiftUI, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Muted Authorization Warnings
**Files:**
- Modify: `Views/OverviewTabView.swift`
- Modify: `Views/SettingsTabView.swift`

- [ ] **Step 1: Simplify authorization card colors in Overview**
  In `Views/OverviewTabView.swift`:
  Replace lines 30-46:
  ```swift
                              Text("Authorize")
                                  .font(.system(size: 12, weight: .medium))
                                  .padding(.vertical, 10)
                                  .padding(.horizontal, 16)
                                  .background(Color.orange)
                                  .foregroundColor(.black)
                                  .cornerRadius(8)
                          }
                          .buttonStyle(PlainButtonStyle())
                      }
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .background(Color.orange.opacity(0.1))
                      .cornerRadius(12)
                      .overlay(
                          RoundedRectangle(cornerRadius: 12)
                              .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                      )
  ```
  with:
  ```swift
                              Text("Authorize")
                                  .font(.system(size: 12, weight: .medium))
                                  .padding(.vertical, 10)
                                  .padding(.horizontal, 16)
                                  .background(Color.white.opacity(0.1))
                                  .foregroundColor(.white)
                                  .cornerRadius(8)
                          }
                          .buttonStyle(PlainButtonStyle())
                      }
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .background(Color.white.opacity(0.03))
                      .cornerRadius(12)
                      .overlay(
                          RoundedRectangle(cornerRadius: 12)
                              .stroke(Color.white.opacity(0.1), lineWidth: 1)
                      )
  ```

- [ ] **Step 2: Simplify authorization card colors in Settings**
  In `Views/SettingsTabView.swift`:
  Replace lines 28-45:
  ```swift
                              Text("Authorize")
                                  .font(.system(size: 12, weight: .medium))
                                  .padding(.vertical, 10)
                                  .padding(.horizontal, 16)
                                  .background(Color.orange)
                                  .foregroundColor(.black)
                                  .cornerRadius(8)
                          }
                          .buttonStyle(PlainButtonStyle())
                      }
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .background(Color.orange.opacity(0.1))
                      .cornerRadius(12)
                      .overlay(
                          RoundedRectangle(cornerRadius: 12)
                              .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                      )
  ```
  with:
  ```swift
                              Text("Authorize")
                                  .font(.system(size: 12, weight: .medium))
                                  .padding(.vertical, 10)
                                  .padding(.horizontal, 16)
                                  .background(Color.white.opacity(0.1))
                                  .foregroundColor(.white)
                                  .cornerRadius(8)
                          }
                          .buttonStyle(PlainButtonStyle())
                      }
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .background(Color.white.opacity(0.03))
                      .cornerRadius(12)
                      .overlay(
                          RoundedRectangle(cornerRadius: 12)
                              .stroke(Color.white.opacity(0.1), lineWidth: 1)
                      )
  ```

- [ ] **Step 3: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 4: Commit changes**
  Run: `git commit -am "ui: redesign authorization warnings with muted colors"`

---

### Task 2: GPU Sensor Color Redesign to Indigo
**Files:**
- Modify: `Views/OverviewTabView.swift`
- Modify: `Views/TempHistoryChartView.swift`
- Modify: `Views/MenuBarPopoverView.swift`

- [ ] **Step 1: Update GPU Sensor card color in Overview**
  In `Views/OverviewTabView.swift`:
  Replace line 67:
  ```swift
                      CompactSensorCard(title: "GPU", temp: viewModel.gpuTemp, iconName: "gauge.with.needle", color: .purple)
  ```
  with:
  ```swift
                      CompactSensorCard(title: "GPU", temp: viewModel.gpuTemp, iconName: "gauge.with.needle", color: .indigo)
  ```

- [ ] **Step 2: Update GPU Sensor color in History Chart**
  In `Views/TempHistoryChartView.swift`:
  Replace line 20:
  ```swift
          case .gpu: return .purple
  ```
  with:
  ```swift
          case .gpu: return .indigo
  ```

- [ ] **Step 3: Update GPU Telemetry card color in Menu Bar Dropdown**
  In `Views/MenuBarPopoverView.swift`:
  Replace line 11:
  ```swift
                  TelemetryCard(temp: viewModel.gpuTemp, label: "GPU")
  ```
  Wait! Let's check how GPU TelemetryCard is colored in `MenuBarPopoverView.swift` or if it's dynamic. Let's look at `TelemetryCard` in `MenuBarPopoverView.swift`:
  It does not have color customisation in `MenuBarPopoverView.swift`. Wait, let's look at `MenuBarPopoverView.swift` TelemetryCard definition:
  ```swift
  struct TelemetryCard: View {
      var temp: Double?
      var label: String
      
      var body: some View {
          VStack {
  ```
  Ah! TelemetryCard doesn't use the custom sensor color, it uses standard neutral colors. But let's check `MenuBarPopoverView.swift` for any other `.purple` references.
  Wait, let's search for `purple` in all swift files to be sure.
  Let's do that in Step 3.

- [ ] **Step 4: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 5: Commit changes**
  Run: `git commit -am "ui: change GPU sensor accent color to indigo"`

---

### Task 3: Unify Rules Engine Styling to Teal
**Files:**
- Modify: `Views/RulesEngineView.swift`

- [ ] **Step 1: Replace purple and green accents in RulesEngineView with teal**
  In `Views/RulesEngineView.swift`:
  Replace lines 11-13:
  ```swift
                          Image(systemName: "slider.horizontal.3")
                              .foregroundColor(.purple)
  ```
  with:
  ```swift
                          Image(systemName: "slider.horizontal.3")
                              .foregroundColor(.teal)
  ```

  Replace line 26:
  ```swift
                      .toggleStyle(SwitchToggleStyle(tint: .purple))
  ```
  with:
  ```swift
                      .toggleStyle(SwitchToggleStyle(tint: .teal))
  ```

  Replace lines 49-53:
  ```swift
                          .foregroundColor(.purple)
                          .padding(.vertical, 8)
                          .frame(maxWidth: .infinity)
                          .background(Color.purple.opacity(0.1))
  ```
  with:
  ```swift
                          .foregroundColor(.teal)
                          .padding(.vertical, 8)
                          .frame(maxWidth: .infinity)
                          .background(Color.teal.opacity(0.1))
  ```

  Replace line 65:
  ```swift
                  .stroke(viewModel.isRulesEngineEnabled ? Color.purple.opacity(0.2) : Color.white.opacity(0.04), lineWidth: 1)
  ```
  with:
  ```swift
                  .stroke(viewModel.isRulesEngineEnabled ? Color.teal.opacity(0.2) : Color.white.opacity(0.04), lineWidth: 1)
  ```

  Replace line 80:
  ```swift
                      .toggleStyle(SwitchToggleStyle(tint: .green))
  ```
  with:
  ```swift
                      .toggleStyle(SwitchToggleStyle(tint: .teal))
  ```

  Replace line 133:
  ```swift
                              .accentColor(.purple)
  ```
  with:
  ```swift
                              .accentColor(.teal)
  ```

  Replace line 148:
  ```swift
                              .accentColor(.purple)
  ```
  with:
  ```swift
                              .accentColor(.teal)
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "ui: unify Rules Engine interactive accent colors to teal"`

---

### Task 4: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Run complete build**
  Run: `./build.sh`
  Expected: Build and Packaging Complete.
