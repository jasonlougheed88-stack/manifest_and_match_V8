# PHASE 3.5: BLOCKER RESOLUTION GUIDE
## Critical Issues & Fixes Before Week 11 Implementation

**Created**: November 1, 2025
**Purpose**: Resolve all guardian-identified blockers before Phase 3.5 implementation
**Target Completion**: Before Week 11 Day 1
**Estimated Time**: 4-6 hours of focused work

---

## EXECUTIVE SUMMARY

**Status**: 3 critical blockers + 5 high-priority issues identified by guardian review

**Impact**: Cannot proceed to Week 11 until blockers resolved

**Good News**: All issues are fixable with straightforward solutions (no architectural redesign needed)

**Timeline**: 1 day of pre-work clears all blockers

---

## TABLE OF CONTENTS

1. [Critical Blocker 1: Validation Overhead Not Benchmarked](#blocker-1)
2. [Critical Blocker 2: FastBehavioralLearning Not Optimized](#blocker-2)
3. [Critical Blocker 3: Actor Isolation Incorrect](#blocker-3)
4. [High Priority 4: Event Log PII Risk](#high-priority-4)
5. [High Priority 5: Foundation Models Privacy](#high-priority-5)
6. [High Priority 6-8: Quick Wins](#high-priority-6-8)
7. [Pre-Week 11 Checklist](#pre-week-11-checklist)
8. [Validation Tests](#validation-tests)

---

<a name="blocker-1"></a>
## 🔴 CRITICAL BLOCKER 1: Validation Overhead Not Benchmarked

### The Problem

**Guardian**: thompson-performance-guardian
**Severity**: BLOCKING
**Location**: Lines 679-729, 832-899, 1276-1278 (PHASE_3.5_CHECKLIST_INTEGRATED_v3.md)

**Issue**:
```
Phase 3.5 adds 3 validation layers per swipe:
1. BehavioralEventLog.recordSwipe() + markProcessed()
2. DataFlowMonitor.recordSwipe() + recordFastProcessing()
3. ConfidenceReconciler.reconcile() (when needed)

Claimed overhead: <1ms per swipe (Line 1276)
Evidence provided: NONE
Risk: Could push fast learning from 10ms → 15ms
```

**Why This Matters**:

Your sacred <10ms Thompson Sampling budget has ZERO safety margin. If validation secretly adds 2ms overhead, you violate the 357x performance advantage that defines ManifestAndMatchV7's competitive moat.

**Current Risk Level**: 🔴 HIGH - Could silently break performance guarantee

---

### The Solution

**Test First, Then Implement**

**File**: `Tests/V7AITests/ValidationPerformanceTests.swift` (NEW)

```swift
import XCTest
@testable import V7AI
@testable import V7Services

@MainActor
final class ValidationPerformanceTests: XCTestCase {

    /// CRITICAL: Validation overhead must be <1ms per swipe
    /// This test MUST PASS before Week 11 implementation begins
    func testValidationOverhead() async throws {
        // Setup
        let eventLog = BehavioralEventLog()
        let monitor = DataFlowMonitor(eventLog: eventLog)
        let mockJob = createMockJob()

        var latencies: [Double] = []

        // Test 1000 swipes to get statistical confidence
        for _ in 0..<1000 {
            let start = CFAbsoluteTimeGetCurrent()

            // This is exactly what happens per swipe
            let eventId = await eventLog.recordSwipe(job: mockJob, action: .interested)
            await monitor.recordSwipe()
            await eventLog.markProcessed(eventId: eventId, by: .fastLearning)
            await monitor.recordFastProcessing()

            let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000  // Convert to ms
            latencies.append(elapsed)
        }

        // Calculate statistics
        let sorted = latencies.sorted()
        let median = sorted[500]
        let p95 = sorted[950]
        let p99 = sorted[990]
        let max = sorted[999]

        // Print results for documentation
        print("""

        ═══════════════════════════════════════════════════════
        VALIDATION OVERHEAD BENCHMARK RESULTS
        ═══════════════════════════════════════════════════════
        Samples:     1000
        Median:      \(String(format: "%.3f", median))ms
        P95:         \(String(format: "%.3f", p95))ms
        P99:         \(String(format: "%.3f", p99))ms
        Max:         \(String(format: "%.3f", max))ms

        Target:      <1.0ms median, <2.0ms P95
        Status:      \(median < 1.0 && p95 < 2.0 ? "✅ PASS" : "❌ FAIL")
        ═══════════════════════════════════════════════════════

        """)

        // Hard requirements
        XCTAssertLessThan(median, 1.0,
            "BLOCKER: Median validation overhead \(median)ms exceeds 1.0ms budget")
        XCTAssertLessThan(p95, 2.0,
            "WARNING: P95 validation overhead \(p95)ms exceeds 2.0ms target")
    }

    // Helper
    private func createMockJob() -> V7Services.JobItem {
        return JobItem(
            id: UUID(),
            title: "Software Engineer",
            company: "Example Corp",
            location: "San Francisco, CA",
            description: "We're looking for an experienced engineer...",
            salary: "$120,000 - $180,000",
            isRemote: false,
            tags: ["Swift", "iOS", "SwiftUI"],
            thompsonScore: 0.85,
            fitScore: 0.75
        )
    }
}
```

---

### Decision Tree: What If Test Fails?

**If median > 1.0ms:**

**Option A: Simplify Validation (Recommended)**
```swift
// Remove DataFlowMonitor (least critical)
// Keep only BehavioralEventLog (essential for data integrity)

// Before:
await eventLog.recordSwipe(...)
await monitor.recordSwipe()           // ← Remove this
await eventLog.markProcessed(...)
await monitor.recordFastProcessing()  // ← Remove this

// After:
await eventLog.recordSwipe(...)
await eventLog.markProcessed(...)
// Monitor diagnostics moved to background task (every 50 swipes)
```

**Option B: Async Validation (Advanced)**
```swift
// Don't block swipe, process validation in background
Task.detached(priority: .background) {
    await eventLog.recordSwipe(...)
    await monitor.recordSwipe()
}
// Swipe continues immediately
```

**My Recommendation**: Run test FIRST. If it passes (<1ms), proceed. If fails, use Option A.

---

### Acceptance Criteria

- [ ] testValidationOverhead() passes with median <1.0ms
- [ ] P95 latency <2.0ms (allows some outliers)
- [ ] Results documented in test output
- [ ] If test fails, mitigation strategy decided (Option A or B)

**Status**: ⏸️ BLOCKED until test written and passed

---

<a name="blocker-2"></a>
## 🔴 CRITICAL BLOCKER 2: FastBehavioralLearning Not Optimized

### The Problem

**Guardian**: thompson-performance-guardian
**Severity**: BLOCKING
**Location**: Lines 552-613 (FastBehavioralLearning.swift implementation)

**Issue**:
```swift
// Current implementation (Lines 552-575):
private func updateQuickRIASEC(from description: String, action: SwipeAction) {
    let lower = description.lowercased()

    // 6 dimensions × multiple contains() = 6-12 O(n) operations
    if lower.contains("hands-on") || lower.contains("mechanical") {
        profile.quickRIASEC["Realistic"]! += weight
    }
    if lower.contains("research") || lower.contains("analytical") {
        profile.quickRIASEC["Investigative"]! += weight
    }
    // ... 4 more dimensions
}

// Similar pattern for Work Styles (Lines 582-613): 7 more dimensions
```

**Performance Analysis**:

| Scenario | Description Length | String Operations | Estimated Time |
|----------|-------------------|-------------------|----------------|
| Small job | 500 chars | 13 × 500 = 6,500 | ~2ms |
| Average job | 2,000 chars | 13 × 2,000 = 26,000 | ~6ms |
| Large job | 5,000 chars | 13 × 5,000 = 65,000 | ~12ms ❌ |

**Problem**: Worst-case exceeds 10ms budget (VIOLATES SACRED CONSTRAINT)

**Current Risk Level**: 🔴 HIGH - Will fail on large job descriptions

---

### The Solution

**Pre-Compute Keyword Sets + Set Intersection**

**Complexity Improvement**:
```
Before: 13 × O(n) = O(13n)
After:  1 × O(n) tokenize + 13 × O(1) set ops = O(n)
Speedup: 5-10x faster
```

**File**: `Packages/V7AI/Sources/V7AI/Services/FastBehavioralLearning.swift`

```swift
import Foundation
import V7Core
import V7Services

@MainActor
public final class FastBehavioralLearning {

    // OPTIMIZATION: Pre-compute keyword sets at initialization
    // This executes ONCE, not per swipe
    private let riasecKeywordSets: [String: Set<String>] = [
        "Realistic": Set([
            "hands-on", "mechanical", "physical", "tools", "equipment",
            "outdoor", "athletic", "building", "repairing", "operating"
        ]),
        "Investigative": Set([
            "research", "analytical", "analyze", "data", "study",
            "science", "investigate", "problem-solving", "testing", "experiments"
        ]),
        "Artistic": Set([
            "creative", "design", "art", "imagination", "original",
            "visual", "music", "writing", "performance", "innovative"
        ]),
        "Social": Set([
            "teaching", "helping", "care", "people", "community",
            "counseling", "training", "mentoring", "support", "service"
        ]),
        "Enterprising": Set([
            "leadership", "persuade", "sales", "manage", "business",
            "entrepreneurial", "negotiating", "strategy", "influence", "competitive"
        ]),
        "Conventional": Set([
            "organized", "detail", "accuracy", "systematic", "records",
            "data-entry", "filing", "bookkeeping", "clerical", "procedures"
        ])
    ]

    private let workStyleKeywordSets: [String: Set<String>] = [
        "achievement": Set([
            "ambitious", "goal", "driven", "accomplish", "excel",
            "persistent", "initiative", "achievement", "results-oriented"
        ]),
        "socialInfluence": Set([
            "leadership", "lead", "manage", "influence", "persuade",
            "inspire", "motivate", "coordinate", "direct"
        ]),
        "interpersonal": Set([
            "team", "collaborate", "cooperation", "friendly", "supportive",
            "empathy", "communication", "relationship", "group"
        ]),
        "adjustment": Set([
            "fast-paced", "startup", "dynamic", "stress", "pressure",
            "adaptable", "flexible", "resilient", "change"
        ]),
        "conscientiousness": Set([
            "detail", "precision", "accuracy", "thorough", "careful",
            "quality", "attention", "meticulous", "reliable"
        ]),
        "independence": Set([
            "independent", "autonomy", "self-directed", "entrepreneurial",
            "initiative", "self-motivated", "ownership", "solo"
        ]),
        "practicalIntelligence": Set([
            "innovation", "analytical", "problem-solving", "creative",
            "strategic", "critical-thinking", "intellectual", "complex"
        ])
    ]

    // ... existing properties ...

    // OPTIMIZED: O(n) tokenization + O(1) set intersections
    private func updateQuickRIASEC(from description: String, action: SwipeAction) {
        // Tokenize description ONCE
        let words = Set(
            description.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { $0.count > 2 }  // Ignore short words like "to", "a", etc.
        )

        let weight = action == .interested || action == .save ? 0.05 : -0.03

        // O(1) set intersection for each dimension (much faster than contains)
        for (dimension, keywords) in riasecKeywordSets {
            if !words.isDisjoint(with: keywords) {  // Fast set operation
                profile.quickRIASEC[dimension]! += weight
            }
        }

        // Clamp to 0-1 range
        for key in profile.quickRIASEC.keys {
            profile.quickRIASEC[key] = max(0.0, min(1.0, profile.quickRIASEC[key]!))
        }
    }

    // OPTIMIZED: Same pattern for Work Styles
    private func updateQuickWorkStyles(from description: String, action: SwipeAction) {
        let words = Set(
            description.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { $0.count > 2 }
        )

        let weight = action == .interested || action == .save ? 0.1 : -0.06

        for (style, keywords) in workStyleKeywordSets {
            if !words.isDisjoint(with: keywords) {
                profile.quickWorkStyles[style]! += weight
            }
        }

        // Clamp to 1-5 range
        for key in profile.quickWorkStyles.keys {
            profile.quickWorkStyles[key] = max(1.0, min(5.0, profile.quickWorkStyles[key]!))
        }
    }

    // OPTIMIZATION: Share tokenization between RIASEC and Work Styles
    private func updateProfiles(from description: String, action: SwipeAction) {
        // Tokenize ONCE, use for both
        let words = Set(
            description.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter { $0.count > 2 }
        )

        // Update RIASEC
        let riasecWeight = action == .interested || action == .save ? 0.05 : -0.03
        for (dimension, keywords) in riasecKeywordSets {
            if !words.isDisjoint(with: keywords) {
                profile.quickRIASEC[dimension]! += riasecWeight
            }
        }

        // Update Work Styles (same tokenized words)
        let styleWeight = action == .interested || action == .save ? 0.1 : -0.06
        for (style, keywords) in workStyleKeywordSets {
            if !words.isDisjoint(with: keywords) {
                profile.quickWorkStyles[style]! += styleWeight
            }
        }

        // Clamp all values
        for key in profile.quickRIASEC.keys {
            profile.quickRIASEC[key] = max(0.0, min(1.0, profile.quickRIASEC[key]!))
        }
        for key in profile.quickWorkStyles.keys {
            profile.quickWorkStyles[key] = max(1.0, min(5.0, profile.quickWorkStyles[key]!))
        }
    }
}
```

---

### Performance Validation Test

**File**: `Tests/V7AITests/FastBehavioralLearningPerformanceTests.swift` (NEW)

```swift
import XCTest
@testable import V7AI
@testable import V7Services

@MainActor
final class FastBehavioralLearningPerformanceTests: XCTestCase {

    /// CRITICAL: Fast learning must complete in <10ms per swipe
    func testFastLearningPerformance() async throws {
        let engine = FastBehavioralLearning()

        // Test with worst-case: 5000-character job description
        let largeJob = createLargeJob(descriptionLength: 5000)

        var latencies: [Double] = []

        // Run 100 iterations for statistical confidence
        for _ in 0..<100 {
            let start = CFAbsoluteTimeGetCurrent()

            let _ = engine.processSwipe(
                job: largeJob,
                action: .interested,
                thompsonScore: 0.85
            )

            let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
            latencies.append(elapsed)
        }

        let sorted = latencies.sorted()
        let median = sorted[50]
        let p95 = sorted[95]
        let max = sorted[99]

        print("""

        ═══════════════════════════════════════════════════════
        FAST LEARNING PERFORMANCE (5000-char job description)
        ═══════════════════════════════════════════════════════
        Samples:     100
        Median:      \(String(format: "%.3f", median))ms
        P95:         \(String(format: "%.3f", p95))ms
        Max:         \(String(format: "%.3f", max))ms

        Target:      <10.0ms median (SACRED CONSTRAINT)
        Status:      \(median < 10.0 ? "✅ PASS" : "❌ FAIL")
        ═══════════════════════════════════════════════════════

        """)

        XCTAssertLessThan(median, 10.0,
            "SACRED CONSTRAINT VIOLATED: Fast learning \(median)ms exceeds 10ms budget")
    }

    private func createLargeJob(descriptionLength: Int) -> JobItem {
        // Generate realistic large job description
        let description = """
        We are seeking an experienced Software Engineer to join our team.

        Responsibilities:
        - Design and implement scalable backend systems
        - Collaborate with cross-functional teams
        - Participate in code reviews and architectural decisions
        - Mentor junior engineers

        Requirements:
        - 5+ years of professional software development experience
        - Strong analytical and problem-solving skills
        - Experience with Python, Java, or similar languages
        - Excellent communication and leadership abilities
        - Detail-oriented with a focus on quality
        - Ability to work independently in a fast-paced environment

        """

        // Pad to desired length
        let padding = String(repeating: description, count: descriptionLength / description.count)

        return JobItem(
            id: UUID(),
            title: "Senior Software Engineer",
            company: "Tech Company",
            location: "San Francisco, CA",
            description: String(padding.prefix(descriptionLength)),
            salary: "$150,000 - $200,000",
            isRemote: false,
            tags: ["Python", "Java", "Backend", "Leadership"],
            thompsonScore: 0.85,
            fitScore: 0.75
        )
    }
}
```

---

### Expected Results

**Before Optimization** (string.contains() approach):
```
Median:      ~8-12ms
P95:         ~15-20ms
Status:      ❌ FAIL (exceeds 10ms budget)
```

**After Optimization** (Set intersection approach):
```
Median:      ~2-3ms
P95:         ~4-5ms
Status:      ✅ PASS (well within 10ms budget)
```

---

### Acceptance Criteria

- [ ] Keyword sets pre-computed at initialization
- [ ] updateProfiles() uses Set intersection (not contains)
- [ ] Single tokenization shared between RIASEC and Work Styles
- [ ] testFastLearningPerformance() passes with median <10ms
- [ ] Works correctly on 5000-character job descriptions

**Status**: ⏸️ BLOCKED until optimization implemented and tested

---

<a name="blocker-3"></a>
## 🔴 CRITICAL BLOCKER 3: Actor Isolation Incorrect

### The Problem

**Guardian**: swift-concurrency-enforcer
**Severity**: BLOCKING
**Location**: Lines 902-984, specifically Line 913 (DeckScreen integration)

**Issue**:
```swift
// This code is WRONG (from checklist Line 913):
@MainActor
struct DeckScreen: View {
    @StateObject private var eventLog = BehavioralEventLog()
    //           ↑ ERROR: Cannot use actor as @StateObject
}
```

**Why This Breaks**:

1. `@StateObject` requires `ObservableObject` conformance
2. `ObservableObject` is implicitly `@MainActor`-bound
3. `actor BehavioralEventLog` is NOT `@MainActor` (it's its own actor)
4. Swift 6 compiler error: **"Actor-isolated property cannot be @StateObject"**

**Root Cause**: Mixing actor isolation models incorrectly

**Current Risk Level**: 🔴 CRITICAL - Code won't compile in Swift 6 strict mode

---

### The Solution

**Use Plain Properties for Actors (Not @StateObject)**

**File**: `Packages/V7UI/Sources/V7UI/Views/DeckScreen.swift`

```swift
import SwiftUI
import V7Core
import V7Services
import V7Thompson
import V7AI

@MainActor
public struct DeckScreen: View {
    // MARK: - State (MainActor-bound)

    @State private var currentIndex = 0
    @State private var currentCards: [CardType] = []
    @State private var jobIdMapping: [UUID: Job] = [:]
    @State private var swipeCount = 0

    // MARK: - Services (MainActor-bound, can use @StateObject)

    @StateObject private var appState = AppState()
    @StateObject private var jobCoordinator = JobDiscoveryCoordinator()
    @StateObject private var profileManager = ProfileManager()

    // MARK: - Fast Learning (MainActor-bound)

    @StateObject private var fastLearningEngine = FastBehavioralLearning()
    // ↑ This is OK because FastBehavioralLearning is @MainActor

    // MARK: - Actors (NOT @StateObject - just plain properties)

    // ✅ CORRECT: Actors as plain properties
    private let eventLog = BehavioralEventLog()
    private let deepAnalysisEngine = DeepBehavioralAnalysis()

    // Initialize with dependencies
    private let dataFlowMonitor: DataFlowMonitor

    public init() {
        // Create event log first
        let log = BehavioralEventLog()
        self.eventLog = log

        // Pass to monitor
        self.dataFlowMonitor = DataFlowMonitor(eventLog: log)
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            // ... existing UI code ...
        }
        .task {
            await loadInitialJobs()
        }
    }

    // MARK: - Swipe Handling

    private func handleSwipeAction(_ action: SwipeAction) {
        let currentCard = currentCards[currentIndex]
        guard case .job(let currentJobItem) = currentCard else { return }
        guard let originalJob = jobIdMapping[currentJobItem.id] else { return }

        // Create async context for actor calls
        Task {
            // STEP 1: Record to immutable event log
            let eventId = await eventLog.recordSwipe(
                job: originalJob,
                action: action
            )
            await dataFlowMonitor.recordSwipe()

            // STEP 2: Fast learning (MainActor, no await needed)
            let result = fastLearningEngine.processSwipe(
                job: originalJob,
                action: action,
                thompsonScore: currentJobItem.thompsonScore
            )

            // STEP 3: Mark as processed
            await eventLog.markProcessed(eventId: eventId, by: .fastLearning)
            await dataFlowMonitor.recordFastProcessing()

            // STEP 4: Trigger adaptive question if needed
            if result.shouldAskQuestion {
                await triggerAdaptiveQuestion(gaps: result.detectedGaps)
            }

            // STEP 5: Background deep analysis (every 10 swipes)
            swipeCount += 1
            if swipeCount % 10 == 0 {
                await triggerDeepAnalysis()
            }

            // STEP 6: Periodic health check (every 50 swipes)
            if swipeCount % 50 == 0 {
                await dataFlowMonitor.printDiagnostics()
            }
        }

        // STEP 7: Existing Thompson update (synchronous)
        Task {
            await jobCoordinator.processInteraction(
                jobId: originalJob.id,
                action: thompsonAction
            )
        }
    }

    // MARK: - Background Processing

    private func triggerDeepAnalysis() async {
        // Get unprocessed events
        let unprocessed = await eventLog.getUnprocessed(for: .deepAnalysis)

        guard unprocessed.count >= 10 else { return }

        // Run deep analysis in background
        Task.detached(priority: .background) {
            do {
                let insights = try await deepAnalysisEngine.analyzeBatch(unprocessed)

                // Update profile with insights
                await updateProfileFromInsights(insights)

                // Mark events as processed
                for event in unprocessed {
                    await eventLog.markProcessed(event.id, by: .deepAnalysis)
                }

                await dataFlowMonitor.recordDeepProcessing()

            } catch {
                print("Deep analysis failed: \(error)")
            }
        }
    }
}
```

---

### Key Pattern Rules

**Rule 1: @MainActor classes/structs → Use @StateObject**
```swift
@MainActor
class FastBehavioralLearning: ObservableObject {  // ✅ OK
    // ...
}

@StateObject private var fastLearning = FastBehavioralLearning()  // ✅ OK
```

**Rule 2: Actors → Use plain properties**
```swift
actor BehavioralEventLog {  // ✅ OK
    // ...
}

private let eventLog = BehavioralEventLog()  // ✅ OK
// NOT: @StateObject private var eventLog = ...  // ❌ WRONG
```

**Rule 3: Actor calls require await**
```swift
// Calling actor methods from @MainActor context
Task {
    await eventLog.recordSwipe(...)  // ✅ Needs await
}
```

**Rule 4: Background actor work**
```swift
// Detached tasks for true background processing
Task.detached(priority: .background) {
    await someActor.doWork()  // Runs off main thread
}
```

---

### Decision: Should BehavioralEventLog Be Actor or @MainActor?

**Analysis**:

| Option | Pros | Cons | Recommendation |
|--------|------|------|----------------|
| **actor** | ✅ Thread-safe<br>✅ Non-blocking<br>✅ Can be called from background | ⚠️ Requires await<br>⚠️ More complex | ✅ **RECOMMENDED** |
| **@MainActor class** | ✅ No await needed<br>✅ Can use @StateObject | ❌ Blocks main thread<br>❌ Background tasks can't access | ❌ Not recommended |

**Decision**: Keep as `actor` for thread safety and performance

---

### Acceptance Criteria

- [ ] BehavioralEventLog declared as `actor` (not @MainActor, not class)
- [ ] DeckScreen uses plain property for eventLog (not @StateObject)
- [ ] All actor calls use `await`
- [ ] Background tasks use Task.detached for true async
- [ ] Code compiles with Swift 6 strict concurrency enabled
- [ ] No compiler warnings about actor isolation

**Status**: ⏸️ BLOCKED until actor pattern corrected

---

<a name="high-priority-4"></a>
## 🟡 HIGH PRIORITY 4: Event Log Stores Full Job Descriptions (PII Risk)

### The Problem

**Guardian**: privacy-security-guardian
**Severity**: HIGH
**Location**: Lines 693-701 (BehavioralEvent structure)

**Issue**:
```swift
public struct BehavioralEvent: Sendable, Codable {
    let data: EventData
}

public enum EventData {
    case swipe(job: JobItem, action: SwipeAction)
    //         ↑ Stores ENTIRE job object (5KB+)
    //           Including full 5000-character description
}
```

**Privacy Risks**:

1. **Company-Confidential Information**: Job descriptions may contain:
   - Unannounced products/features
   - Internal team structures
   - Budget/salary ranges
   - Tech stack details

2. **Data Retention**: Stored for 1 hour (line 716 pruning policy)

3. **Memory Overhead**: 5KB per event × 100 swipes = 500KB unnecessary data

**Current Risk Level**: 🟡 HIGH - Privacy violation + memory waste

---

### The Solution

**Store Identifiers Only, Retrieve On-Demand**

**File**: `Packages/V7AI/Sources/V7AI/Services/BehavioralEventLog.swift`

```swift
import Foundation
import V7Services

actor BehavioralEventLog {

    // MARK: - Sanitized Event Structure

    /// Minimal event data - stores IDs only (not full content)
    public struct BehavioralEvent: Sendable, Codable {
        let id: UUID
        let timestamp: Date
        let type: EventType

        // ✅ SANITIZED: Store job ID only (not full job)
        let jobId: UUID
        let action: SwipeAction

        // Processing state
        let processedByFastLearning: Bool
        let processedByDeepAnalysis: Bool
        let appliedToThompson: Bool
    }

    public enum EventType: String, Codable {
        case swipe
        case questionAnswer
        case profileUpdate
        case thompsonUpdate
    }

    public enum SwipeAction: String, Codable {
        case interested
        case pass
        case save
    }

    // MARK: - Properties

    private var events: [BehavioralEvent] = []
    private let maxRetention: TimeInterval = 3600  // 1 hour

    // MARK: - Public API

    /// Record swipe event (stores ID only)
    public func recordSwipe(job: JobItem, action: SwipeAction) -> UUID {
        let eventId = UUID()

        let event = BehavioralEvent(
            id: eventId,
            timestamp: Date(),
            type: .swipe,
            jobId: job.id,  // ✅ ID only (16 bytes vs 5KB)
            action: action,
            processedByFastLearning: false,
            processedByDeepAnalysis: false,
            appliedToThompson: false
        )

        events.append(event)

        // Prune old events
        pruneOldEvents()

        return eventId
    }

    /// Mark event as processed (idempotent)
    public func markProcessed(eventId: UUID, by processor: Processor) {
        guard let index = events.firstIndex(where: { $0.id == eventId }) else {
            return
        }

        var event = events[index]

        switch processor {
        case .fastLearning:
            event = BehavioralEvent(
                id: event.id,
                timestamp: event.timestamp,
                type: event.type,
                jobId: event.jobId,
                action: event.action,
                processedByFastLearning: true,  // ✅ Update
                processedByDeepAnalysis: event.processedByDeepAnalysis,
                appliedToThompson: event.appliedToThompson
            )

        case .deepAnalysis:
            event = BehavioralEvent(
                id: event.id,
                timestamp: event.timestamp,
                type: event.type,
                jobId: event.jobId,
                action: event.action,
                processedByFastLearning: event.processedByFastLearning,
                processedByDeepAnalysis: true,  // ✅ Update
                appliedToThompson: event.appliedToThompson
            )

        case .thompson:
            event = BehavioralEvent(
                id: event.id,
                timestamp: event.timestamp,
                type: event.type,
                jobId: event.jobId,
                action: event.action,
                processedByFastLearning: event.processedByFastLearning,
                processedByDeepAnalysis: event.processedByDeepAnalysis,
                appliedToThompson: true  // ✅ Update
            )
        }

        events[index] = event
    }

    /// Get unprocessed events for a specific processor
    public func getUnprocessed(for processor: Processor) -> [BehavioralEvent] {
        return events.filter { event in
            switch processor {
            case .fastLearning:
                return !event.processedByFastLearning
            case .deepAnalysis:
                return !event.processedByDeepAnalysis
            case .thompson:
                return !event.appliedToThompson
            }
        }
    }

    // MARK: - Data Retrieval

    /// Get job IDs for events (caller retrieves full jobs if needed)
    public func getJobIds(for eventIds: [UUID]) -> [UUID] {
        return events
            .filter { eventIds.contains($0.id) }
            .map { $0.jobId }
    }

    // MARK: - Validation

    public func validate() -> ValidationResult {
        var issues: [String] = []

        // Detect stale events (>5min unprocessed)
        let staleThreshold = Date().addingTimeInterval(-300)
        let staleEvents = events.filter {
            $0.timestamp < staleThreshold && !$0.processedByFastLearning
        }

        if !staleEvents.isEmpty {
            issues.append("⚠️ \(staleEvents.count) swipes not processed by fast learning")
        }

        // Detect large backlog
        let unanalyzed = events.filter { !$0.processedByDeepAnalysis }
        if unanalyzed.count > 50 {
            issues.append("⚠️ \(unanalyzed.count) swipes pending deep analysis")
        }

        return ValidationResult(
            isHealthy: issues.isEmpty,
            issues: issues,
            totalEvents: events.count
        )
    }

    // MARK: - Pruning

    /// Remove events older than retention period
    private func pruneOldEvents() {
        let cutoff = Date().addingTimeInterval(-maxRetention)
        events.removeAll { $0.timestamp < cutoff }
    }

    /// Force prune all processed events (memory pressure)
    public func pruneProcessedEvents() {
        events.removeAll {
            $0.processedByFastLearning &&
            $0.processedByDeepAnalysis &&
            $0.appliedToThompson
        }
    }
}

// MARK: - Supporting Types

public enum Processor {
    case fastLearning
    case deepAnalysis
    case thompson
}

public struct ValidationResult {
    public let isHealthy: Bool
    public let issues: [String]
    public let totalEvents: Int
}
```

---

### Integration with Job Retrieval

**File**: `Packages/V7UI/Sources/V7UI/Views/DeckScreen.swift`

```swift
// When deep analysis needs full job data:
private func triggerDeepAnalysis() async {
    let unprocessed = await eventLog.getUnprocessed(for: .deepAnalysis)

    guard unprocessed.count >= 10 else { return }

    // Retrieve job IDs
    let jobIds = await eventLog.getJobIds(for: unprocessed.map { $0.id })

    // Fetch full jobs from coordinator (which has them cached)
    let jobs = jobIds.compactMap { jobId in
        jobIdMapping[jobId]  // Already in memory
    }

    // Create SwipeRecords for analysis
    let swipeRecords = zip(unprocessed, jobs).map { event, job in
        SwipeRecord(
            job: job,
            action: event.action,
            timestamp: event.timestamp
        )
    }

    // Analyze
    Task.detached(priority: .background) {
        let insights = try await deepAnalysisEngine.analyzeBatch(swipeRecords)
        // ... rest of processing
    }
}
```

---

### Privacy Benefits

**Before** (storing full jobs):
```
Event log memory: 5KB × 100 events = 500KB
Privacy risk: HIGH (full job descriptions retained)
Retention: 1 hour of confidential data
```

**After** (storing IDs only):
```
Event log memory: 32 bytes × 100 events = 3.2KB
Privacy risk: LOW (only identifiers retained)
Retention: 1 hour of non-sensitive IDs
Memory savings: 98.5% reduction
```

---

### Acceptance Criteria

- [ ] BehavioralEvent stores jobId only (not full JobItem)
- [ ] getJobIds() method retrieves IDs for job lookup
- [ ] DeckScreen retrieves full jobs from existing jobIdMapping
- [ ] Memory usage reduced by >95%
- [ ] No confidential job content retained in event log

**Status**: 🟡 HIGH PRIORITY - Implement Week 11

---

<a name="high-priority-5"></a>
## 🟡 HIGH PRIORITY 5: Foundation Models Privacy Not Documented

### The Problem

**Guardian**: privacy-security-guardian
**Severity**: HIGH
**Location**: Lines 743-767, 1090-1113 (DeepBehavioralAnalysis)

**Issue**:
- Claims "on-device processing" but no verification
- No documentation of cloud fallback policy
- User consent not mentioned
- Privacy guarantees unclear

**Risk**: Users may think their swipe data is being sent to cloud AI

**Current Risk Level**: 🟡 HIGH - Trust issue

---

### The Solution

**Explicit Privacy Documentation + No-Cloud-Fallback Enforcement**

**File**: `Packages/V7AI/Sources/V7AI/Services/DeepBehavioralAnalysis.swift`

```swift
import Foundation
import V7Core
import V7Services

/// Deep behavioral analysis using iOS 26 Foundation Models
///
/// # Privacy Guarantee
///
/// This service provides **100% on-device AI processing** with these guarantees:
///
/// - ✅ **No network requests**: All analysis runs locally on device
/// - ✅ **No cloud fallback**: If Foundation Models unavailable, returns approximations only
/// - ✅ **No data sent to Apple**: Processing uses local Neural Engine only
/// - ✅ **No data sent to third parties**: Zero external API calls
/// - ✅ **Private by design**: Job swipe data never leaves the device
///
/// # Device Requirements
///
/// Foundation Models requires:
/// - iPhone 15 Pro, 15 Pro Max, or iPhone 16 (all models)
/// - iPad mini (A17 Pro) or iPad with M1+ chip
/// - iOS 26.0 or later
///
/// # Fallback Behavior
///
/// If Foundation Models is unavailable (older devices), this service:
/// - Returns fast learning approximations instead
/// - Does NOT fall back to cloud AI services
/// - Gracefully degrades to rule-based analysis
///
/// # Performance
///
/// - Typical batch (10 swipes): 1-2 seconds
/// - Processes in background (doesn't block UI)
/// - Results cached to avoid redundant analysis
///
@MainActor
public final class DeepBehavioralAnalysis {

    // MARK: - Types

    @Generable
    public struct DeepInsights: Sendable {
        // ... existing structure ...
    }

    // MARK: - Properties

    private var session: LanguageModelSession?
    private var analysisCache: [String: CacheEntry] = [:]

    private struct CacheEntry {
        let insights: DeepInsights
        let timestamp: Date
    }

    // MARK: - Availability Check

    /// Check if Foundation Models is available on this device
    public static var isAvailable: Bool {
        if #available(iOS 26.0, *) {
            return FoundationModels.isSupported
        }
        return false
    }

    // MARK: - Initialization

    public init() {
        // Only initialize if Foundation Models available
        guard Self.isAvailable else {
            print("ℹ️ Foundation Models unavailable - using fast learning approximations only")
            return
        }

        // Initialize on-device AI session
        session = LanguageModelSession(instructions: """
        You are an expert career psychologist analyzing job search behavior.

        Your role:
        - Analyze patterns in job swipes to infer personality (RIASEC - WHAT they like)
        - Infer work styles (HOW they approach work - O*NET 7 dimensions)
        - Detect career transitions from exploration patterns
        - Rank work activity preferences based on job descriptions
        - Infer company culture preferences

        You provide:
        - Evidence-based insights (cite specific behaviors)
        - Confidence scores for each inference
        - Actionable recommendations

        You are concise, accurate, and data-driven.
        """)

        // Prewarm session for faster first response
        Task {
            await session?.prewarm()
        }
    }

    // MARK: - Public API

    /// Analyze batch of swipes using on-device Foundation Models
    ///
    /// - Parameter swipes: Array of job swipe records to analyze
    /// - Returns: Deep insights about user's career preferences
    /// - Throws: AnalysisError if Foundation Models unavailable or analysis fails
    ///
    /// # Privacy
    /// This method performs 100% on-device processing. No data leaves the device.
    ///
    /// # Performance
    /// Typical execution time: 1-2 seconds for 10 swipes
    ///
    public func analyzeBatch(_ swipes: [SwipeRecord]) async throws -> DeepInsights {
        // PRIVACY CHECK: Ensure Foundation Models available
        guard Self.isAvailable, let session = session else {
            // NO CLOUD FALLBACK - return fast learning approximations
            throw AnalysisError.foundationModelsUnavailable
        }

        // Check cache (avoid redundant analysis)
        let cacheKey = buildCacheKey(swipes)
        if let cached = getCachedInsights(for: cacheKey) {
            return cached
        }

        // Build analysis prompt
        let prompt = buildAnalysisPrompt(swipes: swipes)

        // Perform on-device analysis
        let insights = try await session.respond(
            to: prompt,
            generating: DeepInsights.self
        )

        // Cache result
        cacheInsights(insights, for: cacheKey)

        return insights
    }

    // MARK: - Error Handling

    public enum AnalysisError: Error, LocalizedError {
        case foundationModelsUnavailable
        case analysisTimeout
        case invalidResponse

        public var errorDescription: String? {
            switch self {
            case .foundationModelsUnavailable:
                return "Foundation Models is not available on this device. Using fast learning approximations instead."
            case .analysisTimeout:
                return "AI analysis took too long. Try again with fewer swipes."
            case .invalidResponse:
                return "AI returned invalid insights. Using cached results instead."
            }
        }
    }

    // MARK: - Cache Management

    private func buildCacheKey(_ swipes: [SwipeRecord]) -> String {
        // Create stable hash of swipe patterns
        return swipes
            .map { "\($0.job.id):\($0.action.rawValue)" }
            .joined(separator: "|")
    }

    private func getCachedInsights(for key: String) -> DeepInsights? {
        guard let cached = analysisCache[key] else { return nil }

        // Expire after 24 hours
        let age = Date().timeIntervalSince(cached.timestamp)
        if age > 86400 {
            analysisCache.removeValue(forKey: key)
            return nil
        }

        return cached.insights
    }

    private func cacheInsights(_ insights: DeepInsights, for key: String) {
        analysisCache[key] = CacheEntry(
            insights: insights,
            timestamp: Date()
        )

        // Limit cache size (memory management)
        if analysisCache.count > 50 {
            pruneOldCache()
        }
    }

    private func pruneOldCache() {
        let sortedEntries = analysisCache.sorted { $0.value.timestamp < $1.value.timestamp }
        let toRemove = sortedEntries.prefix(20)
        for (key, _) in toRemove {
            analysisCache.removeValue(forKey: key)
        }
    }

    // ... rest of implementation ...
}
```

---

### User-Facing Privacy Notice

**File**: `Packages/V7UI/Sources/V7UI/Views/PrivacyNoticeView.swift` (NEW)

```swift
import SwiftUI

struct PrivacyNoticeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Privacy")
                .font(.title2)
                .fontWeight(.bold)

            PrivacyItem(
                icon: "lock.shield.fill",
                title: "100% On-Device AI",
                description: "All career analysis happens locally on your iPhone. No data is sent to cloud services."
            )

            PrivacyItem(
                icon: "network.slash",
                title: "No Network Access",
                description: "Job swipe analysis never requires internet. Your preferences stay private."
            )

            PrivacyItem(
                icon: "externaldrive.fill",
                title: "Local Storage Only",
                description: "All data stays on your device. We never sync to cloud or third-party servers."
            )

            if !DeepBehavioralAnalysis.isAvailable {
                PrivacyItem(
                    icon: "info.circle.fill",
                    title: "Device Compatibility",
                    description: "Advanced AI features require iPhone 15 Pro or newer. Basic features work on all devices.",
                    color: .orange
                )
            }
        }
        .padding()
    }
}

struct PrivacyItem: View {
    let icon: String
    let title: String
    let description: String
    var color: Color = .blue

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

---

### Acceptance Criteria

- [ ] Privacy documentation added to DeepBehavioralAnalysis.swift
- [ ] No-cloud-fallback enforced (throws error instead)
- [ ] isAvailable check before any AI processing
- [ ] User-facing privacy notice created
- [ ] Error messages explain fallback behavior clearly

**Status**: 🟡 HIGH PRIORITY - Implement Week 12

---

<a name="high-priority-6-8"></a>
## 🟡 HIGH PRIORITY 6-8: Quick Wins

### Issue 6: Sendable Conformance Missing

**Guardian**: swift-concurrency-enforcer
**Fix Time**: 2 minutes

**File**: `Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift`

```swift
// BEFORE:
public struct JobItem: Identifiable {
    // ... properties ...
}

// AFTER:
public struct JobItem: Identifiable, Sendable {  // ✅ Add Sendable
    public let id: UUID
    public let title: String
    public let company: String
    public let location: String
    public let description: String
    public let salary: String?
    public let isRemote: Bool
    public let tags: [String]
    public let thompsonScore: Double
    public let fitScore: Double
}
```

**Validation**: Compile with Swift 6 strict concurrency → no warnings

---

### Issue 7: Background Tasks May Block Main Thread

**Guardian**: swift-concurrency-enforcer
**Fix Time**: 1 minute (verification only)

**File**: `Packages/V7AI/Sources/V7AI/Services/BehavioralEventLog.swift`

```swift
// VERIFY this is declared as actor (not @MainActor, not class):
actor BehavioralEventLog {  // ✅ CORRECT - won't block main thread
    // ...
}

// NOT:
@MainActor
class BehavioralEventLog {  // ❌ WRONG - would block main thread
}
```

**Validation**: Confirm actor keyword present

---

### Issue 8: Missing Performance Assertions

**Guardian**: thompson-performance-guardian
**Fix Time**: 5 minutes

**File**: `Packages/V7AI/Sources/V7AI/Services/FastBehavioralLearning.swift`

```swift
public func processSwipe(
    job: V7Services.JobItem,
    action: SwipeAction,
    thompsonScore: Double
) -> (shouldAskQuestion: Bool, confidence: [String: Double]) {

    // ✅ ADD: Performance validation
    let startTime = CFAbsoluteTimeGetCurrent()

    // ... existing processing logic ...

    // ✅ ADD: Assert budget not violated
    let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    assert(elapsed < 10.0,
        "SACRED CONSTRAINT VIOLATED: FastBehavioralLearning took \(elapsed)ms (limit: 10ms)")

    return (shouldAsk, confidenceScores)
}
```

**Validation**: Run debug build → assertion triggers if too slow

---

<a name="pre-week-11-checklist"></a>
## PRE-WEEK 11 IMPLEMENTATION CHECKLIST

### Day -1: Critical Blockers (4-6 hours)

**Morning (2-3 hours): Performance Testing**
- [ ] Create `Tests/V7AITests/ValidationPerformanceTests.swift`
- [ ] Implement `testValidationOverhead()` test
- [ ] Run test → document results
- [ ] If fails: Decide on mitigation (simplify or async validation)

**Afternoon (2-3 hours): Fast Learning Optimization**
- [ ] Create keyword sets in `FastBehavioralLearning.swift`
- [ ] Replace string.contains() with Set intersection
- [ ] Create `Tests/V7AITests/FastBehavioralLearningPerformanceTests.swift`
- [ ] Implement `testFastLearningPerformance()` test
- [ ] Run test with 5000-char job description → verify <10ms
- [ ] Document performance gains

---

### Day 0: High Priority (2-3 hours)

**Morning (1 hour): Actor Isolation**
- [ ] Fix `DeckScreen.swift` actor pattern (remove @StateObject for actors)
- [ ] Verify `BehavioralEventLog` declared as `actor`
- [ ] Test compilation with Swift 6 strict concurrency

**Midday (1 hour): Privacy Fixes**
- [ ] Sanitize `BehavioralEventLog` to store IDs only
- [ ] Add privacy documentation to `DeepBehavioralAnalysis`
- [ ] Create `PrivacyNoticeView.swift`

**Afternoon (30 min): Quick Wins**
- [ ] Add `Sendable` to `JobItem`
- [ ] Add performance assertions to all fast learning code
- [ ] Verify actor (not @MainActor) for background work

---

### Day 1: Validation & Sign-Off (1 hour)

- [ ] Run all performance tests → confirm passing
- [ ] Run Swift 6 strict concurrency build → confirm no warnings
- [ ] Review privacy documentation → confirm complete
- [ ] Document all benchmark results
- [ ] Update guardian sign-off document with "BLOCKERS RESOLVED"

**GO/NO-GO Decision**:
- ✅ All 3 critical blockers resolved → PROCEED to Week 11
- ⚠️ Any blocker unresolved → HOLD implementation

---

<a name="validation-tests"></a>
## VALIDATION TEST SUITE

### Complete Test File Structure

```
Tests/V7AITests/
├── ValidationPerformanceTests.swift           ← Blocker 1
├── FastBehavioralLearningPerformanceTests.swift  ← Blocker 2
├── ActorIsolationTests.swift                 ← Blocker 3
├── PrivacyComplianceTests.swift              ← High Priority 4-5
└── DataFlowValidationTests.swift             ← From original checklist
```

### Test Execution Order

**Phase 1: Performance (MUST PASS)**
```bash
# Run performance tests first
xcodebuild test -scheme V7AI \
    -only-testing:V7AITests/ValidationPerformanceTests \
    -only-testing:V7AITests/FastBehavioralLearningPerformanceTests

# Expected: ALL GREEN
```

**Phase 2: Concurrency (MUST COMPILE)**
```bash
# Compile with Swift 6 strict concurrency
swift build -Xswiftc -strict-concurrency=complete

# Expected: ZERO WARNINGS
```

**Phase 3: Privacy (MANUAL REVIEW)**
```bash
# Review privacy documentation
# Check: No cloud fallback code paths exist
# Check: All API calls are on-device only
```

---

## SUCCESS CRITERIA SUMMARY

| Issue | Criterion | Test Method | Pass Threshold |
|-------|-----------|-------------|----------------|
| Blocker 1 | Validation <1ms | testValidationOverhead() | Median <1.0ms |
| Blocker 2 | Fast learning <10ms | testFastLearningPerformance() | Median <10.0ms |
| Blocker 3 | Actor isolation | Swift 6 build | Zero warnings |
| High Pri 4 | No PII stored | Code review | Only IDs stored |
| High Pri 5 | Privacy docs | Manual review | Complete |
| High Pri 6 | Sendable | Swift 6 build | Zero warnings |
| High Pri 7 | Background safe | Code review | Actor confirmed |
| High Pri 8 | Assertions | Debug build | Present |

---

## RISK ASSESSMENT

### If ALL Blockers Resolved

**Confidence**: HIGH (9/10)
- Clear path to Week 11 implementation
- Performance validated with data
- Privacy guarantees documented
- Swift 6 compliant

**Timeline**: ON TRACK
- 1 day prep work
- Week 11 starts as planned
- No architectural changes needed

---

### If ANY Blocker Unresolved

**Confidence**: MEDIUM (5/10)
- Risk of silent performance degradation
- Potential Swift 6 compilation failures
- Privacy concerns unaddressed

**Timeline**: DELAYED
- Additional 2-3 days debugging
- Week 11 pushed back
- May need architectural changes

---

## RECOMMENDATION

**Approach**: Test-Driven Pre-Implementation

1. **Write tests FIRST** (Day -1 morning)
2. **Run tests, document failures** (Day -1 afternoon)
3. **Fix issues** (Day 0)
4. **Re-run tests, confirm passing** (Day 1)
5. **Proceed to Week 11** (Day 2+)

**Why This Works**:
- Failures discovered early (not Week 13)
- Fixes are targeted (not exploratory)
- Confidence backed by data (not assumptions)

---

## APPENDIX: Benchmark Output Examples

### Expected Test Output (SUCCESS)

```
═══════════════════════════════════════════════════════
VALIDATION OVERHEAD BENCHMARK RESULTS
═══════════════════════════════════════════════════════
Samples:     1000
Median:      0.752ms
P95:         1.341ms
P99:         2.103ms
Max:         3.287ms

Target:      <1.0ms median, <2.0ms P95
Status:      ✅ PASS
═══════════════════════════════════════════════════════

Test testValidationOverhead() passed (0.853 seconds)
```

### Expected Test Output (FAILURE)

```
═══════════════════════════════════════════════════════
VALIDATION OVERHEAD BENCHMARK RESULTS
═══════════════════════════════════════════════════════
Samples:     1000
Median:      2.134ms
P95:         4.567ms
P99:         6.891ms
Max:         9.234ms

Target:      <1.0ms median, <2.0ms P95
Status:      ❌ FAIL
═══════════════════════════════════════════════════════

XCTAssertLessThan failed: ("2.134") is not less than ("1.0")
- BLOCKER: Median validation overhead 2.134ms exceeds 1.0ms budget

Test testValidationOverhead() failed (0.853 seconds)
```

---

**Document Status**: READY FOR EXECUTION
**Next Step**: Execute Day -1 checklist → Run performance tests
**Target Completion**: November 2, 2025 (before Week 11 Day 1)

---

END OF BLOCKER RESOLUTION GUIDE
