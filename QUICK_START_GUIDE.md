# iOS 26 Migration Quick Start Guide
**Get Started in 5 Minutes**

---

## Prerequisites

Before you begin, ensure you have:
- ✅ macOS 15.0+ (Sequoia)
- ✅ 50GB free disk space
- ✅ Apple Developer account
- ✅ ManifestAndMatch V7 codebase access

---

## Step 1: Install Xcode 26 (15 minutes)

```bash
# Download Xcode 26.0 from:
# https://developer.apple.com/download/

# After installation, set as active:
sudo xcode-select --switch /Applications/Xcode.app

# Verify:
xcodebuild -version
# Should output: Xcode 26.0
```

---

## Step 2: Install iOS 26 Simulator (5 minutes)

```
1. Open Xcode
2. Xcode → Settings → Platforms
3. Click "+" to add platform
4. Select "iOS 26.0.1"
5. Click "Download" (wait for completion)
```

---

## Step 3: Build Project on iOS 26 (10 minutes)

```bash
# Navigate to project
cd "/Users/jasonl/Desktop/manifest and match  v7/V7 build files/v7codebase/Manifest_and_Match_V7_Working code base: instruction files /upgrade/v_7_uppgrade"

# Open workspace
open ManifestAndMatchV7.xcworkspace

# Build for iOS 26 simulator
xcodebuild -workspace ManifestAndMatchV7.xcworkspace \
           -scheme ManifestAndMatchV7 \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0' \
           build
```

**Expected Output**:
```
BUILD SUCCEEDED
** BUILD SUCCEEDED **
```

**If Build Fails**:
1. Check error messages carefully
2. Most common: Missing package dependencies
3. Solution: File → Packages → Update to Latest Package Versions
4. Rebuild

---

## Step 4: Test on iOS 26 Simulator (5 minutes)

```bash
# Boot iPhone 16 Pro simulator
xcrun simctl boot "iPhone 16 Pro"

# Open Simulator app
open -a Simulator

# Run app from Xcode
# Xcode → Product → Run (Cmd+R)
```

**What to Check**:
- ✅ App launches successfully
- ✅ Liquid Glass visible (translucent backgrounds)
- ✅ Sacred 4-tab UI still intact
- ✅ Job cards display correctly
- ✅ Swipe gestures work

**Test Liquid Glass Modes**:
```
1. Settings → Display & Brightness → Liquid Glass
2. Toggle between "Clear" and "Tinted"
3. Return to app, observe visual changes
4. Verify text remains readable in both modes
```

---

## Step 5: Run Initial Tests (10 minutes)

```bash
# Run full test suite
xcodebuild test \
  -workspace ManifestAndMatchV7.xcworkspace \
  -scheme ManifestAndMatchV7 \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0'

# Expected: All tests pass
# If tests fail: Review test output for iOS 26 compatibility issues
```

---

## Next Steps

### If Everything Works ✅
**Congratulations!** You've completed Phase 0 successfully.

**Next Actions**:
1. Read the full master plan: `IOS26_MANIFEST_AND_MATCH_MASTER_PLAN.md`
2. Start Phase 1 (Skills System Bias Fix) in Week 2
3. Set up monitoring infrastructure (Sentry, Firebase)

### If Build Fails ❌
**Common Issues & Solutions**:

**Issue 1: "No such module 'V7Core'"**
```bash
Solution:
File → Packages → Reset Package Caches
File → Packages → Update to Latest Package Versions
Clean Build Folder (Cmd+Shift+K)
Rebuild (Cmd+B)
```

**Issue 2: "iOS 26 SDK not found"**
```bash
Solution:
Verify Xcode 26 is active:
xcode-select -p
# Should output: /Applications/Xcode.app/Contents/Developer

If not:
sudo xcode-select --switch /Applications/Xcode.app
```

**Issue 3: "Minimum deployment target is iOS 18.0"**
```bash
Solution:
1. Open project settings
2. Select ManifestAndMatchV7 target
3. General → Deployment Info
4. Change "iOS Deployment Target" to 26.0
5. Rebuild
```

**Issue 4: View hierarchy changes break UI tests**
```swift
// iOS 26 adds UIDropShadowView to hierarchy
// Update test selectors:

// Old (iOS 18):
app.buttons["submitButton"].tap()

// New (iOS 26):
app.descendants(matching: .button)
   .matching(identifier: "submitButton")
   .firstMatch
   .tap()
```

---

## Daily Development Workflow

### Morning Routine
```bash
# 1. Pull latest changes
git pull origin ios26-migration

# 2. Update packages
# Xcode → File → Packages → Update to Latest

# 3. Clean build (if needed)
xcodebuild clean -workspace ManifestAndMatchV7.xcworkspace

# 4. Build and run
xcodebuild build \
  -workspace ManifestAndMatchV7.xcworkspace \
  -scheme ManifestAndMatchV7 \
  -sdk iphonesimulator
```

### Before Committing Changes
```bash
# 1. Run tests
xcodebuild test \
  -workspace ManifestAndMatchV7.xcworkspace \
  -scheme ManifestAndMatchV7 \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0'

# 2. Check for warnings
# Build should show "0 Warnings"

# 3. Verify performance targets
# Thompson scoring: <10ms
# Foundation Models: <50ms
# Memory: <200MB

# 4. Test accessibility
# Enable VoiceOver and test critical flows
```

---

## Troubleshooting Resources

### Apple Documentation
- iOS 26 Release Notes: https://developer.apple.com/ios/
- Foundation Models Guide: https://developer.apple.com/documentation/foundationmodels
- Liquid Glass Design: https://developer.apple.com/design/liquid-glass
- Migration Guide: https://developer.apple.com/ios/migration/

### Community Resources
- Hacking with Swift iOS 26: https://hackingwithswift.com/ios26
- SwiftUI Changes: https://swiftui-changes.com
- Foundation Models Examples: GitHub search "foundation models ios 26"

### Internal Resources
- Full Master Plan: `IOS26_MANIFEST_AND_MATCH_MASTER_PLAN.md`
- Skills Reference: `/.claude/skills/` (21 guardian skills)
- V7 Master Plan: `../upgrade/MASTER_V7_DEVELOPMENT_PLAN_2025-10-27.md`

---

## Success Checklist

**Phase 0 Complete When**:
- [x] Xcode 26 installed and active
- [x] iOS 26 simulators available
- [x] Project builds successfully on iOS 26
- [x] App runs on iOS 26 simulator with Liquid Glass
- [x] All tests pass
- [x] Sacred constraints maintained (<10ms Thompson, 4-tab UI)

**Ready for Phase 1**:
- [x] Phase 0 checklist complete
- [x] Master plan reviewed and understood
- [x] Week 2 sprint planned (Skills System Bias Fix)
- [x] Team aligned on timeline and priorities

---

## Getting Help

**If Stuck**:
1. Check this guide first
2. Review master plan for detailed context
3. Search Apple Developer Forums
4. Check iOS 26 migration documentation
5. Review error logs carefully (often self-explanatory)

**Emergency Contact**:
- File an issue in the project repository
- Include: Error message, steps to reproduce, Xcode version, iOS version

---

**Last Updated**: October 27, 2025
**Target**: Complete Phase 0 by end of Week 1
**Next Phase**: Phase 1 (Skills System) starts Week 2
