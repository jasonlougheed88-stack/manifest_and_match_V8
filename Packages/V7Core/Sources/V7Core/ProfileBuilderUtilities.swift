// ProfileBuilderUtilities.swift - V7Core Module
// Pure utility functions for building enhanced ProfessionalProfile with O*NET data
//
// O*NET Phase 2B (October 28, 2025): Profile enhancement utilities
// Provides mapping and inference functions for O*NET fields

import Foundation

// MARK: - Education Level Mapping

/// Maps education degree strings to O*NET 1-12 education scale
///
/// **O*NET Education Levels:**
/// - 1: Less than high school diploma
/// - 4: High school diploma or equivalent
/// - 6: Some college, no degree
/// - 7: Associate's degree
/// - 8: Bachelor's degree
/// - 10: Master's degree
/// - 11: Post-master's certificate
/// - 12: Doctoral degree
///
/// - Parameter educationString: Degree description (e.g., "Bachelor of Science")
/// - Returns: O*NET education level (1-12), or nil if unable to map
public func mapEducationLevel(_ educationString: String) -> Int? {
    let normalized = educationString.lowercased().trimmingCharacters(in: .whitespaces)

    // Doctoral degrees (12)
    if normalized.contains("phd") || normalized.contains("ph.d") ||
       normalized.contains("doctor") || normalized.contains("doctorate") {
        return 12
    }

    // Post-master's certificate (11)
    if (normalized.contains("post") && normalized.contains("master")) ||
       normalized.contains("specialist degree") {
        return 11
    }

    // Master's degrees (10)
    if normalized.contains("master") || normalized.contains("m.s.") ||
       normalized.contains("m.a.") || normalized.contains("mba") ||
       normalized.contains("m.ed") || normalized.contains("m.eng") {
        return 10
    }

    // Bachelor's degrees (8)
    if normalized.contains("bachelor") || normalized.contains("b.s.") ||
       normalized.contains("b.a.") || normalized.contains("b.eng") ||
       normalized.contains("b.sc") {
        return 8
    }

    // Associate's degree (7)
    if normalized.contains("associate") || normalized.contains("a.a.") ||
       normalized.contains("a.s.") || normalized.contains("a.a.s") {
        return 7
    }

    // Some college, no degree (6)
    if normalized.contains("some college") || normalized.contains("college coursework") {
        return 6
    }

    // High school diploma (4)
    if normalized.contains("high school") || normalized.contains("hs diploma") ||
       normalized.contains("ged") || normalized.contains("secondary") {
        return 4
    }

    // Less than high school (1)
    if normalized.contains("less than high school") || normalized.contains("no diploma") {
        return 1
    }

    // Unable to map
    return nil
}

// MARK: - Experience Calculation

/// Calculates total years of experience from work history
///
/// - Parameter workHistory: Array of work history items with dates
/// - Returns: Total years of experience, accounting for overlaps
public func calculateYearsOfExperience(from workHistory: [WorkHistoryItem]) -> Double {
    guard !workHistory.isEmpty else { return 0.0 }

    // Strategy: Sum all non-overlapping date ranges
    var dateRanges: [(start: Date, end: Date)] = []

    for item in workHistory {
        let endDate = item.endDate ?? Date() // Current job = today
        dateRanges.append((start: item.startDate, end: endDate))
    }

    // Sort by start date
    dateRanges.sort { $0.start < $1.start }

    // Merge overlapping ranges
    var mergedRanges: [(start: Date, end: Date)] = []
    var currentRange = dateRanges[0]

    for range in dateRanges.dropFirst() {
        if range.start <= currentRange.end {
            // Overlap - extend current range
            currentRange.end = max(currentRange.end, range.end)
        } else {
            // No overlap - save current and start new
            mergedRanges.append(currentRange)
            currentRange = range
        }
    }
    mergedRanges.append(currentRange)

    // Calculate total years
    let totalSeconds = mergedRanges.reduce(0.0) { sum, range in
        sum + range.end.timeIntervalSince(range.start)
    }

    let yearsPerSecond = 1.0 / (365.25 * 24 * 60 * 60)
    return totalSeconds * yearsPerSecond
}

// MARK: - Work Activities Inference

/// Infers O*NET work activities from job descriptions using keyword matching
///
/// **Note:** This is a simple keyword-based heuristic. For production use,
/// consider integrating iOS 26 Foundation Models for more accurate extraction.
///
/// - Parameter jobDescription: Free-text job description
/// - Returns: Dictionary mapping activity IDs to inferred importance scores (0.0-7.0)
public func inferWorkActivities(from jobDescription: String) -> [String: Double] {
    let normalized = jobDescription.lowercased()
    var activities: [String: Double] = [:]

    // Define keyword → activity mappings (subset of 41 total activities)
    let activityKeywords: [(activityID: String, keywords: [String], baseScore: Double)] = [
        // Information Input (4.A.1.*)
        ("4.A.1.a.1", ["gather", "collect", "research", "find information"], 5.0),
        ("4.A.1.b.5", ["inspect", "evaluate", "assess", "examine"], 5.0),

        // Mental Processes (4.A.2.*)
        ("4.A.2.a.1", ["decide", "choose", "determine", "select"], 6.0),
        ("4.A.2.a.4", ["analyze", "analytical", "data analysis", "statistics"], 6.5),
        ("4.A.2.b.1", ["process", "compute", "calculate", "tabulate"], 5.5),
        ("4.A.2.b.4", ["evaluate", "judge", "compare", "weigh"], 5.5),

        // Work Output (4.A.3.*)
        ("4.A.3.a.3", ["document", "write", "record", "report"], 5.0),
        ("4.A.3.b.1", ["draft", "compose", "author", "create documents"], 5.0),
        ("4.A.3.b.4", ["present", "communicate", "explain", "teach"], 6.0),

        // Interacting with Others (4.A.4.*)
        ("4.A.4.a.1", ["coordinate", "collaborate", "work with others"], 6.0),
        ("4.A.4.a.5", ["coach", "mentor", "train", "develop others"], 5.5),
        ("4.A.4.b.5", ["sell", "persuade", "influence", "negotiate"], 5.0),
        ("4.A.4.c.3", ["customer service", "client relations", "support"], 5.5)
    ]

    for (activityID, keywords, baseScore) in activityKeywords {
        var matchCount = 0
        for keyword in keywords {
            if normalized.contains(keyword) {
                matchCount += 1
            }
        }

        if matchCount > 0 {
            // Score increases with keyword frequency
            let frequencyBoost = min(Double(matchCount) * 0.5, 2.0)
            let finalScore = min(baseScore + frequencyBoost, 7.0)
            activities[activityID] = finalScore
        }
    }

    return activities
}

// MARK: - RIASEC Interest Inference

/// Infers RIASEC interest profile from career choices using occupation-to-interest mappings
///
/// **Holland RIASEC Model:**
/// - R (Realistic): Hands-on work with objects, tools, machines
/// - I (Investigative): Analytical thinking, research, problem-solving
/// - A (Artistic): Creative expression, design, arts
/// - S (Social): Helping people, teaching, healthcare
/// - E (Enterprising): Leadership, sales, persuasion
/// - C (Conventional): Organization, data management, procedures
///
/// - Parameter jobTitles: Array of job titles from work history
/// - Returns: RIASEC profile with scores 0.0-7.0 for each dimension
public func inferRIASECInterests(from jobTitles: [String]) -> RIASECProfile? {
    guard !jobTitles.isEmpty else { return nil }

    var realisticScore = 0.0
    var investigativeScore = 0.0
    var artisticScore = 0.0
    var socialScore = 0.0
    var enterprisingScore = 0.0
    var conventionalScore = 0.0

    let allTitles = jobTitles.map { $0.lowercased() }.joined(separator: " ")

    // Realistic (R): Hands-on technical work
    let realisticKeywords = ["engineer", "technician", "mechanic", "construction", "electrician", "operator"]
    realisticScore = scoreKeywords(realisticKeywords, in: allTitles)

    // Investigative (I): Research and analysis
    let investigativeKeywords = ["scientist", "researcher", "analyst", "developer", "programmer", "data"]
    investigativeScore = scoreKeywords(investigativeKeywords, in: allTitles)

    // Artistic (A): Creative expression
    let artisticKeywords = ["designer", "artist", "writer", "creative", "architect", "musician"]
    artisticScore = scoreKeywords(artisticKeywords, in: allTitles)

    // Social (S): Helping and teaching
    let socialKeywords = ["teacher", "nurse", "counselor", "therapist", "social worker", "trainer"]
    socialScore = scoreKeywords(socialKeywords, in: allTitles)

    // Enterprising (E): Leadership and persuasion
    let enterprisingKeywords = ["manager", "director", "executive", "sales", "entrepreneur", "supervisor"]
    enterprisingScore = scoreKeywords(enterprisingKeywords, in: allTitles)

    // Conventional (C): Organization and data
    let conventionalKeywords = ["accountant", "clerk", "administrator", "coordinator", "assistant", "bookkeeper"]
    conventionalScore = scoreKeywords(conventionalKeywords, in: allTitles)

    // Normalize scores to 0.0-7.0 scale
    let maxScore = max(realisticScore, investigativeScore, artisticScore, socialScore, enterprisingScore, conventionalScore)
    guard maxScore > 0 else { return nil }

    let normalize = { (score: Double) in min((score / maxScore) * 7.0, 7.0) }

    return RIASECProfile(
        realistic: normalize(realisticScore),
        investigative: normalize(investigativeScore),
        artistic: normalize(artisticScore),
        social: normalize(socialScore),
        enterprising: normalize(enterprisingScore),
        conventional: normalize(conventionalScore)
    )
}

/// Helper: Score keywords in text (0.0-7.0 scale)
private func scoreKeywords(_ keywords: [String], in text: String) -> Double {
    let matchCount = keywords.filter { text.contains($0) }.count
    return min(Double(matchCount) * 2.0, 7.0)
}

// MARK: - Supporting Types

/// Work history item structure for experience calculation
public struct WorkHistoryItem: Codable, Sendable {
    public let title: String
    public let company: String
    public let startDate: Date
    public let endDate: Date?
    public let description: String

    public init(title: String, company: String, startDate: Date, endDate: Date? = nil, description: String) {
        self.title = title
        self.company = company
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
    }
}

// MARK: - Profile Enhancement Helper

/// Enhance a professional profile from structured resume data
///
/// **Example Usage:**
/// ```swift
/// let enhanced = enhanceProfile(
///     existingSkills: ["Swift", "iOS"],
///     education: "Bachelor of Science in Computer Science",
///     workHistory: [
///         WorkHistoryItem(title: "iOS Developer", company: "Tech Corp", ...)
///     ]
/// )
/// // Returns: (educationLevel: 8, yearsOfExperience: 5.0, workActivities: [...], interests: RIASECProfile)
/// ```
///
/// - Parameters:
///   - existingSkills: User's existing skills list
///   - education: Highest degree earned (e.g., "Master of Arts")
///   - workHistory: Array of work experience items
/// - Returns: Tuple with enhanced profile data ready for ProfessionalProfile
public func enhanceProfile(
    existingSkills: [String],
    education: String?,
    workHistory: [WorkHistoryItem]
) -> (
    skills: [String],
    educationLevel: Int?,
    yearsOfExperience: Double?,
    workActivities: [String: Double]?,
    interests: RIASECProfile?
) {
    // Map education level
    let educationLevel = education.flatMap { mapEducationLevel($0) }

    // Calculate years of experience
    let yearsOfExperience = calculateYearsOfExperience(from: workHistory)

    // Infer work activities from job descriptions
    let allDescriptions = workHistory.map { $0.description }.joined(separator: " ")
    let workActivities = inferWorkActivities(from: allDescriptions)

    // Infer RIASEC interests from job titles
    let jobTitles = workHistory.map { $0.title }
    let interests = inferRIASECInterests(from: jobTitles)

    return (
        skills: existingSkills,
        educationLevel: educationLevel,
        yearsOfExperience: yearsOfExperience,
        workActivities: workActivities.isEmpty ? nil : workActivities,
        interests: interests
    )
}
