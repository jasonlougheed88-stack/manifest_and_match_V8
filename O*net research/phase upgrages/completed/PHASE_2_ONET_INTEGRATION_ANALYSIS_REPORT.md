# Phase 2 O*NET Profile Editor Integration Report
## ManifestAndMatch V8 (iOS 26) - Comprehensive Pre-Implementation Analysis

**Prepared by**: Claude Code with V7 Architecture Guardian, Core Data Specialist, Swift Concurrency Enforcer
**Date**: October 31, 2025
**Report Type**: Pre-Implementation Analysis & Planning
**Status**: Ready for Implementation (Post Phase 1.9 Completion)
**Analysis Duration**: 2 hours with full codebase exploration

---

## Executive Summary

**Goal**: Integrate Phase 2 O*NET Profile Editor into the existing V8 ProfileScreen to enable users to view and edit O*NET-specific fields (Education Level, Work Activities, RIASEC Interests) that drive Thompson Sampling career matching.

**Current Status**: ✅ **EXCELLENT FOUNDATION**
- Thompson Sampling already has full O*NET integration (`ThompsonSampling+ONet.swift`)
- O*NET data models fully implemented (`ONetDataModels.swift` with RIASEC, work activities)
- O*NET data files present (`onet_work_activities.json` in V7Core/Resources)
- Core Data schema has Education entity with level tracking
- ProfileScreen exists with MV pattern and state management

**Key Finding**: 🎯 **The backend is ready** - we only need to build the UI layer. Thompson scoring, data models, and persistence are already in place.

**Estimated Effort**: 60 hours (Phase 2 document: 76 hours; my analysis: 60 hours realistic with +6h for missing persistence)

**Risk Level**: 🟢 **LOW** - Well-defined task with solid foundation

**Confidence**: 🟢 **HIGH** - Recommend proceeding after Phase 1.9 completion

---

## Table of Contents

1. [Current State Analysis](#1-current-state-analysis)
2. [Integration Requirements](#2-integration-requirements)
3. [Architecture & Guardian Skills Compliance](#3-architecture--guardian-skills-compliance)
4. [Implementation Roadmap](#4-implementation-roadmap)
5. [Risks, Blockers & Mitigations](#5-risks-blockers--mitigations)
6. [Performance Considerations](#6-performance-considerations)
7. [Testing Strategy](#7-testing-strategy)
8. [Timeline & Resource Estimates](#8-timeline--resource-estimates)
9. [Recommended Implementation Order](#9-recommended-implementation-order)
10. [Final Recommendations](#10-final-recommendations)
11. [Next Steps](#11-next-steps)

---

## 1. Current State Analysis

### 1.1 What EXISTS and WORKS ✅

#### A. Thompson Scoring Integration (V7Thompson Package)
**File**: `Packages/V7Thompson/Sources/V7Thompson/ThompsonSampling+ONet.swift`

**Functionality**: Already implemented scoring with 5 dimensions:
```swift
public func computeONetScore(
    for job: Job,
    profile: ProfessionalProfile,
    onetCode: String
) async throws -> Double {
    // Weights exactly match Phase 2 document:
    // - Skills: 30%
    // - Education: 15%  ✅
    // - Experience: 15%
    // - Work Activities: 25%  ✅
    // - RIASEC Interests: 15%  ✅
}
```

**Implementation Details**:
- `matchEducation()` - lines 128-131 - Uses educationLevel: Int?
- `matchWorkActivities()` - lines 136-139 - Uses workActivities: [String: Double]?
- `matchInterests()` - lines 140-143 - Uses interests: RIASECProfile?

**Status**: ✅ Fully implemented with correct weights
**Performance**: Target <8ms, already optimized with async parallel execution
**Concurrency**: Swift 6 compliant with actor patterns

#### B. O*NET Data Models (V7Core Package)
**File**: `Packages/V7Core/Sources/V7Core/ONetDataModels.swift`

**Structures Available**:

```swift
// RIASEC Profile - Line 265
public struct RIASECProfile: Codable, Sendable, Hashable {
    public let realistic: Double  // 0.0-7.0
    public let investigative: Double
    public let artistic: Double
    public let social: Double
    public let enterprising: Double
    public let conventional: Double

    // Includes cosine similarity method for matching
    public func similarity(to other: RIASECProfile) -> Double
}

// Work Activities - Line 115
public struct ONetWorkActivities: Codable, Sendable {
    public let version: String
    public let source: String
    public let totalOccupations: Int
    public let totalActivities: Int
    public let occupations: [OccupationWorkActivities]
    public let activityMetadata: [ActivityMetadata]
}

// Education Requirements - Line 65
public struct EducationRequirements: Codable, Sendable, Hashable {
    public let requiredLevel: Int  // 1-12 scale
    public let percentFrequency: Double
    public let confidence: ConfidenceInterval
    public let alternatives: [AlternativeEducation]
}
```

**Status**: ✅ Complete, Sendable-compliant, ready to use
**Documentation**: Comprehensive inline documentation with examples
**Performance**: O(1) lookups via dictionary optimization

#### C. O*NET Data Files
**Location**: `Packages/V7Core/Sources/V7Core/Resources/onet_work_activities.json`

**Verified Structure**:
```json
{
  "version": "30.0",
  "source": "O*NET Database",
  "totalOccupations": 894,
  "totalActivities": 41,
  "activityMetadata": [
    {
      "activityId": "4.A.1.a.1",
      "activityName": "Getting Information",
      "category": "Information Input",
      "averageImportance": 4.192865497076024,
      "occurrenceCount": 171,
      "transferabilityScore": 0.95
    },
    // ... 40 more activities
  ],
  "occupations": [
    // 894 occupation profiles with activity ratings
  ]
}
```

**Status**: ✅ 41 activities across 4 categories, matches Phase 2 spec
**Size**: ~1.9MB (acceptable for bundle inclusion)
**Categories**:
1. Information Input (5 activities)
2. Mental Processes (10 activities)
3. Work Output (9 activities)
4. Interacting with Others (17 activities)

#### D. Core Data Schema (V7Data Package)
**File**: `Packages/V7Data/Sources/V7Data/V7DataModel.xcdatamodeld/V7DataModel.xcdatamodel/contents`

**Education Entity** (Lines 73-90):
```xml
<entity name="Education" representedClassName="Education" syncable="YES">
    <attribute name="id" attributeType="UUID" usesScalarValueType="NO"/>
    <attribute name="institution" attributeType="String"/>
    <attribute name="degree" optional="YES" attributeType="String"/>
    <attribute name="fieldOfStudy" optional="YES" attributeType="String"/>
    <attribute name="startDate" optional="YES" attributeType="Date"/>
    <attribute name="endDate" optional="YES" attributeType="Date"/>
    <attribute name="gpa" attributeType="Double" defaultValueString="0.0"/>
    <attribute name="educationLevelValue" attributeType="Integer 16" defaultValueString="0"/>
    <!-- Stores 1-5 scale: highSchool=1, associate=2, bachelor=3, master=4, doctorate=5 -->
    <relationship name="profile" maxCount="1" deletionRule="Nullify" destinationEntity="UserProfile"/>
</entity>
```

**Education+CoreData.swift** (Lines 264-285):
```swift
public enum EducationLevel: Int, Codable, Comparable, Sendable {
    case highSchool = 1
    case associate = 2
    case bachelor = 3
    case master = 4
    case doctorate = 5

    public var displayName: String {
        switch self {
        case .highSchool: return "High School"
        case .associate: return "Associate Degree"
        case .bachelor: return "Bachelor's Degree"
        case .master: return "Master's Degree"
        case .doctorate: return "Doctorate"
        }
    }
}
```

**UserProfile Entity** (Lines 4-51):
```xml
<entity name="UserProfile" representedClassName="UserProfile" syncable="YES">
    <!-- Identity -->
    <attribute name="id" attributeType="UUID" usesScalarValueType="NO"/>
    <attribute name="createdDate" attributeType="Date" usesScalarValueType="NO"/>
    <attribute name="lastModified" attributeType="Date" usesScalarValueType="NO"/>

    <!-- Contact Information -->
    <attribute name="name" attributeType="String"/>
    <attribute name="email" attributeType="String"/>
    <attribute name="phone" optional="YES" attributeType="String"/>
    <attribute name="location" optional="YES" attributeType="String"/>

    <!-- Skills -->
    <attribute name="skills" attributeType="Transformable" valueTransformerName="NSSecureUnarchiveFromData"/>

    <!-- Dual-Profile System -->
    <attribute name="amberTealPosition" attributeType="Double" defaultValueString="0.5"/>

    <!-- Relationships (Cascade Delete) -->
    <relationship name="workExperience" toMany="YES" deletionRule="Cascade" destinationEntity="WorkExperience"/>
    <relationship name="education" toMany="YES" deletionRule="Cascade" destinationEntity="Education"/>
    <relationship name="certifications" toMany="YES" deletionRule="Cascade" destinationEntity="Certification"/>

    <!-- NO O*NET-specific fields yet ❌ -->
</entity>
```

**Status**: ⚠️ **MISMATCH IDENTIFIED**
- Education uses 1-5 scale (highSchool → doctorate)
- O*NET uses 1-12 scale (Phase 2 spec)
- UserProfile has no fields for workActivities or RIASEC profile
- **Action Required**: Add mapping/conversion logic OR extend schema

#### E. ProfileScreen (V7UI Package)
**File**: `Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`

**Current State** (Lines 1-150):
```swift
@MainActor
public struct ProfileScreen: View {
    // MARK: - State Management (MV Pattern - ✅ Correct)
    @State private var viewState: ViewState = .loaded
    @State private var isEditing: Bool = false

    // Profile Fields (Editable)
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var skills: [String] = []
    @State private var profileBlend: Double = 0.5  // ✅ Amber→Teal dual-profile

    // Core Data Entity Management (✅ Swift 6 Sendable Pattern)
    @State private var selectedWorkExperienceID: NSManagedObjectID?
    @State private var selectedEducationID: NSManagedObjectID?
    @State private var selectedCertificationID: NSManagedObjectID?

    // NO O*NET UI fields yet ❌
    // Missing: @State private var onetEducationLevel: Int
    // Missing: @State private var onetWorkActivities: [String: Double]
    // Missing: @State private var onetRIASECProfile: RIASECProfile

    // Environment
    @Environment(AppState.self) private var appState
    @Environment(\.managedObjectContext) private var context
}
```

**Status**: ⚠️ UI layer needs Phase 2 components
- Basic profile editing exists
- MV pattern correctly implemented (no ViewModels)
- Swift 6 Sendable compliance with NSManagedObjectID pattern
- Missing all O*NET UI sections

---

### 1.2 What NEEDS to be BUILT 🔨

#### Task 2.1: O*NET Education Level Picker (8 hours)
**Missing Components**:

1. **ONetEducationLevelPicker.swift** - New component (Phase 2 spec lines 70-280)
   - Visual slider with 1-12 scale
   - Color gradient (amber → teal)
   - Quick select buttons (High School, Associate, Bachelor's, Master's, Doctoral)
   - Info box explaining impact on Thompson scoring

2. **Education Level section in ProfileScreen**
   - Integration point after existing Education section
   - State binding to Core Data
   - onChange handler to save to persistence

3. **Mapping between 1-5 (Core Data) and 1-12 (O*NET) scales**
   - Computed property in Education+CoreData.swift
   - Conversion logic for Thompson scoring

**Phase 2 Spec Reference**: Lines 36-365

#### Task 2.2: Work Activities Selector (12 hours)
**Missing Components**:

1. **ONetWorkActivitiesSelector.swift** - New component (Phase 2 lines 490-763)
   - 41 work activities grouped by 4 categories
   - Collapsible category sections
   - Checkbox selection with importance slider (1-7 scale)
   - Selected count display
   - Info box highlighting 25% Thompson weight

2. **ONetWorkActivity model** in V7Core
   - Struct definition with Sendable compliance
   - Category enum (Information Input, Mental Processes, etc.)
   - Codable for JSON deserialization

3. **ONetWorkActivitiesDatabase actor** for async loading
   - Actor-isolated for Swift 6 compliance
   - Bundle resource loading (onet_work_activities.json)
   - Cached instance pattern (load once, reuse)
   - Category filtering methods

4. **Work Activities section in ProfileScreen**
   - State: `@State private var workActivitiesPreferences: [String: Double] = [:]`
   - Integration after Education Level section
   - onChange handler to save to Core Data

**Phase 2 Spec Reference**: Lines 368-830

#### Task 2.3: RIASEC Interest Profiler (10 hours)
**Missing Components**:

1. **RIASECInterestProfiler.swift** - New component (Phase 2 lines 899-1319)
   - Manual sliders for 6 dimensions (Realistic, Investigative, Artistic, Social, Enterprising, Conventional)
   - Collapsible dimension sections with descriptions
   - Quick quiz button (optional 2-minute assessment)
   - Info box explaining Holland Codes

2. **RIASECRadarChart** - Radar visualization component
   - Hexagon background grid (1-7 scale layers)
   - Profile data polygon overlay
   - Dimension labels at vertices
   - Accessibility representation (VoiceOver alternative)

3. **RIASECQuizView** - Optional quick assessment (can defer to Phase 3)
   - 12-question quiz (2 per dimension)
   - Auto-populate RIASEC profile from answers

4. **RIASEC section in ProfileScreen**
   - State: `@State private var riasecProfile: RIASECProfile`
   - Integration after Work Activities section
   - onChange handler to save to Core Data

**Phase 2 Spec Reference**: Lines 833-1333

---

## 2. Integration Requirements

### 2.1 Package Dependency Graph

```
Current V8 Package Structure:
┌─────────────────────────────────────────────────────────────┐
│  ManifestAndMatchV7Feature (App Layer)                      │
│  - ProfileScreen.swift (MODIFY - add 3 new sections)        │
│  - Onboarding flows (Phase 1.9 - in progress)               │
└──────────────┬──────────────────────────────────────────────┘
               │
        ┌──────┴───────┬──────────────────┬──────────────────┐
        │              │                   │                   │
   ┌────▼────┐    ┌───▼──────┐       ┌───▼──────┐      ┌────▼─────┐
   │ V7UI    │    │ V7Data   │       │ V7Thompson│      │ V7Services│
   │ (ADD    │    │ (EXTEND  │       │ (EXISTS   │      │ (N/A)     │
   │ 3 NEW   │    │  SCHEMA) │       │  ✅)      │      │           │
   │ COMPS)  │    │          │       │           │      └───────────┘
   └────┬────┘    └───┬──────┘       └───┬──────┘
        │             │                   │
        └─────────────┴───────────────────┘
                      │
                 ┌────▼────┐
                 │ V7Core  │
                 │ (ADD    │
                 │ MODELS) │
                 │ - ONetWorkActivity.swift (NEW)            │
                 │ - ONetWorkActivitiesDatabase.swift (NEW)  │
                 │ - RIASECProfile (EXISTS ✅)               │
                 └─────────┘
```

**Safe Dependency Pattern** (V7 Architecture Guardian):
- ✅ V7UI → V7Core (allowed for O*NET models)
- ✅ V7UI → V7Data (allowed for Core Data entities)
- ✅ ManifestAndMatchV7Feature → All packages (app layer)
- ✅ V7Thompson → V7Core (already exists for O*NET models)
- ❌ V7Core → Any other package (FORBIDDEN - foundation layer must have zero dependencies)

**Verified**: No circular dependencies will be introduced

### 2.2 Core Data Schema Changes

**Current Issue**: UserProfile entity has no O*NET-specific fields for persistence.

**Option A: Minimal Impact (RECOMMENDED)**
Add O*NET fields to UserProfile entity:

```xml
<!-- File: V7DataModel.xcdatamodel/contents -->
<!-- Add to UserProfile entity after line 36 (amberTealPosition) -->

<!-- O*NET Profile Fields (Phase 2) -->
<attribute name="onetEducationLevel" optional="YES" attributeType="Integer 16" defaultValueString="0"/>
<attribute name="onetWorkActivities" optional="YES" attributeType="Transformable" valueTransformerName="NSSecureUnarchiveFromData"/>
<attribute name="onetRIASECRealistic" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECInvestigative" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECArtistic" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECSocial" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECEnterprising" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECConventional" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
```

**Rationale**:
- Store RIASEC as 6 separate doubles (simpler than Transformable, faster queries)
- `onetEducationLevel` uses 1-12 scale (matches O*NET directly)
- `onetWorkActivities` as Transformable (Dictionary requires custom transformer)
- All optional to maintain backward compatibility

**Migration Impact**: Lightweight migration (adding optional fields) - low risk

**Option B: Create separate ONetProfile entity (NOT RECOMMENDED)**
```xml
<entity name="ONetProfile">
    <attribute name="educationLevel" attributeType="Integer 16"/>
    <attribute name="workActivities" attributeType="Transformable"/>
    <attribute name="riasecProfile" attributeType="Transformable"/>
    <relationship name="userProfile" maxCount="1" destinationEntity="UserProfile"/>
</entity>
```

**Cons**:
- Requires additional entity
- More complex fetch logic (JOIN required)
- Higher cognitive overhead for developers

**Recommendation**: **Use Option A** (extend UserProfile entity)

### 2.3 Education Level Scale Mapping

**Problem**: Core Data Education entity stores 1-5 scale, but O*NET uses 1-12 scale.

**Solution**: Add computed property to Education+CoreData.swift:

```swift
// File: Packages/V7Data/Sources/V7Data/Entities/Education+CoreData.swift
// Add after line 101 (isCurrent property)

extension Education {
    /// Maps internal 1-5 scale to O*NET 1-12 scale for Thompson scoring
    ///
    /// **Mapping**:
    /// - 1 (High School) → 4 (O*NET: High school diploma)
    /// - 2 (Associate) → 7 (O*NET: Associate's degree)
    /// - 3 (Bachelor) → 8 (O*NET: Bachelor's degree)
    /// - 4 (Master) → 10 (O*NET: Master's degree)
    /// - 5 (Doctorate) → 12 (O*NET: Doctoral/professional degree)
    ///
    /// **Rationale**: Preserves existing 1-5 storage while providing O*NET-compatible values
    /// for Thompson Sampling matchEducation() function.
    ///
    /// - Returns: O*NET education level (1-12 scale), or 0 if not set
    public var onetEducationLevel: Int {
        switch educationLevelValue {
        case 1: return 4   // High School → O*NET Level 4
        case 2: return 7   // Associate → O*NET Level 7
        case 3: return 8   // Bachelor → O*NET Level 8
        case 4: return 10  // Master → O*NET Level 10
        case 5: return 12  // Doctorate → O*NET Level 12
        default: return 0
        }
    }

    /// Reverse mapping: O*NET 1-12 scale to internal 1-5 scale
    ///
    /// **Mapping**:
    /// - 1-3 → 1 (High School)
    /// - 4-6 → 1 (High School)
    /// - 7 → 2 (Associate)
    /// - 8-9 → 3 (Bachelor)
    /// - 10-11 → 4 (Master)
    /// - 12 → 5 (Doctorate)
    ///
    /// - Parameter onetLevel: O*NET education level (1-12)
    /// - Returns: Internal education level (1-5)
    public static func internalLevel(from onetLevel: Int) -> Int16 {
        switch onetLevel {
        case 1...6: return 1   // High School
        case 7: return 2       // Associate
        case 8...9: return 3   // Bachelor
        case 10...11: return 4 // Master
        case 12: return 5      // Doctorate
        default: return 0
        }
    }
}
```

**Benefit**: No schema migration required, just add computed properties.

### 2.4 Thompson ProfessionalProfile Storage Bridge

**Current Issue**: Thompson's `ProfessionalProfile` is a struct (not persisted), but needs to read from Core Data.

**Solution**: Add computed property to UserProfile+CoreData.swift:

```swift
// File: Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift
// Add new extension

import V7Thompson

extension UserProfile {
    /// Converts Core Data UserProfile to Thompson ProfessionalProfile
    ///
    /// **Data Flow**: Core Data → Thompson Scoring
    ///
    /// Maps O*NET fields from Core Data to Thompson's expected struct format.
    /// Used by Thompson Sampling engine for job scoring.
    ///
    /// - Returns: ProfessionalProfile struct for Thompson scoring
    public func toThompsonProfile() -> ProfessionalProfile {
        // Decode work activities from Transformable
        let workActivitiesDict: [String: Double]? = {
            guard let data = onetWorkActivities as? Data else { return nil }
            return try? JSONDecoder().decode([String: Double].self, from: data)
        }()

        // Construct RIASEC profile from 6 separate doubles
        let riasecProfile: RIASECProfile? = {
            // Only create if at least one value is non-zero
            let hasData = onetRIASECRealistic > 0 || onetRIASECInvestigative > 0 ||
                         onetRIASECArtistic > 0 || onetRIASECSocial > 0 ||
                         onetRIASECEnterprising > 0 || onetRIASECConventional > 0

            guard hasData else { return nil }

            return RIASECProfile(
                realistic: onetRIASECRealistic,
                investigative: onetRIASECInvestigative,
                artistic: onetRIASECArtistic,
                social: onetRIASECSocial,
                enterprising: onetRIASECEnterprising,
                conventional: onetRIASECConventional
            )
        }()

        // Decode skills from Transformable (already exists in schema)
        let skillsArray = skills as? [String] ?? []

        return ProfessionalProfile(
            skills: skillsArray,
            educationLevel: onetEducationLevel > 0 ? Int(onetEducationLevel) : nil,
            yearsOfExperience: nil,  // TODO: Calculate from workExperience relationship
            workActivities: workActivitiesDict,
            interests: riasecProfile,
            abilities: nil  // Phase 3 feature
        )
    }

    /// Updates Core Data fields from Thompson ProfessionalProfile
    ///
    /// **Data Flow**: Thompson → Core Data (for persistence)
    ///
    /// Used when ProfileScreen UI updates O*NET fields.
    ///
    /// - Parameter profile: Thompson ProfessionalProfile to save
    public func updateFromThompsonProfile(_ profile: ProfessionalProfile) {
        // Update education level
        if let educationLevel = profile.educationLevel {
            onetEducationLevel = Int16(educationLevel)
        }

        // Update work activities
        if let workActivities = profile.workActivities {
            if let data = try? JSONEncoder().encode(workActivities) {
                onetWorkActivities = data as NSObject
            }
        }

        // Update RIASEC profile
        if let interests = profile.interests {
            onetRIASECRealistic = interests.realistic
            onetRIASECInvestigative = interests.investigative
            onetRIASECArtistic = interests.artistic
            onetRIASECSocial = interests.social
            onetRIASECEnterprising = interests.enterprising
            onetRIASECConventional = interests.conventional
        }
    }
}
```

**Benefit**: Clean separation between Core Data (persistence) and Thompson (computation).

---

## 3. Architecture & Guardian Skills Compliance

### 3.1 V7 Architecture Guardian Validation ✅

**Sacred Constraints Check**:

| Constraint | Status | Verification |
|------------|--------|--------------|
| Tab Order (Sacred 4-Tab UI) | ✅ PASS | No changes to Discover/History/Profile/Analytics tabs |
| Thompson <10ms Performance | ✅ PASS | UI changes only, Thompson scoring unchanged |
| Package Dependencies | ✅ PASS | V7UI → V7Core (allowed), no circular deps |
| Dual-Profile Colors | ✅ PASS | Amber 0.083, Teal 0.528 preserved in spec (line 32-36) |
| MV Pattern | ✅ PASS | Phase 2 components use @State, no ViewModels |
| Naming Conventions | ✅ PASS | PascalCase types, camelCase functions |
| V7Core Zero Dependencies | ✅ PASS | No new imports in V7Core |

**Package Placement Validation**:
- ✅ New UI components → `Packages/V7UI/Sources/V7UI/Components/`
  - ONetEducationLevelPicker.swift
  - ONetWorkActivitiesSelector.swift
  - RIASECInterestProfiler.swift
  - RIASECRadarChart.swift (sub-component)

- ✅ O*NET models → `Packages/V7Core/Sources/V7Core/Models/`
  - ONetWorkActivity.swift (NEW)
  - ONetWorkActivitiesDatabase.swift (NEW - actor)
  - ONetDataModels.swift (EXISTS - contains RIASECProfile)

- ✅ ProfileScreen modifications → `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Screens/`
  - ProfileScreen.swift (MODIFY)

**State Management Pattern Validation**:
```swift
// ✅ CORRECT: MV Pattern from Phase 2 spec (line 76)
@MainActor
public struct ONetEducationLevelPicker: View {
    @Binding var selectedLevel: Int  // ✅ Binding to parent state
    let profileBlend: Double

    // NO ViewModel ✅
    // Uses @State for local UI state only
}
```

### 3.2 Swift Concurrency Enforcer Validation ✅

**Concurrency Compliance Check**:

| Requirement | Status | Evidence |
|-------------|--------|----------|
| @MainActor on all views | ✅ PASS | Phase 2 spec lines 76, 497, 904 |
| Actor for async loading | ✅ PASS | ONetWorkActivitiesDatabase is actor (line 432) |
| Sendable conformance | ✅ PASS | All O*NET models in ONetDataModels.swift are Sendable |
| Async file loading | ✅ PASS | Database actor uses async/await (line 440-446) |
| No main thread blocking | ✅ PASS | JSON loading happens in actor isolation |

**Example from Phase 2 spec (lines 432-480)**:
```swift
// ✅ CORRECT: Actor-isolated database
actor ONetWorkActivitiesDatabase {
    public static let shared = ONetWorkActivitiesDatabase()

    private var activities: [ONetWorkActivity]?
    private var loadTask: Task<[ONetWorkActivity], Error>?

    private init() {
        // ✅ Start loading immediately in background
        loadTask = Task {
            try await loadActivities()
        }
    }

    private func loadActivities() async throws -> [ONetWorkActivity] {
        // ✅ Return cached if available
        if let cached = activities {
            return cached
        }

        // ✅ Async file loading (does NOT block main thread)
        guard let url = Bundle.main.url(forResource: "onet_work_activities", withExtension: "json") else {
            throw ONetError.fileNotFound
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode([ONetWorkActivity].self, from: data)

        activities = decoded
        print("✅ Loaded \(decoded.count) O*NET work activities (async)")

        return decoded
    }

    // ✅ Public async API
    public func getAllActivities() async throws -> [ONetWorkActivity] {
        if let loadTask = loadTask {
            return try await loadTask.value
        } else if let cached = activities {
            return cached
        } else {
            return try await loadActivities()
        }
    }
}
```

**Performance Note**: Actor pattern ensures:
- Main thread never blocks during 1.9MB JSON load
- Singleton pattern prevents duplicate loads
- Task-based caching reuses initial load across multiple callers

### 3.3 Core Data Specialist Validation ⚠️

**Data Persistence Concerns**:

| Issue | Severity | Status | Notes |
|-------|----------|--------|-------|
| Missing Core Data save logic | 🔴 CRITICAL | ⚠️ MUST IMPLEMENT | Phase 2 spec shows UI but no persistence |
| Transformable attributes | 🟡 MEDIUM | ⚠️ NEEDS ATTENTION | workActivities dictionary requires custom handling |
| Fetch optimization | 🟢 LOW | ✅ OK | Simple profile fetches, no N+1 queries |
| Schema migration | 🟢 LOW | ✅ LIGHTWEIGHT | Adding optional fields only |

**Critical Gap Analysis**:

Phase 2 spec includes stub helper functions (lines 342-353):
```swift
@MainActor
private func updateThompsonProfile(educationLevel: Int) async {
    // Update Thompson ProfessionalProfile
    // This ensures Thompson scoring uses the updated education level

    // Implementation depends on how ProfessionalProfile is stored
    // Example:
    // appState.currentUser?.thompsonProfile.educationLevel = educationLevel

    // Log for verification
    print("✅ Updated Thompson education level to \(educationLevel)")
}
```

**Problem**: This is just a print statement, not actual Core Data persistence.

**Required Implementation** (add to ProfileScreen.swift):
```swift
@MainActor
private func saveONetEducationLevel(_ level: Int) async {
    guard let userProfile = fetchCurrentUserProfile() else {
        logger.error("❌ No user profile found for O*NET education level save")
        return
    }

    // Update Core Data entity
    userProfile.onetEducationLevel = Int16(level)
    userProfile.lastModified = Date()

    do {
        try context.save()
        logger.info("✅ Saved O*NET education level: \(level)")

        // Optionally notify Thompson engine to refresh
        NotificationCenter.default.post(name: .profileDidUpdate, object: nil)
    } catch {
        logger.error("❌ Failed to save O*NET education level: \(error)")
        // TODO: Show user-facing error alert
    }
}

@MainActor
private func saveONetWorkActivities(_ activities: [String: Double]) async {
    guard let userProfile = fetchCurrentUserProfile() else { return }

    // Encode dictionary to Data for Transformable attribute
    if let data = try? JSONEncoder().encode(activities) {
        userProfile.onetWorkActivities = data as NSObject
        userProfile.lastModified = Date()

        do {
            try context.save()
            logger.info("✅ Saved \(activities.count) O*NET work activities")
        } catch {
            logger.error("❌ Failed to save work activities: \(error)")
        }
    }
}

@MainActor
private func saveONetRIASECProfile(_ profile: RIASECProfile) async {
    guard let userProfile = fetchCurrentUserProfile() else { return }

    // Store as 6 separate doubles (simpler than Transformable)
    userProfile.onetRIASECRealistic = profile.realistic
    userProfile.onetRIASECInvestigative = profile.investigative
    userProfile.onetRIASECArtistic = profile.artistic
    userProfile.onetRIASECSocial = profile.social
    userProfile.onetRIASECEnterprising = profile.enterprising
    userProfile.onetRIASECConventional = profile.conventional
    userProfile.lastModified = Date()

    do {
        try context.save()
        logger.info("✅ Saved O*NET RIASEC profile")
    } catch {
        logger.error("❌ Failed to save RIASEC profile: \(error)")
    }
}

private func fetchCurrentUserProfile() -> UserProfile? {
    let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
    request.fetchLimit = 1

    do {
        return try context.fetch(request).first
    } catch {
        logger.error("❌ Failed to fetch user profile: \(error)")
        return nil
    }
}
```

**Action Required**: Add 6 hours to implementation timeline for Core Data persistence layer.

---

## 4. Implementation Roadmap

### Phase 2 Task Breakdown with Dependencies

```
WEEK 0: Foundation (Pre-Phase 2) - 2 hours
├─ [DONE] Phase 1.9 Onboarding completion (work experience/certifications save)
└─ [NEEDED] Add O*NET fields to UserProfile Core Data schema
    ├─ Modify V7DataModel.xcdatamodel/contents
    ├─ Add onetEducationLevel attribute
    ├─ Add onetWorkActivities attribute (Transformable)
    ├─ Add 6 onetRIASEC* attributes (separate doubles)
    └─ Test lightweight migration

WEEK 1: Core Components - 30 hours
├─ Task 2.1: Education Level Picker (8h)
│   ├─ [2h] Create ONetEducationLevelPicker component
│   │   ├─ Slider with 1-12 scale
│   │   ├─ Visual bars indicator
│   │   ├─ Quick select buttons
│   │   └─ Info box
│   ├─ [2h] Add education level mapping (1-5 → 1-12)
│   │   └─ Computed property in Education+CoreData.swift
│   ├─ [2h] Integrate into ProfileScreen
│   │   ├─ Add state variable
│   │   ├─ Add section after Education
│   │   └─ Wire onChange handler
│   └─ [2h] Add Core Data persistence
│       ├─ saveONetEducationLevel() function
│       ├─ fetchCurrentUserProfile() helper
│       └─ Error handling
│
├─ Task 2.2: Work Activities Selector (14h) [+2h vs spec]
│   ├─ [2h] Create ONetWorkActivity model
│   │   ├─ Struct definition in V7Core
│   │   ├─ ActivityCategory enum (4 categories)
│   │   └─ Codable conformance
│   ├─ [2h] Create ONetWorkActivitiesDatabase actor
│   │   ├─ Singleton pattern
│   │   ├─ Async bundle loading
│   │   ├─ JSON parsing (onet_work_activities.json)
│   │   └─ Category filtering methods
│   ├─ [6h] Build ONetWorkActivitiesSelector UI
│   │   ├─ Category sections (collapsible)
│   │   ├─ Activity rows (checkbox + importance slider)
│   │   ├─ Selected count display
│   │   └─ Info box (25% weight)
│   ├─ [2h] Integrate into ProfileScreen
│   │   ├─ Add state: workActivitiesPreferences
│   │   ├─ Add section after Education Level
│   │   └─ Wire onChange handler
│   └─ [2h] Add Core Data persistence [NEW]
│       ├─ saveONetWorkActivities() function
│       ├─ JSON encoding for Transformable
│       └─ Error handling
│
└─ Task 2.3: RIASEC Profiler (12h) [+2h vs spec]
    ├─ [0.5h] Verify RIASECProfile model (exists in V7Core)
    ├─ [3h] Create RIASECRadarChart component
    │   ├─ Hexagon background grid
    │   ├─ Profile data polygon
    │   ├─ Dimension labels
    │   └─ Accessibility representation (VoiceOver)
    ├─ [5h] Build RIASECInterestProfiler UI
    │   ├─ Radar chart display
    │   ├─ 6 dimension sliders (collapsible)
    │   ├─ Quick quiz button (optional - can defer)
    │   └─ Info box (Holland Codes explanation)
    ├─ [1.5h] Integrate into ProfileScreen
    │   ├─ Add state: riasecProfile
    │   ├─ Add section after Work Activities
    │   └─ Wire onChange handler
    └─ [2h] Add Core Data persistence [NEW]
        ├─ saveONetRIASECProfile() function
        ├─ Store as 6 separate doubles
        └─ Error handling

WEEK 2: Testing & Polish - 14 hours
├─ [4h] Performance validation
│   ├─ Thompson scoring still <10ms
│   ├─ JSON load time <100ms
│   └─ ProfileScreen render 60 FPS
├─ [4h] Accessibility testing
│   ├─ VoiceOver announces all fields
│   ├─ Dynamic Type support (Small → XXXL)
│   ├─ Radar chart text alternative
│   └─ Keyboard navigation
├─ [4h] Integration testing
│   ├─ ProfileScreen → Core Data → Thompson
│   ├─ Data persistence across app restarts
│   └─ Education mapping (1-5 ↔ 1-12)
└─ [2h] Device testing
    ├─ iPhone 15 Pro (primary)
    ├─ iPad Air (adaptive layout)
    └─ Various iOS 26 simulators

TOTAL: 60 hours (vs Phase 2 spec: 76 hours)
```

**Critical Path**:
Task 2.1 → Task 2.2 → Task 2.3 → Testing (sequential dependencies on ProfileScreen state)

**Parallel Work Opportunities**:
- Task 2.2 & 2.3 models can be built while Task 2.1 UI is being implemented
- Testing can start incrementally as each task completes

### Detailed Implementation Steps

#### Pre-Implementation: Core Data Schema Extension (2 hours)

**Objective**: Add O*NET profile fields to UserProfile entity without breaking existing data.

**File**: `Packages/V7Data/Sources/V7Data/V7DataModel.xcdatamodeld/V7DataModel.xcdatamodel/contents`

**Changes** (add after line 36 - amberTealPosition attribute):

```xml
<!-- O*NET Profile Fields (Phase 2 - October 31, 2025) -->
<!-- Education Level (1-12 O*NET scale) -->
<attribute name="onetEducationLevel" optional="YES" attributeType="Integer 16" defaultValueString="0" usesScalarValueType="YES"/>

<!-- Work Activities (41 activities with importance scores 0.0-7.0) -->
<!-- Stored as JSON-encoded dictionary [String: Double] -->
<attribute name="onetWorkActivities" optional="YES" attributeType="Transformable" valueTransformerName="NSSecureUnarchiveFromData"/>

<!-- RIASEC Profile (6 dimensions, 0.0-7.0 scale) -->
<!-- Stored as separate doubles for query performance -->
<attribute name="onetRIASECRealistic" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECInvestigative" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECArtistic" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECSocial" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECEnterprising" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
<attribute name="onetRIASECConventional" optional="YES" attributeType="Double" defaultValueString="0.0" usesScalarValueType="YES"/>
```

**Testing**:
1. Clean build (delete DerivedData)
2. Run app on simulator
3. Verify lightweight migration succeeds (Core Data logs)
4. Test existing profile data loads correctly
5. Test new fields default to 0/nil as expected

**Success Criteria**:
- [ ] Schema compiles without errors
- [ ] Existing user profiles load without crashes
- [ ] New attributes are accessible in code
- [ ] No heavyweight migration required

#### Task 2.1: Education Level Picker (8 hours)

**Step 1: Create ONetEducationLevelPicker Component** (2 hours)

**File**: `Packages/V7UI/Sources/V7UI/Components/ONetEducationLevelPicker.swift`

**Implementation** (based on Phase 2 spec lines 70-280):

```swift
import SwiftUI

// MARK: - O*NET Education Level Picker
@MainActor
public struct ONetEducationLevelPicker: View {
    @Binding var selectedLevel: Int  // 1-12 O*NET scale
    let profileBlend: Double

    public init(selectedLevel: Binding<Int>, profileBlend: Double = 0.5) {
        self._selectedLevel = selectedLevel
        self.profileBlend = profileBlend
    }

    private let educationLevels: [(level: Int, label: String, description: String)] = [
        (1, "Less than HS", "No high school diploma"),
        (2, "High School", "High school diploma or GED"),
        (3, "HS Graduate", "High school graduate"),
        (4, "Some College", "Some college coursework"),
        (5, "Post-HS Training", "Vocational or technical training"),
        (6, "Associate's", "2-year college degree"),
        (7, "Advanced Associate", "Associate's with additional certification"),
        (8, "Bachelor's", "4-year college degree"),
        (9, "Post-Bachelor Cert", "Graduate certificate"),
        (10, "Master's", "Master's degree"),
        (11, "Advanced Master's", "Post-master's specialist"),
        (12, "Doctoral/Professional", "PhD, MD, JD, or equivalent")
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Education Level (O*NET Scale)")
                    .font(.headline)

                Text("This helps match you with jobs requiring similar education. Used in Thompson Sampling scoring (15% weight).")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Visual Slider with Labels
            VStack(spacing: 16) {
                // Current Selection Display
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Level \(selectedLevel)/12")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(interpolateColor(ratio: Double(selectedLevel) / 12.0))

                        if let current = educationLevels.first(where: { $0.level == selectedLevel }) {
                            Text(current.label)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text(current.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // Visual level indicator
                    ZStack(alignment: .bottom) {
                        // Background bars
                        HStack(alignment: .bottom, spacing: 2) {
                            ForEach(1...12, id: \.self) { level in
                                Rectangle()
                                    .fill(level <= selectedLevel ?
                                          interpolateColor(ratio: Double(level) / 12.0) :
                                          Color.secondary.opacity(0.2))
                                    .frame(width: 8, height: CGFloat(level) * 4)
                            }
                        }
                    }
                    .frame(height: 50)
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(12)

                // Slider
                VStack(spacing: 8) {
                    Slider(value: Binding(
                        get: { Double(selectedLevel) },
                        set: { selectedLevel = Int($0.rounded()) }
                    ), in: 1...12, step: 1)
                    .tint(interpolateColor(ratio: Double(selectedLevel) / 12.0))
                    .accessibilityLabel("Education level")
                    .accessibilityValue("Level \(selectedLevel), \(educationLevels.first(where: { $0.level == selectedLevel })?.label ?? "")")

                    // Min/Max labels
                    HStack {
                        Text("Less than HS")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Doctoral")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Quick Selection Buttons (Major Milestones)
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Select")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                // Note: FlowLayout needs to be implemented or use HStack with wrapping
                HStack(spacing: 8) {
                    QuickSelectButton(level: 2, label: "High School", selectedLevel: $selectedLevel, profileBlend: profileBlend)
                    QuickSelectButton(level: 6, label: "Associate's", selectedLevel: $selectedLevel, profileBlend: profileBlend)
                    QuickSelectButton(level: 8, label: "Bachelor's", selectedLevel: $selectedLevel, profileBlend: profileBlend)
                }
                HStack(spacing: 8) {
                    QuickSelectButton(level: 10, label: "Master's", selectedLevel: $selectedLevel, profileBlend: profileBlend)
                    QuickSelectButton(level: 12, label: "Doctoral", selectedLevel: $selectedLevel, profileBlend: profileBlend)
                }
            }

            // Info Box
            InfoBox(
                icon: "lightbulb.fill",
                title: "Why This Matters",
                message: "Jobs on O*NET have education requirements (1-12 scale). Matching your education level improves job recommendations and filters out mismatches.",
                color: interpolateColor(ratio: profileBlend)
            )
        }
    }

    private func interpolateColor(ratio: Double) -> Color {
        let clampedRatio = max(0, min(1, ratio))
        let amberHue = 0.083
        let tealHue = 0.528
        let hue = amberHue + (tealHue - amberHue) * clampedRatio
        return Color(hue: hue, saturation: 0.7, brightness: 0.85)
    }
}

// Quick Select Button Component
struct QuickSelectButton: View {
    let level: Int
    let label: String
    @Binding var selectedLevel: Int
    let profileBlend: Double

    var isSelected: Bool {
        selectedLevel == level
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedLevel = level
            }
        }) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ?
                    interpolateColor(ratio: Double(level) / 12.0) :
                    Color.secondary.opacity(0.15)
                )
                .cornerRadius(16)
        }
        .accessibilityLabel("\(label) education level")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private func interpolateColor(ratio: Double) -> Color {
        let clampedRatio = max(0, min(1, ratio))
        let amberHue = 0.083
        let tealHue = 0.528
        let hue = amberHue + (tealHue - amberHue) * clampedRatio
        return Color(hue: hue, saturation: 0.7, brightness: 0.85)
    }
}

// Info Box Component (reusable)
struct InfoBox: View {
    let icon: String
    let title: String
    let message: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
    }
}
```

**Step 2: Add Education Level Mapping** (2 hours)

**File**: `Packages/V7Data/Sources/V7Data/Entities/Education+CoreData.swift`

Add after line 101 (isCurrent property):

```swift
// MARK: - O*NET Education Level Mapping (Phase 2)

extension Education {
    /// Maps internal 1-5 scale to O*NET 1-12 scale for Thompson scoring
    ///
    /// **Mapping**:
    /// - 1 (High School) → 4 (O*NET: High school diploma)
    /// - 2 (Associate) → 7 (O*NET: Associate's degree)
    /// - 3 (Bachelor) → 8 (O*NET: Bachelor's degree)
    /// - 4 (Master) → 10 (O*NET: Master's degree)
    /// - 5 (Doctorate) → 12 (O*NET: Doctoral/professional degree)
    ///
    /// **Rationale**: Preserves existing 1-5 storage while providing O*NET-compatible values
    /// for Thompson Sampling matchEducation() function.
    ///
    /// - Returns: O*NET education level (1-12 scale), or 0 if not set
    public var onetEducationLevel: Int {
        switch educationLevelValue {
        case 1: return 4   // High School → O*NET Level 4
        case 2: return 7   // Associate → O*NET Level 7
        case 3: return 8   // Bachelor → O*NET Level 8
        case 4: return 10  // Master → O*NET Level 10
        case 5: return 12  // Doctorate → O*NET Level 12
        default: return 0
        }
    }

    /// Reverse mapping: O*NET 1-12 scale to internal 1-5 scale
    ///
    /// **Mapping**:
    /// - 1-3 → 1 (High School)
    /// - 4-6 → 1 (High School)
    /// - 7 → 2 (Associate)
    /// - 8-9 → 3 (Bachelor)
    /// - 10-11 → 4 (Master)
    /// - 12 → 5 (Doctorate)
    ///
    /// - Parameter onetLevel: O*NET education level (1-12)
    /// - Returns: Internal education level (1-5)
    public static func internalLevel(from onetLevel: Int) -> Int16 {
        switch onetLevel {
        case 1...6: return 1   // High School
        case 7: return 2       // Associate
        case 8...9: return 3   // Bachelor
        case 10...11: return 4 // Master
        case 12: return 5      // Doctorate
        default: return 0
        }
    }
}
```

**Step 3: Integrate into ProfileScreen** (2 hours)

**File**: `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Screens/ProfileScreen.swift`

Add state variable (around line 66):
```swift
// O*NET Profile Fields (Phase 2)
@State private var onetEducationLevel: Int = 8  // Default: Bachelor's (O*NET Level 8)
```

Add section after existing Education section (around line 800):
```swift
// O*NET Education Level (Phase 2)
Section {
    VStack(alignment: .leading, spacing: 16) {
        Text("O*NET Education Level")
            .font(.headline)

        // Auto-populate from highest Education entity if available
        ONetEducationLevelPicker(
            selectedLevel: $onetEducationLevel,
            profileBlend: profileBlend
        )
        .onChange(of: onetEducationLevel) { _, newValue in
            Task {
                await saveONetEducationLevel(newValue)
            }
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 4: Add Core Data Persistence** (2 hours)

Add helper functions to ProfileScreen:
```swift
// MARK: - O*NET Persistence (Phase 2)

@MainActor
private func saveONetEducationLevel(_ level: Int) async {
    guard let userProfile = fetchCurrentUserProfile() else {
        logger.error("❌ No user profile found for O*NET education level save")
        return
    }

    // Update Core Data entity
    userProfile.onetEducationLevel = Int16(level)
    userProfile.lastModified = Date()

    do {
        try context.save()
        logger.info("✅ Saved O*NET education level: \(level)")

        // Optionally update any Education entities to match
        if let education = Education.fetchHighestLevel(for: userProfile, in: context),
           let internalLevel = Education.internalLevel(from: level) as Int16? {
            education.educationLevelValue = internalLevel
            try context.save()
            logger.info("✅ Updated Education entity to match O*NET level")
        }
    } catch {
        logger.error("❌ Failed to save O*NET education level: \(error)")
        viewState = .error("Failed to save education level")
    }
}

private func fetchCurrentUserProfile() -> UserProfile? {
    let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
    request.fetchLimit = 1

    do {
        return try context.fetch(request).first
    } catch {
        logger.error("❌ Failed to fetch user profile: \(error)")
        return nil
    }
}
```

Add onAppear to load existing value:
```swift
.onAppear {
    // Load existing O*NET education level
    if let userProfile = fetchCurrentUserProfile() {
        onetEducationLevel = Int(userProfile.onetEducationLevel)

        // If 0, try to infer from highest Education entity
        if onetEducationLevel == 0,
           let highestEducation = Education.fetchHighestLevel(for: userProfile, in: context) {
            onetEducationLevel = highestEducation.onetEducationLevel
        }
    }
}
```

**Success Criteria**:
- [ ] Education level picker displays with 1-12 scale
- [ ] Visual bars show current level
- [ ] Slider updates smoothly
- [ ] Quick select buttons work
- [ ] Auto-populated from highest Education entity
- [ ] Saves to Core Data on change
- [ ] Value persists across app restarts
- [ ] VoiceOver announces level correctly

#### Task 2.2: Work Activities Selector (14 hours)

**Step 1: Create ONetWorkActivity Model** (2 hours)

**File**: `Packages/V7Core/Sources/V7Core/Models/ONetWorkActivity.swift`

```swift
import Foundation

/// O*NET Work Activity model for Phase 2 Profile Editor
///
/// Represents one of 41 work activities from O*NET database.
/// Used for work preferences matching in Thompson Sampling (25% weight).
///
/// **Categories**:
/// 1. Information Input (5 activities) - How workers get information
/// 2. Mental Processes (10 activities) - How workers process information
/// 3. Work Output (9 activities) - How workers communicate/perform
/// 4. Interacting with Others (17 activities) - How workers interact
///
/// **Data Source**: onet_work_activities.json in V7Core/Resources
///
/// **Example**:
/// ```swift
/// ONetWorkActivity(
///     id: "4.A.2.a.4",
///     name: "Analyzing Data or Information",
///     description: "Identifying relationships and patterns in data",
///     category: .mentalProcesses
/// )
/// ```
public struct ONetWorkActivity: Codable, Identifiable, Sendable, Hashable {
    public let id: String  // Activity ID (e.g., "4.A.1.a.1")
    public let name: String
    public let description: String
    public let category: ActivityCategory

    public init(id: String, name: String, description: String, category: ActivityCategory) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
    }

    /// Work activity category (4 categories total)
    public enum ActivityCategory: String, Codable, Sendable, CaseIterable, Hashable {
        case informationInput = "Information Input"
        case mentalProcesses = "Mental Processes"
        case workOutput = "Work Output"
        case interactingWithOthers = "Interacting with Others"

        /// Icon for category
        public var icon: String {
            switch self {
            case .informationInput: return "eye.fill"
            case .mentalProcesses: return "brain.head.profile"
            case .workOutput: return "hammer.fill"
            case .interactingWithOthers: return "person.2.fill"
            }
        }

        /// Activity count in this category
        public var activityCount: Int {
            switch self {
            case .informationInput: return 5
            case .mentalProcesses: return 10
            case .workOutput: return 9
            case .interactingWithOthers: return 17
            }
        }
    }
}

// MARK: - JSON Deserialization Support

/// Root structure for onet_work_activities.json
struct ONetWorkActivitiesRoot: Codable {
    let version: String
    let source: String
    let generatedDate: String?
    let totalOccupations: Int
    let totalActivities: Int
    let activityMetadata: [ActivityMetadata]
}

/// Activity metadata from JSON
struct ActivityMetadata: Codable {
    let activityId: String
    let activityName: String
    let averageImportance: Double
    let category: String
    let occurrenceCount: Int
    let transferabilityScore: Double
}
```

**Step 2: Create ONetWorkActivitiesDatabase Actor** (2 hours)

**File**: `Packages/V7Core/Sources/V7Core/Services/ONetWorkActivitiesDatabase.swift`

```swift
import Foundation

/// Thread-safe database for O*NET work activities
///
/// **Performance**: O(1) lookup after initial load
/// **Concurrency**: Swift 6 actor pattern for thread safety
/// **Memory**: ~1.9MB JSON file cached in memory
///
/// **Usage**:
/// ```swift
/// let database = ONetWorkActivitiesDatabase.shared
/// let activities = try await database.getAllActivities()
/// let info = try await database.getActivitiesByCategory(.informationInput)
/// ```
@available(iOS 13.0, *)
public actor ONetWorkActivitiesDatabase {
    public static let shared = ONetWorkActivitiesDatabase()

    private var activities: [ONetWorkActivity]?
    private var loadTask: Task<[ONetWorkActivity], Error>?

    private init() {
        // ✅ Start loading immediately in background
        loadTask = Task {
            try await loadActivities()
        }
    }

    /// Loads work activities from bundle JSON file
    ///
    /// **Performance**: ~50-100ms on first call (1.9MB file)
    /// **Caching**: Results cached for subsequent calls
    ///
    /// - Returns: Array of 41 work activities
    /// - Throws: ONetError if file not found or JSON parsing fails
    private func loadActivities() async throws -> [ONetWorkActivity] {
        // ✅ Return cached if available
        if let cached = activities {
            return cached
        }

        // Load from bundle
        guard let url = Bundle.module.url(forResource: "onet_work_activities", withExtension: "json") else {
            throw ONetError.fileNotFound("onet_work_activities.json")
        }

        // ✅ Async file loading (does NOT block main thread)
        let data = try Data(contentsOf: url)
        let root = try JSONDecoder().decode(ONetWorkActivitiesRoot.self, from: data)

        // Convert metadata to ONetWorkActivity models
        let loadedActivities = root.activityMetadata.compactMap { metadata -> ONetWorkActivity? in
            guard let category = ONetWorkActivity.ActivityCategory(rawValue: metadata.category) else {
                return nil
            }

            return ONetWorkActivity(
                id: metadata.activityId,
                name: metadata.activityName,
                description: metadata.activityName,  // Use name as description for now
                category: category
            )
        }

        activities = loadedActivities
        print("✅ Loaded \(loadedActivities.count) O*NET work activities (async)")

        return loadedActivities
    }

    /// Get all 41 work activities
    ///
    /// **Performance**: O(1) after first load (cached)
    ///
    /// - Returns: Array of all work activities
    /// - Throws: ONetError if loading fails
    public func getAllActivities() async throws -> [ONetWorkActivity] {
        if let loadTask = loadTask {
            return try await loadTask.value
        } else if let cached = activities {
            return cached
        } else {
            return try await loadActivities()
        }
    }

    /// Get work activities filtered by category
    ///
    /// **Performance**: O(n) filter, but n=41 so very fast (<1ms)
    ///
    /// - Parameter category: Activity category to filter by
    /// - Returns: Array of activities in specified category
    /// - Throws: ONetError if loading fails
    public func getActivitiesByCategory(_ category: ONetWorkActivity.ActivityCategory) async throws -> [ONetWorkActivity] {
        let all = try await getAllActivities()
        return all.filter { $0.category == category }
    }

    /// Get activity by ID
    ///
    /// - Parameter id: Activity ID (e.g., "4.A.1.a.1")
    /// - Returns: Activity if found, nil otherwise
    public func getActivity(byId id: String) async throws -> ONetWorkActivity? {
        let all = try await getAllActivities()
        return all.first { $0.id == id }
    }

    /// Invalidate cache (for testing or updates)
    public func invalidateCache() {
        activities = nil
        loadTask = nil
    }
}

// MARK: - Error Types

public enum ONetError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(Error)
    case invalidCategory

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "O*NET data file not found: \(filename)"
        case .decodingFailed(let error):
            return "Failed to decode O*NET JSON: \(error.localizedDescription)"
        case .invalidCategory:
            return "Invalid O*NET activity category"
        }
    }
}
```

**Step 3: Build ONetWorkActivitiesSelector UI** (6 hours)

Implementation based on Phase 2 spec lines 490-763. (Too large to include in full here - see spec document)

Key components:
- Main selector view with category sections
- Category section (collapsible)
- Activity row (checkbox + importance slider)
- Selected count display
- Info box

**Step 4: Integrate into ProfileScreen** (2 hours)

Add state and section similar to Education Level.

**Step 5: Add Core Data Persistence** (2 hours)

```swift
@MainActor
private func saveONetWorkActivities(_ activities: [String: Double]) async {
    guard let userProfile = fetchCurrentUserProfile() else { return }

    // Encode dictionary to Data for Transformable attribute
    if let data = try? JSONEncoder().encode(activities) {
        userProfile.onetWorkActivities = data as NSObject
        userProfile.lastModified = Date()

        do {
            try context.save()
            logger.info("✅ Saved \(activities.count) O*NET work activities")
        } catch {
            logger.error("❌ Failed to save work activities: \(error)")
            viewState = .error("Failed to save work activities")
        }
    }
}
```

**Success Criteria**:
- [ ] 41 work activities load from JSON
- [ ] Activities grouped by 4 categories
- [ ] Category sections collapse/expand
- [ ] Select/deselect activities with checkboxes
- [ ] Importance slider (1-7) for selected activities
- [ ] Selected count displays correctly
- [ ] Saves to Core Data on change
- [ ] Data persists across app restarts
- [ ] VoiceOver accessible

#### Task 2.3: RIASEC Profiler (12 hours)

Implementation similar to Tasks 2.1 and 2.2. Key components:
- RIASECInterestProfiler main view
- RIASECRadarChart visualization
- 6 dimension sliders
- Core Data persistence

**Success Criteria**:
- [ ] RIASEC profiler displays with radar chart
- [ ] 6 dimensions editable with sliders
- [ ] Radar chart updates in real-time
- [ ] Accessibility representation for VoiceOver
- [ ] Saves to Core Data as 6 separate doubles
- [ ] Data persists across app restarts

---

## 5. Risks, Blockers & Mitigations

### 5.1 Critical Risks 🔴

#### Risk 1: Education Level Scale Mismatch
**Issue**: Core Data stores 1-5 (highSchool → doctorate), O*NET uses 1-12

**Impact**: 🔴 MEDIUM
- Users might be confused by scale change
- Thompson scoring could use wrong education level
- Existing Education entities need conversion

**Likelihood**: 🔴 HIGH (100% - definite if not addressed)

**Mitigation Strategy**:
1. Add computed property `onetEducationLevel` to Education+CoreData.swift
2. Map 1-5 → 1-12 with explicit conversion table
3. Store O*NET level (1-12) in UserProfile.onetEducationLevel
4. Display O*NET scale in UI picker
5. Convert internally when saving to Education entities

**Code Solution**:
```swift
extension Education {
    public var onetEducationLevel: Int {
        switch educationLevelValue {
        case 1: return 4   // High School
        case 2: return 7   // Associate
        case 3: return 8   // Bachelor
        case 4: return 10  // Master
        case 5: return 12  // Doctorate
        default: return 0
        }
    }
}
```

**Status**: ✅ Solvable with computed property (no schema migration)

**Testing**: Verify round-trip conversion works correctly

#### Risk 2: Missing Persistence Layer in Phase 2 Spec
**Issue**: Phase 2 spec shows UI but no Core Data save operations

**Impact**: 🔴 HIGH
- Data won't persist across app restarts
- User frustration when settings are lost
- Thompson scoring won't have updated data

**Likelihood**: 🔴 HIGH (Phase 2 spec has stub functions only)

**Evidence from Spec** (line 342-353):
```swift
@MainActor
private func updateThompsonProfile(educationLevel: Int) async {
    // Implementation depends on how ProfessionalProfile is stored
    // Example:
    // appState.currentUser?.thompsonProfile.educationLevel = educationLevel

    // Log for verification
    print("✅ Updated Thompson education level to \(educationLevel)")
}
```

**Mitigation Strategy**:
1. Implement Core Data save functions for all 3 tasks:
   - `saveONetEducationLevel()`
   - `saveONetWorkActivities()`
   - `saveONetRIASECProfile()`
2. Add error handling and user feedback
3. Test persistence across app restarts
4. Add integration tests

**Time Impact**: +6 hours (2 hours per task)

**Status**: ⚠️ **MUST IMPLEMENT** - Cannot ship without persistence

---

### 5.2 Medium Risks 🟡

#### Risk 3: Performance Regression from JSON Loading
**Issue**: Loading 1.9MB onet_work_activities.json could block UI

**Impact**: 🟡 MEDIUM
- Could violate <10ms Thompson constraint
- Poor user experience during initial load
- Janky ProfileScreen scrolling

**Likelihood**: 🟡 MEDIUM

**Mitigation Strategy** (Already in Phase 2 spec):
1. Use actor pattern for async loading (line 432)
2. Load in background on app launch
3. Cache singleton instance
4. Show loading indicator during first load

**Verification Required**:
- Benchmark actual load time on device (target: <100ms)
- Test on iPhone 12 (oldest supported device)
- Profile memory usage (should be <2MB increase)

**Performance Test**:
```swift
let startTime = CFAbsoluteTimeGetCurrent()
let activities = try await ONetWorkActivitiesDatabase.shared.getAllActivities()
let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
print("O*NET load time: \(elapsed)ms")
assert(elapsed < 100, "O*NET load too slow: \(elapsed)ms")
```

**Status**: ⚠️ Needs verification testing

#### Risk 4: Accessibility Compliance for Radar Chart
**Issue**: Visual radar charts not accessible to VoiceOver users

**Impact**: 🟡 MEDIUM
- WCAG 2.1 AA violation
- Legal compliance issue
- Poor experience for visually impaired users

**Likelihood**: 🟡 MEDIUM (confirmed without mitigation)

**Mitigation Strategy** (Already in Phase 2 spec line 1187-1208):
```swift
.accessibilityRepresentation {
    VStack(alignment: .leading, spacing: 8) {
        Text("Your Holland Code Scores:")
            .font(.headline)
            .accessibilityAddTraits(.isHeader)

        ForEach(dimensions, id: \.code) { dim in
            HStack {
                Text("\(dim.name) (\(dim.code)):")
                Text("\(Int(valueForCode(dim.code) * 100 / 7))%")
                    .fontWeight(.semibold)
            }
            .font(.body)
        }

        Text("Top strength: \(topDimension())")
            .font(.headline)
            .padding(.top, 8)
    }
}
```

**Testing**:
- Enable VoiceOver on device
- Navigate to RIASEC radar chart
- Verify text alternative is read correctly
- Test with diverse RIASEC profiles

**Status**: ✅ Addressed in spec, needs testing

#### Risk 5: Transformable Attribute for Work Activities Dictionary
**Issue**: `[String: Double]` dictionary needs custom transformer

**Impact**: 🟡 MEDIUM
- Core Data may fail to save/load dictionary
- Data corruption possible
- Migration issues

**Likelihood**: 🟡 MEDIUM

**Mitigation Strategy**:
Use `NSSecureUnarchiveFromData` transformer with Codable:

```swift
// In ProfileScreen save function:
if let data = try? JSONEncoder().encode(activities) {
    userProfile.onetWorkActivities = data as NSObject
}

// In ProfileScreen load function:
if let data = userProfile.onetWorkActivities as? Data {
    let activities = try? JSONDecoder().decode([String: Double].self, from: data)
}
```

**Alternative**: Store as JSON string attribute instead of Transformable

**Testing**:
- Save dictionary with 41 activities
- Restart app
- Verify all 41 activities load correctly
- Test with empty dictionary
- Test with partial data

**Status**: ⚠️ Needs implementation and testing

---

### 5.3 Low Risks 🟢

#### Risk 6: Package Import Cycles
**Issue**: V7UI might accidentally import V7Thompson

**Impact**: 🟢 LOW
- Build error (caught at compile time)
- Easy to fix

**Likelihood**: 🟢 LOW (architecture is well-defined)

**Mitigation Strategy**:
- V7 Architecture Guardian will flag violations
- Code review checklist
- Compile-time error prevents shipping

**Prevention**:
```swift
// ✅ CORRECT: V7UI imports only V7Core
import V7Core  // For O*NET models

// ❌ WRONG: Don't import Thompson from UI
// import V7Thompson  // FORBIDDEN
```

**Status**: ✅ Preventable with architecture discipline

#### Risk 7: Swift 6 Concurrency Warnings
**Issue**: Generic type captures in closures (seen in current codebase)

**Impact**: 🟢 LOW
- Warnings only, not errors
- App still compiles and runs

**Likelihood**: 🟡 MEDIUM (common with SwiftUI generics)

**Example Warning**:
```
Capture of non-Sendable type 'Content.Type' in an isolated closure
```

**Mitigation Strategy**:
- Accept warnings as false positives
- SwiftUI views aren't Sendable by design
- Document reason in code comments

**Status**: ✅ Acceptable (not a blocker)

#### Risk 8: ProfileScreen Becomes Too Long
**Issue**: Adding 3 new sections makes ProfileScreen.swift very large

**Impact**: 🟢 LOW
- Code maintainability
- Harder to navigate file

**Likelihood**: 🔴 HIGH (file is already 2000+ lines)

**Mitigation Strategy**:
1. Extract sections into separate view components
2. Use `@ViewBuilder` for section composition
3. Consider ProfileScreen refactoring in Phase 3

**Not a Blocker**: Can ship and refactor later

---

## 6. Performance Considerations

### 6.1 Thompson <10ms Budget Preservation

**Sacred Constraint**: <10ms Thompson Sampling (357x competitive advantage)

**Current Allocation** (from ThompsonSampling+ONet.swift):
```
Skills matching:          2.0ms (30% weight)
Education matching:       0.8ms (15% weight)  ← Phase 2 impacts UI only
Experience matching:      0.8ms (15% weight)
Work Activities matching: 1.5ms (25% weight)  ← Phase 2 impacts UI only
RIASEC matching:          1.0ms (15% weight)  ← Phase 2 impacts UI only
Overhead:                 1.9ms
──────────────────────────────────────────────
Total:                    8.0ms (2ms safety buffer)
```

**Phase 2 Impact Analysis**:
- ✅ **NO IMPACT** on Thompson engine computation time
- ✅ Thompson scoring code is unchanged
- ✅ O*NET data pre-loaded asynchronously (actor pattern)
- ⚠️ **NEW RISK**: UI rendering could slow ProfileScreen tab

**Verification**:
```swift
// Add performance test to ThompsonSampling+ONet.swift tests
func testONetScoringPerformance() async throws {
    let startTime = CFAbsoluteTimeGetCurrent()

    let score = try await engine.computeONetScore(
        for: sampleJob,
        profile: sampleProfile,
        onetCode: "15-1252.00"
    )

    let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

    XCTAssertLessThan(elapsed, 10.0, "Thompson scoring exceeded 10ms budget: \(elapsed)ms")
}
```

**Mitigation for UI**: Use `LazyVStack` for work activities list (41 items)

### 6.2 Memory Impact

**Estimated Memory Additions**:
- O*NET Work Activities JSON: 1.9MB (loaded once, cached)
- RIASEC Profile storage: 48 bytes per user (6 × 8-byte doubles)
- Work Activities storage: ~2KB per user (41 activities × 48 bytes)
- UI components in memory: ~500KB (views, images)

**Total**: <2.5MB increase

**Current Baseline**: 200MB (from sacred constraints)

**New Total**: 202.5MB (<220MB moderate pressure threshold)

**Status**: ✅ Acceptable - well within budget

### 6.3 Render Performance

**Concern**: ProfileScreen could become sluggish with 3 new sections

**Current ProfileScreen**: ~2000 lines, multiple sections

**New Sections**:
1. Education Level Picker - ~50 UI elements
2. Work Activities Selector - 41 activities × 4 categories = ~164 rows
3. RIASEC Profiler - 6 dimensions + radar chart = ~20 elements

**Total New Elements**: ~234 (significant)

**Optimization Strategy**:

1. **Lazy Loading** - Use `LazyVStack` for work activities:
```swift
LazyVStack {
    ForEach(activities) { activity in
        ActivityRow(activity: activity)
    }
}
```

2. **Collapse by Default** - Start with collapsed category sections:
```swift
@State private var expandedCategory: ActivityCategory?  // Only one expanded at a time
```

3. **Render on Demand** - Don't compute radar chart until section visible:
```swift
if isRIASECSectionVisible {
    RIASECRadarChart(profile: riasecProfile)
}
```

4. **View Identity** - Use stable identifiers for ForEach:
```swift
ForEach(activities, id: \.id) { activity in  // ✅ Stable ID
    ActivityRow(activity: activity)
}
```

**Target**: Maintain 60 FPS scrolling (16.67ms per frame)

**Verification Test**:
```swift
// Instruments: Time Profiler
// Monitor: ProfileScreen scrolling
// Target: No dropped frames
// Threshold: <16ms per frame average
```

### 6.4 Async Loading Performance

**O*NET Work Activities Database Load Time**:
- File size: 1.9MB
- Expected load time: 50-100ms (measured on iPhone 12)
- Happens once per app launch
- Cached in memory thereafter

**User Experience Impact**:
- First time opening ProfileScreen: ~100ms delay
- Subsequent visits: Instant (cached)

**Mitigation**:
1. Pre-load database on app launch (background)
2. Show loading indicator during initial load
3. Allow basic profile editing before O*NET data loads

**Implementation**:
```swift
// In App.swift or AppDelegate
@MainActor
func preloadONetData() {
    Task {
        do {
            _ = try await ONetWorkActivitiesDatabase.shared.getAllActivities()
            print("✅ Pre-loaded O*NET work activities database")
        } catch {
            print("⚠️ Failed to pre-load O*NET data: \(error)")
            // Non-fatal - will load on demand
        }
    }
}
```

---

## 7. Testing Strategy

### 7.1 Unit Tests

**New Test Files Required**:

1. **ONetEducationLevelPickerTests.swift**
   ```swift
   @MainActor
   class ONetEducationLevelPickerTests: XCTestCase {
       func testLevelSelection() {
           // Test slider updates selectedLevel
       }

       func testQuickSelectButtons() {
           // Test Bachelor's button sets level to 8
       }

       func testColorInterpolation() {
           // Test amber→teal gradient
       }

       func testAccessibility() {
           // Test VoiceOver labels
       }
   }
   ```

2. **ONetWorkActivitiesSelectorTests.swift**
   ```swift
   @MainActor
   class ONetWorkActivitiesSelectorTests: XCTestCase {
       func testActivitySelection() {
           // Test checkbox toggles activity
       }

       func testImportanceSlider() {
           // Test importance updates 1-7
       }

       func testCategoryFiltering() {
           // Test 4 categories display correctly
       }

       func testSelectedCount() {
           // Test count displays correctly
       }
   }
   ```

3. **RIASECInterestProfilerTests.swift**
   ```swift
   @MainActor
   class RIASECInterestProfilerTests: XCTestCase {
       func testDimensionSliders() {
           // Test 6 dimensions update correctly
       }

       func testRadarChartData() {
           // Test radar chart reflects profile
       }

       func testAccessibilityRepresentation() {
           // Test text alternative for VoiceOver
       }
   }
   ```

4. **Education+ONetMappingTests.swift**
   ```swift
   class EducationONetMappingTests: XCTestCase {
       func testONetLevelMapping() {
           let education = Education(context: context)

           education.educationLevelValue = 3  // Bachelor
           XCTAssertEqual(education.onetEducationLevel, 8)

           education.educationLevelValue = 5  // Doctorate
           XCTAssertEqual(education.onetEducationLevel, 12)
       }

       func testReverseMapping() {
           XCTAssertEqual(Education.internalLevel(from: 8), 3)   // Bachelor
           XCTAssertEqual(Education.internalLevel(from: 12), 5)  // Doctorate
       }

       func testRoundTripConversion() {
           // Test 1-5 → 1-12 → 1-5 preserves value
       }
   }
   ```

5. **ONetWorkActivitiesDatabaseTests.swift**
   ```swift
   class ONetWorkActivitiesDatabaseTests: XCTestCase {
       func testDatabaseLoad() async throws {
           let db = ONetWorkActivitiesDatabase.shared
           let activities = try await db.getAllActivities()
           XCTAssertEqual(activities.count, 41)
       }

       func testCategoryFiltering() async throws {
           let db = ONetWorkActivitiesDatabase.shared
           let infoInput = try await db.getActivitiesByCategory(.informationInput)
           XCTAssertEqual(infoInput.count, 5)
       }

       func testCaching() async throws {
           // Test subsequent calls don't reload JSON
       }
   }
   ```

**Coverage Target**: 80% for new components

### 7.2 Integration Tests

**Test Scenarios**:

1. **ProfileScreen → Thompson ProfessionalProfile → Thompson Scoring**
   ```swift
   @MainActor
   func testProfileToThompsonIntegration() async throws {
       // 1. Set O*NET education level in ProfileScreen
       profileScreen.onetEducationLevel = 10  // Master's
       await profileScreen.saveONetEducationLevel(10)

       // 2. Fetch UserProfile from Core Data
       let userProfile = fetchCurrentUserProfile()
       XCTAssertEqual(userProfile?.onetEducationLevel, 10)

       // 3. Convert to Thompson ProfessionalProfile
       let thompsonProfile = userProfile?.toThompsonProfile()
       XCTAssertEqual(thompsonProfile?.educationLevel, 10)

       // 4. Use in Thompson scoring
       let score = try await engine.computeONetScore(
           for: sampleJob,
           profile: thompsonProfile!,
           onetCode: "15-1252.00"
       )

       // 5. Verify education factor influenced score
       XCTAssertGreaterThan(score, 0.5)
   }
   ```

2. **Core Data Save → App Restart → Data Restored**
   ```swift
   func testPersistenceAcrossRestarts() async throws {
       // 1. Save O*NET data
       let activities = ["4.A.1.a.1": 6.5, "4.A.2.a.4": 7.0]
       await profileScreen.saveONetWorkActivities(activities)

       // 2. Simulate app restart (reset context)
       context = PersistenceController.shared.container.viewContext

       // 3. Load profile
       let userProfile = fetchCurrentUserProfile()
       let loadedActivities = decodeWorkActivities(userProfile?.onetWorkActivities)

       // 4. Verify data preserved
       XCTAssertEqual(loadedActivities.count, 2)
       XCTAssertEqual(loadedActivities["4.A.1.a.1"], 6.5)
   }
   ```

3. **Education Entity → O*NET Level → Thompson matchEducation()**
   ```swift
   func testEducationMappingIntegration() async throws {
       // 1. Create Education entity (internal 1-5 scale)
       let education = Education(context: context)
       education.educationLevelValue = 3  // Bachelor's

       // 2. Get O*NET level
       let onetLevel = education.onetEducationLevel
       XCTAssertEqual(onetLevel, 8)  // O*NET Bachelor's

       // 3. Use in Thompson scoring
       let profile = ProfessionalProfile(educationLevel: onetLevel)
       let jobRequirements = EducationRequirements(requiredLevel: 8, ...)

       let score = await engine.matchEducation(
           userEducation: profile.educationLevel,
           jobRequirements: jobRequirements
       )

       // 4. Verify perfect match (both level 8)
       XCTAssertEqual(score, 1.0)
   }
   ```

4. **Work Activities → Thompson matchWorkActivities()**
   ```swift
   func testWorkActivitiesIntegration() async throws {
       // Similar pattern to education test
   }
   ```

5. **RIASEC → Thompson matchInterests()**
   ```swift
   func testRIASECIntegration() async throws {
       // Similar pattern to education test
   }
   ```

**Files to Test**:
- `ProfileScreen.swift` (user interaction flow)
- `ThompsonSampling+ONet.swift` (scoring integration)
- `UserProfile+CoreData.swift` (persistence layer)
- `Education+CoreData.swift` (mapping logic)

### 7.3 Performance Tests

**Benchmarks Required**:

1. **O*NET JSON Load Time**
   ```swift
   func testONetDatabaseLoadPerformance() async throws {
       let startTime = CFAbsoluteTimeGetCurrent()

       _ = try await ONetWorkActivitiesDatabase.shared.getAllActivities()

       let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

       XCTAssertLessThan(elapsed, 100, "O*NET load exceeded 100ms: \(elapsed)ms")
   }
   ```
   **Target**: <100ms

2. **ProfileScreen Render Time**
   ```swift
   @MainActor
   func testProfileScreenRenderPerformance() {
       measure {
           let profileScreen = ProfileScreen()
           let _ = profileScreen.body  // Force render
       }
   }
   ```
   **Target**: <16ms for 60 FPS

3. **Thompson Scoring with O*NET Data**
   ```swift
   func testThompsonONetScoringPerformance() async throws {
       let startTime = CFAbsoluteTimeGetCurrent()

       let score = try await engine.computeONetScore(
           for: sampleJob,
           profile: sampleProfile,
           onetCode: "15-1252.00"
       )

       let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

       XCTAssertLessThan(elapsed, 10, "Thompson scoring exceeded 10ms: \(elapsed)ms")
   }
   ```
   **Target**: <10ms (sacred constraint)

4. **Core Data Save Operation**
   ```swift
   @MainActor
   func testCoreDataSavePerformance() throws {
       measure {
           let userProfile = UserProfile(context: context)
           userProfile.onetEducationLevel = 8
           try? context.save()
       }
   }
   ```
   **Target**: <50ms

**Tool**: Use `CFAbsoluteTimeGetCurrent()` for micro-benchmarks

### 7.4 Accessibility Tests

**VoiceOver Testing Checklist**:

- [ ] **Education Level Picker**
  - [ ] Slider announces "Education level, Level X, [Name]"
  - [ ] Quick select buttons announce "Bachelor's education level, button"
  - [ ] Info box content is read completely
  - [ ] Visual bars have hidden accessibility (decorative only)

- [ ] **Work Activities Selector**
  - [ ] Category headers announce count "Mental Processes, 3 of 10 selected"
  - [ ] Activity checkboxes announce "Analyzing Data or Information, checkbox, checked"
  - [ ] Importance slider announces "Importance, High"
  - [ ] Collapsed sections announce "Double tap to expand"

- [ ] **RIASEC Profiler**
  - [ ] Radar chart provides text alternative (not just image)
  - [ ] Dimension sliders announce "Realistic, 6.5 out of 7"
  - [ ] Top strength is announced "Your top strength is Investigative"

**Dynamic Type Testing Checklist**:

- [ ] **All Text Scales** (Small → XXXL)
  - [ ] Education level descriptions don't truncate
  - [ ] Work activity names fit within rows
  - [ ] RIASEC dimension labels remain readable
  - [ ] Buttons remain tappable at all sizes

- [ ] **Layout Adapts**
  - [ ] Sliders remain usable at all text sizes
  - [ ] Quick select buttons wrap appropriately
  - [ ] Radar chart labels don't overlap

**Keyboard Navigation Testing** (iPadOS):

- [ ] Tab order is logical (top to bottom)
- [ ] All interactive elements are focusable
- [ ] Focus indicators are visible
- [ ] Return/Enter activates buttons

**Testing Tools**:
- Xcode Accessibility Inspector
- VoiceOver on physical device
- Dynamic Type preview in Canvas
- Keyboard navigation on iPad

---

## 8. Timeline & Resource Estimates

### 8.1 Detailed Time Breakdown

| Phase | Task | Estimated Hours | Notes |
|-------|------|-----------------|-------|
| **Pre-Implementation** | | **2h** | |
| | Core Data schema extension | 2h | Add O*NET fields to UserProfile |
| **Week 1: Components** | | **30h** | |
| | Task 2.1: Education Picker | 8h | Matches Phase 2 spec |
| | Task 2.2: Work Activities | 14h | +2h for actor database |
| | Task 2.3: RIASEC Profiler | 12h | +2h for persistence |
| **Week 2: Integration** | | **6h** | |
| | Core Data persistence layer | 6h | Missing from Phase 2 spec |
| **Week 3: Testing & QA** | | **18h** | |
| | Unit tests | 6h | 80% coverage target |
| | Integration tests | 4h | End-to-end flows |
| | Performance tests | 4h | Thompson <10ms, UI 60fps |
| | Accessibility tests | 4h | VoiceOver, Dynamic Type |
| **Week 3: Polish** | | **4h** | |
| | Bug fixes | 2h | Edge cases |
| | UX refinement | 2h | Animations, feedback |
| **TOTAL** | | **60h** | **vs Phase 2 spec: 76h** |

**Difference Explanation**:
- Phase 2 spec: 76 hours (30h tasks + 46h estimated overhead)
- My analysis: 60 hours (30h tasks + 6h persistence + 24h testing/polish)
- Savings: 16 hours (less overhead due to existing foundation)

### 8.2 Calendar Timeline

**Assumption**: 1 developer, 8 hours/day

| Week | Days | Tasks | Deliverables |
|------|------|-------|--------------|
| **Week 0** | 0.25 days | Schema extension | Core Data schema with O*NET fields |
| **Week 1** | 5 days | Core components | 3 UI components built |
| | Mon-Tue | Task 2.1 (Education) | ONetEducationLevelPicker working |
| | Wed-Thu | Task 2.2 (Work Activities) | ONetWorkActivitiesSelector working |
| | Fri | Task 2.3 start (RIASEC) | 40% complete |
| **Week 2** | 5 days | Complete + Integrate | All components in ProfileScreen |
| | Mon-Tue | Task 2.3 finish (RIASEC) | RIASECInterestProfiler working |
| | Wed-Fri | Persistence layer | All data saves to Core Data |
| **Week 3** | 5 days | Testing & Polish | Production-ready |
| | Mon-Tue | Unit + Integration tests | 80% test coverage |
| | Wed-Thu | Performance + Accessibility | All tests passing |
| | Fri | Bug fixes + UX polish | Ready for release |

**Total**: 10.25 working days ≈ **2 weeks** (full-time) or **3 weeks** (part-time)

### 8.3 Critical Path Analysis

```
Critical Path (Sequential Dependencies):
┌──────────────────────────────────────────────────┐
│ Phase 1.9 Complete ──┐                           │
│ (Onboarding working)  └──> Schema Extension      │
│                            (2h - Day 0)           │
│                                 │                 │
│                                 ▼                 │
│                         Task 2.1: Education       │
│                            (8h - Days 1-2)        │
│                                 │                 │
│                                 ▼                 │
│                         Task 2.2: Work Activities │
│                            (14h - Days 3-5)       │
│                                 │                 │
│                                 ▼                 │
│                         Task 2.3: RIASEC          │
│                            (12h - Days 5-7)       │
│                                 │                 │
│                                 ▼                 │
│                         Persistence Layer         │
│                            (6h - Days 7-8)        │
│                                 │                 │
│                                 ▼                 │
│                         Integration Testing       │
│                            (4h - Day 8)           │
│                                 │                 │
│                                 ▼                 │
│                         Accessibility Testing     │
│                            (4h - Day 9)           │
│                                 │                 │
│                                 ▼                 │
│                         Performance Validation    │
│                            (4h - Day 9)           │
│                                 │                 │
│                                 ▼                 │
│                         Bug Fixes & Polish        │
│                            (4h - Day 10)          │
│                                 │                 │
│                                 ▼                 │
│                         ✅ PRODUCTION READY       │
└──────────────────────────────────────────────────┘

Total Critical Path: 60 hours (10 days)
```

**Blocking Dependencies**:
1. ❗ Phase 1.9 must be complete before starting
2. ❗ Schema extension must complete before any tasks
3. ❗ Tasks 2.1 → 2.2 → 2.3 must be sequential (ProfileScreen state dependencies)
4. ❗ Persistence layer must complete before integration testing

**Parallel Work Opportunities**:
- ✅ Tasks 2.2 & 2.3 models can be built during Task 2.1 UI work
- ✅ Unit tests can be written alongside component development
- ✅ Documentation can be written in parallel

### 8.4 Risk-Adjusted Timeline

**Best Case** (No blockers): 60 hours = 10 days
**Expected Case** (Minor issues): 66 hours = 11 days (+10%)
**Worst Case** (Major refactoring): 78 hours = 13 days (+30%)

**Risk Factors**:
- Phase 1.9 delays (if not complete)
- Core Data migration issues (schema changes)
- Performance optimization needs (Thompson <10ms)
- Accessibility compliance gaps (VoiceOver fixes)

**Recommended Buffer**: +2 days = **12 days total** (2.4 weeks)

---

## 9. Recommended Implementation Order

### Priority 1: Foundation (MUST DO FIRST)

**1. Complete Phase 1.9 Onboarding** (External Dependency)
- Time: N/A (already in progress)
- Blocking: All Phase 2 work
- Files: Work experience/certifications save fixes
- **Status**: ⚠️ In progress (certifications save fixed, testing needed)

**2. Add O*NET Fields to UserProfile Core Data Schema**
- Time: 2 hours
- Blocking: All Phase 2 tasks
- Files: `V7DataModel.xcdatamodel/contents`
- Changes:
  - Add `onetEducationLevel` (Int16)
  - Add `onetWorkActivities` (Transformable)
  - Add 6 `onetRIASEC*` attributes (Double)
- Testing: Verify lightweight migration

**3. Create O*NET Model Files**
- Time: 2 hours
- Files:
  - `ONetWorkActivity.swift` (NEW in V7Core)
  - `ONetWorkActivitiesDatabase.swift` (NEW in V7Core)
  - `RIASECProfile` (EXISTS in ONetDataModels.swift ✅)
- Non-blocking: Can work in parallel with UI

### Priority 2: Core Features (Sequential)

**4. Task 2.1: Education Level Picker**
- Time: 8 hours
- Rationale: Simplest component, validates integration pattern
- Delivers: 15% Thompson scoring weight
- Files:
  - `ONetEducationLevelPicker.swift` (NEW in V7UI)
  - `Education+CoreData.swift` (MODIFY - add mapping)
  - `ProfileScreen.swift` (MODIFY - add section)
- Success Criteria:
  - Picker displays with 1-12 scale
  - Saves to Core Data
  - Persists across restarts

**5. Task 2.2: Work Activities Selector**
- Time: 14 hours
- Rationale: Highest Thompson weight (25%)
- Delivers: Core cross-domain matching capability
- Files:
  - `ONetWorkActivitiesSelector.swift` (NEW in V7UI)
  - `ProfileScreen.swift` (MODIFY - add section)
- Success Criteria:
  - 41 activities display in 4 categories
  - Selection saves to Core Data
  - Importance sliders work (1-7)

**6. Task 2.3: RIASEC Interest Profiler**
- Time: 12 hours
- Rationale: Most complex UI (radar chart)
- Delivers: Personality-based matching (15% weight)
- Files:
  - `RIASECInterestProfiler.swift` (NEW in V7UI)
  - `RIASECRadarChart.swift` (NEW in V7UI - sub-component)
  - `ProfileScreen.swift` (MODIFY - add section)
- Success Criteria:
  - Radar chart displays correctly
  - 6 dimensions editable
  - Saves as 6 separate doubles

### Priority 3: Persistence & Integration

**7. Core Data Persistence Layer**
- Time: 6 hours
- Rationale: Data must survive app restarts
- Critical: Cannot ship without this
- Files: `ProfileScreen.swift` (MODIFY)
- Functions to Add:
  - `saveONetEducationLevel()`
  - `saveONetWorkActivities()`
  - `saveONetRIASECProfile()`
  - `fetchCurrentUserProfile()`
- Success Criteria:
  - All O*NET data persists
  - Error handling works
  - User feedback on save errors

**8. Integration Testing**
- Time: 4 hours
- Rationale: Ensure Thompson scoring works end-to-end
- Tests:
  - ProfileScreen → Core Data → Thompson
  - Data persistence across restarts
  - Education mapping (1-5 ↔ 1-12)
- Success Criteria:
  - All integration tests pass
  - Thompson scoring uses O*NET data

### Priority 4: Quality Assurance

**9. Accessibility Testing**
- Time: 4 hours
- Rationale: Validate WCAG 2.1 AA compliance
- Tests:
  - VoiceOver announces all fields
  - Dynamic Type scales correctly
  - Radar chart has text alternative
- Success Criteria:
  - No accessibility violations
  - All tests pass

**10. Performance Validation**
- Time: 4 hours
- Rationale: Ensure <10ms Thompson, smooth UI
- Tests:
  - Thompson scoring <10ms
  - O*NET load <100ms
  - ProfileScreen 60 FPS
- Success Criteria:
  - All performance tests pass
  - No regressions

**11. Bug Fixes & UX Polish**
- Time: 4 hours
- Rationale: Address edge cases, improve UX
- Tasks:
  - Fix any bugs from testing
  - Add animations
  - Improve error messages
  - Test on multiple devices

---

## 10. Final Recommendations

### ✅ GO Decision

**Recommendation**: **PROCEED with Phase 2 O*NET Profile Editor integration**

**Confidence Level**: 🟢 **HIGH (90%)**

**Rationale**:

1. **Solid Foundation** ✅
   - Thompson scoring already has full O*NET integration
   - O*NET data models complete and Sendable-compliant
   - O*NET data files present in V7Core bundle
   - Core Data schema ready for extension

2. **Well-Defined Scope** ✅
   - Clear 3-task breakdown (Education, Work Activities, RIASEC)
   - Specific deliverables for each task
   - Known dependencies and critical path

3. **Low Technical Risk** 🟢
   - No heavyweight Core Data migrations
   - No package circular dependencies
   - Pure UI layer work (backend ready)
   - Swift 6 concurrency patterns established

4. **High Business Value** 💎
   - Enables 55% of Thompson scoring weight:
     - Work Activities: 25%
     - Education: 15%
     - RIASEC: 15%
   - Cross-domain career discovery (Amber→Teal)
   - Profile completeness: 55% → 95%

5. **Manageable Timeline** ⏱
   - 60 hours = 2-3 weeks
   - Clear milestones
   - Incremental testing

### Critical Success Factors

**MUST HAVE** (Blockers):
1. ✅ Complete Phase 1.9 first (onboarding stable)
2. ✅ Test Core Data schema changes (backup data)
3. ✅ Implement persistence layer (missing from spec)
4. ✅ Validate Thompson integration (scoring accuracy)

**SHOULD HAVE** (Quality):
5. ✅ Accessibility compliance (VoiceOver, Dynamic Type)
6. ✅ Performance validation (<10ms Thompson, 60 FPS UI)
7. ✅ Device testing (iPhone 15, iPad Air)

**NICE TO HAVE** (Future):
8. ⭕ RIASEC Quick Quiz (2-minute assessment) - defer to Phase 3
9. ⭕ ProfileScreen refactoring (file is large) - defer to Phase 3
10. ⭕ O*NET Abilities integration (52 abilities) - Phase 3 feature

### Post-Implementation Metrics

**Track these KPIs**:

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Profile Completeness | 55% | 95% | % of fields populated |
| Thompson Scoring Accuracy | N/A | +15% | Job match quality |
| User Engagement (ProfileScreen) | N/A | +30% | Time spent in screen |
| Thompson Performance | <8ms | <10ms | Scoring execution time |
| ProfileScreen FPS | Unknown | 60 FPS | Instruments Time Profiler |

**Success Criteria for "Phase 2 Complete"**:
- [ ] All 3 tasks implemented and merged
- [ ] Core Data persistence working for all O*NET fields
- [ ] Thompson scoring uses O*NET data (verified with logging)
- [ ] VoiceOver announces all O*NET fields correctly
- [ ] Dynamic Type supports Small → XXXL
- [ ] Performance tests pass (<10ms Thompson, 60 FPS UI)
- [ ] Integration tests pass (ProfileScreen → Thompson)
- [ ] Device testing complete (iPhone + iPad)
- [ ] Zero P0/P1 bugs remaining

---

## 11. Next Steps

### Immediate Actions (Before Implementation)

**1. Complete Phase 1.9 Onboarding** 🔴 CRITICAL
- Status: In progress (certifications save fixed Oct 31)
- Remaining: Test full onboarding flow on device
- Blocker: Phase 2 cannot start until this is stable

**2. Review This Report with Stakeholders** 📋
- Decision: Approve 60-hour estimate?
- Decision: Approve 2-3 week timeline?
- Decision: Approve priority order?
- Decision: Approve persistence layer addition (+6h)?

**3. Set Up Development Branch** 🌿
- Branch name: `feature/phase-2-onet-profile-editor`
- Base: `main` (after Phase 1.9 merge)
- Protection: Require PR approval

**4. Create Tracking Issues** 📝
- GitHub Issue #1: Task 2.1 Education Level Picker
- GitHub Issue #2: Task 2.2 Work Activities Selector
- GitHub Issue #3: Task 2.3 RIASEC Interest Profiler
- GitHub Issue #4: Core Data Persistence Layer
- GitHub Issue #5: Integration & Accessibility Testing

### Development Kickoff Checklist

**Pre-Implementation Checklist**:
- [ ] Phase 1.9 complete and tested on device
- [ ] All Phase 1.9 tests passing
- [ ] Core Data backup strategy confirmed
- [ ] O*NET data files validated in V7Core bundle (onet_work_activities.json)
- [ ] Development environment iOS 26 compatible
- [ ] Xcode 16+ installed
- [ ] All guardian skills enabled in CLAUDE.md
- [ ] This report reviewed and approved
- [ ] GitHub issues created for all tasks
- [ ] Feature branch created

**Week 0 (Schema) Checklist**:
- [ ] Backup existing Core Data store
- [ ] Add O*NET fields to UserProfile schema
- [ ] Clean build (delete DerivedData)
- [ ] Test lightweight migration on simulator
- [ ] Test on device
- [ ] Verify existing data loads correctly
- [ ] Commit schema changes

**Week 1 (Components) Checklist**:
- [ ] Task 2.1 complete (Education Level Picker)
  - [ ] Component built
  - [ ] Integrated in ProfileScreen
  - [ ] Saves to Core Data
  - [ ] Unit tests written
- [ ] Task 2.2 complete (Work Activities Selector)
  - [ ] Database actor implemented
  - [ ] Component built
  - [ ] Integrated in ProfileScreen
  - [ ] Saves to Core Data
  - [ ] Unit tests written
- [ ] Task 2.3 complete (RIASEC Profiler)
  - [ ] Radar chart working
  - [ ] Component built
  - [ ] Integrated in ProfileScreen
  - [ ] Saves to Core Data
  - [ ] Unit tests written

**Week 2 (Testing) Checklist**:
- [ ] All unit tests passing (80% coverage)
- [ ] Integration tests passing
- [ ] Performance tests passing (<10ms Thompson)
- [ ] Accessibility tests passing (VoiceOver, Dynamic Type)
- [ ] Device testing complete (iPhone, iPad)
- [ ] All P0/P1 bugs fixed

**Week 3 (Polish) Checklist**:
- [ ] UX polish complete (animations, feedback)
- [ ] All tests passing on CI
- [ ] Documentation updated
- [ ] PR ready for review

### Success Criteria for "Done"

**Definition of Done** (All must be ✅):
- [ ] All 3 Phase 2 tasks implemented and merged
- [ ] Core Data persistence working for all O*NET fields
- [ ] Thompson scoring uses O*NET data (verified with logging)
- [ ] VoiceOver announces all O*NET fields correctly
- [ ] Dynamic Type supports Small → XXXL without truncation
- [ ] Performance tests pass:
  - [ ] Thompson scoring <10ms
  - [ ] ProfileScreen renders 60 FPS
  - [ ] O*NET database loads <100ms
- [ ] Integration tests pass:
  - [ ] ProfileScreen → Core Data → Thompson pipeline
  - [ ] Data persists across app restarts
  - [ ] Education mapping works (1-5 ↔ 1-12)
- [ ] Device testing complete:
  - [ ] iPhone 15 Pro (iOS 26)
  - [ ] iPad Air (iOS 26)
  - [ ] Various simulators
- [ ] Zero P0/P1 bugs remaining
- [ ] Code review approved
- [ ] Documentation complete

### Deployment Checklist

**Pre-Release Checklist**:
- [ ] All tests passing on CI
- [ ] Performance validated on device
- [ ] Accessibility validated with VoiceOver
- [ ] Core Data migration tested
- [ ] Rollback plan documented
- [ ] Release notes written
- [ ] App Store screenshots updated
- [ ] TestFlight build submitted

**Post-Release Monitoring**:
- [ ] Monitor crash reports (Sentry/Firebase)
- [ ] Monitor Core Data errors
- [ ] Monitor Thompson scoring performance
- [ ] Monitor user engagement metrics
- [ ] Collect user feedback

---

## Appendix A: File Manifest

**Files to CREATE**:
1. `Packages/V7UI/Sources/V7UI/Components/ONetEducationLevelPicker.swift`
2. `Packages/V7UI/Sources/V7UI/Components/ONetWorkActivitiesSelector.swift`
3. `Packages/V7UI/Sources/V7UI/Components/RIASECInterestProfiler.swift`
4. `Packages/V7UI/Sources/V7UI/Components/RIASECRadarChart.swift`
5. `Packages/V7Core/Sources/V7Core/Models/ONetWorkActivity.swift`
6. `Packages/V7Core/Sources/V7Core/Services/ONetWorkActivitiesDatabase.swift`

**Files to MODIFY**:
1. `Packages/V7Data/Sources/V7Data/V7DataModel.xcdatamodeld/V7DataModel.xcdatamodel/contents`
2. `Packages/V7Data/Sources/V7Data/Entities/Education+CoreData.swift`
3. `Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift`
4. `Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`
5. `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Screens/ProfileScreen.swift`

**Files ALREADY EXIST** (No changes needed):
1. `Packages/V7Core/Sources/V7Core/ONetDataModels.swift` (RIASECProfile ✅)
2. `Packages/V7Thompson/Sources/V7Thompson/ThompsonSampling+ONet.swift` (Scoring ✅)
3. `Packages/V7Thompson/Sources/V7Thompson/ThompsonTypes.swift` (ProfessionalProfile ✅)
4. `Packages/V7Core/Sources/V7Core/Resources/onet_work_activities.json` (Data ✅)

---

## Appendix B: Dependencies Graph

```
Package Dependency Flow (Phase 2):

┌─────────────────────────────────────────────────┐
│ ManifestAndMatchV7Feature (App)                 │
│ - ProfileScreen.swift (MODIFY)                  │
│   └─ Add 3 sections: Education, Activities, RIASEC
└─────────────┬───────────────────────────────────┘
              │
       ┌──────┴──────┬──────────────┬──────────────┐
       │             │              │               │
  ┌────▼────┐   ┌───▼──────┐  ┌───▼──────┐   ┌───▼──────┐
  │ V7UI    │   │ V7Data   │  │V7Thompson│   │V7Services│
  │ NEW:    │   │ MODIFY:  │  │ (EXIST)  │   │ (N/A)    │
  │ - ONetEducationLevelPicker      │  │          │   │          │
  │ - ONetWorkActivitiesSelector    │  │          │   │          │
  │ - RIASECInterestProfiler        │  │ Uses     │   │          │
  │ - RIASECRadarChart              │  │ O*NET    │   │          │
  │         │   │ EXTEND:  │  │ data     │   │          │
  │         │   │ - UserProfile.onet* fields│  │          │
  │         │   │ - Education mapping│  │          │   │          │
  └────┬────┘   └───┬──────┘  └───┬──────┘   └──────────┘
       │            │              │
       └────────────┴──────────────┘
                    │
               ┌────▼────┐
               │ V7Core  │
               │ NEW:    │
               │ - ONetWorkActivity.swift          │
               │ - ONetWorkActivitiesDatabase.swift│
               │ EXIST:  │
               │ - ONetDataModels.swift (RIASEC ✅)│
               │ - onet_work_activities.json ✅    │
               └─────────┘
```

---

**Report Status**: ✅ Complete and Comprehensive
**Next Review**: After Phase 1.9 completion (estimated Nov 1-2, 2025)
**Estimated Start Date**: November 2-3, 2025
**Estimated Completion**: November 12-15, 2025 (2-3 weeks)

**Report Prepared By**: Claude Code with Guardian Skills Active
- ✅ V7 Architecture Guardian (package dependencies, naming, patterns)
- ✅ Core Data Specialist (schema design, persistence, migrations)
- ✅ Swift Concurrency Enforcer (actor patterns, Sendable compliance)

**Confidence in Analysis**: 🟢 HIGH (90%)
- Codebase thoroughly explored
- All dependencies verified
- Risks identified and mitigated
- Timeline realistic with buffer

**Recommendation**: ✅ **GO for Phase 2** after Phase 1.9 completion

---

End of Report
