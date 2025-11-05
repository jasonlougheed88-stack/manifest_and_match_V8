// ThompsonONetPerformanceTests.swift - V7Thompson Module
// Performance validation for O*NET integration in Thompson Sampling
//
// CRITICAL REQUIREMENTS:
// - P95 (95th percentile) < 10ms Thompson budget
// - P50 (50th percentile) < 6ms for optimal user experience
// - CI/CD gates fail build if thresholds exceeded
//
// Test methodology:
// 1. Warm-up iterations (cache priming)
// 2. 1000 measurement iterations
// 3. Statistical analysis (P50, P95, P99)
// 4. Threshold validation with detailed failure diagnostics

import Testing
import Foundation
@testable import V7Thompson
@testable import V7Core

// MARK: - Performance Test Suite

@Suite("Thompson O*NET Performance Tests", .serialized)
struct ThompsonONetPerformanceTests {

    // MARK: - Test Configuration

    private static let warmupIterations = 100
    private static let measurementIterations = 1000
    private static let p95Threshold: Double = 10.0  // milliseconds
    private static let p50Threshold: Double = 6.0   // milliseconds

    // MARK: - Individual O*NET Function Performance

    @Test("matchSkills() performance: P95<10ms, P50<6ms")
    func testMatchSkillsPerformance() async throws {
        let engine = await ThompsonSamplingEngine()

        let testUserSkills = [
            "Swift", "iOS Development", "SwiftUI", "UIKit", "Core Data",
            "Combine", "Async/Await", "REST APIs", "Git", "Xcode",
            "Unit Testing", "Performance Optimization", "Accessibility"
        ]

        let testJob = Job(
            title: "Senior iOS Engineer",
            company: "Tech Corp",
            requirements: [
                "Swift", "SwiftUI", "Core Data", "REST APIs",
                "Unit Testing", "CI/CD", "App Store Deployment"
            ],
            onetCode: "15-1253.00"  // Software Quality Assurance Analysts (closest available to software dev)
        )

        let measurements = try await measurePerformance(
            warmupIterations: Self.warmupIterations,
            measurementIterations: Self.measurementIterations
        ) {
            _ = await engine.matchSkills(userSkills: testUserSkills, job: testJob)
        }

        try validatePerformanceThresholds(
            measurements: measurements,
            functionName: "matchSkills()",
            p95Threshold: Self.p95Threshold,
            p50Threshold: Self.p50Threshold
        )
    }

    @Test("matchEducation() performance: P95<10ms, P50<6ms")
    func testMatchEducationPerformance() async throws {
        let engine = await ThompsonSamplingEngine()

        let testEducationLevel = 8  // Bachelor's degree
        let testJob = Job(
            title: "Software Engineer",
            company: "Tech Corp",
            onetCode: "15-1253.00"  // Software Quality Assurance Analysts
        )

        // Load O*NET credentials for education requirements
        guard let credentials = try await ONetDataService.shared.getCredentials(for: testJob.onetCode!) else {
            throw TestError.missingONetData("Credentials not found for O*NET code: \(testJob.onetCode!)")
        }

        let measurements = try await measurePerformance(
            warmupIterations: Self.warmupIterations,
            measurementIterations: Self.measurementIterations
        ) {
            _ = await engine.matchEducation(
                userEducation: testEducationLevel,
                jobRequirements: credentials.educationRequirements
            )
        }

        try validatePerformanceThresholds(
            measurements: measurements,
            functionName: "matchEducation()",
            p95Threshold: Self.p95Threshold,
            p50Threshold: Self.p50Threshold
        )
    }

    @Test("matchExperience() performance: P95<10ms, P50<6ms")
    func testMatchExperiencePerformance() async throws {
        let engine = await ThompsonSamplingEngine()

        let testExperience = 5.0  // 5 years
        let testJob = Job(
            title: "Senior Developer",
            company: "Tech Corp",
            onetCode: "15-1253.00"  // Software Quality Assurance Analysts
        )

        // Load O*NET credentials for experience requirements
        guard let credentials = try await ONetDataService.shared.getCredentials(for: testJob.onetCode!) else {
            throw TestError.missingONetData("Credentials not found for O*NET code: \(testJob.onetCode!)")
        }

        let measurements = try await measurePerformance(
            warmupIterations: Self.warmupIterations,
            measurementIterations: Self.measurementIterations
        ) {
            _ = await engine.matchExperience(
                userExperience: testExperience,
                jobRequirements: credentials.experienceRequirements
            )
        }

        try validatePerformanceThresholds(
            measurements: measurements,
            functionName: "matchExperience()",
            p95Threshold: Self.p95Threshold,
            p50Threshold: Self.p50Threshold
        )
    }

    @Test("matchWorkActivities() performance: P95<10ms, P50<6ms")
    func testMatchWorkActivitiesPerformance() async throws {
        let engine = await ThompsonSamplingEngine()

        let testActivities: [String: Double] = [
            "4.A.2.a.4": 6.5,  // Analyzing Data
            "4.A.1.a.1": 5.0,  // Getting Information
            "4.A.2.b.2": 5.5,  // Processing Information
            "4.A.4.a.1": 4.0   // Updating Knowledge
        ]

        let testJob = Job(
            title: "Data Analyst",
            company: "Analytics Inc",
            onetCode: "11-2021.00"  // Marketing Managers (valid in all O*NET databases)
        )

        // Load O*NET work activities
        guard let jobActivities = try await ONetDataService.shared.getWorkActivities(for: testJob.onetCode!) else {
            throw TestError.missingONetData("Work activities not found for O*NET code: \(testJob.onetCode!)")
        }

        let measurements = try await measurePerformance(
            warmupIterations: Self.warmupIterations,
            measurementIterations: Self.measurementIterations
        ) {
            _ = await engine.matchWorkActivities(
                userActivities: testActivities,
                jobActivities: jobActivities
            )
        }

        try validatePerformanceThresholds(
            measurements: measurements,
            functionName: "matchWorkActivities()",
            p95Threshold: Self.p95Threshold,
            p50Threshold: Self.p50Threshold
        )
    }

    @Test("matchInterests() performance: P95<10ms, P50<6ms")
    func testMatchInterestsPerformance() async throws {
        let engine = await ThompsonSamplingEngine()

        let testInterests = RIASECProfile(
            realistic: 3.0,
            investigative: 6.5,
            artistic: 4.0,
            social: 3.5,
            enterprising: 5.0,
            conventional: 4.5
        )

        let testJob = Job(
            title: "Software Engineer",
            company: "Tech Corp",
            onetCode: "15-1253.00"  // Software Quality Assurance Analysts
        )

        // Load O*NET interests
        guard let jobInterests = try await ONetDataService.shared.getInterests(for: testJob.onetCode!) else {
            throw TestError.missingONetData("Interests not found for O*NET code: \(testJob.onetCode!)")
        }

        let measurements = try await measurePerformance(
            warmupIterations: Self.warmupIterations,
            measurementIterations: Self.measurementIterations
        ) {
            _ = await engine.matchInterests(
                userInterests: testInterests,
                jobInterests: jobInterests.riasecProfile
            )
        }

        try validatePerformanceThresholds(
            measurements: measurements,
            functionName: "matchInterests()",
            p95Threshold: Self.p95Threshold,
            p50Threshold: Self.p50Threshold
        )
    }

    // MARK: - Composite O*NET Scoring Performance

    @Test("Complete O*NET scoring pipeline: P95<10ms, P50<6ms")
    func testCompleteONetScoringPerformance() async throws {
        let engine = await ThompsonSamplingEngine()

        let testProfile = ProfessionalProfile(
            skills: ["Swift", "iOS", "SwiftUI", "Core Data"],
            educationLevel: 8,
            yearsOfExperience: 5.0,
            workActivities: ["4.A.2.a.4": 6.5, "4.A.1.a.1": 5.0],
            interests: RIASECProfile(
                realistic: 3.0,
                investigative: 6.5,
                artistic: 4.0,
                social: 3.5,
                enterprising: 5.0,
                conventional: 4.5
            ),
            abilities: ["1.A.1.a.1": 6.0, "2.A.1.a": 6.5]
        )

        let testJob = Job(
            title: "Senior iOS Developer",
            company: "Mobile First Inc",
            requirements: ["Swift", "SwiftUI", "UIKit", "Core Data"],
            onetCode: "15-1253.00"  // Software Quality Assurance Analysts
        )

        guard let onetCode = testJob.onetCode else {
            throw TestError.missingONetData("Job missing O*NET code")
        }

        let measurements = try await measurePerformance(
            warmupIterations: Self.warmupIterations,
            measurementIterations: Self.measurementIterations
        ) {
            _ = try? await engine.computeONetScore(
                for: testJob,
                profile: testProfile,
                onetCode: onetCode
            )
        }

        try validatePerformanceThresholds(
            measurements: measurements,
            functionName: "Complete O*NET pipeline",
            p95Threshold: Self.p95Threshold,
            p50Threshold: Self.p50Threshold
        )
    }

    // MARK: - Performance Measurement Utilities

    private func measurePerformance(
        warmupIterations: Int,
        measurementIterations: Int,
        operation: @escaping () async -> Void
    ) async throws -> [Double] {
        // Warmup phase (prime caches)
        for _ in 0..<warmupIterations {
            await operation()
        }

        // Measurement phase
        var measurements: [Double] = []
        measurements.reserveCapacity(measurementIterations)

        for _ in 0..<measurementIterations {
            let startTime = CFAbsoluteTimeGetCurrent()
            await operation()
            let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000.0  // Convert to ms
            measurements.append(elapsed)
        }

        return measurements
    }

    private func validatePerformanceThresholds(
        measurements: [Double],
        functionName: String,
        p95Threshold: Double,
        p50Threshold: Double
    ) throws {
        let sorted = measurements.sorted()

        // Calculate percentiles
        let p50Index = Int(Double(sorted.count) * 0.50)
        let p95Index = Int(Double(sorted.count) * 0.95)
        let p99Index = Int(Double(sorted.count) * 0.99)

        let p50 = sorted[p50Index]
        let p95 = sorted[p95Index]
        let p99 = sorted[p99Index]
        let mean = sorted.reduce(0.0, +) / Double(sorted.count)
        let min = sorted.first ?? 0.0
        let max = sorted.last ?? 0.0

        // Print detailed statistics
        print("""

        📊 Performance Report: \(functionName)
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Iterations: \(measurements.count)

        Latency (ms):
          Min:  \(String(format: "%.3f", min))
          P50:  \(String(format: "%.3f", p50))  [Threshold: <\(p50Threshold)ms]
          P95:  \(String(format: "%.3f", p95))  [Threshold: <\(p95Threshold)ms]
          P99:  \(String(format: "%.3f", p99))
          Max:  \(String(format: "%.3f", max))
          Mean: \(String(format: "%.3f", mean))

        Threshold Status:
          P50: \(p50 < p50Threshold ? "✅ PASS" : "❌ FAIL")
          P95: \(p95 < p95Threshold ? "✅ PASS" : "❌ FAIL")
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        """)

        // Validate P50 threshold
        #expect(
            p50 < p50Threshold,
            """
            ❌ P50 PERFORMANCE VIOLATION: \(functionName)

            P50 latency: \(String(format: "%.3f", p50))ms
            Threshold:   \(p50Threshold)ms
            Violation:   +\(String(format: "%.3f", p50 - p50Threshold))ms over budget

            This indicates the typical user experience is degraded.
            Review algorithmic complexity and cache efficiency.
            """
        )

        // Validate P95 threshold (CRITICAL - sacred Thompson budget)
        #expect(
            p95 < p95Threshold,
            """
            ❌ P95 PERFORMANCE VIOLATION: \(functionName)

            P95 latency: \(String(format: "%.3f", p95))ms
            Threshold:   \(p95Threshold)ms (SACRED THOMPSON BUDGET)
            Violation:   +\(String(format: "%.3f", p95 - p95Threshold))ms over budget

            This violates the sacred <10ms Thompson Sampling constraint.
            The 357x competitive advantage is at risk.
            IMMEDIATE ACTION REQUIRED.
            """
        )
    }
}

// MARK: - Test Error Types

enum TestError: Error, CustomStringConvertible {
    case missingONetData(String)

    var description: String {
        switch self {
        case .missingONetData(let message):
            return "O*NET Data Error: \(message)"
        }
    }
}

// MARK: - CI/CD Integration

/// CI/CD gate configuration for performance tests
///
/// Add to your CI/CD pipeline (GitHub Actions, Xcode Cloud, etc.):
///
/// ```bash
/// # Run performance tests
/// swift test --filter ThompsonONetPerformanceTests
///
/// # Exit code:
/// # 0 = All tests passed (P50 < 6ms, P95 < 10ms)
/// # 1 = Performance threshold violated (FAIL BUILD)
/// ```
///
/// **GitHub Actions Example:**
/// ```yaml
/// - name: Performance Tests
///   run: |
///     swift test --filter ThompsonONetPerformanceTests
///   env:
///     SWIFT_DETERMINISTIC_HASHING: 1
/// ```
///
/// **Xcode Cloud Example:**
/// - Add "Run Swift Tests" action
/// - Filter: "ThompsonONetPerformanceTests"
/// - Fail build on test failure: YES
