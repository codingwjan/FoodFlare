# FoodFlare iOS 26 Build Revival Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Upgrade the FoodFlare Xcode project to target iOS 26 and finish with a simulator build that completes without errors.

**Architecture:** Keep the existing single-project SwiftUI app and widget structure intact. Limit changes to project configuration and only touch source or assets if the Xcode 26/iOS 26 build exposes real regressions that block compilation.

**Tech Stack:** Xcode project (`.pbxproj`), SwiftUI, WidgetKit, Core Data, Core ML

---

### Task 1: Establish the failing build baseline

**Files:**
- Modify: `Front End/FoodFlare App/FoodFlare.xcodeproj/project.pbxproj`
- Create: `docs/plans/2026-03-22-ios-26-build-revival.md`

**Step 1: Reproduce the current build**

Run: `xcodebuild -project 'Front End/FoodFlare App/FoodFlare.xcodeproj' -scheme 'FoodFlare' -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.3.1' build`
Expected: Build reaches Xcode 26 toolchain, revealing whether deployment targets or source compatibility block the build.

**Step 2: Inspect current deployment target values**

Run: `rg -n 'IPHONEOS_DEPLOYMENT_TARGET' 'Front End/FoodFlare App/FoodFlare.xcodeproj/project.pbxproj'`
Expected: App target shows `16.4`; widget target shows `17.0`.

### Task 2: Upgrade project deployment targets

**Files:**
- Modify: `Front End/FoodFlare App/FoodFlare.xcodeproj/project.pbxproj`

**Step 1: Change all iPhone deployment targets to iOS 26**

Set every `IPHONEOS_DEPLOYMENT_TARGET` entry in the project to `26.0`.

**Step 2: Keep the change minimal**

Do not refactor unrelated build settings. Preserve bundle IDs, plist paths, and existing target structure.

### Task 3: Rebuild and fix concrete breakages

**Files:**
- Modify: `Front End/FoodFlare App/FoodFlare.xcodeproj/project.pbxproj`
- Modify if required: `Front End/FoodFlare App/FoodFlare App/**/*.swift`
- Modify if required: `Front End/FoodFlare App/FoodFlare Widget/**/*.swift`
- Modify if required: `Front End/FoodFlare App/FoodFlare App/Assets.xcassets/**`

**Step 1: Run the simulator build again**

Run: `xcodebuild -project 'Front End/FoodFlare App/FoodFlare.xcodeproj' -scheme 'FoodFlare' -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.3.1' build`
Expected: Either `BUILD SUCCEEDED` or a precise list of errors/warnings caused by the iOS 26 upgrade.

**Step 2: Fix one root cause at a time**

Use the build log to identify the first real failure, make the smallest possible fix, and rebuild.

**Step 3: Repeat until clean**

Continue build/fix iterations until the build exits successfully with no errors.

### Task 4: Verify the final state

**Files:**
- Modify if required: `Front End/FoodFlare App/FoodFlare.xcodeproj/project.pbxproj`

**Step 1: Run a fresh verification build**

Run: `xcodebuild -project 'Front End/FoodFlare App/FoodFlare.xcodeproj' -scheme 'FoodFlare' -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.3.1' build`
Expected: Exit code `0` and `BUILD SUCCEEDED`.

**Step 2: Confirm final deployment targets**

Run: `rg -n 'IPHONEOS_DEPLOYMENT_TARGET' 'Front End/FoodFlare App/FoodFlare.xcodeproj/project.pbxproj'`
Expected: Every iOS target shows `26.0`.
