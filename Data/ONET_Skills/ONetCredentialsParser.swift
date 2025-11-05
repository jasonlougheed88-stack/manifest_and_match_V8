#!/usr/bin/env swift

import Foundation

// MARK: - O*NET Credentials Parser for ManifestAndMatch V8
// Purpose: Parse education, training, experience, and job zone data from O*NET 30.0
// Output: onet_credentials.json for integration with V8 UserProfile
// iOS 26 Compatible: Swift 6 strict concurrency patterns
// Created: October 27, 2025

// MARK: - Education Levels (12 O*NET categories)
enum EducationLevel: Int, Codable, CaseIterable {
    case lessThanHS = 1
    case highSchool = 2
    case postSecCert = 3
    case someCollege = 4
    case associates = 5
    case bachelors = 6
    case postBacCert = 7
    case masters = 8
    case postMastersCert = 9
    case firstProfessional = 10  // J.D., M.D., etc.
    case doctoral = 11
    case postDoctoral = 12

    var displayName: String {
        switch self {
        case .lessThanHS: return "Less than High School"
        case .highSchool: return "High School Diploma or GED"
        case .postSecCert: return "Post-Secondary Certificate"
        case .someCollege: return "Some College, No Degree"
        case .associates: return "Associate's Degree"
        case .bachelors: return "Bachelor's Degree"
        case .postBacCert: return "Post-Baccalaureate Certificate"
        case .masters: return "Master's Degree"
        case .postMastersCert: return "Post-Master's Certificate"
        case .firstProfessional: return "Professional Degree (J.D., M.D.)"
        case .doctoral: return "Doctoral Degree (Ph.D.)"
        case .postDoctoral: return "Post-Doctoral Training"
        }
    }

    var yearsOfEducation: Int {
        switch self {
        case .lessThanHS: return 0
        case .highSchool: return 12
        case .postSecCert: return 13
        case .someCollege: return 13
        case .associates: return 14
        case .bachelors: return 16
        case .postBacCert: return 17
        case .masters: return 18
        case .postMastersCert: return 19
        case .firstProfessional: return 19
        case .doctoral: return 21
        case .postDoctoral: return 23
        }
    }
}

// MARK: - Work Experience Levels (11 O*NET categories)
enum WorkExperienceLevel: Int, Codable, CaseIterable {
    case none = 1
    case upTo1Month = 2
    case oneToThreeMonths = 3
    case threeToSixMonths = 4
    case sixMonthsToOneYear = 5
    case oneToTwoYears = 6
    case twoToFourYears = 7
    case fourToSixYears = 8
    case sixToEightYears = 9
    case eightToTenYears = 10
    case overTenYears = 11

    var displayName: String {
        switch self {
        case .none: return "None"
        case .upTo1Month: return "Up to 1 month"
        case .oneToThreeMonths: return "1-3 months"
        case .threeToSixMonths: return "3-6 months"
        case .sixMonthsToOneYear: return "6 months - 1 year"
        case .oneToTwoYears: return "1-2 years"
        case .twoToFourYears: return "2-4 years"
        case .fourToSixYears: return "4-6 years"
        case .sixToEightYears: return "6-8 years"
        case .eightToTenYears: return "8-10 years"
        case .overTenYears: return "Over 10 years"
        }
    }

    var minimumYears: Double {
        switch self {
        case .none: return 0
        case .upTo1Month: return 0.08
        case .oneToThreeMonths: return 0.17
        case .threeToSixMonths: return 0.5
        case .sixMonthsToOneYear: return 0.75
        case .oneToTwoYears: return 1.5
        case .twoToFourYears: return 3
        case .fourToSixYears: return 5
        case .sixToEightYears: return 7
        case .eightToTenYears: return 9
        case .overTenYears: return 11
        }
    }
}

// MARK: - Job Zones (5 preparation levels)
enum JobZone: Int, Codable {
    case zone1 = 1  // Little or No Preparation
    case zone2 = 2  // Some Preparation
    case zone3 = 3  // Medium Preparation
    case zone4 = 4  // Considerable Preparation
    case zone5 = 5  // Extensive Preparation

    var displayName: String {
        switch self {
        case .zone1: return "Little or No Preparation Needed"
        case .zone2: return "Some Preparation Needed"
        case .zone3: return "Medium Preparation Needed"
        case .zone4: return "Considerable Preparation Needed"
        case .zone5: return "Extensive Preparation Needed"
        }
    }

    var svpRange: ClosedRange<Double> {
        switch self {
        case .zone1: return 0.0...3.99
        case .zone2: return 4.0...5.99
        case .zone3: return 6.0...6.99
        case .zone4: return 7.0...7.99
        case .zone5: return 8.0...10.0
        }
    }

    var typicalEducation: [EducationLevel] {
        switch self {
        case .zone1: return [.lessThanHS, .highSchool]
        case .zone2: return [.highSchool]
        case .zone3: return [.postSecCert, .associates, .someCollege]
        case .zone4: return [.bachelors]
        case .zone5: return [.bachelors, .masters, .doctoral, .firstProfessional]
        }
    }
}

// MARK: - Sector Mapping (19 sectors)
enum Sector: String, CaseIterable {
    case officeAdmin = "Office/Administrative"
    case healthcare = "Healthcare"
    case technology = "Technology"
    case retail = "Retail"
    case skilledTrades = "Skilled Trades"
    case finance = "Finance"
    case foodService = "Food Service"
    case warehouseLogistics = "Warehouse/Logistics"
    case education = "Education"
    case construction = "Construction"
    case legal = "Legal"
    case realEstate = "Real Estate"
    case marketing = "Marketing"
    case humanResources = "Human Resources"
    case artsDesignMedia = "Arts/Design/Media"
    case protectiveService = "Protective Service"
    case scienceResearch = "Science/Research"
    case socialCommunityService = "Social/Community Service"
    case personalCareService = "Personal Care/Service"

    func matches(onetCode: String, title: String = "") -> Bool {
        let prefixes = self.onetPrefixes
        let matchesPrefix = prefixes.contains { onetCode.hasPrefix($0) }

        // Special cases based on title
        if onetCode.hasPrefix("11-") {
            return matchesManagementRole(title: title)
        }
        if onetCode.hasPrefix("17-") {
            return title.contains("Civil") ? self == .construction : self == .technology
        }
        if onetCode.hasPrefix("19-") {
            return title.contains("Medical") ? self == .healthcare : self == .scienceResearch
        }
        if onetCode.hasPrefix("41-") {
            return matchesSalesRole(title: title)
        }

        return matchesPrefix
    }

    var onetPrefixes: [String] {
        switch self {
        case .officeAdmin: return ["11-", "13-1", "43-"]
        case .healthcare: return ["29-", "31-"]
        case .technology: return ["15-"]
        case .retail: return ["41-"]
        case .skilledTrades: return ["47-", "49-", "45-"]
        case .finance: return ["13-2"]
        case .foodService: return ["35-"]
        case .warehouseLogistics: return ["53-"]
        case .education: return ["25-"]
        case .construction: return ["47-"]
        case .legal: return ["23-"]
        case .realEstate: return ["41-9021", "41-9022"]
        case .marketing: return ["11-2021", "11-2031", "13-1161"]
        case .humanResources: return ["13-1071", "13-1075", "13-1151", "13-1199"]
        case .artsDesignMedia: return ["27-"]
        case .protectiveService: return ["33-"]
        case .scienceResearch: return ["19-"]
        case .socialCommunityService: return ["21-"]
        case .personalCareService: return ["39-"]
        }
    }

    private func matchesManagementRole(title: String) -> Bool {
        let lower = title.lowercased()
        if lower.contains("financial") || lower.contains("controller") || lower.contains("treasurer") {
            return self == .finance
        } else if lower.contains("marketing") || lower.contains("advertising") || lower.contains("promotions") {
            return self == .marketing
        } else if lower.contains("human resources") || lower.contains("compensation") {
            return self == .humanResources
        } else {
            return self == .officeAdmin
        }
    }

    private func matchesSalesRole(title: String) -> Bool {
        let lower = title.lowercased()
        if lower.contains("real estate") {
            return self == .realEstate
        } else if lower.contains("advertising") || lower.contains("marketing") {
            return self == .marketing
        } else {
            return self == .retail
        }
    }

    static func determineSector(onetCode: String, title: String) -> String {
        return Sector.allCases.first { $0.matches(onetCode: onetCode, title: title) }?.rawValue ?? "Office/Administrative"
    }
}

// MARK: - Data Models
struct ConfidenceInterval: Codable {
    let lower: Double
    let upper: Double
    let standardError: Double
    let sampleSize: Int
}

struct EducationRequirements: Codable {
    let requiredLevel: EducationLevel
    let percentFrequency: Double
    let confidence: ConfidenceInterval
    let alternatives: [EducationAlternative]
}

struct EducationAlternative: Codable {
    let level: EducationLevel
    let percentFrequency: Double
}

struct ExperienceRequirements: Codable {
    let relatedWorkExperience: WorkExperienceLevel
    let percentFrequency: Double
    let confidence: ConfidenceInterval
}

struct TrainingRequirements: Codable {
    let onSiteTraining: TrainingLevel?
    let onTheJobTraining: TrainingLevel?
}

struct TrainingLevel: Codable {
    let level: Int
    let description: String
    let percentFrequency: Double
}

struct OccupationCredentials: Codable {
    let onetCode: String
    let title: String
    let sector: String
    let jobZone: JobZone
    let educationRequirements: EducationRequirements
    let experienceRequirements: ExperienceRequirements
    let trainingRequirements: TrainingRequirements
}

struct CredentialsDatabase: Codable {
    let version: String
    let source: String
    let dateExtracted: String
    let totalOccupations: Int
    let occupations: [OccupationCredentials]
    let attribution: String
}

// MARK: - Internal Data Structures
struct EducationRecord {
    let scaleId: String
    let category: Int
    let percentFrequency: Double
    let sampleSize: Int
    let confidenceInterval: ConfidenceInterval
}

struct Occupation {
    let code: String
    let title: String
    let description: String
}

// MARK: - Parser
class ONetCredentialsParser {
    private var occupations: [String: Occupation] = [:]
    private var jobZones: [String: Int] = [:]
    private var educationCategories: [String: [Int: String]] = [:]
    private var occupationCredentials: [String: OccupationCredentials] = [:]

    // MARK: - Parse Occupation Data
    func parseOccupations() throws {
        print("📖 Parsing Occupation_Data.txt...")
        let content = try String(contentsOfFile: "Occupation_Data.txt", encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 3 else { continue }

            let code = fields[0]
            let title = fields[1]
            let description = fields[2]

            occupations[code] = Occupation(
                code: code,
                title: title,
                description: description
            )
        }

        print("✅ Loaded \(occupations.count) occupations")
    }

    // MARK: - Parse Education Categories Reference
    func parseEducationCategories() throws {
        print("📖 Parsing Education, Training, and Experience Categories.txt...")
        let content = try String(contentsOfFile: "Education, Training, and Experience Categories.txt", encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 5 else { continue }

            // File format: Element ID, Element Name, Scale ID, Category, Category Description
            let scaleId = fields[2]
            let category = Int(fields[3]) ?? 0
            let description = fields[4]

            var categories = educationCategories[scaleId, default: [:]]
            categories[category] = description
            educationCategories[scaleId] = categories
        }

        print("✅ Loaded education categories for \(educationCategories.keys.count) scales")
        print("   - RL (Education): \(educationCategories["RL"]?.count ?? 0) levels")
        print("   - RW (Experience): \(educationCategories["RW"]?.count ?? 0) levels")
        print("   - PT (On-Site Training): \(educationCategories["PT"]?.count ?? 0) levels")
        print("   - OJ (On-The-Job Training): \(educationCategories["OJ"]?.count ?? 0) levels")
    }

    // MARK: - Parse Job Zones
    func parseJobZones() throws {
        print("📖 Parsing Job Zones.txt...")
        let content = try String(contentsOfFile: "Job Zones.txt", encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 2 else { continue }

            let onetCode = fields[0]
            let jobZone = Int(fields[1]) ?? 0
            jobZones[onetCode] = jobZone
        }

        print("✅ Loaded job zones for \(jobZones.count) occupations")
    }

    // MARK: - Parse Education Requirements
    func parseEducationRequirements() throws {
        print("📖 Parsing Education, Training, and Experience.txt...")
        let content = try String(contentsOfFile: "Education, Training, and Experience.txt", encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        var educationData: [String: [EducationRecord]] = [:]

        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 13 else { continue }

            let onetCode = fields[0]
            let scaleId = fields[3]
            let category = Int(fields[4]) ?? 0
            let dataValue = Double(fields[5]) ?? 0.0
            let sampleSize = Int(fields[6]) ?? 0
            let stdError = Double(fields[7]) ?? 0.0
            let lowerCI = Double(fields[8]) ?? 0.0
            let upperCI = Double(fields[9]) ?? 0.0
            let recommendSuppress = fields[10]

            // Skip low-quality data
            guard recommendSuppress != "Y", sampleSize >= 30 else { continue }

            let record = EducationRecord(
                scaleId: scaleId,
                category: category,
                percentFrequency: dataValue,
                sampleSize: sampleSize,
                confidenceInterval: ConfidenceInterval(
                    lower: lowerCI,
                    upper: upperCI,
                    standardError: stdError,
                    sampleSize: sampleSize
                )
            )

            var records = educationData[onetCode, default: []]
            records.append(record)
            educationData[onetCode] = records
        }

        print("✅ Parsed education requirements for \(educationData.count) occupations")

        // Synthesize into OccupationCredentials
        synthesizeCredentials(educationData: educationData)
    }

    // MARK: - Synthesize Credentials
    private func synthesizeCredentials(educationData: [String: [EducationRecord]]) {
        print("\n🔧 Synthesizing occupation credentials...")

        var successCount = 0
        var skippedCount = 0

        for (onetCode, records) in educationData {
            guard let occupation = occupations[onetCode] else {
                skippedCount += 1
                continue
            }

            guard let jobZoneValue = jobZones[onetCode],
                  let jobZone = JobZone(rawValue: jobZoneValue) else {
                skippedCount += 1
                continue
            }

            let educationRecords = records.filter { $0.scaleId == "RL" }
            let experienceRecords = records.filter { $0.scaleId == "RW" }
            let onSiteRecords = records.filter { $0.scaleId == "PT" }
            let onJobRecords = records.filter { $0.scaleId == "OJ" }

            // Find primary education requirement (highest frequency)
            guard let primaryEducation = educationRecords.max(by: { $0.percentFrequency < $1.percentFrequency }) else {
                skippedCount += 1
                continue
            }

            // Find alternative education paths (>20% frequency)
            let alternatives = educationRecords
                .filter { $0.percentFrequency >= 20.0 && $0.category != primaryEducation.category }
                .compactMap { record -> EducationAlternative? in
                    guard let level = EducationLevel(rawValue: record.category) else { return nil }
                    return EducationAlternative(level: level, percentFrequency: record.percentFrequency)
                }
                .sorted { $0.percentFrequency > $1.percentFrequency }

            guard let primaryEducationLevel = EducationLevel(rawValue: primaryEducation.category) else {
                skippedCount += 1
                continue
            }

            let educationReqs = EducationRequirements(
                requiredLevel: primaryEducationLevel,
                percentFrequency: primaryEducation.percentFrequency,
                confidence: primaryEducation.confidenceInterval,
                alternatives: alternatives
            )

            // Find primary experience requirement
            let primaryExperience = experienceRecords.max(by: { $0.percentFrequency < $1.percentFrequency })
            let experienceLevel = WorkExperienceLevel(rawValue: primaryExperience?.category ?? 1) ?? .none

            let experienceReqs = ExperienceRequirements(
                relatedWorkExperience: experienceLevel,
                percentFrequency: primaryExperience?.percentFrequency ?? 0.0,
                confidence: primaryExperience?.confidenceInterval ?? ConfidenceInterval(lower: 0, upper: 0, standardError: 0, sampleSize: 0)
            )

            // Training requirements (if available)
            let onSiteTraining: TrainingLevel? = onSiteRecords.max(by: { $0.percentFrequency < $1.percentFrequency }).map {
                TrainingLevel(
                    level: $0.category,
                    description: educationCategories["PT"]?[$0.category] ?? "On-Site Training",
                    percentFrequency: $0.percentFrequency
                )
            }

            let onJobTraining: TrainingLevel? = onJobRecords.max(by: { $0.percentFrequency < $1.percentFrequency }).map {
                TrainingLevel(
                    level: $0.category,
                    description: educationCategories["OJ"]?[$0.category] ?? "On-The-Job Training",
                    percentFrequency: $0.percentFrequency
                )
            }

            let trainingReqs = TrainingRequirements(
                onSiteTraining: onSiteTraining,
                onTheJobTraining: onJobTraining
            )

            let sector = Sector.determineSector(onetCode: onetCode, title: occupation.title)

            let credentials = OccupationCredentials(
                onetCode: onetCode,
                title: occupation.title,
                sector: sector,
                jobZone: jobZone,
                educationRequirements: educationReqs,
                experienceRequirements: experienceReqs,
                trainingRequirements: trainingReqs
            )

            occupationCredentials[onetCode] = credentials
            successCount += 1
        }

        print("✅ Synthesized \(successCount) occupation credentials")
        print("⚠️  Skipped \(skippedCount) occupations (missing data)")
    }

    // MARK: - Export to JSON
    func exportCredentials() throws {
        print("\n📝 Exporting credentials database...")

        let output = CredentialsDatabase(
            version: "1.0",
            source: "O*NET 30.0 Database",
            dateExtracted: ISO8601DateFormatter().string(from: Date()),
            totalOccupations: occupationCredentials.count,
            occupations: Array(occupationCredentials.values).sorted { $0.onetCode < $1.onetCode },
            attribution: """
            Education and credential data sourced from the O*NET® 30.0 Database by the U.S. Department \
            of Labor, Employment and Training Administration (USDOL/ETA), used under the CC BY 4.0 license. \
            Modified and integrated for ManifestAndMatch V8.
            """
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(output)
        try jsonData.write(to: URL(fileURLWithPath: "onet_credentials.json"))

        print("✅ Exported: onet_credentials.json")
        printStatistics()
    }

    // MARK: - Statistics
    func printStatistics() {
        print("\n" + String(repeating: "=", count: 80))
        print("📊 CREDENTIALS DATABASE STATISTICS")
        print(String(repeating: "=", count: 80))
        print()

        print("OVERVIEW:")
        print("   Total Occupations: \(occupationCredentials.count)")
        print()

        print("JOB ZONES DISTRIBUTION:")
        for zone in 1...5 {
            let count = occupationCredentials.values.filter { $0.jobZone.rawValue == zone }.count
            let percentage = Double(count) / Double(occupationCredentials.count) * 100
            let zoneName = JobZone(rawValue: zone)?.displayName ?? "Unknown"
            let percentStr = String(Int(percentage * 10) / 10)
            print("   Zone \(zone) (\(zoneName)): \(count) occupations (\(percentStr)%)")
        }
        print()

        print("EDUCATION LEVELS DISTRIBUTION:")
        for level in EducationLevel.allCases {
            let count = occupationCredentials.values.filter { $0.educationRequirements.requiredLevel == level }.count
            guard count > 0 else { continue }
            let percentage = Double(count) / Double(occupationCredentials.count) * 100
            let percentStr = String(Int(percentage * 10) / 10)
            print("   \(level.displayName) (\(level.rawValue)): \(count) occupations (\(percentStr)%)")
        }
        print()

        print("SECTOR DISTRIBUTION:")
        var sectorCounts: [String: Int] = [:]
        for sector in Sector.allCases {
            sectorCounts[sector.rawValue] = 0
        }
        for credentials in occupationCredentials.values {
            sectorCounts[credentials.sector, default: 0] += 1
        }
        for (sector, count) in sectorCounts.sorted(by: { $0.key < $1.key }) where count > 0 {
            let percentage = Double(count) / Double(occupationCredentials.count) * 100
            let percentStr = String(Int(percentage * 10) / 10)
            let paddedSector = sector.padding(toLength: 30, withPad: " ", startingAt: 0)
            print("   \(paddedSector): \(count) occupations (\(percentStr)%)")
        }
        print()

        print("EXPERIENCE REQUIREMENTS:")
        for level in WorkExperienceLevel.allCases {
            let count = occupationCredentials.values.filter { $0.experienceRequirements.relatedWorkExperience == level }.count
            guard count > 0 else { continue }
            let percentage = Double(count) / Double(occupationCredentials.count) * 100
            let percentStr = String(Int(percentage * 10) / 10)
            print("   \(level.displayName) (\(level.rawValue)): \(count) occupations (\(percentStr)%)")
        }
        print()

        print(String(repeating: "=", count: 80))
    }
}

// MARK: - Main Execution
print(String(repeating: "=", count: 80))
print("O*NET Credentials Parser for ManifestAndMatch V8")
print("iOS 26 Compatible | Swift 6 Ready | O*NET 30.0")
print(String(repeating: "=", count: 80))
print()

let parser = ONetCredentialsParser()

do {
    try parser.parseOccupations()
    try parser.parseEducationCategories()
    try parser.parseJobZones()
    try parser.parseEducationRequirements()
    try parser.exportCredentials()

    print("\n" + String(repeating: "=", count: 80))
    print("✅ PARSING COMPLETE")
    print(String(repeating: "=", count: 80))
    print()
    print("📄 Output: onet_credentials.json")
    print("📊 Ready for ManifestAndMatch V8 integration")
    print()
    print("NEXT STEPS:")
    print("1. Verify onet_credentials.json structure")
    print("2. Copy to Packages/V7Core/Sources/V7Core/Resources/")
    print("3. Update Package.swift to include new resource")
    print("4. Integrate with UserProfile model")
    print("5. Update Thompson scoring with education/experience matching")
    print()

} catch {
    print("\n❌ ERROR: \(error)")
    print("Please ensure all required files are in the current directory:")
    print("   - Occupation_Data.txt")
    print("   - Education, Training, and Experience.txt")
    print("   - Education, Training, and Experience Categories.txt")
    print("   - Job Zones.txt")
    exit(1)
}
