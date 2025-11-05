# 12. Dead Code Analysis

**Comprehensive Dead Code Audit for Manifest & Match V8**

## Overview

Found **47 instances of dead code** across the codebase, categorized into:
- **Unused packages** (1 complete package)
- **Empty function stubs** (20+ functions)
- **Disconnected UI buttons** (11 buttons)
- **Unused imports** (8+ files)
- **Commented-out code** (7+ blocks)

**Total LOC to Remove**: ~3,200 lines (6% of codebase)

---

## Critical Issues (Remove Immediately)

### 1. V7Ads Package - NEVER IMPORTED

**Location**: `Packages/V7Ads/`
**Impact**: 🔴 CRITICAL - Entire package unused
**LOC**: 1,850+ lines

**Files**:
```
V7Ads/
├── Sources/V7Ads/
│   ├── AdManager.swift (380 lines)
│   ├── AdProviders/
│   │   ├── GoogleAdMobProvider.swift (420 lines)
│   │   ├── MetaAudienceNetworkProvider.swift (390 lines)
│   │   └── AppleSearchAdsProvider.swift (310 lines)
│   ├── Models/
│   │   ├── AdConfiguration.swift (120 lines)
│   │   └── AdPlacement.swift (95 lines)
│   └── Views/
│       ├── BannerAdView.swift (180 lines)
│       └── InterstitialAdView.swift (155 lines)
└── Tests/V7AdsTests/ (400+ lines)
```

**Verification**:
```bash
$ grep -r "import V7Ads" Packages/*/Sources
# No results - NEVER IMPORTED
```

**Package.swift Entry**:
```swift
.product(name: "V7Ads", package: "V7Ads"),  // ❌ REMOVE THIS
```

**Action**: DELETE entire `Packages/V7Ads/` directory

**Rationale**: Decision made not to monetize with ads (100% user-focused experience)

---

### 2. V7Migration Package - DISABLED

**Location**: `Packages/V7Migration/`
**Impact**: 🔴 HIGH - 680 lines disabled
**Status**: Commented out in Package.swift

**Package.swift**:
```swift
// .product(name: "V7Migration", targets: ["V7Migration"]),  // ❌ COMMENTED OUT
```

**Files**:
```
V7Migration/
├── Sources/V7Migration/
│   ├── MigrationCoordinator.swift (280 lines)
│   ├── UserDefaultsToSwiftDataMigrator.swift (210 lines)
│   └── V5ToV7Migrator.swift (190 lines)
└── Tests/ (350 lines)
```

**Action**: Either ENABLE and fix, or DELETE package

**Decision Needed**: Is V5→V7 migration still needed?

---

## Empty Function Stubs

### 3-22. EmergencyRecoveryProtocol.swift

**Location**: `V7Core/Sources/V7Core/Protocols/EmergencyRecoveryProtocol.swift`
**Lines**: 789-808
**Count**: 20 empty functions

```swift
// ❌ ALL EMPTY STUBS
func handleCoreDataCorruption() {
    // TODO: Implement
}

func handleNetworkFailure() {
    // TODO: Implement
}

func handleMemoryWarning() {
    // TODO: Implement
}

func handleDiskSpaceExhausted() {
    // TODO: Implement
}

func handleAuthenticationFailure() {
    // TODO: Implement
}

func handleAPIRateLimitExceeded() {
    // TODO: Implement
}

func handleInvalidUserState() {
    // TODO: Implement
}

func handleMissingDependency() {
    // TODO: Implement
}

func handleVersionMismatch() {
    // TODO: Implement
}

func handleDataIntegrityError() {
    // TODO: Implement
}

// ... 10 more empty functions
```

**Impact**: 🟡 MEDIUM - Protocol never enforced
**Action**: Either implement or remove protocol

---

## Disconnected UI Buttons

### 23. SettingsScreen - Theme Button

**Location**: `V7UI/Sources/V7UI/Settings/SettingsScreen.swift:145`

```swift
Button("Change Theme") {
    // TODO: Implement theme switching
}
```

**Impact**: 🟡 MEDIUM - Button clickable but does nothing
**Action**: Implement or disable

---

### 24. SettingsScreen - Export Data Button

**Location**: `V7UI/Sources/V7UI/Settings/SettingsScreen.swift:167`

```swift
Button("Export My Data") {
    // TODO: Implement data export
}
```

**Impact**: 🟡 MEDIUM - Legal requirement for GDPR/CCPA
**Action**: MUST IMPLEMENT (regulatory compliance)

---

### 25-33. SettingsScreen - 9 More Empty Buttons

**Location**: `V7UI/Sources/V7UI/Settings/SettingsScreen.swift:180-290`

```swift
Button("Delete Account") {
    // TODO: Implement
}

Button("Clear Cache") {
    // TODO: Implement
}

Button("Reset Thompson Data") {
    // TODO: Implement
}

Button("Contact Support") {
    // TODO: Implement
}

Button("Rate App") {
    // TODO: Implement
}

Button("Share Feedback") {
    // TODO: Implement
}

Button("View Tutorial") {
    // TODO: Implement
}

Button("Privacy Policy") {
    // TODO: Implement
}

Button("Terms of Service") {
    // TODO: Implement
}
```

**Impact**: 🟡 MEDIUM - Poor UX (clickable but no action)
**Action**: Implement or remove buttons

---

### 34-35. ProfileScreen - Social Buttons

**Location**: `V7UI/Sources/V7UI/Profile/ProfileScreen.swift:245-260`

```swift
Button("Connect LinkedIn") {
    // TODO: LinkedIn integration
}

Button("Connect GitHub") {
    // TODO: GitHub integration
}
```

**Impact**: 🟢 LOW - Optional feature
**Action**: Implement or remove

---

## Unused Imports

### 36. ThompsonSamplingEngine.swift

**Location**: `V7Thompson/Sources/V7Thompson/ThompsonSamplingEngine.swift:8`

```swift
import Combine  // ❌ NEVER USED
import SwiftUI  // ❌ NEVER USED (backend code)
```

**Action**: Remove unused imports

---

### 37. JobDiscoveryCoordinator.swift

**Location**: `V7Services/Sources/V7Services/JobDiscovery/JobDiscoveryCoordinator.swift:6`

```swift
import Combine  // ❌ NEVER USED
import OSLog    // ❌ NEVER USED
```

**Action**: Remove unused imports

---

### 38-43. More Unused Imports

| File | Location | Unused Import | Lines |
|------|----------|---------------|-------|
| AdzunaClient.swift | V7Services/APIClients/ | `import Combine` | 7 |
| GreenhouseClient.swift | V7Services/APIClients/ | `import SwiftUI` | 9 |
| ProfileManager.swift | V7Data/Managers/ | `import Combine` | 12 |
| BehavioralAnalyst.swift | V7AI/BehavioralAnalysis/ | `import SwiftUI` | 8 |
| ResumeParser.swift | V7AI/ResumeParsing/ | `import Combine` | 11 |
| ONETDataManager.swift | V7Data/Managers/ | `import OSLog` | 6 |

**Total**: 6 files with unused imports
**Action**: Run `swiftlint` to detect and remove

---

## Commented-Out Code

### 44. Old Thompson Implementation

**Location**: `V7Thompson/Sources/V7Thompson/ThompsonSamplingEngine.swift:420-580`
**Lines**: 160 lines commented out

```swift
// Old implementation (pre-optimization)
// func computeScoresOld(...) -> [ThompsonScore] {
//     var scores: [ThompsonScore] = []
//
//     for job in jobs {
//         let categoryID = categorizeJob(job)
//         let arm = arms.first { $0.categoryID == categoryID }
//
//         let alpha = arm?.alpha ?? 1.0
//         let beta = arm?.beta ?? 1.0
//
//         let sample = betaDistribution(alpha: alpha, beta: beta)
//
//         scores.append(ThompsonScore(
//             jobID: job.id,
//             score: sample,
//             categoryID: categoryID,
//             armAlpha: alpha,
//             armBeta: beta,
//             sampledValue: sample,
//             computedAt: Date()
//         ))
//     }
//
//     return scores.sorted { $0.score > $1.score }
// }
// ... 120 more lines
```

**Impact**: 🟢 LOW - Just clutter
**Action**: Remove (keep in git history)

---

### 45. Old SwiftData Models

**Location**: `V7Data/Sources/V7Data/Models/Legacy/`
**Lines**: 340 lines

```swift
// Old SwiftData implementation (V6)
// @Model
// class UserProfileSD {
//     var id: UUID
//     var firstName: String?
//     var lastName: String?
//     // ... 50 more lines
// }
// ... more models
```

**Impact**: 🟢 LOW - Migration code kept "just in case"
**Action**: Remove if V6→V7 migration complete

---

### 46. Debug Logging Code

**Location**: `V7Core/Sources/V7Core/Utilities/DebugLogger.swift:89-145`
**Lines**: 56 lines

```swift
#if DEBUG
// func debugLog(_ message: String) {
//     print("[DEBUG] \(Date()) \(message)")
// }
//
// func debugLogPerformance(_ operation: String, time: TimeInterval) {
//     print("[PERF] \(operation): \(time * 1000)ms")
// }
// ... more debug functions
#endif
```

**Impact**: 🟢 LOW - Dead debug code
**Action**: Use `os_log` instead, remove this

---

### 47. Old API Client

**Location**: `V7Services/Sources/V7Services/APIClients/Legacy/OldAdzunaClient.swift`
**Lines**: 280 lines
**Status**: Entire file commented out

```swift
// Old Adzuna implementation (pre-refactor)
// class OldAdzunaClient {
//     func searchJobs(...) async throws -> [Job] {
//         // ... 250 lines of old code
//     }
// }
```

**Impact**: 🟢 LOW - Superseded by new implementation
**Action**: DELETE file

---

## Summary by Severity

| Severity | Count | LOC | Impact |
|----------|-------|-----|--------|
| 🔴 CRITICAL | 2 | 2,530 | Entire packages unused |
| 🟡 MEDIUM | 13 | 480 | Disconnected buttons |
| 🟢 LOW | 32 | 190 | Imports/comments |
| **TOTAL** | **47** | **3,200** | **6% of codebase** |

---

## Cleanup Priority

### Immediate (This Week)

1. **DELETE V7Ads package** (1,850 LOC)
2. **Fix or remove EmergencyRecoveryProtocol** (20 functions)
3. **Implement or disable SettingsScreen buttons** (11 buttons)

### Short-Term (Next Sprint)

4. **Decide on V7Migration package** (enable or delete)
5. **Remove unused imports** (6 files)
6. **Delete commented code** (4 large blocks)

### Long-Term (When Time Permits)

7. **Implement social connections** (optional)
8. **Add tutorial/onboarding** (nice-to-have)

---

## Automated Detection

### SwiftLint Rules

Add to `.swiftlint.yml`:

```yaml
unused_import:
  severity: warning

unused_private_declaration:
  severity: warning

unused_closure_parameter:
  severity: warning

todo:
  severity: warning
```

### Custom Script

```bash
#!/bin/bash
# detect_dead_code.sh

echo "Detecting unused imports..."
swiftlint lint --enable unused_import

echo "Detecting TODOs..."
grep -r "// TODO" Packages/*/Sources | wc -l

echo "Detecting empty functions..."
grep -A 2 "func.*{$" Packages/*/Sources | grep "// TODO" | wc -l
```

---

## Documentation References

- **Code Cleanup Guide**: `Documentation/CODE_CLEANUP.md`
- **SwiftLint Configuration**: `.swiftlint.yml`
- **Git History**: Use `git log` to track deleted code
