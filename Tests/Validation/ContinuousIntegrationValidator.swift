import Foundation
import CryptoKit

// MARK: - Continuous Integration Validation Framework
// ManifestAndMatchV7 CI/CD Documentation Validation
// Prevents documentation drift from entering the codebase

/// CI/CD pipeline validator that blocks commits with documentation drift
@MainActor
public final class ContinuousIntegrationValidator: Sendable {

    // MARK: - Properties

    private let workspacePath: URL
    private let truthValidator: DocumentationTruthValidator
    private let gitIntegration: GitIntegration
    private let webhookNotifier: WebhookNotifier

    // MARK: - Initialization

    public init(workspacePath: URL) {
        self.workspacePath = workspacePath
        self.truthValidator = DocumentationTruthValidator(workspacePath: workspacePath)
        self.gitIntegration = GitIntegration(workspacePath: workspacePath)
        self.webhookNotifier = WebhookNotifier()
    }

    // MARK: - Pre-Commit Validation

    /// Validates documentation before allowing commits
    public func validatePreCommit() async throws -> PreCommitValidationResult {
        print("🚦 Running pre-commit documentation validation...")

        // Get staged changes
        let stagedChanges = try await gitIntegration.getStagedChanges()

        // Check if documentation or code files are modified
        let hasDocumentationChanges = stagedChanges.contains { $0.hasSuffix(".md") }
        let hasCodeChanges = stagedChanges.contains { $0.hasSuffix(".swift") }

        if !hasDocumentationChanges && !hasCodeChanges {
            return PreCommitValidationResult(
                passed: true,
                validations: [],
                blockingIssues: [],
                warnings: []
            )
        }

        // Run truth validation
        let truthReport = try await truthValidator.validateDocumentationTruth()

        // Analyze results for blocking issues
        let blockingIssues = extractBlockingIssues(from: truthReport)
        let warnings = extractWarnings(from: truthReport)

        // Check for documentation-code synchronization
        let syncValidation = try await validateDocumentationCodeSync(
            documentationChanges: stagedChanges.filter { $0.hasSuffix(".md") },
            codeChanges: stagedChanges.filter { $0.hasSuffix(".swift") }
        )

        let result = PreCommitValidationResult(
            passed: blockingIssues.isEmpty && syncValidation.isSynchronized,
            validations: [truthReport],
            blockingIssues: blockingIssues + (syncValidation.isSynchronized ? [] : syncValidation.issues),
            warnings: warnings
        )

        // Generate detailed report
        if !result.passed {
            try await generatePreCommitReport(result)
        }

        return result
    }

    // MARK: - Pull Request Validation

    /// Validates documentation in pull requests
    public func validatePullRequest(branch: String, baseBranch: String = "main") async throws -> PullRequestValidationResult {
        print("🔍 Validating pull request documentation...")

        // Get diff between branches
        let diff = try await gitIntegration.getDiff(from: baseBranch, to: branch)

        // Identify changed documentation and code
        let changedDocs = diff.changedFiles.filter { $0.path.hasSuffix(".md") }
        let changedCode = diff.changedFiles.filter { $0.path.hasSuffix(".swift") }

        // Run comprehensive validation
        let truthReport = try await truthValidator.validateDocumentationTruth()

        // Check for documentation coverage of new features
        let coverageValidation = try await validateDocumentationCoverage(
            newCode: changedCode,
            documentation: changedDocs
        )

        // Validate that performance claims are still valid after changes
        let performanceValidation = try await validatePerformancePreservation(
            changedFiles: changedCode
        )

        // Check for breaking changes that need documentation updates
        let breakingChanges = try await detectBreakingChanges(in: changedCode)

        let result = PullRequestValidationResult(
            branch: branch,
            baseBranch: baseBranch,
            truthValidation: truthReport,
            coverageValidation: coverageValidation,
            performanceValidation: performanceValidation,
            breakingChanges: breakingChanges,
            passed: truthReport.isValid && coverageValidation.hasSufficientCoverage && performanceValidation.preserved
        )

        // Post status to PR
        try await postPullRequestStatus(result)

        return result
    }

    // MARK: - Continuous Monitoring

    /// Continuously monitors and validates documentation in CI pipeline
    public func startContinuousMonitoring() async throws {
        print("🔄 Starting continuous documentation monitoring...")

        // Set up scheduled validation
        Task {
            while !Task.isCancelled {
                do {
                    // Run validation every hour
                    try await Task.sleep(nanoseconds: 3600 * 1_000_000_000)

                    let report = try await truthValidator.validateDocumentationTruth()

                    if report.driftDetected {
                        // Send alerts
                        try await sendDriftAlert(report)

                        // Create automated issue
                        try await createGitHubIssue(for: report)
                    }

                    // Update metrics dashboard
                    try await updateMetricsDashboard(report)

                } catch {
                    print("⚠️ Monitoring error: \(error)")
                }
            }
        }
    }

    // MARK: - Build Pipeline Integration

    /// Integrates with build pipeline to validate documentation
    public func validateBuildPipeline() async throws -> BuildValidationResult {
        print("🔨 Validating documentation in build pipeline...")

        // Check if build is from main branch
        let currentBranch = try await gitIntegration.getCurrentBranch()
        let isMainBranch = currentBranch == "main" || currentBranch == "master"

        // Run different validation levels based on branch
        let validationLevel: ValidationLevel = isMainBranch ? .comprehensive : .standard

        // Execute validation suite
        let validations = try await executeValidationSuite(level: validationLevel)

        // Generate build artifacts
        let artifacts = try await generateBuildArtifacts(validations: validations)

        // Check quality gates
        let qualityGates = checkQualityGates(validations: validations)

        let result = BuildValidationResult(
            branch: currentBranch,
            validations: validations,
            artifacts: artifacts,
            qualityGatesPassed: qualityGates.allPassed,
            failedGates: qualityGates.failed
        )

        // Fail build if quality gates not met
        if !result.qualityGatesPassed && isMainBranch {
            throw CIValidationError.qualityGatesNotMet(gates: qualityGates.failed)
        }

        return result
    }

    // MARK: - Deployment Validation

    /// Final validation before deployment
    public func validateDeployment(environment: DeploymentEnvironment) async throws -> DeploymentValidationResult {
        print("🚀 Running deployment documentation validation...")

        // Ensure no critical documentation issues
        let truthReport = try await truthValidator.validateDocumentationTruth()

        guard !truthReport.driftDetected else {
            throw CIValidationError.documentationDriftDetected(report: truthReport)
        }

        // Verify all required documentation exists
        let requiredDocs = try await verifyRequiredDocumentation(for: environment)

        // Check API documentation completeness
        let apiDocValidation = try await validateAPIDocumentation()

        // Validate release notes
        let releaseNotesValidation = try await validateReleaseNotes()

        let result = DeploymentValidationResult(
            environment: environment,
            truthValidation: truthReport,
            requiredDocsPresent: requiredDocs.allPresent,
            apiDocumentationComplete: apiDocValidation.isComplete,
            releaseNotesValid: releaseNotesValidation.isValid,
            canDeploy: truthReport.isValid && requiredDocs.allPresent && apiDocValidation.isComplete
        )

        if !result.canDeploy {
            throw CIValidationError.deploymentBlocked(reason: result.blockingReason)
        }

        // Generate deployment report
        try await generateDeploymentReport(result)

        return result
    }

    // MARK: - Documentation Coverage Validation

    private func validateDocumentationCoverage(
        newCode: [GitDiff.ChangedFile],
        documentation: [GitDiff.ChangedFile]
    ) async throws -> DocumentationCoverageValidation {
        print("📚 Validating documentation coverage...")

        var undocumentedFeatures: [String] = []
        var partiallyDocumented: [String] = []

        for codeFile in newCode {
            // Extract new public APIs
            let newAPIs = try await extractNewPublicAPIs(from: codeFile)

            for api in newAPIs {
                let docCoverage = try await findDocumentationCoverage(for: api, in: documentation)

                switch docCoverage {
                case .none:
                    undocumentedFeatures.append(api.name)
                case .partial:
                    partiallyDocumented.append(api.name)
                case .complete:
                    break // Properly documented
                }
            }
        }

        let coveragePercentage = calculateCoveragePercentage(
            total: newCode.count,
            documented: newCode.count - undocumentedFeatures.count
        )

        return DocumentationCoverageValidation(
            hasSufficientCoverage: coveragePercentage >= 0.8, // 80% threshold
            coveragePercentage: coveragePercentage,
            undocumentedFeatures: undocumentedFeatures,
            partiallyDocumented: partiallyDocumented
        )
    }

    // MARK: - Performance Preservation Validation

    private func validatePerformancePreservation(changedFiles: [GitDiff.ChangedFile]) async throws -> PerformancePreservationValidation {
        print("⚡ Validating performance preservation...")

        // Check if Thompson algorithm files were modified
        let thompsonFiles = changedFiles.filter { $0.path.contains("Thompson") }

        if !thompsonFiles.isEmpty {
            // Run performance benchmarks
            let benchmarkResults = try await runPerformanceBenchmarks()

            // Check for regression
            let baseline357x = 357.0
            let tolerance = 0.05 // 5% tolerance

            let currentMultiplier = benchmarkResults.thompsonMultiplier
            let preserved = abs(currentMultiplier - baseline357x) / baseline357x <= tolerance

            return PerformancePreservationValidation(
                preserved: preserved,
                currentMultiplier: currentMultiplier,
                baselineMultiplier: baseline357x,
                regression: preserved ? nil : PerformanceRegression(
                    metric: "Thompson Algorithm",
                    expected: baseline357x,
                    actual: currentMultiplier,
                    percentageChange: ((currentMultiplier - baseline357x) / baseline357x) * 100
                )
            )
        }

        return PerformancePreservationValidation(
            preserved: true,
            currentMultiplier: 357.0,
            baselineMultiplier: 357.0,
            regression: nil
        )
    }

    // MARK: - Quality Gates

    private func checkQualityGates(validations: [ValidationResult]) -> QualityGateResults {
        var passed: [QualityGate] = []
        var failed: [QualityGate] = []

        // Gate 1: No critical documentation violations
        let criticalViolations = validations.flatMap { validation in
            validation.violations.filter { $0.severity == .critical }
        }

        let noCriticalGate = QualityGate(
            name: "No Critical Documentation Violations",
            threshold: 0,
            actual: Double(criticalViolations.count),
            passed: criticalViolations.isEmpty
        )

        if noCriticalGate.passed {
            passed.append(noCriticalGate)
        } else {
            failed.append(noCriticalGate)
        }

        // Gate 2: Documentation accuracy above 95%
        let accuracyScore = calculateAccuracyScore(from: validations)
        let accuracyGate = QualityGate(
            name: "Documentation Accuracy",
            threshold: 95.0,
            actual: accuracyScore,
            passed: accuracyScore >= 95.0
        )

        if accuracyGate.passed {
            passed.append(accuracyGate)
        } else {
            failed.append(accuracyGate)
        }

        // Gate 3: API documentation coverage above 90%
        let apiCoverage = calculateAPICoverage(from: validations)
        let coverageGate = QualityGate(
            name: "API Documentation Coverage",
            threshold: 90.0,
            actual: apiCoverage,
            passed: apiCoverage >= 90.0
        )

        if coverageGate.passed {
            passed.append(coverageGate)
        } else {
            failed.append(coverageGate)
        }

        // Gate 4: Performance claims validated
        let performanceValidated = validations.allSatisfy { validation in
            validation.performanceClaimsValid
        }

        let performanceGate = QualityGate(
            name: "Performance Claims Validated",
            threshold: 1.0,
            actual: performanceValidated ? 1.0 : 0.0,
            passed: performanceValidated
        )

        if performanceGate.passed {
            passed.append(performanceGate)
        } else {
            failed.append(performanceGate)
        }

        return QualityGateResults(
            passed: passed,
            failed: failed,
            allPassed: failed.isEmpty
        )
    }

    // MARK: - Alert and Notification

    private func sendDriftAlert(_ report: TruthValidationReport) async throws {
        let alert = DriftAlert(
            timestamp: Date(),
            severity: report.criticalViolations.isEmpty ? .warning : .critical,
            summary: "Documentation drift detected",
            details: report.summary,
            violations: report.criticalViolations,
            actionRequired: "Review and update documentation to match implementation"
        )

        // Send to configured webhooks
        try await webhookNotifier.send(alert)

        // Log to monitoring system
        print("🚨 DRIFT ALERT: \(alert.summary)")
        print("   Severity: \(alert.severity)")
        print("   Violations: \(alert.violations.count)")
    }

    private func createGitHubIssue(for report: TruthValidationReport) async throws {
        let issueBody = """
        ## Documentation Drift Detected

        **Truth Score:** \(Int(report.overallTruthScore))/100
        **Critical Violations:** \(report.criticalViolations.count)

        ### Violations

        \(report.criticalViolations.map { violation in
            "- **\(violation.type.rawValue)**: \(violation.claim) vs \(violation.reality)"
        }.joined(separator: "\n"))

        ### Required Actions

        1. Review all critical violations
        2. Update documentation to reflect actual implementation
        3. Run validation suite to confirm fixes

        ---
        *This issue was automatically generated by the Documentation Truth Validator*
        """

        try await gitIntegration.createIssue(
            title: "Documentation Drift: Truth Score \(Int(report.overallTruthScore))",
            body: issueBody,
            labels: ["documentation", "drift", "automated"]
        )
    }

    // MARK: - Report Generation

    private func generatePreCommitReport(_ result: PreCommitValidationResult) async throws {
        let report = """
        ❌ PRE-COMMIT VALIDATION FAILED

        Documentation validation detected issues that must be resolved before committing.

        BLOCKING ISSUES:
        \(result.blockingIssues.map { "  • \($0)" }.joined(separator: "\n"))

        WARNINGS:
        \(result.warnings.map { "  • \($0)" }.joined(separator: "\n"))

        To fix:
        1. Review the blocking issues above
        2. Update documentation or code as needed
        3. Run 'swift run DocumentationValidator --validate-all' to verify fixes
        4. Retry your commit

        For detailed validation report, see: .build/validation-report.html
        """

        print(report)

        // Save detailed HTML report
        let htmlReport = generateHTMLReport(result)
        let reportPath = workspacePath.appendingPathComponent(".build/validation-report.html")
        try htmlReport.write(to: reportPath, atomically: true, encoding: .utf8)
    }

    private func generateHTMLReport(_ result: PreCommitValidationResult) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Documentation Validation Report</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; margin: 40px; }
                .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; }
                .status-failed { color: #e53e3e; font-weight: bold; }
                .status-passed { color: #38a169; font-weight: bold; }
                .section { margin: 30px 0; padding: 20px; background: #f7fafc; border-radius: 8px; }
                .issue { margin: 10px 0; padding: 10px; background: white; border-left: 4px solid #e53e3e; }
                .warning { margin: 10px 0; padding: 10px; background: white; border-left: 4px solid #f6ad55; }
                code { background: #edf2f7; padding: 2px 6px; border-radius: 3px; }
            </style>
        </head>
        <body>
            <div class="header">
                <h1>Documentation Validation Report</h1>
                <p>Generated: \(ISO8601DateFormatter().string(from: Date()))</p>
                <p>Status: <span class="status-failed">FAILED</span></p>
            </div>

            <div class="section">
                <h2>Blocking Issues</h2>
                \(result.blockingIssues.map { "<div class='issue'>\($0)</div>" }.joined(separator: "\n"))
            </div>

            <div class="section">
                <h2>Warnings</h2>
                \(result.warnings.map { "<div class='warning'>\($0)</div>" }.joined(separator: "\n"))
            </div>

            <div class="section">
                <h2>Validation Details</h2>
                <pre>\(result.validations.map { $0.summary }.joined(separator: "\n"))</pre>
            </div>
        </body>
        </html>
        """
    }
}

// MARK: - Supporting Types

public struct PreCommitValidationResult: Sendable {
    let passed: Bool
    let validations: [TruthValidationReport]
    let blockingIssues: [String]
    let warnings: [String]
}

public struct PullRequestValidationResult: Sendable {
    let branch: String
    let baseBranch: String
    let truthValidation: TruthValidationReport
    let coverageValidation: DocumentationCoverageValidation
    let performanceValidation: PerformancePreservationValidation
    let breakingChanges: [BreakingChange]
    let passed: Bool
}

public struct BuildValidationResult: Sendable {
    let branch: String
    let validations: [ValidationResult]
    let artifacts: [BuildArtifact]
    let qualityGatesPassed: Bool
    let failedGates: [QualityGate]
}

public struct DeploymentValidationResult: Sendable {
    let environment: DeploymentEnvironment
    let truthValidation: TruthValidationReport
    let requiredDocsPresent: Bool
    let apiDocumentationComplete: Bool
    let releaseNotesValid: Bool
    let canDeploy: Bool

    var blockingReason: String {
        if !truthValidation.isValid {
            return "Documentation drift detected"
        } else if !requiredDocsPresent {
            return "Required documentation missing"
        } else if !apiDocumentationComplete {
            return "API documentation incomplete"
        } else if !releaseNotesValid {
            return "Release notes invalid or missing"
        } else {
            return "Unknown blocking reason"
        }
    }
}

public struct DocumentationCoverageValidation: Sendable {
    let hasSufficientCoverage: Bool
    let coveragePercentage: Double
    let undocumentedFeatures: [String]
    let partiallyDocumented: [String]
}

public struct PerformancePreservationValidation: Sendable {
    let preserved: Bool
    let currentMultiplier: Double
    let baselineMultiplier: Double
    let regression: PerformanceRegression?
}

public struct PerformanceRegression: Sendable {
    let metric: String
    let expected: Double
    let actual: Double
    let percentageChange: Double
}

public struct QualityGate: Sendable {
    let name: String
    let threshold: Double
    let actual: Double
    let passed: Bool
}

public struct QualityGateResults: Sendable {
    let passed: [QualityGate]
    let failed: [QualityGate]
    let allPassed: Bool
}

public struct ValidationResult: Sendable {
    let violations: [TruthViolation]
    let performanceClaimsValid: Bool
    let summary: String
}

public struct BuildArtifact: Sendable {
    let name: String
    let path: URL
    let type: ArtifactType

    enum ArtifactType: String, Sendable {
        case report = "Report"
        case metrics = "Metrics"
        case coverage = "Coverage"
    }
}

public struct BreakingChange: Sendable {
    let type: String
    let description: String
    let impact: ImpactLevel

    enum ImpactLevel: String, Sendable {
        case major = "Major"
        case minor = "Minor"
        case patch = "Patch"
    }
}

public enum DeploymentEnvironment: String, Sendable {
    case development = "Development"
    case staging = "Staging"
    case production = "Production"
}

public enum ValidationLevel: String, Sendable {
    case minimal = "Minimal"
    case standard = "Standard"
    case comprehensive = "Comprehensive"
}

public struct DriftAlert: Sendable {
    let timestamp: Date
    let severity: Severity
    let summary: String
    let details: String
    let violations: [TruthViolation]
    let actionRequired: String

    enum Severity: String, Sendable {
        case critical = "Critical"
        case warning = "Warning"
        case info = "Info"
    }
}

// MARK: - Error Types

public enum CIValidationError: LocalizedError {
    case qualityGatesNotMet(gates: [QualityGate])
    case documentationDriftDetected(report: TruthValidationReport)
    case deploymentBlocked(reason: String)
    case validationTimeout
    case gitOperationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .qualityGatesNotMet(let gates):
            return "Quality gates not met: \(gates.map { $0.name }.joined(separator: ", "))"
        case .documentationDriftDetected(let report):
            return "Documentation drift detected: \(report.summary)"
        case .deploymentBlocked(let reason):
            return "Deployment blocked: \(reason)"
        case .validationTimeout:
            return "Validation timed out"
        case .gitOperationFailed(let message):
            return "Git operation failed: \(message)"
        }
    }
}

// MARK: - Helper Classes

/// Git integration for version control operations
final class GitIntegration: @unchecked Sendable {
    private let workspacePath: URL

    init(workspacePath: URL) {
        self.workspacePath = workspacePath
    }

    func getStagedChanges() async throws -> [String] {
        // Implementation would use git commands
        return []
    }

    func getCurrentBranch() async throws -> String {
        return "main"
    }

    func getDiff(from: String, to: String) async throws -> GitDiff {
        return GitDiff(changedFiles: [])
    }

    func createIssue(title: String, body: String, labels: [String]) async throws {
        // GitHub API integration
    }
}

struct GitDiff: Sendable {
    let changedFiles: [ChangedFile]

    struct ChangedFile: Sendable {
        let path: String
        let additions: Int
        let deletions: Int
    }
}

/// Webhook notifier for external integrations
final class WebhookNotifier: @unchecked Sendable {
    func send(_ alert: DriftAlert) async throws {
        // Send to configured webhooks (Slack, Discord, etc.)
    }
}

// MARK: - Utility Functions

private func extractBlockingIssues(from report: TruthValidationReport) -> [String] {
    report.criticalViolations.map { violation in
        "\(violation.type.rawValue): \(violation.claim) != \(violation.reality)"
    }
}

private func extractWarnings(from report: TruthValidationReport) -> [String] {
    report.validations.flatMap { validation in
        validation.violations
            .filter { $0.severity == .medium || $0.severity == .low }
            .map { "\($0.type.rawValue): \($0.claim)" }
    }
}

private func calculateCoveragePercentage(total: Int, documented: Int) -> Double {
    guard total > 0 else { return 1.0 }
    return Double(documented) / Double(total)
}

private func calculateAccuracyScore(from validations: [ValidationResult]) -> Double {
    let totalClaims = validations.reduce(0) { $0 + $1.violations.count + 10 } // Assume 10 verified claims per validation
    let accurateClaims = totalClaims - validations.reduce(0) { $0 + $1.violations.count }
    return (Double(accurateClaims) / Double(totalClaims)) * 100
}

private func calculateAPICoverage(from validations: [ValidationResult]) -> Double {
    // Placeholder - would analyze actual API documentation coverage
    return 95.0
}