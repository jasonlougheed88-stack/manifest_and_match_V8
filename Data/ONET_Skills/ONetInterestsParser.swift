#!/usr/bin/env swift

import Foundation

// MARK: - O*NET Interests Parser for ManifestAndMatch V8
// Purpose: Parse RIASEC interests (6 types) from O*NET 30.0 for career matching
// Output: onet_interests.json for personality-based job discovery
// iOS 26 Compatible: Swift 6 strict concurrency patterns
// Created: October 28, 2025
//
// Strategic Importance: HIGH Priority (Critical for Amber→Teal)
// RIASEC model measures occupational interests based on personality type
// Foundation for career exploration beyond current skills
// Generated via Machine Learning from O*NET occupation data

// MARK: - RIASEC Interest Types (6 personality dimensions)

enum InterestType: String, Codable, CaseIterable {
    case realistic = "Realistic"
    case investigative = "Investigative"
    case artistic = "Artistic"
    case social = "Social"
    case enterprising = "Enterprising"
    case conventional = "Conventional"

    var onetId: String {
        switch self {
        case .realistic: return "1.B.1.a"
        case .investigative: return "1.B.1.b"
        case .artistic: return "1.B.1.c"
        case .social: return "1.B.1.d"
        case .enterprising: return "1.B.1.e"
        case .conventional: return "1.B.1.f"
        }
    }

    var shortCode: String {
        switch self {
        case .realistic: return "R"
        case .investigative: return "I"
        case .artistic: return "A"
        case .social: return "S"
        case .enterprising: return "E"
        case .conventional: return "C"
        }
    }

    var description: String {
        switch self {
        case .realistic:
            return "Prefer hands-on work with tools, machines, animals, or being outdoors. Practical, physical, mechanical."
        case .investigative:
            return "Prefer to solve problems through research, analysis, and abstract thinking. Scientific, analytical, curious."
        case .artistic:
            return "Prefer creative expression through art, music, writing, or design. Innovative, original, independent."
        case .social:
            return "Prefer helping, teaching, counseling, or serving others. Cooperative, empathetic, patient."
        case .enterprising:
            return "Prefer leading, persuading, managing, or taking financial/business risks. Ambitious, energetic, competitive."
        case .conventional:
            return "Prefer working with data, details, organization, and following procedures. Organized, precise, efficient."
        }
    }

    var typicalOccupations: [String] {
        switch self {
        case .realistic:
            return ["Mechanic", "Electrician", "Farmer", "Carpenter", "Pilot", "Engineer"]
        case .investigative:
            return ["Scientist", "Researcher", "Analyst", "Doctor", "Programmer", "Mathematician"]
        case .artistic:
            return ["Designer", "Artist", "Writer", "Musician", "Actor", "Architect"]
        case .social:
            return ["Teacher", "Counselor", "Nurse", "Social Worker", "Therapist", "Trainer"]
        case .enterprising:
            return ["Manager", "Executive", "Salesperson", "Entrepreneur", "Lawyer", "Politician"]
        case .conventional:
            return ["Accountant", "Administrator", "Banker", "Secretary", "Auditor", "Bookkeeper"]
        }
    }

    var compatibleTypes: [InterestType] {
        // Holland's RIASEC hexagon model - adjacent types are compatible
        switch self {
        case .realistic:
            return [.investigative, .conventional]
        case .investigative:
            return [.realistic, .artistic]
        case .artistic:
            return [.investigative, .social]
        case .social:
            return [.artistic, .enterprising]
        case .enterprising:
            return [.social, .conventional]
        case .conventional:
            return [.enterprising, .realistic]
        }
    }

    var oppositeType: InterestType {
        // Opposite types on Holland's hexagon
        switch self {
        case .realistic: return .social
        case .investigative: return .enterprising
        case .artistic: return .conventional
        case .social: return .realistic
        case .enterprising: return .investigative
        case .conventional: return .artistic
        }
    }
}

// MARK: - Sector Mapping (19 sectors from V7/V8 architecture)

enum Sector: String, CaseIterable {
    case officeAdmin = "Office/Administrative"
    case healthcare = "Healthcare"
    case technology = "Technology"
    case finance = "Finance"
    case education = "Education"
    case legal = "Legal"
    case marketing = "Marketing"
    case humanResources = "Human Resources"
    case retail = "Retail"
    case foodService = "Food Service"
    case skilledTrades = "Skilled Trades"
    case construction = "Construction"
    case warehouseLogistics = "Warehouse/Logistics"
    case personalCare = "Personal Care/Service"
    case science = "Science/Research"
    case arts = "Arts/Design/Media"
    case protectiveService = "Protective Service"
    case socialService = "Social/Community Service"
    case realEstate = "Real Estate"

    func matches(onetCode: String, title: String = "") -> Bool {
        let code = onetCode.prefix(2)

        switch self {
        case .officeAdmin:
            return code == "43"
        case .healthcare:
            return code == "29" || code == "31"
        case .technology:
            return code == "15"
        case .finance:
            return code == "13"
        case .education:
            return code == "25"
        case .legal:
            return code == "23"
        case .marketing:
            return code == "11" && (title.contains("Marketing") || title.contains("Advertising") || title.contains("Public Relations"))
        case .humanResources:
            return code == "11" && (title.contains("Human Resources") || title.contains("Training") || title.contains("Compensation"))
        case .retail:
            return code == "41"
        case .foodService:
            return code == "35"
        case .skilledTrades:
            return code == "47" || code == "49"
        case .construction:
            return code == "47" && (title.contains("Construct") || title.contains("Builder") || title.contains("Superintendent"))
        case .warehouseLogistics:
            return code == "53"
        case .personalCare:
            return code == "39"
        case .science:
            return code == "19"
        case .arts:
            return code == "27"
        case .protectiveService:
            return code == "33"
        case .socialService:
            return code == "21"
        case .realEstate:
            return code == "41" && (title.contains("Real Estate") || title.contains("Broker") || title.contains("Agent"))
        }
    }

    static func determineSector(onetCode: String, title: String) -> String {
        for sector in Sector.allCases {
            if sector.matches(onetCode: onetCode, title: title) {
                return sector.rawValue
            }
        }
        return "Office/Administrative"
    }
}

// MARK: - Data Models

struct RIASECProfile: Codable {
    let realistic: Double
    let investigative: Double
    let artistic: Double
    let social: Double
    let enterprising: Double
    let conventional: Double

    var hollandCode: String {
        // Top 3 interests in order (e.g., "RIA", "SEC")
        let scores = [
            ("R", realistic),
            ("I", investigative),
            ("A", artistic),
            ("S", social),
            ("E", enterprising),
            ("C", conventional)
        ]
        let sorted = scores.sorted { $0.1 > $1.1 }.prefix(3)
        return sorted.map { $0.0 }.joined()
    }

    var dominantInterest: String {
        let scores = [
            (InterestType.realistic.rawValue, realistic),
            (InterestType.investigative.rawValue, investigative),
            (InterestType.artistic.rawValue, artistic),
            (InterestType.social.rawValue, social),
            (InterestType.enterprising.rawValue, enterprising),
            (InterestType.conventional.rawValue, conventional)
        ]
        return scores.max { $0.1 < $1.1 }?.0 ?? "Realistic"
    }

    func similarity(to other: RIASECProfile) -> Double {
        // Cosine similarity between RIASEC vectors
        let dotProduct = (realistic * other.realistic) +
                        (investigative * other.investigative) +
                        (artistic * other.artistic) +
                        (social * other.social) +
                        (enterprising * other.enterprising) +
                        (conventional * other.conventional)

        let magnitudeA = sqrt(realistic * realistic +
                             investigative * investigative +
                             artistic * artistic +
                             social * social +
                             enterprising * enterprising +
                             conventional * conventional)

        let magnitudeB = sqrt(other.realistic * other.realistic +
                             other.investigative * other.investigative +
                             other.artistic * other.artistic +
                             other.social * other.social +
                             other.enterprising * other.enterprising +
                             other.conventional * other.conventional)

        guard magnitudeA > 0 && magnitudeB > 0 else { return 0.0 }
        return dotProduct / (magnitudeA * magnitudeB)
    }
}

struct OccupationInterests: Codable {
    let onetCode: String
    let title: String
    let sector: String
    let riasecProfile: RIASECProfile
    let hollandCode: String
    let dominantInterest: String
    let topThreeInterests: [String]
}

struct InterestsDatabase: Codable {
    let version: String
    let source: String
    let generatedDate: String
    let dataSource: String
    let totalOccupations: Int
    let occupations: [OccupationInterests]
    let interestDistribution: [String: Int]
}

// MARK: - Parser Class

class ONetInterestsParser {
    private var occupations: [String: (code: String, title: String)] = [:]
    private var interestScores: [String: [String: Double]] = [:]
    private var interestHighPoints: [String: [Int]] = [:]

    private let baseDir = "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8/Data/ONET_Skills"

    // MARK: - Main Execution

    func run() throws {
        print("🚀 O*NET RIASEC Interests Parser for ManifestAndMatch V8")
        print("=" * 80)
        print("")

        print("📂 Phase 1: Loading occupation data...")
        try parseOccupations()
        print("   ✅ Loaded \(occupations.count) occupations")
        print("")

        print("📊 Phase 2: Parsing RIASEC interest profiles...")
        try parseInterests()
        print("   ✅ Parsed RIASEC profiles for \(interestScores.count) occupations")
        print("")

        print("🔄 Phase 3: Building database...")
        let database = buildDatabase()
        print("   ✅ Built database with \(database.occupations.count) complete interest profiles")
        print("")

        print("💾 Phase 4: Exporting JSON...")
        try exportDatabase(database)
        print("")

        print("📈 Phase 5: Statistics...")
        printStatistics(database)
        print("")

        print("✅ RIASEC interests parsing complete!")
        print("=" * 80)
    }

    // MARK: - Parsing Functions

    func parseOccupations() throws {
        let filePath = "\(baseDir)/Occupation Data.txt"
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }

            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 2 else { continue }

            let code = fields[0].trimmingCharacters(in: .whitespaces)
            let title = fields[1].trimmingCharacters(in: .whitespaces)

            occupations[code] = (code, title)
        }
    }

    func parseInterests() throws {
        let filePath = "\(baseDir)/Interests.txt"
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        var processedCount = 0

        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }

            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 5 else { continue }

            let onetCode = fields[0].trimmingCharacters(in: .whitespaces)
            let elementId = fields[1].trimmingCharacters(in: .whitespaces)
            let scaleId = fields[3].trimmingCharacters(in: .whitespaces)
            let dataValue = Double(fields[4]) ?? 0.0

            // Parse RIASEC scores (OI = Occupational Interests)
            if scaleId == "OI" {
                if interestScores[onetCode] == nil {
                    interestScores[onetCode] = [:]
                }
                interestScores[onetCode]![elementId] = dataValue
                processedCount += 1
            }

            // Parse high-point rankings (IH = Interest High-Point)
            if scaleId == "IH" {
                if interestHighPoints[onetCode] == nil {
                    interestHighPoints[onetCode] = []
                }
                interestHighPoints[onetCode]!.append(Int(dataValue))
            }
        }

        print("   📊 Processed \(processedCount) RIASEC scores across \(interestScores.count) occupations")
    }

    // MARK: - Database Building

    func buildDatabase() -> InterestsDatabase {
        var occupationProfiles: [OccupationInterests] = []
        var dominantInterestCounts: [String: Int] = [:]

        for (onetCode, scores) in interestScores {
            guard let occupation = occupations[onetCode] else { continue }
            guard scores.count == 6 else { continue }  // Must have all 6 RIASEC scores

            let riasecProfile = RIASECProfile(
                realistic: scores["1.B.1.a"] ?? 0.0,
                investigative: scores["1.B.1.b"] ?? 0.0,
                artistic: scores["1.B.1.c"] ?? 0.0,
                social: scores["1.B.1.d"] ?? 0.0,
                enterprising: scores["1.B.1.e"] ?? 0.0,
                conventional: scores["1.B.1.f"] ?? 0.0
            )

            let hollandCode = riasecProfile.hollandCode
            let dominantInterest = riasecProfile.dominantInterest

            // Get top 3 interests based on scores
            let sortedInterests = [
                (InterestType.realistic.rawValue, riasecProfile.realistic),
                (InterestType.investigative.rawValue, riasecProfile.investigative),
                (InterestType.artistic.rawValue, riasecProfile.artistic),
                (InterestType.social.rawValue, riasecProfile.social),
                (InterestType.enterprising.rawValue, riasecProfile.enterprising),
                (InterestType.conventional.rawValue, riasecProfile.conventional)
            ].sorted { $0.1 > $1.1 }.prefix(3).map { $0.0 }

            let sector = Sector.determineSector(onetCode: onetCode, title: occupation.title)

            let profile = OccupationInterests(
                onetCode: onetCode,
                title: occupation.title,
                sector: sector,
                riasecProfile: riasecProfile,
                hollandCode: hollandCode,
                dominantInterest: dominantInterest,
                topThreeInterests: Array(sortedInterests)
            )

            occupationProfiles.append(profile)
            dominantInterestCounts[dominantInterest, default: 0] += 1
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return InterestsDatabase(
            version: "1.0",
            source: "O*NET 30.0 Database - Interests (RIASEC Model)",
            generatedDate: dateFormatter.string(from: Date()),
            dataSource: "Machine Learning",
            totalOccupations: occupationProfiles.count,
            occupations: occupationProfiles.sorted { $0.onetCode < $1.onetCode },
            interestDistribution: dominantInterestCounts
        )
    }

    // MARK: - Export

    func exportDatabase(_ database: InterestsDatabase) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try encoder.encode(database)
        let outputPath = "\(baseDir)/onet_interests.json"

        try jsonData.write(to: URL(fileURLWithPath: outputPath))

        let fileSizeMB = Double(jsonData.count) / 1_048_576.0
        print("   ✅ Exported to: onet_interests.json")
        print("   📦 File size: \(String(format: "%.2f", fileSizeMB)) MB")
    }

    // MARK: - Statistics

    func printStatistics(_ database: InterestsDatabase) {
        print("📊 RIASEC Interests Statistics:")
        print("=" * 80)
        print("")

        print("📈 Overall Metrics:")
        print("   • Total Occupations: \(database.totalOccupations)")
        print("   • Data Source: \(database.dataSource)")
        print("")

        print("🎯 Dominant Interest Distribution:")
        let sortedDistribution = database.interestDistribution.sorted { $0.value > $1.value }
        for (interest, count) in sortedDistribution {
            let percentage = Double(count) / Double(database.totalOccupations) * 100
            print("   • \(interest): \(count) occupations (\(String(format: "%.1f", percentage))%)")
        }
        print("")

        // Top 10 Holland Codes
        var hollandCodeCounts: [String: Int] = [:]
        for occupation in database.occupations {
            hollandCodeCounts[occupation.hollandCode, default: 0] += 1
        }
        let topHollandCodes = hollandCodeCounts.sorted { $0.value > $1.value }.prefix(10)

        print("🔤 Top 10 Most Common Holland Codes:")
        for (index, (code, count)) in topHollandCodes.enumerated() {
            print("   \(index + 1). \(code): \(count) occupations")
        }
        print("")

        // Sector distribution
        var sectorCounts: [String: Int] = [:]
        for occupation in database.occupations {
            sectorCounts[occupation.sector, default: 0] += 1
        }

        print("🏢 Sector Distribution:")
        for (sector, count) in sectorCounts.sorted(by: { $0.value > $1.value }).prefix(10) {
            let percentage = Double(count) / Double(database.totalOccupations) * 100
            print("   • \(sector): \(count) (\(String(format: "%.1f", percentage))%)")
        }
        print("")

        // Sample profiles
        print("📋 Sample RIASEC Profiles:")
        for occupation in database.occupations.prefix(5) {
            print("   • \(occupation.title) (\(occupation.hollandCode))")
            print("     Realistic: \(String(format: "%.2f", occupation.riasecProfile.realistic))")
            print("     Investigative: \(String(format: "%.2f", occupation.riasecProfile.investigative))")
            print("     Artistic: \(String(format: "%.2f", occupation.riasecProfile.artistic))")
            print("     Social: \(String(format: "%.2f", occupation.riasecProfile.social))")
            print("     Enterprising: \(String(format: "%.2f", occupation.riasecProfile.enterprising))")
            print("     Conventional: \(String(format: "%.2f", occupation.riasecProfile.conventional))")
        }
    }
}

// MARK: - String Repetition Helper

extension String {
    static func * (left: String, right: Int) -> String {
        String(repeating: left, count: right)
    }
}

// MARK: - Main Execution

let parser = ONetInterestsParser()
do {
    try parser.run()
} catch {
    print("❌ Error: \(error.localizedDescription)")
    exit(1)
}
