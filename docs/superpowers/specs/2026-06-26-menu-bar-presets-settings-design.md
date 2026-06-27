# Menu Bar Presets & Settings Design

## Goal
Enhance the menu bar popover for MacFanControl by providing quick preset speed buttons instead of a slider, and redesigning the bottom actions area into a horizontal toolbar with icons. Additionally, add support for a standard macOS Settings window and a "Sync All Fans" feature.

## Architecture & Components

### 1. MenuBarFanRow Updates
- **Replacing Slider with Presets**: The current `Slider` in `MenuBarFanRow` will be replaced by an `HStack` of 5 compact buttons (`Min`, `20%`, `50%`, `80%`, `Max`).
- **Logic**: Similar to the main `FanControlRow`, each preset button will calculate the appropriate RPM based on the fan's min and max speeds, and call `viewModel.changeFanSpeed(fanId:speed:)`.

### 2. Bottom Actions Toolbar (MenuBarPopoverView)
- **Layout**: Replace the vertical `VStack` of text buttons with an `HStack` of icon buttons (a horizontal layout).
- **Buttons**:
  - **Open App**: Icon `macwindow`.
  - **Sync All Fans**: Icon `link` or `arrow.triangle.2.circlepath`. (New Feature)
  - **Reset All**: Icon `arrow.counterclockwise`.
  - **Settings**: Icon `gearshape`. (New Feature)
  - **Quit**: Icon `power`.
- **Styling**: The buttons will use vertical layouts (`VStack { Image; Text }` with very small text, or just icons with Tooltips depending on available space). Given the user's "vertical icon" request, it will be an icon above small text.

### 3. Settings Scene Integration
- **SettingsView**: Create a new file `SettingsView.swift` containing a basic `TabView` layout (the standard macOS settings window pattern). It will serve as a placeholder for future settings.
- **App Update**: In `FanControlApp.swift`, add a `Settings { SettingsView() }` block to register the native settings window.
- **Invocation**: The new Settings icon button in the menu bar will call `NSApp.sendAction(Selector("showSettingsWindow:"), to: nil, from: nil)` to natively open the settings window.

### 4. Sync All Fans Logic
- **FanViewModel**: Add a `syncAllFans(toSpeed: Int, orPercentage: Double)` or just a mode flag if "Sync" means linking the speeds of all fans together. If it just means applying the same manual mode and speed, we will implement `syncAllFans(speed:)`. We will clarify during implementation if needed, but the UI button will be added.

## Data Flow
- Preset buttons trigger the existing `viewModel.changeFanSpeed` method.
- The new Sync All Fans button triggers a new `viewModel.syncAllFans` method.

## Error Handling & Edge Cases
- Auto Mode Disabled State: The preset buttons will be visually disabled or hidden if the fan is in "Auto" mode, ensuring the user understands they cannot set a speed manually while Auto is active.
