#!/usr/bin/env swift

import Foundation

// Additional supplemental skills for final pass
let additionalSkills: [String: [String]] = [
    "Personal Care/Service": [
        // Advanced Esthetics
        "LED Light Therapy", "Radio Frequency Treatments", "Ultrasound Facials",
        "Oxygen Therapy", "Dermaplaning", "Hydrafacial", "Permanent Makeup",
        "Microblading", "Lash Lift", "Brow Lamination",
        // Specialized Hair Services
        "Hair Loss Treatment", "Scalp Analysis", "Keratin Treatment",
        "Japanese Straightening", "Perm Services", "Men's Grooming",
        "Beard Trimming", "Shaving Services",
        // Wellness Services
        "Reiki", "Energy Healing", "Meditation Coaching", "Mindfulness Training",
        "Stress Management", "Life Coaching", "Health Coaching",
        // Business Skills
        "Inventory Management", "Point of Sale", "Booking Software",
        "Social Media Marketing", "Client Retention", "Upselling",
        "Product Recommendations", "Customer Loyalty Programs"
    ],

    "Protective Service": [
        // Advanced Law Enforcement
        "Fingerprint Analysis", "Ballistics", "Digital Forensics", "Crime Analysis",
        "Undercover Operations", "K-9 Handling", "SWAT Operations",
        "Hostage Negotiation", "Gang Intelligence",
        // Specialized Security
        "Executive Protection", "VIP Security", "Event Security",
        "Loss Prevention", "Asset Protection", "Fraud Investigation",
        // Emergency Management
        "Disaster Response", "Emergency Planning", "Evacuation Procedures",
        "Incident Command", "Mass Casualty Management", "Triage"
    ],

    "Social/Community Service": [
        // Additional Counseling
        "Play Therapy", "Art Therapy", "Music Therapy", "Grief Counseling",
        "Bereavement Support", "Anger Management", "Stress Counseling",
        "Career Counseling", "School Counseling",
        // Program Management
        "Needs Assessment", "Community Needs Analysis", "Service Delivery",
        "Quality Assurance", "Performance Metrics", "Impact Evaluation",
        "Stakeholder Engagement"
    ]
]

// Data Models
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

class FinalSupplementer {
    var skills: [Skill] = []
    var maxIdBySector: [String: Int] = [:]

    func loadSkills() throws {
        print("📖 Loading skills_final.json...")
        let data = try Data(contentsOf: URL(fileURLWithPath: "skills_final.json"))
        let database = try JSONDecoder().decode(SkillsDatabase.self, from: data)
        skills = database.skills

        for skill in skills {
            let prefix = extractPrefix(from: skill.id)
            let number = extractNumber(from: skill.id)
            maxIdBySector[prefix] = max(maxIdBySector[prefix, default: 0], number)
        }

        print("✅ Loaded \(skills.count) skills")
    }

    func addFinalSupplements() {
        print("\n🔧 Adding final supplements...")

        for (category, newSkills) in additionalSkills {
            let currentCount = skills.filter { $0.category == category }.count
            let needed = max(0, 150 - currentCount)

            if needed > 0 {
                print("   Adding \(min(needed, newSkills.count)) to \(category)")

                for skillName in newSkills.prefix(needed) {
                    addSkill(name: skillName, category: category)
                }
            }
        }
    }

    func addSkill(name: String, category: String) {
        let exists = skills.contains { $0.name.lowercased() == name.lowercased() && $0.category == category }
        guard !exists else { return }

        let prefix = category.lowercased()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        let nextId = maxIdBySector[prefix, default: 0] + 1
        maxIdBySector[prefix] = nextId

        let skill = Skill(
            id: "\(prefix)_\(String(format: "%03d", nextId))",
            name: name,
            category: category,
            keywords: generateKeywords(for: name),
            relatedSkills: []
        )

        skills.append(skill)
    }

    func extractPrefix(from id: String) -> String {
        let components = id.components(separatedBy: "_")
        return components.dropLast().joined(separator: "_")
    }

    func extractNumber(from id: String) -> Int {
        let components = id.components(separatedBy: "_")
        guard let last = components.last, let number = Int(last) else { return 0 }
        return number
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
        let output = SkillsDatabase(skills: skills)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(output)

        try jsonData.write(to: URL(fileURLWithPath: "skills_v2_complete.json"))

        print("\n📝 Written to skills_v2_complete.json")
        printStats()
    }

    func printStats() {
        var categoryCount: [String: Int] = [:]
        for skill in skills {
            categoryCount[skill.category, default: 0] += 1
        }

        print("\n📊 FINAL STATISTICS:")
        print("   Total Skills: \(skills.count)")
        print("\n📈 SECTOR DISTRIBUTION:")

        for (category, count) in categoryCount.sorted(by: { $0.key < $1.key }) {
            // Core Skills and Knowledge Areas are special - don't need 150+
            let isSpecial = category == "Core Skills" || category == "Knowledge Areas"
            let status = isSpecial ? "✅" : (count >= 150 ? "✅" : "⚠️")
            print("   \(status) \(category.padding(toLength: 30, withPad: " ", startingAt: 0)): \(count) skills")
        }

        let sectorCategories = categoryCount.filter { $0.key != "Core Skills" && $0.key != "Knowledge Areas" }
        let below150 = sectorCategories.filter { $0.value < 150 }

        if below150.isEmpty {
            print("\n🎯 ✅ ALL SECTOR CATEGORIES MEET 150+ THRESHOLD")
        }
    }
}

print("=" + String(repeating: "=", count: 79))
print("Final Skills Supplementer")
print("=" + String(repeating: "=", count: 79))
print()

let supp = FinalSupplementer()

do {
    try supp.loadSkills()
    supp.addFinalSupplements()
    try supp.writeOutput()
    print("\n✅ COMPLETE")
} catch {
    print("❌ ERROR: \(error)")
    exit(1)
}
