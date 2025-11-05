# PHASE 3.5: AI-DRIVEN O*NET INTEGRATION
## Revised Integration Plan: Remove Manual UI, Enable AI-Driven Profile Building

**Status**: Planning - Revised Approach
**Created**: 2025-10-31
**Supersedes**: PHASE_3_ONET_CAREER_INTEGRATION_PLAN.md (manual UI approach)

---

## EXECUTIVE SUMMARY

### ❌ Rejected Approach (Previous Plan)
- Manual sliders and pickers for O*NET profile building
- User manually selects education level, work activities, RIASEC dimensions
- O*NET UI moved from ProfileScreen to ManifestTabView

### ✅ Approved Approach (This Plan)
- **AI-driven O*NET profile building** through conversational questions
- User answers natural career questions, AI infers O*NET profile
- **Remove all manual O*NET UI components** from ProfileScreen
- **Keep Core Data schema** unchanged (AI populates these fields)
- ManifestTabView features **consume** O*NET data without exposing manual controls

### Key Principle
> "I want this to be built into the system but then updated through the ai driven questions to assist with the future career path."
> — User Requirement, 2025-10-31

---

## PART 1: CURRENT STATE ANALYSIS

### 1.1 What Exists Today (Phase 2 Implementation)

**Core Data Schema** ✅ KEEP UNCHANGED
```swift
// UserProfile+CoreData.swift
@NSManaged public var onetEducationLevel: Int16                      // 1-12 scale
@NSManaged public var onetWorkActivities: [String: Double]?          // 41 activities, 1-7 importance
@NSManaged public var onetRIASECRealistic: Double                    // 0-7 scale
@NSManaged public var onetRIASECInvestigative: Double
@NSManaged public var onetRIASECArtistic: Double
@NSManaged public var onetRIASECSocial: Double
@NSManaged public var onetRIASECEnterprising: Double
@NSManaged public var onetRIASECConventional: Double
```
**Status**: These fields remain in Core Data. AI populates them, not manual UI.

**Manual UI Components** ❌ REMOVE ENTIRELY
- **ONetEducationLevelPicker** (`V7UI/Components/ONetEducationLevelPicker.swift`)
  - 12-level slider with quick select buttons
  - Lines 39-150, 250 lines
  - Thompson weight: 15%

- **ONetWorkActivitiesSelector** (`V7UI/Components/ONetWorkActivitiesSelector.swift`)
  - 41 work activities with 1-7 importance sliders
  - Lines 42-350, 650 lines
  - Thompson weight: 25%

- **RIASECInterestProfiler** (`V7UI/Components/RIASECInterestProfiler.swift`)
  - 6 RIASEC dimensions with radar chart and sliders
  - Lines 40-450, 850 lines
  - Thompson weight: 15%

**ProfileScreen Integration** ❌ REMOVE O*NET CARDS
- State variables: `@State private var onetEducationLevel`, `onetWorkActivities`, `riasec*` (Lines 124-141)
- Cards in hierarchy: `onetEducationLevelCard`, `onetWorkActivitiesCard`, `riasecInterestCard` (Lines 217-224)
- Save functions: `saveONetEducationLevel()`, `saveONetWorkActivities()`, `saveRIASECProfile()` (Lines 2022-2100)

**Total Lines to Remove from ProfileScreen**: ~300 lines (state vars, cards, save functions)

### 1.2 Thompson Sampling Dependency

**Critical Integration**: V7Thompson algorithm uses O*NET for job scoring

```swift
// ThompsonSamplingAlgorithm.swift (conceptual)
func scoreJob(_ job: Job, profile: UserProfile) -> Double {
    var score = 0.0

    // Education match (15% weight)
    score += educationMatch(job.requiredEducation, profile.onetEducationLevel) * 0.15

    // Work activities alignment (25% weight)
    score += workActivitiesMatch(job.activities, profile.onetWorkActivities) * 0.25

    // RIASEC personality fit (15% weight)
    score += riasecMatch(job.riasecProfile, profile) * 0.15

    // Skills + other factors (45% weight)
    score += skillsMatch(...) * 0.45

    return score
}
```

**Implication**: O*NET data MUST exist in Core Data for Thompson to function. The question is **how it gets there** (AI-driven, not manual).

### 1.3 ManifestTabView Career Features

**Phase 3 Features** (Already Implemented)
- **Skills Gap Analysis**: Compares current skills vs career path requirements
- **Career Path Visualization**: Shows progression timeline with milestones
- **Course Recommendations**: Suggests courses to close skills gaps

**Current Problem**: These features can't fully leverage O*NET data because:
1. Users might not fill out O*NET manually (tedious)
2. O*NET is in ProfileScreen (Match/Amber), not career context (Manifest/Teal)
3. No AI-driven inference means incomplete O*NET profiles

**Desired State**: AI builds O*NET profile naturally through career questions → Career features use rich O*NET data for recommendations.

---

## PART 2: AI-DRIVEN O*NET ARCHITECTURE

### 2.1 Conceptual Overview

```
User Career Questions → AI Analysis → O*NET Profile Inference → Core Data Population
                                                                        ↓
                                                    Thompson Sampling + Career Features Consume Data
```

**User Experience Flow**:
1. User navigates to ManifestTabView (Career Journey)
2. System detects incomplete O*NET profile
3. AI asks natural questions: "What kind of projects excite you?" "Describe your ideal work environment"
4. User answers conversationally (text or voice)
5. AI processes answers and populates `onetEducationLevel`, `onetWorkActivities`, `onetRIASEC*`
6. O*NET profile emerges naturally without user seeing "O*NET" terminology
7. Skills Gap Analysis, Career Path, Courses now powered by rich O*NET data

### 2.2 Question Database Design

**CareerQuestion Entity** (New or Enhanced)
```swift
@Model
final class CareerQuestion {
    // Question metadata
    var id: UUID
    var text: String              // "What kind of problems energize you?"
    var category: QuestionCategory  // .interests, .workStyle, .education, .skills

    // O*NET mapping metadata
    var onetEducationSignal: Int?           // If answer implies education level
    var onetWorkActivities: [String]        // Tagged work activities this question reveals
    var onetRIASECDimensions: [RIASECDim]  // RIASEC dimensions this question probes

    // AI processing
    var aiProcessingHints: String          // Guidance for AI to extract O*NET signals

    // Order and conditions
    var displayOrder: Int
    var conditionalLogic: String?          // "Only ask if RIASEC Investigative < 3.0"
}

enum QuestionCategory: String, Codable {
    case interests              // RIASEC-focused
    case workStyle             // Work activities preferences
    case education             // Education level inference
    case skills                // Skills + work activities
    case values                // Work values (may influence RIASEC)
}

enum RIASECDim: String, Codable {
    case realistic, investigative, artistic, social, enterprising, conventional
}
```

**Example Questions with O*NET Mapping**:

```swift
// Question 1: RIASEC Artistic + Investigative
CareerQuestion(
    text: "Describe a project you're most proud of. What made it meaningful?",
    category: .interests,
    onetWorkActivities: ["4.A.1.a.1", "4.A.2.a.3"],  // Thinking Creatively, Analyzing Data
    onetRIASECDimensions: [.artistic, .investigative],
    aiProcessingHints: "High artistic words: 'design', 'create', 'visual', 'aesthetic'. High investigative: 'analyze', 'research', 'solve', 'figure out'."
)

// Question 2: Work Activities (Interacting with Computers)
CareerQuestion(
    text: "How comfortable are you working with software and technology?",
    category: .workStyle,
    onetWorkActivities: ["4.A.3.a.3"],  // Interacting with Computers
    aiProcessingHints: "Rate 1-7 based on: 'daily use' (6-7), 'comfortable' (4-5), 'learning' (2-3), 'avoid' (1)"
)

// Question 3: Education Level
CareerQuestion(
    text: "What level of education feels right for your career goals?",
    category: .education,
    onetEducationSignal: 8,  // Triggers education level inference
    aiProcessingHints: "Map responses: 'PhD/doctorate' → 12, 'Master's' → 10, 'Bachelor's' → 8, 'Associate's' → 6, 'High school' → 2"
)

// Question 4: RIASEC Social + Enterprising
CareerQuestion(
    text: "Do you prefer working independently or leading a team?",
    category: .interests,
    onetRIASECDimensions: [.social, .enterprising],
    aiProcessingHints: "High social: 'collaborate', 'help', 'teach'. High enterprising: 'lead', 'manage', 'direct', 'persuade'."
)
```

### 2.3 AI Processing Architecture

**AI Answer Processor** (Conceptual Service)
```swift
actor AICareerProfileBuilder {

    /// Processes user answer and updates O*NET profile in Core Data
    func processAnswer(
        question: CareerQuestion,
        answer: String,
        userProfile: UserProfile,
        context: ModelContext
    ) async throws {

        // 1. Get AI inference from answer
        let inference = try await inferONetSignals(
            question: question,
            answer: answer
        )

        // 2. Update Core Data based on inference
        await MainActor.run {
            // Education level
            if let educationLevel = inference.educationLevel {
                userProfile.onetEducationLevel = Int16(educationLevel)
            }

            // Work activities (merge with existing)
            if let activities = inference.workActivities {
                var existing = userProfile.onetWorkActivities ?? [:]
                for (activityID, importance) in activities {
                    // Average with existing value if present
                    if let existingValue = existing[activityID] {
                        existing[activityID] = (existingValue + importance) / 2.0
                    } else {
                        existing[activityID] = importance
                    }
                }
                userProfile.onetWorkActivities = existing
            }

            // RIASEC dimensions (incremental adjustment)
            if let riasec = inference.riasecAdjustments {
                userProfile.onetRIASECRealistic += riasec.realistic ?? 0.0
                userProfile.onetRIASECInvestigative += riasec.investigative ?? 0.0
                userProfile.onetRIASECArtistic += riasec.artistic ?? 0.0
                userProfile.onetRIASECSocial += riasec.social ?? 0.0
                userProfile.onetRIASECEnterprising += riasec.enterprising ?? 0.0
                userProfile.onetRIASECConventional += riasec.conventional ?? 0.0

                // Clamp to 0-7 range
                userProfile.onetRIASECRealistic = min(max(userProfile.onetRIASECRealistic, 0.0), 7.0)
                // ... (repeat for all dimensions)
            }

            userProfile.lastModified = Date()
            try? context.save()
        }
    }

    /// Sends answer to AI API and extracts O*NET signals
    private func inferONetSignals(
        question: CareerQuestion,
        answer: String
    ) async throws -> ONetInference {

        // Build AI prompt with question context
        let prompt = """
        Question: \(question.text)
        User Answer: \(answer)

        Processing Hints: \(question.aiProcessingHints)

        Extract O*NET signals:
        - Education level (1-12 scale): \(question.onetEducationSignal != nil ? "REQUIRED" : "optional")
        - Work activities importance (1-7 scale): \(question.onetWorkActivities.joined(separator: ", "))
        - RIASEC adjustments (-2 to +2): \(question.onetRIASECDimensions.map(\.rawValue).joined(separator: ", "))

        Return JSON with extracted values.
        """

        // Call AI API (OpenRouter, Anthropic, etc.)
        let response = try await aiService.complete(prompt: prompt)

        // Parse JSON response into ONetInference
        return try JSONDecoder().decode(ONetInference.self, from: response.data)
    }
}

struct ONetInference: Codable {
    var educationLevel: Int?                        // 1-12
    var workActivities: [String: Double]?           // activityID → importance (1-7)
    var riasecAdjustments: RIASECAdjustments?       // Incremental changes
}

struct RIASECAdjustments: Codable {
    var realistic: Double?       // -2.0 to +2.0 per question
    var investigative: Double?
    var artistic: Double?
    var social: Double?
    var enterprising: Double?
    var conventional: Double?
}
```

### 2.4 Integration Points

**Where AI Questions Appear**:
1. **ManifestTabView Initial Launch**: If O*NET profile incomplete, show AI question flow
2. **Skills Gap Analysis**: If skills gap detected, ask clarifying O*NET questions
3. **Career Path Selection**: When exploring new career, ask O*NET questions to refine recommendations
4. **Periodic Refinement**: Every 30 days, ask 1-2 questions to update O*NET profile

**UI Pattern**:
```swift
// ManifestTabView.swift
struct ManifestTabView: View {
    @State private var showONetDiscovery = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if onetProfileIncomplete {
                    // AI-driven O*NET discovery card
                    AICareerDiscoveryCard(onComplete: { showONetDiscovery = false })
                }

                // Career features (use O*NET data)
                SkillsGapAnalysisCard()
                CareerPathVisualizationCard()
                CourseRecommendationsCard()
            }
        }
    }

    private var onetProfileIncomplete: Bool {
        // Check if O*NET profile needs refinement
        guard let profile = UserProfile.fetchCurrent(in: context) else { return true }

        // Check education level set
        guard profile.onetEducationLevel > 0 else { return true }

        // Check at least 10 work activities rated
        guard (profile.onetWorkActivities?.count ?? 0) >= 10 else { return true }

        // Check RIASEC dimensions not all default (3.5)
        let riasecValues = [
            profile.onetRIASECRealistic,
            profile.onetRIASECInvestigative,
            profile.onetRIASECArtistic,
            profile.onetRIASECSocial,
            profile.onetRIASECEnterprising,
            profile.onetRIASECConventional
        ]
        let variance = riasecValues.reduce(0.0) { $0 + abs($1 - 3.5) }
        guard variance > 2.0 else { return true }  // If all near 3.5, incomplete

        return false
    }
}
```

---

## PART 3: IMPLEMENTATION PLAN

### 3.1 Task Breakdown

**TASK 1: Remove Manual O*NET UI from ProfileScreen**
- **Scope**: Delete O*NET state variables, cards, and save functions from ProfileScreen
- **Files Modified**:
  - `V7UI/Sources/V7UI/Views/ProfileScreen.swift` (remove ~300 lines)
- **Files Deleted** (Optional - can keep for reference but not use):
  - `V7UI/Sources/V7UI/Components/ONetEducationLevelPicker.swift` (250 lines)
  - `V7UI/Sources/V7UI/Components/ONetWorkActivitiesSelector.swift` (650 lines)
  - `V7UI/Sources/V7UI/Components/RIASECInterestProfiler.swift` (850 lines)
- **Estimated Time**: 2-3 hours
- **Risk**: Low (removal only, no new code)

**TASK 2: Create CareerQuestion Database Schema**
- **Scope**: Define CareerQuestion entity with O*NET mapping metadata
- **Files Created**:
  - `V7Data/Sources/V7Data/Entities/CareerQuestion+CoreData.swift` (150 lines)
  - `V7Data/Sources/V7Data/Services/CareerQuestionDatabase.swift` (300 lines)
- **Schema Design**:
  - `id: UUID`, `text: String`, `category: QuestionCategory`
  - `onetEducationSignal: Int?`, `onetWorkActivities: [String]`, `onetRIASECDimensions: [RIASECDim]`
  - `aiProcessingHints: String`, `displayOrder: Int`, `conditionalLogic: String?`
- **Estimated Time**: 4-6 hours
- **Risk**: Medium (new Core Data entity, migration required)

**TASK 3: Build AI Processing Service**
- **Scope**: Create AICareerProfileBuilder actor that processes answers and populates O*NET Core Data
- **Files Created**:
  - `V7Services/Sources/V7Services/AI/AICareerProfileBuilder.swift` (400 lines)
  - `V7Services/Sources/V7Services/AI/ONetInference.swift` (100 lines)
- **Key Methods**:
  - `processAnswer(question:answer:userProfile:context:)` → updates Core Data
  - `inferONetSignals(question:answer:)` → calls AI API, parses response
- **AI API Integration**: OpenRouter (multi-model) or direct Anthropic/OpenAI
- **Estimated Time**: 8-12 hours
- **Risk**: High (AI reliability, parsing, error handling)

**TASK 4: Create AI Career Discovery UI**
- **Scope**: Build conversational UI for AI-driven O*NET questions in ManifestTabView
- **Files Created**:
  - `V7Career/Sources/V7Career/Views/AICareerDiscoveryView.swift` (500 lines)
  - `V7Career/Sources/V7Career/Components/AICareerDiscoveryCard.swift` (200 lines)
- **UI Flow**:
  - Show question text with Manifest/Teal theming
  - Text field for answer (or voice input)
  - Progress indicator (e.g., "3 of 8 questions")
  - "Skip" option with warning that recommendations will be less accurate
- **Estimated Time**: 6-8 hours
- **Risk**: Medium (UX design, accessibility)

**TASK 5: Integrate AI Discovery into ManifestTabView**
- **Scope**: Add O*NET completeness check and trigger AI discovery flow
- **Files Modified**:
  - `V7Career/Sources/V7Career/Views/ManifestTabView.swift` (add 80 lines)
- **Logic**:
  - Check `onetProfileIncomplete` property (education level, work activities count, RIASEC variance)
  - Show AICareerDiscoveryCard if incomplete
  - Hide after completion or user dismisses
- **Estimated Time**: 3-4 hours
- **Risk**: Low (integration only)

**TASK 6: Seed Initial Question Database**
- **Scope**: Create 15-20 initial career questions with O*NET mappings
- **Files Created**:
  - `V7Data/Sources/V7Data/Seed/CareerQuestionsSeed.swift` (600 lines)
- **Question Categories**:
  - Interests (RIASEC): 6 questions (1 per dimension)
  - Work style (Activities): 8 questions (cover top work activities)
  - Education: 2 questions (direct + aspirational)
  - Skills: 4 questions (technical, creative, interpersonal, analytical)
- **Estimated Time**: 6-8 hours
- **Risk**: Medium (question design, O*NET mapping accuracy)

**TASK 7: Test AI Processing Pipeline**
- **Scope**: Validate AI answer processing and Core Data population
- **Files Created**:
  - `V7Tests/V7ServicesTests/AI/AICareerProfileBuilderTests.swift` (400 lines)
- **Test Cases**:
  - Education level inference from answers
  - Work activities importance extraction
  - RIASEC dimension adjustments
  - Core Data persistence after processing
  - Error handling (AI API failures, invalid responses)
- **Estimated Time**: 6-8 hours
- **Risk**: High (AI non-determinism, mock API responses)

**TASK 8: Update Thompson Sampling Integration**
- **Scope**: Ensure Thompson algorithm correctly uses AI-populated O*NET data
- **Files Modified**:
  - `V7Thompson/Sources/V7Thompson/ThompsonSamplingAlgorithm.swift` (verify existing code)
- **Validation**:
  - Confirm education matching logic works with AI-populated levels
  - Verify work activities alignment uses AI-populated dictionary
  - Test RIASEC personality fit with AI-adjusted dimensions
- **Estimated Time**: 3-4 hours
- **Risk**: Low (validation only, Thompson already uses O*NET fields)

**TASK 9: Guardian Skills Review**
- **Scope**: Have all guardian skills review revised architecture
- **Files to Review**: All new files from Tasks 2-8
- **Guardians**:
  - v7-architecture-guardian (package dependencies, MV pattern)
  - swift-concurrency-enforcer (actor isolation, Sendable)
  - swiftui-specialist (state management, accessibility)
  - accessibility-compliance-enforcer (VoiceOver, Dynamic Type)
  - core-data-specialist (schema, thread safety)
  - app-narrative-guide (Manifest/Match alignment, career discovery narrative)
- **Estimated Time**: 2-3 hours
- **Risk**: Low (review only)

### 3.2 Total Effort Estimate

**Total Time**: 40-56 hours (5-7 days for 1 developer)

**Breakdown by Risk**:
- Low Risk Tasks: 10-14 hours (removal, integration, validation)
- Medium Risk Tasks: 16-22 hours (schema, UI, seeding)
- High Risk Tasks: 14-20 hours (AI service, testing)

---

## PART 4: CORE DATA MIGRATION

### 4.1 No Schema Changes Required

**Good News**: O*NET fields already exist in UserProfile Core Data schema from Phase 2.

```swift
// Existing schema (NO CHANGES)
@NSManaged public var onetEducationLevel: Int16
@NSManaged public var onetWorkActivities: [String: Double]?
@NSManaged public var onetRIASECRealistic: Double
@NSManaged public var onetRIASECInvestigative: Double
@NSManaged public var onetRIASECArtistic: Double
@NSManaged public var onetRIASECSocial: Double
@NSManaged public var onetRIASECEnterprising: Double
@NSManaged public var onetRIASECConventional: Double
```

**Only Change**: How these fields get populated (AI instead of manual UI).

### 4.2 New Entity: CareerQuestion

**New Core Data Entity** (requires lightweight migration):

```swift
@Model
final class CareerQuestion {
    @Attribute(.unique) var id: UUID
    var text: String
    var category: String  // QuestionCategory enum raw value

    // O*NET mapping
    var onetEducationSignal: Int16
    var onetWorkActivitiesJSON: String  // JSON-encoded [String]
    var onetRIASECDimensionsJSON: String  // JSON-encoded [RIASECDim]

    // AI hints
    var aiProcessingHints: String

    // Ordering
    var displayOrder: Int16
    var conditionalLogic: String?

    // Timestamps
    var createdAt: Date
    var updatedAt: Date
}
```

**Migration Strategy**:
1. Add CareerQuestion entity to Core Data model
2. Run lightweight migration (no existing data to migrate)
3. Seed initial questions in first app launch after migration

### 4.3 User Answer History (Optional for Phase 3.5)

**Future Enhancement**: Store user answers for profile refinement over time.

```swift
@Model
final class CareerQuestionAnswer {
    @Attribute(.unique) var id: UUID
    var question: CareerQuestion  // Relationship
    var answer: String
    var answeredAt: Date

    // O*NET signals extracted
    var extractedEducationLevel: Int16
    var extractedWorkActivitiesJSON: String
    var extractedRIASECJSON: String
}
```

**Not Required for Phase 3.5**: Focus on initial O*NET population, not historical tracking.

---

## PART 5: AI API INTEGRATION

### 5.1 API Provider Selection

**Recommended: OpenRouter**
- Multi-model support (fallback if one model fails)
- Cost-effective ($0.06-$0.15 per 1M tokens)
- Simple REST API
- Models: GPT-4o-mini, Claude 3 Haiku, Llama 3 70B

**Alternative: Direct Anthropic API**
- Claude 3.5 Sonnet ($3.00 per 1M input tokens)
- Excellent at structured output (JSON)
- Higher quality inference, higher cost

**Alternative: OpenAI API**
- GPT-4o-mini ($0.15 per 1M input tokens)
- Good structured output with JSON mode
- Moderate cost

**Recommendation**: Start with OpenRouter GPT-4o-mini for cost efficiency, add Claude fallback for complex questions.

### 5.2 API Request Format

**Example Request**:
```json
{
  "model": "openai/gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are a career assessment AI. Extract O*NET profile signals from user answers. Return ONLY valid JSON with no additional text."
    },
    {
      "role": "user",
      "content": "Question: Describe a project you're most proud of. What made it meaningful?\n\nUser Answer: I built a machine learning model to predict customer churn. I loved analyzing the data patterns and figuring out which features mattered most. The visual dashboard I created helped the business team understand the insights.\n\nProcessing Hints: High artistic words: 'design', 'create', 'visual', 'aesthetic'. High investigative: 'analyze', 'research', 'solve', 'figure out'.\n\nExtract O*NET signals:\n- Work activities importance (1-7 scale): 4.A.2.a.3 (Analyzing Data), 4.A.1.a.1 (Thinking Creatively)\n- RIASEC adjustments (-2 to +2): investigative, artistic\n\nReturn JSON:\n{\n  \"workActivities\": { \"activityID\": importance },\n  \"riasecAdjustments\": { \"dimension\": adjustment }\n}"
    }
  ],
  "response_format": { "type": "json_object" },
  "temperature": 0.3
}
```

**Example Response**:
```json
{
  "id": "gen-123",
  "choices": [
    {
      "message": {
        "content": "{\"workActivities\":{\"4.A.2.a.3\":6.5,\"4.A.1.a.1\":5.0},\"riasecAdjustments\":{\"investigative\":1.5,\"artistic\":1.0}}"
      }
    }
  ]
}
```

### 5.3 Error Handling

**Failure Modes**:
1. API timeout or network error
2. Invalid JSON response
3. Missing required fields in JSON
4. Out-of-range values (education level > 12, RIASEC adjustment > 2.0)

**Fallback Strategy**:
```swift
actor AICareerProfileBuilder {

    private let primaryProvider = "openai/gpt-4o-mini"
    private let fallbackProvider = "anthropic/claude-3-haiku"

    func inferONetSignals(question: CareerQuestion, answer: String) async throws -> ONetInference {
        do {
            return try await callAI(provider: primaryProvider, question: question, answer: answer)
        } catch {
            print("⚠️ Primary AI provider failed, trying fallback: \(error)")
            return try await callAI(provider: fallbackProvider, question: question, answer: answer)
        }
    }

    private func callAI(provider: String, question: CareerQuestion, answer: String) async throws -> ONetInference {
        // Build request
        let request = AIRequest(provider: provider, prompt: buildPrompt(question, answer))

        // Call API with 10s timeout
        let response = try await aiService.complete(request, timeout: 10.0)

        // Parse and validate JSON
        guard let data = response.content.data(using: .utf8) else {
            throw AIError.invalidResponse
        }

        let inference = try JSONDecoder().decode(ONetInference.self, from: data)

        // Validate ranges
        try validateInference(inference)

        return inference
    }

    private func validateInference(_ inference: ONetInference) throws {
        // Education level: 1-12
        if let edu = inference.educationLevel, !(1...12).contains(edu) {
            throw AIError.outOfRange("Education level must be 1-12, got \(edu)")
        }

        // Work activities: 1-7
        if let activities = inference.workActivities {
            for (id, importance) in activities {
                guard (1.0...7.0).contains(importance) else {
                    throw AIError.outOfRange("Work activity \(id) importance must be 1-7, got \(importance)")
                }
            }
        }

        // RIASEC adjustments: -2 to +2
        if let riasec = inference.riasecAdjustments {
            let adjustments = [riasec.realistic, riasec.investigative, riasec.artistic,
                             riasec.social, riasec.enterprising, riasec.conventional].compactMap { $0 }
            for adj in adjustments {
                guard (-2.0...2.0).contains(adj) else {
                    throw AIError.outOfRange("RIASEC adjustment must be -2 to +2, got \(adj)")
                }
            }
        }
    }
}
```

### 5.4 Cost Estimation

**Per User O*NET Profile Build** (15 questions):
- Average tokens per question: 200 input + 50 output = 250 tokens
- Total tokens: 250 × 15 = 3,750 tokens = 0.00375M tokens
- Cost (GPT-4o-mini): $0.15 per 1M input + $0.60 per 1M output = $0.00056 + $0.00045 = **$0.001 per user**

**At Scale**:
- 1,000 users: $1.00
- 10,000 users: $10.00
- 100,000 users: $100.00

**Acceptable**: AI cost is negligible compared to value of accurate O*NET profiles for Thompson Sampling.

---

## PART 6: UI/UX DESIGN

### 6.1 AI Career Discovery Card (ManifestTabView)

**Visual Design**:
```
┌─────────────────────────────────────────────────────────────┐
│ 🎯 Discover Your Career Path                                │
│                                                              │
│ Answer a few questions to help us understand your           │
│ interests, skills, and aspirations. We'll use this to       │
│ match you with careers that align with your unique profile. │
│                                                              │
│ ⏱️ Takes 5-8 minutes · 15 questions                         │
│                                                              │
│ [Start Discovery] ───────────────────────────────────> ▶    │
└─────────────────────────────────────────────────────────────┘
```

**Theming**:
- Manifest/Teal gradient background (0.528 hue)
- White text for contrast
- Rounded corners (SacredUI.cornerRadius = 12)
- Padding (SacredUI.padding = 16)

### 6.2 AI Question Flow

**Conversational UI**:
```
┌─────────────────────────────────────────────────────────────┐
│ Question 3 of 15                                 [Skip] [X] │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│ 💭 Describe a project you're most proud of.                 │
│    What made it meaningful?                                  │
│                                                              │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ I built a machine learning model to predict customer  │ │
│ │ churn. I loved analyzing the data patterns and        │ │
│ │ figuring out which features mattered most...          │ │
│ │                                                        │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                              │
│ [Previous]                                  [Next Question] │
└─────────────────────────────────────────────────────────────┘
```

**Interaction**:
- Text field with 3-5 line minimum (encourage thoughtful answers)
- "Skip" button with warning: "Skipping reduces recommendation accuracy"
- Progress bar at top (15 dots, current question highlighted)
- "Previous" button to review/edit past answers
- "Next Question" enabled after typing (no validation, just confirmation)

### 6.3 Completion Summary

**After 15 Questions**:
```
┌─────────────────────────────────────────────────────────────┐
│ ✅ Career Profile Complete!                                 │
│                                                              │
│ Based on your answers, we've identified:                    │
│                                                              │
│ 🎓 Education Level: Bachelor's Degree                       │
│ 🛠️ Top Work Activities:                                     │
│    • Analyzing Data and Information (6.5/7)                 │
│    • Thinking Creatively (5.0/7)                            │
│    • Interacting with Computers (6.0/7)                     │
│ 🧩 Personality Type: IAS (Investigative, Artistic, Social) │
│                                                              │
│ Your profile helps us recommend careers that align with     │
│ your strengths and interests.                               │
│                                                              │
│ [Explore Career Paths] ──────────────────────────────> ▶   │
└─────────────────────────────────────────────────────────────┘
```

**Transparency**:
- Show extracted O*NET profile (education, top activities, RIASEC code)
- Explain how this will be used ("recommend careers", "match jobs")
- Option to "Refine Profile" (restart discovery with 5 new questions)

### 6.4 Accessibility

**VoiceOver**:
- Question text: "Question 3 of 15. Describe a project you're most proud of. What made it meaningful? Text field."
- Progress: "Progress: 3 of 15 questions answered"
- Skip button: "Skip question. Warning: Skipping reduces recommendation accuracy."

**Dynamic Type**:
- Support .small to .XXXL (question text, answer field scale)
- Min height for text field: 120pt at .small, 200pt at .XXXL

**Contrast**:
- Teal background: #48CAE4 (luminance 0.58)
- White text: #FFFFFF (luminance 1.0)
- Contrast ratio: 1.0 / 0.58 = 1.72 ❌ FAILS WCAG AA (4.5:1)
- **FIX**: Use darker teal #0077B6 (luminance 0.20) → 1.0 / 0.20 = 5.0 ✅ PASSES

---

## PART 7: NARRATIVE ALIGNMENT

### 7.1 Why AI-Driven O*NET is Better

**Manual Approach (Phase 2)** ❌
- Feels like "filling out a form"
- User sees "O*NET" terminology (confusing, technical)
- Tedious sliders for 41 work activities
- No narrative connection to career discovery
- Low completion rate (users abandon mid-flow)

**AI-Driven Approach (Phase 3.5)** ✅
- Feels like "career conversation"
- User never sees "O*NET" (just answers natural questions)
- AI infers profile from thoughtful answers
- Strong narrative: "Tell us about yourself → We match you with careers"
- High completion rate (conversational, engaging)

### 7.2 Manifest vs Match Alignment

**O*NET in ProfileScreen (Wrong)**:
- ProfileScreen is Match/Amber (current reality, explicit skills)
- O*NET represents career aspirations (Manifest/Teal)
- Narrative misalignment: "Here's who I am today" vs "Here's where I want to go"

**O*NET in ManifestTabView (Correct)**:
- ManifestTabView is Manifest/Teal (future aspirations, career journey)
- AI discovery happens in career context
- Narrative alignment: "Where do you want to go?" → "What careers fit you?"

### 7.3 User Journey

**Old Flow** (Phase 2):
1. User opens ProfileScreen
2. Sees "O*NET Education Level" section
3. Thinks: "What's O*NET? Do I need to fill this out?"
4. Adjusts slider to Bachelor's (guesses)
5. Sees 41 work activities
6. Thinks: "This is tedious, I'll skip it"
7. O*NET profile incomplete → Thompson Sampling less accurate

**New Flow** (Phase 3.5):
1. User opens ManifestTabView (Career Journey)
2. Sees "Discover Your Career Path" card
3. Thinks: "Interesting, let's see what this is about"
4. Answers 15 conversational questions (5-8 minutes)
5. AI builds O*NET profile automatically
6. Sees completion summary: "Your profile: IAS (Investigative, Artistic, Social)"
7. Thinks: "Cool! Now show me career recommendations"
8. O*NET profile complete → Thompson Sampling highly accurate

### 7.4 Guardian Approval: app-narrative-guide

**Why This Approach Serves the Core Mission**:
> "The app's mission is helping people discover unexpected careers and confidently transition to fulfilling work."

**AI-Driven O*NET Alignment**:
1. **Discovery**: AI questions reveal hidden interests user may not consciously know
2. **Unexpected**: AI infers O*NET profile from answers, surfaces career matches user wouldn't manually search for
3. **Confidence**: Rich O*NET data powers accurate Thompson Sampling → better job recommendations → user trusts the system
4. **Fulfilling Work**: O*NET includes personality (RIASEC), work style (activities), and education fit → matches are holistic, not just skills-based

**Verdict**: ✅✅✅ STRONGLY APPROVED by app-narrative-guide

---

## PART 8: IMPLEMENTATION CHECKLIST

### Phase 3.5 Pre-Implementation Checklist

**Before Starting**:
- [ ] User approves this revised plan (AI-driven vs manual UI)
- [ ] All guardian skills review and sign off on architecture
- [ ] AI API provider selected (OpenRouter vs Anthropic vs OpenAI)
- [ ] Question database design finalized (15-20 initial questions)
- [ ] Core Data migration strategy confirmed (CareerQuestion entity)

### Task 1: Remove Manual O*NET UI (2-3 hours)
- [ ] Remove O*NET state variables from ProfileScreen.swift (lines 124-141)
- [ ] Remove O*NET cards from view hierarchy (lines 217-224)
- [ ] Remove O*NET save functions (lines 2022-2100)
- [ ] Test ProfileScreen renders correctly without O*NET sections
- [ ] Commit: "Phase 3.5 Task 1: Remove manual O*NET UI from ProfileScreen"

### Task 2: Create CareerQuestion Schema (4-6 hours)
- [ ] Create CareerQuestion+CoreData.swift with entity definition
- [ ] Add Core Data model migration (lightweight)
- [ ] Create CareerQuestionDatabase service for CRUD operations
- [ ] Write unit tests for CareerQuestion schema
- [ ] Commit: "Phase 3.5 Task 2: Add CareerQuestion Core Data entity"

### Task 3: Build AI Processing Service (8-12 hours)
- [ ] Create AICareerProfileBuilder actor in V7Services
- [ ] Implement inferONetSignals() method with AI API call
- [ ] Implement processAnswer() method to update Core Data
- [ ] Add error handling and fallback provider logic
- [ ] Create ONetInference struct for JSON parsing
- [ ] Write unit tests with mock AI responses
- [ ] Commit: "Phase 3.5 Task 3: Implement AI career profile builder service"

### Task 4: Create AI Discovery UI (6-8 hours)
- [ ] Create AICareerDiscoveryView.swift in V7Career
- [ ] Implement question flow with progress indicator
- [ ] Add text field for answers with validation
- [ ] Create completion summary screen
- [ ] Add accessibility labels and Dynamic Type support
- [ ] Commit: "Phase 3.5 Task 4: Build AI career discovery UI flow"

### Task 5: Integrate into ManifestTabView (3-4 hours)
- [ ] Add onetProfileIncomplete computed property
- [ ] Show AICareerDiscoveryCard when profile incomplete
- [ ] Hide card after completion or dismissal
- [ ] Test integration with existing career features
- [ ] Commit: "Phase 3.5 Task 5: Integrate AI discovery into ManifestTabView"

### Task 6: Seed Question Database (6-8 hours)
- [ ] Create CareerQuestionsSeed.swift with 15-20 questions
- [ ] Map questions to O*NET work activities (41 total)
- [ ] Map questions to RIASEC dimensions (6 total)
- [ ] Add education level inference questions (2-3 questions)
- [ ] Write AI processing hints for each question
- [ ] Commit: "Phase 3.5 Task 6: Seed initial career question database"

### Task 7: Test AI Pipeline (6-8 hours)
- [ ] Write AICareerProfileBuilderTests with mock AI responses
- [ ] Test education level inference from sample answers
- [ ] Test work activities extraction from sample answers
- [ ] Test RIASEC adjustments from sample answers
- [ ] Test Core Data persistence after processing
- [ ] Test error handling (API failures, invalid JSON)
- [ ] Commit: "Phase 3.5 Task 7: Add comprehensive AI pipeline tests"

### Task 8: Validate Thompson Integration (3-4 hours)
- [ ] Confirm Thompson algorithm reads AI-populated O*NET fields
- [ ] Test education matching with AI-inferred levels
- [ ] Test work activities alignment with AI-populated dictionary
- [ ] Test RIASEC personality fit with AI-adjusted dimensions
- [ ] Run performance benchmarks (<10ms per job with O*NET)
- [ ] Commit: "Phase 3.5 Task 8: Validate Thompson Sampling with AI O*NET data"

### Task 9: Guardian Skills Final Review (2-3 hours)
- [ ] v7-architecture-guardian: Review package dependencies, MV pattern
- [ ] swift-concurrency-enforcer: Review actor isolation, Sendable types
- [ ] swiftui-specialist: Review state management, view composition
- [ ] accessibility-compliance-enforcer: Review VoiceOver, Dynamic Type, contrast
- [ ] core-data-specialist: Review Core Data thread safety, migration
- [ ] app-narrative-guide: Review narrative alignment, user journey

### Post-Implementation
- [ ] Full integration test with real user flow (ManifestTabView → AI discovery → career recommendations)
- [ ] Performance validation (Thompson <10ms with AI-populated O*NET)
- [ ] Accessibility audit (VoiceOver, Dynamic Type, contrast ratios)
- [ ] User testing with 5-10 beta testers (collect feedback on question quality, AI accuracy)
- [ ] Documentation update (README, API docs, architecture diagrams)

---

## PART 9: SUCCESS METRICS

### 9.1 Technical Metrics

**Core Data Population**:
- ✅ 95%+ users have onetEducationLevel > 0 after AI discovery
- ✅ 90%+ users have ≥10 work activities rated after AI discovery
- ✅ 95%+ users have RIASEC variance > 2.0 (not all default 3.5)

**AI Inference Accuracy**:
- ✅ Education level inference matches user intent 90%+ (manual validation of 100 samples)
- ✅ Work activities alignment validated by user 85%+ (show user extracted activities, ask "Does this match?")
- ✅ RIASEC profile feels accurate to user 85%+ (show Holland Code, ask "Does this describe you?")

**Performance**:
- ✅ AI question processing <5s per question (including API call)
- ✅ Thompson Sampling <10ms per job with full O*NET profile (no performance regression)
- ✅ UI remains responsive during AI processing (async/await, proper loading states)

**Reliability**:
- ✅ AI API success rate >99% (with fallback provider)
- ✅ Zero crashes from AI processing errors (comprehensive error handling)
- ✅ Core Data save success rate 100% (rollback on failure)

### 9.2 User Experience Metrics

**Engagement**:
- ✅ AI discovery completion rate >70% (users finish all 15 questions)
- ✅ Average time to complete: 5-8 minutes
- ✅ Skip rate <20% (users answer most questions, not skip)

**Satisfaction**:
- ✅ User feedback: "Questions felt natural and relevant" (80%+ agree)
- ✅ User feedback: "Profile summary accurately describes me" (85%+ agree)
- ✅ User feedback: "Career recommendations improved after discovery" (80%+ agree)

**Narrative Alignment**:
- ✅ Users understand why they're answering questions (career matching, not just data entry)
- ✅ Users never see "O*NET" terminology (technical jargon hidden)
- ✅ Users feel discovery flow is part of career journey (Manifest/Teal), not profile setup (Match/Amber)

### 9.3 Business Impact

**Thompson Sampling Accuracy**:
- ✅ Job recommendation click-through rate increases 20%+ (with AI-populated O*NET vs empty)
- ✅ Job application rate increases 15%+ (better matches → more applications)
- ✅ User retention increases 10%+ (accurate recommendations → continued engagement)

**Cost Efficiency**:
- ✅ AI cost per user <$0.01 (15 questions × $0.001 per question)
- ✅ Cost at scale: $100 for 10,000 users (negligible vs value)

---

## PART 10: RISKS AND MITIGATIONS

### 10.1 AI Inference Accuracy Risk

**Risk**: AI extracts incorrect O*NET signals from user answers (e.g., rates "Analyzing Data" as 2/7 when answer clearly indicates 6/7).

**Likelihood**: Medium (AI parsing is non-deterministic, depends on answer quality and prompt engineering)

**Impact**: High (inaccurate O*NET → bad Thompson Sampling → poor job recommendations → user churn)

**Mitigation**:
1. **Structured Prompts**: Include explicit processing hints in prompts ("High investigative words: 'analyze', 'research'")
2. **Validation**: Show extracted profile to user after completion, allow editing
3. **Fallback Provider**: If primary AI fails, retry with higher-quality model (Claude 3.5 Sonnet)
4. **Human Review**: Manually validate 100 sample extractions before launch
5. **Iterative Improvement**: Collect user feedback ("Does this profile match you?"), refine prompts based on mismatches

### 10.2 User Engagement Risk

**Risk**: Users abandon AI discovery mid-flow (completion rate <50%).

**Likelihood**: Medium (15 questions is significant time commitment, users may get bored or distracted)

**Impact**: High (incomplete O*NET → Thompson Sampling falls back to skills-only → weaker recommendations)

**Mitigation**:
1. **Clear Value Prop**: Show "⏱️ Takes 5-8 minutes · Unlock better career matches" upfront
2. **Progress Indicator**: Show "3 of 15" with visual progress bar (encourages completion)
3. **Save Progress**: Allow users to pause and resume (save partial answers)
4. **Shorter Alternative**: Offer "Quick Discovery" (5 questions) vs "Deep Discovery" (15 questions)
5. **Gamification**: Show badge after completion ("🏆 Career Explorer")

### 10.3 AI API Cost Risk

**Risk**: AI API costs exceed budget at scale (100K users = $100, but could spike with retries).

**Likelihood**: Low (GPT-4o-mini is $0.15 per 1M tokens, very cost-effective)

**Impact**: Low (AI cost is <1% of total infrastructure cost)

**Mitigation**:
1. **Cost Monitoring**: Track AI API spend per user, alert if >$0.01
2. **Rate Limiting**: Limit AI discovery to 1x per user per 30 days (prevent abuse)
3. **Caching**: Cache AI responses for common answers (e.g., "I have a Bachelor's degree" → education level 8)
4. **Budget Provider**: Use GPT-4o-mini for most questions, reserve Claude for complex/ambiguous answers

### 10.4 Core Data Migration Risk

**Risk**: Adding CareerQuestion entity causes Core Data migration failure, app crashes on launch.

**Likelihood**: Low (CareerQuestion is new entity, no existing data to migrate)

**Impact**: Critical (app unusable if migration fails)

**Mitigation**:
1. **Lightweight Migration**: CareerQuestion is new entity, no schema changes to UserProfile
2. **Fallback**: If migration fails, app continues with manual O*NET UI (Phase 2 components remain in codebase, just hidden)
3. **Testing**: Test migration on 10 beta devices before production release
4. **Monitoring**: Add Core Data migration telemetry, alert if failures >1%

### 10.5 Performance Regression Risk

**Risk**: AI processing slows down UI, causes lag or frame drops during question flow.

**Likelihood**: Low (AI calls are async, won't block main thread)

**Impact**: Medium (laggy UI frustrates users, reduces completion rate)

**Mitigation**:
1. **Async/Await**: All AI calls use async/await, run on background actor
2. **Loading States**: Show spinner during AI processing ("Processing your answer...")
3. **Timeout**: Cap AI API calls at 10s, fail fast if provider is slow
4. **Prefetch**: Load next question while AI processes current answer (parallel execution)

---

## PART 11: FUTURE ENHANCEMENTS (Post-Phase 3.5)

### 11.1 Voice Input for Answers

**Feature**: Allow users to speak answers instead of typing (leverages Apple Speech framework).

**Value**: Faster completion, more natural conversation, accessible for users who prefer speech.

**Implementation**:
- Add microphone button to answer text field
- Use `SFSpeechRecognizer` for live transcription
- Store transcribed text in same answer field (AI processes identically)

**Effort**: 4-6 hours

### 11.2 Adaptive Question Selection

**Feature**: AI chooses next question based on previous answers (e.g., if user shows high Investigative, ask more technical questions).

**Value**: Shorter flow (only ask relevant questions), more accurate profile.

**Implementation**:
- Add `conditionalLogic` field to CareerQuestion (e.g., "Only ask if RIASEC Investigative > 4.0")
- AI analyzes answer, checks conditions, selects next question dynamically
- Reduces 15 questions → 8-10 questions for most users

**Effort**: 8-12 hours

### 11.3 Profile Refinement Over Time

**Feature**: Periodically ask 1-2 follow-up questions to update O*NET profile (e.g., every 30 days or after 100 job swipes).

**Value**: O*NET profile stays current as user's interests evolve, recommendations improve over time.

**Implementation**:
- Add `lastONetUpdate` timestamp to UserProfile
- Show 1-2 questions in ManifestTabView if >30 days since last update
- AI processes answers, adjusts O*NET fields incrementally (not full rebuild)

**Effort**: 4-6 hours

### 11.4 Explain Recommendations

**Feature**: When user sees job recommendation, show why it matched (e.g., "This job matches your Investigative personality and preference for Analyzing Data").

**Value**: Transparency builds trust, users understand how Thompson Sampling works, increases engagement.

**Implementation**:
- Thompson Sampling returns match score breakdown (education: 0.9, activities: 0.85, RIASEC: 0.8)
- UI shows "Why this job?" section with top 3 match factors
- Link to O*NET profile: "Update your profile to improve recommendations"

**Effort**: 6-8 hours

### 11.5 Career Path Simulation

**Feature**: Show user how changing O*NET profile affects career recommendations (e.g., "If you pursued a Master's degree, these careers would open up").

**Value**: Empowers users to explore "what if" scenarios, aligns with Manifest narrative (future aspirations).

**Implementation**:
- Add "Explore Scenarios" in ManifestTabView
- User adjusts education level or RIASEC dimensions via temporary sliders (doesn't save to Core Data)
- Thompson Sampling runs with hypothetical profile, shows different career matches
- User can "Apply This Profile" to save changes

**Effort**: 10-15 hours

---

## PART 12: CONCLUSION

### 12.1 Why This Plan is Better

**Previous Plan** (PHASE_3_ONET_CAREER_INTEGRATION_PLAN.md):
- Moved manual O*NET UI from ProfileScreen to ManifestTabView
- Preserved tedious sliders and pickers
- Narrative improvement (O*NET in career context), but UX still poor

**This Plan** (PHASE_3.5_AI_DRIVEN_ONET_INTEGRATION.md):
- **Removes** manual O*NET UI entirely
- **Introduces** AI-driven O*NET profile building through conversational questions
- **Aligns** with app narrative (discovery, not data entry)
- **Improves** completion rate (engaging questions vs tedious sliders)
- **Maintains** Core Data schema (AI populates same fields Thompson Sampling uses)

### 12.2 Alignment with User Requirements

**User Stated**:
> "i want this to be built into the system but then updated through the ai driven questions to assist with the future carrer path"

**This Plan Delivers**:
1. ✅ **Built into the system**: O*NET Core Data schema remains unchanged
2. ✅ **Updated through AI-driven questions**: AICareerProfileBuilder processes answers and populates O*NET fields
3. ✅ **Assist with future career path**: O*NET data powers Thompson Sampling (55% weight), Skills Gap Analysis, Career Path Visualization, and Course Recommendations

### 12.3 Next Steps

**Awaiting User Approval**:
1. Review this plan (PHASE_3.5_AI_DRIVEN_ONET_INTEGRATION.md)
2. Confirm AI-driven approach is correct vs manual UI
3. Select AI API provider (OpenRouter vs Anthropic vs OpenAI)
4. Approve question database design (15-20 initial questions)

**Upon Approval**:
1. Activate all guardian skills for architecture review
2. Begin Task 1: Remove manual O*NET UI from ProfileScreen (2-3 hours)
3. Proceed through 9 tasks sequentially (40-56 hours total)
4. Deliver Phase 3.5: AI-Driven O*NET Integration

---

**END OF PHASE 3.5 AI-DRIVEN O*NET INTEGRATION PLAN**
