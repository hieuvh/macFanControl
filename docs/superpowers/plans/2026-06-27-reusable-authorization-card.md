# Reusable Authorization Card Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a common, reusable `AuthorizationRequiredCard` view and refactor existing warnings in Overview, Settings, and Menu Bar popover to use it.

**Architecture:** We will build a unified warning component that supports standard and compact layouts, replacing duplicate visual styles.

**Tech Stack:** SwiftUI, macOS SDK 13.0+

## Global Constraints
- Target macOS version: macOS 13.0
- Build must compile successfully using `./build.sh` at each step.

---

### Task 1: Create AuthorizationRequiredCard View Component
**Files:**
- Create: `Views/AuthorizationRequiredCard.swift`

- [ ] **Step 1: Write View class implementation**
  Create the view component file at `Views/AuthorizationRequiredCard.swift`.

  Code:
  ```swift
  import SwiftUI

  struct AuthorizationRequiredCard: View {
      @ObservedObject var viewModel: FanViewModel
      var compact: Bool = false
      
      var body: some View {
          VStack(alignment: .leading, spacing: compact ? 10 : 16) {
              HStack(spacing: compact ? 8 : 12) {
                  Image(systemName: "exclamationmark.triangle.fill")
                      .foregroundColor(.orange)
                      .font(.system(size: compact ? 14 : 20))
                  Text("Authorization required")
                      .font(.system(size: compact ? 12 : 14, weight: .semibold))
              }
              
              Text(compact ? "Authorize to manage fans and read sensors." : "Authorize to manage fan speeds and read hardware sensors.")
                  .font(.system(size: compact ? 11 : 12))
                  .foregroundColor(.gray)
              
              Button(action: { viewModel.authorize() }) {
                  Text("Authorize")
                      .font(.system(size: compact ? 11 : 12, weight: .medium))
                      .padding(.vertical, compact ? 6 : 10)
                      .padding(.horizontal, compact ? 12 : 16)
                      .background(Color.orange)
                      .foregroundColor(.black)
                      .cornerRadius(compact ? 6 : 8)
              }
              .buttonStyle(PlainButtonStyle())
          }
          .padding(compact ? 12 : 16)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(Color.orange.opacity(0.1))
          .cornerRadius(compact ? 8 : 12)
          .overlay(
              RoundedRectangle(cornerRadius: compact ? 8 : 12)
                  .stroke(Color.orange.opacity(0.3), lineWidth: 1)
          )
      }
  }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git add Views/AuthorizationRequiredCard.swift && git commit -m "feat: create reusable AuthorizationRequiredCard component"`

---

### Task 2: Refactor OverviewTabView to use AuthorizationRequiredCard
**Files:**
- Modify: `Views/OverviewTabView.swift`

- [ ] **Step 1: Replace warning box with component call**
  In `Views/OverviewTabView.swift`:
  Replace lines 13-47:
  ```swift
                  if !viewModel.isAuthorized {
                      // Privilege setup card
                      VStack(alignment: .leading, spacing: 16) {
                          HStack(spacing: 12) {
                              Image(systemName: "exclamationmark.triangle.fill")
                                  .foregroundColor(.orange)
                                  .font(.system(size: 20))
                              Text("Authorization required")
                                  .font(.system(size: 14, weight: .semibold))
                          }
                          
                          Text("Authorize to manage fan speeds and read hardware sensors.")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
                          
                          Button(action: { viewModel.authorize() }) {
                              Text("Authorize")
                                  .font(.system(size: 12, weight: .medium))
                                  .padding(.vertical, 10)
                                  .padding(.horizontal, 16)
                                  .background(Color.orange)
                                  .foregroundColor(.black)
                                  .cornerRadius(8)
                          }
                          .buttonStyle(PlainButtonStyle())
                      }
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .background(Color.orange.opacity(0.1))
                      .cornerRadius(12)
                      .overlay(
                          RoundedRectangle(cornerRadius: 12)
                              .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                      )
                  }
  ```
  with:
  ```swift
                  if !viewModel.isAuthorized {
                      AuthorizationRequiredCard(viewModel: viewModel)
                  }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected output: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "refactor: use AuthorizationRequiredCard in OverviewTabView"`

---

### Task 3: Refactor SettingsTabView to use AuthorizationRequiredCard
**Files:**
- Modify: `Views/SettingsTabView.swift`

- [ ] **Step 1: Replace warning box with component call**
  In `Views/SettingsTabView.swift`:
  Replace lines 12-46:
  ```swift
                  if !viewModel.isAuthorized {
                      // Privilege setup card
                      VStack(alignment: .leading, spacing: 16) {
                          HStack(spacing: 12) {
                              Image(systemName: "exclamationmark.triangle.fill")
                                  .foregroundColor(.orange)
                                  .font(.system(size: 20))
                              Text("Authorization required")
                                  .font(.system(size: 14, weight: .semibold))
                          }
                          
                          Text("Authorize to manage fan speeds and read hardware sensors.")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
                          
                          Button(action: { viewModel.authorize() }) {
                              Text("Authorize")
                                  .font(.system(size: 12, weight: .medium))
                                  .padding(.vertical, 10)
                                  .padding(.horizontal, 16)
                                  .background(Color.orange)
                                  .foregroundColor(.black)
                                  .cornerRadius(8)
                          }
                          .buttonStyle(PlainButtonStyle())
                      }
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                      .background(Color.orange.opacity(0.1))
                      .cornerRadius(12)
                      .overlay(
                          RoundedRectangle(cornerRadius: 12)
                              .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                      )
                  }
  ```
  with:
  ```swift
                  if !viewModel.isAuthorized {
                      AuthorizationRequiredCard(viewModel: viewModel)
                  }
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "refactor: use AuthorizationRequiredCard in SettingsTabView"`

---

### Task 4: Refactor MenuBarPopoverView to use AuthorizationRequiredCard
**Files:**
- Modify: `Views/MenuBarPopoverView.swift`

- [ ] **Step 1: Replace popover warning box with component call**
  In `Views/MenuBarPopoverView.swift`:
  Replace lines 18-51:
  ```swift
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
  ```
  with:
  ```swift
              if !viewModel.isAuthorized {
                  AuthorizationRequiredCard(viewModel: viewModel, compact: true)
                      .padding(.horizontal)
  ```

- [ ] **Step 2: Verify compilation**
  Run: `./build.sh`
  Expected: Build success.

- [ ] **Step 3: Commit changes**
  Run: `git commit -am "refactor: use AuthorizationRequiredCard in MenuBarPopoverView"`

---

### Task 5: Full Application Build & Verification
**Files:**
- None

- [ ] **Step 1: Clean build application**
  Run: `./build.sh`
  Expected output: Build and Packaging Complete.
