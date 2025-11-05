# Manifest and Match V7: Annotated Component Map

**Comprehensive Component Documentation with Naming Conventions and Critical Sections**

**Last Updated:** October 17, 2025
**Version:** V7.0
**Status:** Production-Ready Core | Expanding Integrations

---

## Table of Contents

1. [Complete Component Inventory](#1-complete-component-inventory)
2. [Naming Conventions](#2-naming-conventions)
3. [Critical Sections](#3-critical-sections-never-modify)
4. [High-Impact Areas](#4-high-impact-areas-requires-testing)
5. [Safe Modification Areas](#5-safe-modification-areas-standard-development)
6. [Component Dependency Map](#6-component-dependency-map)
7. [Onboarding Guide](#7-onboarding-guide)
8. [Architecture Decision Records](#8-architecture-decision-records-adr)
9. [Verification Commands](#9-verification-commands)

---

## 1. Complete Component Inventory

### Overview
Manifest and Match V7 consists of **11 Swift packages** organized in a clean, zero-circular-dependency architecture. Each package has a specific domain responsibility and follows strict performance budgets.

### Package List

#### 1.1 V7Core (Foundation Layer)
**Purpose:** Foundation package providing sacred constants, protocols, and shared utilities with zero external dependencies.

**Key Files:**
1. `/Packages/V7Core/Sources/V7Core/SacredUIConstants.swift` - Sacred UI values and performance budgets
2. `/Packages/V7Core/Sources/V7Core/StateManagement/StateCoordinator.swift` - Centralized state coordination
3. `/Packages/V7Core/Sources/V7Core/Protocols/PerformanceMonitorProtocol.swift` - Performance monitoring interfaces
4. `/Packages/V7Core/Sources/V7Core/Protocols/MonitoringSystem.swift` - System monitoring protocols
5. `/Packages/V7Core/Sources/V7Core/SkillsMatching/EnhancedSkillsMatcher.swift` - Skills matching foundation

**Entry Points:**
- `V7Core.swift` - Main module export
- `SacredUIConstants.swift` - Sacred values access point
- `StateCoordinator.swift` - State management entry

**Public Interfaces:**
```swift
// Sacred Constants
public enum SacredUI { ... }
public enum PerformanceBudget { ... }

// Protocols
public protocol PerformanceMonitorProtocol: Actor, Sendable
public protocol ThompsonMonitorable: Actor, Sendable
public protocol JobDiscoveryMonitorable: Actor, Sendable

// State Management
@MainActor @Observable public class StateCoordinator
@Observable public class AppState: Sendable
```

**Testing Status:** ✅ Basic tests (3 test files)
- StateCoordinator tests
- Protocol conformance tests
- Sacred constants validation

---

#### 1.2 V7Thompson (Algorithm Layer)
**Purpose:** Thompson Sampling algorithm implementation with <10ms performance requirement and 357x advantage.

**Key Files:**
1. `/Packages/V7Thompson/Sources/V7Thompson/OptimizedThompsonEngine.swift` - Core algorithm engine
2. `/Packages/V7Thompson/Sources/V7Thompson/FastBetaSampler.swift` - Beta distribution sampling
3. `/Packages/V7Thompson/Sources/V7Thompson/ThompsonCache.swift` - Performance optimization cache
4. `/Packages/V7Thompson/Sources/V7Thompson/SwipePatternAnalyzer.swift` - User behavior learning
5. `/Packages/V7Thompson/Sources/V7Thompson/ThompsonExplanationEngine.swift` - Score explanation system

**Entry Points:**
- `V7Thompson.swift` - Main module export
- `OptimizedThompsonEngine.swift` - Algorithm entry point
- `ThompsonIntegration.swift` - UI integration bridge

**Public Interfaces:**
```swift
// Core Algorithm
public class OptimizedThompsonEngine
public struct FastBetaSampler
public actor ThompsonCache

// Integration
@MainActor public class ThompsonIntegration: ObservableObject
public protocol ThompsonMonitorable: Actor, Sendable

// Types
public struct Job
public struct ThompsonMetrics
public enum SwipeAction
```

**Testing Status:** ✅ Comprehensive tests (10 test files)
- Performance validation (<10ms requirement)
- Mathematical correctness tests
- Integration tests
- Pattern memory validation
- Real-time scoring tests

**Performance Requirements:**
- **SACRED:** <10ms per scoring operation
- **SACRED:** 357x performance advantage maintained
- Zero-allocation critical paths

---

#### 1.3 V7Services (Service Layer)
**Purpose:** API integrations, job sources, and network services for job discovery.

**Key Files:**
1. `/Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift` - Job discovery orchestration
2. `/Packages/V7Services/Sources/V7Services/CompanyAPIs/GreenhouseAPIClient.swift` - Greenhouse API integration
3. `/Packages/V7Services/Sources/V7Services/CompanyAPIs/LeverAPIClient.swift` - Lever API integration
4. `/Packages/V7Services/Sources/V7Services/JobSources/RSSFeedJobSource.swift` - RSS feed integration
5. `/Packages/V7Services/Sources/V7Services/Intelligence/SmartSourceSelector.swift` - Intelligent source selection

**Entry Points:**
- `V7Services.swift` - Main module export
- `JobDiscoveryCoordinator.swift` - Service orchestration entry point

**Public Interfaces:**
```swift
// Job Discovery
public class JobDiscoveryCoordinator
public protocol JobDiscoveryMonitorable: Actor, Sendable

// API Clients
public actor GreenhouseAPIClient
public actor LeverAPIClient
public actor RSSFeedJobSource

// Models
public struct JobItem
public struct EnhancedJobData
```

**Testing Status:** ⚠️ Partial tests
- API client unit tests
- Integration tests needed
- Performance validation needed

**Performance Requirements:**
- Company API: <3s response time
- RSS feeds: <2s response time
- Total pipeline: <5s end-to-end

---

#### 1.4 V7UI (Presentation Layer)
**Purpose:** SwiftUI views, components, and accessibility features with sacred UI constant enforcement.

**Key Files:**
1. `/Packages/V7UI/Sources/V7UI/Views/DeckScreen.swift` - Main card swiping interface
2. `/Packages/V7UI/Sources/V7UI/Colors/DualProfileColorSystem.swift` - Amber-Teal color system
3. `/Packages/V7UI/Sources/V7UI/Views/PerformanceChartsView.swift` - Performance monitoring UI
4. `/Packages/V7UI/Sources/V7UI/Accessibility/AccessibilityManager.swift` - Accessibility coordination
5. `/Packages/V7UI/Sources/V7UI/Views/ExplainFitSheet.swift` - Job fit explanation UI

**Entry Points:**
- `V7UI.swift` - Main module export
- `DeckScreen.swift` - Primary user interface
- `DualProfileColorSystem.swift` - Color system entry

**Public Interfaces:**
```swift
// Views
@MainActor public struct DeckScreen: View
@MainActor public struct PerformanceChartsView: View
@MainActor public struct ExplainFitSheet: View

// Color System
public struct DualProfileColorSystem
public struct AccessibilityColorAdapter

// Services
public class DeepLinkHandler
public class JobApplicationURLService
```

**Testing Status:** ⚠️ Partial tests
- View model tests
- Accessibility tests needed
- UI integration tests needed

**Sacred UI Enforcement:**
- Swipe thresholds: Right(100), Left(-100), Up(-80)
- Animation: 0.6s spring, 0.8 damping
- Dual-Profile colors: Amber(45°/360°), Teal(174°/360°)

---

#### 1.5 V7Data (Persistence Layer)
**Purpose:** Core Data stack and migration logic for local data storage.

**Key Files:**
1. `/Packages/V7Data/Sources/V7Data/V7DataModel.xcdatamodeld` - Core Data model
2. `/Packages/V7Data/Sources/V7Data/Migration/V7MigrationCoordinator.swift` - Migration orchestration
3. `/Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift` - User profile entity
4. `/Packages/V7Data/Sources/V7Data/Entities/ThompsonArm+CoreData.swift` - Thompson state entity
5. `/Packages/V7Data/Sources/V7Data/Entities/SwipeHistory+CoreData.swift` - Swipe history entity

**Entry Points:**
- `V7Data.swift` - Main module export
- `V7MigrationCoordinator.swift` - Migration entry point

**Public Interfaces:**
```swift
// Core Data
public class V7DataStack
public protocol V7DataProvider

// Entities
public class UserProfile: NSManagedObject
public class ThompsonArm: NSManagedObject
public class SwipeHistory: NSManagedObject
public class JobCache: NSManagedObject
```

**Testing Status:** ⚠️ Basic tests
- Core Data stack tests
- Migration tests needed
- Entity relationship tests needed

---

#### 1.6 V7Performance (Monitoring Layer)
**Purpose:** Performance monitoring, budget enforcement, and graceful degradation.

**Key Files:**
1. `/Packages/V7Performance/Sources/V7Performance/ProductionMonitoringIntegration.swift` - Production monitoring
2. `/Packages/V7Performance/Sources/V7Performance/PerformanceBudget.swift` - Budget definitions
3. `/Packages/V7Performance/Sources/V7Performance/MemoryBudgetManager.swift` - Memory budget enforcement
4. `/Packages/V7Performance/Sources/V7Performance/MonitoringOverheadValidator.swift` - Overhead validation
5. `/Packages/V7Performance/Sources/V7Performance/ProductionMetricsDashboard.swift` - Metrics dashboard

**Entry Points:**
- `ProductionMonitoringIntegration.swift` - Monitoring entry point
- `PerformanceBudget.swift` - Budget definitions

**Public Interfaces:**
```swift
// Monitoring
public actor ProductionMonitoringIntegration
@MainActor public class ProductionMetricsDashboard: ObservableObject

// Budget Management
public enum PerformanceBudget
public class MemoryBudgetManager

// Validation
public struct MonitoringOverheadValidator
```

**Testing Status:** ✅ Good coverage
- Budget validation tests
- Overhead validation tests
- Performance regression tests

**Performance Requirements:**
- Monitoring overhead: <1% of total time
- Thompson <10ms budget maintained
- Memory baseline: <200MB

---

#### 1.7 V7Migration (Migration Layer)
**Purpose:** V6 to V7 migration with rollback safety and data validation.

**Key Files:**
1. `/Packages/V7Migration/Sources/V7Migration/V7DataMigrationManager.swift` - Migration orchestration
2. `/Packages/V7Migration/Sources/V7Migration/ThompsonParameterCorrector.swift` - Algorithm parameter migration
3. `/Packages/V7Migration/Sources/V7Migration/V5DataExtractor.swift` - V5/V6 data extraction
4. `/Packages/V7Migration/Sources/V7Migration/MigrationValidator.swift` - Migration validation
5. `/Packages/V7Migration/Sources/V7Migration/V7Migration.swift` - Main export

**Entry Points:**
- `V7DataMigrationManager.swift` - Migration entry point
- `MigrationValidator.swift` - Validation entry point

**Public Interfaces:**
```swift
// Migration
public class V7DataMigrationManager
public struct MigrationValidator
public class ThompsonParameterCorrector

// Status
public enum MigrationStatus
public struct MigrationResult
```

**Testing Status:** ⚠️ Needs expansion
- Basic migration tests
- Rollback tests needed
- Edge case validation needed

---

#### 1.8 V7JobParsing (Job Analysis Layer)
**Purpose:** Job description parsing, skill extraction, and seniority detection.

**Key Files:**
1. `/Packages/V7JobParsing/Sources/V7JobParsing/Core/JobParsingService.swift` - Main parsing service
2. `/Packages/V7JobParsing/Sources/V7JobParsing/Core/SkillsDatabase.swift` - Skills taxonomy
3. `/Packages/V7JobParsing/Sources/V7JobParsing/Extractors/JobSkillsExtractor.swift` - Skill extraction
4. `/Packages/V7JobParsing/Sources/V7JobParsing/Models/ParsedJobMetadata.swift` - Parsed job model
5. `/Packages/V7JobParsing/Sources/V7JobParsing/Models/SeniorityLevel.swift` - Seniority classification

**Entry Points:**
- `JobParsingService.swift` - Parsing entry point
- `JobSkillsExtractor.swift` - Skill extraction entry

**Public Interfaces:**
```swift
// Parsing
public actor JobParsingService
public struct JobSkillsExtractor

// Models
public struct ParsedJobMetadata
public enum SeniorityLevel
public struct ExperienceRange

// Database
public struct SkillsDatabase
```

**Testing Status:** ✅ Good coverage
- Parsing tests
- Skill extraction tests
- Seniority detection tests
- Experience range tests

**Performance Requirements:**
- Job parsing: <2s per job description
- Memory: <50MB per parsing operation

---

#### 1.9 V7AIParsing (AI Processing Layer)
**Purpose:** Advanced AI parsing engine for resume and job content analysis.

**Key Files:**
1. `/Packages/V7AIParsing/Sources/V7AIParsing/` - Package structure defined
2. Currently empty - planned implementation

**Entry Points:**
- Future: Resume parsing
- Future: AI-powered skill matching

**Public Interfaces:**
```swift
// Planned interfaces
// public actor ResumeParsingEngine
// public actor JobContentAnalyzer
// public struct AIParsingResult
```

**Testing Status:** ❌ Not implemented
- Package structure exists
- Implementation pending

**Performance Requirements:**
- AI parsing: <10ms integration with Thompson
- Must maintain 357x advantage

---

#### 1.10 V7Embeddings (Semantic Matching Layer)
**Purpose:** Vector embeddings for semantic job-resume matching.

**Key Files:**
1. `/Packages/V7Embeddings/Sources/V7Embeddings/EmbeddingService.swift` - Embedding generation
2. `/Packages/V7Embeddings/Sources/V7Embeddings/SimilarityCalculator.swift` - Similarity computation
3. `/Packages/V7Embeddings/Sources/V7Embeddings/Models/ResumeEmbedding.swift` - Resume vectors
4. `/Packages/V7Embeddings/Sources/V7Embeddings/Models/JobEmbedding.swift` - Job vectors
5. `/Packages/V7Embeddings/Sources/V7Embeddings/Integration/ThompsonIntegration.swift` - Thompson integration

**Entry Points:**
- `EmbeddingService.swift` - Embedding generation
- `SimilarityCalculator.swift` - Similarity computation

**Public Interfaces:**
```swift
// Embeddings
public struct EmbeddingService
public struct SimilarityCalculator

// Models
public struct ResumeEmbedding
public struct JobEmbedding
```

**Testing Status:** ⚠️ Basic tests
- Embedding generation tests
- Similarity calculation tests
- Integration tests needed

---

#### 1.11 ManifestAndMatchV7Feature (Integration Layer)
**Purpose:** Main application feature integrating all V7 packages.

**Key Files:**
1. `/ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/ContentView.swift` - Main app view
2. `/ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/ManifestAndMatchV7App.swift` - App entry point
3. Integration of all packages into cohesive application

**Entry Points:**
- `ManifestAndMatchV7App.swift` - Application entry point
- `ContentView.swift` - Root view

**Public Interfaces:**
```swift
@MainActor
public struct ManifestAndMatchV7App: App
```

**Testing Status:** ⚠️ Integration tests needed

**Dependencies:** ALL V7 packages

---

## 2. Naming Conventions

### 2.1 Package Naming Pattern

**Convention:** `V7{Domain}` pattern for all packages

**Examples:**
```
✅ V7Core         - Foundation domain
✅ V7Thompson     - Thompson sampling domain
✅ V7Services     - Service integration domain
✅ V7UI           - User interface domain
✅ V7Performance  - Performance monitoring domain
✅ V7Data         - Data persistence domain
✅ V7Migration    - Migration domain
✅ V7JobParsing   - Job parsing domain
✅ V7AIParsing    - AI parsing domain
✅ V7Embeddings   - Embeddings domain
```

**Rationale:**
- Clear version identifier (V7)
- Domain-driven design
- Easy to distinguish from V5/V6 code
- Consistent with Swift package naming

---

### 2.2 Type Naming Conventions

**Structs, Classes, Enums:** PascalCase

```swift
✅ public struct JobItem
✅ public class OptimizedThompsonEngine
✅ public enum SwipeAction
✅ public actor ProductionMonitoringIntegration

❌ public struct jobItem        // lowercase start
❌ public class thompsonEngine  // camelCase
❌ public enum swipe_action     // snake_case
```

**Protocols:** PascalCase with descriptive suffix

```swift
✅ public protocol PerformanceMonitorProtocol
✅ public protocol ThompsonMonitorable
✅ public protocol JobDiscoveryMonitorable
✅ public protocol V7DataProvider

❌ public protocol PerformanceMonitor  // Missing Protocol suffix
❌ public protocol Monitorable         // Too generic
```

**Actors:** PascalCase, clearly marked as actors

```swift
✅ public actor ProductionMonitoringIntegration
✅ public actor JobDiscoveryCoordinator
✅ public actor ThompsonCache

❌ public class ThompsonCache  // Should be actor for concurrency
```

---

### 2.3 Function Naming Conventions

**Convention:** camelCase with clear verb prefixes

```swift
// Query operations - get/fetch/retrieve
✅ func getCurrentMetrics() async -> ThompsonMetrics
✅ func fetchJobs(count: Int) async -> [JobItem]
✅ func retrieveUserProfile() async -> UserProfile?

// State changes - update/set/apply
✅ func updateBaseline(reason: String) async
✅ func setSwipeAction(_ action: SwipeAction) async
✅ func applyMigration() async throws

// Validation - validate/check/verify
✅ func validateMigration() -> MigrationResult
✅ func checkPerformanceBudget() -> Bool
✅ func verifyIntegrity() async -> Bool

// Recording - record/track/log
✅ func recordMetric(name: String, value: Double) async
✅ func trackInteraction(jobId: UUID, action: SwipeAction) async
✅ func logPerformanceViolation() async

// Processing - process/handle/execute
✅ func processInteraction(jobId: UUID, action: SwipeAction) async
✅ func handleSwipeAction(_ action: SwipeAction) async
✅ func executeMigration() async throws

❌ func metrics()              // Missing verb
❌ func GetCurrentMetrics()    // PascalCase, should be camelCase
❌ func update_baseline()      // snake_case
```

---

### 2.4 File Naming Conventions

**Convention:** Match primary type name

```swift
// File: OptimizedThompsonEngine.swift
✅ public class OptimizedThompsonEngine { }

// File: JobDiscoveryCoordinator.swift
✅ public class JobDiscoveryCoordinator { }

// File: SacredUIConstants.swift
✅ public enum SacredUI { }

// File: PerformanceMonitorProtocol.swift
✅ public protocol PerformanceMonitorProtocol { }

❌ File: thompson.swift         // Should be OptimizedThompsonEngine.swift
❌ File: Utils.swift            // Too generic
❌ File: JobStuff.swift         // Unclear naming
```

**Special Files:**
```
✅ Package.swift               // SPM standard
✅ V7Core.swift                // Module entry point
✅ {Type}+CoreData.swift       // Core Data extensions
✅ {Type}+Extensions.swift     // Type extensions
```

---

### 2.5 Test Naming Conventions

**Convention:** `{Type}Tests` pattern

```swift
// File: OptimizedThompsonEngineTests.swift
✅ class OptimizedThompsonEngineTests: XCTestCase

// File: JobParsingServiceTests.swift
✅ class JobParsingServiceTests: XCTestCase

// File: PerformanceValidation.swift
✅ class PerformanceValidation: XCTestCase

❌ class TestThompson: XCTestCase  // Missing Tests suffix
❌ class Tests: XCTestCase          // Too generic
```

**Test Method Naming:**
```swift
✅ func testThompsonSamplingPerformance() async
✅ func testMigrationRollback() async throws
✅ func testSacredUIConstantsValidation()

❌ func test1()                     // Non-descriptive
❌ func thompsonTest()              // Missing test prefix
```

---

### 2.6 Swift 6 Patterns

**@MainActor Usage:**
```swift
// UI-facing components
✅ @MainActor
   public struct DeckScreen: View { }

✅ @MainActor
   public class StateCoordinator: ObservableObject { }

✅ @MainActor
   public class ThompsonIntegration: ObservableObject { }
```

**Actor Isolation:**
```swift
// Background processing
✅ public actor ProductionMonitoringIntegration { }
✅ public actor JobDiscoveryCoordinator { }
✅ public actor ThompsonCache { }
```

**Sendable Conformance:**
```swift
// Cross-actor data types
✅ public struct JobItem: Sendable { }
✅ public struct ThompsonMetrics: Sendable { }
✅ public struct PerformanceBaseline: Sendable { }

// Protocols
✅ public protocol ThompsonMonitorable: Actor, Sendable { }
```

**nonisolated Access:**
```swift
// Safe cross-actor access for immutable data
✅ public nonisolated func getSafeMetrics() -> ThompsonMetrics {
    // Only access immutable, thread-safe data
   }

✅ public nonisolated var immutableProperty: MetricValue { }
```

---

## 3. Critical Sections (🔴 NEVER MODIFY WITHOUT APPROVAL)

### 3.1 Sacred UI Constants

**Location:** `/Packages/V7Core/Sources/V7Core/SacredUIConstants.swift`

**CRITICAL VALUES - NEVER CHANGE:**

```swift
// Swipe Gesture Thresholds
public enum SacredUI {
    public enum Swipe {
        public static let rightThreshold: CGFloat = 100      // 🔴 SACRED
        public static let leftThreshold: CGFloat = -100      // 🔴 SACRED
        public static let upThreshold: CGFloat = -80         // 🔴 SACRED
        public static let rotationDivisor: CGFloat = 20.0    // 🔴 SACRED
    }
}
```

**Rationale:** These values preserve exact muscle memory from V5.7. Users have trained their gestures to these precise thresholds. Any change breaks the sacred contract with users.

**Validation:**
```bash
# Verify sacred constants are unchanged
grep -A 3 "public enum Swipe" Packages/V7Core/Sources/V7Core/SacredUIConstants.swift
```

---

```swift
// Animation Timing
public enum SacredUI {
    public enum Animation {
        public static let springResponse: Double = 0.6    // 🔴 SACRED
        public static let springDamping: Double = 0.8     // 🔴 SACRED
    }
}
```

**Rationale:** Spring animation feel calibrated to user expectations. 0.6s response with 0.8 damping creates the exact "feel" users expect.

---

```swift
// Dual-Profile Color System
public enum SacredUI {
    public enum DualProfile {
        public static let amberHue: Double = 45.0 / 360.0   // 🔴 SACRED (#FFBF00)
        public static let tealHue: Double = 174.0 / 360.0   // 🔴 SACRED (#00BFA5)
        public static let saturation: Double = 0.85         // 🔴 SACRED
        public static let brightness: Double = 0.9          // 🔴 SACRED
    }
}
```

**Rationale:** Dual-profile brand identity. Amber represents "current self", Teal represents "future self". Mathematical precision ensures consistent color across the app.

**Brand Enforcement:**
- Amber Hue: 45° (pure amber, mathematically precise)
- Teal Hue: 174° (brand teal, mathematically precise)
- Never use approximate colors

---

### 3.2 Thompson Sampling Algorithm

**Location:** `/Packages/V7Thompson/Sources/V7Thompson/`

**CRITICAL FILES:**

1. **OptimizedThompsonEngine.swift** - 🔴 Core algorithm
   - Beta distribution sampling
   - Parameter updates
   - Arm selection logic

2. **FastBetaSampler.swift** - 🔴 Mathematical core
   - Beta distribution implementation
   - Performance-optimized sampling
   - Zero-allocation paths

**Critical Sections:**

```swift
// Beta Distribution Sampling - MATHEMATICALLY VERIFIED
public struct FastBetaSampler {
    public func sample(alpha: Double, beta: Double) -> Double {
        // 🔴 CRITICAL: Mathematical correctness verified
        // DO NOT MODIFY without statistical validation
    }
}
```

**Performance Requirements:**
- **SACRED:** <10ms per scoring operation
- **SACRED:** 357x performance advantage
- Zero-allocation critical paths

**Why Critical:**
- Mathematical correctness verified by statisticians
- Performance is competitive differentiator
- Any change requires full statistical validation
- User learning patterns depend on algorithm stability

**Modification Process:**
1. Statistical validation required
2. Performance regression testing
3. A/B testing with real users
4. Gradual rollout monitoring
5. Architecture team approval

---

### 3.3 Performance Budgets

**Location:** `/Packages/V7Core/Sources/V7Core/SacredUIConstants.swift`

**CRITICAL BUDGETS:**

```swift
public enum PerformanceBudget {
    // 🔴 SACRED: Thompson Sampling Performance
    public static let thompsonSamplingTarget: TimeInterval = 0.010  // 10ms

    // 🔴 CRITICAL: API Response Times
    public static let companyAPITarget: TimeInterval = 3.0          // 3s
    public static let rssFeedTarget: TimeInterval = 2.0             // 2s
    public static let apiResponseTarget: TimeInterval = 2.0         // 2s

    // 🔴 CRITICAL: Memory Budgets
    public static let memoryBaselineMB: Double = 200.0              // 200MB
    public static let emergencyMemoryThresholdMB: Double = 250.0    // 250MB
    public static let highMemoryThresholdMB: Double = 220.0         // 220MB

    // 🔴 CRITICAL: Total Pipeline
    public static let totalPipelineTarget: TimeInterval = 5.0       // 5s
}
```

**Why Sacred:**
- Thompson <10ms is the **357x competitive advantage**
- Users expect instantaneous feedback
- Performance is a quality attribute
- Budgets prevent performance regressions

**Enforcement:**
```swift
// Automatic validation in production code
let startTime = Date()
await performThompsonScoring()
let duration = Date().timeIntervalSince(startTime)

if duration > PerformanceBudget.thompsonSamplingTarget {
    logger.error("⚠️ SACRED BUDGET VIOLATED: \(duration * 1000)ms")
    // Triggers production alert
}
```

---

### 3.4 Package Dependencies

**Location:** All `Package.swift` files

**CRITICAL RULE:** Zero circular dependencies

**Sacred Dependency Hierarchy:**

```
V7Core (Foundation - ZERO dependencies)
├── V7Thompson (depends: V7Core)
├── V7Data (depends: V7Core)
├── V7Migration (depends: V7Core)
├── V7JobParsing (depends: V7Core)
├── V7Embeddings (depends: V7Core)
├── V7Performance (depends: V7Core, V7Thompson)
├── V7Services (depends: V7Core, V7Thompson, V7JobParsing)
├── V7AIParsing (depends: V7Core, V7Thompson, V7Performance)
└── V7UI (depends: V7Core, V7Services, V7Thompson, V7Performance)
    └── ManifestAndMatchV7Feature (depends: ALL)
```

**Rules:**
1. V7Core has ZERO external dependencies
2. V7Core has ZERO dependencies on other V7 packages
3. No circular dependencies allowed
4. Protocol-based dependency inversion required

**Validation:**
```bash
# Check V7Core has no dependencies
grep -A 5 "dependencies:" Packages/V7Core/Package.swift | grep -c "package"
# Expected output: 0

# Verify no circular dependencies
./Documentation/CodeQuality/check_circular_dependencies.sh
```

---

## 4. High-Impact Areas (⚠️ REQUIRES COMPREHENSIVE TESTING)

### 4.1 Data Migration System

**Location:** `/Packages/V7Migration/`

**Why High-Impact:**
- Migrates user data from V6 to V7
- Incorrect migration = data loss
- Must support rollback
- Affects existing user base

**Critical Operations:**
1. **Data extraction** from V6 schema
2. **Thompson parameter correction** (algorithm changes)
3. **Validation** before commit
4. **Rollback** on failure

**Testing Requirements:**
- Unit tests for each migration step
- Integration tests for full migration
- Rollback tests
- Edge case validation (corrupted data, partial migrations)
- Performance tests (large datasets)

**Safe Modification Process:**
1. Add comprehensive tests first
2. Test with production-like data
3. Implement rollback mechanism
4. Gradual rollout with monitoring
5. Keep V6 compatibility during transition

---

### 4.2 API Integration Layer

**Location:** `/Packages/V7Services/`

**Why High-Impact:**
- External API changes can break integration
- Network failures must be handled gracefully
- Performance budgets must be maintained
- User-facing functionality depends on it

**Critical Components:**
1. **GreenhouseAPIClient** - Greenhouse job API
2. **LeverAPIClient** - Lever job API
3. **RSSFeedJobSource** - RSS feed parsing
4. **JobDiscoveryCoordinator** - Orchestrates all sources

**Testing Requirements:**
- Mock API responses for unit tests
- Network error handling tests
- Rate limiting tests
- Performance budget validation
- Integration tests with real APIs (staging)
- Fallback behavior tests

**Safe Modification Process:**
1. Add tests for current behavior
2. Test against real API (staging environment)
3. Implement error handling
4. Add monitoring and alerting
5. Gradual rollout with feature flags

---

### 4.3 Resume Parsing (Future)

**Location:** `/Packages/V7AIParsing/`

**Why High-Impact:**
- Complex natural language processing
- Affects job matching accuracy
- Must maintain Thompson <10ms budget
- Privacy-sensitive data processing

**Critical Considerations:**
1. NLP accuracy
2. Performance overhead
3. Privacy requirements
4. Error handling
5. Graceful degradation

**Testing Requirements:**
- NLP accuracy tests with real resumes
- Performance tests (<10ms integration)
- Privacy compliance tests
- Error handling tests
- Fallback behavior tests

---

### 4.4 Job Parsing

**Location:** `/Packages/V7JobParsing/`

**Why High-Impact:**
- Extracts critical information from job descriptions
- Affects matching quality
- Must handle diverse job description formats
- Performance-sensitive

**Critical Components:**
1. **JobParsingService** - Main parsing orchestration
2. **JobSkillsExtractor** - Skill extraction from text
3. **SkillsDatabase** - Skills taxonomy
4. **SeniorityLevel** - Seniority detection

**Testing Requirements:**
- Parsing accuracy tests
- Skill extraction validation
- Seniority detection tests
- Performance tests (<2s per job)
- Edge case handling (malformed descriptions)

---

## 5. Safe Modification Areas (✅ STANDARD DEVELOPMENT)

### 5.1 UI Components

**Location:** `/Packages/V7UI/Sources/V7UI/Views/`

**Safe to Modify:**
- Non-swipe views (ProfileScreen, HistoryScreen, AnalyticsScreen)
- Color system extensions (as long as sacred colors preserved)
- Accessibility features
- Animation details (not sacred timing)
- Layout adjustments (respecting sacred spacing)

**Guidelines:**
1. Use sacred constants for critical values
2. Add tests for new components
3. Follow SwiftUI best practices
4. Maintain @MainActor isolation
5. Follow accessibility guidelines

**Example Safe Changes:**
```swift
// ✅ SAFE: Adding new view
@MainActor
public struct NewFeatureView: View {
    var body: some View {
        VStack(spacing: SacredUI.Spacing.standard) {  // Use sacred constants
            // New UI code
        }
    }
}

// ✅ SAFE: Extending color system
extension DualProfileColorSystem {
    public func customGradient() -> LinearGradient {
        // Use sacred colors as base
    }
}
```

---

### 5.2 Test Infrastructure

**Location:** All `Tests/` directories

**Safe to Modify:**
- Adding new tests (always safe!)
- Test helpers and utilities
- Mock implementations
- Test data fixtures
- Performance benchmarks

**Guidelines:**
1. Follow `{Type}Tests` naming convention
2. Use descriptive test method names
3. Test one thing per test method
4. Use async/await for asynchronous tests
5. Add performance tests for critical paths

**Example:**
```swift
// ✅ SAFE: Adding comprehensive tests
class NewFeatureTests: XCTestCase {
    func testFeatureBehaviorUnderNormalConditions() async throws {
        // Test implementation
    }

    func testFeatureErrorHandling() async throws {
        // Error case testing
    }

    func testFeaturePerformance() async throws {
        // Performance validation
    }
}
```

---

### 5.3 Documentation

**Location:** `/Documentation/`

**Safe to Modify:**
- Architecture documentation
- Development guides
- API documentation
- Code examples
- Troubleshooting guides

**Guidelines:**
1. Keep documentation in sync with code
2. Use clear, professional language
3. Include code examples
4. Add diagrams where helpful
5. Link to related documents

---

### 5.4 Configuration Files

**Location:** Various `*.json`, `*.plist`, etc.

**Safe to Modify:**
- Job source configurations
- API endpoint configurations
- Feature flags
- Environment configurations
- Build settings (with testing)

**Guidelines:**
1. Validate JSON/plist syntax
2. Add comments explaining purpose
3. Version control all changes
4. Test configurations before committing
5. Document configuration options

---

## 6. Component Dependency Map

### 6.1 V7Core (Foundation)

**Depends On:**
- **ZERO** external dependencies
- **ZERO** other V7 packages

**Depended On By:**
- V7Thompson
- V7Services
- V7UI
- V7Data
- V7Performance
- V7Migration
- V7JobParsing
- V7AIParsing
- V7Embeddings
- ManifestAndMatchV7Feature

**Public API Surface:**
```swift
// Sacred Constants
public enum SacredUI
public enum PerformanceBudget
public struct SacredValueValidator

// Protocols
public protocol PerformanceMonitorProtocol: Actor, Sendable
public protocol ThompsonMonitorable: Actor, Sendable
public protocol JobDiscoveryMonitorable: Actor, Sendable

// State Management
@MainActor @Observable public class StateCoordinator
@Observable public class AppState: Sendable
@MainActor public class MonitoringSystemRegistry

// Skills Matching
public struct EnhancedSkillsMatcher
public struct SkillTaxonomy
```

**Internal Implementation:**
- Configuration management
- State coordination
- Memory monitoring
- Interface contracts

---

### 6.2 V7Thompson (Algorithm)

**Depends On:**
- V7Core (protocols, sacred constants)

**Depended On By:**
- V7Services
- V7UI
- V7Performance
- V7AIParsing
- ManifestAndMatchV7Feature

**Public API Surface:**
```swift
// Core Algorithm
public class OptimizedThompsonEngine
public struct FastBetaSampler
public actor ThompsonCache

// Integration
@MainActor public class ThompsonIntegration: ObservableObject
public struct ThompsonScoringBridge

// Types
public struct Job
public struct ThompsonMetrics
public enum SwipeAction

// Protocols
extension OptimizedThompsonEngine: ThompsonMonitorable
```

**Internal Implementation:**
- Beta distribution sampling
- Thompson arm management
- Swipe pattern analysis
- Performance optimization
- Real-time scoring

---

### 6.3 V7Services (Service Layer)

**Depends On:**
- V7Core (protocols, state)
- V7Thompson (Job type, integration)
- V7JobParsing (job metadata parsing)

**Depended On By:**
- V7UI
- ManifestAndMatchV7Feature

**Public API Surface:**
```swift
// Job Discovery
public class JobDiscoveryCoordinator
public protocol JobDiscoveryMonitorable

// API Clients
public actor GreenhouseAPIClient
public actor LeverAPIClient
public actor RSSFeedJobSource

// Models
public struct JobItem
public struct EnhancedJobData

// Intelligence
public class SmartSourceSelector
```

**Internal Implementation:**
- API client implementations
- Request coalescing
- Network optimization
- Rate limiting
- Company API management

---

### 6.4 V7UI (Presentation)

**Depends On:**
- V7Core (sacred constants, state)
- V7Services (job data)
- V7Thompson (algorithm integration)
- V7Performance (monitoring UI)

**Depended On By:**
- ManifestAndMatchV7Feature

**Public API Surface:**
```swift
// Views
@MainActor public struct DeckScreen: View
@MainActor public struct PerformanceChartsView: View
@MainActor public struct ProfileScreen: View
@MainActor public struct ExplainFitSheet: View

// Color System
public struct DualProfileColorSystem
public struct AccessibilityColorAdapter

// Services
public class DeepLinkHandler
public class JobApplicationURLService

// Accessibility
@MainActor public class AccessibilityManager
```

**Internal Implementation:**
- SwiftUI views
- Color system
- Accessibility features
- Deep linking
- Navigation

---

### 6.5 V7Performance (Monitoring)

**Depends On:**
- V7Core (protocols, budgets)
- V7Thompson (algorithm monitoring)

**Depended On By:**
- V7UI (charts, dashboards)
- V7AIParsing (performance monitoring)
- ManifestAndMatchV7Feature

**Public API Surface:**
```swift
// Monitoring
public actor ProductionMonitoringIntegration
@MainActor public class ProductionMetricsDashboard: ObservableObject

// Budget Management
public enum PerformanceBudget
public class MemoryBudgetManager

// Validation
public struct MonitoringOverheadValidator
```

**Internal Implementation:**
- Performance monitoring
- Budget enforcement
- Memory management
- Metrics aggregation
- Alert system

---

### 6.6 V7Data (Persistence)

**Depends On:**
- V7Core (protocols only)

**Depended On By:**
- ManifestAndMatchV7Feature

**Public API Surface:**
```swift
// Core Data
public class V7DataStack
public protocol V7DataProvider

// Entities
public class UserProfile: NSManagedObject
public class ThompsonArm: NSManagedObject
public class SwipeHistory: NSManagedObject
public class JobCache: NSManagedObject
```

**Internal Implementation:**
- Core Data stack
- Migration coordinator
- Entity management
- Data validation

---

### 6.7 V7Migration (Migration)

**Depends On:**
- V7Core (protocols only)

**Depended On By:**
- ManifestAndMatchV7Feature (optional)

**Public API Surface:**
```swift
// Migration
public class V7DataMigrationManager
public struct MigrationValidator
public class ThompsonParameterCorrector

// Status
public enum MigrationStatus
public struct MigrationResult
```

**Internal Implementation:**
- V5/V6 data extraction
- Thompson parameter correction
- Migration validation
- Rollback mechanism

---

### 6.8 V7JobParsing (Job Analysis)

**Depends On:**
- V7Core (protocols only)

**Depended On By:**
- V7Services (job metadata)

**Public API Surface:**
```swift
// Parsing
public actor JobParsingService
public struct JobSkillsExtractor

// Models
public struct ParsedJobMetadata
public enum SeniorityLevel
public struct ExperienceRange

// Database
public struct SkillsDatabase
```

**Internal Implementation:**
- NaturalLanguage framework integration
- Skill extraction algorithms
- Seniority detection logic
- Experience range parsing

---

### 6.9 Dependency Graph Visualization

```
┌─────────────────────────────────────────────────────────────┐
│                   ManifestAndMatchV7Feature                 │
│                    (Integration Layer)                      │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐          ┌──────────┐         ┌──────────────┐
   │  V7UI   │          │V7Services│         │V7Performance │
   └─────────┘          └──────────┘         └──────────────┘
        │                     │                     │
        │    ┌────────────────┼──────┐              │
        │    │                │      │              │
        ▼    ▼                ▼      ▼              ▼
   ┌──────────────┐    ┌──────────┐        ┌─────────────┐
   │  V7Thompson  │    │V7JobParse│        │   V7Data    │
   └──────────────┘    └──────────┘        └─────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                        ┌──────────┐
                        │  V7Core  │
                        │Foundation│
                        └──────────┘

Legend:
┌────┐
│ X  │  = Package
└────┘
  │     = depends on
  ▼     = dependency direction
```

---

## 7. Onboarding Guide

### 7.1 Start Here: Read V7Core First

**Day 1-2: Foundation Understanding**

**Read in this order:**

1. **SacredUIConstants.swift**
   - Understand sacred values
   - Learn why they're immutable
   - See performance budgets

2. **Protocols/PerformanceMonitorProtocol.swift**
   - Learn protocol-based architecture
   - Understand actor isolation
   - See Sendable conformance

3. **StateManagement/StateCoordinator.swift**
   - Understand state management pattern
   - Learn @Observable usage
   - See MainActor isolation

**Key Takeaways:**
- Sacred constants are immutable
- Protocol-based dependency inversion
- Actor isolation for concurrency
- Performance budgets as constraints

**Hands-On:**
```bash
# Explore V7Core structure
ls -R Packages/V7Core/Sources/V7Core/

# Read sacred constants
cat Packages/V7Core/Sources/V7Core/SacredUIConstants.swift

# Validate sacred constants at runtime
# These assertions should pass
swift test --filter SacredValueValidator
```

---

### 7.2 Then: Understand V7Thompson Algorithm

**Day 3-4: Algorithm Deep Dive**

**Read in this order:**

1. **OptimizedThompsonEngine.swift**
   - Core Thompson Sampling implementation
   - Beta distribution sampling
   - Arm selection logic

2. **FastBetaSampler.swift**
   - Mathematical implementation
   - Performance optimization
   - Zero-allocation design

3. **ThompsonCache.swift**
   - Performance caching strategy
   - Actor-based isolation
   - <10ms budget enforcement

4. **Tests/V7ThompsonTests/PerformanceValidation.swift**
   - See performance requirements
   - Understand testing strategy
   - Learn validation patterns

**Key Takeaways:**
- <10ms is sacred performance requirement
- 357x competitive advantage
- Mathematical correctness verified
- Zero-allocation critical paths

**Hands-On:**
```bash
# Run Thompson tests
cd Packages/V7Thompson
swift test

# Run performance validation
swift test --filter PerformanceValidation

# See performance in action
swift test --filter RealTimeScoringTests
```

---

### 7.3 Next: Explore V7Services for API Integration

**Day 5-6: Service Layer Understanding**

**Read in this order:**

1. **JobDiscoveryCoordinator.swift**
   - Service orchestration
   - API coordination
   - Error handling

2. **CompanyAPIs/GreenhouseAPIClient.swift**
   - Real API integration example
   - Network handling
   - Rate limiting

3. **Intelligence/SmartSourceSelector.swift**
   - Intelligent job source selection
   - Thompson integration
   - Performance optimization

**Key Takeaways:**
- Protocol-based API abstraction
- Performance budgets enforced
- Error handling patterns
- Network optimization

**Hands-On:**
```bash
# Explore API clients
ls Packages/V7Services/Sources/V7Services/CompanyAPIs/

# Run service tests
cd Packages/V7Services
swift test

# See job discovery in action
# (requires API credentials)
```

---

### 7.4 Finally: V7UI for User-Facing Features

**Day 7: UI Layer Understanding**

**Read in this order:**

1. **Views/DeckScreen.swift**
   - Main card swiping interface
   - Sacred gesture thresholds
   - Animation timing

2. **Colors/DualProfileColorSystem.swift**
   - Amber-Teal color system
   - Brand identity implementation
   - Accessibility support

3. **Views/PerformanceChartsView.swift**
   - Performance monitoring UI
   - Real-time data visualization
   - Dashboard integration

**Key Takeaways:**
- Sacred UI constants enforced
- SwiftUI best practices
- @MainActor isolation
- Accessibility first

**Hands-On:**
```bash
# Explore UI components
ls Packages/V7UI/Sources/V7UI/Views/

# Run UI tests
cd Packages/V7UI
swift test

# Build and run the app
cd ../..
xcodebuild -scheme ManifestAndMatchV7
```

---

### 7.5 Week 1 Success Checklist

After one week, you should be able to:

- [ ] Explain why sacred constants are immutable
- [ ] Describe the Thompson <10ms requirement
- [ ] Understand protocol-based dependency inversion
- [ ] Navigate the package architecture
- [ ] Run all tests successfully
- [ ] Identify critical vs. safe modification areas
- [ ] Use sacred constants in code
- [ ] Follow naming conventions
- [ ] Understand actor isolation patterns
- [ ] Know when to seek architecture approval

**Self-Assessment:**
```bash
# Can you answer these questions?
# 1. What are the sacred swipe thresholds?
# 2. What is the Thompson performance budget?
# 3. Which package has zero dependencies?
# 4. What is the dependency direction rule?
# 5. When should you use @MainActor?

# Practical test:
# 1. Add a new view to V7UI
# 2. Ensure it uses sacred constants
# 3. Write tests for it
# 4. Run all tests
# 5. Submit for code review
```

---

## 8. Architecture Decision Records (ADR)

### ADR-001: Why Modular Architecture?

**Context:**
V5.7 was a monolithic codebase with tight coupling, making changes risky and testing difficult.

**Decision:**
Adopt modular architecture with 11 separate Swift packages, each with a single responsibility.

**Rationale:**
1. **Separation of Concerns:** Each package has one clear purpose
2. **Independent Evolution:** Packages can evolve independently
3. **Testability:** Smaller, focused packages are easier to test
4. **Clear Boundaries:** Package boundaries enforce architectural rules
5. **Team Scalability:** Multiple developers can work on different packages

**Consequences:**
- ✅ Better code organization
- ✅ Easier testing
- ✅ Clearer dependencies
- ✅ Reduced coupling
- ⚠️ More Package.swift files to manage
- ⚠️ Need to understand package boundaries

**Status:** Accepted | Implemented | Successful

---

### ADR-002: Why Swift Package Manager?

**Context:**
Need to choose dependency management system for modular architecture.

**Decision:**
Use Swift Package Manager (SPM) for all packages.

**Rationale:**
1. **Native Swift:** First-class Swift tool
2. **Xcode Integration:** Excellent Xcode support
3. **Zero External Tools:** No CocoaPods or Carthage needed
4. **Swift 6 Support:** Full Swift 6 concurrency support
5. **Local Packages:** Path-based dependencies for local packages
6. **Build Performance:** Incremental compilation

**Alternatives Considered:**
- CocoaPods: Extra tooling, slower builds
- Carthage: Less Xcode integration
- Manual frameworks: No dependency management

**Consequences:**
- ✅ Native Swift experience
- ✅ Excellent Xcode support
- ✅ Clean dependency declarations
- ✅ Fast incremental builds
- ⚠️ Learning curve for SPM

**Status:** Accepted | Implemented | Successful

---

### ADR-003: Why Zero External Dependencies in V7Core?

**Context:**
V7Core is the foundation package. Should it have external dependencies?

**Decision:**
V7Core has **ZERO** external dependencies - only Foundation and SwiftUI.

**Rationale:**
1. **Stability:** No external dependency version conflicts
2. **Build Speed:** Faster builds without external dependencies
3. **Control:** Full control over all code
4. **Security:** No third-party security vulnerabilities
5. **Portability:** Easy to port to other platforms if needed

**Consequences:**
- ✅ Maximum stability
- ✅ No version conflicts
- ✅ Fastest builds
- ✅ Full control
- ⚠️ Must implement some utilities ourselves
- ⚠️ Cannot use popular third-party libraries

**Examples of What We Implemented:**
- Skills matching (no external NLP library)
- State management (no external state library)
- Performance monitoring (no external APM)

**Status:** Accepted | Implemented | Maintained

---

### ADR-004: Why Thompson Sampling vs Alternatives?

**Context:**
Need recommendation algorithm for job matching. Many options available.

**Decision:**
Implement Thompson Sampling with <10ms performance requirement.

**Alternatives Considered:**

1. **Epsilon-Greedy**
   - ❌ Slower learning
   - ❌ Less optimal exploration
   - ✅ Simpler implementation

2. **UCB (Upper Confidence Bound)**
   - ❌ Requires more computation
   - ❌ Not Bayesian
   - ✅ Good theoretical bounds

3. **Contextual Bandits**
   - ❌ More complex
   - ❌ Higher computation cost
   - ✅ Better personalization

4. **Neural Collaborative Filtering**
   - ❌ Requires large dataset
   - ❌ High computation cost
   - ❌ Not real-time
   - ✅ Good for large scale

**Why Thompson Sampling Won:**

1. **Bayesian Learning:** Optimal exploration-exploitation
2. **Performance:** Can achieve <10ms with optimization
3. **Privacy:** On-device learning, no external AI
4. **Mathematical Rigor:** Well-understood theory
5. **User Experience:** Real-time learning from swipes
6. **Competitive Advantage:** 357x faster than alternatives

**Rationale for <10ms Requirement:**
- Users expect instant feedback (<100ms perception threshold)
- Swipe gesture timing requires immediate response
- Maintain 60fps UI responsiveness
- Competitive differentiation

**Implementation Details:**
- Optimized beta distribution sampling
- Zero-allocation critical paths
- Actor-based caching
- GPU-accelerated math where possible

**Performance Evidence:**
```
Thompson Sampling: 0.028ms average (357x faster)
Standard ML Models: 10ms+ (unacceptable for real-time)
Neural Networks: 50-100ms (far too slow)
```

**Consequences:**
- ✅ 357x performance advantage
- ✅ Real-time user feedback
- ✅ Privacy-preserving on-device learning
- ✅ Mathematical rigor
- ⚠️ Complex implementation
- ⚠️ Requires statistical expertise

**Status:** Accepted | Implemented | Validated | Sacred

---

### ADR-005: Why Protocol-Based Dependency Inversion?

**Context:**
Need to avoid circular dependencies while allowing cross-package communication.

**Decision:**
Use protocol-based dependency inversion with V7Core defining all protocols.

**Rationale:**
1. **Zero Circular Dependencies:** Protocols in foundation layer
2. **Loose Coupling:** Packages depend on abstractions, not implementations
3. **Testability:** Easy to mock protocol implementations
4. **Flexibility:** Can swap implementations without changing dependents
5. **Swift 6 Compliance:** Actor protocols with Sendable conformance

**Pattern:**
```swift
// V7Core defines protocol (no implementation)
public protocol ThompsonMonitorable: Actor, Sendable {
    func getCurrentMetrics() async -> ThompsonMetrics
}

// V7Thompson implements protocol
extension OptimizedThompsonEngine: ThompsonMonitorable {
    public func getCurrentMetrics() async -> ThompsonMetrics { ... }
}

// V7Performance depends on protocol (not implementation)
func monitorThompson(_ system: any ThompsonMonitorable) async {
    let metrics = await system.getCurrentMetrics()
}
```

**Consequences:**
- ✅ Zero circular dependencies achieved
- ✅ Clean architecture maintained
- ✅ Easy testing with mocks
- ✅ Swift 6 concurrency compliance
- ⚠️ More protocols to maintain
- ⚠️ Need to understand protocol design

**Status:** Accepted | Implemented | Core Pattern

---

### ADR-006: Why Swift 6 Strict Concurrency?

**Context:**
Need to ensure thread safety and prevent data races.

**Decision:**
Enable Swift 6 strict concurrency in all packages.

**Rationale:**
1. **Thread Safety:** Compiler-enforced concurrency safety
2. **Actor Isolation:** Clear isolation boundaries
3. **Sendable Types:** Safe cross-actor data transfer
4. **Future-Proof:** Aligned with Swift evolution
5. **Performance:** Better optimization opportunities

**Patterns Adopted:**
- `@MainActor` for UI components
- `actor` for background processing
- `Sendable` for cross-actor types
- `nonisolated` for immutable access

**Consequences:**
- ✅ Compiler-enforced thread safety
- ✅ Eliminates data races
- ✅ Clear concurrency model
- ✅ Better performance
- ⚠️ Learning curve for Swift concurrency
- ⚠️ More verbose code in some cases

**Status:** Accepted | Implemented | Enforced

---

### ADR-007: Why Sacred UI Constants?

**Context:**
Users migrating from V5.7 have muscle memory for gesture thresholds and animations.

**Decision:**
Define sacred UI constants that are immutable and validated at runtime.

**Rationale:**
1. **User Experience:** Preserve exact muscle memory
2. **Brand Identity:** Consistent amber-teal color system
3. **Quality Attribute:** Performance budgets as architectural constraints
4. **Regression Prevention:** Runtime validation catches violations
5. **Team Communication:** "Sacred" clearly communicates "do not change"

**Sacred Values:**
- Swipe thresholds: Right(100), Left(-100), Up(-80)
- Animation: 0.6s spring, 0.8 damping
- Colors: Amber(45°), Teal(174°)
- Performance: Thompson <10ms

**Enforcement:**
```swift
public struct SacredValueValidator {
    public static func validateAll() {
        assert(SacredUI.Swipe.rightThreshold == 100, "Sacred value violated!")
        // ... more assertions
    }
}
```

**Consequences:**
- ✅ User experience preserved
- ✅ No accidental regressions
- ✅ Clear architectural constraints
- ✅ Team alignment on critical values
- ⚠️ Requires architecture approval to change

**Status:** Accepted | Implemented | Enforced | Sacred

---

## 9. Verification Commands

### 9.1 Verify Naming Conventions

```bash
# Check that all Swift files start with uppercase (PascalCase)
find Packages -name "*.swift" -type f | while read file; do
    basename "$file" | grep -E '^[A-Z]' || echo "❌ Invalid: $file"
done

# Check for snake_case (should find none)
find Packages -name "*.swift" -type f | grep -E '_' && echo "⚠️ Found snake_case files"

# Verify test files end with Tests.swift
find Packages -path "*/Tests/*" -name "*.swift" -type f | \
    grep -v "Tests\.swift$" && echo "⚠️ Found test files without Tests suffix"
```

**Expected Output:**
- No invalid files
- No snake_case files
- All test files end with `Tests.swift`

---

### 9.2 Check Test Coverage

```bash
# Count total test files
echo "Total test files:"
find Packages -name "*Tests.swift" -type f | wc -l

# Tests per package
for pkg in V7Core V7Thompson V7UI V7Services V7Data V7Performance \
           V7Migration V7JobParsing V7AIParsing V7Embeddings; do
    count=$(find "Packages/$pkg" -name "*Tests.swift" -type f 2>/dev/null | wc -l)
    echo "$pkg: $count test files"
done

# Find packages without tests
for pkg in V7Core V7Thompson V7UI V7Services V7Data V7Performance \
           V7Migration V7JobParsing V7AIParsing V7Embeddings; do
    count=$(find "Packages/$pkg" -name "*Tests.swift" -type f 2>/dev/null | wc -l)
    if [ "$count" -eq 0 ]; then
        echo "⚠️ $pkg has no tests"
    fi
done
```

**Expected Output:**
- Total: ~45 test files
- V7Thompson: ~10 tests (comprehensive)
- V7JobParsing: ~4 tests (good coverage)
- V7AIParsing: 0 tests (not implemented yet)

---

### 9.3 List Public Interfaces

```bash
# Find all public protocols
echo "=== Public Protocols ==="
grep -r "^public protocol" --include="*.swift" Packages/ | \
    sed 's/.*public protocol //' | sed 's/[:{].*//' | sort -u

# Find all public structs
echo "=== Public Structs ==="
grep -r "^public struct" --include="*.swift" Packages/ | \
    sed 's/.*public struct //' | sed 's/[:{].*//' | sort -u | head -20

# Find all public classes
echo "=== Public Classes ==="
grep -r "^public class" --include="*.swift" Packages/ | \
    sed 's/.*public class //' | sed 's/[:{].*//' | sort -u | head -20

# Find all public actors
echo "=== Public Actors ==="
grep -r "^public actor" --include="*.swift" Packages/ | \
    sed 's/.*public actor //' | sed 's/[:{].*//' | sort -u
```

**Expected Output:**
- Protocols: PerformanceMonitorProtocol, ThompsonMonitorable, etc.
- Structs: JobItem, ThompsonMetrics, etc.
- Classes: OptimizedThompsonEngine, StateCoordinator, etc.
- Actors: ThompsonCache, JobDiscoveryCoordinator, etc.

---

### 9.4 Verify Sacred Constants

```bash
# Check sacred swipe thresholds
echo "=== Sacred Swipe Thresholds ==="
grep -A 3 "public enum Swipe" Packages/V7Core/Sources/V7Core/SacredUIConstants.swift

# Expected:
# rightThreshold: CGFloat = 100
# leftThreshold: CGFloat = -100
# upThreshold: CGFloat = -80

# Check sacred animation values
echo "=== Sacred Animation Values ==="
grep -A 2 "public enum Animation" Packages/V7Core/Sources/V7Core/SacredUIConstants.swift

# Expected:
# springResponse: Double = 0.6
# springDamping: Double = 0.8

# Check sacred performance budgets
echo "=== Sacred Performance Budgets ==="
grep "thompsonSamplingTarget" Packages/V7Core/Sources/V7Core/SacredUIConstants.swift

# Expected:
# thompsonSamplingTarget: TimeInterval = 0.010  // 10ms

# Check that sacred constants are not modified elsewhere
echo "=== Verify No Sacred Constant Reassignments ==="
grep -r "SacredUI.*=" --include="*.swift" Packages/ | \
    grep -v "let.*SacredUI" | \
    grep -v "SacredUIConstants.swift"

# Expected output: (empty - no reassignments)
```

---

### 9.5 Check Package Dependencies

```bash
# Verify V7Core has ZERO dependencies
echo "=== V7Core Dependencies (should be 0) ==="
grep -A 10 "dependencies:" Packages/V7Core/Package.swift | \
    grep "\.package" | wc -l

# Expected: 0

# Check for circular dependencies
echo "=== Checking for Circular Dependencies ==="
# This would require a script to analyze Package.swift files
# For now, manual verification:

for pkg in Packages/*/Package.swift; do
    echo "=== $(basename $(dirname $pkg)) ==="
    grep "\.package(path:" "$pkg" | sed 's/.*path: "\.\.\///' | sed 's/").*//'
done

# Verify dependency hierarchy is respected
# V7Core -> (nothing)
# V7Thompson -> V7Core
# V7Services -> V7Core, V7Thompson, V7JobParsing
# V7UI -> V7Core, V7Services, V7Thompson, V7Performance
```

---

### 9.6 Performance Verification

```bash
# Run Thompson performance tests
echo "=== Thompson Performance Validation ==="
cd Packages/V7Thompson
swift test --filter PerformanceValidation

# Expected: All tests pass, performance within <10ms budget

# Check for performance budget violations in code
echo "=== Search for Performance Budget Checks ==="
grep -r "thompsonSamplingTarget" --include="*.swift" Packages/

# Should find enforcement code in multiple places

# Verify zero-allocation paths
echo "=== Check for Allocation in Critical Paths ==="
grep -r "@_optimize(speed)" --include="*.swift" Packages/V7Thompson/

# Look for performance-critical optimizations
```

---

### 9.7 Swift 6 Compliance Check

```bash
# Check for @MainActor usage
echo "=== @MainActor Usage ==="
grep -r "@MainActor" --include="*.swift" Packages/ | wc -l

# Check for actor usage
echo "=== Actor Usage ==="
grep -r "^public actor\|^actor" --include="*.swift" Packages/ | wc -l

# Check for Sendable conformance
echo "=== Sendable Conformance ==="
grep -r ": Sendable\|, Sendable" --include="*.swift" Packages/ | wc -l

# Check for StrictConcurrency enablement
echo "=== StrictConcurrency Enabled Packages ==="
grep -r "StrictConcurrency" --include="Package.swift" Packages/ | \
    grep -v "^//" | wc -l

# Expected: Most packages have StrictConcurrency enabled
```

---

### 9.8 Code Quality Checks

```bash
# Check for TODO/FIXME comments
echo "=== TODO/FIXME Comments ==="
grep -r "TODO\|FIXME" --include="*.swift" Packages/ | wc -l

# Check for force unwraps (should minimize)
echo "=== Force Unwraps (!) ==="
grep -r "!" --include="*.swift" Packages/V7Core/Sources/ | \
    grep -v "//" | grep -v "\"" | wc -l

# Check for fatalError (should be minimal)
echo "=== fatalError Usage ==="
grep -r "fatalError" --include="*.swift" Packages/ | wc -l

# Check for proper error handling
echo "=== Error Handling (throws) ==="
grep -r "throws" --include="*.swift" Packages/ | wc -l
```

---

### 9.9 Architecture Health Check

```bash
# Run full test suite
echo "=== Running Full Test Suite ==="
swift test

# Check build success
echo "=== Build Verification ==="
swift build

# Package structure validation
echo "=== Package Structure ==="
for pkg in Packages/*; do
    if [ -d "$pkg" ]; then
        echo "Package: $(basename $pkg)"
        [ -f "$pkg/Package.swift" ] && echo "  ✅ Package.swift exists" || echo "  ❌ Missing Package.swift"
        [ -d "$pkg/Sources" ] && echo "  ✅ Sources directory exists" || echo "  ❌ Missing Sources"
        [ -d "$pkg/Tests" ] && echo "  ✅ Tests directory exists" || echo "  ⚠️ Missing Tests"
    fi
done
```

---

### 9.10 Quick Reference: One-Command Validation

```bash
# Create a validation script
cat > validate_architecture.sh << 'EOF'
#!/bin/bash
echo "🔍 Manifest and Match V7 Architecture Validation"
echo "================================================"

echo ""
echo "1️⃣ Sacred Constants Validation..."
sacred_violations=$(grep -r "SacredUI.*=" --include="*.swift" Packages/ | \
    grep -v "let.*SacredUI" | \
    grep -v "SacredUIConstants.swift" | wc -l)
if [ "$sacred_violations" -eq 0 ]; then
    echo "✅ Sacred constants: PROTECTED"
else
    echo "❌ Sacred constants: $sacred_violations VIOLATIONS FOUND"
fi

echo ""
echo "2️⃣ V7Core Zero Dependencies..."
core_deps=$(grep -A 10 "dependencies:" Packages/V7Core/Package.swift | \
    grep "\.package" | wc -l)
if [ "$core_deps" -eq 0 ]; then
    echo "✅ V7Core dependencies: ZERO (correct)"
else
    echo "❌ V7Core has $core_deps dependencies (should be 0)"
fi

echo ""
echo "3️⃣ Test Coverage..."
total_tests=$(find Packages -name "*Tests.swift" -type f | wc -l)
echo "✅ Total test files: $total_tests"

echo ""
echo "4️⃣ Naming Conventions..."
invalid_files=$(find Packages -name "*.swift" -type f | while read file; do
    basename "$file" | grep -E '^[A-Z]' || echo "$file"
done | grep -v "^$" | wc -l)
if [ "$invalid_files" -eq 0 ]; then
    echo "✅ File naming: All PascalCase"
else
    echo "⚠️ Found $invalid_files files with invalid naming"
fi

echo ""
echo "5️⃣ Swift 6 Compliance..."
actors=$(grep -r "^public actor\|^actor" --include="*.swift" Packages/ | wc -l)
mainactors=$(grep -r "@MainActor" --include="*.swift" Packages/ | wc -l)
echo "✅ Actors: $actors | @MainActor: $mainactors"

echo ""
echo "================================================"
echo "✅ Architecture validation complete!"
EOF

chmod +x validate_architecture.sh
./validate_architecture.sh
```

---

## Appendix A: Quick Reference Tables

### Sacred Constants Quick Reference

| Constant | Value | Location | Why Sacred |
|----------|-------|----------|------------|
| **Swipe Right** | `100` | SacredUIConstants.swift | User muscle memory |
| **Swipe Left** | `-100` | SacredUIConstants.swift | User muscle memory |
| **Swipe Up** | `-80` | SacredUIConstants.swift | User muscle memory |
| **Spring Response** | `0.6s` | SacredUIConstants.swift | Animation feel |
| **Spring Damping** | `0.8` | SacredUIConstants.swift | Animation feel |
| **Amber Hue** | `45°/360°` | SacredUIConstants.swift | Brand identity |
| **Teal Hue** | `174°/360°` | SacredUIConstants.swift | Brand identity |
| **Thompson Budget** | `10ms` | SacredUIConstants.swift | 357x advantage |
| **Memory Baseline** | `200MB` | SacredUIConstants.swift | Performance |

---

### Performance Budgets Quick Reference

| Operation | Budget | Rationale | Enforcement |
|-----------|--------|-----------|-------------|
| **Thompson Scoring** | <10ms | 357x competitive advantage | Runtime monitoring |
| **Company API** | <3s | User expectation | Network timeout |
| **RSS Feed** | <2s | User expectation | Network timeout |
| **Job Parsing** | <2s | Background operation | Performance tests |
| **Memory Baseline** | <200MB | Resource constraint | Memory monitoring |
| **Emergency Memory** | 250MB | Critical threshold | Triggers cleanup |
| **Total Pipeline** | <5s | End-to-end experience | Integration tests |

---

### Package Dependency Hierarchy

| Layer | Packages | Dependencies |
|-------|----------|--------------|
| **Foundation** | V7Core | None (ZERO) |
| **Algorithm** | V7Thompson | V7Core |
| **Services** | V7Services, V7JobParsing, V7Embeddings | V7Core |
| **Monitoring** | V7Performance | V7Core, V7Thompson |
| **Persistence** | V7Data, V7Migration | V7Core |
| **Processing** | V7AIParsing | V7Core, V7Thompson, V7Performance |
| **Presentation** | V7UI | V7Core, V7Services, V7Thompson, V7Performance |
| **Integration** | ManifestAndMatchV7Feature | ALL |

---

### Testing Status Overview

| Package | Test Files | Status | Priority |
|---------|-----------|--------|----------|
| V7Core | 3 | ⚠️ Basic | Medium |
| V7Thompson | 10 | ✅ Comprehensive | Critical |
| V7Services | 5 | ⚠️ Partial | High |
| V7UI | 5 | ⚠️ Partial | High |
| V7Data | 1 | ⚠️ Basic | High |
| V7Performance | 5 | ✅ Good | Medium |
| V7Migration | 2 | ⚠️ Basic | High |
| V7JobParsing | 4 | ✅ Good | Medium |
| V7AIParsing | 0 | ❌ None | Future |
| V7Embeddings | 1 | ⚠️ Basic | Medium |

---

## Appendix B: Common Development Workflows

### Adding a New Feature

```bash
# 1. Identify the correct package
# - UI feature? -> V7UI
# - API integration? -> V7Services
# - Algorithm change? -> V7Thompson (CAREFUL!)
# - Data model? -> V7Data

# 2. Check dependencies
cd Packages/{TargetPackage}
cat Package.swift

# 3. Add tests FIRST
# Create {Feature}Tests.swift in Tests/

# 4. Implement feature
# Create {Feature}.swift in Sources/

# 5. Use sacred constants
# Import V7Core
# Use SacredUI.* for critical values

# 6. Run tests
swift test

# 7. Verify no violations
../../validate_architecture.sh

# 8. Submit for review
git add .
git commit -m "Add {feature}: {description}"
```

---

### Modifying Existing Code

```bash
# 1. Read existing code and tests
cat Packages/{Package}/Sources/{File}.swift
cat Packages/{Package}/Tests/{File}Tests.swift

# 2. Add tests for new behavior FIRST
# Edit Tests/{File}Tests.swift

# 3. Make changes
# Edit Sources/{File}.swift

# 4. Check sacred constants not violated
grep "SacredUI" Sources/{File}.swift
# Ensure you're USING sacred constants, not MODIFYING them

# 5. Run tests
swift test

# 6. Performance check (if algorithm/performance-critical)
swift test --filter Performance

# 7. Validate architecture
../../validate_architecture.sh
```

---

### Debugging Performance Issues

```bash
# 1. Run performance tests
cd Packages/V7Thompson
swift test --filter PerformanceValidation

# 2. Check for performance violations in logs
grep -r "SACRED BUDGET VIOLATED" .

# 3. Profile the operation
# Use Instruments for detailed profiling

# 4. Check memory usage
swift test --filter MemoryBudget

# 5. Validate monitoring overhead
cd ../V7Performance
swift test --filter MonitoringOverhead
```

---

## Document Change Log

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2025-10-17 | 1.0 | Initial comprehensive component map | Claude |

---

## Document Maintenance

**Update Triggers:**
- New package added
- Package dependencies change
- Sacred constants change (requires approval!)
- Performance budgets change (requires approval!)
- Major architecture changes

**Review Cycle:** Quarterly or after major releases

**Ownership:** Architecture Team

---

**End of Annotated Component Map**

*This document provides comprehensive guidance for understanding, navigating, and contributing to the Manifest and Match V7 codebase. For questions or clarifications, consult the Architecture Team.*
