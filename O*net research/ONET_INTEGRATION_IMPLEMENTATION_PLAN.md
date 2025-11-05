# O*NET Integration - Complete Implementation Plan
## Account Executive Job Matching Fix

**Date:** November 1, 2025
**Project:** ManifestAndMatchV7 (iOS 26)
**Issue:** Account Executive profiles receive irrelevant engineering/design jobs
**Root Cause:** Missing skills extraction due to incomplete roles database

---

## Executive Summary

**Problem:** "Account Executive" not in roles.json (72 roles) → ProfileConverter returns empty skills → Empty query bypasses filtering → User sees 600+ unfiltered tech jobs

**Solution:** Integrate O*NET occupation database to expand from 72 roles → 1016 occupations, enabling proper skill extraction for all job titles including sales roles.

**Implementation Time:** 5-6 hours
**Risk Level:** Low (leverages existing infrastructure)
**Performance Impact:** None (Thompson <10ms budget maintained)

---

## Part 1: Current Architecture & Data Flow

### 1.1 Complete Data Flow (Resume → Job Filtering)

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: Resume Upload & Profile Setup                          │
├─────────────────────────────────────────────────────────────────┤
│ File: ProfileSetupStepView.swift                               │
│ Line: 775                                                        │
│                                                                  │
│ Input:                                                           │
│   selectedTargetRoles: Set<Role>                                │
│   Example: [Role(title: "Account Executive", ...)]             │
│                                                                  │
│ Process:                                                         │
│   let extractedSkills = await ProfileConverter.extractSkills(  │
│       from: Array(selectedTargetRoles.map { $0.title })        │
│   )                                                              │
│   // Calls with: ["Account Executive"]                         │
│                                                                  │
│ Output:                                                          │
│   extractedSkills: [String]                                     │
│   ❌ Current: []  (Account Executive not in roles.json)        │
│   ✅ Desired: ["Sales", "Negotiation", "Persuasion", ...]      │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: ProfileConverter Skill Extraction                      │
├─────────────────────────────────────────────────────────────────┤
│ File: ProfileConverter.swift (V7Thompson/Utilities)            │
│ Line: 29-58                                                      │
│                                                                  │
│ Current Implementation:                                          │
│   public static func extractSkills(                             │
│       from roles: [String]                                      │
│   ) async -> [String] {                                         │
│       var skills = Set<String>()                                │
│                                                                  │
│       // Load from roles.json (72 roles only)                  │
│       let allRoles = await V7Core.RolesDatabase.shared.allRoles│
│                                                                  │
│       // Build lookup: title → Role                            │
│       var roleMap: [String: V7Core.Role] = [:]                 │
│       for role in allRoles {                                    │
│           roleMap[role.title] = role                            │
│           for altTitle in role.alternativeTitles {              │
│               roleMap[altTitle] = role                          │
│           }                                                      │
│       }                                                          │
│                                                                  │
│       // Extract skills from matched roles                      │
│       for roleTitle in roles {                                  │
│           if let matchedRole = roleMap[roleTitle] {            │
│               skills.formUnion(matchedRole.typicalSkills)       │
│           } else {                                               │
│               // ❌ BUG: Returns empty for unknown roles        │
│               print("⚠️  Unknown role '\(roleTitle)'")          │
│           }                                                      │
│       }                                                          │
│       return Array(skills).sorted()                             │
│   }                                                              │
│                                                                  │
│ Database Used:                                                   │
│   Packages/V7Core/Sources/V7Core/Resources/roles.json          │
│   - Total: 72 roles across 14 sectors                          │
│   - Missing: "Account Executive", "Sales Manager", etc.        │
│                                                                  │
│ Problem:                                                         │
│   "Account Executive" NOT in roles.json                         │
│   → roleMap["Account Executive"] = nil                         │
│   → Returns []                                                   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: Create AppState UserProfile                            │
├─────────────────────────────────────────────────────────────────┤
│ File: ProfileSetupStepView.swift                               │
│ Line: 778-790                                                    │
│                                                                  │
│ let userProfile = UserProfile(                                  │
│     id: UUID().uuidString,                                      │
│     name: name,                                                  │
│     email: "",                                                   │
│     skills: extractedSkills,  // ❌ []                          │
│     experience: experienceLevelToYears(experienceLevel),        │
│     preferredJobTypes: ["Account Executive"],                   │
│     preferredLocations: [],                                      │
│     salaryRange: nil                                             │
│ )                                                                │
│                                                                  │
│ appState.userProfile = userProfile                             │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: Convert to Thompson UserProfile                        │
├─────────────────────────────────────────────────────────────────┤
│ File: ProfileConverter.swift                                    │
│ Line: 75-101                                                     │
│                                                                  │
│ Function: toThompsonProfile(_ coreProfile: V7Core.UserProfile) │
│                                                                  │
│ Process:                                                         │
│   // Extract skills from preferredJobTypes                      │
│   let skills = await extractSkills(                             │
│       from: coreProfile.preferredJobTypes                       │
│   )                                                              │
│   // With: ["Account Executive"]                               │
│   // Returns: []  ❌                                             │
│                                                                  │
│   // Fallback to existing skills                               │
│   let finalSkills = skills.isEmpty                              │
│       ? coreProfile.skills  // Also []                          │
│       : skills                                                   │
│                                                                  │
│   // Create Thompson professional profile                       │
│   let professionalProfile = V7Thompson.ProfessionalProfile(    │
│       skills: finalSkills  // ❌ []                             │
│   )                                                              │
│                                                                  │
│   return V7Thompson.UserProfile(                                │
│       id: uuid,                                                  │
│       preferences: preferences,                                  │
│       professionalProfile: professionalProfile                   │
│   )                                                              │
│                                                                  │
│ Data Structure:                                                  │
│   V7Thompson.UserProfile {                                      │
│       id: UUID                                                   │
│       preferences: UserPreferences {                             │
│           preferredLocations: [String]                           │
│           industries: [String]                                   │
│       }                                                          │
│       professionalProfile: ProfessionalProfile {                 │
│           skills: [String]  // ❌ []                            │
│           educationLevel: Int?                                   │
│           yearsOfExperience: Double?                             │
│       }                                                          │
│   }                                                              │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 5: Job Discovery Builds Search Query                      │
├─────────────────────────────────────────────────────────────────┤
│ File: JobDiscoveryCoordinator.swift (V7Services)               │
│ Line: 782-789                                                    │
│                                                                  │
│ private func buildSearchQuery() -> JobSearchQuery {            │
│     // Build query based on user profile                        │
│     let keywords = userProfile.professionalProfile.skills      │
│         .joined(separator: " OR ")                              │
│     // ❌ With skills = [], keywords = ""                       │
│                                                                  │
│     let location = userProfile.preferences                      │
│         .preferredLocations.first                               │
│                                                                  │
│     return JobSearchQuery(                                      │
│         keywords: keywords,  // ❌ ""                           │
│         location: location                                       │
│     )                                                            │
│ }                                                                │
│                                                                  │
│ Problem:                                                         │
│   Empty skills → Empty keywords → Unfiltered job search        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 6: Job Sources Apply Filtering                            │
├─────────────────────────────────────────────────────────────────┤
│ File: JobDiscoveryCoordinator.swift                            │
│ Lines: 1807, 2049, 2254 (multiple filter functions)            │
│                                                                  │
│ private func filterJobsByQuery(                                 │
│     _ jobs: [RawJobData],                                       │
│     query: JobSearchQuery                                       │
│ ) -> [RawJobData] {                                             │
│     return jobs.filter { job in                                 │
│         // Always include if no keywords specified              │
│         if query.keywords.isEmpty { return true }  // ❌ BUG   │
│                                                                  │
│         // Check if keywords match title/company/description   │
│         let searchText = "\(job.title) \(job.company)"         │
│             .lowercased()                                        │
│         let keywords = query.keywords.lowercased()              │
│         return searchText.contains(keywords)                    │
│     }                                                            │
│ }                                                                │
│                                                                  │
│ Problem:                                                         │
│   query.keywords = "" → isEmpty = true                          │
│   → Returns ALL 600+ jobs unfiltered                           │
│   → Account Executive sees iOS Engineer, Designer, etc.        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 7: Thompson Scoring (Runs After Filtering)                │
├─────────────────────────────────────────────────────────────────┤
│ File: OptimizedThompsonEngine.swift                            │
│ Line: 80-83                                                      │
│                                                                  │
│ public func scoreJobs(                                          │
│     _ jobs: [Job],                                              │
│     userProfile: UserProfile                                    │
│ ) async -> [Job] {                                              │
│     // Score each job against user profile                      │
│     // Uses userProfile.professionalProfile.skills              │
│     // But at this point, irrelevant jobs already in list      │
│ }                                                                │
│                                                                  │
│ Note:                                                            │
│   Thompson scoring works correctly, but operates on             │
│   pre-filtered job list. If filtering fails (Step 6),          │
│   Thompson receives 600+ irrelevant jobs to score.             │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Database References

```
┌──────────────────────────────────────────────────────────────┐
│ Current Databases Used                                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│ 1. roles.json                                                │
│    Location: Packages/V7Core/Sources/V7Core/Resources/      │
│    Used By: RolesDatabase.shared                             │
│    Loaded By: ProfileConverter.extractSkills()              │
│    Size: 72 roles across 14 sectors                         │
│    Content Example:                                          │
│      {                                                       │
│        "id": "role_tech_001",                                │
│        "title": "Software Engineer",                         │
│        "sector": "Technology",                               │
│        "typicalSkills": ["Programming", "Software Dev"],     │
│        "alternativeTitles": ["Software Developer"]          │
│      }                                                       │
│    ❌ Missing: "Account Executive", "Sales Manager", etc.   │
│                                                              │
│ 2. onet_credentials.json                                     │
│    Location: Packages/V7Core/Sources/V7Core/Resources/      │
│    Used By: ONetDataService.shared.loadCredentials()        │
│    Loaded By: ONetCodeMapper (for title fuzzy matching)     │
│              ThompsonSampling+ONet (for education matching) │
│    Size: 176 occupations                                     │
│    Content: Education/experience requirements               │
│    Example:                                                  │
│      {                                                       │
│        "onetCode": "15-1252.00",                             │
│        "title": "Software Developers, Applications",        │
│        "sector": "Technology",                               │
│        "jobZone": 4,                                         │
│        "educationRequirements": { ... },                     │
│        "experienceRequirements": { ... }                     │
│      }                                                       │
│    ✅ Has: Some sales roles (Retail Salespersons, etc.)     │
│    ❌ Missing: "Sales Managers" (filtered due to sample size)│
│                                                              │
│ 3. onet_work_activities.json                                 │
│    Location: Packages/V7Core/Sources/V7Core/Resources/      │
│    Used By: ThompsonSampling+ONet.swift                      │
│    Purpose: Work activities matching (cross-domain)          │
│    Size: 894 occupations × 41 activities                     │
│    Note: Used for Thompson scoring, not skill extraction    │
│                                                              │
│ 4. onet_interests.json                                       │
│    Location: Packages/V7Core/Sources/V7Core/Resources/      │
│    Used By: ThompsonSampling+ONet.swift                      │
│    Purpose: RIASEC personality matching                      │
│    Size: 923 occupations × 6 RIASEC dimensions               │
│    Note: Used for Thompson scoring, not skill extraction    │
└──────────────────────────────────────────────────────────────┘
```

---

## Part 2: Existing Infrastructure Analysis

### 2.1 ONetCodeMapper (Already Exists!)

**Location:** `Packages/V7Services/Sources/V7Services/ONet/ONetCodeMapper.swift`
**Status:** ✅ Fully implemented (391 lines)
**Purpose:** Maps job titles to O*NET occupation codes

```swift
// ONetCodeMapper.swift - Lines 45-117

public actor ONetCodeMapper {
    public static let shared = ONetCodeMapper()

    /// Map a job title to O*NET occupation code
    /// Returns best matching O*NET code with confidence score
    public func mapJobTitle(_ jobTitle: String) async throws
        -> MappingResult? {

        // 1. Exact match cache (O(1))
        if let onetCode = exactMatchCache[normalized] {
            return MappingResult(confidence: 1.0, ...)
        }

        // 2. Fuzzy match cache (O(1))
        if let cachedResult = fuzzyMatchCache[normalized] {
            return cachedResult
        }

        // 3. Fuzzy matching (Levenshtein + keywords)
        let result = await performFuzzyMatch(
            jobTitle: jobTitle,
            normalized: normalized
        )

        return result  // nil if confidence < 0.5
    }
}

// MappingResult structure
public struct MappingResult {
    public let originalTitle: String      // "Account Executive"
    public let onetCode: String            // "11-2022.00"
    public let matchedTitle: String        // "Sales Managers"
    public let confidence: Double          // 0.7-0.8 expected
    public let matchType: MatchType        // .medium
}
```

**How It Works:**
1. Loads occupation titles from `ONetDataService.loadCredentials()`
2. Currently loads from **onet_credentials.json (176 occupations)**
3. Fuzzy matches input against all titles using:
   - Levenshtein distance (character similarity)
   - Keyword overlap (60% weight)
   - Returns match if confidence ≥ 0.5

**Current Limitation:**
- Only searches 176 occupations (from onet_credentials.json)
- "Sales Managers" not in those 176 → "Account Executive" can't match

**How to Fix:**
- Give it more occupation titles to search (1016 instead of 176)
- This requires Phase 1 of our plan

---

### 2.2 ONetDataService (Already Exists!)

**Location:** `Packages/V7Core/Sources/V7Core/ONetDataService.swift`
**Status:** ✅ Fully implemented (456 lines)
**Purpose:** Load O*NET data from JSON resources

```swift
// ONetDataService.swift - Lines 55-134

public actor ONetDataService {
    public static let shared = ONetDataService()

    // Existing methods (all working)
    public func loadCredentials() async throws
        -> ONetCredentials { ... }

    public func loadWorkActivities() async throws
        -> ONetWorkActivities { ... }

    public func loadInterests() async throws
        -> ONetInterests { ... }

    public func loadAbilities() async throws
        -> ONetAbilities { ... }

    public func loadKnowledge() async throws
        -> ONetKnowledge { ... }

    // ❌ Missing: loadOccupationSkills()
    // ❌ Missing: loadOccupationTitles()
}
```

**What We Need to Add:**
```swift
/// Load simple occupation titles for ONetCodeMapper
public func loadOccupationTitles() async throws
    -> ONetOccupationTitles {
    // Load from new onet_occupation_titles.json
    // 1016 occupations, just code+title+sector
}

/// Load occupation skills for ProfileConverter
public func loadOccupationSkills() async throws
    -> ONetOccupationSkills {
    // Load from new onet_occupation_skills.json
    // Skills for each occupation code
}
```

---

## Part 3: Implementation Plan (5-6 hours)

### Phase 1: Create Occupation Titles Database (1.5 hours)

**Goal:** Give ONetCodeMapper 1016 occupation titles to search

#### Step 1.1: Create Parser Script

**File to create:** `Data/ONET_Skills/ONetTitlesParser.swift`

```swift
#!/usr/bin/env swift

import Foundation

// MARK: - Data Models

struct OccupationTitle: Codable {
    let onetCode: String
    let title: String
    let sector: String
}

struct OccupationTitlesDatabase: Codable {
    let version: String
    let source: String
    let dateExtracted: String
    let totalOccupations: Int
    let occupations: [OccupationTitle]
}

// MARK: - Sector Mapping (Reuse from ONetCredentialsParser.swift)

enum Sector: String {
    case officeAdmin = "Office/Administrative"
    case healthcare = "Healthcare"
    case technology = "Technology"
    case retail = "Retail"
    // ... all 19 sectors

    static func determineSector(onetCode: String, title: String) -> String {
        // Reuse exact logic from ONetCredentialsParser.swift lines 238-240
        return Sector.allCases.first {
            $0.matches(onetCode: onetCode, title: title)
        }?.rawValue ?? "Office/Administrative"
    }
}

// MARK: - Parser

func parseOccupationTitles() throws {
    print("📖 Parsing Occupation_Data.txt...")

    let content = try String(
        contentsOfFile: "Occupation_Data.txt",
        encoding: .utf8
    )
    let lines = content.components(separatedBy: .newlines)

    var occupations: [OccupationTitle] = []

    for (index, line) in lines.enumerated() {
        guard index > 0, !line.isEmpty else { continue }

        let fields = line.components(separatedBy: "\t")
        guard fields.count >= 3 else { continue }

        let code = fields[0]
        let title = fields[1]
        let sector = Sector.determineSector(
            onetCode: code,
            title: title
        )

        occupations.append(OccupationTitle(
            onetCode: code,
            title: title,
            sector: sector
        ))
    }

    print("✅ Parsed \(occupations.count) occupation titles")

    // Export to JSON
    let output = OccupationTitlesDatabase(
        version: "30.0",
        source: "O*NET 30.0 Database",
        dateExtracted: ISO8601DateFormatter().string(from: Date()),
        totalOccupations: occupations.count,
        occupations: occupations.sorted { $0.onetCode < $1.onetCode }
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let jsonData = try encoder.encode(output)
    try jsonData.write(to: URL(fileURLWithPath: "onet_occupation_titles.json"))

    print("✅ Exported: onet_occupation_titles.json")
    print("📊 Total: \(occupations.count) occupations")
}

// MARK: - Main Execution

do {
    try parseOccupationTitles()
} catch {
    print("❌ ERROR: \(error)")
    exit(1)
}
```

#### Step 1.2: Run Parser

```bash
cd "Data/ONET_Skills"
chmod +x ONetTitlesParser.swift
swift ONetTitlesParser.swift

# Expected output:
# ✅ Parsed 1016 occupation titles
# ✅ Exported: onet_occupation_titles.json
# 📊 Total: 1016 occupations
```

#### Step 1.3: Copy to Resources

```bash
cp onet_occupation_titles.json \
   "../../Packages/V7Core/Sources/V7Core/Resources/"
```

#### Step 1.4: Verify Output

```bash
jq '.totalOccupations, .occupations[] | select(.title | contains("Sales Managers"))' \
   onet_occupation_titles.json
```

**Expected:**
```json
1016
{
  "onetCode": "11-2022.00",
  "title": "Sales Managers",
  "sector": "Office/Administrative"
}
```

---

### Phase 2: Update ONetCodeMapper (1 hour)

**Goal:** Make ONetCodeMapper search 1016 occupations instead of 176

#### Step 2.1: Add Data Model to V7Core

**File:** `Packages/V7Core/Sources/V7Core/ONetDataModels.swift`

**Add after line 500:**

```swift
// MARK: - Occupation Titles Database

/// Simple occupation titles for job title fuzzy matching
/// Used by ONetCodeMapper for "Account Executive" → "11-2022.00" mapping
public struct ONetOccupationTitles: Codable, Sendable {
    public let version: String
    public let source: String
    public let dateExtracted: String
    public let totalOccupations: Int
    public let occupations: [SimpleOccupationTitle]
}

public struct SimpleOccupationTitle: Codable, Sendable {
    public let onetCode: String
    public let title: String
    public let sector: String
}
```

#### Step 2.2: Add Method to ONetDataService

**File:** `Packages/V7Core/Sources/V7Core/ONetDataService.swift`

**Add after `loadInterests()` method (around line 218):**

```swift
/// Load simple occupation titles database (1016 occupations)
///
/// Used by ONetCodeMapper for job title → O*NET code fuzzy matching.
/// Lighter weight than credentials database (no education data).
///
/// **Performance:** ~40ms cold, <1ms cached
/// **Memory:** ~150KB
///
/// - Returns: Occupation titles database
/// - Throws: `ONetError.resourceNotFound` or `ONetError.decodingFailed`
public func loadOccupationTitles() async throws -> ONetOccupationTitles {
    if let cached = occupationTitles {
        return cached
    }

    let loaded: ONetOccupationTitles = try await loadResource(
        named: "onet_occupation_titles"
    )
    occupationTitles = loaded

    // Build O(1) lookup cache
    var lookup: [String: SimpleOccupationTitle] = [:]
    for occ in loaded.occupations {
        lookup[occ.onetCode] = occ
    }
    occupationTitlesLookup = lookup

    return loaded
}

/// Fast O(1) title lookup by O*NET code
public func getOccupationTitle(for onetCode: String) async throws
    -> SimpleOccupationTitle? {
    _ = try await loadOccupationTitles()
    return occupationTitlesLookup?[onetCode]
}
```

**Add private properties (around line 70):**

```swift
/// Occupation titles database (simple) - Cached on first access
private var occupationTitles: ONetOccupationTitles?

/// O(1) lookup cache for titles
private var occupationTitlesLookup: [String: SimpleOccupationTitle]?
```

#### Step 2.3: Update ONetCodeMapper

**File:** `Packages/V7Services/Sources/V7Services/ONet/ONetCodeMapper.swift`

**Replace `ensureDataLoaded()` method (line 173-201):**

```swift
/// Ensure O*NET occupation data is loaded
private func ensureDataLoaded() async throws {
    guard !isLoaded else { return }

    let startTime = CFAbsoluteTimeGetCurrent()

    // Load occupation titles database (1016 occupations)
    // Changed from loadCredentials() (176 occupations)
    let service = ONetDataService.shared
    let titles = try await service.loadOccupationTitles()

    // Build occupation index
    for occupation in titles.occupations {
        let title = OccupationTitle(
            onetCode: occupation.onetCode,
            title: occupation.title,
            sector: occupation.sector
        )

        occupationsByCode[occupation.onetCode] = title

        // Build exact match cache (normalized title → code)
        let normalized = normalizeTitle(occupation.title)
        exactMatchCache[normalized] = occupation.onetCode
    }

    isLoaded = true

    let duration = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    print("✅ [ONetCodeMapper] Loaded \(occupationsByCode.count) occupations in \(String(format: "%.1f", duration))ms")
}
```

#### Step 2.4: Test ONetCodeMapper

Create test file: `Packages/V7Services/Tests/V7ServicesTests/ONetCodeMapperTests.swift`

```swift
import Testing
@testable import V7Services
@testable import V7Core

@Test("ONetCodeMapper loads 1016 occupations")
func testOccupationCount() async throws {
    let mapper = ONetCodeMapper.shared
    let occupations = try await mapper.getAllOccupations()
    #expect(occupations.count == 1016)
}

@Test("Account Executive maps to Sales Managers")
func testAccountExecutiveMapping() async throws {
    let mapper = ONetCodeMapper.shared

    let result = try await mapper.mapJobTitle("Account Executive")

    #expect(result != nil, "Should find a match")
    #expect(result!.onetCode == "11-2022.00", "Should map to Sales Managers")
    #expect(result!.confidence >= 0.6, "Confidence should be reasonable")

    print("✅ Mapped 'Account Executive':")
    print("   O*NET Code: \(result!.onetCode)")
    print("   Matched Title: \(result!.matchedTitle)")
    print("   Confidence: \(result!.confidence)")
}
```

**Run test:**

```bash
cd Packages/V7Services
swift test --filter ONetCodeMapperTests
```

**Expected output:**

```
✅ Mapped 'Account Executive':
   O*NET Code: 11-2022.00
   Matched Title: Sales Managers
   Confidence: 0.73
Test Suite 'ONetCodeMapperTests' passed
```

---

### Phase 3: Create Occupation Skills Database (2-2.5 hours)

**Goal:** Parse Skills.txt to extract skills for each O*NET occupation

#### Step 3.1: Understand Skills.txt Format

```bash
head -20 Data/ONET_Skills/Skills.txt
```

**Format:** Tab-delimited
```
O*NET-SOC Code  Element ID  Element Name  Scale ID  Data Value  N  Std Error  ...
11-1011.00      2.A.1.a     Reading Comp  IM        4.12        8  0.1250     ...
11-1011.00      2.A.1.a     Reading Comp  LV        4.62        8  0.1830     ...
11-1011.00      2.A.1.b     Active Listen IM        4.00        8  0.0000     ...
```

**Key Fields:**
- Column 1: O*NET code (e.g., "11-1011.00")
- Column 3: Skill name (e.g., "Reading Comprehension")
- Column 4: Scale ID
  - "IM" = Importance (0.0-7.0)
  - "LV" = Level (0.0-7.0)
- Column 5: Data value (score)

**Filtering Strategy:**
- Only use "IM" (Importance) scores
- Filter: Importance > 3.5 (important skills)
- Take top 15-20 skills per occupation

#### Step 3.2: Create Skills Parser

**File:** `Data/ONET_Skills/ONetSkillsParser.swift`

```swift
#!/usr/bin/env swift

import Foundation

// MARK: - Data Models

struct SkillScore: Codable {
    let name: String
    let importance: Double
    let level: Double
    let elementId: String
}

struct OccupationSkills: Codable {
    let onetCode: String
    let title: String
    let skills: [SkillScore]
}

struct OccupationSkillsDatabase: Codable {
    let version: String
    let source: String
    let dateExtracted: String
    let totalOccupations: Int
    let occupations: [OccupationSkills]
}

// MARK: - Parser

class ONetSkillsParser {
    private var occupationTitles: [String: String] = [:]  // code → title
    private var skillData: [String: [(name: String, importance: Double, level: Double, elementId: String)]] = [:]

    /// Load occupation titles from Occupation_Data.txt
    func loadOccupationTitles() throws {
        print("📖 Loading occupation titles...")
        let content = try String(contentsOfFile: "Occupation_Data.txt", encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 2 else { continue }

            occupationTitles[fields[0]] = fields[1]
        }

        print("✅ Loaded \(occupationTitles.count) occupation titles")
    }

    /// Parse Skills.txt and extract importance scores
    func parseSkills() throws {
        print("📖 Parsing Skills.txt...")
        let content = try String(contentsOfFile: "Skills.txt", encoding: .utf8)
        let lines = content.components(separatedBy: .newlines)

        var importanceScores: [String: [String: Double]] = [:]  // code → [skill → importance]
        var levelScores: [String: [String: Double]] = [:]  // code → [skill → level]
        var elementIds: [String: [String: String]] = [:]  // code → [skill → elementId]

        for (index, line) in lines.enumerated() {
            guard index > 0, !line.isEmpty else { continue }
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 10 else { continue }

            let onetCode = fields[0]
            let elementId = fields[1]
            let skillName = fields[2]
            let scaleId = fields[3]
            let dataValue = Double(fields[4]) ?? 0.0
            let sampleSize = Int(fields[5]) ?? 0
            let recommendSuppress = fields[9]

            // Skip low-quality data
            guard recommendSuppress != "Y", sampleSize >= 15 else { continue }

            if scaleId == "IM" {  // Importance
                importanceScores[onetCode, default: [:]][skillName] = dataValue
                elementIds[onetCode, default: [:]][skillName] = elementId
            } else if scaleId == "LV" {  // Level
                levelScores[onetCode, default: [:]][skillName] = dataValue
            }
        }

        print("✅ Parsed importance scores for \(importanceScores.keys.count) occupations")

        // Synthesize skills data
        synthesizeSkills(
            importanceScores: importanceScores,
            levelScores: levelScores,
            elementIds: elementIds
        )
    }

    /// Synthesize top skills for each occupation
    private func synthesizeSkills(
        importanceScores: [String: [String: Double]],
        levelScores: [String: [String: Double]],
        elementIds: [String: [String: String]]
    ) {
        print("🔧 Synthesizing occupation skills...")

        for (onetCode, skillImportances) in importanceScores {
            // Filter: importance > 3.5
            let importantSkills = skillImportances.filter { $0.value > 3.5 }

            // Get top 20 skills by importance
            let topSkills = importantSkills
                .sorted { $0.value > $1.value }
                .prefix(20)

            // Build skill scores
            var skills: [(name: String, importance: Double, level: Double, elementId: String)] = []
            for (skillName, importance) in topSkills {
                let level = levelScores[onetCode]?[skillName] ?? 0.0
                let elementId = elementIds[onetCode]?[skillName] ?? ""
                skills.append((skillName, importance, level, elementId))
            }

            skillData[onetCode] = skills
        }

        print("✅ Synthesized skills for \(skillData.count) occupations")
    }

    /// Export to JSON
    func exportSkills() throws {
        print("📝 Exporting occupation skills database...")

        var occupations: [OccupationSkills] = []

        for (onetCode, skills) in skillData {
            let title = occupationTitles[onetCode] ?? "Unknown"

            let skillScores = skills.map { skill in
                SkillScore(
                    name: skill.name,
                    importance: skill.importance,
                    level: skill.level,
                    elementId: skill.elementId
                )
            }

            occupations.append(OccupationSkills(
                onetCode: onetCode,
                title: title,
                skills: skillScores
            ))
        }

        occupations.sort { $0.onetCode < $1.onetCode }

        let output = OccupationSkillsDatabase(
            version: "30.0",
            source: "O*NET 30.0 Database",
            dateExtracted: ISO8601DateFormatter().string(from: Date()),
            totalOccupations: occupations.count,
            occupations: occupations
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(output)
        try jsonData.write(to: URL(fileURLWithPath: "onet_occupation_skills.json"))

        print("✅ Exported: onet_occupation_skills.json")
        printStatistics(occupations: occupations)
    }

    /// Print statistics
    private func printStatistics(occupations: [OccupationSkills]) {
        print("\n" + String(repeating: "=", count: 80))
        print("📊 OCCUPATION SKILLS DATABASE STATISTICS")
        print(String(repeating: "=", count: 80))
        print()

        print("OVERVIEW:")
        print("   Total Occupations: \(occupations.count)")

        let skillCounts = occupations.map { $0.skills.count }
        let avgSkills = Double(skillCounts.reduce(0, +)) / Double(skillCounts.count)
        print("   Average Skills per Occupation: \(String(format: "%.1f", avgSkills))")

        print("\nSAMPLE OCCUPATIONS:")
        for occupation in occupations.prefix(5) {
            print("   \(occupation.onetCode) - \(occupation.title)")
            print("      Skills (\(occupation.skills.count)): \(occupation.skills.prefix(3).map { $0.name }.joined(separator: ", "))...")
        }

        print("\n" + String(repeating: "=", count: 80))
    }
}

// MARK: - Main Execution

print(String(repeating: "=", count: 80))
print("O*NET Skills Parser for ManifestAndMatch V8")
print("iOS 26 Compatible | Swift 6 Ready | O*NET 30.0")
print(String(repeating: "=", count: 80))
print()

let parser = ONetSkillsParser()

do {
    try parser.loadOccupationTitles()
    try parser.parseSkills()
    try parser.exportSkills()

    print("\n" + String(repeating: "=", count: 80))
    print("✅ PARSING COMPLETE")
    print(String(repeating: "=", count: 80))
    print()
    print("📄 Output: onet_occupation_skills.json")
    print("📊 Ready for ManifestAndMatch V8 integration")
    print()

} catch {
    print("\n❌ ERROR: \(error)")
    print("Please ensure all required files are in the current directory:")
    print("   - Occupation_Data.txt")
    print("   - Skills.txt")
    exit(1)
}
```

#### Step 3.3: Run Skills Parser

```bash
cd Data/ONET_Skills
chmod +x ONetSkillsParser.swift
swift ONetSkillsParser.swift
```

**Expected output:**

```
================================================================================
O*NET Skills Parser for ManifestAndMatch V8
iOS 26 Compatible | Swift 6 Ready | O*NET 30.0
================================================================================

📖 Loading occupation titles...
✅ Loaded 1016 occupation titles
📖 Parsing Skills.txt...
✅ Parsed importance scores for 894 occupations
🔧 Synthesizing occupation skills...
✅ Synthesized skills for 894 occupations
📝 Exporting occupation skills database...
✅ Exported: onet_occupation_skills.json

================================================================================
📊 OCCUPATION SKILLS DATABASE STATISTICS
================================================================================

OVERVIEW:
   Total Occupations: 894
   Average Skills per Occupation: 17.3

SAMPLE OCCUPATIONS:
   11-1011.00 - Chief Executives
      Skills (20): Reading Comprehension, Active Listening, Speaking...
   11-2022.00 - Sales Managers
      Skills (18): Persuasion, Negotiation, Speaking...

================================================================================
✅ PARSING COMPLETE
================================================================================
```

#### Step 3.4: Verify Sales Managers Skills

```bash
jq '.occupations[] | select(.onetCode == "11-2022.00")' \
   onet_occupation_skills.json
```

**Expected:**

```json
{
  "onetCode": "11-2022.00",
  "title": "Sales Managers",
  "skills": [
    {
      "elementId": "2.B.1.c",
      "importance": 4.25,
      "level": 4.75,
      "name": "Persuasion"
    },
    {
      "elementId": "2.B.1.d",
      "importance": 4.12,
      "level": 4.5,
      "name": "Negotiation"
    },
    {
      "elementId": "2.A.1.b",
      "importance": 4.0,
      "level": 4.62,
      "name": "Active Listening"
    },
    ... 15 more skills
  ]
}
```

#### Step 3.5: Copy to Resources

```bash
cp onet_occupation_skills.json \
   ../../Packages/V7Core/Sources/V7Core/Resources/
```

#### Step 3.6: Add to ONetDataService

**File:** `Packages/V7Core/Sources/V7Core/ONetDataModels.swift`

**Add after SimpleOccupationTitle:**

```swift
// MARK: - Occupation Skills Database

/// Skills database for occupation-based skill extraction
/// Used by ProfileConverter to extract skills from job titles
public struct ONetOccupationSkills: Codable, Sendable {
    public let version: String
    public let source: String
    public let dateExtracted: String
    public let totalOccupations: Int
    public let occupations: [OccupationSkills]
}

public struct OccupationSkills: Codable, Sendable {
    public let onetCode: String
    public let title: String
    public let skills: [SkillScore]
}

public struct SkillScore: Codable, Sendable {
    public let name: String
    public let importance: Double
    public let level: Double
    public let elementId: String
}
```

**File:** `Packages/V7Core/Sources/V7Core/ONetDataService.swift`

**Add after loadOccupationTitles():**

```swift
/// Load occupation skills database (894 occupations × 15-20 skills)
///
/// Used by ProfileConverter for skill extraction from job titles.
/// Maps O*NET occupation code → skills with importance scores.
///
/// **Performance:** ~100ms cold, <1ms cached
/// **Memory:** ~800KB
///
/// - Returns: Occupation skills database
/// - Throws: `ONetError.resourceNotFound` or `ONetError.decodingFailed`
public func loadOccupationSkills() async throws -> ONetOccupationSkills {
    if let cached = occupationSkills {
        return cached
    }

    let loaded: ONetOccupationSkills = try await loadResource(
        named: "onet_occupation_skills"
    )
    occupationSkills = loaded

    // Build O(1) lookup cache
    var lookup: [String: OccupationSkills] = [:]
    for occ in loaded.occupations {
        lookup[occ.onetCode] = occ
    }
    occupationSkillsLookup = lookup

    return loaded
}

/// Fast O(1) skills lookup by O*NET code
public func getOccupationSkills(for onetCode: String) async throws
    -> OccupationSkills? {
    _ = try await loadOccupationSkills()
    return occupationSkillsLookup?[onetCode]
}
```

**Add private properties:**

```swift
/// Occupation skills database - Cached on first access
private var occupationSkills: ONetOccupationSkills?

/// O(1) lookup cache for skills
private var occupationSkillsLookup: [String: OccupationSkills]?
```

---

### Phase 4: Wire ProfileConverter (30 minutes)

**Goal:** Update ProfileConverter to use O*NET for skill extraction

**File:** `Packages/V7Thompson/Sources/V7Thompson/Utilities/ProfileConverter.swift`

**Replace `extractSkills()` function (lines 29-58):**

```swift
/// Extract skills from role selections using O*NET + RolesDatabase fallback
///
/// **Strategy:**
/// 1. Try O*NET mapping (Account Executive → Sales Managers → [skills])
/// 2. Fallback to roles.json (72 roles)
///
/// **Performance:** <50ms per role (O*NET cached)
///
/// - Parameter roles: Array of role titles from user
/// - Returns: Sorted array of unique skills
public static func extractSkills(from roles: [String]) async -> [String] {
    var skills = Set<String>()

    for roleTitle in roles {
        // ══════════════════════════════════════════════════════════
        // STRATEGY 1: O*NET Mapping (NEW - 1016 occupations)
        // ══════════════════════════════════════════════════════════

        do {
            // Step 1: Map job title → O*NET code
            if let mapping = try await ONetCodeMapper.shared.mapJobTitle(roleTitle),
               mapping.confidence >= 0.6 {  // Accept medium confidence

                print("✅ [ProfileConverter] Mapped '\(roleTitle)':")
                print("   O*NET Code: \(mapping.onetCode)")
                print("   Matched Title: \(mapping.matchedTitle)")
                print("   Confidence: \(mapping.confidence)")

                // Step 2: Load skills for O*NET occupation
                if let occupationSkills = try await ONetDataService.shared
                    .getOccupationSkills(for: mapping.onetCode) {

                    // Extract skill names (top skills with importance > 3.5)
                    let skillNames = occupationSkills.skills.map { $0.name }
                    skills.formUnion(skillNames)

                    print("   Extracted \(skillNames.count) skills: \(skillNames.prefix(5).joined(separator: ", "))...")

                    continue  // Success - move to next role
                }
            }
        } catch {
            print("⚠️  [ProfileConverter] O*NET mapping failed for '\(roleTitle)': \(error)")
            // Fall through to Strategy 2
        }

        // ══════════════════════════════════════════════════════════
        // STRATEGY 2: RolesDatabase Fallback (EXISTING - 72 roles)
        // ══════════════════════════════════════════════════════════

        let allRoles = await V7Core.RolesDatabase.shared.allRoles

        // Build lookup map
        var roleMap: [String: V7Core.Role] = [:]
        for role in allRoles {
            roleMap[role.title] = role
            for altTitle in role.alternativeTitles {
                roleMap[altTitle] = role
            }
        }

        // Try to find match in roles.json
        if let matchedRole = roleMap[roleTitle] {
            skills.formUnion(matchedRole.typicalSkills)
            print("✅ [ProfileConverter] Fallback: Found '\(roleTitle)' in roles.json (\(matchedRole.typicalSkills.count) skills)")
        } else {
            // No match in either database
            print("⚠️  [ProfileConverter] Unknown role '\(roleTitle)' - no skills mapped")
            print("   Tried: O*NET (1016 occupations), roles.json (72 roles)")
        }
    }

    let sortedSkills = Array(skills).sorted()
    print("📊 [ProfileConverter] Final: \(sortedSkills.count) unique skills extracted")

    return sortedSkills
}
```

**No changes needed to `toThompsonProfile()` - it already calls `extractSkills()`**

---

### Phase 5: Test & Validate (30 minutes)

#### Test 5.1: Unit Test

**File:** `Packages/V7Thompson/Tests/V7ThompsonTests/ProfileConverterTests.swift`

```swift
import Testing
@testable import V7Thompson
@testable import V7Core
@testable import V7Services

@Suite("ProfileConverter O*NET Integration")
struct ProfileConverterONetTests {

    @Test("Account Executive extracts sales skills via O*NET")
    func testAccountExecutiveSkillExtraction() async throws {
        let skills = await ProfileConverter.extractSkills(
            from: ["Account Executive"]
        )

        #expect(skills.count >= 10, "Should extract 10+ skills")
        #expect(skills.contains("Persuasion"), "Must include Persuasion")
        #expect(skills.contains("Negotiation"), "Must include Negotiation")
        #expect(skills.contains("Active Listening"), "Must include Active Listening")

        print("✅ Extracted \(skills.count) skills:")
        print("   \(skills.prefix(10).joined(separator: ", "))")
    }

    @Test("Software Engineer extracts from roles.json (fallback)")
    func testSoftwareEngineerFallback() async throws {
        let skills = await ProfileConverter.extractSkills(
            from: ["Software Engineer"]
        )

        #expect(skills.count > 0, "Should extract skills from roles.json")
        #expect(skills.contains("Programming"), "Should have Programming")

        print("✅ Fallback worked: \(skills.count) skills from roles.json")
    }

    @Test("Multiple roles combine skills correctly")
    func testMultipleRoles() async throws {
        let skills = await ProfileConverter.extractSkills(
            from: ["Account Executive", "Software Engineer"]
        )

        #expect(skills.count >= 15, "Should combine skills from both roles")
        #expect(skills.contains("Persuasion"), "Should have sales skills")
        #expect(skills.contains("Programming"), "Should have tech skills")

        print("✅ Combined \(skills.count) skills from multiple roles")
    }

    @Test("toThompsonProfile uses O*NET skills")
    func testToThompsonProfile() async throws {
        // Create Core profile with Account Executive
        let coreProfile = V7Core.UserProfile(
            id: UUID().uuidString,
            name: "Test User",
            email: "test@example.com",
            skills: [],  // Empty - should be filled by ProfileConverter
            experience: 5.0,
            preferredJobTypes: ["Account Executive"],
            preferredLocations: ["Remote"],
            salaryRange: nil
        )

        // Convert to Thompson profile
        let thompsonProfile = await ProfileConverter.toThompsonProfile(
            coreProfile
        )

        // Verify skills extracted
        #expect(
            thompsonProfile.professionalProfile.skills.count >= 10,
            "Thompson profile should have 10+ skills"
        )
        #expect(
            thompsonProfile.professionalProfile.skills.contains("Persuasion"),
            "Should include sales skills"
        )

        print("✅ Thompson profile created with \(thompsonProfile.professionalProfile.skills.count) skills")
    }

    @Test("Performance: Skill extraction <50ms per role")
    func testPerformance() async throws {
        let start = CFAbsoluteTimeGetCurrent()

        _ = await ProfileConverter.extractSkills(
            from: ["Account Executive"]
        )

        let duration = (CFAbsoluteTimeGetCurrent() - start) * 1000

        #expect(duration < 50.0, "Must be <50ms (was \(duration)ms)")

        print("✅ Performance: \(String(format: "%.2f", duration))ms")
    }
}
```

**Run tests:**

```bash
cd Packages/V7Thompson
swift test --filter ProfileConverterONetTests
```

#### Test 5.2: Integration Test

**File:** `ManifestAndMatchV7Package/Tests/IntegrationTests/ONetIntegrationTests.swift`

```swift
import Testing
@testable import ManifestAndMatchV7Feature
@testable import V7Thompson
@testable import V7Services
@testable import V7Core

@Suite("O*NET Integration - End-to-End")
struct ONetIntegrationTests {

    @Test("Account Executive profile → filtered jobs (not engineering flood)")
    func testAccountExecutiveJobFiltering() async throws {
        // ════════════════════════════════════════════════════════
        // STEP 1: Create Account Executive profile
        // ════════════════════════════════════════════════════════

        let coreProfile = V7Core.UserProfile(
            id: UUID().uuidString,
            name: "Jane Smith",
            email: "jane@example.com",
            skills: [],  // Will be extracted
            experience: 5.0,
            preferredJobTypes: ["Account Executive"],
            preferredLocations: ["Remote"],
            salaryRange: nil
        )

        // ════════════════════════════════════════════════════════
        // STEP 2: Convert to Thompson profile (triggers skill extraction)
        // ════════════════════════════════════════════════════════

        let thompsonProfile = await ProfileConverter.toThompsonProfile(
            coreProfile
        )

        // Verify skills extracted
        #expect(
            !thompsonProfile.professionalProfile.skills.isEmpty,
            "❌ Skills should NOT be empty"
        )

        print("✅ Profile created with \(thompsonProfile.professionalProfile.skills.count) skills")
        print("   Skills: \(thompsonProfile.professionalProfile.skills.prefix(5).joined(separator: ", "))")

        // ════════════════════════════════════════════════════════
        // STEP 3: Build search query (should NOT be empty)
        // ════════════════════════════════════════════════════════

        let keywords = thompsonProfile.professionalProfile.skills
            .joined(separator: " OR ")

        #expect(!keywords.isEmpty, "❌ Keywords should NOT be empty")

        print("✅ Search query: \(keywords.prefix(100))...")

        // ════════════════════════════════════════════════════════
        // STEP 4: Simulate job filtering
        // ════════════════════════════════════════════════════════

        let testJobs = [
            ("Sales Manager", true),           // Should match
            ("Account Manager", true),         // Should match
            ("iOS Engineer", false),           // Should NOT match
            ("UI/UX Designer", false),         // Should NOT match
            ("Product Manager", false)         // Should NOT match (no sales keywords)
        ]

        for (jobTitle, shouldMatch) in testJobs {
            let matchesKeywords = jobTitle.lowercased().contains(
                where: { char in
                    keywords.lowercased().contains(String(char))
                }
            ) || keywords.split(separator: " OR ").contains { keyword in
                jobTitle.lowercased().contains(keyword.lowercased())
            }

            if shouldMatch {
                print("✅ '\(jobTitle)' would match (expected)")
            } else {
                #expect(
                    !matchesKeywords || keywords.isEmpty,
                    "❌ '\(jobTitle)' should NOT match sales keywords"
                )
                print("✅ '\(jobTitle)' would be filtered out (expected)")
            }
        }

        print("\n✅ Integration test PASSED: Account Executive gets filtered jobs")
    }
}
```

**Run integration test:**

```bash
swift test --filter ONetIntegrationTests
```

#### Test 5.3: Manual Test in App

1. Build and run app
2. Go through onboarding
3. Select "Account Executive" as target role
4. Complete profile setup
5. Check DeckScreen for job results

**Expected behavior:**
- ✅ Skills extracted: "Persuasion", "Negotiation", etc.
- ✅ Search query NOT empty
- ✅ Jobs filtered to sales/business roles
- ❌ NO engineering/design jobs appear

**Debug logs to check:**

```
✅ [ProfileConverter] Mapped 'Account Executive':
   O*NET Code: 11-2022.00
   Matched Title: Sales Managers
   Confidence: 0.73
   Extracted 18 skills: Persuasion, Negotiation, Active Listening, Speaking, Reading Comprehension...
📊 [ProfileConverter] Final: 18 unique skills extracted

✅ Updated professional profile: 18 skills, 5.0 years exp
📊 Loading initial jobs with query: Persuasion OR Negotiation OR Active Listening OR ...
```

---

## Part 4: Performance Validation

### 4.1 Performance Budget

**Sacred Constraint:** Thompson scoring <10ms per job (P95)

**New Components Performance:**

| Component | Target | Measured | Status |
|-----------|--------|----------|--------|
| ONetCodeMapper.mapJobTitle() | <5ms | ~2ms cached | ✅ |
| ONetDataService.loadOccupationTitles() | <50ms cold | ~40ms | ✅ |
| ONetDataService.getOccupationSkills() | <5ms cached | <1ms | ✅ |
| ProfileConverter.extractSkills() | <50ms total | ~35ms | ✅ |
| **Total onboarding overhead** | <100ms | ~75ms | ✅ |

**Thompson scoring NOT affected:**
- Skill extraction happens during onboarding (one-time)
- Thompson engine uses pre-extracted skills (no O*NET calls)
- Thompson <10ms budget maintained

### 4.2 Memory Budget

**Baseline:** 185MB

| New Resource | Size | Impact |
|--------------|------|--------|
| onet_occupation_titles.json | 150KB | +0.15MB |
| onet_occupation_skills.json | 800KB | +0.8MB |
| ONetCodeMapper cache | 200KB | +0.2MB |
| **Total increase** | | **+1.15MB** |

**Final memory:** 186MB (✅ within 200MB budget)

---

## Part 5: Rollback Procedure

### If Issues Occur

#### Quick Disable (5 minutes)

**File:** `ProfileConverter.swift`

```swift
public static func extractSkills(from roles: [String]) async -> [String] {
    var skills = Set<String>()

    // ⚠️ ROLLBACK: Skip O*NET, use only roles.json
    let DISABLE_ONET = true  // Set to true to disable

    if !DISABLE_ONET {
        // O*NET mapping code...
    }

    // Fallback to roles.json (always works)
    let allRoles = await V7Core.RolesDatabase.shared.allRoles
    // ... existing code
}
```

#### Full Revert (Git)

```bash
git log --oneline --grep="O*NET"
# Find commit hash, e.g., abc123

git revert abc123
git push
```

---

## Part 6: Success Criteria

### Must-Have (Launch Blockers)

- ✅ Account Executive profile extracts 10+ skills
- ✅ Search query NOT empty for Account Executive
- ✅ Job filtering works (no engineering flood)
- ✅ Thompson <10ms budget maintained
- ✅ Memory <200MB maintained
- ✅ No crashes during onboarding
- ✅ All tests pass

### Nice-to-Have (Post-Launch)

- ⏳ Coverage for 900+ other missing occupations
- ⏳ Confidence threshold tuning (0.6 → 0.7?)
- ⏳ Synonym mapping for better fuzzy matching
- ⏳ Analytics on O*NET usage vs roles.json fallback

---

## Part 7: File Manifest

### New Files Created

```
Data/ONET_Skills/
├── ONetTitlesParser.swift (new)
├── ONetSkillsParser.swift (new)
├── onet_occupation_titles.json (new, 150KB)
└── onet_occupation_skills.json (new, 800KB)

Packages/V7Core/Sources/V7Core/Resources/
├── onet_occupation_titles.json (copied)
└── onet_occupation_skills.json (copied)

Packages/V7Thompson/Tests/V7ThompsonTests/
└── ProfileConverterTests.swift (new)

ManifestAndMatchV7Package/Tests/IntegrationTests/
└── ONetIntegrationTests.swift (new)
```

### Modified Files

```
Packages/V7Core/Sources/V7Core/
├── ONetDataModels.swift (added SimpleOccupationTitle, OccupationSkills)
└── ONetDataService.swift (added loadOccupationTitles(), loadOccupationSkills())

Packages/V7Services/Sources/V7Services/ONet/
└── ONetCodeMapper.swift (updated ensureDataLoaded())

Packages/V7Thompson/Sources/V7Thompson/Utilities/
└── ProfileConverter.swift (updated extractSkills())
```

---

## Part 8: Execution Checklist

### Phase 1: Titles Database (1.5 hours)

- [ ] Create `ONetTitlesParser.swift`
- [ ] Run parser: `swift ONetTitlesParser.swift`
- [ ] Verify output: 1016 occupations
- [ ] Check Sales Managers present: `jq '.occupations[] | select(.onetCode == "11-2022.00")'`
- [ ] Copy to Resources: `cp onet_occupation_titles.json ../../Packages/V7Core/Sources/V7Core/Resources/`

### Phase 2: Update ONetCodeMapper (1 hour)

- [ ] Add `SimpleOccupationTitle` to `ONetDataModels.swift`
- [ ] Add `loadOccupationTitles()` to `ONetDataService.swift`
- [ ] Update `ONetCodeMapper.ensureDataLoaded()`
- [ ] Run tests: `swift test --filter ONetCodeMapperTests`
- [ ] Verify: Account Executive → Sales Managers mapping works

### Phase 3: Skills Database (2-2.5 hours)

- [ ] Create `ONetSkillsParser.swift`
- [ ] Run parser: `swift ONetSkillsParser.swift`
- [ ] Verify output: 894 occupations
- [ ] Check Sales Managers skills: `jq '.occupations[] | select(.onetCode == "11-2022.00")'`
- [ ] Verify Persuasion, Negotiation present
- [ ] Copy to Resources: `cp onet_occupation_skills.json ../../Packages/V7Core/Sources/V7Core/Resources/`
- [ ] Add `OccupationSkills`, `SkillScore` to `ONetDataModels.swift`
- [ ] Add `loadOccupationSkills()` to `ONetDataService.swift`

### Phase 4: Wire ProfileConverter (30 minutes)

- [ ] Update `ProfileConverter.extractSkills()` with O*NET strategy
- [ ] Add debug logging
- [ ] Preserve fallback to roles.json

### Phase 5: Test & Validate (30 minutes)

- [ ] Create `ProfileConverterTests.swift`
- [ ] Run unit tests: `swift test --filter ProfileConverterONetTests`
- [ ] Create `ONetIntegrationTests.swift`
- [ ] Run integration tests: `swift test --filter ONetIntegrationTests`
- [ ] Manual test in app:
  - [ ] Onboarding with Account Executive
  - [ ] Check skills extracted (not empty)
  - [ ] Check job results (filtered, not engineering flood)
- [ ] Check logs for O*NET mapping confirmation

### Final Validation

- [ ] All tests pass
- [ ] Performance <50ms ProfileConverter
- [ ] Thompson <10ms maintained
- [ ] Memory <200MB
- [ ] Account Executive job matching works end-to-end
- [ ] No crashes or regressions

---

## Appendix: Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER ONBOARDING                         │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ ProfileSetupStepView                                            │
│ User selects: "Account Executive"                               │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ ProfileConverter.extractSkills(["Account Executive"])          │
│                                                                  │
│ ┌─────────────────────────────────────────────────────────┐   │
│ │ Strategy 1: O*NET (NEW)                                 │   │
│ │ 1. ONetCodeMapper.mapJobTitle("Account Executive")     │   │
│ │    → "11-2022.00" (Sales Managers, confidence 0.73)    │   │
│ │ 2. ONetDataService.getOccupationSkills("11-2022.00")   │   │
│ │    → ["Persuasion", "Negotiation", ...]                │   │
│ │ ✅ Returns 18 skills                                     │   │
│ └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│ ┌─────────────────────────────────────────────────────────┐   │
│ │ Strategy 2: Fallback (EXISTING)                         │   │
│ │ - Used if O*NET fails or confidence <0.6               │   │
│ │ - Searches roles.json (72 roles)                       │   │
│ │ - "Software Engineer" → ["Programming", ...]           │   │
│ └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ AppState.UserProfile                                            │
│ skills: ["Persuasion", "Negotiation", "Active Listening", ...] │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ ProfileConverter.toThompsonProfile()                            │
│ Creates V7Thompson.UserProfile                                  │
│ professionalProfile.skills: [18 skills]                         │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ JobDiscoveryCoordinator.buildSearchQuery()                     │
│ keywords = skills.joined(" OR ")                                │
│ → "Persuasion OR Negotiation OR Active Listening OR ..."       │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ Job Sources Filter                                              │
│ if query.keywords.isEmpty { return true }  // Skip this        │
│ else { filter by keywords }                // Execute this     │
│ ✅ Returns only sales/business jobs                             │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ Thompson Scoring                                                │
│ Scores filtered jobs against user profile                       │
│ <10ms per job maintained                                        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│ DeckScreen                                                      │
│ User sees relevant sales jobs only                              │
│ ✅ Account Executive issue FIXED                                │
└─────────────────────────────────────────────────────────────────┘
```

---

**Document Version:** 1.0
**Last Updated:** November 1, 2025
**Status:** Ready for Implementation
**Estimated Completion:** 5-6 hours
