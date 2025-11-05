#!/usr/bin/env swift

import Foundation

/// O*NET Occupation Titles Parser for ManifestAndMatchV7
///
/// Parses Occupation_Data.txt → onet_occupation_titles.json
///
/// **Input Format** (Tab-delimited):
/// - Column 1: O*NET-SOC Code (e.g., "11-2022.00")
/// - Column 2: Title (e.g., "Sales Managers")
/// - Column 3: Description (long text, not used)
///
/// **Output Format** (JSON):
/// ```json
/// {
///   "occupations": [
///     {"onetCode": "11-2022.00", "title": "Sales Managers", "sector": "Office/Administrative"}
///   ],
///   "version": "1.0.0",
///   "lastUpdated": "2025-11-01",
///   "totalOccupations": 1016
/// }
/// ```
///
/// **Sector Mapping Strategy**:
/// Uses O*NET major group codes (first 2 digits) to infer sectors
///
/// **Usage**:
/// ```bash
/// chmod +x ONetTitlesParser.swift
/// ./ONetTitlesParser.swift
/// ```
///
/// Created: November 1, 2025
/// Phase: 1.1 - O*NET Integration

// MARK: - Data Models

struct OccupationTitle: Codable {
    let onetCode: String
    let title: String
    let sector: String
}

struct OccupationTitlesDatabase: Codable {
    let occupations: [OccupationTitle]
    let version: String
    let lastUpdated: String
    let totalOccupations: Int
}

// MARK: - Sector Mapper

/// Maps O*NET major group codes to ManifestAndMatch sectors
struct SectorMapper {

    /// Map O*NET code to sector using major group (first 2 digits)
    static func mapSector(onetCode: String) -> String {
        // Extract major group (e.g., "11-2022.00" → "11")
        let majorGroup = String(onetCode.prefix(2))

        switch majorGroup {
        case "11": return "Office/Administrative"  // Management
        case "13": return "Finance"                // Business and Financial Operations
        case "15": return "Technology"             // Computer and Mathematical
        case "17": return "Technology"             // Architecture and Engineering
        case "19": return "Technology"             // Life, Physical, and Social Science
        case "21": return "Education"              // Community and Social Service
        case "23": return "Legal"                  // Legal
        case "25": return "Education"              // Educational Instruction and Library
        case "27": return "Technology"             // Arts, Design, Entertainment, Sports, Media
        case "29": return "Healthcare"             // Healthcare Practitioners and Technical
        case "31": return "Healthcare"             // Healthcare Support
        case "33": return "Office/Administrative"  // Protective Service
        case "35": return "Food Service"           // Food Preparation and Serving Related
        case "37": return "Office/Administrative"  // Building and Grounds Cleaning and Maintenance
        case "39": return "Healthcare"             // Personal Care and Service
        case "41": return "Retail"                 // Sales and Related
        case "43": return "Office/Administrative"  // Office and Administrative Support
        case "45": return "Skilled Trades"         // Farming, Fishing, and Forestry
        case "47": return "Construction"           // Construction and Extraction
        case "49": return "Skilled Trades"         // Installation, Maintenance, and Repair
        case "51": return "Warehouse/Logistics"    // Production
        case "53": return "Warehouse/Logistics"    // Transportation and Material Moving
        default:   return "Office/Administrative"  // Fallback
        }
    }
}

// MARK: - Parser

struct ONetTitlesParser {

    let inputPath: String
    let outputPath: String

    /// Parse Occupation_Data.txt and generate JSON
    func parse() throws {
        print("📖 [ONetTitlesParser] Reading input file: \(inputPath)")

        // Read input file
        guard let content = try? String(contentsOfFile: inputPath, encoding: .utf8) else {
            throw ParserError.fileReadFailed(inputPath)
        }

        // Split into lines
        let lines = content.components(separatedBy: .newlines)
        print("📊 [ONetTitlesParser] Total lines: \(lines.count)")

        var occupations: [OccupationTitle] = []
        var skippedCount = 0

        // Parse each line (skip header)
        for (index, line) in lines.enumerated() {
            // Skip header and empty lines
            if index == 0 || line.isEmpty {
                continue
            }

            // Parse tab-delimited line
            let columns = line.components(separatedBy: "\t")

            // Validate format
            guard columns.count >= 2 else {
                skippedCount += 1
                continue
            }

            let onetCode = columns[0].trimmingCharacters(in: .whitespaces)
            let title = columns[1].trimmingCharacters(in: .whitespaces)

            // Skip if missing data
            guard !onetCode.isEmpty, !title.isEmpty else {
                skippedCount += 1
                continue
            }

            // Map sector
            let sector = SectorMapper.mapSector(onetCode: onetCode)

            // Create occupation
            let occupation = OccupationTitle(
                onetCode: onetCode,
                title: title,
                sector: sector
            )

            occupations.append(occupation)
        }

        print("✅ [ONetTitlesParser] Parsed \(occupations.count) occupations (skipped \(skippedCount))")

        // Verify Sales Managers present (critical test case)
        if let salesManagers = occupations.first(where: { $0.title.contains("Sales Managers") }) {
            print("✅ [ONetTitlesParser] Found critical occupation: \(salesManagers.title) (\(salesManagers.onetCode))")
        } else {
            print("⚠️  [ONetTitlesParser] WARNING: Sales Managers not found in parsed data")
        }

        // Create database
        let database = OccupationTitlesDatabase(
            occupations: occupations,
            version: "1.0.0",
            lastUpdated: ISO8601DateFormatter().string(from: Date()),
            totalOccupations: occupations.count
        )

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try encoder.encode(database)

        // Write output file
        try jsonData.write(to: URL(fileURLWithPath: outputPath))

        print("✅ [ONetTitlesParser] Written \(occupations.count) occupations to: \(outputPath)")
        print("📊 [ONetTitlesParser] Database metadata:")
        print("   - Version: \(database.version)")
        print("   - Last Updated: \(database.lastUpdated)")
        print("   - Total Occupations: \(database.totalOccupations)")

        // Print sector distribution
        printSectorDistribution(occupations)
    }

    /// Print sector distribution for validation
    private func printSectorDistribution(_ occupations: [OccupationTitle]) {
        var sectorCounts: [String: Int] = [:]

        for occupation in occupations {
            sectorCounts[occupation.sector, default: 0] += 1
        }

        print("\n📊 [ONetTitlesParser] Sector Distribution:")
        for (sector, count) in sectorCounts.sorted(by: { $0.value > $1.value }) {
            let percentage = Double(count) / Double(occupations.count) * 100
            print("   - \(sector): \(count) (\(String(format: "%.1f", percentage))%)")
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
    print("🚀 [ONetTitlesParser] Starting O*NET Occupation Titles Parser")
    print("=" + String(repeating: "=", count: 70))

    // Paths (relative to script location)
    let scriptDir = URL(fileURLWithPath: #file).deletingLastPathComponent().path
    let inputPath = "\(scriptDir)/Occupation_Data.txt"
    let outputPath = "\(scriptDir)/onet_occupation_titles.json"

    print("📂 [ONetTitlesParser] Input:  \(inputPath)")
    print("📂 [ONetTitlesParser] Output: \(outputPath)")
    print("")

    // Parse
    let parser = ONetTitlesParser(inputPath: inputPath, outputPath: outputPath)

    do {
        try parser.parse()
        print("\n✅ [ONetTitlesParser] SUCCESS - Ready for Phase 1.2")
        exit(0)
    } catch {
        print("\n❌ [ONetTitlesParser] ERROR: \(error)")
        exit(1)
    }
}

// Execute
main()
