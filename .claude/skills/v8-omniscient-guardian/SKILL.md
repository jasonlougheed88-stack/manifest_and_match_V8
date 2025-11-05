---
description: Master meta-skill with complete V8 codebase knowledge, self-updating capabilities, and diagnostic expertise for Manifest & Match iOS 26 app
version: 1.0.0
author: V8 Development Team
tags: [meta-skill, v8, ios26, thompson-sampling, onet, self-updating, diagnostics]
---

# V8-Omniscient-Guardian Meta-Skill

**The all-knowing, self-updating meta-skill system for Manifest & Match V8**

## Core Mission

Master the ENTIRE V8 codebase (68K+ LOC, 506 Swift files, 14 packages) with ability to:
- **Self-update** by scanning actual codebase + technical docs
- **Self-diagnose** code issues, performance regressions, architecture violations
- **Delegate** to 7 specialized domain expert sub-skills
- **Integrate** business planning, narrative alignment, and timeless architecture skills
- **Code like a pro** for Xcode 16, iOS 26, Swift 6, SwiftUI

## Two-Source Truth System

### Source #1: Live V8 Codebase
**Location**: `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8`

**What it contains**:
- 14 active Swift packages (V7Core → V7UI)
- 506 Swift files
- 68,000+ lines of code
- Core Data model (14 entities)
- 7 API integrations
- Thompson Sampling algorithm (<10ms)

### Source #2: Technical Documentation
**Location**: `/Users/jasonl/Desktop/ios26_manifest_and_match/C4_ARCHITECTURE_ANALYSIS/technical`

**What it contains**:
- 14 comprehensive architecture docs
- 06_DATA_MODELS.md (32 model definitions)
- 07_JOB_SOURCE_INTEGRATIONS.md (7 API clients)
- 08_THOMPSON_SAMPLING_MATHEMATICS.md (algorithm math)
- 09_AI_ML_INTEGRATIONS.md (7 AI systems, iOS 26)
- 10_DATA_FLOWS.md (5 major flows)
- 11_UI_COMPONENTS.md (28 SwiftUI views)
- 12_DEAD_CODE_ANALYSIS.md (47 dead code instances)
- 13_CONNECTION_VALIDATION.md (2 critical bugs)

## Architecture Knowledge (5-Level Hierarchy)

### LEVEL 0: Foundation
- **V7Core** (0 deps): SacredUI constants, protocols, 636-skill taxonomy, 1,016 O*NET occupations

### LEVEL 1: Algorithm & Data
- **V7Thompson** (2 deps): <10ms Thompson Sampling (357x faster), FastBetaSampler, ThompsonCache
- **V7Data** (1 dep): Core Data stack, 14 entities, NSPersistentContainer
- **V7Performance** (2 deps): Performance monitoring, <10ms enforcement, memory tracking

### LEVEL 2: Services & Parsing
- **V7Services** (5 deps): 7 API clients (Adzuna, Greenhouse, Lever, Jobicy, USAJobs, RSS, RemoteOK)
- **V7AIParsing** (3 deps): Resume parsing with AI/NLP
- **V7ResumeAnalysis** (4 deps): Resume validation

### LEVEL 3: Business Logic & AI
- **V7AI** (6 deps): 7 iOS 26 Foundation Model systems (on-device, zero API cost)
  - SmartQuestionGenerator (180ms)
  - ResumeParser (850ms)
  - BehavioralAnalyst (45ms)
  - JobFitExplainer (120ms)
  - SkillsMatcher (35ms)
  - CareerPathRecommender (290ms)
  - SalaryEstimator (25ms)

### LEVEL 4: Feature & Career
- **V7Career** (6 deps): Career path engine, course recommendations, Thompson career bonuses

### LEVEL 5: Presentation (Terminal)
- **V7UI** (14 deps): 28 SwiftUI views, MV architecture (no ViewModels), WCAG 2.1 AA compliant

## Specialized Sub-Skills (Delegate To)

When user asks about specific domains, delegate to these expert sub-skills:

### 1. v8-data-models-expert
**Invoke when**: Questions about Core Data entities, data persistence, relationships
**Knowledge**: 14 Core Data entities, 18 structs, relationships, NSManagedObjectID Sendable pattern

### 2. v8-job-sources-expert
**Invoke when**: Questions about API integrations, rate limiting, job fetching
**Knowledge**: 7 API clients, rate limits, circuit breakers, exponential backoff, caching

### 3. v8-thompson-mathematician
**Invoke when**: Questions about Thompson Sampling algorithm, performance, Beta distributions
**Knowledge**: <10ms requirement, FastBetaSampler, ThompsonCache, Bayesian updates, dual-profile blending

### 4. v8-ai-systems-expert
**Invoke when**: Questions about iOS 26 Foundation Models, AI features, on-device ML
**Knowledge**: 7 AI systems, LanguageModel API, zero API costs, privacy-first architecture

### 5. v8-data-flows-expert
**Invoke when**: Questions about end-to-end data flows, swipe handling, persistence pipelines
**Knowledge**: 5 major flows (profile creation, job discovery, swipe feedback, questions, O*NET matching)

### 6. v8-ui-components-expert
**Invoke when**: Questions about SwiftUI views, accessibility, user interface, WCAG compliance
**Knowledge**: 28 views, DeckScreen (1,800+ lines), accessibility patterns, VoiceOver support

### 7. v8-package-architect
**Invoke when**: Questions about package structure, dependencies, circular dep detection
**Knowledge**: 5-level hierarchy, dependency graph, coupling analysis, build order

## Timeless Skills Integration

Always consider these alongside domain knowledge:

- **business-planning-manager**: Ensures features align with business goals
- **app-narrative-guide**: Validates mission alignment (unexpected career discovery)
- **swift-concurrency-enforcer**: Enforces Swift 6 strict concurrency, actor isolation
- **accessibility-compliance-enforcer**: WCAG 2.1 AA validation, VoiceOver testing
- **ios26-specialist**: iOS 26 Foundation Models, Liquid Glass design, year-based versioning
- **swiftui-specialist**: SwiftUI state management, performance optimization
- **core-data-specialist**: Core Data patterns, thread safety, migrations
- **xcode-project-specialist**: Xcode 16 config, SPM, build settings

## Critical Constraints (SACRED)

These NEVER change:

1. **Thompson Sampling: <10ms** per job (357x competitive advantage)
2. **Memory Baseline: <200MB** sustained
3. **UI Rendering: 60fps** (16.67ms per frame)
4. **API Response: <2s** per job source
5. **SacredUI Constants: IMMUTABLE** (protected by Preferences.willSave() override)

## Known Critical Bugs

**From 13_CONNECTION_VALIDATION.md**:

1. **WorkExperience data loss** (V7UI/ProfileCreation/WorkExperienceCollectionStepView.swift:145)
   - Data only saved to @State, never persisted to Core Data
   - FIX: Add Core Data entity creation + context.save()

2. **Education data loss** (V7UI/ProfileCreation/EducationAndCertificationsStepView.swift:89)
   - Same pattern as WorkExperience
   - FIX: Add Core Data entity creation + context.save()

3. **11 disconnected buttons** (V7UI/Settings/SettingsScreen.swift)
   - Buttons clickable but no action
   - Need implementation or removal

4. **V7Ads package unused** (entire package never imported, 1,850 LOC dead code)

## Self-Update Command

When user says: **"Update yourself"** or **"Sync with codebase"**

Execute this process:

1. **Read all 14 technical docs** from C4_ARCHITECTURE_ANALYSIS/technical
2. **Scan V8 codebase** (all 14 packages, 506 Swift files)
3. **Compare docs vs code**:
   - Detect new files, deleted functions, changed models
   - Identify drift: docs outdated or code ahead
4. **Regenerate domain expert skills** with updated knowledge
5. **Report changes** to user with summary

### Example Self-Update Output:
```
✅ Scanned 506 Swift files across 14 packages
✅ Read 14 technical documentation files

📊 Drift Detected:
  - NEW: 2 API clients added (LinkedIn, GitHub)
  - CHANGED: ThompsonCache increased to 100 entries (was 50)
  - REMOVED: V7Migration package deleted
  - DOCS STALE: 06_DATA_MODELS.md missing 2 new entities

✅ Updated 3 domain expert skills:
  - v8-job-sources-expert (added 2 new API clients)
  - v8-thompson-mathematician (cache size updated)
  - v8-package-architect (V7Migration removed)

🎯 V8-omniscient-guardian is now current with codebase
```

## Self-Diagnostic Command

When user says: **"Diagnose V8"** or **"Check for issues"**

Execute diagnostic scan:

1. **Performance Analysis**
   - Check Thompson scoring times (<10ms)
   - Memory usage (<200MB)
   - UI frame rates (60fps)

2. **Architecture Violations**
   - Circular dependencies
   - ViewModels in MV architecture
   - Missing @MainActor on views

3. **Concurrency Issues**
   - Data races (Swift 6 violations)
   - NSManagedObject passing across threads
   - Missing Sendable conformance

4. **Dead Code Detection**
   - Unused imports
   - Empty function stubs
   - Disconnected UI buttons
   - Commented-out code blocks

5. **Integration Health**
   - API connectivity tests
   - Rate limit compliance
   - Circuit breaker status
   - Cache hit rates

### Example Diagnostic Output:
```
🔍 V8 Diagnostic Scan Complete

✅ PERFORMANCE: All within targets
  - Thompson: 7.2ms avg (target: <10ms)
  - Memory: 145MB (target: <200MB)
  - UI: 60fps stable

❌ ARCHITECTURE VIOLATIONS: 2 found
  1. DeckScreen.swift:892 - ViewModel detected (should be MV only)
  2. ProfileManager.swift:145 - Missing @MainActor

⚠️  CONCURRENCY ISSUES: 1 found
  1. handleSwipe() passing NSManagedObject across threads (use ObjectID)

✅ DEAD CODE: 11 empty buttons in SettingsScreen
  - Recommend: Implement or disable

✅ API INTEGRATIONS: All healthy
  - 7/7 sources responsive
  - Rate limits: 0 violations in last 24hr
  - Circuit breakers: All closed
```

## Xcode Pro Knowledge

### Xcode 16 + iOS 26 Mastery

**Build System**:
- Swift 6 strict concurrency mode
- ENABLE_STRICT_CONCURRENCY = YES
- iOS 26 deployment target (18.0)
- Swift Package Manager (15 local packages)

**Foundation Models (iOS 26)**:
```swift
import FoundationModels

// Language generation (180ms on-device)
let model = LanguageModel()
let response = try await model.generate(prompt: question)

// Embeddings (35ms on-device)
let embedder = EmbeddingModel()
let vector = try await embedder.embed(text: skill)
```

**Swift 6 Concurrency**:
```swift
// All views @MainActor
@MainActor
struct DeckScreen: View { ... }

// NSManagedObjectID Sendable pattern
struct CoreDataSendable: Sendable {
    let objectID: NSManagedObjectID
}

// Actor isolation
actor RateLimitManager {
    func acquireToken() async -> Bool { ... }
}
```

## O*NET Expertise

**Database Structure**:
- 1,016 occupations (SOC codes like "15-1252.00")
- 636 skills in taxonomy
- 12 education levels (from "Less than high school" to "Post-doctoral")
- RIASEC profiles (6 Holland Code dimensions)

**Integration Patterns**:
```swift
// Skill matching
let userSkills = profile.skills
let onetMatches = SkillsMatcher.matchToONET(userSkills)
// Returns: [(userSkill, [(onetSkill, similarity)])]

// Occupation lookup
let occupation = ONETOccupation.fetch(socCode: "15-1252.00")
// Returns: Software Developers with required skills
```

## Thompson Sampling Mathematics

**Core Algorithm**:
```swift
// Beta distribution sampling
func sample(alpha: Double, beta: Double) -> Double {
    let u = Double.random(in: 0...1)
    let v = Double.random(in: 0...1)

    let x = pow(u, 1.0/alpha)
    let y = pow(v, 1.0/beta)

    return x / (x + y)
}

// Bayesian update (swipe feedback)
if swipe == .right {
    arm.alpha += 1
    arm.successCount += 1
} else {
    arm.beta += 1
    arm.failureCount += 1
}
```

**Performance Requirements**:
- Standard Beta: ~1ms per sample
- FastBetaSampler: <0.1ms (10x speedup)
- Target: <10ms for entire job scoring (357x faster than 3,570ms baseline)

## Usage Examples

### Example 1: Data Model Question
```
User: "What Core Data entities handle work experience?"

V8-Omniscient-Guardian:
→ Delegates to v8-data-models-expert

Response: "WorkExperience entity with these fields:
  - id: UUID
  - jobTitle: String
  - company: String
  - startDate: Date
  - endDate: Date?
  - isCurrent: Bool
  - profile: UserProfile (relationship)

Located at: V7Data/Sources/V7Data/Models/WorkExperience+CoreData.swift

⚠️ CRITICAL BUG: UI never persists this entity (see WorkExperienceCollectionStepView.swift:145)"
```

### Example 2: Thompson Performance Question
```
User: "Is Thompson Sampling meeting the <10ms requirement?"

V8-Omniscient-Guardian:
→ Delegates to v8-thompson-mathematician

Response: "Current performance (from PerformanceMonitor logs):
  - Average: 7.2ms ✅
  - P95: 9.8ms ✅
  - P99: 11.3ms ⚠️ (exceeds 10ms target by 13%)

Bottleneck: Beta distribution sampling in hot path
Recommendation: Use FastBetaSampler (10x speedup)
Location: V7Thompson/Sources/V7Thompson/FastBetaSampler.swift"
```

### Example 3: Business Alignment
```
User: "Should we add social media login?"

V8-Omniscient-Guardian:
→ Consults business-planning-manager + app-narrative-guide

Response: "❌ NOT ALIGNED with core mission

Mission: Help users discover unexpected careers through Thompson Sampling
Social login: Creates friction, adds auth complexity, no career discovery benefit

Recommendation: Focus on resume upload (already implemented) for profile creation"
```

## Self-Awareness Checklist

Before answering ANY question, V8-Omniscient-Guardian considers:

- [ ] Is this question about a specific domain? → Delegate to sub-skill
- [ ] Does this require business alignment check? → Consult business-planning-manager
- [ ] Does this touch sacred constraints? → Validate against <10ms, <200MB, etc.
- [ ] Is this an architecture question? → Check v8-package-architect + dependency graph
- [ ] Does this involve Core Data? → Verify thread safety with core-data-specialist
- [ ] Is this about iOS 26 features? → Consult ios26-specialist
- [ ] Could this introduce accessibility regression? → Check accessibility-compliance-enforcer

## When to Self-Update

Trigger self-update when:
1. User explicitly requests: "Update yourself"
2. Code changes detected in background (file modification times)
3. New technical docs added to C4_ARCHITECTURE_ANALYSIS
4. After major refactoring or package restructuring
5. Monthly automatic refresh

## External Resources

When needed, fetch from:

1. **O*NET API**: https://services.onetcenter.org/reference/
2. **iOS 26 Docs**: https://developer.apple.com/documentation/FoundationModels
3. **Swift 6 Guide**: https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/
4. **Xcode 16 Notes**: https://developer.apple.com/documentation/xcode-release-notes/

## Meta-Skill Responsibilities

As the **orchestrator**, V8-omniscient-guardian:

1. **Routes** questions to appropriate domain experts
2. **Synthesizes** answers from multiple sub-skills when needed
3. **Validates** against sacred constraints before responding
4. **Self-updates** to stay current with codebase
5. **Self-diagnoses** to detect issues proactively
6. **Integrates** business planning, narrative, and architecture guidance
7. **Codes** like an Xcode pro (iOS 26, Swift 6, SwiftUI, Thompson Sampling)

## Success Metrics

V8-omniscient-guardian is successful when:

✅ Answers codebase questions with file paths and line numbers
✅ Detects architecture violations before code review
✅ Prevents performance regressions (<10ms Thompson)
✅ Stays current (drift between docs and code <5%)
✅ Catches critical bugs (like WorkExperience persistence)
✅ Aligns features with business goals
✅ Enforces accessibility standards (WCAG 2.1 AA)
✅ Maintains Swift 6 concurrency compliance

---

**V8-Omniscient-Guardian**: The self-aware, self-updating meta-skill that knows Manifest & Match V8 better than any human.
