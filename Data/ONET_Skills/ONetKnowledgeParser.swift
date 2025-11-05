#!/usr/bin/env swift

import Foundation

// MARK: - O*NET Knowledge Parser for ManifestAndMatch V8
// Purpose: Parse 33 knowledge areas from O*NET 30.0 for profile enhancement
// Output: onet_knowledge.json for educational background and domain expertise matching
// iOS 26 Compatible: Swift 6 strict concurrency patterns
// Created: October 28, 2025
//
// Strategic Importance: MEDIUM-HIGH Priority
// Knowledge areas represent formal education, training, and domain expertise
// Complements skills (WHAT you can do) with knowledge (WHAT you understand)
// Critical for education/training recommendations and career transitions

// MARK: - Knowledge Categories (10 major groups)

enum KnowledgeCategory: String, Codable, CaseIterable {
    case business = "Business and Management"
    case manufacturing = "Manufacturing and Production"
    case engineeringTech = "Engineering and Technology"
    case sciences = "Sciences and Mathematics"
    case healthServices = "Health Services"
    case education = "Education and Training"
    case artsHumanities = "Arts and Humanities"
    case lawSafety = "Law and Public Safety"
    case communications = "Communications and Media"
    case transportation = "Transportation"

    var description: String {
        switch self {
        case .business:
            return "Knowledge of business operations, management, economics, and customer service"
        case .manufacturing:
            return "Knowledge of production processes, materials, and quality control"
        case .engineeringTech:
            return "Knowledge of engineering principles, technology systems, and mechanical design"
        case .sciences:
            return "Knowledge of scientific principles in mathematics, natural sciences, and social sciences"
        case .healthServices:
            return "Knowledge of medical practices, patient care, and therapeutic interventions"
        case .education:
            return "Knowledge of teaching methods, curriculum design, and training principles"
        case .artsHumanities:
            return "Knowledge of languages, arts, history, and cultural studies"
        case .lawSafety:
            return "Knowledge of legal systems, regulations, and public safety procedures"
        case .communications:
            return "Knowledge of media production, telecommunications, and information dissemination"
        case .transportation:
            return "Knowledge of transportation methods, routing, and logistics"
        }
    }
}

// MARK: - Individual Knowledge Areas (33 areas)

enum KnowledgeArea: String, Codable, CaseIterable {
    // Business and Management (6 areas)
    case adminManagement = "Administration and Management"
    case administrative = "Administrative"
    case economicsAccounting = "Economics and Accounting"
    case salesMarketing = "Sales and Marketing"
    case customerService = "Customer and Personal Service"
    case personnelHR = "Personnel and Human Resources"

    // Manufacturing and Production (2 areas)
    case productionProcessing = "Production and Processing"
    case foodProduction = "Food Production"

    // Engineering and Technology (5 areas)
    case computersElectronics = "Computers and Electronics"
    case engineeringTech = "Engineering and Technology"
    case design = "Design"
    case buildingConstruction = "Building and Construction"
    case mechanical = "Mechanical"

    // Sciences and Mathematics (7 areas)
    case mathematics = "Mathematics"
    case physics = "Physics"
    case chemistry = "Chemistry"
    case biology = "Biology"
    case psychology = "Psychology"
    case sociologyAnthropology = "Sociology and Anthropology"
    case geography = "Geography"

    // Health Services (2 areas)
    case medicineDentistry = "Medicine and Dentistry"
    case therapyCounseling = "Therapy and Counseling"

    // Education and Training (1 area)
    case educationTraining = "Education and Training"

    // Arts and Humanities (5 areas)
    case englishLanguage = "English Language"
    case foreignLanguage = "Foreign Language"
    case fineArts = "Fine Arts"
    case historyArcheology = "History and Archeology"
    case philosophyTheology = "Philosophy and Theology"

    // Law and Public Safety (2 areas)
    case publicSafetySecurity = "Public Safety and Security"
    case lawGovernment = "Law and Government"

    // Communications and Media (2 areas)
    case telecommunications = "Telecommunications"
    case communicationsMedia = "Communications and Media"

    // Transportation (1 area)
    case transportation = "Transportation"

    var onetId: String {
        switch self {
        // Business and Management
        case .adminManagement: return "2.C.1.a"
        case .administrative: return "2.C.1.b"
        case .economicsAccounting: return "2.C.1.c"
        case .salesMarketing: return "2.C.1.d"
        case .customerService: return "2.C.1.e"
        case .personnelHR: return "2.C.1.f"

        // Manufacturing and Production
        case .productionProcessing: return "2.C.2.a"
        case .foodProduction: return "2.C.2.b"

        // Engineering and Technology
        case .computersElectronics: return "2.C.3.a"
        case .engineeringTech: return "2.C.3.b"
        case .design: return "2.C.3.c"
        case .buildingConstruction: return "2.C.3.d"
        case .mechanical: return "2.C.3.e"

        // Sciences and Mathematics
        case .mathematics: return "2.C.4.a"
        case .physics: return "2.C.4.b"
        case .chemistry: return "2.C.4.c"
        case .biology: return "2.C.4.d"
        case .psychology: return "2.C.4.e"
        case .sociologyAnthropology: return "2.C.4.f"
        case .geography: return "2.C.4.g"

        // Health Services
        case .medicineDentistry: return "2.C.5.a"
        case .therapyCounseling: return "2.C.5.b"

        // Education and Training
        case .educationTraining: return "2.C.6"

        // Arts and Humanities
        case .englishLanguage: return "2.C.7.a"
        case .foreignLanguage: return "2.C.7.b"
        case .fineArts: return "2.C.7.c"
        case .historyArcheology: return "2.C.7.d"
        case .philosophyTheology: return "2.C.7.e"

        // Law and Public Safety
        case .publicSafetySecurity: return "2.C.8.a"
        case .lawGovernment: return "2.C.8.b"

        // Communications and Media
        case .telecommunications: return "2.C.9.a"
        case .communicationsMedia: return "2.C.9.b"

        // Transportation
        case .transportation: return "2.C.10"
        }
    }

    var category: KnowledgeCategory {
        let id = onetId

        if id.hasPrefix("2.C.1.") {
            return .business
        } else if id.hasPrefix("2.C.2.") {
            return .manufacturing
        } else if id.hasPrefix("2.C.3.") {
            return .engineeringTech
        } else if id.hasPrefix("2.C.4.") {
            return .sciences
        } else if id.hasPrefix("2.C.5.") {
            return .healthServices
        } else if id == "2.C.6" {
            return .education
        } else if id.hasPrefix("2.C.7.") {
            return .artsHumanities
        } else if id.hasPrefix("2.C.8.") {
            return .lawSafety
        } else if id.hasPrefix("2.C.9.") {
            return .communications
        } else if id == "2.C.10" {
            return .transportation
        }

        return .business  // Fallback
    }

    var educationLevel: String {
        // Higher education typically required for these knowledge areas
        if [.mathematics, .physics, .chemistry, .biology, .medicineDentistry,
            .engineeringTech, .lawGovernment, .philosophyTheology].contains(self) {
            return "Bachelor's Degree or Higher"
        }

        // Specialized training or associate degree
        if [.computersElectronics, .mechanical, .design, .therapyCounseling,
            .educationTraining, .buildingConstruction].contains(self) {
            return "Associate's Degree or Higher"
        }

        // Can be acquired through experience and training
        return "High School Diploma or Higher"
    }

    var transferabilityScore: Double {
        // Highly transferable knowledge (0.85-1.0): Applicable across many sectors
        if [.adminManagement, .customerService, .englishLanguage,
            .communicationsMedia, .psychology].contains(self) {
            return 0.90
        }

        // Moderately transferable (0.6-0.84): Valuable in multiple related sectors
        if [.economicsAccounting, .personnelHR, .salesMarketing,
            .computersElectronics, .mathematics, .educationTraining].contains(self) {
            return 0.75
        }

        // Specialized knowledge (0.4-0.59): Sector-specific but valuable
        if [.medicineDentistry, .lawGovernment, .engineeringTech,
            .buildingConstruction, .mechanical, .physics, .chemistry,
            .biology, .foodProduction].contains(self) {
            return 0.50
        }

        // Niche knowledge (0.2-0.39): Highly specialized
        if [.foreignLanguage, .fineArts, .historyArcheology, .philosophyTheology,
            .geography, .sociologyAnthropology, .telecommunications,
            .publicSafetySecurity, .transportation, .therapyCounseling].contains(self) {
            return 0.35
        }

        return 0.65  // Default moderate transferability
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

struct KnowledgeRating: Codable {
    let importance: Double
    let level: Double
    let confidence: ConfidenceInterval?
    let sampleSize: Int

    var isHighQuality: Bool {
        sampleSize >= 30
    }
}

struct ConfidenceInterval: Codable {
    let lower: Double
    let upper: Double
    let standardError: Double
}

struct OccupationKnowledge: Codable {
    let onetCode: String
    let title: String
    let sector: String
    let knowledge: [String: KnowledgeRating]  // Knowledge ID -> Rating
    let topKnowledge: [String]  // Top 5 knowledge areas by importance
    let knowledgeCount: Int
}

struct KnowledgeDatabase: Codable {
    let version: String
    let source: String
    let generatedDate: String
    let totalOccupations: Int
    let totalKnowledgeAreas: Int
    let occupations: [OccupationKnowledge]
    let knowledgeMetadata: [KnowledgeMetadata]
}

struct KnowledgeMetadata: Codable {
    let knowledgeId: String
    let knowledgeName: String
    let category: String
    let educationLevel: String
    let transferabilityScore: Double
    let occurrenceCount: Int
    let averageImportance: Double
}

// MARK: - Parser Class

class ONetKnowledgeParser {
    private var occupations: [String: (code: String, title: String)] = [:]
    private var knowledgeRatings: [String: [String: (importance: Double?, level: Double?, n: Int?, se: Double?, lowerCI: Double?, upperCI: Double?)]] = [:]

    private let baseDir = "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8/Data/ONET_Skills"

    // MARK: - Main Execution

    func run() throws {
        print("🚀 O*NET Knowledge Parser for ManifestAndMatch V8")
        print("=" * 80)
        print("")

        print("📂 Phase 1: Loading occupation data...")
        try parseOccupations()
        print("   ✅ Loaded \(occupations.count) occupations")
        print("")

        print("📊 Phase 2: Parsing knowledge ratings...")
        try parseKnowledge()
        print("   ✅ Parsed knowledge ratings for \(knowledgeRatings.count) occupations")
        print("")

        print("🔄 Phase 3: Building database...")
        let database = buildDatabase()
        print("   ✅ Built database with \(database.occupations.count) complete occupation profiles")
        print("")

        print("💾 Phase 4: Exporting JSON...")
        try exportDatabase(database)
        print("")

        print("📈 Phase 5: Statistics...")
        printStatistics(database)
        print("")

        print("✅ Knowledge parsing complete!")
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

    func parseKnowledge() throws {
        let filePath = "\(baseDir)/Knowledge.txt"
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        var processedCount = 0

        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }

            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 13 else { continue }

            let onetCode = fields[0].trimmingCharacters(in: .whitespaces)
            let elementId = fields[1].trimmingCharacters(in: .whitespaces)
            let scaleId = fields[3].trimmingCharacters(in: .whitespaces)
            let suppressStr = fields[9].trimmingCharacters(in: .whitespaces)

            // Skip if recommended to suppress
            if suppressStr == "Y" { continue }

            // Parse numeric values
            let dataValue = Double(fields[4]) ?? 0.0
            let n = Int(fields[5]) ?? 0
            let se = Double(fields[6]) ?? 0.0
            let lowerCI = Double(fields[7]) ?? 0.0
            let upperCI = Double(fields[8]) ?? 0.0

            // Initialize knowledge record if needed
            if knowledgeRatings[onetCode] == nil {
                knowledgeRatings[onetCode] = [:]
            }
            if knowledgeRatings[onetCode]![elementId] == nil {
                knowledgeRatings[onetCode]![elementId] = (nil, nil, nil, nil, nil, nil)
            }

            // Store rating by scale (IM = Importance, LV = Level)
            var current = knowledgeRatings[onetCode]![elementId]!

            if scaleId == "IM" {
                current.importance = dataValue
                current.n = n
                current.se = se
                current.lowerCI = lowerCI
                current.upperCI = upperCI
            } else if scaleId == "LV" {
                current.level = dataValue
            }

            knowledgeRatings[onetCode]![elementId] = current
            processedCount += 1
        }

        print("   📊 Processed \(processedCount) knowledge ratings across \(knowledgeRatings.count) occupations")
    }

    // MARK: - Database Building

    func buildDatabase() -> KnowledgeDatabase {
        var occupationProfiles: [OccupationKnowledge] = []
        var knowledgeOccurrences: [String: Int] = [:]
        var knowledgeImportanceSum: [String: Double] = [:]

        for (onetCode, ratings) in knowledgeRatings {
            guard let occupation = occupations[onetCode] else { continue }

            var knowledge: [String: KnowledgeRating] = [:]

            for (knowledgeId, rating) in ratings {
                // Both importance and level must be present
                guard let importance = rating.importance,
                      let level = rating.level,
                      let n = rating.n,
                      n >= 30 else { continue }

                let confidence = ConfidenceInterval(
                    lower: rating.lowerCI ?? 0.0,
                    upper: rating.upperCI ?? 0.0,
                    standardError: rating.se ?? 0.0
                )

                let knowledgeRating = KnowledgeRating(
                    importance: importance,
                    level: level,
                    confidence: confidence,
                    sampleSize: n
                )

                knowledge[knowledgeId] = knowledgeRating

                // Track occurrences for metadata
                knowledgeOccurrences[knowledgeId, default: 0] += 1
                knowledgeImportanceSum[knowledgeId, default: 0.0] += importance
            }

            // Get top 5 knowledge areas by importance
            let topKnowledge = knowledge
                .sorted { $0.value.importance > $1.value.importance }
                .prefix(5)
                .map { $0.key }

            let sector = Sector.determineSector(onetCode: onetCode, title: occupation.title)

            let profile = OccupationKnowledge(
                onetCode: onetCode,
                title: occupation.title,
                sector: sector,
                knowledge: knowledge,
                topKnowledge: Array(topKnowledge),
                knowledgeCount: knowledge.count
            )

            occupationProfiles.append(profile)
        }

        // Build knowledge metadata
        let knowledgeMetadata = KnowledgeArea.allCases.map { area -> KnowledgeMetadata in
            let occurrences = knowledgeOccurrences[area.onetId] ?? 0
            let avgImportance = occurrences > 0
                ? (knowledgeImportanceSum[area.onetId] ?? 0.0) / Double(occurrences)
                : 0.0

            return KnowledgeMetadata(
                knowledgeId: area.onetId,
                knowledgeName: area.rawValue,
                category: area.category.rawValue,
                educationLevel: area.educationLevel,
                transferabilityScore: area.transferabilityScore,
                occurrenceCount: occurrences,
                averageImportance: avgImportance
            )
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return KnowledgeDatabase(
            version: "1.0",
            source: "O*NET 30.0 Database - Knowledge",
            generatedDate: dateFormatter.string(from: Date()),
            totalOccupations: occupationProfiles.count,
            totalKnowledgeAreas: KnowledgeArea.allCases.count,
            occupations: occupationProfiles.sorted { $0.onetCode < $1.onetCode },
            knowledgeMetadata: knowledgeMetadata.sorted { $0.knowledgeId < $1.knowledgeId }
        )
    }

    // MARK: - Export

    func exportDatabase(_ database: KnowledgeDatabase) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try encoder.encode(database)
        let outputPath = "\(baseDir)/onet_knowledge.json"

        try jsonData.write(to: URL(fileURLWithPath: outputPath))

        let fileSizeMB = Double(jsonData.count) / 1_048_576.0
        print("   ✅ Exported to: onet_knowledge.json")
        print("   📦 File size: \(String(format: "%.2f", fileSizeMB)) MB")
    }

    // MARK: - Statistics

    func printStatistics(_ database: KnowledgeDatabase) {
        print("📊 Knowledge Statistics:")
        print("=" * 80)
        print("")

        print("📈 Overall Metrics:")
        print("   • Total Occupations: \(database.totalOccupations)")
        print("   • Total Knowledge Areas: \(database.totalKnowledgeAreas)")
        print("")

        // Knowledge per occupation distribution
        let knowledgeCounts = database.occupations.map { $0.knowledgeCount }
        let avgKnowledge = knowledgeCounts.reduce(0, +) / knowledgeCounts.count
        let minKnowledge = knowledgeCounts.min() ?? 0
        let maxKnowledge = knowledgeCounts.max() ?? 0

        print("🎯 Knowledge Areas per Occupation:")
        print("   • Average: \(avgKnowledge)")
        print("   • Range: \(minKnowledge) - \(maxKnowledge)")
        print("")

        // Top 10 most common knowledge areas
        let topCommon = database.knowledgeMetadata
            .sorted { $0.occurrenceCount > $1.occurrenceCount }
            .prefix(10)

        print("🔝 Top 10 Most Common Knowledge Areas:")
        for (index, knowledge) in topCommon.enumerated() {
            let percentage = Double(knowledge.occurrenceCount) / Double(database.totalOccupations) * 100
            print("   \(index + 1). \(knowledge.knowledgeName)")
            print("      Occurs in \(knowledge.occurrenceCount) occupations (\(String(format: "%.1f", percentage))%)")
            print("      Avg Importance: \(String(format: "%.2f", knowledge.averageImportance))")
            print("      Education: \(knowledge.educationLevel)")
            print("      Transferability: \(String(format: "%.2f", knowledge.transferabilityScore))")
        }
        print("")

        // Category distribution
        var categoryCounts: [String: Int] = [:]
        for knowledge in database.knowledgeMetadata {
            categoryCounts[knowledge.category, default: 0] += 1
        }

        print("📚 Knowledge Category Distribution:")
        for (category, count) in categoryCounts.sorted(by: { $0.key < $1.key }) {
            print("   • \(category): \(count) areas")
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
    }
}

// MARK: - String Repetition Helper

extension String {
    static func * (left: String, right: Int) -> String {
        String(repeating: left, count: right)
    }
}

// MARK: - Main Execution

let parser = ONetKnowledgeParser()
do {
    try parser.run()
} catch {
    print("❌ Error: \(error.localizedDescription)")
    exit(1)
}
