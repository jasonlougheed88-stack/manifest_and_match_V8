# ManifestAndMatch V8 - Enhanced UserProfile Data Architecture
## Technical Specification for iOS 26 with Foundation Models Integration

**Version**: 1.0
**Created**: October 27, 2025
**Target Platform**: iOS 26.0+
**Data Framework**: SwiftData (migrated from Core Data)
**AI Integration**: iOS 26 Foundation Models (on-device)
**Performance Budget**: <10ms Thompson Sampling compatibility

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current State Analysis](#current-state-analysis)
3. [V8 Enhanced Architecture](#v8-enhanced-architecture)
4. [SwiftData Model Definitions](#swiftdata-model-definitions)
5. [Actor-Based Service Architecture](#actor-based-service-architecture)
6. [Foundation Models Integration](#foundation-models-integration)
7. [Migration Strategy](#migration-strategy)
8. [Privacy & Security](#privacy--security)
9. [Performance Budgets](#performance-budgets)
10. [Implementation Roadmap](#implementation-roadmap)

---

## Executive Summary

### Objectives

Transform the UserProfile from a basic 11-field model (55% completeness) to a comprehensive professional profile system (95% completeness) that:

- **Integrates O*NET 30.0 taxonomy** - 3,864 skills, 52 abilities, RIASEC career interests
- **Migrates to SwiftData** - Modern iOS 26 data persistence with type-safe models
- **Leverages Foundation Models** - On-device AI for profile enrichment and skill extraction
- **Maintains performance** - <10ms Thompson Sampling, <200MB memory footprint
- **Ensures privacy** - 100% on-device processing, Keychain security for sensitive data

### Key Improvements

| Metric | V7 Current | V8 Target | Change |
|--------|-----------|-----------|--------|
| Profile Fields | 11 | 45+ | +309% |
| Data Entities | 1 | 12 | +1100% |
| Skills Coverage | 200 tech skills | 3,864 O*NET skills | +1832% |
| Abilities Tracking | None | 52 O*NET abilities | New |
| Career Interests | None | RIASEC codes | New |
| Certifications | String array | Full entity model | Enhanced |
| Work Experience | Basic | Enhanced with technologies/achievements | Enhanced |
| Education | Basic | Enhanced with GPA/honors/coursework | Enhanced |
| Privacy | Cloud processing | 100% on-device | Improved |

---

## Current State Analysis

### V7 UserProfile Model (Core Data)

**Location**: `/Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift`

**Current Fields** (11 total):
```swift
@NSManaged public var id: UUID
@NSManaged public var name: String
@NSManaged public var email: String
@NSManaged public var createdDate: Date
@NSManaged public var currentDomain: String        // BIAS FIXED: No tech default
@NSManaged public var experienceLevel: String      // "entry", "mid", "senior", "lead", "executive"
@NSManaged public var desiredRoles: [String]?
@NSManaged public var locations: [String]?
@NSManaged public var remotePreference: String     // "remote", "hybrid", "onsite"
@NSManaged public var amberTealPosition: Double    // 0.0-1.0 (amber=structured, teal=autonomous)
@NSManaged public var lastModified: Date
```

**Limitations**:
1. No structured certifications (just string arrays in some implementations)
2. No work experience history tracking
3. No education history tracking
4. No skills proficiency levels
5. No career interests or personality assessments
6. No abilities profile (O*NET's 52 abilities)
7. No training/courses tracking
8. Limited career preferences

**Profile Completeness Score**: 55/100

---

## V8 Enhanced Architecture

### Data Model Hierarchy

```
UserProfile (SwiftData root model)
├─ PersonalInfo
│  ├─ Basic identity fields
│  └─ Privacy-controlled contact info
│
├─ ProfessionalIdentity
│  ├─ ExperienceLevel (enhanced)
│  ├─ CurrentDomain (sector-neutral)
│  └─ CareerStage
│
├─ Skills & Abilities
│  ├─ UserSkill (many) → ONetSkill reference
│  ├─ AbilitiesProfile → O*NET 52 abilities
│  └─ SkillsCertifications (many)
│
├─ Career Interests
│  ├─ RIASECProfile (Holland Codes)
│  ├─ WorkValues
│  └─ WorkPreferences
│
├─ Experience & Education
│  ├─ WorkExperience (many)
│  ├─ Education (many)
│  ├─ VolunteerExperience (many)
│  └─ Projects (many)
│
├─ Credentials & Achievements
│  ├─ Certification (many)
│  ├─ License (many)
│  ├─ Award (many)
│  └─ Publication (many)
│
└─ Training & Development
   ├─ CompletedTraining (many)
   ├─ InProgressTraining (many)
   └─ PlannedTraining (many)
```

### O*NET 30.0 Integration

**Data Sources** (already available):
- `/Data/ONET_Skills/skills_v2_complete.json` - 3,864 skills
- `/Data/ONET_Skills/Skills.txt` - Skill ratings by occupation
- `/Data/ONET_Skills/Occupation_Data.txt` - 1,016 occupations

**O*NET Abilities** (52 total, to be integrated):
- **Cognitive** (21): Oral Comprehension, Written Expression, Mathematical Reasoning, etc.
- **Psychomotor** (10): Arm-Hand Steadiness, Manual Dexterity, Reaction Time, etc.
- **Physical** (9): Static Strength, Trunk Strength, Stamina, etc.
- **Sensory** (12): Near Vision, Hearing Sensitivity, Speech Clarity, etc.

**RIASEC Career Interests** (Holland Codes):
- **R**ealistic - Hands-on, practical work
- **I**nvestigative - Research, analysis, problem-solving
- **A**rtistic - Creative, expressive work
- **S**ocial - Helping, teaching, interpersonal
- **E**nterprising - Leadership, persuasion, business
- **C**onventional - Organized, detail-oriented, structured

---

## SwiftData Model Definitions

### Core Model: UserProfile

```swift
import SwiftData
import Foundation

/// Enhanced UserProfile model for ManifestAndMatch V8
/// Migrated from Core Data to SwiftData for iOS 26
@Model
public final class UserProfile: Sendable {

    // MARK: - Identity

    @Attribute(.unique) public var id: UUID
    public var createdDate: Date
    public var lastModified: Date

    // MARK: - Personal Information

    public var name: String
    public var email: String
    public var phoneNumber: String?        // NEW - Optional, privacy-controlled
    public var linkedInURL: String?        // NEW
    public var portfolioURL: String?       // NEW
    public var location: String?           // NEW - Current location

    // MARK: - Professional Identity

    public var currentDomain: String                  // Sector-neutral (from 14 sectors)
    public var experienceLevel: ExperienceLevel       // Enum: entry/mid/senior/lead/executive/expert
    public var careerStage: CareerStage              // NEW: exploring/transitioning/advancing/established
    public var yearsOfExperience: Int                // NEW - Total years
    public var desiredRoles: [String]                // Target role titles

    // MARK: - Work Preferences

    public var remotePreference: RemotePreference    // Enum: remote/hybrid/onsite/flexible
    public var locations: [String]                   // Preferred work locations
    public var workSchedulePreference: WorkSchedule  // NEW: fullTime/partTime/contract/flexible
    public var willingToRelocate: Bool               // NEW
    public var expectedSalaryMin: Int?               // NEW - Optional, privacy-controlled
    public var expectedSalaryMax: Int?               // NEW - Optional

    // MARK: - Career Positioning

    public var amberTealPosition: Double             // 0.0-1.0 (preserved from V7)

    // MARK: - Relationships (SwiftData cascading deletes)

    @Relationship(deleteRule: .cascade)
    public var skills: [UserSkill]                   // NEW - Skills with proficiency

    @Relationship(deleteRule: .cascade)
    public var abilitiesProfile: AbilitiesProfile?   // NEW - O*NET 52 abilities

    @Relationship(deleteRule: .cascade)
    public var riasecProfile: RIASECProfile?         // NEW - Career interests

    @Relationship(deleteRule: .cascade)
    public var workValues: WorkValues?               // NEW - What matters to user

    @Relationship(deleteRule: .cascade)
    public var workExperiences: [WorkExperience]     // Enhanced from V7

    @Relationship(deleteRule: .cascade)
    public var educations: [Education]               // Enhanced from V7

    @Relationship(deleteRule: .cascade)
    public var certifications: [Certification]       // NEW - Full entity model

    @Relationship(deleteRule: .cascade)
    public var licenses: [License]                   // NEW - Professional licenses

    @Relationship(deleteRule: .cascade)
    public var projects: [Project]                   // NEW - Portfolio projects

    @Relationship(deleteRule: .cascade)
    public var volunteerExperiences: [VolunteerExperience] // NEW

    @Relationship(deleteRule: .cascade)
    public var awards: [Award]                       // NEW

    @Relationship(deleteRule: .cascade)
    public var publications: [Publication]           // NEW

    @Relationship(deleteRule: .cascade)
    public var completedTraining: [Training]         // NEW - Completed courses/bootcamps

    @Relationship(deleteRule: .cascade)
    public var inProgressTraining: [Training]        // NEW

    @Relationship(deleteRule: .cascade)
    public var plannedTraining: [Training]           // NEW

    // MARK: - Computed Properties

    /// Profile completeness score (0-100)
    public var completenessScore: Int {
        var score = 0

        // Core identity (20 points)
        if !name.isEmpty { score += 5 }
        if !email.isEmpty { score += 5 }
        if !currentDomain.isEmpty { score += 5 }
        if !desiredRoles.isEmpty { score += 5 }

        // Skills (20 points)
        if !skills.isEmpty { score += 10 }
        if skills.count >= 10 { score += 5 }
        if skills.count >= 20 { score += 5 }

        // Experience (20 points)
        if !workExperiences.isEmpty { score += 10 }
        if workExperiences.count >= 2 { score += 5 }
        if workExperiences.count >= 3 { score += 5 }

        // Education (15 points)
        if !educations.isEmpty { score += 10 }
        if educations.count >= 2 { score += 5 }

        // Certifications/Projects (15 points)
        if !certifications.isEmpty { score += 5 }
        if !projects.isEmpty { score += 5 }
        if !volunteerExperiences.isEmpty { score += 5 }

        // Career interests (10 points)
        if riasecProfile != nil { score += 5 }
        if abilitiesProfile != nil { score += 5 }

        return min(score, 100)
    }

    /// Whether profile is ready for job matching
    public var isMatchReady: Bool {
        completenessScore >= 60 &&
        !skills.isEmpty &&
        !desiredRoles.isEmpty &&
        !currentDomain.isEmpty
    }

    // MARK: - Initialization

    public init(
        name: String,
        email: String,
        currentDomain: String
    ) {
        self.id = UUID()
        self.createdDate = Date()
        self.lastModified = Date()
        self.name = name
        self.email = email
        self.currentDomain = currentDomain
        self.experienceLevel = .mid
        self.careerStage = .exploring
        self.yearsOfExperience = 0
        self.desiredRoles = []
        self.remotePreference = .flexible
        self.locations = []
        self.workSchedulePreference = .fullTime
        self.willingToRelocate = false
        self.amberTealPosition = 0.5

        // Initialize empty relationships
        self.skills = []
        self.workExperiences = []
        self.educations = []
        self.certifications = []
        self.licenses = []
        self.projects = []
        self.volunteerExperiences = []
        self.awards = []
        self.publications = []
        self.completedTraining = []
        self.inProgressTraining = []
        self.plannedTraining = []
    }
}

// MARK: - Supporting Enums

public enum ExperienceLevel: String, Codable, Sendable {
    case entry = "entry"           // 0-2 years
    case mid = "mid"               // 2-5 years
    case senior = "senior"         // 5-8 years
    case lead = "lead"             // 8-12 years
    case executive = "executive"   // 12+ years
    case expert = "expert"         // 15+ years, specialized
}

public enum CareerStage: String, Codable, Sendable {
    case exploring = "exploring"           // Still figuring out direction
    case transitioning = "transitioning"   // Changing careers/industries
    case advancing = "advancing"           // Growing in current field
    case established = "established"       // Senior professional
    case mentoring = "mentoring"           // Teaching/leading others
}

public enum RemotePreference: String, Codable, Sendable {
    case remote = "remote"         // 100% remote only
    case hybrid = "hybrid"         // Mix of remote/office
    case onsite = "onsite"         // Office-based only
    case flexible = "flexible"     // Open to any arrangement
}

public enum WorkSchedule: String, Codable, Sendable {
    case fullTime = "fullTime"     // 40+ hours/week
    case partTime = "partTime"     // <40 hours/week
    case contract = "contract"     // Project-based
    case freelance = "freelance"   // Independent contractor
    case flexible = "flexible"     // Open to any schedule
}
```

---

### Enhanced Entity: UserSkill

```swift
import SwiftData
import Foundation

/// User's skill with proficiency level and context
/// Links to O*NET Skills database (3,864 skills)
@Model
public final class UserSkill: Sendable {

    @Attribute(.unique) public var id: UUID

    /// Skill name (must match O*NET skill name)
    public var skillName: String

    /// O*NET skill ID (e.g., "onet_core_001")
    public var onetSkillID: String?

    /// Proficiency level (1-5)
    /// 1=Beginner, 2=Intermediate, 3=Advanced, 4=Expert, 5=Master
    public var proficiency: Int

    /// Years of experience with this skill
    public var yearsOfExperience: Int

    /// Last time this skill was used professionally
    public var lastUsedDate: Date?

    /// Context where skill was acquired/used
    public var context: SkillContext

    /// Whether this is a core skill for user's career
    public var isCoreSkill: Bool

    /// User's willingness to use this skill (1-5)
    public var interest: Int

    /// Date skill was added to profile
    public var dateAdded: Date

    /// Source of skill data
    public var source: SkillSource

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Initialization

    public init(
        skillName: String,
        onetSkillID: String? = nil,
        proficiency: Int = 3,
        yearsOfExperience: Int = 0,
        context: SkillContext = .work,
        isCoreSkill: Bool = false,
        interest: Int = 3
    ) {
        self.id = UUID()
        self.skillName = skillName
        self.onetSkillID = onetSkillID
        self.proficiency = min(max(proficiency, 1), 5)
        self.yearsOfExperience = yearsOfExperience
        self.context = context
        self.isCoreSkill = isCoreSkill
        self.interest = min(max(interest, 1), 5)
        self.dateAdded = Date()
        self.source = .userProvided
    }
}

public enum SkillContext: String, Codable, Sendable {
    case work = "work"
    case education = "education"
    case personal = "personal"
    case volunteer = "volunteer"
    case training = "training"
}

public enum SkillSource: String, Codable, Sendable {
    case resumeParsed = "resumeParsed"         // Extracted by AI
    case userProvided = "userProvided"         // User added manually
    case inferredFromJob = "inferredFromJob"   // Based on job history
    case assessment = "assessment"             // From skills assessment
}
```

---

### New Entity: AbilitiesProfile (O*NET 52 Abilities)

```swift
import SwiftData
import Foundation

/// O*NET Work-Related Abilities Profile
/// Based on O*NET 52 abilities taxonomy
/// Self-assessed on 1-5 scale (1=Low, 5=High)
@Model
public final class AbilitiesProfile: Sendable {

    @Attribute(.unique) public var id: UUID
    public var lastUpdated: Date

    // MARK: - Cognitive Abilities (21)

    public var oralComprehension: Int           // Understanding spoken language
    public var writtenComprehension: Int        // Understanding written text
    public var oralExpression: Int              // Speaking clearly
    public var writtenExpression: Int           // Writing clearly
    public var fluentOfIdeas: Int              // Generating ideas
    public var originalityIdeas: Int            // Creating novel solutions
    public var problemSensitivity: Int          // Recognizing problems
    public var deductiveReasoning: Int          // Applying rules to problems
    public var inductiveReasoning: Int          // Finding patterns
    public var informationOrdering: Int         // Sequencing information
    public var categoryFlexibility: Int         // Grouping things differently
    public var mathematicalReasoning: Int       // Math problem solving
    public var numberFacility: Int              // Quick calculations
    public var memorization: Int                // Remembering information
    public var speedOfClosure: Int              // Finding patterns quickly
    public var flexibilityOfClosure: Int        // Finding patterns despite distractions
    public var perceptualSpeed: Int             // Comparing information quickly
    public var spatialOrientation: Int          // Understanding spatial relationships
    public var visualization: Int               // Imagining objects/scenarios
    public var selectiveAttention: Int          // Focusing despite distractions
    public var timeSharing: Int                 // Doing multiple tasks simultaneously

    // MARK: - Psychomotor Abilities (10)

    public var armHandSteadiness: Int           // Keeping hand/arm steady
    public var manualDexterity: Int             // Hand manipulation
    public var fingerDexterity: Int             // Precise finger movements
    public var controlPrecision: Int            // Precise adjustments to controls
    public var multilimbCoordination: Int       // Coordinating limbs
    public var responseOrientation: Int         // Choosing correct response quickly
    public var rateControl: Int                 // Adjusting control timing
    public var reactionTime: Int                // Quick reactions
    public var wristFingerSpeed: Int            // Fast hand/finger movements
    public var speedOfLimbMovement: Int         // Fast arm/leg movements

    // MARK: - Physical Abilities (9)

    public var staticStrength: Int              // Lifting/pushing strength
    public var explosiveStrength: Int           // Energy bursts
    public var dynamicStrength: Int             // Repeated muscle exertion
    public var trunkStrength: Int               // Core strength
    public var stamina: Int                     // Physical endurance
    public var extent_flexibility: Int          // Bending/stretching range
    public var dynamicFlexibility: Int          // Repeated bending
    public var grossBodyCoordination: Int       // Coordinating whole body
    public var grossBodyEquilibrium: Int        // Balance

    // MARK: - Sensory Abilities (12)

    public var nearVision: Int                  // Seeing close details
    public var farVision: Int                   // Seeing distant details
    public var visualColorDiscrimination: Int   // Distinguishing colors
    public var nightVision: Int                 // Seeing in low light
    public var peripheralVision: Int            // Seeing to the side
    public var depthPerception: Int             // Judging distances
    public var glareSpectivity: Int            // Seeing in bright light
    public var hearingSensitivity: Int          // Detecting sounds
    public var auditoryAttention: Int           // Focusing on sounds
    public var soundLocalization: Int           // Determining sound direction
    public var speechRecognition: Int           // Understanding speech
    public var speechClarity: Int               // Speaking clearly

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var averageCognitive: Double {
        let sum = oralComprehension + writtenComprehension + oralExpression +
                  writtenExpression + fluentOfIdeas + originalityIdeas +
                  problemSensitivity + deductiveReasoning + inductiveReasoning +
                  informationOrdering + categoryFlexibility + mathematicalReasoning +
                  numberFacility + memorization + speedOfClosure +
                  flexibilityOfClosure + perceptualSpeed + spatialOrientation +
                  visualization + selectiveAttention + timeSharing
        return Double(sum) / 21.0
    }

    public var averagePsychomotor: Double {
        let sum = armHandSteadiness + manualDexterity + fingerDexterity +
                  controlPrecision + multilimbCoordination + responseOrientation +
                  rateControl + reactionTime + wristFingerSpeed + speedOfLimbMovement
        return Double(sum) / 10.0
    }

    public var averagePhysical: Double {
        let sum = staticStrength + explosiveStrength + dynamicStrength +
                  trunkStrength + stamina + extent_flexibility + dynamicFlexibility +
                  grossBodyCoordination + grossBodyEquilibrium
        return Double(sum) / 9.0
    }

    public var averageSensory: Double {
        let sum = nearVision + farVision + visualColorDiscrimination +
                  nightVision + peripheralVision + depthPerception +
                  glareSpectivity + hearingSensitivity + auditoryAttention +
                  soundLocalization + speechRecognition + speechClarity
        return Double(sum) / 12.0
    }

    // MARK: - Initialization

    public init() {
        self.id = UUID()
        self.lastUpdated = Date()

        // Initialize all abilities to neutral (3)
        // Cognitive
        self.oralComprehension = 3
        self.writtenComprehension = 3
        self.oralExpression = 3
        self.writtenExpression = 3
        self.fluentOfIdeas = 3
        self.originalityIdeas = 3
        self.problemSensitivity = 3
        self.deductiveReasoning = 3
        self.inductiveReasoning = 3
        self.informationOrdering = 3
        self.categoryFlexibility = 3
        self.mathematicalReasoning = 3
        self.numberFacility = 3
        self.memorization = 3
        self.speedOfClosure = 3
        self.flexibilityOfClosure = 3
        self.perceptualSpeed = 3
        self.spatialOrientation = 3
        self.visualization = 3
        self.selectiveAttention = 3
        self.timeSharing = 3

        // Psychomotor
        self.armHandSteadiness = 3
        self.manualDexterity = 3
        self.fingerDexterity = 3
        self.controlPrecision = 3
        self.multilimbCoordination = 3
        self.responseOrientation = 3
        self.rateControl = 3
        self.reactionTime = 3
        self.wristFingerSpeed = 3
        self.speedOfLimbMovement = 3

        // Physical
        self.staticStrength = 3
        self.explosiveStrength = 3
        self.dynamicStrength = 3
        self.trunkStrength = 3
        self.stamina = 3
        self.extent_flexibility = 3
        self.dynamicFlexibility = 3
        self.grossBodyCoordination = 3
        self.grossBodyEquilibrium = 3

        // Sensory
        self.nearVision = 3
        self.farVision = 3
        self.visualColorDiscrimination = 3
        self.nightVision = 3
        self.peripheralVision = 3
        self.depthPerception = 3
        self.glareSpectivity = 3
        self.hearingSensitivity = 3
        self.auditoryAttention = 3
        self.soundLocalization = 3
        self.speechRecognition = 3
        self.speechClarity = 3
    }
}
```

---

### New Entity: RIASECProfile (Holland Codes)

```swift
import SwiftData
import Foundation

/// RIASEC Career Interest Profile (Holland Codes)
/// Based on Holland's Vocational Personality Types
/// Each score 0-100 (percentage interest)
@Model
public final class RIASECProfile: Sendable {

    @Attribute(.unique) public var id: UUID
    public var lastUpdated: Date

    // MARK: - RIASEC Scores (0-100)

    /// Realistic: Hands-on, practical, mechanical work
    /// Examples: Construction, agriculture, engineering, athletics
    public var realistic: Int

    /// Investigative: Research, analysis, problem-solving
    /// Examples: Science, medicine, research, data analysis
    public var investigative: Int

    /// Artistic: Creative, expressive, innovative work
    /// Examples: Design, arts, writing, entertainment
    public var artistic: Int

    /// Social: Helping, teaching, interpersonal work
    /// Examples: Education, healthcare, counseling, social work
    public var social: Int

    /// Enterprising: Leadership, persuasion, business
    /// Examples: Sales, management, law, politics
    public var enterprising: Int

    /// Conventional: Organized, detail-oriented, structured
    /// Examples: Accounting, administration, data entry
    public var conventional: Int

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    /// Holland Code (3-letter code of top 3 interests)
    /// Example: "RIA" = Realistic-Investigative-Artistic
    public var hollandCode: String {
        let scores: [(String, Int)] = [
            ("R", realistic),
            ("I", investigative),
            ("A", artistic),
            ("S", social),
            ("E", enterprising),
            ("C", conventional)
        ]

        let sorted = scores.sorted { $0.1 > $1.1 }
        return sorted.prefix(3).map { $0.0 }.joined()
    }

    /// Primary interest (highest score)
    public var primaryInterest: String {
        let scores: [(String, Int)] = [
            ("Realistic", realistic),
            ("Investigative", investigative),
            ("Artistic", artistic),
            ("Social", social),
            ("Enterprising", enterprising),
            ("Conventional", conventional)
        ]

        return scores.max { $0.1 < $1.1 }?.0 ?? "Unknown"
    }

    // MARK: - Initialization

    public init() {
        self.id = UUID()
        self.lastUpdated = Date()

        // Initialize all scores to 50 (neutral)
        self.realistic = 50
        self.investigative = 50
        self.artistic = 50
        self.social = 50
        self.enterprising = 50
        self.conventional = 50
    }
}
```

---

### New Entity: WorkValues

```swift
import SwiftData
import Foundation

/// User's work values and priorities
/// What matters most in their career
@Model
public final class WorkValues: Sendable {

    @Attribute(.unique) public var id: UUID
    public var lastUpdated: Date

    // MARK: - Work Values (1-5 importance scale)

    public var achievement: Int             // Accomplishment, results
    public var independence: Int            // Autonomy, freedom
    public var recognition: Int             // Acknowledgment, status
    public var relationships: Int           // Coworker connections
    public var support: Int                 // Supportive management
    public var workingConditions: Int       // Comfortable environment
    public var compensation: Int            // Salary, benefits
    public var advancement: Int             // Growth opportunities
    public var workLifeBalance: Int         // Time for personal life
    public var jobSecurity: Int             // Stability, predictability
    public var creativity: Int              // Innovation, new ideas
    public var variety: Int                 // Diverse tasks
    public var impact: Int                  // Making a difference
    public var learning: Int                // Skill development
    public var challenge: Int               // Difficult problems

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var topThreeValues: [String] {
        let values: [(String, Int)] = [
            ("Achievement", achievement),
            ("Independence", independence),
            ("Recognition", recognition),
            ("Relationships", relationships),
            ("Support", support),
            ("Working Conditions", workingConditions),
            ("Compensation", compensation),
            ("Advancement", advancement),
            ("Work-Life Balance", workLifeBalance),
            ("Job Security", jobSecurity),
            ("Creativity", creativity),
            ("Variety", variety),
            ("Impact", impact),
            ("Learning", learning),
            ("Challenge", challenge)
        ]

        return values.sorted { $0.1 > $1.1 }.prefix(3).map { $0.0 }
    }

    // MARK: - Initialization

    public init() {
        self.id = UUID()
        self.lastUpdated = Date()

        // Initialize all values to neutral (3)
        self.achievement = 3
        self.independence = 3
        self.recognition = 3
        self.relationships = 3
        self.support = 3
        self.workingConditions = 3
        self.compensation = 3
        self.advancement = 3
        self.workLifeBalance = 3
        self.jobSecurity = 3
        self.creativity = 3
        self.variety = 3
        self.impact = 3
        self.learning = 3
        self.challenge = 3
    }
}
```

---

### Enhanced Entity: WorkExperience

```swift
import SwiftData
import Foundation

/// Enhanced work experience with achievements and technologies
@Model
public final class WorkExperience: Sendable {

    @Attribute(.unique) public var id: UUID

    // MARK: - Basic Info

    public var jobTitle: String
    public var company: String
    public var location: String?                // NEW - "San Francisco, CA"
    public var industry: String?                // NEW - "Healthcare", "Finance", etc.
    public var employmentType: EmploymentType   // NEW - Full-time/Part-time/Contract
    public var startDate: Date
    public var endDate: Date?                   // nil = current position
    public var description_: String?            // Underscore to avoid reserved word

    // MARK: - Enhanced Fields (V8)

    public var achievements: [String]           // NEW - Bullet points of accomplishments
    public var technologiesUsed: [String]       // NEW - Tech stack/tools
    public var skillsGained: [String]           // NEW - Skills developed
    public var teamSize: Int?                   // NEW - Size of team led/worked with
    public var reportsTo: String?               // NEW - Manager title

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var isCurrent: Bool {
        endDate == nil
    }

    public var durationMonths: Int {
        let end = endDate ?? Date()
        let components = Calendar.current.dateComponents([.month], from: startDate, to: end)
        return components.month ?? 0
    }

    public var durationYears: Double {
        Double(durationMonths) / 12.0
    }

    // MARK: - Initialization

    public init(
        jobTitle: String,
        company: String,
        location: String? = nil,
        industry: String? = nil,
        employmentType: EmploymentType = .fullTime,
        startDate: Date,
        endDate: Date? = nil,
        description: String? = nil
    ) {
        self.id = UUID()
        self.jobTitle = jobTitle
        self.company = company
        self.location = location
        self.industry = industry
        self.employmentType = employmentType
        self.startDate = startDate
        self.endDate = endDate
        self.description_ = description
        self.achievements = []
        self.technologiesUsed = []
        self.skillsGained = []
    }
}

public enum EmploymentType: String, Codable, Sendable {
    case fullTime = "fullTime"
    case partTime = "partTime"
    case contract = "contract"
    case freelance = "freelance"
    case internship = "internship"
    case apprenticeship = "apprenticeship"
}
```

---

### Enhanced Entity: Education

```swift
import SwiftData
import Foundation

/// Enhanced education with GPA, honors, coursework
@Model
public final class Education: Sendable {

    @Attribute(.unique) public var id: UUID

    // MARK: - Basic Info

    public var institution: String
    public var degree: String                // "Bachelor of Science", "MBA", etc.
    public var fieldOfStudy: String          // "Computer Science", "Nursing", etc.
    public var startDate: Date
    public var endDate: Date?                // nil = in progress
    public var description_: String?

    // MARK: - Enhanced Fields (V8)

    public var gpa: Double?                  // NEW - 0.0-4.0 scale
    public var honors: [String]              // NEW - "Dean's List", "Summa Cum Laude"
    public var relevantCoursework: [String]  // NEW - Key courses taken
    public var activities: [String]          // NEW - Clubs, sports, leadership
    public var thesis: String?               // NEW - Thesis/capstone title

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var isInProgress: Bool {
        endDate == nil
    }

    public var durationYears: Int {
        let end = endDate ?? Date()
        let components = Calendar.current.dateComponents([.year], from: startDate, to: end)
        return components.year ?? 0
    }

    // MARK: - Initialization

    public init(
        institution: String,
        degree: String,
        fieldOfStudy: String,
        startDate: Date,
        endDate: Date? = nil
    ) {
        self.id = UUID()
        self.institution = institution
        self.degree = degree
        self.fieldOfStudy = fieldOfStudy
        self.startDate = startDate
        self.endDate = endDate
        self.honors = []
        self.relevantCoursework = []
        self.activities = []
    }
}
```

---

### New Entity: Certification

```swift
import SwiftData
import Foundation

/// Professional certification with expiration tracking
@Model
public final class Certification: Sendable {

    @Attribute(.unique) public var id: UUID

    public var name: String                  // "AWS Solutions Architect"
    public var issuer: String                // "Amazon Web Services"
    public var issueDate: Date?
    public var expirationDate: Date?
    public var credentialID: String?         // Verification ID
    public var verificationURL: String?      // URL to verify cert
    public var doesNotExpire: Bool           // Lifetime certification

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var isExpired: Bool {
        guard !doesNotExpire, let expiration = expirationDate else {
            return false
        }
        return expiration < Date()
    }

    public var isValid: Bool {
        !name.isEmpty && !issuer.isEmpty && !isExpired
    }

    public var displayStatus: String {
        if doesNotExpire {
            return "Valid (No Expiration)"
        } else if let expiration = expirationDate {
            return isExpired ? "Expired" : "Valid until \(expiration.formatted(date: .abbreviated, time: .omitted))"
        } else {
            return "Valid"
        }
    }

    // MARK: - Initialization

    public init(
        name: String,
        issuer: String,
        issueDate: Date? = nil,
        expirationDate: Date? = nil,
        doesNotExpire: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.issuer = issuer
        self.issueDate = issueDate
        self.expirationDate = expirationDate
        self.doesNotExpire = doesNotExpire
    }
}
```

---

### New Entity: License

```swift
import SwiftData
import Foundation

/// Professional license (e.g., RN, CPA, Bar License)
@Model
public final class License: Sendable {

    @Attribute(.unique) public var id: UUID

    public var name: String                  // "Registered Nurse"
    public var licenseNumber: String         // License ID
    public var issuingAuthority: String      // "California Board of Nursing"
    public var state: String?                // State/region if applicable
    public var issueDate: Date
    public var expirationDate: Date?
    public var verificationURL: String?

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var isExpired: Bool {
        guard let expiration = expirationDate else { return false }
        return expiration < Date()
    }

    public var isActive: Bool {
        !isExpired
    }

    // MARK: - Initialization

    public init(
        name: String,
        licenseNumber: String,
        issuingAuthority: String,
        issueDate: Date
    ) {
        self.id = UUID()
        self.name = name
        self.licenseNumber = licenseNumber
        self.issuingAuthority = issuingAuthority
        self.issueDate = issueDate
    }
}
```

---

### New Entity: Project

```swift
import SwiftData
import Foundation

/// Portfolio project or professional project
@Model
public final class Project: Sendable {

    @Attribute(.unique) public var id: UUID

    public var name: String
    public var description_: String
    public var highlights: [String]          // Key achievements/features
    public var technologies: [String]        // Tech stack used
    public var startDate: Date
    public var endDate: Date?                // nil = ongoing
    public var url: String?                  // Project URL
    public var repositoryURL: String?        // GitHub/GitLab link
    public var roles: [String]               // Roles played in project
    public var entity: ProjectEntity         // Personal/Company/Academic/OpenSource
    public var type: ProjectType             // Application/Website/Research/Library

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var isCurrent: Bool {
        endDate == nil
    }

    public var durationMonths: Int {
        let end = endDate ?? Date()
        let components = Calendar.current.dateComponents([.month], from: startDate, to: end)
        return components.month ?? 0
    }

    // MARK: - Initialization

    public init(
        name: String,
        description: String,
        startDate: Date,
        entity: ProjectEntity = .personal,
        type: ProjectType = .application
    ) {
        self.id = UUID()
        self.name = name
        self.description_ = description
        self.startDate = startDate
        self.entity = entity
        self.type = type
        self.highlights = []
        self.technologies = []
        self.roles = []
    }
}

public enum ProjectEntity: String, Codable, Sendable {
    case personal = "personal"
    case company = "company"
    case academic = "academic"
    case openSource = "openSource"
}

public enum ProjectType: String, Codable, Sendable {
    case application = "application"
    case website = "website"
    case research = "research"
    case library = "library"
    case tool = "tool"
    case other = "other"
}
```

---

### New Entity: VolunteerExperience

```swift
import SwiftData
import Foundation

/// Volunteer work and community involvement
@Model
public final class VolunteerExperience: Sendable {

    @Attribute(.unique) public var id: UUID

    public var organization: String
    public var role: String
    public var startDate: Date
    public var endDate: Date?                // nil = ongoing
    public var description_: String?
    public var hoursPerWeek: Int?
    public var achievements: [String]
    public var skillsUsed: [String]

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var isCurrent: Bool {
        endDate == nil
    }

    public var totalHours: Int? {
        guard let hours = hoursPerWeek else { return nil }
        let weeks = durationMonths * 4
        return hours * weeks
    }

    public var durationMonths: Int {
        let end = endDate ?? Date()
        let components = Calendar.current.dateComponents([.month], from: startDate, to: end)
        return components.month ?? 0
    }

    // MARK: - Initialization

    public init(
        organization: String,
        role: String,
        startDate: Date,
        endDate: Date? = nil
    ) {
        self.id = UUID()
        self.organization = organization
        self.role = role
        self.startDate = startDate
        self.endDate = endDate
        self.achievements = []
        self.skillsUsed = []
    }
}
```

---

### New Entity: Award

```swift
import SwiftData
import Foundation

/// Professional award or recognition
@Model
public final class Award: Sendable {

    @Attribute(.unique) public var id: UUID

    public var title: String
    public var issuer: String
    public var date: Date
    public var description_: String?

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Initialization

    public init(
        title: String,
        issuer: String,
        date: Date
    ) {
        self.id = UUID()
        self.title = title
        self.issuer = issuer
        self.date = date
    }
}
```

---

### New Entity: Publication

```swift
import SwiftData
import Foundation

/// Academic or professional publication
@Model
public final class Publication: Sendable {

    @Attribute(.unique) public var id: UUID

    public var title: String
    public var publisher: String
    public var date: Date
    public var url: String?
    public var authors: [String]             // Co-authors
    public var description_: String?

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Initialization

    public init(
        title: String,
        publisher: String,
        date: Date
    ) {
        self.id = UUID()
        self.title = title
        self.publisher = publisher
        self.date = date
        self.authors = []
    }
}
```

---

### New Entity: Training

```swift
import SwiftData
import Foundation

/// Training course, bootcamp, or online learning
@Model
public final class Training: Sendable {

    @Attribute(.unique) public var id: UUID

    public var name: String
    public var provider: String              // Udemy, Coursera, etc.
    public var category: String              // Technology, Business, etc.
    public var startDate: Date?
    public var completionDate: Date?
    public var status: TrainingStatus        // Completed/InProgress/Planned
    public var certificateURL: String?
    public var skillsLearned: [String]
    public var hoursSpent: Int?

    // MARK: - Relationship

    public var profile: UserProfile?

    // MARK: - Computed Properties

    public var isCompleted: Bool {
        status == .completed
    }

    // MARK: - Initialization

    public init(
        name: String,
        provider: String,
        category: String,
        status: TrainingStatus = .planned
    ) {
        self.id = UUID()
        self.name = name
        self.provider = provider
        self.category = category
        self.status = status
        self.skillsLearned = []
    }
}

public enum TrainingStatus: String, Codable, Sendable {
    case completed = "completed"
    case inProgress = "inProgress"
    case planned = "planned"
}
```

---

## Actor-Based Service Architecture

### ProfileService Actor

```swift
import SwiftData
import Foundation

/// Thread-safe service for UserProfile operations
/// Manages all profile CRUD operations with Swift Concurrency
@ModelActor
public actor ProfileService {

    // MARK: - Model Context

    private let modelContext: ModelContext

    // MARK: - Initialization

    public init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
    }

    // MARK: - Profile Operations

    /// Fetch the current user profile (singleton pattern)
    public func fetchCurrentProfile() throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.createdDate, order: .forward)]
        )

        let profiles = try modelContext.fetch(descriptor)
        return profiles.first
    }

    /// Create a new profile (enforces singleton)
    public func createProfile(
        name: String,
        email: String,
        currentDomain: String
    ) throws -> UserProfile {
        // Check if profile already exists
        if let existing = try fetchCurrentProfile() {
            print("⚠️ Profile already exists, returning existing profile")
            return existing
        }

        let profile = UserProfile(
            name: name,
            email: email,
            currentDomain: currentDomain
        )

        modelContext.insert(profile)
        try modelContext.save()

        print("✅ Created new UserProfile: \(profile.id)")
        return profile
    }

    /// Update profile fields
    public func updateProfile(
        _ profile: UserProfile,
        updates: (UserProfile) -> Void
    ) throws {
        updates(profile)
        profile.lastModified = Date()
        try modelContext.save()

        print("✅ Updated UserProfile: \(profile.id)")
    }

    /// Add skill to profile
    public func addSkill(
        to profile: UserProfile,
        skillName: String,
        onetSkillID: String?,
        proficiency: Int,
        yearsOfExperience: Int
    ) throws {
        let skill = UserSkill(
            skillName: skillName,
            onetSkillID: onetSkillID,
            proficiency: proficiency,
            yearsOfExperience: yearsOfExperience
        )

        profile.skills.append(skill)
        profile.lastModified = Date()
        try modelContext.save()

        print("✅ Added skill '\(skillName)' to profile")
    }

    /// Remove skill from profile
    public func removeSkill(
        from profile: UserProfile,
        skillID: UUID
    ) throws {
        guard let index = profile.skills.firstIndex(where: { $0.id == skillID }) else {
            print("⚠️ Skill not found: \(skillID)")
            return
        }

        let skill = profile.skills[index]
        profile.skills.remove(at: index)
        modelContext.delete(skill)
        profile.lastModified = Date()
        try modelContext.save()

        print("✅ Removed skill from profile")
    }

    /// Add work experience
    public func addWorkExperience(
        to profile: UserProfile,
        experience: WorkExperience
    ) throws {
        profile.workExperiences.append(experience)
        profile.lastModified = Date()
        try modelContext.save()

        print("✅ Added work experience: \(experience.jobTitle) at \(experience.company)")
    }

    /// Add education
    public func addEducation(
        to profile: UserProfile,
        education: Education
    ) throws {
        profile.educations.append(education)
        profile.lastModified = Date()
        try modelContext.save()

        print("✅ Added education: \(education.degree) from \(education.institution)")
    }

    /// Add certification
    public func addCertification(
        to profile: UserProfile,
        certification: Certification
    ) throws {
        profile.certifications.append(certification)
        profile.lastModified = Date()
        try modelContext.save()

        print("✅ Added certification: \(certification.name)")
    }

    /// Calculate and update profile completeness
    public func updateCompleteness(_ profile: UserProfile) throws {
        // Completeness is computed property, just trigger save
        profile.lastModified = Date()
        try modelContext.save()

        print("✅ Profile completeness: \(profile.completenessScore)%")
    }

    /// Delete profile (with cascade)
    public func deleteProfile(_ profile: UserProfile) throws {
        modelContext.delete(profile)
        try modelContext.save()

        print("✅ Deleted UserProfile: \(profile.id)")
    }
}
```

---

### ONetService Actor

```swift
import SwiftData
import Foundation

/// Service for O*NET skills, abilities, and occupation data
/// Provides read-only access to O*NET 30.0 taxonomy
public actor ONetService {

    // MARK: - Configuration

    private let skillsJSONPath: String
    private var cachedSkills: [ONetSkill]?

    // MARK: - Initialization

    public init(skillsJSONPath: String = "Data/ONET_Skills/skills_v2_complete.json") {
        self.skillsJSONPath = skillsJSONPath
    }

    // MARK: - Skills Operations

    /// Load all O*NET skills from JSON
    public func loadSkills() async throws -> [ONetSkill] {
        if let cached = cachedSkills {
            return cached
        }

        // Load from bundle
        guard let url = Bundle.main.url(forResource: "skills_v2_complete", withExtension: "json", subdirectory: "Data/ONET_Skills") else {
            throw ONetError.skillsFileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let skillsData = try decoder.decode(SkillsData.self, from: data)

        let skills = skillsData.skills.map { ONetSkill(from: $0) }
        cachedSkills = skills

        print("✅ Loaded \(skills.count) O*NET skills")
        return skills
    }

    /// Search skills by name
    public func searchSkills(query: String) async throws -> [ONetSkill] {
        let allSkills = try await loadSkills()
        let lowercased = query.lowercased()

        return allSkills.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.keywords.contains { $0.lowercased().contains(lowercased) }
        }
    }

    /// Get skill by ID
    public func getSkill(id: String) async throws -> ONetSkill? {
        let allSkills = try await loadSkills()
        return allSkills.first { $0.id == id }
    }

    /// Get skills by category
    public func getSkills(category: String) async throws -> [ONetSkill] {
        let allSkills = try await loadSkills()
        return allSkills.filter { $0.category == category }
    }

    /// Get all skill categories
    public func getCategories() async throws -> [String] {
        let allSkills = try await loadSkills()
        let categories = Set(allSkills.map { $0.category })
        return Array(categories).sorted()
    }
}

// MARK: - Supporting Types

public struct ONetSkill: Sendable, Codable {
    public let id: String
    public let name: String
    public let category: String
    public let keywords: [String]
    public let relatedSkills: [String]

    init(from skillData: SkillData) {
        self.id = skillData.id
        self.name = skillData.name
        self.category = skillData.category
        self.keywords = skillData.keywords
        self.relatedSkills = skillData.relatedSkills
    }
}

struct SkillsData: Codable {
    let skills: [SkillData]
}

struct SkillData: Codable {
    let id: String
    let name: String
    let category: String
    let keywords: [String]
    let relatedSkills: [String]
}

enum ONetError: Error {
    case skillsFileNotFound
    case invalidData
}
```

---

## Foundation Models Integration

### Resume Parsing with Foundation Models

```swift
import Foundation
import FoundationModels

/// Foundation Models integration for resume parsing
/// Replaces OpenAI API with on-device AI (iOS 26)
public actor ResumeParsingService {

    // MARK: - Foundation Models

    private let embeddingModel: EmbeddingModel
    private let generationModel: GenerationModel

    // MARK: - Services

    private let onetService: ONetService

    // MARK: - Initialization

    public init() async throws {
        // Initialize Foundation Models (on-device)
        self.embeddingModel = try await EmbeddingModel()
        self.generationModel = try await GenerationModel()
        self.onetService = ONetService()
    }

    // MARK: - Resume Parsing

    /// Parse resume text and extract profile data
    /// Uses Foundation Models for on-device AI processing
    public func parseResume(_ resumeText: String) async throws -> ParsedProfile {
        print("📄 Parsing resume with Foundation Models...")

        // Step 1: Extract structured data using @Generable models
        let parsed = try await extractStructuredData(resumeText)

        // Step 2: Match skills to O*NET taxonomy
        let matchedSkills = try await matchSkillsToONet(parsed.skills)

        // Step 3: Infer abilities from work history
        let abilitiesProfile = try await inferAbilities(parsed)

        // Step 4: Infer RIASEC interests from career history
        let riasecProfile = try await inferRIASEC(parsed)

        print("✅ Resume parsing complete")

        return ParsedProfile(
            personalInfo: parsed.personalInfo,
            skills: matchedSkills,
            workExperiences: parsed.workExperiences,
            educations: parsed.educations,
            certifications: parsed.certifications,
            projects: parsed.projects,
            abilitiesProfile: abilitiesProfile,
            riasecProfile: riasecProfile
        )
    }

    // MARK: - Private Methods

    private func extractStructuredData(_ resumeText: String) async throws -> ParsedResumeData {
        // Use Foundation Models @Generable protocol
        // This replaces OpenAI API calls with on-device processing

        let prompt = """
        Extract structured data from the following resume:

        \(resumeText)

        Identify:
        - Personal information (name, email, phone, location)
        - Skills (technical and soft skills)
        - Work experience (company, title, dates, responsibilities)
        - Education (institution, degree, field, dates)
        - Certifications (name, issuer, date)
        - Projects (name, description, technologies)
        """

        // Generate structured output
        let response = try await generationModel.generate(
            prompt: prompt,
            maxTokens: 2000,
            temperature: 0.1  // Low temperature for factual extraction
        )

        // Parse response into structured model
        return try parseResponse(response)
    }

    private func matchSkillsToONet(_ extractedSkills: [String]) async throws -> [UserSkill] {
        print("🔍 Matching \(extractedSkills.count) skills to O*NET taxonomy...")

        var matchedSkills: [UserSkill] = []

        for skillName in extractedSkills {
            // Search O*NET database
            let onetMatches = try await onetService.searchSkills(query: skillName)

            if let bestMatch = onetMatches.first {
                // Create UserSkill with O*NET reference
                let userSkill = UserSkill(
                    skillName: bestMatch.name,
                    onetSkillID: bestMatch.id,
                    proficiency: 3,  // Default to intermediate
                    yearsOfExperience: 0,
                    context: .work,
                    isCoreSkill: false,
                    interest: 3
                )
                userSkill.source = .resumeParsed
                matchedSkills.append(userSkill)

                print("  ✅ Matched '\(skillName)' → O*NET: '\(bestMatch.name)' (\(bestMatch.id))")
            } else {
                // No O*NET match, add as custom skill
                let userSkill = UserSkill(
                    skillName: skillName,
                    onetSkillID: nil,
                    proficiency: 3,
                    yearsOfExperience: 0,
                    context: .work,
                    isCoreSkill: false,
                    interest: 3
                )
                userSkill.source = .resumeParsed
                matchedSkills.append(userSkill)

                print("  ⚠️ No O*NET match for '\(skillName)' - added as custom skill")
            }
        }

        return matchedSkills
    }

    private func inferAbilities(_ parsed: ParsedResumeData) async throws -> AbilitiesProfile {
        // Use Foundation Models to infer O*NET abilities from work history
        // Example: "Managed team of 10" → High Coordination, Oral Expression

        let profile = AbilitiesProfile()

        // Analyze work experience for ability indicators
        let workHistory = parsed.workExperiences.map { exp in
            "\(exp.jobTitle) at \(exp.company): \(exp.description_ ?? "")"
        }.joined(separator: "\n")

        let prompt = """
        Based on this work history, rate the person's abilities on a scale of 1-5:

        \(workHistory)

        Rate these cognitive abilities:
        - Oral Comprehension, Written Comprehension, Oral Expression, Written Expression
        - Problem Sensitivity, Deductive Reasoning, Inductive Reasoning
        - Mathematical Reasoning, Critical Thinking

        Provide ratings as JSON: {"oralComprehension": 4, "writtenComprehension": 5, ...}
        """

        let response = try await generationModel.generate(
            prompt: prompt,
            maxTokens: 500,
            temperature: 0.2
        )

        // Parse ratings and update profile
        // (Implementation would parse JSON response and update AbilitiesProfile)

        return profile
    }

    private func inferRIASEC(_ parsed: ParsedResumeData) async throws -> RIASECProfile {
        // Infer Holland Codes from career history

        let profile = RIASECProfile()

        let careerSummary = parsed.workExperiences.map { exp in
            "\(exp.jobTitle): \(exp.description_ ?? "")"
        }.joined(separator: "\n")

        let prompt = """
        Based on this career history, score RIASEC interests (0-100):

        \(careerSummary)

        - Realistic: Hands-on, mechanical work
        - Investigative: Research, problem-solving
        - Artistic: Creative, expressive work
        - Social: Helping, teaching people
        - Enterprising: Leadership, business
        - Conventional: Organized, structured work

        Provide scores as JSON: {"realistic": 30, "investigative": 80, ...}
        """

        let response = try await generationModel.generate(
            prompt: prompt,
            maxTokens: 300,
            temperature: 0.2
        )

        // Parse scores and update profile
        // (Implementation would parse JSON response)

        return profile
    }

    private func parseResponse(_ response: String) throws -> ParsedResumeData {
        // Parse Foundation Models response into structured data
        // This is a placeholder - actual implementation would use JSONDecoder

        // For now, return empty data
        return ParsedResumeData(
            personalInfo: PersonalInfo(name: "", email: ""),
            skills: [],
            workExperiences: [],
            educations: [],
            certifications: [],
            projects: []
        )
    }
}

// MARK: - Supporting Types

struct ParsedProfile {
    let personalInfo: PersonalInfo
    let skills: [UserSkill]
    let workExperiences: [WorkExperience]
    let educations: [Education]
    let certifications: [Certification]
    let projects: [Project]
    let abilitiesProfile: AbilitiesProfile
    let riasecProfile: RIASECProfile
}

struct ParsedResumeData {
    let personalInfo: PersonalInfo
    let skills: [String]
    let workExperiences: [WorkExperience]
    let educations: [Education]
    let certifications: [Certification]
    let projects: [Project]
}

struct PersonalInfo {
    let name: String
    let email: String
    var phone: String?
    var location: String?
}
```

---

## Migration Strategy

### Core Data to SwiftData Migration

**Challenge**: Migrate existing V7 Core Data UserProfile to V8 SwiftData models without data loss.

**Strategy**: Multi-phase migration with validation at each step.

#### Phase 1: Parallel Data Layer (Weeks 1-2)

```swift
/// Migration coordinator for V7 → V8 profile migration
public actor ProfileMigrationCoordinator {

    // MARK: - Data Contexts

    private let coreDataContext: NSManagedObjectContext  // V7
    private let swiftDataContext: ModelContext           // V8

    // MARK: - Migration Status

    public enum MigrationStatus {
        case notStarted
        case inProgress(progress: Double)
        case completed
        case failed(error: Error)
    }

    private var status: MigrationStatus = .notStarted

    // MARK: - Initialization

    public init(
        coreDataContext: NSManagedObjectContext,
        swiftDataContainer: ModelContainer
    ) {
        self.coreDataContext = coreDataContext
        self.swiftDataContext = ModelContext(swiftDataContainer)
    }

    // MARK: - Migration

    /// Migrate V7 Core Data profile to V8 SwiftData
    public func migrateProfile() async throws {
        print("🔄 Starting V7 → V8 profile migration...")
        status = .inProgress(progress: 0.0)

        // Step 1: Fetch V7 profile
        guard let v7Profile = fetchV7Profile() else {
            throw MigrationError.noProfileFound
        }
        print("  ✅ Found V7 profile: \(v7Profile.name)")
        status = .inProgress(progress: 0.1)

        // Step 2: Create V8 profile with basic fields
        let v8Profile = try migrateBasicFields(v7Profile)
        print("  ✅ Migrated basic fields")
        status = .inProgress(progress: 0.3)

        // Step 3: Migrate skills (if any)
        try await migrateSkills(from: v7Profile, to: v8Profile)
        print("  ✅ Migrated skills")
        status = .inProgress(progress: 0.5)

        // Step 4: Create default profiles for new V8 entities
        try createDefaultProfiles(for: v8Profile)
        print("  ✅ Created default profiles")
        status = .inProgress(progress: 0.7)

        // Step 5: Save V8 profile
        try swiftDataContext.save()
        print("  ✅ Saved V8 profile")
        status = .inProgress(progress: 0.9)

        // Step 6: Validate migration
        try validateMigration(v7: v7Profile, v8: v8Profile)
        print("  ✅ Validation passed")

        status = .completed
        print("✅ Migration complete!")
    }

    // MARK: - Private Methods

    private func fetchV7Profile() -> V7UserProfile? {
        let request = NSFetchRequest<V7UserProfile>(entityName: "UserProfile")
        request.fetchLimit = 1

        do {
            let profiles = try coreDataContext.fetch(request)
            return profiles.first
        } catch {
            print("❌ Failed to fetch V7 profile: \(error)")
            return nil
        }
    }

    private func migrateBasicFields(_ v7: V7UserProfile) throws -> UserProfile {
        let v8 = UserProfile(
            name: v7.name,
            email: v7.email,
            currentDomain: v7.currentDomain
        )

        // Migrate simple fields
        v8.createdDate = v7.createdDate
        v8.lastModified = v7.lastModified
        v8.desiredRoles = v7.desiredRoles ?? []
        v8.locations = v7.locations ?? []
        v8.amberTealPosition = v7.amberTealPosition

        // Map experience level
        v8.experienceLevel = ExperienceLevel(rawValue: v7.experienceLevel) ?? .mid

        // Map remote preference
        v8.remotePreference = RemotePreference(rawValue: v7.remotePreference) ?? .flexible

        // Set defaults for new V8 fields
        v8.careerStage = .exploring
        v8.yearsOfExperience = estimateYearsOfExperience(v7.experienceLevel)
        v8.workSchedulePreference = .fullTime
        v8.willingToRelocate = false

        swiftDataContext.insert(v8)
        return v8
    }

    private func migrateSkills(from v7: V7UserProfile, to v8: UserProfile) async throws {
        // V7 doesn't have skills, so we'll leave this empty
        // Skills will be populated via resume parsing or manual entry
        print("  ℹ️ No skills to migrate (V7 didn't track skills)")
    }

    private func createDefaultProfiles(for profile: UserProfile) throws {
        // Create default AbilitiesProfile (all neutral 3s)
        let abilities = AbilitiesProfile()
        profile.abilitiesProfile = abilities

        // Create default RIASECProfile (all neutral 50s)
        let riasec = RIASECProfile()
        profile.riasecProfile = riasec

        // Create default WorkValues (all neutral 3s)
        let values = WorkValues()
        profile.workValues = values
    }

    private func validateMigration(v7: V7UserProfile, v8: UserProfile) throws {
        // Validate critical fields
        guard v8.name == v7.name else {
            throw MigrationError.validationFailed("Name mismatch")
        }

        guard v8.email == v7.email else {
            throw MigrationError.validationFailed("Email mismatch")
        }

        guard v8.currentDomain == v7.currentDomain else {
            throw MigrationError.validationFailed("Domain mismatch")
        }

        print("  ✅ All validation checks passed")
    }

    private func estimateYearsOfExperience(_ level: String) -> Int {
        switch level {
        case "entry": return 1
        case "mid": return 4
        case "senior": return 7
        case "lead": return 10
        case "executive": return 15
        default: return 0
        }
    }
}

// MARK: - Errors

enum MigrationError: LocalizedError {
    case noProfileFound
    case validationFailed(String)

    var errorDescription: String? {
        switch self {
        case .noProfileFound:
            return "No V7 profile found to migrate"
        case .validationFailed(let reason):
            return "Migration validation failed: \(reason)"
        }
    }
}
```

#### Phase 2: Data Validation (Week 3)

```swift
/// Validation service to ensure data integrity
public actor ProfileValidationService {

    /// Validate profile completeness and data integrity
    public func validateProfile(_ profile: UserProfile) throws -> ValidationReport {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []

        // Validate required fields
        if profile.name.isEmpty {
            errors.append(.requiredFieldMissing("name"))
        }

        if profile.email.isEmpty {
            errors.append(.requiredFieldMissing("email"))
        } else if !isValidEmail(profile.email) {
            errors.append(.invalidEmailFormat)
        }

        if profile.currentDomain.isEmpty {
            errors.append(.requiredFieldMissing("currentDomain"))
        }

        // Validate ranges
        if profile.amberTealPosition < 0 || profile.amberTealPosition > 1 {
            errors.append(.invalidRange("amberTealPosition", expected: "0.0-1.0"))
        }

        // Validate relationships
        if profile.skills.isEmpty {
            warnings.append(.noSkillsAdded)
        }

        if profile.workExperiences.isEmpty {
            warnings.append(.noWorkExperienceAdded)
        }

        // Validate certifications expiration
        for cert in profile.certifications where cert.isExpired {
            warnings.append(.expiredCertification(cert.name))
        }

        return ValidationReport(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            completenessScore: profile.completenessScore
        )
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

struct ValidationReport {
    let isValid: Bool
    let errors: [ValidationError]
    let warnings: [ValidationWarning]
    let completenessScore: Int
}

enum ValidationError: LocalizedError {
    case requiredFieldMissing(String)
    case invalidEmailFormat
    case invalidRange(String, expected: String)

    var errorDescription: String? {
        switch self {
        case .requiredFieldMissing(let field):
            return "Required field missing: \(field)"
        case .invalidEmailFormat:
            return "Invalid email format"
        case .invalidRange(let field, let expected):
            return "Invalid range for \(field), expected: \(expected)"
        }
    }
}

enum ValidationWarning {
    case noSkillsAdded
    case noWorkExperienceAdded
    case expiredCertification(String)
}
```

---

## Privacy & Security

### Data Classification

| Data Type | Privacy Level | Storage | Encryption |
|-----------|--------------|---------|------------|
| Name, Email | Sensitive | SwiftData | At-rest encryption (iOS default) |
| Phone Number | Highly Sensitive | SwiftData + Keychain option | Keychain if user enables |
| Salary Expectations | Highly Sensitive | SwiftData (optional field) | At-rest encryption |
| Skills, Experience | Standard | SwiftData | At-rest encryption |
| Abilities, RIASEC | Standard | SwiftData | At-rest encryption |
| Resume Text | Sensitive | Temporary (discarded after parsing) | Not stored |

### Privacy-First Design

```swift
/// Privacy manager for sensitive profile data
public actor ProfilePrivacyService {

    // MARK: - Keychain Storage

    private let keychain = KeychainManager()

    // MARK: - Privacy Settings

    public enum PrivacyLevel {
        case minimal        // Only name, skills
        case standard       // + email, location, experience
        case complete       // + phone, salary, full history
    }

    /// Store phone number in Keychain (optional enhanced security)
    public func storePhoneSecurely(_ phone: String, profileID: UUID) throws {
        try keychain.save(
            key: "profile_\(profileID.uuidString)_phone",
            value: phone.data(using: .utf8)!
        )
    }

    /// Retrieve phone from Keychain
    public func retrievePhone(profileID: UUID) throws -> String? {
        guard let data = try keychain.retrieve(key: "profile_\(profileID.uuidString)_phone") else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Anonymize profile for privacy (removes PII)
    public func anonymizeProfile(_ profile: UserProfile) -> AnonymizedProfile {
        return AnonymizedProfile(
            skills: profile.skills.map { $0.skillName },
            experienceLevel: profile.experienceLevel,
            domain: profile.currentDomain,
            yearsOfExperience: profile.yearsOfExperience,
            completenessScore: profile.completenessScore
        )
    }
}

struct AnonymizedProfile {
    let skills: [String]
    let experienceLevel: ExperienceLevel
    let domain: String
    let yearsOfExperience: Int
    let completenessScore: Int
}
```

### On-Device Processing Guarantee

All AI processing uses iOS 26 Foundation Models:
- Resume parsing: 100% on-device
- Skills extraction: 100% on-device
- Abilities inference: 100% on-device
- RIASEC scoring: 100% on-device

**No data leaves the device** for AI processing.

---

## Performance Budgets

### Sacred Constraint: <10ms Thompson Sampling

**Challenge**: V8 profile has 45+ fields and 12 entities. Must maintain Thompson performance.

**Solution**: Optimized fetching with SwiftData prefetch descriptors.

```swift
/// High-performance profile fetcher for Thompson Sampling
public actor ThompsonProfileService {

    private let modelContext: ModelContext

    public init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
    }

    /// Fetch profile data optimized for Thompson Sampling
    /// MUST complete in <10ms
    public func fetchForThompson() throws -> ThompsonProfileData {
        let startTime = CFAbsoluteTimeGetCurrent()

        // Fetch with specific fields only (not full relationships)
        let descriptor = FetchDescriptor<UserProfile>(
            predicate: nil,
            sortBy: [SortDescriptor(\.createdDate, order: .forward)]
        )

        guard let profile = try modelContext.fetch(descriptor).first else {
            throw ThompsonError.noProfile
        }

        // Extract only what Thompson needs (minimal data)
        let data = ThompsonProfileData(
            currentDomain: profile.currentDomain,
            experienceLevel: profile.experienceLevel,
            topSkills: Array(profile.skills.prefix(10).map { $0.skillName }),
            amberTealPosition: profile.amberTealPosition
        )

        let duration = (CFAbsoluteTimeGetCurrent() - startTime) * 1000 // ms
        print("⚡ Thompson profile fetch: \(String(format: "%.2f", duration))ms")

        if duration > 10.0 {
            print("⚠️ WARNING: Thompson fetch exceeded 10ms budget!")
        }

        return data
    }
}

struct ThompsonProfileData: Sendable {
    let currentDomain: String
    let experienceLevel: ExperienceLevel
    let topSkills: [String]
    let amberTealPosition: Double
}

enum ThompsonError: Error {
    case noProfile
    case fetchTooSlow
}
```

### Memory Budget: <200MB

**Strategy**: Lazy loading of relationships, pagination for large collections.

```swift
extension UserProfile {

    /// Load work experiences with pagination
    public func loadWorkExperiences(limit: Int = 10, offset: Int = 0) -> [WorkExperience] {
        let sorted = workExperiences.sorted { $0.startDate > $1.startDate }
        let start = min(offset, sorted.count)
        let end = min(offset + limit, sorted.count)
        return Array(sorted[start..<end])
    }

    /// Load recent skills only
    public func loadRecentSkills(limit: Int = 20) -> [UserSkill] {
        let sorted = skills.sorted { $0.dateAdded > $1.dateAdded }
        return Array(sorted.prefix(limit))
    }
}
```

### Disk Usage Budget: <50MB for profile data

**Monitoring**: Track SwiftData store size.

```swift
public actor ProfileStorageMonitor {

    public func getStorageSize() -> Int64 {
        // Get SwiftData store file size
        let storeURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("default.store")

        guard let url = storeURL,
              let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? Int64 else {
            return 0
        }

        let sizeMB = Double(size) / 1_000_000.0
        print("💾 Profile storage: \(String(format: "%.2f", sizeMB)) MB")

        if size > 50_000_000 {
            print("⚠️ WARNING: Profile storage exceeds 50MB budget!")
        }

        return size
    }
}
```

---

## Implementation Roadmap

### Week 1-2: Core Model Implementation
- [ ] Define all SwiftData models (UserProfile, Skills, Abilities, RIASEC, etc.)
- [ ] Create actor-based services (ProfileService, ONetService)
- [ ] Implement validation logic
- [ ] Unit tests for all models

### Week 3-4: Migration System
- [ ] Build Core Data → SwiftData migration coordinator
- [ ] Implement validation service
- [ ] Test migration with sample V7 data
- [ ] Zero data loss verification

### Week 5-6: Foundation Models Integration
- [ ] Implement ResumeParsingService with Foundation Models
- [ ] Build skills matching to O*NET
- [ ] Implement abilities inference
- [ ] Implement RIASEC inference

### Week 7-8: UI Integration
- [ ] Update onboarding flow for new fields
- [ ] Build profile editing screens
- [ ] Implement abilities assessment UI
- [ ] Implement RIASEC assessment UI

### Week 9-10: Performance Optimization
- [ ] Optimize Thompson Sampling queries (<10ms)
- [ ] Implement lazy loading for relationships
- [ ] Memory profiling and optimization
- [ ] Storage monitoring

### Week 11-12: Testing & Validation
- [ ] End-to-end testing with real resumes
- [ ] Performance regression testing
- [ ] Privacy audit
- [ ] Migration testing with production data snapshots

---

## Success Metrics

| Metric | Target | Validation Method |
|--------|--------|-------------------|
| Profile Completeness | 95/100 | Automated scoring |
| O*NET Skills Coverage | 3,864 skills | Database count |
| Migration Success Rate | 100% (zero data loss) | Validation tests |
| Thompson Fetch Time | <10ms | Performance profiling |
| Memory Footprint | <200MB | Instruments monitoring |
| Storage Size | <50MB | File size monitoring |
| AI Processing | 100% on-device | Network monitoring (should be zero) |
| Resume Parsing Accuracy | >90% | Manual validation with 100 resumes |

---

## Appendix

### File Structure

```
Packages/V8Data/
├── Sources/V8Data/
│   ├── Models/
│   │   ├── UserProfile.swift
│   │   ├── UserSkill.swift
│   │   ├── AbilitiesProfile.swift
│   │   ├── RIASECProfile.swift
│   │   ├── WorkValues.swift
│   │   ├── WorkExperience.swift
│   │   ├── Education.swift
│   │   ├── Certification.swift
│   │   ├── License.swift
│   │   ├── Project.swift
│   │   ├── VolunteerExperience.swift
│   │   ├── Award.swift
│   │   ├── Publication.swift
│   │   └── Training.swift
│   │
│   ├── Services/
│   │   ├── ProfileService.swift
│   │   ├── ONetService.swift
│   │   ├── ProfileValidationService.swift
│   │   ├── ProfilePrivacyService.swift
│   │   ├── ThompsonProfileService.swift
│   │   └── ProfileStorageMonitor.swift
│   │
│   └── Migration/
│       └── ProfileMigrationCoordinator.swift
│
Packages/V8FoundationModels/
└── Sources/V8FoundationModels/
    └── Services/
        └── ResumeParsingService.swift
```

### Dependencies

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
],
targets: [
    .target(
        name: "V8Data",
        dependencies: [
            .product(name: "Collections", package: "swift-collections"),
        ]
    ),
]
```

---

**End of Technical Specification**

**Next Steps**:
1. Review and approve architecture
2. Begin Phase 1 implementation (Core Models)
3. Set up CI/CD for automated testing
4. Schedule weekly architecture reviews

**Questions/Feedback**: Contact V8 Architecture Team
