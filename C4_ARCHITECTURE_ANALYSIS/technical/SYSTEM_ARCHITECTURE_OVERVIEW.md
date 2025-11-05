# SYSTEM/ARCHITECTURE OVERVIEW MAP
## Manifest & Match V8 - High-Level Blueprint

---

## Purpose
This document provides a **high-level blueprint** of the entire Manifest & Match V8 application, showing:
- Main modules and services
- Dependencies between them
- Naming conventions across domains
- Critical integration points
- Team onboarding guide

---

## System Architecture (Bird's Eye View)

```
┌─────────────────────────────────────────────────────────────────────┐
│                      MANIFEST & MATCH V8                             │
│                  iOS Job Discovery Application                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER (SwiftUI)                     │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────┐ │
│  │  Discover    │  │   Profile    │  │   History    │  │Manifest │ │
│  │  (DeckScreen)│  │  (UserData)  │  │ (AppTracker) │  │ (Career)│ │
│  │              │  │              │  │              │  │         │ │
│  │ • Job Cards  │  │ • 7 Forms    │  │ • Saved Jobs │  │ • Paths │ │
│  │ • Swipe UI   │  │ • Resume     │  │ • Applied    │  │ • Skills│ │
│  │ • Questions  │  │ • Settings   │  │ • Timeline   │  │ • Courses│ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └─────────┘ │
└────────┬──────────────────┬─────────────────┬──────────────┬────────┘
         │                  │                 │              │
         │                  │                 │              │
┌────────▼──────────────────▼─────────────────▼──────────────▼────────┐
│                    BUSINESS LOGIC LAYER                              │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │              Job Discovery & Scoring Engine                     │ │
│  │                                                                 │ │
│  │  JobDiscoveryCoordinator                                        │ │
│  │  ├─ Fetches from 7 APIs                                        │ │
│  │  ├─ Normalizes to RawJobData                                   │ │
│  │  ├─ Thompson Sampling (<10ms per job)                          │ │
│  │  ├─ O*NET Enhancement (+30% weight)                            │ │
│  │  ├─ UserTruths Bonus (loves/hates/values)                      │ │
│  │  └─ Returns scored JobItems for UI                             │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │          Behavioral Learning & AI System                        │ │
│  │                                                                 │ │
│  │  FastBehavioralLearning (Real-time)                            │ │
│  │  ├─ Swipe pattern analysis                                     │ │
│  │  ├─ Fatigue detection                                          │ │
│  │  ├─ Preference drift                                           │ │
│  │  └─ Pattern classification (5 types)                           │ │
│  │                                                                 │ │
│  │  SmartQuestionGenerator (Contextual)                           │ │
│  │  ├─ Generates career questions                                 │ │
│  │  ├─ Adaptive timing (5-20 jobs between)                        │ │
│  │  ├─ Confidence-based prioritization                            │ │
│  │  └─ UserTruths discovery                                       │ │
│  │                                                                 │ │
│  │  DeepBehavioralAnalysis (Background)                           │ │
│  │  ├─ Batch analysis (every 10 swipes)                           │ │
│  │  ├─ RIASEC profile inference                                   │ │
│  │  ├─ Work style extraction                                      │ │
│  │  └─ Foundation Models (iOS 26)                                 │ │
│  └────────────────────────────────────────────────────────────────┘ │
└────────┬──────────────────┬─────────────────┬──────────────────────┘
         │                  │                 │
         │                  │                 │
┌────────▼──────────────────▼─────────────────▼──────────────────────┐
│                      DATA ACCESS LAYER                              │
│                                                                      │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │  Core Data       │  │  O*NET Database  │  │  Application     │ │
│  │  (SQLite)        │  │  (JSON Bundle)   │  │  State           │ │
│  │                  │  │                  │  │  (In-Memory)     │ │
│  │ • UserProfile    │  │ • 1,016 Roles    │  │                  │ │
│  │ • WorkExperience │  │ • 636 Skills     │  │ • Session Data   │ │
│  │ • Education      │  │ • Work Activities│  │ • UI State       │ │
│  │ • SwipeHistory   │  │ • RIASEC Profiles│  │ • Cache Status   │ │
│  │ • JobCache       │  │ • Education Lvls │  │ • Performance    │ │
│  │ • UserTruths     │  │                  │  │   Metrics        │ │
│  │ • ThompsonArm    │  │                  │  │                  │ │
│  │ • CareerQuestion │  │                  │  │                  │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘ │
└────────┬──────────────────┬─────────────────┬──────────────────────┘
         │                  │                 │
         │                  │                 │
┌────────▼──────────────────▼─────────────────▼──────────────────────┐
│                    EXTERNAL INTEGRATIONS                             │
│                                                                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ │
│  │  Adzuna  │ │Greenhouse│ │  Lever   │ │  Jobicy  │ │ USAJobs  │ │
│  │   API    │ │   API    │ │   API    │ │   API    │ │   API    │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘ │
│                                                                      │
│  ┌──────────┐ ┌─────────────────────┐ ┌─────────────────────────┐ │
│  │   RSS    │ │  Apple Foundation   │ │  Apple Services         │ │
│  │  Feeds   │ │  Models (iOS 26)    │ │  (iCloud, Keychain)     │ │
│  └──────────┘ └─────────────────────┘ └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Main Modules & Services

### 1. PRESENTATION LAYER (V7UI Package)

**Purpose:** User interface and interaction handling

**Key Components:**
- `DeckScreen` - Primary job discovery interface
- `ProfileScreen` - User profile management
- `HistoryScreen` - Job interaction history
- `ManifestTabView` - Career building hub

**Responsibilities:**
- Render SwiftUI views
- Handle user gestures (swipe, tap, drag)
- Display job cards and questions
- Form input and validation
- Navigation and routing

**Dependencies:** ALL packages (terminal package)

**Naming Conventions:**
- Views: `{Feature}View.swift` or `{Feature}Screen.swift`
- Forms: `{Entity}FormView.swift`
- Cards: `{Type}CardView.swift`
- Sheets: `{Feature}Sheet.swift`

---

### 2. JOB DISCOVERY SERVICE (V7Services Package)

**Purpose:** Aggregate jobs from multiple sources and normalize data

**Key Components:**
- `JobDiscoveryCoordinator` - Orchestrates job fetching
- `JobSourceIntegrationService` - Manages 7 API clients
- `RateLimitManager` - Token bucket rate limiting
- `SmartSourceSelector` - Intelligent API routing
- API Clients:
  - `AdzunaAPIClient`
  - `GreenhouseAPIClient`
  - `LeverAPIClient`
  - `JobicyAPIClient`
  - `USAJobsAPIClient`
  - `RSSFeedJobSource`
  - `LinkedInAPIClient` (planned)

**Responsibilities:**
- Fetch jobs from 7 external APIs
- Handle rate limiting (10-100 req/min per source)
- Circuit breakers (3-5 failure threshold)
- Normalize to `RawJobData` struct
- Error handling and fallback strategies

**Dependencies:** V7Core, V7Thompson, V7JobParsing, V7AIParsing, V7Data

**Naming Conventions:**
- API Clients: `{Source}APIClient.swift`
- Services: `{Service}Service.swift`
- Protocols: `JobSourceProtocol.swift`
- Models: `RawJobData.swift`, `JobSearchQuery.swift`

---

### 3. THOMPSON SAMPLING ENGINE (V7Thompson Package)

**Purpose:** <10ms job scoring algorithm with 357x performance advantage

**Key Components:**
- `FastBetaSampler` - SIMD-optimized Beta sampling
- `ThompsonCache` - Lock-free caching (50-entry LRU)
- `RealTimeScoring` - Differential score updates
- `SwipePatternAnalyzer` - ML-based fatigue detection
- `ThompsonSamplingEngine` - Main scoring orchestrator

**Responsibilities:**
- Score jobs using Thompson Sampling (<10ms per job)
- Maintain Beta distribution parameters (α, β)
- Update model based on swipe feedback
- Dual-profile blend (Amber/Teal)
- O*NET enhancement (+30% weight)
- Real-time differential updates

**Dependencies:** V7Core, V7Embeddings, Accelerate (SIMD)

**Naming Conventions:**
- Engines: `{Feature}Engine.swift`
- Samplers: `{Algorithm}Sampler.swift`
- Caches: `{Feature}Cache.swift`
- Scoring: `{Type}Scoring.swift`

**Sacred Constraint:** <10ms per job (enforced in CI/CD)

---

### 4. BEHAVIORAL LEARNING SYSTEM (V7AI Package)

**Purpose:** Real-time learning from user behavior and career discovery

**Key Components:**
- `FastBehavioralLearning` - Real-time swipe pattern analysis
- `DeepBehavioralAnalysis` - Background batch analysis (iOS 26 Foundation Models)
- `SmartQuestionGenerator` - Contextual career question generation
- `UserTruths` (Core Data) - Discovered user preferences
- `CareerQuestion` (Core Data) - AI-generated questions
- `QuestionTimingCoordinator` - Adaptive question timing

**Responsibilities:**
- Analyze swipe patterns (speed, consistency, fatigue)
- Classify behavior (Decisive, Exploratory, Cautious, Impulsive, Methodical)
- Generate contextual career questions
- Extract UserTruths (loves, hates, values, interests)
- Calculate Thompson bonus multipliers (0.5x - 2.0x)
- On-device AI processing (zero API costs)

**Dependencies:** V7Core, V7Data, V7Services, V7Thompson, V7Performance

**Naming Conventions:**
- Learning: `{Feature}Learning.swift`
- Analysis: `{Feature}Analysis.swift`
- Generators: `{Type}Generator.swift`
- Coordinators: `{Feature}Coordinator.swift`

---

### 5. DATA PERSISTENCE LAYER (V7Data Package)

**Purpose:** Core Data storage and entity management

**Key Components:**
- `PersistenceController` - NSPersistentContainer wrapper
- **14 Core Data Entities:**
  - Profile: `UserProfile`, `WorkExperience`, `Education`, `Certification`, `Project`, `VolunteerExperience`, `Award`, `Publication`
  - Behavioral: `SwipeHistory`, `ThompsonArm`, `CareerQuestion`, `UserTruths`
  - Performance: `JobCache`, `Preferences`

**Responsibilities:**
- Manage Core Data stack (SQLite backend)
- Entity CRUD operations
- Relationship management (1:N, N:1)
- Thread-safe context handling (viewContext, backgroundContext)
- Data validation and integrity

**Dependencies:** V7Core, CoreData (system framework)

**Naming Conventions:**
- Entities: `{Entity}.swift`, `{Entity}+CoreData.swift`
- Fetch Requests: `{Entity}.fetchCurrent(in:)`
- Extensions: `{Entity}+{Feature}.swift`

---

### 6. RESUME PARSING SERVICE (V7AIParsing Package)

**Purpose:** Extract structured data from resumes (PDF/DOCX/TXT)

**Key Components:**
- `ResumeParsingService` - Main parsing orchestrator
- `PDFTextExtractor` - PDFKit-based text extraction
- `SkillsExtractor` - NLP skill identification (636 skills)
- `OpenAIClient` - Optional AI-enhanced parsing
- `ResumeParsingCache` - LRU cache (50 resumes, SHA256 keyed)

**Responsibilities:**
- Extract text from PDF/DOCX files
- Parse contact info (email, phone, location)
- Extract work experience, education, certifications
- Identify skills (636-skill taxonomy)
- Validate and clean extracted data
- Cache results (prevent re-parsing)

**Dependencies:** V7Core, V7Thompson, V7Performance, PDFKit, NaturalLanguage

**Naming Conventions:**
- Services: `{Feature}Service.swift`
- Extractors: `{Type}Extractor.swift`
- Parsers: `{Format}Parser.swift`
- Models: `ParsedResume.swift`, `ParsingOptions.swift`

**Performance:** 500ms-5s (depends on parsing method)

---

### 7. O*NET INTEGRATION (V7Core Package)

**Purpose:** Career taxonomy and occupational data (embedded JSON)

**Key Components:**
- `RolesDatabase.json` - 1,016 O*NET occupations
- `SkillTaxonomy.json` - 636 skills across 14 sectors
- `WorkActivities.json` - 41 work activity dimensions
- `EducationLevels.json` - 12-level O*NET scale
- `SkillTaxonomyLoader` (actor) - Thread-safe lazy loading

**Responsibilities:**
- Provide career taxonomy lookup
- O*NET role selection (work experience forms)
- Skills normalization and fuzzy matching
- Thompson scoring enhancement (+30% weight)
- Cross-domain career discovery

**Dependencies:** None (embedded JSON bundle)

**Naming Conventions:**
- Databases: `{Feature}Database.json`
- Loaders: `{Feature}Loader.swift`
- Models: `Role.swift`, `ONetWorkActivity.swift`, `RIASECProfile.swift`

**Performance:** <500ms initial load, O(1) lookups thereafter

---

### 8. PERFORMANCE MONITORING (V7Performance Package)

**Purpose:** Enforce performance budgets and detect violations

**Key Components:**
- `PerformanceMonitor` - Real-time metric tracking
- `MemoryManager` - <200MB baseline enforcement
- `BiasDetectionService` - Sector neutrality validation
- `SystemResourceMonitor` - CPU, memory, battery tracking
- `ProductionHealthMonitor` - Critical threshold alerting
- `EmergencyRecoveryProtocol` - Recovery procedures (20 stub functions)

**Responsibilities:**
- Monitor Thompson Sampling (<10ms enforcement)
- Track memory usage (<200MB baseline)
- Detect performance regressions
- Alert on budget violations
- Bias detection (max 15% per sector)
- Emergency recovery triggers

**Dependencies:** V7Core, V7Thompson

**Naming Conventions:**
- Monitors: `{Feature}Monitor.swift`
- Services: `{Feature}Service.swift`
- Protocols: `{Feature}Protocol.swift`

**Sacred Constraints:**
- Thompson Sampling: <10ms per job (357x advantage)
- Memory Baseline: <200MB sustained
- API Response: <2s per job source
- UI Rendering: 60fps (16.67ms frame time)

---

## Domain-Specific Naming Conventions

### User Domain (Profile, Authentication, Preferences)
- **Services:** `ProfileManager`, `UserPreferences`, `AuthenticationService`
- **Models:** `UserProfile`, `WorkExperience`, `Education`, `Certification`
- **Views:** `ProfileScreen`, `EducationFormView`, `SkillsReviewStepView`
- **Storage:** Core Data entities with `User` prefix

### Job Domain (Listings, Discovery, Matching)
- **Services:** `JobDiscoveryCoordinator`, `JobSourceIntegrationService`
- **Models:** `RawJobData`, `JobItem`, `JobCard`, `JobSearchQuery`
- **Views:** `DeckScreen`, `AccessibleJobCard`, `JobDetailSheet`
- **Storage:** `JobCache` (Core Data), `jobIdMapping` (in-memory)

### Thompson Domain (Algorithm, Scoring, Sampling)
- **Services:** `ThompsonSamplingEngine`, `RealTimeScoring`, `ThompsonBridge`
- **Models:** `ThompsonScore`, `ThompsonArm`, `BetaDistribution`
- **Views:** `ExplainFitSheet` (Beta distribution visualization)
- **Storage:** `ThompsonArm` (Core Data), `ThompsonCache` (in-memory)

### AI Domain (Questions, Learning, Truths)
- **Services:** `SmartQuestionGenerator`, `FastBehavioralLearning`, `DeepBehavioralAnalysis`
- **Models:** `CareerQuestion`, `UserTruths`, `BehavioralPattern`
- **Views:** `QuestionCardView`, `MLInsightsDashboard`
- **Storage:** `CareerQuestion`, `UserTruths` (Core Data)

### API Domain (External Integrations)
- **Services:** `{Source}APIClient` (e.g., `AdzunaAPIClient`)
- **Protocols:** `JobSourceProtocol`, `APICredentialsProvider`
- **Models:** `APICredential`, `RateLimitStatus`, `SourceHealth`
- **Error Handling:** `JobSourceError`, `CircuitBreakerState`

---

## Critical Integration Points

### 1. UI ← → Core Data (Data Binding)
```swift
// In DeckScreen (V7UI)
@Environment(\.managedObjectContext) var context

@FetchRequest(
    entity: SwipeHistory.entity(),
    sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]
) var swipeHistory: FetchedResults<SwipeHistory>

// Write operation
let history = SwipeHistory(context: context)
history.jobId = job.id
try context.save()
```

### 2. Services → Thompson → UI (Job Scoring Pipeline)
```swift
// 1. Services fetches jobs
let rawJobs = try await jobService.fetchJobs(query: query)

// 2. Thompson scores jobs
let scores = rawJobs.map { thompsonEngine.score($0, profile) }

// 3. UI displays scored jobs
let jobItems = zip(rawJobs, scores).map { JobItem(raw: $0, score: $1) }
```

### 3. User Swipes → Behavioral Learning → Thompson Update
```swift
// 1. User swipes (DeckScreen)
handleSwipeAction(.interested)

// 2. Behavioral learning processes
await fastLearning.processSwipe(job, action, thompsonScore)

// 3. Thompson parameters updated
await thompsonEngine.processInteraction(jobId, action)

// 4. Scores recalculated for remaining jobs
updateRemainingJobScores()
```

### 4. Question Answer → UserTruths → Thompson Bonus
```swift
// 1. User answers question
handleQuestionAnswer(question, response)

// 2. AI parses response
let keywords = await generator.parseResponse(response, question, truths)

// 3. UserTruths updated
userTruths.addLoveTask("data analysis")
userTruths.increaseConfidence("loveTasks", by: 0.05)

// 4. Thompson bonus recalculated
let bonus = userTruths.calculateThompsonBonus(for: jobDescription)
finalScore = baseScore * bonus  // 0.5x - 2.0x multiplier
```

### 5. Resume Upload → Parsing → 7 Core Data Entities
```swift
// 1. User uploads PDF
let pdfData = selectedFile.data

// 2. Parsing extracts structured data
let parsed = try await resumeParser.parse(pdfData)

// 3. Validation cleans data
let validated = parsed.validated()

// 4. Transform to 7 Core Data entities
for exp in validated.experience {
    let cdExp = WorkExperience(context: context)
    cdExp.company = exp.company
    cdExp.title = exp.title
    // ...
}
try context.save()
```

---

## Authentication & Security Flow

### API Credential Management
```swift
// 1. Secure storage (Keychain)
KeychainManager.shared.store(apiKey, for: "adzuna_api_key")

// 2. Retrieval in service
let apiKey = try KeychainManager.shared.retrieve("adzuna_api_key")

// 3. Usage in API client
let headers = ["Authorization": "Bearer \(apiKey)"]
```

### Core Data Encryption
- SQLite database encrypted at rest
- UserDefaults for non-sensitive preferences only
- Keychain for API keys and credentials

---

## Cache Architecture (3-Tier)

### L1 Cache: In-Memory (Fastest)
- **Thompson Score Cache:** 50 jobs, 5-minute TTL
- **O*NET Lookup Cache:** Loaded on first access
- **Job ID Mapping:** Current session only

### L2 Cache: Core Data (Fast)
- **JobCache Entity:** 2,000 jobs, 30-minute TTL
- **Resume Parsing Cache:** 50 resumes, SHA256 keyed
- **Skills Taxonomy Cache:** Persistent

### L3 Cache: API Response (Slowest)
- **RSS Feed Cache:** Configurable (1h-30d)
- **Company API Cache:** Session-based
- **Enhanced Job Data:** Keyed by externalId

---

## Error Handling Strategy

### Layered Error Handling

**1. UI Layer:** User-friendly error messages
```swift
.alert("Save Failed", isPresented: $showSaveError) {
    Button("Retry") { saveProfile() }
    Button("Cancel", role: .cancel) { }
}
```

**2. Service Layer:** Circuit breakers & exponential backoff
```swift
guard await rateLimitManager.acquireToken(for: sourceId) else {
    throw JobSourceError.rateLimitExceeded(resetsAt: resetTime)
}
```

**3. Data Layer:** Rollback on failure
```swift
do {
    try context.save()
} catch {
    context.rollback()
    throw error
}
```

---

## Testing Conventions

### Test File Naming
- Pattern: `{Target}Tests.swift`
- Example: `ThompsonSamplingEngineTests.swift`

### Test Function Naming
- Pattern: `test_{Feature}_{Scenario}_{ExpectedResult}`
- Example: `test_ThompsonScoring_WhenSwipeRight_IncreasesAlpha`

### Mock Naming
- Pattern: `Mock{Protocol}.swift`
- Example: `MockJobSourceProtocol.swift`

---

## Summary: Main Modules

| Module | Package | Purpose | Key Metric |
|--------|---------|---------|------------|
| **Presentation** | V7UI | SwiftUI views & forms | 60fps |
| **Job Discovery** | V7Services | 7 API integrations | <2s per API |
| **Thompson Sampling** | V7Thompson | Job scoring algorithm | <10ms per job |
| **Behavioral Learning** | V7AI | Real-time pattern analysis | <50ms per question |
| **Data Persistence** | V7Data | Core Data (14 entities) | <100ms save |
| **Resume Parsing** | V7AIParsing | PDF/NLP extraction | 500ms-5s |
| **O*NET Integration** | V7Core | Career taxonomy | O(1) lookup |
| **Performance Monitoring** | V7Performance | Budget enforcement | <1ms overhead |

**Total Lines of Code:** ~68,000
**Total Swift Files:** 335+
**Total Packages:** 15 (14 active + 1 disabled)
**Architecture Pattern:** MV (Model-View, NO ViewModels)
**Concurrency Model:** Swift 6 strict concurrency with actors
