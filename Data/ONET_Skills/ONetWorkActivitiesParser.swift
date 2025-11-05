#!/usr/bin/env swift

import Foundation

// MARK: - O*NET Work Activities Parser for ManifestAndMatch V8
// Purpose: Parse 41 work activities from O*NET 30.0 for Amber→Teal career discovery
// Output: onet_work_activities.json for cross-domain transferable skills matching
// iOS 26 Compatible: Swift 6 strict concurrency patterns
// Created: October 28, 2025
//
// Strategic Importance: THE GAME CHANGER ⭐⭐⭐
// Work activities describe HOW people work, not WHAT they know
// Highly transferable across sectors (e.g., "Analyzing Data" works in tech, finance, healthcare, marketing)
// Critical for Amber→Teal cross-domain discovery

// MARK: - Work Activity Categories (4 major groups)

enum WorkActivityCategory: String, Codable, CaseIterable {
    case informationInput = "Information Input"
    case mentalProcesses = "Mental Processes"
    case workOutput = "Work Output"
    case interactingWithOthers = "Interacting with Others"

    var description: String {
        switch self {
        case .informationInput:
            return "Activities that involve looking for and receiving job-related information"
        case .mentalProcesses:
            return "Activities that involve processing information and making work-related decisions"
        case .workOutput:
            return "Activities that involve performing physical and technical tasks"
        case .interactingWithOthers:
            return "Activities that involve communicating, managing, and working with people"
        }
    }
}

// MARK: - Individual Work Activities (41 activities)

enum WorkActivity: String, Codable, CaseIterable {
    // Information Input (5 activities)
    case gettingInformation = "Getting Information"
    case monitoringProcesses = "Monitoring Processes, Materials, or Surroundings"
    case identifyingObjects = "Identifying Objects, Actions, and Events"
    case inspectingEquipment = "Inspecting Equipment, Structures, or Materials"
    case estimatingCharacteristics = "Estimating the Quantifiable Characteristics of Products, Events, or Information"

    // Mental Processes (9 activities)
    case judgingQualities = "Judging the Qualities of Objects, Services, or People"
    case processingInformation = "Processing Information"
    case evaluatingCompliance = "Evaluating Information to Determine Compliance with Standards"
    case analyzingData = "Analyzing Data or Information"
    case makingDecisions = "Making Decisions and Solving Problems"
    case thinkingCreatively = "Thinking Creatively"
    case updatingKnowledge = "Updating and Using Relevant Knowledge"
    case developingObjectives = "Developing Objectives and Strategies"
    case schedulingWork = "Scheduling Work and Activities"
    case organizingWork = "Organizing, Planning, and Prioritizing Work"

    // Work Output (11 activities)
    case performingPhysical = "Performing General Physical Activities"
    case handlingObjects = "Handling and Moving Objects"
    case controllingMachines = "Controlling Machines and Processes"
    case operatingVehicles = "Operating Vehicles, Mechanized Devices, or Equipment"
    case workingWithComputers = "Working with Computers"
    case draftingTechnical = "Drafting, Laying Out, and Specifying Technical Devices, Parts, and Equipment"
    case repairingMechanical = "Repairing and Maintaining Mechanical Equipment"
    case repairingElectronic = "Repairing and Maintaining Electronic Equipment"
    case documentingInformation = "Documenting/Recording Information"

    // Interacting with Others (16 activities)
    case interpretingMeaning = "Interpreting the Meaning of Information for Others"
    case communicatingInternal = "Communicating with Supervisors, Peers, or Subordinates"
    case communicatingExternal = "Communicating with People Outside the Organization"
    case establishingRelationships = "Establishing and Maintaining Interpersonal Relationships"
    case assistingCaring = "Assisting and Caring for Others"
    case sellingInfluencing = "Selling or Influencing Others"
    case resolvingConflicts = "Resolving Conflicts and Negotiating with Others"
    case performingPublic = "Performing for or Working Directly with the Public"
    case coordinatingWork = "Coordinating the Work and Activities of Others"
    case buildingTeams = "Developing and Building Teams"
    case trainingTeaching = "Training and Teaching Others"
    case guidingSubordinates = "Guiding, Directing, and Motivating Subordinates"
    case coachingDeveloping = "Coaching and Developing Others"
    case providingConsultation = "Providing Consultation and Advice to Others"
    case performingAdministrative = "Performing Administrative Activities"
    case staffingUnits = "Staffing Organizational Units"
    case monitoringResources = "Monitoring and Controlling Resources"

    var onetId: String {
        switch self {
        // Information Input
        case .gettingInformation: return "4.A.1.a.1"
        case .monitoringProcesses: return "4.A.1.a.2"
        case .identifyingObjects: return "4.A.1.b.1"
        case .inspectingEquipment: return "4.A.1.b.2"
        case .estimatingCharacteristics: return "4.A.1.b.3"

        // Mental Processes
        case .judgingQualities: return "4.A.2.a.1"
        case .processingInformation: return "4.A.2.a.2"
        case .evaluatingCompliance: return "4.A.2.a.3"
        case .analyzingData: return "4.A.2.a.4"
        case .makingDecisions: return "4.A.2.b.1"
        case .thinkingCreatively: return "4.A.2.b.2"
        case .updatingKnowledge: return "4.A.2.b.3"
        case .developingObjectives: return "4.A.2.b.4"
        case .schedulingWork: return "4.A.2.b.5"
        case .organizingWork: return "4.A.2.b.6"

        // Work Output
        case .performingPhysical: return "4.A.3.a.1"
        case .handlingObjects: return "4.A.3.a.2"
        case .controllingMachines: return "4.A.3.a.3"
        case .operatingVehicles: return "4.A.3.a.4"
        case .workingWithComputers: return "4.A.3.b.1"
        case .draftingTechnical: return "4.A.3.b.2"
        case .repairingMechanical: return "4.A.3.b.4"
        case .repairingElectronic: return "4.A.3.b.5"
        case .documentingInformation: return "4.A.3.b.6"

        // Interacting with Others
        case .interpretingMeaning: return "4.A.4.a.1"
        case .communicatingInternal: return "4.A.4.a.2"
        case .communicatingExternal: return "4.A.4.a.3"
        case .establishingRelationships: return "4.A.4.a.4"
        case .assistingCaring: return "4.A.4.a.5"
        case .sellingInfluencing: return "4.A.4.a.6"
        case .resolvingConflicts: return "4.A.4.a.7"
        case .performingPublic: return "4.A.4.a.8"
        case .coordinatingWork: return "4.A.4.b.1"
        case .buildingTeams: return "4.A.4.b.2"
        case .trainingTeaching: return "4.A.4.b.3"
        case .guidingSubordinates: return "4.A.4.b.4"
        case .coachingDeveloping: return "4.A.4.b.5"
        case .providingConsultation: return "4.A.4.b.6"
        case .performingAdministrative: return "4.A.4.c.1"
        case .staffingUnits: return "4.A.4.c.2"
        case .monitoringResources: return "4.A.4.c.3"
        }
    }

    var category: WorkActivityCategory {
        let prefix = String(onetId.prefix(5))  // e.g., "4.A.1" or "4.A.2"

        if prefix.hasPrefix("4.A.1") {
            return .informationInput
        } else if prefix.hasPrefix("4.A.2") {
            return .mentalProcesses
        } else if prefix.hasPrefix("4.A.3") {
            return .workOutput
        } else if prefix.hasPrefix("4.A.4") {
            return .interactingWithOthers
        }

        return .informationInput  // Fallback
    }

    var transferabilityScore: Double {
        // Highly transferable activities (0.9-1.0): Work across almost all sectors
        if [.analyzingData, .processingInformation, .makingDecisions,
            .communicatingInternal, .communicatingExternal, .organizingWork,
            .documentingInformation, .gettingInformation].contains(self) {
            return 0.95
        }

        // Moderately transferable (0.7-0.89): Work across many sectors
        if [.judgingQualities, .thinkingCreatively, .updatingKnowledge,
            .establishingRelationships, .interpretingMeaning, .workingWithComputers,
            .developingObjectives, .schedulingWork].contains(self) {
            return 0.80
        }

        // Sector-specific activities (0.4-0.69): More specialized
        if [.repairingMechanical, .repairingElectronic, .operatingVehicles,
            .controllingMachines, .performingPhysical, .handlingObjects,
            .draftingTechnical, .inspectingEquipment].contains(self) {
            return 0.55
        }

        // Management/leadership activities (0.7-0.85): Transferable but require experience
        if [.coordinatingWork, .buildingTeams, .trainingTeaching,
            .guidingSubordinates, .coachingDeveloping, .providingConsultation,
            .performingAdministrative, .staffingUnits, .monitoringResources].contains(self) {
            return 0.75
        }

        // Customer-facing activities (0.6-0.8): Transferable within service sectors
        if [.assistingCaring, .sellingInfluencing, .performingPublic,
            .resolvingConflicts].contains(self) {
            return 0.70
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
            return code == "43"  // Office and Administrative Support
        case .healthcare:
            return code == "29" || code == "31"  // Healthcare Practitioners, Healthcare Support
        case .technology:
            return code == "15"  // Computer and Mathematical
        case .finance:
            return code == "13"  // Business and Financial Operations
        case .education:
            return code == "25"  // Educational Instruction and Library
        case .legal:
            return code == "23"  // Legal
        case .marketing:
            return code == "11" && (title.contains("Marketing") || title.contains("Advertising") || title.contains("Public Relations"))
        case .humanResources:
            return code == "11" && (title.contains("Human Resources") || title.contains("Training") || title.contains("Compensation"))
        case .retail:
            return code == "41"  // Sales and Related
        case .foodService:
            return code == "35"  // Food Preparation and Serving
        case .skilledTrades:
            return code == "47" || code == "49"  // Construction Trades, Installation/Maintenance/Repair
        case .construction:
            return code == "47" && (title.contains("Construct") || title.contains("Builder") || title.contains("Superintendent"))
        case .warehouseLogistics:
            return code == "53"  // Transportation and Material Moving
        case .personalCare:
            return code == "39"  // Personal Care and Service
        case .science:
            return code == "19"  // Life, Physical, and Social Science
        case .arts:
            return code == "27"  // Arts, Design, Entertainment, Sports, and Media
        case .protectiveService:
            return code == "33"  // Protective Service
        case .socialService:
            return code == "21"  // Community and Social Service
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
        return "Office/Administrative"  // Safe default
    }
}

// MARK: - Data Models

struct ActivityRating: Codable {
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

struct OccupationWorkActivities: Codable {
    let onetCode: String
    let title: String
    let sector: String
    let activities: [String: ActivityRating]  // Activity ID -> Rating
    let topActivities: [String]  // Top 5 activities by importance
    let activityCount: Int
}

struct WorkActivitiesDatabase: Codable {
    let version: String
    let source: String
    let generatedDate: String
    let totalOccupations: Int
    let totalActivities: Int
    let occupations: [OccupationWorkActivities]
    let activityMetadata: [ActivityMetadata]
}

struct ActivityMetadata: Codable {
    let activityId: String
    let activityName: String
    let category: String
    let transferabilityScore: Double
    let occurrenceCount: Int
    let averageImportance: Double
}

// MARK: - Parser Class

class ONetWorkActivitiesParser {
    private var occupations: [String: (code: String, title: String)] = [:]
    private var activityRatings: [String: [String: (importance: Double?, level: Double?, n: Int?, se: Double?, lowerCI: Double?, upperCI: Double?)]] = [:]

    private let baseDir = "/Users/jasonl/Desktop/ios26_manifest_and_match/manifest and match V8/Data/ONET_Skills"

    // MARK: - Main Execution

    func run() throws {
        print("🚀 O*NET Work Activities Parser for ManifestAndMatch V8")
        print("=" * 80)
        print("")

        print("📂 Phase 1: Loading occupation data...")
        try parseOccupations()
        print("   ✅ Loaded \(occupations.count) occupations")
        print("")

        print("📊 Phase 2: Parsing work activities ratings...")
        try parseWorkActivities()
        print("   ✅ Parsed activity ratings for \(activityRatings.count) occupations")
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

        print("✅ Work activities parsing complete!")
        print("=" * 80)
    }

    // MARK: - Parsing Functions

    func parseOccupations() throws {
        let filePath = "\(baseDir)/Occupation Data.txt"
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }  // Skip header

            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 2 else { continue }

            let code = fields[0].trimmingCharacters(in: .whitespaces)
            let title = fields[1].trimmingCharacters(in: .whitespaces)

            occupations[code] = (code, title)
        }
    }

    func parseWorkActivities() throws {
        let filePath = "\(baseDir)/Work Activities.txt"
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        var processedCount = 0

        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue }  // Skip header

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

            // Initialize activity record if needed
            if activityRatings[onetCode] == nil {
                activityRatings[onetCode] = [:]
            }
            if activityRatings[onetCode]![elementId] == nil {
                activityRatings[onetCode]![elementId] = (nil, nil, nil, nil, nil, nil)
            }

            // Store rating by scale (IM = Importance, LV = Level)
            var current = activityRatings[onetCode]![elementId]!

            if scaleId == "IM" {
                current.importance = dataValue
                current.n = n
                current.se = se
                current.lowerCI = lowerCI
                current.upperCI = upperCI
            } else if scaleId == "LV" {
                current.level = dataValue
            }

            activityRatings[onetCode]![elementId] = current
            processedCount += 1
        }

        print("   📊 Processed \(processedCount) activity ratings across \(activityRatings.count) occupations")
    }

    // MARK: - Database Building

    func buildDatabase() -> WorkActivitiesDatabase {
        var occupationProfiles: [OccupationWorkActivities] = []
        var activityOccurrences: [String: Int] = [:]
        var activityImportanceSum: [String: Double] = [:]

        for (onetCode, ratings) in activityRatings {
            guard let occupation = occupations[onetCode] else { continue }

            var activities: [String: ActivityRating] = [:]

            for (activityId, rating) in ratings {
                // Both importance and level must be present
                guard let importance = rating.importance,
                      let level = rating.level,
                      let n = rating.n,
                      n >= 30 else { continue }  // Quality threshold

                let confidence = ConfidenceInterval(
                    lower: rating.lowerCI ?? 0.0,
                    upper: rating.upperCI ?? 0.0,
                    standardError: rating.se ?? 0.0
                )

                let activityRating = ActivityRating(
                    importance: importance,
                    level: level,
                    confidence: confidence,
                    sampleSize: n
                )

                activities[activityId] = activityRating

                // Track occurrences for metadata
                activityOccurrences[activityId, default: 0] += 1
                activityImportanceSum[activityId, default: 0.0] += importance
            }

            // Get top 5 activities by importance
            let topActivities = activities
                .sorted { $0.value.importance > $1.value.importance }
                .prefix(5)
                .map { $0.key }

            let sector = Sector.determineSector(onetCode: onetCode, title: occupation.title)

            let profile = OccupationWorkActivities(
                onetCode: onetCode,
                title: occupation.title,
                sector: sector,
                activities: activities,
                topActivities: Array(topActivities),
                activityCount: activities.count
            )

            occupationProfiles.append(profile)
        }

        // Build activity metadata
        let activityMetadata = WorkActivity.allCases.map { activity -> ActivityMetadata in
            let occurrences = activityOccurrences[activity.onetId] ?? 0
            let avgImportance = occurrences > 0
                ? (activityImportanceSum[activity.onetId] ?? 0.0) / Double(occurrences)
                : 0.0

            return ActivityMetadata(
                activityId: activity.onetId,
                activityName: activity.rawValue,
                category: activity.category.rawValue,
                transferabilityScore: activity.transferabilityScore,
                occurrenceCount: occurrences,
                averageImportance: avgImportance
            )
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return WorkActivitiesDatabase(
            version: "1.0",
            source: "O*NET 30.0 Database - Work Activities",
            generatedDate: dateFormatter.string(from: Date()),
            totalOccupations: occupationProfiles.count,
            totalActivities: WorkActivity.allCases.count,
            occupations: occupationProfiles.sorted { $0.onetCode < $1.onetCode },
            activityMetadata: activityMetadata.sorted { $0.activityId < $1.activityId }
        )
    }

    // MARK: - Export

    func exportDatabase(_ database: WorkActivitiesDatabase) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let jsonData = try encoder.encode(database)
        let outputPath = "\(baseDir)/onet_work_activities.json"

        try jsonData.write(to: URL(fileURLWithPath: outputPath))

        let fileSizeMB = Double(jsonData.count) / 1_048_576.0
        print("   ✅ Exported to: onet_work_activities.json")
        print("   📦 File size: \(String(format: "%.2f", fileSizeMB)) MB")
    }

    // MARK: - Statistics

    func printStatistics(_ database: WorkActivitiesDatabase) {
        print("📊 Work Activities Statistics:")
        print("=" * 80)
        print("")

        print("📈 Overall Metrics:")
        print("   • Total Occupations: \(database.totalOccupations)")
        print("   • Total Activities: \(database.totalActivities)")
        print("")

        // Activities per occupation distribution
        let activitiesCounts = database.occupations.map { $0.activityCount }
        let avgActivities = activitiesCounts.reduce(0, +) / activitiesCounts.count
        let minActivities = activitiesCounts.min() ?? 0
        let maxActivities = activitiesCounts.max() ?? 0

        print("🎯 Activities per Occupation:")
        print("   • Average: \(avgActivities)")
        print("   • Range: \(minActivities) - \(maxActivities)")
        print("")

        // Top 10 most common activities
        let topCommon = database.activityMetadata
            .sorted { $0.occurrenceCount > $1.occurrenceCount }
            .prefix(10)

        print("🔝 Top 10 Most Common Activities:")
        for (index, activity) in topCommon.enumerated() {
            let percentage = Double(activity.occurrenceCount) / Double(database.totalOccupations) * 100
            print("   \(index + 1). \(activity.activityName)")
            print("      Occurs in \(activity.occurrenceCount) occupations (\(String(format: "%.1f", percentage))%)")
            print("      Avg Importance: \(String(format: "%.2f", activity.averageImportance))")
            print("      Transferability: \(String(format: "%.2f", activity.transferabilityScore))")
        }
        print("")

        // Transferability distribution
        let highTransfer = database.activityMetadata.filter { $0.transferabilityScore >= 0.90 }.count
        let mediumTransfer = database.activityMetadata.filter { $0.transferabilityScore >= 0.70 && $0.transferabilityScore < 0.90 }.count
        let lowTransfer = database.activityMetadata.filter { $0.transferabilityScore < 0.70 }.count

        print("🔄 Transferability Distribution:")
        print("   • High (≥0.90): \(highTransfer) activities")
        print("   • Medium (0.70-0.89): \(mediumTransfer) activities")
        print("   • Sector-Specific (<0.70): \(lowTransfer) activities")
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

let parser = ONetWorkActivitiesParser()
do {
    try parser.run()
} catch {
    print("❌ Error: \(error.localizedDescription)")
    exit(1)
}
