# Menu Bar Popover Authorization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate a compact helper authorization request card into the status menu bar popover when the helper tool is unauthorized.

**Architecture:** Modify the structure of `MenuBarPopoverView` to conditionally swap the empty fan row list with a helper authorization alert when `viewModel.isAuthorized` is `false`.

**Tech Stack:** SwiftUI, AppKit, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Update MenuBarPopoverView Layout
**Files:**
- Modify: `Views/MenuBarPopoverView.swift`

- [ ] **Step 1: Replace standard middle fan rows with conditional check**
  In `Views/MenuBarPopoverView.swift`:
  Replace lines 17-23:
  ```swift
              // Middle Section: Fans
              VStack(spacing: 12) {
                  ForEach(viewModel.fans) { fan in
                      MenuBarFanRow(fan: fan, viewModel: viewModel)
                  }
              }
              .padding(.horizontal)
  ```
  with:
  ```swift
              // Middle Section: Fans / Authorization
              if !viewModel.isAuthorized {
                  VStack(alignment: .leading, spacing: 10) {
                      HStack(spacing: 8) {
                          Image(systemName: "exclamationmark.triangle.fill")
                              .foregroundColor(.orange)
                              .font(.system(size: 14))
                          Text("Authorization required")
                              .font(.system(size: 12, weight: .semibold))
                      }
                      
                      Text("Authorize to manage fans and read sensors.")
                          .font(.system(size: 11))
                          .foregroundColor(.gray)
                      
                      Button(action: { viewModel.authorize() }) {
                          Text("Authorize")
                              .font(.system(size: 11, weight: .medium))
                              .padding(.vertical, 6)
                              .padding(.horizontal, 12)
                              .background(Color.orange)
                              .foregroundColor(.black)
                              .cornerRadius(6)
                      }
                      .buttonStyle(PlainButtonStyle())
                  }
                  .padding(12)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(Color.orange.opacity(0.1))
                  .cornerRadius(8)
                  .overlay(
                      RoundedRectangle(cornerRadius: 8)
                          .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                  )
                  .padding(.horizontal)
              } else {
                  VStack(spacing: 12) {
                      ForEach(viewModel.fans) { fan in
                          MenuBarFanRow(fan: fan, viewModel: viewModel)
                      }
                  }
                  .padding(.horizontal)
              }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "feat: add helper authorization warning card in menu bar popover when unauthorized"`

---

### Task 2: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
