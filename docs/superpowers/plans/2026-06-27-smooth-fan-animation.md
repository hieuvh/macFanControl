# Smooth Fan Animation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a seamlessly interpolating visual animation for the current RPM text and fan rotation that smooths out 1.5-second polling intervals.

**Architecture:** We will create an `AnimatableModifier` that takes a Double target value and drives a Text view. The views `FanControlRow` and `MenuBarFanRow` will maintain a local `@State` bound to `fan.currentSpeed` using `withAnimation(.linear(duration: 1.5))`.

**Tech Stack:** SwiftUI, Combine

## Global Constraints

- Target OS: macOS 13.0
- Architecture: arm64/x86_64
- Polling Interval: 1.5 seconds

---

### Task 1: Create `AnimatableNumberModifier`

**Files:**
- Create: `Views/AnimatableNumberModifier.swift`

**Interfaces:**
- Produces: `struct AnimatableNumberModifier: AnimatableModifier` and `extension View { func animatableNumber(value: Double) -> some View }`

- [ ] **Step 1: Write minimal implementation**

```swift
import SwiftUI

struct AnimatableNumberModifier: AnimatableModifier {
    var animatableData: Double
    
    init(value: Double) {
        self.animatableData = value
    }
    
    func body(content: Content) -> some View {
        Text("\(Int(animatableData))")
    }
}

extension View {
    func animatableNumber(value: Double) -> some View {
        self.modifier(AnimatableNumberModifier(value: value))
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Views/AnimatableNumberModifier.swift
git commit -m "feat: add AnimatableNumberModifier for smooth value interpolation"
```

### Task 2: Update `SpinningFanView`

**Files:**
- Modify: `Views/SpinningFanView.swift`

**Interfaces:**
- Consumes: No change to signature (`currentSpeed: Double`).

- [ ] **Step 1: Write minimal implementation**

The `SpinningFanView` currently has a `TimelineView` with `.onChange(of: timeline.date)`. If `currentSpeed` is bound to an animated state from the parent, its value will change every frame smoothly.

Wait, `SpinningFanView`'s TimelineView is fine, but it does `angle += delta`. No changes are actually strictly required inside `SpinningFanView` if the parent feeds it an animated `currentSpeed`. But wait, in SwiftUI, if a parent passes an animated `currentSpeed: Double`, does the child see it update every frame if it's just a `let`? No, standard `let` properties do not trigger body redraws *during* the animation frames unless they are wrapped in an `AnimatableModifier` or use `VectorArithmetic`.

To allow `SpinningFanView` to receive interpolated values during the animation, we must make `SpinningFanView` conform to `Animatable`, or use a binding, or let the parent handle the modifier.

Actually, the simplest way is to conform `SpinningFanView` to `Animatable`.

```swift
import SwiftUI

// MARK: - Animated Custom Vector Fan View
struct SpinningFanView: View, Animatable {
    var currentSpeed: Double
    let maxSpeed: Double
    var size: CGFloat = 80 // Default size for main app
    @State private var angle: Double = 0.0
    
    var animatableData: Double {
        get { currentSpeed }
        set { currentSpeed = newValue }
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Image(systemName: "fan.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.white.opacity(currentSpeed > 0 ? 0.8 : 0.3))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(angle))
                .shadow(color: Color.teal.opacity(currentSpeed > 1000 ? 0.6 : 0), radius: currentSpeed > 3000 ? 6 : 2)
            .onChange(of: timeline.date) { _ in
                // Standardize rotation step to speed
                // 1000 RPM -> ~4 deg per frame
                let delta = max(currentSpeed, 200.0) / 1000.0 * 3.5
                angle += delta
                if angle >= 360 { angle -= 360 }
            }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Views/SpinningFanView.swift
git commit -m "feat: make SpinningFanView animatable to receive interpolated speeds"
```

### Task 3: Integrate Animations into `FanControlRow`

**Files:**
- Modify: `Views/FanControlRow.swift`

**Interfaces:**
- Consumes: `AnimatableNumberModifier`

- [ ] **Step 1: Write minimal implementation**

Add `@State private var animatableSpeed: Double = 0.0`
Replace `Text("\(fan.currentSpeed)")` with `Text("").animatableNumber(value: animatableSpeed)`
Pass `animatableSpeed` to `SpinningFanView` instead of `Double(fan.currentSpeed)`
Add `.onChange(of: fan.currentSpeed) { withAnimation(.linear(duration: 1.5)) { animatableSpeed = Double($0) } }`

```swift
import SwiftUI
import Combine

// MARK: - Individual Fan Control Row
struct FanControlRow: View {
    let fan: FanJSON
    @ObservedObject var viewModel: FanViewModel
    
    @State private var sliderVal: Double = 0.0
    @State private var isEditingSlider: Bool = false
    @State private var sliderPublisher = PassthroughSubject<Double, Never>()
    @State private var animatableSpeed: Double = 0.0
    
    init(fan: FanJSON, viewModel: FanViewModel) {
        self.fan = fan
        self.viewModel = viewModel
        // Initial setup of state
        _sliderVal = State(initialValue: Double(fan.targetSpeed))
        _animatableSpeed = State(initialValue: Double(fan.currentSpeed))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Info
            HStack(spacing: 16) {
                SpinningFanView(currentSpeed: animatableSpeed, maxSpeed: Double(fan.maxSpeed))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(fan.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Text("")
                            .animatableNumber(value: animatableSpeed)
                            .font(.system(size: 26, weight: .black, design: .monospaced))
                            .foregroundColor(rpmColor)
                        Text("RPM")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.gray)
                            .offset(y: 4)
                    }
                }
                
                Spacer()
            }
// ...
// At the bottom of the View modifiers
        .onChange(of: fan.currentSpeed) { newSpeed in
            withAnimation(.linear(duration: 1.5)) {
                animatableSpeed = Double(newSpeed)
            }
        }
```

Wait, `Text("")` does not apply the font formatting properly if the modifier returns `Text`. The `animatableNumber` modifier completely replaces the text, but modifiers applied *after* `animatableNumber` will wrap the modified view. Yes, this works.

- [ ] **Step 2: Commit**

```bash
git add Views/FanControlRow.swift
git commit -m "feat: integrate smooth animatable speed into FanControlRow"
```

### Task 4: Integrate Animations into `MenuBarFanRow`

**Files:**
- Modify: `Views/MenuBarPopoverView.swift`

**Interfaces:**
- Consumes: `AnimatableNumberModifier`

- [ ] **Step 1: Write minimal implementation**

Inside `MenuBarFanRow`:
Add `@State private var animatableSpeed: Double = 0.0`
Replace `Text("\(fan.currentSpeed) RPM")` with `Text("").animatableNumber(value: animatableSpeed) + Text(" RPM")` (Actually better to use HStack or modify `AnimatableNumberModifier` to take a suffix). Let's change `AnimatableNumberModifier` in Task 1 to take an optional suffix string. No, an HStack is fine.

```swift
    @State private var animatableSpeed: Double = 0.0
// ...
        .onAppear {
            sliderVal = Double(fan.targetSpeed)
            animatableSpeed = Double(fan.currentSpeed)
        }
        .onChange(of: fan.currentSpeed) { newSpeed in
            withAnimation(.linear(duration: 1.5)) {
                animatableSpeed = Double(newSpeed)
            }
        }
// ...
            HStack(spacing: 2) {
                Text("")
                    .animatableNumber(value: animatableSpeed)
                Text("RPM")
            }
            .font(.caption)
            .foregroundColor(.secondary)
```

- [ ] **Step 2: Commit**

```bash
git add Views/MenuBarPopoverView.swift
git commit -m "feat: integrate smooth animatable speed into MenuBarFanRow"
```

### Task 5: Final Validation

- [ ] **Step 1: Run build**

```bash
./build.sh
```

- [ ] **Step 2: Run application and test manually**
Drag the fan slider to 6000 RPM. Observe that the RPM texts smoothly count upwards in real time, and the fan rotation speeds up smoothly.
