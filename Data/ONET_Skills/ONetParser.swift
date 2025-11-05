#!/usr/bin/env swift

import Foundation

// MARK: - O*NET Core Skills (35 standard skills from O*NET)
let onetCoreSkills: [String: String] = [
    "2.A.1.a": "Reading Comprehension",
    "2.A.1.b": "Active Listening",
    "2.A.1.c": "Writing",
    "2.A.1.d": "Speaking",
    "2.A.1.e": "Mathematics",
    "2.A.1.f": "Science",
    "2.A.2.a": "Critical Thinking",
    "2.A.2.b": "Active Learning",
    "2.A.2.c": "Learning Strategies",
    "2.A.2.d": "Monitoring",
    "2.B.1.a": "Social Perceptiveness",
    "2.B.1.b": "Coordination",
    "2.B.1.c": "Persuasion",
    "2.B.1.d": "Negotiation",
    "2.B.1.e": "Instructing",
    "2.B.1.f": "Service Orientation",
    "2.B.2.i": "Complex Problem Solving",
    "2.B.3.a": "Operations Analysis",
    "2.B.3.b": "Technology Design",
    "2.B.3.c": "Equipment Selection",
    "2.B.3.d": "Installation",
    "2.B.3.e": "Programming",
    "2.B.3.f": "Quality Control Analysis",
    "2.B.3.g": "Operations Monitoring",
    "2.B.3.h": "Operation and Control",
    "2.B.3.i": "Product Inspection",
    "2.B.3.j": "Equipment Maintenance",
    "2.B.3.k": "Troubleshooting",
    "2.B.3.l": "Repairing",
    "2.B.4.a": "Judgment and Decision Making",
    "2.B.4.b": "Systems Analysis",
    "2.B.4.c": "Systems Evaluation",
    "2.B.5.a": "Time Management",
    "2.B.5.b": "Management of Financial Resources",
    "2.B.5.c": "Management of Material Resources",
    "2.B.5.d": "Management of Personnel Resources"
]

// MARK: - Sector Mapping (Expanded from 14 to 19)
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
    // NEW SECTORS (5 additions)
    case artsDesignMedia = "Arts/Design/Media"
    case protectiveService = "Protective Service"
    case scienceResearch = "Science/Research"
    case socialCommunityService = "Social/Community Service"
    case personalCareService = "Personal Care/Service"

    func matches(onetCode: String) -> Bool {
        let prefixes = self.onetPrefixes
        return prefixes.contains { onetCode.hasPrefix($0) }
    }

    var onetPrefixes: [String] {
        switch self {
        case .officeAdmin: return ["11-", "13-1", "43-"]
        case .healthcare: return ["29-", "31-"]
        case .technology: return ["15-"]
        case .retail: return ["41-"]
        case .skilledTrades: return ["47-", "49-"]
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
}

// MARK: - Skill Transferability Classification
enum Transferability: String, Codable {
    case universal      // Applies to ALL sectors (e.g., Critical Thinking)
    case crossDomain    // Applies to 3+ sectors (e.g., Customer Service)
    case sectorSpecific // Applies to 1-2 sectors (e.g., Medical Terminology)
    case toolSpecific   // Technology/tool skills (e.g., Python, AutoCAD)
}

// MARK: - Data Models
struct Occupation: Codable {
    let code: String
    let title: String
    let description: String
    let sector: String
}

struct Skill: Codable {
    let id: String
    let name: String
    let category: String
    let keywords: [String]
    let relatedSkills: [String]
    let transferability: String
    let onetElementId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, category, keywords, relatedSkills, transferability
        case onetElementId = "onet_element_id"
    }
}

struct SkillsOutput: Codable {
    let version: String
    let source: String
    let dateExtracted: String
    let totalSkills: Int
    let sectors: [String: [Skill]]
    let coreSkills: [Skill]
    let attribution: String

    enum CodingKeys: String, CodingKey {
        case version, source, totalSkills, sectors, coreSkills, attribution
        case dateExtracted = "date_extracted"
    }
}

// MARK: - Parser
class ONetParser {
    var occupations: [String: Occupation] = [:]
    var skillsBySector: [String: Set<String>] = [:]
    var technologyBySector: [String: Set<String>] = [:]

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

            let sector = Sector.allCases.first { $0.matches(onetCode: code) }?.rawValue ?? "Office/Administrative"

            occupations[code] = Occupation(
                code: code,
                title: title,
                description: description,
                sector: sector
            )
        }

        print("✅ Loaded \(occupations.count) occupations")
    }

    func parseSkills() throws {
        print("📖 Parsing Skills.txt...")
        let content = try String(contentsOfFile: "Skills.txt", encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 3 else { continue }

            let onetCode = fields[0]
            let elementId = fields[1]
            let skillName = fields[2]

            // Only process core O*NET skills (not every variant)
            guard onetCoreSkills[elementId] != nil else { continue }

            if let occupation = occupations[onetCode] {
                var skills = skillsBySector[occupation.sector, default: Set<String>()]
                skills.insert(skillName)
                skillsBySector[occupation.sector] = skills
            }
        }

        print("✅ Parsed core O*NET skills")
    }

    func parseTechnologySkills() throws {
        print("📖 Parsing Technology_Skills.txt...")
        let content = try String(contentsOfFile: "Technology_Skills.txt", encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        var techCategories: Set<String> = []

        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 4 else { continue }

            let onetCode = fields[0]
            let example = fields[3].trimmingCharacters(in: .whitespaces)

            guard !example.isEmpty else { continue }

            // Extract category (e.g., "Python" -> "Programming Languages")
            let category = extractTechnologyCategory(example)
            techCategories.insert(category)

            if let occupation = occupations[onetCode] {
                var tech = technologyBySector[occupation.sector, default: Set<String>()]
                tech.insert(category)
                technologyBySector[occupation.sector] = tech
            }
        }

        print("✅ Extracted \(techCategories.count) technology categories")
    }

    func extractTechnologyCategory(_ example: String) -> String {
        let lower = example.lowercased()

        // Programming languages
        if lower.contains("python") || lower.contains("java") || lower.contains("javascript") ||
           lower.contains("c++") || lower.contains("ruby") || lower.contains("swift") {
            return "Programming Languages"
        }

        // Database systems
        if lower.contains("sql") || lower.contains("oracle") || lower.contains("mongodb") ||
           lower.contains("database") {
            return "Database Management"
        }

        // Microsoft Office
        if lower.contains("excel") || lower.contains("word") || lower.contains("powerpoint") ||
           lower.contains("microsoft office") {
            return "Microsoft Office Suite"
        }

        // Design software
        if lower.contains("photoshop") || lower.contains("illustrator") || lower.contains("autocad") ||
           lower.contains("solidworks") {
            return "Design Software"
        }

        // CRM/ERP
        if lower.contains("salesforce") || lower.contains("sap") || lower.contains("crm") {
            return "CRM/ERP Systems"
        }

        // Default: use the example as category name
        return example
    }

    func generateSkillsJSON() throws {
        print("\n🔧 Generating curated skills.json...")

        // 1. Create core O*NET skills (35 universal skills)
        var coreSkills: [Skill] = []
        var skillId = 1

        for (elementId, skillName) in onetCoreSkills.sorted(by: { $0.value < $1.value }) {
            let skill = Skill(
                id: "onet_core_\(String(format: "%03d", skillId))",
                name: skillName,
                category: "Core Skills",
                keywords: generateKeywords(for: skillName),
                relatedSkills: [],
                transferability: Transferability.universal.rawValue,
                onetElementId: elementId
            )
            coreSkills.append(skill)
            skillId += 1
        }

        // 2. Create sector-specific skills
        var sectorSkills: [String: [Skill]] = [:]

        for sector in Sector.allCases {
            var skills: [Skill] = []

            // Add sector skills from O*NET
            if let sectorSkillSet = skillsBySector[sector.rawValue] {
                for skillName in sectorSkillSet.sorted() {
                    let skill = Skill(
                        id: "\(sector.rawValue.lowercased().replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: " ", with: "_"))_\(String(format: "%03d", skills.count + 1))",
                        name: skillName,
                        category: sector.rawValue,
                        keywords: generateKeywords(for: skillName),
                        relatedSkills: [],
                        transferability: Transferability.sectorSpecific.rawValue,
                        onetElementId: nil
                    )
                    skills.append(skill)
                }
            }

            // Add technology skills for sector
            if let techSet = technologyBySector[sector.rawValue] {
                for techName in techSet.sorted() {
                    let skill = Skill(
                        id: "\(sector.rawValue.lowercased().replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: " ", with: "_"))_tech_\(String(format: "%03d", skills.count + 1))",
                        name: techName,
                        category: sector.rawValue,
                        keywords: generateKeywords(for: techName),
                        relatedSkills: [],
                        transferability: Transferability.toolSpecific.rawValue,
                        onetElementId: nil
                    )
                    skills.append(skill)
                }
            }

            sectorSkills[sector.rawValue] = skills
        }

        // 3. Calculate totals
        let totalSkills = coreSkills.count + sectorSkills.values.reduce(0) { $0 + $1.count }

        // 4. Create output structure
        let output = SkillsOutput(
            version: "2.0",
            source: "O*NET 30.0 Database + ManifestAndMatch Curation",
            dateExtracted: ISO8601DateFormatter().string(from: Date()),
            totalSkills: totalSkills,
            sectors: sectorSkills,
            coreSkills: coreSkills,
            attribution: """
            Career and occupation data sourced from the O*NET® 30.0 Database by the U.S. Department \
            of Labor, Employment and Training Administration (USDOL/ETA), used under the CC BY 4.0 \
            license. Modified and curated for ManifestAndMatch V8.
            """
        )

        // 5. Write JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(output)
        try jsonData.write(to: URL(fileURLWithPath: "onet_curated_skills.json"))

        print("✅ Generated onet_curated_skills.json")
        print("\n📊 STATISTICS:")
        print("   Core Skills (Universal): \(coreSkills.count)")
        print("   Sector-Specific Skills: \(sectorSkills.values.reduce(0) { $0 + $1.count })")
        print("   Total Skills: \(totalSkills)")
        print("\n📈 SECTOR DISTRIBUTION:")

        for sector in Sector.allCases.sorted(by: { $0.rawValue < $1.rawValue }) {
            let count = sectorSkills[sector.rawValue]?.count ?? 0
            let status = count >= 150 ? "✅" : "⚠️"
            print("   \(status) \(sector.rawValue.padding(toLength: 30, withPad: " ", startingAt: 0)): \(count) skills")
        }

        print("\n✅ SUCCESS: Skills database curated from O*NET 30.0")
    }

    func generateKeywords(for skillName: String) -> [String] {
        let words = skillName
            .lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty && $0.count > 2 }
        return Array(Set(words))
    }
}

// MARK: - Main Execution
print("=" + String(repeating: "=", count: 79))
print("O*NET Skills Parser for ManifestAndMatch V8")
print("=" + String(repeating: "=", count: 79))
print()

let parser = ONetParser()

do {
    try parser.parseOccupations()
    try parser.parseSkills()
    try parser.parseTechnologySkills()
    try parser.generateSkillsJSON()

    print("\n" + String(repeating: "=", count: 80))
    print("✅ PARSING COMPLETE")
    print(String(repeating: "=", count: 80))
} catch {
    print("\n❌ ERROR: \(error)")
    exit(1)
}
