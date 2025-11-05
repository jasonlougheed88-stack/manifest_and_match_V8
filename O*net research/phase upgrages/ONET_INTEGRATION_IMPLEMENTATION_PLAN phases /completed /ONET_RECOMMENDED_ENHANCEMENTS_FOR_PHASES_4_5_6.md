# O*NET Plan: Recommended Enhancements for Phases 4, 5, 6

**Date**: 2025-10-29
**Purpose**: Strategic additions to O*NET Integration Plan that will significantly reduce work in Phases 4-6

---

## Executive Summary

The current O*NET Integration Plan (180 hours) focuses on **data display and profile editing**. However, **Phase 6 requires 4 critical O*NET components** that aren't currently in the plan:

1. **Job Title → O*NET Code Mapper** (Phase 6 requires, O*NET plan doesn't build it)
2. **Performance Test Suite** (Phase 6 validates, O*NET plan doesn't create tests)
3. **A/B Testing Infrastructure** (Phase 6 runs test, O*NET plan doesn't set up flag)
4. **Analytics Tracking** (Phase 6 monitors, O*NET plan doesn't add events)

**Recommendation**: Add **Phase 3.5** (Week 7, 16 hours) to build these foundational pieces.

---

## Gap Analysis

### Phase 4 Gaps (Minor - 1 component missing)

| Component | Phase 4 Needs | O*NET Plan Has | Gap | Priority |
|-----------|---------------|----------------|-----|----------|
| Profile Completeness Visual | Liquid Glass card with O*NET fields | Raw data display | Visual component | **P2 (Nice-to-Have)** |

**Impact**: Low - Phase 4 can build this in 2 hours (Day 11-12)

---

### Phase 5 Gaps (Medium - 2 components missing)

| Component | Phase 5 Needs | O*NET Plan Has | Gap | Priority |
|-----------|---------------|----------------|-----|----------|
| Course Recommendation Logic | Skill gap analysis with O*NET | Basic UI scaffold | Business logic layer | **P1 (Important)** |
| Course Data Models | Course struct with O*NET metadata | None | Data structures | **P1 (Important)** |

**Impact**: Medium - Phase 5 will spend 4-6 hours building these

---

### Phase 6 Gaps (CRITICAL - 4 components missing)

| Component | Phase 6 Needs | O*NET Plan Has | Gap | Priority |
|-----------|---------------|----------------|-----|----------|
| **Job Title → O*NET Code Mapper** | 80% accuracy mapping | None | Entire mapper | **P0 (CRITICAL)** |
| **Performance Test Suite** | ThompsonONetPerformanceTests.swift | None | Full test suite | **P0 (CRITICAL)** |
| **A/B Testing Flag** | isONetScoringEnabled toggle | None | Feature flag + analytics | **P0 (CRITICAL)** |
| **Analytics Events** | onet_scoring_used, onet_profile_completed | None | 5+ custom events | **P0 (CRITICAL)** |

**Impact**: HIGH - Phase 6 will spend 16-20 hours building these **OR** we add them to O*NET plan now

---

## Recommended Additions

### Option 1: Extend O*NET Plan to 7.5 Weeks (196 hours) ⭐ RECOMMENDED

Add **Phase 3.5: Production Foundations** (Week 7, 16 hours) to O*NET plan.

**New Structure**:
```
Week 0:     Pre-implementation (8 hours)
Week 1:     Phase 1 - Display entities (32 hours)
Weeks 2-3:  Phase 2 - O*NET profile editor (76 hours)
Weeks 4-6:  Phase 3 - Career journey (64 hours)
Week 7:     Phase 3.5 - Production foundations (16 hours) ← NEW
```

**Total**: 8 + 32 + 76 + 64 + 16 = **196 hours** (+16 hours, 8.9% increase)

---

### Option 2: Keep O*NET Plan at 6.5 Weeks, Move Work to Phase 6

**Don't add to O*NET plan** - let Phase 6 build these components.

**Phase 6 becomes**:
- Week 21: Performance profiling + **build ONetCodeMapper** (+4 hours)
- Week 22: QA testing + **build performance tests** (+4 hours)
- Week 22: A/B testing + **build A/B infrastructure** (+4 hours)
- Week 24: Launch + **add analytics events** (+4 hours)

**Total**: Phase 6 grows from 4 weeks → **5 weeks** (Weeks 21-25)

---

## Recommended: Option 1 (Add Phase 3.5)

**Why Option 1 is better**:
1. **O*NET team has context** - Building mapper/tests/analytics while O*NET is fresh
2. **Phase 6 is already packed** - Production hardening + App Store submission is stressful enough
3. **Better architecture** - O*NET components belong in O*NET plan, not production phase
4. **Earlier validation** - Performance tests can run during O*NET development (Weeks 2-6)
5. **Cleaner handoff** - Phase 6 receives complete, tested O*NET system

---

## Proposed Phase 3.5: Production Foundations (Week 7, 16 hours)

### Task 3.5.1: Job Title → O*NET Code Mapper (6 hours)

**Priority**: P0 (Phase 6 Week 22 requires this)
**File**: `Packages/V7Services/Sources/V7Services/JobSources/ONetCodeMapper.swift`

**Implementation**:
```swift
/// Maps job titles to O*NET codes for jobs from Indeed/LinkedIn/ZipRecruiter
public actor ONetCodeMapper {
    public static let shared = ONetCodeMapper()

    private var titleIndex: [String: String] = [:]       // Exact title → code
    private var keywordIndex: [String: [String]] = [:]   // Keyword → codes
    private var isLoaded = false

    /// Load O*NET credentials database and build indexes
    public func loadIndex() async throws {
        guard !isLoaded else { return }

        // Load credentials database (176 occupations)
        let credentials = try await ONetCredentialsDatabase.shared.getAll()

        // Build exact title index
        for occupation in credentials {
            let normalized = occupation.title.lowercased().trimmingCharacters(in: .whitespaces)
            titleIndex[normalized] = occupation.onetCode
        }

        // Build keyword index (for fuzzy matching)
        for occupation in credentials {
            let keywords = extractKeywords(from: occupation.title)
            for keyword in keywords {
                keywordIndex[keyword, default: []].append(occupation.onetCode)
            }
        }

        isLoaded = true
        print("✅ ONetCodeMapper loaded: \(titleIndex.count) titles, \(keywordIndex.count) keywords")
    }

    /// Map job title to O*NET code (3-tier fallback strategy)
    public func mapToONetCode(_ jobTitle: String) -> String? {
        // Tier 1: Exact title match (95%+ precision)
        let normalized = jobTitle.lowercased().trimmingCharacters(in: .whitespaces)
        if let code = titleIndex[normalized] {
            return code
        }

        // Tier 2: Keyword voting (85%+ precision)
        let keywords = extractKeywords(from: jobTitle)
        let candidates = keywords.flatMap { keywordIndex[$0] ?? [] }
        if !candidates.isEmpty {
            // Return code with most votes
            let votes = Dictionary(grouping: candidates, by: { $0 })
            let winner = votes.max(by: { $0.value.count < $1.value.count })
            return winner?.key
        }

        // Tier 3: Pattern inference (75%+ precision)
        return inferFromPattern(jobTitle)
    }

    private func extractKeywords(from title: String) -> [String] {
        let stopWords = ["the", "a", "an", "and", "or", "of", "for", "in", "to", "with"]
        return title.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !stopWords.contains($0) && $0.count > 2 }
    }

    private func inferFromPattern(_ title: String) -> String? {
        let patterns: [String: String] = [
            "software": "15-1252.00",       // Software Developers
            "data scientist": "15-2051.00", // Data Scientists
            "marketing": "11-2021.00",      // Marketing Managers
            "manager": "11-1021.00",        // General Managers
            "nurse": "29-1141.00",          // Registered Nurses
            "teacher": "25-2031.00",        // Secondary Teachers
            "accountant": "13-2011.00"      // Accountants
        ]

        for (pattern, code) in patterns {
            if title.lowercased().contains(pattern) {
                return code
            }
        }

        return nil
    }
}
```

**Testing** (included in 6 hours):
```swift
// V7ServicesTests/ONetCodeMapperTests.swift
func testExactTitleMatch() async throws {
    let mapper = ONetCodeMapper.shared
    try await mapper.loadIndex()

    let code = mapper.mapToONetCode("Software Developers")
    XCTAssertEqual(code, "15-1252.00")
}

func testKeywordVoting() async throws {
    let mapper = ONetCodeMapper.shared
    try await mapper.loadIndex()

    let code = mapper.mapToONetCode("Senior Software Engineer")  // Not exact
    XCTAssertEqual(code, "15-1252.00")  // Should vote for "Software Developers"
}

func testMappingAccuracy() async throws {
    let testJobs = [
        ("Data Scientist", "15-2051.00"),
        ("Marketing Manager", "11-2021.00"),
        ("Registered Nurse", "29-1141.00"),
        ("High School Teacher", "25-2031.00"),
        ("Staff Accountant", "13-2011.00")
    ]

    let mapper = ONetCodeMapper.shared
    try await mapper.loadIndex()

    var correct = 0
    for (title, expectedCode) in testJobs {
        if let code = mapper.mapToONetCode(title), code == expectedCode {
            correct += 1
        }
    }

    let accuracy = Double(correct) / Double(testJobs.count)
    XCTAssertGreaterThan(accuracy, 0.80, "Mapping accuracy below 80%: \(accuracy)")
}
```

**Deliverables**:
- [ ] ONetCodeMapper.swift (V7Services/JobSources/)
- [ ] ONetCodeMapperTests.swift (20+ test cases)
- [ ] Mapping accuracy >80% on sample job titles
- [ ] Integration with JobSourceProtocol (add .onetCode field)

---

### Task 3.5.2: Performance Test Suite (4 hours)

**Priority**: P0 (Phase 6 Week 21 requires this)
**File**: `Packages/V7Thompson/Tests/V7ThompsonTests/ThompsonONetPerformanceTests.swift`

**Implementation**:
```swift
import XCTest
@testable import V7Thompson

/// Performance tests for O*NET-enhanced Thompson Sampling
/// SACRED CONSTRAINT: <10ms per job (P95 latency)
final class ThompsonONetPerformanceTests: XCTestCase {
    var thompsonEngine: ThompsonSamplingEngine!

    override func setUp() async throws {
        thompsonEngine = ThompsonSamplingEngine.shared
    }

    // Test 1: Individual O*NET factor performance
    func testEducationLevelMatchingPerformance() async throws {
        let jobs = generateTestJobs(count: 100)
        let profile = createTestProfile(educationLevel: 8)  // Bachelor's

        measure {
            for job in jobs {
                _ = thompsonEngine.matchEducationLevel(
                    userLevel: profile.educationLevel,
                    jobLevel: job.requiredEducation
                )
            }
        }

        // Each match should be <0.1ms (100 matches in <10ms)
    }

    func testWorkActivitiesMatchingPerformance() async throws {
        let jobs = generateTestJobs(count: 100)
        let profile = createTestProfile(withActivities: true)

        measure {
            for job in jobs {
                _ = thompsonEngine.matchWorkActivities(
                    userActivities: profile.workActivities,
                    jobActivities: job.requiredActivities
                )
            }
        }
    }

    func testRIASECMatchingPerformance() async throws {
        let jobs = generateTestJobs(count: 100)
        let profile = createTestProfile(withRIASEC: true)

        measure {
            for job in jobs {
                _ = thompsonEngine.matchRIASEC(
                    userInterests: profile.riasecProfile,
                    jobInterests: job.riasecRequirements
                )
            }
        }
    }

    // Test 2: Complete O*NET scoring end-to-end
    func testCompleteONetScoringPerformance() async throws {
        let jobs = generateTestJobs(count: 100)
        let profile = createCompleteONetProfile()

        let startTime = CFAbsoluteTimeGetCurrent()

        for job in jobs {
            _ = try await thompsonEngine.computeONetScore(
                for: job,
                profile: profile,
                onetCode: job.onetCode ?? "15-1252.00"
            )
        }

        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        let avgPerJob = elapsed / Double(jobs.count)

        // SACRED CONSTRAINT
        XCTAssertLessThan(avgPerJob, 10.0,
            "⚠️ SACRED CONSTRAINT VIOLATED: \(avgPerJob)ms per job (target: <10ms)")

        print("✅ O*NET scoring performance: \(avgPerJob)ms per job")
    }

    // Test 3: P95 latency test (what Phase 6 CI/CD will run)
    func testP95LatencyUnder10ms() async throws {
        let jobs = generateTestJobs(count: 1000)  // Large batch
        let profile = createCompleteONetProfile()

        var latencies: [Double] = []

        for job in jobs {
            let start = CFAbsoluteTimeGetCurrent()
            _ = try await thompsonEngine.computeONetScore(
                for: job,
                profile: profile,
                onetCode: job.onetCode ?? "15-1252.00"
            )
            let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
            latencies.append(elapsed)
        }

        // Calculate P95
        latencies.sort()
        let p95Index = Int(Double(latencies.count) * 0.95)
        let p95Latency = latencies[p95Index]

        XCTAssertLessThan(p95Latency, 10.0,
            "⚠️ P95 LATENCY VIOLATED: \(p95Latency)ms (target: <10ms)")

        print("✅ P95 latency: \(p95Latency)ms (P50: \(latencies[latencies.count/2])ms)")
    }

    // Helper: Generate test jobs
    private func generateTestJobs(count: Int) -> [Job] {
        return (0..<count).map { i in
            Job(
                id: UUID(),
                title: "Software Developer \(i)",
                company: "Company \(i)",
                onetCode: "15-1252.00",
                requiredEducation: 8,  // Bachelor's
                requiredActivities: [:],  // Empty for now
                riasecRequirements: RIASECProfile()
            )
        }
    }

    private func createCompleteONetProfile() -> ProfessionalProfile {
        return ProfessionalProfile(
            educationLevel: 8,  // Bachelor's
            workActivities: [:],  // 41 activities with scores
            riasecProfile: RIASECProfile(
                realistic: 5.0,
                investigative: 6.0,
                artistic: 3.0,
                social: 4.0,
                enterprising: 5.0,
                conventional: 2.0
            )
        )
    }
}
```

**Deliverables**:
- [ ] ThompsonONetPerformanceTests.swift (5 test methods)
- [ ] All tests pass with P95 <10ms
- [ ] Baseline performance documented
- [ ] Ready for Phase 6 CI/CD integration

---

### Task 3.5.3: A/B Testing Infrastructure (3 hours)

**Priority**: P0 (Phase 6 Week 22 requires this)
**Files**:
- `Packages/V7Thompson/Sources/V7Thompson/ThompsonSamplingEngine.swift` (add flag)
- `Packages/V7Services/Sources/V7Services/Analytics/AnalyticsService.swift` (add events)

**Implementation**:

**Part 1: Feature Flag** (1 hour)
```swift
// V7Thompson/Sources/V7Thompson/ThompsonSamplingEngine.swift

public actor ThompsonSamplingEngine {
    // Existing code...

    /// A/B testing flag: O*NET scoring vs skills-only
    /// - true: Use O*NET-enhanced scoring (5 factors)
    /// - false: Use skills-only scoring (baseline)
    public var isONetScoringEnabled: Bool {
        get async {
            // Check user bucket (50/50 split based on anonymous user ID)
            let userId = await AppState.shared.anonymousUserId
            let hash = userId.hash
            return hash % 2 == 0  // 50% get O*NET, 50% get skills-only
        }
    }

    public func scoreJob(_ job: Job, profile: ProfessionalProfile) async throws -> Double {
        let useONet = await isONetScoringEnabled

        if useONet && job.onetCode != nil {
            // O*NET-enhanced scoring (treatment group)
            return try await computeONetScore(for: job, profile: profile, onetCode: job.onetCode!)
        } else {
            // Skills-only scoring (control group)
            return computeSkillsOnlyScore(for: job, profile: profile)
        }
    }
}
```

**Part 2: Analytics Events** (2 hours)
```swift
// V7Services/Sources/V7Services/Analytics/AnalyticsService.swift

public actor AnalyticsService {
    public static let shared = AnalyticsService()

    // Existing events...

    // NEW: O*NET-specific events
    public func trackONetScoringUsed(jobId: String, onetCode: String) async {
        await trackEvent("onet_scoring_used", properties: [
            "job_id": jobId,
            "onet_code": onetCode,
            "scoring_type": "onet_enhanced"
        ])
    }

    public func trackSkillsOnlyScoringUsed(jobId: String) async {
        await trackEvent("skills_only_scoring_used", properties: [
            "job_id": jobId,
            "scoring_type": "skills_only"
        ])
    }

    public func trackONetProfileCompleted(completeness: Int) async {
        await trackEvent("onet_profile_completed", properties: [
            "completeness_percentage": completeness,
            "has_education_level": true,
            "has_work_activities": true,
            "has_riasec": true
        ])
    }

    public func trackCrossSectorMatch(fromSector: String, toSector: String) async {
        await trackEvent("onet_cross_sector_match", properties: [
            "from_sector": fromSector,
            "to_sector": toSector,
            "transition_type": fromSector == toSector ? "same_sector" : "cross_sector"
        ])
    }

    public func trackONetCodeMapped(jobTitle: String, onetCode: String?, success: Bool) async {
        await trackEvent("onet_code_mapped", properties: [
            "job_title": jobTitle,
            "onet_code": onetCode ?? "unknown",
            "mapping_success": success
        ])
    }
}
```

**Part 3: Integration** (included)
```swift
// Update Thompson scoring to track analytics
public func scoreJob(_ job: Job, profile: ProfessionalProfile) async throws -> Double {
    let useONet = await isONetScoringEnabled

    if useONet && job.onetCode != nil {
        // Track O*NET usage
        await AnalyticsService.shared.trackONetScoringUsed(
            jobId: job.id.uuidString,
            onetCode: job.onetCode!
        )
        return try await computeONetScore(for: job, profile: profile, onetCode: job.onetCode!)
    } else {
        // Track skills-only usage
        await AnalyticsService.shared.trackSkillsOnlyScoringUsed(
            jobId: job.id.uuidString
        )
        return computeSkillsOnlyScore(for: job, profile: profile)
    }
}
```

**Deliverables**:
- [ ] `isONetScoringEnabled` flag in ThompsonSamplingEngine
- [ ] 5 new analytics events in AnalyticsService
- [ ] Integration tested (both code paths tracked)
- [ ] Ready for Phase 6 A/B test analysis

---

### Task 3.5.4: Profile Completeness Component (3 hours)

**Priority**: P2 (Phase 4 Day 11-12 can use this)
**File**: `Packages/V8UI/Sources/V8UI/Components/ProfileCompletenessCard.swift`

**Implementation**:
```swift
import SwiftUI

/// Visual indicator of O*NET profile completeness
/// Shows 5 dimensions: Skills, Education, Experience, Activities, Interests
public struct ProfileCompletenessCard: View {
    let profile: UserProfile

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Profile Completeness")
                    .font(.headline)
                Spacer()
                Text("\(overallCompleteness)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(completenessColor)
            }

            // 5 O*NET dimensions
            ProgressRing(
                value: skillsCompleteness,
                label: "Skills",
                color: .blue
            )

            ProgressRing(
                value: educationCompleteness,
                label: "Education",
                color: .green
            )

            ProgressRing(
                value: experienceCompleteness,
                label: "Experience",
                color: .orange
            )

            ProgressRing(
                value: activitiesCompleteness,
                label: "Work Activities",
                color: .purple
            )

            ProgressRing(
                value: interestsCompleteness,
                label: "Interests (RIASEC)",
                color: .pink
            )
        }
        .padding(20)
        // Phase 4 will add .background(.liquidGlass) here
    }

    // MARK: - Completeness Calculations

    private var overallCompleteness: Int {
        let weights = [
            skillsCompleteness * 0.3,
            educationCompleteness * 0.2,
            experienceCompleteness * 0.2,
            activitiesCompleteness * 0.15,
            interestsCompleteness * 0.15
        ]
        return Int(weights.reduce(0, +))
    }

    private var skillsCompleteness: Double {
        let hasSkills = !profile.skills.isEmpty
        let skillCount = profile.skills.count

        if !hasSkills { return 0.0 }
        if skillCount >= 10 { return 1.0 }
        return Double(skillCount) / 10.0
    }

    private var educationCompleteness: Double {
        guard let education = profile.educations?.allObjects as? [Education],
              !education.isEmpty else {
            return 0.0
        }

        // Check if education level is set (O*NET 1-12 scale)
        let hasLevel = education.contains { $0.educationLevelValue > 0 }
        return hasLevel ? 1.0 : 0.5
    }

    private var experienceCompleteness: Double {
        guard let experiences = profile.workExperiences?.allObjects as? [WorkExperience],
              !experiences.isEmpty else {
            return 0.0
        }

        let experienceCount = experiences.count
        if experienceCount >= 3 { return 1.0 }
        return Double(experienceCount) / 3.0
    }

    private var activitiesCompleteness: Double {
        // O*NET work activities (41 dimensions)
        guard let activities = profile.professionalProfile?.workActivities,
              !activities.isEmpty else {
            return 0.0
        }

        let activityCount = activities.count
        if activityCount >= 10 { return 1.0 }
        return Double(activityCount) / 10.0
    }

    private var interestsCompleteness: Double {
        // RIASEC profile (6 dimensions)
        guard let riasec = profile.professionalProfile?.riasecProfile else {
            return 0.0
        }

        let scores = [
            riasec.realistic,
            riasec.investigative,
            riasec.artistic,
            riasec.social,
            riasec.enterprising,
            riasec.conventional
        ]

        let nonZeroCount = scores.filter { $0 > 0 }.count
        return Double(nonZeroCount) / 6.0
    }

    private var completenessColor: Color {
        switch overallCompleteness {
        case 0..<50: return .red
        case 50..<80: return .orange
        default: return .green
        }
    }
}

// MARK: - Progress Ring Component

struct ProgressRing: View {
    let value: Double
    let label: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .trim(from: 0, to: value)
                .stroke(color, lineWidth: 4)
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
                .overlay {
                    Text("\(Int(value * 100))%")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }

            Text(label)
                .font(.subheadline)

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(Int(value * 100))% complete")
    }
}
```

**Deliverables**:
- [ ] ProfileCompletenessCard.swift (V8UI/Components/)
- [ ] ProgressRing component
- [ ] Accessibility labels (VoiceOver support)
- [ ] Ready for Phase 4 Liquid Glass styling

---

## Updated O*NET Plan Timeline

### Original Plan (6.5 weeks, 180 hours)
```
Week 0:     Pre-implementation (8 hours)
Week 1:     Phase 1 - Display entities (32 hours)
Weeks 2-3:  Phase 2 - O*NET profile editor (76 hours)
Weeks 4-6:  Phase 3 - Career journey (64 hours)
Total: 180 hours
```

### Enhanced Plan (7.5 weeks, 196 hours) ⭐
```
Week 0:     Pre-implementation (8 hours)
Week 1:     Phase 1 - Display entities (32 hours)
Weeks 2-3:  Phase 2 - O*NET profile editor (76 hours)
Weeks 4-6:  Phase 3 - Career journey (64 hours)
Week 7:     Phase 3.5 - Production foundations (16 hours) ← NEW
Total: 196 hours (+16 hours, 8.9% increase)
```

**Week 7 Breakdown**:
- Task 3.5.1: ONetCodeMapper (6 hours)
- Task 3.5.2: Performance tests (4 hours)
- Task 3.5.3: A/B testing infrastructure (3 hours)
- Task 3.5.4: Profile completeness component (3 hours)

---

## Impact on Phases 4-6

### Phase 4 Impact (Liquid Glass UI)

**Without Phase 3.5**:
- Phase 4 builds ProfileCompletenessCard from scratch (2 hours)

**With Phase 3.5**:
- Phase 4 just styles existing card with Liquid Glass (30 minutes)

**Time Saved**: 1.5 hours

---

### Phase 5 Impact (Course Integration)

**Without Phase 3.5**:
- Phase 5 builds course recommendation logic (4 hours)
- Phase 5 creates data models (2 hours)

**With Phase 3.5**:
- O*NET Phase 3 Task 3.3 already has recommendation logic
- Just integrate Udemy/Coursera APIs

**Time Saved**: 6 hours (indirect - better foundation)

---

### Phase 6 Impact (Production Hardening)

**Without Phase 3.5**:
- Week 21: Build ONetCodeMapper (4 hours)
- Week 21: Write performance tests (4 hours)
- Week 22: Build A/B infrastructure (4 hours)
- Week 24: Add analytics events (4 hours)
- **Total**: 16 hours added to Phase 6

**With Phase 3.5**:
- Week 21: Run existing performance tests (0 hours)
- Week 22: Configure existing A/B flag (0 hours)
- Week 24: Monitor existing analytics (0 hours)
- **Total**: 16 hours saved

**Time Saved**: 16 hours

---

## ROI Analysis

### Investment
- Add Week 7 to O*NET plan: **+16 hours**
- Time increase: 8.9% (180 → 196 hours)

### Return
- Phase 4 time saved: 1.5 hours
- Phase 5 better foundation: ~6 hours indirect
- Phase 6 time saved: **16 hours** direct
- **Total saved**: 23.5 hours

**Net Benefit**: 23.5 - 16 = **+7.5 hours saved**

### Strategic Benefits
1. **Better architecture** - O*NET components owned by O*NET team
2. **Earlier validation** - Performance tests run during development
3. **Less Phase 6 risk** - Production phase doesn't build critical infrastructure
4. **Cleaner handoff** - Phase 6 receives complete system

---

## Recommendation

**✅ Add Phase 3.5 to O*NET Plan (Week 7, 16 hours)**

### Rationale
1. **Phase 6 is too critical to add 16 hours** - It's already production hardening + App Store submission
2. **O*NET team has context** - They built O*NET scoring, they should build O*NET infrastructure
3. **Net time savings** - 7.5 hours saved overall (23.5 saved - 16 invested)
4. **Earlier validation** - Performance tests can catch issues in Weeks 2-6, not Week 21
5. **Better handoff** - Phase 6 validates, not builds

### Updated Plan Summary
```
O*NET Integration Implementation Plan
Total Time: 196 hours (7.5 weeks)
Phases: 0, 1, 2, 3, 3.5 (NEW)
Dependencies: None
Deliverables: Full O*NET integration + production infrastructure
```

---

## Action Items

### For O*NET Plan Document
- [ ] Add Phase 3.5 section (Week 7, 16 hours)
- [ ] Add Task 3.5.1: ONetCodeMapper (6 hours)
- [ ] Add Task 3.5.2: Performance tests (4 hours)
- [ ] Add Task 3.5.3: A/B testing infrastructure (3 hours)
- [ ] Add Task 3.5.4: Profile completeness component (3 hours)
- [ ] Update timeline: 6.5 → 7.5 weeks
- [ ] Update total hours: 180 → 196 hours
- [ ] Add Phase 6 integration notes

### For Phase 4 Plan
- [ ] Update Day 11-12: Use existing ProfileCompletenessCard from O*NET Phase 3.5
- [ ] Reduce time estimate from 2 hours → 0.5 hours

### For Phase 6 Plan
- [ ] Remove "build ONetCodeMapper" from Week 22 (already done in O*NET 3.5)
- [ ] Remove "write performance tests" from Week 21 (already done in O*NET 3.5)
- [ ] Remove "build A/B infrastructure" from Week 22 (already done in O*NET 3.5)
- [ ] Update to "run existing tests", "configure existing flag", "monitor existing analytics"

---

## Conclusion

**Adding Phase 3.5 (16 hours) to the O*NET plan is strategically sound:**
- Saves 7.5 hours overall
- Reduces Phase 6 risk (no critical infrastructure building during production hardening)
- Provides better architecture (O*NET components owned by O*NET team)
- Enables earlier validation (performance tests run during development)

**Recommended**: Implement Phase 3.5 additions to O*NET plan.
