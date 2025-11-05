# Phase 2 Future Evolution: AI-Driven O*NET Discovery

**Document Status**: Planning / Vision Document
**Created**: October 31, 2025
**Priority**: P2 (Future Enhancement)
**Depends On**: Phase 2 manual implementation (current), AI Career Discovery Questions system
**Estimated Effort**: 40-60 hours (4-6 weeks)

---

## Executive Summary

### The Narrative Misalignment

The current Phase 2 implementation (manual sliders and pickers for O*NET data) **does not align with ManifestAndMatch's core narrative**:

**❌ Current Manual Approach** (Phase 2 As-Is):
- User explicitly fills out forms
- 41 work activity sliders
- Education level picker
- RIASEC personality sliders
- Feels like "homework" / data entry
- **Belongs in Match Profile** (Amber/current reality)

**✅ Future AI-Driven Approach** (Aligned with App Mission):
- O*NET profile emerges naturally through conversation
- Questions serve dual purpose: career discovery + personality profiling
- User doesn't realize they're being assessed
- Engaging, game-like experience
- **Belongs in Manifest Profile** (Teal/potential/aspiration)

### The Core Insight

**Act II: "The Revelation"** is about discovering hidden potential through AI-guided career exploration. The O*NET profile should be a **byproduct** of this journey, not a manual prerequisite.

```
Current Flow (Manual):
User → Fills 41 sliders → Fills education → Fills RIASEC → Gets matches

Future Flow (AI-Driven):
User → Answers engaging questions → Profile emerges invisibly → Gets personalized matches
         ↓
   "Do you enjoy analyzing data?" (7/7)
         ↓
   Increases onetRIASECInvestigative by 0.5
   Increases work activity "4.A.2.a.4" (Analyzing Data)
   Signals high education preference
         ↓
   Manifest Profile builds naturally
```

---

## Part 1: Current vs. Future Comparison

### Current Implementation (Phase 2 Manual)

**Files**:
- `ONetEducationLevelPicker.swift` - 345 lines
- `ONetWorkActivitiesSelector.swift` - 484 lines
- `RIASECInterestProfiler.swift` - 693 lines

**User Experience**:
1. User navigates to ProfileScreen
2. Sees 3 O*NET sections with collapsed cards
3. Expands "Education Level" → selects from 1-12 scale
4. Expands "Work Activities" → checks 41 activities, sets importance sliders
5. Expands "RIASEC Interests" → adjusts 6 personality dimension sliders
6. Total time: 10-15 minutes of tedious data entry

**Pros**:
- ✅ Explicit control over profile data
- ✅ Immediate visibility of all dimensions
- ✅ Works without AI/network dependency
- ✅ Easy to debug and test

**Cons**:
- ❌ Tedious, feels like paperwork
- ❌ Users don't know what half these activities mean
- ❌ Self-assessment bias (people overestimate their interests)
- ❌ High friction, low completion rate expected
- ❌ **Misaligned with app narrative** (Act II is about discovery, not self-reporting)

### Future AI-Driven Approach

**User Experience**:
1. User browses job cards (DeckScreen)
2. Between every 5-7 jobs, system asks an engaging question:
   - "You just liked several data analyst roles. Do you enjoy working with numbers and statistics?" (Yes/No)
   - "I noticed you skipped management positions. How do you feel about leading teams?" (Rating 1-7)
   - "Would you rather work with your hands or work with ideas?" (Multiple choice)
3. User answers naturally, thinking it's career guidance
4. **Behind the scenes**: Each answer updates O*NET dimensions
5. After 20-30 questions (over 2-3 sessions), O*NET profile is 80% complete
6. User never saw a single slider or form

**Pros**:
- ✅ **Aligned with Act II narrative** (discovery, not data entry)
- ✅ Engaging, game-like experience
- ✅ Higher completion rate (questions feel natural)
- ✅ Reduces self-assessment bias (implicit measurement)
- ✅ Questions provide career guidance value (dual purpose)
- ✅ Can be spread across multiple sessions (low friction)

**Cons**:
- ⚠️ More complex to implement (question generation, answer parsing)
- ⚠️ Requires AI API calls (cost, latency)
- ⚠️ Less explicit control for power users
- ⚠️ Harder to debug profile accuracy

**Solution to Cons**: Keep manual ProfileScreen components as fallback/override. Power users can still manually adjust in settings.

---

## Part 2: Technical Architecture

### 2.1 Existing CareerQuestion System

**Core Data Entity** (`CareerQuestion+CoreData.swift`):
```swift
@objc(CareerQuestion)
public class CareerQuestion: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var questionText: String
    @NSManaged public var category: String      // "values", "tasks", "interests", "skills"
    @NSManaged public var type: String          // "multiple_choice", "free_text", "rating", "binary"
    @NSManaged public var priority: Int16
    @NSManaged public var relevanceScore: Double
    @NSManaged public var answeredDate: Date?
    @NSManaged private var responseData: Data?
    @NSManaged private var metadataData: Data?
}
```

**Key Features**:
- Priority-based question selection
- Category-based filtering (values, tasks, interests, skills)
- Skip tracking (questions skipped 3+ times are deprioritized)
- Metadata storage for extensibility

### 2.2 Extending CareerQuestion for O*NET

**New Metadata Fields** (stored in `metadataData`):

```swift
// O*NET Dimension Tracking
metadata = [
    // Education Level Impact
    "onetEducationMin": 6,          // Answer suggests minimum education level 6+
    "onetEducationMax": 10,         // Answer suggests maximum education level 10
    "onetEducationWeight": 0.3,     // How much this answer affects education (0.0-1.0)

    // Work Activities Impact (activity ID → weight change)
    "onetWorkActivities": [
        "4.A.2.a.4": 0.5,           // "Analyzing Data" +0.5 weight
        "4.A.3.b.1": 0.3            // "Interacting With Computers" +0.3 weight
    ],

    // RIASEC Dimension Impact
    "onetRIASEC": [
        "investigative": 0.6,       // +0.6 to Investigative
        "realistic": -0.2           // -0.2 to Realistic (inverse relationship)
    ],

    // Question Context
    "onetPrimaryDimension": "RIASEC_I",  // Primary O*NET dimension this question measures
    "onetSecondaryDimensions": ["WorkActivity_4.A.2.a.4", "Education"]
]
```

**Answer Processing Flow**:

```swift
// When user answers a question
func processAnswer(question: CareerQuestion, response: [String: Any]) {
    // 1. Extract O*NET metadata
    let onetMetadata = question.metadata

    // 2. Parse answer value (1-7 scale, binary, etc.)
    let answerStrength = parseAnswerStrength(response, questionType: question.type)

    // 3. Update UserProfile O*NET fields
    if let educationImpact = onetMetadata["onetEducationWeight"] as? Double {
        updateEducationLevel(impact: educationImpact, strength: answerStrength)
    }

    if let workActivities = onetMetadata["onetWorkActivities"] as? [String: Double] {
        updateWorkActivities(impacts: workActivities, strength: answerStrength)
    }

    if let riasecImpacts = onetMetadata["onetRIASEC"] as? [String: Double] {
        updateRIASECProfile(impacts: riasecImpacts, strength: answerStrength)
    }

    // 4. Log for debugging
    print("✅ [O*NET] Updated profile from question: \(question.questionText)")
}

private func parseAnswerStrength(_ response: [String: Any], questionType: String) -> Double {
    switch questionType {
    case "rating":
        // Rating 1-7 → 0.0-1.0 scale
        if let rating = response["rating"] as? Int {
            return Double(rating) / 7.0
        }
    case "binary":
        // Yes = 1.0, No = 0.0
        if let answer = response["answer"] as? String {
            return answer.lowercased() == "yes" ? 1.0 : 0.0
        }
    case "multiple_choice":
        // Map choices to scale
        if let choice = response["choice"] as? String {
            return mapChoiceToStrength(choice)
        }
    default:
        return 0.5  // Default neutral
    }
    return 0.5
}

private func updateRIASECProfile(impacts: [String: Double], strength: Double) {
    guard let profile = UserProfile.fetchCurrent(in: context) else { return }

    for (dimension, weight) in impacts {
        let adjustedImpact = weight * strength  // Scale by answer strength

        switch dimension {
        case "realistic":
            profile.onetRIASECRealistic = clamp(profile.onetRIASECRealistic + adjustedImpact, 0, 7)
        case "investigative":
            profile.onetRIASECInvestigative = clamp(profile.onetRIASECInvestigative + adjustedImpact, 0, 7)
        case "artistic":
            profile.onetRIASECArtistic = clamp(profile.onetRIASECArtistic + adjustedImpact, 0, 7)
        case "social":
            profile.onetRIASECSocial = clamp(profile.onetRIASECSocial + adjustedImpact, 0, 7)
        case "enterprising":
            profile.onetRIASECEnterprising = clamp(profile.onetRIASECEnterprising + adjustedImpact, 0, 7)
        case "conventional":
            profile.onetRIASECConventional = clamp(profile.onetRIASECConventional + adjustedImpact, 0, 7)
        default:
            break
        }
    }

    try? context.save()
}
```

### 2.3 Question Generation Strategy

**Three-Tier Question Library**:

#### Tier 1: Direct O*NET Questions (Explicit Assessment)
**Priority**: Low (only if AI fails or user requests explicit test)

Examples:
- "Rate your interest in analyzing data (1-7)"
- "How important is working with computers to you?"
- "Do you prefer hands-on work or abstract thinking?"

**O*NET Metadata**:
```swift
metadata = [
    "onetPrimaryDimension": "RIASEC_I",
    "onetRIASEC": ["investigative": 1.0],  // Direct 1:1 mapping
    "onetWorkActivities": ["4.A.2.a.4": 1.0]
]
```

#### Tier 2: Contextualized Career Questions (Implicit Assessment)
**Priority**: Medium (good for mid-session profiling)

Examples:
- "You just liked several software engineer roles. Do you enjoy solving complex technical problems?" (Yes/No)
- "I noticed you skipped management positions. How comfortable are you leading teams?" (Rating 1-7)
- "Would you rather spend your day: (A) Building things with tools, (B) Analyzing data, (C) Helping people solve problems?" (Multiple choice)

**O*NET Metadata**:
```swift
// Example: Complex problem-solving question
metadata = [
    "onetPrimaryDimension": "RIASEC_I",
    "onetRIASEC": [
        "investigative": 0.7,      // Strong signal
        "realistic": 0.3           // Weak signal
    ],
    "onetWorkActivities": [
        "4.A.2.a.4": 0.6,          // Analyzing Data
        "4.A.2.b.2": 0.5           // Thinking Creatively
    ],
    "onetEducationMin": 8,         // Suggests Bachelor's+
    "onetEducationWeight": 0.2
]
```

#### Tier 3: Behavioral Inference Questions (Natural Discovery)
**Priority**: High (best user experience, lowest friction)

These questions don't look like assessments at all—they're genuine career guidance:

Examples:
- "What motivates you most in your work?" (Multiple choice: Money, Impact, Creativity, Stability, Recognition)
- "Describe your ideal work environment" (Free text)
- "If you could shadow anyone for a day, who would it be?" (Free text with AI parsing)

**O*NET Metadata** (Probabilistic):
```swift
// Example: "What motivates you most?"
// If answer = "Creativity"
metadata = [
    "onetRIASEC": [
        "artistic": 0.5,
        "investigative": 0.2,
        "enterprising": 0.1
    ],
    "onetWorkActivities": [
        "4.A.2.b.2": 0.4,  // Thinking Creatively
        "4.A.4.b.4": 0.3   // Developing Objectives/Strategies
    ]
]

// If answer = "Stability"
metadata = [
    "onetRIASEC": [
        "conventional": 0.6,
        "realistic": 0.3
    ],
    "onetWorkActivities": [
        "4.A.3.a.3": 0.4,  // Documenting/Recording Info
        "4.A.3.b.5": 0.3   // Processing Information
    ]
]
```

### 2.4 AI-Powered Dynamic Question Generation

**SmartQuestionGenerator Extension**:

```swift
actor SmartQuestionGenerator {

    /// Generate next O*NET discovery question based on current profile gaps
    func generateNextONetQuestion(
        userProfile: UserProfile,
        recentJobInteractions: [JobInteraction]
    ) async throws -> CareerQuestion {

        // 1. Analyze O*NET profile completeness
        let profileGaps = analyzeONetGaps(userProfile)

        // 2. Prioritize gaps (RIASEC > Work Activities > Education)
        let priorityGap = profileGaps.max(by: { $0.priority < $1.priority })

        // 3. Generate contextualized question using AI
        let context = buildQuestionContext(
            gap: priorityGap,
            recentJobs: recentJobInteractions,
            userProfile: userProfile
        )

        let prompt = """
        Generate a natural, engaging career discovery question that:
        - Helps discover the user's \(priorityGap.dimension) dimension
        - References their recent job interactions: \(context.recentJobTitles)
        - Doesn't feel like a personality test
        - Provides genuine career guidance value

        Dimension to assess: \(priorityGap.dimension)
        Current value: \(priorityGap.currentValue) (need more data)
        Related O*NET activities: \(priorityGap.relatedActivities)

        Format:
        {
          "questionText": "...",
          "type": "rating|binary|multiple_choice",
          "answerOptions": [...],  // If multiple choice
          "onetMetadata": {
            "onetRIASEC": {...},
            "onetWorkActivities": {...}
          }
        }
        """

        let response = try await aiService.generateQuestion(prompt: prompt)

        // 4. Create CareerQuestion with O*NET metadata
        let question = CareerQuestion.createFromAI(
            questionText: response.questionText,
            type: response.type,
            answerOptions: response.answerOptions,
            onetMetadata: response.onetMetadata,
            in: context
        )

        return question
    }

    private func analyzeONetGaps(_ profile: UserProfile) -> [ONetGap] {
        var gaps: [ONetGap] = []

        // Check RIASEC completeness
        let riasecValues = [
            ("realistic", profile.onetRIASECRealistic),
            ("investigative", profile.onetRIASECInvestigative),
            ("artistic", profile.onetRIASECArtistic),
            ("social", profile.onetRIASECSocial),
            ("enterprising", profile.onetRIASECEnterprising),
            ("conventional", profile.onetRIASECConventional)
        ]

        for (dimension, value) in riasecValues {
            if value == 0.0 {  // Unassessed
                gaps.append(ONetGap(
                    dimension: "RIASEC_\(dimension)",
                    currentValue: value,
                    priority: 100,  // Highest priority
                    relatedActivities: getRelatedActivities(dimension)
                ))
            }
        }

        // Check Work Activities completeness
        let assessedActivities = profile.onetWorkActivities?.keys.count ?? 0
        if assessedActivities < 20 {  // Less than half assessed
            gaps.append(ONetGap(
                dimension: "WorkActivities",
                currentValue: Double(assessedActivities),
                priority: 80,
                relatedActivities: getMissingActivities(profile)
            ))
        }

        // Check Education Level
        if profile.onetEducationLevel == 0 {
            gaps.append(ONetGap(
                dimension: "EducationLevel",
                currentValue: 0,
                priority: 60,
                relatedActivities: []
            ))
        }

        return gaps
    }
}

struct ONetGap {
    let dimension: String
    let currentValue: Double
    let priority: Int
    let relatedActivities: [String]
}
```

---

## Part 3: Dual-Purpose Question Examples

### Example 1: Analyzing Data Interest

**Question Text**:
> "You've shown interest in data analyst roles. On a scale of 1-7, how much do you enjoy diving deep into numbers and finding patterns?"

**Type**: `rating` (1-7 scale)

**O*NET Impact** (if user answers 6/7):
```swift
metadata = [
    "onetRIASEC": [
        "investigative": 0.5  // +0.5 × (6/7) = +0.43
    ],
    "onetWorkActivities": [
        "4.A.2.a.4": 0.7      // "Analyzing Data" +0.7 × (6/7) = +0.6
    ],
    "onetEducationMin": 8,     // Suggests Bachelor's degree
    "onetEducationWeight": 0.3
]
```

**Career Guidance Value**:
- Helps user reflect on analytical work
- Validates their interest in data roles
- Can trigger follow-up job recommendations

### Example 2: Hands-On vs. Abstract Work

**Question Text**:
> "If you could choose, would you rather: (A) Build and repair physical things, (B) Design systems and solve abstract problems, or (C) Work directly with people to help them?"

**Type**: `multiple_choice`

**O*NET Impact**:

**Answer A** (Build/repair):
```swift
metadata = [
    "onetRIASEC": [
        "realistic": 0.8,
        "investigative": -0.2  // Inverse relationship
    ],
    "onetWorkActivities": [
        "4.A.3.a.4": 0.6,  // Repairing/Maintaining Mechanical Equipment
        "4.A.3.a.2": 0.5   // Handling/Moving Objects
    ],
    "onetEducationMax": 7  // Suggests trade school/associate's
]
```

**Answer B** (Design/solve):
```swift
metadata = [
    "onetRIASEC": [
        "investigative": 0.8,
        "artistic": 0.3
    ],
    "onetWorkActivities": [
        "4.A.2.a.4": 0.6,  // Analyzing Data
        "4.A.2.b.2": 0.5   // Thinking Creatively
    ],
    "onetEducationMin": 8  // Suggests Bachelor's+
]
```

**Answer C** (Work with people):
```swift
metadata = [
    "onetRIASEC": [
        "social": 0.9,
        "enterprising": 0.2
    ],
    "onetWorkActivities": [
        "4.A.4.c.2": 0.7,  // Establishing/Maintaining Relationships
        "4.A.4.a.5": 0.6   // Assisting/Caring for Others
    ]
]
```

**Career Guidance Value**:
- Fundamental career orientation question
- Helps narrow job categories immediately
- Provides insight user can act on

### Example 3: Leadership Comfort

**Question Text**:
> "I noticed you've skipped several management roles. How comfortable are you with leading a team?" (1 = Very uncomfortable, 7 = Very comfortable)

**Type**: `rating` (1-7 scale)

**O*NET Impact** (if user answers 2/7 - uncomfortable):
```swift
metadata = [
    "onetRIASEC": [
        "enterprising": -0.5,  // Negative impact (low leadership interest)
        "social": -0.2
    ],
    "onetWorkActivities": [
        "4.A.4.b.5": -0.6,  // Coordinating Work/Activities of Others
        "4.A.4.b.1": -0.4,  // Guiding/Directing Others
        "4.A.2.b.1": -0.3   // Making Decisions/Solving Problems
    ]
]
```

**Career Guidance Value**:
- Explains why user is skipping certain jobs
- Validates individual contributor path
- Can trigger IC-focused recommendations

---

## Part 4: User Journey Flow

### Session 1: Initial Job Browsing (Questions 1-5)

**User Actions**:
- Opens app, sees DeckScreen with job cards
- Swipes through 5-7 job cards (likes, skips, passes)

**System Actions**:
- After 5 cards, shows first question (Tier 3 - Natural):
  - "What matters most to you in your next role?" (Multiple choice: Growth, Stability, Impact, Creativity, Compensation)
- User answers → Updates RIASEC profile invisibly
- After 5 more cards, shows second question (Tier 3):
  - "Describe your ideal work environment in 3 words" (Free text)
- AI parses response → Updates work activities preferences

**O*NET Progress**: 5-10% complete (broad strokes)

### Session 2: Contextual Discovery (Questions 6-15)

**User Actions**:
- Returns next day, continues swiping
- Showing stronger preferences (likes data roles, skips sales)

**System Actions**:
- After noticing data role interest, asks (Tier 2 - Contextualized):
  - "You've liked several analyst roles. Do you enjoy working with spreadsheets and databases?" (Yes/No)
- User: "Yes" → +0.5 to Investigative, +0.6 to "Analyzing Data" activity
- After skipping sales roles, asks:
  - "How comfortable are you with public speaking?" (Rating 1-7)
- User: 2/7 → -0.4 to Enterprising, -0.5 to "Performing for Public" activity

**O*NET Progress**: 40-50% complete (clear patterns emerging)

### Session 3: Refinement (Questions 16-25)

**User Actions**:
- Third session, system has strong signal on user preferences

**System Actions**:
- Asks targeted questions to fill remaining gaps:
  - "Do you prefer structured, routine work or varied, unpredictable tasks?" (Binary choice)
  - "Rate your interest in: (A) Fixing technical problems, (B) Creating new designs, (C) Teaching others" (Multiple choice)
- Fills in remaining RIASEC dimensions
- Completes work activities profile

**O*NET Progress**: 80-90% complete (actionable profile)

### Background: Continuous Refinement

**System Actions**:
- As user continues using app, occasionally asks clarifying questions
- Detects inconsistencies (e.g., user likes creative roles but rated Artistic low)
- Sends gentle correction questions to refine profile
- Never asks more than 1 question per 10 job cards (low friction)

**O*NET Progress**: 90-100% complete after ~50 job interactions

---

## Part 5: Implementation Roadmap

### Phase 2.5: Hybrid Approach (4-6 weeks, P2 priority)

**Goal**: Keep manual ProfileScreen UI, add AI question insertion to DeckScreen

**Tasks**:

1. **Extend CareerQuestion with O*NET Metadata** (1 week)
   - Add Core Data migration for metadata fields
   - Create `ONetQuestionMetadata` helper struct
   - Write metadata parsing/update logic

2. **Create Question Library (Tier 2 Contextualized)** (1 week)
   - Write 30-50 pre-scripted O*NET questions
   - Assign O*NET metadata to each question
   - Store in JSON file or Core Data seed

3. **Integrate Question Presentation in DeckScreen** (1 week)
   - Add question card UI between job cards
   - Implement answer recording logic
   - Hook up to O*NET profile updates

4. **Build O*NET Profile Gap Analyzer** (1 week)
   - Detect missing RIASEC dimensions
   - Prioritize which questions to ask next
   - Ensure balanced assessment (don't over-ask one dimension)

5. **Testing & Validation** (1-2 weeks)
   - Verify O*NET updates work correctly
   - Test question timing/frequency
   - A/B test question effectiveness
   - Ensure <10ms Thompson constraint still met

**Success Metrics**:
- 70%+ O*NET profile completion rate (vs. expected 20% for manual)
- Average 25 questions to reach 80% completion
- No user complaints about "too many questions"
- Thompson scoring uses richer O*NET data

### Phase 3: Full AI-Driven Generation (8-12 weeks, P3 priority)

**Prerequisite**: Phase 2.5 complete + AI API budget approved

**Goal**: Replace static question library with dynamic AI generation

**Tasks**:

1. **Extend SmartQuestionGenerator for O*NET** (2 weeks)
   - Add `generateONetQuestion()` method
   - Implement profile gap analysis
   - Write AI prompts for question generation

2. **Build Answer Parsing Logic** (2 weeks)
   - Free text answer analysis (extract O*NET signals)
   - Sentiment analysis for RIASEC inference
   - Confidence scoring for metadata weights

3. **Implement Adaptive Questioning** (2 weeks)
   - Detect contradictions in answers
   - Ask clarifying follow-ups
   - Adjust question difficulty based on user engagement

4. **Performance Optimization** (2 weeks)
   - Cache AI-generated questions
   - Pre-generate questions in background
   - Ensure <10ms Thompson constraint

5. **Advanced Features** (2-4 weeks)
   - Multi-dimensional inference (one answer updates multiple dimensions)
   - Career journey narrative integration
   - Question timing optimization (when user is most engaged)

**Success Metrics**:
- 90%+ O*NET profile completion rate
- Average 20 questions to reach 80% completion (vs. 25 for Phase 2.5)
- Profile accuracy validated against self-reported data
- User satisfaction: "Questions felt helpful, not intrusive"

---

## Part 6: Technical Challenges & Solutions

### Challenge 1: Profile Accuracy

**Problem**: Implicit assessment may be less accurate than explicit self-reporting

**Solutions**:
1. **Validation Layer**: Occasionally ask direct verification questions
   - "Based on your answers, I think you're highly Investigative (analytical). Does that sound right?" (Yes/No)
2. **Confidence Scoring**: Track confidence level for each O*NET dimension
   - Low confidence → Ask more targeted questions
3. **Manual Override**: Keep ProfileScreen manual editors accessible
   - Power users can review and adjust AI-inferred profile

### Challenge 2: Question Fatigue

**Problem**: Too many questions feel intrusive, hurt engagement

**Solutions**:
1. **Adaptive Frequency**: Adjust question rate based on user tolerance
   - If user skips 2 questions in a row → Reduce frequency
   - If user answers quickly → Can ask slightly more often
2. **Session Limits**: Max 3 questions per session (unless user opts in)
3. **Gamification**: Show progress indicator
   - "Your career profile is 45% complete! 5 more quick questions to unlock personalized recommendations"

### Challenge 3: Thompson Performance Budget

**Problem**: Adding O*NET metadata processing might violate <10ms constraint

**Solutions**:
1. **Pre-compute Updates**: Calculate O*NET impacts in background task
2. **Debounce Saves**: Batch multiple answer updates into single Core Data save
3. **Performance Testing**: Add assertions to ensure <10ms maintained

### Challenge 4: AI Cost

**Problem**: Generating questions with AI API calls can be expensive

**Solutions**:
1. **Hybrid Library**: Use static question library for 80% of questions, AI for 20% edge cases
2. **Question Caching**: Cache generated questions, reuse for similar users
3. **Batch Generation**: Pre-generate 10 questions at a time in background

---

## Part 7: Success Metrics & KPIs

### Primary Metrics

**Profile Completion Rate**:
- **Current (Manual)**: Expected 15-25% (based on industry benchmarks for profile forms)
- **Target (AI-Driven)**: 70-85% (based on conversational UI benchmarks)

**Questions to Profile Completion**:
- **Manual**: 41 work activities + 6 RIASEC sliders + 1 education = 48 inputs
- **AI-Driven Target**: 20-30 questions to reach 80% profile accuracy

**Time to Completion**:
- **Manual**: 10-15 minutes of focused effort
- **AI-Driven**: 5-10 minutes spread across 3-5 sessions (lower perceived friction)

### Secondary Metrics

**Question Answer Rate**:
- Target: 80%+ of questions answered (not skipped)
- Acceptable: 70%+ (some skips expected)

**Profile Accuracy** (validated against self-reported explicit assessments):
- Target: 85%+ correlation with manual O*NET assessment
- Acceptable: 75%+ (some variance is natural)

**User Satisfaction**:
- Survey: "Did the career questions help you understand yourself better?" (Target: 80%+ "Yes")
- Survey: "Did questions feel intrusive or annoying?" (Target: <10% "Yes")

**Thompson Scoring Improvement**:
- Richer O*NET data should improve match quality
- Target: 10-15% improvement in user satisfaction with job recommendations
- Measured by: Job save rate, application rate, session length

---

## Part 8: Migration Path

### Option A: Big Bang (Not Recommended)

- Remove manual O*NET UI entirely
- Replace with AI questions only
- Risk: Users lose control, may feel "black box"

### Option B: Hybrid Coexistence (Recommended)

**Phase 1**: Keep manual UI, add AI questions alongside
- ProfileScreen manual editors remain accessible
- DeckScreen shows AI questions between job cards
- Users can choose which approach they prefer

**Phase 2**: Promote AI questions, demote manual
- Show banner: "Let us discover your profile through questions instead of forms"
- Move manual editors to Settings > Advanced
- Default to AI-driven flow

**Phase 3**: Optional removal of manual UI
- If AI adoption >80%, consider hiding manual UI by default
- Always keep as fallback for edge cases

---

## Part 9: Open Questions & Decisions Needed

### Decision 1: When to Ask Questions?

**Option A**: Between job cards (current proposal)
- Pro: Natural flow, user is already engaged
- Con: Interrupts job browsing momentum

**Option B**: Dedicated "Career Discovery" mode
- Pro: Focused experience, clear separation
- Con: Extra mode, may reduce completion rate

**Option C**: During onboarding
- Pro: Get profile data early
- Con: High friction at signup, may hurt activation

**Recommendation**: Hybrid - 5 questions during onboarding, rest between job cards

### Decision 2: How Many Questions is Too Many?

**Conservative**: Max 1 question per 10 job cards
- Low friction, slower profile building
- Estimated 50+ sessions to complete profile

**Moderate**: Max 1 question per 5-7 job cards (current proposal)
- Balanced friction, reasonable completion time
- Estimated 20-30 sessions to complete profile

**Aggressive**: Max 1 question per 3 job cards
- Fast profile building, risk of fatigue
- Estimated 10-15 sessions to complete profile

**Recommendation**: Start moderate, A/B test aggressive with tolerant users

### Decision 3: Profile Transparency

**Should users see their O*NET profile emerge in real-time?**

**Option A**: Show progress (transparent)
- "Your Investigative score just increased! You're 45% complete."
- Pro: User feels sense of progress, gamification
- Con: May reveal "game mechanics," reduce implicit assessment accuracy

**Option B**: Hide progress (black box)
- Profile builds invisibly, only show final result
- Pro: Pure implicit assessment, no gaming the system
- Con: User may feel lack of control, distrust

**Recommendation**: Show high-level progress ("Profile 45% complete"), hide dimension-level details until 80%+ complete

---

## Conclusion

### Why This Matters

The AI-driven O*NET discovery approach represents a fundamental alignment with ManifestAndMatch's core narrative:

**The app's mission is to reveal hidden career potential, not to make users fill out forms.**

Act II: "The Revelation" should feel like a **discovery journey**, not a **data entry task**. By embedding O*NET assessment into natural career questions, we:

1. ✅ **Align with Manifest Profile** (Teal/aspirational/AI-discovered)
2. ✅ **Increase completion rates** (70%+ vs. 20% for manual)
3. ✅ **Provide dual value** (career guidance + profile building)
4. ✅ **Reduce self-assessment bias** (implicit measurement)
5. ✅ **Create engaging experience** (conversation, not homework)

### Next Steps

**Immediate** (Current Phase 2):
- ✅ Complete manual O*NET UI implementation (done)
- ✅ Document future vision (this document)
- ⏸️ Keep manual UI as fallback/override

**Near-Term** (Phase 2.5 - 4-6 weeks):
- Extend CareerQuestion with O*NET metadata
- Create static question library (30-50 questions)
- Integrate question presentation in DeckScreen
- Validate O*NET profile updates work correctly

**Long-Term** (Phase 3 - 8-12 weeks):
- Build full AI question generation
- Implement adaptive questioning
- Optimize for cost and performance
- Measure profile completion and accuracy

### Document Status

**Status**: ✅ Complete - Ready for Future Implementation
**Owner**: Jason (Product Owner)
**Next Review**: After Phase 2.5 begins
**Last Updated**: October 31, 2025

---

**Related Documents**:
- `PHASE_2_ONET_PROFILE_EDITOR.md` - Current manual implementation
- `CareerQuestion+CoreData.swift` - Existing question system
- `SmartQuestionGenerator.swift` - AI question generation service
- App narrative: Act II "The Revelation" (career discovery mission)
