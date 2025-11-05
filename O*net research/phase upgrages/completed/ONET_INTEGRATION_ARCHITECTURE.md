# O*NET Integration Architecture - ManifestAndMatch V8
## Phase 2B: UserProfile Enhancement & Thompson Scoring Integration

**Document Version:** 1.0
**Created:** October 28, 2025
**Status:** 🟢 DESIGN COMPLETE - READY FOR IMPLEMENTATION
**Last Updated:** October 28, 2025

---

## Executive Summary

This document defines the complete architecture for integrating 5 O*NET databases (15MB data) into ManifestAndMatch V8's UserProfile and Thompson Sampling systems. The integration unlocks Amber→Teal career discovery while maintaining the sacred <10ms Thompson performance constraint.

**Key Metrics:**
- **Data Extracted:** 5 databases, 894 occupations, ~15MB
- **Performance Budget:** 8ms available (10ms total - 2ms existing)
- **Thompson Enhancement:** 40% skills + 60% O*NET data (5 factors)
- **Expected Impact:** Enable cross-sector career discovery for 100% of users

---

## 1. Current State Assessment

### ✅ Phase 2A Complete: Data Extraction
- [x] ONetCredentialsParser.swift (176 occupations, 200KB)
- [x] ONetWorkActivitiesParser.swift (894 occupations, 1.9MB)
- [x] ONetKnowledgeParser.swift (894 occupations, 1.4MB)
- [x] ONetInterestsParser.swift (923 occupations, 0.45MB)
- [x] ONetAbilitiesParser.swift (894 occupations, 11.3MB)
- [x] All JSON databases in V7Core/Resources/

### 🔴 Phase 2B Pending: Integration
- [ ] Data models for all 5 databases
- [ ] ONetDataService actor for loading/caching
- [ ] UserProfile extension with O*NET fields
- [ ] Thompson scoring algorithm updates
- [ ] Performance validation (<10ms P95)

---

## 2. Sacred Constraints Matrix

| Guardian Skill | Constraint | Integration Risk | Mitigation |
|----------------|------------|------------------|------------|
| **thompson-performance-guardian** | <10ms P95 | 🔴 HIGH | Pre-computed lookups, hash maps, progressive loading |
| **swift-concurrency-enforcer** | No data races | 🟡 MEDIUM | Actor isolation, Sendable types, @MainActor UI |
| **privacy-security-guardian** | On-device | 🟢 LOW | All data embedded in bundle, no network calls |
| **bias-detection-guardian** | 19 sectors | 🟢 LOW | O*NET already sector-mapped in parsers |
| **v7-architecture-guardian** | Naming patterns | 🟡 MEDIUM | Follow V7/V8 conventions strictly |
| **cost-optimization-watchdog** | No AI costs | 🟢 LOW | O*NET data free, static lookups |
| **accessibility-compliance-enforcer** | WCAG 2.1 AA | 🟢 LOW | O*NET enhances matching, no UI changes |

**Overall Risk:** 🟡 MEDIUM (Performance is critical path)

---

## 3. Performance Budget Analysis

### Current Thompson Performance
```
Skills matching:     ~2.0ms  (existing, 100% weight)
Overhead:            ~0.5ms  (job loading, cache)
────────────────────────────────────────────────
Current Total:       ~2.5ms  (well under 10ms)
Available Budget:    ~7.5ms  (for O*NET integration)
```

### Proposed Thompson Performance with O*NET
```
┌─────────────────────────────┬────────┬─────────┬──────────┐
│ Component                   │ Time   │ Weight  │ Priority │
├─────────────────────────────┼────────┼─────────┼──────────┤
│ Skills matching             │ 2.0ms  │ 40%     │ P0       │
│ Education match             │ 0.8ms  │ 15%     │ P1       │
│ Experience match            │ 0.8ms  │ 15%     │ P1       │
│ Work activities match       │ 1.5ms  │ 15%     │ P0       │
│ RIASEC interests match      │ 1.0ms  │ 10%     │ P2       │
│ Abilities match             │ 1.0ms  │ 5%      │ P2       │
│ Cache lookups/overhead      │ 1.4ms  │ -       │ -        │
├─────────────────────────────┼────────┼─────────┼──────────┤
│ TOTAL                       │ 8.5ms  │ 100%    │ -        │
└─────────────────────────────┴────────┴─────────┴──────────┘

P95 Target: <10.0ms ✅ (15% margin)
P50 Target: <6.0ms ✅ (expected ~5ms)
```

**Performance Strategy:**
1. **Pre-compute all O*NET lookups** (O(1) hash map access, not O(n) iteration)
2. **Progressive data loading** (credentials first, abilities last)
3. **Lazy matching** (only compute needed components)
4. **Cache strategy** (occupation lookups cached per job)

---

## 4. Architecture Design: 3-Layer Integration

```
┌────────────────────────────────────────────────────────────┐
│  LAYER 1: Data Models (V7Core/Models/)                     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ ONetDataModels.swift                                 │  │
│  │ - Codable structs matching all 5 JSON schemas       │  │
│  │ - Value types (struct) for performance              │  │
│  │ - Hashable for dictionary keys                      │  │
│  │ - Sendable for Swift 6 concurrency                  │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────┐
│  LAYER 2: Data Service (V7Core/Services/)                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ ONetDataService.swift (actor)                        │  │
│  │ - Bundle.main.url(forResource:) loading             │  │
│  │ - JSONDecoder with custom strategies                │  │
│  │ - Lazy initialization (load on first access)        │  │
│  │ - O(1) lookup dictionaries [onetCode: Data]         │  │
│  │ - Memory management (release abilities after use)   │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
                            ↓
┌────────────────────────────────────────────────────────────┐
│  LAYER 3: Thompson Integration (V7Thompson/)               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ ThompsonSampling+ONet.swift                          │  │
│  │ - Weighted scoring algorithm                         │  │
│  │ - 5 fast matching functions:                         │  │
│  │   • matchEducation(user:job:) -> Double             │  │
│  │   • matchExperience(user:job:) -> Double            │  │
│  │   • matchActivities(user:job:) -> Double            │  │
│  │   • matchInterests(user:job:) -> Double             │  │
│  │   • matchAbilities(user:job:) -> Double             │  │
│  │ - Cache-friendly data access patterns               │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

### Layer 1: Data Models Structure

```swift
// ONetDataModels.swift
// Location: Packages/V7Core/Sources/V7Core/Models/ONetDataModels.swift

// MARK: - Credentials (Education/Experience/Training)
struct ONetCredentials: Codable, Sendable {
    let version: String
    let occupations: [OccupationCredentials]

    // Fast lookup optimization
    private var _lookup: [String: OccupationCredentials]?
    func occupation(for onetCode: String) -> OccupationCredentials?
}

struct OccupationCredentials: Codable, Sendable, Hashable {
    let onetCode: String
    let title: String
    let sector: String
    let jobZone: Int
    let educationRequirements: EducationRequirements
    let experienceRequirements: ExperienceRequirements
    let trainingRequirements: TrainingRequirements
}

// MARK: - Work Activities
struct ONetWorkActivities: Codable, Sendable {
    let version: String
    let occupations: [OccupationWorkActivities]

    private var _lookup: [String: OccupationWorkActivities]?
    func occupation(for onetCode: String) -> OccupationWorkActivities?
}

struct OccupationWorkActivities: Codable, Sendable, Hashable {
    let onetCode: String
    let title: String
    let sector: String
    let activities: [String: ActivityRating]  // [activityId: rating]
    let topActivities: [String]  // Top 5 by importance
}

// MARK: - Knowledge Areas
struct ONetKnowledge: Codable, Sendable {
    let version: String
    let occupations: [OccupationKnowledge]

    private var _lookup: [String: OccupationKnowledge]?
    func occupation(for onetCode: String) -> OccupationKnowledge?
}

// MARK: - Interests (RIASEC)
struct ONetInterests: Codable, Sendable {
    let version: String
    let occupations: [OccupationInterests]

    private var _lookup: [String: OccupationInterests]?
    func occupation(for onetCode: String) -> OccupationInterests?
}

struct OccupationInterests: Codable, Sendable, Hashable {
    let onetCode: String
    let riasecProfile: RIASECProfile
    let hollandCode: String  // e.g., "RIA", "SEC"
    let dominantInterest: String
}

struct RIASECProfile: Codable, Sendable, Hashable {
    let realistic: Double
    let investigative: Double
    let artistic: Double
    let social: Double
    let enterprising: Double
    let conventional: Double

    // Cosine similarity for matching
    func similarity(to other: RIASECProfile) -> Double
}

// MARK: - Abilities (52 abilities)
struct ONetAbilities: Codable, Sendable {
    let version: String
    let occupations: [OccupationAbilities]

    private var _lookup: [String: OccupationAbilities]?
    func occupation(for onetCode: String) -> OccupationAbilities?
}
```

### Layer 2: Data Service Architecture

```swift
// ONetDataService.swift
// Location: Packages/V7Core/Sources/V7Core/Services/ONetDataService.swift

actor ONetDataService {
    // Singleton
    static let shared = ONetDataService()

    // Lazy-loaded databases (progressive loading)
    private var credentials: ONetCredentials?
    private var workActivities: ONetWorkActivities?
    private var knowledge: ONetKnowledge?
    private var interests: ONetInterests?
    private var abilities: ONetAbilities?

    // Memory management flags
    private var isAbilitiesLoadedAndReleased = false

    // MARK: - Public API

    func loadCredentials() async throws -> ONetCredentials {
        if let cached = credentials { return cached }
        credentials = try await load("onet_credentials")
        return credentials!
    }

    func loadWorkActivities() async throws -> ONetWorkActivities {
        if let cached = workActivities { return cached }
        workActivities = try await load("onet_work_activities")
        return workActivities!
    }

    func loadInterests() async throws -> ONetInterests {
        if let cached = interests { return cached }
        interests = try await load("onet_interests")
        return interests!
    }

    func loadKnowledge() async throws -> ONetKnowledge {
        if let cached = knowledge { return cached }
        knowledge = try await load("onet_knowledge")
        return knowledge!
    }

    func loadAbilities() async throws -> ONetAbilities {
        if let cached = abilities { return cached }
        abilities = try await load("onet_abilities")
        return abilities!
    }

    // Release abilities to save memory (11MB)
    func releaseAbilities() {
        abilities = nil
        isAbilitiesLoadedAndReleased = true
    }

    // MARK: - Private Loading

    private func load<T: Decodable>(_ resourceName: String) async throws -> T {
        guard let url = Bundle.main.url(
            forResource: resourceName,
            withExtension: "json",
            subdirectory: "Resources"
        ) else {
            throw ONetError.resourceNotFound(resourceName)
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

enum ONetError: Error {
    case resourceNotFound(String)
    case decodingFailed(String)
    case occupationNotFound(String)
}
```

### Layer 3: Thompson Scoring Integration

```swift
// ThompsonSampling+ONet.swift
// Location: Packages/V7Thompson/Sources/V7Thompson/ThompsonSampling+ONet.swift

extension ThompsonSampler {
    // MARK: - Enhanced Scoring with O*NET

    func computeONetScore(
        for job: Job,
        userProfile: UserProfile,
        onetService: ONetDataService
    ) async throws -> Double {

        // Weight distribution (total = 100%)
        let weights = ONetWeights(
            skills: 0.40,          // 40% - Core competencies
            education: 0.15,       // 15% - Education requirements
            experience: 0.15,      // 15% - Work experience
            activities: 0.15,      // 15% - Work activities (Amber→Teal)
            interests: 0.10,       // 10% - RIASEC personality fit
            abilities: 0.05        // 5%  - Physical/cognitive capabilities
        )

        // Parallel score computation
        async let skillsScore = matchSkills(job: job, profile: userProfile)
        async let educationScore = matchEducation(job: job, profile: userProfile, onetService: onetService)
        async let experienceScore = matchExperience(job: job, profile: userProfile, onetService: onetService)
        async let activitiesScore = matchActivities(job: job, profile: userProfile, onetService: onetService)
        async let interestsScore = matchInterests(job: job, profile: userProfile, onetService: onetService)
        async let abilitiesScore = matchAbilities(job: job, profile: userProfile, onetService: onetService)

        let scores = try await (
            skills: skillsScore,
            education: educationScore,
            experience: experienceScore,
            activities: activitiesScore,
            interests: interestsScore,
            abilities: abilitiesScore
        )

        // Weighted combination
        let totalScore =
            scores.skills * weights.skills +
            scores.education * weights.education +
            scores.experience * weights.experience +
            scores.activities * weights.activities +
            scores.interests * weights.interests +
            scores.abilities * weights.abilities

        return totalScore
    }

    // MARK: - Individual Matching Functions

    private func matchEducation(
        job: Job,
        profile: UserProfile,
        onetService: ONetDataService
    ) async throws -> Double {
        // Fast O(1) lookup by O*NET code
        guard let onetCode = job.metadata.onetCode else { return 0.5 }
        let credentials = try await onetService.loadCredentials()
        guard let occCredentials = credentials.occupation(for: onetCode) else { return 0.5 }

        // Compare user education level with job requirement
        let userLevel = profile.educationLevel ?? 0
        let requiredLevel = occCredentials.educationRequirements.requiredLevel

        if userLevel >= requiredLevel {
            return 1.0  // Meets or exceeds requirement
        } else {
            // Partial credit for close matches
            let gap = Double(requiredLevel - userLevel)
            return max(0.0, 1.0 - (gap * 0.15))
        }
    }

    private func matchExperience(
        job: Job,
        profile: UserProfile,
        onetService: ONetDataService
    ) async throws -> Double {
        guard let onetCode = job.metadata.onetCode else { return 0.5 }
        let credentials = try await onetService.loadCredentials()
        guard let occCredentials = credentials.occupation(for: onetCode) else { return 0.5 }

        // Compare years of experience
        let userYears = profile.yearsOfExperience ?? 0.0
        let requiredYears = occCredentials.experienceRequirements.minimumYears

        if userYears >= requiredYears {
            return 1.0
        } else {
            let ratio = userYears / max(requiredYears, 0.1)
            return min(1.0, ratio)
        }
    }

    private func matchActivities(
        job: Job,
        profile: UserProfile,
        onetService: ONetDataService
    ) async throws -> Double {
        // THE GAME CHANGER: Amber→Teal cross-domain discovery
        guard let onetCode = job.metadata.onetCode else { return 0.5 }
        let activities = try await onetService.loadWorkActivities()
        guard let occActivities = activities.occupation(for: onetCode) else { return 0.5 }

        // User's transferable activities (from previous roles)
        guard let userActivities = profile.workActivities else { return 0.5 }

        // Calculate overlap with importance weighting
        var totalImportance = 0.0
        var matchedImportance = 0.0

        for (activityId, activityRating) in occActivities.activities {
            totalImportance += activityRating.importance

            if let userRating = userActivities[activityId] {
                // Both have this activity - weight by minimum
                let matchStrength = min(userRating, activityRating.importance)
                matchedImportance += matchStrength
            }
        }

        guard totalImportance > 0 else { return 0.5 }
        return matchedImportance / totalImportance
    }

    private func matchInterests(
        job: Job,
        profile: UserProfile,
        onetService: ONetDataService
    ) async throws -> Double {
        guard let onetCode = job.metadata.onetCode else { return 0.5 }
        let interests = try await onetService.loadInterests()
        guard let occInterests = interests.occupation(for: onetCode) else { return 0.5 }

        // User's RIASEC profile (from assessment or inferred)
        guard let userRiasec = profile.riasecProfile else { return 0.5 }

        // Cosine similarity between RIASEC vectors
        return occInterests.riasecProfile.similarity(to: userRiasec)
    }

    private func matchAbilities(
        job: Job,
        profile: UserProfile,
        onetService: ONetDataService
    ) async throws -> Double {
        // Abilities are lowest priority (5% weight)
        // Only load if profile has ability data
        guard profile.hasAbilityData else { return 0.5 }

        guard let onetCode = job.metadata.onetCode else { return 0.5 }
        let abilities = try await onetService.loadAbilities()
        guard let occAbilities = abilities.occupation(for: onetCode) else { return 0.5 }

        // Calculate ability match (similar to activities)
        // ... implementation details ...

        return 0.7  // Placeholder
    }
}

struct ONetWeights {
    let skills: Double
    let education: Double
    let experience: Double
    let activities: Double
    let interests: Double
    let abilities: Double
}
```

---

## 5. UserProfile Extension Design

### Current UserProfile (V7/V8)
```swift
// Packages/V7Core/Sources/V7Core/Models/UserProfile.swift

struct UserProfile: Codable, Sendable {
    // Existing fields
    var skills: [String]
    var experience: [WorkExperience]
    var preferences: JobPreferences

    // ... other V7 fields ...
}
```

### Enhanced UserProfile with O*NET
```swift
// Packages/V7Core/Sources/V7Core/Models/UserProfile+ONet.swift

extension UserProfile {
    // MARK: - O*NET Enhancement Fields

    /// Education level (1-12, maps to O*NET EducationLevel enum)
    /// 1=Less than HS, 6=Bachelor's, 8=Master's, 11=Doctoral
    var educationLevel: Int?

    /// Years of work experience across all roles
    var yearsOfExperience: Double?

    /// Work activities profile (extracted from resume or self-reported)
    /// Key: O*NET activity ID (e.g., "4.A.2.a.4" = Analyzing Data)
    /// Value: Proficiency/importance (0.0-7.0)
    var workActivities: [String: Double]?

    /// RIASEC interest profile (from assessment or inferred)
    var riasecProfile: RIASECProfile?

    /// User's Holland Code (top 3 interests, e.g., "RIA")
    var hollandCode: String?

    /// Knowledge areas from formal education/training
    /// Key: O*NET knowledge ID (e.g., "2.C.3.a" = Computers and Electronics)
    /// Value: Level (0.0-7.0)
    var knowledgeAreas: [String: Double]?

    /// Abilities (optional, only for roles requiring specific capabilities)
    var abilities: [String: Double]?

    // MARK: - Computed Properties

    var hasONetData: Bool {
        educationLevel != nil ||
        yearsOfExperience != nil ||
        workActivities != nil ||
        riasecProfile != nil
    }

    var hasAbilityData: Bool {
        abilities != nil && !abilities!.isEmpty
    }

    // MARK: - Profile Enhancement from Resume

    mutating func enhanceFromResume(_ extractedData: ResumeExtraction) {
        // Map extracted education to O*NET levels
        self.educationLevel = mapEducationLevel(extractedData.education)

        // Calculate total experience
        self.yearsOfExperience = extractedData.workHistory
            .reduce(0.0) { $0 + $1.durationYears }

        // Infer work activities from job descriptions
        self.workActivities = inferActivities(
            from: extractedData.workHistory,
            using: ActivityInferenceEngine.shared
        )

        // Infer RIASEC from career choices
        self.riasecProfile = inferInterests(
            from: extractedData.workHistory,
            using: InterestInferenceEngine.shared
        )

        // Extract knowledge from education/training
        self.knowledgeAreas = extractKnowledge(
            from: extractedData.education,
            and: extractedData.certifications
        )
    }
}

// MARK: - Resume Extraction (iOS 26 Foundation Models)

struct ResumeExtraction: Sendable {
    let education: [Education]
    let workHistory: [WorkHistoryItem]
    let certifications: [Certification]
    let skills: [String]
}

struct Education: Codable, Sendable {
    let degree: String  // "Bachelor of Science", "Master of Arts"
    let field: String   // "Computer Science", "Biology"
    let institution: String
    let year: Int?
}

struct WorkHistoryItem: Codable, Sendable {
    let title: String
    let company: String
    let startDate: Date
    let endDate: Date?
    let description: String
    let durationYears: Double
}
```

---

## 6. Implementation Plan: Phased Rollout

### Phase 1: Foundation (Zero Risk) - 45 minutes
**Goal:** Data models + service infrastructure with no behavior changes

```
Task 1.1: Create ONetDataModels.swift
  - Location: Packages/V7Core/Sources/V7Core/Models/
  - Content: All 5 database struct definitions
  - Requirements: Codable, Sendable, Hashable, O(1) lookups
  - Tests: Decode all 5 JSON files, validate structure
  - Guardian: swift-concurrency-enforcer (actor-safe types)

Task 1.2: Create ONetDataService.swift
  - Location: Packages/V7Core/Sources/V7Core/Services/
  - Content: Actor-based service, lazy loading, caching
  - Requirements: Bundle loading, error handling, memory management
  - Tests: Load each database, measure memory/time
  - Guardian: performance-engineer (measure load times)

Task 1.3: Add Unit Tests
  - Location: Packages/V7Core/Tests/V7CoreTests/
  - Coverage: Data model decoding, service loading, edge cases
  - Validate: All 5 databases decode without errors
  - Guardian: testing-qa-strategist (test design)
```

**Success Criteria:**
- ✅ All 5 JSON files decode successfully
- ✅ ONetDataService loads data in <100ms cold start
- ✅ Memory usage <3MB for typical usage
- ✅ Unit test coverage >90%
- ✅ Zero behavior changes to existing app

**Validation Command:**
```bash
swift test --package-path "Packages/V7Core" --filter ONetTests
```

---

### Phase 2: Profile Enhancement (Low Risk) - 30 minutes
**Goal:** Extend UserProfile with O*NET fields, no scoring changes yet

```
Task 2.1: Extend UserProfile model
  - Location: Packages/V7Core/Sources/V7Core/Models/
  - Add: educationLevel, yearsOfExperience, workActivities, etc.
  - Requirements: All fields optional (backward compatible)
  - Migration: Existing profiles continue working
  - Guardian: database-migration-specialist (safe schema changes)

Task 2.2: Add profile builder utilities
  - Location: Packages/V7Core/Sources/V7Core/Utilities/
  - Functions: mapEducationLevel(), inferActivities(), inferInterests()
  - Requirements: Pure functions, well-tested
  - Guardian: v7-architecture-guardian (naming conventions)

Task 2.3: Add iOS 26 Foundation Models integration
  - Location: Packages/V7Services/Sources/V7Services/AI/
  - Content: ResumeExtractor actor (wraps Foundation Models)
  - Requirements: On-device, privacy-preserving, error handling
  - Guardian: ios26-specialist (Foundation Models APIs)

Task 2.4: Add persistence for enhanced profile
  - Location: Packages/V7Data/Sources/V7Data/
  - Update: UserProfile Core Data/SwiftData schema
  - Requirements: Migration from existing schema
  - Guardian: core-data-specialist (migration safety)
```

**Success Criteria:**
- ✅ UserProfile backward compatible (existing profiles work)
- ✅ Resume extraction extracts education + experience correctly
- ✅ Profile enhancement populates O*NET fields
- ✅ Data persists across app launches
- ✅ Still no changes to Thompson scoring (disabled until Phase 3)

**Validation:**
- Test with 10 sample resumes
- Verify education level mapping accuracy >90%
- Verify experience calculation within 10% of actual

---

### Phase 3: Thompson Integration (HIGH RISK) - 60 minutes
**Goal:** Integrate O*NET into Thompson scoring, validate <10ms

```
Task 3.1: Implement weighted scoring algorithm
  - Location: Packages/V7Thompson/Sources/V7Thompson/
  - Create: ThompsonSampling+ONet.swift
  - Functions: computeONetScore(), all 5 matching functions
  - Requirements: <8ms total execution time
  - Guardian: thompson-performance-guardian (CRITICAL)

Task 3.2: Optimize for performance
  - Strategy: Pre-compute lookups, hash maps, parallel async
  - Benchmark: Measure each matching function separately
  - Target: Skills 2ms, Education 0.8ms, Experience 0.8ms, etc.
  - Guardian: performance-engineer (profiling, optimization)

Task 3.3: Add feature flag
  - Location: Packages/V7Core/Sources/V7Core/Config/
  - Flag: isONetScoringEnabled (default: false)
  - Purpose: A/B testing, rollback safety
  - Guardian: app-narrative-guide (user impact assessment)

Task 3.4: Add performance tests
  - Location: Packages/V7Thompson/Tests/V7ThompsonTests/
  - Tests: Performance regression, accuracy validation
  - CI/CD: Fail build if P95 >10ms
  - Guardian: performance-regression-detector (automated checks)

Task 3.5: Gradual rollout
  - Day 1: 10% of users (A/B test)
  - Day 3: 50% of users (monitor metrics)
  - Day 7: 100% of users (full rollout)
```

**Success Criteria:**
- ✅ Thompson scoring P95 <10ms (measured on iPhone 12)
- ✅ Thompson scoring P50 <6ms
- ✅ Matching accuracy improved vs skills-only baseline
- ✅ Amber→Teal cross-sector recommendations working
- ✅ No crashes, no data races, no memory leaks
- ✅ Feature flag allows instant rollback

**Performance Validation:**
```swift
// Performance test
func testThompsonONetPerformance() {
    measure {
        let score = try await sampler.computeONetScore(
            for: testJob,
            userProfile: testProfile,
            onetService: .shared
        )
    }
    // Assert: P95 < 10ms, P50 < 6ms
}
```

---

## 7. Risk Mitigation Strategy

### Risk 1: Thompson Performance Regression 🔴 HIGH
**Threat:** O*NET matching breaks <10ms constraint, 357x advantage lost

**Mitigation:**
1. **Pre-compute all lookups:** Use hash maps [onetCode: Data] for O(1) access
2. **Parallel async execution:** Compute all 5 scores concurrently
3. **Progressive optimization:** Start with slow implementation, optimize iteratively
4. **Performance tests in CI/CD:** Fail build if regression detected
5. **Feature flag:** Instant rollback if production issues

**Validation:**
- Benchmark on iPhone 12 (minimum target device)
- Measure P50, P95, P99 latencies
- Test with 1000 jobs, 100 user profiles
- Monitor production metrics (Firebase Performance)

**Fallback:**
- Disable O*NET scoring via feature flag
- Revert to skills-only matching
- Investigate bottleneck offline

---

### Risk 2: Memory Pressure on Older Devices 🟡 MEDIUM
**Threat:** 15MB O*NET data causes memory warnings/crashes

**Mitigation:**
1. **Progressive loading:** Load only what's needed (credentials first, abilities last)
2. **Memory budget:** Monitor via Instruments, target <50MB total
3. **Release abilities:** After matching, release 11MB abilities data
4. **Reduced dataset:** If needed, ship only top 500 occupations

**Validation:**
- Test on iPhone 12 (3GB RAM)
- Monitor memory warnings in Xcode Instruments
- Stress test with 100 concurrent job matches

**Fallback:**
- Ship "lite" version with reduced dataset
- Disable abilities matching (5% weight, minimal impact)

---

### Risk 3: iOS 26 Foundation Models Unavailable 🟡 MEDIUM
**Threat:** Foundation Models API not available on user's device

**Mitigation:**
1. **Version detection:** Check iOS version, use FM only on iOS 26+
2. **Manual fallback:** Allow manual profile entry if FM unavailable
3. **Graceful degradation:** Use skills-only matching if no O*NET data
4. **Mock for testing:** Abstract behind protocol, easy to test

**Validation:**
- Test on iOS 25.x devices (should fallback gracefully)
- Test with FM disabled (feature flag)
- Verify manual entry works

**Fallback:**
- Traditional profile creation form
- Skills-only Thompson scoring

---

### Risk 4: O*NET Data Staleness 🟢 LOW
**Threat:** O*NET data becomes outdated (published yearly)

**Mitigation:**
1. **Version field in JSON:** Track O*NET database version
2. **Update check:** Prompt user to update app if new data available
3. **Quarterly refresh:** Re-run parsers when O*NET updates
4. **Graceful handling:** Stale data still valuable, doesn't break app

**Validation:**
- Document parser update workflow
- Automate parser execution in CI/CD
- Version compatibility checks

**Fallback:**
- Continue with stale data (1-2 years old still useful)
- Manual parser re-run as needed

---

### Risk 5: Swift 6 Concurrency Violations 🟡 MEDIUM
**Threat:** Data races, actor isolation violations

**Mitigation:**
1. **Actor isolation:** All mutable state in actors
2. **Sendable types:** All data models conform to Sendable
3. **@MainActor for UI:** UI updates on main thread
4. **Strict concurrency checking:** Enable in Xcode 26

**Validation:**
- Enable Swift 6 strict concurrency mode
- Run Thread Sanitizer in debug builds
- Code review with swift-concurrency-enforcer

**Fallback:**
- Fix violations before shipping
- No runtime crashes acceptable

---

## 8. Testing Strategy

### Unit Tests (Fast, <1s total)
```
✓ ONetDataModels decoding (all 5 databases)
✓ ONetDataService loading (mock Bundle)
✓ UserProfile+ONet field mapping
✓ Matching functions (education, experience, etc.)
✓ Edge cases (missing data, malformed JSON)
✓ RIASEC similarity calculations
✓ Education level mapping accuracy
```

### Integration Tests (Medium, <10s total)
```
✓ End-to-end profile enhancement flow
✓ Resume extraction → Profile → Thompson scoring
✓ Cross-sector job recommendations
✓ Progressive data loading (credentials → activities → abilities)
✓ Memory management (release abilities after use)
✓ Feature flag toggling (enable/disable O*NET scoring)
```

### Performance Tests (Slow, ~60s total)
```
✓ Thompson scoring P95 <10ms (1000 jobs)
✓ Thompson scoring P50 <6ms (1000 jobs)
✓ Memory usage <50MB (iPhone 12)
✓ Cold start <100ms (app launch)
✓ Data loading times (all 5 databases)
✓ Parallel async matching performance
```

### UI Tests (Manual, ~30 minutes)
```
✓ Profile creation flow with resume upload
✓ Job recommendations quality (do they make sense?)
✓ Amber→Teal suggestions (cross-sector jobs shown?)
✓ Education/experience filtering works
✓ RIASEC personality assessment integration
```

### A/B Testing (Production, 7 days)
```
Control Group (50%): Skills-only matching
Treatment Group (50%): O*NET-enhanced matching

Metrics to track:
  • Job application rate (expect +20%)
  • User satisfaction (surveys)
  • Cross-sector applications (expect +100%)
  • Thompson latency P95 (must stay <10ms)
  • Crash rate (must stay <0.1%)
```

---

## 9. Success Criteria & Metrics

### Must Have (Blocking Ship)
- ✅ Thompson scoring P95 <10ms maintained
- ✅ All 5 O*NET databases integrated
- ✅ UserProfile enhanced with O*NET fields
- ✅ Swift 6 strict concurrency compliance
- ✅ Unit test coverage >80%
- ✅ No memory leaks detected
- ✅ No crashes in 1000 test runs

### Should Have (Target)
- ✅ Amber→Teal cross-domain matching functional
- ✅ Education/experience filtering working
- ✅ RIASEC interests matching implemented
- ✅ Performance tests in CI/CD pipeline
- ✅ A/B testing framework deployed
- ✅ Feature flag for instant rollback

### Nice to Have (Future)
- 🎯 iOS 26 Foundation Models integration
- 🎯 Automated O*NET data updates (quarterly)
- 🎯 Machine learning for weight optimization
- 🎯 User feedback loop (thumbs up/down on recommendations)
- 🎯 Analytics dashboard for matching quality

### Key Performance Indicators (KPIs)

| Metric | Baseline | Target | Method |
|--------|----------|--------|--------|
| Thompson P95 latency | 2.5ms | <10ms | Firebase Performance |
| Job application rate | 8% | 10% | Analytics event tracking |
| Cross-sector applications | 2% | 10% | Sector mismatch analysis |
| User satisfaction (1-5) | 3.2 | 3.8 | In-app survey |
| Profile completion rate | 45% | 70% | Onboarding funnel |
| Crash rate | 0.08% | <0.10% | Firebase Crashlytics |

---

## 10. Deployment Plan

### Pre-Launch Checklist
```
[ ] All unit tests passing
[ ] All integration tests passing
[ ] Performance tests passing (P95 <10ms)
[ ] Code review approved (2+ reviewers)
[ ] Guardian sign-offs:
    [ ] thompson-performance-guardian (performance validated)
    [ ] swift-concurrency-enforcer (no data races)
    [ ] v7-architecture-guardian (naming conventions)
    [ ] privacy-security-guardian (on-device processing)
    [ ] ios26-specialist (iOS 26 APIs correct)
[ ] Documentation complete (this document + inline comments)
[ ] Feature flag tested (enable/disable works)
[ ] Rollback plan documented
[ ] Monitoring dashboards configured
```

### Rollout Timeline

**Day 0 (Code Freeze):**
- Merge Phase 1 + 2 (Foundation + Profile Enhancement)
- Deploy to TestFlight (internal)
- QA team testing (2 days)

**Day 2 (Beta):**
- Deploy to TestFlight (external beta, 100 users)
- Monitor crash rate, performance metrics
- Collect user feedback

**Day 5 (Soft Launch):**
- Deploy to production with feature flag OFF
- Verify deployment successful (no regressions)
- Enable feature flag for 10% of users

**Day 7 (Expansion):**
- If metrics look good, expand to 50%
- Monitor A/B test results
- Investigate any anomalies

**Day 10 (Full Rollout):**
- If all clear, expand to 100%
- Disable feature flag (always-on)
- Publish release notes

**Day 14 (Post-Launch Review):**
- Analyze KPIs vs targets
- User feedback review
- Plan Phase 4 enhancements

---

## 11. Rollback Plan

### Scenario 1: Performance Regression (P95 >10ms)
**Detection:** Firebase Performance alerts, CI/CD tests

**Action:**
1. Set feature flag `isONetScoringEnabled = false`
2. App immediately reverts to skills-only matching
3. No app update required (server-side flag)
4. Investigate bottleneck offline
5. Fix, test, re-enable gradually

**Timeline:** <5 minutes to disable, 1-2 days to fix

---

### Scenario 2: Crash Rate Spike (>0.2%)
**Detection:** Firebase Crashlytics alerts

**Action:**
1. Set feature flag `isONetScoringEnabled = false`
2. Analyze crash logs (identify culprit)
3. Hotfix if critical, otherwise schedule fix
4. Re-test thoroughly before re-enabling

**Timeline:** <5 minutes to disable, 1-2 days for hotfix

---

### Scenario 3: User Complaints (Poor Recommendations)
**Detection:** App Store reviews, support tickets

**Action:**
1. Keep feature enabled (not critical)
2. Collect examples of poor recommendations
3. Adjust weights or matching algorithms
4. A/B test improvements
5. Deploy iterative fixes

**Timeline:** 1-2 weeks for data collection + fix

---

### Scenario 4: Memory Issues (Crashes on iPhone 12)
**Detection:** Crashlytics, memory warnings

**Action:**
1. Set feature flag `isONetScoringEnabled = false`
2. Implement memory optimizations:
   - More aggressive abilities release
   - Reduce dataset size
   - Optimize data structures
3. Re-test on iPhone 12
4. Re-enable gradually

**Timeline:** 2-3 days for optimization

---

## 12. Monitoring & Observability

### Real-Time Metrics (Firebase Performance)
```
• Thompson scoring latency (P50, P95, P99)
• O*NET data loading time
• Memory usage (peak, average)
• Crash rate by device model
• Feature flag adoption rate
```

### User Behavior Metrics (Firebase Analytics)
```
• Job application rate (overall, cross-sector)
• Profile completion rate
• Resume upload success rate
• Time spent on job recommendations
• Swipe patterns (accept/reject)
```

### Business Metrics (Custom Dashboard)
```
• Amber→Teal conversion rate (user switches sectors)
• Education-based filtering usage
• Experience-based filtering usage
• RIASEC assessment completion rate
• User retention (30-day, 90-day)
```

### Alerting Rules
```
🚨 CRITICAL (page on-call):
  - Thompson P95 >10ms for 5 minutes
  - Crash rate >0.5% for 5 minutes
  - Feature flag toggle fails

⚠️ WARNING (Slack notification):
  - Thompson P95 >8ms for 15 minutes
  - Memory usage >40MB for 15 minutes
  - Job application rate drops >20%

ℹ️ INFO (daily digest):
  - A/B test results summary
  - User feedback highlights
  - Performance trends (weekly)
```

---

## 13. Documentation Requirements

### Code Documentation (Inline)
```swift
/// Matches user education level with job requirements using O*NET credentials data.
///
/// This function implements the education component of Thompson scoring, contributing
/// 15% of the total match score. It compares the user's education level (1-12 scale)
/// with the job's required education level from O*NET data.
///
/// **Performance:** O(1) lookup in credentials dictionary, <0.8ms target
/// **Accuracy:** 95% for jobs with clear education requirements
///
/// - Parameters:
///   - job: The job to match against
///   - profile: The user's profile with education data
///   - onetService: Service for accessing O*NET credentials data
/// - Returns: Match score (0.0-1.0), or 0.5 if data unavailable
/// - Throws: `ONetError.resourceNotFound` if credentials data missing
///
/// # Example
/// ```swift
/// let score = try await matchEducation(
///     job: softwareEngineerJob,
///     profile: userWithBachelors,
///     onetService: .shared
/// )
/// // Returns: 1.0 (Bachelor's meets requirement)
/// ```
///
/// # Sacred Constraint
/// - **thompson-performance-guardian:** Must complete in <0.8ms P95
///
/// # See Also
/// - `matchExperience(_:profile:onetService:)` for experience matching
/// - `ONetCredentials` for data structure
private func matchEducation(
    job: Job,
    profile: UserProfile,
    onetService: ONetDataService
) async throws -> Double
```

### Architecture Documentation (This File)
- ✅ This document (`ONET_INTEGRATION_ARCHITECTURE.md`)
- Location: `O*net research/phase upgrades/`
- Keep updated as implementation evolves

### User-Facing Documentation (Help Center)
```
- "How We Match You with Jobs" (explain O*NET integration)
- "Understanding Your Profile" (education, experience, interests)
- "Exploring New Careers" (Amber→Teal concept)
- "Why We Ask About Your Education" (privacy-preserving)
```

### API Documentation (if public SDK)
```
- ONetDataService public API
- UserProfile+ONet extension methods
- ThompsonSampling+ONet scoring functions
```

---

## 14. Future Enhancements (Post-Launch)

### Phase 4: Machine Learning Weight Optimization (Q1 2026)
**Goal:** Use ML to optimize Thompson weights per user

**Approach:**
- Collect user feedback (thumbs up/down on recommendations)
- Train lightweight model to predict optimal weights
- A/B test learned weights vs fixed weights
- Personalize weights based on user behavior

**Expected Impact:** +15% job application rate

---

### Phase 5: Career Path Recommendations (Q2 2026)
**Goal:** Suggest 3-step career progressions using O*NET

**Approach:**
- Build graph of occupation transitions
- Use O*NET data to find "stepping stone" jobs
- Show user: Current → Step 1 → Step 2 → Target
- Highlight skill gaps to close

**Expected Impact:** +30% user engagement

---

### Phase 6: Automated O*NET Updates (Q3 2026)
**Goal:** Keep O*NET data fresh without manual re-parsing

**Approach:**
- Monitor O*NET database for updates (RSS feed)
- Trigger automated parser runs in CI/CD
- Generate new JSON databases
- Deploy to production via OTA update

**Expected Impact:** Always-fresh data, <1 hour staleness

---

### Phase 7: Explainable Recommendations (Q4 2026)
**Goal:** Show users WHY each job was recommended

**Approach:**
- Break down Thompson score into components
- Show: "Matched on: Education (90%), Activities (75%), Interests (80%)"
- Highlight: "You have Marketing experience, this role needs it"
- Build trust through transparency

**Expected Impact:** +25% job application rate

---

## 15. Appendix: Reference Materials

### O*NET Resources
- **Website:** https://www.onetcenter.org/
- **Database Version:** O*NET 30.0 (August 2025)
- **License:** CC BY 4.0 (attribution required)
- **Update Frequency:** Annually
- **Documentation:** https://www.onetcenter.org/database.html

### Related Documents
- `PHASE_1_COMPLETION_REPORT.md` - Skills system bias fix
- `ONET_PROFILE_ENHANCEMENT_OPPORTUNITIES.md` - Initial O*NET analysis
- `ONET_CREDENTIALS_DATA_ANALYSIS.md` - Credentials data structure
- `JobSourceHelpers.swift` - 19-sector taxonomy reference

### Guardian Skill References
- `thompson-performance-guardian` - <10ms enforcement
- `swift-concurrency-enforcer` - Swift 6 compliance
- `v7-architecture-guardian` - V7/V8 patterns
- `ios26-specialist` - iOS 26 API guidance
- `performance-engineer` - Optimization strategies

### Key File Locations
```
O*NET Data (JSON):
  Packages/V7Core/Sources/V7Core/Resources/
    - onet_credentials.json (200KB)
    - onet_work_activities.json (1.9MB)
    - onet_knowledge.json (1.4MB)
    - onet_interests.json (0.45MB)
    - onet_abilities.json (11.3MB)

O*NET Parsers (Swift):
  manifest and match V8/Data/ONET_Skills/
    - ONetCredentialsParser.swift
    - ONetWorkActivitiesParser.swift
    - ONetKnowledgeParser.swift
    - ONetInterestsParser.swift
    - ONetAbilitiesParser.swift

Implementation (To Be Created):
  Packages/V7Core/Sources/V7Core/Models/
    - ONetDataModels.swift
    - UserProfile+ONet.swift

  Packages/V7Core/Sources/V7Core/Services/
    - ONetDataService.swift

  Packages/V7Thompson/Sources/V7Thompson/
    - ThompsonSampling+ONet.swift
```

---

## 16. Sign-Off Requirements

Before marking this phase complete, ALL guardians must validate:

### thompson-performance-guardian ⏱️
- [ ] Thompson P95 <10ms validated on iPhone 12
- [ ] Performance tests pass in CI/CD
- [ ] No regression from baseline (2.5ms → <10ms)
- [ ] 357x competitive advantage preserved

### swift-concurrency-enforcer 🔒
- [ ] All data models Sendable
- [ ] ONetDataService properly actor-isolated
- [ ] No data race warnings in Thread Sanitizer
- [ ] Swift 6 strict concurrency mode enabled

### v7-architecture-guardian 🏗️
- [ ] Naming conventions followed (V7/V8 patterns)
- [ ] File organization correct (Models, Services, Thompson)
- [ ] No violations of sacred constraints
- [ ] Code review approved

### privacy-security-guardian 🛡️
- [ ] All O*NET data on-device (no network calls)
- [ ] User data never sent to third parties
- [ ] Keychain used for sensitive data (if any)
- [ ] Privacy manifest updated

### ios26-specialist 📱
- [ ] Foundation Models APIs used correctly
- [ ] iOS 26 features properly feature-flagged
- [ ] Backward compatibility with iOS 25
- [ ] Year-based versioning conventions followed

### performance-engineer 🔬
- [ ] Memory profiling complete (Instruments)
- [ ] CPU profiling complete (Time Profiler)
- [ ] Memory usage <50MB validated
- [ ] No memory leaks detected

### testing-qa-strategist ✅
- [ ] Unit test coverage >80%
- [ ] Integration tests passing
- [ ] Performance tests passing
- [ ] Manual QA checklist complete

### app-narrative-guide 🎯
- [ ] Feature aligns with Amber→Teal mission
- [ ] User experience improved (not degraded)
- [ ] Cross-sector discovery enabled
- [ ] No unintended consequences identified

---

## 17. Implementation Status

### Current Status: 🟢 DESIGN COMPLETE - READY FOR IMPLEMENTATION

```
Phase 2A: Data Extraction
  ✅ ONetCredentialsParser.swift
  ✅ ONetWorkActivitiesParser.swift
  ✅ ONetKnowledgeParser.swift
  ✅ ONetInterestsParser.swift
  ✅ ONetAbilitiesParser.swift
  ✅ All JSON databases in V7Core/Resources/

Phase 2B: Integration (NEXT)
  ⏳ Task 1: Data Models + Service (Foundation)
  ⏳ Task 2: UserProfile Extension (Profile Enhancement)
  ⏳ Task 3: Thompson Integration (Performance Critical)
```

### Next Action
**Invoke ios26-v8-upgrade-coordinator to begin Task 1: Data Models + Service**

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Oct 28, 2025 | Claude Code + ios26-v8-upgrade-coordinator | Initial architecture document |

**Approval:** Ready for implementation upon guardian sign-off

**Review Cycle:** Update after each phase completion

**Archival:** Keep in `O*net research/phase upgrades/` permanently

---

END OF DOCUMENT
