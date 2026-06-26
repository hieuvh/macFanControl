# Main App UI Redesign: Pro / High-Tech Dark

## Goal
Overhaul the visual aesthetic of the main `ContentView` and its subcomponents (`TempMetricCard`, `FanControlRow`) to adopt a "Pro / High-Tech Dark" theme. This gives the application a sleek, cyberpunk hardware controller vibe.

## Architecture & Components

### 1. Color Palette & Typography
- **Global Background**: Change to `#0A0A0C` (very dark space gray) from the current `Color(red: 0.08, green: 0.08, blue: 0.1)`.
- **Accents**: Use Neon Cyan (`.teal` or `.cyan`) for primary interactive elements. Keep `.orange`, `.purple`, and `.green` for CPU, GPU, and Battery respectively.
- **Typography**: Apply `.monospacedDigit()` and `.design(.monospaced)` to all telemetry values (RPM, Temperature). Use uppercase, bold styling with slight letter spacing for small labels (e.g., "RPM", "TARGET SPEED").

### 2. Component Styling Updates

#### ContentView
- **Header**: Change the "v2.0" version badge to look like a terminal tag (e.g., green monospaced text on a dark green translucent background).

#### TempMetricCard
- **Layout**: Hollow out the solid background. Use `Color.white.opacity(0.02)` fill with a thin `.stroke(Color.white.opacity(0.1))` border.
- **Active State**: When selected (`isSelected == true`), change the border to glow with the icon's color (`.stroke(iconColor.opacity(0.8), lineWidth: 1)`).
- **Icons**: Add a subtle `.shadow(color: iconColor.opacity(0.6), radius: 4)` drop shadow to create a glowing effect.
- **Font**: Update temperature reading to use `.monospacedDigit()`.

#### FanControlRow
- **Card Container**: Update the background from `Color.white.opacity(0.03)` to `Color.white.opacity(0.02)` and use a slightly sharper corner radius (`12` instead of `16`). Update the stroke to match the new wireframe aesthetic.
- **Values**: Apply monospaced font to the current speed, max speed, and target speed percentage labels.
- **Preset Buttons**: Update the manual mode preset buttons to have sharper corners (`cornerRadius(4)`). Give them a wireframe look: translucent dark fill with a subtle border.
- **Spinning Fan Icon**: Add a subtle teal/cyan glow behind or around the fan icon if it's spinning at high speeds.

## Verification Plan
- Build the app via `./build.sh` to ensure there are no SwiftUI syntax errors.
- Test the app visually by running the executable to confirm the UI matches the new aesthetic.
- Ensure hover states and selected states on the telemetry cards transition smoothly.
