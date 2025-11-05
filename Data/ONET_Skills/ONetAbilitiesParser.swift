#!/usr/bin/env swift

import Foundation

// MARK: - O*NET Abilities Parser for ManifestAndMatch V8
// Purpose: Parse 52 abilities from O*NET 30.0 for comprehensive capability assessment
// Output: onet_abilities.json for matching user capabilities with job requirements
// iOS 26 Compatible: Swift 6 strict concurrency patterns
// Created: October 28, 2025
//
// Strategic Importance: MEDIUM Priority (Tier 2)
// Abilities represent innate or developed capabilities (cognitive, physical, sensory)
// Complements skills (learned proficiencies) and knowledge (formal education)
// Critical for identifying transferable capabilities across occupations

// MARK: - Ability Categories (4 major groups)

enum AbilityCategory: String, Codable, CaseIterable {
    case cognitive = "Cognitive Abilities"
    case psychomotor = "Psychomotor Abilities"
    case physical = "Physical Abilities"
    case sensory = "Sensory Abilities"

    var description: String {
        switch self {
        case .cognitive:
            return "Mental abilities for thinking, reasoning, memory, and problem-solving"
        case .psychomotor:
            return "Abilities for physical coordination, dexterity, and motor control"
        case .physical:
            return "Abilities for strength, endurance, flexibility, and gross body movements"
        case .sensory:
            return "Abilities for vision, hearing, and sensory perception"
        }
    }

    var transferability: Double {
        switch self {
        case .cognitive:
            return 0.90  // Highly transferable across sectors
        case .psychomotor:
            return 0.60  // Moderately transferable (more sector-specific)
        case .physical:
            return 0.50  // Sector-specific (trades, construction, logistics)
        case .sensory:
            return 0.65  // Moderately transferable (required in many roles)
        }
    }
}

// MARK: - Individual Abilities (52 total)

enum Ability: String, Codable, CaseIterable {
    // Cognitive Abilities - Verbal (4)
    case oralComprehension = "Oral Comprehension"
    case writtenComprehension = "Written Comprehension"
    case oralExpression = "Oral Expression"
    case writtenExpression = "Written Expression"

    // Cognitive Abilities - Idea Generation (2)
    case fluencyOfIdeas = "Fluency of Ideas"
    case originality = "Originality"

    // Cognitive Abilities - Reasoning (5)
    case problemSensitivity = "Problem Sensitivity"
    case deductiveReasoning = "Deductive Reasoning"
    case inductiveReasoning = "Inductive Reasoning"
    case informationOrdering = "Information Ordering"
    case categoryFlexibility = "Category Flexibility"

    // Cognitive Abilities - Quantitative (2)
    case mathematicalReasoning = "Mathematical Reasoning"
    case numberFacility = "Number Facility"

    // Cognitive Abilities - Memory (1)
    case memorization = "Memorization"

    // Cognitive Abilities - Perceptual (3)
    case speedOfClosure = "Speed of Closure"
    case flexibilityOfClosure = "Flexibility of Closure"
    case perceptualSpeed = "Perceptual Speed"

    // Cognitive Abilities - Spatial (2)
    case spatialOrientation = "Spatial Orientation"
    case visualization = "Visualization"

    // Cognitive Abilities - Attentiveness (2)
    case selectiveAttention = "Selective Attention"
    case timeSharing = "Time Sharing"

    // Psychomotor Abilities - Fine Manipulative (3)
    case armHandSteadiness = "Arm-Hand Steadiness"
    case manualDexterity = "Manual Dexterity"
    case fingerDexterity = "Finger Dexterity"

    // Psychomotor Abilities - Control Movement (4)
    case controlPrecision = "Control Precision"
    case multilimbCoordination = "Multilimb Coordination"
    case responseOrientation = "Response Orientation"
    case rateControl = "Rate Control"

    // Psychomotor Abilities - Reaction Time & Speed (3)
    case reactionTime = "Reaction Time"
    case wristFingerSpeed = "Wrist-Finger Speed"
    case speedOfLimbMovement = "Speed of Limb Movement"

    // Physical Abilities - Strength (4)
    case staticStrength = "Static Strength"
    case explosiveStrength = "Explosive Strength"
    case dynamicStrength = "Dynamic Strength"
    case trunkStrength = "Trunk Strength"

    // Physical Abilities - Endurance (1)
    case stamina = "Stamina"

    // Physical Abilities - Flexibility & Coordination (4)
    case extentFlexibility = "Extent Flexibility"
    case dynamicFlexibility = "Dynamic Flexibility"
    case grossBodyCoordination = "Gross Body Coordination"
    case grossBodyEquilibrium = "Gross Body Equilibrium"

    // Sensory Abilities - Visual (7)
    case nearVision = "Near Vision"
    case farVision = "Far Vision"
    case visualColorDiscrimination = "Visual Color Discrimination"
    case nightVision = "Night Vision"
    case peripheralVision = "Peripheral Vision"
    case depthPerception = "Depth Perception"
    case glareSensitivity = "Glare Sensitivity"

    // Sensory Abilities - Auditory (5)
    case hearingSensitivity = "Hearing Sensitivity"
    case auditoryAttention = "Auditory Attention"
    case soundLocalization = "Sound Localization"
    case speechRecognition = "Speech Recognition"
    case speechClarity = "Speech Clarity"

    var onetId: String {
        switch self {
        // Cognitive - Verbal
        case .oralComprehension: return "1.A.1.a.1"
        case .writtenComprehension: return "1.A.1.a.2"
        case .oralExpression: return "1.A.1.a.3"
        case .writtenExpression: return "1.A.1.a.4"
        // Cognitive - Idea Generation
        case .fluencyOfIdeas: return "1.A.1.b.1"
        case .originality: return "1.A.1.b.2"
        // Cognitive - Reasoning
        case .problemSensitivity: return "1.A.1.b.3"
        case .deductiveReasoning: return "1.A.1.b.4"
        case .inductiveReasoning: return "1.A.1.b.5"
        case .informationOrdering: return "1.A.1.b.6"
        case .categoryFlexibility: return "1.A.1.b.7"
        // Cognitive - Quantitative
        case .mathematicalReasoning: return "1.A.1.c.1"
        case .numberFacility: return "1.A.1.c.2"
        // Cognitive - Memory
        case .memorization: return "1.A.1.d.1"
        // Cognitive - Perceptual
        case .speedOfClosure: return "1.A.1.e.1"
        case .flexibilityOfClosure: return "1.A.1.e.2"
        case .perceptualSpeed: return "1.A.1.e.3"
        // Cognitive - Spatial
        case .spatialOrientation: return "1.A.1.f.1"
        case .visualization: return "1.A.1.f.2"
        // Cognitive - Attentiveness
        case .selectiveAttention: return "1.A.1.g.1"
        case .timeSharing: return "1.A.1.g.2"
        // Psychomotor - Fine Manipulative
        case .armHandSteadiness: return "1.A.2.a.1"
        case .manualDexterity: return "1.A.2.a.2"
        case .fingerDexterity: return "1.A.2.a.3"
        // Psychomotor - Control Movement
        case .controlPrecision: return "1.A.2.b.1"
        case .multilimbCoordination: return "1.A.2.b.2"
        case .responseOrientation: return "1.A.2.b.3"
        case .rateControl: return "1.A.2.b.4"
        // Psychomotor - Reaction Time & Speed
        case .reactionTime: return "1.A.2.c.1"
        case .wristFingerSpeed: return "1.A.2.c.2"
        case .speedOfLimbMovement: return "1.A.2.c.3"
        // Physical - Strength
        case .staticStrength: return "1.A.3.a.1"
        case .explosiveStrength: return "1.A.3.a.2"
        case .dynamicStrength: return "1.A.3.a.3"
        case .trunkStrength: return "1.A.3.a.4"
        // Physical - Endurance
        case .stamina: return "1.A.3.b.1"
        // Physical - Flexibility & Coordination
        case .extentFlexibility: return "1.A.3.c.1"
        case .dynamicFlexibility: return "1.A.3.c.2"
        case .grossBodyCoordination: return "1.A.3.c.3"
        case .grossBodyEquilibrium: return "1.A.3.c.4"
        // Sensory - Visual
        case .nearVision: return "1.A.4.a.1"
        case .farVision: return "1.A.4.a.2"
        case .visualColorDiscrimination: return "1.A.4.a.3"
        case .nightVision: return "1.A.4.a.4"
        case .peripheralVision: return "1.A.4.a.5"
        case .depthPerception: return "1.A.4.a.6"
        case .glareSensitivity: return "1.A.4.a.7"
        // Sensory - Auditory
        case .hearingSensitivity: return "1.A.4.b.1"
        case .auditoryAttention: return "1.A.4.b.2"
        case .soundLocalization: return "1.A.4.b.3"
        case .speechRecognition: return "1.A.4.b.4"
        case .speechClarity: return "1.A.4.b.5"
        }
    }

    var category: AbilityCategory {
        let prefix = onetId.prefix(5)
        if prefix.hasPrefix("1.A.1") { return .cognitive }
        if prefix.hasPrefix("1.A.2") { return .psychomotor }
        if prefix.hasPrefix("1.A.3") { return .physical }
        if prefix.hasPrefix("1.A.4") { return .sensory }
        return .cognitive
    }
}

// MARK: - Sector Mapping

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
        case .officeAdmin: return code == "43"
        case .healthcare: return code == "29" || code == "31"
        case .technology: return code == "15"
        case .finance: return code == "13"
        case .education: return code == "25"
        case .legal: return code == "23"
        case .marketing: return code == "11" && (title.contains("Marketing") || title.contains("Advertising") || title.contains("Public Relations"))
        case .humanResources: return code == "11" && (title.contains("Human Resources") || title.contains("Training") || title.contains("Compensation"))
        case .retail: return code == "41"
        case .foodService: return code == "35"
        case .skilledTrades: return code == "47" || code == "49"
        case .construction: return code == "47" && (title.contains("Construct") || title.contains("Builder") || title.contains("Superintendent"))
        case .warehouseLogistics: return code == "53"
        case .personalCare: return code == "39"
        case .science: return code == "19"
        case .arts: return code == "27"
        case .protectiveService: return code == "33"
        case .socialService: return code == "21"
        case .realEstate: return code == "41" && (title.contains("Real Estate") || title.contains("Broker") || title.contains("Agent"))
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

struct AbilityRating: Codable {
    let importance: Double
    let level: Double
    let confidence: ConfidenceInterval?
    let sampleSize: Int
    var isHighQuality: Bool { sampleSize >= 5 }  // Abilities use analyst ratings (n=8 typical), not large surveys
}

struct ConfidenceInterval: Codable {
    let lower: Double
    let upper: Double
    let standardError: Double
}

struct OccupationAbilities: Codable {
    let onetCode: String
    let title: String
    let sector: String
    let abilities: [String: AbilityRating]
    let topAbilities: [String]
    let abilityCount: Int
}

struct AbilitiesDatabase: Codable {
    let version: String
    let source: String
    let generatedDate: String
    let totalOccupations: Int
    let totalAbilities: Int
    let occupations: [OccupationAbilities]
    let abilityMetadata: [AbilityMetadata]
}

struct AbilityMetadata: Codable {
    let abilityId: String
    let abilityName: String
    let category: String
    let occurrenceCount: Int
    let averageImportance: Double
}

// MARK: - Parser Class

class ONetAbilitiesParser {
    private var occupations: [String: (code: String, title: String)] = [:]
    private var abilityRatings: [String: [String: (importance: Double?, level: Double?, n: Int?, se: Double?, lowerCI: Double?, upperCI: Double?)]] = [:]
    private let baseDir = "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8/Data/ONET_Skills"

    func run() throws {
        print("🚀 O*NET Abilities Parser for ManifestAndMatch V8")
        print("=" * 80)
        print("")

        print("📂 Phase 1: Loading occupation data...")
        try parseOccupations()
        print("   ✅ Loaded \(occupations.count) occupations")
        print("")

        print("📊 Phase 2: Parsing ability ratings...")
        try parseAbilities()
        print("   ✅ Parsed ability ratings for \(abilityRatings.count) occupations")
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

        print("✅ Abilities parsing complete!")
        print("=" * 80)
    }

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

    func parseAbilities() throws {
        let filePath = "\(baseDir)/Abilities.txt"
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
            if suppressStr == "Y" { continue }

            let dataValue = Double(fields[4]) ?? 0.0
            let n = Int(fields[5]) ?? 0
            let se = Double(fields[6]) ?? 0.0
            let lowerCI = Double(fields[7]) ?? 0.0
            let upperCI = Double(fields[8]) ?? 0.0

            if abilityRatings[onetCode] == nil { abilityRatings[onetCode] = [:] }
            if abilityRatings[onetCode]![elementId] == nil {
                abilityRatings[onetCode]![elementId] = (nil, nil, nil, nil, nil, nil)
            }

            var current = abilityRatings[onetCode]![elementId]!
            if scaleId == "IM" {
                current.importance = dataValue
                current.n = n
                current.se = se
                current.lowerCI = lowerCI
                current.upperCI = upperCI
            } else if scaleId == "LV" {
                current.level = dataValue
            }
            abilityRatings[onetCode]![elementId] = current
            processedCount += 1
        }
        print("   📊 Processed \(processedCount) ability ratings across \(abilityRatings.count) occupations")
    }

    func buildDatabase() -> AbilitiesDatabase {
        var occupationProfiles: [OccupationAbilities] = []
        var abilityOccurrences: [String: Int] = [:]
        var abilityImportanceSum: [String: Double] = [:]

        for (onetCode, ratings) in abilityRatings {
            guard let occupation = occupations[onetCode] else { continue }
            var abilities: [String: AbilityRating] = [:]

            for (abilityId, rating) in ratings {
                guard let importance = rating.importance,
                      let level = rating.level,
                      let n = rating.n,
                      n >= 5 else { continue }  // Abilities use analyst ratings (n=8 typical)

                let confidence = ConfidenceInterval(
                    lower: rating.lowerCI ?? 0.0,
                    upper: rating.upperCI ?? 0.0,
                    standardError: rating.se ?? 0.0
                )
                let abilityRating = AbilityRating(importance: importance, level: level, confidence: confidence, sampleSize: n)
                abilities[abilityId] = abilityRating
                abilityOccurrences[abilityId, default: 0] += 1
                abilityImportanceSum[abilityId, default: 0.0] += importance
            }

            let topAbilities = abilities.sorted { $0.value.importance > $1.value.importance }.prefix(5).map { $0.key }
            let sector = Sector.determineSector(onetCode: onetCode, title: occupation.title)
            let profile = OccupationAbilities(onetCode: onetCode, title: occupation.title, sector: sector, abilities: abilities, topAbilities: Array(topAbilities), abilityCount: abilities.count)
            occupationProfiles.append(profile)
        }

        let abilityMetadata = Ability.allCases.map { ability -> AbilityMetadata in
            let occurrences = abilityOccurrences[ability.onetId] ?? 0
            let avgImportance = occurrences > 0 ? (abilityImportanceSum[ability.onetId] ?? 0.0) / Double(occurrences) : 0.0
            return AbilityMetadata(abilityId: ability.onetId, abilityName: ability.rawValue, category: ability.category.rawValue, occurrenceCount: occurrences, averageImportance: avgImportance)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return AbilitiesDatabase(version: "1.0", source: "O*NET 30.0 Database - Abilities", generatedDate: dateFormatter.string(from: Date()), totalOccupations: occupationProfiles.count, totalAbilities: Ability.allCases.count, occupations: occupationProfiles.sorted { $0.onetCode < $1.onetCode }, abilityMetadata: abilityMetadata.sorted { $0.abilityId < $1.abilityId })
    }

    func exportDatabase(_ database: AbilitiesDatabase) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(database)
        let outputPath = "\(baseDir)/onet_abilities.json"
        try jsonData.write(to: URL(fileURLWithPath: outputPath))
        let fileSizeMB = Double(jsonData.count) / 1_048_576.0
        print("   ✅ Exported to: onet_abilities.json")
        print("   📦 File size: \(String(format: "%.2f", fileSizeMB)) MB")
    }

    func printStatistics(_ database: AbilitiesDatabase) {
        print("📊 Abilities Statistics:")
        print("=" * 80)
        print("")
        print("📈 Overall Metrics:")
        print("   • Total Occupations: \(database.totalOccupations)")
        print("   • Total Abilities: \(database.totalAbilities)")
        print("")

        let abilityCounts = database.occupations.map { $0.abilityCount }
        let avgAbilities = abilityCounts.reduce(0, +) / abilityCounts.count
        print("🎯 Abilities per Occupation:")
        print("   • Average: \(avgAbilities)")
        print("   • Range: \(abilityCounts.min() ?? 0) - \(abilityCounts.max() ?? 0)")
        print("")

        let topCommon = database.abilityMetadata.sorted { $0.occurrenceCount > $1.occurrenceCount }.prefix(10)
        print("🔝 Top 10 Most Common Abilities:")
        for (index, ability) in topCommon.enumerated() {
            let percentage = Double(ability.occurrenceCount) / Double(database.totalOccupations) * 100
            print("   \(index + 1). \(ability.abilityName)")
            print("      Occurs in \(ability.occurrenceCount) occupations (\(String(format: "%.1f", percentage))%)")
            print("      Avg Importance: \(String(format: "%.2f", ability.averageImportance))")
            print("      Category: \(ability.category)")
        }
        print("")

        var categoryCounts: [String: Int] = [:]
        for ability in database.abilityMetadata {
            categoryCounts[ability.category, default: 0] += 1
        }
        print("📚 Ability Category Distribution:")
        for (category, count) in categoryCounts.sorted(by: { $0.key < $1.key }) {
            print("   • \(category): \(count) abilities")
        }
    }
}

extension String {
    static func * (left: String, right: Int) -> String {
        String(repeating: left, count: right)
    }
}

let parser = ONetAbilitiesParser()
do {
    try parser.run()
} catch {
    print("❌ Error: \(error.localizedDescription)")
    exit(1)
}
