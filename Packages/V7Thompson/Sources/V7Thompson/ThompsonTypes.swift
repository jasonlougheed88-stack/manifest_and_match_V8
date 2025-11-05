// ThompsonTypes.swift - V7Thompson Module
// Types specific to Thompson Sampling implementation
//
// O*NET Phase 2B (October 28, 2025): Enhanced UserProfile with O*NET professional data
// for improved career matching and Thompson Sampling accuracy

import Foundation
import V7Core  // O*NET data models (RIASECProfile, etc.)

// MARK: - Job Model (Enhanced for Full Display Pipeline)

/// Job structure for Thompson Sampling scoring + UI display
/// ✅ PHASE 1.2A: Enhanced with 9 new fields to support rich job card display
/// This is the single source of truth flowing through: API → Thompson → UI
public struct Job: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let company: String
    public let location: String
    public let description: String
    public let requirements: [String]
    public let url: URL
    public var thompsonScore: ThompsonScore?
    public let sector: String
    public var matchScore: Double

    /// O*NET occupation code for enhanced career matching (Phase 3)
    /// Format: "15-1252.00" (SOC 2018 code)
    /// Optional - if nil, O*NET scoring is skipped
    public let onetCode: String?

    // ✅ NEW FIELDS - Phase 1.2A: Enhanced display data
    public let benefits: [String]          // Benefits offered (health, 401k, etc.)
    public let jobType: String?            // "full_time", "part_time", "contract", "internship"
    public let experienceLevel: String?    // "entry_level", "mid_level", "senior_level"
    public let postedDate: Date?           // When job was posted
    public let isRemote: Bool              // Remote vs onsite
    public let salary: String?             // Formatted salary range

    // ✅ NEW FIELDS - Phase 1.2A: AI-enhanced fields from ParsedJobMetadata
    public let requiredSkills: [String]    // AI-parsed required skills (must-haves)
    public let preferredSkills: [String]   // AI-parsed preferred skills (nice-to-haves)
    public let experienceYears: String?    // Formatted experience range (e.g., "3-5 years")

    public init(
        id: UUID = UUID(),
        title: String,
        company: String,
        location: String = "Remote",
        description: String = "",
        requirements: [String] = [],
        url: URL? = nil,
        thompsonScore: ThompsonScore? = nil,
        sector: String = "Technology",
        matchScore: Double = 0.50,
        onetCode: String? = nil,
        benefits: [String] = [],
        jobType: String? = nil,
        experienceLevel: String? = nil,
        postedDate: Date? = nil,
        isRemote: Bool = false,
        salary: String? = nil,
        requiredSkills: [String] = [],
        preferredSkills: [String] = [],
        experienceYears: String? = nil
    ) {
        self.id = id
        self.title = title
        self.company = company
        self.location = location
        self.description = description
        self.requirements = requirements
        self.url = url ?? URL(string: "https://example.com")!
        self.thompsonScore = thompsonScore
        self.sector = sector
        self.matchScore = matchScore
        self.onetCode = onetCode
        self.benefits = benefits
        self.jobType = jobType
        self.experienceLevel = experienceLevel
        self.postedDate = postedDate
        self.isRemote = isRemote
        self.salary = salary
        self.requiredSkills = requiredSkills
        self.preferredSkills = preferredSkills
        self.experienceYears = experienceYears
    }
}

// MARK: - Thompson Sampling Types

/// Thompson Sampling score components
public struct ThompsonScore: Codable, Equatable, Sendable {
    public let personalScore: Double
    public let professionalScore: Double
    public let combinedScore: Double
    public let explorationBonus: Double
    public let timestamp: Date

    public init(
        personalScore: Double,
        professionalScore: Double,
        combinedScore: Double,
        explorationBonus: Double,
        timestamp: Date = Date()
    ) {
        self.personalScore = personalScore
        self.professionalScore = professionalScore
        self.combinedScore = combinedScore
        self.explorationBonus = explorationBonus
        self.timestamp = timestamp
    }
}

/// Beta distribution parameters for dual-profile system
public struct BetaParameters: Codable, Equatable, Sendable {
    public var personalAlpha: Double
    public var personalBeta: Double
    public var professionalAlpha: Double
    public var professionalBeta: Double

    public init(
        personalAlpha: Double = 1.0,
        personalBeta: Double = 1.0,
        professionalAlpha: Double = 1.0,
        professionalBeta: Double = 1.0
    ) {
        self.personalAlpha = personalAlpha
        self.personalBeta = personalBeta
        self.professionalAlpha = professionalAlpha
        self.professionalBeta = professionalBeta
    }
}

/// User interaction with a job
public struct JobInteraction: Codable, Equatable, Sendable {
    public let jobId: UUID
    public let action: SwipeAction
    public let timestamp: Date
    public let thompsonScore: ThompsonScore?

    public init(
        jobId: UUID,
        action: SwipeAction,
        timestamp: Date = Date(),
        thompsonScore: ThompsonScore? = nil
    ) {
        self.jobId = jobId
        self.action = action
        self.timestamp = timestamp
        self.thompsonScore = thompsonScore
    }
}

/// Swipe actions for job cards
public enum SwipeAction: String, Codable, Sendable {
    case interested
    case pass
    case save
}

// MARK: - User Profile (Simplified)

/// Simplified user profile for Thompson Sampling
public struct UserProfile: Sendable {
    public let id: UUID
    public var preferences: UserPreferences
    public var professionalProfile: ProfessionalProfile

    public init(
        id: UUID = UUID(),
        preferences: UserPreferences = UserPreferences(),
        professionalProfile: ProfessionalProfile = ProfessionalProfile()
    ) {
        self.id = id
        self.preferences = preferences
        self.professionalProfile = professionalProfile
    }
}

/// User preferences for job matching
public struct UserPreferences: Sendable {
    public var preferredLocations: [String]
    public var industries: [String]

    public init(
        preferredLocations: [String] = [],
        industries: [String] = []
    ) {
        self.preferredLocations = preferredLocations
        self.industries = industries
    }
}

/// Professional profile information
///
/// **O*NET Phase 2B Enhancements:**
/// Extended with O*NET professional data for enhanced career matching.
/// All new fields are optional to maintain backward compatibility with existing profiles.
///
/// **Data Sources:**
/// - educationLevel: Maps to O*NET 1-12 education scale
/// - yearsOfExperience: Calculated from work history
/// - workActivities: 41 O*NET work activities (importance scores 0.0-7.0)
/// - interests: RIASEC personality profile (6 dimensions)
/// - abilities: 52 O*NET abilities (proficiency scores 0.0-7.0)
public struct ProfessionalProfile: Sendable {
    // MARK: - Original Fields

    /// User's professional skills (extracted from resume or manually entered)
    public var skills: [String]

    // MARK: - O*NET Phase 2B Fields (All Optional for Backward Compatibility)

    /// Education level on O*NET 1-12 scale:
    /// - 1: Less than high school diploma
    /// - 4: High school diploma or equivalent
    /// - 6: Some college, no degree
    /// - 7: Associate's degree
    /// - 8: Bachelor's degree
    /// - 10: Master's degree
    /// - 11: Post-master's certificate
    /// - 12: Doctoral degree
    ///
    /// See: ONetDataModels.swift EducationRequirements
    public var educationLevel: Int?

    /// Years of relevant work experience (calculated from work history)
    public var yearsOfExperience: Double?

    /// O*NET work activities profile (41 activities)
    ///
    /// Maps activity ID (e.g., "4.A.2.a.4") to importance score (0.0-7.0).
    /// Activities describe HOW people work, enabling cross-domain career discovery.
    ///
    /// **Example:**
    /// - "4.A.2.a.4": 6.5 (Analyzing Data or Information - high importance)
    /// - "4.A.1.a.1": 5.0 (Getting Information - moderate importance)
    ///
    /// See: ONetDataModels.swift OccupationWorkActivities
    public var workActivities: [String: Double]?

    /// RIASEC personality profile (Holland Code: Realistic, Investigative, Artistic, Social, Enterprising, Conventional)
    ///
    /// Used for personality-based career matching. Each dimension scored 0.0-7.0.
    ///
    /// **Example Holland Codes:**
    /// - "RIA": Realistic-Investigative-Artistic (e.g., Architect)
    /// - "SEC": Social-Enterprising-Conventional (e.g., HR Manager)
    ///
    /// See: ONetDataModels.swift RIASECProfile
    public var interests: RIASECProfile?

    /// O*NET abilities profile (52 abilities)
    ///
    /// Maps ability ID (e.g., "1.A.1.a.1") to proficiency score (0.0-7.0).
    /// Includes cognitive, physical, and sensory capabilities.
    ///
    /// **Example:**
    /// - "1.A.1.a.1": 6.0 (Oral Comprehension - high proficiency)
    /// - "1.A.2.a.1": 5.5 (Written Comprehension - moderate-high proficiency)
    ///
    /// See: ONetDataModels.swift OccupationAbilities
    public var abilities: [String: Double]?

    // MARK: - Initialization

    public init(
        skills: [String] = [],
        educationLevel: Int? = nil,
        yearsOfExperience: Double? = nil,
        workActivities: [String: Double]? = nil,
        interests: RIASECProfile? = nil,
        abilities: [String: Double]? = nil
    ) {
        self.skills = skills
        self.educationLevel = educationLevel
        self.yearsOfExperience = yearsOfExperience
        self.workActivities = workActivities
        self.interests = interests
        self.abilities = abilities
    }
}