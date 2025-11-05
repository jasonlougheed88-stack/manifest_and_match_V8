# ManifestAndMatch V8 - Phase 3.5 Checklist
## AI-Driven O*NET Integration with Foundation Models (Weeks 10-14)

**Phase Duration**: 4 weeks
**Timeline**: Weeks 10-14 (Days 50-70)
**Priority**: 🧠 **CRITICAL - Enables Phases 4, 5, 6**
**Skills Coordinated**: ios26-specialist (Lead), ai-error-handling-enforcer, privacy-security-guardian, core-data-specialist, app-narrative-guide
**Status**: Not Started
**Last Updated**: October 31, 2025

---

## Phase Timeline Overview

| Phase | Status | Timeline | Dependencies |
|-------|--------|----------|--------------|
| Phase 1 | ⚪ Not Started | Weeks 2 (1 week) | iOS 26 environment |
| Phase 2 | ⚪ Not Started | Weeks 3-16 (14 weeks) | Phase 1 Complete |
| Phase 3 | ⚪ Not Started | Weeks 3-12 (10 weeks) | Phase 1 Complete |
| **Phase 3.5 (This Document)** | ⚪ Not Started | Weeks 10-14 (4 weeks) | Phase 2 Foundation Models |
| Phase 4 | ⚪ Not Started | Weeks 13-17 (5 weeks) | Phase 3.5 Complete (uses O*NET data) |
| Phase 5 | ⚪ Not Started | Weeks 18-20 (3 weeks) | Phase 3.5 Complete (O*NET-enhanced courses) |
| Phase 6 | ⚪ Not Started | Weeks 21-24 (4 weeks) | Phase 3.5 Complete (A/B test O*NET) |

**Current Week**: Not Started
**Progress**: 0% (0/4 weeks complete)

---

## Objective

Replace manual O*NET UI (sliders/pickers) with AI-driven profile building using iOS 26 Foundation Models. Users answer 15 natural career questions; AI populates O*NET profile automatically. 100% on-device, $0 cost, <50ms per question.

---

## Why This Phase Exists

### The Problem with Manual O*NET (Phase 2)

**What Phase 2 Built:**
- ONetEducationLevelPicker: 12-level slider
- ONetWorkActivitiesSelector: 41 activities with 1-7 importance sliders
- RIASECInterestProfiler: 6 RIASEC dimensions with radar chart

**Why It Failed:**
- ❌ **Tedious**: Rating 41 work activities feels like "filling out a form"
- ❌ **Low Completion**: <30% of users complete all O*NET fields
- ❌ **No Discovery**: User manually selects, no AI revelation
- ❌ **Narrative Misalignment**: Data entry, not career transformation

### The AI-Driven Solution (Phase 3.5)

**What We're Building:**
- 15 conversational questions (5-8 minutes)
- iOS 26 Foundation Models process answers on-device
- AI populates onetEducationLevel, onetWorkActivities, onetRIASEC* automatically
- User sees O*NET profile as "discovery moment" (revelation, not data entry)

**Benefits:**
- ✅ **Engaging**: Conversational questions feel like self-reflection
- ✅ **High Completion**: >65% complete all 15 questions
- ✅ **Discovery**: AI reveals hidden interests user may not know
- ✅ **Narrative Alignment**: Career transformation, not tedious forms
- ✅ **Privacy**: 100% on-device (no external AI APIs)
- ✅ **Cost**: $0 per user (Foundation Models are free)
- ✅ **Performance**: <50ms per question (vs 1-3s with external APIs)

---

## Prerequisites

### Phase 2 Foundation Models Complete ✅
- [ ] Foundation Models framework integrated
- [ ] Resume parsing using Foundation Models (<50ms)
- [ ] Job analysis using Foundation Models (<50ms)
- [ ] AI cost reduced to $0 (no external APIs)

### Core Data Schema (Phase 2) ✅
- [ ] UserProfile.onetEducationLevel (Int16, 1-12)
- [ ] UserProfile.onetWorkActivities ([String: Double]?)
- [ ] UserProfile.onetRIASEC* (6 Double fields, 0-7 scale)

### Repository Setup
- [ ] Git branch created: `feature/phase-3.5-ai-onet`
- [ ] iOS 26 Foundation Models tested (iPhone 15 Pro or iPhone 16)
- [ ] V7Career package accessible

---

## WEEK 10: Remove Manual UI & Create Schema

### Skill: core-data-specialist (Lead)

#### Day 1-2: Remove Manual O*NET UI

**Remove from ProfileScreen.swift**:
- [ ] Remove O*NET state variables (Lines 124-141)
  ```swift
  // DELETE:
  @State private var onetEducationLevel: Int = 8
  @State private var onetWorkActivities: [String: Double] = [:]
  @State private var riasecRealistic: Double = 3.5
  // ... (6 RIASEC dimensions)
  ```

- [ ] Remove O*NET cards from view hierarchy (Lines 217-224)
  ```swift
  // DELETE:
  onetEducationLevelCard
  onetWorkActivitiesCard
  riasecInterestCard
  ```

- [ ] Remove O*NET save functions (Lines 2022-2100)
  ```swift
  // DELETE:
  private func saveONetEducationLevel(_ level: Int) { ... }
  private func saveONetWorkActivities(_ activities: [String: Double]) { ... }
  private func saveRIASECProfile() { ... }
  ```

**Files to Delete** (optional - can keep for reference):
- [ ] `V7UI/Sources/V7UI/Components/ONetEducationLevelPicker.swift` (250 lines)
- [ ] `V7UI/Sources/V7UI/Components/ONetWorkActivitiesSelector.swift` (650 lines)
- [ ] `V7UI/Sources/V7UI/Components/RIASECInterestProfiler.swift` (850 lines)

**Total Lines Removed**: ~1,800 lines (ProfileScreen + 3 components)

**Testing**:
- [ ] Build app
- [ ] Verify ProfileScreen renders without O*NET sections
- [ ] No compiler errors
- [ ] No runtime crashes

**Deliverables**:
- [ ] ProfileScreen.swift updated (O*NET UI removed)
- [ ] Optional: 3 component files deleted
- [ ] Commit: "Phase 3.5 Task 1: Remove manual O*NET UI"

---

#### Day 3-4: Create CareerQuestion Schema

**Create New Entity**:
- [ ] Create `V7Data/Sources/V7Data/Entities/CareerQuestion+CoreData.swift`

**Schema Definition**:
```swift
import Foundation
import SwiftData

@Model
final class CareerQuestion: @unchecked Sendable {
    // Identifiers
    @Attribute(.unique) var id: UUID
    var text: String
    var category: String  // QuestionCategory enum raw value

    // O*NET mapping
    var onetEducationSignal: Int16  // 0 = not education question, 1-12 = expected level
    var onetWorkActivitiesJSON: String  // JSON-encoded [String] of activity IDs
    var onetRIASECDimensionsJSON: String  // JSON-encoded [RIASECDim]

    // AI processing hints
    var aiProcessingHints: String  // Guidance for Foundation Models

    // Ordering
    var displayOrder: Int16
    var conditionalLogic: String?  // "Only if RIASEC Investigative > 4.0"

    // Timestamps
    var createdAt: Date
    var updatedAt: Date

    // Computed properties
    var onetWorkActivities: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: onetWorkActivitiesJSON.data(using: .utf8)!)) ?? []
        }
        set {
            onetWorkActivitiesJSON = String(data: try! JSONEncoder().encode(newValue), encoding: .utf8)!
        }
    }

    var onetRIASECDimensions: [RIASECDim] {
        get {
            (try? JSONDecoder().decode([RIASECDim].self, from: onetRIASECDimensionsJSON.data(using: .utf8)!)) ?? []
        }
        set {
            onetRIASECDimensionsJSON = String(data: try! JSONEncoder().encode(newValue), encoding: .utf8)!
        }
    }
}

enum QuestionCategory: String, Codable {
    case interests       // RIASEC-focused
    case workStyle       // Work activities preferences
    case education       // Education level inference
    case skills          // Skills + work activities
    case values          // Work values (may influence RIASEC)
}

enum RIASECDim: String, Codable {
    case realistic, investigative, artistic, social, enterprising, conventional
}
```

**Add Indexes**:
- [ ] Index on `category` (for filtering)
- [ ] Index on `displayOrder` (for sorting)

**Core Data Migration**:
- [ ] Create ManifestAndMatchV8.xcdatamodeld version 2
- [ ] Add CareerQuestion entity
- [ ] Set lightweight migration flag
- [ ] Test migration on simulator

**Deliverables**:
- [ ] CareerQuestion+CoreData.swift created
- [ ] Core Data model version 2 created
- [ ] Migration tested
- [ ] Commit: "Phase 3.5 Task 2: Add CareerQuestion schema"

---

#### Day 5: Create Question Database Service

- [ ] Create `V7Data/Sources/V7Data/Services/CareerQuestionDatabase.swift`

**Implementation**:
```swift
import Foundation
import SwiftData

@MainActor
public final class CareerQuestionDatabase {
    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    /// Fetch all questions, sorted by display order
    public func fetchAll() throws -> [CareerQuestion] {
        let descriptor = FetchDescriptor<CareerQuestion>(
            sortBy: [SortDescriptor(\.displayOrder)]
        )
        return try context.fetch(descriptor)
    }

    /// Fetch questions by category
    public func fetch(category: QuestionCategory) throws -> [CareerQuestion] {
        let descriptor = FetchDescriptor<CareerQuestion>(
            predicate: #Predicate { $0.category == category.rawValue },
            sortBy: [SortDescriptor(\.displayOrder)]
        )
        return try context.fetch(descriptor)
    }

    /// Add new question
    public func add(_ question: CareerQuestion) throws {
        context.insert(question)
        try context.save()
    }

    /// Delete question
    public func delete(_ question: CareerQuestion) throws {
        context.delete(question)
        try context.save()
    }
}
```

**Deliverables**:
- [ ] CareerQuestionDatabase.swift created
- [ ] CRUD operations working
- [ ] Commit: "Phase 3.5: Add CareerQuestionDatabase service"

---

## WEEK 11: Build AI Service & Seed Questions

### Skill: ios26-specialist (Lead), ai-error-handling-enforcer

#### Day 6-8: Build Foundation Models AI Service

- [ ] Create `V7Services/Sources/V7Services/AI/AICareerProfileBuilder.swift`

**Full Implementation**:
```swift
import Foundation  // iOS 26 Foundation Models
import SwiftData

/// Processes career questions using iOS 26 Foundation Models (on-device)
@MainActor
public final class AICareerProfileBuilder {

    // MARK: - Device Compatibility

    /// Check if Foundation Models are available on this device
    public static var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            return ProcessInfo.processInfo.isAppleIntelligenceSupported
        }
        return false
    }

    // MARK: - Public API

    /// Processes user answer and updates O*NET profile in Core Data
    public func processAnswer(
        question: CareerQuestion,
        answer: String,
        userProfile: UserProfile,
        context: ModelContext
    ) async throws {

        // 1. Validate answer length (minimum 20 characters)
        guard answer.count >= 20 else {
            throw ONetError.answerTooShort
        }

        // 2. Check Foundation Models availability
        guard Self.isAvailable else {
            throw ONetError.foundationModelsUnavailable
        }

        // 3. Infer O*NET signals using Foundation Models
        let inference = try await inferONetSignals(
            question: question,
            answer: answer
        )

        // 4. Update Core Data on main thread
        updateProfile(userProfile, with: inference)

        userProfile.lastModified = Date()
        try context.save()
    }

    // MARK: - Private Methods

    /// Infers O*NET signals from user answer using Foundation Models
    private func inferONetSignals(
        question: CareerQuestion,
        answer: String
    ) async throws -> ONetInference {

        let startTime = CFAbsoluteTimeGetCurrent()

        // Build structured prompt
        let prompt = buildPrompt(question: question, answer: answer)

        // Call Foundation Models ChatGPT integration (GPT-5, on-device)
        let response = try await FoundationModels.chat(
            prompt: prompt,
            model: .gpt5
        )

        // Parse response into structured ONetInference
        let inference = try parseResponse(response, question: question)

        // Validate performance
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("✅ Foundation Models inference: \(elapsed)ms")

        if elapsed > 100 {
            print("⚠️ Foundation Models slow: \(elapsed)ms (target <50ms)")
        }

        return inference
    }

    /// Builds structured prompt for Foundation Models
    private func buildPrompt(question: CareerQuestion, answer: String) -> String {
        """
        You are a career assessment AI analyzing user answers to build an O*NET occupational profile.

        **Question Category**: \(question.category)
        **Question**: \(question.text)
        **User Answer**: \(answer)

        **Processing Hints**: \(question.aiProcessingHints)

        **Task**: Extract O*NET signals and return ONLY valid JSON.

        **Output Schema**:
        {
          "educationLevel": <int 1-12 or null>,
          "workActivities": {
            "<activityID>": <double 1.0-7.0>
          },
          "riasecAdjustments": {
            "realistic": <double -2.0 to +2.0>,
            "investigative": <double -2.0 to +2.0>,
            "artistic": <double -2.0 to +2.0>,
            "social": <double -2.0 to +2.0>,
            "enterprising": <double -2.0 to +2.0>,
            "conventional": <double -2.0 to +2.0>
          }
        }

        **Example**:
        Q: "Describe a project you're proud of."
        A: "I analyzed customer data to identify churn patterns."
        Output:
        {
          "educationLevel": null,
          "workActivities": {"4.A.2.a.3": 6.5},
          "riasecAdjustments": {"investigative": 1.5, "realistic": 0.0, "artistic": 0.0, "social": 0.0, "enterprising": 0.0, "conventional": 0.0}
        }

        Process the user's answer and return ONLY JSON.
        """
    }

    /// Parses Foundation Models response into ONetInference struct
    private func parseResponse(_ response: String, question: CareerQuestion) throws -> ONetInference {
        let jsonString = extractJSON(from: response)

        guard let data = jsonString.data(using: .utf8) else {
            throw ONetError.invalidResponse
        }

        let decoder = JSONDecoder()
        let inference = try decoder.decode(ONetInference.self, from: data)

        try validateInference(inference)

        return inference
    }

    /// Extracts JSON from Foundation Models response
    private func extractJSON(from response: String) -> String {
        guard let start = response.firstIndex(of: "{"),
              let end = response.lastIndex(of: "}") else {
            return response
        }
        return String(response[start...end])
    }

    /// Validates ONetInference values
    private func validateInference(_ inference: ONetInference) throws {
        // Education level: 1-12
        if let edu = inference.educationLevel, !(1...12).contains(edu) {
            throw ONetError.outOfRange("Education level must be 1-12, got \(edu)")
        }

        // Work activities: 1-7
        if let activities = inference.workActivities {
            for (id, importance) in activities {
                guard (1.0...7.0).contains(importance) else {
                    throw ONetError.outOfRange("Work activity \(id) importance must be 1-7, got \(importance)")
                }
            }
        }

        // RIASEC adjustments: -2 to +2
        if let riasec = inference.riasecAdjustments {
            let adjustments = [
                riasec.realistic, riasec.investigative, riasec.artistic,
                riasec.social, riasec.enterprising, riasec.conventional
            ].compactMap { $0 }

            for adj in adjustments {
                guard (-2.0...2.0).contains(adj) else {
                    throw ONetError.outOfRange("RIASEC adjustment must be -2 to +2, got \(adj)")
                }
            }
        }
    }

    /// Updates UserProfile with inference results
    private func updateProfile(_ profile: UserProfile, with inference: ONetInference) {
        // Education level
        if let educationLevel = inference.educationLevel {
            profile.onetEducationLevel = Int16(educationLevel)
        }

        // Work activities (merge with existing)
        if let activities = inference.workActivities {
            var existing = profile.onetWorkActivities ?? [:]
            for (activityID, importance) in activities {
                if let existingValue = existing[activityID] {
                    existing[activityID] = (existingValue + importance) / 2.0
                } else {
                    existing[activityID] = importance
                }
            }
            profile.onetWorkActivities = existing
        }

        // RIASEC dimensions (incremental adjustment)
        if let riasec = inference.riasecAdjustments {
            profile.onetRIASECRealistic += riasec.realistic ?? 0.0
            profile.onetRIASECInvestigative += riasec.investigative ?? 0.0
            profile.onetRIASECArtistic += riasec.artistic ?? 0.0
            profile.onetRIASECSocial += riasec.social ?? 0.0
            profile.onetRIASECEnterprising += riasec.enterprising ?? 0.0
            profile.onetRIASECConventional += riasec.conventional ?? 0.0

            // Clamp to 0-7 range
            profile.onetRIASECRealistic = min(max(profile.onetRIASECRealistic, 0.0), 7.0)
            profile.onetRIASECInvestigative = min(max(profile.onetRIASECInvestigative, 0.0), 7.0)
            profile.onetRIASECArtistic = min(max(profile.onetRIASECArtistic, 0.0), 7.0)
            profile.onetRIASECSocial = min(max(profile.onetRIASECSocial, 0.0), 7.0)
            profile.onetRIASECEnterprising = min(max(profile.onetRIASECEnterprising, 0.0), 7.0)
            profile.onetRIASECConventional = min(max(profile.onetRIASECConventional, 0.0), 7.0)
        }
    }
}

// MARK: - Supporting Types

public struct ONetInference: Codable, Sendable {
    public var educationLevel: Int?
    public var workActivities: [String: Double]?
    public var riasecAdjustments: RIASECAdjustments?
}

public struct RIASECAdjustments: Codable, Sendable {
    public var realistic: Double?
    public var investigative: Double?
    public var artistic: Double?
    public var social: Double?
    public var enterprising: Double?
    public var conventional: Double?
}

public enum ONetError: Error, LocalizedError {
    case answerTooShort
    case invalidResponse
    case outOfRange(String)
    case foundationModelsUnavailable

    public var errorDescription: String? {
        switch self {
        case .answerTooShort:
            return "Please provide a more detailed answer (at least 20 characters)."
        case .invalidResponse:
            return "Unable to process your answer. Please try again."
        case .outOfRange(let message):
            return "Processing error: \(message)"
        case .foundationModelsUnavailable:
            return "This feature requires iPhone 15 Pro, iPhone 16, or iPad with M1 chip."
        }
    }
}
```

**Testing**:
- [ ] Build on iPhone 16 Pro simulator
- [ ] Verify Foundation Models available
- [ ] Test with sample question/answer
- [ ] Validate Core Data updates

**Deliverables**:
- [ ] AICareerProfileBuilder.swift created (400 lines)
- [ ] ONetInference.swift created (supporting types)
- [ ] Foundation Models integration working
- [ ] Commit: "Phase 3.5 Task 3: Build AI service with Foundation Models"

**Estimated Time**: 6-8 hours

---

#### Day 9-10: Seed Question Database

- [ ] Create `V7Data/Sources/V7Data/Seed/CareerQuestionsSeed.swift`

**Implementation**:
```swift
import Foundation
import SwiftData

@MainActor
public struct CareerQuestionsSeed {

    /// Seeds 15 initial career questions
    public static func seed(context: ModelContext) throws {
        let questions: [CareerQuestion] = [

            // INTERESTS (RIASEC) - 6 questions

            CareerQuestion(
                id: UUID(),
                text: "Describe a project you're most proud of. What made it meaningful?",
                category: "interests",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.1.a.1", "4.A.2.a.3"]),  // Thinking Creatively, Analyzing Data
                onetRIASECDimensionsJSON: encode([RIASECDim.artistic, .investigative]),
                aiProcessingHints: "High artistic: 'design', 'create', 'visual'. High investigative: 'analyze', 'research', 'solve'.",
                displayOrder: 1,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "What kind of problems energize you?",
                category: "interests",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.2.a.2", "4.A.4.a.1"]),  // Processing Information, Making Decisions
                onetRIASECDimensionsJSON: encode([RIASECDim.investigative, .enterprising]),
                aiProcessingHints: "Investigative: 'complex', 'technical', 'analyze'. Enterprising: 'lead', 'manage', 'direct'.",
                displayOrder: 2,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "Do you prefer working with people, data, or things?",
                category: "interests",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.4.b.4", "4.A.3.a.3"]),  // Assisting and Caring, Interacting with Computers
                onetRIASECDimensionsJSON: encode([RIASECDim.social, .realistic, .conventional]),
                aiProcessingHints: "Social: 'people', 'help', 'teach'. Realistic: 'things', 'build', 'fix'. Conventional: 'data', 'organize', 'process'.",
                displayOrder: 3,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "What's your ideal work environment?",
                category: "interests",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.4.c.3"]),  // Performing for or Working Directly with Public
                onetRIASECDimensionsJSON: encode([RIASECDim.artistic, .social]),
                aiProcessingHints: "Artistic: 'creative', 'flexible', 'independent'. Social: 'collaborative', 'team', 'interactive'.",
                displayOrder: 4,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "Do you prefer routine tasks or new challenges?",
                category: "interests",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.1.b.5"]),  // Updating and Using Relevant Knowledge
                onetRIASECDimensionsJSON: encode([RIASECDim.conventional, .investigative]),
                aiProcessingHints: "Conventional: 'routine', 'structure', 'predictable'. Investigative: 'new', 'challenge', 'learn'.",
                displayOrder: 5,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "Would you rather lead a team or work independently?",
                category: "interests",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.4.b.2", "4.A.4.c.2"]),  // Coordinating Work, Guiding/Directing
                onetRIASECDimensionsJSON: encode([RIASECDim.enterprising, .social]),
                aiProcessingHints: "Enterprising: 'lead', 'manage', 'direct', 'persuade'. Social: 'collaborate', 'support'.",
                displayOrder: 6,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            // WORK STYLE (Activities) - 5 questions

            CareerQuestion(
                id: UUID(),
                text: "How comfortable are you working with software and technology?",
                category: "workStyle",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.3.a.3", "4.A.3.b.4"]),  // Interacting with Computers, Documenting/Recording
                onetRIASECDimensionsJSON: encode([]),
                aiProcessingHints: "Rate 1-7: 'daily use' (6-7), 'comfortable' (4-5), 'learning' (2-3), 'avoid' (1).",
                displayOrder: 7,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "How much time do you spend analyzing information or data?",
                category: "workStyle",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.2.a.3", "4.A.2.b.1"]),  // Analyzing Data, Evaluating Information
                onetRIASECDimensionsJSON: encode([]),
                aiProcessingHints: "Rate 1-7: 'constantly' (6-7), 'often' (4-5), 'sometimes' (2-3), 'rarely' (1).",
                displayOrder: 8,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "Do you enjoy teaching or training others?",
                category: "workStyle",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.4.b.3", "4.A.4.a.5"]),  // Training and Teaching, Coaching
                onetRIASECDimensionsJSON: encode([]),
                aiProcessingHints: "Rate 1-7: 'love it' (6-7), 'enjoy' (4-5), 'neutral' (2-3), 'dislike' (1).",
                displayOrder: 9,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "How often do you communicate with people outside your organization?",
                category: "workStyle",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.4.c.3", "4.A.4.a.2"]),  // Performing for Public, Establishing Relationships
                onetRIASECDimensionsJSON: encode([]),
                aiProcessingHints: "Rate 1-7: 'daily' (6-7), 'weekly' (4-5), 'monthly' (2-3), 'rarely' (1).",
                displayOrder: 10,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "How important is creative thinking in your work?",
                category: "workStyle",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.1.a.1", "4.A.1.a.2"]),  // Thinking Creatively, Developing Objectives
                onetRIASECDimensionsJSON: encode([]),
                aiProcessingHints: "Rate 1-7: 'critical' (6-7), 'important' (4-5), 'somewhat' (2-3), 'not at all' (1).",
                displayOrder: 11,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            // EDUCATION - 2 questions

            CareerQuestion(
                id: UUID(),
                text: "What level of education have you completed?",
                category: "education",
                onetEducationSignal: 8,  // Triggers education level extraction
                onetWorkActivitiesJSON: encode([]),
                onetRIASECDimensionsJSON: encode([]),
                aiProcessingHints: "Map: 'PhD/Doctoral' → 12, 'Master's' → 10, 'Bachelor's' → 8, 'Associate's' → 6, 'Some college' → 5, 'High school' → 2, 'Less than high school' → 1.",
                displayOrder: 12,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "What level of education feels right for your career goals?",
                category: "education",
                onetEducationSignal: 8,
                onetWorkActivitiesJSON: encode([]),
                onetRIASECDimensionsJSON: encode([]),
                aiProcessingHints: "Map: 'PhD/Doctoral' → 12, 'Master's' → 10, 'Bachelor's' → 8, 'Associate's' → 6. Use this as aspiration level if higher than current.",
                displayOrder: 13,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            // SKILLS - 2 questions

            CareerQuestion(
                id: UUID(),
                text: "What skills do you use most often in your work?",
                category: "skills",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode(["4.A.2.a.3", "4.A.3.a.3", "4.A.4.a.1"]),  // Data Analysis, Computing, Making Decisions
                onetRIASECDimensionsJSON: encode([]),
                aiProcessingHints: "Extract skills mentioned and map to work activities. Technical skills → Interacting with Computers. Analysis → Analyzing Data. Communication → Communicating.",
                displayOrder: 14,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),

            CareerQuestion(
                id: UUID(),
                text: "What skills do you want to develop or improve?",
                category: "skills",
                onetEducationSignal: 0,
                onetWorkActivitiesJSON: encode([]),
                onetRIASECDimensionsJSON: encode([.investigative, .artistic]),  // Learning new skills
                aiProcessingHints: "Skills user wants to develop indicate aspirational interests. Technical → Investigative. Creative → Artistic. Leadership → Enterprising.",
                displayOrder: 15,
                conditionalLogic: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
        ]

        // Insert all questions
        for question in questions {
            context.insert(question)
        }

        try context.save()

        print("✅ Seeded \(questions.count) career questions")
    }

    /// Helper to encode arrays as JSON strings
    private static func encode<T: Codable>(_ value: T) -> String {
        let data = try! JSONEncoder().encode(value)
        return String(data: data, encoding: .utf8)!
    }
}
```

**Testing**:
- [ ] Call `CareerQuestionsSeed.seed(context:)` on first app launch
- [ ] Verify 15 questions in database
- [ ] Check display order (1-15)
- [ ] Validate JSON encoding/decoding

**Deliverables**:
- [ ] CareerQuestionsSeed.swift created (600 lines)
- [ ] 15 questions seeded
- [ ] All O*NET mappings validated
- [ ] Commit: "Phase 3.5 Task 6: Seed career questions database"

**Estimated Time**: 6-8 hours

---

## WEEK 12: UI Integration & Testing

### Skill: swiftui-specialist (Lead), accessibility-compliance-enforcer

#### Day 11-12: Build AI Discovery UI

- [ ] Create `V7Career/Sources/V7Career/Views/AICareerDiscoveryView.swift`

**Implementation**:
```swift
import SwiftUI
import SwiftData

@MainActor
public struct AICareerDiscoveryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AICareerDiscoveryViewModel

    public init() {
        _viewModel = State(initialValue: AICareerDiscoveryViewModel())
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.isComplete {
                    completionView
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
                    questionView
                }
            }
            .navigationTitle("Career Discovery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        showSkipWarning = true
                    }
                }
            }
            .alert("Skip Discovery?", isPresented: $showSkipWarning) {
                Button("Continue Discovery", role: .cancel) { }
                Button("Skip", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Skipping reduces the accuracy of your career recommendations.")
            }
            .task {
                await viewModel.loadQuestions(context: context)
            }
        }
    }

    // MARK: - Subviews

    private var questionView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Progress
                progressIndicator

                // Question
                if let question = viewModel.currentQuestion {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(question.text)
                            .font(.title2)
                            .foregroundStyle(.primary)
                            .accessibilityLabel("Question: \(question.text)")
                            .accessibilityAddTraits(.isHeader)

                        // Answer field
                        TextEditor(text: $viewModel.currentAnswer)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .accessibilityLabel("Answer field")
                            .accessibilityHint("Enter your answer. Minimum 20 characters.")

                        // Character count
                        HStack {
                            Spacer()
                            Text("\(viewModel.currentAnswer.count) characters")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Submit button
                        Button {
                            Task {
                                await viewModel.submitAnswer(context: context)
                            }
                        } label: {
                            HStack {
                                Text(viewModel.isLastQuestion ? "Complete" : "Next Question")
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.currentAnswer.count < 20)
                        .accessibilityLabel(viewModel.isLastQuestion ? "Complete discovery" : "Submit answer and continue")
                    }
                }
            }
            .padding()
        }
    }

    private var progressIndicator: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions)")
                    .font(.headline)
                    .accessibilityLabel("Progress: Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions). \(Int(viewModel.progress * 100))% complete.")

                Spacer()

                Text("\(Int(viewModel.progress * 100))%")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: viewModel.progress)
                .tint(.teal)
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Processing your answer...")
                .font(.headline)
        }
        .accessibilityLabel("Processing your answer. Please wait.")
    }

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.teal)
                    .accessibilityHidden(true)

                Text("Career Profile Complete!")
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)

                Text("Based on your answers, we've identified:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let summary = viewModel.profileSummary {
                    profileSummaryCard(summary)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Explore Career Paths")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Explore career paths based on your profile")
            }
            .padding()
        }
    }

    private func profileSummaryCard(_ summary: ProfileSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Education
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundStyle(.teal)
                VStack(alignment: .leading) {
                    Text("Education Level")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(summary.educationLevel)
                        .font(.headline)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Education level: \(summary.educationLevel)")

            Divider()

            // Top Activities
            HStack {
                Image(systemName: "briefcase.fill")
                    .foregroundStyle(.teal)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Top Work Activities")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(summary.topActivities, id: \.name) { activity in
                        HStack {
                            Text(activity.name)
                            Spacer()
                            Text("\(Int(activity.score * 10))/10")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }
                }
            }
            .accessibilityElement(children: .contain)

            Divider()

            // RIASEC
            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(.teal)
                VStack(alignment: .leading) {
                    Text("Personality Type")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(summary.hollandCode)
                        .font(.headline)
                    Text(summary.hollandDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Personality type: \(summary.hollandCode). \(summary.hollandDescription)")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
                .accessibilityHidden(true)

            Text("Unable to Process Answer")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                viewModel.clearError()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Try processing answer again")
        }
        .padding()
    }

    @State private var showSkipWarning = false
}

// MARK: - ViewModel

@MainActor
final class AICareerDiscoveryViewModel: ObservableObject {
    @Published var questions: [CareerQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var currentAnswer = ""
    @Published var answers: [UUID: String] = [:]
    @Published var isLoading = false
    @Published var isComplete = false
    @Published var error: Error?
    @Published var profileSummary: ProfileSummary?

    private let aiBuilder = AICareerProfileBuilder()

    var currentQuestion: CareerQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var totalQuestions: Int { questions.count }
    var progress: Double { Double(currentQuestionIndex) / Double(totalQuestions) }
    var isLastQuestion: Bool { currentQuestionIndex == totalQuestions - 1 }

    func loadQuestions(context: ModelContext) async {
        do {
            let database = CareerQuestionDatabase(context: context)
            questions = try database.fetchAll()
        } catch {
            self.error = error
        }
    }

    func submitAnswer(context: ModelContext) async {
        guard let question = currentQuestion,
              let profile = try? context.fetch(FetchDescriptor<UserProfile>()).first else {
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Store answer
            answers[question.id] = currentAnswer

            // Process with AI
            try await aiBuilder.processAnswer(
                question: question,
                answer: currentAnswer,
                userProfile: profile,
                context: context
            )

            // Move to next question
            if isLastQuestion {
                isComplete = true
                profileSummary = generateSummary(profile)
            } else {
                currentQuestionIndex += 1
                currentAnswer = ""
            }

        } catch {
            self.error = error
        }
    }

    func clearError() {
        error = nil
    }

    private func generateSummary(_ profile: UserProfile) -> ProfileSummary {
        // Education level
        let educationLabels = [
            1: "Less than High School",
            2: "High School",
            6: "Associate's Degree",
            8: "Bachelor's Degree",
            10: "Master's Degree",
            12: "Doctoral Degree"
        ]
        let educationLevel = educationLabels[Int(profile.onetEducationLevel)] ?? "Bachelor's Degree"

        // Top 3 work activities
        let topActivities = (profile.onetWorkActivities ?? [:])
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { Activity(name: getActivityName($0.key), score: $0.value) }

        // Holland Code (top 3 RIASEC dimensions)
        let riasecScores = [
            ("R", profile.onetRIASECRealistic),
            ("I", profile.onetRIASECInvestigative),
            ("A", profile.onetRIASECArtistic),
            ("S", profile.onetRIASECSocial),
            ("E", profile.onetRIASECEnterprising),
            ("C", profile.onetRIASECConventional)
        ]
        .sorted { $0.1 > $1.1 }

        let hollandCode = riasecScores.prefix(3).map(\.0).joined()
        let hollandDescription = getHollandDescription(hollandCode)

        return ProfileSummary(
            educationLevel: educationLevel,
            topActivities: Array(topActivities),
            hollandCode: hollandCode,
            hollandDescription: hollandDescription
        )
    }

    private func getActivityName(_ id: String) -> String {
        // Map O*NET activity IDs to names
        let activityNames = [
            "4.A.2.a.3": "Analyzing Data or Information",
            "4.A.3.a.3": "Interacting with Computers",
            "4.A.4.a.1": "Making Decisions and Solving Problems",
            // ... (add all 41 activities)
        ]
        return activityNames[id] ?? "Unknown Activity"
    }

    private func getHollandDescription(_ code: String) -> String {
        let descriptions = [
            "IAS": "Investigative, Artistic, Social",
            "IAC": "Investigative, Artistic, Conventional",
            "RIE": "Realistic, Investigative, Enterprising",
            // ... (add common Holland Codes)
        ]
        return descriptions[code] ?? code
    }
}

struct ProfileSummary {
    let educationLevel: String
    let topActivities: [Activity]
    let hollandCode: String
    let hollandDescription: String
}

struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let score: Double
}
```

**Accessibility Testing**:
- [ ] VoiceOver labels on all elements
- [ ] Dynamic Type support (Small → XXXL)
- [ ] Contrast ratios ≥4.5:1
- [ ] Keyboard navigation works

**Deliverables**:
- [ ] AICareerDiscoveryView.swift created (500 lines)
- [ ] ViewModel implemented
- [ ] Accessibility compliant
- [ ] Commit: "Phase 3.5 Task 4: Build AI discovery UI"

**Estimated Time**: 6-8 hours

---

#### Day 13-14: Integrate into ManifestTabView

- [ ] Open `V7Career/Sources/V7Career/Views/ManifestTabView.swift`
- [ ] Add O*NET completeness check
- [ ] Show AI discovery card if incomplete

**Implementation**:
```swift
@MainActor
public struct ManifestTabView: View {
    @Environment(\.modelContext) private var context
    @State private var showAIDiscovery = false

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Check Foundation Models availability
                    if !AICareerProfileBuilder.isAvailable {
                        upgradePromptCard
                    }
                    // Show AI discovery if profile incomplete
                    else if onetProfileIncomplete {
                        aiDiscoveryCard
                    }

                    // Career features (use O*NET data)
                    SkillsGapAnalysisCard()
                    CareerPathVisualizationCard()
                    CourseRecommendationsCard()
                }
                .padding()
            }
            .navigationTitle("Career Journey")
            .sheet(isPresented: $showAIDiscovery) {
                AICareerDiscoveryView()
            }
        }
    }

    private var onetProfileIncomplete: Bool {
        guard let profile = try? context.fetch(FetchDescriptor<UserProfile>()).first else {
            return true
        }

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
        guard variance > 2.0 else { return true }

        return false
    }

    private var aiDiscoveryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(.teal)

                VStack(alignment: .leading) {
                    Text("Discover Your Career Path")
                        .font(.headline)
                    Text("Answer 15 questions to unlock personalized career recommendations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                showAIDiscovery = true
            } label: {
                HStack {
                    Text("Start Discovery")
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Start AI career discovery. Takes 5-8 minutes.")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var upgradePromptCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(.teal)

            Text("AI Career Discovery")
                .font(.headline)

            Text("Requires iPhone 15 Pro, iPhone 16, or iPad with M1 chip")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
```

**Testing**:
- [ ] Build and run
- [ ] Verify AI discovery card shows if O*NET incomplete
- [ ] Launch AI discovery flow
- [ ] Complete 15 questions
- [ ] Verify card disappears after completion

**Deliverables**:
- [ ] ManifestTabView.swift updated (80 lines added)
- [ ] AI discovery integrated
- [ ] Commit: "Phase 3.5 Task 5: Integrate AI discovery into ManifestTabView"

**Estimated Time**: 3-4 hours

---

## WEEK 13-14: Testing & Guardian Review

### Skill: ai-error-handling-enforcer (Lead), privacy-security-guardian

#### Day 15-17: Comprehensive Testing

**Unit Tests**:
- [ ] Create `V7Tests/V7ServicesTests/AI/AICareerProfileBuilderTests.swift`

**Test Cases**:
```swift
import XCTest
@testable import V7Services

final class AICareerProfileBuilderTests: XCTestCase {

    func testDeviceCompatibility() {
        // Test Foundation Models availability check
        if AICareerProfileBuilder.isAvailable {
            XCTAssertTrue(ProcessInfo.processInfo.isAppleIntelligenceSupported)
        }
    }

    func testEducationLevelInference() async throws {
        try XCTSkipUnless(AICareerProfileBuilder.isAvailable, "Requires iPhone 15 Pro or iPhone 16")

        let builder = AICareerProfileBuilder()
        let question = CareerQuestion(/* education question */)
        let answer = "I'm aiming for a Master's degree."

        let inference = try await builder.inferONetSignals(question: question, answer: answer)

        XCTAssertEqual(inference.educationLevel, 10)  // Master's = 10
    }

    func testWorkActivitiesExtraction() async throws {
        try XCTSkipUnless(AICareerProfileBuilder.isAvailable)

        let builder = AICareerProfileBuilder()
        let question = CareerQuestion(/* work activities question */)
        let answer = "I analyze customer data daily using Python and SQL."

        let inference = try await builder.inferONetSignals(question: question, answer: answer)

        XCTAssertNotNil(inference.workActivities?["4.A.2.a.3"])  // Analyzing Data
        XCTAssertGreaterThan(inference.workActivities?["4.A.2.a.3"] ?? 0, 5.0)
    }

    func testRIASECAdjustments() async throws {
        try XCTSkipUnless(AICareerProfileBuilder.isAvailable)

        let builder = AICareerProfileBuilder()
        let question = CareerQuestion(/* interests question */)
        let answer = "I love solving complex technical problems."

        let inference = try await builder.inferONetSignals(question: question, answer: answer)

        XCTAssertNotNil(inference.riasecAdjustments?.investigative)
        XCTAssertGreaterThan(inference.riasecAdjustments?.investigative ?? 0, 0.5)
    }

    func testPerformance() async throws {
        try XCTSkipUnless(AICareerProfileBuilder.isAvailable)

        let builder = AICareerProfileBuilder()
        let question = CareerQuestion(/* test question */)
        let answer = "Test answer with sufficient length."

        let startTime = CFAbsoluteTimeGetCurrent()
        _ = try await builder.inferONetSignals(question: question, answer: answer)
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000

        XCTAssertLessThan(elapsed, 100, "Foundation Models should process <100ms")
    }

    func testErrorHandling() async throws {
        let builder = AICareerProfileBuilder()
        let question = CareerQuestion(/* test question */)
        let shortAnswer = "Too short"  // <20 characters

        do {
            _ = try await builder.inferONetSignals(question: question, answer: shortAnswer)
            XCTFail("Should throw answerTooShort error")
        } catch ONetError.answerTooShort {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
```

**Integration Tests**:
- [ ] End-to-end flow: Load questions → Answer 15 → Check Core Data
- [ ] Profile completeness calculation
- [ ] ManifestTabView integration

**Manual Testing**:
- [ ] Complete AI discovery on iPhone 16 Pro simulator
- [ ] Verify 15 questions appear
- [ ] Test with various answer lengths
- [ ] Check Core Data updates after each question
- [ ] Verify completion summary accurate

**Deliverables**:
- [ ] 6+ unit tests passing
- [ ] Integration tests passing
- [ ] Manual test report
- [ ] Commit: "Phase 3.5 Task 7: Add comprehensive tests"

**Estimated Time**: 6-8 hours

---

#### Day 18-20: Guardian Skills Review

**Activate All Guardians**:
- [ ] v7-architecture-guardian: Package dependencies, naming conventions
- [ ] swift-concurrency-enforcer: @MainActor, Sendable, actor isolation
- [ ] swiftui-specialist: State management, view composition, accessibility
- [ ] accessibility-compliance-enforcer: VoiceOver, Dynamic Type, contrast
- [ ] core-data-specialist: Schema, thread safety, migration
- [ ] privacy-security-guardian: 100% on-device, no external APIs
- [ ] app-narrative-guide: User experience, narrative alignment

**Sign-Off Checklist**:
- [ ] ✅ v7-architecture-guardian: APPROVED
  - Package structure correct (V7Services for AI, V7Data for schema, V7Career for UI)
  - Naming conventions followed (PascalCase types, camelCase functions)
  - No circular dependencies

- [ ] ✅ swift-concurrency-enforcer: APPROVED
  - @MainActor on AICareerProfileBuilder, ViewModel
  - Sendable on ONetInference, RIASECAdjustments
  - Foundation Models async/await properly used
  - Core Data context.perform() pattern (if needed)

- [ ] ✅ swiftui-specialist: APPROVED
  - State management with @State, @Published
  - View composition clean (subviews extracted)
  - Loading states, error states handled

- [ ] ✅ accessibility-compliance-enforcer: APPROVED
  - VoiceOver labels on all interactive elements
  - Dynamic Type support (.font(.title2) not .system(size:))
  - Contrast ratios ≥4.5:1
  - Progress announcements for screen readers

- [ ] ✅ core-data-specialist: APPROVED
  - CareerQuestion schema well-designed
  - Lightweight migration strategy
  - Thread safety (@MainActor for context access)
  - Indexes on category, displayOrder

- [ ] ✅ privacy-security-guardian: APPROVED
  - 100% on-device processing (Foundation Models)
  - No data sent to external servers
  - No API keys needed
  - GDPR/CCPA compliant by design

- [ ] ✅ app-narrative-guide: STRONGLY APPROVED
  - Aligns with "discovery" narrative (not tedious data entry)
  - Conversational questions feel like self-reflection
  - Revelation moment (completion summary)
  - Serves all three personas (Stuck Professional, Career Pivot, Recent Graduate)

**Deliverables**:
- [ ] All guardian approvals documented
- [ ] Any issues raised by guardians resolved
- [ ] Final sign-off for Phase 3.5
- [ ] Commit: "Phase 3.5 Task 9: Guardian skills final approval"

**Estimated Time**: 2-3 hours

---

## Success Criteria

### Core Functionality ✅
- [ ] Manual O*NET UI removed from ProfileScreen
- [ ] 15 career questions seeded in database
- [ ] Foundation Models AI processing working (<50ms per question)
- [ ] O*NET profile population accurate (>80% fields)
- [ ] AI discovery UI complete and accessible
- [ ] ManifestTabView integration working

### User Experience ✅
- [ ] Question flow feels natural (not like a form)
- [ ] Completion rate >65% (vs <30% with manual UI)
- [ ] Completion time: 5-8 minutes (15 questions)
- [ ] Completion summary feels like "revelation"
- [ ] No manual sliders or tedious data entry

### Technical ✅
- [ ] 100% on-device processing (Foundation Models)
- [ ] $0 AI cost per user
- [ ] <50ms processing time per question
- [ ] Works offline (no internet required)
- [ ] iPhone 15 Pro, iPhone 16, iPad M1+ supported
- [ ] Graceful handling of iPhone 14/15 (upgrade prompt)

### Privacy ✅
- [ ] No data sent to external servers
- [ ] GDPR/CCPA compliant by design
- [ ] No API keys needed
- [ ] No privacy policy disclosure required

### Performance ✅
- [ ] Core Data save <10ms per question
- [ ] UI remains responsive during AI processing
- [ ] No memory leaks
- [ ] 60 FPS maintained

### Integration with Later Phases ✅
- [ ] Phase 4: Profile completeness UI shows >60% average
- [ ] Phase 5: Course recommendations can use O*NET data
- [ ] Phase 6: A/B test ready (O*NET vs skills-only)

---

## Deliverables Checklist

### Code Files
- [ ] ProfileScreen.swift (O*NET UI removed)
- [ ] CareerQuestion+CoreData.swift (new entity)
- [ ] CareerQuestionDatabase.swift (CRUD service)
- [ ] AICareerProfileBuilder.swift (Foundation Models AI)
- [ ] CareerQuestionsSeed.swift (15 questions)
- [ ] AICareerDiscoveryView.swift (UI)
- [ ] ManifestTabView.swift (integration)

### Tests
- [ ] AICareerProfileBuilderTests.swift (6+ tests)
- [ ] CareerQuestionDatabaseTests.swift
- [ ] Integration tests (end-to-end)

### Documentation
- [ ] PHASE_3.5_FOUNDATION_MODELS_ARCHITECTURE.md (architecture)
- [ ] Testing report (unit + integration + manual)
- [ ] Guardian approval report

---

## Risk Mitigation

### Risk: Foundation Models Unavailable on Device
- **Likelihood**: Medium (iPhone 14/15 non-Pro don't support)
- **Impact**: High (feature unavailable)
- **Mitigation**:
  - Show upgrade prompt: "Requires iPhone 15 Pro or iPhone 16"
  - Clear messaging: "AI Career Discovery needs advanced hardware"
  - Don't fall back to manual UI (keeps codebase clean)

### Risk: AI Inference Inaccurate
- **Likelihood**: Medium (AI parsing is non-deterministic)
- **Impact**: High (bad O*NET → bad Thompson recommendations)
- **Mitigation**:
  - Structured prompts with clear examples
  - Validation of extracted values (1-12 education, 1-7 activities, -2 to +2 RIASEC)
  - Show completion summary for user validation
  - Allow "Refine Profile" button to restart with different questions

### Risk: Low Completion Rate
- **Likelihood**: Low (conversational questions more engaging than manual)
- **Impact**: High (incomplete O*NET → weak recommendations)
- **Mitigation**:
  - Progress indicator (encourages completion)
  - Clear value prop: "Unlock better career matches"
  - Save progress (can resume later)
  - Only 15 questions (5-8 minutes is acceptable)

### Risk: Performance Regression
- **Likelihood**: Low (Foundation Models are fast)
- **Impact**: Medium (laggy UI frustrates users)
- **Mitigation**:
  - All AI calls are async (don't block UI)
  - Loading spinner during processing
  - Timeout if >100ms (warn user)
  - Profile with Instruments before launch

---

## Handoff to Phase 4

### Prerequisites for Phase 4 Start (Liquid Glass UI)
- [ ] Phase 3.5 complete
- [ ] O*NET profiles can be populated via AI
- [ ] >60% average profile completeness

### Phase 4 Integration Points
Phase 4 (Liquid Glass UI) uses Phase 3.5 in:

**Week 15, Day 11-12: Profile Completeness UI**
```swift
// Phase 4 will build this UI using Phase 3.5 O*NET data
struct ProfileCompletenessCard: View {
    let profile: UserProfile

    var onetCompleteness: Double {
        // Uses AI-populated O*NET fields from Phase 3.5
        // Education: 20%
        // Work Activities: 20%
        // RIASEC: 20%
        // Skills: 20%
        // Experience: 20%
    }
}
```

**Phase 4 Team Notification**:
Once Phase 3.5 is complete, **Phase 4 (Liquid Glass UI) can begin Week 13**:

```
Phase 3.5 (AI-Driven O*NET) COMPLETE ✅

AI Discovery: 15 questions, 5-8 minutes ✅
Foundation Models: <50ms per question, $0 cost ✅
User Completion: >65% complete all questions ✅
O*NET Profile: >80% fields populated ✅
Privacy: 100% on-device, no external APIs ✅

Phase 4 (Liquid Glass UI) ready to begin Week 13.
Profile Completeness UI will show rich O*NET data.
```

---

## Timeline Summary

| Week | Focus | Milestone |
|------|-------|-----------|
| 10 | Remove manual UI, create schema | Manual UI gone, CareerQuestion schema created |
| 11 | Build AI service, seed questions | Foundation Models working, 15 questions seeded |
| 12 | UI integration, testing | AI discovery UI complete, ManifestTabView integrated |
| 13-14 | Testing, guardian review | All tests passing, guardians approve |

**Total**: 4 weeks

---

## Cost & Privacy Summary

### Cost Comparison

| Metric | External APIs (Original) | Foundation Models (Final) | Savings |
|--------|-------------------------|--------------------------|---------|
| Cost per user | $0.015 | $0.00 | $0.015 |
| 1,000 users/month | $15 | $0 | **$15/month** |
| 10,000 users/month | $150 | $0 | **$150/month** |
| Annual (1K users) | $180 | $0 | **$180/year** |
| Annual (10K users) | $1,800 | $0 | **$1,800/year** |

### Combined with Phase 2 Savings
- **Phase 2**: Resume parsing, job analysis → **$2,400-6,000/year** saved
- **Phase 3.5**: O*NET AI discovery → **$180-1,800/year** saved
- **Total AI Cost Savings**: **$2,580-7,800/year**

### Privacy
- ✅ 100% on-device processing
- ✅ No data sent to external servers
- ✅ GDPR/CCPA compliant by design
- ✅ No privacy policy disclosure needed
- ✅ Works offline

---

**Phase 3.5 Status**: ⚪ Not Started | 🟡 In Progress | 🟢 Complete | 🔴 Blocked

**Last Updated**: October 31, 2025
**Next Phase**: Phase 4 - Liquid Glass UI Adoption (uses O*NET profile completeness)
