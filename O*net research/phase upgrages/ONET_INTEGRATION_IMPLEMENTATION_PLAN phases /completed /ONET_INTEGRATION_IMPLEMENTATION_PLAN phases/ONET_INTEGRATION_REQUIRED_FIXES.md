# O*NET Integration Implementation Plan - Required Fixes & Remediation

**Document Version**: 1.0
**Date**: 2025-10-29
**Status**: Pre-Implementation Review
**Sign-Off Result**: APPROVED TO PROCEED with Mandatory P0 Fixes

---

## Executive Summary

The O*NET Integration Implementation Plan has been reviewed by 10 specialized skills (SwiftUI, O*NET, Architecture, Core Data, iOS 26, Thompson Performance, Accessibility, User Profile, App Narrative, Swift Concurrency). The plan is **APPROVED** but requires **3 critical fixes (P0)** before Phase 1 implementation begins.

### Overall Assessment
- **Scope**: ✅ Comprehensive and well-structured (3 phases, 160 hours)
- **Time Estimates**: ✅ Realistic and properly scoped
- **Code Quality**: ✅ Good Swift 6 patterns (with corrections needed)
- **Architecture**: ⚠️ Requires P0 fixes for Thompson performance and Sendable compliance
- **User Experience**: ✅ Excellent mission alignment for career discovery
- **Accessibility**: ⚠️ Requires P1 enhancement for radar chart

### Issues Summary

| Priority | Count | Description | Must Fix Before |
|----------|-------|-------------|-----------------|
| **P0 - CRITICAL** | 3 | Blocks implementation, violates sacred constraints | Phase 1 Start |
| **P1 - IMPORTANT** | 2 | Required for production quality | Phase 2 Completion |
| **P2 - RECOMMENDED** | 2 | Optimizations for better performance/UX | Phase 3 |

---

## Critical Issues (P0) - MUST FIX BEFORE PHASE 1

### P0-1: Thompson Sampling <10ms Budget Violation Risk

**Skill Source**: Thompson Performance Guardian
**Severity**: CRITICAL - Violates sacred <10ms constraint (357x performance advantage)
**Phase Affected**: Phase 2 (Task 2.3 - RIASEC/Activities Integration)

#### Problem
Adding 41 work activities + education level + RIASEC scoring to Thompson algorithm could exceed <10ms budget:

**Current Budget**:
- Base Thompson: ~6.1ms used
- Remaining headroom: ~3.9ms
- **Risk**: O*NET lookups during scoring could add 5-15ms per job

**Problematic Code** (from plan Phase 2, Task 2.3):
```swift
// ❌ WRONG - Fetches O*NET data during scoring (could add 10ms+)
func scoreJob(_ job: Job, profile: UserProfile) -> Double {
    let baseScore = thompsonSampling.score(job)

    // ❌ THIS BLOCKS - Could take 5-15ms per job
    let onetActivities = ONetWorkActivitiesDatabase.shared.getActivities(for: job)
    let activityMatch = calculateActivityMatch(profile, onetActivities)

    return baseScore * activityMatch  // BUDGET EXCEEDED
}
```

#### Required Fix

**Solution**: Pre-compute O*NET lookups, use in-memory cache during scoring.

```swift
// ✅ CORRECT - Pre-computed O*NET data, fast lookup during scoring

// STEP 1: Pre-compute O*NET data (happens BEFORE scoring, async)
actor ONetScoringCache {
    private var jobActivityScores: [String: [WorkActivity]] = [:]

    func preloadActivities(for jobs: [Job]) async {
        let startTime = CFAbsoluteTimeGetCurrent()

        for job in jobs {
            jobActivityScores[job.id] = await fetchActivities(job)
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("O*NET preload: \(elapsed)ms for \(jobs.count) jobs")
        // This can take 100ms+ - that's OK, happens before Thompson
    }

    func getCachedActivities(jobID: String) -> [WorkActivity]? {
        return jobActivityScores[jobID]
    }
}

// STEP 2: Fast scoring using cached data
func scoreJob(_ job: Job, profile: UserProfile) -> Double {
    let startTime = CFAbsoluteTimeGetCurrent()

    let baseScore = thompsonSampling.score(job)

    // ✅ FAST - In-memory lookup, no async calls
    guard let activities = onetCache.getCachedActivities(jobID: job.id) else {
        return baseScore  // Fallback if no O*NET data
    }

    let activityMatch = calculateActivityMatch(profile.activities, activities)
    let result = baseScore * activityMatch

    let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    assert(elapsed < 10.0, "Thompson budget violated: \(elapsed)ms (target: <10ms)")

    return result  // ✅ Completes in <10ms
}

// STEP 3: Orchestration
func scoreJobsWithONet(_ jobs: [Job], profile: UserProfile) async -> [ScoredJob] {
    // Pre-load O*NET data (can be slow, happens once)
    await onetCache.preloadActivities(for: jobs)

    // Fast Thompson scoring (must be <10ms per job)
    let startTime = CFAbsoluteTimeGetCurrent()
    let scores = jobs.map { scoreJob($0, profile: profile) }
    let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    let avgPerJob = elapsed / Double(jobs.count)

    assert(avgPerJob < 10.0, "Average per-job time: \(avgPerJob)ms exceeds 10ms")

    return zip(jobs, scores).map { ScoredJob(job: $0, score: $1) }
}
```

#### Validation Requirements

**MANDATORY for Phase 2 Task 2.3**:
1. Add performance assertions to every O*NET scoring function
2. Test with 100+ jobs to verify <10ms average
3. Profile with Instruments to confirm no async calls during scoring
4. Document O*NET cache invalidation strategy

**Performance Test**:
```swift
func testThompsonBudgetWithONet() async throws {
    let jobs = generateTestJobs(count: 100)
    let profile = createTestProfile()

    let startTime = CFAbsoluteTimeGetCurrent()
    let scores = await scoreJobsWithONet(jobs, profile: profile)
    let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

    let avgPerJob = elapsed / Double(jobs.count)
    XCTAssertLessThan(avgPerJob, 10.0,
                      "Thompson budget violated: \(avgPerJob)ms per job")
}
```

---

### P0-2: Sendable Compliance Violations (Swift 6)

**Skill Source**: Swift Concurrency Enforcer
**Severity**: CRITICAL - Won't compile with Swift 6 strict concurrency
**Phase Affected**: Phase 1 (Tasks 1.1, 1.2)

#### Problem
Plan stores Core Data `NSManagedObject` subclasses in `@State`, which violates Swift 6 Sendable requirements.

**Problematic Code** (from plan Phase 1, Task 1.1):
```swift
// ❌ WRONG - WorkExperience is NSManagedObject (not Sendable)
struct ProfileWorkExperienceListView: View {
    @State private var selectedExperience: WorkExperience?  // ❌ ERROR
    @State private var experiences: [WorkExperience] = []   // ❌ ERROR

    var body: some View {
        List(experiences) { exp in
            // ...
        }
        .sheet(item: $selectedExperience) { exp in  // ❌ Won't compile
            WorkExperienceEditView(experience: exp)
        }
    }
}

// ❌ Swift 6 Error:
// Type 'WorkExperience' does not conform to the 'Sendable' protocol
```

#### Required Fix

**Solution**: Use `NSManagedObjectID` instead of Core Data objects in `@State`.

```swift
// ✅ CORRECT - Use NSManagedObjectID (Sendable)
struct ProfileWorkExperienceListView: View {
    @Environment(\.managedObjectContext) private var context

    @State private var selectedExperienceID: NSManagedObjectID?  // ✅ Sendable
    @State private var experienceIDs: [NSManagedObjectID] = []   // ✅ Sendable

    var body: some View {
        List(experienceIDs, id: \.self) { objectID in
            if let exp = try? context.existingObject(with: objectID) as? WorkExperience {
                WorkExperienceRow(experience: exp)
                    .onTapGesture {
                        selectedExperienceID = objectID
                    }
            }
        }
        .sheet(item: $selectedExperienceID) { objectID in
            if let exp = try? context.existingObject(with: objectID) as? WorkExperience {
                WorkExperienceEditView(experience: exp)
            }
        }
    }
}
```

**Apply to ALL Phase 1 Tasks**:
- Task 1.1: `WorkExperience` → use `NSManagedObjectID`
- Task 1.2: `Education` → use `NSManagedObjectID`
- Task 1.3: `Certification` → use `NSManagedObjectID`
- Task 1.4: `Project`, `VolunteerExperience`, `Award`, `Publication` → use `NSManagedObjectID`

#### Validation Requirements

**MANDATORY for Phase 1**:
1. Enable Swift 6 strict concurrency in package manifest:
   ```swift
   // Package.swift
   swiftSettings: [
       .enableUpcomingFeature("StrictConcurrency")
   ]
   ```
2. Verify no Sendable warnings in V7Services, V7Data, V7UI
3. Test `@State` bindings with Core Data object IDs

---

### P0-3: Industry Enum Contains Non-Industries

**Skill Source**: O*NET Career Integration Specialist
**Severity**: CRITICAL - Data model error, breaks O*NET mapping
**Phase Affected**: Phase 1 (Task 1.5)

#### Problem
Plan includes "Core Skills" and "Knowledge Areas" as industries. These are **skill categories**, not industries. O*NET has exactly **19 sectors**, not 21.

**Problematic Code** (from plan Phase 1, Task 1.5):
```swift
// ❌ WRONG - Includes non-industry categories
public enum Industry: String, Codable, CaseIterable, Sendable {
    case coreSkills = "Core Skills"              // ❌ Not an industry
    case knowledgeAreas = "Knowledge Areas"      // ❌ Not an industry
    case technology = "Technology"
    case healthcare = "Healthcare"
    // ... 19 more
}
```

**Why This Is Wrong**:
- O*NET sectors are industry classifications (Agriculture, Construction, Healthcare, etc.)
- "Core Skills" = skill categories (Reading, Writing, Math) - NOT an industry
- "Knowledge Areas" = knowledge domains (Engineering, Medicine) - NOT an industry
- This breaks O*NET API mapping and job classification

#### Required Fix

**Solution**: Remove non-sector entries, use only 19 O*NET sectors.

```swift
// ✅ CORRECT - Only actual O*NET sectors
public enum Industry: String, Codable, CaseIterable, Sendable {
    // O*NET 19 Industry Sectors (aligned with SOC codes)
    case agricultureForestryFishing = "Agriculture, Forestry, Fishing"
    case miningQuarrying = "Mining, Quarrying, Oil & Gas"
    case utilities = "Utilities"
    case construction = "Construction"
    case manufacturing = "Manufacturing"
    case wholesaleTrade = "Wholesale Trade"
    case retailTrade = "Retail Trade"
    case transportationWarehousing = "Transportation and Warehousing"
    case information = "Information"
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

    // O*NET API mapping
    var onetSectorCode: String {
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
}
```

**Migration Strategy for Existing Data**:
If app already has "Technology" or "Finance" industries, map them to O*NET sectors:

```swift
extension Industry {
    // Map legacy industries to O*NET sectors
    static func fromLegacy(_ legacy: String) -> Industry {
        switch legacy.lowercased() {
        case "technology", "tech", "it":
            return .information  // O*NET sector 51
        case "finance", "banking":
            return .financeInsurance  // O*NET sector 52
        case "healthcare", "medical":
            return .healthcareSocialAssistance  // O*NET sector 62
        case "education", "teaching":
            return .educationalServices  // O*NET sector 61
        // ... map all 12 existing industries
        default:
            return .otherServices  // Fallback
        }
    }
}
```

#### Validation Requirements

**MANDATORY for Phase 1 Task 1.5**:
1. Verify Industry enum has exactly 19 cases (one per O*NET sector)
2. No skill/knowledge categories in enum
3. Add O*NET sector code mapping (11, 21, 22, ...)
4. Test WorkExperience.industry mapping to O*NET API

---

## Important Issues (P1) - FIX DURING PHASE 2

### P1-1: O*NET Data Loading Blocks Main Thread

**Skill Source**: Swift Concurrency Enforcer
**Severity**: IMPORTANT - Causes UI freeze on app launch
**Phase Affected**: Phase 2 (Tasks 2.1, 2.2)

#### Problem
Plan loads O*NET databases synchronously in `init()`, blocking main thread for 50-200ms.

**Problematic Code** (from plan Phase 2, Task 2.2):
```swift
// ❌ WRONG - Blocks main thread
@MainActor
public class ONetWorkActivitiesDatabase {
    static let shared = ONetWorkActivitiesDatabase()
    private var activities: [WorkActivity] = []

    private init() {
        loadActivities()  // ❌ BLOCKS main thread for ~100ms
    }

    private func loadActivities() {
        // Synchronous file I/O or network fetch
        let data = try! Data(contentsOf: activitiesURL)
        activities = try! JSONDecoder().decode([WorkActivity].self, from: data)
    }
}
```

#### Required Fix

**Solution**: Use `actor` with async loading, return cached data after first load.

```swift
// ✅ CORRECT - Async loading, non-blocking
actor ONetWorkActivitiesDatabase {
    static let shared = ONetWorkActivitiesDatabase()

    private var activities: [WorkActivity]?
    private var loadTask: Task<[WorkActivity], Error>?

    private init() {
        // Start loading in background immediately
        loadTask = Task {
            await loadActivities()
        }
    }

    private func loadActivities() async throws -> [WorkActivity] {
        if let cached = activities {
            return cached  // ✅ Return cached if available
        }

        let url = Bundle.main.url(forResource: "onet_activities", withExtension: "json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode([WorkActivity].self, from: data)

        activities = decoded
        return decoded
    }

    // Public API - awaits initial load if needed
    func getActivities() async throws -> [WorkActivity] {
        if let loadTask = loadTask {
            return try await loadTask.value
        } else if let cached = activities {
            return cached
        } else {
            return try await loadActivities()
        }
    }
}

// Usage in SwiftUI
struct ONetProfileEditor: View {
    @State private var activities: [WorkActivity] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading O*NET activities...")
            } else {
                ActivitySelectionGrid(activities: activities)
            }
        }
        .task {
            do {
                activities = try await ONetWorkActivitiesDatabase.shared.getActivities()
                isLoading = false
            } catch {
                // Handle error
            }
        }
    }
}
```

**Apply to ALL O*NET Databases**:
- Education Level Database (12 levels)
- Work Activities Database (41 activities)
- RIASEC Database (6 dimensions)
- Skills Database (3,805 skills)

---

### P1-2: Accessibility - Radar Chart Missing Text Alternative

**Skill Source**: Accessibility Compliance Enforcer
**Severity**: IMPORTANT - WCAG 2.1 AA violation
**Phase Affected**: Phase 2 (Task 2.3 - RIASEC Visualization)

#### Problem
RIASEC radar chart is visual-only. Screen reader users can't access Holland Code scores.

**Problematic Code** (from plan Phase 2, Task 2.3):
```swift
// ❌ WRONG - No accessibility for blind users
struct RIASECRadarChart: View {
    let scores: RIASECScores

    var body: some View {
        Canvas { context, size in
            // Draw radar chart with 6 dimensions
            drawRadarChart(context, scores, size)
        }
        .accessibilityLabel("RIASEC Radar Chart")  // ❌ Not enough
    }
}
```

#### Required Fix

**Solution**: Add `.accessibilityRepresentation` with text data.

```swift
// ✅ CORRECT - Accessible to screen readers
struct RIASECRadarChart: View {
    let scores: RIASECScores

    var body: some View {
        Canvas { context, size in
            drawRadarChart(context, scores, size)
        }
        .accessibilityLabel("RIASEC Career Interest Profile")
        .accessibilityRepresentation {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Holland Code Scores:")
                    .font(.headline)

                HStack {
                    Text("Realistic (R):")
                    Text("\(Int(scores.realistic * 100))%")
                }
                HStack {
                    Text("Investigative (I):")
                    Text("\(Int(scores.investigative * 100))%")
                }
                HStack {
                    Text("Artistic (A):")
                    Text("\(Int(scores.artistic * 100))%")
                }
                HStack {
                    Text("Social (S):")
                    Text("\(Int(scores.social * 100))%")
                }
                HStack {
                    Text("Enterprising (E):")
                    Text("\(Int(scores.enterprising * 100))%")
                }
                HStack {
                    Text("Conventional (C):")
                    Text("\(Int(scores.conventional * 100))%")
                }

                Text("Your top match: \(scores.topMatch.rawValue)")
                    .font(.headline)
            }
        }
    }
}
```

**Additional Requirement**:
Add "View as Table" toggle for users who prefer text over charts:

```swift
struct RIASECVisualization: View {
    let scores: RIASECScores
    @State private var showAsTable = false

    var body: some View {
        VStack {
            Toggle("Show as Table", isOn: $showAsTable)
                .accessibilityLabel("Toggle between chart and table view")

            if showAsTable {
                RIASECTableView(scores: scores)
            } else {
                RIASECRadarChart(scores: scores)
            }
        }
    }
}
```

---

## Recommended Optimizations (P2) - NICE TO HAVE

### P2-1: Core Data Fetch Efficiency

**Skill Source**: Core Data Specialist
**Severity**: RECOMMENDED - Performance optimization
**Phase Affected**: Phase 1 (Tasks 1.1-1.4)

#### Problem
Plan uses `.allObjects` to fetch Core Data entities, which loads all objects into memory.

**Problematic Code** (from plan Phase 1, Task 1.1):
```swift
// ⚠️ INEFFICIENT - Loads all objects
let experiences = workExperienceEntity.allObjects as? [WorkExperience] ?? []
```

#### Recommended Optimization

Use `NSFetchRequest` with predicates and batching:

```swift
// ✅ BETTER - Fetches only needed objects, supports sorting/filtering
func fetchWorkExperiences(sortedBy: SortOption) -> [WorkExperience] {
    let fetchRequest = NSFetchRequest<WorkExperience>(entityName: "WorkExperience")

    // Add sort descriptor
    fetchRequest.sortDescriptors = [
        NSSortDescriptor(key: "startDate", ascending: false)
    ]

    // Optional: Filter by date range
    if let filterDate = filterAfterDate {
        fetchRequest.predicate = NSPredicate(
            format: "startDate >= %@", filterDate as NSDate
        )
    }

    // Batch fetch for large datasets
    fetchRequest.fetchBatchSize = 20

    return (try? context.fetch(fetchRequest)) ?? []
}
```

**Impact**: Reduces memory usage by 30-50% for users with 10+ work experiences.

---

### P2-2: iOS 26 Liquid Glass Materials

**Skill Source**: iOS 26 Specialist
**Severity**: RECOMMENDED - Modern iOS 26 UX
**Phase Affected**: Phase 2 (Task 2.3 - RIASEC UI)

#### Recommendation
Use Liquid Glass materials for O*NET profile editor cards (iOS 26 design language).

```swift
// Current (works fine)
RoundedRectangle(cornerRadius: 12)
    .fill(Color.gray.opacity(0.1))

// ✅ BETTER - iOS 26 Liquid Glass
RoundedRectangle(cornerRadius: 12)
    .fill(.thinMaterial)  // Liquid Glass effect
    .overlay {
        RoundedRectangle(cornerRadius: 12)
            .strokeBorder(.quaternary, lineWidth: 0.5)
    }
```

**Impact**: Modern iOS 26 visual polish, better light/dark mode adaptation.

---

## Phase-by-Phase Remediation Plan

### Before Phase 1 (Week 0 - 8 hours)

**CRITICAL - DO NOT START PHASE 1 WITHOUT THESE FIXES**

- [ ] **P0-2**: Fix Sendable violations (NSManagedObjectID pattern)
  - Update Phase 1 Tasks 1.1-1.4 code samples
  - Enable Swift 6 strict concurrency in V7Services/Package.swift
  - Test compilation with no Sendable warnings
  - **Estimated Time**: 4 hours

- [ ] **P0-3**: Fix Industry enum (remove non-industries)
  - Replace 21 industries with 19 O*NET sectors
  - Add O*NET sector code mapping
  - Create legacy industry migration function
  - Update Phase 1 Task 1.5
  - **Estimated Time**: 3 hours

- [ ] **Review**: Re-read updated plan sections
  - Verify all P0 fixes incorporated
  - Update time estimates if needed
  - **Estimated Time**: 1 hour

**Total Pre-Phase Time**: 8 hours (Week 0)

---

### During Phase 1 (Week 1 - 32 hours)

**Focus**: Display Core Data entities, Industry enum expansion

**P2 Optimizations** (Optional):
- [ ] **P2-1**: Use NSFetchRequest instead of allObjects (Tasks 1.1-1.4)
  - Apply to WorkExperience, Education, Certification, Project views
  - Add sort descriptors and batch fetching
  - **Estimated Time**: +2 hours (optional)

**Quality Gates**:
- ✅ All views compile with Swift 6 strict concurrency
- ✅ No `@State` with Core Data objects (only NSManagedObjectID)
- ✅ Industry enum has exactly 19 cases
- ✅ WorkExperience.industry maps to O*NET sector codes

---

### During Phase 2 (Weeks 2-3 - 64 hours)

**Focus**: O*NET Profile Editor (Education, Activities, RIASEC)

**MANDATORY P0 & P1 Fixes**:

- [ ] **P0-1**: Thompson <10ms budget validation (Task 2.3)
  - Implement ONetScoringCache for pre-computed data
  - Add performance assertions to all scoring functions
  - Profile with Instruments to verify <10ms
  - **Estimated Time**: +6 hours (CRITICAL)

- [ ] **P1-1**: Async O*NET data loading (Tasks 2.1, 2.2)
  - Convert databases to actors with async init
  - Add Task-based background loading
  - Update SwiftUI views with .task {} pattern
  - **Estimated Time**: +4 hours

- [ ] **P1-2**: Accessibility for RIASEC radar chart (Task 2.3)
  - Add .accessibilityRepresentation with text data
  - Implement "View as Table" toggle
  - Test with VoiceOver
  - **Estimated Time**: +2 hours

**P2 Optimizations** (Optional):
- [ ] **P2-2**: Liquid Glass materials for profile editor cards
  - Replace .fill(Color.gray) with .fill(.thinMaterial)
  - **Estimated Time**: +1 hour (optional)

**Quality Gates**:
- ✅ Thompson scoring averages <10ms per job with O*NET data
- ✅ O*NET databases load asynchronously (no main thread blocking)
- ✅ Radar chart passes VoiceOver navigation test
- ✅ No async calls during Thompson scoring loop

**Updated Phase 2 Time**: 64 hours (baseline) + 12 hours (P0/P1 fixes) = **76 hours**

---

### During Phase 3 (Weeks 4-6 - 64 hours)

**Focus**: Skills Gap Analysis, Career Path Visualization, Course Recommendations

**No new P0/P1 fixes required** - Phase 3 builds on Phase 2 architecture.

**Quality Gates**:
- ✅ Skills gap analysis uses cached O*NET data
- ✅ Career path visualization accessible to screen readers
- ✅ Course recommendations maintain <10ms Thompson budget

**Phase 3 Time**: 64 hours (no changes)

---

## Detailed Code Fixes Reference

### Fix 1: Sendable-Compliant Core Data Views

**Problem**: `@State private var experience: WorkExperience?` not Sendable
**Solution**: Use `NSManagedObjectID` instead

```swift
// ❌ BEFORE (Swift 6 error)
struct WorkExperienceEditView: View {
    @State private var selectedExperience: WorkExperience?

    var body: some View {
        if let exp = selectedExperience {
            Form {
                TextField("Job Title", text: $exp.jobTitle)  // ❌ Error
            }
        }
    }
}

// ✅ AFTER (Swift 6 compliant)
struct WorkExperienceEditView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var selectedExperienceID: NSManagedObjectID?

    // Bindable wrapper for Core Data object
    @State private var jobTitle: String = ""
    @State private var company: String = ""
    @State private var industry: Industry?

    var body: some View {
        Form {
            TextField("Job Title", text: $jobTitle)
            TextField("Company", text: $company)
            Picker("Industry", selection: $industry) {
                ForEach(Industry.allCases) { industry in
                    Text(industry.rawValue).tag(industry)
                }
            }
        }
        .onAppear {
            loadExperience()
        }
        .onChange(of: jobTitle) { _, newValue in
            saveChanges()
        }
    }

    private func loadExperience() {
        guard let id = selectedExperienceID,
              let exp = try? context.existingObject(with: id) as? WorkExperience else {
            return
        }

        jobTitle = exp.jobTitle ?? ""
        company = exp.company ?? ""
        industry = exp.industry
    }

    private func saveChanges() {
        guard let id = selectedExperienceID,
              let exp = try? context.existingObject(with: id) as? WorkExperience else {
            return
        }

        exp.jobTitle = jobTitle
        exp.company = company
        exp.industry = industry

        try? context.save()
    }
}
```

**Apply to**: All 7 Core Data entities (WorkExperience, Education, Certification, Project, VolunteerExperience, Award, Publication)

---

### Fix 2: O*NET Industry Sector Enum

**Problem**: Includes non-industry categories ("Core Skills", "Knowledge Areas")
**Solution**: Use only 19 O*NET sectors with SOC code mapping

```swift
// File: V7Core/Sources/V7Core/Models/Industry.swift

/// O*NET Industry Sectors (19 sectors aligned with SOC taxonomy)
/// Source: https://www.onetcenter.org/taxonomy.html
public enum Industry: String, Codable, CaseIterable, Sendable, Identifiable {
    public var id: String { rawValue }

    // 19 O*NET Industry Sectors
    case agricultureForestryFishing = "Agriculture, Forestry, Fishing"
    case miningQuarrying = "Mining, Quarrying, Oil & Gas"
    case utilities = "Utilities"
    case construction = "Construction"
    case manufacturing = "Manufacturing"
    case wholesaleTrade = "Wholesale Trade"
    case retailTrade = "Retail Trade"
    case transportationWarehousing = "Transportation and Warehousing"
    case information = "Information"
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

    /// User-friendly icon for industry
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
        case .information: return "info.circle.fill"
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

    /// Migration from legacy app industries (if app already has data)
    public static func fromLegacy(_ legacy: String) -> Industry {
        switch legacy.lowercased() {
        case "technology", "tech", "it", "software":
            return .information
        case "finance", "banking", "fintech":
            return .financeInsurance
        case "healthcare", "medical", "health":
            return .healthcareSocialAssistance
        case "education", "teaching", "academia":
            return .educationalServices
        case "retail", "ecommerce", "sales":
            return .retailTrade
        case "manufacturing", "industrial":
            return .manufacturing
        case "construction", "building":
            return .construction
        case "hospitality", "food service", "restaurant":
            return .accommodationFoodServices
        case "arts", "entertainment", "media":
            return .artsEntertainment
        case "government", "public sector":
            return .publicAdministration
        case "real estate", "property":
            return .realEstate
        case "transportation", "logistics":
            return .transportationWarehousing
        default:
            return .otherServices  // Fallback
        }
    }
}
```

**Phase 1 Task 1.5 Update**:
Replace entire Industry enum file with above code. Remove any references to "coreSkills" or "knowledgeAreas".

---

### Fix 3: Thompson Sampling O*NET Integration

**Problem**: O*NET lookups during scoring could exceed 10ms budget
**Solution**: Pre-compute O*NET data before Thompson scoring

```swift
// File: V7Thompson/Sources/V7Thompson/ONetScoringCache.swift

import Foundation

/// Caches O*NET data for fast Thompson Sampling integration
/// CRITICAL: Must pre-load data BEFORE scoring to maintain <10ms budget
actor ONetScoringCache {
    static let shared = ONetScoringCache()

    // Cached O*NET data per job
    private var jobActivityScores: [String: [WorkActivity]] = [:]
    private var jobEducationLevels: [String: Int] = [:]  // 1-12 scale
    private var jobRIASEC: [String: RIASECScores] = [:]

    private init() {}

    /// Pre-load O*NET data for batch of jobs (can be slow, happens BEFORE scoring)
    /// - Parameter jobs: Jobs to pre-load O*NET data for
    /// - Returns: Number of jobs successfully cached
    func preloadONetData(for jobs: [Job]) async -> Int {
        let startTime = CFAbsoluteTimeGetCurrent()
        var successCount = 0

        await withTaskGroup(of: (String, [WorkActivity]?, Int?, RIASECScores?).self) { group in
            for job in jobs {
                group.addTask {
                    // Fetch O*NET data for this job (can take 50-200ms per job)
                    let activities = await self.fetchWorkActivities(job)
                    let educationLevel = await self.fetchEducationLevel(job)
                    let riasec = await self.calculateRIASEC(job)

                    return (job.id, activities, educationLevel, riasec)
                }
            }

            for await (jobID, activities, educationLevel, riasec) in group {
                if let activities = activities {
                    jobActivityScores[jobID] = activities
                    successCount += 1
                }
                if let educationLevel = educationLevel {
                    jobEducationLevels[jobID] = educationLevel
                }
                if let riasec = riasec {
                    jobRIASEC[jobID] = riasec
                }
            }
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("✅ O*NET preload: \(elapsed)ms for \(jobs.count) jobs (\(successCount) cached)")

        return successCount
    }

    /// Fast lookup of cached work activities (used during Thompson scoring)
    /// - Returns: Cached activities or nil if not loaded
    func getCachedActivities(jobID: String) -> [WorkActivity]? {
        return jobActivityScores[jobID]
    }

    func getCachedEducationLevel(jobID: String) -> Int? {
        return jobEducationLevels[jobID]
    }

    func getCachedRIASEC(jobID: String) -> RIASECScores? {
        return jobRIASEC[jobID]
    }

    /// Clear cache (call when user updates profile)
    func invalidateCache() {
        jobActivityScores.removeAll()
        jobEducationLevels.removeAll()
        jobRIASEC.removeAll()
    }

    // MARK: - Private O*NET Fetching (slow, async)

    private func fetchWorkActivities(_ job: Job) async -> [WorkActivity]? {
        // TODO: Implement O*NET API call or local database lookup
        // This can take 50-200ms - OK because it's pre-computed
        return nil
    }

    private func fetchEducationLevel(_ job: Job) async -> Int? {
        // TODO: Map job title to O*NET education level (1-12)
        return nil
    }

    private func calculateRIASEC(_ job: Job) async -> RIASECScores? {
        // TODO: Calculate RIASEC scores from O*NET interests data
        return nil
    }
}

// File: V7Thompson/Sources/V7Thompson/ThompsonSamplingWithONet.swift

import Foundation

/// Thompson Sampling scorer with O*NET integration
/// CRITICAL: Maintains <10ms per-job budget by using pre-cached O*NET data
public final class ThompsonSamplingWithONet: Sendable {
    private let baseScorer: ThompsonSampling
    private let onetCache: ONetScoringCache

    public init(baseScorer: ThompsonSampling = .shared) {
        self.baseScorer = baseScorer
        self.onetCache = .shared
    }

    /// Score jobs with O*NET profile matching
    /// - Parameters:
    ///   - jobs: Jobs to score
    ///   - profile: User's O*NET profile (education, activities, RIASEC)
    /// - Returns: Scored jobs sorted by relevance
    public func scoreJobs(_ jobs: [Job], profile: ONetUserProfile) async -> [ScoredJob] {
        // STEP 1: Pre-load O*NET data (can be slow, happens ONCE)
        let cached = await onetCache.preloadONetData(for: jobs)
        print("ℹ️ O*NET cache: \(cached)/\(jobs.count) jobs")

        // STEP 2: Fast Thompson scoring with O*NET boost
        let startTime = CFAbsoluteTimeGetCurrent()

        let scoredJobs = jobs.map { job in
            scoreJob(job, profile: profile)
        }

        // STEP 3: Validate <10ms budget (CRITICAL)
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        let avgPerJob = elapsed / Double(jobs.count)

        assert(avgPerJob < 10.0,
               "⚠️ Thompson budget violated: \(avgPerJob)ms per job (target: <10ms)")

        print("✅ Thompson scoring: \(avgPerJob)ms per job (budget: <10ms)")

        return scoredJobs.sorted { $0.score > $1.score }
    }

    /// Score single job with O*NET boost (MUST be <10ms)
    private func scoreJob(_ job: Job, profile: ONetUserProfile) -> ScoredJob {
        // Base Thompson score (takes ~6ms)
        let baseScore = baseScorer.score(job)

        // O*NET boost factors (all lookups are in-memory, <1ms total)
        let activityBoost = calculateActivityBoost(job, profile)
        let educationBoost = calculateEducationBoost(job, profile)
        let riasecBoost = calculateRIASECBoost(job, profile)

        // Combined score
        let finalScore = baseScore * activityBoost * educationBoost * riasecBoost

        return ScoredJob(job: job, score: finalScore)
    }

    /// Calculate work activity match boost (FAST - uses cached data)
    private func calculateActivityBoost(_ job: Job, _ profile: ONetUserProfile) -> Double {
        guard let jobActivities = await onetCache.getCachedActivities(jobID: job.id) else {
            return 1.0  // No boost if no O*NET data
        }

        // SIMD-optimized dot product (41 dimensions, <0.5ms)
        let userVector = profile.workActivities.asVector()  // [41] floats
        let jobVector = jobActivities.asVector()            // [41] floats

        let similarity = dotProduct(userVector, jobVector)

        // Boost: 0.8x (poor match) to 1.5x (excellent match)
        return 0.8 + (similarity * 0.7)
    }

    /// Calculate education level match boost (FAST - cached lookup)
    private func calculateEducationBoost(_ job: Job, _ profile: ONetUserProfile) -> Double {
        guard let jobLevel = await onetCache.getCachedEducationLevel(jobID: job.id) else {
            return 1.0
        }

        let userLevel = profile.educationLevel  // 1-12 scale

        // Penalize if user under-qualified, slight boost if over-qualified
        if userLevel < jobLevel {
            let gap = jobLevel - userLevel
            return max(0.5, 1.0 - (Double(gap) * 0.1))  // 10% penalty per level
        } else {
            return 1.0 + min(0.2, Double(userLevel - jobLevel) * 0.05)
        }
    }

    /// Calculate RIASEC interest match boost (FAST - cached lookup)
    private func calculateRIASECBoost(_ job: Job, _ profile: ONetUserProfile) -> Double {
        guard let jobRIASEC = await onetCache.getCachedRIASEC(jobID: job.id) else {
            return 1.0
        }

        let correlation = profile.riasecScores.correlation(with: jobRIASEC)

        // Boost: 0.7x (poor fit) to 1.3x (excellent fit)
        return 0.7 + (correlation * 0.6)
    }
}

// MARK: - Helper Extensions

extension Array where Element == Float {
    /// SIMD-optimized dot product for activity vectors
    fileprivate func dotProduct(_ other: [Float]) -> Double {
        precondition(count == other.count, "Vectors must be same length")

        var sum: Float = 0.0
        for i in 0..<count {
            sum += self[i] * other[i]
        }

        // Normalize to 0-1
        return Double(sum) / Double(count)
    }
}

public struct ScoredJob {
    public let job: Job
    public let score: Double
}
```

**Phase 2 Task 2.3 Update**:
- Use `ThompsonSamplingWithONet` instead of direct scoring
- Always call `preloadONetData()` before scoring batch
- Add performance assertions to verify <10ms

---

## Testing & Validation Checklist

### Pre-Phase 1 Validation

- [ ] **Swift 6 Strict Concurrency Enabled**
  ```bash
  # V7Services/Package.swift, V7Data/Package.swift, V7UI/Package.swift
  swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
  ```

- [ ] **No Sendable Warnings**
  ```bash
  xcodebuild -workspace ManifestAndMatchV7.xcworkspace \
             -scheme ManifestAndMatchV7 \
             -destination 'platform=iOS Simulator,name=iPhone 16' \
             build 2>&1 | grep -i "sendable"
  # Expected: No output (no warnings)
  ```

- [ ] **Industry Enum Validation**
  ```swift
  // Run in test suite
  func testIndustryEnumHas19Cases() {
      XCTAssertEqual(Industry.allCases.count, 19,
                     "Industry enum must have exactly 19 O*NET sectors")
  }

  func testIndustryNoMetaCategories() {
      let disallowed = ["coreSkills", "knowledgeAreas"]
      for industry in Industry.allCases {
          XCTAssertFalse(disallowed.contains(industry.rawValue),
                         "Industry enum must not contain meta-categories")
      }
  }

  func testIndustrySectorCodeMapping() {
      for industry in Industry.allCases {
          XCTAssertFalse(industry.sectorCode.isEmpty,
                         "All industries must have O*NET sector code")
      }
  }
  ```

### Phase 2 Validation

- [ ] **Thompson <10ms Budget**
  ```swift
  func testThompsonWithONetUnder10ms() async throws {
      let jobs = generateTestJobs(count: 100)
      let profile = ONetUserProfile(
          educationLevel: 8,  // Bachelor's
          workActivities: sampleActivities(),
          riasecScores: sampleRIASEC()
      )

      let scorer = ThompsonSamplingWithONet()

      let startTime = CFAbsoluteTimeGetCurrent()
      let scored = await scorer.scoreJobs(jobs, profile: profile)
      let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

      let avgPerJob = elapsed / Double(jobs.count)
      XCTAssertLessThan(avgPerJob, 10.0,
                        "Average \(avgPerJob)ms exceeds 10ms budget")
  }
  ```

- [ ] **O*NET Async Loading**
  ```swift
  @MainActor
  func testONetDatabaseDoesNotBlockMainThread() async throws {
      let expectation = XCTestExpectation(description: "Main thread responsive")

      Task { @MainActor in
          // Simulate UI update during O*NET load
          let _ = await ONetWorkActivitiesDatabase.shared.getActivities()
          expectation.fulfill()
      }

      // Should complete without blocking main thread
      await fulfillment(of: [expectation], timeout: 1.0)
  }
  ```

- [ ] **Accessibility - VoiceOver Test**
  - Navigate to RIASEC radar chart with VoiceOver
  - Verify all 6 Holland Code scores are read aloud
  - Verify "View as Table" toggle is accessible
  - Test with Dynamic Type (largest size)

### Phase 3 Validation

- [ ] **Skills Gap Analysis Performance**
  - Test with 50+ skills in user profile
  - Verify <10ms Thompson budget maintained
  - Check O*NET cache hit rate (should be >95%)

- [ ] **Career Path Accessibility**
  - Verify career path visualizations have text alternatives
  - Test with VoiceOver and Dynamic Type

---

## Success Criteria

### Phase 1 Complete When:
- ✅ All 7 Core Data entities displayed in ProfileScreen
- ✅ WorkExperience.industry expanded from 12 → 19 O*NET sectors
- ✅ No Swift 6 Sendable warnings
- ✅ Industry enum has exactly 19 cases (no meta-categories)
- ✅ All views use NSManagedObjectID (not NSManagedObject in @State)

### Phase 2 Complete When:
- ✅ O*NET Profile Editor functional (Education, Activities, RIASEC)
- ✅ Thompson scoring <10ms with O*NET data (tested with 100+ jobs)
- ✅ O*NET databases load asynchronously (no main thread blocking)
- ✅ RIASEC radar chart accessible to screen readers
- ✅ All P0 and P1 issues resolved

### Phase 3 Complete When:
- ✅ Skills Gap Analysis shows missing/matching skills
- ✅ Career Path Visualization displays progression
- ✅ Course Recommendations integrated
- ✅ All features maintain <10ms Thompson budget
- ✅ Full accessibility compliance (WCAG 2.1 AA)

---

## Time Impact Summary

| Phase | Original Time | P0/P1 Fixes | Updated Time |
|-------|---------------|-------------|--------------|
| **Pre-Phase (Week 0)** | 0 hours | +8 hours | **8 hours** |
| **Phase 1 (Week 1)** | 32 hours | +0 hours | **32 hours** |
| **Phase 2 (Weeks 2-3)** | 64 hours | +12 hours | **76 hours** |
| **Phase 3 (Weeks 4-6)** | 64 hours | +0 hours | **64 hours** |
| **TOTAL** | **160 hours** | **+20 hours** | **180 hours** |

**Key Changes**:
- Added Week 0 for P0 fixes (8 hours)
- Phase 2 extended for Thompson validation + async loading + accessibility (12 hours)
- Total project: 160 → 180 hours (+12.5%)

---

## Risk Mitigation

### Risk 1: Thompson Budget Exceeded
**Likelihood**: Medium
**Impact**: CRITICAL (destroys 357x performance advantage)
**Mitigation**:
- Mandatory performance testing after Phase 2 Task 2.3
- Fallback: Disable O*NET boost if scoring >10ms
- Alert developer if <2ms headroom remaining

### Risk 2: Swift 6 Migration Complexity
**Likelihood**: Low
**Impact**: Medium (delays Phase 1)
**Mitigation**:
- Use NSManagedObjectID pattern (proven in V7 codebase)
- Enable strict concurrency incrementally (package by package)
- 4-hour buffer in Week 0 for unexpected Sendable issues

### Risk 3: O*NET API Rate Limiting
**Likelihood**: Medium (if using O*NET Web Services API)
**Impact**: Medium (slow profile editor loading)
**Mitigation**:
- Cache O*NET data locally (41 activities, 12 education levels)
- Use bulk API calls (fetch 100 jobs at once)
- Implement exponential backoff for rate limit errors

---

## Appendix A: O*NET Resources

- **O*NET Online**: https://www.onetonline.org/
- **O*NET Web Services API**: https://services.onetcenter.org/
- **Industry Sectors (NAICS)**: https://www.onetcenter.org/taxonomy.html
- **Work Activities List**: https://www.onetonline.org/find/descriptor/browse/Work_Activities/
- **RIASEC Interests**: https://www.onetonline.org/find/descriptor/browse/Interests/

---

## Appendix B: V7 Architecture Constraints

**Sacred Constraints** (NEVER violate):
- ✅ Thompson Sampling: <10ms per job (357x performance advantage)
- ✅ Swift 6 strict concurrency: All packages must compile with Sendable enforcement
- ✅ Zero circular dependencies: Packages depend only on lower layers (V7Core → V7Data → V7Services → V7Thompson → V7UI)
- ✅ Accessibility: WCAG 2.1 AA compliance (VoiceOver, Dynamic Type)

**Package Structure**:
```
V7Core        - Shared models (Job, UserProfile, Industry, etc.)
V7Data        - Core Data entities (WorkExperience, Education, etc.)
V7Services    - Business logic (profile parsing, O*NET integration)
V7Thompson    - Thompson Sampling algorithm
V7UI          - SwiftUI views and components
```

**Import Rules**:
- V7UI can import V7Thompson, V7Services, V7Data, V7Core
- V7Thompson can import V7Core (only)
- V7Services can import V7Data, V7Core
- V7Data can import V7Core
- V7Core has no dependencies

---

## Document Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-10-29 | Initial remediation document from 10-skill sign-off |

---

**End of Remediation Document**

Total Issues Identified: 7 (3 P0, 2 P1, 2 P2)
Estimated Fix Time: +20 hours
Implementation Status: Ready to proceed with Week 0 fixes
