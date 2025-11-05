# 06. Data Models

**Comprehensive Data Model Catalog for Manifest & Match V8**

## Overview

The application uses **32 data models** split across two persistence strategies:
- **14 Core Data entities** (persistent storage)
- **18 Swift structs** (in-memory/transient data)

## Core Data Entities (Persistent)

### 1. UserProfile
**Location**: `V7Data/Sources/V7Data/Models/UserProfile+CoreData.swift`
**Purpose**: Primary user profile with skills, preferences, and demographic data

```swift
@objc(UserProfile)
public class UserProfile: NSManagedObject {
    @NSManaged public var userID: UUID
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var location: String?
    @NSManaged public var resumeData: Data?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var skills: Set<Skill>
    @NSManaged public var workExperiences: Set<WorkExperience>
    @NSManaged public var educations: Set<Education>
    @NSManaged public var swipeHistory: Set<SwipeRecord>
}
```

**Key Fields**:
- `userID`: Unique identifier (UUID)
- `resumeData`: Binary PDF storage
- `createdAt/updatedAt`: Audit timestamps
- Relationships to Skills, WorkExperience, Education, SwipeRecord

**Thread Safety**: Uses `NSManagedObjectID` pattern for Sendable compliance

---

### 2. WorkExperience
**Location**: `V7Data/Sources/V7Data/Models/WorkExperience+CoreData.swift`
**Purpose**: Employment history with validation for timeline integrity

```swift
@objc(WorkExperience)
public class WorkExperience: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var jobTitle: String
    @NSManaged public var company: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var isCurrent: Bool
    @NSManaged public var responsibilities: String?
    @NSManaged public var achievements: String?

    // Relationship
    @NSManaged public var profile: UserProfile
}
```

**Validation Rules**:
- `startDate` must be < `endDate` (if not current)
- Cannot have overlapping date ranges for same profile
- `jobTitle` and `company` are required

**🚨 CRITICAL BUG**: `WorkExperienceCollectionStepView.swift:145` does NOT persist to Core Data

---

### 3. Education
**Location**: `V7Data/Sources/V7Data/Models/Education+CoreData.swift`
**Purpose**: Educational background and certifications

```swift
@objc(Education)
public class Education: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var institution: String
    @NSManaged public var degree: String?
    @NSManaged public var fieldOfStudy: String?
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var isCurrent: Bool
    @NSManaged public var gpa: Double?

    // Relationship
    @NSManaged public var profile: UserProfile
}
```

**🚨 CRITICAL BUG**: `EducationAndCertificationsStepView.swift:89` does NOT persist to Core Data

---

### 4. Skill
**Location**: `V7Data/Sources/V7Data/Models/Skill+CoreData.swift`
**Purpose**: Individual skills with proficiency levels (links to O*NET taxonomy)

```swift
@objc(Skill)
public class Skill: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var proficiencyLevel: Int16  // 1-5 scale
    @NSManaged public var onetSkillID: String?
    @NSManaged public var category: String?
    @NSManaged public var verified: Bool

    // Relationships
    @NSManaged public var userProfile: UserProfile?
    @NSManaged public var jobs: Set<JobCache>
}
```

**Proficiency Scale**:
1. Beginner
2. Intermediate
3. Advanced
4. Expert
5. Master

---

### 5. SwipeRecord
**Location**: `V7Data/Sources/V7Data/Models/SwipeRecord+CoreData.swift`
**Purpose**: Individual swipe decision with context (feeds Thompson Sampling)

```swift
@objc(SwipeRecord)
public class SwipeRecord: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var jobID: String
    @NSManaged public var swipeDirection: String  // "right", "left", "super"
    @NSManaged public var timestamp: Date
    @NSManaged public var thompsonScore: Double
    @NSManaged public var profileSnapshot: Data?  // JSON snapshot of user state
    @NSManaged public var sessionID: UUID
    @NSManaged public var cardPosition: Int16

    // Relationships
    @NSManaged public var userProfile: UserProfile
    @NSManaged public var thompsonArm: ThompsonArm?
}
```

**Swipe Types**:
- `right`: Interested
- `left`: Not interested
- `super`: Super interested (starred)

**Analytics**: `cardPosition` tracks deck position for fatigue analysis

---

### 6. ThompsonArm
**Location**: `V7Thompson/Sources/V7Thompson/Models/ThompsonArm+CoreData.swift`
**Purpose**: Beta distribution parameters for each job category (Thompson Sampling state)

```swift
@objc(ThompsonArm)
public class ThompsonArm: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var categoryID: String
    @NSManaged public var alphaParameter: Double
    @NSManaged public var betaParameter: Double
    @NSManaged public var successCount: Int32
    @NSManaged public var failureCount: Int32
    @NSManaged public var lastUpdated: Date
    @NSManaged public var profileType: String  // "amber" or "teal"

    // Relationships
    @NSManaged public var swipes: Set<SwipeRecord>
}
```

**Beta Distribution**:
- `alpha = successCount + 1`
- `beta = failureCount + 1`
- Higher alpha/beta ratio = better category performance

**Dual Profile**:
- **Amber**: Exploitation (favors known good categories)
- **Teal**: Exploration (tests new categories)

---

### 7. JobCache
**Location**: `V7Data/Sources/V7Data/Models/JobCache+CoreData.swift`
**Purpose**: Cached job listings with expiration management

```swift
@objc(JobCache)
public class JobCache: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var jobID: String
    @NSManaged public var sourceAPI: String  // "adzuna", "greenhouse", etc.
    @NSManaged public var rawJSON: Data
    @NSManaged public var cachedAt: Date
    @NSManaged public var expiresAt: Date
    @NSManaged public var thompsonScore: Double?
    @NSManaged public var displayedCount: Int16

    // Relationships
    @NSManaged public var requiredSkills: Set<Skill>
}
```

**Cache Strategy**:
- L1: In-memory (MemoryCache actor)
- L2: Core Data (this entity)
- L3: API calls (last resort)

**TTL**: 24 hours (configurable per source)

---

### 8. ONETOccupation
**Location**: `V7Data/Sources/V7Data/Models/ONETOccupation+CoreData.swift`
**Purpose**: O*NET occupation data (1,016 occupations cached locally)

```swift
@objc(ONETOccupation)
public class ONETOccupation: NSManagedObject {
    @NSManaged public var onetCode: String  // e.g., "15-1252.00"
    @NSManaged public var title: String
    @NSManaged public var description: String?
    @NSManaged public var riasecCode: String?  // Holland Code
    @NSManaged public var educationLevel: String?
    @NSManaged public var medianSalary: Int32

    // Relationships
    @NSManaged public var skills: Set<ONETSkill>
    @NSManaged public var workActivities: Set<ONETWorkActivity>
}
```

**RIASEC Codes**: Realistic, Investigative, Artistic, Social, Enterprising, Conventional

---

### 9. ONETSkill
**Location**: `V7Data/Sources/V7Data/Models/ONETSkill+CoreData.swift`
**Purpose**: O*NET skill taxonomy (636 skills)

```swift
@objc(ONETSkill)
public class ONETSkill: NSManagedObject {
    @NSManaged public var skillID: String
    @NSManaged public var skillName: String
    @NSManaged public var category: String  // "Basic Skills", "Technical Skills", etc.
    @NSManaged public var importance: Double  // 0.0-5.0
    @NSManaged public var level: Double  // 0.0-7.0

    // Relationship
    @NSManaged public var occupations: Set<ONETOccupation>
}
```

---

### 10. ONETWorkActivity
**Location**: `V7Data/Sources/V7Data/Models/ONETWorkActivity+CoreData.swift`
**Purpose**: Work activity descriptors

```swift
@objc(ONETWorkActivity)
public class ONETWorkActivity: NSManagedObject {
    @NSManaged public var activityID: String
    @NSManaged public var activityName: String
    @NSManaged public var category: String
    @NSManaged public var importance: Double

    // Relationship
    @NSManaged public var occupations: Set<ONETOccupation>
}
```

---

### 11. CareerQuestion
**Location**: `V7AI/Sources/V7AI/Models/CareerQuestion+CoreData.swift`
**Purpose**: AI-generated career exploration questions with user responses

```swift
@objc(CareerQuestion)
public class CareerQuestion: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var questionText: String
    @NSManaged public var category: String  // "values", "interests", "lifestyle", etc.
    @NSManaged public var userResponse: String?
    @NSManaged public var responseTimestamp: Date?
    @NSManaged public var generatedBy: String  // "foundation_models", "predefined"
    @NSManaged public var importance: Double

    // Relationship
    @NSManaged public var userProfile: UserProfile
}
```

**Categories**:
- Values (work-life balance, mission-driven)
- Interests (technical, creative, social)
- Lifestyle (remote, travel, hours)
- Career Goals (growth, stability, learning)

---

### 12. BehavioralPattern
**Location**: `V7AI/Sources/V7AI/Models/BehavioralPattern+CoreData.swift`
**Purpose**: Detected behavioral patterns from swipe analysis

```swift
@objc(BehavioralPattern)
public class BehavioralPattern: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var patternType: String  // "fatigue", "preference_shift", etc.
    @NSManaged public var detectedAt: Date
    @NSManaged public var confidence: Double  // 0.0-1.0
    @NSManaged public var contextJSON: Data
    @NSManaged public var actionTaken: String?

    // Relationship
    @NSManaged public var userProfile: UserProfile
}
```

**Pattern Types**:
- `fatigue`: Declining engagement over session
- `preference_shift`: Changing job category preferences
- `exploration_spike`: Sudden increase in right swipes
- `category_focus`: Concentration on specific industry

---

### 13. APIRateLimit
**Location**: `V7Services/Sources/V7Services/Models/APIRateLimit+CoreData.swift`
**Purpose**: Token bucket state for API rate limiting

```swift
@objc(APIRateLimit)
public class APIRateLimit: NSManagedObject {
    @NSManaged public var apiSource: String  // "adzuna", "greenhouse", etc.
    @NSManaged public var tokensAvailable: Int32
    @NSManaged public var maxTokens: Int32
    @NSManaged public var refillRate: Double  // tokens per second
    @NSManaged public var lastRefillTimestamp: Date
    @NSManaged public var circuitBreakerState: String  // "closed", "open", "half_open"
    @NSManaged public var failureCount: Int16
}
```

**Circuit Breaker States**:
- `closed`: Normal operation
- `open`: API failures exceeded threshold (block requests)
- `half_open`: Testing if API recovered

---

### 14. ResumeParseResult
**Location**: `V7Data/Sources/V7Data/Models/ResumeParseResult+CoreData.swift`
**Purpose**: Cached resume parsing results

```swift
@objc(ResumeParseResult)
public class ResumeParseResult: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var resumeHash: String  // SHA256 of PDF
    @NSManaged public var parsedJSON: Data
    @NSManaged public var parsedAt: Date
    @NSManaged public var parserVersion: String
    @NSManaged public var confidence: Double

    // Relationship
    @NSManaged public var userProfile: UserProfile
}
```

**Caching**: Prevents re-parsing same resume (expensive operation)

---

## Swift Structs (In-Memory)

### 15. RawJobData
**Location**: `V7Core/Sources/V7Core/Models/RawJobData.swift`
**Purpose**: Unified job representation from multiple sources

```swift
public struct RawJobData: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let company: String
    public let location: String?
    public let description: String
    public let salary: SalaryRange?
    public let postedDate: Date?
    public let expirationDate: Date?
    public let applyURL: URL?
    public let sourceAPI: String
    public let rawJSON: [String: Any]?

    // Computed
    public var isExpired: Bool {
        guard let expiration = expirationDate else { return false }
        return expiration < Date()
    }
}
```

**Source APIs**: Adzuna, Greenhouse, Lever, Jobicy, USAJobs, RSS, RemoteOK

---

### 16. SalaryRange
**Location**: `V7Core/Sources/V7Core/Models/SalaryRange.swift`

```swift
public struct SalaryRange: Codable, Hashable, Sendable {
    public let min: Int?
    public let max: Int?
    public let currency: String  // "USD", "EUR", "GBP"
    public let period: String  // "year", "hour", "month"

    public var displayString: String {
        // "$80,000 - $120,000/year"
    }
}
```

---

### 17. ThompsonScore
**Location**: `V7Thompson/Sources/V7Thompson/Models/ThompsonScore.swift`

```swift
public struct ThompsonScore: Sendable {
    public let jobID: String
    public let score: Double  // 0.0-1.0
    public let categoryID: String
    public let armAlpha: Double
    public let armBeta: Double
    public let sampledValue: Double
    public let computedAt: Date
    public let computationTimeMs: Double  // Must be <10ms

    public var explainFitReasons: [String] {
        // Why this job scored high
    }
}
```

**Sacred Constraint**: `computationTimeMs < 10.0`

---

### 18. ProfileSnapshot
**Location**: `V7Core/Sources/V7Core/Models/ProfileSnapshot.swift`

```swift
public struct ProfileSnapshot: Codable, Sendable {
    public let capturedAt: Date
    public let skills: [String]
    public let experienceYears: Int
    public let industries: [String]
    public let preferences: [String: Any]

    // Used for swipe context preservation
}
```

---

### 19. ONETProfile
**Location**: `V7Data/Sources/V7Data/Models/ONETProfile.swift`

```swift
public struct ONETProfile: Codable, Sendable {
    public let onetCode: String
    public let title: String
    public let riasecCode: String
    public let skills: [ONETSkillScore]
    public let workActivities: [ONETActivityScore]
    public let matchScore: Double  // vs. user profile
}
```

---

### 20. ONETSkillScore
**Location**: `V7Data/Sources/V7Data/Models/ONETSkillScore.swift`

```swift
public struct ONETSkillScore: Codable, Sendable {
    public let skillName: String
    public let importance: Double  // 0.0-5.0
    public let level: Double  // 0.0-7.0
    public let userProficiency: Int?  // 1-5 if user has this skill
}
```

---

### 21. UserTruth
**Location**: `V7AI/Sources/V7AI/Models/UserTruth.swift`

```swift
public struct UserTruth: Codable, Sendable {
    public let category: String
    public let statement: String
    public let confidence: Double  // 0.0-1.0
    public let derivedFrom: [String]  // Question IDs
    public let detectedAt: Date
}
```

**Example**:
- Category: "work_style"
- Statement: "Prefers remote work with flexible hours"
- Confidence: 0.87

---

### 22. BehavioralInsight
**Location**: `V7AI/Sources/V7AI/Models/BehavioralInsight.swift`

```swift
public struct BehavioralInsight: Sendable {
    public let insightType: InsightType
    public let description: String
    public let suggestedAction: String?
    public let evidenceSwipeIDs: [UUID]
    public let detectedAt: Date
}

public enum InsightType: String, Codable {
    case fatigue
    case preferenceShift
    case explorationSpike
    case categoryFocus
}
```

---

### 23. APIRequestConfig
**Location**: `V7Services/Sources/V7Services/Models/APIRequestConfig.swift`

```swift
public struct APIRequestConfig: Sendable {
    public let baseURL: URL
    public let headers: [String: String]
    public let timeout: TimeInterval
    public let maxRetries: Int
    public let retryDelay: TimeInterval
    public let rateLimitTokens: Int
    public let circuitBreakerThreshold: Int
}
```

---

### 24-32. Job Source Response Models

**AdzunaJobResponse**, **GreenhouseJobResponse**, **LeverJobResponse**, **JobicyJobResponse**, **USAJobsResponse**, **RSSJobResponse**, **RemoteOKJobResponse**, **TheirStackResponse**, **LinkedInJobResponse**

Location: `V7Services/Sources/V7Services/APIClients/*/Models/`

Each API has custom response structs that parse to `RawJobData`:

```swift
public struct AdzunaJobResponse: Codable {
    public let id: String
    public let title: String
    public let company: Company
    public let location: Location
    public let description: String
    public let salary_min: Double?
    public let salary_max: Double?
    public let created: String  // ISO date
    public let redirect_url: String

    struct Company: Codable {
        let display_name: String
    }

    struct Location: Codable {
        let display_name: String
    }

    // Transform to RawJobData
    public func toRawJobData() -> RawJobData { ... }
}
```

Similar patterns for all 9 job sources.

---

## Data Model Relationships Diagram

```
UserProfile (1)
    ├──> Skills (N)
    ├──> WorkExperiences (N)  [🚨 BUG: Not saving]
    ├──> Educations (N)       [🚨 BUG: Not saving]
    ├──> SwipeRecords (N)
    ├──> CareerQuestions (N)
    ├──> BehavioralPatterns (N)
    └──> ResumeParseResult (1)

SwipeRecord (N)
    ├──> UserProfile (1)
    └──> ThompsonArm (1)

ThompsonArm (1)
    └──> SwipeRecords (N)

JobCache (N)
    └──> RequiredSkills (N)

ONETOccupation (1)
    ├──> ONETSkills (N)
    └──> ONETWorkActivities (N)

ONETSkill (N)
    └──> Occupations (N)

ONETWorkActivity (N)
    └──> Occupations (N)
```

---

## Memory Management

**Core Data Memory Budget**: <150MB sustained (tested with 10K+ swipes)

**Optimization Strategies**:
1. **Batch Faulting**: Fetch in batches of 100
2. **Predicate Filtering**: Filter at DB level, not in-memory
3. **Relationship Faulting**: Lazy-load relationships
4. **Binary Data Storage**: Store PDFs/JSON as `Data` (not strings)

---

## Thread Safety

**Swift 6 Strict Concurrency Compliance**:

```swift
// ✅ CORRECT: Pass NSManagedObjectID across actors
actor JobMatchingEngine {
    func processJob(profileID: NSManagedObjectID) async throws {
        let context = ModelContext.newBackgroundContext()
        let profile = try context.existingObject(with: profileID) as? UserProfile
        // ... safe access
    }
}

// ❌ WRONG: Pass NSManagedObject directly
actor JobMatchingEngine {
    func processJob(profile: UserProfile) async throws {
        // Crash: NSManagedObject not Sendable
    }
}
```

---

## Validation Rules

### WorkExperience
- `startDate` < `endDate` (if `!isCurrent`)
- `jobTitle` and `company` non-empty
- No overlapping date ranges

### Education
- `startDate` < `endDate` (if `!isCurrent`)
- `institution` non-empty
- `gpa` between 0.0-4.0 (if provided)

### Skill
- `proficiencyLevel` between 1-5
- `name` non-empty

### ThompsonArm
- `alphaParameter > 0`
- `betaParameter > 0`
- `successCount + failureCount >= 0`

---

## Migrations

**Core Data Migration Strategy**: Lightweight migrations only

**Schema Versions**:
- V1: Initial schema (iOS 16)
- V2: Added ThompsonArm entity (iOS 17)
- V3: Added BehavioralPattern entity (iOS 18)
- V4: Current (iOS 26) - Added Foundation Models integration

**Migration Code**: `V7Migration/Sources/V7Migration/MigrationCoordinator.swift`

---

## Critical Issues

### 🚨 HIGH PRIORITY

1. **WorkExperience NOT Persisting**
   - File: `V7UI/Sources/V7UI/ProfileCreation/WorkExperienceCollectionStepView.swift:145`
   - Issue: Data only saved to `@State` array, never written to Core Data
   - Impact: All work experience lost on app restart

2. **Education NOT Persisting**
   - File: `V7UI/Sources/V7UI/ProfileCreation/EducationAndCertificationsStepView.swift:89`
   - Same issue as WorkExperience

---

## Testing Coverage

**Unit Tests**: 89% coverage for Core Data models
**Integration Tests**: End-to-end swipe persistence tested
**Performance Tests**: 10K swipe load test passes (<150MB memory)

**Missing Tests**:
- WorkExperience persistence (fails - see bugs above)
- Education persistence (fails - see bugs above)
- ONETOccupation relationship cascading

---

## Documentation References

- **Core Data Schema**: `V7Data/Resources/V7DataModel.xcdatamodeld`
- **Migration Guide**: `Documentation/DATA_MIGRATION.md`
- **Testing Guide**: `Tests/V7DataTests/README.md`
