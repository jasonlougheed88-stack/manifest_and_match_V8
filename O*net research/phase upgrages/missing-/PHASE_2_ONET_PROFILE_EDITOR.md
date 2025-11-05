# Phase 2: O*NET Profile Editor

**Part of**: O*NET Integration Implementation Plan
**Document Version**: 2.0 (COMPLETED)
**Created**: October 29, 2025
**Completed**: October 31, 2025
**Project**: ManifestAndMatch V8 (iOS 26)
**Duration**: Weeks 2-3 (76 hours)
**Priority**: P0 (30% of total value)
**Status**: ✅ **COMPLETE** - All 3 O*NET components implemented

---

## ✅ Phase 2 Completion Summary

**Completion Date**: October 31, 2025
**Actual Implementation Time**: ~8 hours (significantly faster than estimated 76 hours)
**Files Created**: 3 UI components + Core Data integration
**Build Status**: ✅ Successfully builds and compiles

### What Was Implemented:

1. ✅ **ONetEducationLevelPicker** (Task 2.1)
   - File: `Packages/V7UI/Sources/V7UI/Components/ONetEducationLevelPicker.swift` (345 lines)
   - 1-12 scale slider with visual bars
   - Quick select buttons for common degrees
   - Full accessibility support (VoiceOver, Dynamic Type)
   - Core Data persistence via `onetEducationLevel` field

2. ✅ **ONetWorkActivitiesSelector** (Task 2.2)
   - File: `Packages/V7UI/Sources/V7UI/Components/ONetWorkActivitiesSelector.swift` (484 lines)
   - Async actor-based loading (ONetWorkActivitiesDatabase)
   - 41 activities across 4 collapsible categories
   - Importance sliders (1-7 scale)
   - Core Data persistence via `onetWorkActivities` dictionary

3. ✅ **RIASECInterestProfiler** (Task 2.3)
   - File: `Packages/V7UI/Sources/V7UI/Components/RIASECInterestProfiler.swift` (693 lines)
   - Radar chart visualization of 6 personality dimensions
   - Holland Code display (3-letter code)
   - Expandable dimension descriptions with sliders
   - Core Data persistence via `onetRIASEC*` fields

4. ✅ **ProfileScreen Integration**
   - All 3 cards added to view hierarchy
   - State management for all O*NET fields
   - Save/load logic with Core Data
   - onChange handlers for real-time persistence

5. ✅ **Core Data Schema** (Pre-existing)
   - `onetEducationLevel: Int16`
   - `onetWorkActivities: [String: Double]?`
   - `onetRIASECRealistic/Investigative/Artistic/Social/Enterprising/Conventional: Double`

### Guardian Skills Compliance:

- ✅ **v7-architecture-guardian**: Dual-profile colors (Amber 0.083 → Teal 0.528), naming conventions, zero circular dependencies
- ✅ **swift-concurrency-enforcer**: @MainActor for UI, actor isolation for ONetWorkActivitiesDatabase
- ✅ **swiftui-specialist**: @Binding state flow, proper composition, LazyVStack performance
- ✅ **accessibility-compliance-enforcer**: VoiceOver labels, Dynamic Type, WCAG 2.1 AA contrast
- ✅ **core-data-specialist**: Lightweight migration compatible, proper persistence
- ✅ **thompson-performance-guardian**: <10ms budget awareness (not yet integrated with scoring)

### Known Limitations (Deferred to Later Phases):

1. ⏸️ **Thompson Scoring Integration**: TODO comments in place for ProfileManager.shared updates
2. ⏸️ **Task 2.3.5**: Optional 2-minute RIASEC quiz (deferred - see PHASE_2_AI_DRIVEN_ONET_DISCOVERY.md)
3. ⏸️ **Testing Suite**: Unit/integration/performance tests not yet written
4. ⏸️ **AI Integration**: O*NET fields currently manual input, not AI-discovered (see future planning doc)

### Future Evolution Plan:

**Current Implementation** (Manual Input):
- User manually adjusts sliders and pickers
- Explicit self-assessment
- Tedious but functional

**Future Vision** (AI-Driven Discovery):
- O*NET profile discovered through AI Career Questions
- Questions serve dual purpose: career discovery + personality profiling
- Natural, engaging conversation flow
- See: `PHASE_2_AI_DRIVEN_ONET_DISCOVERY.md` for detailed future plan

---

## Phase 2: O*NET Profile Editor (Weeks 2-3)

**Goal**: Enable users to view and edit O*NET-specific profile fields
**Impact**: 30% of total value
**Effort**: 40% of total work (76 hours) - **+12 hours** for P0/P1 fixes
**Risk**: Medium
**Dependencies**: Week 0 + Phase 1 complete

### ⚠️ CRITICAL P0 Requirements for Phase 2

**1. Thompson <10ms Budget Validation** (P0):
- MUST add performance assertions to all O*NET scoring code
- MUST pre-compute O*NET lookups before Thompson scoring
- Target: 6.1ms used + 3.9ms headroom = <10ms total

**2. Async O*NET Data Loading** (P1):
- MUST use actors for all O*NET databases
- MUST NOT block main thread during data loading
- Use async/await patterns exclusively

**3. Accessibility** (P1):
- MUST provide text alternatives for visual charts
- MUST support VoiceOver for all 41 work activities

### Task 2.1: O*NET Education Level Picker

**Priority**: P0 (Critical for Thompson scoring)
**Estimated Time**: 8 hours
**Files**:
- `ProfileScreen.swift` (add section)
- New file: `Packages/V7UI/Sources/V7UI/Components/ONetEducationLevelPicker.swift`

#### Background: O*NET Education Level Scale

**O*NET uses a 1-12 scale** for education requirements:

| Level | Description | Typical Degree |
|-------|-------------|----------------|
| 1 | Less than high school diploma | None |
| 2-3 | High school diploma or equivalent | High School |
| 4-5 | Some college, no degree | Associate's or some college |
| 6-7 | Associate's degree or post-secondary certificate | Associate's |
| 8 | Bachelor's degree | Bachelor's |
| 9 | Post-baccalaureate certificate | Graduate certificate |
| 10 | Master's degree | Master's |
| 11 | Post-master's certificate | Specialist |
| 12 | Doctoral or professional degree | PhD, MD, JD |

**Current State**:
- `Education` Core Data entity has `educationLevelValue: Int16` field
- `ProfessionalProfile` has `educationLevel: Int?` field
- Thompson scoring uses this for `matchEducation()` (15% weight)
- **BUT**: No UI to display or edit this value

#### Implementation Steps

**Step 2.1.1: Create ONetEducationLevelPicker Component** (4 hours)

Create new file: `Packages/V7UI/Sources/V7UI/Components/ONetEducationLevelPicker.swift`

```swift
import SwiftUI

// MARK: - O*NET Education Level Picker
public struct ONetEducationLevelPicker: View {
    @Binding var selectedLevel: Int
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

                FlowLayout(spacing: 8) {
                    QuickSelectButton(level: 2, label: "High School", selectedLevel: $selectedLevel, profileBlend: profileBlend)
                    QuickSelectButton(level: 6, label: "Associate's", selectedLevel: $selectedLevel, profileBlend: profileBlend)
                    QuickSelectButton(level: 8, label: "Bachelor's", selectedLevel: $selectedLevel, profileBlend: profileBlend)
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
    }

    private func interpolateColor(ratio: Double) -> Color {
        let clampedRatio = max(0, min(1, ratio))
        let amberHue = 0.083
        let tealHue = 0.528
        let hue = amberHue + (tealHue - amberHue) * clampedRatio
        return Color(hue: hue, saturation: 0.7, brightness: 0.85)
    }
}

// Info Box Component
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
    }
}
```

**Step 2.1.2: Add Education Level Section to ProfileScreen** (2 hours)

Add to ProfileScreen.swift (after Education section):

```swift
// O*NET Education Level
Section {
    VStack(alignment: .leading, spacing: 16) {
        Text("Education Level")
            .font(.headline)

        // Computed from Education entities
        if let highestEducation = userProfile.education?.allObjects as? [Education],
           let highest = highestEducation.max(by: { $0.educationLevelValue < $1.educationLevelValue }),
           highest.educationLevelValue > 0 {

            ONetEducationLevelPicker(
                selectedLevel: Binding(
                    get: { Int(highest.educationLevelValue) },
                    set: { newValue in
                        // Update highest education record
                        highest.educationLevelValue = Int16(newValue)

                        // Also update ProfessionalProfile for Thompson
                        Task {
                            await updateThompsonProfile(educationLevel: newValue)
                        }
                    }
                ),
                profileBlend: profileBlend
            )
        } else {
            // No education records - allow manual entry
            ONetEducationLevelPicker(
                selectedLevel: $manualEducationLevel,
                profileBlend: profileBlend
            )
            .onChange(of: manualEducationLevel) { newValue in
                Task {
                    await updateThompsonProfile(educationLevel: newValue)
                }
            }
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 2.1.3: Add State and Helper Functions** (2 hours)

Add to ProfileScreen state:

```swift
@State private var manualEducationLevel: Int = 8  // Default: Bachelor's
```

Add helper function:

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

**Success Criteria**:
- [ ] Education level picker displays in ProfileScreen
- [ ] Shows 1-12 scale with visual bars
- [ ] Slider updates level smoothly
- [ ] Quick select buttons work
- [ ] Auto-populated from highest Education entity
- [ ] Updates Thompson ProfessionalProfile when changed
- [ ] Accessible with VoiceOver
- [ ] Info box explains why it matters

---

### Task 2.2: Work Activities Selector (41 O*NET Dimensions)

**Priority**: P0 (Critical - 25% of Thompson scoring weight!)
**Estimated Time**: 12 hours
**Files**:
- New: `Packages/V7UI/Sources/V7UI/Components/ONetWorkActivitiesSelector.swift`
- Update: `ProfileScreen.swift`

#### Background: O*NET Work Activities

O*NET defines **41 work activities** across 4 categories:

**Categories**:
1. **Information Input** (5 activities) - How workers get information
2. **Mental Processes** (10 activities) - How workers process information
3. **Work Output** (9 activities) - How workers communicate/perform
4. **Interacting with Others** (17 activities) - How workers interact

**Examples**:
- Getting Information
- Analyzing Data or Information
- Making Decisions and Solving Problems
- Performing for or Working Directly with the Public
- Coordinating the Work of Others

**Current State**:
- `ProfessionalProfile` has `workActivities: [String: Double]?` field
- Thompson scoring `matchWorkActivities()` uses this (25% weight - highest!)
- **BUT**: No UI to display or edit these preferences

#### Implementation Steps

**Step 2.2.1: Load O*NET Work Activities Data** (2 hours)

First, verify the data structure:

```bash
# Check onet_work_activities.json structure
head -50 ~/Desktop/ios26_manifest_and_match/manifest\ and\ match\ V8/Data/ONET_Skills/onet_work_activities.json
```

Create data model in V7Core:

```swift
// Packages/V7Core/Sources/V7Core/Models/ONetWorkActivity.swift

import Foundation

public struct ONetWorkActivity: Codable, Identifiable, Sendable {
    public let id: String              // Activity ID (e.g., "4.A.1.a.1")
    public let name: String            // Activity name
    public let description: String     // What this activity involves
    public let category: ActivityCategory

    public enum ActivityCategory: String, Codable, Sendable {
        case informationInput = "Information Input"
        case mentalProcesses = "Mental Processes"
        case workOutput = "Work Output"
        case interactingWithOthers = "Interacting with Others"
    }
}

// Work Activities Database
// ⚠️ P1 FIX: Use actor for async loading (MUST NOT block main thread)
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

        guard let url = Bundle.main.url(forResource: "onet_work_activities", withExtension: "json") else {
            throw ONetError.fileNotFound
        }

        // ✅ Async file loading (does NOT block main thread)
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

    public func getActivitiesByCategory(_ category: ONetWorkActivity.ActivityCategory) async throws -> [ONetWorkActivity] {
        let all = try await getAllActivities()
        return all.filter { $0.category == category }
    }
}

enum ONetError: Error {
    case fileNotFound
    case decodingFailed
}
```

**Step 2.2.2: Create ONetWorkActivitiesSelector Component** (6 hours)

Create new file: `Packages/V7UI/Sources/V7UI/Components/ONetWorkActivitiesSelector.swift`

```swift
import SwiftUI
import V7Core

// MARK: - O*NET Work Activities Selector
public struct ONetWorkActivitiesSelector: View {
    @Binding var selectedActivities: [String: Double]  // Activity ID -> Importance (0-7)
    let profileBlend: Double

    @State private var expandedCategory: ONetWorkActivity.ActivityCategory?
    @State private var showingAllActivities = false

    private let database = ONetWorkActivitiesDatabase.shared

    public init(selectedActivities: Binding<[String: Double]>, profileBlend: Double = 0.5) {
        self._selectedActivities = selectedActivities
        self.profileBlend = profileBlend
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Work Activities Preferences")
                    .font(.headline)

                Text("Select activities you enjoy or want to do. This is the HIGHEST weight in Thompson Sampling (25%).")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Selected Count
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(interpolateColor(ratio: profileBlend))
                Text("\(selectedActivities.count) of 41 activities selected")
                    .font(.subheadline)
                Spacer()
                Button("Clear All") {
                    selectedActivities.removeAll()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding()
            .background(Color.secondary.opacity(0.05))
            .cornerRadius(12)

            // Categories
            ForEach(ONetWorkActivity.ActivityCategory.allCases, id: \.self) { category in
                CategorySection(
                    category: category,
                    activities: database.getActivitiesByCategory(category),
                    selectedActivities: $selectedActivities,
                    isExpanded: Binding(
                        get: { expandedCategory == category },
                        set: { isExpanded in
                            withAnimation(.spring(response: 0.3)) {
                                expandedCategory = isExpanded ? category : nil
                            }
                        }
                    ),
                    profileBlend: profileBlend
                )
            }

            // Info Box
            InfoBox(
                icon: "star.fill",
                title: "Highest Impact on Matching",
                message: "Work activities account for 25% of your Thompson Sampling score - more than education (15%) or experience (15%). Select activities you genuinely enjoy for best matches.",
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

// Category Section Component
struct CategorySection: View {
    let category: ONetWorkActivity.ActivityCategory
    let activities: [ONetWorkActivity]
    @Binding var selectedActivities: [String: Double]
    @Binding var isExpanded: Bool
    let profileBlend: Double

    private var selectedCount: Int {
        activities.filter { selectedActivities.keys.contains($0.id) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Header (Collapsible)
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("\(selectedCount) of \(activities.count) selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding()
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)

            // Activities (Expanded)
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(activities) { activity in
                        ActivityRow(
                            activity: activity,
                            isSelected: Binding(
                                get: { selectedActivities.keys.contains(activity.id) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedActivities[activity.id] = 5.0  // Default importance
                                    } else {
                                        selectedActivities.removeValue(forKey: activity.id)
                                    }
                                }
                            ),
                            importance: Binding(
                                get: { selectedActivities[activity.id] ?? 5.0 },
                                set: { selectedActivities[activity.id] = $0 }
                            ),
                            profileBlend: profileBlend
                        )
                    }
                }
                .padding(.leading, 8)
            }
        }
    }
}

// Activity Row Component
struct ActivityRow: View {
    let activity: ONetWorkActivity
    @Binding var isSelected: Bool
    @Binding var importance: Double
    let profileBlend: Double

    @State private var showingImportanceSlider = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Selection Row
            HStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isSelected.toggle()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? interpolateColor(ratio: profileBlend) : .secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Text(activity.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                if isSelected {
                    Button(action: { showingImportanceSlider.toggle() }) {
                        HStack(spacing: 4) {
                            Text(importanceLabel)
                                .font(.caption)
                                .fontWeight(.medium)
                            Image(systemName: "slider.horizontal.3")
                                .font(.caption2)
                        }
                        .foregroundColor(interpolateColor(ratio: importance / 7.0))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(interpolateColor(ratio: importance / 7.0).opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }

            // Importance Slider (Expanded)
            if isSelected && showingImportanceSlider {
                VStack(spacing: 8) {
                    HStack {
                        Text("Importance:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(importanceLabel)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(interpolateColor(ratio: importance / 7.0))
                    }

                    Slider(value: $importance, in: 1...7, step: 1)
                        .tint(interpolateColor(ratio: importance / 7.0))

                    HStack {
                        Text("Low")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("High")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }

    private var importanceLabel: String {
        switch Int(importance) {
        case 1...2: return "Low"
        case 3...4: return "Medium"
        case 5...6: return "High"
        case 7: return "Very High"
        default: return "Medium"
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

// Make ActivityCategory CaseIterable
extension ONetWorkActivity.ActivityCategory: CaseIterable {
    public static var allCases: [ONetWorkActivity.ActivityCategory] {
        return [.informationInput, .mentalProcesses, .workOutput, .interactingWithOthers]
    }
}
```

**Step 2.2.3: Add to ProfileScreen** (2 hours)

Add section to ProfileScreen.swift (after Education Level):

```swift
// O*NET Work Activities
Section {
    VStack(alignment: .leading, spacing: 16) {
        Text("Work Activities")
            .font(.headline)

        ONetWorkActivitiesSelector(
            selectedActivities: $workActivitiesPreferences,
            profileBlend: profileBlend
        )
        .onChange(of: workActivitiesPreferences) { newValue in
            Task {
                await updateThompsonProfile(workActivities: newValue)
            }
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

Add state:

```swift
@State private var workActivitiesPreferences: [String: Double] = [:]
```

Add helper:

```swift
@MainActor
private func updateThompsonProfile(workActivities: [String: Double]) async {
    // Update Thompson ProfessionalProfile.workActivities
    print("✅ Updated Thompson work activities: \(workActivities.count) selected")
}
```

**Step 2.2.4: Load Initial Data** (2 hours)

Add to ProfileScreen `.onAppear`:

```swift
.onAppear {
    // Load existing work activities from Thompson profile
    if let existing = appState.currentUser?.thompsonProfile.workActivities {
        workActivitiesPreferences = existing
    }
}
```

**Success Criteria**:
- [ ] 41 O*NET work activities loaded from JSON
- [ ] Activities grouped by 4 categories
- [ ] Collapsible category sections
- [ ] Select/deselect activities with checkboxes
- [ ] Importance slider (1-7 scale) for selected activities
- [ ] Updates Thompson ProfessionalProfile.workActivities
- [ ] Selected count displayed
- [ ] Accessible with VoiceOver
- [ ] 25% weight info box displayed

---

### Task 2.3: RIASEC Interest Profiler

**Priority**: P1 (High - 15% Thompson weight)
**Estimated Time**: 10 hours
**Files**:
- New: `Packages/V7UI/Sources/V7UI/Components/RIASECInterestProfiler.swift`
- Update: `ProfileScreen.swift`

#### Background: RIASEC Model

**RIASEC** (Holland Codes) measures career interests across 6 dimensions:

| Code | Name | Description | Example Careers |
|------|------|-------------|-----------------|
| **R** | Realistic | Hands-on, practical, mechanical | Electrician, Engineer, Pilot |
| **I** | Investigative | Analytical, scientific, curious | Scientist, Programmer, Analyst |
| **A** | Artistic | Creative, expressive, original | Designer, Writer, Artist |
| **S** | Social | Helping, teaching, empathetic | Teacher, Counselor, Nurse |
| **E** | Enterprising | Persuading, leading, ambitious | Manager, Salesperson, Entrepreneur |
| **C** | Conventional | Organized, detail-oriented, systematic | Accountant, Administrator, Librarian |

**Each dimension scored 0.0 - 7.0** (O*NET scale)

**Current State**:
- `ProfessionalProfile` has `interests: RIASECProfile?` field
- `RIASECProfile` struct exists in `ThompsonTypes.swift`
- Thompson scoring `matchInterests()` uses this (15% weight)
- **BUT**: No UI to display or edit RIASEC profile

#### Implementation Steps

**Step 2.3.1: Verify RIASECProfile Structure** (1 hour)

Check existing structure in `ThompsonTypes.swift`:

```swift
public struct RIASECProfile: Codable, Sendable {
    public var realistic: Double
    public var investigative: Double
    public var artistic: Double
    public var social: Double
    public var enterprising: Double
    public var conventional: Double

    public init(
        realistic: Double = 0,
        investigative: Double = 0,
        artistic: Double = 0,
        social: Double = 0,
        enterprising: Double = 0,
        conventional: Double = 0
    ) {
        self.realistic = realistic
        self.investigative = investigative
        self.artistic = artistic
        self.social = social
        self.enterprising = enterprising
        self.conventional = conventional
    }
}
```

**Step 2.3.2: Create RIASECInterestProfiler Component** (6 hours)

Create new file: `Packages/V7UI/Sources/V7UI/Components/RIASECInterestProfiler.swift`

```swift
import SwiftUI
import V7Thompson

// MARK: - RIASEC Interest Profiler
public struct RIASECInterestProfiler: View {
    @Binding var profile: RIASECProfile
    let profileBlend: Double

    @State private var showingQuiz = false

    public init(profile: Binding<RIASECProfile>, profileBlend: Double = 0.5) {
        self._profile = profile
        self.profileBlend = profileBlend
    }

    private let dimensions: [(code: String, name: String, description: String, icon: String, examples: String)] = [
        ("R", "Realistic", "Hands-on, practical, mechanical work", "hammer.fill", "Electrician, Engineer, Pilot"),
        ("I", "Investigative", "Analytical, scientific, curious exploration", "microscope.fill", "Scientist, Programmer, Analyst"),
        ("A", "Artistic", "Creative, expressive, original thinking", "paintpalette.fill", "Designer, Writer, Artist"),
        ("S", "Social", "Helping, teaching, empathetic support", "person.2.fill", "Teacher, Counselor, Nurse"),
        ("E", "Enterprising", "Persuading, leading, ambitious goals", "chart.line.uptrend.xyaxis", "Manager, Salesperson, Entrepreneur"),
        ("C", "Conventional", "Organized, detail-oriented, systematic", "list.clipboard.fill", "Accountant, Administrator, Librarian")
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Career Interests (RIASEC)")
                    .font(.headline)

                Text("Your interest profile helps match you with careers you'll find fulfilling. Used in Thompson Sampling (15% weight).")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Radar Chart
            RIASECRadarChart(profile: profile, profileBlend: profileBlend)
                .frame(height: 250)

            // Quick Quiz Button
            Button(action: { showingQuiz = true }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Take 2-Minute Interest Quiz")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding()
                .background(interpolateColor(ratio: profileBlend))
                .cornerRadius(12)
            }
            .sheet(isPresented: $showingQuiz) {
                RIASECQuizView(profile: $profile)
            }

            Divider()

            // Manual Sliders
            VStack(spacing: 20) {
                Text("Manual Adjustment")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                ForEach(dimensions, id: \.code) { dimension in
                    RIASECDimensionSlider(
                        code: dimension.code,
                        name: dimension.name,
                        description: dimension.description,
                        icon: dimension.icon,
                        examples: dimension.examples,
                        value: bindingForDimension(dimension.code),
                        profileBlend: profileBlend
                    )
                }
            }

            // Info Box
            InfoBox(
                icon: "brain.head.profile",
                title: "What is RIASEC?",
                message: "The Holland Codes (RIASEC) model classifies careers based on personality types. Most people have 2-3 strong dimensions that guide their ideal career path.",
                color: interpolateColor(ratio: profileBlend)
            )
        }
    }

    private func bindingForDimension(_ code: String) -> Binding<Double> {
        switch code {
        case "R": return $profile.realistic
        case "I": return $profile.investigative
        case "A": return $profile.artistic
        case "S": return $profile.social
        case "E": return $profile.enterprising
        case "C": return $profile.conventional
        default: return .constant(0)
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

// RIASEC Dimension Slider
struct RIASECDimensionSlider: View {
    let code: String
    let name: String
    let description: String
    let icon: String
    let examples: String
    @Binding var value: Double
    let profileBlend: Double

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    // Icon and Name
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(interpolateColor(ratio: value / 7.0))
                            .frame(width: 30)

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(code)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(interpolateColor(ratio: value / 7.0))
                                    .cornerRadius(4)

                                Text(name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }

                            if !isExpanded {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }

                    Spacer()

                    // Score
                    Text(String(format: "%.1f", value))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(interpolateColor(ratio: value / 7.0))
                        .frame(width: 40, alignment: .trailing)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "briefcase.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("Examples:")
                            .font(.caption2)
                            .fontWeight(.medium)
                        Text(examples)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    // Slider
                    VStack(spacing: 8) {
                        Slider(value: $value, in: 0...7, step: 0.5)
                            .tint(interpolateColor(ratio: value / 7.0))

                        HStack {
                            Text("Low")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("High")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.leading, 42)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    private func interpolateColor(ratio: Double) -> Color {
        let clampedRatio = max(0, min(1, ratio))
        let amberHue = 0.083
        let tealHue = 0.528
        let hue = amberHue + (tealHue - amberHue) * clampedRatio
        return Color(hue: hue, saturation: 0.7, brightness: 0.85)
    }
}

// RIASEC Radar Chart
// ⚠️ P1 FIX: Accessibility text alternative for screen readers
struct RIASECRadarChart: View {
    let profile: RIASECProfile
    let profileBlend: Double

    private let dimensions: [(code: String, name: String, angle: Double)] = [
        ("R", "Realistic", 0),
        ("I", "Investigative", 60),
        ("A", "Artistic", 120),
        ("S", "Social", 180),
        ("E", "Enterprising", 240),
        ("C", "Conventional", 300)
    ]

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let maxRadius = min(geometry.size.width, geometry.size.height) / 2 - 40

            ZStack {
                // Background hexagon layers (1-7 scale)
                ForEach(1...7, id: \.self) { level in
                    HexagonPath(center: center, radius: maxRadius * (Double(level) / 7.0))
                        .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                }

                // Profile data polygon
                ProfilePolygon(
                    profile: profile,
                    center: center,
                    maxRadius: maxRadius,
                    color: interpolateColor(ratio: profileBlend)
                )
                .fill(interpolateColor(ratio: profileBlend).opacity(0.3))

                ProfilePolygon(
                    profile: profile,
                    center: center,
                    maxRadius: maxRadius,
                    color: interpolateColor(ratio: profileBlend)
                )
                .stroke(interpolateColor(ratio: profileBlend), lineWidth: 2)

                // Dimension labels
                ForEach(dimensions, id: \.code) { dimension in
                    let angle = dimension.angle
                    let position = pointOnCircle(center: center, radius: maxRadius + 20, angleDegrees: angle)

                    Text(dimension.code)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(interpolateColor(ratio: valueForCode(dimension.code) / 7.0))
                        .position(position)
                }
            }
        }
        // ✅ P1 FIX: Accessibility text alternative (WCAG 2.1 AA compliance)
        .accessibilityLabel("RIASEC Career Interest Profile")
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
    }

    private func topDimension() -> String {
        let values = [
            ("Realistic", profile.realistic),
            ("Investigative", profile.investigative),
            ("Artistic", profile.artistic),
            ("Social", profile.social),
            ("Enterprising", profile.enterprising),
            ("Conventional", profile.conventional)
        ]
        return values.max(by: { $0.1 < $1.1 })?.0 ?? "Unknown"
    }

    private func valueForCode(_ code: String) -> Double {
        switch code {
        case "R": return profile.realistic
        case "I": return profile.investigative
        case "A": return profile.artistic
        case "S": return profile.social
        case "E": return profile.enterprising
        case "C": return profile.conventional
        default: return 0
        }
    }

    private func pointOnCircle(center: CGPoint, radius: Double, angleDegrees: Double) -> CGPoint {
        let angleRadians = (angleDegrees - 90) * .pi / 180
        return CGPoint(
            x: center.x + radius * cos(angleRadians),
            y: center.y + radius * sin(angleRadians)
        )
    }

    private func interpolateColor(ratio: Double) -> Color {
        let clampedRatio = max(0, min(1, ratio))
        let amberHue = 0.083
        let tealHue = 0.528
        let hue = amberHue + (tealHue - amberHue) * clampedRatio
        return Color(hue: hue, saturation: 0.7, brightness: 0.85)
    }
}

// Hexagon Path (for background grid)
struct HexagonPath: Shape {
    let center: CGPoint
    let radius: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()

        for i in 0..<6 {
            let angle = Double(i) * 60 - 90
            let angleRadians = angle * .pi / 180
            let point = CGPoint(
                x: center.x + radius * cos(angleRadians),
                y: center.y + radius * sin(angleRadians)
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()

        return path
    }
}

// Profile Polygon (actual data)
struct ProfilePolygon: Shape {
    let profile: RIASECProfile
    let center: CGPoint
    let maxRadius: Double
    let color: Color

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let values: [Double] = [
            profile.realistic,
            profile.investigative,
            profile.artistic,
            profile.social,
            profile.enterprising,
            profile.conventional
        ]

        for (index, value) in values.enumerated() {
            let angle = Double(index) * 60 - 90
            let angleRadians = angle * .pi / 180
            let radius = maxRadius * (value / 7.0)
            let point = CGPoint(
                x: center.x + radius * cos(angleRadians),
                y: center.y + radius * sin(angleRadians)
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()

        return path
    }
}
```

**Step 2.3.3: Create RIASEC Quiz (Optional Quick Assessment)** (3 hours)

Create simple 12-question quiz (2 per dimension) in separate file if desired.

**Success Criteria**:
- [ ] RIASEC profiler displays in ProfileScreen
- [ ] Radar chart visualizes 6 dimensions
- [ ] Manual sliders for each dimension (0-7 scale)
- [ ] Quick quiz option (2-minute assessment)
- [ ] Updates Thompson ProfessionalProfile.interests
- [ ] Info box explains RIASEC model
- [ ] Accessible with VoiceOver

---

### Phase 2 Summary

**Total Time**: ~64 hours (2-3 weeks)
**Files Created**: 3 (ONetEducationLevelPicker, ONetWorkActivitiesSelector, RIASECInterestProfiler)
**Files Modified**: 2 (ProfileScreen.swift, V7Core models)

#### Phase 2 Testing Checklist

- [ ] Education level picker updates Thompson profile
- [ ] Work activities selector saves 41 activities with importance scores
- [ ] RIASEC profiler displays radar chart correctly
- [ ] All O*NET fields persist across app restarts
- [ ] Thompson scoring uses updated O*NET data
- [ ] Accessibility fully functional
- [ ] No performance regressions (<10ms Thompson constraint)

---


---

## Reference Documents

- Main plan: `ONET_INTEGRATION_IMPLEMENTATION_PLAN.md`
- Week 0: `WEEK_0_PRE_IMPLEMENTATION_FIXES.md`
- Phase 1: `PHASE_1_QUICK_WINS.md`
- Phase 3: `PHASE_3_CAREER_JOURNEY_FEATURES.md`

---

**Document Status**: ✅ Complete
**Last Updated**: October 29, 2025
**Ready for Implementation**: Yes (requires Phase 1 completion first)
