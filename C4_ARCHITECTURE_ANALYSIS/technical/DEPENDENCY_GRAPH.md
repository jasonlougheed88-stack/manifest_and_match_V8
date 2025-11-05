# DEPENDENCY GRAPH & MODULE MAP
## Manifest & Match V8 - Complete Dependency Analysis

---

## Visual Dependency Graph (5-Level Architecture)

```
┌────────────────────────────────────────────────────────────────────────┐
│                    LEVEL 0: FOUNDATION (0 Dependencies)                 │
└────────────────────────────────────────────────────────────────────────┘

        ┌─────────────┐
        │   V7Core    │  ← ZERO external dependencies
        │             │     Foundation for all packages
        │  • SacredUI │
        │  • Protocols│
        │  • Constants│
        └──────┬──────┘
               │
               │ depended on by ALL packages below
               │
    ┌──────────┼──────────┬──────────────┐
    │          │          │              │
    ▼          ▼          ▼              ▼
┌─────────┐ ┌────────┐ ┌───────────┐ ┌──────────┐
│V7Embed  │ │V7Job   │ │V7Migration│ │          │
│dings    │ │Parsing │ │(DISABLED) │ │          │
│         │ │        │ │           │ │          │
└────┬────┘ └───┬────┘ └───────────┘ │          │
     │          │                     │          │
     │          │                     │          │


┌────────────────────────────────────────────────────────────────────────┐
│              LEVEL 1: ALGORITHM & DATA (Deps: Level 0)                  │
└────────────────────────────────────────────────────────────────────────┘

     │          │
     │          │
     └─────┬────┴──────────────┬─────────────────┐
           │                   │                 │
           ▼                   ▼                 ▼
      ┌─────────────┐    ┌──────────┐     ┌──────────────┐
      │ V7Thompson  │    │ V7Data   │     │V7Performance │
      │             │    │          │     │              │
      │ Deps:       │    │ Deps:    │     │ Deps:        │
      │ • V7Core    │    │ • V7Core │     │ • V7Core     │
      │ • V7Embeddi │    │          │     │ • V7Thompson │
      │   ngs       │    │          │     │              │
      └──────┬──────┘    └────┬─────┘     └───────┬──────┘
             │                │                    │
             │                │                    │
             │                │                    │


┌────────────────────────────────────────────────────────────────────────┐
│          LEVEL 2: SERVICES & PARSING (Deps: Levels 0-1)                │
└────────────────────────────────────────────────────────────────────────┘

             │                │                    │
             │                │                    │
      ┌──────┴────────────────┴────────┬───────────┴──────┐
      │                                │                  │
      ▼                                ▼                  ▼
┌──────────────┐              ┌─────────────────┐  ┌──────────────────┐
│  V7Services  │              │  V7AIParsing    │  │V7ResumeAnalysis  │
│              │              │                 │  │                  │
│ Deps:        │              │ Deps:           │  │ Deps:            │
│ • V7Core     │              │ • V7Core        │  │ • V7Core         │
│ • V7Thompson │              │ • V7Thompson    │  │ • V7Data         │
│ • V7JobParsn │              │ • V7Performance │  │ • V7Career       │
│ • V7AIParsng │              │                 │  │ • V7AI           │
│ • V7Data     │              │                 │  │                  │
└──────┬───────┘              └────────┬────────┘  └─────────┬────────┘
       │                               │                     │
       │                               │                     │


┌────────────────────────────────────────────────────────────────────────┐
│         LEVEL 3: BUSINESS LOGIC & AI (Deps: Levels 0-2)                │
└────────────────────────────────────────────────────────────────────────┘

       │                               │                     │
       │                               │                     │
       └───────────────┬───────────────┴─────────────────────┘
                       │
                       ▼
                ┌──────────────┐              ┌──────────────┐
                │    V7AI      │              │   V7Ads      │
                │              │              │   (UNUSED)   │
                │ Deps:        │              │              │
                │ • V7Core     │              │ Deps:        │
                │ • V7Data     │              │ • V7Core     │
                │ • V7Services │              │ • V7UI  ← ⚠️ │
                │ • V7Thompson │              │ • V7Perform  │
                │ • V7Perform  │              │              │
                └───────┬──────┘              └──────────────┘
                        │
                        │


┌────────────────────────────────────────────────────────────────────────┐
│         LEVEL 4: FEATURE & CAREER (Deps: Levels 0-3)                   │
└────────────────────────────────────────────────────────────────────────┘

                        │
                        ▼
                 ┌─────────────┐
                 │  V7Career   │
                 │             │
                 │ Deps:       │
                 │ • V7Core    │
                 │ • V7Data    │
                 │ • V7Thompson│
                 │ • V7AI      │
                 │ • V7Services│
                 │ • V7Perform │
                 └──────┬──────┘
                        │
                        │


┌────────────────────────────────────────────────────────────────────────┐
│     LEVEL 5: PRESENTATION - TERMINAL (Deps: ALL packages above)        │
└────────────────────────────────────────────────────────────────────────┘

                        │
                        ▼
                 ┌─────────────┐
                 │    V7UI     │  ← TERMINAL: Only depends on, never depended on
                 │  (Terminal) │     (Exception: V7Ads one-way dependency)
                 │             │
                 │ Deps: ALL   │
                 │ • V7Core    │
                 │ • V7Data    │
                 │ • V7Thompson│
                 │ • V7Services│
                 │ • V7AI      │
                 │ • V7AIParsng│
                 │ • V7JobParsn│
                 │ • V7ResumeAn│
                 │ • V7Embeddi │
                 │ • V7Perform │
                 │ • V7Career  │
                 └─────────────┘
```

---

## Import Analysis (Per Package)

### V7Core (0 imports)
```swift
import Foundation    // System framework only
// NO package dependencies
```

### V7Thompson (2 imports)
```swift
import V7Core
import V7Embeddings
import Accelerate    // System framework (SIMD optimization)
import simd          // System framework
import os.log        // System framework
```

### V7Data (1 import)
```swift
import V7Core
import CoreData      // System framework
import Foundation    // System framework
```

### V7Services (5 imports)
```swift
import V7Core
import V7Thompson
import V7JobParsing
import V7AIParsing
import V7Data
import Foundation    // System framework
```

### V7AI (6 imports)
```swift
import V7Core
import V7Data
import V7Services
import V7Thompson
import V7Performance
import NaturalLanguage   // System framework
import Security          // System framework (Keychain)
import CoreData          // System framework
import Observation       // System framework
```

### V7UI (14 imports) - TERMINAL PACKAGE
```swift
import V7Core
import V7Data
import V7Thompson
import V7Services
import V7AI
import V7AIParsing
import V7JobParsing
import V7ResumeAnalysis
import V7Embeddings
import V7Performance
import V7Career
import SwiftUI           // System framework
import Foundation        // System framework
import Charts            // System framework (iOS 16+)
```

---

## Coupling Analysis (Afferent/Efferent Coupling)

### Coupling Metrics

| Package | Afferent (Ca) | Efferent (Ce) | Instability (I = Ce/(Ca+Ce)) | Category |
|---------|---------------|---------------|------------------------------|----------|
| **V7Core** | 14 | 0 | 0.00 | Stable Foundation |
| **V7Thompson** | 6 | 2 | 0.25 | Stable Algorithm |
| **V7Data** | 8 | 1 | 0.11 | Stable Persistence |
| **V7Performance** | 5 | 2 | 0.29 | Stable Monitoring |
| **V7Services** | 4 | 5 | 0.56 | Balanced Gateway |
| **V7AI** | 3 | 6 | 0.67 | Flexible Logic |
| **V7Career** | 2 | 6 | 0.75 | Flexible Feature |
| **V7UI** | 0 | 14 | 1.00 | Maximum Instability (Terminal) |

**Instability Interpretation:**
- **I = 0.0** - Maximally stable (V7Core)
- **I = 0.5** - Balanced
- **I = 1.0** - Maximally instable (V7UI, as designed for terminal package)

**Key Insight:** Instability increases with level number, following Stable Dependencies Principle.

---

## Circular Dependency Detection

### Result: ✅ ZERO Circular Dependencies

**Validation Method:**
1. Topological sort of package graph
2. Depth-first search from each package
3. Checked for back edges

**One Exception (By Design):**
- V7Ads → V7UI (one-way for ad placement in UI)
- V7UI does NOT depend on V7Ads
- This is acceptable asymmetric coupling

**Prevented Cycles:**
- V7Data does NOT depend on V7UI (Core Data accessed via Environment)
- V7Thompson does NOT depend on V7Services (protocol-based inversion)
- V7Performance does NOT depend on monitored packages (observer pattern)

---

## Bottleneck Analysis

### Potential Bottlenecks (High Fan-In)

#### 1. V7Core (Ca = 14, CRITICAL PATH)
**Risk:** Changes cascade to ALL packages
**Mitigation:**
- Strict API stability guarantees
- Semantic versioning enforcement
- Extensive test coverage (>90%)
- Avoid breaking changes

#### 2. V7Thompson (Ca = 6, PERFORMANCE CRITICAL)
**Risk:** Performance regression affects entire scoring pipeline
**Mitigation:**
- <10ms constraint enforced in CI/CD
- Performance tests run on every PR
- Benchmark suite with 357x baseline tracking
- Guardian skill: thompson-performance-guardian

#### 3. V7Data (Ca = 8, DATA INTEGRITY CRITICAL)
**Risk:** Core Data schema changes require migrations
**Mitigation:**
- Lightweight migrations preferred
- V7Migration package for complex migrations
- Rollback procedures documented
- Backup before major changes

### Potential Bottlenecks (High Fan-Out)

#### 1. V7UI (Ce = 14, INTEGRATION COMPLEXITY)
**Risk:** Changes in any dependency break UI compilation
**Mitigation:**
- Protocol-based contracts with dependencies
- Snapshot tests for UI stability
- Feature flags for gradual rollout
- Comprehensive integration tests

#### 2. V7Services (Ce = 5, EXTERNAL API DEPENDENCY)
**Risk:** External API changes cascade through service layer
**Mitigation:**
- Adapter pattern for each API
- Circuit breakers prevent cascading failures
- Fallback to cached data
- Graceful degradation strategies

---

## Package Cohesion Analysis

### High Cohesion (Good)

✅ **V7Thompson** - Single responsibility: Thompson Sampling algorithm
✅ **V7Data** - Single responsibility: Core Data persistence
✅ **V7JobParsing** - Single responsibility: Job description parsing
✅ **V7Embeddings** - Single responsibility: Vector embeddings

### Medium Cohesion (Acceptable)

⚠️ **V7AI** - Multiple responsibilities: Questions, UserTruths, Behavioral Learning
- Could split into: V7Questions, V7BehavioralLearning, V7UserTruths
- Current grouping acceptable for now (semantic cohesion)

⚠️ **V7Services** - Multiple responsibilities: 7 API clients + coordination
- Could split into: V7JobAPIs, V7ServiceCoordination
- Current grouping acceptable (all job fetching related)

### Low Cohesion (Needs Improvement)

❌ **V7Core** - Kitchen sink: Protocols, Constants, SacredUI, SkillTaxonomy, O*NET
- **Should split into:**
  - V7Foundation (protocols, base types)
  - V7Constants (SacredUI, PerformanceBudget)
  - V7SkillTaxonomy (skills database)
  - V7ONet (O*NET data models)
- **Risk:** V7Core becoming "god package"
- **Recommendation:** Refactor in Phase 2

---

## Import Cycles (File-Level)

### Within V7Thompson Package
```
FastBetaSampler.swift
├─ imports ThompsonTypes.swift
└─ imports ThompsonCache.swift

ThompsonCache.swift
├─ imports ThompsonTypes.swift
└─ NO circular dependency

RealTimeScoring.swift
├─ imports FastBetaSampler.swift
├─ imports ThompsonCache.swift
└─ imports ThompsonTypes.swift
```
✅ **Result:** Clean DAG, no file-level cycles

### Within V7AI Package
```
FastBehavioralLearning.swift
├─ imports UserTruths+CoreData.swift
└─ imports CareerQuestion+CoreData.swift

SmartQuestionGenerator.swift
├─ imports FastBehavioralLearning.swift
├─ imports UserTruths+CoreData.swift
└─ imports QuestionTemplateLibrary.swift
```
✅ **Result:** Clean DAG, no file-level cycles

---

## Transitive Dependency Analysis

### V7UI Transitive Closure (ALL 14 packages)
```
V7UI directly depends on: 11 packages
  ├─ V7Core
  ├─ V7Data
  ├─ V7Thompson
  ├─ V7Services
  ├─ V7AI
  ├─ V7AIParsing
  ├─ V7JobParsing
  ├─ V7ResumeAnalysis
  ├─ V7Embeddings
  ├─ V7Performance
  └─ V7Career

V7UI transitively depends on: +3 packages (via dependencies)
  ├─ V7Core (redundant, already direct)
  ├─ V7Thompson (redundant, already direct)
  └─ V7Data (redundant, already direct)

Total unique: 14 packages (11 direct + 0 unique transitive)
```

**Optimization Opportunity:** None - all transitive deps are already direct deps.

---

## Build Time Impact Analysis

### Critical Path Build Order
```
1. V7Core (0 deps) → Build first
2. Parallel:
   - V7Embeddings (deps: V7Core)
   - V7JobParsing (deps: V7Core)
   - V7Migration (deps: V7Core, DISABLED)
3. Parallel:
   - V7Thompson (deps: V7Core, V7Embeddings)
   - V7Data (deps: V7Core)
4. V7Performance (deps: V7Core, V7Thompson)
5. Parallel:
   - V7Services (deps: V7Core, V7Thompson, V7JobParsing, V7AIParsing, V7Data)
   - V7AIParsing (deps: V7Core, V7Thompson, V7Performance)
6. Parallel:
   - V7AI (deps: V7Core, V7Data, V7Services, V7Thompson, V7Performance)
   - V7ResumeAnalysis (deps: V7Core, V7Data, V7Career, V7AI)
7. V7Career (deps: V7Core, V7Data, V7Thompson, V7AI, V7Services, V7Performance)
8. V7UI (deps: ALL above) → Build last
```

**Longest Critical Path:** V7Core → V7Embeddings → V7Thompson → V7Performance → V7Services → V7AI → V7Career → V7UI
**Parallelization Opportunities:** Steps 2, 3, 5, 6 can build concurrently

---

## Dependency Violations & Anti-Patterns

### ❌ VIOLATION 1: V7Ads → V7UI (Reverse Dependency)
**Location:** `/Packages/V7Ads/Package.swift:25`
**Issue:** Lower-level package (V7Ads, Level 3) depends on higher-level (V7UI, Level 5)
**Impact:** Breaks level-based architecture
**Justification:** ONE-WAY for ad placement in job deck
**Resolution:** Acceptable exception, but should use protocol injection instead

**Better Design:**
```swift
// In V7Core (Level 0)
protocol AdPlacementDelegate {
    func placeAd(at index: Int, in deck: [JobCard])
}

// In V7UI (Level 5)
class DeckScreen: AdPlacementDelegate {
    func placeAd(at index: Int, in deck: [JobCard]) { ... }
}

// In V7Ads (Level 3)
class AdManager {
    weak var delegate: AdPlacementDelegate?
}
```

### ⚠️ WARNING: V7Core Growing Too Large
**Issue:** 50+ files, 8,000+ LOC in single package
**Risk:** Becomes "god package" with low cohesion
**Recommendation:** Split into:
- V7Foundation (protocols, base types)
- V7Constants (SacredUI, performance budgets)
- V7SkillTaxonomy (skills database, 636 skills)
- V7ONet (O*NET data, 1,016 roles)

---

## Dependency Injection Patterns

### 1. Environment-Based Injection (Core Data)
```swift
// In V7Data
extension EnvironmentValues {
    var managedObjectContext: NSManagedObjectContext { ... }
}

// In V7UI
@Environment(\.managedObjectContext) var context
```

### 2. Property-Based Injection (Thompson Engine)
```swift
// In V7UI/DeckScreen
@State var jobCoordinator = JobDiscoveryCoordinator()

init(thompsonEngine: ThompsonSamplingEngine = .default) {
    self.jobCoordinator = JobDiscoveryCoordinator(engine: thompsonEngine)
}
```

### 3. Protocol-Based Injection (Job Sources)
```swift
// In V7Services
protocol JobSourceProtocol {
    func fetchJobs(query: JobSearchQuery) async throws -> [RawJobData]
}

// In JobDiscoveryCoordinator
func registerSource(_ source: JobSourceProtocol) { ... }
```

---

## Compile-Time Dependencies vs Runtime Dependencies

### Compile-Time (Static)
- Package.swift dependencies
- Import statements
- Protocol conformances
- Type usage

### Runtime (Dynamic)
- Core Data entity relationships
- SwiftUI @Environment injection
- Actor message passing
- Async/await task spawning

**Key Insight:** Swift's static type system catches most dependency errors at compile time.

---

## Future Dependency Changes

### Planned Additions
1. **V7Logging** - Centralized logging (deps: V7Core)
2. **V7Analytics** - User behavior analytics (deps: V7Core, V7Data)
3. **V7Networking** - Abstract URLSession (deps: V7Core)

### Planned Removals
1. **V7Ads** - Never used, remove entire package
2. **V7Migration** - Complete migration or remove

### Planned Refactorings
1. Split V7Core into 4 packages
2. Extract V7UIComponents from V7UI
3. Modularize V7Services by API type

---

## Dependency Health Metrics

| Metric | Value | Status | Target |
|--------|-------|--------|--------|
| Total Packages | 15 | ⚠️ | 12-18 (acceptable) |
| Max Depth | 5 levels | ✅ | <7 levels |
| Circular Deps | 0 | ✅ | 0 |
| V7Core Fan-Out | 0 | ✅ | 0 (stable foundation) |
| V7Core Fan-In | 14 | ⚠️ | <10 (high coupling) |
| V7UI Fan-Out | 14 | ⚠️ | <12 (high coupling) |
| Unused Packages | 1 (V7Ads) | ❌ | 0 |
| Disabled Packages | 1 (V7Migration) | ⚠️ | 0 |

---

## Recommendations

### Immediate (This Sprint)
1. ✅ Remove V7Ads package (never imported, 15+ dead files)
2. ✅ Complete or remove V7Migration
3. ⚠️ Document V7Ads → V7UI exception pattern

### Short-Term (Next Sprint)
4. ⚠️ Split V7Core into 4 focused packages
5. ⚠️ Reduce V7UI dependencies (use protocols where possible)
6. ✅ Add dependency visualization tool to CI/CD

### Long-Term (Before V8)
7. Enforce dependency rules via Swift Package Plugin
8. Add automated circular dependency detection
9. Track coupling metrics in CI/CD dashboard

---

## Tools for Dependency Visualization

### Recommended
1. **Swift Package Graph** - Built-in `swift package show-dependencies`
2. **Graphviz** - Generate visual graphs from Package.swift
3. **XcodeGen** - Manage project structure as code
4. **SwiftLint** - Custom rules for dependency violations

### Example Graphviz Generation
```bash
swift package show-dependencies --format dot > deps.dot
dot -Tpng deps.dot -o dependency_graph.png
```

---

## Summary

**Dependency Graph Health:** 🟡 GOOD with minor issues

**Strengths:**
- ✅ Zero circular dependencies
- ✅ Clean 5-level hierarchy
- ✅ Stable foundation (V7Core)
- ✅ Terminal presentation layer (V7UI)

**Weaknesses:**
- ❌ V7Ads package unused (remove)
- ⚠️ V7Core too large (split recommended)
- ⚠️ High coupling on V7UI (14 deps)
- ⚠️ V7Ads → V7UI reverse dependency

**Critical Paths:**
1. V7Core → (affects all 14 packages)
2. V7Thompson → (affects 6 packages, performance critical)
3. V7Data → (affects 8 packages, data integrity critical)

**Build Parallelization:** 4 parallel stages (steps 2, 3, 5, 6)

**Next Actions:**
1. Remove V7Ads
2. Split V7Core
3. Add CI/CD dependency monitoring
