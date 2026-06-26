# Smooth Fan Animation Design

## Goal
Make the UI and UX feel perfectly smooth by visually interpolating the fan's current speed readings between hardware polling intervals. This eliminates the visual "jumping" of RPM numbers and rotation speeds while the physical fan ramps up or down.

## Background
The hardware fan takes several seconds to spin up to a target speed. The app polls the hardware every 1.5 seconds. Currently, the UI instantly updates to reflect the raw hardware polling data, causing the `currentSpeed` RPM text and the `SpinningFanView`'s rotation delta to jump abruptly every 1.5 seconds (e.g., 2000 -> 3500 -> 4800).

## Architecture & Data Flow

1. **Local View State:**
   Views that display the `currentSpeed` (e.g., `FanControlRow` and `MenuBarFanRow`) will maintain a local `@State private var animatableSpeed: Double` instead of directly binding to the raw `fan.currentSpeed` Integer.
   
2. **State Synchronization:**
   The views will use an `.onChange(of: fan.currentSpeed)` modifier. When the 1.5-second polling loop updates the hardware speed, the view will execute:
   `withAnimation(.linear(duration: 1.5)) { animatableSpeed = Double(fan.currentSpeed) }`
   This ensures the local display value constantly interpolates towards the newest hardware snapshot over the exact duration of the polling interval.

## Components

### 1. `AnimatableNumberModifier`
We will create a custom `ViewModifier` (or extension) that conforms to `Animatable`.
- **Purpose**: SwiftUI's `Text` view cannot inherently interpolate an integer string value over time. An `AnimatableModifier` allows us to feed it the `animatableSpeed` Double. As SwiftUI drives the animation from the old value to the new value over 1.5 seconds, the modifier will be redrawn every frame (60fps), allowing us to format and display the interpolated number (e.g., 2015, 2030, 2045) in real-time.

### 2. `SpinningFanView`
- **Purpose**: It currently receives the raw `fan.currentSpeed`. It will now receive the `animatableSpeed` Double.
- **Behavior**: Because the `animatableSpeed` will be smoothly changing every frame, the rotation `delta` calculated inside the `TimelineView` will scale smoothly, completely eliminating any jarring hiccups in the fan blade animation.

## Verification
- Change the fan speed from Min to Max and observe the RPM text visually counting up rapidly and smoothly without any 1.5-second skips.
- Observe the spinning fan icon to ensure its rotation accelerates and decelerates seamlessly.
