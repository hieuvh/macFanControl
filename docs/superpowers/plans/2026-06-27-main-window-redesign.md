# Main Window Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the main Fan Control Center (`ContentView`) into a premium, modern dashboard with a custom glassmorphic sidebar and a Hero Fan overview.

**Architecture:** We will create discrete SwiftUI views for the new components (`HeroFanDial`, `CompactSensorCard`, `OverviewTabView`, `SettingsTabView`) and then refactor `ContentView` to use a custom sidebar layout instead of a single vertical scroll.

**Tech Stack:** SwiftUI, AppKit

## Global Constraints

- Must run on macOS 13.0+
- Must use Apple's native SF Symbols
- Must maintain the dark glassmorphic aesthetic (`#0F1218` background, `ultraThinMaterial`)

---

### Task 1: Create HeroFanDial View

**Files:**
- Create: `Views/HeroFanDial.swift`

**Interfaces:**
- Consumes: `FanJSON`, `FanViewModel`
- Produces: `HeroFanDial` (SwiftUI View)

- [ ] **Step 1: Write the HeroFanDial view code**

```swift
import SwiftUI

struct HeroFanDial: View {
    let fan: FanJSON
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(fan.currentSpeed) / CGFloat(fan.maxSpeed > 0 ? fan.maxSpeed : 6000))
                    .stroke(Color.teal, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: fan.currentSpeed)
                
                VStack(spacing: 4) {
                    Text(String(fan.currentSpeed))
                        .animatableNumber(value: Double(fan.currentSpeed))
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                    Text("RPM")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Text(fan.name)
                .font(.system(size: 16, weight: .bold))
            
            // Slider
            Slider(
                value: Binding(
                    get: { Double(fan.targetSpeed) },
                    set: { val in
                        if fan.mode != 1 {
                            viewModel.changeFanMode(fanId: fan.id, mode: 1)
                        }
                        viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
                    }
                ),
                in: Double(fan.minSpeed)...Double(fan.maxSpeed)
            )
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
```

- [ ] **Step 2: Compile the project to verify syntax**

Run: `./build.sh`
Expected: Compile successfully.

- [ ] **Step 3: Commit**

```bash
git add Views/HeroFanDial.swift
git commit -m "feat(ui): add HeroFanDial component"
```

---

### Task 2: Create CompactSensorCard View

**Files:**
- Create: `Views/CompactSensorCard.swift`

**Interfaces:**
- Consumes: Title, Temperature, Icon
- Produces: `CompactSensorCard` (SwiftUI View)

- [ ] **Step 1: Write the CompactSensorCard view code**

```swift
import SwiftUI

struct CompactSensorCard: View {
    let title: String
    let temp: Double?
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let t = temp {
                    Text(String(format: "%.1f°C", t))
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                } else {
                    Text(verbatim: "--")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                }
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
```

- [ ] **Step 2: Compile the project to verify syntax**

Run: `./build.sh`
Expected: Compile successfully.

- [ ] **Step 3: Commit**

```bash
git add Views/CompactSensorCard.swift
git commit -m "feat(ui): add CompactSensorCard component"
```

---

### Task 3: Create OverviewTabView & SettingsTabView

**Files:**
- Create: `Views/OverviewTabView.swift`
- Create: `Views/SettingsTabView.swift`

**Interfaces:**
- Consumes: `FanViewModel`
- Produces: `OverviewTabView`, `SettingsTabView`

- [ ] **Step 1: Write OverviewTabView**

```swift
import SwiftUI

struct OverviewTabView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let firstFan = viewModel.fans.first {
                    HeroFanDial(fan: firstFan, viewModel: viewModel)
                }
                
                HStack(spacing: 16) {
                    CompactSensorCard(title: "CPU", temp: viewModel.cpuTemp, iconName: "cpu", color: .orange)
                    CompactSensorCard(title: "GPU", temp: viewModel.gpuTemp, iconName: "gauge.with.needle", color: .purple)
                    CompactSensorCard(title: "BATTERY", temp: viewModel.batteryTemp, iconName: "battery.100.bolt", color: .green)
                }
                
                if viewModel.fans.count > 1 {
                    VStack(spacing: 16) {
                        ForEach(viewModel.fans.dropFirst()) { fan in
                            FanControlRow(fan: fan, viewModel: viewModel)
                        }
                    }
                }
            }
            .padding(32)
        }
    }
}
```

- [ ] **Step 2: Write SettingsTabView**

```swift
import SwiftUI

struct SettingsTabView: View {
    @ObservedObject var viewModel: FanViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.system(size: 28, weight: .black))
                
                if !viewModel.isAuthorized {
                    // Privilege setup card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Helper Authentication Required")
                            .font(.system(size: 16, weight: .bold))
                        
                        Button(action: { viewModel.authorize() }) {
                            Text("Authorize & Enable Fan Adjustments")
                                .font(.system(size: 13, weight: .bold))
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Global Controls
                VStack(spacing: 16) {
                    Toggle("Sync All Fans Together", isOn: $viewModel.linkedFans)
                        .toggleStyle(SwitchToggleStyle(tint: .teal))
                    
                    Button(action: { viewModel.resetAll() }) {
                        Text("Reset All to Auto")
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
            .padding(32)
        }
    }
}
```

- [ ] **Step 3: Compile the project**

Run: `./build.sh`
Expected: Compile successfully.

- [ ] **Step 4: Commit**

```bash
git add Views/OverviewTabView.swift Views/SettingsTabView.swift
git commit -m "feat(ui): add Overview and Settings tabs"
```

---

### Task 4: Refactor ContentView to Dashboard Layout

**Files:**
- Modify: `Views/ContentView.swift`

**Interfaces:**
- Consumes: `OverviewTabView`, `SettingsTabView`, `RulesEngineView`

- [ ] **Step 1: Replace ContentView.swift with Dashboard Layout**

Replace the entire `ContentView` body to use a custom sidebar layout.

```swift
import SwiftUI
import AppKit

enum DashboardTab {
    case overview
    case rules
    case settings
}

struct ContentView: View {
    @ObservedObject var viewModel: FanViewModel
    @State private var selectedTab: DashboardTab = .overview
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fan Control")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.white)
                    Text("Center v2.0")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.teal)
                }
                .padding(.bottom, 20)
                
                SidebarButton(title: "Overview", icon: "square.grid.2x2.fill", isSelected: selectedTab == .overview) {
                    selectedTab = .overview
                }
                
                SidebarButton(title: "Rules Engine", icon: "bolt.fill", isSelected: selectedTab == .rules) {
                    selectedTab = .rules
                }
                
                SidebarButton(title: "Settings", icon: "gearshape.fill", isSelected: selectedTab == .settings) {
                    selectedTab = .settings
                }
                
                Spacer()
            }
            .padding(24)
            .frame(width: 200)
            .background(Color.black.opacity(0.3))
            
            // Main Content Area
            ZStack {
                Color(red: 0.04, green: 0.04, blue: 0.05).edgesIgnoringSafeArea(.all)
                
                switch selectedTab {
                case .overview:
                    OverviewTabView(viewModel: viewModel)
                case .rules:
                    ScrollView {
                        RulesEngineView(viewModel: viewModel)
                            .padding(32)
                    }
                case .settings:
                    SettingsTabView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color(red: 0.04, green: 0.04, blue: 0.05))
        .background(WindowAccessor { window in
            window.delegate = MainWindowDelegate.shared
        })
    }
}

struct SidebarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.teal.opacity(0.2) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.teal.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Window Accessor
struct WindowAccessor: NSViewRepresentable {
    var onWindowBind: (NSWindow) -> Void
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window { onWindowBind(window) }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

class MainWindowDelegate: NSObject, NSWindowDelegate {
    static let shared = MainWindowDelegate()
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        NSApplication.shared.setActivationPolicy(.accessory)
        return false
    }
}
```

- [ ] **Step 2: Compile the project**

Run: `./build.sh`
Expected: Compile successfully.

- [ ] **Step 3: Commit**

```bash
git add Views/ContentView.swift
git commit -m "refactor(ui): transition to dashboard sidebar layout"
```
