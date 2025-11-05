# Bias Elimination Implementation Checklist
*Step-by-Step Execution Guide for Job Discovery Bias Remediation*

**Project**: ManifestAndMatchV7 - Job Discovery Bias Elimination
**Reference**: `JOB_DISCOVERY_BIAS_ELIMINATION_STRATEGIC_PLAN.md`
**Created**: October 14, 2025
**Status**: Ready for Execution

---

## 📋 OVERVIEW

This checklist provides step-by-step execution for the 6-phase bias elimination plan. Each task includes:
- ✅ Clear completion criteria
- 📁 Exact file locations
- ⏱️ Time estimates
- 🧪 Validation steps

**Total Duration**: 21 days (168 hours)
**Total Phases**: 6
**Total Tasks**: 89

---

## 🚀 PHASE 1: IMMEDIATE CRITICAL FIXES
**Duration**: Day 1-2 (8 hours)
**Goal**: Stop showing tech jobs to all users immediately

### Pre-Phase Checklist
- [ ] Backup current codebase
- [ ] Create feature branch: `feature/bias-elimination-phase1`
- [ ] Verify build succeeds before changes
- [ ] Document current behavior (screenshots)

### Task 1.1: Remove "Software Engineer" Default Query (30 min)

#### Implementation Steps
- [ ] **Step 1**: Open file
  ```
  File: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  Line: 769
  ```

- [ ] **Step 2**: Locate `buildSearchQuery()` function
  ```swift
  // Find this code:
  private func buildSearchQuery() -> JobSearchQuery {
      let keywords = userProfile.professionalProfile.skills.joined(separator: " OR ")
      let location = userProfile.preferences.preferredLocations.first

      return JobSearchQuery(
          keywords: keywords.isEmpty ? "Software Engineer" : keywords,  // ← THIS LINE
  ```

- [ ] **Step 3**: Remove the fallback
  ```swift
  // Change to:
  return JobSearchQuery(
      keywords: keywords,  // No fallback - empty string when no skills
  ```

- [ ] **Step 4**: Save file

#### Validation Steps
- [ ] **Validate 1**: Search for remaining references
  ```bash
  grep -r "Software Engineer" Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  ```
  Expected: No matches in keyword fallback

- [ ] **Validate 2**: Build project
  ```bash
  cd Packages/V7Services && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 3**: Check API calls in logs
  - Run app in simulator
  - Check console for job API requests
  - Verify keyword parameter is empty or user-provided (not "Software Engineer")

- [ ] **Validate 4**: Commit changes
  ```bash
  git add Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  git commit -m "fix: remove 'Software Engineer' default query fallback"
  ```

**Completion Criteria**: ✅ No "Software Engineer" sent to APIs when user has no skills

---

### Task 1.2: Remove Thompson Sampling Tech Bias (1 hour)

#### Implementation Steps
- [ ] **Step 1**: Open Thompson file
  ```
  File: Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
  Lines: 391-401
  ```

- [ ] **Step 2**: Locate `calculateBasicProfessionalScore()` function
  ```swift
  // Find this entire function:
  private func calculateBasicProfessionalScore(job: Job, baseScore: Double) -> Double {
      var score = baseScore

      // Simple skill matching heuristic
      let commonSkills = ["swift", "ios", "mobile", "app", "development"]
      let jobText = "\(job.title) \(job.description)".lowercased()

      let skillMatches = commonSkills.filter { skill in
          jobText.contains(skill)
      }.count

      // Add skill bonus (up to 0.1)
      let skillBonus = min(0.1, Double(skillMatches) * 0.02)
      score += skillBonus

      return min(1.0, score)
  }
  ```

- [ ] **Step 3**: Replace with unbiased version
  ```swift
  // Replace entire function with:
  private func calculateBasicProfessionalScore(job: Job, baseScore: Double) -> Double {
      // With no user profile, return base score without any bias
      // Professional scoring should only apply when we have actual user skills
      return min(1.0, baseScore)
  }
  ```

- [ ] **Step 4**: Save file

#### Validation Steps
- [ ] **Validate 1**: Search for tech skill arrays
  ```bash
  grep -r "swift.*ios.*mobile" Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
  ```
  Expected: No matches

- [ ] **Validate 2**: Build Thompson package
  ```bash
  cd Packages/V7Thompson && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 3**: Run Thompson tests
  ```bash
  cd Packages/V7Thompson && swift test
  ```
  Expected: All tests pass

- [ ] **Validate 4**: Test scoring
  - Run app with no profile
  - Check match scores for tech jobs
  - Expected: Tech jobs score 45-55% (not 65-75%)

- [ ] **Validate 5**: Commit changes
  ```bash
  git add Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
  git commit -m "fix: remove +10% tech keyword bonus from Thompson Sampling"
  ```

**Completion Criteria**: ✅ Tech jobs receive no automatic scoring bonus

---

### Task 1.3: Use Neutral Thompson Sampling Priors (30 min)

#### Implementation Steps
- [ ] **Step 1**: Same file as Task 1.2
  ```
  File: Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
  Lines: 342-349
  ```

- [ ] **Step 2**: Locate Beta parameter initialization
  ```swift
  // Find this code in scoreJob():
  let amberAlpha = 1.5
  let amberBeta = 1.5
  let tealAlpha = 2.0
  let tealBeta = 2.0
  ```

- [ ] **Step 3**: Change to neutral priors
  ```swift
  // Change to:
  let amberAlpha = 1.0  // Beta(1,1) = uniform distribution
  let amberBeta = 1.0
  let tealAlpha = 1.0
  let tealBeta = 1.0
  ```

- [ ] **Step 4**: Add comment explaining change
  ```swift
  // Use Beta(1,1) for completely neutral prior when no user data exists
  // This creates a uniform distribution over [0,1] with no bias
  let amberAlpha = 1.0
  let amberBeta = 1.0
  let tealAlpha = 1.0
  let tealBeta = 1.0
  ```

- [ ] **Step 5**: Save file

#### Validation Steps
- [ ] **Validate 1**: Build Thompson package
  ```bash
  cd Packages/V7Thompson && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 2**: Run Thompson tests
  ```bash
  cd Packages/V7Thompson && swift test
  ```
  Expected: All tests pass

- [ ] **Validate 3**: Check score distribution
  - Run app with no profile
  - Collect 20+ job scores
  - Verify distribution is uniform (45-55% range)
  - Standard deviation should be low (<0.10)

- [ ] **Validate 4**: Commit changes
  ```bash
  git add Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift
  git commit -m "fix: use Beta(1,1) neutral priors for Thompson Sampling"
  ```

**Completion Criteria**: ✅ Thompson Sampling uses uniform prior distribution

---

### Task 1.4: Replace iOS-Specific RSS Feeds (1 hour)

#### Implementation Steps
- [ ] **Step 1**: Open JobDiscoveryCoordinator
  ```
  File: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  Lines: 1948-1952
  ```

- [ ] **Step 2**: Locate RSS feed URLs
  ```swift
  // Find this code:
  private let rssFeedUrls = [
      "https://remoteok.io/remote-ios-jobs.rss",        // iOS ONLY
      "https://remoteok.io/remote-swift-jobs.rss",      // Swift ONLY
      "https://himalayas.app/jobs/rss"
  ]
  ```

- [ ] **Step 3**: Replace with diverse feeds
  ```swift
  // Replace with:
  private let rssFeedUrls = [
      "https://remoteok.io/remote-jobs.rss",            // All jobs
      "https://weworkremotely.com/remote-jobs.rss",     // All categories
      "https://himalayas.app/jobs/rss",                 // All jobs
      "https://jobicy.com/api/v2/remote-jobs.rss"       // All categories
  ]
  ```

- [ ] **Step 4**: Update function that uses feeds
  - Find where `rssFeedUrls` is used
  - Verify no iOS-specific filtering happens
  - Remove any iOS keyword filters

- [ ] **Step 5**: Save file

#### Validation Steps
- [ ] **Validate 1**: Search for iOS-specific feeds
  ```bash
  grep -r "remote-ios-jobs\|remote-swift-jobs" Packages/V7Services/
  ```
  Expected: No matches

- [ ] **Validate 2**: Build Services package
  ```bash
  cd Packages/V7Services && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 3**: Test RSS parsing
  - Run app
  - Monitor network requests
  - Verify new RSS URLs are being fetched
  - Check job titles span multiple industries

- [ ] **Validate 4**: Check job diversity
  - Collect 50 jobs from RSS feeds
  - Categorize by sector
  - Verify at least 3-4 different sectors represented

- [ ] **Validate 5**: Commit changes
  ```bash
  git add Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  git commit -m "fix: replace iOS-specific RSS feeds with diverse job sources"
  ```

**Completion Criteria**: ✅ RSS feeds fetch jobs from all sectors, not just iOS/Swift

---

### Task 1.5: Remove Default Tech Industries (30 min)

#### Implementation Steps
- [ ] **Step 1**: Open JobDiscoveryCoordinator
  ```
  File: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  Lines: 94-106
  ```

- [ ] **Step 2**: Locate `createDefaultUserProfile()` function
  ```swift
  // Find this function:
  private static func createDefaultUserProfile() -> V7Thompson.UserProfile {
      return V7Thompson.UserProfile(
          id: UUID(),
          preferences: UserPreferences(
              preferredLocations: ["Remote", "San Francisco, CA", "New York, NY"],
              industries: ["Technology", "Software"]  // ← REMOVE THIS
          ),
          professionalProfile: ProfessionalProfile(
              skills: []
          )
      )
  }
  ```

- [ ] **Step 3**: Remove default industries and locations
  ```swift
  // Change to:
  private static func createDefaultUserProfile() -> V7Thompson.UserProfile {
      return V7Thompson.UserProfile(
          id: UUID(),
          preferences: UserPreferences(
              preferredLocations: [],  // Empty - no defaults
              industries: []           // Empty - no defaults
          ),
          professionalProfile: ProfessionalProfile(
              skills: []
          )
      )
  }
  ```

- [ ] **Step 4**: Save file

#### Validation Steps
- [ ] **Validate 1**: Build Services package
  ```bash
  cd Packages/V7Services && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 2**: Test profile creation
  - Run app (fresh install simulation)
  - Check default profile in debugger
  - Verify industries array is empty
  - Verify locations array is empty

- [ ] **Validate 3**: Check for other default industries
  ```bash
  grep -r '"Technology"\|"Software"' Packages/V7Services/ | grep -v "test\|Test"
  ```
  Expected: No other hardcoded industry defaults

- [ ] **Validate 4**: Commit changes
  ```bash
  git add Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  git commit -m "fix: remove default tech industries from user profile"
  ```

**Completion Criteria**: ✅ Default user profile has no industry preferences

---

### Task 1.6: Remove Core Data Tech Default (45 min)

#### Implementation Steps
- [ ] **Step 1**: Open UserProfile Core Data file
  ```
  File: Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift
  Lines: 97-106
  ```

- [ ] **Step 2**: Locate `awakeFromInsert()` function
  ```swift
  // Find this function:
  public override func awakeFromInsert() {
      super.awakeFromInsert()
      id = UUID()
      createdDate = Date()
      lastModified = Date()
      currentDomain = "technology"  // ← REMOVE THIS
      experienceLevel = "mid"       // ← REMOVE THIS
      amberTealPosition = 0.5
      remotePreference = "hybrid"   // ← REMOVE THIS
  }
  ```

- [ ] **Step 3**: Remove all default values
  ```swift
  // Change to:
  public override func awakeFromInsert() {
      super.awakeFromInsert()
      id = UUID()
      createdDate = Date()
      lastModified = Date()
      currentDomain = nil          // No default domain
      experienceLevel = nil        // No default level
      amberTealPosition = 0.5      // Keep neutral position
      remotePreference = nil       // No default preference
  }
  ```

- [ ] **Step 4**: Update property definitions if needed
  - Check if properties need to be optional
  - Update type declarations: `String?` instead of `String`

- [ ] **Step 5**: Save file

#### Validation Steps
- [ ] **Validate 1**: Build V7Data package
  ```bash
  cd Packages/V7Data && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 2**: Run migration tests
  ```bash
  cd Packages/V7Data && swift test
  ```
  Expected: All tests pass

- [ ] **Validate 3**: Test profile creation
  - Run app
  - Create new profile
  - Check Core Data in debugger
  - Verify currentDomain is nil
  - Verify experienceLevel is nil

- [ ] **Validate 4**: Test app behavior with nil values
  - Ensure app doesn't crash with nil defaults
  - Verify onboarding forces user to select values

- [ ] **Validate 5**: Commit changes
  ```bash
  git add Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift
  git commit -m "fix: remove 'technology' default domain from Core Data"
  ```

**Completion Criteria**: ✅ Core Data entities have no default sector/industry values

---

### Phase 1 Final Validation

- [ ] **Final Build Test**: Build entire workspace
  ```bash
  xcodebuild -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 build
  ```
  Expected: Build succeeds

- [ ] **Final Test Suite**: Run all tests
  ```bash
  xcodebuild -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 test
  ```
  Expected: All tests pass

- [ ] **Manual Testing Checklist**:
  - [ ] Delete app from simulator
  - [ ] Rebuild and install
  - [ ] Launch app
  - [ ] Expected: See onboarding (not jobs)
  - [ ] Complete onboarding as "Nurse"
  - [ ] Expected: See healthcare jobs (not tech)
  - [ ] Check match scores
  - [ ] Expected: Scores reflect profile (not biased to tech)

- [ ] **Check for Remaining Tech Bias**:
  ```bash
  # Search for tech-specific keywords
  grep -r "software engineer\|ios developer\|swift" --include="*.swift" Packages/ | grep -v "test\|Test\|comment"

  # Search for hardcoded tech skills
  grep -r "swift.*ios.*mobile" --include="*.swift" Packages/

  # Search for tech industry defaults
  grep -r '"Technology"\|"Software"' --include="*.swift" Packages/ | grep -v "test"
  ```
  Expected: No hardcoded defaults remaining

- [ ] **Performance Validation**:
  - [ ] Thompson Sampling still <10ms
  - [ ] Memory usage still <200MB
  - [ ] UI still 60fps

- [ ] **Create Pull Request**:
  ```bash
  git push origin feature/bias-elimination-phase1
  # Create PR for review
  ```

- [ ] **Phase 1 Sign-Off**: All tasks completed and validated

**Phase 1 Success Criteria**:
✅ No "Software Engineer" default query
✅ No +10% tech keyword bonus
✅ Diverse RSS feeds (not iOS-specific)
✅ No default industries or domains
✅ Jobs display across multiple sectors
✅ Match scores 45-55% without profile

---

## 🚪 PHASE 2: PROFILE COMPLETION GATE
**Duration**: Day 3 (6 hours)
**Goal**: Block job loading until user completes onboarding

### Pre-Phase Checklist
- [ ] Phase 1 merged to main
- [ ] Create feature branch: `feature/bias-elimination-phase2`
- [ ] Verify Phase 1 changes working in production

### Task 2.1: Add Profile Completion Check (2 hours)

#### Implementation Steps
- [ ] **Step 1**: Open ContentView
  ```
  File: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/ContentView.swift
  Lines: 887-949
  ```

- [ ] **Step 2**: Locate `loadInitialJobs()` function
  ```swift
  // Find this function:
  private func loadInitialJobs() async {
      viewState = .loading
      logger.info("Loading initial jobs")
      // ... rest of function
  }
  ```

- [ ] **Step 3**: Add profile completion check at start
  ```swift
  private func loadInitialJobs() async {
      // Check if user has completed profile setup
      guard UserDefaults.standard.bool(forKey: "v7_has_onboarded"),
            appState.userProfile != nil else {
          viewState = .onboarding
          logger.info("Profile incomplete - showing onboarding")
          return
      }

      viewState = .loading
      logger.info("Loading initial jobs with user profile")
      // ... rest of function
  }
  ```

- [ ] **Step 4**: Update onboarding state handling
  - Find where `viewState` is set
  - Ensure `.onboarding` case exists in enum
  - Add UI for onboarding state if missing

- [ ] **Step 5**: Save file

#### Validation Steps
- [ ] **Validate 1**: Build feature package
  ```bash
  cd ManifestAndMatchV7Package && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 2**: Test fresh install flow
  - Delete app
  - Reinstall
  - Launch
  - Expected: Onboarding screen shown immediately
  - Expected: No jobs visible

- [ ] **Validate 3**: Test profile check logic
  - Set breakpoint at guard statement
  - Verify UserDefaults check
  - Verify appState.userProfile check
  - Confirm onboarding shown when either fails

- [ ] **Validate 4**: Test with incomplete profile
  - Set `v7_has_onboarded = true` but no profile
  - Launch app
  - Expected: Still shows onboarding

- [ ] **Validate 5**: Commit changes
  ```bash
  git add ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/ContentView.swift
  git commit -m "feat: add profile completion gate before job loading"
  ```

**Completion Criteria**: ✅ Jobs not shown until profile complete

---

### Task 2.2: Wire Onboarding Completion to Job Coordinator (4 hours)

#### Implementation Steps
- [ ] **Step 1**: Open OnboardingFlow
  ```
  File: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/OnboardingFlow.swift
  Lines: 816-875
  ```

- [ ] **Step 2**: Locate onboarding completion handler
  ```swift
  // Find where onboarding completes:
  private func handleOnboardingComplete() {
      // Save onboarding analytics
      recordOnboardingCompletion()

      // Mark as complete
      UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

      // Call completion
      onComplete()
  }
  ```

- [ ] **Step 3**: Add job coordinator update
  ```swift
  private func handleOnboardingComplete() async {
      // Save onboarding analytics
      await recordOnboardingCompletion()

      // Mark onboarding as complete
      UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
      UserDefaults.standard.set(true, forKey: "v7_has_onboarded")

      // ⭐ UPDATE JOB COORDINATOR WITH USER PROFILE
      if let profile = appState.userProfile {
          await jobCoordinator.updateFromCoreProfile(profile)
          logger.info("Job coordinator updated with user profile: \(profile.id)")
      } else {
          logger.error("Profile missing after onboarding completion!")
      }

      // Call completion handler
      onComplete()
  }
  ```

- [ ] **Step 4**: Verify `updateFromCoreProfile()` exists
  - Open `JobDiscoveryCoordinator.swift`
  - Find `updateFromCoreProfile()` method
  - Verify it updates internal profile state
  - Verify it calls `loadInitialJobs()` or similar

- [ ] **Step 5**: If method doesn't exist, create it
  ```swift
  // In JobDiscoveryCoordinator.swift:
  public func updateFromCoreProfile(_ coreProfile: V7Core.UserProfile) async {
      // Convert Core Data profile to Thompson profile
      let thompsonProfile = ProfileConverter.toThompsonProfile(coreProfile)
      self.userProfile = thompsonProfile

      logger.info("Profile updated from Core: \(thompsonProfile.id)")

      // Clear existing jobs to force refresh with new profile
      await clearJobs()

      // Load jobs with new profile
      await loadInitialJobs()
  }
  ```

- [ ] **Step 6**: Add logging throughout
  - Log when onboarding starts
  - Log when profile is created
  - Log when coordinator is updated
  - Log when jobs start loading

- [ ] **Step 7**: Save all files

#### Validation Steps
- [ ] **Validate 1**: Build packages
  ```bash
  cd ManifestAndMatchV7Package && swift build
  cd Packages/V7Services && swift build
  ```
  Expected: Both build successfully

- [ ] **Validate 2**: Test complete onboarding flow
  - Delete app
  - Reinstall
  - Launch app
  - Complete onboarding as "Nurse"
  - Check logs for "Job coordinator updated with user profile"
  - Verify jobs load after completion

- [ ] **Validate 3**: Verify profile is used
  - Complete onboarding with specific skills
  - Check job titles after completion
  - Verify jobs match selected profile
  - Example: "Patient Care" skill → healthcare jobs shown

- [ ] **Validate 4**: Test different profiles
  - [ ] Nurse profile → Healthcare jobs
  - [ ] Accountant profile → Finance jobs
  - [ ] Developer profile → Tech jobs
  - [ ] Teacher profile → Education jobs

- [ ] **Validate 5**: Check for profile update errors
  - Monitor logs for errors
  - Verify no crashes during profile update
  - Check that jobs load successfully

- [ ] **Validate 6**: Commit changes
  ```bash
  git add ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/OnboardingFlow.swift
  git add Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  git commit -m "feat: wire onboarding completion to update job coordinator"
  ```

**Completion Criteria**: ✅ Job coordinator uses actual user profile after onboarding

---

### Phase 2 Final Validation

- [ ] **Integration Test**: Complete end-to-end flow
  1. [ ] Fresh install
  2. [ ] Launch → Onboarding shown
  3. [ ] Complete as Nurse
  4. [ ] Jobs load → Healthcare jobs shown
  5. [ ] No tech jobs visible
  6. [ ] Match scores reflect nursing profile

- [ ] **Profile Types Test**:
  ```
  Test Matrix:
  - [ ] Nurse → Healthcare jobs
  - [ ] Accountant → Finance jobs
  - [ ] Developer → Tech jobs
  - [ ] Teacher → Education jobs
  - [ ] Sales Rep → Sales/Marketing jobs
  ```

- [ ] **Error Handling Test**:
  - [ ] Incomplete onboarding → Jobs not loaded
  - [ ] Profile save fails → Error shown, onboarding retried
  - [ ] Coordinator update fails → Error shown, retry available

- [ ] **Performance Test**:
  - [ ] Onboarding completes in <2s
  - [ ] Profile update takes <500ms
  - [ ] Jobs load in <3s after onboarding

- [ ] **Create Pull Request**:
  ```bash
  git push origin feature/bias-elimination-phase2
  # Create PR for review
  ```

- [ ] **Phase 2 Sign-Off**: All tasks completed and validated

**Phase 2 Success Criteria**:
✅ New users see onboarding, not jobs
✅ Job coordinator updated after onboarding
✅ Jobs match user skills after completion
✅ No tech job bias for non-tech profiles

---

## 📦 PHASE 3: EXTERNALIZE CONFIGURATION DATA
**Duration**: Day 4-8 (5 days, 40 hours)
**Goal**: Move all hardcoded data to external configuration files

### Pre-Phase Checklist
- [ ] Phase 2 merged to main
- [ ] Create feature branch: `feature/bias-elimination-phase3`
- [ ] Review JSON schema specifications

### Task 3.1: Create Configuration Service Architecture (4 hours)

#### Implementation Steps
- [ ] **Step 1**: Create new directory
  ```bash
  mkdir -p Packages/V7Services/Sources/V7Services/Configuration
  ```

- [ ] **Step 2**: Create ConfigurationProvider.swift
  ```
  File: Packages/V7Services/Sources/V7Services/Configuration/ConfigurationProvider.swift
  ```

- [ ] **Step 3**: Implement protocol and types
  ```swift
  import Foundation

  public protocol ConfigurationProvider: Sendable {
      func getSkills() async throws -> SkillsConfiguration
      func getRoles() async throws -> [JobRole]
      func getCompanies() async throws -> [Company]
      func getRSSFeeds() async throws -> [RSSFeed]
      func getBenefits() async throws -> [Benefit]
  }

  public struct SkillsConfiguration: Codable, Sendable {
      public let version: String
      public let skills: [Skill]
      public let categories: [SkillCategory]

      public init(version: String, skills: [Skill], categories: [SkillCategory]) {
          self.version = version
          self.skills = skills
          self.categories = categories
      }
  }

  public struct Skill: Codable, Sendable, Hashable, Identifiable {
      public let id: UUID
      public let name: String
      public let category: String
      public let sector: String

      public init(id: UUID, name: String, category: String, sector: String) {
          self.id = id
          self.name = name
          self.category = category
          self.sector = sector
      }
  }

  // Add remaining types: SkillCategory, JobRole, Company, RSSFeed, Benefit
  ```

- [ ] **Step 4**: Add remaining type definitions
  - [ ] SkillCategory struct
  - [ ] JobRole struct
  - [ ] Company struct with APIType enum
  - [ ] RSSFeed struct
  - [ ] Benefit struct
  - [ ] ConfigurationError enum

- [ ] **Step 5**: Save file

#### Validation Steps
- [ ] **Validate 1**: Build protocol file
  ```bash
  cd Packages/V7Services && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 2**: Verify Sendable conformance
  - Check all types are Sendable
  - Verify async methods compile
  - No concurrency warnings

- [ ] **Validate 3**: Commit changes
  ```bash
  git add Packages/V7Services/Sources/V7Services/Configuration/ConfigurationProvider.swift
  git commit -m "feat: add ConfigurationProvider protocol and types"
  ```

**Completion Criteria**: ✅ Configuration architecture defined

---

### Task 3.2: Create JSON Configuration Files (8 hours)

This is the most time-consuming task - creating comprehensive data across all sectors.

#### Implementation Steps - Skills Database

- [ ] **Step 1**: Create Resources directory
  ```bash
  mkdir -p Packages/V7Services/Resources
  ```

- [ ] **Step 2**: Create skills.json template
  ```
  File: Packages/V7Services/Resources/skills.json
  ```

- [ ] **Step 3**: Add healthcare skills (100+ skills)
  ```json
  {
    "version": "1.0.0",
    "skills": [
      {
        "id": "uuid-1",
        "name": "Patient Care",
        "category": "Clinical",
        "sector": "Healthcare"
      },
      {
        "id": "uuid-2",
        "name": "EMR Systems",
        "category": "Technology",
        "sector": "Healthcare"
      }
      // Add 100+ healthcare skills
    ]
  }
  ```

- [ ] **Step 4**: Add finance skills (80+ skills)
  ```json
  {
    "id": "uuid-finance-1",
    "name": "Financial Analysis",
    "category": "Analysis",
    "sector": "Finance"
  }
  // Add 80+ finance skills
  ```

- [ ] **Step 5**: Add technology skills (existing 100+ skills)
  - Port from SkillsDatabase.swift
  - Keep Swift, iOS, etc.
  - Properly categorize

- [ ] **Step 6**: Add remaining sectors (300+ skills total)
  - [ ] Education (50 skills)
  - [ ] Retail (40 skills)
  - [ ] Hospitality (40 skills)
  - [ ] Legal (30 skills)
  - [ ] Marketing (50 skills)
  - [ ] Sales (40 skills)
  - [ ] Manufacturing (40 skills)
  - [ ] Construction (30 skills)
  - [ ] Transportation (30 skills)

- [ ] **Step 7**: Add skill categories
  ```json
  "categories": [
    {
      "id": "uuid-cat-1",
      "name": "Clinical",
      "sector": "Healthcare"
    }
  ]
  ```

- [ ] **Step 8**: Validate JSON structure
  ```bash
  # Check JSON syntax
  python3 -m json.tool Packages/V7Services/Resources/skills.json > /dev/null
  ```
  Expected: No errors

#### Implementation Steps - Job Roles

- [ ] **Step 9**: Create roles.json
  ```
  File: Packages/V7Services/Resources/roles.json
  ```

- [ ] **Step 10**: Add healthcare roles (20 roles)
  ```json
  {
    "version": "1.0.0",
    "roles": [
      {
        "id": "uuid-role-1",
        "title": "Registered Nurse",
        "category": "Healthcare",
        "sector": "Healthcare",
        "skills": ["Patient Care", "EMR Systems", "Medication Administration"]
      }
    ]
  }
  ```

- [ ] **Step 11**: Add finance roles (15 roles)
- [ ] **Step 12**: Add technology roles (20 roles)
- [ ] **Step 13**: Add education roles (15 roles)
- [ ] **Step 14**: Add retail roles (10 roles)
- [ ] **Step 15**: Add other sectors (20 roles)

- [ ] **Step 16**: Validate roles.json
  ```bash
  python3 -m json.tool Packages/V7Services/Resources/roles.json > /dev/null
  ```

#### Implementation Steps - Companies

- [ ] **Step 17**: Create companies.json
  ```
  File: Packages/V7Services/Resources/companies.json
  ```

- [ ] **Step 18**: Add healthcare companies (25 companies)
  ```json
  {
    "version": "1.0.0",
    "companies": [
      {
        "id": "uuid-comp-1",
        "name": "Kaiser Permanente",
        "sector": "Healthcare",
        "apiType": "greenhouse",
        "identifier": "kaiser"
      }
    ]
  }
  ```

- [ ] **Step 19**: Add finance companies (25 companies)
- [ ] **Step 20**: Add technology companies (25 companies - existing)
- [ ] **Step 21**: Add retail companies (15 companies)
- [ ] **Step 22**: Add other sectors (10 companies)

- [ ] **Step 23**: Validate companies.json

#### Implementation Steps - RSS Feeds

- [ ] **Step 24**: Create rss_feeds.json
  ```
  File: Packages/V7Services/Resources/rss_feeds.json
  ```

- [ ] **Step 25**: Add healthcare feeds (5 feeds)
  ```json
  {
    "version": "1.0.0",
    "feeds": [
      {
        "id": "uuid-feed-1",
        "url": "https://www.healthecareers.com/jobs/rss",
        "sector": "Healthcare",
        "description": "HealtheCareers - All healthcare positions"
      }
    ]
  }
  ```

- [ ] **Step 26**: Add finance feeds (3 feeds)
- [ ] **Step 27**: Add technology feeds (5 feeds)
- [ ] **Step 28**: Add education feeds (3 feeds)
- [ ] **Step 29**: Add general/multi-sector feeds (10 feeds)

- [ ] **Step 30**: Validate rss_feeds.json

#### Implementation Steps - Benefits

- [ ] **Step 31**: Create benefits.json
  ```
  File: Packages/V7Services/Resources/benefits.json
  ```

- [ ] **Step 32**: Add benefits list (50+ benefits)
  ```json
  {
    "version": "1.0.0",
    "benefits": [
      {
        "id": "uuid-benefit-1",
        "name": "Health Insurance",
        "category": "Healthcare"
      },
      {
        "id": "uuid-benefit-2",
        "name": "401(k)",
        "category": "Retirement"
      }
    ]
  }
  ```

- [ ] **Step 33**: Validate benefits.json

#### Final JSON Validation

- [ ] **Step 34**: Update Package.swift to include resources
  ```swift
  // In Package.swift:
  .target(
      name: "V7Services",
      dependencies: [...],
      resources: [
          .process("Resources")
      ]
  )
  ```

- [ ] **Step 35**: Validate all JSON files
  ```bash
  for file in Packages/V7Services/Resources/*.json; do
      echo "Validating $file"
      python3 -m json.tool "$file" > /dev/null && echo "✅ Valid" || echo "❌ Invalid"
  done
  ```

- [ ] **Step 36**: Commit JSON files
  ```bash
  git add Packages/V7Services/Resources/*.json
  git add Packages/V7Services/Package.swift
  git commit -m "feat: add comprehensive configuration JSON files across 20+ sectors"
  ```

**Completion Criteria**: ✅ 500+ skills, 100+ roles, 100+ companies, 30+ feeds

---

### Task 3.3: Implement Local Configuration Service (4 hours)

#### Implementation Steps
- [ ] **Step 1**: Create LocalConfigurationService.swift
  ```
  File: Packages/V7Services/Sources/V7Services/Configuration/LocalConfigurationService.swift
  ```

- [ ] **Step 2**: Implement configuration loading
  ```swift
  import Foundation

  public final class LocalConfigurationService: ConfigurationProvider {
      private let bundle: Bundle
      private let decoder = JSONDecoder()

      public init(bundle: Bundle = .module) {
          self.bundle = bundle
      }

      public func getSkills() async throws -> SkillsConfiguration {
          try await loadConfiguration(filename: "skills")
      }

      public func getRoles() async throws -> [JobRole] {
          let config: RolesConfiguration = try await loadConfiguration(filename: "roles")
          return config.roles
      }

      private func loadConfiguration<T: Decodable>(filename: String) async throws -> T {
          guard let url = bundle.url(forResource: filename, withExtension: "json") else {
              throw ConfigurationError.fileNotFound("\(filename).json")
          }

          let data = try Data(contentsOf: url)
          return try decoder.decode(T.self, from: data)
      }
  }
  ```

- [ ] **Step 3**: Add helper configuration wrapper types
  - RolesConfiguration
  - CompaniesConfiguration
  - RSSFeedsConfiguration
  - BenefitsConfiguration

- [ ] **Step 4**: Add error handling
  - ConfigurationError enum
  - Proper error messages
  - Logging

- [ ] **Step 5**: Save file

#### Validation Steps
- [ ] **Validate 1**: Build Services package
  ```bash
  cd Packages/V7Services && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 2**: Create unit test
  ```swift
  // Tests/V7ServicesTests/ConfigurationTests.swift
  func testLoadSkills() async throws {
      let service = LocalConfigurationService()
      let config = try await service.getSkills()

      XCTAssertGreaterThan(config.skills.count, 500)
      XCTAssertTrue(config.skills.contains { $0.sector == "Healthcare" })
      XCTAssertTrue(config.skills.contains { $0.sector == "Finance" })
  }
  ```

- [ ] **Validate 3**: Run configuration tests
  ```bash
  swift test --filter ConfigurationTests
  ```
  Expected: All tests pass

- [ ] **Validate 4**: Commit changes
  ```bash
  git add Packages/V7Services/Sources/V7Services/Configuration/LocalConfigurationService.swift
  git commit -m "feat: implement LocalConfigurationService for JSON loading"
  ```

**Completion Criteria**: ✅ Configuration service loads all JSON files

---

### Task 3.4: Update SkillsDatabase to Use Configuration (4 hours)

#### Implementation Steps
- [ ] **Step 1**: Open SkillsDatabase.swift
  ```
  File: Packages/V7JobParsing/Sources/V7JobParsing/Core/SkillsDatabase.swift
  ```

- [ ] **Step 2**: Add V7Services dependency
  ```swift
  // In Package.swift for V7JobParsing:
  dependencies: [
      .product(name: "V7Services", package: "V7Services")
  ]
  ```

- [ ] **Step 3**: Replace hardcoded skills with dynamic loading
  ```swift
  import Foundation
  import V7Services

  public final class SkillsDatabase {
      public static let shared = SkillsDatabase()

      private var skills: Set<String> = []
      private var skillsByCategory: [String: Set<String>] = [:]
      private var skillsBySector: [String: Set<String>] = [:]
      private var configService: ConfigurationProvider

      private init() {
          self.configService = LocalConfigurationService()
      }

      public func loadSkills() async throws {
          let config = try await configService.getSkills()

          skills = Set(config.skills.map { $0.name })

          // Organize by category
          for skill in config.skills {
              skillsByCategory[skill.category, default: []].insert(skill.name)
              skillsBySector[skill.sector, default: []].insert(skill.name)
          }
      }

      public func getAllSkills() -> Set<String> {
          return skills
      }

      public func getSkills(in category: String) -> Set<String> {
          return skillsByCategory[category] ?? []
      }

      public func getSkills(in sector: String) -> Set<String> {
          return skillsBySector[sector] ?? []
      }
  }
  ```

- [ ] **Step 4**: Remove ALL hardcoded skill arrays
  - Delete `technicalSkills` constant
  - Delete all hardcoded skill arrays
  - Keep only dynamic loading logic

- [ ] **Step 5**: Update initialization
  - Add async init if needed
  - Call `loadSkills()` on first access
  - Add caching for performance

- [ ] **Step 6**: Save file

#### Validation Steps
- [ ] **Validate 1**: Build V7JobParsing package
  ```bash
  cd Packages/V7JobParsing && swift build
  ```
  Expected: Build succeeds

- [ ] **Validate 2**: Test skills loading
  ```swift
  func testSkillsLoadFromConfiguration() async throws {
      let db = SkillsDatabase.shared
      try await db.loadSkills()

      let allSkills = db.getAllSkills()
      XCTAssertGreaterThan(allSkills.count, 500)

      let healthcareSkills = db.getSkills(in: "Healthcare")
      XCTAssertGreaterThan(healthcareSkills.count, 50)
  }
  ```

- [ ] **Validate 3**: Run skills tests
  ```bash
  swift test --filter SkillsDatabaseTests
  ```
  Expected: All tests pass

- [ ] **Validate 4**: Test app behavior
  - Run app
  - Check logs for skills loading
  - Verify job parsing uses all sectors
  - No tech-only filtering

- [ ] **Validate 5**: Commit changes
  ```bash
  git add Packages/V7JobParsing/Sources/V7JobParsing/Core/SkillsDatabase.swift
  git add Packages/V7JobParsing/Package.swift
  git commit -m "refactor: replace hardcoded skills with dynamic configuration loading"
  ```

**Completion Criteria**: ✅ SkillsDatabase loads from configuration, not hardcoded

---

### Task 3.5: Update Job Source Clients (16 hours)

This is spread across multiple files and job sources.

#### GreenhouseAPIClient Updates (4 hours)

- [ ] **Step 1**: Open GreenhouseAPIClient.swift
  ```
  File: Packages/V7Services/Sources/V7Services/CompanyAPIs/GreenhouseAPIClient.swift
  ```

- [ ] **Step 2**: Replace hardcoded company list (Line 733)
  ```swift
  // OLD:
  private func createGreenhouseCompanies() -> [String] {
      return [
          "airbnb", "stripe", "figma", "shopify", "square", "robinhood",
          "adobe", "sketch", "dropbox", "spotify", "pinterest", "medium",
          "github", "gitlab", "docker", "hashicorp", "mongodb", "elastic"
      ]
  }

  // NEW:
  private func loadGreenhouseCompanies() async throws -> [Company] {
      let companies = try await configService.getCompanies()
      return companies.filter { $0.apiType == .greenhouse }
  }
  ```

- [ ] **Step 3**: Replace hardcoded tech skills (Line 562)
  ```swift
  // OLD:
  let techSkills = ["Swift", "iOS", "SwiftUI", ...]

  // NEW:
  let allSkills = try await SkillsDatabase.shared.getAllSkills()
  ```

- [ ] **Step 4**: Remove keyword-to-company mappings (Lines 610-618)
  - Delete hardcoded keyword matching
  - Use sector-based filtering instead

- [ ] **Step 5**: Save file

- [ ] **Validate**: Build and test Greenhouse client

#### LeverAPIClient Updates (4 hours)

- [ ] **Step 6**: Repeat similar changes for LeverAPIClient.swift
- [ ] **Step 7**: Replace company lists
- [ ] **Step 8**: Replace skill lists
- [ ] **Step 9**: Remove keyword biases
- [ ] **Validate**: Build and test Lever client

#### JobDiscoveryCoordinator Updates (4 hours)

- [ ] **Step 10**: Update RSS feed loading
  ```swift
  // Load RSS feeds from configuration
  private func loadRSSFeeds() async throws -> [RSSFeed] {
      return try await configService.getRSSFeeds()
  }
  ```

- [ ] **Step 11**: Remove hardcoded RSS URLs
- [ ] **Step 12**: Update RSS parsing to use all sectors
- [ ] **Step 13**: Remove tech skill extraction biases
- [ ] **Validate**: Test RSS feed parsing

#### Other Job Source Files (4 hours)

- [ ] **Step 14**: Update RemotiveJobSource
- [ ] **Step 15**: Update AngelListJobSource
- [ ] **Step 16**: Update any other job sources
- [ ] **Validate**: Test all job sources

#### Final Integration

- [ ] **Step 17**: Update initialization
  - Load configuration on app start
  - Cache for performance
  - Handle loading errors gracefully

- [ ] **Step 18**: Add configuration version checking
  - Track current version
  - Detect updates
  - Reload when needed

- [ ] **Step 19**: Commit all changes
  ```bash
  git add Packages/V7Services/Sources/V7Services/CompanyAPIs/*.swift
  git add Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
  git commit -m "refactor: update all job source clients to use configuration service"
  ```

**Completion Criteria**: ✅ All job sources use configuration, no hardcoded data

---

### Phase 3 Final Validation

- [ ] **Configuration Loading Test**:
  ```bash
  swift test --filter ConfigurationTests
  ```
  Expected: All tests pass

- [ ] **Skills Test**:
  - [ ] Healthcare skills: >100
  - [ ] Finance skills: >80
  - [ ] Technology skills: >100
  - [ ] Total skills: >500

- [ ] **Roles Test**:
  - [ ] Healthcare roles: >20
  - [ ] Finance roles: >15
  - [ ] Total roles: >100

- [ ] **Companies Test**:
  - [ ] Healthcare companies: >25
  - [ ] Finance companies: >25
  - [ ] Total companies: >100

- [ ] **RSS Feeds Test**:
  - [ ] Healthcare feeds: >5
  - [ ] Finance feeds: >3
  - [ ] Total feeds: >30

- [ ] **Build Test**:
  ```bash
  xcodebuild -workspace ManifestAndMatchV7.xcworkspace -scheme ManifestAndMatchV7 build
  ```
  Expected: Build succeeds

- [ ] **App Test**:
  - Run app
  - Verify configuration loads
  - Check logs for errors
  - Test job discovery across sectors

- [ ] **Performance Test**:
  - Configuration load time: <1s
  - Memory impact: <10MB
  - No performance degradation

- [ ] **Create Pull Request**:
  ```bash
  git push origin feature/bias-elimination-phase3
  # Create PR for review
  ```

- [ ] **Phase 3 Sign-Off**: All tasks completed and validated

**Phase 3 Success Criteria**:
✅ JSON configuration files created (500+ skills, 100+ roles, 100+ companies, 30+ feeds)
✅ Configuration service implemented and tested
✅ SkillsDatabase loads dynamically
✅ All job source clients use configuration
✅ Zero hardcoded skills/roles/companies remaining

---

## 🌐 PHASE 4: EXPAND JOB SOURCES
**Duration**: Day 9-13 (5 days, 40 hours)
**Goal**: Add diverse job sources beyond tech sector

*(Continues with similar detailed checklists for Phases 4, 5, and 6...)*

---

**Note**: Due to length constraints, I'm providing the complete structure for Phases 1-3 in detail. Would you like me to continue with the detailed checklists for Phases 4-6, or would you prefer a summary format for the remaining phases?

---

## 📊 OVERALL PROGRESS TRACKER

### Phase Completion Status

```
Phase 1: Immediate Critical Fixes        [ ] 0/6 tasks complete
Phase 2: Profile Completion Gate         [ ] 0/2 tasks complete
Phase 3: Externalize Configuration       [ ] 0/5 tasks complete
Phase 4: Expand Job Sources             [ ] Not started
Phase 5: Bias Detection & Monitoring    [ ] Not started
Phase 6: Validation & Testing           [ ] Not started

Overall Progress: 0% (0/89 tasks)
```

### Success Metrics Dashboard

```
Current State:
- Bias Score: ~20/100 (severe bias)
- Tech Job %: ~80% (all users)
- Sector Diversity: 2 sectors
- Job Sources: 3 (all tech)

Target State:
- Bias Score: >90/100
- Tech Job %: ≤30%
- Sector Diversity: 20+ sectors
- Job Sources: 30+ (all sectors)
```

---

**END OF PHASES 1-3 DETAILED CHECKLIST**

Shall I continue with detailed checklists for Phases 4-6?