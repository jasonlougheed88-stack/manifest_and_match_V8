#!/usr/bin/env swift

import Foundation

// MARK: - Supplemental Skills for Low-Count Categories
let supplementalSkills: [String: [String]] = [
    "Arts/Design/Media": [
        // Graphic Design
        "Adobe Creative Suite", "Photoshop", "Illustrator", "InDesign", "After Effects",
        "Figma", "Sketch", "XD", "Canva", "CorelDRAW",
        // Video/Audio Production
        "Final Cut Pro", "Premiere Pro", "Avid Media Composer", "DaVinci Resolve",
        "Logic Pro", "Pro Tools", "Ableton Live", "FL Studio",
        // 3D/Animation
        "Blender", "Maya", "3ds Max", "Cinema 4D", "ZBrush",
        "Unity", "Unreal Engine", "Motion Graphics",
        // Photography
        "Lightroom", "Capture One", "Portrait Photography", "Product Photography",
        "Event Photography", "Photo Editing", "Color Grading",
        // Writing/Content
        "Copywriting", "Content Strategy", "SEO Writing", "Technical Writing",
        "Grant Writing", "Screenplay Writing", "Journalism", "Editing",
        // Design Skills
        "Typography", "Color Theory", "Layout Design", "Brand Identity",
        "UI Design", "UX Design", "Wireframing", "Prototyping",
        "Print Design", "Packaging Design", "Logo Design",
        // Media Production
        "Video Editing", "Audio Editing", "Sound Design", "Music Production",
        "Podcast Production", "Live Streaming", "Broadcasting"
    ],

    "Personal Care/Service": [
        // Cosmetology
        "Hair Cutting", "Hair Styling", "Hair Coloring", "Balayage", "Highlights",
        "Blow Drying", "Updos", "Braiding", "Extensions",
        // Skincare/Esthetics
        "Facials", "Microdermabrasion", "Chemical Peels", "Waxing",
        "Makeup Application", "Bridal Makeup", "Special Effects Makeup",
        "Lash Extensions", "Brow Shaping", "Skincare Consultation",
        // Nails
        "Manicures", "Pedicures", "Gel Nails", "Acrylic Nails", "Nail Art",
        // Massage/Bodywork
        "Swedish Massage", "Deep Tissue Massage", "Sports Massage", "Reflexology",
        "Hot Stone Massage", "Prenatal Massage", "Aromatherapy",
        // Fitness/Wellness
        "Personal Training", "Yoga Instruction", "Pilates", "Zumba",
        "Nutrition Counseling", "Weight Management", "Fitness Assessment",
        // Other Services
        "Barbering", "Spa Services", "Body Wraps", "Tanning",
        "Image Consulting", "Wardrobe Styling", "Color Analysis",
        "Customer Service", "Appointment Scheduling", "Retail Sales",
        "Product Knowledge", "Sanitation Practices", "Client Consultation"
    ],

    "Protective Service": [
        // Law Enforcement
        "Criminal Law", "Patrol Procedures", "Traffic Control", "Crime Scene Investigation",
        "Evidence Collection", "Report Writing", "Arrest Procedures", "Search and Seizure",
        "Community Policing", "De-escalation", "Crisis Intervention",
        // Security
        "Access Control", "Surveillance Systems", "CCTV Monitoring", "Alarm Systems",
        "Security Patrol", "Incident Response", "Threat Assessment", "Risk Management",
        "Physical Security", "Cybersecurity Basics", "Emergency Response",
        // Fire/EMS
        "Firefighting", "Fire Prevention", "Hazmat Response", "Rescue Operations",
        "EMT Certification", "CPR/AED", "First Aid", "Trauma Care",
        "Emergency Medical Services", "Ambulance Operations",
        // Corrections
        "Inmate Supervision", "Correctional Procedures", "Contraband Detection",
        "Crisis Management", "Conflict Resolution", "Behavioral Management",
        // Military/Defense
        "Weapons Handling", "Tactical Operations", "Military Protocols",
        "Combat Training", "Strategic Planning", "Intelligence Analysis",
        // General
        "Background Checks", "Security Clearance", "Self-Defense",
        "Defensive Tactics", "Use of Force", "Legal Procedures",
        "Radio Communications", "Microsoft Office", "Report Documentation",
        "Situational Awareness", "Teamwork", "Physical Fitness"
    ],

    "Science/Research": [
        // Laboratory Skills
        "Laboratory Techniques", "Aseptic Technique", "Pipetting", "Cell Culture",
        "PCR", "Gel Electrophoresis", "Spectroscopy", "Chromatography",
        "Microscopy", "Centrifugation", "Titration", "pH Measurement",
        // Analytical Skills
        "Data Analysis", "Statistical Analysis", "R Programming", "Python",
        "MATLAB", "SAS", "SPSS", "Regression Analysis", "Hypothesis Testing",
        // Research Methods
        "Experimental Design", "Protocol Development", "Literature Review",
        "Grant Writing", "IRB Compliance", "GLP/GMP", "Quality Control",
        "Technical Writing", "Scientific Writing", "Peer Review",
        // Instrumentation
        "Mass Spectrometry", "NMR", "HPLC", "FPLC", "Flow Cytometry",
        "Western Blot", "ELISA", "qPCR", "DNA Sequencing",
        // Specialized Fields
        "Molecular Biology", "Biochemistry", "Genetics", "Microbiology",
        "Immunology", "Pharmacology", "Neuroscience", "Ecology",
        "Environmental Science", "Chemistry", "Physics", "Geology",
        // Software/Tools
        "LabVIEW", "GraphPad Prism", "EndNote", "Mendeley", "ChemDraw",
        "Bioinformatics", "Genomics", "Proteomics", "Computational Biology",
        // Compliance
        "Safety Protocols", "Chemical Handling", "Waste Disposal",
        "OSHA Regulations", "ISO Standards", "Documentation"
    ],

    "Social/Community Service": [
        // Social Work
        "Case Management", "Client Assessment", "Crisis Intervention",
        "Counseling", "Trauma-Informed Care", "Substance Abuse Counseling",
        "Mental Health Support", "Family Therapy", "Group Therapy",
        "Cognitive Behavioral Therapy", "Motivational Interviewing",
        // Community Outreach
        "Community Organizing", "Program Development", "Volunteer Coordination",
        "Event Planning", "Fundraising", "Grant Writing", "Public Speaking",
        "Coalition Building", "Advocacy", "Policy Analysis",
        // Child/Family Services
        "Child Welfare", "Foster Care", "Adoption Services", "Parenting Support",
        "Child Development", "Family Preservation", "Home Visits",
        "Youth Mentoring", "Juvenile Justice",
        // Healthcare/Support
        "Patient Advocacy", "Care Coordination", "Discharge Planning",
        "Benefits Navigation", "Housing Assistance", "Food Security",
        "Medical Social Work", "Hospice Care", "Palliative Care",
        // Nonprofit Management
        "Program Evaluation", "Outcome Measurement", "Budget Management",
        "Donor Relations", "Board Development", "Strategic Planning",
        "Nonprofit Accounting", "Volunteer Management",
        // Cultural Competency
        "Multilingual Services", "Cultural Sensitivity", "Diversity Training",
        "Immigrant Services", "Refugee Resettlement", "Translation Services",
        // Documentation
        "Electronic Health Records", "HIPAA Compliance", "Report Writing",
        "Progress Notes", "Treatment Planning", "Referral Coordination",
        // General Skills
        "Active Listening", "Empathy", "Boundary Setting", "Self-Care",
        "Professional Ethics", "Confidentiality", "Time Management"
    ]
]

// MARK: - Data Models
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

// MARK: - Supplementer
class SkillsSupplementer {
    var skills: [Skill] = []
    var maxIdBySector: [String: Int] = [:]

    func loadMergedSkills() throws {
        print("📖 Loading merged skills...")
        let data = try Data(contentsOf: URL(fileURLWithPath: "skills_merged.json"))
        let database = try JSONDecoder().decode(SkillsDatabase.self, from: data)
        skills = database.skills

        // Find max ID per sector for ID generation
        for skill in skills {
            let prefix = extractPrefix(from: skill.id)
            let number = extractNumber(from: skill.id)
            maxIdBySector[prefix] = max(maxIdBySector[prefix, default: 0], number)
        }

        print("✅ Loaded \(skills.count) skills")
    }

    func supplementLowCountCategories() {
        print("\n🔧 Supplementing low-count categories...")

        for (category, newSkills) in supplementalSkills {
            let currentCount = skills.filter { $0.category == category }.count
            let needed = max(0, 150 - currentCount)

            if needed > 0 {
                print("   Adding \(min(needed, newSkills.count)) skills to \(category) (currently \(currentCount))")

                let skillsToAdd = Array(newSkills.prefix(needed))
                for skillName in skillsToAdd {
                    addSkill(name: skillName, category: category)
                }
            }
        }

        print("✅ Supplementation complete")
    }

    func addSkill(name: String, category: String) {
        // Check for duplicates
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
        print("\n📝 Writing final skills.json...")

        let output = SkillsDatabase(skills: skills)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(output)

        try jsonData.write(to: URL(fileURLWithPath: "skills_final.json"))

        print("✅ Written to skills_final.json")
        printStatistics()
    }

    func printStatistics() {
        print("\n📊 FINAL STATISTICS:")
        print("   Total Skills: \(skills.count)")

        var categoryCount: [String: Int] = [:]
        for skill in skills {
            categoryCount[skill.category, default: 0] += 1
        }

        print("\n📈 CATEGORY DISTRIBUTION:")
        for (category, count) in categoryCount.sorted(by: { $0.key < $1.key }) {
            let status = count >= 150 ? "✅" : (count >= 100 ? "⚠️" : "❌")
            print("   \(status) \(category.padding(toLength: 30, withPad: " ", startingAt: 0)): \(count) skills")
        }

        let belowTarget = categoryCount.filter { $0.value < 150 }
        if belowTarget.isEmpty {
            print("\n🎯 ✅ ALL CATEGORIES MEET 150+ THRESHOLD")
        } else {
            print("\n⚠️  CATEGORIES BELOW 150:")
            for (category, count) in belowTarget.sorted(by: { $0.key < $1.key }) {
                print("      \(category): \(count) (need \(150 - count) more)")
            }
        }
    }
}

// MARK: - Main
print("=" + String(repeating: "=", count: 79))
print("Skills Supplementer for ManifestAndMatch V8")
print("=" + String(repeating: "=", count: 79))
print()

let supplementer = SkillsSupplementer()

do {
    try supplementer.loadMergedSkills()
    supplementer.supplementLowCountCategories()
    try supplementer.writeOutput()

    print("\n" + String(repeating: "=", count: 80))
    print("✅ SUPPLEMENTATION COMPLETE")
    print(String(repeating: "=", count: 80))
} catch {
    print("\n❌ ERROR: \(error)")
    exit(1)
}
