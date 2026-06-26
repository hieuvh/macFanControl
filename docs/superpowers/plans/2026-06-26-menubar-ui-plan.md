# Menu Bar UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a rich, interactive popover window for the MacFanControl menu bar to display system temperatures and adjust fan speeds without opening the main application.

**Architecture:** Create a new `MenuBarPopoverView` in SwiftUI that binds to the shared `FanViewModel`. Update `FanControlApp` to use `.menuBarExtraStyle(.window)` and present this new view.

**Tech Stack:** SwiftUI, macOS

## Global Constraints

- Must work on macOS 13.0+
- Must use existing `FanViewModel` and not duplicate logic.
- Must preserve the existing `MenuBarExtra` label (the icon showing current RPM).

---

### Task 1: Create `MenuBarPopoverView` Component

**Files:**
- Create: `Views/MenuBarPopoverView.swift`

**Interfaces:**
- Consumes: `FanViewModel`
- Produces: `MenuBarPopoverView` struct for use in `FanControlApp`

- [ ] **Step 1: Create the file with the UI shell**

```swift
// Views/MenuBarPopoverView.swift
import SwiftUI

struct MenuBarPopoverView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Top Section: Telemetry
            HStack(spacing: 10) {
                TelemetryCard(temp: viewModel.cpuTemp, label: "CPU")
                TelemetryCard(temp: viewModel.gpuTemp, label: "GPU")
                TelemetryCard(temp: viewModel.batteryTemp, label: "BATT")
            }
            .padding(.horizontal)
            .padding(.top, 15)
            
            // Middle Section: Fans
            VStack(spacing: 12) {
                ForEach(viewModel.fans) { fan in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(fan.name).fontWeight(.bold)
                            Spacer()
                            Button(fan.mode == 1 ? "Manual" : "Auto") {
                                let newMode = fan.mode == 1 ? 0 : 1
                                viewModel.changeFanMode(fanId: fan.id, mode: newMode)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(fan.currentSpeed) },
                                set: { newValue in
                                    viewModel.changeFanSpeed(fanId: fan.id, speed: Int(newValue))
                                }
                            ),
                            in: Double(fan.minSpeed)...Double(fan.maxSpeed),
                            step: 100.0
                        )
                        .disabled(fan.mode == 0) // Disabled if in Auto mode
                        
                        Text("\(fan.currentSpeed) RPM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Bottom Section: Actions
            VStack(spacing: 8) {
                Button("Open Fan Control Center") {
                    openMainWindow()
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("Reset All to Auto") {
                    viewModel.resetAll()
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.red)
            }
            .padding(.bottom, 15)
        }
        .frame(width: 320)
    }
    
    private func openMainWindow() {
        NSApplication.shared.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
}

struct TelemetryCard: View {
    var temp: Double?
    var label: String
    
    var body: some View {
        VStack {
            if let t = temp {
                Text(String(format: "%.0f°C", t))
                    .font(.system(size: 20, weight: .bold))
            } else {
                Text("--")
                    .font(.system(size: 20, weight: .bold))
            }
            Text(label)
                .font(.system(size: 10))
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}
```

- [ ] **Step 2: Build project to verify compilation**

Run: `./build.sh`
Expected: Successful build, no compilation errors.

- [ ] **Step 3: Commit**

```bash
git add Views/MenuBarPopoverView.swift
git commit -m "feat: create MenuBarPopoverView component"
```

---

### Task 2: Integrate `MenuBarPopoverView` into App Entry Point

**Files:**
- Modify: `App/FanControlApp.swift`

**Interfaces:**
- Consumes: `MenuBarPopoverView`

- [ ] **Step 1: Replace existing `MenuBarExtra` content**

Modify `App/FanControlApp.swift` to remove the existing `Group { ... }` content inside `MenuBarExtra` and replace it with `MenuBarPopoverView(viewModel: viewModel)`. Ensure that `.menuBarExtraStyle(.window)` is applied to the `MenuBarExtra`. Also, ensure the existing `openMainWindow` function in `FanControlApp` isn't accidentally removed as it's still used by the menu bar label if needed, or if it is unneeded, it can be removed. Wait, the original `MenuBarExtra` used the `Group`. The new code uses `MenuBarPopoverView`.

```swift
// Replace lines 20-72 in App/FanControlApp.swift
        MenuBarExtra {
            MenuBarPopoverView(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "wind")
                if let firstFan = viewModel.fans.first {
                    Text("\(firstFan.currentSpeed) RPM")
                } else {
                    Text("Fan Control")
                }
            }
        }
        .menuBarExtraStyle(.window)
```

*(Note: remove the existing `openMainWindow()` function from `FanControlApp.swift` if it is no longer referenced there, as we copied it into `MenuBarPopoverView`.)*

- [ ] **Step 2: Build project to verify compilation**

Run: `./build.sh`
Expected: Successful build.

- [ ] **Step 3: Commit**

```bash
git add App/FanControlApp.swift
git commit -m "feat: integrate MenuBarPopoverView into MenuBarExtra"
```
