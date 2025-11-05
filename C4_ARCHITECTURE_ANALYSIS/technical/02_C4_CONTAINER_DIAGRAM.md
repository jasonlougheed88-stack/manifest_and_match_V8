# C4 CONTAINER DIAGRAM
## Manifest & Match V8 - Major Containers View

---

## Diagram Overview

This Container Diagram breaks down the Manifest & Match V8 application into major containers (deployable units like iOS app, databases, packages).

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                         CONTAINER ARCHITECTURE                                 │
└───────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │  Job Seeker  │
    │    (User)    │
    └──────┬───────┘
           │
           │ interacts with
           │
           ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                    MANIFEST & MATCH V8 iOS APPLICATION                        │
│                                                                               │
│  ┌────────────────────────────────────────────────────────────────────┐     │
│  │                     PRESENTATION LAYER (SwiftUI)                    │     │
│  │                                                                     │     │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────┐     │
│  │  │ DeckScreen   │  │ ProfileScreen│  │ HistoryScreen│  │ Manifest│     │
│  │  │ (Job Swipe)  │  │ (User Data)  │  │ (Job Tracker)│  │  Tab    │     │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └─────────┘     │
│  │                                                                     │     │
│  │  ┌──────────────────────────────────────────────────────────────┐  │     │
│  │  │              UI Components (V7UI Package)                     │  │     │
│  │  │  • AccessibleJobCard  • QuestionCardView  • AdCardView       │  │     │
│  │  │  • FormViews (7 entities)  • ExplainFitSheet                 │  │     │
│  │  └──────────────────────────────────────────────────────────────┘  │     │
│  └─────────────────────────────────────────────────────────────────────┘     │
│           │                              │                           │        │
│           │                              │                           │        │
│  ┌────────▼────────────────────┐  ┌─────▼────────────────────────┐  │        │
│  │    BUSINESS LOGIC LAYER     │  │    AI & ALGORITHM LAYER       │  │        │
│  │                             │  │                              │  │        │
│  │  ┌────────────────────────┐ │  │  ┌──────────────────────┐   │  │        │
│  │  │ JobDiscoveryCoordinator│ │  │  │ Thompson Sampling    │   │  │        │
│  │  │                        │ │  │  │ Engine (<10ms)       │   │  │        │
│  │  │ • Fetches from 7 APIs  │ │  │  │                      │   │  │        │
│  │  │ • Normalizes jobs      │ │  │  │ • Beta distribution  │   │  │        │
│  │  │ • Coordinates scoring  │ │  │  │ • Dual-profile blend │   │  │        │
│  │  └────────────────────────┘ │  │  │ • <10ms guarantee    │   │  │        │
│  │                             │  │  └──────────────────────┘   │  │        │
│  │  ┌────────────────────────┐ │  │                              │  │        │
│  │  │ JobSourceIntegration   │ │  │  ┌──────────────────────┐   │  │        │
│  │  │ Service                │ │  │  │ FastBehavioral       │   │  │        │
│  │  │                        │ │  │  │ Learning             │   │  │        │
│  │  │ • Rate limiting        │ │  │  │                      │   │  │        │
│  │  │ • Circuit breakers     │ │  │  │ • Swipe pattern ML   │   │  │        │
│  │  │ • Caching strategy     │ │  │  │ • Fatigue detection  │   │  │        │
│  │  └────────────────────────┘ │  │  │ • Real-time learning │   │  │        │
│  │                             │  │  └──────────────────────┘   │  │        │
│  └─────────────────────────────┘  │                              │  │        │
│           │                       │  ┌──────────────────────┐   │  │        │
│           │                       │  │ SmartQuestion        │   │  │        │
│           │                       │  │ Generator            │   │  │        │
│           │                       │  │                      │   │  │        │
│           │                       │  │ • AI-powered Q&A     │   │  │        │
│           │                       │  │ • Confidence tracking│   │  │        │
│           │                       │  │ • Adaptive timing    │   │  │        │
│           │                       │  └──────────────────────┘   │  │        │
│           │                       └──────────────────────────────┘  │        │
│           │                                                          │        │
│  ┌────────▼──────────────────────────────────────────────────────┐  │        │
│  │              DATA PERSISTENCE LAYER (V7Data)                   │  │        │
│  │                                                                 │  │        │
│  │  ┌──────────────────────────────────────────────────────────┐  │  │        │
│  │  │              Core Data Stack (SQLite)                     │  │  │        │
│  │  │                                                            │  │  │        │
│  │  │  Entities:                                                │  │  │        │
│  │  │  • UserProfile (root entity with 7 relationships)         │  │  │        │
│  │  │  • WorkExperience, Education, Certification, Project       │  │  │        │
│  │  │  • VolunteerExperience, Award, Publication                │  │  │        │
│  │  │  • SwipeHistory (behavioral tracking)                     │  │  │        │
│  │  │  • JobCache (performance caching)                          │  │  │        │
│  │  │  • ThompsonArm (algorithm state)                          │  │  │        │
│  │  │  • CareerQuestion (AI questions)                          │  │  │        │
│  │  │  • UserTruths (discovered preferences)                    │  │  │        │
│  │  │  • Preferences (sacred UI constants)                      │  │  │        │
│  │  └──────────────────────────────────────────────────────────┘  │  │        │
│  └─────────────────────────────────────────────────────────────────┘  │        │
│           │                                                            │        │
│           │                                                            │        │
│  ┌────────▼──────────────────────────────────────────────────────┐   │        │
│  │              SUPPORTING SERVICES LAYER                         │   │        │
│  │                                                                 │   │        │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐    │   │        │
│  │  │ Performance  │  │ Resume       │  │ O*NET            │    │   │        │
│  │  │ Monitoring   │  │ Parsing      │  │ Integration      │    │   │        │
│  │  │              │  │              │  │                  │    │   │        │
│  │  │ • <10ms      │  │ • PDF extract│  │ • 1,016 roles    │    │   │        │
│  │  │   enforcement│  │ • AI parsing │  │ • Work activities│    │   │        │
│  │  │ • Memory     │  │ • NLP skills │  │ • RIASEC profiles│    │   │        │
│  │  │   budgets    │  │   extraction │  │ • Education map  │    │   │        │
│  │  └──────────────┘  └──────────────┘  └──────────────────┘    │   │        │
│  └─────────────────────────────────────────────────────────────────┘   │        │
└──────────────────────────────────────────────────────────────────────────┘        │
           │                      │                         │
           │                      │                         │
           ▼                      ▼                         ▼
┌──────────────────┐   ┌────────────────────┐   ┌───────────────────┐
│ EXTERNAL APIs    │   │ Apple Foundation   │   │ O*NET Database    │
│                  │   │ Models (iOS 26)    │   │ (JSON Bundle)     │
│ • Adzuna         │   │                    │   │                   │
│ • Greenhouse     │   │ • On-device AI     │   │ • Embedded in app │
│ • Lever          │   │ • Career questions │   │ • 1,016 O*NET     │
│ • LinkedIn       │   │ • Pattern analysis │   │   occupations     │
│ • Jobicy         │   │ • Zero API costs   │   │ • 5MB data        │
│ • USAJobs        │   │                    │   │                   │
│ • RSS Feeds      │   │                    │   │                   │
└──────────────────┘   └────────────────────┘   └───────────────────┘
```

---

## Container Definitions

### CONTAINER 1: iOS Application (Primary)

**Technology:** Swift 6, SwiftUI, Xcode 26
**Deployment:** App Store, TestFlight
**Platform:** iOS 26+, iPadOS 26+
**Architecture Pattern:** MV (Model-View, NO ViewModels)

**Purpose:** Native iOS job discovery app with behavioral learning and Thompson Sampling

**Sub-Containers (SPM Packages):**
- **V7UI** - Presentation layer (SwiftUI views)
- **V7Core** - Foundation (0 external dependencies)
- **V7Thompson** - Thompson Sampling algorithm
- **V7Data** - Core Data persistence
- **V7Services** - API integrations (7 job sources)
- **V7AI** - Behavioral learning & questions
- **V7AIParsing** - Resume & job parsing
- **V7JobParsing** - Job description analysis
- **V7ResumeAnalysis** - Resume extraction
- **V7Embeddings** - Vector similarity (framework)
- **V7Performance** - Performance monitoring
- **V7Career** - Career building hub
- **V7Ads** - Ad integration (placeholder mode)
- **V7Migration** - Data migration (disabled)

**Entry Point:** `@main ManifestAndMatchV7App`

**Memory Budget:** <200MB baseline, <250MB peak

---

### CONTAINER 2: Core Data Storage (SQLite)

**Technology:** Core Data (NSPersistentContainer)
**Location:** Application Support directory
**Size:** Dynamic (grows with user data)
**Backup:** iCloud (optional, not yet enabled)

**Entities (14 Total):**

**Profile Entities (8):**
1. UserProfile (root, singleton)
2. WorkExperience (many-to-one with UserProfile)
3. Education (many-to-one)
4. Certification (many-to-one)
5. Project (many-to-one)
6. VolunteerExperience (many-to-one)
7. Award (many-to-one)
8. Publication (many-to-one)

**Behavioral Entities (4):**
9. SwipeHistory (user interactions, timestamp-indexed)
10. ThompsonArm (algorithm state, domain-indexed)
11. CareerQuestion (AI questions, priority-indexed)
12. UserTruths (discovered preferences, userId-indexed)

**Performance Entities (2):**
13. JobCache (job caching with embeddings, expiresAt-indexed)
14. Preferences (sacred UI constants, singleton)

**Relationships:**
- UserProfile → (1:N) → WorkExperience, Education, Certification, etc.
- UserTruths → (N:1) → UserProfile (via userId UUID)
- All cascade delete except SwipeHistory (nullify for analytics preservation)

**Concurrency Model:**
- viewContext: Main thread (UI reads/writes)
- backgroundContext: Private queue (background tasks)
- Actor-isolated for Swift 6 strict concurrency

---

### CONTAINER 3: O*NET Database (JSON Bundle)

**Technology:** JSON resource bundle (embedded)
**Location:** App bundle (read-only)
**Size:** ~5MB uncompressed
**Update Frequency:** App updates only

**Files:**
- `RolesDatabase.json` - 1,016 O*NET occupations
- `SkillTaxonomy.json` - 636 skills across 14 sectors
- `WorkActivities.json` - 41 work activity dimensions
- `EducationLevels.json` - 12-level O*NET scale

**Loading:**
- Actor-based SkillTaxonomyLoader
- Lazy initialization on first access
- In-memory caching for O(1) lookups
- Thread-safe via Swift actors

**Usage:**
- Work experience O*NET role selection
- Thompson scoring enhancement (30% weight)
- Cross-domain career discovery
- Skills normalization and fuzzy matching

---

### CONTAINER 4: Apple Foundation Models (iOS 26 System Service)

**Technology:** Apple Intelligence (iOS 26+)
**Location:** System framework (not embedded)
**API:** Foundation Models API
**Cost:** $0 (included in iOS)

**Capabilities:**
- Career question processing (<50ms per question)
- Behavioral pattern analysis (swipe history)
- RIASEC personality inference
- Work style extraction
- Skills categorization

**Integration Points:**
- FastBehavioralLearning (real-time)
- DeepBehavioralAnalysis (background batch)
- SmartQuestionGenerator (contextual Q&A)
- UserTruths discovery (preference extraction)

**Privacy:**
- 100% on-device processing
- No external API calls
- No token usage or rate limits
- GDPR/CCPA compliant

---

### CONTAINER 5: External Job APIs (7 REST Services)

**Technology:** REST over HTTPS
**Authentication:** API Keys / OAuth (varies by source)
**Rate Limiting:** Source-dependent (10-100 req/min)

**API Sources:**

| API | Type | Auth | Rate Limit | Priority |
|-----|------|------|------------|----------|
| Adzuna | Aggregator | API Key | 60/min | 3 |
| Greenhouse | Company Boards | None | 60/min | 2 |
| Lever | Company Boards | Optional | 100/min | 2 |
| LinkedIn | Professional Network | OAuth | 300/month | 1 |
| Jobicy | Remote Jobs | None | 10/min | 5 |
| USAJobs | Government | API Key | 10/min | 6 |
| RSS Feeds | Custom | None | 20/min | 7 |

**Normalization:** All APIs → RawJobData struct → Thompson scoring

**Error Handling:**
- Circuit breakers (3-5 failure threshold)
- Exponential backoff (1s, 2s, 4s, 8s max)
- Graceful degradation (continue with other sources)

---

### CONTAINER 6: Google AdMob (Optional, Currently Disabled)

**Technology:** Google Mobile Ads SDK
**Status:** PLACEHOLDER MODE (SDK commented out)
**Integration:** V7Ads package

**If Enabled:**
- Native ad cards in job feed
- Ad placement: 1 ad per 10 jobs
- ATT consent flow
- CloudKit performance tracking

**Performance Targets:**
- <350KB memory per ad
- <500ms ad load time
- 60fps animation

**Current Status:** Infrastructure exists but SDK not linked

---

## Data Flows Between Containers

### 1. User Profile Creation Flow
```
User Input (SwiftUI Forms)
  → V7UI (FormViews)
  → V7Data (Core Data entities)
  → SQLite Database
  → AppState (in-memory cache)
```

### 2. Resume Upload Flow
```
User Uploads PDF
  → V7AIParsing (PDFKit extraction)
  → V7ResumeAnalysis (NLP parsing)
  → ParsedResume (transient struct)
  → V7Data (7 Core Data entities)
  → SQLite Database
```

### 3. Job Discovery Flow
```
User Opens DeckScreen
  → JobDiscoveryCoordinator
  → V7Services (7 API clients)
  → External Job APIs (HTTPS requests)
  → RawJobData (normalized)
  → V7Thompson (Thompson scoring <10ms)
  → V7Data (JobCache persistence)
  → V7UI (DeckScreen display)
```

### 4. Swipe Interaction Flow
```
User Swipes Job Card
  → DeckScreen (gesture handler)
  → BehavioralEventLog (immutable record)
  → FastBehavioralLearning (real-time ML)
  → V7Thompson (Beta parameter update)
  → V7Data (SwipeHistory entity)
  → ApplicationTracker (SwiftData history)
  → AppState (session metrics)
```

### 5. Career Question Flow
```
SmartQuestionGenerator (generates question)
  → V7Data (CareerQuestion entity)
  → DeckScreen (QuestionCardView)
  → User Answers
  → V7AI (NLP parsing)
  → V7Data (UserTruths entity)
  → Thompson bonus calculation (updated scores)
```

### 6. O*NET Integration Flow
```
User Selects Work Experience
  → WorkExperienceFormView
  → O*NET Database (JSON lookup)
  → Role Selection (1,016 options)
  → V7Data (WorkExperience with O*NET role)
  → Thompson scoring enhancement (30% weight)
```

---

## Container Communication Patterns

### Synchronous (Request-Response)
- UI → Business Logic: Direct function calls (@MainActor)
- Business Logic → Core Data: `context.perform {}`
- Thompson Engine → User Profile: Synchronous data access

### Asynchronous (Futures/Promises)
- API Calls: `async/await` with structured concurrency
- Background Tasks: `Task.detached(priority: .background)`
- Actor Communication: Message passing with isolation

### Event-Driven (Publishers)
- Thompson Score Updates: AsyncStream broadcasting
- Profile Changes: Combine publishers
- Application State: @Observable pattern

### Caching Layers
- **L1 Cache:** In-memory (50 jobs, 5-minute TTL)
- **L2 Cache:** Core Data JobCache (2000 jobs, 30-minute TTL)
- **L3 Cache:** API response caching (1-hour TTL)

---

## Security Boundaries

### App Sandbox
- Core Data: Encrypted at rest
- Keychain: Secure credential storage
- UserDefaults: Non-sensitive preferences only

### Network Security
- HTTPS only for all API calls
- Certificate validation
- API key rotation ready

### Process Isolation
- Foundation Models: System process (sandboxed)
- Core Data: App process (sandboxed)
- APIs: External (TLS encrypted)

---

## Deployment Architecture

### Single Deployment Unit
- iOS app bundle (.ipa)
- Embedded O*NET JSON resources
- No separate backend server required

### External Dependencies (Runtime)
- Job APIs (internet required)
- Apple Foundation Models (iOS 26 required)
- Optional: iCloud (user choice)
- Optional: AdMob (if feature enabled)

### Update Strategy
- App Store updates for app code
- Bundle updates for O*NET data
- No backend database migrations

---

## Container Sizing & Performance

| Container | Size | Memory | Performance Target |
|-----------|------|--------|-------------------|
| iOS App Binary | ~50MB | - | - |
| O*NET Database | 5MB | 10MB loaded | <500ms initial load |
| Core Data | Dynamic | 20-50MB | <100ms save |
| Thompson Engine | - | <10MB | <10ms per job |
| Job Cache | Dynamic | 8MB | O(1) lookup |
| Foundation Models | System | Managed by OS | <50ms per query |

---

## Summary

**Total Containers:** 6
1. iOS Application (15 SPM packages)
2. Core Data Storage (14 entities)
3. O*NET Database (JSON bundle)
4. Apple Foundation Models (system service)
5. External Job APIs (7 sources)
6. Google AdMob (optional, disabled)

**Container Dependencies:**
- iOS App → Core Data (strong)
- iOS App → O*NET Database (strong, embedded)
- iOS App → Foundation Models (strong, system)
- iOS App → Job APIs (weak, internet-dependent)
- iOS App → AdMob (weak, optional)

**Deployment Model:** Monolithic iOS app with embedded resources, no separate backend server
