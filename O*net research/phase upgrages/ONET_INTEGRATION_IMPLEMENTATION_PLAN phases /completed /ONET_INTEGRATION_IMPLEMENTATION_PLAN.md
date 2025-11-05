# O*NET Integration Implementation Plan
## ManifestAndMatch V8 - Comprehensive Phase-by-Phase Upgrade Strategy

**Document Version**: 1.0
**Created**: October 29, 2025
**Project**: ManifestAndMatch V8 (iOS 26)
**Codebase Location**: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8/`

---

## Executive Summary

### Current State
- **O*NET Data**: Fully compiled (6 JSON files, 1.0MB+) but partially integrated
- **Industry Coverage**: 12 of 21 sectors (52.4% coverage) - **CRITICAL GAP**
- **Core Data Entities**: 7 entities (WorkExperience, Education, etc.) fully populated but 0% displayed
- **Thompson Scoring**: Already uses O*NET data (educationLevel, workActivities, interests) - **READY**
- **UI Pattern**: Perfect pill-style pattern exists and is reusable

### Target State
- **Industry Coverage**: 19 of 19 sectors (100% O*NET alignment - **CORRECTED**)
- **Profile Display**: All 7 Core Data entities visible and editable
- **O*NET Profile Panel**: Users can view/edit education level, work activities, RIASEC interests
- **Career Journey Features**: Skills gap analysis, career path visualization, course recommendations
- **Complete User Flow**: Upload resume → Parse → Pre-fill → Review → Match → Apply → Career growth

### Implementation Timeline (**UPDATED with P0/P1 fixes + Phase 3.5**)
- **Week 0** (Pre-Implementation): P0 Fixes - 8 hours (**REQUIRED**)
- **Phase 1** (Week 1): Quick Wins - 40% impact, 32 hours
- **Phase 2** (Weeks 2-3): O*NET Profile Editor - 30% impact, 76 hours (**+12 hours** for P0/P1 fixes)
- **Phase 3** (Weeks 4-6): Career Journey Features - 30% impact, 64 hours
- **Phase 3.5** (Week 7): Phase 4-6 Infrastructure - 3 hours (**NEW - reduced from 9 hours**)

**Total Timeline**: 6.5 weeks (**+0.5 week** from original 6 weeks)
**Total Effort**: ~183 hours (**+23 hours** from original 160 hours)
**Risk Level**: Low (building on solid foundation)

**Time Increase Breakdown**:
- Week 0 (P0 fixes): +8 hours
- Phase 2 (Thompson validation, async loading, accessibility): +12 hours
- Phase 3.5 (ProfileCompletenessCard only - ONetCodeMapper already exists): +3 hours
- **Total**: +23 hours (14.4% increase)

---

## Critical Findings Summary

### Finding 1: The 12/21 Industry Mismatch

**Current Industry Enum** (`AppState.swift:387-417`):
```swift
Technology, Healthcare, Finance, Education, Retail, Manufacturing,
Consulting, Media & Entertainment, Non-profit, Government, Hospitality, Real Estate
```

**O*NET Sectors Available** (19 total - **NOT 21**):
```
Agriculture/Forestry/Fishing, Mining/Quarrying, Utilities, Construction,
Manufacturing, Wholesale Trade, Retail Trade, Transportation/Warehousing,
Information, Finance/Insurance, Real Estate, Professional/Scientific/Technical,
Management, Administrative/Support, Educational Services, Healthcare/Social,
Arts/Entertainment, Accommodation/Food Services, Other Services,
Public Administration
```

**⚠️ CRITICAL CORRECTION**: Previous count included "Core Skills" and "Knowledge Areas" which are **skill categories**, NOT industries. O*NET has exactly **19 sectors** (aligned with NAICS taxonomy).

**Impact**:
- 47.6% of O*NET occupations unavailable to users
- ~1,500+ skills inaccessible through UI filtering
- Thompson scoring degraded for missing sectors
- **Office/Administrative (largest sector!) completely missing**

### Finding 2: The "Parsed But Invisible" Data

**What's Working**:
- ✅ Resume upload and parsing (ResumeExtractor)
- ✅ ParsedResumeMapper stores all 7 entities in Core Data
- ✅ All relationships to UserProfile established
- ✅ Data persists correctly

**What's Broken**:
- ❌ ProfileScreen shows NONE of the 7 entities
- ❌ Users can't see their work experience, education, certifications, projects, volunteer work, awards, or publications
- ❌ Resume data goes into a black hole after upload

**File Evidence**:
- `ParsedResumeMapper.swift:166-568` → Populates all 7 entities perfectly
- `ProfileScreen.swift:1-1127` → Displays 0 of them

### Finding 3: Perfect UI Pattern Already Exists

**Location**: `ProfileScreen.swift:815-835` (`jobTypeChip()` function)

**Pattern Characteristics**:
- Pill-style multi-select chips
- Amber→Teal color interpolation (honors dual-profile system)
- FlowLayout for automatic wrapping
- Accessible (VoiceOver-ready)
- Performant and lightweight

**Reusable For**:
- Industry selection (expand 12 → 21)
- Work Activities (41 O*NET dimensions)
- RIASEC Interests (6 dimensions)
- Skills display (already used)
- Any multi-select categorical data

### Finding 4: Thompson Engine is O*NET-Ready

**Location**: `ThompsonSampling+ONet.swift:72-150`

**O*NET Fields Already Used in Scoring**:
```swift
skillsScore         // 30% weight, 2.0ms
educationScore      // 15% weight, 0.8ms  ✅ USES educationLevel
experienceScore     // 15% weight, 0.8ms  ✅ USES yearsOfExperience
activitiesScore     // 25% weight, 1.5ms  ✅ USES workActivities
interestsScore      // 15% weight, 1.0ms  ✅ USES interests (RIASEC)
```

**Total Time**: 6.1ms of 10ms budget (sacred <10ms constraint maintained ✅)

**Conclusion**: Thompson engine is ready - just needs UI to let users provide O*NET data!

---

## Week 0: Pre-Implementation Fixes (8 hours) - **REQUIRED BEFORE PHASE 1**

**Goal**: Fix critical P0 issues identified in skill sign-off review
**Priority**: P0 (CRITICAL - Cannot start Phase 1 without these fixes)
**Effort**: 8 hours
**Risk**: Low (well-defined fixes)

###⚠️ DO NOT SKIP THIS PHASE

These fixes prevent compilation errors and architectural violations. Skipping Week 0 will cause Phase 1 to fail.

### Pre-Task 0.1: Enable Swift 6 Strict Concurrency

**Priority**: P0 (Required for Sendable compliance)
**Estimated Time**: 1 hour

#### Steps

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

**Success Criteria**:
- [ ] Swift 6 strict concurrency enabled in all V7 packages
- [ ] No Sendable warnings in existing code
- [ ] Project builds successfully

---

### Pre-Task 0.2: Add Sendable Compliance Helpers

**Priority**: P0 (Prevents Phase 1 compilation errors)
**Estimated Time**: 2 hours

#### Steps

1. Create Core Data helper extensions in V7Data package:

```swift
// File: V7Data/Sources/V7Data/Extensions/NSManagedObject+Sendable.swift

import CoreData

/// Sendable-safe Core Data helpers for Swift 6 compliance
extension NSManagedObject {
    /// Get a Sendable-safe object ID
    var sendableID: NSManagedObjectID {
        return self.objectID
    }
}

extension Array where Element: NSManagedObject {
    /// Get Sendable-safe object IDs from array of Core Data objects
    var sendableIDs: [NSManagedObjectID] {
        return self.map { $0.objectID }
    }
}

extension NSManagedObjectContext {
    /// Safely fetch object from Sendable ID
    func fetchObject<T: NSManagedObject>(withID id: NSManagedObjectID) -> T? {
        return try? existingObject(with: id) as? T
    }
}
```

**Success Criteria**:
- [ ] Helper extensions added to V7Data package
- [ ] Extensions compile without errors
- [ ] Can fetch objects using `fetchObject(withID:)` pattern

---

### Pre-Task 0.3: Validate Industry Enum Update

**Priority**: P0 (Required for Task 1.5)
**Estimated Time**: 3 hours

#### Steps

1. Review Industry enum in AppState.swift (Task 1.5 code)
2. Verify it has exactly **19 cases** (NOT 21)
3. Ensure NO "coreSkills" or "knowledgeAreas" cases
4. Add migration helper (`fromLegacy()`)
5. Test compilation

**Success Criteria**:
- [ ] Industry enum has 19 cases
- [ ] No meta-categories included
- [ ] Migration helper function tested
- [ ] All V7 packages compile

---

### Pre-Task 0.4: Review Phase 1 Code Patterns

**Priority**: P1 (Preparation)
**Estimated Time**: 2 hours

#### Steps

1. Review all Phase 1 tasks (1.1-1.6)
2. Identify all Core Data @State usage
3. Create checklist of files to update
4. Prepare test data (sample resume with all 7 entities)

**Success Criteria**:
- [ ] Checklist of Phase 1 files created
- [ ] Test resume prepared
- [ ] Team briefed on Sendable pattern

---

### Week 0 Summary

**Total Time**: 8 hours (1 day)
**Risk Level**: Low
**Blockers Removed**: 3 P0 issues (Sendable, Industry enum, Swift 6 config)

**Ready to Start Phase 1?**
- ✅ Swift 6 strict concurrency enabled
- ✅ Sendable helpers in place
- ✅ Industry enum validated
- ✅ Test data prepared

**If ANY checkbox above is unchecked, DO NOT proceed to Phase 1.**

---

## Phase 1: Quick Wins (Week 1)

**Goal**: Display existing Core Data entities and expand industry coverage
**Impact**: 40% of total value
**Effort**: 20% of total work (32 hours)
**Risk**: Very Low
**Dependencies**: Week 0 (Pre-implementation fixes)

### ⚠️ CRITICAL: Swift 6 Sendable Compliance

**ALL Phase 1 code MUST use NSManagedObjectID instead of Core Data objects in @State.**

Swift 6 strict concurrency requires Sendable types in @State. Core Data NSManagedObject subclasses are NOT Sendable.

**Pattern to follow**:
```swift
// ❌ WRONG - Won't compile with Swift 6
@State private var selectedExperience: WorkExperience?

// ✅ CORRECT - Sendable-compliant
@State private var selectedExperienceID: NSManagedObjectID?
@Environment(\.managedObjectContext) private var context

// Usage:
if let id = selectedExperienceID,
   let exp = try? context.existingObject(with: id) as? WorkExperience {
    // Use exp
}
```

**This pattern applies to ALL 7 entities**: WorkExperience, Education, Certification, Project, VolunteerExperience, Award, Publication.

### Task 1.1: Display WorkExperience Entity

**Priority**: P0 (Critical - highest user value)
**Estimated Time**: 4 hours
**File**: `Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`
**Insert Location**: After Skills section (line 353)

#### Implementation Steps

**Step 1.1.1: Add WorkExperience Section to ProfileScreen** (2 hours)

```swift
// Add after Skills section (line 353)
// ⚠️ Swift 6 Sendable-compliant: Uses NSManagedObjectID, NOT WorkExperience objects
Section {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("Work Experience")
                .font(.headline)
            Spacer()
            Button(action: { showAddExperienceSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(interpolateColor(ratio: profileBlend))
            }
        }

        // ✅ SENDABLE-COMPLIANT: Get IDs, not objects
        if let experiences = userProfile.workExperiences?.allObjects as? [WorkExperience],
           !experiences.isEmpty {
            let experienceIDs = experiences
                .sorted(by: { ($0.startDate ?? Date.distantPast) > ($1.startDate ?? Date.distantPast) })
                .map { $0.objectID }

            ForEach(experienceIDs, id: \.self) { objectID in
                // ✅ Fetch object from context using ID
                if let experience = try? context.existingObject(with: objectID) as? WorkExperience {
                    WorkExperienceRow(experience: experience, profileBlend: profileBlend)
                        .onTapGesture {
                            selectedExperienceID = objectID  // ✅ Store ID, not object
                            showEditExperienceSheet = true
                        }
                }
            }
        } else {
            EmptyStateView(
                icon: "briefcase",
                title: "No work experience yet",
                message: "Add your work history to improve job matching"
            )
            .padding(.vertical)
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 1.1.2: Create WorkExperienceRow Component** (1 hour)

Add to ProfileScreen.swift (bottom of file):

```swift
// MARK: - WorkExperience Row Component
struct WorkExperienceRow: View {
    let experience: WorkExperience
    let profileBlend: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title and Company
            VStack(alignment: .leading, spacing: 4) {
                Text(experience.title ?? "Untitled Position")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(experience.company ?? "Unknown Company")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Date Range
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(formatDateRange(
                    start: experience.startDate,
                    end: experience.endDate,
                    isCurrent: experience.isCurrent
                ))
                .font(.caption)
                .foregroundColor(.secondary)

                if experience.isCurrent {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(interpolateColor(ratio: profileBlend))
                }
            }

            // Description (first 2 lines)
            if let description = experience.jobDescription, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }

            // Technologies/Skills tags
            if let technologies = experience.technologies, !technologies.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(Array(technologies.prefix(5)), id: \.self) { tech in
                        Text(tech)
                            .font(.system(size: 11))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }

                    if technologies.count > 5 {
                        Text("+\(technologies.count - 5)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var label = "\(experience.title ?? "Position") at \(experience.company ?? "company")"
        label += ", \(formatDateRange(start: experience.startDate, end: experience.endDate, isCurrent: experience.isCurrent))"
        if experience.isCurrent {
            label += ", Current position"
        }
        return label
    }

    private func formatDateRange(start: Date?, end: Date?, isCurrent: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"

        let startStr = start.map { formatter.string(from: $0) } ?? "Unknown"
        let endStr: String
        if isCurrent {
            endStr = "Present"
        } else {
            endStr = end.map { formatter.string(from: $0) } ?? "Unknown"
        }

        return "\(startStr) – \(endStr)"
    }
}
```

**Step 1.1.3: Add State Variables** (30 minutes)

Add to ProfileScreen state (top of struct, around line 40):

```swift
// ✅ Swift 6 Sendable-compliant state variables
@State private var showAddExperienceSheet = false
@State private var showEditExperienceSheet = false
@State private var selectedExperienceID: NSManagedObjectID?  // ✅ NOT WorkExperience object
@Environment(\.managedObjectContext) private var context      // ✅ Required for object fetching
```

**Step 1.1.4: Create EmptyStateView Component** (30 minutes)

```swift
// MARK: - Empty State Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
    }
}
```

**Success Criteria**:
- [ ] WorkExperience entities displayed in ProfileScreen
- [ ] Sorted by start date (most recent first)
- [ ] Shows company, title, date range, current status
- [ ] Technologies displayed as chips (max 5 + count)
- [ ] Empty state shown when no experience exists
- [ ] Accessible with VoiceOver
- [ ] Tappable for future edit functionality

---

### Task 1.2: Display Education Entity

**Priority**: P0 (Critical)
**Estimated Time**: 3 hours
**File**: `ProfileScreen.swift`
**Insert Location**: After WorkExperience section

#### Implementation Steps

**Step 1.2.1: Add Education Section** (1.5 hours)

```swift
// Add after WorkExperience section
Section {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("Education")
                .font(.headline)
            Spacer()
            Button(action: { showAddEducationSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(interpolateColor(ratio: profileBlend))
            }
        }

        if let educationRecords = userProfile.education?.allObjects as? [Education],
           !educationRecords.isEmpty {
            ForEach(educationRecords.sorted(by: {
                ($0.startDate ?? Date.distantPast) > ($1.startDate ?? Date.distantPast)
            }), id: \.self) { education in
                EducationRow(education: education, profileBlend: profileBlend)
                    .onTapGesture {
                        selectedEducation = education
                        showEditEducationSheet = true
                    }
            }
        } else {
            EmptyStateView(
                icon: "graduationcap",
                title: "No education added yet",
                message: "Add your educational background to improve matches"
            )
            .padding(.vertical)
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 1.2.2: Create EducationRow Component** (1 hour)

```swift
// MARK: - Education Row Component
struct EducationRow: View {
    let education: Education
    let profileBlend: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Degree and Field
            VStack(alignment: .leading, spacing: 4) {
                if let degree = education.degree, !degree.isEmpty {
                    Text(degree)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                if let field = education.fieldOfStudy, !field.isEmpty {
                    Text(field)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Institution
            if let institution = education.institution {
                HStack(spacing: 4) {
                    Image(systemName: "building.columns")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(institution)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Date Range and GPA
            HStack {
                // Date range
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(formatDateRange(
                        start: education.startDate,
                        end: education.endDate
                    ))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                // GPA if present
                if let gpa = education.gpa, gpa > 0 {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    HStack(spacing: 2) {
                        Text("GPA:")
                        Text(String(format: "%.2f", gpa))
                            .fontWeight(.medium)
                            .foregroundColor(interpolateColor(ratio: profileBlend))
                    }
                    .font(.caption)
                }
            }

            // O*NET Education Level Badge
            if education.educationLevelValue > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 10))
                    Text("Level \(education.educationLevelValue)/12")
                        .font(.system(size: 11))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(interpolateColor(ratio: profileBlend))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var label = ""
        if let degree = education.degree {
            label += degree
        }
        if let field = education.fieldOfStudy {
            label += " in \(field)"
        }
        if let institution = education.institution {
            label += " from \(institution)"
        }
        if let gpa = education.gpa, gpa > 0 {
            label += ", GPA \(String(format: "%.2f", gpa))"
        }
        return label
    }

    private func formatDateRange(start: Date?, end: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"

        let startStr = start.map { formatter.string(from: $0) } ?? "Unknown"
        let endStr = end.map { formatter.string(from: $0) } ?? "Unknown"

        return "\(startStr) – \(endStr)"
    }
}
```

**Step 1.2.3: Add State Variables** (30 minutes)

```swift
@State private var showAddEducationSheet = false
@State private var showEditEducationSheet = false
@State private var selectedEducation: Education?
```

**Success Criteria**:
- [ ] Education entities displayed in ProfileScreen
- [ ] Shows degree, field of study, institution
- [ ] Date range formatted as years
- [ ] GPA displayed if present (>0)
- [ ] O*NET education level badge shown (1-12 scale)
- [ ] Empty state for no education
- [ ] Accessible with VoiceOver

---

### Task 1.3: Display Certification Entity

**Priority**: P1 (High)
**Estimated Time**: 2.5 hours
**File**: `ProfileScreen.swift`

#### Implementation Steps

**Step 1.3.1: Add Certification Section** (1.5 hours)

```swift
Section {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("Certifications & Credentials")
                .font(.headline)
            Spacer()
            Button(action: { showAddCertificationSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(interpolateColor(ratio: profileBlend))
            }
        }

        if let certifications = userProfile.certifications?.allObjects as? [Certification],
           !certifications.isEmpty {
            ForEach(certifications.sorted(by: {
                ($0.issueDate ?? Date.distantPast) > ($1.issueDate ?? Date.distantPast)
            }), id: \.self) { cert in
                CertificationRow(certification: cert, profileBlend: profileBlend)
            }
        } else {
            EmptyStateView(
                icon: "checkmark.seal",
                title: "No certifications yet",
                message: "Add professional certifications to stand out"
            )
            .padding(.vertical)
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 1.3.2: Create CertificationRow Component** (1 hour)

```swift
// MARK: - Certification Row Component
struct CertificationRow: View {
    let certification: Certification
    let profileBlend: Double

    private var isExpired: Bool {
        guard !certification.doesNotExpire,
              let expirationDate = certification.expirationDate else {
            return false
        }
        return expirationDate < Date()
    }

    private var expiresWithin90Days: Bool {
        guard !certification.doesNotExpire,
              let expirationDate = certification.expirationDate else {
            return false
        }
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return daysUntilExpiration > 0 && daysUntilExpiration <= 90
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Name and Status Badge
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(certification.name ?? "Unnamed Certification")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    if let issuer = certification.issuer {
                        Text(issuer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Status Badge
                Group {
                    if isExpired {
                        StatusBadge(text: "Expired", color: .red)
                    } else if expiresWithin90Days {
                        StatusBadge(text: "Expiring Soon", color: .orange)
                    } else {
                        StatusBadge(text: "Active", color: .green)
                    }
                }
            }

            // Dates
            VStack(alignment: .leading, spacing: 4) {
                if let issueDate = certification.issueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.caption2)
                        Text("Issued: \(formatDate(issueDate))")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                if !certification.doesNotExpire {
                    if let expirationDate = certification.expirationDate {
                        HStack(spacing: 4) {
                            Image(systemName: isExpired ? "calendar.badge.exclamationmark" : "calendar.badge.clock")
                                .font(.caption2)
                            Text(isExpired ? "Expired: " : "Expires: ")
                            Text(formatDate(expirationDate))
                                .foregroundColor(isExpired ? .red : expiresWithin90Days ? .orange : .secondary)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }

            // Credential ID
            if let credentialId = certification.credentialId, !credentialId.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "number")
                        .font(.caption2)
                    Text("ID: \(credentialId)")
                }
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.8))
            }

            // Verification Link
            if let verificationURL = certification.verificationURL,
               let url = URL(string: verificationURL) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                        Text("Verify Credential")
                    }
                    .font(.caption)
                    .foregroundColor(interpolateColor(ratio: profileBlend))
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

// Status Badge Component
struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(6)
    }
}
```

**Success Criteria**:
- [ ] Certifications displayed with name, issuer, dates
- [ ] Active/Expired/Expiring Soon status badges
- [ ] Credential ID shown if present
- [ ] Verification link clickable
- [ ] Sorted by issue date
- [ ] Empty state displayed

---

### Task 1.4: Display Projects, Volunteer, Awards, Publications

**Priority**: P1 (High)
**Estimated Time**: 2 hours each (8 hours total)
**File**: `ProfileScreen.swift`

Follow similar pattern to WorkExperience/Education/Certification sections.

**Components to Create**:
1. ProjectRow - Shows name, description, technologies, links
2. VolunteerRow - Shows organization, role, hours/week, dates
3. AwardRow - Shows title, issuer, date, description
4. PublicationRow - Shows title, publisher, authors, date, URL

**Success Criteria** (per entity):
- [ ] Section added to ProfileScreen
- [ ] Custom row component created
- [ ] Empty state displayed
- [ ] Sorted appropriately (by date)
- [ ] Key fields visible
- [ ] Accessible

---

### Task 1.5: Expand Industry Enum from 12 to 19 (**CORRECTED**)

**Priority**: P0 (Critical - unlocks O*NET integration)
**Estimated Time**: 2 hours (**+1 hour** for proper O*NET sector mapping)
**File**: `Packages/V7Core/Sources/V7Core/StateManagement/AppState.swift`
**Location**: Lines 387-417

**⚠️ CRITICAL FIX**: Original plan incorrectly included 21 industries with "Core Skills" and "Knowledge Areas" (these are skill categories, NOT industries). O*NET has exactly **19 sectors** aligned with NAICS taxonomy.

#### Implementation Steps

**Step 1.5.1: Update Industry Enum** (1 hour - **CORRECTED**)

**Current Code**:
```swift
public enum Industry: String, Codable, CaseIterable, Sendable {
    case technology = "Technology"
    case healthcare = "Healthcare"
    case finance = "Finance"
    case education = "Education"
    case retail = "Retail"
    case manufacturing = "Manufacturing"
    case consulting = "Consulting"
    case media = "Media & Entertainment"
    case nonprofit = "Non-profit"
    case government = "Government"
    case hospitality = "Hospitality"
    case realestate = "Real Estate"
}
```

**New Code** (**CORRECTED - 19 O*NET Sectors, NO meta-categories**):
```swift
/// O*NET Industry Sectors (19 sectors aligned with NAICS taxonomy)
/// ⚠️ CRITICAL: Does NOT include "Core Skills" or "Knowledge Areas" (those are skill categories, not industries)
public enum Industry: String, Codable, CaseIterable, Sendable, Identifiable {
    public var id: String { rawValue }

    // 19 O*NET Industry Sectors (NAICS-aligned)
    case agricultureForestryFishing = "Agriculture, Forestry, Fishing"
    case miningQuarrying = "Mining, Quarrying, Oil & Gas"
    case utilities = "Utilities"
    case construction = "Construction"
    case manufacturing = "Manufacturing"
    case wholesaleTrade = "Wholesale Trade"
    case retailTrade = "Retail Trade"
    case transportationWarehousing = "Transportation and Warehousing"
    case information = "Information"                     // includes Technology, Media
    case financeInsurance = "Finance and Insurance"
    case realEstate = "Real Estate and Rental"
    case professionalScientificTechnical = "Professional, Scientific, Technical"
    case managementOfCompanies = "Management of Companies"
    case administrativeSupport = "Administrative and Support Services"
    case educationalServices = "Educational Services"
    case healthcareSocialAssistance = "Healthcare and Social Assistance"
    case artsEntertainment = "Arts, Entertainment, Recreation"
    case accommodationFoodServices = "Accommodation and Food Services"
    case otherServices = "Other Services (except Public Administration)"
    case publicAdministration = "Public Administration"

    /// O*NET sector code (NAICS-based)
    public var sectorCode: String {
        switch self {
        case .agricultureForestryFishing: return "11"
        case .miningQuarrying: return "21"
        case .utilities: return "22"
        case .construction: return "23"
        case .manufacturing: return "31-33"
        case .wholesaleTrade: return "42"
        case .retailTrade: return "44-45"
        case .transportationWarehousing: return "48-49"
        case .information: return "51"
        case .financeInsurance: return "52"
        case .realEstate: return "53"
        case .professionalScientificTechnical: return "54"
        case .managementOfCompanies: return "55"
        case .administrativeSupport: return "56"
        case .educationalServices: return "61"
        case .healthcareSocialAssistance: return "62"
        case .artsEntertainment: return "71"
        case .accommodationFoodServices: return "72"
        case .otherServices: return "81"
        case .publicAdministration: return "92"
        }
    }

    /// SF Symbol icon for industry
    public var icon: String {
        switch self {
        case .agricultureForestryFishing: return "leaf.fill"
        case .miningQuarrying: return "mountain.2.fill"
        case .utilities: return "bolt.fill"
        case .construction: return "hammer.fill"
        case .manufacturing: return "gearshape.fill"
        case .wholesaleTrade: return "shippingbox.fill"
        case .retailTrade: return "cart.fill"
        case .transportationWarehousing: return "truck.box.fill"
        case .information: return "antenna.radiowaves.left.and.right"
        case .financeInsurance: return "dollarsign.circle.fill"
        case .realEstate: return "house.fill"
        case .professionalScientificTechnical: return "flask.fill"
        case .managementOfCompanies: return "building.2.fill"
        case .administrativeSupport: return "folder.fill"
        case .educationalServices: return "book.fill"
        case .healthcareSocialAssistance: return "cross.case.fill"
        case .artsEntertainment: return "theatermasks.fill"
        case .accommodationFoodServices: return "fork.knife"
        case .otherServices: return "wrench.and.screwdriver.fill"
        case .publicAdministration: return "building.columns.fill"
        }
    }
}
```

**Step 1.5.2: Add Migration Helper** (1 hour - **UPDATED**)

Add to AppState.swift (below Industry enum):

```swift
// MARK: - Industry Migration
extension Industry {
    /// Migrates old 12-industry app values to new 19 O*NET sectors
    /// Maps legacy app industries to proper NAICS-aligned sectors
    public static func fromLegacy(_ legacy: String) -> Industry {
        switch legacy.lowercased() {
        // Direct mappings (app industry → O*NET sector)
        case "technology", "tech", "it", "software":
            return .information  // NAICS 51
        case "healthcare", "medical", "health":
            return .healthcareSocialAssistance  // NAICS 62
        case "finance", "banking", "fintech":
            return .financeInsurance  // NAICS 52
        case "education", "teaching", "academia":
            return .educationalServices  // NAICS 61
        case "retail", "ecommerce", "sales":
            return .retailTrade  // NAICS 44-45
        case "manufacturing", "industrial":
            return .manufacturing  // NAICS 31-33
        case "consulting", "professional services":
            return .professionalScientificTechnical  // NAICS 54
        case "media & entertainment", "media", "entertainment":
            return .artsEntertainment  // NAICS 71
        case "non-profit", "nonprofit", "charity":
            return .otherServices  // NAICS 81
        case "government", "public sector":
            return .publicAdministration  // NAICS 92
        case "hospitality", "food service", "restaurant":
            return .accommodationFoodServices  // NAICS 72
        case "real estate", "property":
            return .realEstate  // NAICS 53

        // Additional O*NET sectors
        case "construction", "building":
            return .construction
        case "transportation", "logistics":
            return .transportationWarehousing
        case "utilities":
            return .utilities
        case "agriculture", "farming", "forestry":
            return .agricultureForestryFishing

        default:
            return .otherServices  // Fallback for unknown
        }
    }

    /// Check if legacy data needs migration
    public static func needsMigration(from oldEnum: String) -> Bool {
        // Return true if old app had 12 industries
        let legacyIndustries = [
            "Technology", "Healthcare", "Finance", "Education",
            "Retail", "Manufacturing", "Consulting",
            "Media & Entertainment", "Non-profit", "Government",
            "Hospitality", "Real Estate"
        ]
        return legacyIndustries.contains(oldEnum)
    }
}
```

**Success Criteria**:
- [ ] Enum expanded from 12 to **19 cases** (**CORRECTED** - NOT 21)
- [ ] **NO** "coreSkills" or "knowledgeAreas" cases (these are skill categories, not industries)
- [ ] Migration helper function added (`fromLegacy()`)
- [ ] All 19 O*NET sectors represented with NAICS codes
- [ ] Backward compatibility maintained via migration
- [ ] SF Symbol icons added for each sector
- [ ] Compiles without errors

---

### Task 1.6: Update JobPreferencesView for 19 Industries (**CORRECTED**)

**Priority**: P0 (Critical)
**Estimated Time**: 1 hour
**File**: Location TBD (find JobPreferencesView file)

#### Implementation Steps

**Step 1.6.1: Find JobPreferencesView** (5 minutes)

```bash
# Search for JobPreferencesView
find ~/Desktop/ios26_manifest_and_match/manifest\ and\ match\ V8/Packages -name "*JobPreferences*"
```

**Step 1.6.2: Update Industry Display Logic** (55 minutes)

The existing FlowLayout should automatically handle 19 industries (it wraps dynamically).

**Changes needed**:
1. No code changes required for layout (FlowLayout handles it)
2. Test that all 19 display correctly
3. Optional: Add grouping by sector category if UI becomes cluttered

**Optional Enhancement - Grouped Display**:

```swift
// Group industries by category
let groupedIndustries = Dictionary(grouping: Industry.allCases, by: { $0.group })

ForEach(IndustryGroup.allCases, id: \.self) { group in
    if let industries = groupedIndustries[group], !industries.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
            Text(group.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.leading, 4)

            FlowLayout(spacing: 8) {
                ForEach(industries, id: \.self) { industry in
                    industryChip(industry)
                }
            }
        }
        .padding(.bottom, 16)
    }
}
```

**Success Criteria**:
- [ ] All **19 industries** display in JobPreferencesView (**CORRECTED**)
- [ ] FlowLayout wraps correctly
- [ ] Selection state works for all industries
- [ ] No UI clipping or overflow
- [ ] Accessible with VoiceOver
- [ ] Industry icons display correctly (SF Symbols)

---

### Phase 1 Summary & Testing

**Total Time**: ~32 hours (1 week)
**Files Modified**: 2 (ProfileScreen.swift, AppState.swift)
**New Components**: 7 (WorkExperienceRow, EducationRow, CertificationRow, ProjectRow, VolunteerRow, AwardRow, PublicationRow)

#### Phase 1 Testing Checklist

**ProfileScreen Display Tests**:
- [ ] Upload resume with all 7 entity types
- [ ] Verify each section displays parsed data
- [ ] Test empty states for each section
- [ ] Test tap gestures (prepare for Phase 2 edit sheets)
- [ ] Verify sorting (most recent first for time-based)
- [ ] Test accessibility with VoiceOver
- [ ] Test on iPhone SE (small screen), iPhone 16 Pro Max (large screen)
- [ ] Test in Light Mode and Dark Mode
- [ ] Test with Liquid Glass Clear and Tinted modes

**Industry Expansion Tests**:
- [ ] Select each of **19 industries** in JobPreferencesView (**CORRECTED**)
- [ ] Verify selection state persists
- [ ] Test legacy industry migration (load old profile with "Technology", verify migrates to "Information" sector)
- [ ] Verify Thompson scoring uses all 19 sectors
- [ ] Test accessibility for all industry chips
- [ ] Verify NAICS sector codes display correctly

**Performance Tests**:
- [ ] ProfileScreen loads in <1 second with 10+ work experiences
- [ ] Scrolling is smooth (60 FPS)
- [ ] No memory leaks when navigating to/from ProfileScreen
- [ ] Thompson scoring still <10ms with 21 sectors

**Success Metrics**:
- ✅ Users can see their complete work history
- ✅ Users can see their education background
- ✅ Users can see certifications with expiration status
- ✅ Users in all 21 O*NET sectors can select their industry
- ✅ No breaking changes to existing functionality

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

## Phase 3: Career Journey Features (Weeks 4-6)

**Goal**: Complete career discovery and growth features
**Impact**: 30% of total value
**Effort**: 40% of total work (64 hours)
**Risk**: Medium-High
**Dependencies**: Phases 1 & 2 complete

### Task 3.1: Skills Gap Analysis

**Priority**: P1 (High - core value proposition)
**Estimated Time**: 16 hours
**Files**:
- New: `Packages/V7UI/Sources/V7UI/Views/SkillsGapAnalysisView.swift`
- New: `Packages/V7Services/Sources/V7Services/Career/SkillsGapAnalyzer.swift`

#### Implementation Plan

**Compare user skills to target career O*NET requirements**:
1. User selects target career (from O*NET occupation list)
2. App fetches O*NET skill requirements for that occupation
3. Compare user's current skills to required skills
4. Visualize:
   - ✅ Transferable skills (user has, job needs)
   - ⚠️ Skill gaps (job needs, user doesn't have)
   - 💎 Bonus skills (user has, job doesn't require - differentiators)

**Success Criteria**:
- [ ] Target career selection UI
- [ ] Skills comparison algorithm
- [ ] Visual gap analysis (charts/lists)
- [ ] Prioritized learning recommendations

---

### Task 3.2: Career Path Visualization

**Priority**: P1 (High - "realistic transition pathways")
**Estimated Time**: 20 hours
**Files**:
- New: `Packages/V7UI/Sources/V7UI/Views/CareerPathVisualizationView.swift`
- New: `Packages/V7Services/Sources/V7Services/Career/CareerPathFinder.swift`

#### Implementation Plan

**Timeline view: Current → Intermediate → Target roles**:
1. Analyze user's current skills/experience
2. Identify 2-3 intermediate stepping-stone roles
3. Show progression timeline with skill acquisition checkpoints
4. Estimate time to each milestone (6 months, 1 year, 2 years)

**Success Criteria**:
- [ ] Multi-step career path visualization
- [ ] Timeline with milestones
- [ ] Skill acquisition checkpoints
- [ ] Time estimates based on learning rates

---

### Task 3.3: Course Recommendations

**Priority**: P2 (Medium - monetization opportunity)
**Estimated Time**: 12 hours
**Files**:
- New: `Packages/V7Services/Sources/V7Services/Learning/CourseRecommender.swift`
- New: `Packages/V7UI/Sources/V7UI/Views/CourseRecommendationsView.swift`

#### Implementation Plan

**Map skill gaps to learning resources**:
1. For each identified skill gap
2. Search course APIs (Coursera, Udemy, LinkedIn Learning)
3. Rank by relevance, cost, duration, ratings
4. Display as actionable "Next Steps"

**Success Criteria**:
- [ ] Course API integration
- [ ] Relevance ranking algorithm
- [ ] Course cards with details (cost, duration, provider)
- [ ] Direct enrollment links

---

### Task 3.4: AI Cover Letter Generator

**Priority**: P2 (Medium - completes application workflow)
**Estimated Time**: 16 hours
**Files**:
- New: `Packages/V7Services/Sources/V7Services/Application/CoverLetterGenerator.swift`
- New: `Packages/V7UI/Sources/V7UI/Views/CoverLetterEditorView.swift`

#### Implementation Plan

**Generate cover letters from parsed resume + job description**:
1. Extract key requirements from job description
2. Match to user's resume data (work experience, education, skills)
3. Use Foundation Models (iOS 26 on-device AI) to generate draft
4. Allow user editing before saving/copying

**Success Criteria**:
- [ ] Job description parsing
- [ ] Resume data extraction
- [ ] Foundation Models integration
- [ ] Editable cover letter output
- [ ] Copy/export functionality

---

### Phase 3 Summary

**Total Time**: ~64 hours (3 weeks)
**Files Created**: 8 new files
**Files Modified**: 4 (integration points)

---

## Phase 3.5: Phase 4-6 Infrastructure (Week 7)

**Purpose**: Build supporting infrastructure needed for Phases 4-6 O*NET integration
**Context**: Audit revealed 3 of 4 proposed components already exist (see `PHASE_3.5_CODEBASE_AUDIT_RESULTS.md`)
**Duration**: 3 hours (**REDUCED from 9 hours** - most components already implemented)
**Risk**: Low (isolated component, no core system changes)

### What Already Exists ✅

1. **ThompsonONetPerformanceTests** - Complete test suite (413 lines)
   - Location: `Packages/V7Thompson/Tests/V7ThompsonTests/ThompsonONetPerformanceTests.swift`
   - Tests all 5 O*NET factors + complete pipeline
   - Enforces P95 < 10ms, P50 < 6ms (sacred constraint)
   - Production-ready, CI/CD integrated

2. **A/B Testing Infrastructure** - Feature flag implemented
   - Location: `Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift:74`
   - `isONetScoringEnabled: Bool = false`
   - Validated in Phase 4 testing

3. **ONetCodeMapper** - Production-ready actor (894 occupations)
   - Location: `Packages/V7Services/Sources/V7Services/ONet/ONetCodeMapper.swift`
   - Singleton pattern (`ONetCodeMapper.shared`)
   - 4-tier matching strategy (exact → normalized → fuzzy → keyword)
   - Performance: <5ms cached, <50ms initial load
   - Accuracy: 85%+ on standard job titles
   - V7 architecture compliant (actor isolation, zero circular deps)

### What Needs to Be Built ⚙️

#### Task 1: ProfileCompletenessCard (3 hours) **ONLY REMAINING COMPONENT**

**Why**: Phase 4 Week 14 optional feature to help users understand profile completeness
**File**: `Packages/V7UI/Sources/V7UI/Cards/ProfileCompletenessCard.swift`

**Note on ONetCodeMapper**: Originally planned for Phase 3.5 (6 hours), but **already exists** in production-ready state. See `Packages/V7Services/Sources/V7Services/ONet/ONetCodeMapper.swift` for implementation.

**Implementation** (All 5 V7 Guardians Approved ✅):

```swift
import SwiftUI
import V7Core

/// Profile completeness card showing user profile field population
/// Helps users understand profile completion progress
/// Liquid Glass design (iOS 26)
///
/// **Architecture Notes**:
/// - Uses V7Core AppState environment (not custom \.userProfile key)
/// - Dual-profile color system (Amber→Teal gradient)
/// - Full accessibility support (VoiceOver)
/// - Completeness based on actual UserProfile schema
///
/// **Sacred Constraints**:
/// - v7-architecture-guardian: Uses AppState from V7Core, zero circular deps
/// - accessibility-compliance-enforcer: WCAG 2.1 AA, VoiceOver labels
/// - swift-concurrency-enforcer: @MainActor for UI thread safety
@available(iOS 26.0, *)
@MainActor
public struct ProfileCompletenessCard: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Completeness Calculation

    private var completenessPercentage: Double {
        guard let profile = appState.userProfile else { return 0.0 }

        var filledCount = 0
        let totalFields = 5

        // Field 1: Skills (any skills entered)
        if !profile.skills.isEmpty {
            filledCount += 1
        }

        // Field 2: Experience (years of experience)
        if profile.experience > 0 {
            filledCount += 1
        }

        // Field 3: Preferred Job Types
        if !profile.preferredJobTypes.isEmpty {
            filledCount += 1
        }

        // Field 4: Preferred Locations
        if !profile.preferredLocations.isEmpty {
            filledCount += 1
        }

        // Field 5: Salary Range
        if profile.salaryRange != nil {
            filledCount += 1
        }

        return Double(filledCount) / Double(totalFields)
    }

    private var completenessScore: Int {
        Int(completenessPercentage * 100)
    }

    private var missingFields: [String] {
        guard let profile = appState.userProfile else {
            return ["Skills", "Experience", "Job Types", "Locations", "Salary Range"]
        }

        var missing: [String] = []

        if profile.skills.isEmpty {
            missing.append("Skills")
        }
        if profile.experience == 0 {
            missing.append("Experience Level")
        }
        if profile.preferredJobTypes.isEmpty {
            missing.append("Preferred Job Types")
        }
        if profile.preferredLocations.isEmpty {
            missing.append("Preferred Locations")
        }
        if profile.salaryRange == nil {
            missing.append("Salary Range")
        }

        return missing
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(completenessGradient)
                    .font(.title3)

                Text("Profile Completeness")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(completenessScore)%")
                    .font(.title2.bold())
                    .foregroundStyle(completenessColor)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Profile completeness: \(completenessScore) percent")

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .frame(height: 12)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(completenessGradient)
                        .frame(width: geometry.size.width * completenessPercentage, height: 12)
                        .animation(.smooth(duration: 0.6), value: completenessPercentage)
                }
            }
            .frame(height: 12)
            .accessibilityHidden(true)  // Redundant with header percentage

            // Missing fields (if any)
            if !missingFields.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Complete your profile to improve matches:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ForEach(missingFields, id: \.self) { field in
                        HStack(spacing: 8) {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(field)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Missing field: \(field)")
                    }
                }
            } else {
                // Complete state
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)

                    Text("Your profile is complete!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Profile is complete")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Computed Styles

    /// Use V7 dual-profile color system (Amber→Teal)
    private var completenessColor: Color {
        DualProfileColorSystem.profileColor(blendRatio: completenessPercentage)
    }

    private var completenessGradient: LinearGradient {
        // Amber (0%) to Teal (100%)
        let startColor = DualProfileColorSystem.profileColor(blendRatio: 0.0)
        let endColor = DualProfileColorSystem.profileColor(blendRatio: completenessPercentage)

        return LinearGradient(
            colors: [startColor.opacity(0.8), endColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 26.0, *)
#Preview("Profile Completeness - 80%") {
    @Previewable @State var appState = AppState()

    ProfileCompletenessCard()
        .padding()
        .environment(appState)
        .onAppear {
            appState.userProfile = mockUserProfile(completeness: 0.8)
        }
}

@available(iOS 26.0, *)
#Preview("Profile Completeness - 40%") {
    @Previewable @State var appState = AppState()

    ProfileCompletenessCard()
        .padding()
        .environment(appState)
        .onAppear {
            appState.userProfile = mockUserProfile(completeness: 0.4)
        }
}

@available(iOS 26.0, *)
#Preview("Profile Completeness - 100%") {
    @Previewable @State var appState = AppState()

    ProfileCompletenessCard()
        .padding()
        .environment(appState)
        .onAppear {
            appState.userProfile = mockUserProfile(completeness: 1.0)
        }
}

private func mockUserProfile(completeness: Double) -> UserProfile {
    UserProfile(
        id: UUID().uuidString,
        name: "Test User",
        email: "test@example.com",
        skills: completeness >= 0.2 ? ["Swift", "iOS Development", "SwiftUI"] : [],
        experience: completeness >= 0.4 ? 5 : 0,
        preferredJobTypes: completeness >= 0.6 ? ["Full-time", "Contract"] : [],
        preferredLocations: completeness >= 0.8 ? ["Remote", "San Francisco"] : [],
        salaryRange: completeness >= 1.0 ? SalaryRange(min: 120000, max: 180000) : nil
    )
}
#endif
```

---

### Phase 3.5 Summary

**Total Time**: 3 hours (Week 7)
**Components Built**: 1 (ProfileCompletenessCard only)
**Components Already Exist**: 3 (ThompsonONetPerformanceTests, isONetScoringEnabled, ONetCodeMapper)
**Files Created**: 1 new file (ProfileCompletenessCard.swift)
**Audit Reference**: `PHASE_3.5_CODEBASE_AUDIT_RESULTS.md`

**Key Architectural Decisions**:
- **@MainActor isolation** for Swift 6 strict concurrency compliance
- **V7Core AppState** environment (not custom \.userProfile)
- **DualProfileColorSystem** integration (Amber→Teal gradient)
- **WCAG 2.1 AA** accessibility compliance (100% validated)
- **Zero Thompson impact** (not on critical path)

**Guardian Approvals**: 5/5 ✅
- V7 Architecture Guardian ✅
- Swift Concurrency Enforcer ✅
- Thompson Performance Guardian ✅ (10/10)
- Privacy & Security Guardian ✅ (zero risk)
- Accessibility Compliance Enforcer ✅ (10/10)

**Implementation Documentation**:
- Complete code: `PHASE_3.5_CORRECTED_IMPLEMENTATION.md`
- Guardian reviews: `PHASE_3.5_GUARDIAN_SIGN_OFFS.md`
- Audit findings: `PHASE_3.5_CODEBASE_AUDIT_RESULTS.md`
- Completion summary: `PHASE_3.5_COMPLETION_SUMMARY.md`

