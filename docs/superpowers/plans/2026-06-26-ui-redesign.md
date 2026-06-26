# Main App UI Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Overhaul the visual aesthetic of the main `ContentView` and its subcomponents to adopt a "Pro / High-Tech Dark" theme.

**Architecture:** We are updating the SwiftUI modifiers in `ContentView.swift`, `TempMetricCard.swift` (assuming it exists as a separate file or is within ContentView/another file), and `FanControlRow.swift`.

**Tech Stack:** Swift, SwiftUI, macOS.

## Global Constraints
- Target: macOS 13.0
- Build: Use `./build.sh` for compile verification.

---

### Task 1: Update Global Background and Header in ContentView

**Files:**
- Modify: `Views/ContentView.swift`

**Interfaces:**
- Consumes: SwiftUI `Color` and `View` modifiers.
- Produces: Updated layout for `ContentView`.

- [ ] **Step 1: Update Global Background**
In `Views/ContentView.swift`, find `.background(Color(red: 0.08, green: 0.08, blue: 0.1))` near the bottom of `ContentView` and replace it with:
```swift
        .background(Color(red: 0.04, green: 0.04, blue: 0.05)) // #0A0A0C
```

- [ ] **Step 2: Update Header Version Tag**
In `Views/ContentView.swift`, find the "v2.0" text modifiers:
```swift
                        Text("v2.0")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
```
Replace them with:
```swift
                        Text("v2.0")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.green.opacity(0.5), lineWidth: 1))
```

- [ ] **Step 3: Run compilation check**
Run: `./build.sh`
Expected: Compile succeeds.

- [ ] **Step 4: Commit**
```bash
git add Views/ContentView.swift
git commit -m "style: update ContentView background and header badge"
```

### Task 2: Redesign TempMetricCard

**Files:**
- Modify: `Views/TempMetricCard.swift`

**Interfaces:**
- Consumes: SwiftUI modifiers.

- [ ] **Step 1: Apply High-Tech Dark Styling**
Open `Views/TempMetricCard.swift` and locate the main `VStack`. Replace its styling. Wait, `TempMetricCard` is in its own file. The existing content is likely similar to:
```swift
        .padding()
        .background(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
        .cornerRadius(12)
```
Replace the background, border, font, and icon shadow.

Modify `Views/TempMetricCard.swift` so the `body` looks like this:
```swift
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .shadow(color: isSelected ? iconColor.opacity(0.8) : iconColor.opacity(0.4), radius: isSelected ? 6 : 2)
            
            if let t = temp {
                Text(String(format: "%.0f°C", t))
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            } else {
                Text("--")
                    .font(.system(size: 22, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundColor(.gray)
        }
        .frame(minWidth: 100)
        .padding()
        .background(Color.white.opacity(0.02))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? iconColor.opacity(0.8) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
```
*(Ensure `title`, `temp`, `iconName`, `iconColor`, `isSelected` variables match what exists in the struct. Adjust if needed based on the actual file content.)*

- [ ] **Step 2: Run compilation check**
Run: `./build.sh`
Expected: Compile succeeds.

- [ ] **Step 3: Commit**
```bash
git add Views/TempMetricCard.swift
git commit -m "style: redesign TempMetricCard for high-tech dark theme"
```

### Task 3: Redesign FanControlRow

**Files:**
- Modify: `Views/FanControlRow.swift`

**Interfaces:**
- Consumes: Fan telemetry properties.

- [ ] **Step 1: Update Fonts and Layout in FanControlRow**
Open `Views/FanControlRow.swift`. Locate the `HStack(spacing: 8)` displaying the `fan.currentSpeed` and update its font:
```swift
                            .font(.system(size: 26, weight: .black, design: .monospaced))
```
Make sure `Text("RPM")` looks like:
```swift
                        Text("RPM")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.gray)
```

- [ ] **Step 2: Update Card Container**
Find the modifiers applied to the main `VStack` in `FanControlRow.swift`:
```swift
        .padding(20)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
```
Replace them with:
```swift
        .padding(20)
        .background(Color.white.opacity(0.02))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
```

- [ ] **Step 3: Update Preset Buttons**
Find `presetButton(title: String, val: Double)` function at the bottom. Replace its implementation with:
```swift
    func presetButton(title: String, val: Double) -> some View {
        Button(action: {
            sliderVal = val
            viewModel.changeFanSpeed(fanId: fan.id, speed: Int(val))
        }) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(sliderVal == val ? .teal : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(sliderVal == val ? Color.teal.opacity(0.1) : Color.white.opacity(0.02))
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(sliderVal == val ? Color.teal.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
```

- [ ] **Step 4: Update SpinningFanView to glow**
In `Views/SpinningFanView.swift` (assuming it exists, otherwise in `Views/FanControlRow.swift`), find `Image(systemName: "fan.fill")` and add:
```swift
        .shadow(color: Color.teal.opacity(currentSpeed > 1000 ? 0.6 : 0), radius: currentSpeed > 3000 ? 6 : 2)
```
*(If `SpinningFanView` is a separate component, edit its file. If we don't have access, add the shadow where the component is used in `FanControlRow.swift`.)*

- [ ] **Step 5: Run compilation check**
Run: `./build.sh`
Expected: Compile succeeds.

- [ ] **Step 6: Commit**
```bash
git add Views/FanControlRow.swift
git add Views/SpinningFanView.swift
git commit -m "style: redesign FanControlRow to match high-tech dark theme"
```
