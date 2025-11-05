# O*NET Integration - Remaining Work (Single Source of Truth)
## Manifest & Match iOS26 V8 - Phase 2B/3 Completion Checklist

**Created:** October 28, 2025
**Status:** 🔴 IN PROGRESS - 70% Complete (Foundation Done, Production Integration Pending)
**Source Documents:**
- `ONET_INTEGRATION_STRATEGY.md` (Option E - Hybrid Approach)
- `ONET_INTEGRATION_ARCHITECTURE.md` (Phase 2B Implementation Plan)

**Overall Progress:**
- ✅ Phase 2A: Data Extraction (100% Complete)
- ✅ Phase 2B Layer 1: Data Models & Service (100% Complete)
- ⚠️ Phase 2B Layer 2: Profile Enhancement (60% Complete)
- ❌ Phase 2B Layer 3: Thompson Integration (30% Complete - Code exists, not connected)
- ❌ Phase 3: Production Deployment (0% Complete)

---

## 🔴 CRITICAL PATH - Must Complete for Production

These items block production deployment. Without them, O*NET integration is non-functional.

### CRITICAL-1: Connect Thompson Engine to O*NET Scoring
**Priority:** P0 - BLOCKING
**Estimated Time:** 2 hours
**Owner:** TBD
**Status:** ❌ NOT STARTED

**Problem:**
- `ThompsonSampling+ONet.swift` exists with full scoring implementation
- `ThompsonSamplingEngine` doesn't call `computeONetScore()` in production flow
- O*NET data is loaded but never used for job recommendations

**Required Changes:**
```swift
// Location: Packages/V7Thompson/Sources/V7Thompson/ThompsonSamplingEngine.swift

extension ThompsonSamplingEngine {
    func scoreJob(
        _ job: Job,
        userProfile: UserProfile,
        useONet: Bool = true  // Feature flag control
    ) async throws -> Double {

        // EXISTING: Base Thompson score (skills-only)
        let baseScore = await computeBaseScore(job, userProfile)

        // NEW: O*NET-enhanced score (if enabled and O*NET code available)
        if useONet, let onetCode = job.onetCode {
            let onetScore = try await computeONetScore(
                for: job,
                profile: userProfile.professionalProfile,
                onetCode: onetCode
            )

            // Weighted combination: 40% skills + 60% O*NET
            return (baseScore * 0.40) + (onetScore * 0.60)
        }

        // Fallback: Skills-only if O*NET unavailable
        return baseScore
    }
}
```

**Acceptance Criteria:**
- [ ] `ThompsonSamplingEngine.scoreJob()` calls `computeONetScore()` when O*NET code available
- [ ] Weighted scoring: 40% skills + 60% O*NET (5 factors)
- [ ] Graceful fallback to skills-only when O*NET code missing
- [ ] Performance: P95 latency stays <10ms
- [ ] Unit tests: Verify weighted combination math
- [ ] Integration tests: End-to-end job scoring with O*NET data

**Source:**
- Architecture doc §4 lines 313-361 (weighted scoring algorithm)
- Strategy doc §5 Option E Layer 2 lines 1006-1074 (Thompson integration)

---

### CRITICAL-2: Persist O*NET Profile Fields in Core Data
**Priority:** P0 - BLOCKING
**Estimated Time:** 3 hours
**Owner:** TBD
**Status:** ❌ NOT STARTED

**Problem:**
- `ProfessionalProfile` struct has O*NET fields (education, experience, activities, interests)
- `UserProfile+CoreData.swift` does NOT persist these fields
- User data is lost on app restart

**Required Changes:**

**Step 1: Update Core Data Model**
```swift
// Location: Packages/V7Data/Sources/V7Data/ManifestAndMatchV7.xcdatamodeld

// Add to UserProfile entity:
- educationLevel: Integer 16 (Optional)
- yearsOfExperience: Double (Optional)
- workActivitiesJSON: String (Optional)  // JSON-encoded [String: Double]
- riasecProfileJSON: String (Optional)   // JSON-encoded RIASECProfile
- abilitiesJSON: String (Optional)       // JSON-encoded [String: Double]
```

**Step 2: Add Computed Properties**
```swift
// Location: Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift

extension UserProfile {
    // MARK: - O*NET Fields (Computed from JSON)

    var workActivities: [String: Double]? {
        get {
            guard let json = workActivitiesJSON else { return nil }
            return try? JSONDecoder().decode([String: Double].self, from: json.data(using: .utf8)!)
        }
        set {
            workActivitiesJSON = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }

    var riasecProfile: RIASECProfile? {
        get {
            guard let json = riasecProfileJSON else { return nil }
            return try? JSONDecoder().decode(RIASECProfile.self, from: json.data(using: .utf8)!)
        }
        set {
            riasecProfileJSON = newValue.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        }
    }

    // Convert to ProfessionalProfile for Thompson
    func toProfessionalProfile() -> ProfessionalProfile {
        return ProfessionalProfile(
            skills: self.skills ?? [],
            educationLevel: self.educationLevel > 0 ? Int(self.educationLevel) : nil,
            yearsOfExperience: self.yearsOfExperience > 0 ? self.yearsOfExperience : nil,
            workActivities: self.workActivities,
            interests: self.riasecProfile,
            abilities: self.abilities
        )
    }
}
```

**Step 3: Create Migration**
```swift
// Location: Packages/V7Data/Sources/V7Data/Migrations/

// Lightweight migration (all fields Optional, no data loss)
// No custom migration code needed - Core Data auto-migrates
```

**Acceptance Criteria:**
- [ ] Core Data model updated with 5 new Optional fields
- [ ] Existing user profiles migrate without data loss
- [ ] O*NET fields persist across app restarts
- [ ] JSON encoding/decoding works for complex types (dictionaries, RIASECProfile)
- [ ] `UserProfile.toProfessionalProfile()` converts to Thompson-compatible format
- [ ] Migration tested on iOS 26 simulator + physical device

**Source:**
- Architecture doc §5 lines 491-606 (UserProfile extension design)
- Architecture doc Phase 2 Task 2.4 lines 678-679 (persistence requirement)

---

### CRITICAL-3: Add Feature Flag System
**Priority:** P0 - BLOCKING
**Estimated Time:** 1 hour
**Owner:** TBD
**Status:** ❌ NOT STARTED

**Problem:**
- No way to gradually roll out O*NET integration
- No instant rollback mechanism if performance degrades
- Cannot A/B test O*NET vs skills-only matching

**Required Changes:**

**Step 1: Create FeatureFlags**
```swift
// Location: Packages/V7Core/Sources/V7Core/Configuration/FeatureFlags.swift

import Foundation

/// Feature flags for gradual rollout and instant rollback
///
/// **Usage:**
/// ```swift
/// if await FeatureFlags.shared.isONetScoringEnabled {
///     // Use O*NET-enhanced scoring
/// } else {
///     // Fall back to skills-only
/// }
/// ```
@MainActor
public class FeatureFlags: ObservableObject {
    public static let shared = FeatureFlags()

    // MARK: - O*NET Integration Flags

    /// Enable O*NET-enhanced Thompson scoring
    /// - Default: false (disabled)
    /// - Rollout: 10% → 50% → 100% over 7 days
    /// - Rollback: Set to false instantly via remote config
    @Published public var isONetScoringEnabled: Bool = false

    /// Enable iOS 26 Foundation Models resume parsing
    /// - Default: false (manual entry only)
    /// - Requires: iOS 26+
    @Published public var isResumeParsingEnabled: Bool = false

    /// Enable abilities matching (lowest priority, 5% weight)
    /// - Default: true (if O*NET enabled)
    /// - Memory optimization: Can disable to save 11MB
    @Published public var isAbilitiesMatchingEnabled: Bool = true

    // MARK: - Remote Config (Future: Firebase Remote Config)

    /// Load flags from remote config service
    /// For now, uses UserDefaults for local testing
    public func loadRemoteConfig() async {
        // TODO: Integrate Firebase Remote Config
        // For now: Load from UserDefaults
        self.isONetScoringEnabled = UserDefaults.standard.bool(forKey: "feature.onet.enabled")
        self.isResumeParsingEnabled = UserDefaults.standard.bool(forKey: "feature.resume.enabled")
        self.isAbilitiesMatchingEnabled = UserDefaults.standard.bool(forKey: "feature.abilities.enabled")
    }

    /// Override flags for testing
    public func setOverride(onetEnabled: Bool? = nil, resumeEnabled: Bool? = nil) {
        if let onet = onetEnabled {
            self.isONetScoringEnabled = onet
            UserDefaults.standard.set(onet, forKey: "feature.onet.enabled")
        }
        if let resume = resumeEnabled {
            self.isResumeParsingEnabled = resume
            UserDefaults.standard.set(resume, forKey: "feature.resume.enabled")
        }
    }
}
```

**Step 2: Integrate with Thompson Engine**
```swift
// Use in CRITICAL-1 implementation:
let useONet = await FeatureFlags.shared.isONetScoringEnabled
let score = try await scoreJob(job, userProfile, useONet: useONet)
```

**Acceptance Criteria:**
- [ ] `FeatureFlags.swift` created with 3 flags (O*NET, Resume, Abilities)
- [ ] Flags stored in UserDefaults (migration path to Firebase Remote Config)
- [ ] Thompson engine respects `isONetScoringEnabled` flag
- [ ] Admin can toggle flags without app update (UserDefaults for now)
- [ ] Unit tests: Verify flag-controlled behavior switching

**Source:**
- Architecture doc Phase 3 Task 3.3 lines 712-716 (feature flag requirement)
- Architecture doc §11 lines 1010-1066 (rollback plan using feature flags)

---

## 🟡 HIGH PRIORITY - Needed for Robust Production

These items are strongly recommended before launch but not absolute blockers.

### HIGH-1: iOS 26 Foundation Models Resume Parsing
**Priority:** P1 - HIGH
**Estimated Time:** 4 hours
**Owner:** TBD
**Status:** ❌ NOT STARTED

**Problem:**
- Profile enhancement relies on manual data entry or basic keyword inference
- No intelligent resume parsing using iOS 26 Foundation Models API
- User onboarding friction (must manually enter education, experience, etc.)

**Required Changes:**

**Step 1: Create ResumeExtractor Actor**
```swift
// Location: Packages/V7Services/Sources/V7Services/AI/ResumeExtractor.swift

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Extracts professional profile data from resume PDF/image using iOS 26 Foundation Models
///
/// **Requirements:**
/// - iOS 26+ (Foundation Models API)
/// - On-device processing (privacy-preserving)
/// - Fallback to manual entry on iOS 25 or parsing failure
///
/// **Usage:**
/// ```swift
/// let extractor = ResumeExtractor()
/// let data = try await extractor.extractFromResume(pdfData)
///
/// // Use data to populate ProfessionalProfile
/// let profile = ProfessionalProfile(
///     skills: data.skills,
///     educationLevel: mapEducationLevel(data.education.first?.degree),
///     yearsOfExperience: calculateYearsOfExperience(from: data.workHistory),
///     workActivities: inferWorkActivities(from: data.workHistory),
///     interests: inferRIASECInterests(from: data.workHistory)
/// )
/// ```
@available(iOS 26.0, *)
public actor ResumeExtractor {

    public init() {}

    /// Extract structured data from resume PDF or image
    ///
    /// **Performance:** 2-5 seconds for typical resume
    /// **Privacy:** On-device processing, data never leaves device
    ///
    /// - Parameter resumeData: PDF or image data
    /// - Returns: Extracted professional data
    /// - Throws: `ResumeError` if parsing fails
    public func extractFromResume(_ resumeData: Data) async throws -> ResumeExtraction {
        // TODO: Implement iOS 26 Foundation Models integration
        // For now: Placeholder implementation

        // Step 1: Detect document type (PDF vs image)
        let documentType = detectDocumentType(resumeData)

        // Step 2: Extract text using Vision/PDFKit
        let rawText = try await extractText(from: resumeData, type: documentType)

        // Step 3: Structure extraction using Foundation Models (PLACEHOLDER)
        // Replace with actual Foundation Models API when available
        let structured = try await parseStructuredData(from: rawText)

        return structured
    }

    // MARK: - Helper Methods

    private func detectDocumentType(_ data: Data) -> DocumentType {
        // Check PDF magic number
        if data.prefix(4) == Data([0x25, 0x50, 0x44, 0x46]) {
            return .pdf
        }
        // Check image formats (JPEG, PNG)
        if data.prefix(2) == Data([0xFF, 0xD8]) { return .jpeg }
        if data.prefix(4) == Data([0x89, 0x50, 0x4E, 0x47]) { return .png }

        return .unknown
    }

    private func extractText(from data: Data, type: DocumentType) async throws -> String {
        // TODO: Use Vision framework for images, PDFKit for PDFs
        // Placeholder: Return empty string
        return ""
    }

    private func parseStructuredData(from text: String) async throws -> ResumeExtraction {
        // TODO: Use iOS 26 Foundation Models API for intelligent parsing
        // Placeholder: Return empty extraction
        return ResumeExtraction(
            education: [],
            workHistory: [],
            certifications: [],
            skills: []
        )
    }
}

enum DocumentType {
    case pdf
    case jpeg
    case png
    case unknown
}

public enum ResumeError: Error {
    case unsupportedFormat
    case extractionFailed(Error)
    case parsingFailed(String)
}

/// Extracted resume data structure
public struct ResumeExtraction: Sendable {
    public let education: [Education]
    public let workHistory: [WorkHistoryItem]
    public let certifications: [Certification]
    public let skills: [String]

    public init(
        education: [Education],
        workHistory: [WorkHistoryItem],
        certifications: [Certification],
        skills: [String]
    ) {
        self.education = education
        self.workHistory = workHistory
        self.certifications = certifications
        self.skills = skills
    }
}

public struct Education: Codable, Sendable {
    public let degree: String
    public let field: String
    public let institution: String
    public let year: Int?

    public init(degree: String, field: String, institution: String, year: Int? = nil) {
        self.degree = degree
        self.field = field
        self.institution = institution
        self.year = year
    }
}

public struct Certification: Codable, Sendable {
    public let name: String
    public let issuer: String
    public let year: Int?

    public init(name: String, issuer: String, year: Int? = nil) {
        self.name = name
        self.issuer = issuer
        self.year = year
    }
}
```

**Step 2: Integrate with Profile Enhancement**
```swift
// Location: Packages/V7Services/Sources/V7Services/Profile/ProfileEnhancementService.swift

public actor ProfileEnhancementService {

    @available(iOS 26.0, *)
    public func enhanceFromResume(
        _ resumeData: Data,
        existingProfile: ProfessionalProfile
    ) async throws -> ProfessionalProfile {

        // Extract data using Foundation Models
        let extractor = ResumeExtractor()
        let extracted = try await extractor.extractFromResume(resumeData)

        // Enhance profile using ProfileBuilderUtilities
        let enhanced = enhanceProfile(
            existingSkills: existingProfile.skills + extracted.skills,
            education: extracted.education.first?.degree,
            workHistory: extracted.workHistory
        )

        return ProfessionalProfile(
            skills: enhanced.skills,
            educationLevel: enhanced.educationLevel,
            yearsOfExperience: enhanced.yearsOfExperience,
            workActivities: enhanced.workActivities,
            interests: enhanced.interests,
            abilities: existingProfile.abilities  // Keep existing
        )
    }
}
```

**Acceptance Criteria:**
- [ ] `ResumeExtractor.swift` created with iOS 26 availability check
- [ ] PDF and image resume parsing implemented
- [ ] Structured data extraction (education, work history, skills)
- [ ] Integration with `enhanceProfile()` from ProfileBuilderUtilities
- [ ] Graceful fallback to manual entry on iOS 25 or parsing failure
- [ ] Feature flag integration (`FeatureFlags.isResumeParsingEnabled`)
- [ ] Privacy manifest updated (on-device processing disclosed)

**Source:**
- Architecture doc Phase 2 Task 2.3 lines 661-679 (Foundation Models integration)
- Architecture doc §5 lines 583-605 (resume enhancement workflow)

---

### HIGH-2: Performance Regression Detection in CI/CD
**Priority:** P1 - HIGH
**Estimated Time:** 2 hours
**Owner:** TBD
**Status:** ⚠️ PARTIAL (tests exist, not in CI/CD)

**Problem:**
- `ThompsonONetPerformanceTests.swift` exists but doesn't fail builds
- No automated enforcement of <10ms sacred constraint
- Performance regressions could slip into production

**Required Changes:**

**Step 1: Configure Xcode Test Plans**
```xml
<!-- Location: ManifestAndMatchV7.xctestplan -->

<testplan version="1.0">
    <test-configurations>
        <test-configuration name="Performance Validation">
            <test-target name="ThompsonONetPerformanceTests">
                <skipped-tests>
                    <!-- None - all performance tests must pass -->
                </skipped-tests>
                <test-execution-ordering>random</test-execution-ordering>
                <parallel-testing>false</parallel-testing>
                <maximum-test-execution-time>300</maximum-test-execution-time>
            </test-target>
        </test-configuration>
    </test-configurations>

    <test-performance-baselines>
        <baseline name="Thompson P95 Latency" threshold="10.0ms"/>
        <baseline name="Thompson P50 Latency" threshold="6.0ms"/>
    </test-performance-baselines>
</testplan>
```

**Step 2: Update Performance Test**
```swift
// Location: Packages/V7Thompson/Tests/V7ThompsonTests/ThompsonONetPerformanceTests.swift

// Add to existing testThompsonONetPerformance() test:

func testThompsonONetPerformance_CIEnforcement() async throws {
    // Warmup: First 10 iterations to populate caches
    for _ in 0..<10 {
        _ = try await engine.computeONetScore(
            for: testJob,
            profile: testProfile,
            onetCode: "15-1252.00"
        )
    }

    // Measure: 100 iterations for statistical significance
    var measurements: [TimeInterval] = []
    for _ in 0..<100 {
        let start = CFAbsoluteTimeGetCurrent()
        _ = try await engine.computeONetScore(
            for: testJob,
            profile: testProfile,
            onetCode: "15-1252.00"
        )
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        measurements.append(elapsed * 1000.0)  // Convert to ms
    }

    // Statistical analysis
    let sorted = measurements.sorted()
    let p50 = sorted[50]
    let p95 = sorted[95]
    let p99 = sorted[99]

    print("""
    📊 Thompson O*NET Performance (100 iterations):
       P50: \(String(format: "%.2f", p50))ms
       P95: \(String(format: "%.2f", p95))ms
       P99: \(String(format: "%.2f", p99))ms
    """)

    // SACRED CONSTRAINT ENFORCEMENT (thompson-performance-guardian)
    // CI/CD build MUST FAIL if these assertions fail
    XCTAssertLessThan(
        p95,
        10.0,
        "❌ SACRED CONSTRAINT VIOLATED: Thompson P95 latency (\(p95)ms) exceeded 10ms threshold. 357x competitive advantage at risk."
    )

    XCTAssertLessThan(
        p50,
        6.0,
        "⚠️ WARNING: Thompson P50 latency (\(p50)ms) exceeded 6ms target (safe but suboptimal)."
    )
}
```

**Step 3: GitHub Actions CI/CD (if using)**
```yaml
# Location: .github/workflows/performance-tests.yml

name: Performance Validation

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  performance-tests:
    runs-on: macos-14  # Xcode 16+
    steps:
      - uses: actions/checkout@v3

      - name: Run Performance Tests
        run: |
          xcodebuild test \
            -workspace ManifestAndMatchV7.xcworkspace \
            -scheme ManifestAndMatchV7 \
            -testPlan PerformanceValidation \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -resultBundlePath TestResults.xcresult

      - name: Check for Sacred Constraint Violations
        run: |
          # Parse xcresult for test failures
          xcrun xcresulttool get --path TestResults.xcresult \
            --format json | jq '.issues.testFailureSummaries[] | select(.message | contains("SACRED CONSTRAINT"))'

          # Fail CI if violations found
          if [ $? -eq 0 ]; then
            echo "❌ Performance regression detected - blocking merge"
            exit 1
          fi
```

**Acceptance Criteria:**
- [ ] `ThompsonONetPerformanceTests` updated with warmup iterations
- [ ] Test assertions fail build if P95 > 10ms or P50 > 6ms
- [ ] CI/CD pipeline runs performance tests on every PR
- [ ] Build blocks merge if performance regressions detected
- [ ] Performance baselines tracked over time (trend analysis)

**Source:**
- Architecture doc Phase 3 Task 3.4 lines 717-727 (performance testing)
- Architecture doc §2 lines 59-97 (performance budget)
- Architecture doc Appendix C lines 1836-1914 (performance test script)

---

### HIGH-3: Job Source O*NET Code Mapping
**Priority:** P1 - HIGH
**Estimated Time:** 3 hours
**Owner:** TBD
**Status:** ❌ NOT STARTED

**Problem:**
- Jobs from Indeed/LinkedIn/ZipRecruiter don't have O*NET codes
- Cannot use O*NET scoring without occupation code mapping
- Need intelligent job title → O*NET code inference

**Required Changes:**

**Step 1: Create O*NET Code Mapper**
```swift
// Location: Packages/V7Services/Sources/V7Services/JobSources/ONetCodeMapper.swift

import Foundation
import V7Core

/// Maps job titles to O*NET occupation codes using fuzzy matching
///
/// **Strategy:**
/// 1. Exact title match (e.g., "Software Developer" → "15-1252.00")
/// 2. Keyword-based matching (e.g., "Senior iOS Engineer" → "15-1252.00")
/// 3. Fallback to sector-based inference (e.g., "Technology" → likely 15-*)
///
/// **Data Source:** O*NET credentials database (176 occupations)
@MainActor
public class ONetCodeMapper {

    private let service = ONetDataService.shared
    private var titleIndex: [String: String] = [:]  // [normalized title: onetCode]
    private var keywordIndex: [String: [String]] = [:]  // [keyword: [onetCodes]]

    public init() {}

    /// Initialize mapper by loading O*NET credentials
    public func loadIndex() async throws {
        let credentials = try await service.loadCredentials()

        // Build exact title index
        for occ in credentials.occupations {
            let normalized = occ.title.lowercased().trimmingCharacters(in: .whitespaces)
            titleIndex[normalized] = occ.onetCode

            // Build keyword index
            let keywords = normalized.components(separatedBy: .whitespaces)
            for keyword in keywords where keyword.count > 3 {
                keywordIndex[keyword, default: []].append(occ.onetCode)
            }
        }
    }

    /// Map job title to O*NET code (best guess)
    ///
    /// - Parameter jobTitle: Raw job title from job posting
    /// - Returns: O*NET code or nil if no match
    public func mapToONetCode(_ jobTitle: String) -> String? {
        let normalized = jobTitle.lowercased().trimmingCharacters(in: .whitespaces)

        // Strategy 1: Exact match
        if let code = titleIndex[normalized] {
            return code
        }

        // Strategy 2: Keyword-based voting
        let keywords = normalized.components(separatedBy: .whitespaces)
        var votes: [String: Int] = [:]

        for keyword in keywords where keyword.count > 3 {
            if let codes = keywordIndex[keyword] {
                for code in codes {
                    votes[code, default: 0] += 1
                }
            }
        }

        // Return code with most keyword matches
        if let winner = votes.max(by: { $0.value < $1.value }) {
            return winner.key
        }

        // Strategy 3: Common job title patterns
        return inferFromPattern(normalized)
    }

    /// Infer O*NET code from common job title patterns
    private func inferFromPattern(_ title: String) -> String? {
        // Software/Developer roles
        if title.contains("software") || title.contains("developer") || title.contains("engineer") && title.contains("ios") {
            return "15-1252.00"  // Software Developers, Applications
        }

        // Data roles
        if title.contains("data") && (title.contains("scientist") || title.contains("analyst")) {
            return "15-2051.00"  // Data Scientists
        }

        // Manager roles
        if title.contains("manager") || title.contains("director") {
            return "11-1021.00"  // General and Operations Managers
        }

        // Marketing roles
        if title.contains("marketing") && title.contains("manager") {
            return "11-2021.00"  // Marketing Managers
        }

        // Default: Unable to infer
        return nil
    }
}
```

**Step 2: Integrate with Job Sources**
```swift
// Location: Packages/V7Services/Sources/V7Services/JobSources/JobSourceProtocol.swift

extension JobSourceProtocol {
    /// Enrich job with O*NET code
    func enrichWithONetCode(_ job: inout Job, mapper: ONetCodeMapper) {
        if job.onetCode == nil {
            job.onetCode = mapper.mapToONetCode(job.title)
        }
    }
}
```

**Acceptance Criteria:**
- [ ] `ONetCodeMapper.swift` created with fuzzy matching
- [ ] Exact title matching implemented (high precision)
- [ ] Keyword-based voting implemented (medium precision)
- [ ] Pattern-based inference for common roles (low precision fallback)
- [ ] All job sources enriched with O*NET codes before scoring
- [ ] Unit tests: Verify mapping accuracy on 100 sample job titles
- [ ] Performance: Mapping <1ms per job (cached lookups)

**Source:**
- Strategy doc Option E Layer 3 lines 1075-1150 (job source integration)
- Architecture doc §4 lines 313-361 (O*NET code requirement for scoring)

---

## 🟢 NICE TO HAVE - Post-Launch Improvements

These items enhance the system but are not required for initial launch.

### NICE-1: Monitoring & Analytics Dashboard
**Priority:** P2 - NICE TO HAVE
**Estimated Time:** 4 hours
**Owner:** TBD
**Status:** ❌ NOT STARTED

**What to Build:**
1. Firebase Performance integration for Thompson latency tracking
2. Firebase Analytics events for O*NET usage metrics
3. Custom dashboard showing:
   - Thompson P50/P95/P99 latencies over time
   - O*NET scoring coverage (% of jobs with O*NET codes)
   - Cross-sector job applications (Amber→Teal transitions)
   - User profile completion rates (education, experience filled)

**Source:**
- Architecture doc §12 lines 1069-1114 (monitoring requirements)

---

### NICE-2: A/B Testing Framework
**Priority:** P2 - NICE TO HAVE
**Estimated Time:** 3 hours
**Owner:** TBD
**Status:** ❌ NOT STARTED

**What to Build:**
1. User bucketing (50% control, 50% treatment)
2. Treatment: O*NET-enhanced scoring
3. Control: Skills-only scoring
4. Metrics tracking:
   - Job application rate
   - User satisfaction (in-app surveys)
   - Time to first application
   - Cross-sector exploration rate

**Source:**
- Architecture doc §8 lines 902-913 (A/B testing strategy)
- Architecture doc §10 lines 976-1007 (deployment rollout plan)

---

### NICE-3: Automated O*NET Database Updates
**Priority:** P2 - NICE TO HAVE
**Estimated Time:** 2 hours
**Owner:** TBD
**Status:** ❌ NOT STARTED

**What to Build:**
1. CI/CD script to check for new O*NET database releases (quarterly)
2. Automated re-run of all 5 parsers when new data available
3. Automated test validation of new JSON databases
4. Deployment via app update (bundle new O*NET data)

**Source:**
- Architecture doc §14 Phase 6 lines 1212-1222 (automated updates)

---

### NICE-4: Explainable Recommendations
**Priority:** P2 - NICE TO HAVE
**Estimated Time:** 3 hours
**Owner:** TBD
**Status:** ❌ NOT STARTED

**What to Build:**
UI showing breakdown of Thompson score:
```
Why this job matches you:

✅ Skills Match: 92% (Swift, iOS, SwiftUI)
✅ Education: Bachelor's required, you have Master's (100%)
✅ Experience: 3 years required, you have 5 years (100%)
✅ Work Style: 85% match on "Analyzing Data" and "Problem Solving"
✅ Interests: RIA profile matches Investigative (95%)

Overall Match: 94%
```

**Source:**
- Architecture doc §14 Phase 7 lines 1223-1234 (explainability)

---

## 📋 Implementation Checklist Summary

### Week 1: Critical Path (P0 Items)
- [ ] **Day 1-2:** CRITICAL-1 - Connect Thompson Engine (2 hours)
- [ ] **Day 2-3:** CRITICAL-2 - Persist O*NET Fields (3 hours)
- [ ] **Day 3:** CRITICAL-3 - Add Feature Flags (1 hour)
- [ ] **Day 4-5:** End-to-end testing, bug fixes

**Deliverable:** O*NET integration functional in production with rollout control

### Week 2: High Priority (P1 Items)
- [ ] **Day 1-2:** HIGH-1 - iOS 26 Foundation Models Resume Parsing (4 hours)
- [ ] **Day 3:** HIGH-2 - Performance CI/CD Integration (2 hours)
- [ ] **Day 4-5:** HIGH-3 - Job Source O*NET Code Mapping (3 hours)

**Deliverable:** Robust production system with automated quality gates

### Week 3+: Nice to Have (P2 Items)
- [ ] NICE-1: Monitoring Dashboard
- [ ] NICE-2: A/B Testing Framework
- [ ] NICE-3: Automated O*NET Updates
- [ ] NICE-4: Explainable Recommendations

**Deliverable:** Enhanced system with observability and continuous improvement

---

## ✅ Completion Criteria - Definition of Done

**Phase 2B/3 is COMPLETE when:**

1. ✅ **Functional Integration**
   - Thompson engine scores jobs using O*NET data (5 factors)
   - User profiles persist O*NET fields across app restarts
   - Feature flags control O*NET rollout (instant enable/disable)

2. ✅ **Performance Validated**
   - Thompson P95 latency <10ms (verified on iPhone 12)
   - CI/CD blocks builds on performance regressions
   - No memory leaks detected (Instruments validation)

3. ✅ **Production Ready**
   - Unit tests: >80% coverage on O*NET modules
   - Integration tests: End-to-end job scoring with O*NET
   - Performance tests: 100 iterations, all <10ms P95
   - Manual QA: 10 user flows tested on physical device

4. ✅ **Guardian Sign-Offs**
   - [ ] thompson-performance-guardian: P95 <10ms validated
   - [ ] swift-concurrency-enforcer: No data races detected
   - [ ] v7-architecture-guardian: Naming conventions followed
   - [ ] privacy-security-guardian: On-device processing confirmed
   - [ ] ios26-specialist: Foundation Models correctly integrated

5. ✅ **Documentation Complete**
   - Inline code documentation (all public APIs)
   - Architecture diagram updated with O*NET integration
   - User-facing help docs: "How We Match You"
   - Privacy manifest: O*NET data usage disclosed

---

## 📊 Progress Tracking

**Last Updated:** October 28, 2025
**Next Review:** TBD
**Blockers:** None (all dependencies completed in Phase 2A/2B Layer 1)

| Priority | Item | Status | ETA | Owner |
|----------|------|--------|-----|-------|
| P0 | Connect Thompson Engine | ❌ Not Started | Week 1 Day 1-2 | TBD |
| P0 | Persist O*NET Fields | ❌ Not Started | Week 1 Day 2-3 | TBD |
| P0 | Feature Flags | ❌ Not Started | Week 1 Day 3 | TBD |
| P1 | iOS 26 Resume Parsing | ❌ Not Started | Week 2 Day 1-2 | TBD |
| P1 | Performance CI/CD | ⚠️ Partial | Week 2 Day 3 | TBD |
| P1 | O*NET Code Mapping | ❌ Not Started | Week 2 Day 4-5 | TBD |
| P2 | Monitoring Dashboard | ❌ Not Started | Week 3+ | TBD |
| P2 | A/B Testing | ❌ Not Started | Week 3+ | TBD |
| P2 | Automated Updates | ❌ Not Started | Week 3+ | TBD |
| P2 | Explainable Recs | ❌ Not Started | Week 3+ | TBD |

**Overall Completion:** 70% (Foundation complete, production integration pending)

---

## 🔗 Related Documents

- **Source 1:** `ONET_INTEGRATION_STRATEGY.md` (Option E - Hybrid Approach)
- **Source 2:** `ONET_INTEGRATION_ARCHITECTURE.md` (Phase 2B Technical Design)
- **Implementation:** See file paths in each task above
- **Tests:** `Packages/V7Thompson/Tests/V7ThompsonTests/ThompsonONetPerformanceTests.swift`

---

**END OF DOCUMENT**

**Action Required:** Review this checklist, assign owners, and begin Week 1 critical path items.
