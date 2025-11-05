# Phase 3.5 Build Error Fixes

## Issue #1: PreferencesStepView.swift - Missing jobTitlesSection

**Files Affected**: `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/Steps/PreferencesStepView.swift`

**Root Cause**: Incomplete Phase 7 refactor - file references old sector-based properties that don't exist

**Solution**: Replace `careerFieldsSection` (lines 334-497) with `jobTitlesSection` from NEW_JOB_TITLES_SECTION.swift

**Actions**:
1. Delete lines 334-497 (old careerFieldsSection and supporting views)
2. Insert new jobTitlesSection code from NEW_JOB_TITLES_SECTION.swift
3. Code is already present in project root - just needs to be integrated

## Issue #2: WorkExperienceCollectionStepView.swift - Sendable Violations

**Files Affected**: `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/Steps/WorkExperienceCollectionStepView.swift`

**Root Cause**: Swift 6 strict concurrency - `Content.Type` captured in alignment guide closures (lines 773, 786)

**Solution**: Mark PreferencesFlowLayout.LayoutState as `@unchecked Sendable`

**Fix Location**: Around line 797-800

**Before**:
```swift
// ✅ Layout state for synchronous alignment guide calculations
// @unchecked Sendable is safe here because:
// - Alignment guides execute synchronously during SwiftUI layout pass
```

**After**:
```swift
// ✅ Layout state for synchronous alignment guide calculations
// @unchecked Sendable is safe here because:
// - Alignment guides execute synchronously during SwiftUI layout pass
// - No concurrent access possible within single layout cycle
// - All mutations happen on MainActor during view rendering
@unchecked Sendable
```

Then mark the class itself:
```swift
private final class LayoutState: @unchecked Sendable {
    var width: CGFloat = 0
    var height: CGFloat = 0
}
```

## Implementation Steps

### Step 1: Fix PreferencesStepView.swift

Navigate to line 334 and delete until line 497 (careerFieldsSection + supporting views).

Insert content from NEW_JOB_TITLES_SECTION.swift starting at line 334.

### Step 2: Fix WorkExperienceCollectionStepView.swift

Find PreferencesFlowLayout.LayoutState class declaration (around line 800).

Add `@unchecked Sendable` conformance to the class.

### Step 3: Verify Build

Run: `mcp__XcodeBuildMCP__build_sim` with ManifestAndMatchV7 scheme

Expected: 0 errors (all 19 errors should be resolved)

## Testing Checklist

- [ ] PreferencesStepView compiles without errors
- [ ] Job title selection UI renders correctly
- [ ] Search functionality works (1016 O*NET roles)
- [ ] Popular roles grid displays
- [ ] Selected roles chips appear
- [ ] WorkExperienceCollectionStepView compiles without Sendable warnings
- [ ] Swift 6 strict concurrency mode passes
- [ ] Full app builds successfully on simulator

## V8-Omniscient-Guardian Sign-Off

**Diagnosis**: ✅ Complete - Both issues identified with precise line numbers and solutions
**Risk Level**: LOW - Changes are surgical and well-defined
**Complexity**: MEDIUM - Requires file editing and understanding Phase 7 refactor
**Testing**: Required - UI functionality must be verified after integration

---

**Status**: Ready for implementation
**Est. Time**: 15-20 minutes
**Next**: Apply fixes then rebuild
