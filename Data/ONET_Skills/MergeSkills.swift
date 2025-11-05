#!/usr/bin/env swift

import Foundation

// MARK: - O*NET Knowledge Areas (33 domains)
let onetKnowledge: [String: [String]] = [
    "Business/Management": [
        "Administration and Management",
        "Economics and Accounting",
        "Sales and Marketing",
        "Customer and Personal Service",
        "Personnel and Human Resources",
        "Clerical"
    ],
    "Manufacturing/Production": [
        "Production and Processing",
        "Food Production",
        "Design",
        "Building and Construction",
        "Mechanical"
    ],
    "Engineering/Technology": [
        "Computers and Electronics",
        "Engineering and Technology",
        "Mathematics",
        "Physics",
        "Chemistry"
    ],
    "Transportation": [
        "Transportation",
        "Geography"
    ],
    "Arts/Humanities": [
        "Fine Arts",
        "History and Archeology",
        "Philosophy and Theology",
        "English Language",
        "Foreign Language"
    ],
    "Education/Training": [
        "Education and Training"
    ],
    "Health/Science": [
        "Medicine and Dentistry",
        "Therapy and Counseling",
        "Biology",
        "Psychology",
        "Sociology and Anthropology"
    ],
    "Public Safety/Law": [
        "Public Safety and Security",
        "Law and Government"
    ],
    "Communications": [
        "Telecommunications",
        "Communications and Media"
    ]
]

// MARK: - Data Models (matching V8 structure)
struct Skill: Codable {
    let id: String
    let name: String
    let category: String
    let keywords: [String]
    let relatedSkills: [String]
}

struct SkillsDatabase: Codable {
    let skills: [Skill]
}

struct ONetOutput: Codable {
    let coreSkills: [Skill]
    let sectors: [String: [Skill]]
}

// MARK: - Merger
class SkillsMerger {
    var existingSkills: [Skill] = []
    var onetData: ONetOutput?
    var mergedSkills: [String: Set<String>] = [:] // Track unique skills per sector
    var skillsOutput: [Skill] = []

    func loadExistingSkills() throws {
        print("📖 Loading existing V8 skills.json...")
        let basePath = "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8/Packages/V7Core/Sources/V7Core/Resources"
        let url = URL(fileURLWithPath: "\(basePath)/skills.json")
        let data = try Data(contentsOf: url)
        let database = try JSONDecoder().decode(SkillsDatabase.self, from: data)
        existingSkills = database.skills
        print("✅ Loaded \(existingSkills.count) existing skills")
    }

    func loadONetData() throws {
        print("📖 Loading O*NET curated data...")
        let data = try Data(contentsOf: URL(fileURLWithPath: "onet_curated_skills.json"))

        struct TempOutput: Codable {
            let coreSkills: [TempSkill]
            let sectors: [String: [TempSkill]]
        }

        struct TempSkill: Codable {
            let id: String
            let name: String
            let category: String
            let keywords: [String]
            let relatedSkills: [String]
        }

        let temp = try JSONDecoder().decode(TempOutput.self, from: data)

        // Convert to V8 format (remove extra fields)
        let coreSkills = temp.coreSkills.map { skill in
            Skill(
                id: skill.id,
                name: skill.name,
                category: "Core Skills",
                keywords: skill.keywords,
                relatedSkills: skill.relatedSkills
            )
        }

        var sectors: [String: [Skill]] = [:]
        for (sector, skills) in temp.sectors {
            sectors[sector] = skills.map { skill in
                Skill(
                    id: skill.id,
                    name: skill.name,
                    category: sector,
                    keywords: skill.keywords,
                    relatedSkills: skill.relatedSkills
                )
            }
        }

        onetData = ONetOutput(coreSkills: coreSkills, sectors: sectors)
        print("✅ Loaded O*NET data: \(coreSkills.count) core + \(sectors.values.reduce(0) { $0 + $1.count }) sector skills")
    }

    func mergeAndDeduplicate() {
        print("\n🔧 Merging and deduplicating skills...")

        var idCounter = 1

        // 1. Add O*NET core skills first
        if let onet = onetData {
            for skill in onet.coreSkills {
                addSkill(skill, generateId: &idCounter)
            }
        }

        // 2. Add O*NET knowledge areas
        for (domain, knowledgeAreas) in onetKnowledge {
            for knowledge in knowledgeAreas {
                let skill = Skill(
                    id: "knowledge_\(String(format: "%03d", idCounter))",
                    name: knowledge,
                    category: "Knowledge Areas",
                    keywords: generateKeywords(for: knowledge),
                    relatedSkills: []
                )
                addSkill(skill, generateId: &idCounter)
                idCounter += 1
            }
        }

        // 3. Add O*NET sector skills
        if let onet = onetData {
            for (sector, skills) in onet.sectors {
                for skill in skills {
                    addSkill(skill, generateId: &idCounter)
                }
            }
        }

        // 4. Add existing V8 skills (deduplicated)
        for skill in existingSkills {
            addSkill(skill, generateId: &idCounter)
        }

        print("✅ Merged \(skillsOutput.count) total skills")
    }

    func addSkill(_ skill: Skill, generateId: inout Int) {
        let category = skill.category
        let skillName = skill.name.lowercased()

        // Check if skill already exists in this category
        var categorySkills = mergedSkills[category, default: Set<String>()]

        if !categorySkills.contains(skillName) {
            categorySkills.insert(skillName)
            mergedSkills[category] = categorySkills

            // Use existing ID or generate new one
            let finalSkill = Skill(
                id: skill.id,
                name: skill.name,
                category: category,
                keywords: skill.keywords,
                relatedSkills: skill.relatedSkills
            )

            skillsOutput.append(finalSkill)
        }
    }

    func generateKeywords(for name: String) -> [String] {
        let words = name
            .lowercased()
            .components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty && $0.count > 2 }
        return Array(Set(words))
    }

    func writeOutput() throws {
        print("\n📝 Writing merged skills.json...")

        let output = SkillsDatabase(skills: skillsOutput)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(output)

        // Write to new file for review
        try jsonData.write(to: URL(fileURLWithPath: "skills_merged.json"))

        print("✅ Written to skills_merged.json")
        printStatistics()
    }

    func printStatistics() {
        print("\n📊 FINAL STATISTICS:")
        print("   Total Skills: \(skillsOutput.count)")

        // Count by category
        var categoryCount: [String: Int] = [:]
        for skill in skillsOutput {
            categoryCount[skill.category, default: 0] += 1
        }

        print("\n📈 CATEGORY DISTRIBUTION:")
        for (category, count) in categoryCount.sorted(by: { $0.key < $1.key }) {
            let status = count >= 150 ? "✅" : (count >= 100 ? "⚠️" : "❌")
            print("   \(status) \(category.padding(toLength: 30, withPad: " ", startingAt: 0)): \(count) skills")
        }

        // Check if we met target
        if skillsOutput.count >= 2800 {
            print("\n🎯 ✅ TARGET MET: \(skillsOutput.count) >= 2,800 skills")
        } else {
            print("\n⚠️  BELOW TARGET: \(skillsOutput.count) < 2,800 skills (need \(2800 - skillsOutput.count) more)")
        }
    }
}

// MARK: - Main
print("=" + String(repeating: "=", count: 79))
print("Skills Merger for ManifestAndMatch V8")
print("=" + String(repeating: "=", count: 79))
print()

let merger = SkillsMerger()

do {
    try merger.loadExistingSkills()
    try merger.loadONetData()
    merger.mergeAndDeduplicate()
    try merger.writeOutput()

    print("\n" + String(repeating: "=", count: 80))
    print("✅ MERGE COMPLETE")
    print(String(repeating: "=", count: 80))
} catch {
    print("\n❌ ERROR: \(error)")
    exit(1)
}
