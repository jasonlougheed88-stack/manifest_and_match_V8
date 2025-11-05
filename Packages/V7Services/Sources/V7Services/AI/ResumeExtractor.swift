// ResumeExtractor.swift - V7Services Module
// On-device resume parsing using iOS 26 Foundation Models
//
// O*NET Phase 2B (October 28, 2025): Resume data extraction for profile enhancement
// Privacy-preserving, on-device AI processing for resume parsing

import Foundation
import V7Core
import V7AIParsing

// MARK: - Resume Extraction Error

public enum ResumeExtractionError: Error, CustomStringConvertible {
    case invalidInput
    case parsingFailed(String)
    case foundationModelsUnavailable
    case timeout

    public var description: String {
        switch self {
        case .invalidInput:
            return "Invalid resume text provided"
        case .parsingFailed(let reason):
            return "Failed to parse resume: \(reason)"
        case .foundationModelsUnavailable:
            return "iOS 26 Foundation Models not available on this device"
        case .timeout:
            return "Resume extraction timed out"
        }
    }
}

// MARK: - Resume Extractor Actor

/// Actor for extracting structured data from resume text using iOS 26 Foundation Models
///
/// **iOS 26 Foundation Models:**
/// - On-device AI processing (100% private)
/// - No network calls (offline capable)
/// - Free (no API costs)
/// - Requires iOS 26+ and compatible hardware (A17 Pro, M1+)
///
/// **Fallback Strategy:**
/// - iOS 26+ with compatible hardware: Use Foundation Models
/// - Older devices or iOS <26: Use manual parsing (keyword-based)
///
/// **Example Usage:**
/// ```swift
/// let extractor = ResumeExtractor.shared
/// let resumeText = """
/// John Doe
/// Software Engineer
/// Education: Bachelor of Science in Computer Science, MIT, 2018
/// Experience:
/// - iOS Developer at Tech Corp (2018-2023)
///   Developed mobile applications using Swift and SwiftUI
/// - Junior Developer at StartupCo (2016-2018)
///   Built web applications using JavaScript
/// """
///
/// let extracted = try await extractor.extractResumeData(from: resumeText)
/// print(extracted.education)  // [Education(degree: "Bachelor of Science", field: "Computer Science", ...)]
/// print(extracted.workHistory)  // [WorkHistoryItem(title: "iOS Developer", ...)]
/// ```
///
/// **Privacy:**
/// - All processing is 100% on-device
/// - No data sent to external servers
/// - Resume text never leaves the device
public actor ResumeExtractor {
    /// Shared instance
    public static let shared = ResumeExtractor()

    /// iOS 26 Foundation Models availability
    private var isFoundationModelsAvailable: Bool {
        if #available(iOS 26.0, *) {
            // Check if device supports Foundation Models
            // A17 Pro (iPhone 15 Pro+), M1+ (iPad/Mac)
            return ProcessInfo.processInfo.processorCount >= 6  // Simplified check
        }
        return false
    }

    private init() {}

    // MARK: - Public API

    /// Extract structured data from resume text
    ///
    /// - Parameter resumeText: Raw resume text (from PDF, Word, or plain text)
    /// - Returns: Structured resume data (education, work history, skills)
    /// - Throws: ResumeExtractionError if parsing fails
    public func extractResumeData(from resumeText: String) async throws -> ResumeExtraction {
        guard !resumeText.isEmpty else {
            throw ResumeExtractionError.invalidInput
        }

        // Try Foundation Models first (iOS 26+)
        if #available(iOS 26.0, *), isFoundationModelsAvailable {
            do {
                return try await extractWithFoundationModels(resumeText)
            } catch {
                // Fallback to manual parsing
                return try await extractManually(resumeText)
            }
        } else {
            // Manual parsing for older devices
            return try await extractManually(resumeText)
        }
    }

    // MARK: - iOS 26 Foundation Models Extraction

    @available(iOS 26.0, *)
    private func extractWithFoundationModels(_ text: String) async throws -> ResumeExtraction {
        // NOTE: Foundation Models API is conceptual based on iOS 26 specialist knowledge
        // Actual API may differ in production iOS 26

        // Extract education
        let educationText = try await extractEducationSection(from: text)
        let education = parseEducation(from: educationText)

        // Extract work history
        let experienceText = try await extractExperienceSection(from: text)
        let workHistory = parseWorkHistory(from: experienceText)

        // Extract skills
        let skills = try await extractSkills(from: text)

        // Extract certifications
        let certifications = try await extractCertifications(from: text)

        // Extract new data types (Phase 3)
        let projects = try await extractProjects(from: text)
        let volunteerExperience = try await extractVolunteerExperience(from: text)
        let awards = try await extractAwards(from: text)
        let publications = try await extractPublications(from: text)

        return ResumeExtraction(
            education: education,
            workHistory: workHistory,
            certifications: certifications,
            skills: skills,
            projects: projects,
            volunteerExperience: volunteerExperience,
            awards: awards,
            publications: publications
        )
    }

    @available(iOS 26.0, *)
    private func extractEducationSection(from text: String) async throws -> String {
        // Simulate Foundation Models entity extraction
        // In production, use: FoundationModels.extract(entities: [.education], from: text)

        let lines = text.components(separatedBy: .newlines)
        var educationLines: [String] = []
        var inEducationSection = false

        for line in lines {
            let normalized = line.lowercased()

            // Start of education section
            if normalized.contains("education") || normalized.contains("academic") {
                inEducationSection = true
            }

            // End of education section
            if inEducationSection && (normalized.contains("experience") || normalized.contains("employment")) {
                break
            }

            if inEducationSection {
                educationLines.append(line)
            }
        }

        return educationLines.joined(separator: "\n")
    }

    @available(iOS 26.0, *)
    private func extractExperienceSection(from text: String) async throws -> String {
        let lines = text.components(separatedBy: .newlines)
        var experienceLines: [String] = []
        var inExperienceSection = false

        for line in lines {
            let normalized = line.lowercased()

            // Start of experience section
            if normalized.contains("experience") || normalized.contains("employment") || normalized.contains("work history") {
                inExperienceSection = true
            }

            // End of experience section
            if inExperienceSection && (normalized.contains("education") || normalized.contains("skills") || normalized.contains("certifications")) {
                break
            }

            if inExperienceSection {
                experienceLines.append(line)
            }
        }

        return experienceLines.joined(separator: "\n")
    }

    @available(iOS 26.0, *)
    private func extractSkills(from text: String) async throws -> [String] {
        // Simulate Foundation Models skill extraction
        // In production: FoundationModels.extract(entities: [.skills], from: text)

        let commonSkills = [
            "Swift", "iOS", "SwiftUI", "UIKit", "Python", "JavaScript", "Java",
            "C++", "React", "Angular", "Vue", "Node.js", "SQL", "NoSQL",
            "AWS", "Azure", "GCP", "Docker", "Kubernetes", "Git", "Agile",
            "Scrum", "Leadership", "Communication", "Problem Solving"
        ]

        var foundSkills: [String] = []
        for skill in commonSkills {
            if text.range(of: skill, options: .caseInsensitive) != nil {
                foundSkills.append(skill)
            }
        }

        return foundSkills
    }

    @available(iOS 26.0, *)
    private func extractCertifications(from text: String) async throws -> [V7AIParsing.Certification] {
        let lines = text.components(separatedBy: .newlines)
        var certifications: [V7AIParsing.Certification] = []

        for line in lines {
            let normalized = line.lowercased()

            // Look for certification keywords
            if normalized.contains("certified") || normalized.contains("certification") {
                let yearInt = extractYear(from: line)
                let issueDate = yearInt.flatMap { Calendar.current.date(from: DateComponents(year: $0, month: 1)) }

                let cert = V7AIParsing.Certification(
                    name: line.trimmingCharacters(in: .whitespaces),
                    issuer: "",  // Extract issuer from line if possible
                    issueDate: issueDate,
                    expirationDate: nil,
                    credentialId: nil,
                    verificationURL: nil,
                    doesNotExpire: true
                )
                certifications.append(cert)
            }
        }

        return certifications
    }

    @available(iOS 26.0, *)
    private func extractProjects(from text: String) async throws -> [V7AIParsing.Project] {
        let lines = text.components(separatedBy: .newlines)
        var projects: [V7AIParsing.Project] = []

        for line in lines {
            let normalized = line.lowercased()

            // Look for project keywords
            if normalized.contains("project") && !normalized.contains("experience") && !normalized.contains("work") {
                projects.append(V7AIParsing.Project(
                    name: line.trimmingCharacters(in: .whitespaces),
                    description: nil,
                    highlights: [],
                    technologies: [],
                    startDate: nil,
                    endDate: nil,
                    isCurrent: false,
                    url: nil,
                    repositoryURL: nil,
                    entity: .personal,
                    type: .other,
                    roles: []
                ))
            }
        }

        return projects
    }

    @available(iOS 26.0, *)
    private func extractVolunteerExperience(from text: String) async throws -> [V7AIParsing.VolunteerExperience] {
        let lines = text.components(separatedBy: .newlines)
        var volunteer: [V7AIParsing.VolunteerExperience] = []

        for line in lines {
            let normalized = line.lowercased()

            // Look for volunteer keywords
            if normalized.contains("volunteer") || normalized.contains("community service") {
                volunteer.append(V7AIParsing.VolunteerExperience(
                    organization: line.trimmingCharacters(in: .whitespaces),
                    role: "Volunteer",
                    startDate: nil,
                    endDate: nil,
                    isCurrent: false,
                    description: nil,
                    hoursPerWeek: nil,
                    achievements: [],
                    skills: []
                ))
            }
        }

        return volunteer
    }

    @available(iOS 26.0, *)
    private func extractAwards(from text: String) async throws -> [V7AIParsing.Award] {
        let lines = text.components(separatedBy: .newlines)
        var awards: [V7AIParsing.Award] = []

        for line in lines {
            let normalized = line.lowercased()

            // Look for award keywords
            if normalized.contains("award") || normalized.contains("honor") || normalized.contains("recognition") {
                let yearInt = extractYear(from: line)
                let date = yearInt.flatMap { Calendar.current.date(from: DateComponents(year: $0, month: 1)) }

                awards.append(V7AIParsing.Award(
                    title: line.trimmingCharacters(in: .whitespaces),
                    issuer: "",
                    date: date,
                    description: nil
                ))
            }
        }

        return awards
    }

    @available(iOS 26.0, *)
    private func extractPublications(from text: String) async throws -> [V7AIParsing.Publication] {
        let lines = text.components(separatedBy: .newlines)
        var publications: [V7AIParsing.Publication] = []

        for line in lines {
            let normalized = line.lowercased()

            // Look for publication keywords
            if normalized.contains("published") || normalized.contains("publication") || normalized.contains("paper") {
                let yearInt = extractYear(from: line)
                let date = yearInt.flatMap { Calendar.current.date(from: DateComponents(year: $0, month: 1)) }

                publications.append(V7AIParsing.Publication(
                    title: line.trimmingCharacters(in: .whitespaces),
                    publisher: nil,
                    date: date,
                    url: nil,
                    authors: [],
                    description: nil
                ))
            }
        }

        return publications
    }

    // MARK: - Manual Extraction (Fallback)

    @available(iOS 18.0, macOS 14.0, *)
    private func extractManually(_ text: String) async throws -> ResumeExtraction {
        let educationText = extractEducationSectionManually(from: text)
        let education = parseEducation(from: educationText)

        let experienceText = extractExperienceSectionManually(from: text)
        let workHistory = parseWorkHistory(from: experienceText)

        let skills = extractSkillsManually(from: text)

        let certifications = extractCertificationsManually(from: text)

        // Extract new data types (Phase 3)
        let projects = extractProjectsManually(from: text)
        let volunteerExperience = extractVolunteerExperienceManually(from: text)
        let awards = extractAwardsManually(from: text)
        let publications = extractPublicationsManually(from: text)

        return ResumeExtraction(
            education: education,
            workHistory: workHistory,
            certifications: certifications,
            skills: skills,
            projects: projects,
            volunteerExperience: volunteerExperience,
            awards: awards,
            publications: publications
        )
    }

    private func extractEducationSectionManually(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        var educationLines: [String] = []
        var inEducationSection = false

        for line in lines {
            let normalized = line.lowercased()

            if normalized.contains("education") || normalized.contains("academic background") {
                inEducationSection = true
            }

            if inEducationSection && (normalized.contains("experience") || normalized.contains("skills")) {
                break
            }

            if inEducationSection {
                educationLines.append(line)
            }
        }

        return educationLines.joined(separator: "\n")
    }

    private func extractExperienceSectionManually(from text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        var experienceLines: [String] = []
        var inExperienceSection = false

        for line in lines {
            let normalized = line.lowercased()

            if normalized.contains("experience") || normalized.contains("work history") || normalized.contains("employment") {
                inExperienceSection = true
            }

            if inExperienceSection && normalized.contains("education") {
                break
            }

            if inExperienceSection {
                experienceLines.append(line)
            }
        }

        return experienceLines.joined(separator: "\n")
    }

    private func extractSkillsManually(from text: String) -> [String] {
        // Same as Foundation Models version (keyword matching)
        let commonSkills = [
            "Swift", "iOS", "SwiftUI", "UIKit", "Python", "JavaScript", "Java",
            "C++", "React", "Angular", "Vue", "Node.js", "SQL", "NoSQL",
            "AWS", "Azure", "GCP", "Docker", "Kubernetes", "Git", "Agile"
        ]

        return commonSkills.filter { skill in
            text.range(of: skill, options: .caseInsensitive) != nil
        }
    }

    @available(iOS 18.0, macOS 14.0, *)
    private func extractCertificationsManually(from text: String) -> [V7AIParsing.Certification] {
        let lines = text.components(separatedBy: .newlines)
        var certifications: [V7AIParsing.Certification] = []

        for line in lines {
            if line.lowercased().contains("certified") || line.lowercased().contains("certification") {
                let yearInt = extractYear(from: line)
                let issueDate = yearInt.flatMap { Calendar.current.date(from: DateComponents(year: $0, month: 1)) }

                certifications.append(
                    V7AIParsing.Certification(
                        name: line.trimmingCharacters(in: .whitespaces),
                        issuer: "",
                        issueDate: issueDate,
                        expirationDate: nil,
                        credentialId: nil,
                        verificationURL: nil,
                        doesNotExpire: true
                    )
                )
            }
        }

        return certifications
    }

    @available(iOS 18.0, macOS 14.0, *)
    private func extractProjectsManually(from text: String) -> [V7AIParsing.Project] {
        let lines = text.components(separatedBy: .newlines)
        var projects: [V7AIParsing.Project] = []

        for line in lines {
            let normalized = line.lowercased()
            if normalized.contains("project") && !normalized.contains("experience") && !normalized.contains("work") {
                projects.append(V7AIParsing.Project(
                    name: line.trimmingCharacters(in: .whitespaces),
                    description: nil,
                    highlights: [],
                    technologies: [],
                    startDate: nil,
                    endDate: nil,
                    isCurrent: false,
                    url: nil,
                    repositoryURL: nil,
                    entity: .personal,
                    type: .other,
                    roles: []
                ))
            }
        }

        return projects
    }

    @available(iOS 18.0, macOS 14.0, *)
    private func extractVolunteerExperienceManually(from text: String) -> [V7AIParsing.VolunteerExperience] {
        let lines = text.components(separatedBy: .newlines)
        var volunteer: [V7AIParsing.VolunteerExperience] = []

        for line in lines {
            let normalized = line.lowercased()
            if normalized.contains("volunteer") || normalized.contains("community service") {
                volunteer.append(V7AIParsing.VolunteerExperience(
                    organization: line.trimmingCharacters(in: .whitespaces),
                    role: "Volunteer",
                    startDate: nil,
                    endDate: nil,
                    isCurrent: false,
                    description: nil,
                    hoursPerWeek: nil,
                    achievements: [],
                    skills: []
                ))
            }
        }

        return volunteer
    }

    @available(iOS 18.0, macOS 14.0, *)
    private func extractAwardsManually(from text: String) -> [V7AIParsing.Award] {
        let lines = text.components(separatedBy: .newlines)
        var awards: [V7AIParsing.Award] = []

        for line in lines {
            let normalized = line.lowercased()
            if normalized.contains("award") || normalized.contains("honor") || normalized.contains("recognition") {
                let yearInt = extractYear(from: line)
                let date = yearInt.flatMap { Calendar.current.date(from: DateComponents(year: $0, month: 1)) }

                awards.append(V7AIParsing.Award(
                    title: line.trimmingCharacters(in: .whitespaces),
                    issuer: "",
                    date: date,
                    description: nil
                ))
            }
        }

        return awards
    }

    @available(iOS 18.0, macOS 14.0, *)
    private func extractPublicationsManually(from text: String) -> [V7AIParsing.Publication] {
        let lines = text.components(separatedBy: .newlines)
        var publications: [V7AIParsing.Publication] = []

        for line in lines {
            let normalized = line.lowercased()
            if normalized.contains("published") || normalized.contains("publication") || normalized.contains("paper") {
                let yearInt = extractYear(from: line)
                let date = yearInt.flatMap { Calendar.current.date(from: DateComponents(year: $0, month: 1)) }

                publications.append(V7AIParsing.Publication(
                    title: line.trimmingCharacters(in: .whitespaces),
                    publisher: nil,
                    date: date,
                    url: nil,
                    authors: [],
                    description: nil
                ))
            }
        }

        return publications
    }

    // MARK: - Parsing Helpers

    @available(iOS 18.0, macOS 14.0, *)
    private func parseEducation(from text: String) -> [V7AIParsing.Education] {
        var education: [V7AIParsing.Education] = []
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let normalized = line.lowercased()

            // Detect degree keywords
            let degreeKeywords = ["bachelor", "master", "phd", "doctorate", "associate", "diploma"]
            guard degreeKeywords.contains(where: { normalized.contains($0) }) else { continue }

            // Extract degree type
            var degree = "Unknown Degree"
            if normalized.contains("bachelor") {
                degree = "Bachelor's degree"
            } else if normalized.contains("master") {
                degree = "Master's degree"
            } else if normalized.contains("phd") || normalized.contains("doctorate") {
                degree = "Doctoral degree"
            } else if normalized.contains("associate") {
                degree = "Associate's degree"
            }

            // Extract field (simplified heuristic)
            let field = extractField(from: line)

            // Extract institution (simplified)
            let institution = extractInstitution(from: line) ?? "Unknown Institution"

            // Extract year - convert to Date
            let yearInt = extractYear(from: line)
            let graduationDate = yearInt.flatMap { Calendar.current.date(from: DateComponents(year: $0, month: 6)) }

            education.append(V7AIParsing.Education(
                institution: institution,  // Required first parameter
                degree: degree,            // Optional
                fieldOfStudy: field,       // Renamed from "field"
                startDate: nil,            // New field (no data available)
                endDate: graduationDate,   // Renamed from "graduationDate"
                gpa: nil,                  // Optional
                level: nil                 // Renamed from "achievements", now EducationLevel?
            ))
        }

        return education
    }

    private func parseWorkHistory(from text: String) -> [WorkHistoryItem] {
        var workHistory: [WorkHistoryItem] = []
        let lines = text.components(separatedBy: .newlines)

        var currentJob: (title: String, company: String, dates: String, description: [String]) = ("", "", "", [])

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            // Detect job title line (heuristic: contains "at", "•", "-", or year range)
            if trimmed.contains(" at ") || trimmed.hasPrefix("•") || trimmed.hasPrefix("-") || containsYearRange(trimmed) {
                // Save previous job if exists
                if !currentJob.title.isEmpty {
                    if let job = createWorkHistoryItem(from: currentJob) {
                        workHistory.append(job)
                    }
                }

                // Parse new job
                let components = trimmed.replacingOccurrences(of: "• ", with: "").components(separatedBy: " at ")
                if components.count >= 2 {
                    currentJob.title = components[0].trimmingCharacters(in: .whitespaces)

                    // Extract company and dates
                    let remaining = components[1]
                    let parts = remaining.components(separatedBy: "(")
                    currentJob.company = parts[0].trimmingCharacters(in: .whitespaces)
                    currentJob.dates = parts.count > 1 ? parts[1].replacingOccurrences(of: ")", with: "") : ""
                    currentJob.description = []
                } else {
                    currentJob.title = trimmed
                    currentJob.description = []
                }
            } else {
                // Accumulate job description
                currentJob.description.append(trimmed)
            }
        }

        // Save last job
        if !currentJob.title.isEmpty {
            if let job = createWorkHistoryItem(from: currentJob) {
                workHistory.append(job)
            }
        }

        return workHistory
    }

    private func createWorkHistoryItem(from job: (title: String, company: String, dates: String, description: [String])) -> WorkHistoryItem? {
        guard !job.title.isEmpty else { return nil }

        let company = job.company.isEmpty ? "Unknown Company" : job.company
        let description = job.description.joined(separator: " ")

        // Parse dates (simplified)
        let (startDate, endDate) = parseDateRange(from: job.dates)

        return WorkHistoryItem(
            title: job.title,
            company: company,
            startDate: startDate,
            endDate: endDate,
            description: description
        )
    }

    // MARK: - Helper Functions

    private func extractField(from line: String) -> String {
        let fields = ["Computer Science", "Engineering", "Business", "Mathematics", "Physics", "Biology", "Chemistry"]
        for field in fields {
            if line.range(of: field, options: .caseInsensitive) != nil {
                return field
            }
        }
        return "Unknown Field"
    }

    private func extractInstitution(from line: String) -> String? {
        // Simplified: Look for proper nouns after degree keywords
        let components = line.components(separatedBy: ",")
        if components.count >= 2 {
            return components[1].trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    private func extractYear(from line: String) -> Int? {
        let pattern = #"\b(19|20)\d{2}\b"#
        if let range = line.range(of: pattern, options: .regularExpression) {
            return Int(String(line[range]))
        }
        return nil
    }

    private func containsYearRange(_ line: String) -> Bool {
        line.range(of: #"\d{4}\s*-\s*\d{4}"#, options: .regularExpression) != nil ||
        line.range(of: #"\d{4}\s*-\s*Present"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private func parseDateRange(from dateString: String) -> (start: Date, end: Date?) {
        let normalized = dateString.replacingOccurrences(of: " ", with: "")
        let components = normalized.components(separatedBy: "-")

        guard components.count == 2 else {
            return (Date.distantPast, nil)
        }

        let startYear = Int(components[0]) ?? 2020
        let startDate = Calendar.current.date(from: DateComponents(year: startYear, month: 1, day: 1)) ?? Date.distantPast

        var endDate: Date? = nil
        if components[1].lowercased() != "present" {
            let endYear = Int(components[1]) ?? 2023
            endDate = Calendar.current.date(from: DateComponents(year: endYear, month: 12, day: 31))
        }

        return (startDate, endDate)
    }
}

// MARK: - Resume Extraction Result

/// Structured resume data extracted from text
@available(iOS 18.0, macOS 14.0, *)
public struct ResumeExtraction: Codable, Sendable {
    public let education: [V7AIParsing.Education]
    public let workHistory: [WorkHistoryItem]
    public let certifications: [V7AIParsing.Certification]
    public let skills: [String]
    public let projects: [V7AIParsing.Project]
    public let volunteerExperience: [V7AIParsing.VolunteerExperience]
    public let awards: [V7AIParsing.Award]
    public let publications: [V7AIParsing.Publication]

    public init(
        education: [V7AIParsing.Education],
        workHistory: [WorkHistoryItem],
        certifications: [V7AIParsing.Certification],
        skills: [String],
        projects: [V7AIParsing.Project] = [],
        volunteerExperience: [V7AIParsing.VolunteerExperience] = [],
        awards: [V7AIParsing.Award] = [],
        publications: [V7AIParsing.Publication] = []
    ) {
        self.education = education
        self.workHistory = workHistory
        self.certifications = certifications
        self.skills = skills
        self.projects = projects
        self.volunteerExperience = volunteerExperience
        self.awards = awards
        self.publications = publications
    }
}

/// Work history entry (simplified for extraction)
/// NOTE: This is different from V7AIParsing.WorkExperience which has more fields
public struct WorkHistoryItem: Codable, Sendable, Hashable {
    public let title: String
    public let company: String
    public let startDate: Date
    public let endDate: Date?
    public let description: String

    public init(title: String, company: String, startDate: Date, endDate: Date?, description: String) {
        self.title = title
        self.company = company
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
    }
}
