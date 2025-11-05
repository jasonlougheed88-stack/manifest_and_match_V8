# 10. Data Flows

**End-to-End Data Flow Analysis for Manifest & Match V8**

## Overview

This document traces **5 major data flows** through the application, showing how data moves from entry point to persistence and presentation.

---

## Flow 1: Profile Creation & Resume Upload

**Purpose**: User creates profile and uploads resume, data flows through AI parsing to Core Data persistence

### Flow Diagram

```
User Action (ProfileScreen)
    │
    ├──> Profile Form Data
    │    │
    │    ▼
    │    @State var firstName, lastName, email, etc.
    │    │
    │    ▼
    │    Save Button Tapped (ProfileScreen:148-183)
    │    │
    │    ▼
    │    ProfileManager.saveProfile()
    │    │
    │    ├──> Core Data Context
    │    │    │
    │    │    ▼
    │    │    UserProfile entity created
    │    │    └──> Persisted to disk
    │    │
    │    └──> SwiftData Context
    │         │
    │         ▼
    │         UserProfileSD entity created
    │         └──> Persisted to disk
    │
    └──> Resume PDF Upload
         │
         ▼
         DocumentPicker (SwiftUI)
         │
         ▼
         PDF Data received (Data)
         │
         ▼
         ResumeParser.parse(pdfData:)
         │
         ├──> Step 1: PDF → Text
         │    │
         │    ▼
         │    PDFKit.PDFDocument
         │    │
         │    ▼
         │    Extract text from pages
         │    │
         │    └──> Full text string
         │
         ├──> Step 2: Text → Structured Data
         │    │
         │    ▼
         │    Foundation Language Model
         │    │
         │    ▼
         │    Generate JSON prompt
         │    │
         │    ▼
         │    Parse JSON response
         │    │
         │    └──> ParsedResumeData struct
         │
         └──> Step 3: Structured Data → Profile
              │
              ▼
              Update UserProfile fields
              ├──> firstName
              ├──> lastName
              ├──> email
              ├──> phone
              ├──> location
              │
              ▼
              Create Skills entities
              ├──> Skill 1 (Core Data)
              ├──> Skill 2
              └──> Skill N
              │
              ▼
              Create WorkExperience entities [🚨 BUG: NOT SAVED]
              ├──> Experience 1
              ├──> Experience 2
              └──> Experience N
              │
              ▼
              Create Education entities [🚨 BUG: NOT SAVED]
              ├──> Education 1
              └──> Education N
              │
              ▼
              Save context to Core Data
              │
              └──> Persisted profile
```

### Code References

**Profile Form**: `V7UI/Sources/V7UI/ProfileCreation/ProfileScreen.swift:50-135`
**Save Logic**: `V7UI/Sources/V7UI/ProfileCreation/ProfileScreen.swift:148-183`
**Resume Parser**: `V7AI/Sources/V7AI/ResumeParsing/ResumeParser.swift:23-145`
**Profile Manager**: `V7Data/Sources/V7Data/Managers/ProfileManager.swift:45-120`

### Critical Bug

**WorkExperience & Education NOT Persisted**:
```swift
// WorkExperienceCollectionStepView.swift:145
@State private var experiences: [WorkExperienceData] = []

// User adds experience
experiences.append(newExperience)

// ❌ NEVER SAVED TO CORE DATA
// Only lives in @State, lost on app restart
```

**Fix Required**:
```swift
func saveExperience(_ exp: WorkExperienceData) {
    let context = dataManager.viewContext
    let entity = WorkExperience(context: context)
    entity.id = UUID()
    entity.jobTitle = exp.title
    entity.company = exp.company
    // ... set all fields
    entity.profile = userProfile
    try? context.save()  // ✅ PERSIST TO CORE DATA
}
```

---

## Flow 2: Job Discovery & Thompson Sampling

**Purpose**: User swipes through jobs, Thompson Sampling scores and ranks jobs based on learned preferences

### Flow Diagram

```
User Opens DeckScreen
    │
    ▼
DeckScreen.onAppear()
    │
    ├──> Check JobCache (L2)
    │    │
    │    ▼
    │    Fetch recent cached jobs (24hr TTL)
    │    │
    │    ├──> Cache Hit (70%)
    │    │    └──> Return cached jobs
    │    │
    │    └──> Cache Miss (30%)
    │         │
    │         ▼
    │         JobDiscoveryCoordinator.fetchJobs()
    │
    └──> Fetch Fresh Jobs (if cache miss)
         │
         ▼
         JobDiscoveryCoordinator.fetchJobs()
         │
         ├──> Step 1: Parallel API Calls
         │    │
         │    ├──> AdzunaClient.searchJobs()
         │    │    └──> Returns [RawJobData]
         │    │
         │    ├──> GreenhouseClient.getJobs()
         │    │    └──> Returns [RawJobData]
         │    │
         │    ├──> LeverClient.getJobs()
         │    │    └──> Returns [RawJobData]
         │    │
         │    ├──> JobicyClient.searchJobs()
         │    │    └──> Returns [RawJobData]
         │    │
         │    ├──> USAJobsClient.searchJobs()
         │    │    └──> Returns [RawJobData]
         │    │
         │    ├──> RSSParserClient.parseFeeds()
         │    │    └──> Returns [RawJobData]
         │    │
         │    └──> RemoteOKClient.getJobs()
         │         └──> Returns [RawJobData]
         │
         ├──> Step 2: Deduplicate Jobs
         │    │
         │    ▼
         │    Group by (title + company)
         │    │
         │    └──> Deduplicated [RawJobData]
         │
         ├──> Step 3: Thompson Sampling Scoring
         │    │
         │    ▼
         │    ThompsonSamplingEngine.computeScores()
         │    │
         │    ├──> Fetch ThompsonArms (cached)
         │    │    │
         │    │    ▼
         │    │    [ThompsonArm] (α, β parameters)
         │    │
         │    ├──> Sample Beta Distributions
         │    │    │
         │    │    ▼
         │    │    For each arm:
         │    │      sample = Beta(α, β)
         │    │    │
         │    │    └──> [categoryID: sampledValue]
         │    │
         │    ├──> Categorize Jobs
         │    │    │
         │    │    ▼
         │    │    For each job:
         │    │      categoryID = categorize(job)
         │    │    │
         │    │    └──> [job: categoryID]
         │    │
         │    ├──> Assign Scores
         │    │    │
         │    │    ▼
         │    │    For each job:
         │    │      score = samples[job.categoryID]
         │    │    │
         │    │    └──> [ThompsonScore]
         │    │
         │    └──> Sort by Score (descending)
         │         │
         │         └──> Ranked [ThompsonScore]
         │
         ├──> Step 4: Cache Results
         │    │
         │    ├──> L1: MemoryCache (60s TTL)
         │    │    └──> In-memory dictionary
         │    │
         │    └──> L2: JobCache Core Data (24hr TTL)
         │         └──> Persisted to disk
         │
         └──> Return Ranked Jobs
              │
              ▼
DeckScreen receives jobs
    │
    ▼
Display job cards (SwiftUI)
    │
    └──> User sees ranked jobs
```

### Code References

**DeckScreen**: `V7UI/Sources/V7UI/JobDiscovery/DeckScreen.swift:89-145`
**Job Discovery Coordinator**: `V7Services/Sources/V7Services/JobDiscovery/JobDiscoveryCoordinator.swift:34-120`
**Thompson Engine**: `V7Thompson/Sources/V7Thompson/ThompsonSamplingEngine.swift:45-180`
**Job Cache**: `V7Data/Sources/V7Data/Cache/JobCache.swift:23-90`

### Performance

- **Cache Hit (L1)**: <5ms
- **Cache Hit (L2)**: <50ms
- **API Fetch + Thompson**: 1.2-2.5s
- **Thompson Scoring**: 6-8ms (within <10ms budget)

---

## Flow 3: Swipe Interaction & Learning

**Purpose**: User swipes on job, feedback flows through Thompson arm updates and behavioral analysis

### Flow Diagram

```
User Swipes Card (DeckScreen)
    │
    ├──> Swipe Right (Interested)
    │
    ├──> Swipe Left (Not Interested)
    │
    └──> Swipe Up (Super Interested)
         │
         ▼
handleSwipeAction() (DeckScreen:665-853)
    │
    ├──> Step 1: Create SwipeRecord
    │    │
    │    ▼
    │    SwipeRecord entity
    │    ├──> id = UUID()
    │    ├──> jobID = job.id
    │    ├──> swipeDirection = "right" | "left" | "super"
    │    ├──> timestamp = Date()
    │    ├──> thompsonScore = score
    │    ├──> profileSnapshot = JSON(profile)
    │    ├──> sessionID = currentSessionID
    │    └──> cardPosition = currentIndex
    │
    ├──> Step 2: Update Thompson Arm (Bayesian Update)
    │    │
    │    ▼
    │    ThompsonArmManager.updateArm()
    │    │
    │    ├──> Fetch arm for job category
    │    │    │
    │    │    ▼
    │    │    ThompsonArm(categoryID: category)
    │    │
    │    ├──> Bayesian Update
    │    │    │
    │    │    ▼
    │    │    If swipe == "right" or "super":
    │    │      arm.alpha += 1
    │    │      arm.successCount += 1
    │    │    Else if swipe == "left":
    │    │      arm.beta += 1
    │    │      arm.failureCount += 1
    │    │
    │    └──> Save updated arm
    │         │
    │         └──> Persisted to Core Data
    │
    ├──> Step 3: Behavioral Analysis
    │    │
    │    ▼
    │    BehavioralAnalyst.analyzeSwipeSession()
    │    │
    │    ├──> Extract features from swipes
    │    │    ├──> sessionDuration
    │    │    ├──> averageSwipeInterval
    │    │    ├──> rightSwipeRate
    │    │    ├──> thompsonScoreTrend
    │    │    └──> ... 41 more features
    │    │
    │    ├──> Run Core ML Inference
    │    │    │
    │    │    ▼
    │    │    BehavioralPatternModel.prediction()
    │    │    │
    │    │    └──> Pattern probabilities:
    │    │         ├──> fatigue: 0.15
    │    │         ├──> preferenceShift: 0.82 ✅
    │    │         ├──> explorationSpike: 0.04
    │    │         └──> categoryFocus: 0.67 ✅
    │    │
    │    ├──> Generate Insights
    │    │    │
    │    │    ▼
    │    │    If preferenceShift > 0.6:
    │    │      BehavioralInsight(
    │    │        type: .preferenceShift,
    │    │        description: "Shifting toward Data Science",
    │    │        suggestedAction: "Show more data jobs"
    │    │      )
    │    │
    │    └──> Save Insights
    │         │
    │         └──> BehavioralPattern Core Data
    │
    ├──> Step 4: Update Job Cache
    │    │
    │    ▼
    │    JobCache.updateDisplayCount()
    │    │
    │    └──> Increment displayedCount field
    │
    ├──> Step 5: Check Starred (Super Swipe)
    │    │
    │    ▼
    │    If swipe == "super":
    │      │
    │      ├──> Add to StarredJobs
    │      │    └──> Persisted to Core Data
    │      │
    │      └──> Create notification
    │           └──> "You starred [Job Title]!"
    │
    ├──> Step 6: Persist All Changes
    │    │
    │    ▼
    │    Core Data context.save()
    │    ├──> SwipeRecord ✅
    │    ├──> ThompsonArm ✅
    │    ├──> BehavioralPattern ✅
    │    ├──> JobCache ✅
    │    └──> StarredJobs ✅ (if super swipe)
    │
    └──> Step 7: UI Update
         │
         ▼
         Remove card from deck
         │
         ▼
         Show next job card
         │
         └──> Animation complete
```

### Code References

**Swipe Handler**: `V7UI/Sources/V7UI/JobDiscovery/DeckScreen.swift:665-853`
**Thompson Update**: `V7Thompson/Sources/V7Thompson/Managers/ThompsonArmManager.swift:78-135`
**Behavioral Analysis**: `V7AI/Sources/V7AI/BehavioralAnalysis/BehavioralAnalyst.swift:45-220`

### Data Persistence

**7 layers of persistence** (all atomic):
1. SwipeRecord (individual swipe)
2. ThompsonArm (category learning)
3. BehavioralPattern (insights)
4. JobCache (display count)
5. StarredJobs (super swipes)
6. SwipeSessionMetadata (session stats)
7. PerformanceMetrics (timing data)

---

## Flow 4: Career Question Generation & Response

**Purpose**: AI generates personalized questions, user responds, answers flow to profile enrichment

### Flow Diagram

```
User Taps "Career Questions" (HomeScreen)
    │
    ▼
QuestionCardView appears
    │
    ▼
SmartQuestionGenerator.generateQuestions()
    │
    ├──> Step 1: Identify Profile Gaps
    │    │
    │    ▼
    │    Analyze UserProfile
    │    ├──> Missing skills? ✅
    │    ├──> Missing work experience? ❌
    │    ├──> Answered "values" questions? ❌
    │    ├──> Answered "interests" questions? ❌
    │    └──> Answered "lifestyle" questions? ✅
    │    │
    │    └──> Gaps: [values, interests]
    │
    ├──> Step 2: Build AI Prompt
    │    │
    │    ▼
    │    Prompt template:
    │    "Generate 3 career questions focusing on: values, interests"
    │    │
    │    └──> Full prompt string
    │
    ├──> Step 3: Foundation Model Generation
    │    │
    │    ▼
    │    LanguageModel.generate()
    │    │
    │    ├──> On-device inference (180ms)
    │    │
    │    └──> Raw response text:
    │         Q: What matters most to you in a career?
    │         Category: values
    │
    │         Q: What types of problems excite you?
    │         Category: interests
    │
    │         Q: Describe your ideal work environment?
    │         Category: lifestyle
    │
    ├──> Step 4: Parse Response
    │    │
    │    ▼
    │    Extract questions and categories
    │    │
    │    └──> [CareerQuestion] structs
    │
    └──> Return questions to UI
         │
         ▼
QuestionCardView displays questions
    │
    └──> User sees cards

User Answers Question
    │
    ▼
Text input / Multiple choice selection
    │
    ▼
QuestionCardView.saveAnswer()
    │
    ├──> Create/Update CareerQuestion entity
    │    │
    │    ▼
    │    CareerQuestion (Core Data)
    │    ├──> id = UUID()
    │    ├──> questionText = "What matters most..."
    │    ├──> category = "values"
    │    ├──> userResponse = "Work-life balance and..."
    │    ├──> responseTimestamp = Date()
    │    ├──> generatedBy = "foundation_models"
    │    └──> importance = 1.0
    │    │
    │    └──> Persisted to Core Data
    │
    ├──> Extract User Truths
    │    │
    │    ▼
    │    Analyze response for patterns
    │    │
    │    ▼
    │    Foundation Model inference
    │    │
    │    └──> UserTruth:
    │         - category: "work_style"
    │         - statement: "Prefers remote work"
    │         - confidence: 0.85
    │
    ├──> Update Thompson Arms
    │    │
    │    ▼
    │    If response indicates category preference:
    │      Boost α for matching categories
    │    │
    │    └──> Updated ThompsonArm
    │
    └──> Persist all changes
         │
         └──> Core Data context.save()
```

### Code References

**Question Generator**: `V7AI/Sources/V7AI/QuestionGeneration/SmartQuestionGenerator.swift:34-156`
**Question Card View**: `V7UI/Sources/V7UI/CareerQuestions/QuestionCardView.swift:45-220`
**User Truths Extractor**: `V7AI/Sources/V7AI/TruthExtraction/UserTruthExtractor.swift:23-98`

---

## Flow 5: O*NET Skills Matching & Career Path Recommendations

**Purpose**: User skills matched to O*NET taxonomy, career transition paths recommended

### Flow Diagram

```
User Views Profile → Taps "Recommended Careers"
    │
    ▼
CareerPathScreen appears
    │
    ▼
CareerPathRecommender.recommendPaths()
    │
    ├──> Step 1: Match Skills to O*NET
    │    │
    │    ▼
    │    SkillsMatcher.matchSkills()
    │    │
    │    ├──> Get user skills
    │    │    └──> ["Swift", "Python", "Machine Learning"]
    │    │
    │    ├──> Generate embeddings (Foundation Model)
    │    │    │
    │    │    ▼
    │    │    EmbeddingModel.embed(texts: skills)
    │    │    │
    │    │    └──> [Float] vectors (768 dimensions each)
    │    │
    │    ├──> Load O*NET skills (636 skills cached)
    │    │    │
    │    │    ▼
    │    │    [ONETSkill] from Core Data
    │    │
    │    ├──> Get cached O*NET embeddings
    │    │    │
    │    │    └──> [Float] vectors (pre-computed)
    │    │
    │    ├──> Compute cosine similarities
    │    │    │
    │    │    ▼
    │    │    For each (userSkill, onetSkill):
    │    │      similarity = cosine(userEmbed, onetEmbed)
    │    │    │
    │    │    └──> [(userSkill, [(onetSkill, similarity)])]
    │    │
    │    └──> Return top matches
    │         │
    │         Example:
    │         "Swift" → "Mobile Development" (0.94)
    │         "Python" → "Programming" (0.89)
    │         "Machine Learning" → "AI/ML" (1.00)
    │
    ├──> Step 2: Identify O*NET Occupations
    │    │
    │    ▼
    │    Query ONETOccupation entities
    │    │
    │    ▼
    │    Filter by matched skills
    │    │
    │    └──> Candidate occupations:
    │         - "15-1252.00: Software Developers"
    │         - "15-2051.00: Data Scientists"
    │         - "15-1299.07: Blockchain Engineers"
    │
    ├──> Step 3: Analyze Swipe History
    │    │
    │    ▼
    │    Fetch SwipeRecords (last 90 days)
    │    │
    │    ▼
    │    Analyze category preferences
    │    │
    │    └──> Emerging categories:
    │         - Data Science: 45%
    │         - ML Engineering: 32%
    │         - DevOps: 12%
    │
    ├──> Step 4: Generate Career Paths (Foundation Model)
    │    │
    │    ▼
    │    Build prompt:
    │    - Current occupation
    │    - Matched O*NET skills
    │    - Emerging interests from swipes
    │    - Current experience level
    │    │
    │    ▼
    │    LanguageModel.generate()
    │    │
    │    └──> Raw response:
    │         PATH 1: Machine Learning Engineer
    │         Why: Strong Python + ML skills
    │         Skills Needed: PyTorch, TensorFlow
    │         Timeline: 6-9 months
    │         First Steps: Build ML projects
    │
    │         PATH 2: Data Scientist
    │         ...
    │
    ├──> Step 5: Parse Paths
    │    │
    │    ▼
    │    Extract structured data
    │    │
    │    └──> [CareerPath] structs
    │
    └──> Display in UI
         │
         ▼
CareerPathScreen shows cards
    │
    └──> User sees recommendations

User Taps Path → "Learn More"
    │
    ▼
CareerPathDetailView
    │
    ├──> Show detailed breakdown
    │
    ├──> Link to relevant courses
    │
    └──> Show matching jobs
         │
         ▼
         JobDiscoveryCoordinator.fetchJobs(category: path.category)
         │
         └──> Filtered jobs displayed
```

### Code References

**Skills Matcher**: `V7AI/Sources/V7AI/SkillsMatching/SkillsMatcher.swift:34-145`
**Career Path Recommender**: `V7AI/Sources/V7AI/CareerPath/CareerPathRecommender.swift:45-220`
**O*NET Data Manager**: `V7Data/Sources/V7Data/Managers/ONETDataManager.swift:56-189`
**Career Path Screen**: `V7UI/Sources/V7UI/CareerPath/CareerPathScreen.swift:78-245`

---

## Cross-Flow Data Dependencies

### Shared Data Entities

```
UserProfile
    ├──> Used by: Flow 1, 2, 3, 4, 5
    └──> Updated by: Flow 1, 4

ThompsonArm
    ├──> Used by: Flow 2, 3
    └──> Updated by: Flow 3

SwipeRecord
    ├──> Used by: Flow 3, 5
    └──> Updated by: Flow 3

ONETOccupation & ONETSkill
    ├──> Used by: Flow 5
    └──> Updated by: Initial app data load

JobCache
    ├──> Used by: Flow 2
    └──> Updated by: Flow 2, 3
```

### Data Consistency

All flows use **Core Data's built-in ACID transactions** to ensure data consistency:
```swift
try context.performAndWait {
    // Multiple entity updates
    context.insert(swipeRecord)
    thompsonArm.alpha += 1
    jobCache.displayedCount += 1

    // Atomic commit
    try context.save()  // ✅ All or nothing
}
```

---

## Performance Metrics by Flow

| Flow | End-to-End Latency | Critical Path | Bottleneck |
|------|-------------------|---------------|------------|
| Flow 1 (Profile) | 1.2-2.5s | Resume parsing | Vision OCR (scanned PDFs) |
| Flow 2 (Discovery) | 1.5-3.0s | API calls | Network latency |
| Flow 3 (Swipe) | 45-120ms | Behavioral analysis | Core ML inference |
| Flow 4 (Questions) | 180-320ms | Question generation | Language Model |
| Flow 5 (Career Paths) | 350-580ms | Path generation | Language Model + embeddings |

---

## Error Handling Patterns

### Retry Logic

```swift
func fetchWithRetry<T>(
    maxRetries: Int = 3,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?

    for attempt in 0..<maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxRetries - 1 {
                let delay = pow(2.0, Double(attempt))  // Exponential backoff
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }

    throw lastError!
}
```

### Graceful Degradation

```swift
// Flow 2: If Thompson Sampling fails, fall back to random
let jobs: [RawJobData]
do {
    jobs = try await fetchAndScoreJobs()  // Thompson Sampling
} catch {
    jobs = try await fetchJobs().shuffled()  // Random fallback
}
```

---

## Documentation References

- **Data Flow Diagrams**: `Documentation/DATA_FLOWS.md`
- **Error Handling Guide**: `Documentation/ERROR_HANDLING.md`
- **Performance Optimization**: `Documentation/PERFORMANCE.md`
