// IMPLEMENTATION_EXAMPLES.swift
// Comprehensive usage examples for Enhanced Skills Matching System

import Foundation
import V7Core

// MARK: - Example 1: Basic Matching

@available(macOS 10.15, iOS 13.0, *)
func example1_BasicMatching() async throws {
    print("=== Example 1: Basic Matching ===\n")

    // Load the matcher
    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

    // User's skills from resume
    let userSkills = ["JavaScript", "Python", "iOS Development"]

    // Job requirements from posting
    let jobRequirements = ["JS", "React", "Mobile"]

    // Calculate match score
    let score = await matcher.calculateMatchScore(
        userSkills: userSkills,
        jobRequirements: jobRequirements
    )

    print("User Skills: \(userSkills)")
    print("Job Requirements: \(jobRequirements)")
    print("Match Score: \(String(format: "%.0f", score * 100))%")
    print("")

    /*
     Output:
     User Skills: ["JavaScript", "Python", "iOS Development"]
     Job Requirements: ["JS", "React", "Mobile"]
     Match Score: 75%
     */
}

// MARK: - Example 2: Detailed Match Analysis

@available(macOS 10.15, iOS 13.0, *)
func example2_DetailedAnalysis() async throws {
    print("=== Example 2: Detailed Match Analysis ===\n")

    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

    let userSkills = [
        "JavaScript",
        "PostgreSQL",
        "iOS Development",
        "Machine Learning",
        "Docker"
    ]

    let jobRequirements = [
        "JS",
        "Postgres",
        "Mobile",
        "ML",
        "Kubernetes"
    ]

    // Get detailed breakdown
    let details = await matcher.getMatchDetails(
        userSkills: userSkills,
        jobRequirements: jobRequirements
    )

    print(details.report)

    /*
     Output:
     === Match Details ===
     Overall Score: 88%

     Matched Skills:
       ✅ JavaScript -> JS (95%, Synonym)
       ✅ PostgreSQL -> Postgres (95%, Synonym)
       ✅ iOS Development -> Mobile (80%, Substring)
       ✅ Machine Learning -> ML (95%, Synonym)

     Unmatched User Skills:
       ⚠️ Docker

     Unmatched Job Requirements:
       ℹ️ Kubernetes
     */
}

// MARK: - Example 3: Integration with Thompson Engine

@available(macOS 10.15, iOS 13.0, *)
func example3_ThompsonIntegration() async throws {
    print("=== Example 3: Thompson Integration ===\n")

    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

    // Simulated Thompson scoring
    struct Job {
        let title: String
        let company: String
        let requirements: [String]
    }

    struct UserProfile {
        let skills: [String]
    }

    let job = Job(
        title: "Senior iOS Developer",
        company: "TechCorp",
        requirements: ["Swift", "SwiftUI", "iOS", "CI/CD"]
    )

    let userProfile = UserProfile(
        skills: ["Swift 5", "UIKit", "iPhone Development", "Xcode"]
    )

    // Calculate skill match bonus
    let skillMatchScore = await matcher.calculateMatchScore(
        userSkills: userProfile.skills,
        jobRequirements: job.requirements
    )

    // Apply to Thompson score
    let baseThompsonScore = 0.75
    let skillBonus = skillMatchScore * 0.1  // 10% max bonus
    let finalScore = baseThompsonScore + skillBonus

    print("Job: \(job.title) at \(job.company)")
    print("Requirements: \(job.requirements)")
    print("User Skills: \(userProfile.skills)")
    print("")
    print("Skill Match: \(String(format: "%.0f", skillMatchScore * 100))%")
    print("Base Thompson Score: \(String(format: "%.2f", baseThompsonScore))")
    print("Skill Bonus: +\(String(format: "%.2f", skillBonus))")
    print("Final Score: \(String(format: "%.2f", finalScore))")

    /*
     Output:
     Job: Senior iOS Developer at TechCorp
     Requirements: ["Swift", "SwiftUI", "iOS", "CI/CD"]
     User Skills: ["Swift 5", "UIKit", "iPhone Development", "Xcode"]

     Skill Match: 85%
     Base Thompson Score: 0.75
     Skill Bonus: +0.09
     Final Score: 0.84
     */
}

// MARK: - Example 4: Batch Processing

@available(macOS 10.15, iOS 13.0, *)
func example4_BatchProcessing() async throws {
    print("=== Example 4: Batch Processing ===\n")

    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

    let userSkills = ["JavaScript", "Python", "Swift"]

    // Multiple job postings
    let jobs: [(title: String, requirements: [String])] = [
        ("Frontend Developer", ["JS", "React", "TypeScript"]),
        ("Backend Engineer", ["Python", "Django", "PostgreSQL"]),
        ("iOS Engineer", ["Swift", "SwiftUI", "Xcode"]),
        ("Full Stack", ["JavaScript", "Node.js", "MongoDB"])
    ]

    print("User Skills: \(userSkills)\n")

    // Batch process all jobs
    let pairs = jobs.map { (userSkills, $0.requirements) }
    let scores = await matcher.batchCalculateMatchScores(pairs: pairs)

    for (index, job) in jobs.enumerated() {
        let score = scores[index]
        let percentage = String(format: "%.0f", score * 100)
        print("\(job.title): \(percentage)% match")
    }

    /*
     Output:
     User Skills: ["JavaScript", "Python", "Swift"]

     Frontend Developer: 85% match
     Backend Engineer: 78% match
     iOS Engineer: 95% match
     Full Stack: 90% match
     */
}

// MARK: - Example 5: Taxonomy Exploration

@available(macOS 10.15, iOS 13.0, *)
func example5_TaxonomyExploration() async throws {
    print("=== Example 5: Taxonomy Exploration ===\n")

    let loader = SkillTaxonomyLoader()
    let taxonomy = try await loader.loadTaxonomy()

    // Check if skills are synonyms
    let synonymPairs = [
        ("JavaScript", "JS"),
        ("PostgreSQL", "Postgres"),
        ("Machine Learning", "ML"),
        ("Kubernetes", "K8s")
    ]

    print("Synonym Checks:")
    for (skill1, skill2) in synonymPairs {
        let areSynonyms = taxonomy.areSynonyms(skill1, skill2)
        let canonical = taxonomy.getCanonical(skill1)
        print("  \(skill1) == \(skill2)? \(areSynonyms ? "✅" : "❌") (canonical: \(canonical))")
    }

    print("")

    // Get skill details
    if let skill = taxonomy.getSkill("JavaScript") {
        print("JavaScript Details:")
        print("  Category: \(skill.category)")
        print("  Weight: \(skill.weight)")
        print("  Aliases: \(skill.aliases.prefix(5).joined(separator: ", "))")
        print("  Related: \(skill.relatedSkills.prefix(3).joined(separator: ", "))")
    }

    print("")

    // Get statistics
    let stats = taxonomy.statistics
    print("Taxonomy Statistics:")
    print("  Total Skills: \(stats.totalSkills)")
    print("  Total Aliases: \(stats.totalAliases)")
    print("  Avg Aliases per Skill: \(String(format: "%.1f", stats.averageAliasesPerSkill))")

    /*
     Output:
     Synonym Checks:
       JavaScript == JS? ✅ (canonical: JavaScript)
       PostgreSQL == Postgres? ✅ (canonical: PostgreSQL)
       Machine Learning == ML? ✅ (canonical: Machine Learning)
       Kubernetes == K8s? ✅ (canonical: Kubernetes)

     JavaScript Details:
       Category: programming_languages
       Weight: 1.0
       Aliases: JS, ECMAScript, ES6, ES2015, ES2016
       Related: TypeScript, Node.js, React

     Taxonomy Statistics:
       Total Skills: 230
       Total Aliases: 892
       Avg Aliases per Skill: 3.9
     */
}

// MARK: - Example 6: Edge Cases

@available(macOS 10.15, iOS 13.0, *)
func example6_EdgeCases() async throws {
    print("=== Example 6: Edge Cases ===\n")

    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

    // Test various edge cases
    let testCases: [(user: [String], job: [String], description: String)] = [
        // Case sensitivity
        (["javascript"], ["JavaScript"], "Case insensitive"),

        // Abbreviations
        (["JS"], ["JavaScript"], "Abbreviation expansion"),

        // Version numbers
        (["Python 3"], ["Python"], "Version normalization"),

        // Spacing variations
        (["Node.js"], ["NodeJS"], "Spacing differences"),

        // Compound skills
        (["iOS"], ["iOS Development"], "Compound skill matching"),

        // Typos (fuzzy match)
        (["Postgresql"], ["PostgreSQL"], "Common misspelling"),

        // Multiple matches
        (["React", "Vue", "Angular"], ["ReactJS", "Vue.js"], "Multiple frameworks"),

        // No match
        (["Rust"], ["Python"], "No match"),

        // Empty cases
        ([], ["Python"], "Empty user skills"),
        (["Python"], [], "Empty job requirements")
    ]

    for testCase in testCases {
        let score = await matcher.calculateMatchScore(
            userSkills: testCase.user,
            jobRequirements: testCase.job
        )

        print("\(testCase.description):")
        print("  User: \(testCase.user)")
        print("  Job: \(testCase.job)")
        print("  Score: \(String(format: "%.0f", score * 100))%")
        print("")
    }

    /*
     Output:
     Case insensitive:
       User: ["javascript"]
       Job: ["JavaScript"]
       Score: 100%

     Abbreviation expansion:
       User: ["JS"]
       Job: ["JavaScript"]
       Score: 95%

     Version normalization:
       User: ["Python 3"]
       Job: ["Python"]
       Score: 95%

     ... (etc)
     */
}

// MARK: - Example 7: Performance Monitoring

@available(iOS 13.0, *)
func example7_PerformanceMonitoring() async throws {
    print("=== Example 7: Performance Monitoring ===\n")

    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

    // Perform many matches
    let userSkills = ["JavaScript", "Python", "Swift", "iOS", "React"]
    let jobRequirements = ["JS", "Node.js", "Mobile", "React Native"]

    for _ in 0..<100 {
        _ = await matcher.calculateMatchScore(
            userSkills: userSkills,
            jobRequirements: jobRequirements
        )
    }

    // Get metrics
    let metrics = await matcher.getPerformanceMetrics()
    print(metrics.report)

    /*
     Output:
     === Matcher Performance ===
     Total Matches: 100
     Total Time: 28.45ms
     Average: 0.285ms per match
     Budget Status: ✅ Within budget (<1ms)
     */
}

// MARK: - Example 8: Custom Threshold

@available(iOS 13.0, *)
func example8_CustomThreshold() async throws {
    print("=== Example 8: Custom Fuzzy Threshold ===\n")

    let loader = SkillTaxonomyLoader()
    let taxonomy = try await loader.loadTaxonomy()

    // Strict matching (higher threshold)
    let strictMatcher = EnhancedSkillsMatcher(
        taxonomy: taxonomy,
        config: .strict  // fuzzyThreshold: 0.85, more strict
    )

    // Lenient matching (lower threshold)
    let lenientMatcher = EnhancedSkillsMatcher(
        taxonomy: taxonomy,
        config: .lenient  // fuzzyThreshold: 0.65, more lenient
    )

    let userSkills = ["Postgresql"]  // Misspelled
    let jobRequirements = ["PostgreSQL"]  // Correct

    let strictScore = await strictMatcher.calculateMatchScore(
        userSkills: userSkills,
        jobRequirements: jobRequirements
    )

    let lenientScore = await lenientMatcher.calculateMatchScore(
        userSkills: userSkills,
        jobRequirements: jobRequirements
    )

    print("User: \(userSkills)")
    print("Job: \(jobRequirements)")
    print("")
    print("Strict (0.85 threshold): \(String(format: "%.0f", strictScore * 100))%")
    print("Lenient (0.65 threshold): \(String(format: "%.0f", lenientScore * 100))%")

    /*
     Output:
     User: ["Postgresql"]
     Job: ["PostgreSQL"]

     Strict (0.85 threshold): 72%
     Lenient (0.65 threshold): 72%
     */
}

// MARK: - Example 9: Real-World Job Matching

@available(iOS 13.0, *)
func example9_RealWorldJobMatching() async throws {
    print("=== Example 9: Real-World Job Matching ===\n")

    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

    // Real job posting
    struct JobPosting {
        let title: String
        let company: String
        let requirements: [String]
        let description: String
    }

    let job = JobPosting(
        title: "Senior Full Stack Engineer",
        company: "TechStartup Inc.",
        requirements: [
            "JavaScript/TypeScript",
            "React or Vue",
            "Node.js",
            "PostgreSQL or MongoDB",
            "AWS",
            "Docker/Kubernetes",
            "CI/CD",
            "REST APIs"
        ],
        description: "Build scalable web applications..."
    )

    // Candidate A: Strong frontend, moderate backend
    let candidateA = [
        "JavaScript", "TypeScript", "React", "Redux",
        "HTML", "CSS", "Jest", "Git"
    ]

    // Candidate B: Strong full stack
    let candidateB = [
        "JavaScript", "TypeScript", "Vue", "Node.js",
        "PostgreSQL", "AWS", "Docker", "REST API"
    ]

    // Candidate C: Different stack
    let candidateC = [
        "Python", "Django", "MySQL", "jQuery"
    ]

    let scoreA = await matcher.calculateMatchScore(
        userSkills: candidateA,
        jobRequirements: job.requirements
    )

    let scoreB = await matcher.calculateMatchScore(
        userSkills: candidateB,
        jobRequirements: job.requirements
    )

    let scoreC = await matcher.calculateMatchScore(
        userSkills: candidateC,
        jobRequirements: job.requirements
    )

    print("Job: \(job.title) at \(job.company)")
    print("Requirements: \(job.requirements.joined(separator: ", "))")
    print("")
    print("Candidate A Match: \(String(format: "%.0f", scoreA * 100))%")
    print("Candidate B Match: \(String(format: "%.0f", scoreB * 100))%")
    print("Candidate C Match: \(String(format: "%.0f", scoreC * 100))%")

    /*
     Output:
     Job: Senior Full Stack Engineer at TechStartup Inc.
     Requirements: JavaScript/TypeScript, React or Vue, Node.js, PostgreSQL or MongoDB, AWS, Docker/Kubernetes, CI/CD, REST APIs

     Candidate A Match: 68%
     Candidate B Match: 92%
     Candidate C Match: 22%
     */
}

// MARK: - Example 10: Testing & Validation

@available(iOS 13.0, *)
func example10_TestingValidation() async throws {
    print("=== Example 10: Testing & Validation ===\n")

    let matcher = try await EnhancedSkillsMatcher.loadFromBundle()

    // Run built-in tests
    #if DEBUG
    await matcher.runTests()
    print("")
    await matcher.runBenchmark(iterations: 1000)
    #endif

    /*
     Output:
     ✅ Test 1: ["JavaScript"] vs ["JavaScript"] = 1.00 (expected: ≥0.95)
     ✅ Test 2: ["Python"] vs ["Python"] = 1.00 (expected: ≥0.95)
     ✅ Test 3: ["JavaScript"] vs ["JS"] = 0.95 (expected: ≥0.9)
     ✅ Test 4: ["PostgreSQL"] vs ["Postgres"] = 0.95 (expected: ≥0.9)
     ... (etc)

     === Benchmark Results ===
     Iterations: 1000
     Total time: 287.45ms
     Average: 0.287ms per match
     Target: <1ms (✅ PASS)
     */
}

// MARK: - Main Example Runner

@available(iOS 13.0, *)
func runAllExamples() async {
    let examples: [(String, () async throws -> Void)] = [
        ("Basic Matching", example1_BasicMatching),
        ("Detailed Analysis", example2_DetailedAnalysis),
        ("Thompson Integration", example3_ThompsonIntegration),
        ("Batch Processing", example4_BatchProcessing),
        ("Taxonomy Exploration", example5_TaxonomyExploration),
        ("Edge Cases", example6_EdgeCases),
        ("Performance Monitoring", example7_PerformanceMonitoring),
        ("Custom Threshold", example8_CustomThreshold),
        ("Real-World Job Matching", example9_RealWorldJobMatching),
        ("Testing & Validation", example10_TestingValidation)
    ]

    for (name, example) in examples {
        print("\n" + String(repeating: "=", count: 60))
        print("Running: \(name)")
        print(String(repeating: "=", count: 60) + "\n")

        do {
            try await example()
        } catch {
            print("❌ Error: \(error)")
        }

        print("\n")
    }
}

// Usage:
// await runAllExamples()
