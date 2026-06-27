# Menu Bar Presets & Settings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add preset speed buttons to the menu bar, redesign the bottom actions toolbar with icons, and introduce a settings window and a sync all fans action.

**Architecture:** We are updating SwiftUI views (`MenuBarPopoverView`, `MenuBarFanRow`, `FanControlApp`) and the `FanViewModel` to support new UI elements and actions.

**Tech Stack:** Swift, SwiftUI, macOS.

## Global Constraints
- Target: macOS 13.0
- Build: Use `./build.sh` for compile verification.

---

### Task 1: Create SettingsView and register in FanControlApp

**Files:**
- Create: `Views/SettingsView.swift`
- Modify: `App/FanControlApp.swift`

**Interfaces:**
- Consumes: SwiftUI `View` and `App` protocols.
- Produces: `SettingsView`

- [ ] **Step 1: Write SettingsView code**
```swift
// Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            VStack {
                Text("General Settings")
                Text("Coming soon...")
            }
            .tabItem {
                Label("General", systemImage: "gear")
            }
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}
```

- [ ] **Step 2: Register Settings window in App**
Modify `App/FanControlApp.swift`. Replace the `body` property block with the following:
```swift
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Settings {
            SettingsView()
        }
        
        MenuBarExtra {
            MenuBarPopoverView(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "wind")
            }
        }
        .menuBarExtraStyle(.window)
    }
```

- [ ] **Step 3: Run compilation check**
Run: `./build.sh`
Expected: Compile succeeds.

- [ ] **Step 4: Commit**
```bash
git add Views/SettingsView.swift App/FanControlApp.swift
git commit -m "feat: add SettingsView and register Settings scene"
```

### Task 2: Add syncAllFans to FanViewModel

**Files:**
- Modify: `ViewModels/FanViewModel.swift`

**Interfaces:**
- Consumes: `changeFanSpeed` and `changeFanMode`.
- Produces: `func syncAllFans(toSpeed speed: Int)`

- [ ] **Step 1: Write syncAllFans function**
Open `ViewModels/FanViewModel.swift` and add this function inside the `FanViewModel` class:
```swift
    func syncAllFans(toSpeed speed: Int) {
        for fan in fans {
            if fan.mode != 1 {
                changeFanMode(fanId: fan.id, mode: 1)
            }
            changeFanSpeed(fanId: fan.id, speed: speed)
        }
    }
```

- [ ] **Step 2: Run compilation check**
Run: `./build.sh`
Expected: Compile succeeds.

- [ ] **Step 3: Commit**
```bash
git add ViewModels/FanViewModel.swift
git commit -m "feat: add syncAllFans to FanViewModel"
```

### Task 3: Implement Presets in MenuBarFanRow

**Files:**
- Modify: `Views/MenuBarPopoverView.swift`

**Interfaces:**
- Consumes: `FanViewModel` and `FanJSON` properties.

- [ ] **Step 1: Replace Slider with Presets**
In `Views/MenuBarPopoverView.swift`, inside the `MenuBarFanRow` struct, find the `Slider` block and the text right below it. Replace it with:
```swift
            if fan.mode == 1 {
                HStack(spacing: 6) {
                    presetButton(title: "Min", val: Double(fan.minSpeed))
                    presetButton(title: "20%", val: getSpeedForPercentage(0.20))
                    presetButton(title: "50%", val: getSpeedForPercentage(0.50))
                    presetButton(title: "80%", val: getSpeedForPercentage(0.80))
                    presetButton(title: "Max", val: Double(fan.maxSpeed))
                }
                .padding(.top, 4)
            } else {
                Text("Auto Mode")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }
```

- [ ] **Step 2: Add helper methods to MenuBarFanRow**
Inside `MenuBarFanRow`, add these methods below the `body` property:
```swift
    func getSpeedForPercentage(_ pct: Double) -> Double {
        let range = Double(fan.maxSpeed - fan.minSpeed)
        return Double(fan.minSpeed) + range * pct
    }
    
    func presetButton(title: String, val: Double) -> some View {
        Button(action: {
            sliderVal = val
            viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
        }) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
```

- [ ] **Step 3: Run compilation check**
Run: `./build.sh`
Expected: Compile succeeds.

- [ ] **Step 4: Commit**
```bash
git add Views/MenuBarPopoverView.swift
git commit -m "feat: replace menu bar slider with preset buttons"
```

### Task 4: Update Bottom Actions Toolbar in MenuBarPopoverView

**Files:**
- Modify: `Views/MenuBarPopoverView.swift`

**Interfaces:**
- Consumes: `viewModel.syncAllFans` and standard App APIs.

- [ ] **Step 1: Redesign bottom actions**
In `Views/MenuBarPopoverView.swift`, locate the `VStack` below the `Divider()` in `MenuBarPopoverView` containing the text buttons. Replace it with:
```swift
            // Bottom Section: Actions
            HStack(spacing: 20) {
                // Open App
                Button(action: { openMainWindow() }) {
                    VStack {
                        Image(systemName: "macwindow")
                            .font(.system(size: 14))
                        Text("App").font(.system(size: 8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .help("Open Fan Control Center")
                
                // Sync All Fans (using a fixed max for now, can be adjusted)
                Button(action: { 
                    for fan in viewModel.fans {
                        let range = Double(fan.maxSpeed - fan.minSpeed)
                        let val = Double(fan.minSpeed) + range * 0.5
                        if fan.mode != 1 {
                            viewModel.changeFanMode(fanId: fan.id, mode: 1)
                        }
                        viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                    }
                }) {
                    VStack {
                        Image(systemName: "link")
                            .font(.system(size: 14))
                        Text("Sync 50%").font(.system(size: 8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .help("Sync All Fans to 50%")
                
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
                
                // Settings
                Button(action: { NSApp.sendAction(Selector("showSettingsWindow:"), to: nil, from: nil) }) {
                    VStack {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14))
                        Text("Settings").font(.system(size: 8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .help("Open Settings")
                
                // Quit
                Button(action: { NSApplication.shared.terminate(nil) }) {
                    VStack {
                        Image(systemName: "power")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                        Text("Quit").font(.system(size: 8)).foregroundColor(.red)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 15)
```

- [ ] **Step 2: Run compilation check**
Run: `./build.sh`
Expected: Compile succeeds.

- [ ] **Step 3: Commit**
```bash
git add Views/MenuBarPopoverView.swift
git commit -m "feat: redesign menu bar actions toolbar"
```
