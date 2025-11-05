# ANNOTATED COMPONENT MAP
## Team Conventions & Critical Sections Guide

---

## Purpose
This document serves as the **developer onboarding guide** and **team conventions reference**, showing:
- What each component does
- Where to find critical logic
- Naming conventions per domain
- Common patterns and anti-patterns
- Quick reference for new team members

---

## Component Catalog (By Domain)

### 🎨 PRESENTATION DOMAIN (V7UI Package)

#### Components

**DeckScreen.swift** (1,800+ lines) - PRIMARY USER INTERFACE
```
Location: /Packages/V7UI/Sources/V7UI/Views/DeckScreen.swift
Purpose: Main job discovery screen with swipe interface
Critical Sections:
  • Lines 665-853: handleSwipeAction() - 7-layer persistence pipeline
  • Lines 1207-1235: fetchOrCreateUserTruths() - Thread-safe Core Data access
  • Lines 1350-1402: loadMoreJobs() - Incremental job loading
  • Lines 1404-1418: updateRemainingJobScores() - Differential scoring

Naming Convention:
  • State variables: @State var currentCards: [CardItem]
  • Handlers: func handle{Action}Action(_:)
  • Loaders: func load{Feature}()

Team Notes:
  ⚠️ SACRED: Swipe thresholds (100pt, -100pt, -80pt) NEVER CHANGE
  ⚠️ PERFORMANCE: Thompson scoring must complete in <10ms
  ✅ ACCESSIBILITY: All elements have VoiceOver labels
```

**AccessibleJobCard.swift** - JOB CARD COMPONENT
```
Location: /Packages/V7UI/Sources/V7UI/Accessibility/AccessibleJobCard.swift
Purpose: WCAG AA compliant job card with swipe gestures
Critical Sections:
  • Gesture handlers: onSwipe callback
  • VoiceOver labels: All interactive elements
  • Dynamic Type: Supports small → XXXL
  • Contrast ratios: 4.5:1 minimum (WCAG AA)

Naming Convention:
  • Cards: {Type}Card.swift (JobCard, AdCard, QuestionCard)
  • Accessibility: Accessible{Component}.swift

Team Notes:
  ✅ WCAG 2.1 AA compliant - DO NOT regress contrast ratios
  ✅ VoiceOver tested on every PR
  ⚠️ Card dimensions sacred: 92% width, 85% height (SacredUI constants)
```

**ProfileScreen.swift** - USER PROFILE MANAGEMENT
```
Location: /Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift
Purpose: User data management with 7 Core Data entity forms
Critical Sections:
  • Lines 148-183: saveProfile() - Dual persistence (Core Data + AppState)
  • Lines 100-121: loadCurrentProfile() - Fallback from Core Data → AppState
  • Form sheet states: 7 @State vars for each entity type

Naming Convention:
  • Forms: {Entity}FormView.swift
  • Save handlers: save{Entity}()
  • Load handlers: load{Feature}()

Team Notes:
  ⚠️ CRITICAL: WorkExperience/Education NOT persisting (bug in onboarding)
  ✅ All saves have rollback on error
  ✅ Validation before save (non-empty checks)
```

**{Entity}FormView.swift** (7 forms) - DATA INPUT FORMS
```
Locations:
  • WorkExperienceFormView.swift - O*NET role selection (1,016 roles)
  • EducationFormView.swift - 12 O*NET education levels
  • CertificationFormView.swift - Certification entry
  • ProjectFormView.swift - Portfolio projects
  • VolunteerExperienceFormView.swift - Volunteer work
  • AwardFormView.swift - Awards and honors
  • PublicationFormView.swift - Research publications

Common Pattern:
  • editingEntity: WorkExperience? (nil = add, non-nil = edit)
  • @State properties mirror Core Data fields
  • saveEntity() -> context.save() -> dismiss()

Team Notes:
  ✅ O*NET integration: WorkExperience (roles), Education (levels)
  ⚠️ Validation: Check empty strings before save
  ⚠️ Accessibility: All fields have labels for VoiceOver
```

---

### 🔍 JOB DISCOVERY DOMAIN (V7Services Package)

#### Components

**JobDiscoveryCoordinator.swift** - JOB ORCHESTRATOR
```
Location: /Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
Purpose: Orchestrates job fetching, scoring, and caching
Critical Sections:
  • loadInitialJobs() - Entry point for job discovery
  • buildSearchQuery() - Extracts user preferences
  • Parallel API calls - Fetches from 7 sources concurrently
  • Thompson scoring pipeline - <10ms per job

Naming Convention:
  • Coordinators: {Feature}Coordinator.swift
  • Services: {Feature}Service.swift
  • Clients: {Source}APIClient.swift

Team Notes:
  ✅ Error handling: Continue with other sources if one fails
  ✅ Rate limiting: Per-source token buckets
  ⚠️ TODO: Add LinkedIn API client when ready
```

**AdzunaAPIClient.swift** (and 6 other API clients)
```
Location: /Packages/V7Services/Sources/V7Services/CompanyAPIs/{Source}APIClient.swift
Purpose: API-specific job fetching with rate limiting
Critical Sections:
  • fetchJobs() - Async API call with error handling
  • normalizeJob() - Transform API response to RawJobData
  • Rate limiting: Token bucket pattern (60-100 req/min)
  • Circuit breakers: 3-5 failure threshold

API Clients:
  • AdzunaAPIClient - Global aggregator (60 req/min)
  • GreenhouseAPIClient - Company boards (60 req/min)
  • LeverAPIClient - Company boards (100 req/min)
  • JobicyAPIClient - Remote jobs (10 req/min)
  • USAJobsAPIClient - Government jobs (10 req/min)
  • RSSFeedJobSource - RSS/Atom feeds (20 req/min)
  • LinkedInAPIClient - Planned (300 req/month)

Naming Convention:
  • Pattern: {Source}APIClient.swift
  • Protocol: JobSourceProtocol
  • Errors: JobSourceError enum

Team Notes:
  ⚠️ AUTHENTICATION: Store API keys in Keychain (never hardcode)
  ✅ Circuit breakers prevent cascading failures
  ✅ Exponential backoff: 1s, 2s, 4s, 8s max
```

**RateLimitManager.swift** - RATE LIMITING SERVICE
```
Location: /Packages/V7Services/Sources/V7Services/CompanyAPIs/RateLimitManager.swift
Purpose: Token bucket rate limiting for all API sources
Critical Sections:
  • registerSource() - Define per-source rate limits
  • acquireToken() - Thread-safe token acquisition
  • Token refill: Background timer refills buckets

Pattern: Actor-based for thread safety
  actor RateLimitManager {
      private var tokenBuckets: [String: TokenBucket] = [:]
      // ...
  }

Team Notes:
  ✅ Singleton: RateLimitManager.shared
  ✅ Per-source limits: Configure in API client init
  ⚠️ Burst capacity: Allows short spikes above sustained rate
```

---

### 🎯 ALGORITHM DOMAIN (V7Thompson Package)

#### Components

**ThompsonSamplingEngine.swift** - CORE SCORING ALGORITHM
```
Location: /Packages/V7Thompson/Sources/V7Thompson/ThompsonSamplingEngine.swift
Purpose: <10ms Thompson Sampling implementation (357x faster)
Critical Sections:
  • score(job:profile:) - Main scoring function (<10ms)
  • Beta distribution sampling - Marsaglia & Tsang algorithm
  • Dual-profile blend - Amber (exploitation) + Teal (exploration)
  • processInteraction() - Update model from swipe feedback

Mathematical Correctness:
  • Beta(α, β) via Gamma method (not pow() bug from V5.7)
  • Sample_amber * (1 - ω) + Sample_teal * ω
  • Combined = (Personal + Professional) / 2 + Exploration
  • Clamp to [0.0, 0.95]

Naming Convention:
  • Engines: {Algorithm}Engine.swift
  • Samplers: {Distribution}Sampler.swift
  • Scores: ThompsonScore struct

Team Notes:
  ⚠️ SACRED: <10ms constraint enforced in CI/CD (357x advantage)
  ⚠️ Performance: Use FastBetaSampler for 10x speedup
  ✅ Mathematical correctness: Beta distribution validated
  ✅ Zero bias: Beta(1,1) = Uniform(0,1) initial prior
```

**FastBetaSampler.swift** - OPTIMIZED SAMPLER
```
Location: /Packages/V7Thompson/Sources/V7Thompson/FastBetaSampler.swift
Purpose: 10x faster Beta sampling via Kumaraswamy approximation
Critical Sections:
  • Kumaraswamy distribution: 2 operations vs Gamma's ~20
  • SIMD vectorization: Process 4 samples in parallel (ARM64)
  • Lookup table: 490x490 precomputed values for common α, β

Performance:
  • Standard Beta: ~1ms per sample
  • Fast Beta: <0.1ms per sample (10x faster)
  • Accuracy: ~98% (2% trade-off for speed)

Team Notes:
  ✅ Use for production (speed over 2% accuracy)
  ✅ SIMD-optimized for ARM64 (iPhone 12+)
  ⚠️ Lookup table: ~4MB memory (acceptable vs 10MB budget)
```

**ThompsonCache.swift** - LOCK-FREE CACHE
```
Location: /Packages/V7Thompson/Sources/V7Thompson/ThompsonCache.swift
Purpose: High-performance score caching (50-entry LRU)
Critical Sections:
  • Lock-free design: NSLock for batch operations only
  • LRU eviction: Remove oldest when >50 entries
  • TTL: 5-minute cache expiration

Performance:
  • Cache hit: <0.001ms (vs 0.028ms recalculation)
  • 24x faster than actor serialization
  • 50-entry limit prevents memory bloat

Team Notes:
  ✅ Use lock.withLock {} for batch operations (not per-access)
  ✅ Thread-safe via NSLock (Swift 6 compliant)
  ⚠️ Clear cache when Thompson parameters change
```

---

### 🧠 AI/ML DOMAIN (V7AI Package)

#### Components

**FastBehavioralLearning.swift** - REAL-TIME SWIPE ANALYSIS
```
Location: /Packages/V7AI/Sources/V7AI/FastBehavioralLearning.swift
Purpose: Real-time ML pattern detection from swipe behavior
Critical Sections:
  • processSwipe() - Immediate pattern classification (<2ms)
  • 8-dimensional feature extraction - Duration, velocity, score, etc.
  • 5 pattern types - Decisive, Exploratory, Cautious, Impulsive, Methodical
  • Fatigue detection - 5 fatigue features with weighted scoring

Pattern Classification:
  pattern_score = dot_product(features, pattern_weights)
  best_pattern = argmax(pattern_scores)

Fatigue Detection:
  fatigue = dot_product(fatigue_features, [0.3, 0.2, 0.25, 0.15, 0.1])
  recommend_break = fatigue > 0.6

Team Notes:
  ✅ @MainActor isolated for UI thread safety
  ✅ <2ms performance (within <10ms Thompson budget)
  ⚠️ Window size: Last 20-50 swipes analyzed
```

**SmartQuestionGenerator.swift** - CAREER QUESTION GENERATION
```
Location: /Packages/V7AI/Sources/V7AI/SmartQuestionGenerator.swift
Purpose: Generate contextual career discovery questions
Critical Sections:
  • generateNextQuestion() - AI-powered question creation
  • Confidence-based prioritization - Focus on low-confidence fields
  • NLP response parsing - Extract keywords and sentiment
  • UserTruths updates - Populate loves/hates/values/interests

Question Strategy:
  if loveTasks.confidence < 0.5:
      Ask about task preferences
  elif hateTasks.confidence < 0.5:
      Ask about tasks to avoid
  elif workValues.isEmpty:
      Ask about work values
  elif interests.isEmpty:
      Ask about industry interests

Team Notes:
  ✅ Adaptive timing: 5-20 jobs between questions
  ✅ Skip limit: Deactivate after 3 skips
  ⚠️ Foundation Models: iOS 26 on-device AI (<50ms per question)
```

**DeepBehavioralAnalysis.swift** - BACKGROUND BATCH ANALYSIS
```
Location: /Packages/V7AI/Sources/V7AI/DeepBehavioralAnalysis.swift
Purpose: Background analysis of swipe batches (every 10 swipes)
Critical Sections:
  • analyzeBatch() - iOS 26 Foundation Models integration
  • RIASEC profile inference - 6 Holland Code dimensions
  • Work style extraction - 7 dimensions from O*NET
  • Confidence scoring - 0.0-1.0 per field

Performance:
  • Batch size: 10 swipes
  • Analysis time: ~2 seconds (background thread)
  • Foundation Models: On-device, no API costs

Team Notes:
  ✅ Task.detached(priority: .background) - Non-blocking
  ✅ Proper actor isolation - @preconcurrency import CoreData
  ⚠️ Results logged for now (profile update pending)
```

---

### 💾 DATA DOMAIN (V7Data Package)

#### Components

**PersistenceController.swift** - CORE DATA STACK
```
Location: /Packages/V7Data/Sources/V7Data/PersistenceController.swift
Purpose: Core Data setup and management
Critical Sections:
  • Singleton: PersistenceController.shared
  • NSPersistentContainer: V7DataModel.xcdatamodeld
  • Contexts: viewContext (main), backgroundContext (private queue)
  • CloudKit: Ready but disabled by default

Concurrency Model:
  • viewContext: @MainActor (UI reads/writes)
  • backgroundContext: private queue (background tasks)
  • context.perform {} for thread safety

Team Notes:
  ✅ Use viewContext for UI operations
  ✅ Use backgroundContext for batch operations
  ⚠️ NEVER pass NSManagedObject across threads (use ObjectID)
  ⚠️ CloudKit sync disabled (enable if multi-device needed)
```

**UserProfile+CoreData.swift** (and 13 other entities)
```
Locations: /Packages/V7Data/Sources/V7Data/{Entity}+CoreData.swift
Purpose: Core Data entity definitions with computed properties
Entities:
  Profile (8):
    • UserProfile - Root entity (singleton)
    • WorkExperience - Job history
    • Education - Education history
    • Certification - Certifications
    • Project - Portfolio projects
    • VolunteerExperience - Volunteer work
    • Award - Awards and honors
    • Publication - Research publications

  Behavioral (4):
    • SwipeHistory - User interactions
    • ThompsonArm - Algorithm state
    • CareerQuestion - AI questions
    • UserTruths - Discovered preferences

  Performance (2):
    • JobCache - Job caching
    • Preferences - Sacred UI constants

Naming Convention:
  • Files: {Entity}+CoreData.swift
  • Fetch: {Entity}.fetchCurrent(in: context)
  • Extensions: {Entity}+{Feature}.swift

Team Notes:
  ✅ All entities have computed properties for validation
  ✅ Relationships: CASCADE delete for profile entities
  ⚠️ UserTruths: Uses @preconcurrency for Swift 6 compatibility
  ⚠️ Preferences: Override willSave() to protect sacred values
```

---

### 📄 PARSING DOMAIN (V7AIParsing Package)

#### Components

**ResumeParsingService.swift** - RESUME PARSER
```
Location: /Packages/V7AIParsing/Sources/V7AIParsing/ResumeParsingService.swift
Purpose: Extract structured data from resumes
Critical Sections:
  • parse(data:options:) - Main entry point
  • PDFTextExtractor - PDFKit text extraction
  • Basic parsing: Regex patterns (0.7 confidence)
  • AI parsing: OpenAI integration (0.95 confidence)
  • Caching: LRU cache (50 resumes, SHA256 keyed)

Parsing Methods:
  1. Basic (500ms):
     - Regex email: [A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,64}
     - Regex phone: Multiple patterns (US, international)
     - Keyword matching for skills (636-skill taxonomy)

  2. AI-Enhanced (2-5s):
     - OpenAI GPT-4 structured extraction
     - Higher confidence (0.95 vs 0.7)
     - Better accuracy for complex resumes

Team Notes:
  ✅ Validation: parsed.validated() removes invalid entries
  ✅ Caching: Prevents re-parsing same resume (SHA256 key)
  ⚠️ AI parsing optional: Requires OpenAI API key
  ⚠️ Performance: 500ms-5s (show progress indicator)
```

---

## Critical Logic Locations (Quick Reference)

### Authentication & Security
```
Keychain Management:    /V7AI/Sources/V7AI/KeychainManager.swift
API Credentials:        KeychainManager.shared.store/retrieve()
Core Data Encryption:   Automatic (SQLite encrypted at rest)
```

### Error Handling
```
Circuit Breakers:       /V7Services/.../CircuitBreaker pattern
Rate Limiting:          /V7Services/.../RateLimitManager.swift
Exponential Backoff:    /V7Services/.../retry logic in API clients
Core Data Rollback:     context.rollback() on catch blocks
```

### Performance Critical Paths
```
Thompson Sampling:      /V7Thompson/.../ThompsonSamplingEngine.swift
                        SACRED: <10ms per job (line 200-250)

Fast Beta Sampler:      /V7Thompson/.../FastBetaSampler.swift
                        10x speedup via Kumaraswamy approximation

Real-time Scoring:      /V7Thompson/.../RealTimeScoring.swift
                        Differential updates (50% computation reduction)
```

### Data Persistence Critical Paths
```
Profile Save:           /V7UI/.../ProfileSettingsView.swift:148-183
                        ⚠️ CRITICAL: Dual persistence (Core Data + AppState)

Work Experience:        /V7UI/.../WorkExperienceCollectionStepView.swift:145
                        🚨 BUG: NOT persisting to Core Data (fix required)

Swipe History:          /V7UI/.../DeckScreen.swift:665-853
                        ✅ WORKING: 7-layer persistence pipeline
```

### UI Rendering Critical Paths
```
Job Card Rendering:     /V7UI/.../AccessibleJobCard.swift
                        Target: 60fps (16.67ms per frame)

Swipe Gestures:         /V7UI/.../DeckScreen.swift:400-500
                        Thresholds: 100pt, -100pt, -80pt (SACRED)

Form Validation:        /V7UI/.../ProfileSetupStepView.swift:217-226
                        Inline validation before save
```

---

## Common Patterns

### 1. Async/Await API Calls
```swift
// Pattern: Structured concurrency with error handling
func fetchJobs() async throws -> [RawJobData] {
    guard await rateLimitManager.acquireToken(for: sourceId) else {
        throw JobSourceError.rateLimitExceeded(resetsAt: resetTime)
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw JobSourceError.invalidResponse(response)
    }

    return try JSONDecoder().decode([RawJobData].self, from: data)
}
```

### 2. Core Data Thread Safety
```swift
// Pattern: context.perform for thread-safe operations
await context.perform {
    let entity = Entity(context: context)
    entity.property = value
    try context.save()
}
```

### 3. SwiftUI State Management
```swift
// Pattern: @State for local, @Binding for parent control
struct FormView: View {
    @State private var name: String = ""
    @Binding var isPresented: Bool

    func save() {
        // Save logic
        isPresented = false  // Dismiss
    }
}
```

### 4. Protocol-Based Dependency Injection
```swift
// Pattern: Protocol abstraction for testability
protocol JobSourceProtocol {
    func fetchJobs(query: JobSearchQuery) async throws -> [RawJobData]
}

struct JobDiscoveryCoordinator {
    private var sources: [JobSourceProtocol] = []

    func registerSource(_ source: JobSourceProtocol) {
        sources.append(source)
    }
}
```

---

## Anti-Patterns (DO NOT DO)

### ❌ Passing NSManagedObject Across Threads
```swift
// WRONG: Crashes with concurrency violations
Task {
    let profile = fetchProfile()  // Main thread
    await backgroundTask(profile)  // ❌ Crash: different thread
}

// CORRECT: Use ObjectID
Task {
    let profileID = fetchProfile().objectID
    await backgroundTask(profileID)
    // Inside backgroundTask:
    let profile = context.object(with: profileID) as! UserProfile
}
```

### ❌ Modifying Sacred UI Constants
```swift
// WRONG: Never modify SacredUI values
enum SacredUI {
    static let swipeRightThreshold = 50.0  // ❌ Changed from 100.0
}

// CORRECT: SacredUI values are immutable guarantees
// Protected by Preferences entity's willSave() override
```

### ❌ Blocking Main Thread
```swift
// WRONG: Synchronous API call on main thread
func fetchJobs() -> [Job] {
    let data = try! Data(contentsOf: url)  // ❌ Blocks UI
    return parse(data)
}

// CORRECT: Async/await with background execution
func fetchJobs() async throws -> [Job] {
    let (data, _) = try await URLSession.shared.data(from: url)
    return parse(data)
}
```

### ❌ Empty Button Actions
```swift
// WRONG: Button with no action (currently exists in 11+ places)
Button("Cancel", role: .cancel) { }  // ❌ Does nothing

// CORRECT: Implement dismiss or state change
Button("Cancel", role: .cancel) {
    dismiss()
}
```

---

## Team Conventions Summary

### File Organization
```
/Packages/{PackageName}/
├─ Sources/{PackageName}/
│  ├─ Models/          (Data structures)
│  ├─ Services/        (Business logic)
│  ├─ Views/           (SwiftUI components)
│  ├─ Protocols/       (Interface contracts)
│  └─ Extensions/      (Type extensions)
├─ Tests/{PackageName}Tests/
│  └─ {Feature}Tests.swift
└─ Package.swift
```

### Code Style
- **Indentation:** 4 spaces (no tabs)
- **Line Length:** 120 characters max
- **Braces:** Same line for functions, new line for types
- **Access Control:** Explicit (public/internal/private)
- **Documentation:** Required for public APIs

### Git Workflow
- **Branch Naming:** `feature/{ticket-id}-{description}`
- **Commit Messages:** `{Type}: {Description}` (e.g., "Fix: Thompson scoring regression")
- **PR Requirements:** Tests pass, no Thompson <10ms violations, accessibility verified

---

## Onboarding Checklist for New Developers

### Week 1: Setup & Architecture
- [ ] Clone repository
- [ ] Build app (Xcode 26, iOS 26 simulator)
- [ ] Read this document (ANNOTATED_COMPONENT_MAP.md)
- [ ] Read DEPENDENCY_GRAPH.md
- [ ] Review C4 diagrams (Context, Container)

### Week 2: Code Exploration
- [ ] Read V7Core package (foundation layer)
- [ ] Read V7Thompson package (algorithm)
- [ ] Read V7UI package (presentation)
- [ ] Run app, complete onboarding flow
- [ ] Swipe 50 jobs, observe Thompson scoring

### Week 3: First Contribution
- [ ] Fix one of the 11+ empty button actions
- [ ] Write unit test for fix
- [ ] Submit PR with accessibility verification
- [ ] Code review by senior developer

---

## Quick Reference Card

### Most Important Files
1. **DeckScreen.swift** - Primary UI, swipe handling
2. **ThompsonSamplingEngine.swift** - Core algorithm (<10ms)
3. **JobDiscoveryCoordinator.swift** - Job orchestration
4. **PersistenceController.swift** - Core Data stack
5. **FastBehavioralLearning.swift** - Real-time ML

### Most Critical Constraints
1. Thompson Sampling: **<10ms per job** (357x advantage)
2. Memory Baseline: **<200MB** sustained
3. UI Rendering: **60fps** (16.67ms per frame)
4. API Response: **<2s** per job source
5. SacredUI Constants: **NEVER CHANGE** (user muscle memory)

### Common Tasks
- **Add new API source:** Implement JobSourceProtocol in V7Services
- **Add new Core Data entity:** Update V7DataModel.xcdatamodeld + add +CoreData.swift file
- **Add new SwiftUI view:** Create in V7UI, follow MV pattern (no ViewModels)
- **Fix performance issue:** Check V7Performance violations, optimize Thompson path
- **Fix accessibility issue:** Verify VoiceOver labels, contrast ratios (WCAG AA)

---

## Contact & Support

**Architecture Questions:** Review DEPENDENCY_GRAPH.md
**Data Model Questions:** Review technical/06_DATA_MODELS.md
**Thompson Algorithm:** Review technical/08_THOMPSON_SAMPLING_MATHEMATICS.md
**Bugs & Issues:** Check technical/12_DEAD_CODE_ANALYSIS.md for known issues

**Code Review Process:**
1. Create feature branch
2. Make changes
3. Run tests (`⌘U`)
4. Verify Thompson <10ms (Performance Monitor logs)
5. Test accessibility (VoiceOver ON)
6. Submit PR with description

---

This annotated component map serves as the **single source of truth** for team conventions and onboarding. Update this document when adding new components or changing critical conventions.
