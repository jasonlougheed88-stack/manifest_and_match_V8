#!/usr/bin/env swift

import Foundation

/// O*NET Skills Parser for ManifestAndMatchV7
///
/// Parses Skills.txt → onet_occupation_skills.json
///
/// **Input Format** (Tab-delimited):
/// - Column 0: O*NET-SOC Code (e.g., "11-2022.00")
/// - Column 2: Element Name (skill name, e.g., "Persuasion")
/// - Column 3: Scale ID ("IM" = Importance, "LV" = Level)
/// - Column 4: Data Value (0.0-7.0 scale)
/// - Column 5: N (sample size)
///
/// **Output Format** (JSON):
/// ```json
/// {
///   "occupations": [
///     {
///       "onetCode": "11-2022.00",
///       "title": "Sales Managers",
///       "skills": [
///         {"name": "Persuasion", "importance": 4.5, "level": 5.2},
///         {"name": "Negotiation", "importance": 4.3, "level": 5.0}
///       ]
///     }
///   ],
///   "version": "1.0.0",
///   "lastUpdated": "2025-11-01",
///   "totalOccupations": 894
/// }
/// ```
///
/// **Filtering Strategy**:
/// - Include skills where importance >= 3.5 (high importance)
/// - Sort by importance (descending)
/// - Take top 15-20 skills per occupation
///
/// **Usage**:
/// ```bash
/// chmod +x ONetSkillsParser.swift
/// ./ONetSkillsParser.swift
/// ```
///
/// Created: November 1, 2025
/// Phase: 3.1 - O*NET Integration

// MARK: - Data Models

struct SkillScore: Codable {
    let name: String
    let importance: Double
    let level: Double
}

struct OccupationSkills: Codable {
    let onetCode: String
    let title: String
    let skills: [SkillScore]
}

struct OccupationSkillsDatabase: Codable {
    let occupations: [OccupationSkills]
    let version: String
    let lastUpdated: String
    let totalOccupations: Int
    let totalSkillTypes: Int
}

// MARK: - Parser

struct ONetSkillsParser {

    let inputPath: String
    let titlesPath: String
    let outputPath: String

    /// Parse Skills.txt and generate JSON
    func parse() throws {
        print("📖 [ONetSkillsParser] Reading skills file: \(inputPath)")

        // Load occupation titles for lookup
        let titleMap = try loadOccupationTitles()
        print("📊 [ONetSkillsParser] Loaded \(titleMap.count) occupation titles")

        // Read skills file
        guard let content = try? String(contentsOfFile: inputPath, encoding: .utf8) else {
            throw ParserError.fileReadFailed(inputPath)
        }

        let lines = content.components(separatedBy: .newlines)
        print("📊 [ONetSkillsParser] Total lines: \(lines.count)")

        // Parse skills by occupation
        var skillsByOccupation: [String: [String: (importance: Double, level: Double, sampleSize: Int)]] = [:]
        var skippedCount = 0

        for (index, line) in lines.enumerated() {
            // Skip header and empty lines
            if index == 0 || line.isEmpty {
                continue
            }

            let columns = line.components(separatedBy: "\t")

            // Validate format (need at least 6 columns)
            guard columns.count >= 6 else {
                skippedCount += 1
                continue
            }

            let onetCode = columns[0].trimmingCharacters(in: .whitespaces)
            let skillName = columns[2].trimmingCharacters(in: .whitespaces)
            let scaleID = columns[3].trimmingCharacters(in: .whitespaces)

            guard let dataValue = Double(columns[4].trimmingCharacters(in: .whitespaces)),
                  let sampleSize = Int(columns[5].trimmingCharacters(in: .whitespaces)) else {
                skippedCount += 1
                continue
            }

            // Skip if missing data
            guard !onetCode.isEmpty, !skillName.isEmpty else {
                skippedCount += 1
                continue
            }

            // Initialize occupation entry if needed
            if skillsByOccupation[onetCode] == nil {
                skillsByOccupation[onetCode] = [:]
            }

            // Initialize skill entry if needed
            if skillsByOccupation[onetCode]![skillName] == nil {
                skillsByOccupation[onetCode]![skillName] = (importance: 0.0, level: 0.0, sampleSize: sampleSize)
            }

            // Update importance or level
            if scaleID == "IM" {
                skillsByOccupation[onetCode]![skillName]?.importance = dataValue
            } else if scaleID == "LV" {
                skillsByOccupation[onetCode]![skillName]?.level = dataValue
            }
        }

        print("✅ [ONetSkillsParser] Parsed \(skillsByOccupation.count) occupations (skipped \(skippedCount) lines)")

        // Build final occupation skills list
        var occupations: [OccupationSkills] = []
        var allSkillNames = Set<String>()

        for (onetCode, skills) in skillsByOccupation {
            // Filter skills: importance >= 3.5
            let filteredSkills = skills
                .filter { $0.value.importance >= 3.5 }
                .map { (name, values) in
                    SkillScore(name: name, importance: values.importance, level: values.level)
                }
                .sorted { $0.importance > $1.importance }

            // Skip occupations with no significant skills
            guard !filteredSkills.isEmpty else {
                continue
            }

            // Take top 20 skills
            let topSkills = Array(filteredSkills.prefix(20))

            // Track all skill names
            topSkills.forEach { allSkillNames.insert($0.name) }

            // Get title from title map
            let title = titleMap[onetCode] ?? "Unknown Occupation"

            let occupation = OccupationSkills(
                onetCode: onetCode,
                title: title,
                skills: topSkills
            )

            occupations.append(occupation)
        }

        // Sort by O*NET code
        occupations.sort { $0.onetCode < $1.onetCode }

        print("✅ [ONetSkillsParser] Filtered to \(occupations.count) occupations with skills")
        print("📊 [ONetSkillsParser] Total unique skill types: \(allSkillNames.count)")

        // Verify Sales Managers present (critical test case)
        if let salesManagers = occupations.first(where: { $0.title.contains("Sales Managers") }) {
            print("✅ [ONetSkillsParser] Found critical occupation: \(salesManagers.title) (\(salesManagers.onetCode))")
            print("   Top skills: \(salesManagers.skills.prefix(5).map { $0.name }.joined(separator: ", "))")
        } else {
            print("⚠️  [ONetSkillsParser] WARNING: Sales Managers not found in parsed data")
        }

        // Create database
        let database = OccupationSkillsDatabase(
            occupations: occupations,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            totalOccupations: occupations.count,
            totalSkillTypes: allSkillNames.count
        )

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try encoder.encode(database)

        // Write output file
        try jsonData.write(to: URL(fileURLWithPath: outputPath))

        print("✅ [ONetSkillsParser] Written \(occupations.count) occupations to: \(outputPath)")
        print("📊 [ONetSkillsParser] Database metadata:")
        print("   - Version: \(database.version)")
        print("   - Last Updated: \(database.lastUpdated)")
        print("   - Total Occupations: \(database.totalOccupations)")
        print("   - Total Skill Types: \(database.totalSkillTypes)")

        // Print skill distribution
        printSkillDistribution(occupations)
    }

    /// Load occupation titles from onet_occupation_titles.json
    private func loadOccupationTitles() throws -> [String: String] {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: titlesPath)) else {
            throw ParserError.fileReadFailed(titlesPath)
        }

        struct TitlesDatabase: Codable {
            let occupations: [SimpleTitle]
        }

        struct SimpleTitle: Codable {
            let onetCode: String
            let title: String
        }

        let database = try JSONDecoder().decode(TitlesDatabase.self, from: data)

        var titleMap: [String: String] = [:]
        for occupation in database.occupations {
            titleMap[occupation.onetCode] = occupation.title
        }

        return titleMap
    }

    /// Print skill distribution for validation
    private func printSkillDistribution(_ occupations: [OccupationSkills]) {
        var skillCounts: [String: Int] = [:]

        for occupation in occupations {
            for skill in occupation.skills {
                skillCounts[skill.name, default: 0] += 1
            }
        }

        print("\n📊 [ONetSkillsParser] Top 20 Most Common Skills:")
        let topSkills = skillCounts.sorted { $0.value > $1.value }.prefix(20)
        for (index, (skill, count)) in topSkills.enumerated() {
            let percentage = Double(count) / Double(occupations.count) * 100
            print("   \(index + 1). \(skill): \(count) occupations (\(String(format: "%.1f", percentage))%)")
        }
        print("")
    }
}

// MARK: - Error Types

enum ParserError: Error, CustomStringConvertible {
    case fileReadFailed(String)
    case invalidFormat(String)

    var description: String {
        switch self {
        case .fileReadFailed(let path):
            return "Failed to read file: \(path)"
        case .invalidFormat(let message):
            return "Invalid format: \(message)"
        }
    }
}

// MARK: - Main Execution

func main() {
    print("🚀 [ONetSkillsParser] Starting O*NET Skills Parser")
    print("=" + String(repeating: "=", count: 70))

    // Paths (relative to script location)
    let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent().path
    let inputPath = "\(scriptDir)/Skills.txt"
    let titlesPath = "\(scriptDir)/onet_occupation_titles.json"
    let outputPath = "\(scriptDir)/onet_occupation_skills.json"

    print("📂 [ONetSkillsParser] Skills Input: \(inputPath)")
    print("📂 [ONetSkillsParser] Titles Input:  \(titlesPath)")
    print("📂 [ONetSkillsParser] Output:        \(outputPath)")
    print("")

    // Parse
    let parser = ONetSkillsParser(inputPath: inputPath, titlesPath: titlesPath, outputPath: outputPath)

    do {
        try parser.parse()
        print("\n✅ [ONetSkillsParser] SUCCESS - Ready for Phase 3.2")
        exit(0)
    } catch {
        print("\n❌ [ONetSkillsParser] ERROR: \(error)")
        exit(1)
    }
}

// Execute
main()
