# Phase 3: O*NET Career Integration Plan

**Document Status**: Implementation Plan
**Created**: October 31, 2025
**Priority**: P0 (Critical Architectural Correction)
**Estimated Effort**: 12-16 hours
**Dependencies**: Phase 2 (complete), Phase 3 Career Journey (complete)

---

## Executive Summary

### The Problem

**Phase 2 O*NET components are misplaced architecturally**:

```
Current (WRONG):
ProfileScreen (Match Profile / Amber / Current Reality)
├── Personal Info (name, email) ✅ CORRECT
├── Work Experience ✅ CORRECT
├── Education ✅ CORRECT
├── O*NET Education Level ❌ WRONG LOCATION
├── O*NET Work Activities ❌ WRONG LOCATION
├── RIASEC Interests ❌ WRONG LOCATION
├── Certifications ✅ CORRECT
└── Job Preferences ✅ CORRECT
```

**Why This Is Wrong**:
1. **Narrative Misalignment**: O*NET is about career **aspiration** (Manifest/Teal), not current reality (Match/Amber)
2. **User Experience**: Feels like tedious data entry in profile form
3. **Architectural**: ProfileScreen = "Who I Am", O*NET = "Where I'm Going"

### The Solution

**Move O*NET components to ManifestTabView (Phase 3)**:

```
Correct (NEW):
ProfileScreen (Match Profile / Amber)
├── Personal Info ✅
├── Work Experience ✅
├── Education ✅
├── Certifications ✅
└── Job Preferences ✅

ManifestTabView (Manifest Profile / Teal) ← Phase 3 Career Journey
├── Career Path Overview
├── Skills Gap Analysis ✅ (already exists)
├── O*NET Career Profile ← ADD
│   ├── Education Level Picker (15% Thompson weight)
│   ├── Work Activities Selector (25% Thompson weight)
│   └── RIASEC Interest Profiler (15% Thompson weight)
├── Course Recommendations ✅ (already exists)
└── Timeline & Milestones ✅ (already exists)
```

---

## Part 1: Current State Analysis

### Files Modified in Phase 2 (O*NET Implementation)

#### 1. ProfileScreen.swift (Lines 217-224, 1089-1163)
**Location**: `/Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`

**O*NET Cards in View Hierarchy**:
```swift
// Lines 217-224 - View hierarchy
onetEducationLevelCard        // Line 218
onetWorkActivitiesCard        // Line 221
riasecInterestCard            // Line 224

// Lines 1089-1163 - Card implementations
private var onetEducationLevelCard: some View { ... }  // Lines 1089-1106
private var onetWorkActivitiesCard: some View { ... }  // Lines 1114-1131
private var riasecInterestCard: some View { ... }      // Lines 1139-1163
```

**State Variables** (Lines 134-141):
```swift
@State private var onetEducationLevel: Int = 8
@State private var onetWorkActivities: [String: Double] = [:]
@State private var riasecRealistic: Double = 3.5
@State private var riasecInvestigative: Double = 3.5
@State private var riasecArtistic: Double = 3.5
@State private var riasecSocial: Double = 3.5
@State private var riasecEnterprising: Double = 3.5
@State private var riasecConventional: Double = 3.5
```

**Save/Load Logic**:
```swift
// Lines 2070-2095 - Save education level
private func saveONetEducationLevel(_ level: Int) { ... }

// Lines 2095-2117 - Save work activities
private func saveONetWorkActivities(_ activities: [String: Double]) { ... }

// Lines 2108-2136 - Save RIASEC profile
private func saveRIASECProfile() { ... }

// Lines 1886-1893 - Load RIASEC from Core Data
riasecRealistic = coreDataProfile.onetRIASECRealistic
// ... (6 dimensions)
```

#### 2. O*NET UI Components (Phase 2 Created)
**Location**: `/Packages/V7UI/Sources/V7UI/Components/`

- `ONetEducationLevelPicker.swift` (345 lines)
- `ONetWorkActivitiesSelector.swift` (484 lines)
- `RIASECInterestProfiler.swift` (693 lines)

#### 3. Core Data Persistence (Pre-existing)
**Location**: `/Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift`

**O*NET Fields**:
```swift
@NSManaged public var onetEducationLevel: Int16
@NSManaged public var onetWorkActivities: [String: Double]?
@NSManaged public var onetRIASECRealistic: Double
@NSManaged public var onetRIASECInvestigative: Double
@NSManaged public var onetRIASECArtistic: Double
@NSManaged public var onetRIASECSocial: Double
@NSManaged public var onetRIASECEnterprising: Double
@NSManaged public var onetRIASECConventional: Double
```

### Files Created in Phase 3 (Career Journey - Already Exists)

#### V7Career Package Structure
**Location**: `/Packages/V7Career/Sources/V7Career/`

```
V7Career/
├── Services/
│   ├── SkillsGapAnalyzer.swift          ✅ (160ms → <15ms optimized)
│   ├── SkillGapExtractor.swift          ✅
│   ├── CareerPathEngine.swift           ✅
│   ├── CourseRecommendationEngine.swift ✅
│   └── ThompsonCareerIntegrator.swift   ✅ (<2ms overhead)
├── Views/
│   ├── ManifestTabView.swift            ✅ (Main container - Phase 3)
│   ├── CareerPathVisualizationView.swift ✅
│   ├── SkillGapCard.swift               ✅
│   ├── TransferableSkillsView.swift     ✅
│   ├── TimelineEstimateView.swift       ✅
│   ├── CourseRecommendationCard.swift   ✅
│   ├── CareerJourneyChartView.swift     ✅
│   ├── CareerTrajectoryView.swift       ✅
│   ├── CareerReadinessGauge.swift       ✅
│   ├── SkillsMatrixView.swift           ✅
│   └── EnrollmentTrackerView.swift      ✅
└── Models/
    ├── CareerPath.swift                 ✅
    ├── SkillsGap.swift                  ✅
    └── Course.swift                     ✅
```

**Key Insight**: ManifestTabView already exists as the Phase 3 container!

---

## Part 2: Migration Architecture

### Design Principles

1. **Narrative Alignment**: O*NET = Career Journey (Manifest/Teal), not Profile (Match/Amber)
2. **Zero Duplication**: Move components, don't copy them
3. **Preserve Core Data**: Keep UserProfile schema unchanged
4. **Keep Fallback**: ProfileScreen can link to Manifest tab for O*NET editing
5. **Phase 3.5 Integration**: Use Phase 3.5 as the bridge

### Target Architecture

```
┌─────────────────────────────────────────────────────────┐
│ ProfileScreen (Match Profile - Amber - "Who I Am")      │
├─────────────────────────────────────────────────────────┤
│ Personal Info                                           │
│ Work Experience                                         │
│ Education                                               │
│ Certifications                                          │
│ Job Preferences                                         │
│                                                         │
│ [View My Career Profile] ───────┐                      │
│     ↓ Deep link to Manifest     │                      │
└─────────────────────────────────┼───────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────┐
│ ManifestTabView (Manifest Profile - Teal - "Where I'm  │
│                  Going")                                │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────┐   │
│ │ O*NET Career Profile Section                    │   │
│ │ ─────────────────────────────────────────────── │   │
│ │ "Your career interests and aspirations"         │   │
│ │                                                  │   │
│ │ 📚 Education Level (1-12 scale)                 │   │
│ │    ONetEducationLevelPicker                     │   │
│ │                                                  │   │
│ │ ⚙️  Work Activities (41 activities)              │   │
│ │    ONetWorkActivitiesSelector                   │   │
│ │                                                  │   │
│ │ 🎭 RIASEC Interests (6 dimensions)              │   │
│ │    RIASECInterestProfiler                       │   │
│ └─────────────────────────────────────────────────┘   │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ Skills Gap Analysis                             │   │
│ │ ─────────────────────────────────────────────── │   │
│ │ Uses O*NET profile + job requirements          │   │
│ │ SkillsGapAnalyzer                               │   │
│ └─────────────────────────────────────────────────┘   │
│                                                         │
│ ┌─────────────────────────────────────────────────┐   │
│ │ Career Path Visualization                       │   │
│ │ ─────────────────────────────────────────────── │   │
│ │ Uses O*NET profile for realistic paths         │   │
│ │ CareerPathVisualizationView                     │   │
│ └─────────────────────────────────────────────────┘   │
│                                                         │
│ Course Recommendations                                  │
│ Timeline & Milestones                                   │
└─────────────────────────────────────────────────────────┘
```

---

## Part 3: Implementation Plan

### Phase 3.5 Extension: O*NET Career Profile Integration

**Duration**: 12-16 hours
**Files Modified**: 3
**Files Created**: 1
**Priority**: P0 (Architectural correction)

---

### Task 1: Create ONetCareerProfileView (4 hours)

**New File**: `/Packages/V7Career/Sources/V7Career/Views/ONetCareerProfileView.swift`

**Purpose**: Container view for all 3 O*NET components in career journey context

```swift
//
//  ONetCareerProfileView.swift
//  V7Career - Phase 3.5 Integration
//
//  Integrates O*NET profile components into career journey context
//  Moved from ProfileScreen (Match/Amber) to ManifestTab (Manifest/Teal)
//

import SwiftUI
import V7Core
import V7Data
import V7UI  // Import for O*NET components

/// O*NET Career Profile view for Manifest tab
/// Integrates education level, work activities, and RIASEC interests
/// in career journey context (not user profile context)
@MainActor
public struct ONetCareerProfileView: View {

    // MARK: - Core Data Context

    @Environment(\.managedObjectContext) private var context

    // MARK: - State Management

    /// O*NET Education Level (1-12 scale)
    @State private var educationLevel: Int = 8

    /// O*NET Work Activities (41 activities, 1-7 importance)
    @State private var workActivities: [String: Double] = [:]

    /// RIASEC Personality Dimensions (0-7 scale)
    @State private var riasecRealistic: Double = 3.5
    @State private var riasecInvestigative: Double = 3.5
    @State private var riasecArtistic: Double = 3.5
    @State private var riasecSocial: Double = 3.5
    @State private var riasecEnterprising: Double = 3.5
    @State private var riasecConventional: Double = 3.5

    /// Profile blend (Amber→Teal, 0.0-1.0)
    /// Fixed at 0.7 for Manifest tab (more Teal than Amber)
    private let profileBlend: Double = 0.7

    /// Expanded section tracking
    @State private var expandedSection: ONetSection? = .education

    // MARK: - Section Enum

    enum ONetSection: String, CaseIterable {
        case education = "Education Goals"
        case activities = "Work Preferences"
        case interests = "Career Interests"
    }

    // MARK: - Body

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView

                // Education Level Section
                sectionCard(
                    section: .education,
                    icon: "graduationcap.fill",
                    subtitle: "Your education aspirations"
                ) {
                    ONetEducationLevelPicker(
                        selectedLevel: $educationLevel,
                        profileBlend: profileBlend
                    )
                    .onChange(of: educationLevel) { _, newValue in
                        saveEducationLevel(newValue)
                    }
                }

                // Work Activities Section
                sectionCard(
                    section: .activities,
                    icon: "briefcase.fill",
                    subtitle: "What you enjoy doing at work"
                ) {
                    ONetWorkActivitiesSelector(
                        selectedActivities: $workActivities,
                        profileBlend: profileBlend
                    )
                    .onChange(of: workActivities) { _, newValue in
                        saveWorkActivities(newValue)
                    }
                }

                // RIASEC Interests Section
                sectionCard(
                    section: .interests,
                    icon: "person.fill.questionmark",
                    subtitle: "Your personality and career fit"
                ) {
                    RIASECInterestProfiler(
                        realistic: $riasecRealistic,
                        investigative: $riasecInvestigative,
                        artistic: $riasecArtistic,
                        social: $riasecSocial,
                        enterprising: $riasecEnterprising,
                        conventional: $riasecConventional,
                        profileBlend: profileBlend
                    )
                    .onChange(of: riasecRealistic) { _, _ in saveRIASECProfile() }
                    .onChange(of: riasecInvestigative) { _, _ in saveRIASECProfile() }
                    .onChange(of: riasecArtistic) { _, _ in saveRIASECProfile() }
                    .onChange(of: riasecSocial) { _, _ in saveRIASECProfile() }
                    .onChange(of: riasecEnterprising) { _, _ in saveRIASECProfile() }
                    .onChange(of: riasecConventional) { _, _ in saveRIASECProfile() }
                }

                // Info Box
                infoBox
            }
            .padding()
        }
        .navigationTitle("Career Profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadONetProfile()
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Career Profile")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("Build your O*NET career profile to unlock personalized job matching, skills gap analysis, and career path recommendations.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func sectionCard<Content: View>(
        section: ONetSection,
        icon: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if expandedSection == section {
                        expandedSection = nil
                    } else {
                        expandedSection = section
                    }
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(tealColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(section.rawValue)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: expandedSection == section ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            // Content (expanded)
            if expandedSection == section {
                content()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
    }

    private var infoBox: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.title3)
                .foregroundColor(tealColor)

            VStack(alignment: .leading, spacing: 4) {
                Text("Why This Matters")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Your O*NET career profile powers the Thompson Sampling algorithm (55% total weight) and helps identify realistic career paths based on your interests, not just your current skills.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(tealColor.opacity(0.1))
        )
    }

    // MARK: - Colors

    private var tealColor: Color {
        Color(hue: 0.528, saturation: 0.7, brightness: 0.85)
    }

    // MARK: - Core Data Persistence

    private func loadONetProfile() {
        guard let profile = UserProfile.fetchCurrent(in: context) else {
            print("❌ [ONetCareerProfileView] No current user profile")
            return
        }

        educationLevel = Int(profile.onetEducationLevel)

        if let activities = profile.onetWorkActivities {
            workActivities = activities
        }

        riasecRealistic = profile.onetRIASECRealistic
        riasecInvestigative = profile.onetRIASECInvestigative
        riasecArtistic = profile.onetRIASECArtistic
        riasecSocial = profile.onetRIASECSocial
        riasecEnterprising = profile.onetRIASECEnterprising
        riasecConventional = profile.onetRIASECConventional

        print("✅ [ONetCareerProfileView] Loaded O*NET profile")
    }

    private func saveEducationLevel(_ level: Int) {
        guard let profile = UserProfile.fetchCurrent(in: context) else { return }

        profile.onetEducationLevel = Int16(level)
        profile.lastModified = Date()

        do {
            try context.save()
            print("✅ [ONetCareerProfileView] Saved education level: \(level)")
        } catch {
            print("❌ [ONetCareerProfileView] Failed to save education level: \(error)")
            context.rollback()
        }
    }

    private func saveWorkActivities(_ activities: [String: Double]) {
        guard let profile = UserProfile.fetchCurrent(in: context) else { return }

        profile.onetWorkActivities = activities
        profile.lastModified = Date()

        do {
            try context.save()
            print("✅ [ONetCareerProfileView] Saved work activities: \(activities.count) activities")
        } catch {
            print("❌ [ONetCareerProfileView] Failed to save work activities: \(error)")
            context.rollback()
        }
    }

    private func saveRIASECProfile() {
        guard let profile = UserProfile.fetchCurrent(in: context) else { return }

        profile.onetRIASECRealistic = riasecRealistic
        profile.onetRIASECInvestigative = riasecInvestigative
        profile.onetRIASECArtistic = riasecArtistic
        profile.onetRIASECSocial = riasecSocial
        profile.onetRIASECEnterprising = riasecEnterprising
        profile.onetRIASECConventional = riasecConventional
        profile.lastModified = Date()

        do {
            try context.save()
            print("✅ [ONetCareerProfileView] Saved RIASEC profile")
        } catch {
            print("❌ [ONetCareerProfileView] Failed to save RIASEC profile: \(error)")
            context.rollback()
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview("O*NET Career Profile") {
    NavigationStack {
        ONetCareerProfileView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
```

---

### Task 2: Integrate ONetCareerProfileView into ManifestTabView (3 hours)

**File**: `/Packages/V7Career/Sources/V7Career/Views/ManifestTabView.swift`

**Changes**:

1. Add navigation destination for O*NET profile
2. Add O*NET profile section card in main view
3. Wire up navigation

```swift
// In ManifestDestination enum (add new case)
public enum ManifestDestination: Hashable, Sendable {
    case overview
    case skillsGap
    case courses
    case careerPath(pathId: String)
    case timeline
    case transferableSkills
    case onetProfile  // ← ADD THIS
}

// In ManifestTabView body (add section after header)
var body: some View {
    NavigationStack(path: $navigationPath) {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                headerSection
                quickActionsSection

                // O*NET Career Profile Section ← ADD THIS
                onetProfileSection
                    .opacity(contentOpacity)
                    .scaleEffect(contentScale)

                careerPathSection
                skillsGapSection
                courseRecommendationsSection
                timelineSection
            }
            .padding(.vertical, 16)
        }
        // ... rest of implementation
    }
}

// Add new section view ← ADD THIS
private var onetProfileSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        // Section Header
        HStack {
            Image(systemName: "person.text.rectangle")
                .font(.title2)
                .foregroundColor(tealColor)

            Text("Career Profile")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()
        }

        // Description
        Text("Build your O*NET career profile for personalized job matching and career path recommendations")
            .font(.subheadline)
            .foregroundColor(.secondary)

        // Quick Stats
        HStack(spacing: 16) {
            profileStat(icon: "graduationcap", label: "Education", value: "Level 8")
            profileStat(icon: "briefcase", label: "Activities", value: "12/41")
            profileStat(icon: "person.fill.checkmark", label: "Interests", value: "80%")
        }

        // Navigate Button
        NavigationLink(value: ManifestDestination.onetProfile) {
            HStack {
                Text("Complete Your Profile")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding()
            .background(tealColor)
            .cornerRadius(12)
        }
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    )
    .padding(.horizontal)
}

// Helper for profile stats
private func profileStat(icon: String, label: String, value: String) -> some View {
    VStack(spacing: 4) {
        Image(systemName: icon)
            .font(.title3)
            .foregroundColor(tealColor)
        Text(label)
            .font(.caption)
            .foregroundColor(.secondary)
        Text(value)
            .font(.caption)
            .fontWeight(.semibold)
    }
    .frame(maxWidth: .infinity)
}

// Add to destinationView function
private func destinationView(for destination: ManifestDestination) -> some View {
    Group {
        switch destination {
        case .overview:
            Text("Overview") // Placeholder
        case .skillsGap:
            Text("Skills Gap") // Existing
        case .courses:
            Text("Courses") // Existing
        case .careerPath(let pathId):
            Text("Career Path: \(pathId)") // Existing
        case .timeline:
            Text("Timeline") // Existing
        case .transferableSkills:
            Text("Transferable Skills") // Existing
        case .onetProfile:  // ← ADD THIS
            ONetCareerProfileView()
        }
    }
}

private var tealColor: Color {
    Color(hue: 0.528, saturation: 0.7, brightness: 0.85)
}
```

---

### Task 3: Remove O*NET from ProfileScreen (2 hours)

**File**: `/Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`

**Changes**:

1. **Remove from view hierarchy** (lines 217-224):
```swift
// BEFORE:
educationCard

// O*NET Education Level (Phase 2 Task 2.1)
onetEducationLevelCard  // ← DELETE

// O*NET Work Activities (Phase 2 Task 2.2)
onetWorkActivitiesCard  // ← DELETE

// RIASEC Personality Profile (Phase 2 Task 2.3)
riasecInterestCard  // ← DELETE

certificationCard

// AFTER:
educationCard
certificationCard
```

2. **Remove card implementations** (lines 1089-1163):
```swift
// DELETE these private vars:
private var onetEducationLevelCard: some View { ... }
private var onetWorkActivitiesCard: some View { ... }
private var riasecInterestCard: some View { ... }
```

3. **Remove state variables** (lines 134-141):
```swift
// DELETE:
@State private var onetEducationLevel: Int = 8
@State private var onetWorkActivities: [String: Double] = [:]
@State private var riasecRealistic: Double = 3.5
// ... (all 6 RIASEC dimensions)
```

4. **Remove save/load functions** (lines 2070-2136):
```swift
// DELETE:
private func saveONetEducationLevel(_ level: Int) { ... }
private func saveONetWorkActivities(_ activities: [String: Double]) { ... }
private func saveRIASECProfile() { ... }

// DELETE loading logic (lines 1886-1893):
riasecRealistic = coreDataProfile.onetRIASECRealistic
// ... (all 6 dimensions)
```

5. **Add deep link to Manifest tab** (OPTIONAL):
```swift
// Add after educationCard
Button(action: {
    // Deep link to Manifest tab → O*NET profile
    tabCoordinator.navigateTo(.manifest, destination: .onetProfile)
}) {
    HStack {
        VStack(alignment: .leading, spacing: 4) {
            Text("Complete Your Career Profile")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text("Build your O*NET profile for better job matching")
                .font(.caption)
                .foregroundColor(.secondary)
        }

        Spacer()

        Image(systemName: "arrow.right")
            .font(.caption)
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hue: 0.528, saturation: 0.7, brightness: 0.85).opacity(0.1))
    )
}
.buttonStyle(.plain)
```

---

### Task 4: Update V7Career Package.swift (1 hour)

**File**: `/Packages/V7Career/Package.swift`

**Changes**: Add V7UI dependency for O*NET components

```swift
// Before:
dependencies: [
    .package(path: "../V7Core"),
    .package(path: "../V7Data"),
    .package(path: "../V7Thompson"),
    .package(path: "../V7AI"),
    .package(path: "../V7Services"),
    .package(path: "../V7Performance")
],

// After:
dependencies: [
    .package(path: "../V7Core"),
    .package(path: "../V7Data"),
    .package(path: "../V7Thompson"),
    .package(path: "../V7AI"),
    .package(path: "../V7Services"),
    .package(path: "../V7UI"),  // ← ADD for O*NET components
    .package(path: "../V7Performance")
],

// In target dependencies:
.target(
    name: "V7Career",
    dependencies: [
        "V7Core",
        "V7Data",
        "V7Thompson",
        "V7AI",
        "V7Services",
        "V7UI",  // ← ADD
        "V7Performance"
    ]
)
```

---

### Task 5: Testing & Validation (2-4 hours)

**Test Checklist**:

1. ✅ **Build Validation**
   - Clean build workspace
   - Verify zero circular dependencies
   - Confirm V7Career can import V7UI components

2. ✅ **Navigation Testing**
   - Open Manifest tab → tap "Complete Your Profile"
   - Verify ONetCareerProfileView displays
   - Test all 3 O*NET component interactions

3. ✅ **Core Data Persistence**
   - Change education level → verify saves to UserProfile.onetEducationLevel
   - Select work activities → verify saves to UserProfile.onetWorkActivities
   - Adjust RIASEC sliders → verify saves to UserProfile.onetRIASEC*
   - Restart app → verify data loads correctly

4. ✅ **ProfileScreen Cleanup**
   - Verify O*NET cards removed
   - Verify deep link to Manifest works (if added)
   - Verify no orphaned state variables

5. ✅ **Performance**
   - Verify Thompson <10ms constraint maintained
   - Test async O*NET data loading (no UI blocking)

6. ✅ **Accessibility**
   - VoiceOver navigation in ONetCareerProfileView
   - Dynamic Type support
   - WCAG 2.1 AA contrast ratios

---

## Part 4: Phase 3.5 Integration

### How This Fits Phase 3.5

**Original Phase 3.5** (3 hours):
- ProfileCompletenessCard (in V7UI)
- Supporting infrastructure for Phases 4-6

**Extended Phase 3.5** (15-19 hours total):
- ProfileCompletenessCard ✅ (3 hours)
- O*NET Career Integration (12-16 hours) ← **THIS PLAN**

**Updated Phase 3.5 Scope**:

```
Phase 3.5: Career Infrastructure + O*NET Integration
├── ProfileCompletenessCard (V7UI)  ✅ 3 hours
└── O*NET Career Profile (V7Career) ← NEW
    ├── ONetCareerProfileView        4 hours
    ├── ManifestTabView integration  3 hours
    ├── ProfileScreen cleanup        2 hours
    ├── Package dependency update    1 hour
    └── Testing & validation         2-4 hours
```

**Total Phase 3.5**: 15-19 hours (was 3 hours)

---

## Part 5: Benefits of This Integration

### 1. Narrative Coherence ✅

**Before** (Broken):
```
User: Opens ProfileScreen
      "Fill out these 41 work activity sliders" ← feels like homework
      "Pick your education level" ← feels tedious
      "Rate your RIASEC interests" ← why am I doing this?
```

**After** (Correct):
```
User: Opens Manifest tab (Career Journey)
      "Let's build your career profile!"
      Education goals, work preferences, interests
      → Feeds into Skills Gap Analysis
      → Powers Career Path recommendations
      → Drives Course suggestions
```

### 2. Architectural Clarity ✅

**ProfileScreen** (Match Profile / Amber):
- Who I am **now**
- Current experience
- Current education
- Current certifications

**ManifestTabView** (Manifest Profile / Teal):
- Who I **want to be**
- Career aspirations (O*NET)
- Career path visualization
- Skills to develop
- Courses to take

### 3. User Experience ✅

- O*NET feels like "career exploration" not "data entry"
- All career tools in one place (Manifest tab)
- ProfileScreen simplified (less overwhelming)
- Clear purpose: Profile = past/present, Manifest = future

### 4. Future AI Integration ✅

When Phase 3.5+ adds AI-driven O*NET discovery:
- Questions asked in Manifest tab context (career journey)
- O*NET profile emerges from career exploration
- Seamless integration with existing Skills Gap, Career Path, Courses

---

## Part 6: Migration Checklist

### Pre-Migration
- [ ] Read this document thoroughly
- [ ] Understand current ProfileScreen structure
- [ ] Understand ManifestTabView structure
- [ ] Back up current codebase

### Implementation
- [ ] Task 1: Create ONetCareerProfileView (4 hours)
- [ ] Task 2: Integrate into ManifestTabView (3 hours)
- [ ] Task 3: Remove from ProfileScreen (2 hours)
- [ ] Task 4: Update Package.swift (1 hour)
- [ ] Task 5: Testing & Validation (2-4 hours)

### Post-Migration
- [ ] Build succeeds with zero errors
- [ ] O*NET components display in Manifest tab
- [ ] Core Data persistence works
- [ ] ProfileScreen no longer shows O*NET cards
- [ ] Navigation flows correctly
- [ ] Performance budgets maintained (<10ms Thompson)
- [ ] Accessibility validated (VoiceOver)

### Documentation
- [ ] Update PHASE_2_ONET_PROFILE_EDITOR.md (note migration)
- [ ] Update PHASE_3_CAREER_JOURNEY_FEATURES.md (add O*NET)
- [ ] Update PHASE_3.5_INFRASTRUCTURE.md (extend scope)
- [ ] Create migration completion report

---

## Part 7: Rollback Plan

If migration fails or causes issues:

### Quick Rollback (5 minutes)
```bash
# Revert to before migration
git stash
git checkout <commit-before-migration>
```

### Partial Rollback (15 minutes)

Keep new ONetCareerProfileView but restore ProfileScreen:
1. Keep `/V7Career/Sources/V7Career/Views/ONetCareerProfileView.swift`
2. Restore ProfileScreen.swift from git history
3. Remove ManifestTabView integration
4. Users can access O*NET from both locations temporarily

---

## Conclusion

This migration:
1. ✅ **Fixes narrative misalignment** (O*NET is career journey, not profile)
2. ✅ **Improves user experience** (all career tools in one place)
3. ✅ **Maintains architectural purity** (zero circular dependencies)
4. ✅ **Preserves Core Data schema** (no breaking changes)
5. ✅ **Integrates with Phase 3** (ManifestTabView already exists)
6. ✅ **Extends Phase 3.5** (natural fit for infrastructure phase)
7. ✅ **Enables future AI** (O*NET in career journey context)

**Recommended Timeline**: Complete in Phase 3.5 (before Phase 4)

**Estimated Effort**: 12-16 hours (includes testing)

**Risk Level**: LOW (well-isolated change, clear rollback path)

**Business Impact**: HIGH (correct architectural foundation for career features)

---

**Document Status**: ✅ Ready for Implementation
**Last Updated**: October 31, 2025
**Next Steps**: Review plan → Implement Task 1 → Iterate
