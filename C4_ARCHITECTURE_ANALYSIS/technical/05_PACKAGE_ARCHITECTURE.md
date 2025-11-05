# PACKAGE ARCHITECTURE - Complete SPM Structure
## Manifest & Match V8 - 15-Package System

---

## Package Dependency Hierarchy (5 Levels)

```
LEVEL 0: FOUNDATION (Zero External Dependencies)
│
├── V7Core (0 deps)
│   ├─ Purpose: Foundation types, protocols, constants
│   ├─ Size: ~50 Swift files
│   ├─ Memory: <5MB
│   └─ Sacred: SacredUI constants, PerformanceBudget
│
├── V7Embeddings (deps: V7Core)
│   ├─ Purpose: Vector embeddings for semantic matching
│   ├─ Status: Framework ready, implementation in progress
│   └─ Use: Resume/job similarity computation
│
├── V7JobParsing (deps: V7Core)
│   ├─ Purpose: Job description parsing and metadata extraction
│   ├─ NLP: Skills extraction, seniority detection
│   └─ Performance: <2ms per job
│
└── V7Migration (deps: V7Core) [DISABLED]
    ├─ Purpose: V5/V6 → V7 data migration
    ├─ Status: Commented out in Package.swift
    └─ Recommendation: Complete or remove

═══════════════════════════════════════════════════════════

LEVEL 1: ALGORITHM & DATA
│
├── V7Thompson (deps: V7Core, V7Embeddings)
│   ├─ Purpose: Thompson Sampling algorithm (<10ms)
│   ├─ Components:
│   │  ├─ FastBetaSampler (SIMD optimization)
│   │  ├─ ThompsonCache (lock-free)
│   │  ├─ RealTimeScoring (differential updates)
│   │  └─ SwipePatternAnalyzer (ML fatigue detection)
│   ├─ Performance: 0.028ms avg (357x faster than baseline)
│   └─ Sacred Constraint: <10ms guarantee enforced
│
├── V7Data (deps: V7Core)
│   ├─ Purpose: Core Data persistence layer
│   ├─ Entities: 14 (UserProfile, SwipeHistory, JobCache, etc.)
│   ├─ Stack: NSPersistentContainer + SQLite
│   ├─ Concurrency: viewContext (main) + backgroundContext (private)
│   └─ Size: Dynamic (grows with user data)
│
└── V7Performance (deps: V7Core, V7Thompson)
    ├─ Purpose: Performance monitoring & enforcement
    ├─ Components:
    │  ├─ PerformanceMonitor (<10ms Thompson validation)
    │  ├─ MemoryManager (<200MB baseline enforcement)
    │  ├─ BiasDetectionService (sector neutrality)
    │  └─ EmergencyRecoveryProtocol (20 stub functions)
    └─ Alerting: Violations logged in real-time

═══════════════════════════════════════════════════════════

LEVEL 2: SERVICES & PARSING
│
├── V7Services (deps: V7Core, V7Thompson, V7JobParsing, V7AIParsing, V7Data)
│   ├─ Purpose: API integrations for 7 job sources
│   ├─ Components:
│   │  ├─ JobDiscoveryCoordinator (orchestration)
│   │  ├─ JobSourceIntegrationService (multi-source)
│   │  ├─ RateLimitManager (token bucket pattern)
│   │  ├─ SmartSourceSelector (intelligent routing)
│   │  └─ CompanyAPIs:
│   │     ├─ AdzunaAPIClient (60 req/min)
│   │     ├─ GreenhouseAPIClient (60 req/min)
│   │     ├─ LeverAPIClient (100 req/min)
│   │     ├─ JobicyAPIClient (10 req/min)
│   │     ├─ USAJobsAPIClient (10 req/min)
│   │     └─ RSSFeedJobSource (20 req/min)
│   ├─ Rate Limiting: Per-source token buckets
│   ├─ Circuit Breakers: 3-5 failure threshold
│   └─ Error Handling: Exponential backoff (1s, 2s, 4s, 8s)
│
├── V7AIParsing (deps: V7Core, V7Thompson, V7Performance)
│   ├─ Purpose: Resume parsing with AI/NLP
│   ├─ Components:
│   │  ├─ ResumeParsingService (PDF/text extraction)
│   │  ├─ OpenAIClient (LLM integration - optional)
│   │  ├─ PDFTextExtractor (PDFKit)
│   │  └─ NaturalLanguage framework integration
│   ├─ Parsing Methods:
│   │  ├─ Basic: Regex patterns (0.7 confidence)
│   │  └─ AI-Enhanced: OpenAI parsing (0.95 confidence)
│   ├─ Performance: 500ms-5s (depends on method)
│   └─ Caching: LRU cache (50 resumes, SHA256 keyed)
│
└── V7ResumeAnalysis (deps: V7Core, V7Data, V7Career, V7AI)
    ├─ Purpose: Resume validation & analysis
    ├─ Components:
    │  ├─ Resume validation rules
    │  ├─ UserTruths integration
    │  └─ ResumeUploadViewModel
    └─ Output: ParsedResume → 7 Core Data entities

═══════════════════════════════════════════════════════════

LEVEL 3: BUSINESS LOGIC & AI
│
├── V7AI (deps: V7Core, V7Data, V7Services, V7Thompson, V7Performance)
│   ├─ Purpose: Behavioral learning & career questions
│   ├─ Components:
│   │  ├─ CareerQuestion (Core Data entity)
│   │  ├─ UserTruths (Core Data entity)
│   │  ├─ FastBehavioralLearning (real-time swipe analysis)
│   │  ├─ DeepBehavioralAnalysis (background batch)
│   │  ├─ SmartQuestionGenerator (contextual Q&A)
│   │  ├─ KeychainManager (secure credentials)
│   │  ├─ QuestionTemplateLibrary (career templates)
│   │  ├─ OpenAIContextualService (LLM prompting)
│   │  ├─ QuestionTimingCoordinator (adaptive timing)
│   │  └─ ThompsonBridge (AI ↔ Thompson integration)
│   ├─ AI Integration: Foundation Models (iOS 26)
│   ├─ Performance: <50ms per question
│   └─ Privacy: 100% on-device processing
│
└── V7Ads (deps: V7Core, V7UI, V7Performance) [UNUSED - NEVER IMPORTED]
    ├─ Purpose: Google AdMob native ads
    ├─ Status: PLACEHOLDER MODE (SDK commented out)
    ├─ Components:
    │  ├─ AdCardView (5-state enum)
    │  ├─ AdPerformanceTracker (CloudKit sync)
    │  ├─ AdCachingSystem
    │  ├─ ATTConsentManager (App Tracking Transparency)
    │  ├─ ConsentFlowCoordinator
    │  └─ JobFeedIntegration (1 ad per 10 jobs)
    ├─ Issue: ENTIRE PACKAGE NEVER IMPORTED
    └─ Recommendation: REMOVE unless ads planned for release

═══════════════════════════════════════════════════════════

LEVEL 4: FEATURE & CAREER BUILDING
│
└── V7Career (deps: V7Core, V7Data, V7Thompson, V7AI, V7Services, V7Performance)
    ├─ Purpose: Career building & course recommendations
    ├─ Components:
    │  ├─ CareerPathEngine (learning path generation)
    │  ├─ EnrollmentTrackerView (progress tracking)
    │  ├─ CourseProvider APIs (integration ready)
    │  ├─ Career trajectory prediction
    │  └─ Thompson career bonuses
    ├─ UI: ManifestTabView (4th tab)
    └─ Navigation: ManifestDestination enum (6 destinations)

═══════════════════════════════════════════════════════════

LEVEL 5: PRESENTATION (Terminal Package - Only Depends On, Never Depended On)
│
└── V7UI (deps: ALL packages above)
    ├─ Purpose: SwiftUI presentation layer
    ├─ Components:
    │  ├─ Screens:
    │  │  ├─ DeckScreen (job swipe interface)
    │  │  ├─ ProfileScreen (user data management)
    │  │  ├─ HistoryScreen (application tracker)
    │  │  └─ ManifestTabView (career building hub)
    │  ├─ Forms (7 Core Data entities):
    │  │  ├─ WorkExperienceFormView (O*NET role picker)
    │  │  ├─ EducationFormView (12 O*NET levels)
    │  │  ├─ CertificationFormView
    │  │  ├─ ProjectFormView
    │  │  ├─ VolunteerExperienceFormView
    │  │  ├─ AwardFormView
    │  │  └─ PublicationFormView
    │  ├─ Card Views:
    │  │  ├─ AccessibleJobCard (WCAG AA compliant)
    │  │  ├─ QuestionCardView (4 question types)
    │  │  └─ AdCardView (Google AdMob integration)
    │  ├─ Sheets:
    │  │  ├─ ExplainFitSheet (Beta distribution viz)
    │  │  ├─ DirectAIAssistantView (cover letter gen)
    │  │  └─ MLInsightsDashboard
    │  └─ Accessibility:
    │     ├─ VoiceOver support (all elements)
    │     ├─ Dynamic Type (small → XXXL)
    │     ├─ WCAG 2.1 AA contrast (4.5:1)
    │     └─ Reduce Motion support
    ├─ Architecture: MV (NO ViewModels)
    ├─ Concurrency: @MainActor on all views
    └─ Sacred UI: Constants protected from modification
```

---

## Package Dependency Rules (SACRED)

### 1. Zero Circular Dependencies
- Acyclic directed graph enforced
- V7Core has 0 external dependencies
- V7UI is terminal (only depends on, never depended on)
- Exception: V7Ads → V7UI (ONE-WAY only for ad placement)

### 2. Level-Based Dependencies
- Packages can only depend on same level or lower
- Level 0 → Level 1 → Level 2 → Level 3 → Level 4 → Level 5
- No skipping levels (except V7Core, which all can depend on)

### 3. Protocol-Based Boundaries
- Services communicate via protocols (JobSourceProtocol, etc.)
- Dependency inversion for testability
- Mock implementations for unit tests

---

## Package Statistics

| Package | Swift Files | Lines of Code | Dependencies | Memory | Performance Target |
|---------|-------------|---------------|--------------|--------|--------------------|
| V7Core | 50+ | ~8,000 | 0 | <5MB | - |
| V7Thompson | 30+ | ~6,000 | 2 | <10MB | <10ms per job |
| V7Data | 20+ | ~4,000 | 1 | 20-50MB | <100ms save |
| V7Services | 40+ | ~10,000 | 5 | <15MB | <2s API call |
| V7AI | 35+ | ~8,000 | 6 | <8MB | <50ms per question |
| V7UI | 60+ | ~12,000 | 14 | <30MB | 60fps |
| V7AIParsing | 15+ | ~3,000 | 3 | <10MB | 500ms-5s |
| V7JobParsing | 10+ | ~2,000 | 1 | <5MB | <2ms per job |
| V7ResumeAnalysis | 10+ | ~2,000 | 4 | <8MB | <5s per resume |
| V7Embeddings | 5+ | ~1,000 | 1 | <5MB | TBD |
| V7Performance | 15+ | ~3,000 | 2 | <5MB | <1ms overhead |
| V7Career | 20+ | ~4,000 | 6 | <10MB | <100ms |
| V7Ads | 15+ | ~3,000 | 3 | <15MB | <500ms ad load |
| V7Migration | 10+ | ~2,000 | 1 | <5MB | N/A (disabled) |
| **TOTAL** | **335+** | **~68,000** | **-** | **<200MB** | **-** |

---

## Naming Conventions

### Package Names
- Pattern: `V7{Domain}` (PascalCase)
- Examples: V7Core, V7Thompson, V7Services
- Rationale: Version prefix prevents namespace collisions

### File Names
- **SwiftUI Views:** `{Feature}View.swift` or `{Feature}Screen.swift`
- **Models:** `{Entity}.swift` or `{Entity}+CoreData.swift`
- **Services:** `{Service}Service.swift` or `{API}Client.swift`
- **Protocols:** `{Capability}Protocol.swift` or just `{Protocol}.swift`
- **Extensions:** `{Type}+{Extension}.swift`
- **Tests:** `{Target}Tests.swift`

### Type Names
- **Classes/Structs/Enums:** PascalCase (`UserProfile`, `JobItem`)
- **Protocols:** PascalCase with `-able` or `-Protocol` suffix
- **Actors:** PascalCase (same as classes, but isolation implicit)
- **Functions:** camelCase (`fetchJobs`, `calculateScore`)
- **Properties:** camelCase (`jobTitle`, `thompsonScore`)
- **Constants:** camelCase or SCREAMING_SNAKE_CASE for globals

### Enum Cases
- camelCase: `case interested`, `case pass`, `case save`
- Associated values: labels in camelCase

---

## Critical Inter-Package Contracts

### V7Thompson ← → V7Services
**Contract:** Thompson scores jobs fetched by Services
```swift
// V7Services provides
struct RawJobData { ... }

// V7Thompson consumes
func score(job: RawJobData, profile: UserProfile) -> ThompsonScore
```

### V7Data ← → V7UI
**Contract:** UI reads/writes Core Data via shared context
```swift
// V7Data provides
@Environment(\.managedObjectContext) var context

// V7UI uses
@FetchRequest(entity: WorkExperience.entity(), ...)
var experiences: FetchedResults<WorkExperience>
```

### V7AI ← → V7Thompson
**Contract:** AI provides bonus multipliers for Thompson scoring
```swift
// V7AI provides
func calculateThompsonBonus(for job: JobDescription) -> Double

// V7Thompson consumes
finalScore = baseScore * aiBonus
```

### V7Services ← → V7Performance
**Contract:** Services report metrics, Performance enforces budgets
```swift
// V7Services reports
performanceMonitor.record(responseTime: duration, source: sourceId)

// V7Performance enforces
guard responseTime < budgets.apiTimeout else { circuitBreak() }
```

---

## Swift Package Manager Configuration

### Shared Configuration (Packages/Shared.xcconfig)
```
SWIFT_VERSION = 6.0
IPHONEOS_DEPLOYMENT_TARGET = 18.0
MACOSX_DEPLOYMENT_TARGET = 15.0
ENABLE_STRICT_CONCURRENCY = YES
SWIFT_UPCOMING_FEATURE_CONCURRENCY = YES
```

### Per-Package Package.swift Structure
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "V7{PackageName}",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "V7{PackageName}", targets: ["V7{PackageName}"])
    ],
    dependencies: [
        .package(path: "../V7Core"),
        // Other local dependencies
    ],
    targets: [
        .target(
            name: "V7{PackageName}",
            dependencies: ["V7Core"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "V7{PackageName}Tests",
            dependencies: ["V7{PackageName}"]
        )
    ]
)
```

---

## Build Configurations

### Debug
- Optimizations: None (`-Onone`)
- Assertions: Enabled
- Logging: Verbose
- Thompson performance: Warning if >10ms
- Memory tracking: Enabled

### Release
- Optimizations: Whole Module (`-O`)
- Assertions: Disabled (except Thompson <10ms)
- Logging: Errors only
- Dead code stripping: Enabled
- Bitcode: No (iOS 14+ deprecated)

---

## Concurrency Model (Swift 6)

### Actor Isolation
- **Actors:** ResumeParser, BehavioralEventLog, RateLimitManager, SkillTaxonomyLoader
- **@MainActor:** All SwiftUI views, AppState, ProfileManager
- **Sendable:** NSManagedObjectID wrapper, all value types

### Thread Safety Patterns
```swift
// Core Data context access
await context.perform {
    // Thread-safe Core Data operations
}

// Actor message passing
let result = await someActor.processData(input)

// @MainActor isolated functions
@MainActor
func updateUI() {
    // Guaranteed main thread
}
```

---

## Testing Strategy

### Unit Tests (Per Package)
- Target: V7{PackageName}Tests
- Pattern: One test target per package
- Mocks: Protocol-based mocking
- Coverage: Aim for 70%+ on critical paths

### Integration Tests
- Location: `/Tests/IntegrationTests/`
- Scope: Cross-package interactions
- Focus: Thompson scoring, job discovery pipeline

### Performance Tests
- Location: `/Tests/PerformanceTests/`
- Benchmarks: Thompson <10ms, API <2s, UI 60fps
- Profiling: Instruments.app integration

---

## Dead Code Detection Results

### Unused Packages
- ❌ **V7Ads** - Never imported anywhere (REMOVE)
- ⚠️ **V7Migration** - Commented out in Package.swift (COMPLETE or REMOVE)

### Incomplete Packages
- ⚠️ **V7Embeddings** - Framework exists but minimal implementation
- ⚠️ **V7Performance** - 20 empty stub functions in EmergencyRecoveryProtocol

---

## Recommended Changes

### Immediate
1. **Remove V7Ads** - Entire package unused, adds 15+ files of bloat
2. **Fix V7Performance stubs** - Implement or remove 20 empty functions
3. **Complete V7Migration or remove** - Currently in limbo (disabled)

### Short-Term
4. **Complete V7Embeddings** - Finish vector similarity implementation
5. **Add V7Logging package** - Centralized logging instead of print statements
6. **Add V7Analytics package** - User behavior analytics (optional)

### Long-Term
7. **Extract V7Testing** - Shared test utilities across packages
8. **Add V7Networking** - Abstract URLSession for better testability
9. **Modularize V7UI** - Split into V7UIComponents + V7UIScreens

---

## Summary

**Total Packages:** 15 (14 active + 1 disabled)
**Architecture:** 5-level hierarchy (V7Core → V7UI)
**Dependencies:** Acyclic, protocol-based, testable
**Concurrency:** Swift 6 strict concurrency with actors
**Performance:** <10ms Thompson, <200MB memory, 60fps UI
**Code Quality:** 68,000+ lines, 335+ Swift files
**Issues:** 2 unused packages, 20 stub functions, 11+ empty buttons

**Next Steps:**
1. Remove V7Ads package
2. Complete or remove V7Migration
3. Implement V7Performance emergency recovery
4. Fix data persistence bugs (work experience, education)
5. Clean up dead code (45+ issues total)
