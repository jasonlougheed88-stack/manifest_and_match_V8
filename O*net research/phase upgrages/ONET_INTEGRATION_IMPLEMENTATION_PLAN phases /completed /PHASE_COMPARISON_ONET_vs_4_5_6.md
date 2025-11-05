# O*NET Integration Plan vs Phases 4-6 Comparison

**Date**: 2025-10-29
**Purpose**: Align O*NET Integration Implementation Plan with Phases 4, 5, 6 timelines and deliverables

---

## Executive Summary

The **O*NET Integration Implementation Plan** (Week 0 + Phases 1-3, 6.5 weeks, 180 hours) is a **prerequisite module** that runs **BEFORE** Phases 4-6. It provides critical O*NET profile data that enhances features in Phases 5 and 6.

### Timeline Alignment

| Plan | Weeks | Duration | Start Dependency |
|------|-------|----------|------------------|
| **O*NET Integration** | Week 0 + 1-6 | 6.5 weeks (180 hours) | Can start immediately |
| **Phase 4: Liquid Glass UI** | 13-17 | 5 weeks | Phase 2 complete (overlaps with O*NET) |
| **Phase 5: Course Integration** | 18-20 | 3 weeks | Phase 3 complete + **O*NET Phase 3** |
| **Phase 6: Production Hardening** | 21-24 | 4 weeks | All phases + **O*NET complete** |

### Key Finding: O*NET Plan is a Parallel Track

**O*NET Integration runs concurrently with V8 Phases 2-3** (Weeks 3-12):
- **Week 0-6**: O*NET Integration (this plan)
- **Weeks 3-16**: Phase 2 (Foundation Models)
- **Weeks 3-12**: Phase 3 (Profile Expansion)
- **O*NET + Phase 3 converge** at Week 6 for profile completeness

---

## Timeline Visualization

```
Week:   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24
        |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |

O*NET:  [0][1---------][2-------------][3------------------]
                         (O*NET Profile Editor)  (Career Journey)

V8 P2:              [Phase 2: Foundation Models -------------------------]
V8 P3:              [Phase 3: Profile Expansion ------------------]
V8 P4:                                                              [Phase 4: Liquid Glass ----]
V8 P5:                                                                                          [P5: Courses-]
V8 P6:                                                                                                      [Phase 6: Prod Hardening---]

Legend:
[0] = Week 0 (Pre-implementation fixes)
[1-] = Phase 1 (Display entities, industries)
[2-] = Phase 2 (O*NET Profile Editor)
[3-] = Phase 3 (Skills gap, career path, courses)
```

**Critical Path**:
1. **Week 0-1**: O*NET Phase 1 runs (display Core Data entities, expand industries to 19 sectors)
2. **Weeks 2-3**: O*NET Phase 2 runs (O*NET profile editor: education, activities, RIASEC)
3. **Weeks 4-6**: O*NET Phase 3 runs (skills gap analysis, career path viz, course recommendations)
4. **Week 6**: O*NET complete → data feeds into Thompson scoring for rest of V8
5. **Weeks 13-17**: Phase 4 uses O*NET data for profile completeness UI (optional)
6. **Weeks 18-20**: Phase 5 uses O*NET data for enhanced course recommendations
7. **Weeks 21-24**: Phase 6 validates O*NET performance, A/B tests, and monitors analytics

---

## Feature Overlap Analysis

### 1. Course Recommendations (O*NET Phase 3 vs V8 Phase 5)

**O*NET Phase 3, Task 3.3** (Week 6):
- **Scope**: Basic course recommendations UI
- **Data Source**: Sample/mock courses
- **Integration**: None (just UI scaffold)
- **Skill Gap**: Based on SkillsDatabase matching
- **Time**: 12 hours (part of 64-hour Phase 3)

**V8 Phase 5** (Weeks 18-20):
- **Scope**: Full Udemy + Coursera API integration
- **Data Source**: Real-time API calls with affiliate links
- **Integration**: Production-ready with rate limiting, circuit breakers
- **Skill Gap**: Advanced (parallel API calls, caching, personalization)
- **Revenue**: $0.10-$0.50 per user/month
- **Time**: 3 weeks (full phase)

**Resolution**:
- **O*NET Phase 3** provides the **UI scaffold** and **skill gap analysis logic**
- **V8 Phase 5** replaces mock data with **real API integration**
- **V8 Phase 5 Enhancement** (optional): Use O*NET work activities + education levels for smarter recommendations

**Action**: Keep both phases - they build on each other.

---

### 2. Profile Completeness (O*NET Phase 1-2 vs V8 Phase 4)

**O*NET Phase 1-2** (Weeks 1-3):
- **Scope**: Display all 7 Core Data entities (WorkExperience, Education, etc.)
- **Completeness**: User sees 95% of profile data
- **O*NET Fields**: Education level (1-12), work activities (41), RIASEC interests (6)

**V8 Phase 4, Optional** (Day 11-12):
- **Scope**: Profile completeness indicator card (Liquid Glass design)
- **Completeness**: Visual progress rings for 5 dimensions
- **O*NET Integration**: Shows how complete O*NET profile is

**Resolution**:
- **O*NET provides the data** (education level, activities, interests)
- **V8 Phase 4** provides the **Liquid Glass UI visualization** (optional)

**Action**: V8 Phase 4 references O*NET data but is optional (nice-to-have).

---

### 3. Thompson Performance (<10ms Sacred Constraint)

**O*NET Phase 2** (Weeks 2-3):
- **Requirement**: Thompson scoring with O*NET data must stay <10ms
- **Budget**: 6.1ms used + 3.9ms headroom
- **Validation**: Performance assertions in all O*NET scoring code
- **Strategy**: Pre-compute O*NET lookups, use in-memory cache

**V8 Phase 6** (Week 21, Days 1-5):
- **Requirement**: Comprehensive Thompson profiling with Instruments
- **Budget**: Same <10ms constraint
- **Validation**: CI/CD pipeline blocks builds if P95 >10ms
- **Testing**: O*NET vs skills-only A/B test

**Resolution**:
- **O*NET Phase 2** implements the performance-safe architecture
- **V8 Phase 6** validates it in production with CI/CD

**Action**: Both phases enforce same constraint - aligned.

---

## Integration Points (O*NET → Phase 4, 5, 6)

### Integration 1: O*NET Data → Phase 4 Liquid Glass UI

**O*NET Provides**:
- Education level (1-12 scale)
- Work activities (41 dimensions, 0-7 scale)
- RIASEC interests (6 dimensions, 0-7 scale)
- Skills (from SkillTaxonomy)
- Work experience entities (Core Data)

**Phase 4 Uses** (Optional - Day 11-12):
```swift
// ProfileCompletenessCard.swift (V8UI/Components/)
struct ProfileCompletenessCard: View {
    let profile: UserProfile

    var body: some View {
        VStack {
            Text("Profile Completeness: \(completeness)%")

            // 5 O*NET dimensions with progress rings
            ProgressRing(value: skillsCompleteness, label: "Skills")
            ProgressRing(value: educationCompleteness, label: "Education")
            ProgressRing(value: experienceCompleteness, label: "Experience")
            ProgressRing(value: activitiesCompleteness, label: "Work Activities")
            ProgressRing(value: interestsCompleteness, label: "Interests (RIASEC)")
        }
        .background(.liquidGlass)  // Phase 4 Liquid Glass
    }

    private var completeness: Int {
        let weights = [
            skillsCompleteness * 0.3,
            educationCompleteness * 0.2,
            experienceCompleteness * 0.2,
            activitiesCompleteness * 0.15,
            interestsCompleteness * 0.15
        ]
        return Int(weights.reduce(0, +))
    }
}
```

**Status**: Optional enhancement (Phase 4, Day 11-12)

---

### Integration 2: O*NET Data → Phase 5 Course Recommendations

**O*NET Provides**:
- Skill gaps (current skills vs target role skills)
- Education level (1-12 scale) for course difficulty matching
- Work activities (41 dimensions) for activity-based recommendations
- O*NET knowledge areas (from O*NET API)

**Phase 5 Uses** (Optional Enhancement - Day 5-7):
```swift
// CourseRecommendationService.swift (V8Services/)
public actor CourseRecommendationService {
    private let onetService = ONetDataService.shared

    private func analyzeSkillGaps(
        profile: UserProfile,
        targetRole: String?
    ) async -> [String] {
        // Enhanced with O*NET knowledge requirements
        if let targetOccupation = await findONetOccupation(for: targetRole) {
            let knowledge = try? await onetService.loadKnowledge()
            let occupationKnowledge = knowledge?.occupations.first {
                $0.onetCode == targetOccupation
            }

            // Extract top knowledge areas (these become course topics)
            let topKnowledge = occupationKnowledge?.knowledge
                .filter { $0.importance > 5.0 }
                .sorted { $0.importance > $1.importance }
                .prefix(5)
                .map { $0.name }

            return Array(skillGaps) + (topKnowledge ?? [])
        }

        return Array(skillGaps)  // Fallback
    }

    private func rankCourse(_ course: Course, for profile: ProfessionalProfile) -> Double {
        var score = 0.0

        // NEW: O*NET education level matching
        if let educationLevel = profile.educationLevel {
            let courseLevelMap: [String: Int] = [
                "beginner": 6, "intermediate": 8, "advanced": 10, "expert": 12
            ]
            if let courseLevel = courseLevelMap[course.level],
               abs(courseLevel - educationLevel) <= 2 {
                score += 15  // Course matches user's education level
            }
        }

        // NEW: O*NET work activities alignment
        if let workActivities = profile.workActivities {
            let courseActivities = extractWorkActivities(from: course.description)
            let overlap = Set(workActivities.keys).intersection(courseActivities)
            score += Double(overlap.count) * 5  // 5 points per overlapping activity
        }

        return score
    }
}
```

**Status**: Optional enhancement (Phase 5, Day 5-7)
**Benefit**: 10-20% better course relevance, education-level appropriate recommendations

---

### Integration 3: O*NET Data → Phase 6 Performance Validation

**O*NET Provides**:
- Thompson scoring with 5 O*NET factors
- O*NET database load times (credentials, activities, interests, knowledge, abilities)

**Phase 6 Uses** (Week 21, Days 4-5):
```swift
// ThompsonONetPerformanceTests.swift (already exists in V7ThompsonTests/)
func testThompsonONetScoringUnder10ms() async throws {
    let jobs = generateTestJobs(count: 100)
    let profile = createTestProfileWithONet()  // Has O*NET data

    let startTime = CFAbsoluteTimeGetCurrent()

    for job in jobs {
        let score = try await thompsonEngine.computeONetScore(
            for: job,
            profile: profile,
            onetCode: job.onetCode ?? "15-1252.00"
        )
    }

    let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    let avgPerJob = elapsed / Double(jobs.count)

    // SACRED CONSTRAINT
    XCTAssertLessThan(avgPerJob, 10.0,
        "SACRED CONSTRAINT VIOLATED: \(avgPerJob)ms per job (target: <10ms)")
}
```

**Status**: Required (Phase 6, Week 21)
**CI/CD**: Build fails if P95 >10ms

---

### Integration 4: O*NET Data → Phase 6 Job Source Mapping

**O*NET Provides**:
- O*NET credentials database (176 occupations, 200KB)
- O*NET code structure (SOC taxonomy)

**Phase 6 Implements** (Week 22, Days 9-10):
```swift
// ONetCodeMapper.swift (V7Services/JobSources/)
public actor ONetCodeMapper {
    private var titleIndex: [String: String] = [:]  // Title → O*NET code

    public func mapToONetCode(_ jobTitle: String) -> String? {
        // 1. Exact title match (highest precision)
        let normalized = jobTitle.lowercased().trimmingCharacters(in: .whitespaces)
        if let code = titleIndex[normalized] {
            return code
        }

        // 2. Keyword-based voting (medium precision)
        let keywords = extractKeywords(from: jobTitle)
        let candidates = titleIndex.filter { title, code in
            keywords.contains { title.contains($0) }
        }
        if !candidates.isEmpty {
            return candidates.max(by: { votingScore($0) < votingScore($1) })?.value
        }

        // 3. Pattern-based inference (fallback)
        return inferFromPattern(jobTitle)
    }

    private func inferFromPattern(_ title: String) -> String? {
        let patterns: [String: String] = [
            "software developer": "15-1252.00",
            "data scientist": "15-2051.00",
            "marketing manager": "11-2021.00",
            "general manager": "11-1021.00"
        ]
        return patterns[title.lowercased()]
    }
}
```

**Status**: Required (Phase 6, Week 22)
**Target**: >80% job title → O*NET code mapping accuracy

---

### Integration 5: O*NET Data → Phase 6 A/B Testing

**O*NET Provides**:
- O*NET-enhanced Thompson scoring
- Skills-only Thompson scoring (baseline)

**Phase 6 Tests** (Week 22, Days 6-8):

| Metric | O*NET Enhanced | Skills-Only | Winner |
|--------|---------------|------------|--------|
| Application Rate | ___% | ___% | ___ |
| Avg Time/Job | ___s | ___s | ___ |
| Cross-Sector Exploration | ___% | ___% | ___ |
| User Satisfaction (1-5) | ___ | ___ | ___ |
| Avg Match Score | ___ | ___ | ___ |

**Expected Results**:
- O*NET scoring increases application rate by 10-20%
- Cross-sector exploration increases by 30-50%
- User satisfaction increases by 0.3-0.5 points

**Decision**: If O*NET wins, set `isONetScoringEnabled = true` for 100% rollout

---

### Integration 6: O*NET Data → Phase 6 Analytics Dashboard

**O*NET Provides**:
- Thompson P95 latency with O*NET scoring
- O*NET database load times
- O*NET profile completeness percentage
- Cross-sector job matching rates

**Phase 6 Monitors** (Week 24, Days 19-20):

**Firebase Performance**:
- Thompson P50/P95/P99 latency with O*NET
- O*NET database load times (5 databases)
- Alert if P95 >10ms

**Firebase Analytics**:
- `onet_scoring_used` event
- `onet_profile_completed` (% completion)
- `onet_cross_sector_match` (Amber→Teal)
- `onet_code_mapped` (job title mapping success)

**KPIs**:
| KPI | Target | Alert Threshold |
|-----|--------|----------------|
| Thompson P95 latency | <10ms | >12ms |
| O*NET job coverage | >80% | <70% |
| Profile completion | >60% | <50% |
| Cross-sector exploration | >30% | <20% |

---

## Dependencies Summary

### O*NET Plan Dependencies on Phase 4-6

**NONE** - O*NET plan is self-contained and can run independently.

### Phase 4 Dependencies on O*NET Plan

**Optional** - Phase 4 Liquid Glass UI works without O*NET data.
- **Optional Enhancement** (Day 11-12): Profile completeness indicator using O*NET fields

### Phase 5 Dependencies on O*NET Plan

**Recommended** - Phase 5 course recommendations work without O*NET but are better with it.
- **Required**: O*NET Phase 3 Task 3.3 provides UI scaffold and skill gap logic
- **Optional Enhancement** (Day 5-7): O*NET knowledge areas + education level matching improve recommendations by 10-20%

### Phase 6 Dependencies on O*NET Plan

**Required** - Phase 6 production hardening validates O*NET integration.
- **Required** (Week 21): Performance profiling of O*NET Thompson scoring
- **Required** (Week 22): O*NET vs skills-only A/B test
- **Required** (Week 22): Job title → O*NET code mapping
- **Required** (Week 24): O*NET analytics dashboard

---

## Recommended Integration Strategy

### Option 1: Sequential (Safest)

```
1. Complete O*NET Week 0-6 (180 hours)
2. Start Phase 4 (Week 13-17) - Liquid Glass UI
3. Start Phase 5 (Week 18-20) - Course integration uses O*NET data
4. Start Phase 6 (Week 21-24) - Validates O*NET performance
```

**Pros**: Clean dependencies, no conflicts
**Cons**: Delays Phase 4 start by 6 weeks

---

### Option 2: Parallel (Recommended)

```
Week 1-6:   O*NET Integration (this plan)
Week 3-16:  V8 Phase 2 (Foundation Models) - runs in parallel
Week 3-12:  V8 Phase 3 (Profile Expansion) - runs in parallel
Week 13-17: V8 Phase 4 (Liquid Glass UI) - starts after Week 6, O*NET data available
Week 18-20: V8 Phase 5 (Course Integration) - uses O*NET data
Week 21-24: V8 Phase 6 (Production Hardening) - validates O*NET
```

**Pros**: Faster overall timeline, O*NET data ready for Phase 4
**Cons**: Requires coordination between O*NET and V8 Phase 2/3 teams

**Recommendation**: **Use Option 2 (Parallel)** - O*NET runs concurrently with V8 Phase 2/3, finishes by Week 6, data available for Phase 4-6.

---

## Action Items

### For O*NET Integration Plan

- [x] ✅ Add Week 0 pre-implementation phase (8 hours)
- [x] ✅ Fix Industry enum to 19 sectors (remove meta-categories)
- [x] ✅ Add Sendable compliance throughout Phase 1
- [x] ✅ Add Thompson <10ms validation to Phase 2
- [x] ✅ Add async O*NET loading with actors (Phase 2)
- [x] ✅ Add radar chart accessibility (Phase 2)
- [x] ✅ Update time estimates (160 → 180 hours)
- [ ] **NEW**: Add note in Phase 3 Task 3.3 that this is UI scaffold only, full API integration comes in V8 Phase 5

### For Phase 4 (Liquid Glass UI)

- [ ] **Optional**: If implementing profile completeness UI (Day 11-12), reference O*NET data from Week 2-3:
  - Education level (1-12)
  - Work activities (41 dimensions)
  - RIASEC interests (6 dimensions)

### For Phase 5 (Course Integration)

- [ ] **Required**: Use O*NET Phase 3 Task 3.3 UI scaffold as starting point
- [ ] **Optional**: Implement O*NET enhancement (Day 5-7):
  - Use O*NET knowledge areas for skill gap analysis
  - Match course difficulty to user's education level
  - Recommend courses based on work activities

### For Phase 6 (Production Hardening)

- [ ] **Required** (Week 21): Validate Thompson O*NET scoring <10ms
- [ ] **Required** (Week 21): Configure CI/CD to fail builds if P95 >10ms
- [ ] **Required** (Week 22): Implement job title → O*NET code mapper
- [ ] **Required** (Week 22): Run O*NET vs skills-only A/B test
- [ ] **Required** (Week 24): Set up O*NET analytics dashboard

---

## Conclusion

**The O*NET Integration Implementation Plan is well-aligned with Phases 4-6:**

1. **Timeline**: O*NET runs Weeks 0-6, finishes before Phase 4 starts (Week 13)
2. **Dependencies**: Phase 5 and 6 **require** O*NET data; Phase 4 **optionally** uses it
3. **Conflicts**: **None** - O*NET provides data, Phases 4-6 consume it
4. **Integration Points**: 6 clear integration points identified and documented
5. **Sacred Constraints**: Both plans enforce <10ms Thompson, WCAG 2.1 AA, Swift 6 compliance

**Recommendation**:
- **Proceed with O*NET Integration Plan as written** (180 hours, 6.5 weeks)
- **Run O*NET in parallel with V8 Phase 2/3** (Weeks 0-6)
- **Phase 5 and 6 teams** should review O*NET plan for integration dependencies

**Status**: ✅ Plans are compatible and complementary.
