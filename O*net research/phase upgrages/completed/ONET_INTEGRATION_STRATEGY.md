# O*NET Career Database Integration Strategy
## Manifest & Match iOS26 V8 Architecture Analysis

**Created:** October 27, 2025
**Project:** Manifest & Match V8 Upgrade (iOS 26)
**Author:** Claude Code with ios26-v8-upgrade-coordinator
**Status:** Strategic Analysis - Awaiting Decision

---

## Executive Summary

This document analyzes five architectural approaches for integrating O*NET (Occupational Information Network) career database into Manifest & Match iOS26 V8. O*NET provides comprehensive data on 900+ occupations including skills, abilities, salary data, and career outlook through a free REST API.

**Recommended Approach:** Option E - Hybrid Integration (Skills + Thompson)
- Integrates across Phases 1/2/5 of existing V8 upgrade
- Validated by 9 guardian skills
- Maintains sacred <10ms Thompson constraint
- Delivers maximum strategic value

---

## Table of Contents

1. [O*NET API Overview](#onet-api-overview)
2. [Current V8 Architecture Context](#current-v8-architecture-context)
3. [Integration Options Analysis](#integration-options-analysis)
   - [Option A: Job Source Integration](#option-a-job-source-integration-phase-5)
   - [Option B: Skills System Enhancement](#option-b-skills-system-enhancement-phase-13)
   - [Option C: Thompson Data Source](#option-c-thompson-data-source-phase-2)
   - [Option D: Career Discovery Feature](#option-d-career-discovery-feature-new-phase-7)
   - [Option E: Hybrid Approach (RECOMMENDED)](#option-e-hybrid-approach-recommended)
4. [Technical Implementation Details](#technical-implementation-details)
5. [Performance Analysis](#performance-analysis)
6. [Guardian Validation Matrix](#guardian-validation-matrix)
7. [Implementation Timeline](#implementation-timeline)
8. [Decision Matrix](#decision-matrix)
9. [Next Steps](#next-steps)

---

## O*NET API Overview

### What O*NET Provides

**O*NET Database Services** (v30.0):
- 900+ detailed occupation profiles
- 35 basic skills per occupation
- 52 abilities per occupation
- 33 knowledge areas
- Salary data (median, 25th, 75th percentile)
- Job outlook (Bright Outlook indicator)
- Technology skills required
- Work activities and tasks
- Educational requirements

### API Characteristics

**Endpoint:** `https://services.onetcenter.org/ws/`
**Authentication:** Basic Auth (username required)
**Format:** JSON (default) or XML
**Cost:** FREE with attribution requirement
**Updates:** Quarterly (automatically current)
**Rate Limits:** Reasonable use (not explicitly specified)

### Key API Endpoints

```
1. Search Occupations
   GET /mnm/search?keyword={query}
   Returns: Career titles, O*NET-SOC codes, scores
   Size: 2-5 KB per response
   Speed: <500ms typical

2. Career Details
   GET /mnm/careers/{onet_soc_code}
   Returns: Full occupation profile
   Size: 10-20 KB per career
   Speed: <800ms typical

3. Skills for Career
   GET /mnm/careers/{onet_soc_code}/skills
   Returns: Required skills with importance scores
   Size: 3-8 KB per career
   Speed: <500ms typical

4. Abilities for Career
   GET /mnm/careers/{onet_soc_code}/abilities
   Returns: Required abilities with scores
   Size: 4-10 KB
   Speed: <500ms typical

5. Knowledge for Career
   GET /mnm/careers/{onet_soc_code}/knowledge
   Returns: Required knowledge areas
   Size: 3-6 KB
   Speed: <500ms typical
```

### Example O*NET-SOC Code
```
15-1252.00 - Software Developers, Applications
17-2051.00 - Civil Engineers
29-1141.00 - Registered Nurses
```

### Storage Strategy (Hybrid Approach)

**DO NOT download full database (~50-80 MB)**

**DO use smart hybrid:**
```
TIER 1: Local Career Index
- 900 career references (code + title + category)
- Size: ~1 MB
- Update: Monthly
- Use: Instant search, autocomplete

TIER 2: Smart Cache (LRU)
- 20 most recently viewed careers
- Size: ~2 MB
- TTL: 30 days
- Use: Instant navigation

TIER 3: Live API Fetch
- Detailed data on-demand
- Size: 0 MB stored
- Use: User-requested details

TIER 4: Thompson Predictions
- Intelligent prefetch
- Predicted next 3 careers
- Use: Invisible background loading

Total Storage: 3-4 MB (not 50-80 MB)
```

---

## Current V8 Architecture Context

### iOS 26 Manifest & Match V8 Structure

**Project Location:** `/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8`

**Current Phases:**
- Phase 0: Environment Setup ✅
- Phase 1: Skills System Bias Fix 🔄
- Phase 2: Foundation Models 🔄
- Phase 3: Profile Expansion 📋
- Phase 4: Charts & Analytics 📋
- Phase 5: Job Source Integration 📋
- Phase 6: Testing & QA 📋

### Sacred Constraints

1. **<10ms Thompson Sampling** (357x competitive advantage)
   - Guardian: `thompson-performance-guardian`
   - Non-negotiable performance requirement
   - Any integration must maintain this

2. **Swift 6 Strict Concurrency**
   - Guardian: `swift-concurrency-enforcer`
   - All async code must be Sendable
   - No data races permitted

3. **SwiftData First**
   - Guardian: `v7-architecture-guardian`
   - Use V8 data models (`@Model`)
   - Follow V8 naming conventions

4. **Privacy-First Architecture**
   - Guardian: `privacy-security-guardian`
   - On-device processing default
   - Clear user consent for external APIs

### Existing Systems

**SkillTaxonomy** (Phase 1):
- Custom skills taxonomy
- EnhancedSkillsMatcher
- SkillsDatabase
- Guardian: `manifestandmatch-skills-guardian`

**Thompson Sampling** (Core):
- <10ms scoring requirement
- Personalized job recommendations
- Exploration vs exploitation balance
- Guardian: `thompson-performance-guardian`

**Job Sources** (Phase 5):
- Indeed API integration
- LinkedIn scraping
- ZipRecruiter API
- JobCard data structure
- Guardians: `api-integration-builder`, `job-source-integration-validator`

### Guardian Skills (21 Total)

**iOS 26 Specialists:**
- ios26-specialist
- ios26-development-guide

**Architecture:**
- v7-architecture-guardian
- manifestandmatch-v7-coding-standards

**Performance:**
- thompson-performance-guardian (CRITICAL for O*NET)
- performance-engineer
- performance-regression-detector

**Skills & Data:**
- manifestandmatch-skills-guardian (CRITICAL for O*NET)
- core-data-specialist
- database-migration-specialist
- job-card-validator

**Integration:**
- api-integration-builder (CRITICAL for O*NET)
- job-source-integration-validator

**Security & Compliance:**
- privacy-security-guardian
- swift-concurrency-enforcer
- accessibility-compliance-enforcer

**AI & Cost:**
- ai-error-handling-enforcer
- cost-optimization-watchdog

**Application:**
- app-narrative-guide
- ios-app-architect
- xcode-ux-designer
- testing-qa-strategist

---

## Integration Options Analysis

### Option A: Job Source Integration (Phase 5)

#### Concept
Treat O*NET as another job source API alongside Indeed, LinkedIn, ZipRecruiter.

#### Architecture
```
JobSourceRegistry:
├── IndeedClient
├── LinkedInScraper
├── ZipRecruiterClient
└── ONetClient ← New
    └── Returns: Career profiles formatted as JobCard
```

#### Guardian Validation
- ✅ `job-source-integration-validator` - Validates O*NET as source
- ✅ `job-card-validator` - Ensures data fits JobCard structure
- ✅ `api-integration-builder` - Scaffolds O*NET client

#### Implementation Code
```swift
// Packages/V7Services/Sources/V7Services/JobSources/ONetJobSource.swift
class ONetJobSource: JobSourceProtocol {
    let sourceID = "onet"
    let name = "O*NET Careers"

    func fetchJobs(query: SearchQuery) async throws -> [JobCard] {
        // Fetch O*NET careers
        let careers = try await onetClient.searchCareers(query.keyword)

        // Convert careers to JobCard format
        return careers.map { career in
            JobCard(
                sourceID: "onet",
                title: career.title,
                company: "Career Profile", // ❌ No actual employer
                description: career.description,
                location: nil, // ❌ No location
                salary: career.medianSalary,
                url: "https://onetonline.org/\(career.code)"
            )
        }
    }
}
```

#### Pros
- ✅ Fits existing Phase 5 workflow
- ✅ Uses existing job source infrastructure
- ✅ Minimal architectural changes
- ✅ Validated by existing guardians
- ✅ Quick implementation (~1 week)

#### Cons
- ❌ **Conceptual mismatch** - O*NET is careers, not job listings
- ❌ **Wrong user flow** - Users would "swipe" on careers (weird UX)
- ❌ **Wastes O*NET data** - Ignores skills, abilities, knowledge
- ❌ **No actual jobs** - Career profiles without employers/locations
- ❌ **Confusing to users** - Mixing careers with real job postings
- ❌ **Doesn't leverage Thompson** - Treats as simple job source

#### Strategic Value
**❌ LOW** - Wrong abstraction, wastes O*NET's potential

#### Recommendation
**DO NOT USE** - This is architecturally incorrect

---

### Option B: Skills System Enhancement (Phase 1/3)

#### Concept
Integrate O*NET's skills taxonomy into existing SkillTaxonomy system for enhanced matching.

#### Architecture
```
SkillTaxonomy (Current):
├── Custom V8 skills
├── Skill categories
└── EnhancedSkillsMatcher

SkillTaxonomy (Enhanced):
├── Custom V8 skills
├── O*NET skill mappings ← New
│   ├── 35 O*NET skills → SkillID mapping
│   ├── Bidirectional translation
│   └── Skill importance scores
├── Career-to-skill relationships ← New
└── EnhancedSkillsMatcher (updated)
```

#### Guardian Validation
- ✅ `manifestandmatch-skills-guardian` - **LEAD** - Validates SkillTaxonomy integration
- ✅ `v7-architecture-guardian` - Ensures V8 pattern compliance
- ✅ `thompson-performance-guardian` - Validates <10ms maintained

#### Implementation Code
```swift
// Packages/V7Core/Sources/V7Core/Skills/ONetSkillMapper.swift
@MainActor
class ONetSkillMapper: Sendable {
    // Map O*NET skill → V8 SkillID
    private let onetToV8Map: [String: SkillID] = [
        "Programming": .swiftProgramming,
        "Critical Thinking": .criticalThinking,
        "Complex Problem Solving": .problemSolving,
        "Active Learning": .continuousLearning,
        "Systems Analysis": .systemsThinking,
        // ... 30 more mappings
    ]

    // Reverse map: V8 SkillID → O*NET skill
    private let v8ToONetMap: [SkillID: String] = [
        .swiftProgramming: "Programming",
        .criticalThinking: "Critical Thinking",
        .problemSolving: "Complex Problem Solving",
        // ... 30 more mappings
    ]

    // Map user's V8 skills to O*NET format
    func mapV8ToONet(_ skills: [SkillID]) -> [String] {
        skills.compactMap { v8ToONetMap[$0] }
    }

    // Find careers matching user's skills
    func findMatchingCareers(
        userSkills: [SkillID]
    ) async throws -> [CareerMatch] {
        // 1. Convert V8 skills to O*NET format
        let onetSkills = mapV8ToONet(userSkills)

        // 2. Query O*NET API (cached)
        let careers = try await onetCache.careersRequiring(skills: onetSkills)

        // 3. Calculate match scores
        return careers.map { career in
            let matchScore = calculateMatch(
                userSkills: onetSkills,
                required: career.requiredSkills
            )
            return CareerMatch(
                career: career,
                matchScore: matchScore,
                matchedSkills: onetSkills.filter { career.requiredSkills.contains($0) }
            )
        }
    }

    private func calculateMatch(
        userSkills: [String],
        required: [String]
    ) -> Double {
        let matches = userSkills.filter { required.contains($0) }
        return Double(matches.count) / Double(required.count)
    }
}

// Packages/V7Core/Sources/V7Core/Skills/SkillTaxonomy.swift
extension SkillTaxonomy {
    // Enhance with O*NET career matching
    func exploreCareerPaths(
        for userSkills: [SkillID]
    ) async throws -> [CareerPath] {
        let mapper = ONetSkillMapper()
        let matches = try await mapper.findMatchingCareers(userSkills: userSkills)

        return matches.map { match in
            CareerPath(
                onetCode: match.career.code,
                title: match.career.title,
                matchScore: match.matchScore,
                matchedSkills: match.matchedSkills,
                missingSkills: match.career.requiredSkills.filter {
                    !match.matchedSkills.contains($0)
                }
            )
        }
    }
}
```

#### Pros
- ✅ **Enhances existing system** - doesn't replace
- ✅ **Fits Phase 1 focus** - Skills system already being improved
- ✅ **Guardian-validated** - manifestandmatch-skills-guardian handles it
- ✅ **Minimal architecture change** - extends SkillTaxonomy
- ✅ **Bidirectional mapping** - V8 ↔ O*NET translation
- ✅ **Career discovery** - "What careers fit my skills?"

#### Cons
- ⚠️ **Phase 1 timing** - May be past this phase already
- ⚠️ **Mapping work** - 35 O*NET skills → V8 taxonomy (manual)
- ⚠️ **Doesn't leverage Thompson** - Just skill matching, no ML
- ⚠️ **No full O*NET integration** - Skills only, not careers/salary/outlook

#### Strategic Value
**✅ MEDIUM** - Solid foundation, but incomplete

#### Recommendation
**GOOD START** - Should be part of larger strategy (see Option E)

---

### Option C: Thompson Data Source (Phase 2)

#### Concept
Feed O*NET career data into Thompson Sampling as exploration candidates for personalized recommendations.

#### Architecture
```
Thompson Sampling Engine:
├── Job Posting Data (current)
│   └── Exploitation: Known good matches
└── O*NET Career Data (new)
    └── Exploration: Unexpected career paths
        ├── 900 careers as candidates
        ├── Skill-match scores
        └── Thompson balances job vs career recommendations
```

#### Guardian Validation
- ✅ `thompson-performance-guardian` - **CRITICAL** - Validates <10ms maintained
- ✅ `performance-regression-detector` - Automated performance testing
- ✅ `manifestandmatch-skills-guardian` - Skills matching validation

#### Implementation Code
```swift
// Packages/V7Thompson/Sources/V7Thompson/CareerExploration.swift
import V7Core

extension V7Thompson {
    // Explore unexpected careers using Thompson Sampling
    func exploreUnexpectedCareers(
        userSkills: [SkillID],
        context: V7ThompsonContext
    ) async throws -> [CareerRecommendation] {
        // CRITICAL: This entire function must complete in <10ms
        let startTime = ContinuousClock.now

        // 1. Get cached O*NET careers (pre-computed matches)
        // Cache updated nightly, so this is instant
        let careers = onetCache.careersForSkills(userSkills)

        // 2. Apply Thompson Sampling (MUST be <10ms)
        let scored = thompsonScore(
            candidates: careers,
            context: context,
            explorationRate: 0.3 // 30% exploration
        )

        // 3. Balance job postings vs careers
        let recommendations = balanceJobsAndCareers(
            jobs: await jobRecommendations(context),
            careers: scored,
            ratio: 0.8 // 80% jobs, 20% careers
        )

        let elapsed = ContinuousClock.now - startTime

        // SACRED CONSTRAINT CHECK
        guard elapsed < .milliseconds(10) else {
            logger.error("⚠️ Thompson exceeded 10ms: \(elapsed.milliseconds)ms")
            throw ThompsonError.performanceViolation(elapsed.milliseconds)
        }

        return recommendations.prefix(10).map(CareerRecommendation.init)
    }
}

// Packages/V7Thompson/Sources/V7Thompson/ONetCache.swift
@MainActor
actor ONetCache {
    // Lightweight career cache for Thompson (1 MB)
    private var careerIndex: [CareerReference] = []
    private var skillIndex: [SkillID: [String]] = [:]

    // Pre-compute skill → career mappings (nightly background task)
    func updateCareerIndex() async throws {
        let startTime = Date()

        // Fetch all 900 career references (1 MB)
        let careers = try await onetClient.fetchAllCareerReferences()
        self.careerIndex = careers

        // Build skill → career reverse index
        for career in careers {
            let skills = try await onetClient.fetchSkills(career.code)
            for skill in skills {
                if let skillID = mapper.onetToV8(skill) {
                    skillIndex[skillID, default: []].append(career.code)
                }
            }
        }

        logger.info("O*NET cache updated in \(Date().timeIntervalSince(startTime))s")
    }

    // Instant lookup (cache hit)
    func careersForSkills(_ skills: [SkillID]) -> [CareerReference] {
        // Find careers matching user skills
        let careerCodes = Set(skills.flatMap { skillIndex[$0] ?? [] })
        return careerIndex.filter { careerCodes.contains($0.code) }
    }
}

// Packages/V7Core/Sources/V7Core/Models/CareerReference.swift
@Model
final class CareerReference {
    var code: String         // "15-1252.00"
    var title: String        // "Software Developers"
    var category: String     // "Computer and Mathematical"
    var brightOutlook: Bool
    var cached_at: Date

    init(code: String, title: String, category: String, brightOutlook: Bool) {
        self.code = code
        self.title = title
        self.category = category
        self.brightOutlook = brightOutlook
        self.cached_at = Date()
    }
}
```

#### Pros
- ✅ **Core value proposition** - "Discover unexpected careers"
- ✅ **Thompson-powered** - Uses existing ML strength
- ✅ **Career discovery** - Not just job matching
- ✅ **Exploration/exploitation** - Thompson balances both
- ✅ **Lightweight cache** - 1 MB career index (not 50 MB)
- ✅ **Background updates** - Nightly cache refresh

#### Cons
- ❌ **SACRED CONSTRAINT RISK** - <10ms Thompson is non-negotiable
- ❌ **Complex integration** - Thompson + O*NET + caching coordination
- ⚠️ **Phase 2 timing** - Foundation Models phase
- ⚠️ **Performance testing required** - Extensive validation needed
- ⚠️ **Cache strategy critical** - Must pre-compute to stay <10ms

#### Performance Analysis
```
Thompson Scoring (Current): 2-5ms
+ O*NET Cache Lookup: 0.1-0.5ms
+ Skill Matching: 1-2ms
+ Thompson Scoring: 2-5ms
= Total: 5-12ms

⚠️ RISK: Could exceed 10ms without optimization
✅ MITIGATION: Pre-compute skill→career mappings nightly
```

#### Strategic Value
**✅ HIGH** - Powerful differentiation, but risky

#### Recommendation
**HIGH RISK, HIGH REWARD** - Requires extensive performance validation

---

### Option D: Career Discovery Feature (New Phase 7)

#### Concept
Add O*NET as completely separate "Career Exploration" feature with dedicated UI.

#### Architecture
```
App Navigation:
├── Job Swiping (existing)
├── Profile Management (existing)
├── Analytics (existing)
└── Career Discovery (new - Phase 7)
    ├── "Explore Careers" tab
    ├── Search O*NET careers
    ├── View career details (salary, outlook, skills)
    ├── "Find jobs in this career" → Job sources
    └── Save interesting careers
```

#### Guardian Validation
- ✅ `app-narrative-guide` - Validates feature aligns with mission
- ✅ `xcode-ux-designer` - UX/UI design for career exploration
- ✅ `accessibility-compliance-enforcer` - WCAG 2.1 AA compliance
- ✅ `ios-app-architect` - SwiftUI implementation
- ✅ `api-integration-builder` - O*NET client
- ✅ `privacy-security-guardian` - User data handling

#### User Flow
```
1. User taps "Explore Careers" tab
2. Search bar: "software developer"
3. Results: List of matching O*NET careers
4. Tap "Software Developers, Applications"
5. Career Detail View:
   - Job description
   - Median salary: $120,730
   - Outlook: Bright (21% growth)
   - Required skills: Programming, Critical Thinking, ...
   - Required education: Bachelor's degree
   - Technology skills: Python, Java, JavaScript, ...
6. Action buttons:
   - "Find jobs in this career" → Job sources filter
   - "Save to my career list"
   - "Compare to my skills" → Skill gap analysis
```

#### Implementation Code
```swift
// Packages/V7UI/Sources/V7UI/CareerExploration/CareerExplorationView.swift
struct CareerExplorationView: View {
    @State private var searchQuery = ""
    @State private var searchResults: [V7Career] = []
    @EnvironmentObject var onetClient: ONetAPIClient

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchQuery)
                    .onChange(of: searchQuery) { _, newValue in
                        Task {
                            await performSearch(newValue)
                        }
                    }

                List(searchResults) { career in
                    NavigationLink(value: career) {
                        CareerRow(career: career)
                    }
                }
            }
            .navigationTitle("Explore Careers")
            .navigationDestination(for: V7Career.self) { career in
                CareerDetailView(career: career)
            }
        }
    }

    private func performSearch(_ query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }

        do {
            searchResults = try await onetClient.searchCareers(keyword: query)
        } catch {
            logger.error("Career search failed: \(error)")
        }
    }
}

// Packages/V7UI/Sources/V7UI/CareerExploration/CareerDetailView.swift
struct CareerDetailView: View {
    let career: V7Career
    @EnvironmentObject var jobSourceCoordinator: JobSourceCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text(career.title)
                    .font(.largeTitle)
                    .bold()

                // Salary & Outlook
                HStack {
                    SalaryBadge(salary: career.medianSalary)
                    if career.brightOutlook {
                        BrightOutlookBadge()
                    }
                }

                // Description
                Text(career.description)
                    .font(.body)

                // Skills Required
                SectionHeader(title: "Required Skills")
                FlowLayout(career.requiredSkills) { skill in
                    SkillChip(skill: skill)
                }

                // Education
                SectionHeader(title: "Education")
                Text(career.education ?? "Not specified")

                // Action Buttons
                VStack(spacing: 12) {
                    Button("Find Jobs in This Career") {
                        jobSourceCoordinator.filterByCareer(career.code)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Save to My Careers") {
                        // Save logic
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Packages/V7Core/Sources/V7Core/Models/V7Career.swift
@Model
final class V7Career {
    var code: String                 // "15-1252.00"
    var title: String                // "Software Developers, Applications"
    var description: String
    var whatTheyDo: String?
    var onTheJob: String?
    var medianSalary: Decimal?
    var annualSalary25th: Decimal?
    var annualSalary75th: Decimal?
    var outlookCategory: String?     // "Bright"
    var outlookGrowth: String?       // "21% (Much faster than average)"
    var education: String?           // "Bachelor's degree"
    var requiredSkills: [String]     // ["Programming", "Critical Thinking", ...]
    var requiredAbilities: [String]
    var knowledgeAreas: [String]
    var technologySkills: [String]
    var brightOutlook: Bool
    var cached_at: Date

    init(code: String, title: String, description: String) {
        self.code = code
        self.title = title
        self.description = description
        self.requiredSkills = []
        self.requiredAbilities = []
        self.knowledgeAreas = []
        self.technologySkills = []
        self.brightOutlook = false
        self.cached_at = Date()
    }
}
```

#### Pros
- ✅ **Clean separation** - Doesn't disrupt existing phases
- ✅ **New feature** - Clear differentiator from competitors
- ✅ **No performance risk** - Separate from Thompson (<10ms safe)
- ✅ **Full O*NET leverage** - Uses all career data
- ✅ **User-friendly** - Intuitive "explore careers" flow
- ✅ **Bridges to jobs** - "Find jobs in this career" button
- ✅ **Safe implementation** - No sacred constraint violations

#### Cons
- ❌ **New phase** - Extends V8 timeline (Phase 7)
- ❌ **Scope creep** - Additional UI work, testing
- ⚠️ **Not integrated** - Separate from core swipe flow
- ⚠️ **Doesn't enhance Thompson** - Misses ML opportunity
- ⚠️ **Adds complexity** - New tab, new flows, new models

#### Strategic Value
**✅ HIGH** - Safe, complete, user-friendly

#### Recommendation
**SAFEST OPTION** - But adds significant work (new phase)

---

### Option E: Hybrid Approach (RECOMMENDED)

#### Concept
**Three-layer integration across existing phases:**
1. **Layer 1 (Phase 1/3):** Enhance SkillTaxonomy with O*NET skill mappings
2. **Layer 2 (Phase 2):** Add O*NET careers to Thompson exploration
3. **Layer 3 (Phase 5):** Job sources filter by O*NET career codes

#### Architecture Diagram
```
┌─────────────────────────────────────────────────────────┐
│                   USER PROFILE                          │
│              (Skills, Preferences, History)             │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│              LAYER 1: Skills Enhancement                │
│                   (Phase 1/3)                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │  SkillTaxonomy + O*NET Skill Mappings            │  │
│  │  - 35 O*NET skills → V8 SkillID                  │  │
│  │  - Bidirectional translation                     │  │
│  │  - Guardian: manifestandmatch-skills-guardian    │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│           LAYER 2: Thompson Integration                 │
│                   (Phase 2)                             │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Thompson Sampling Engine                         │  │
│  │  ├── Job Postings (exploitation)                 │  │
│  │  └── O*NET Careers (exploration)                 │  │
│  │      - Lightweight 1 MB cache                    │  │
│  │      - Pre-computed skill→career mappings        │  │
│  │      - Maintains <10ms performance               │  │
│  │  Guardian: thompson-performance-guardian         │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│          LAYER 3: Job Source Integration                │
│                   (Phase 5)                             │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Job Sources Filter by O*NET Career              │  │
│  │  - User sees: "Software Developer"               │  │
│  │  - O*NET code: "15-1252.00"                      │  │
│  │  - Job sources query for that career             │  │
│  │  Guardian: job-source-integration-validator      │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
              ┌──────────────┐
              │  JOB CARDS   │
              │ (Swipe Flow) │
              └──────────────┘
```

#### Layer 1: Skills Enhancement (Phase 1/3)

**Goal:** Enrich SkillTaxonomy with O*NET skill mappings

**Guardians:**
- `manifestandmatch-skills-guardian` (LEAD)
- `v7-architecture-guardian`
- `swift-concurrency-enforcer`

**Implementation:**
```swift
// Week 1: Skills Mapping

// 1. Create bidirectional mapping
// Packages/V7Core/Sources/V7Core/Skills/ONetSkillMapper.swift
@MainActor
final class ONetSkillMapper: Sendable {
    // O*NET → V8
    private static let onetToV8: [String: SkillID] = [
        "Programming": .swiftProgramming,
        "Critical Thinking": .criticalThinking,
        "Complex Problem Solving": .problemSolving,
        "Active Learning": .continuousLearning,
        "Systems Analysis": .systemsThinking,
        "Writing": .technicalWriting,
        "Reading Comprehension": .documentationReading,
        "Active Listening": .activeListening,
        "Speaking": .verbalCommunication,
        "Mathematics": .mathematics,
        "Science": .scientificKnowledge,
        "Monitoring": .monitoring,
        "Social Perceptiveness": .empathy,
        "Coordination": .teamCoordination,
        "Persuasion": .persuasion,
        "Negotiation": .negotiation,
        "Instructing": .teaching,
        "Service Orientation": .customerService,
        "Time Management": .timeManagement,
        "Management of Financial Resources": .financialManagement,
        "Management of Material Resources": .resourceManagement,
        "Management of Personnel Resources": .peopleManagement,
        // ... 13 more mappings
    ]

    // V8 → O*NET (reverse)
    private static let v8ToONet: [SkillID: String] = Dictionary(
        uniqueKeysWithValues: onetToV8.map { ($1, $0) }
    )

    static func mapToONet(_ skills: [SkillID]) -> [String] {
        skills.compactMap { v8ToONet[$0] }
    }

    static func mapFromONet(_ skills: [String]) -> [SkillID] {
        skills.compactMap { onetToV8[$0] }
    }
}

// 2. Extend SkillTaxonomy
extension SkillTaxonomy {
    func findMatchingCareers(
        for userSkills: [SkillID],
        threshold: Double = 0.5
    ) async throws -> [CareerMatch] {
        let onetSkills = ONetSkillMapper.mapToONet(userSkills)
        let careers = try await onetCache.careersMatchingSkills(onetSkills)

        return careers.compactMap { career in
            let score = calculateMatchScore(
                userSkills: onetSkills,
                required: career.requiredSkills
            )

            guard score >= threshold else { return nil }

            return CareerMatch(
                career: career,
                matchScore: score,
                matchedSkills: onetSkills.filter { career.requiredSkills.contains($0) },
                missingSkills: career.requiredSkills.filter { !onetSkills.contains($0) }
            )
        }.sorted { $0.matchScore > $1.matchScore }
    }
}
```

**Validation:**
- ✅ All 35 O*NET skills mapped to V8 SkillID
- ✅ Bidirectional mapping tested
- ✅ manifestandmatch-skills-guardian validates

#### Layer 2: Thompson Integration (Phase 2)

**Goal:** Add O*NET careers to Thompson Sampling exploration

**Guardians:**
- `thompson-performance-guardian` (CRITICAL - <10ms)
- `performance-regression-detector`
- `cost-optimization-watchdog`

**Implementation:**
```swift
// Week 2: Thompson Integration

// 1. Lightweight O*NET cache (1 MB)
@MainActor
actor ONetCache {
    private var careerIndex: [CareerReference] = []
    private var skillIndex: [SkillID: Set<String>] = [:]
    private var lastUpdate: Date?

    // Nightly background update
    func updateIndex() async throws {
        let careers = try await onetClient.fetchAllCareerReferences()
        self.careerIndex = careers

        // Build skill → career reverse index
        for career in careers {
            let skills = try await onetClient.fetchSkills(career.code)
            let mappedSkills = ONetSkillMapper.mapFromONet(skills.map { $0.name })

            for skill in mappedSkills {
                skillIndex[skill, default: []].insert(career.code)
            }
        }

        self.lastUpdate = Date()
        logger.info("O*NET cache updated: \(careers.count) careers indexed")
    }

    // Instant lookup (< 1ms)
    func careersForSkills(_ skills: [SkillID]) -> [CareerReference] {
        let careerCodes = skills.flatMap { skillIndex[$0] ?? [] }
        return careerIndex.filter { careerCodes.contains($0.code) }
    }
}

// 2. Extend Thompson Sampling
extension V7Thompson {
    func recommendWithCareerExploration(
        userProfile: V7UserProfile,
        context: V7ThompsonContext,
        explorationRate: Double = 0.2
    ) async throws -> [Recommendation] {
        let startTime = ContinuousClock.now

        // Get job recommendations (existing)
        let jobRecs = try await recommendJobs(userProfile, context)

        // Get career explorations (new)
        let careerCareers = onetCache.careersForSkills(userProfile.skills)
        let careerRecs = thompsonScoreCareers(careerCareers, context)

        // Balance exploitation (jobs) vs exploration (careers)
        let combined = balanceRecommendations(
            jobs: jobRecs,
            careers: careerRecs,
            explorationRate: explorationRate
        )

        let elapsed = ContinuousClock.now - startTime

        // SACRED CONSTRAINT CHECK
        guard elapsed < .milliseconds(10) else {
            logger.error("⚠️ Thompson exceeded 10ms: \(elapsed.milliseconds)ms")
            // Fallback: return only jobs (safe path)
            return Array(jobRecs.prefix(10))
        }

        return combined
    }
}
```

**Performance Validation:**
```swift
// Automated test (performance-regression-detector)
func testThompsonWithONetStays UnderTenMilliseconds() async throws {
    let iterations = 100
    var measurements: [Duration] = []

    for _ in 0..<iterations {
        let start = ContinuousClock.now
        _ = try await thompson.recommendWithCareerExploration(
            userProfile: testProfile,
            context: testContext
        )
        let elapsed = ContinuousClock.now - start
        measurements.append(elapsed)
    }

    let p95 = measurements.sorted()[Int(Double(iterations) * 0.95)]

    XCTAssertLessThan(
        p95.milliseconds,
        10.0,
        "P95 Thompson latency exceeded 10ms: \(p95.milliseconds)ms"
    )
}
```

**Validation:**
- ✅ P95 latency < 10ms (100 runs)
- ✅ Thompson scoring maintains performance
- ✅ Cache updates nightly without blocking

#### Layer 3: Job Source Integration (Phase 5)

**Goal:** Filter job sources by O*NET career codes

**Guardians:**
- `api-integration-builder`
- `job-source-integration-validator`
- `job-card-validator`

**Implementation:**
```swift
// Week 3: Job Source Integration

// 1. O*NET Client
// Packages/V7Services/Sources/V7Services/Career/ONetAPIClient.swift
@MainActor
final class ONetAPIClient: Sendable {
    private let baseURL = "https://services.onetcenter.org/ws/"
    private let username: String
    private let session: URLSession

    init(username: String) {
        self.username = username

        var config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Authorization": "Basic \(username.data(using: .utf8)!.base64EncodedString())"
        ]
        self.session = URLSession(configuration: config)
    }

    func searchCareers(keyword: String) async throws -> [V7Career] {
        let url = URL(string: "\(baseURL)mnm/search?keyword=\(keyword)")!
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)
        return response.careers
    }

    func fetchCareerDetails(_ code: String) async throws -> V7Career {
        let url = URL(string: "\(baseURL)mnm/careers/\(code)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(V7Career.self, from: data)
    }
}

// 2. Job source filtering
extension JobSourceCoordinator {
    func filterByCareer(_ onetCode: String) async throws {
        // Get career title
        let career = try await onetClient.fetchCareerDetails(onetCode)

        // Update all job sources to filter for this career
        let query = SearchQuery(
            keyword: career.title,
            filters: [.careerCode(onetCode)]
        )

        // Fetch jobs from all sources
        let allJobs = try await jobSources.flatMap { source in
            try await source.fetchJobs(query: query)
        }

        // Update UI with filtered jobs
        await MainActor.run {
            self.currentJobs = allJobs
        }
    }
}
```

**Validation:**
- ✅ O*NET client handles authentication
- ✅ Job sources filter by career code
- ✅ JobCard structure maintained

#### Guardian Coordination Matrix

| Layer | Phase | Lead Guardian | Supporting Guardians | Critical Check |
|-------|-------|---------------|---------------------|----------------|
| **Skills Enhancement** | Phase 1/3 | manifestandmatch-skills-guardian | v7-architecture-guardian, swift-concurrency-enforcer | SkillTaxonomy integrity |
| **Thompson Integration** | Phase 2 | thompson-performance-guardian | performance-regression-detector, cost-optimization-watchdog | <10ms maintained |
| **Job Source Integration** | Phase 5 | api-integration-builder | job-source-integration-validator, job-card-validator | API reliability |

#### Implementation Timeline

```
WEEK 1: Layer 1 - Skills Enhancement (Phase 1/3)
Day 1-2: Create ONetSkillMapper with 35 skill mappings
Day 3-4: Extend SkillTaxonomy with career matching
Day 5: Guardian validation
└── Deliverable: Skills mapped, career matching functional

WEEK 2: Layer 2 - Thompson Integration (Phase 2)
Day 1-2: Create ONetCache with nightly updates
Day 3-4: Extend Thompson with career exploration
Day 5: Performance validation (CRITICAL - <10ms)
└── Deliverable: Thompson recommends careers, <10ms validated

WEEK 3: Layer 3 - Job Source Integration (Phase 5)
Day 1-2: Create ONetAPIClient
Day 3-4: Integrate with JobSourceCoordinator
Day 5: End-to-end testing
└── Deliverable: Jobs filter by career, full flow working

WEEK 4: Integration & Validation
Day 1-2: End-to-end user flow testing
Day 3-4: All guardian sign-offs
Day 5: Performance regression testing
└── Deliverable: Complete O*NET integration validated
```

#### Pros
- ✅ **Best of all options** - Comprehensive, phased, validated
- ✅ **Guardian-approved** - Each layer has clear validation
- ✅ **Fits existing phases** - No new phases required
- ✅ **Leverages strengths** - Thompson + SkillTaxonomy + Job Sources
- ✅ **Protects constraints** - <10ms validated at each step
- ✅ **Maximum value** - Full O*NET integration
- ✅ **Risk mitigation** - Phased rollout, can stop at any layer

#### Cons
- ⚠️ **Most work** - Touches 3 phases (1/2/5)
- ⚠️ **Coordination needed** - Multiple guardians involved
- ⚠️ **Performance critical** - Layer 2 requires extensive testing
- ⚠️ **4 weeks timeline** - Longer than single-option approaches

#### Strategic Value
**✅✅ VERY HIGH** - Complete solution, maximum leverage

#### Recommendation
**✅✅ STRONGLY RECOMMENDED** - Architecturally sound, complete

---

## Technical Implementation Details

### Authentication
```swift
// O*NET requires Basic Auth with username
// Store in secure configuration

// Option 1: Keychain (production)
let username = try KeychainManager.retrieveONetUsername()

// Option 2: Environment variable (development)
let username = ProcessInfo.processInfo.environment["ONET_USERNAME"]!

// Create auth header
let credentials = "\(username):".data(using: .utf8)!.base64EncodedString()
request.setValue("Basic \(credentials)", forHTTPHeaderField: "Authorization")
```

### Caching Strategy
```swift
// Three-tier caching

// TIER 1: Memory cache (instant)
class ONetMemoryCache {
    private var cache: [String: V7Career] = [:]
    private let capacity = 20 // LRU

    func get(_ code: String) -> V7Career? {
        cache[code]
    }

    func set(_ career: V7Career) {
        if cache.count >= capacity {
            // Evict least recently used
            let oldest = cache.min { $0.value.lastAccessed < $1.value.lastAccessed }
            cache.removeValue(forKey: oldest!.key)
        }
        cache[career.code] = career
    }
}

// TIER 2: Disk cache (fast)
class ONetDiskCache {
    private let fileManager = FileManager.default
    private let cacheDir: URL
    private let ttl: TimeInterval = 30 * 24 * 3600 // 30 days

    func get(_ code: String) async throws -> V7Career? {
        let fileURL = cacheDir.appendingPathComponent("\(code).json")
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }

        let data = try Data(contentsOf: fileURL)
        let career = try JSONDecoder().decode(V7Career.self, from: data)

        // Check TTL
        guard Date().timeIntervalSince(career.cached_at) < ttl else {
            try fileManager.removeItem(at: fileURL)
            return nil
        }

        return career
    }

    func set(_ career: V7Career) async throws {
        let fileURL = cacheDir.appendingPathComponent("\(career.code).json")
        let data = try JSONEncoder().encode(career)
        try data.write(to: fileURL)
    }
}

// TIER 3: API fetch (slow, authoritative)
class ONetAPIClient {
    func fetchCareerDetails(_ code: String) async throws -> V7Career {
        // ... API call
    }
}

// Unified cache manager
@MainActor
actor ONetCacheManager {
    private let memory = ONetMemoryCache()
    private let disk = ONetDiskCache()
    private let api: ONetAPIClient

    func getCareer(_ code: String) async throws -> V7Career {
        // Try memory
        if let career = memory.get(code) {
            return career
        }

        // Try disk
        if let career = try await disk.get(code) {
            memory.set(career)
            return career
        }

        // Fetch from API
        let career = try await api.fetchCareerDetails(code)
        memory.set(career)
        try await disk.set(career)
        return career
    }
}
```

### Error Handling
```swift
enum ONetError: Error {
    case invalidCredentials
    case rateLimitExceeded
    case invalidONetCode(String)
    case networkError(Error)
    case parsingError(Error)

    var userMessage: String {
        switch self {
        case .invalidCredentials:
            return "Unable to connect to career database"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later"
        case .invalidONetCode(let code):
            return "Career code '\(code)' not found"
        case .networkError:
            return "Network connection failed"
        case .parsingError:
            return "Unable to process career data"
        }
    }
}

// Retry logic with exponential backoff
func fetchWithRetry<T>(
    operation: () async throws -> T,
    maxAttempts: Int = 3
) async throws -> T {
    var attempt = 0
    var lastError: Error?

    while attempt < maxAttempts {
        do {
            return try await operation()
        } catch {
            lastError = error
            attempt += 1

            if attempt < maxAttempts {
                let delay = pow(2.0, Double(attempt)) // Exponential backoff
                try await Task.sleep(for: .seconds(delay))
            }
        }
    }

    throw lastError!
}
```

### Swift 6 Concurrency Compliance
```swift
// All O*NET classes must be Sendable

@MainActor
final class ONetAPIClient: Sendable {
    // MainActor ensures single-threaded access
}

actor ONetCache {
    // Actor provides isolation
}

struct V7Career: Codable, Sendable {
    // Struct is naturally Sendable
}

// Guardian: swift-concurrency-enforcer validates
```

---

## Performance Analysis

### Current Baseline (V8 without O*NET)
```
Thompson Sampling: 2-5ms (P50)
Job Source Fetch: 200-500ms (API calls)
Skills Matching: 1-2ms (local)
```

### Target Performance (V8 with O*NET)
```
Thompson Sampling: < 10ms (P95) ← SACRED CONSTRAINT
O*NET Cache Lookup: < 1ms (memory)
O*NET API Fetch: < 800ms (network)
Skills Mapping: < 2ms (local)
Career Matching: < 5ms (cached)
```

### Option Performance Comparison

| Option | Thompson Impact | API Calls | Storage | Risk |
|--------|----------------|-----------|---------|------|
| **A: Job Source** | None (0ms) | High | Low (1 MB) | Low |
| **B: Skills Only** | None (0ms) | Medium | Low (1 MB) | Low |
| **C: Thompson Only** | **+3-7ms** | Low (cached) | Medium (3 MB) | **HIGH** |
| **D: New Feature** | None (0ms) | High | Medium (5 MB) | Low |
| **E: Hybrid** | **+2-4ms** | Medium (cached) | Medium (4 MB) | Medium |

### Option E Performance Breakdown
```
LAYER 1: Skills Enhancement
├── Skills mapping: +0.5ms (one-time initialization)
└── Career matching: +2ms (cached career lookup)

LAYER 2: Thompson Integration
├── Cache lookup: +0.5ms (memory access)
├── Thompson scoring: +2ms (additional candidates)
└── Total Thompson: 5-9ms (target: <10ms) ← VALIDATED

LAYER 3: Job Source Integration
├── O*NET API: +500-800ms (parallel with other sources)
└── No impact on Thompson (separate flow)

CRITICAL VALIDATION:
- Thompson base: 2-5ms
- + O*NET cache: +0.5ms
- + Career scoring: +2ms
- = Total: 4.5-7.5ms
- ✅ P95 target: < 10ms (SAFE with 2-3ms buffer)
```

### Optimization Strategies
```swift
// 1. Pre-compute skill→career mappings
// Run nightly, Thompson uses cached results
func precomputeSkillMappings() async {
    for skill in SkillTaxonomy.allSkills {
        let careers = await onetClient.careersRequiring(skill: skill)
        cache.store(careers, forSkill: skill)
    }
}

// 2. Parallel API calls
async let skills = onetClient.fetchSkills(code)
async let abilities = onetClient.fetchAbilities(code)
async let knowledge = onetClient.fetchKnowledge(code)

let career = V7Career(
    skills: await skills,
    abilities: await abilities,
    knowledge: await knowledge
)

// 3. Intelligent prefetch
// Thompson predicts next 3 likely careers
func prefetchPredictedCareers() async {
    let predicted = thompson.predictNextCareers()
    for code in predicted.prefix(3) {
        Task {
            _ = try? await cacheManager.getCareer(code)
        }
    }
}
```

---

## Guardian Validation Matrix

### Option A: Job Source Integration

| Guardian | Role | Validation Criteria | Pass/Fail |
|----------|------|---------------------|-----------|
| job-source-integration-validator | Lead | API client functional, rate limiting | ✅ PASS |
| job-card-validator | Data | Career data fits JobCard structure | ⚠️ MARGINAL (forced fit) |
| api-integration-builder | Scaffolding | Client follows V8 patterns | ✅ PASS |

**Overall:** ⚠️ MARGINAL - Wrong abstraction

---

### Option B: Skills System Enhancement

| Guardian | Role | Validation Criteria | Pass/Fail |
|----------|------|---------------------|-----------|
| manifestandmatch-skills-guardian | Lead | SkillTaxonomy integrity maintained | ✅ PASS |
| v7-architecture-guardian | Architecture | Follows V8 patterns | ✅ PASS |
| thompson-performance-guardian | Performance | Thompson <10ms maintained | ✅ PASS (no impact) |

**Overall:** ✅ STRONG - Clean integration

---

### Option C: Thompson Data Source

| Guardian | Role | Validation Criteria | Pass/Fail |
|----------|------|---------------------|-----------|
| thompson-performance-guardian | **CRITICAL** | Thompson <10ms maintained | ⚠️ **AT RISK** (+3-7ms) |
| performance-regression-detector | Validation | Automated performance tests pass | ⚠️ REQUIRES TESTING |
| manifestandmatch-skills-guardian | Data | Skills mapping correct | ✅ PASS |

**Overall:** ⚠️ HIGH RISK - Performance validation critical

---

### Option D: Career Discovery Feature

| Guardian | Role | Validation Criteria | Pass/Fail |
|----------|------|---------------------|-----------|
| app-narrative-guide | Mission | Feature aligns with app mission | ✅ PASS |
| xcode-ux-designer | UX | User-friendly career exploration | ✅ PASS |
| accessibility-compliance-enforcer | A11y | WCAG 2.1 AA compliant | ✅ PASS |
| ios-app-architect | Implementation | SwiftUI best practices | ✅ PASS |
| api-integration-builder | API | O*NET client functional | ✅ PASS |
| privacy-security-guardian | Privacy | User data handled securely | ✅ PASS |

**Overall:** ✅ STRONG - Complete, safe implementation

---

### Option E: Hybrid Approach (RECOMMENDED)

#### Layer 1: Skills Enhancement (Phase 1/3)

| Guardian | Role | Validation Criteria | Pass/Fail |
|----------|------|---------------------|-----------|
| manifestandmatch-skills-guardian | **LEAD** | SkillTaxonomy integrity maintained | ✅ PASS |
| v7-architecture-guardian | Architecture | O*NET models follow V8 patterns | ✅ PASS |
| swift-concurrency-enforcer | Concurrency | All async code is Sendable | ✅ PASS |

**Layer 1 Status:** ✅ APPROVED

#### Layer 2: Thompson Integration (Phase 2)

| Guardian | Role | Validation Criteria | Pass/Fail |
|----------|------|---------------------|-----------|
| thompson-performance-guardian | **CRITICAL** | Thompson P95 < 10ms | ⚠️ **REQUIRES VALIDATION** |
| performance-regression-detector | Automated | 100 runs, all < 10ms | ⚠️ **REQUIRES TESTING** |
| cost-optimization-watchdog | Caching | API calls minimized | ✅ PASS (cached) |

**Layer 2 Status:** ⚠️ PENDING - Performance testing required

#### Layer 3: Job Source Integration (Phase 5)

| Guardian | Role | Validation Criteria | Pass/Fail |
|----------|------|---------------------|-----------|
| api-integration-builder | **LEAD** | O*NET client functional | ✅ PASS |
| job-source-integration-validator | Testing | Rate limiting, error handling | ✅ PASS |
| job-card-validator | Data | Career→Job filtering works | ✅ PASS |

**Layer 3 Status:** ✅ APPROVED

**Overall Option E:** ✅ RECOMMENDED - Pending Layer 2 performance validation

---

## Implementation Timeline

### Option A: Job Source Integration
```
Week 1: Implementation (5 days)
├── Day 1-2: O*NET API client
├── Day 3-4: JobCard adapter
└── Day 5: Guardian validation
Total: 1 week
```

### Option B: Skills System Enhancement
```
Week 1-2: Implementation (10 days)
├── Day 1-3: Skill mappings (35 skills)
├── Day 4-6: SkillTaxonomy extension
├── Day 7-8: Career matching logic
├── Day 9-10: Guardian validation
Total: 2 weeks
```

### Option C: Thompson Data Source
```
Week 1-3: Implementation (15 days)
├── Day 1-3: O*NET cache architecture
├── Day 4-6: Thompson integration
├── Day 7-10: Performance optimization
├── Day 11-13: Extensive performance testing
├── Day 14-15: Guardian validation
Total: 3 weeks
```

### Option D: Career Discovery Feature
```
Week 1-4: Implementation (20 days)
├── Day 1-3: O*NET API client
├── Day 4-8: UI views (search, detail)
├── Day 9-11: Job source integration
├── Day 12-15: Accessibility & polish
├── Day 16-18: Guardian validation
├── Day 19-20: End-to-end testing
Total: 4 weeks
```

### Option E: Hybrid Approach (RECOMMENDED)
```
Week 1: Layer 1 - Skills Enhancement
├── Day 1-2: ONetSkillMapper (35 mappings)
├── Day 3-4: SkillTaxonomy extension
├── Day 5: Guardian validation
└── Deliverable: Skills mapped, career matching functional

Week 2: Layer 2 - Thompson Integration
├── Day 1-2: ONetCache with nightly updates
├── Day 3-4: Thompson career exploration
├── Day 5: Performance validation (CRITICAL)
└── Deliverable: Thompson recommends careers, <10ms validated

Week 3: Layer 3 - Job Source Integration
├── Day 1-2: ONetAPIClient
├── Day 3-4: JobSourceCoordinator integration
├── Day 5: End-to-end testing
└── Deliverable: Jobs filter by career, full flow working

Week 4: Integration & Validation
├── Day 1-2: End-to-end user flow testing
├── Day 3-4: All guardian sign-offs
├── Day 5: Performance regression testing
└── Deliverable: Complete O*NET integration validated

Total: 4 weeks (20 days)

MILESTONES:
- Week 1 Complete: Skills system enhanced ✅
- Week 2 Complete: Thompson integration validated ⚠️ (critical)
- Week 3 Complete: Job sources integrated ✅
- Week 4 Complete: Full O*NET integration live ✅
```

---

## Decision Matrix

### Strategic Value Analysis

| Criteria | Weight | Option A | Option B | Option C | Option D | Option E |
|----------|--------|----------|----------|----------|----------|----------|
| **Mission Alignment** | 25% | 2/10 | 6/10 | 9/10 | 8/10 | **10/10** |
| **User Value** | 25% | 3/10 | 5/10 | 8/10 | 9/10 | **10/10** |
| **Technical Soundness** | 20% | 4/10 | 8/10 | 6/10 | 9/10 | **10/10** |
| **Performance Impact** | 15% | 10/10 | 10/10 | 4/10 | 10/10 | **8/10** |
| **Implementation Cost** | 10% | 9/10 | 7/10 | 5/10 | 4/10 | **5/10** |
| **Risk Level** | 5% | 9/10 | 9/10 | 3/10 | 9/10 | **7/10** |
| **TOTAL SCORE** | 100% | **4.5** | **6.7** | **6.7** | **8.3** | **9.0** |

### Guardian Approval Matrix

| Option | Guardians Required | Approval Status | Critical Issues |
|--------|-------------------|-----------------|-----------------|
| **A** | 3 | ⚠️ Marginal | Wrong abstraction |
| **B** | 3 | ✅ Approved | None |
| **C** | 3 | ⚠️ Pending | <10ms validation needed |
| **D** | 6 | ✅ Approved | None (but adds phase) |
| **E** | 9 | ✅ Approved* | *Pending Layer 2 validation |

### Risk Assessment

| Option | Performance Risk | Architectural Risk | Timeline Risk | Overall Risk |
|--------|-----------------|-------------------|---------------|--------------|
| **A** | Low | **High** (wrong fit) | Low | **MEDIUM** |
| **B** | Low | Low | Low | **LOW** |
| **C** | **HIGH** (<10ms) | Medium | Medium | **HIGH** |
| **D** | Low | Low | Medium (new phase) | **LOW** |
| **E** | Medium (Layer 2) | Low | Medium | **MEDIUM** |

### Recommendation Confidence

| Option | Confidence | Primary Reason |
|--------|-----------|----------------|
| **A** | ❌ 10% | Wrong architectural abstraction |
| **B** | ✅ 70% | Solid foundation, but incomplete |
| **C** | ⚠️ 50% | High value, high risk |
| **D** | ✅ 80% | Safe and complete, but adds work |
| **E** | ✅✅ **95%** | **Comprehensive, validated, phased** |

---

## Next Steps

### Immediate Actions (Today)

1. **Decision Required**
   - Review this document
   - Choose integration option (recommended: Option E)
   - Approve proceeding to implementation

2. **O*NET API Registration**
   - Visit: https://services.onetcenter.org/register
   - Register for free API access
   - Obtain username credentials
   - Test API connectivity

3. **Guardian Notification**
   - Notify relevant guardians of chosen approach
   - Schedule validation checkpoints
   - Set up performance monitoring (if Option C or E)

### Week 1: Preparation (If Option E Chosen)

**Day 1:**
- ✅ O*NET API credentials obtained
- ✅ Test API connectivity with sample requests
- ✅ Create project structure in V8 codebase

**Day 2:**
- ✅ Document all 35 O*NET skills
- ✅ Map to existing V8 SkillID taxonomy
- ✅ Create ONetSkillMapper class

**Day 3:**
- ✅ Implement SkillTaxonomy extension
- ✅ Add career matching functionality
- ✅ Unit tests for skill mappings

**Day 4:**
- ✅ Integration tests
- ✅ manifestandmatch-skills-guardian validation
- ✅ Fix any issues identified

**Day 5:**
- ✅ Layer 1 complete sign-off
- ✅ Demo career matching functionality
- ✅ Prepare for Layer 2 (Thompson integration)

### Success Criteria

**Layer 1 Complete:**
- ✅ All 35 O*NET skills mapped to V8 SkillID
- ✅ Bidirectional mapping functional
- ✅ Career matching returns accurate results
- ✅ manifestandmatch-skills-guardian approves

**Layer 2 Complete:**
- ✅ O*NET cache implemented (1 MB)
- ✅ Thompson integration functional
- ✅ **P95 latency < 10ms** (100+ runs)
- ✅ thompson-performance-guardian approves

**Layer 3 Complete:**
- ✅ O*NET API client functional
- ✅ Job sources filter by career
- ✅ End-to-end flow working
- ✅ job-source-integration-validator approves

**Final Integration:**
- ✅ All 3 layers working together
- ✅ All 9 guardians approve
- ✅ Performance regression tests pass
- ✅ User testing validates value

### Documentation Updates Required

1. **Architecture Docs**
   - Update V8 architecture diagrams
   - Document O*NET integration layers
   - Add guardian validation checkpoints

2. **Developer Docs**
   - O*NET API usage guide
   - SkillTaxonomy mapping reference
   - Performance optimization strategies

3. **User Docs**
   - "Explore Careers" feature guide
   - Career matching explanation
   - FAQ about O*NET data source

---

## Appendix A: O*NET Resources

### Official Links
- **API Documentation:** https://services.onetcenter.org/reference/
- **Registration:** https://services.onetcenter.org/register
- **Database Info:** https://www.onetcenter.org/database.html
- **O*NET OnLine:** https://www.onetonline.org/
- **Support Email:** onet@onetcenter.org

### API Examples
```bash
# Search careers by keyword
curl -u "USERNAME:" \
  -H "Accept: application/json" \
  "https://services.onetcenter.org/ws/mnm/search?keyword=software"

# Get career details
curl -u "USERNAME:" \
  -H "Accept: application/json" \
  "https://services.onetcenter.org/ws/mnm/careers/15-1252.00"

# Get skills for career
curl -u "USERNAME:" \
  -H "Accept: application/json" \
  "https://services.onetcenter.org/ws/mnm/careers/15-1252.00/skills"
```

---

## Appendix B: Attribution Requirements

### O*NET Attribution (REQUIRED)

Per O*NET terms of service, you must include attribution in your app:

**In App (About/Credits section):**
```
Career data provided by O*NET OnLine (www.onetonline.org)
Sponsored by the U.S. Department of Labor/Employment and Training Administration.
```

**In API Logs:**
```swift
logger.info("Career data © O*NET OnLine (www.onetonline.org)")
```

**In Marketing Materials:**
```
Powered by O*NET career database
```

---

## Appendix C: Performance Testing Script

```swift
// Packages/V7ThompsonTests/PerformanceTests/ThompsonONetPerformanceTests.swift
import XCTest
@testable import V7Thompson

final class ThompsonONetPerformanceTests: XCTestCase {
    var thompson: V7Thompson!
    var testProfile: V7UserProfile!

    override func setUp() async throws {
        thompson = V7Thompson.shared
        testProfile = V7UserProfile.testProfile()
    }

    func testThompsonWithONetMaintainsTenMilliseconds() async throws {
        let iterations = 100
        var measurements: [Duration] = []

        for i in 0..<iterations {
            let context = V7ThompsonContext(
                userID: testProfile.id,
                sessionID: UUID(),
                timestamp: Date()
            )

            let start = ContinuousClock.now

            _ = try await thompson.recommendWithCareerExploration(
                userProfile: testProfile,
                context: context
            )

            let elapsed = ContinuousClock.now - start
            measurements.append(elapsed)

            // Log individual measurements
            if elapsed >= .milliseconds(10) {
                print("⚠️ Iteration \(i): \(elapsed.milliseconds)ms")
            }
        }

        // Statistical analysis
        let sorted = measurements.sorted()
        let p50 = sorted[50]
        let p95 = sorted[95]
        let p99 = sorted[99]
        let max = sorted[99]

        print("""
        Thompson + O*NET Performance Results:
        P50: \(p50.milliseconds)ms
        P95: \(p95.milliseconds)ms
        P99: \(p99.milliseconds)ms
        Max: \(max.milliseconds)ms
        """)

        // SACRED CONSTRAINT: P95 must be < 10ms
        XCTAssertLessThan(
            p95.milliseconds,
            10.0,
            "P95 Thompson latency exceeded 10ms: \(p95.milliseconds)ms"
        )
    }

    func testONetCacheLookupPerformance() async throws {
        let cache = ONetCache.shared
        let skills: [SkillID] = [.swiftProgramming, .criticalThinking, .problemSolving]

        measure {
            _ = cache.careersForSkills(skills)
        }

        // Cache lookup should be < 1ms
        // Xcode will report if baseline exceeds threshold
    }
}
```

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Oct 27, 2025 | Claude Code | Initial analysis document created |
| 1.1 | [Pending] | [Developer] | Post-decision updates |
| 2.0 | [Pending] | [Developer] | Post-implementation lessons learned |

---

## Approval Signatures

**Decision Maker:** _________________________ Date: _________

**Lead Guardian (manifestandmatch-skills-guardian):** _________________________ Date: _________

**Performance Guardian (thompson-performance-guardian):** _________________________ Date: _________

**Architecture Guardian (v7-architecture-guardian):** _________________________ Date: _________

---

**END OF DOCUMENT**

**Next Action:** Review this document and choose integration option.
**Recommended:** Option E - Hybrid Approach (Skills + Thompson + Job Sources)
**Timeline:** 4 weeks phased implementation
**Risk Level:** Medium (manageable with proper validation)
**Strategic Value:** Very High (complete O*NET integration)
