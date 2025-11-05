# Bias Elimination Todo List with Agent Assignments
*Complete Execution Plan with Specialized Agent Allocation*

**Project**: ManifestAndMatchV7 - Job Discovery Bias Elimination
**Reference Documents**:
- Strategic Plan: `JOB_DISCOVERY_BIAS_ELIMINATION_STRATEGIC_PLAN.md`
- Implementation Checklist: `BIAS_ELIMINATION_IMPLEMENTATION_CHECKLIST.md`

**Created**: October 14, 2025
**Total Tasks**: 89
**Total Duration**: 21 days (168 hours)

---

## 📋 TODO LIST FORMAT

Each task includes:
- **Task ID**: Unique identifier (P1.1, P2.1, etc.)
- **Agent**: Which specialized agent should execute this
- **Location**: Exact file path and line numbers
- **Action**: What needs to be done
- **Validation**: How to verify completion
- **Dependencies**: What must be completed first
- **Priority**: P0 (critical), P1 (high), P2 (medium)

---

## 🚀 PHASE 1: IMMEDIATE CRITICAL FIXES (8 hours)

### P1.1: Remove "Software Engineer" Default Query
**Agent**: `backend-ios-expert`
**Priority**: P0 - CRITICAL
**Duration**: 30 minutes
**Dependencies**: None

**Location**:
```
File: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
Line: 769
Function: buildSearchQuery()
```

**Action**:
```swift
// FIND AND REPLACE:
// FROM:
keywords: keywords.isEmpty ? "Software Engineer" : keywords

// TO:
keywords: keywords  // No fallback - empty string when no skills
```

**Agent Instructions**:
```
Use backend-ios-expert agent to:
1. Read Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
2. Locate buildSearchQuery() function around line 769
3. Edit line 769 to remove "Software Engineer" fallback
4. Remove the ternary operator, just use keywords directly
5. Validate by searching for "Software Engineer" in file
6. Build to verify no compilation errors
7. Run tests to ensure JobDiscoveryCoordinator still works
```

**Validation Commands**:
```bash
# Search for remaining "Software Engineer" defaults
grep -r "Software Engineer" Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift

# Build package
cd Packages/V7Services && swift build

# Run tests
cd Packages/V7Services && swift test
```

**Success Criteria**:
- ✅ No "Software Engineer" string in keyword fallback
- ✅ Build succeeds
- ✅ Tests pass

---

### P1.2: Remove Thompson Sampling Tech Bias
**Agent**: `ml-engineering-specialist`
**Priority**: P0 - CRITICAL
**Duration**: 1 hour
**Dependencies**: None

**Location**:
```
File: Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
Lines: 391-401
Function: calculateBasicProfessionalScore()
```

**Action**:
```swift
// REPLACE ENTIRE FUNCTION:
private func calculateBasicProfessionalScore(job: Job, baseScore: Double) -> Double {
    // With no user profile, return base score without any bias
    // Professional scoring should only apply when we have actual user skills
    return min(1.0, baseScore)
}
```

**Agent Instructions**:
```
Use ml-engineering-specialist agent to:
1. Read Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
2. Locate calculateBasicProfessionalScore() function (lines 391-401)
3. Identify the hardcoded tech skills array: ["swift", "ios", "mobile", "app", "development"]
4. Replace entire function body with neutral scoring (return baseScore only)
5. Remove skill matching logic completely
6. Validate Thompson Sampling still works without bias
7. Run performance benchmarks to ensure <10ms maintained
8. Test with various job types to verify uniform scoring
```

**Validation Commands**:
```bash
# Search for tech skill arrays
grep -r "swift.*ios.*mobile" Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift

# Build Thompson package
cd Packages/V7Thompson && swift build

# Run Thompson tests
cd Packages/V7Thompson && swift test

# Run performance tests
swift test --filter ThompsonPerformanceTests
```

**Success Criteria**:
- ✅ No hardcoded tech skills in function
- ✅ Thompson performance still <10ms
- ✅ All tests pass
- ✅ Tech jobs score 45-55% (not 65-75%)

---

### P1.3: Use Neutral Thompson Sampling Priors
**Agent**: `algorithm-math-expert`
**Priority**: P0 - CRITICAL
**Duration**: 30 minutes
**Dependencies**: None

**Location**:
```
File: Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
Lines: 342-349
Function: scoreJob()
```

**Action**:
```swift
// CHANGE FROM:
let amberAlpha = 1.5
let amberBeta = 1.5
let tealAlpha = 2.0
let tealBeta = 2.0

// CHANGE TO:
// Use Beta(1,1) for completely neutral prior when no user data exists
let amberAlpha = 1.0
let amberBeta = 1.0
let tealAlpha = 1.0
let tealBeta = 1.0
```

**Agent Instructions**:
```
Use algorithm-math-expert agent to:
1. Read Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
2. Locate Beta parameter initialization in scoreJob() (lines 342-349)
3. Change all alpha/beta parameters from 1.5/2.0 to 1.0
4. Add mathematical comment explaining Beta(1,1) creates uniform distribution
5. Verify mathematical correctness of change
6. Validate Beta distribution sampling still works correctly
7. Test score distribution is now uniform (0.45-0.55 range)
8. Ensure no impact on Thompson Sampling performance
```

**Validation Commands**:
```bash
# Build and test
cd Packages/V7Thompson && swift build && swift test

# Run statistical tests
swift test --filter BetaDistributionTests

# Check score distribution
swift test --filter ScoreDistributionTests
```

**Success Criteria**:
- ✅ Beta(1,1) uniform priors used
- ✅ Score distribution is uniform (std dev <0.10)
- ✅ Performance maintained <10ms
- ✅ All tests pass

---

### P1.4: Replace iOS-Specific RSS Feeds
**Agent**: `backend-ios-expert`
**Priority**: P0 - CRITICAL
**Duration**: 1 hour
**Dependencies**: None

**Location**:
```
File: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
Lines: 1948-1952
Property: rssFeedUrls
```

**Action**:
```swift
// REPLACE:
private let rssFeedUrls = [
    "https://remoteok.io/remote-ios-jobs.rss",        // iOS ONLY - REMOVE
    "https://remoteok.io/remote-swift-jobs.rss",      // Swift ONLY - REMOVE
    "https://himalayas.app/jobs/rss"
]

// WITH:
private let rssFeedUrls = [
    "https://remoteok.io/remote-jobs.rss",            // All jobs
    "https://weworkremotely.com/remote-jobs.rss",     // All categories
    "https://himalayas.app/jobs/rss",                 // All jobs
    "https://jobicy.com/api/v2/remote-jobs.rss"       // All categories
]
```

**Agent Instructions**:
```
Use backend-ios-expert agent to:
1. Read Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
2. Locate rssFeedUrls property (around line 1948)
3. Replace iOS/Swift-specific feed URLs with generic job feeds
4. Verify RSS parsing logic doesn't filter by tech keywords
5. Search for any iOS-specific filtering in RSS parser functions
6. Remove any tech keyword filters in RSS processing
7. Test RSS feed fetching with new URLs
8. Verify job titles span multiple industries (healthcare, finance, etc.)
9. Monitor network requests to confirm new URLs are used
```

**Validation Commands**:
```bash
# Search for iOS-specific feeds
grep -r "remote-ios-jobs\|remote-swift-jobs" Packages/V7Services/

# Search for tech keyword filtering in RSS parsing
grep -r "ios\|swift\|mobile" Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift | grep -i "filter\|contains"

# Build and test
cd Packages/V7Services && swift build && swift test
```

**Success Criteria**:
- ✅ No iOS/Swift-specific RSS feed URLs
- ✅ RSS parsing has no tech keyword filters
- ✅ Jobs fetched span multiple sectors
- ✅ Build succeeds, tests pass

---

### P1.5: Remove Default Tech Industries
**Agent**: `ios-app-architect`
**Priority**: P0 - CRITICAL
**Duration**: 30 minutes
**Dependencies**: None

**Location**:
```
File: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
Lines: 94-106
Function: createDefaultUserProfile()
```

**Action**:
```swift
// CHANGE FROM:
preferences: UserPreferences(
    preferredLocations: ["Remote", "San Francisco, CA", "New York, NY"],
    industries: ["Technology", "Software"]
)

// CHANGE TO:
preferences: UserPreferences(
    preferredLocations: [],  // Empty - no defaults
    industries: []           // Empty - no defaults
)
```

**Agent Instructions**:
```
Use ios-app-architect agent to:
1. Read Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
2. Locate createDefaultUserProfile() function (lines 94-106)
3. Remove default values from preferredLocations array
4. Remove default values from industries array
5. Verify UserPreferences accepts empty arrays
6. Check if any other code depends on these defaults
7. Update any dependent code to handle empty arrays
8. Test profile creation with empty defaults
9. Ensure app doesn't crash with empty preferences
```

**Validation Commands**:
```bash
# Search for other default industry references
grep -r '"Technology"\|"Software"' Packages/V7Services/ | grep -v "test\|Test"

# Build and test
cd Packages/V7Services && swift build && swift test

# Test profile initialization
swift test --filter UserProfileTests
```

**Success Criteria**:
- ✅ No default industries in profile
- ✅ No default locations in profile
- ✅ App handles empty preferences correctly
- ✅ Tests pass

---

### P1.6: Remove Core Data Tech Default
**Agent**: `ios-app-architect`
**Priority**: P0 - CRITICAL
**Duration**: 45 minutes
**Dependencies**: None

**Location**:
```
File: Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift
Lines: 97-106
Function: awakeFromInsert()
```

**Action**:
```swift
// CHANGE FROM:
public override func awakeFromInsert() {
    super.awakeFromInsert()
    id = UUID()
    createdDate = Date()
    lastModified = Date()
    currentDomain = "technology"  // REMOVE
    experienceLevel = "mid"       // REMOVE
    amberTealPosition = 0.5
    remotePreference = "hybrid"   // REMOVE
}

// CHANGE TO:
public override func awakeFromInsert() {
    super.awakeFromInsert()
    id = UUID()
    createdDate = Date()
    lastModified = Date()
    currentDomain = nil          // No default
    experienceLevel = nil        // No default
    amberTealPosition = 0.5      // Keep neutral
    remotePreference = nil       // No default
}
```

**Agent Instructions**:
```
Use ios-app-architect agent to:
1. Read Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift
2. Locate awakeFromInsert() override (lines 97-106)
3. Change currentDomain from "technology" to nil
4. Change experienceLevel from "mid" to nil
5. Change remotePreference from "hybrid" to nil
6. Verify properties are declared as optional (String?)
7. Update property declarations if needed
8. Test Core Data entity creation with nil values
9. Ensure app handles nil values correctly
10. Run migration tests to verify no data corruption
```

**Validation Commands**:
```bash
# Build V7Data package
cd Packages/V7Data && swift build

# Run Core Data tests
cd Packages/V7Data && swift test

# Run migration tests
swift test --filter MigrationTests
```

**Success Criteria**:
- ✅ No "technology" default in Core Data
- ✅ Properties are optional and accept nil
- ✅ App handles nil values correctly
- ✅ Migration tests pass

---

### P1.FINAL: Phase 1 Integration Testing
**Agent**: `testing-qa-strategist`
**Priority**: P0 - CRITICAL
**Duration**: 2 hours
**Dependencies**: P1.1, P1.2, P1.3, P1.4, P1.5, P1.6

**Action**: Comprehensive validation of all Phase 1 changes

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. BUILD VALIDATION:
   - Build entire workspace
   - Verify all packages compile
   - Check for new warnings
   - Confirm no compilation errors

2. TEST SUITE VALIDATION:
   - Run full test suite
   - Verify all existing tests pass
   - Check for test failures
   - Review test coverage

3. MANUAL TESTING:
   - Delete app from simulator
   - Clean build and install
   - Launch app (should show onboarding)
   - Verify no jobs shown without profile
   - Complete onboarding as "Nurse"
   - Verify healthcare jobs shown (not tech)
   - Check match scores (should be profile-based)

4. BIAS VERIFICATION:
   - Search for remaining tech defaults
   - Verify no "Software Engineer" in API calls
   - Confirm RSS feeds are diverse
   - Check Thompson scoring is neutral
   - Validate no +10% tech bonus

5. PERFORMANCE VALIDATION:
   - Thompson Sampling <10ms maintained
   - Memory usage <200MB maintained
   - UI still 60fps
   - No performance regressions

6. CREATE TEST REPORT:
   - Document all validation results
   - List any issues found
   - Provide recommendations
   - Sign off on Phase 1 completion
```

**Validation Commands**:
```bash
# Full workspace build
xcodebuild -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 build

# Full test suite
xcodebuild -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 test

# Search for tech bias
grep -r "software engineer\|ios developer" --include="*.swift" Packages/ | grep -v test
grep -r "swift.*ios.*mobile" --include="*.swift" Packages/V7Thompson/
grep -r '"Technology"\|"Software"' --include="*.swift" Packages/ | grep -v test

# Performance benchmarks
swift test --filter PerformanceTests
```

**Success Criteria**:
- ✅ All builds succeed
- ✅ All tests pass
- ✅ No tech bias detected
- ✅ Manual testing confirms neutral behavior
- ✅ Performance budgets maintained
- ✅ Ready for Phase 2

---

## 🚪 PHASE 2: PROFILE COMPLETION GATE (6 hours)

### P2.1: Add Profile Completion Check
**Agent**: `ios-app-architect`
**Priority**: P1 - HIGH
**Duration**: 2 hours
**Dependencies**: Phase 1 complete

**Location**:
```
File: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/ContentView.swift
Lines: 887-949
Function: loadInitialJobs()
```

**Action**:
```swift
// ADD AT START OF loadInitialJobs():
guard UserDefaults.standard.bool(forKey: "v7_has_onboarded"),
      appState.userProfile != nil else {
    viewState = .onboarding
    logger.info("Profile incomplete - showing onboarding")
    return
}
```

**Agent Instructions**:
```
Use ios-app-architect agent to:

1. ANALYZE CURRENT FLOW:
   - Read ContentView.swift
   - Understand current job loading logic
   - Identify where loadInitialJobs() is called
   - Map out app state transitions

2. ADD PROFILE GATE:
   - Add guard statement at start of loadInitialJobs()
   - Check v7_has_onboarded UserDefaults flag
   - Check appState.userProfile is not nil
   - Set viewState to .onboarding if check fails
   - Add logging for debugging

3. UPDATE VIEW STATE:
   - Verify .onboarding case exists in ViewState enum
   - Add enum case if missing
   - Update switch statement to handle .onboarding
   - Ensure onboarding view is shown

4. HANDLE EDGE CASES:
   - User cancels onboarding
   - Profile save fails
   - App killed during onboarding
   - Background/foreground transitions

5. TESTING:
   - Fresh install shows onboarding
   - Completed profile shows jobs
   - Incomplete profile shows onboarding
   - Profile deletion shows onboarding
```

**Validation Commands**:
```bash
# Build feature package
cd ManifestAndMatchV7Package && swift build

# Run UI tests
swift test --filter ContentViewTests

# Manual test
# 1. Delete app
# 2. Install
# 3. Launch -> verify onboarding shown
# 4. Check logs for "Profile incomplete" message
```

**Success Criteria**:
- ✅ Guard statement added
- ✅ Onboarding shown when profile missing
- ✅ Jobs not loaded without profile
- ✅ Logs show correct messages
- ✅ Tests pass

---

### P2.2: Wire Onboarding Completion to Job Coordinator
**Agent**: `backend-ios-expert`
**Priority**: P1 - HIGH
**Duration**: 4 hours
**Dependencies**: P2.1

**Location**:
```
File: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/OnboardingFlow.swift
Lines: 816-875
Function: handleOnboardingComplete() or similar
```

**Action**:
```swift
// ADD BEFORE onComplete() call:
if let profile = appState.userProfile {
    await jobCoordinator.updateFromCoreProfile(profile)
    logger.info("Job coordinator updated with profile: \(profile.id)")
}
```

**Agent Instructions**:
```
Use backend-ios-expert agent to:

1. ANALYZE ONBOARDING FLOW:
   - Read OnboardingFlow.swift completely
   - Identify where onboarding completes
   - Understand profile creation flow
   - Map data flow from UI to persistence

2. LOCATE COMPLETION HANDLER:
   - Find function called when user completes onboarding
   - Identify where UserDefaults flags are set
   - Locate where onComplete() callback is invoked
   - Understand current completion logic

3. ADD COORDINATOR UPDATE:
   - Get reference to jobCoordinator
   - Get user profile from appState
   - Call updateFromCoreProfile() with profile
   - Add error handling for failure cases
   - Add comprehensive logging

4. VERIFY updateFromCoreProfile() EXISTS:
   - Check JobDiscoveryCoordinator for method
   - If missing, create the method:
     ```swift
     public func updateFromCoreProfile(_ coreProfile: V7Core.UserProfile) async {
         let thompsonProfile = ProfileConverter.toThompsonProfile(coreProfile)
         self.userProfile = thompsonProfile
         await clearJobs()
         await loadInitialJobs()
     }
     ```

5. HANDLE ASYNC PROPERLY:
   - Make completion handler async if needed
   - Use Task if coordinator update must be async
   - Ensure proper error propagation
   - Add loading indicators if needed

6. TESTING:
   - Complete onboarding as Nurse
   - Verify jobs reflect nursing profile
   - Check logs for coordinator update
   - Test various profile types
```

**Validation Commands**:
```bash
# Build packages
cd ManifestAndMatchV7Package && swift build
cd Packages/V7Services && swift build

# Run onboarding tests
swift test --filter OnboardingFlowTests

# Run integration tests
swift test --filter ProfileIntegrationTests

# Manual test
# 1. Complete onboarding as "Nurse"
# 2. Check console for "Job coordinator updated"
# 3. Verify healthcare jobs shown
# 4. Repeat with different profiles
```

**Success Criteria**:
- ✅ Coordinator update call added
- ✅ updateFromCoreProfile() method exists
- ✅ Jobs loaded after onboarding
- ✅ Jobs match selected profile
- ✅ Tests pass

---

### P2.FINAL: Phase 2 Integration Testing
**Agent**: `testing-qa-strategist`
**Priority**: P1 - HIGH
**Duration**: 1 hour
**Dependencies**: P2.1, P2.2

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. TEST PROFILE GATING:
   - Fresh install -> onboarding shown
   - Delete profile -> onboarding shown
   - Complete profile -> jobs shown
   - Incomplete profile -> onboarding shown

2. TEST PROFILE TYPES:
   Test Matrix:
   - Nurse profile -> Healthcare jobs
   - Accountant profile -> Finance jobs
   - Developer profile -> Tech jobs
   - Teacher profile -> Education jobs
   - Sales Rep profile -> Sales jobs

3. VERIFY NO TECH BIAS:
   - Non-tech profiles don't show tech jobs
   - Match scores reflect actual profile
   - No tech keyword bonuses applied

4. ERROR HANDLING:
   - Onboarding cancellation
   - Profile save failure
   - Coordinator update failure
   - Network errors during job load

5. PERFORMANCE:
   - Onboarding completion <2s
   - Profile update <500ms
   - Jobs load <3s after completion

6. CREATE TEST REPORT:
   - Document results
   - List any issues
   - Provide recommendations
   - Sign off on Phase 2
```

**Validation Commands**:
```bash
# Run full test suite
xcodebuild -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 test

# Run specific test groups
swift test --filter OnboardingTests
swift test --filter ProfileTests
swift test --filter JobLoadingTests
```

**Success Criteria**:
- ✅ All profile types tested
- ✅ No tech bias for non-tech profiles
- ✅ Error handling works
- ✅ Performance acceptable
- ✅ Ready for Phase 3

---

## 📦 PHASE 3: EXTERNALIZE CONFIGURATION DATA (40 hours)

### P3.1: Create Configuration Service Architecture
**Agent**: `backend-ios-expert`
**Priority**: P1 - HIGH
**Duration**: 4 hours
**Dependencies**: Phase 2 complete

**Location**:
```
New File: Packages/V7Services/Sources/V7Services/Configuration/ConfigurationProvider.swift
```

**Action**: Create comprehensive configuration protocol and types

**Agent Instructions**:
```
Use backend-ios-expert agent to:

1. CREATE DIRECTORY STRUCTURE:
   mkdir -p Packages/V7Services/Sources/V7Services/Configuration

2. CREATE ConfigurationProvider.swift:
   - Define ConfigurationProvider protocol
   - Must be Sendable for Swift 6 concurrency
   - Methods: getSkills(), getRoles(), getCompanies(), getRSSFeeds(), getBenefits()
   - All methods async throws for error handling

3. CREATE CONFIGURATION TYPES:
   - SkillsConfiguration: version, skills array, categories
   - Skill: id, name, category, sector (Codable, Sendable, Hashable, Identifiable)
   - SkillCategory: id, name, sector
   - JobRole: id, title, category, sector, skills array
   - Company: id, name, sector, apiType, identifier
   - APIType enum: greenhouse, lever, custom
   - RSSFeed: id, url, sector, description
   - Benefit: id, name, category

4. ADD ERROR HANDLING:
   - ConfigurationError enum
   - fileNotFound(String)
   - decodingError(String)
   - networkError(String)
   - versionMismatch(String)

5. ENSURE SWIFT 6 COMPLIANCE:
   - All types Sendable
   - All async methods properly marked
   - No data races possible
   - Actor isolation correct

6. ADD DOCUMENTATION:
   - Protocol documentation
   - Type documentation
   - Usage examples
   - Migration guide
```

**Validation Commands**:
```bash
# Build Services package
cd Packages/V7Services && swift build

# Check for concurrency warnings
swift build -Xswiftc -warn-concurrency

# Verify protocol compiles
swift build --target V7Services
```

**Success Criteria**:
- ✅ Protocol defined correctly
- ✅ All types Sendable
- ✅ No concurrency warnings
- ✅ Builds successfully
- ✅ Documentation complete

---

### P3.2: Create JSON Configuration Files
**Agent**: `general-purpose`
**Priority**: P1 - HIGH
**Duration**: 8 hours (data entry intensive)
**Dependencies**: P3.1

**Location**:
```
New Directory: Packages/V7Services/Resources/
New Files:
  - skills.json (500+ skills)
  - roles.json (100+ roles)
  - companies.json (100+ companies)
  - rss_feeds.json (30+ feeds)
  - benefits.json (50+ benefits)
```

**Action**: Create comprehensive JSON data across all sectors

**Agent Instructions**:
```
Use general-purpose agent to:

1. CREATE RESOURCES DIRECTORY:
   mkdir -p Packages/V7Services/Resources

2. CREATE skills.json:
   Structure:
   {
     "version": "1.0.0",
     "skills": [...],
     "categories": [...]
   }

   Add 500+ skills across sectors:
   - Healthcare: 100+ (Patient Care, EMR, Nursing, etc.)
   - Finance: 80+ (Financial Analysis, Accounting, etc.)
   - Technology: 100+ (Swift, iOS, Python, etc.)
   - Education: 50+ (Teaching, Curriculum, etc.)
   - Retail: 40+ (Sales, Merchandising, etc.)
   - Hospitality: 40+ (Customer Service, Management, etc.)
   - Legal: 30+ (Legal Research, Compliance, etc.)
   - Marketing: 50+ (SEO, Content, Social Media, etc.)
   - Sales: 40+ (B2B, Lead Generation, etc.)
   - Others: 70+ (remaining sectors)

3. CREATE roles.json:
   Add 100+ roles across sectors:
   - Healthcare: 20 roles
   - Finance: 15 roles
   - Technology: 20 roles
   - Education: 15 roles
   - Retail: 10 roles
   - Others: 20 roles

   Each role includes:
   - Descriptive title
   - Category and sector
   - Relevant skills array

4. CREATE companies.json:
   Add 100+ companies across sectors:
   - Healthcare: 25 (Kaiser, Mayo Clinic, HCA, etc.)
   - Finance: 25 (JPMorgan, Goldman Sachs, etc.)
   - Technology: 25 (Airbnb, Stripe, etc.)
   - Retail: 15 (Walmart, Target, etc.)
   - Others: 10

   Each company includes:
   - Name, sector, apiType (greenhouse/lever)
   - API identifier for integration

5. CREATE rss_feeds.json:
   Add 30+ RSS feeds:
   - Healthcare: 5 feeds
   - Finance: 3 feeds
   - Technology: 5 feeds
   - Education: 3 feeds
   - General/Multi-sector: 10 feeds
   - Others: 4 feeds

6. CREATE benefits.json:
   Add 50+ benefits:
   - Healthcare category: 15
   - Financial category: 10
   - Work-life balance: 10
   - Professional development: 10
   - Other: 5

7. VALIDATE ALL JSON:
   - Correct syntax
   - Valid UUIDs
   - No duplicates
   - Consistent structure

8. UPDATE Package.swift:
   Add resources to target:
   resources: [.process("Resources")]
```

**Validation Commands**:
```bash
# Validate JSON syntax
for file in Packages/V7Services/Resources/*.json; do
    echo "Validating $file"
    python3 -m json.tool "$file" > /dev/null && echo "✅" || echo "❌"
done

# Count items
jq '.skills | length' Packages/V7Services/Resources/skills.json
jq '.roles | length' Packages/V7Services/Resources/roles.json
jq '.companies | length' Packages/V7Services/Resources/companies.json
jq '.feeds | length' Packages/V7Services/Resources/rss_feeds.json

# Check for duplicates
jq '.skills | group_by(.name) | map(select(length > 1))' Packages/V7Services/Resources/skills.json
```

**Success Criteria**:
- ✅ 500+ skills created
- ✅ 100+ roles created
- ✅ 100+ companies created
- ✅ 30+ RSS feeds created
- ✅ 50+ benefits created
- ✅ All JSON valid
- ✅ No duplicates
- ✅ Package.swift updated

---

### P3.3: Implement Local Configuration Service
**Agent**: `backend-ios-expert`
**Priority**: P1 - HIGH
**Duration**: 4 hours
**Dependencies**: P3.1, P3.2

**Location**:
```
New File: Packages/V7Services/Sources/V7Services/Configuration/LocalConfigurationService.swift
```

**Action**: Implement JSON file loading service

**Agent Instructions**:
```
Use backend-ios-expert agent to:

1. CREATE LocalConfigurationService.swift:
   - Implement ConfigurationProvider protocol
   - Use Bundle.module to access resources
   - JSONDecoder for parsing
   - Async/await for loading
   - Proper error handling

2. IMPLEMENT LOADING METHODS:
   public func getSkills() async throws -> SkillsConfiguration
   public func getRoles() async throws -> [JobRole]
   public func getCompanies() async throws -> [Company]
   public func getRSSFeeds() async throws -> [RSSFeed]
   public func getBenefits() async throws -> [Benefit]

3. CREATE HELPER WRAPPER TYPES:
   - RolesConfiguration: {version, roles}
   - CompaniesConfiguration: {version, companies}
   - RSSFeedsConfiguration: {version, feeds}
   - BenefitsConfiguration: {version, benefits}

4. ADD CACHING:
   - Cache loaded configurations
   - Invalidate on version change
   - Thread-safe caching
   - Memory efficient

5. ADD ERROR HANDLING:
   - File not found
   - JSON decode errors
   - Version mismatches
   - Proper logging

6. ADD UNIT TESTS:
   - Test each loading method
   - Test error cases
   - Test caching
   - Test performance
```

**Validation Commands**:
```bash
# Build service
cd Packages/V7Services && swift build

# Run tests
swift test --filter ConfigurationServiceTests

# Test loading performance
swift test --filter ConfigurationPerformanceTests
```

**Success Criteria**:
- ✅ Service implements protocol
- ✅ All JSON files load successfully
- ✅ Caching works correctly
- ✅ Error handling robust
- ✅ Tests pass
- ✅ Performance acceptable (<1s)

---

### P3.4: Update SkillsDatabase to Use Configuration
**Agent**: `backend-ios-expert`
**Priority**: P1 - HIGH
**Duration**: 4 hours
**Dependencies**: P3.3

**Location**:
```
File: Packages/V7JobParsing/Sources/V7JobParsing/Core/SkillsDatabase.swift
Lines: 7-218 (ENTIRE FILE REPLACEMENT)
```

**Action**: Replace hardcoded skills with dynamic configuration loading

**Agent Instructions**:
```
Use backend-ios-expert agent to:

1. UPDATE PACKAGE DEPENDENCIES:
   - Add V7Services dependency to V7JobParsing Package.swift
   - Import V7Services in SkillsDatabase.swift

2. REPLACE ENTIRE FILE:
   - Remove ALL hardcoded skill arrays (500+ lines)
   - Create new dynamic loading implementation
   - Use ConfigurationProvider interface
   - Maintain existing public API

3. IMPLEMENT NEW SKILLSDATABASE:
   ```swift
   public final class SkillsDatabase {
       public static let shared = SkillsDatabase()

       private var skills: Set<String> = []
       private var skillsByCategory: [String: Set<String>] = [:]
       private var skillsBySector: [String: Set<String>] = [:]
       private var configService: ConfigurationProvider

       public func loadSkills() async throws
       public func getAllSkills() -> Set<String>
       public func getSkills(in category: String) -> Set<String>
       public func getSkills(in sector: String) -> Set<String>
   }
   ```

4. ADD INITIALIZATION:
   - Load on first access
   - Cache loaded skills
   - Handle errors gracefully
   - Fallback to empty if load fails

5. UPDATE CONSUMERS:
   - Find all code using SkillsDatabase
   - Add async initialization calls
   - Update error handling
   - Test all skill extraction code

6. VERIFY NO HARDCODED SKILLS REMAIN:
   - Search entire codebase
   - Remove any remaining tech skill arrays
   - Ensure all use SkillsDatabase

7. ADD TESTS:
   - Test loading from configuration
   - Test skill lookup by category
   - Test skill lookup by sector
   - Test caching behavior
```

**Validation Commands**:
```bash
# Update Package.swift
cd Packages/V7JobParsing
# Edit Package.swift to add V7Services dependency

# Build package
swift build

# Run tests
swift test --filter SkillsDatabaseTests

# Search for hardcoded skills
grep -r "let.*Skills.*=.*\[" Packages/V7JobParsing/ | grep -v test

# Verify configuration loading
swift test --filter ConfigurationLoadingTests
```

**Success Criteria**:
- ✅ No hardcoded skills in file
- ✅ Loads from configuration
- ✅ All public API maintained
- ✅ Consumers updated
- ✅ Tests pass
- ✅ Performance maintained

---

### P3.5: Update Job Source Clients
**Agent**: `backend-ios-expert`
**Priority**: P1 - HIGH
**Duration**: 16 hours (multiple files)
**Dependencies**: P3.3

**Sub-Tasks**:

#### P3.5.1: Update GreenhouseAPIClient (4 hours)
**Location**:
```
File: Packages/V7Services/Sources/V7Services/CompanyAPIs/GreenhouseAPIClient.swift
Lines: 562, 610-620, 730-738
```

**Agent Instructions**:
```
Use backend-ios-expert agent to:

1. REPLACE HARDCODED COMPANY LIST (line 730):
   - Remove createGreenhouseCompanies() with hardcoded array
   - Add loadGreenhouseCompanies() using configService
   - Filter companies where apiType == .greenhouse
   - Cache loaded companies

2. REPLACE HARDCODED SKILLS (line 562):
   - Remove tech skills array
   - Use SkillsDatabase.shared.getAllSkills()
   - Ensure async initialization

3. REMOVE KEYWORD MAPPING (lines 610-620):
   - Delete keyword-to-company matching logic
   - Use sector-based filtering instead
   - Remove tech-specific biases

4. TEST:
   - Verify Greenhouse API still works
   - Test with healthcare companies
   - Test with finance companies
   - Ensure no tech bias
```

#### P3.5.2: Update LeverAPIClient (4 hours)
**Location**:
```
File: Packages/V7Services/Sources/V7Services/CompanyAPIs/LeverAPIClient.swift
```

**Agent Instructions**: Similar to P3.5.1

#### P3.5.3: Update JobDiscoveryCoordinator RSS (4 hours)
**Location**:
```
File: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
```

**Agent Instructions**:
```
Use backend-ios-expert agent to:

1. REPLACE RSS FEED LOADING:
   - Load RSS feeds from configService.getRSSFeeds()
   - Remove hardcoded rssFeedUrls array
   - Use all feeds from configuration

2. UPDATE RSS PARSING:
   - Remove tech skill extraction
   - Use SkillsDatabase for all sectors
   - Ensure no tech filtering

3. TEST RSS INTEGRATION:
   - Verify feeds load correctly
   - Test parsing jobs from all sectors
   - Ensure diverse job output
```

#### P3.5.4: Update Other Job Sources (4 hours)
**Agent Instructions**:
```
Update RemotiveJobSource, AngelListJobSource, and any other job sources:
- Remove hardcoded data
- Use configuration service
- Test all integrations
```

**Validation Commands**:
```bash
# Search for hardcoded companies
grep -r "airbnb\|stripe\|figma" Packages/V7Services/Sources/V7Services/CompanyAPIs/ | grep -v test

# Search for hardcoded skills
grep -r "let.*skills.*=.*\[" Packages/V7Services/ | grep -v test

# Build all services
cd Packages/V7Services && swift build

# Run integration tests
swift test --filter JobSourceIntegrationTests
```

**Success Criteria**:
- ✅ All job sources use configuration
- ✅ No hardcoded companies
- ✅ No hardcoded skills
- ✅ All sources tested
- ✅ Diverse job output verified

---

### P3.FINAL: Phase 3 Integration Testing
**Agent**: `testing-qa-strategist`
**Priority**: P1 - HIGH
**Duration**: 4 hours
**Dependencies**: P3.1-P3.5

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. CONFIGURATION VALIDATION:
   - All JSON files load successfully
   - 500+ skills loaded
   - 100+ roles loaded
   - 100+ companies loaded
   - 30+ feeds loaded

2. INTEGRATION TESTING:
   - SkillsDatabase uses configuration
   - Job sources use configuration
   - No hardcoded data remains
   - All sectors represented

3. DIVERSITY TESTING:
   - Verify healthcare data present
   - Verify finance data present
   - Verify education data present
   - Verify 20+ sectors represented

4. PERFORMANCE TESTING:
   - Configuration loads <1s
   - Memory impact <10MB
   - No performance regression
   - Caching works correctly

5. ERROR HANDLING:
   - Missing JSON files
   - Invalid JSON syntax
   - Network errors (future API)
   - Graceful degradation

6. CREATE COMPREHENSIVE REPORT:
   - All validation results
   - Data statistics
   - Performance metrics
   - Issues found
   - Sign off Phase 3
```

**Validation Commands**:
```bash
# Run full test suite
xcodebuild -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 test

# Verify configuration data
swift run --package-path Packages/V7Services ValidateConfiguration

# Test app with configuration
# Run app, check logs for:
# - "Loaded X skills"
# - "Loaded X roles"
# - "Loaded X companies"
# - No errors
```

**Success Criteria**:
- ✅ Configuration system complete
- ✅ All data externalized
- ✅ No hardcoded values
- ✅ Performance acceptable
- ✅ Tests pass
- ✅ Ready for Phase 4

---

## 🌐 PHASE 4: EXPAND JOB SOURCES (40 hours)

### P4.1: Integrate Adzuna API
**Agent**: `backend-ios-expert`
**Priority**: P2 - MEDIUM
**Duration**: 8 hours
**Dependencies**: Phase 3 complete

**Location**:
```
New File: Packages/V7Services/Sources/V7Services/JobAPIs/AdzunaAPIClient.swift
```

**Agent Instructions**:
```
Use backend-ios-expert agent to:

1. CREATE AdzunaAPIClient:
   - Implement Adzuna API integration
   - Free tier: 25 req/min, 250 req/day
   - Endpoint: https://api.adzuna.com/v1/api/jobs/us/search/1
   - Auth: app_id + app_key parameters

2. IMPLEMENT API METHODS:
   - searchJobs(query: JobSearchQuery) async throws -> [Job]
   - Handle pagination
   - Parse JSON response
   - Convert to unified Job model

3. ADD ERROR HANDLING:
   - Rate limiting (429)
   - Authentication errors
   - Network timeouts
   - Invalid responses

4. ADD CONFIGURATION:
   - Store API keys securely (Keychain)
   - Read from environment/config
   - Allow key rotation

5. IMPLEMENT RATE LIMITING:
   - Track request count
   - Respect 25 req/min limit
   - Queue requests if needed
   - Backoff on rate limit

6. TEST INTEGRATION:
   - Unit tests for API client
   - Integration tests with real API
   - Test error handling
   - Test rate limiting
```

**Validation Commands**:
```bash
# Set API keys for testing
export ADZUNA_APP_ID="your_app_id"
export ADZUNA_APP_KEY="your_app_key"

# Build client
cd Packages/V7Services && swift build

# Run tests
swift test --filter AdzunaAPIClientTests

# Test rate limiting
swift test --filter RateLimitingTests
```

**Success Criteria**:
- ✅ API client implemented
- ✅ All sectors supported
- ✅ Rate limiting works
- ✅ Error handling robust
- ✅ Tests pass

---

### P4.2: Integrate Jobicy API
**Agent**: `backend-ios-expert`
**Priority**: P2 - MEDIUM
**Duration**: 8 hours
**Dependencies**: Phase 3 complete

**Agent Instructions**: Similar structure to P4.1, but for Jobicy API

---

### P4.3: Integrate USAJobs API
**Agent**: `backend-ios-expert`
**Priority**: P2 - MEDIUM
**Duration**: 8 hours
**Dependencies**: Phase 3 complete

**Agent Instructions**: Similar structure to P4.1, but for USAJobs government API

---

### P4.4: Add Sector-Specific RSS Feeds
**Agent**: `general-purpose`
**Priority**: P2 - MEDIUM
**Duration**: 8 hours
**Dependencies**: P3.2

**Agent Instructions**:
```
Use general-purpose agent to:

1. RESEARCH RSS FEEDS:
   - Healthcare: HealtheCareers, RNJobSite, PracticeMatch
   - Finance: eFinancialCareers feeds
   - Education: HigherEdJobs RSS
   - Legal: ABA Journal Jobs
   - Others: sector-specific feeds

2. UPDATE rss_feeds.json:
   - Add 20+ new feeds
   - Cover all major sectors
   - Verify feed URLs work
   - Test feed parsing

3. TEST FEED QUALITY:
   - Fetch sample jobs
   - Verify sector diversity
   - Check data quality
   - Test parsing logic

4. UPDATE CONFIGURATION:
   - Increment version
   - Document new feeds
   - Add feed health checks
```

---

### P4.5: Implement Smart Source Rotation
**Agent**: `ml-engineering-specialist`
**Priority**: P2 - MEDIUM
**Duration**: 8 hours
**Dependencies**: P4.1-P4.4

**Location**:
```
New File: Packages/V7Services/Sources/V7Services/JobDiscovery/SmartSourceSelector.swift
```

**Agent Instructions**:
```
Use ml-engineering-specialist agent to:

1. CREATE SmartSourceSelector:
   - Track sector distribution in real-time
   - Enforce 30% max per sector
   - Prioritize under-represented sectors
   - Use Thompson-like sampling for sources

2. IMPLEMENT ALGORITHMS:
   - Calculate sector percentages
   - Identify over/under-represented sectors
   - Select next sources to query
   - Balance exploration vs diversity

3. ADD MONITORING:
   - Track source health
   - Monitor sector distribution
   - Alert on imbalance
   - Log selection decisions

4. INTEGRATE WITH JOB COORDINATOR:
   - Replace sequential source querying
   - Use smart selector for source choice
   - Maintain performance <3s total

5. TEST BALANCING:
   - Verify no sector exceeds 30%
   - Test with various scenarios
   - Validate fairness
   - Check performance
```

**Validation Commands**:
```bash
# Build selector
cd Packages/V7Services && swift build

# Run diversity tests
swift test --filter SmartSourceSelectorTests

# Test sector distribution
swift test --filter SectorBalancingTests

# Performance test
swift test --filter SourceSelectionPerformanceTests
```

**Success Criteria**:
- ✅ Smart selector implemented
- ✅ Sector balancing works
- ✅ No sector exceeds 30%
- ✅ Performance maintained
- ✅ Tests pass

---

### P4.FINAL: Phase 4 Integration Testing
**Agent**: `testing-qa-strategist`
**Priority**: P2 - MEDIUM
**Duration**: 8 hours
**Dependencies**: P4.1-P4.5

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. API INTEGRATION TESTING:
   - Test Adzuna API
   - Test Jobicy API
   - Test USAJobs API
   - Verify all return diverse jobs

2. RSS FEED TESTING:
   - Test new healthcare feeds
   - Test new finance feeds
   - Test new education feeds
   - Verify feed parsing works

3. DIVERSITY VALIDATION:
   - Collect 500 jobs
   - Analyze sector distribution
   - Verify no sector >30%
   - Confirm 15+ sectors represented

4. PERFORMANCE VALIDATION:
   - API response times <3s
   - RSS parsing efficient
   - Source selection fast
   - No memory leaks

5. ERROR HANDLING:
   - API failures
   - Rate limiting
   - Invalid feeds
   - Network errors

6. CREATE REPORT:
   - Source statistics
   - Sector distribution
   - Performance metrics
   - Sign off Phase 4
```

**Success Criteria**:
- ✅ 3 new APIs integrated
- ✅ 20+ new RSS feeds
- ✅ Smart source rotation working
- ✅ Sector diversity achieved
- ✅ Tests pass
- ✅ Ready for Phase 5

---

## 🔍 PHASE 5: BIAS DETECTION & MONITORING (24 hours)

### P5.1: Create Bias Detection Service
**Agent**: `ml-engineering-specialist`
**Priority**: P1 - HIGH
**Duration**: 8 hours
**Dependencies**: Phase 4 complete

**Location**:
```
New File: Packages/V7Performance/Sources/V7Performance/BiasDetection/BiasDetectionService.swift
```

**Agent Instructions**:
```
Use ml-engineering-specialist agent to:

1. CREATE BiasDetectionService:
   - Analyze sector distribution
   - Detect over-representation (>30%)
   - Detect under-representation (<5% for major sectors)
   - Detect scoring bias (uniform scores when no profile)

2. IMPLEMENT ALGORITHMS:
   - Statistical tests for distribution
   - Score variance analysis
   - Sector quota enforcement
   - Bias scoring (0-100 scale)

3. CREATE REPORT TYPES:
   - BiasReport: overall assessment
   - BiasViolation: specific issues
   - ViolationType: overRepresentation, underRepresentation, scoringBias
   - Severity: critical, high, medium, low

4. ADD STATISTICAL METHODS:
   - Calculate sector percentages
   - Chi-square test for distribution
   - Standard deviation for scores
   - Confidence intervals

5. IMPLEMENT SCORING:
   - Bias score 0-100 (higher = less biased)
   - Penalty system for violations
   - Critical: >40% single sector (-40 points)
   - High: >30% single sector (-20 points)

6. ADD TESTING:
   - Test with balanced jobs
   - Test with biased jobs
   - Test scoring algorithm
   - Validate statistical methods
```

**Validation Commands**:
```bash
# Build performance package
cd Packages/V7Performance && swift build

# Run bias detection tests
swift test --filter BiasDetectionTests

# Test statistical methods
swift test --filter StatisticalTests
```

**Success Criteria**:
- ✅ Service implemented
- ✅ Detects all bias types
- ✅ Scoring algorithm works
- ✅ Statistical methods correct
- ✅ Tests pass

---

### P5.2: Create Bias Monitoring Dashboard
**Agent**: `xcode-ux-designer`
**Priority**: P2 - MEDIUM
**Duration**: 8 hours
**Dependencies**: P5.1

**Location**:
```
New File: Packages/V7UI/Sources/V7UI/Analytics/BiasMonitoringView.swift
```

**Agent Instructions**:
```
Use xcode-ux-designer agent to:

1. DESIGN DASHBOARD UI:
   - Bias score display (0-100 circular gauge)
   - Sector distribution chart (bar or pie)
   - Violations list (if any)
   - Real-time updates

2. IMPLEMENT SwiftUI VIEWS:
   - BiasMonitoringView (main view)
   - BiasScoreCard (score display)
   - SectorDistributionChart (chart)
   - ViolationsList (issues list)
   - RefreshButton

3. ADD DATA BINDING:
   - Connect to BiasDetectionService
   - Async loading
   - Error handling
   - Pull-to-refresh

4. DESIGN COLOR CODING:
   - Green: Bias score >80 (good)
   - Yellow: Bias score 60-80 (fair)
   - Red: Bias score <60 (poor)

5. ADD ACCESSIBILITY:
   - VoiceOver labels
   - Dynamic Type support
   - Semantic colors
   - Screen reader optimization

6. TEST UI:
   - Test with various scores
   - Test with violations
   - Test with no data
   - Test accessibility
```

**Validation Commands**:
```bash
# Build UI package
cd Packages/V7UI && swift build

# Run UI tests
swift test --filter BiasMonitoringViewTests

# Test accessibility
swift test --filter AccessibilityTests

# Manual testing in simulator
```

**Success Criteria**:
- ✅ Dashboard implemented
- ✅ Real-time updates work
- ✅ Charts display correctly
- ✅ Accessible
- ✅ Tests pass

---

### P5.3: Implement Automated Tests
**Agent**: `testing-qa-strategist`
**Priority**: P1 - HIGH
**Duration**: 8 hours
**Dependencies**: P5.1

**Location**:
```
New File: Tests/V7PerformanceTests/BiasDetectionTests.swift
```

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. CREATE TEST SUITE:
   - BiasDetectionTests.swift
   - Test no bias with diverse jobs
   - Test detection of tech bias
   - Test detection of scoring bias
   - Test severity calculations

2. IMPLEMENT TEST CASES:
   - testNoBiasWithDiverseJobs()
   - testDetectsTechBias()
   - testDetectsScoringBias()
   - testBiasScoreCalculation()
   - testViolationSeverity()

3. CREATE MOCK DATA:
   - Diverse job sets (no bias)
   - Biased job sets (60% tech)
   - Scoring biased jobs (tech higher scores)

4. ADD EDGE CASE TESTS:
   - Empty job list
   - Single sector
   - Null profile
   - Invalid data

5. ADD PERFORMANCE TESTS:
   - Test with 1000 jobs
   - Test with 10000 jobs
   - Ensure fast analysis
   - No memory issues

6. CREATE TEST DOCUMENTATION:
   - Test plan
   - Expected results
   - Coverage report
   - CI integration
```

**Validation Commands**:
```bash
# Run bias tests
swift test --filter BiasDetectionTests

# Run all tests
swift test

# Generate coverage report
swift test --enable-code-coverage
xcrun llvm-cov report
```

**Success Criteria**:
- ✅ Comprehensive test suite
- ✅ All tests pass
- ✅ Edge cases covered
- ✅ Performance tests pass
- ✅ >80% code coverage

---

### P5.FINAL: Phase 5 Integration Testing
**Agent**: `testing-qa-strategist`
**Priority**: P1 - HIGH
**Duration**: 4 hours
**Dependencies**: P5.1-P5.3

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. END-TO-END BIAS TESTING:
   - Run app with no profile
   - Collect 100 jobs
   - Run bias analysis
   - Verify score >80

2. DASHBOARD VALIDATION:
   - Open bias monitoring view
   - Verify real-time updates
   - Check charts accuracy
   - Test all interactions

3. AUTOMATED TEST VALIDATION:
   - Run full test suite
   - Verify all pass
   - Check coverage >80%
   - Review test quality

4. PERFORMANCE VALIDATION:
   - Bias analysis <1s
   - Dashboard loads <500ms
   - No performance impact

5. CREATE PHASE 5 REPORT:
   - Bias detection working
   - Dashboard functional
   - Tests comprehensive
   - Ready for Phase 6
```

**Success Criteria**:
- ✅ Bias detection working
- ✅ Dashboard functional
- ✅ All tests pass
- ✅ Performance acceptable
- ✅ Ready for Phase 6

---

## ✅ PHASE 6: VALIDATION & TESTING (40 hours)

### P6.1: Create Integration Test Suite
**Agent**: `testing-qa-strategist`
**Priority**: P0 - CRITICAL
**Duration**: 16 hours
**Dependencies**: Phases 1-5 complete

**Location**:
```
New File: Tests/IntegrationTests/BiasEliminationIntegrationTests.swift
```

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. CREATE INTEGRATION TEST SUITE:
   - BiasEliminationIntegrationTests.swift
   - Test complete user journeys
   - Test all profile types
   - Test bias elimination

2. IMPLEMENT KEY TESTS:
   - testNewUserSeesOnboardingNotJobs()
   - testNurseProfileShowsHealthcareJobs()
   - testAccountantProfileShowsFinanceJobs()
   - testDeveloperProfileShowsTechJobs()
   - testJobDistributionWithoutProfile()
   - testMatchScoresUniformWithoutProfile()

3. CREATE TEST MATRIX:
   Profile Type | Expected Jobs | Forbidden Jobs | Score Range
   -------------|---------------|----------------|-------------
   None         | Onboarding    | Any            | N/A
   Nurse        | Healthcare    | Tech           | 60-90%
   Accountant   | Finance       | Tech           | 60-90%
   Developer    | Tech          | Healthcare     | 60-90%
   Teacher      | Education     | Tech           | 60-90%
   Sales Rep    | Sales         | Healthcare     | 60-90%

4. ADD UI AUTOMATION:
   - Use XCTest UI testing
   - Automate profile creation
   - Verify job cards shown
   - Check match percentages

5. ADD ASSERTION HELPERS:
   - jobTitlesContain()
   - verifyJobSector()
   - calculateSectorDistribution()
   - checkScoreUniformity()

6. CREATE TEST DOCUMENTATION:
   - Test plan
   - Test cases
   - Expected results
   - Failure scenarios
```

**Validation Commands**:
```bash
# Run integration tests
xcodebuild test -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test class
swift test --filter BiasEliminationIntegrationTests
```

**Success Criteria**:
- ✅ All integration tests pass
- ✅ All profile types tested
- ✅ UI automation works
- ✅ Test coverage >90%

---

### P6.2: Manual Testing Campaign
**Agent**: `testing-qa-strategist`
**Priority**: P0 - CRITICAL
**Duration**: 16 hours
**Dependencies**: P6.1

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. EXECUTE MANUAL TEST PLAN:

   TEST 1: Fresh Install
   - Delete app
   - Reinstall
   - Launch
   - Expected: Onboarding shown
   - Expected: No jobs visible

   TEST 2: Nurse Profile
   - Complete onboarding as Nurse
   - Select Patient Care, EMR skills
   - View jobs
   - Expected: Healthcare jobs only
   - Expected: Match scores 60-90%
   - Expected: No tech jobs

   TEST 3: Accountant Profile
   - Repeat with accountant
   - Expected: Finance jobs only

   TEST 4: Developer Profile
   - Repeat with developer
   - Expected: Tech jobs appropriate

   TEST 5: Teacher Profile
   - Repeat with teacher
   - Expected: Education jobs only

   TEST 6: Sales Rep Profile
   - Repeat with sales rep
   - Expected: Sales/marketing jobs

2. BIAS VERIFICATION TESTS:
   - Check bias monitoring dashboard
   - Expected: Score >90
   - Expected: No sector >30%
   - Expected: 15+ sectors represented

3. ERROR SCENARIO TESTS:
   - Network failures
   - Profile save failures
   - API timeouts
   - Configuration errors

4. PERFORMANCE TESTS:
   - Onboarding completion time
   - Job loading time
   - Thompson Sampling time
   - Memory usage

5. ACCESSIBILITY TESTS:
   - VoiceOver navigation
   - Dynamic Type
   - High Contrast
   - Reduce Motion

6. CREATE TEST REPORT:
   - Test execution log
   - Screenshots
   - Issues found
   - Pass/fail summary
   - Recommendations
```

**Manual Test Checklist**:
```
□ Fresh install → onboarding
□ Nurse profile → healthcare jobs
□ Accountant profile → finance jobs
□ Developer profile → tech jobs
□ Teacher profile → education jobs
□ Sales rep profile → sales jobs
□ Bias score >90
□ No sector >30%
□ 15+ sectors represented
□ All error scenarios handled
□ Performance acceptable
□ Accessibility compliant
```

**Success Criteria**:
- ✅ All manual tests pass
- ✅ No critical issues found
- ✅ All profiles validated
- ✅ Bias verified eliminated

---

### P6.3: Performance Validation
**Agent**: `performance-engineer`
**Priority**: P1 - HIGH
**Duration**: 8 hours
**Dependencies**: P6.1, P6.2

**Agent Instructions**:
```
Use performance-engineer agent to:

1. THOMPSON SAMPLING VALIDATION:
   - Measure scoring time
   - Target: <10ms per job
   - Test with 100 jobs
   - Verify 357x advantage claim

2. MEMORY VALIDATION:
   - Monitor memory usage
   - Baseline: <200MB
   - Peak: <300MB
   - No memory leaks

3. API RESPONSE VALIDATION:
   - Company APIs: <3s
   - RSS feeds: <2s
   - Configuration loading: <1s

4. UI RESPONSIVENESS:
   - 60fps maintained
   - Tab switching <16ms
   - Scroll performance
   - Animation smoothness

5. CONFIGURATION IMPACT:
   - Loading time
   - Memory footprint
   - Startup impact
   - Caching effectiveness

6. CREATE PERFORMANCE REPORT:
   - All metrics
   - Before/after comparison
   - Regression analysis
   - Optimization recommendations
```

**Validation Commands**:
```bash
# Run performance tests
swift test --filter PerformanceTests

# Profile in Instruments
xcodebuild -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 -destination 'platform=iOS Simulator,name=iPhone 16' -enableCodeCoverage YES

# Check for memory leaks
swift test --sanitize=address
```

**Success Criteria**:
- ✅ Thompson <10ms maintained
- ✅ Memory <200MB baseline
- ✅ APIs <3s response
- ✅ UI 60fps maintained
- ✅ No performance regressions

---

### P6.FINAL: Project Sign-Off
**Agent**: `testing-qa-strategist`
**Priority**: P0 - CRITICAL
**Duration**: 4 hours
**Dependencies**: P6.1, P6.2, P6.3

**Agent Instructions**:
```
Use testing-qa-strategist agent to:

1. VERIFY ALL OBJECTIVES MET:
   - Zero hardcoded job preferences ✓
   - Sector diversity 20+ sectors ✓
   - No sector >30% ✓
   - Bias score >90 ✓
   - All tests passing ✓

2. VALIDATE ALL PHASES:
   - Phase 1: Critical fixes complete
   - Phase 2: Profile gate working
   - Phase 3: Configuration externalized
   - Phase 4: Job sources expanded
   - Phase 5: Bias detection working
   - Phase 6: All tests passing

3. FINAL CHECKLIST:
   □ No hardcoded keywords
   □ No tech bias in algorithms
   □ Configuration service working
   □ 500+ skills loaded
   □ 100+ roles loaded
   □ 100+ companies loaded
   □ 30+ RSS feeds loaded
   □ 3 APIs integrated
   □ Bias detection functional
   □ Dashboard working
   □ All tests passing
   □ Performance maintained
   □ Accessibility compliant

4. CREATE FINAL DELIVERABLES:
   - Complete test report
   - Performance benchmarks
   - Bias analysis report
   - User acceptance criteria
   - Deployment checklist
   - Post-launch monitoring plan

5. SIGN-OFF DOCUMENTATION:
   - Project completion certificate
   - All acceptance criteria met
   - Ready for production deployment
   - Monitoring plan in place
```

**Final Validation**:
```bash
# Run complete test suite
xcodebuild test -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7

# Generate final reports
swift test --enable-code-coverage
xcrun llvm-cov export -format=lcov > coverage.lcov

# Final bias analysis
swift run BiasAnalysisTool --generate-report

# Performance benchmarks
swift test --filter PerformanceTests > performance_report.txt
```

**Success Criteria**:
- ✅ All objectives achieved
- ✅ All tests passing
- ✅ No critical issues
- ✅ Performance maintained
- ✅ Ready for deployment
- ✅ **PROJECT COMPLETE**

---

## 📊 PROGRESS TRACKING

### Overall Progress
```
Phase 1 (8h):   □□□□□□ 0/6 tasks complete
Phase 2 (6h):   □□ 0/2 tasks complete
Phase 3 (40h):  □□□□□ 0/5 tasks complete
Phase 4 (40h):  □□□□□ 0/5 tasks complete
Phase 5 (24h):  □□□ 0/3 tasks complete
Phase 6 (40h):  □□□ 0/3 tasks complete

Total: 0/24 major tasks (0%)
Total: 0/89 sub-tasks (0%)
```

### Agent Utilization Summary
```
backend-ios-expert:        15 tasks (62.5% of work)
testing-qa-strategist:     4 tasks  (16.7% of work)
ml-engineering-specialist: 3 tasks  (12.5% of work)
algorithm-math-expert:     1 task   (4.2% of work)
ios-app-architect:         3 tasks  (12.5% of work)
xcode-ux-designer:         1 task   (4.2% of work)
general-purpose:           2 tasks  (8.3% of work)
performance-engineer:      1 task   (4.2% of work)
```

### Success Metrics Tracker
```
Current State:
- Bias Score: 20/100 (severe bias)
- Tech Job %: 80% (all users)
- Sector Diversity: 2 sectors
- Hardcoded Items: 73
- Job Sources: 3 (all tech)

Target State:
- Bias Score: >90/100 ✓
- Tech Job %: ≤30% ✓
- Sector Diversity: 20+ sectors ✓
- Hardcoded Items: 0 ✓
- Job Sources: 30+ (all sectors) ✓
```

---

## 🎯 EXECUTION GUIDELINES

### For Each Task:
1. **Read** strategic plan and implementation checklist
2. **Assign** to appropriate specialized agent
3. **Execute** using agent with clear instructions
4. **Validate** using provided commands
5. **Test** thoroughly before moving to next task
6. **Document** completion and any issues
7. **Update** progress tracker

### Agent Selection Criteria:
- **backend-ios-expert**: APIs, services, networking, data flow
- **testing-qa-strategist**: Test design, QA, validation
- **ml-engineering-specialist**: Thompson Sampling, bias detection, algorithms
- **algorithm-math-expert**: Mathematical correctness, statistical methods
- **ios-app-architect**: App structure, architecture, Core Data
- **xcode-ux-designer**: UI/UX, SwiftUI views, accessibility
- **general-purpose**: File operations, data entry, configuration
- **performance-engineer**: Performance analysis, optimization

### Quality Gates:
- ✅ All code builds without errors
- ✅ All tests pass
- ✅ Performance budgets maintained
- ✅ No new warnings introduced
- ✅ Documentation updated
- ✅ Peer review completed

---

**READY FOR EXECUTION**

This TODO list provides complete agent assignments and execution instructions for all 89 tasks across 6 phases of the bias elimination project.