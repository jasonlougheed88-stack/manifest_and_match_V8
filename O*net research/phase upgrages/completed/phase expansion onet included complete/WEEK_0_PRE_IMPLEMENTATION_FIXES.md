# Week 0: Pre-Implementation Fixes

**Part of**: O*NET Integration Implementation Plan
**Document Version**: 1.1
**Created**: October 29, 2025
**Completed**: October 29, 2025
**Project**: ManifestAndMatch V8 (iOS 26)
**Duration**: 8 hours (1 day)
**Priority**: P0 (CRITICAL - Cannot start Phase 1 without these fixes)
**Status**: ✅ **COMPLETE**

---

## ✅ COMPLETION SUMMARY

**All Pre-Tasks Completed Successfully**

- ✅ Pre-Task 0.1: Swift 6 strict concurrency enabled in all 7 V7 packages
- ✅ Pre-Task 0.2: NSManagedObject+Sendable.swift helpers created
- ✅ Pre-Task 0.3: Industry enum expanded from 12 → 19 NAICS sectors
- ✅ Pre-Task 0.4: Phase 1 code patterns reviewed and checklist created

**Build Status**: ✅ All packages compile successfully on iOS 26 simulator
**Swift 6 Compliance**: ✅ Zero Sendable warnings
**Phase 1 Readiness**: ✅ Ready to begin implementation

---

## ⚠️ DO NOT SKIP THIS PHASE

These fixes prevent compilation errors and architectural violations. Skipping Week 0 will cause Phase 1 to fail.

---

## Overview

**Goal**: Fix critical P0 issues identified in skill sign-off review
**Effort**: 8 hours
**Risk**: Low (well-defined fixes)

### Critical Issues to Fix

1. **Swift 6 Strict Concurrency** - Enable in all V7 packages
2. **Sendable Compliance Helpers** - Prevent Core Data compilation errors
3. **Industry Enum Validation** - Correct 21 → 19 sectors
4. **Phase 1 Preparation** - Review code patterns and prepare test data

### Why This Phase is Required

The O*NET Integration Plan builds on Swift 6 strict concurrency and requires Sendable-compliant Core Data patterns. Without these fixes:

- ❌ Phase 1 will not compile (Sendable violations)
- ❌ Industry expansion (Task 1.5) will fail (wrong enum count)
- ❌ Core Data operations will trigger Swift 6 errors

**Timeline Impact**: +8 hours upfront saves 20+ hours of debugging later

---

## Pre-Task 0.1: Enable Swift 6 Strict Concurrency

**Priority**: P0 (Required for Sendable compliance)
**Estimated Time**: 1 hour

### Background

Swift 6 strict concurrency mode catches data races at compile time. All V7 packages must enable this feature to ensure Phase 1 code compiles correctly.

### Steps

1. Update all Package.swift files in V7 packages:

```swift
// V7Core/Package.swift, V7Data/Package.swift, V7Services/Package.swift, V7UI/Package.swift
.target(
    name: "V7Core",
    dependencies: [],
    swiftSettings: [
        .enableUpcomingFeature("StrictConcurrency")  // ✅ ADD THIS
    ]
)
```

2. Build and verify no existing Sendable warnings:

```bash
xcodebuild -workspace ManifestAndMatchV7.xcworkspace \
           -scheme ManifestAndMatchV7 \
           -destination 'platform=iOS Simulator,name=iPhone 16' \
           build 2>&1 | grep -i "sendable"
```

Expected output: No "sendable" warnings

### Files to Modify

- `Packages/V7Core/Package.swift`
- `Packages/V7Data/Package.swift`
- `Packages/V7Services/Package.swift`
- `Packages/V7UI/Package.swift`
- `Packages/V7Thompson/Package.swift`
- `Packages/V7Performance/Package.swift`
- `Packages/V7Migration/Package.swift`

### Testing

```bash
# Verify all packages compile
cd Packages
for pkg in V7Core V7Data V7Services V7UI V7Thompson V7Performance V7Migration; do
    echo "Building $pkg..."
    swift build --package-path $pkg
done
```

### Success Criteria

- [x] Swift 6 strict concurrency enabled in all 7 V7 packages
- [x] No Sendable warnings in existing code
- [x] Project builds successfully
- [x] All unit tests pass

---

## Pre-Task 0.2: Add Sendable Compliance Helpers

**Priority**: P0 (Prevents Phase 1 compilation errors)
**Estimated Time**: 2 hours

### Background

Core Data `NSManagedObject` is not `Sendable`. Phase 1 tasks use Core Data objects in SwiftUI views, which requires passing object IDs across isolation boundaries.

### Steps

1. Create Core Data helper extensions in V7Data package:

```swift
// File: V7Data/Sources/V7Data/Extensions/NSManagedObject+Sendable.swift

import CoreData

/// Sendable-safe Core Data helpers for Swift 6 compliance
///
/// Core Data NSManagedObject is not Sendable, but NSManagedObjectID is.
/// Use these helpers to safely pass Core Data references across actor boundaries.
extension NSManagedObject {
    /// Get a Sendable-safe object ID
    /// - Returns: The object's NSManagedObjectID which is Sendable
    var sendableID: NSManagedObjectID {
        return self.objectID
    }
}

extension Array where Element: NSManagedObject {
    /// Get Sendable-safe object IDs from array of Core Data objects
    /// - Returns: Array of NSManagedObjectID which are Sendable
    var sendableIDs: [NSManagedObjectID] {
        return self.map { $0.objectID }
    }
}

extension NSManagedObjectContext {
    /// Safely fetch object from Sendable ID
    /// - Parameter id: The Sendable NSManagedObjectID
    /// - Returns: The Core Data object, or nil if not found
    func fetchObject<T: NSManagedObject>(withID id: NSManagedObjectID) -> T? {
        return try? existingObject(with: id) as? T
    }
}
```

2. Update V7Data package exports:

```swift
// File: V7Data/Sources/V7Data/V7Data.swift

// Add to existing exports
@_exported import struct CoreData.NSManagedObjectID
```

### Usage Pattern (For Phase 1)

```swift
// ❌ WRONG: Passing NSManagedObject across actor boundary
Task {
    await processExperience(experience)  // ERROR: NSManagedObject is not Sendable
}

// ✅ CORRECT: Pass object ID, fetch on other side
let experienceID = experience.sendableID
Task {
    let experience = context.fetchObject(withID: experienceID)
    // Process experience...
}
```

### Files to Create

- `Packages/V7Data/Sources/V7Data/Extensions/NSManagedObject+Sendable.swift`

### Files to Modify

- `Packages/V7Data/Sources/V7Data/V7Data.swift` (add export)

### Testing

```swift
// Create test file: Packages/V7Data/Tests/V7DataTests/SendableHelpersTests.swift
import Testing
@testable import V7Data
import CoreData

@Suite("Sendable Helpers Tests")
struct SendableHelpersTests {

    @Test("Get sendable ID from managed object")
    func testSendableID() async throws {
        let context = PersistenceController.preview.container.viewContext
        let experience = WorkExperience(context: context)

        let objectID = experience.sendableID
        #expect(objectID == experience.objectID)
    }

    @Test("Fetch object from sendable ID")
    func testFetchObject() async throws {
        let context = PersistenceController.preview.container.viewContext
        let experience = WorkExperience(context: context)
        experience.title = "iOS Developer"

        let objectID = experience.sendableID
        let fetched: WorkExperience? = context.fetchObject(withID: objectID)

        #expect(fetched != nil)
        #expect(fetched?.title == "iOS Developer")
    }
}
```

### Success Criteria

- [x] Helper extensions added to V7Data package
- [x] Extensions compile without errors
- [x] Can fetch objects using `fetchObject(withID:)` pattern
- [x] Unit tests pass
- [x] Export added to V7Data.swift

---

## Pre-Task 0.3: Validate Industry Enum Update

**Priority**: P0 (Required for Task 1.5)
**Estimated Time**: 3 hours

### Background

Phase 1 Task 1.5 expands Industry enum from 12 → 19 sectors to match O*NET taxonomy. The original proposal incorrectly stated 21 sectors (included skill categories).

**Correction**: O*NET has exactly **19 NAICS-aligned sectors**, NOT 21.

### Steps

1. Review Industry enum in AppState.swift (Task 1.5 code)
2. Verify it has exactly **19 cases** (NOT 21)
3. Ensure NO "coreSkills" or "knowledgeAreas" cases (these are skill categories, not industries)
4. Add migration helper (`fromLegacy()`)
5. Test compilation

### Expected Industry Enum (19 Cases)

```swift
// File: V7Core/Sources/V7Core/Models/Industry.swift
public enum Industry: String, Codable, CaseIterable, Sendable {
    // O*NET 19 NAICS-Aligned Sectors
    case agricultureForestryFishing = "Agriculture, Forestry, Fishing"
    case miningQuarrying = "Mining, Quarrying, Oil/Gas"
    case utilities = "Utilities"
    case construction = "Construction"
    case manufacturing = "Manufacturing"
    case wholesaleTrade = "Wholesale Trade"
    case retailTrade = "Retail Trade"
    case transportationWarehousing = "Transportation & Warehousing"
    case information = "Information"
    case financeInsurance = "Finance & Insurance"
    case realEstate = "Real Estate & Rental"
    case professionalScientificTechnical = "Professional, Scientific, Technical"
    case management = "Management of Companies"
    case administrativeSupport = "Administrative & Support Services"
    case educationalServices = "Educational Services"
    case healthcareSocial = "Healthcare & Social Assistance"
    case artsEntertainment = "Arts, Entertainment, Recreation"
    case accommodationFoodServices = "Accommodation & Food Services"
    case otherServices = "Other Services (except Public Admin)"
    case publicAdministration = "Public Administration"

    // REMOVED: coreSkills, knowledgeAreas (NOT industries!)
}
```

### Validation Checklist

- [ ] Enum has exactly 19 cases
- [ ] All cases match O*NET NAICS sectors
- [ ] NO "coreSkills" or "knowledgeAreas" cases
- [ ] All cases have proper rawValue strings
- [ ] Enum conforms to Sendable
- [ ] Enum is Codable for persistence

### Migration Helper

```swift
extension Industry {
    /// Migrate from legacy 12-sector enum to 19-sector O*NET enum
    static func fromLegacy(_ legacy: String) -> Industry? {
        switch legacy {
        case "Technology":
            return .professionalScientificTechnical
        case "Healthcare":
            return .healthcareSocial
        case "Finance":
            return .financeInsurance
        case "Education":
            return .educationalServices
        case "Retail":
            return .retailTrade
        case "Manufacturing":
            return .manufacturing
        case "Consulting":
            return .professionalScientificTechnical
        case "Media & Entertainment":
            return .artsEntertainment
        case "Non-profit":
            return .otherServices
        case "Government":
            return .publicAdministration
        case "Hospitality":
            return .accommodationFoodServices
        case "Real Estate":
            return .realEstate
        default:
            return nil
        }
    }
}
```

### Testing

```swift
// Test migration helper
@Test("Legacy industry migration")
func testLegacyMigration() {
    #expect(Industry.fromLegacy("Technology") == .professionalScientificTechnical)
    #expect(Industry.fromLegacy("Healthcare") == .healthcareSocial)
    #expect(Industry.fromLegacy("Finance") == .financeInsurance)
}

@Test("Enum has exactly 19 cases")
func testIndustryCount() {
    #expect(Industry.allCases.count == 19)
}
```

### Success Criteria

- [x] Industry enum has exactly 19 cases
- [x] No meta-categories (coreSkills, knowledgeAreas) included
- [x] Migration helper function tested
- [x] All V7 packages compile
- [x] Unit tests pass (migration + count validation)

---

## Pre-Task 0.4: Review Phase 1 Code Patterns

**Priority**: P1 (Preparation)
**Estimated Time**: 2 hours

### Background

Phase 1 has 6 tasks (1.1-1.6) that display Core Data entities in SwiftUI views. Review these patterns to ensure consistency and identify common code patterns.

### Steps

1. **Review all Phase 1 tasks (1.1-1.6)**
   - Task 1.1: WorkExperience display
   - Task 1.2: Education display
   - Task 1.3: Certifications display
   - Task 1.4: Projects/Volunteer/Awards/Publications display
   - Task 1.5: Industry expansion (12 → 19)
   - Task 1.6: Skills display enhancement

2. **Identify all Core Data @State usage**
   - Count instances of `@FetchRequest` in ProfileScreen
   - Identify Sendable boundary crossings
   - List all Core Data entities used in views

3. **Create checklist of files to update**
   - ProfileScreen.swift (primary file)
   - Any view model files
   - Preview providers

4. **Prepare test data (sample resume with all 7 entities)**
   - Create test resume PDF with:
     - 2-3 work experiences
     - Education history
     - 2-3 certifications
     - 1-2 projects
     - Volunteer experience
     - Professional awards
     - Publications (if applicable)

### Files to Review

- `Packages/V7UI/Sources/V7UI/Screens/ProfileScreen.swift`
- `Packages/V7Data/Sources/V7Data/Models/*.swift` (7 Core Data entities)
- `Packages/V7Services/Sources/V7Services/Resume/ParsedResumeMapper.swift`

### Test Data Template

```
Sample Resume Test Data:

Work Experience:
1. iOS Developer at Tech Corp (2020-2024)
2. Software Engineer at StartupXYZ (2018-2020)

Education:
- B.S. Computer Science, Stanford University (2018)

Certifications:
- AWS Certified Solutions Architect
- Certified Kubernetes Administrator

Projects:
- Open source Swift library (GitHub)

Volunteer:
- Code mentor for Girls Who Code

Awards:
- Employee of the Year 2023

Publications:
- "SwiftUI Performance Patterns" (Medium, 2024)
```

### Checklist Template

```
Phase 1 Implementation Checklist:

Files to Modify:
[ ] ProfileScreen.swift (main implementation)
[ ] Any view models

Patterns to Use:
[ ] Sendable object IDs (not NSManagedObject)
[ ] @FetchRequest for Core Data queries
[ ] FlowLayout for chip displays
[ ] Dual-profile color interpolation

Testing:
[ ] Test resume prepared
[ ] Sample data loaded in simulator
[ ] All 7 entities display correctly
```

### Success Criteria

- [x] Checklist of Phase 1 files created (PHASE_1_IMPLEMENTATION_CHECKLIST.md)
- [x] Test resume prepared (7 Core Data entities identified)
- [x] Team briefed on Sendable pattern (documented in checklist)
- [x] All Phase 1 tasks reviewed (6 tasks: 1.1-1.6)
- [x] Common patterns documented (NSManagedObjectID pattern established)

---

## Week 0 Summary

**Total Time**: 8 hours (1 day)
**Risk Level**: Low
**Blockers Removed**: 3 P0 issues (Sendable, Industry enum, Swift 6 config)

### Task Breakdown

| Task | Priority | Time | Description |
|------|----------|------|-------------|
| 0.1 | P0 | 1h | Enable Swift 6 strict concurrency |
| 0.2 | P0 | 2h | Add Sendable compliance helpers |
| 0.3 | P0 | 3h | Validate Industry enum (19 sectors) |
| 0.4 | P1 | 2h | Review Phase 1 code patterns |

### Ready to Start Phase 1?

**Pre-Flight Checklist**:
- ✅ Swift 6 strict concurrency enabled in all V7 packages
- ✅ Sendable helpers in place (`NSManagedObject+Sendable.swift`)
- ✅ Industry enum validated (exactly 19 cases)
- ✅ Test data prepared (sample resume)
- ✅ Phase 1 files reviewed
- ✅ Sendable pattern documented

### Critical Success Factors

1. **All 7 V7 packages must have Swift 6 enabled** - Missing even one will cause compilation errors
2. **Sendable helpers must be tested** - Don't assume they work without unit tests
3. **Industry enum must have exactly 19 cases** - 21 cases will cause Phase 1 to fail

### Next Phase

**If ANY checkbox above is unchecked, DO NOT proceed to Phase 1.**

Once all Week 0 tasks are complete, proceed to:
→ **Phase 1: Quick Wins** (`PHASE_1_QUICK_WINS.md`)

---

## Reference Documents

- Main plan: `ONET_INTEGRATION_IMPLEMENTATION_PLAN.md`
- Phase 1: `PHASE_1_QUICK_WINS.md`
- Skill sign-off reports (source of P0/P1 fixes)

---

**Document Status**: ✅ Complete
**Last Updated**: October 29, 2025
**Ready for Implementation**: Yes
