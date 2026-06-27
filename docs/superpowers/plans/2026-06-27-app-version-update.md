# Version 3.0 Update Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bump the application version to 3.0 and render the active version string in the settings dashboard footer.

**Architecture:** Modify metadata keys in `build.sh` and append query values to `SettingsTabView`.

---

### Task 1: Bump version in build.sh
**Files:**
- Modify: `build.sh`

- [ ] **Step 1: Edit short version plist tag**
  In `build.sh`:
  Replace lines 124-126:
  ```xml
      <key>CFBundleShortVersionString</key>
      <string>2.0</string>
  ```
  with:
  ```xml
      <key>CFBundleShortVersionString</key>
      <string>3.0</string>
  ```

- [ ] **Step 2: Commit changes**
  Run: `git commit -am "chore: bump application version to 3.0 in build script"`

---

### Task 2: Add version footer to SettingsTabView
**Files:**
- Modify: `Views/SettingsTabView.swift`

- [ ] **Step 1: Insert version footer view**
  In `Views/SettingsTabView.swift`:
  Below the global controls block, insert a center-aligned `HStack` with dynamic bundle version text:
  ```swift
                  // Version Info
                  HStack {
                      Spacer()
                      Text("Version \(Bundle.main.infoDictionary?[\"CFBundleShortVersionString\"] as? String ?? \"3.0\") (Build \(Bundle.main.infoDictionary?[\"CFBundleVersion\"] as? String ?? \"1\"))")
                          .font(.system(size: 11, design: .monospaced))
                          .foregroundColor(.white.opacity(0.4))
                      Spacer()
                  }
                  .padding(.top, 16)
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "feat: display version and build number in Settings footer"`

---

### Task 3: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
