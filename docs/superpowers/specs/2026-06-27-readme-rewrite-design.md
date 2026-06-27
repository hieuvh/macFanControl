# Design Spec: Comprehensive README Update

This specification details a complete rewrite of the project's root `README.md` to accurately document the application's design choices, MVVM structure, Ventura-level APIs, security model, and performance characteristics.

## Content Strategy

1. **Feature Coverage**:
   * **Telemetry**: Real-time CPU, GPU (Indigo), Battery (Green) sensor cards with dynamic Swift Charts temperature log overlays.
   * **Animations**: Timeline-based vector fan blade widget rotating dynamically with hardware RPM, pausing instantly when hidden to conserve CPU.
   * **Rules Engine**: Safety-first automated overrides targeting CPU/GPU/Battery thresholds, evaluating the highest priority constraint.
   * **Quick Presets**: Single-pass auto, 20%, 50%, 80%, and Max buttons.
   * **App Setup**: Launch at startup using macOS native `SMAppService` API.
   * **Status Popover**: System tray utility popover showing live telemetry, presets, link state, and privilege setup cards.

2. **Privileged Helper Security Model**:
   * Document the split-binary design: the sandboxed SwiftUI App communicates with a setuid root-owned helper binary (`smc-helper`) executing raw SMC keys.

3. **Performance & Memory Footprint**:
   * Document dynamic polling (1.5s interactive, 5.0s background active, 30.0s background idle).
   * Document menu bar rendering caching (caching status images to bypass ImageRenderer draw loops).
   * Document O(N) single-pass statistics loops.

4. **Prerequisites & Compilation**:
   * Detail Xcode Command Line Tools requirements and target packaging commands using `./build.sh`.

5. **Screenshots & Assets**:
   * Link only the valid, existing `screenshot.png` file, removing references to non-existent image paths.

---

## Component-Level Details

### 1. Project Documentation
*   **File**: [README.md](file:///Users/hieuvh/Developer/projects/MacFanControl/README.md)
    *   Perform a complete rewrite of the markdown file to align with the specified layout.
