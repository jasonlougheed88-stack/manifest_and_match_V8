import Foundation
import SwiftSyntax
import SwiftParser
import OSLog

// MARK: - Real-time Development Validation Framework
// ManifestAndMatchV7 Live Documentation Validation
// Provides immediate feedback during development to prevent drift

/// Real-time validator that runs during development to catch drift immediately
@MainActor
public final class RealtimeDevelopmentValidator: Sendable {

    // MARK: - Properties

    private let workspacePath: URL
    private let fileWatcher: FileSystemWatcher
    private let incrementalValidator: IncrementalValidator
    private let feedbackRenderer: DeveloperFeedbackRenderer
    private let validationCache: ValidationCache
    private let logger = Logger(subsystem: "com.manifestandmatch.v7", category: "RealtimeValidator")

    // Cache for incremental validation
    private var lastValidationState: ValidationState?
    private var pendingValidations: Set<URL> = []

    // MARK: - Initialization

    public init(workspacePath: URL) {
        self.workspacePath = workspacePath
        self.fileWatcher = FileSystemWatcher(paths: [workspacePath])
        self.incrementalValidator = IncrementalValidator(workspacePath: workspacePath)
        self.feedbackRenderer = DeveloperFeedbackRenderer()
        self.validationCache = ValidationCache()
    }

    // MARK: - Real-time Monitoring

    /// Starts real-time monitoring of documentation and code changes
    public func startRealtimeMonitoring() async throws {
        logger.info("🚀 Starting real-time documentation validation...")

        // Set up file system watching
        fileWatcher.startWatching { [weak self] changedPaths in
            guard let self = self else { return }

            Task {
                await self.handleFileChanges(changedPaths)
            }
        }

        // Initial validation
        try await performInitialValidation()

        // Start incremental validation loop
        Task {
            try await startIncrementalValidationLoop()
        }

        logger.info("✅ Real-time monitoring active")
    }

    // MARK: - File Change Handling

    private func handleFileChanges(_ paths: [URL]) async {
        for path in paths {
            // Filter relevant files
            if path.pathExtension == "swift" || path.pathExtension == "md" {
                pendingValidations.insert(path)

                // Debounce validations
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 500ms debounce
                    await validatePendingFiles()
                }
            }
        }
    }

    private func validatePendingFiles() async {
        guard !pendingValidations.isEmpty else { return }

        let files = Array(pendingValidations)
        pendingValidations.removeAll()

        for file in files {
            await validateSingleFile(file)
        }
    }

    // MARK: - Single File Validation

    private func validateSingleFile(_ file: URL) async {
        logger.debug("Validating file: \(file.lastPathComponent)")

        do {
            if file.pathExtension == "swift" {
                // Code file changed - check if documentation needs update
                let validation = try await validateCodeFile(file)
                await displayValidationFeedback(validation, for: file)
            } else if file.pathExtension == "md" {
                // Documentation file changed - verify claims
                let validation = try await validateDocumentationFile(file)
                await displayValidationFeedback(validation, for: file)
            }
        } catch {
            logger.error("Validation error for \(file.lastPathComponent): \(error)")
        }
    }

    // MARK: - Code File Validation

    private func validateCodeFile(_ file: URL) async throws -> FileValidation {
        let startTime = Date()

        // Parse Swift file
        let sourceCode = try String(contentsOf: file)
        let syntaxTree = Parser.parse(source: sourceCode)

        // Extract public APIs
        let publicAPIs = extractPublicAPIs(from: syntaxTree)

        // Check if documentation exists for these APIs
        var undocumentedAPIs: [String] = []
        var outdatedDocumentation: [DocumentationIssue] = []

        for api in publicAPIs {
            let docStatus = try await checkDocumentationStatus(for: api)

            switch docStatus {
            case .missing:
                undocumentedAPIs.append(api.name)
            case .outdated(let issue):
                outdatedDocumentation.append(issue)
            case .current:
                break // Documentation is up to date
            }
        }

        // Check for performance-critical code changes
        let performanceImpact = try await analyzePerformanceImpact(of: file, content: sourceCode)

        // Validate architectural patterns
        let patternViolations = detectPatternViolations(in: syntaxTree)

        let validationTime = Date().timeIntervalSince(startTime)

        return FileValidation(
            file: file,
            type: .code,
            timestamp: Date(),
            validationTime: validationTime,
            issues: createIssues(
                undocumentedAPIs: undocumentedAPIs,
                outdatedDocs: outdatedDocumentation,
                performanceImpact: performanceImpact,
                patternViolations: patternViolations
            ),
            suggestions: generateSuggestions(
                for: undocumentedAPIs,
                outdated: outdatedDocumentation
            )
        )
    }

    // MARK: - Documentation File Validation

    private func validateDocumentationFile(_ file: URL) async throws -> FileValidation {
        let startTime = Date()

        // Parse documentation
        let content = try String(contentsOf: file)
        let documentationClaims = extractDocumentationClaims(from: content)

        var issues: [ValidationIssue] = []

        // Validate each claim
        for claim in documentationClaims {
            let isValid = try await validateClaim(claim)

            if !isValid {
                issues.append(ValidationIssue(
                    severity: determineSeverity(for: claim),
                    type: .inaccurateClaim,
                    description: "Claim '\(claim.statement)' is not accurate",
                    location: ValidationLocation(
                        file: file.lastPathComponent,
                        line: claim.line,
                        column: claim.column
                    ),
                    suggestedFix: generateFixForClaim(claim)
                ))
            }
        }

        // Check code examples
        let codeExamples = extractCodeExamples(from: content)
        for example in codeExamples {
            let compilationResult = try await compileCodeExample(example)

            if !compilationResult.success {
                issues.append(ValidationIssue(
                    severity: .error,
                    type: .codeExampleFailure,
                    description: "Code example doesn't compile: \(compilationResult.error ?? "Unknown error")",
                    location: ValidationLocation(
                        file: file.lastPathComponent,
                        line: example.startLine,
                        column: 1
                    ),
                    suggestedFix: "Fix compilation errors in code example"
                ))
            }
        }

        // Check for broken links
        let links = extractLinks(from: content)
        for link in links {
            if !(try await validateLink(link)) {
                issues.append(ValidationIssue(
                    severity: .warning,
                    type: .brokenLink,
                    description: "Broken link: \(link.url)",
                    location: ValidationLocation(
                        file: file.lastPathComponent,
                        line: link.line,
                        column: link.column
                    ),
                    suggestedFix: "Update or remove broken link"
                ))
            }
        }

        let validationTime = Date().timeIntervalSince(startTime)

        return FileValidation(
            file: file,
            type: .documentation,
            timestamp: Date(),
            validationTime: validationTime,
            issues: issues,
            suggestions: generateDocumentationSuggestions(for: issues)
        )
    }

    // MARK: - Developer Feedback

    private func displayValidationFeedback(_ validation: FileValidation, for file: URL) async {
        // Check if there are any issues
        guard !validation.issues.isEmpty else {
            // Show success briefly
            await feedbackRenderer.showSuccess(for: file)
            return
        }

        // Group issues by severity
        let criticalIssues = validation.issues.filter { $0.severity == .error }
        let warnings = validation.issues.filter { $0.severity == .warning }
        let info = validation.issues.filter { $0.severity == .info }

        // Render feedback based on severity
        if !criticalIssues.isEmpty {
            await feedbackRenderer.showError(
                title: "Documentation Validation Failed",
                subtitle: "\(criticalIssues.count) critical issues in \(file.lastPathComponent)",
                issues: criticalIssues
            )
        } else if !warnings.isEmpty {
            await feedbackRenderer.showWarning(
                title: "Documentation Warnings",
                subtitle: "\(warnings.count) warnings in \(file.lastPathComponent)",
                issues: warnings
            )
        } else if !info.isEmpty {
            await feedbackRenderer.showInfo(
                title: "Documentation Suggestions",
                subtitle: "\(info.count) suggestions for \(file.lastPathComponent)",
                issues: info
            )
        }

        // Update IDE markers
        await updateIDEMarkers(validation)

        // Log to console with formatting
        logValidationResult(validation)
    }

    // MARK: - IDE Integration

    private func updateIDEMarkers(_ validation: FileValidation) async {
        // This would integrate with IDE extensions (VS Code, Xcode)
        // to show inline errors and warnings

        for issue in validation.issues {
            let marker = IDEMarker(
                file: validation.file,
                line: issue.location.line,
                column: issue.location.column,
                severity: issue.severity,
                message: issue.description,
                quickFix: issue.suggestedFix
            )

            await IDEIntegration.shared.addMarker(marker)
        }
    }

    // MARK: - Incremental Validation

    private func startIncrementalValidationLoop() async throws {
        while !Task.isCancelled {
            do {
                // Wait for next validation cycle
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds

                // Perform incremental validation
                let changes = try await detectIncrementalChanges()

                if !changes.isEmpty {
                    let validationResult = try await incrementalValidator.validate(changes)

                    // Update validation state
                    lastValidationState = validationResult.newState

                    // Display summary if issues found
                    if validationResult.hasIssues {
                        await displayIncrementalValidationSummary(validationResult)
                    }
                }
            } catch {
                logger.error("Incremental validation error: \(error)")
            }
        }
    }

    private func detectIncrementalChanges() async throws -> [IncrementalChange] {
        // Compare current state with last validation state
        guard let lastState = lastValidationState else {
            return []
        }

        let currentState = try await captureCurrentState()
        return compareStates(last: lastState, current: currentState)
    }

    // MARK: - Initial Validation

    private func performInitialValidation() async throws {
        logger.info("Running initial validation...")

        let allFiles = try findAllRelevantFiles()
        var totalIssues = 0

        for file in allFiles {
            let validation = file.pathExtension == "swift"
                ? try await validateCodeFile(file)
                : try await validateDocumentationFile(file)

            totalIssues += validation.issues.count

            // Cache validation result
            validationCache.store(validation, for: file)
        }

        // Display initial summary
        await feedbackRenderer.showSummary(
            title: "Initial Validation Complete",
            filesValidated: allFiles.count,
            issuesFound: totalIssues
        )

        // Capture initial state
        lastValidationState = try await captureCurrentState()
    }

    // MARK: - Performance Impact Analysis

    private func analyzePerformanceImpact(of file: URL, content: String) async throws -> PerformanceImpact? {
        // Check if file contains Thompson algorithm code
        if content.contains("Thompson") || file.path.contains("Thompson") {
            // This is critical performance code
            let modifiedMethods = extractModifiedMethods(from: content)

            for method in modifiedMethods {
                if method.contains("match") || method.contains("compile") || method.contains("execute") {
                    return PerformanceImpact(
                        severity: .high,
                        description: "Changes to Thompson algorithm implementation detected",
                        affectedMetric: "357x performance multiplier",
                        requiresBenchmark: true
                    )
                }
            }
        }

        // Check for other performance-sensitive changes
        if content.contains("@MainActor") && content.contains("async") {
            let asyncOperations = countAsyncOperations(in: content)
            if asyncOperations > 10 {
                return PerformanceImpact(
                    severity: .medium,
                    description: "High number of async operations may impact performance",
                    affectedMetric: "UI responsiveness",
                    requiresBenchmark: false
                )
            }
        }

        return nil
    }

    // MARK: - Console Logging

    private func logValidationResult(_ validation: FileValidation) {
        let fileName = validation.file.lastPathComponent

        if validation.issues.isEmpty {
            print("✅ \(fileName) - No issues found (\(String(format: "%.2f", validation.validationTime * 1000))ms)")
        } else {
            print("⚠️  \(fileName) - \(validation.issues.count) issues found:")

            for issue in validation.issues {
                let icon = issue.severity == .error ? "❌" : (issue.severity == .warning ? "⚠️" : "ℹ️")
                print("  \(icon) Line \(issue.location.line): \(issue.description)")

                if let fix = issue.suggestedFix {
                    print("     💡 Suggestion: \(fix)")
                }
            }
        }

        if !validation.suggestions.isEmpty {
            print("  💡 Suggestions:")
            for suggestion in validation.suggestions {
                print("    • \(suggestion)")
            }
        }
    }
}

// MARK: - Supporting Types

public struct FileValidation: Sendable {
    enum FileType {
        case code
        case documentation
    }

    let file: URL
    let type: FileType
    let timestamp: Date
    let validationTime: TimeInterval
    let issues: [ValidationIssue]
    let suggestions: [String]
}

public struct ValidationIssue: Sendable {
    enum Severity: String {
        case error = "Error"
        case warning = "Warning"
        case info = "Info"
    }

    enum IssueType {
        case undocumentedAPI
        case outdatedDocumentation
        case inaccurateClaim
        case codeExampleFailure
        case brokenLink
        case performanceRisk
        case patternViolation
    }

    let severity: Severity
    let type: IssueType
    let description: String
    let location: ValidationLocation
    let suggestedFix: String?
}

public struct ValidationLocation: Sendable {
    let file: String
    let line: Int
    let column: Int
}

public struct DocumentationIssue: Sendable {
    let api: String
    let currentDoc: String
    let requiredUpdate: String
}

public struct PerformanceImpact: Sendable {
    enum Severity {
        case low
        case medium
        case high
        case critical
    }

    let severity: Severity
    let description: String
    let affectedMetric: String
    let requiresBenchmark: Bool
}

public struct ValidationState: Sendable {
    let timestamp: Date
    let fileStates: [URL: FileState]
    let overallHealth: Double
}

public struct FileState: Sendable {
    let checksum: String
    let lastValidation: Date
    let issueCount: Int
}

public struct IncrementalChange: Sendable {
    let file: URL
    let changeType: ChangeType

    enum ChangeType {
        case modified
        case added
        case deleted
    }
}

public struct IncrementalValidationResult: Sendable {
    let changes: [IncrementalChange]
    let validations: [FileValidation]
    let newState: ValidationState
    let hasIssues: Bool
}

// MARK: - Helper Classes

/// File system watcher for monitoring changes
final class FileSystemWatcher: @unchecked Sendable {
    private let paths: [URL]
    private var watchers: [DispatchSourceFileSystemObject] = []
    private let queue = DispatchQueue(label: "com.manifestandmatch.filewatcher")

    init(paths: [URL]) {
        self.paths = paths
    }

    func startWatching(onChange: @escaping ([URL]) -> Void) {
        for path in paths {
            let fileDescriptor = open(path.path, O_EVTONLY)
            guard fileDescriptor >= 0 else { continue }

            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fileDescriptor,
                eventMask: [.write, .delete, .rename],
                queue: queue
            )

            source.setEventHandler { [weak self] in
                self?.handleFileChange(at: path, onChange: onChange)
            }

            source.setCancelHandler {
                close(fileDescriptor)
            }

            source.resume()
            watchers.append(source)
        }
    }

    private func handleFileChange(at path: URL, onChange: ([URL]) -> Void) {
        // Scan for changed files
        let changedFiles = scanForChanges(at: path)
        onChange(changedFiles)
    }

    private func scanForChanges(at path: URL) -> [URL] {
        // Implementation would scan directory for modified files
        return []
    }

    func stopWatching() {
        watchers.forEach { $0.cancel() }
        watchers.removeAll()
    }
}

/// Incremental validator for efficient validation
final class IncrementalValidator: @unchecked Sendable {
    private let workspacePath: URL

    init(workspacePath: URL) {
        self.workspacePath = workspacePath
    }

    func validate(_ changes: [IncrementalChange]) async throws -> IncrementalValidationResult {
        var validations: [FileValidation] = []

        for change in changes {
            // Validate only changed files
            // Implementation would perform targeted validation
        }

        let newState = ValidationState(
            timestamp: Date(),
            fileStates: [:],
            overallHealth: 100.0
        )

        return IncrementalValidationResult(
            changes: changes,
            validations: validations,
            newState: newState,
            hasIssues: !validations.allSatisfy { $0.issues.isEmpty }
        )
    }
}

/// Developer feedback renderer for displaying validation results
@MainActor
final class DeveloperFeedbackRenderer: Sendable {

    func showSuccess(for file: URL) async {
        // Show brief success notification
        print("✅ \(file.lastPathComponent) validated successfully")
    }

    func showError(title: String, subtitle: String, issues: [ValidationIssue]) async {
        print("❌ \(title)")
        print("   \(subtitle)")
        for issue in issues {
            print("   • \(issue.description)")
        }
    }

    func showWarning(title: String, subtitle: String, issues: [ValidationIssue]) async {
        print("⚠️  \(title)")
        print("   \(subtitle)")
        for issue in issues {
            print("   • \(issue.description)")
        }
    }

    func showInfo(title: String, subtitle: String, issues: [ValidationIssue]) async {
        print("ℹ️  \(title)")
        print("   \(subtitle)")
        for issue in issues {
            print("   • \(issue.description)")
        }
    }

    func showSummary(title: String, filesValidated: Int, issuesFound: Int) async {
        print("""

        =====================================
        \(title)
        =====================================
        Files Validated: \(filesValidated)
        Issues Found: \(issuesFound)
        Status: \(issuesFound == 0 ? "✅ All Clear" : "⚠️  Issues Detected")
        =====================================

        """)
    }
}

/// Validation cache for performance
final class ValidationCache: @unchecked Sendable {
    private var cache: [URL: FileValidation] = [:]

    func store(_ validation: FileValidation, for file: URL) {
        cache[file] = validation
    }

    func retrieve(for file: URL) -> FileValidation? {
        cache[file]
    }

    func invalidate(for file: URL) {
        cache.removeValue(forKey: file)
    }
}

/// IDE integration for displaying markers
@MainActor
final class IDEIntegration {
    static let shared = IDEIntegration()

    private var markers: [IDEMarker] = []

    func addMarker(_ marker: IDEMarker) async {
        markers.append(marker)
        // Would integrate with IDE extensions
    }

    func clearMarkers(for file: URL) async {
        markers.removeAll { $0.file == file }
    }
}

struct IDEMarker: Sendable {
    let file: URL
    let line: Int
    let column: Int
    let severity: ValidationIssue.Severity
    let message: String
    let quickFix: String?
}

// MARK: - Utility Functions

private func extractPublicAPIs(from syntaxTree: SourceFileSyntax) -> [API] {
    // Parse syntax tree for public APIs
    return []
}

private func extractDocumentationClaims(from content: String) -> [DocumentationClaim] {
    // Extract claims from documentation
    return []
}

private func extractCodeExamples(from content: String) -> [CodeExample] {
    // Extract code examples from markdown
    return []
}

private func extractLinks(from content: String) -> [DocumentationLink] {
    // Extract links from documentation
    return []
}

private func extractModifiedMethods(from content: String) -> [String] {
    // Extract method signatures
    return []
}

private func countAsyncOperations(in content: String) -> Int {
    // Count async operations
    return 0
}

private func detectPatternViolations(in syntaxTree: SourceFileSyntax) -> [String] {
    // Detect architectural pattern violations
    return []
}

// Supporting structs for extraction functions
struct API: Sendable {
    let name: String
    let type: APIType
    let signature: String

    enum APIType {
        case `class`
        case `struct`
        case function
        case property
    }
}

struct DocumentationClaim: Sendable {
    let statement: String
    let line: Int
    let column: Int
}

struct CodeExample: Sendable {
    let code: String
    let language: String
    let startLine: Int
}

struct DocumentationLink: Sendable {
    let url: String
    let line: Int
    let column: Int
}

struct CompilationResult: Sendable {
    let success: Bool
    let error: String?
}