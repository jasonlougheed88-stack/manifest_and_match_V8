# Interface Contract Standards & Troubleshooting Guide
*Concrete Implementation Guidance for ManifestAndMatchV7*

**Status**: Based on actual compilation failures and working patterns | **Last Updated**: October 2025

---

## 🎯 OVERVIEW

This document provides **concrete, actionable guidance** for implementing and maintaining interface contracts across ManifestAndMatchV7 packages. All examples are based on **actual working patterns** identified in the codebase and **real compilation failures** that must be fixed.

---

## 🚨 COMMON INTERFACE CONTRACT VIOLATIONS & FIXES

### 1. Cross-Package Type Access Failures

**❌ CURRENT PROBLEM** - Found in V7UI attempting to access V7Performance types:
```swift
// In V7UI/Sources/V7UI/SomeView.swift
import V7Performance

struct MetricsView: View {
    let event: ProductionMetricsDashboard.SystemEvent  // ❌ FAILS: Cannot access nested type
    //                                    ^^^^^^^^^^^
    //                                    Error: 'SystemEvent' is not a member type of class 'ProductionMetricsDashboard'

    var body: some View {
        Text("Event: \(event.description)")
    }
}
```

**✅ SOLUTION** - Move types to top-level and make them properly public:

```swift
// In V7Performance/Sources/V7Performance/PublicTypes.swift
// CREATE THIS FILE with top-level public types:

import Foundation

/// System event for cross-package monitoring interface
/// Designed for V7UI consumption via protocol-based access
public struct SystemEvent: Sendable, Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let type: EventType
    public let description: String
    public let severity: EventSeverity
    public let metadata: [String: String]

    public init(
        type: EventType,
        description: String,
        severity: EventSeverity = .info,
        metadata: [String: String] = [:]
    ) {
        self.type = type
        self.description = description
        self.severity = severity
        self.metadata = metadata
        self.timestamp = Date()
    }
}

public enum EventType: String, Sendable, CaseIterable {
    case performance = "Performance"
    case memory = "Memory"
    case api = "API"
    case thompsonSampling = "Thompson Sampling"
    case networkError = "Network Error"
}

public enum EventSeverity: String, Sendable, CaseIterable {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
    case critical = "Critical"
}

/// API health status for monitoring dashboard
public struct APIHealthStatus: Sendable {
    public let sourceId: String
    public let status: HealthState
    public let lastCheck: Date
    public let responseTimeMs: Double
    public let errorCount: Int
    public let successRate: Double

    public init(
        sourceId: String,
        status: HealthState,
        responseTimeMs: Double,
        errorCount: Int = 0,
        successRate: Double = 1.0
    ) {
        self.sourceId = sourceId
        self.status = status
        self.responseTimeMs = responseTimeMs
        self.errorCount = errorCount
        self.successRate = successRate
        self.lastCheck = Date()
    }
}

public enum HealthState: String, Sendable, CaseIterable {
    case healthy = "Healthy"
    case degraded = "Degraded"
    case unhealthy = "Unhealthy"
    case unknown = "Unknown"
}

/// Timestamped value for metrics tracking
public struct TimestampedValue: Sendable {
    public let timestamp: Date
    public let value: Double
    public let metric: String
    public let unit: String?

    public init(value: Double, metric: String, unit: String? = nil) {
        self.value = value
        self.metric = metric
        self.unit = unit
        self.timestamp = Date()
    }
}
```

**✅ CONSUMER UPDATE** - Fix V7UI to use top-level types:
```swift
// In V7UI/Sources/V7UI/MetricsView.swift
import V7Performance

struct MetricsView: View {
    let event: SystemEvent  // ✅ NOW WORKS: Top-level public type
    let healthStatus: APIHealthStatus  // ✅ NOW WORKS: Top-level public type

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Event: \(event.description)")
            Text("Severity: \(event.severity.rawValue)")
            Text("Source: \(healthStatus.sourceId)")
            Text("Status: \(healthStatus.status.rawValue)")
        }
    }
}
```

### 2. Sendable Conformance Violations

**❌ CURRENT PROBLEM** - Found in cross-package type sharing:
```swift
// Compilation error when StrictConcurrency is enabled:
// error: class 'UserInteractionState' does not conform to the 'Sendable' protocol

@Observable
public final class UserInteractionState {  // ❌ Missing Sendable conformance
    public var currentCardIndex: Int = 0
    public var swipeDirection: SwipeDirection?
    // ... more properties
}
```

**✅ SOLUTION** - Add proper Sendable conformance:

```swift
// In V7Core/Sources/V7Core/StateManagement/UserInteractionState.swift

import Foundation
import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
@Observable
public final class UserInteractionState: Sendable {  // ✅ Add Sendable conformance

    // MARK: - Thread-Safe Properties
    // @Observable automatically handles thread safety for these properties
    public var currentCardIndex: Int = 0
    public var swipeDirection: SwipeDirection? = nil
    public var totalSwipes: Int = 0
    public var swipeVelocity: Double = 0.0
    public var lastSwipeTimestamp: Date? = nil

    // MARK: - Computed Properties (Thread-Safe)
    public var hasActiveSwipe: Bool {
        swipeDirection != nil
    }

    public var swipePerformanceRating: SwipePerformance {
        guard totalSwipes > 0 else { return .unknown }

        let velocityThreshold: Double = 500.0  // pixels per second
        return swipeVelocity > velocityThreshold ? .fast : .normal
    }

    // MARK: - Sendable-Compliant Enums
    public enum SwipeDirection: String, Sendable, CaseIterable {
        case left = "Left"
        case right = "Right"
        case up = "Up"
        case down = "Down"
    }

    public enum SwipePerformance: String, Sendable, CaseIterable {
        case fast = "Fast"
        case normal = "Normal"
        case slow = "Slow"
        case unknown = "Unknown"
    }

    // MARK: - Public Interface
    public init() {
        // @Observable classes automatically become Sendable when all stored properties are Sendable
        // or when using built-in Sendable types like Int, Double, String, Date, etc.
    }

    /// Record a swipe action with performance metrics
    public func recordSwipe(direction: SwipeDirection, velocity: Double = 0.0) {
        self.swipeDirection = direction
        self.swipeVelocity = velocity
        self.totalSwipes += 1
        self.lastSwipeTimestamp = Date()
    }

    /// Clear current swipe state
    public func clearSwipe() {
        self.swipeDirection = nil
        self.swipeVelocity = 0.0
    }
}
```

### 3. Platform Availability Mismatches

**❌ CURRENT PROBLEM** - Found in V7Data package:
```swift
// Package.swift specifies iOS 18+ only:
platforms: [
    .iOS(.v18)
]

// But code requires macOS 10.15+ features:
@Published public private(set) var progress: MigrationProgress  // ❌ Requires macOS 10.15+
public func executeMigration() async throws {  // ❌ async/await requires macOS 10.15+
```

**✅ SOLUTION A** - Update Package.swift to include required platforms:
```swift
// In V7Data/Package.swift
let package = Package(
    name: "V7Data",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)  // ✅ Add macOS support for @Published and async/await
    ],
    // ... rest of package definition
)
```

**✅ SOLUTION B** - Use Swift 6 @Observable instead of @Published:
```swift
// In V7Data/Sources/V7Data/Migration/V7MigrationCoordinator.swift

import Foundation
import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
@Observable  // ✅ Use @Observable instead of @Published
public final class V7MigrationCoordinator: Sendable {

    // MARK: - Observable Properties
    public private(set) var progress: MigrationProgress = MigrationProgress()
    public private(set) var currentStep: MigrationStep = .notStarted
    public private(set) var isRunning: Bool = false
    public private(set) var lastError: MigrationError? = nil

    // MARK: - Migration Steps
    public enum MigrationStep: String, Sendable, CaseIterable {
        case notStarted = "Not Started"
        case validatingSource = "Validating Source Data"
        case migratingData = "Migrating Data"
        case validatingTarget = "Validating Migrated Data"
        case completed = "Completed"
        case failed = "Failed"
    }

    public init() {
        // @Observable automatically handles state management
    }

    /// Execute migration from V5.7 to V7 with comprehensive error handling
    public func executeMigration() async throws {
        guard !isRunning else {
            throw MigrationError.alreadyInProgress
        }

        isRunning = true
        currentStep = .validatingSource
        progress.startTime = Date()

        defer {
            isRunning = false
        }

        do {
            try await validateSourceData()
            try await migrateUserData()
            try await validateMigratedData()

            currentStep = .completed
            progress.completionDate = Date()

        } catch {
            currentStep = .failed
            lastError = error as? MigrationError ?? .unknown(error.localizedDescription)
            throw error
        }
    }

    // MARK: - Private Implementation
    private func validateSourceData() async throws {
        progress.currentOperation = "Validating V5.7 data integrity"
        // Implementation details...
    }

    private func migrateUserData() async throws {
        currentStep = .migratingData
        progress.currentOperation = "Migrating user preferences and sacred constants"
        // Implementation details...
    }

    private func validateMigratedData() async throws {
        currentStep = .validatingTarget
        progress.currentOperation = "Validating migrated data consistency"
        // Implementation details...
    }
}

// MARK: - Supporting Types

public struct MigrationProgress: Sendable {
    public var startTime: Date?
    public var completionDate: Date?
    public var currentOperation: String = ""
    public var progressPercentage: Double = 0.0

    public init() {}

    public var isComplete: Bool {
        completionDate != nil
    }

    public var duration: TimeInterval? {
        guard let start = startTime else { return nil }
        let end = completionDate ?? Date()
        return end.timeIntervalSince(start)
    }
}

public enum MigrationError: Error, Sendable {
    case alreadyInProgress
    case sourceDataNotFound
    case sourceDataCorrupted
    case migrationFailed(String)
    case validationFailed(String)
    case unknown(String)

    public var localizedDescription: String {
        switch self {
        case .alreadyInProgress:
            return "Migration is already in progress"
        case .sourceDataNotFound:
            return "V5.7 source data not found"
        case .sourceDataCorrupted:
            return "Source data is corrupted and cannot be migrated"
        case .migrationFailed(let details):
            return "Migration failed: \(details)"
        case .validationFailed(let details):
            return "Data validation failed: \(details)"
        case .unknown(let details):
            return "Unknown migration error: \(details)"
        }
    }
}
```

---

## 📋 INTERFACE CONTRACT IMPLEMENTATION TEMPLATES

### Template 1: Cross-Package Data Types

```swift
// File: [Package]/Sources/[Package]/PublicTypes.swift
// Purpose: Define types that will be consumed by other packages

import Foundation

/// [Description of what this type represents and why it's needed across packages]
/// Consumer packages: [List which packages will import this type]
/// Dependencies: [List any types this depends on from other packages]
public struct [TypeName]: Sendable, Identifiable {

    // MARK: - Required Properties
    public let id = UUID()  // Always include for SwiftUI List compatibility
    public let timestamp: Date  // Always include for debugging and logging

    // MARK: - Core Data Properties
    // Include all properties that consuming packages need access to
    public let [property1]: [Type]
    public let [property2]: [Type]
    public var [property3]: [Type]  // Use var only when consumers need mutability

    // MARK: - Internal Properties (Optional)
    // Properties that should not be exposed to consumers
    let [internalProperty]: [Type]

    // MARK: - Computed Properties
    // Derived values that consumers might need
    public var [computedProperty]: [Type] {
        // Implementation
    }

    // MARK: - Initializer
    public init(
        [property1]: [Type],
        [property2]: [Type],
        [property3]: [Type] = [defaultValue]
    ) {
        self.[property1] = [property1]
        self.[property2] = [property2]
        self.[property3] = [property3]
        self.timestamp = Date()
    }
}

/// Supporting enums must also be public and Sendable
public enum [RelatedEnum]: String, Sendable, CaseIterable {
    case [case1] = "[rawValue1]"
    case [case2] = "[rawValue2]"

    /// Computed properties for business logic
    public var [businessProperty]: [Type] {
        switch self {
        case .[case1]: return [value1]
        case .[case2]: return [value2]
        }
    }
}
```

### Template 2: Cross-Package Protocol Interfaces

```swift
// File: [Package]/Sources/[Package]/Protocols/[ProtocolName].swift
// Purpose: Define protocol interfaces for dependency inversion

import Foundation

/// [Description of what this protocol provides and why it exists]
/// Implementers: [List packages that will implement this protocol]
/// Consumers: [List packages that will depend on this protocol]
@available(iOS 18.0, macOS 15.0, *)
public protocol [ProtocolName]: Sendable {

    // MARK: - Required Properties
    /// System identifier for [purpose]
    var systemIdentifier: String { get }

    /// Current state for [purpose]
    var currentState: [StateType] { get async }

    // MARK: - Required Methods
    /// [Description of what this method does and when to call it]
    /// - Parameters:
    ///   - parameter1: [Description]
    ///   - parameter2: [Description]
    /// - Returns: [Description of return value]
    /// - Throws: [Description of possible errors]
    func [methodName](_ parameter1: [Type], parameter2: [Type]) async throws -> [ReturnType]

    /// [Description of lifecycle method]
    func start() async

    /// [Description of cleanup method]
    func stop() async
}

// MARK: - Protocol Extensions for Default Implementations

@available(iOS 18.0, macOS 15.0, *)
extension [ProtocolName] {

    /// Default implementation of system identifier based on type name
    public var systemIdentifier: String {
        return String(describing: type(of: self))
    }

    /// Helper method with default implementation
    public func [helperMethod]() async -> [Type] {
        // Provide reasonable default that most implementers can use
        // But allow override for custom behavior
    }
}

// MARK: - Registry Pattern for Dependency Injection

/// Registry for [ProtocolName] implementations to support loose coupling
@available(iOS 18.0, macOS 15.0, *)
@MainActor
public final class [ProtocolName]Registry: @unchecked Sendable {

    public static let shared = [ProtocolName]Registry()

    private var implementations: [String: any [ProtocolName]] = [:]
    private var defaultImplementation: (any [ProtocolName])?

    private init() {}

    /// Register an implementation with specific identifier
    public func register(implementation: any [ProtocolName], for identifier: String) {
        implementations[identifier] = implementation
    }

    /// Set the default implementation
    public func setDefault(implementation: any [ProtocolName]) {
        defaultImplementation = implementation
        register(implementation: implementation, for: "default")
    }

    /// Get implementation by identifier
    public func get(for identifier: String) -> (any [ProtocolName])? {
        return implementations[identifier]
    }

    /// Get default implementation
    public func getDefault() -> (any [ProtocolName])? {
        return defaultImplementation
    }
}
```

### Template 3: Package-Level Public Interface

```swift
// File: [Package]/Sources/[Package]/[Package].swift
// Purpose: Main public interface for the package

// Re-export all public types for clean importing
@_exported import struct [Package].PublicTypes.[TypeName1]
@_exported import struct [Package].PublicTypes.[TypeName2]
@_exported import protocol [Package].Protocols.[ProtocolName1]
@_exported import protocol [Package].Protocols.[ProtocolName2]
@_exported import enum [Package].PublicTypes.[EnumName]

// MARK: - Package Configuration

/// Configuration for [Package] package
/// Used by consuming packages to customize behavior
public struct [Package]Configuration: Sendable {

    public let enableDebugLogging: Bool
    public let performanceMonitoringEnabled: Bool
    public let customSettings: [String: String]

    public static let `default` = [Package]Configuration(
        enableDebugLogging: false,
        performanceMonitoringEnabled: true,
        customSettings: [:]
    )

    public init(
        enableDebugLogging: Bool = false,
        performanceMonitoringEnabled: Bool = true,
        customSettings: [String: String] = [:]
    ) {
        self.enableDebugLogging = enableDebugLogging
        self.performanceMonitoringEnabled = performanceMonitoringEnabled
        self.customSettings = customSettings
    }
}

// MARK: - Package Factory/Builder

/// Factory for creating and configuring [Package] components
@available(iOS 18.0, macOS 15.0, *)
public enum [Package]Factory {

    /// Create the main [Package] component with default configuration
    public static func create(configuration: [Package]Configuration = .default) -> [MainComponentType] {
        let component = [MainComponentType](configuration: configuration)

        // Register with global registries if needed
        [ProtocolName]Registry.shared.setDefault(implementation: component)

        return component
    }

    /// Create [Package] component with custom implementation
    public static func create(
        customImplementation: any [ProtocolName],
        configuration: [Package]Configuration = .default
    ) -> [MainComponentType] {
        let component = [MainComponentType](
            customImplementation: customImplementation,
            configuration: configuration
        )
        return component
    }
}
```

---

## 🔧 TROUBLESHOOTING GUIDE

### Compilation Error: "Cannot find type 'X' in scope"

**Symptoms**:
```
error: cannot find 'SystemEvent' in scope
error: cannot find type 'APIHealthStatus' in scope
```

**Diagnosis Steps**:
1. **Check if type is defined as public**: `grep -r "struct SystemEvent" Packages/*/Sources`
2. **Check if type is top-level**: Look for nested types inside classes
3. **Check import statement**: Verify correct package is imported
4. **Check platform availability**: Ensure `@available` annotations match

**Common Fixes**:
```swift
// Fix 1: Move nested type to top-level
// WRONG:
public class Manager {
    public struct SystemEvent { }  // ❌ Nested - hard to access
}

// RIGHT:
public struct SystemEvent { }  // ✅ Top-level - easy to access

// Fix 2: Add proper public modifier
// WRONG:
struct SystemEvent { }  // ❌ Internal by default

// RIGHT:
public struct SystemEvent { }  // ✅ Public for cross-package access

// Fix 3: Add to package's main public interface
// In Package/Sources/Package/Package.swift:
@_exported import struct Package.PublicTypes.SystemEvent
```

### Compilation Error: "Type 'X' does not conform to protocol 'Sendable'"

**Symptoms**:
```
error: class 'UserInteractionState' does not conform to the 'Sendable' protocol
```

**Diagnosis Steps**:
1. **Check class vs struct**: Classes need explicit Sendable conformance
2. **Check property types**: All properties must be Sendable
3. **Check for mutable shared state**: Requires thread-safety mechanisms

**Common Fixes**:
```swift
// Fix 1: Add Sendable conformance to class
public final class UserState: Sendable {  // ✅ Add Sendable
    // All properties must be Sendable types
}

// Fix 2: Use @Observable for automatic Sendable compliance
@Observable
public final class UserState: Sendable {  // ✅ @Observable + Sendable properties
    public var count: Int = 0  // ✅ Int is Sendable
    public var name: String = ""  // ✅ String is Sendable
}

// Fix 3: Use @unchecked Sendable for thread-safe implementations
public final class ThreadSafeCache: @unchecked Sendable {  // ⚠️ Use carefully
    private let lock = NSLock()
    private var storage: [String: Any] = [:]

    public func get(_ key: String) -> Any? {
        lock.withLock { storage[key] }  // ✅ Thread-safe access
    }
}
```

### Compilation Error: "'X' is only available in macOS Y.Z or newer"

**Symptoms**:
```
error: 'Published' is only available in macOS 10.15 or newer
error: concurrency is only available in macOS 10.15.0 or newer
```

**Diagnosis Steps**:
1. **Check Package.swift platforms**: Verify macOS minimum version
2. **Check @available annotations**: Ensure consistency with Package.swift
3. **Consider iOS-only alternatives**: Use @Observable instead of @Published

**Common Fixes**:
```swift
// Fix 1: Add macOS platform support
// In Package.swift:
platforms: [
    .iOS(.v18),
    .macOS(.v14)  // ✅ Add macOS support
]

// Fix 2: Use iOS 18+ alternatives
// WRONG:
@Published var state: State  // ❌ Requires macOS 10.15+

// RIGHT:
@Observable
final class StateManager: Sendable {  // ✅ Works on iOS 18+
    var state: State
}

// Fix 3: Add consistent @available annotations
@available(iOS 18.0, macOS 14.0, *)  // ✅ Match Package.swift platforms
public final class Component {
    // Implementation
}
```

### Runtime Error: "Sacred UI Constants Validation Failed"

**Symptoms**:
```
Assertion failed: Sacred swipe right threshold violated!
```

**Diagnosis Steps**:
1. **Check for accidental modifications**: `grep -r "SacredUI.*=" --include="*.swift" .`
2. **Verify constant values**: Compare against reference implementation
3. **Check for runtime tampering**: Validate before app startup

**Prevention**:
```swift
// Add runtime validation in app startup:
// In App.swift or SceneDelegate:
init() {
    // Validate sacred constants before any UI appears
    SacredValueValidator.validateAll()
}

// Monitor for changes during development:
#if DEBUG
func validateSacredConstantsInDebug() {
    assert(SacredUI.Swipe.rightThreshold == 100, "Sacred constants modified during development!")
    // ... other validations
}
#endif
```

---

## 📊 VALIDATION CHECKLIST

### Pre-Commit Interface Contract Validation

```bash
#!/bin/bash
# Save as: Scripts/validate_interface_contracts.sh

echo "🔍 Validating Interface Contracts..."

# 1. Test that all packages build individually
echo "Testing individual package builds..."
for package in V7Core V7Thompson V7Data V7Services V7Performance V7UI; do
    echo "  Building $package..."
    cd "Packages/$package" || exit 1
    if ! swift build > /dev/null 2>&1; then
        echo "  ❌ $package build FAILED"
        exit 1
    else
        echo "  ✅ $package build succeeded"
    fi
    cd ../..
done

# 2. Test main package integration
echo "Testing main package integration..."
cd ManifestAndMatchV7Package || exit 1
if ! swift build > /dev/null 2>&1; then
    echo "❌ Main package build FAILED"
    exit 1
else
    echo "✅ Main package build succeeded"
fi
cd ..

# 3. Validate Sacred Constants
echo "Validating Sacred Constants..."
if grep -r "SacredUI.*=" --include="*.swift" . | grep -v "let.*SacredUI" | grep -v "static let"; then
    echo "❌ Sacred constants may have been modified!"
    exit 1
else
    echo "✅ Sacred constants validation passed"
fi

# 4. Check StrictConcurrency is enabled
echo "Checking StrictConcurrency compliance..."
disabled_packages=$(grep -r "StrictConcurrency" Packages/*/Package.swift | grep "// Disabled" | wc -l)
if [ "$disabled_packages" -gt 0 ]; then
    echo "❌ $disabled_packages packages have StrictConcurrency disabled"
    exit 1
else
    echo "✅ All packages have StrictConcurrency enabled"
fi

echo "🎉 All interface contract validations passed!"
```

### Post-Build Interface Contract Verification

```swift
// File: Tests/InterfaceContractTests/InterfaceContractValidationTests.swift

import Testing
@testable import V7Core
@testable import V7Thompson
@testable import V7Data
@testable import V7Services
@testable import V7Performance
@testable import V7UI

@Test("All packages can be imported together without conflicts")
func testCrossPackageImports() async throws {
    // This test verifies that all packages can be imported simultaneously
    // without type conflicts or circular dependencies

    // Should be able to create instances of key types from each package
    let coreState = AppState()
    let thompsonEngine = ThompsonSamplingEngine()
    let performanceMonitor = PerformanceMonitor()

    // Should be able to use cross-package protocols
    let monitor: PerformanceMonitorProtocol = performanceMonitor
    let systemId = monitor.systemIdentifier

    #expect(!systemId.isEmpty)
}

@Test("Sacred UI constants are immutable and correct")
func testSacredUIConstantsIntegrity() async throws {
    // Validate all sacred constants have correct values
    #expect(SacredUI.Swipe.rightThreshold == 100.0)
    #expect(SacredUI.Swipe.leftThreshold == -100.0)
    #expect(SacredUI.Swipe.upThreshold == -80.0)
    #expect(SacredUI.Animation.springResponse == 0.6)
    #expect(SacredUI.Animation.springDamping == 0.8)

    // Validate performance budgets
    #expect(PerformanceBudget.thompsonSamplingTarget == 0.010)
    #expect(PerformanceBudget.memoryBaselineMB == 200.0)
}

@Test("Cross-package type access works correctly")
func testCrossPackageTypeAccess() async throws {
    // Test that V7UI can access V7Performance types
    let event = SystemEvent(
        type: .performance,
        description: "Test event",
        severity: .info
    )

    let healthStatus = APIHealthStatus(
        sourceId: "test-source",
        status: .healthy,
        responseTimeMs: 150.0
    )

    let timestampedValue = TimestampedValue(
        value: 42.0,
        metric: "test-metric"
    )

    // Verify types are properly Sendable
    #expect(event is Sendable)
    #expect(healthStatus is Sendable)
    #expect(timestampedValue is Sendable)
}

@Test("Protocol registries work correctly")
func testProtocolRegistries() async throws {
    // Test that registries can register and retrieve implementations
    let registry = PerformanceMonitorRegistry.shared

    let monitor = MockPerformanceMonitor()
    registry.register(monitor: monitor, for: "test")

    let retrieved = registry.get(for: "test")
    #expect(retrieved != nil)
    #expect(retrieved?.systemIdentifier == monitor.systemIdentifier)
}

// MARK: - Mock Types for Testing

final class MockPerformanceMonitor: PerformanceMonitorProtocol {
    let systemIdentifier = "MockMonitor"

    func startMonitoring() async { }
    func stopMonitoring() async { }
    func getCurrentMemoryUsage() async -> UInt64 { return 1000 }
    func getCurrentCPUUsage() async -> Double { return 0.1 }
    func logBudgetViolation(_ type: BudgetViolationType, duration: TimeInterval?) async { }
    func getCurrentPerformanceState() async -> PerformanceSnapshot {
        return PerformanceSnapshot(
            performanceLevel: .optimal,
            memoryUsage: 1000,
            cpuUsage: 0.1,
            fps: 60.0,
            timestamp: Date()
        )
    }
}
```

This interface contract documentation provides concrete, actionable guidance based on real compilation failures and working patterns identified in the ManifestAndMatchV7 codebase.