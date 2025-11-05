# Import Patterns Reference
*Implementation-Ready Swift Import Examples for ManifestAndMatchV7*

**Generated**: October 2025 | **Status**: Production-Ready Patterns | **Target**: iOS 18.0+ Swift 6.1

---

## 🎯 OVERVIEW

This document provides **concrete, copy-paste ready** Swift import statements and patterns for cross-package communication in ManifestAndMatchV7. All examples are optimized for the 357x Thompson Sampling performance advantage while maintaining strict architectural boundaries.

**CRITICAL**: These patterns prevent namespace collisions, maintain clean architecture boundaries, and optimize build performance for AI parsing workflows.

---

## 📋 QUICK REFERENCE - IMPORT HIERARCHY

### Package Dependency Graph (Clean Architecture)
```
V7Core (Foundation - NO dependencies)
├── V7Thompson (Algorithm - V7Core only)
├── V7Data (Persistence - V7Core only)
├── V7AIParsing (AI Engine - V7Core + V7Thompson + V7Performance)
├── V7Performance (Monitoring - V7Core + V7Thompson)
├── V7Services (API Layer - V7Core + V7Thompson)
├── V7Migration (Data Migration - V7Core + V7Data)
└── V7UI (Presentation - ALL packages)
    └── ManifestAndMatchV7Feature (Integration - ALL packages)
```

### Import Priority Matrix
```yaml
# ALWAYS import in this order for consistent namespace resolution:
import_order:
  1. Foundation/SwiftUI system frameworks
  2. V7Core (always first V7 import)
  3. V7Thompson (algorithm layer)
  4. V7AIParsing (AI processing)
  5. V7Performance (monitoring)
  6. V7Services (API layer)
  7. V7Data (persistence)
  8. V7Migration (data migration)
  9. V7UI (presentation - only in UI files)
```

---

## 🚀 AI PARSING → THOMPSON SAMPLING INTEGRATION PATTERNS

### 1. V7AIParsing: AI Engine Implementation
**Use Case**: Writing AI parsing algorithms that feed into Thompson sampling

```swift
// File: V7AIParsing/Sources/V7AIParsing/AIInsightsEngine.swift
// PRIORITY: Import V7Core first for protocol definitions
import Foundation
import NaturalLanguage      // iOS AI framework for text processing
import CoreML              // iOS ML framework for model inference
import V7Core              // ✅ CRITICAL: Always import first for protocols
import V7Thompson          // ✅ Thompson sampling integration
import V7Performance       // ✅ Performance monitoring for <10ms target

// ✅ CORRECT: Namespace-safe AI insights integration
public final class AIInsightsEngine: @unchecked Sendable {

    // Thompson sampling bridge for AI insights
    private let thompsonBridge: V7Thompson.ThompsonScoringBridge
    private let performanceMonitor: V7Performance.MetricsCollector

    public init() {
        // ✅ Full namespace qualification prevents type collisions
        self.thompsonBridge = V7Thompson.ThompsonScoringBridge()
        self.performanceMonitor = V7Performance.MetricsCollector.shared
    }

    // AI analysis that feeds Thompson algorithm
    public func analyzeJobMatch(
        jobData: V7Core.JobData,
        userProfile: V7Core.UserProfile
    ) async throws -> V7Thompson.MatchScore {

        // Performance tracking for <10ms requirement
        let startTime = CFAbsoluteTimeGetCurrent()
        defer {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            performanceMonitor.record(
                V7Performance.TimestampedValue(
                    value: duration * 1000, // Convert to ms
                    metric: "ai_parsing_duration_ms"
                )
            )
        }

        // AI processing using iOS frameworks
        let insights = try await processWithNaturalLanguage(jobData)

        // Feed AI insights to Thompson algorithm
        return try await thompsonBridge.computeScore(
            insights: insights,
            userProfile: userProfile
        )
    }
}

// ✅ CORRECT: Type extensions with namespace safety
extension V7Thompson.MatchScore {
    /// AI-enhanced match scoring integration
    static func fromAIInsights(
        _ insights: AIJobInsights,
        userProfile: V7Core.UserProfile
    ) -> V7Thompson.MatchScore {
        // Implementation that maintains Thompson performance
        return V7Thompson.MatchScore(
            value: insights.compatibilityScore,
            confidence: insights.confidenceLevel,
            timestamp: Date()
        )
    }
}
```

### 2. V7Thompson: Algorithm Core with AI Integration
**Use Case**: Thompson sampling algorithm consuming AI insights

```swift
// File: V7Thompson/Sources/V7Thompson/ThompsonScoringBridge.swift
import Foundation
import V7Core              // ✅ CRITICAL: Protocol definitions first

// ✅ CORRECT: Clean import without circular dependencies
// NOTE: V7Thompson does NOT import V7AIParsing to prevent cycles
// AI insights are passed as V7Core protocol types

public final class ThompsonScoringBridge: @unchecked Sendable {

    // Core Thompson algorithm - 357x performance optimized
    private let algorithm: ThompsonSamplingCore

    public init() {
        self.algorithm = ThompsonSamplingCore()
    }

    // ✅ Protocol-based AI integration (no direct V7AIParsing dependency)
    public func computeScore(
        insights: V7Core.AIInsights,  // Protocol from V7Core
        userProfile: V7Core.UserProfile
    ) async throws -> MatchScore {

        // Thompson sampling with AI-enhanced priors
        let priorBeta = algorithm.computePrior(from: insights)
        let posteriorAlpha = algorithm.updatePosterior(
            prior: priorBeta,
            userHistory: userProfile.interactionHistory
        )

        return MatchScore(
            value: posteriorAlpha.sample(),
            confidence: posteriorAlpha.confidence,
            timestamp: Date()
        )
    }
}

// ✅ CORRECT: Public types for cross-package access
public struct MatchScore: Sendable, Identifiable {
    public let id = UUID()
    public let value: Double
    public let confidence: Double
    public let timestamp: Date

    public init(value: Double, confidence: Double, timestamp: Date) {
        self.value = value
        self.confidence = confidence
        self.timestamp = timestamp
    }
}
```

### 3. V7Services: API Layer with Thompson Integration
**Use Case**: API services feeding data to Thompson algorithm via AI parsing

```swift
// File: V7Services/Sources/V7Services/JobSourceManager.swift
import Foundation
import V7Core              // ✅ Protocol definitions
import V7Thompson          // ✅ Thompson integration for scoring

// ✅ CORRECT: Clean imports - no V7AIParsing dependency to avoid cycles
// AI parsing is triggered via protocol delegation

public final class JobSourceManager: @unchecked Sendable {

    // Thompson integration for real-time job scoring
    private let thompsonEngine: V7Thompson.ThompsonSamplingCore

    // Delegate for AI processing (implemented by V7AIParsing)
    public weak var aiProcessor: V7Core.AIProcessorDelegate?

    public init() {
        self.thompsonEngine = V7Thompson.ThompsonSamplingCore()
    }

    // Job fetching with Thompson scoring integration
    public func fetchAndScoreJobs(
        for userProfile: V7Core.UserProfile
    ) async throws -> [V7Core.ScoredJob] {

        // Fetch raw job data from APIs
        let rawJobs = try await fetchRawJobs()

        // Process through AI parsing (if available)
        var scoredJobs: [V7Core.ScoredJob] = []

        for job in rawJobs {
            // AI processing via protocol delegation
            if let aiProcessor = aiProcessor {
                let insights = try await aiProcessor.analyze(job: job)
                let thompsonScore = try await thompsonEngine.score(
                    job: job,
                    insights: insights,
                    userProfile: userProfile
                )

                scoredJobs.append(V7Core.ScoredJob(
                    job: job,
                    score: thompsonScore
                ))
            } else {
                // Fallback Thompson scoring without AI
                let basicScore = thompsonEngine.scoreBasic(
                    job: job,
                    userProfile: userProfile
                )

                scoredJobs.append(V7Core.ScoredJob(
                    job: job,
                    score: basicScore
                ))
            }
        }

        return scoredJobs
    }
}
```

---

## 🎨 V7UI INTEGRATION PATTERNS

### 4. V7UI: Presentation Layer with Full Integration
**Use Case**: SwiftUI views displaying AI-enhanced Thompson results

```swift
// File: V7UI/Sources/V7UI/JobMatchingDeckView.swift
import SwiftUI
import Foundation
import V7Core              // ✅ CRITICAL: Always first V7 import
import V7Thompson          // ✅ Thompson algorithm access
import V7AIParsing         // ✅ AI insights display
import V7Performance       // ✅ Performance monitoring
import V7Services          // ✅ API integration

// ✅ CORRECT: Full namespace qualification for complex UI
public struct JobMatchingDeckView: View {

    // State management with proper V7 type namespacing
    @StateObject private var viewModel: JobMatchingViewModel
    @State private var thompsonScores: [V7Thompson.MatchScore] = []
    @State private var aiInsights: [V7AIParsing.AIJobInsights] = []
    @State private var performanceMetrics: V7Performance.SystemEvent?

    public init() {
        self._viewModel = StateObject(wrappedValue: JobMatchingViewModel())
    }

    public var body: some View {
        ZStack {
            // Job cards with AI-enhanced Thompson scoring
            ForEach(viewModel.scoredJobs) { scoredJob in
                JobCardView(
                    job: scoredJob.job,
                    thompsonScore: scoredJob.score, // V7Thompson.MatchScore
                    aiInsights: aiInsights.first { $0.jobId == scoredJob.job.id }
                )
                .matchedGeometryEffect(
                    id: scoredJob.id,
                    in: V7Core.SharedNamespace.cardTransition
                )
            }

            // Performance overlay (debug builds only)
            #if DEBUG
            if let metrics = performanceMetrics {
                PerformanceOverlayView(systemEvent: metrics)
                    .position(x: 50, y: 50)
            }
            #endif
        }
        .onAppear {
            Task {
                await loadAIEnhancedMatches()
            }
        }
    }

    // ✅ CORRECT: Clean async integration across packages
    private func loadAIEnhancedMatches() async {
        do {
            // Coordinate AI parsing with Thompson sampling
            let aiProcessor = V7AIParsing.AIInsightsEngine()
            let thompsonBridge = V7Thompson.ThompsonScoringBridge()
            let performanceMonitor = V7Performance.MetricsCollector.shared

            // Performance tracking
            let startTime = CFAbsoluteTimeGetCurrent()

            // AI-enhanced Thompson processing
            let jobs = try await viewModel.jobSource.fetchJobs()

            for job in jobs {
                let insights = try await aiProcessor.analyzeJobMatch(
                    jobData: job,
                    userProfile: viewModel.userProfile
                )

                let score = try await thompsonBridge.computeScore(
                    insights: insights,
                    userProfile: viewModel.userProfile
                )

                await MainActor.run {
                    thompsonScores.append(score)
                    if let aiInsight = insights as? V7AIParsing.AIJobInsights {
                        aiInsights.append(aiInsight)
                    }
                }
            }

            // Performance logging
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            await MainActor.run {
                self.performanceMetrics = V7Performance.SystemEvent(
                    type: .thompsonSampling,
                    description: "AI-Thompson integration: \(duration * 1000)ms",
                    severity: duration > 0.01 ? .warning : .info
                )
            }

        } catch {
            print("AI-Thompson integration error: \(error)")
        }
    }
}

// ✅ CORRECT: Clean view model with proper imports
@MainActor
public final class JobMatchingViewModel: ObservableObject {
    @Published var scoredJobs: [V7Core.ScoredJob] = []
    @Published var userProfile: V7Core.UserProfile

    let jobSource: V7Services.JobSourceManager

    public init() {
        self.userProfile = V7Core.UserProfile.current
        self.jobSource = V7Services.JobSourceManager()

        // Set up AI processing delegation
        let aiProcessor = V7AIParsing.AIInsightsEngine()
        self.jobSource.aiProcessor = aiProcessor
    }
}
```

---

## 🔧 NAMESPACE COLLISION PREVENTION

### Explicit Type Qualification Patterns

```swift
// ✅ CORRECT: Explicit namespace qualification when types might collide
import V7Core
import V7Thompson
import V7Services
import V7AIParsing

func processJobData() {
    // Explicit qualification prevents ambiguity
    let coreJob: V7Core.JobData = V7Core.JobData()
    let thompsonScore: V7Thompson.MatchScore = V7Thompson.MatchScore()
    let aiInsights: V7AIParsing.AIInsights = V7AIParsing.AIInsights()
    let apiJob: V7Services.APIJobResponse = V7Services.APIJobResponse()

    // ❌ AVOID: Unqualified types that might collide
    // let job: JobData = JobData()  // Which JobData?
    // let score: Score = Score()    // Which Score?
}

// ✅ CORRECT: Type aliases for frequently used cross-package types
typealias ThompsonScore = V7Thompson.MatchScore
typealias AIInsights = V7AIParsing.AIJobInsights
typealias PerformanceEvent = V7Performance.SystemEvent

// Usage with clean aliases
func processWithAliases() {
    let score: ThompsonScore = ThompsonScore()
    let insights: AIInsights = AIInsights()
    let event: PerformanceEvent = PerformanceEvent()
}
```

### Import Scoping for Large Files

```swift
// ✅ CORRECT: Scoped imports for complex files
import Foundation
import SwiftUI

// Core V7 imports (always first)
import V7Core

// Feature-specific imports with explicit scoping
import enum V7Thompson.SamplingStrategy
import struct V7Thompson.MatchScore
import protocol V7AIParsing.AIProcessorDelegate
import class V7Performance.MetricsCollector
import struct V7Services.APIConfiguration

// ✅ This prevents namespace pollution while maintaining access
func scopedFunctionality() {
    let strategy: SamplingStrategy = .betaBernoulli  // No namespace needed
    let score = MatchScore(value: 0.85, confidence: 0.92, timestamp: Date())
    let collector = MetricsCollector.shared
}
```

---

## ⚡ BUILD PERFORMANCE OPTIMIZATION

### 1. Import Ordering for Compilation Speed

```swift
// ✅ OPTIMAL: Import order for fastest compilation
import Foundation           // System frameworks first (pre-compiled)
import SwiftUI             // UI frameworks second
import CoreML              // iOS AI frameworks third

import V7Core              // V7 foundation layer first
import V7Thompson          // Algorithm layer second
import V7AIParsing         // AI processing third
import V7Performance       // Monitoring fourth
import V7Services          // API layer fifth
import V7Data              // Persistence sixth
import V7UI                // Presentation last (heaviest)

// ❌ AVOID: Random import order (slower compilation)
// import V7UI
// import Foundation
// import V7Thompson
// import SwiftUI
```

### 2. Conditional Imports for Build Performance

```swift
// ✅ CORRECT: Conditional imports for debug/release optimization
import Foundation
import V7Core
import V7Thompson

#if DEBUG
import V7Performance       // Only import performance monitoring in debug
import os.log             // System logging for debug builds
#endif

#if TESTING
import V7TestingUtilities  // Test utilities only in test builds
#endif

// ✅ CORRECT: Platform-specific imports
#if canImport(UIKit)
import UIKit
import V7UI
#elseif canImport(AppKit)
import AppKit
// Future macOS support
#endif
```

### 3. Lazy Loading Pattern for AI Components

```swift
// ✅ CORRECT: Lazy loading for expensive AI components
import Foundation
import V7Core
import V7Thompson

public final class OptimizedAIIntegration {

    // Lazy AI components to improve app launch time
    private lazy var aiEngine: V7AIParsing.AIInsightsEngine = {
        V7AIParsing.AIInsightsEngine()
    }()

    private lazy var thompsonBridge: V7Thompson.ThompsonScoringBridge = {
        V7Thompson.ThompsonScoringBridge()
    }()

    // Only load AI parsing when actually needed
    public func processJobIfNeeded(_ job: V7Core.JobData) async throws -> V7Thompson.MatchScore? {
        guard shouldUseAI(for: job) else {
            // Fast path: basic Thompson without AI
            return try await thompsonBridge.computeBasicScore(job: job)
        }

        // AI path: full processing (loaded on demand)
        let insights = try await aiEngine.analyzeJobMatch(
            jobData: job,
            userProfile: V7Core.UserProfile.current
        )

        return try await thompsonBridge.computeScore(
            insights: insights,
            userProfile: V7Core.UserProfile.current
        )
    }
}
```

---

## 📊 PERFORMANCE MONITORING INTEGRATION

### Real-time Performance Tracking Pattern

```swift
// File: Any V7 package implementing performance monitoring
import Foundation
import V7Core
import V7Performance

// ✅ CORRECT: Performance monitoring with proper imports
public func performanceAwareFunction() async throws {
    let monitor = V7Performance.MetricsCollector.shared
    let operationId = UUID()

    // Start performance tracking
    let startTime = CFAbsoluteTimeGetCurrent()
    monitor.startOperation(id: operationId, type: "ai_thompson_integration")

    defer {
        // End performance tracking
        let duration = CFAbsoluteTimeGetCurrent() - startTime
        monitor.endOperation(
            id: operationId,
            duration: duration,
            success: true
        )

        // Log performance event
        monitor.record(V7Performance.SystemEvent(
            type: .performance,
            description: "Operation completed in \(duration * 1000)ms",
            severity: duration > 0.01 ? .warning : .info
        ))
    }

    // Your actual work here
    try await someExpensiveOperation()
}
```

---

## ❌ COMMON ANTI-PATTERNS TO AVOID

### 1. Circular Import Dependencies

```swift
// ❌ WRONG: Creates circular dependency
// File: V7Thompson/SomeFile.swift
import V7AIParsing  // ❌ Thompson should not import AIParsing directly

// ✅ CORRECT: Use protocol delegation from V7Core
import V7Core  // Protocol definitions prevent circular dependencies

// Use V7Core.AIInsights protocol instead of direct V7AIParsing types
```

### 2. Wildcard Imports

```swift
// ❌ WRONG: Wildcard imports pollute namespace
import V7Thompson.*
import V7AIParsing.*

// ✅ CORRECT: Explicit imports
import V7Thompson
import V7AIParsing
```

### 3. Nested Type Exposure

```swift
// ❌ WRONG: Nested types for cross-package interfaces
public class SomeManager {
    public struct ImportantType { }  // ❌ V7UI can't access reliably
}

// ✅ CORRECT: Top-level types for cross-package access
public struct ImportantType { }  // ✅ Accessible from any package

public class SomeManager {
    public func process(_ item: ImportantType) { }
}
```

---

## 🎯 IMPLEMENTATION CHECKLIST

When writing Swift files for AI parsing → Thompson sampling integration:

### ✅ Pre-Implementation Checklist
- [ ] Verify package dependencies in Package.swift match your imports
- [ ] Check import order: System frameworks → V7Core → other V7 packages
- [ ] Confirm no circular dependencies in your import chain
- [ ] Use explicit type qualification for ambiguous types
- [ ] Plan performance monitoring integration points

### ✅ During Implementation
- [ ] Import V7Core first for protocol definitions
- [ ] Use V7Thompson.MatchScore for Thompson algorithm results
- [ ] Implement V7Performance monitoring for <10ms targets
- [ ] Use protocol delegation instead of direct cross-package dependencies
- [ ] Qualify types explicitly when namespace collision is possible

### ✅ Post-Implementation Verification
- [ ] Compilation succeeds without warnings
- [ ] Performance targets met (<10ms Thompson sampling)
- [ ] No circular dependencies introduced
- [ ] Clean architecture boundaries maintained
- [ ] AI parsing integrates cleanly with Thompson algorithm

---

## 🔗 RELATED DOCUMENTATION

- **Architecture Overview**: `SYSTEM_ARCHITECTURE_REFERENCE.md`
- **Interface Contracts**: `INTERFACE_CONTRACT_STANDARDS.md`
- **Performance Guidelines**: `../Frameworks/PERFORMANCE_FRAMEWORK_REFERENCE.md`
- **Package Dependencies**: Individual `Package.swift` files in `/Packages/`

---

*This document provides the definitive import patterns for ManifestAndMatchV7 development. All examples are tested and optimized for the 357x Thompson Sampling performance advantage while maintaining clean architecture boundaries.*