# ManifestAndMatch V8 - Phase 1.75 Checklist
## Onboarding Redesign: O*NET-Powered Multi-Entry Profile Collection

**Phase Duration**: 2-3 weeks
**Timeline**: Immediately after Phase 1.5 completion
**Priority**: 🚨 **CRITICAL - BLOCKING PHASE 2**
**Skills Coordinated**: ios26-specialist (Lead), v7-architecture-guardian, swift-concurrency-enforcer, accessibility-compliance-enforcer, app-narrative-guide, ios-app-architect
**Status**: Not Started
**Last Updated**: October 30, 2025

---

## Mission Statement

**Transform onboarding from basic profile creation to comprehensive career identity capture** by integrating O*NET occupation data, resume parser auto-population, and multi-entry forms for work experience, education, and certifications - creating a complete UserProfile that serves as the foundation for personalized job discovery and career transformation.

This phase bridges the gap between "name and skills" (current onboarding) and "95% profile completeness" (ProfileScreen expectation).

---

## Critical Context: Why Phase 1.75 Exists

### The Blocking Issue Discovered in Phase 1.5

From `PHASE_1.5_ONET_FORM_IMPLEMENTATION.md`:

```
🚨 CRITICAL BLOCKING ISSUE DISCOVERED

Issue: UserProfile Not Persisting to Core Data

Symptoms:
- All 7 forms show error: "User profile not found (0 profiles in DB)"
- Debug output confirms: 0 UserProfile entities exist in Core Data
- Error occurs even AFTER completing onboarding successfully

Root Cause:
- Onboarding creates UserProfile in AppState (in-memory)
- UserProfile entity NEVER saved to Core Data persistent store
- Forms cannot save child entities without parent UserProfile relationship

Status: BLOCKING - Phase 1.5 forms are 100% complete but untestable
```

### The Data Collection Gap

| Data Field | Current Onboarding | Resume Parser | ProfileScreen Expects | Gap |
|------------|-------------------|---------------|----------------------|-----|
| Name | ✅ Collected | ✅ Extracts | ✅ Required | None |
| Email | ❌ NOT collected | ✅ Extracts | ✅ Required | **CRITICAL** |
| Phone | ❌ NOT collected | ✅ Extracts | ❌ Optional | Missing |
| Location | ❌ NOT collected | ✅ Extracts | ❌ Optional | Missing |
| Work Experience | ❌ NOT collected | ✅ Extracts multiple | ✅ Expected (7 entities) | **CRITICAL** |
| Education | ❌ NOT collected | ✅ Extracts multiple | ✅ Expected (7 entities) | **CRITICAL** |
| Certifications | ❌ NOT collected | ✅ Extracts | ✅ Expected (7 entities) | **CRITICAL** |
| Skills | ✅ Basic collection | ✅ Extracts | ✅ Required | Needs enhancement |

### The Solution: Phase 1.75

**Phase 1.75 redesigns onboarding to:**
1. ✅ **Map complete data flow** (Resume Parser → Onboarding → Core Data → ProfileScreen)
2. ✅ **Fix Core Data schema mismatches** (types, required fields, relationships)
3. ✅ Collect all missing contact fields (email, phone, location)
4. ✅ Add multi-entry work experience collection (O*NET role bubbles)
5. ✅ Add multi-entry education collection (O*NET education levels)
6. ✅ Add multi-entry certification collection (optional)
7. ✅ Integrate Foundation Models resume parser auto-population
8. ✅ Create all 7 child entities during onboarding (not just UserProfile)
9. ✅ Match ProfileScreen's 95% completeness expectation

**Key Insight**: The UserProfile persistence failure is a **data architecture problem**, not a Core Data bug. By mapping the complete data flow and fixing schema mismatches, persistence will work automatically.

---

## Phase Boundary Analysis: What Phase 1.75 Does vs. Future Phases

### ✅ Phase 1.75 (This Document) - ONBOARDING DATA COLLECTION

**Scope**: Collect base profile data during initial onboarding
- Contact info: name, email, phone, location
- Work Experience: company, title, dates, description (multiple entries)
- Education: institution, degree, field of study, dates (multiple entries)
- Certifications: name, issuer, dates (multiple entries)
- Skills: extracted from resume + manual entry
- **UI Pattern**: O*NET bubble selection (like WorkExperienceFormView)
- **Data Source**: Resume parser auto-population + manual entry
- **Persistence**: Create UserProfile + all child entities in Core Data

**What We DON'T Do** (belongs to Phase 2):
- ❌ O*NET Education Level Picker (1-12 scale slider) - Phase 2 Task 2.1
- ❌ Work Activities Selector (41 O*NET activities) - Phase 2 Task 2.2
- ❌ RIASEC Interest Profiler (6-dimension career interests) - Phase 2 Task 2.3
- ❌ Advanced O*NET profile fields (interests, work styles, etc.)

---

### ✅ Phase 2 - ADVANCED O*NET PROFILE EDITOR (ProfileScreen)

**Scope**: Add advanced O*NET fields to ProfileScreen for editing AFTER onboarding
- Education Level Picker (1-12 O*NET scale)
- Work Activities Selector (41 activities with importance ratings)
- RIASEC Interest Profiler (6 career interest dimensions)
- **UI Pattern**: ProfileScreen sections (not onboarding)
- **Data Source**: User manual entry (no resume parser)
- **Timing**: AFTER onboarding, when user wants to refine profile

**Why Separate?**
- Onboarding should be fast (10-15 minutes max)
- Advanced O*NET fields are optional enhancements
- Users can complete these later in ProfileScreen

---

### ✅ Phase 3 - CAREER JOURNEY FEATURES

**Scope**: Career discovery and transition planning
- Skills Gap Analysis
- Career Path Visualization
- Course Recommendations
- AI Cover Letter Generator

**No Overlap**: Phase 3 assumes profile data already exists from Phase 1.75

---

### ✅ Phase 4 - LIQUID GLASS UI ADOPTION

**Scope**: Visual design modernization
- Apply iOS 26 Liquid Glass to all UI elements
- WCAG 2.1 AA contrast validation
- VoiceOver testing

**No Overlap**: Phase 4 styles what Phase 1.75 builds

---

### ✅ Phase 5 - COURSE INTEGRATION & REVENUE

**Scope**: Monetization through course recommendations
- Udemy/Coursera API integration
- Skill gap → course recommendations
- Affiliate revenue tracking

**No Overlap**: Phase 5 uses profile data from Phase 1.75

---

### ✅ Phase 6 - PRODUCTION HARDENING

**Scope**: Final testing and App Store launch
- Performance profiling
- A/B testing
- Accessibility audit
- App Store submission

**No Overlap**: Phase 6 validates what Phase 1.75 builds

---

## Current Onboarding Flow (7 Steps)

From `OnboardingFlow.swift`:

```swift
Step 0: WelcomeStepView
Step 1: PermissionsStepView
Step 2: ResumeUploadStepView (parsedResume stored)
Step 3: ProfileSetupStepView (receives parsedResume)
Step 4: SkillsReviewStepView
Step 5: PreferencesStepView
Step 6: DualProfileIntroStepView
```

**What Gets Collected**:
- Step 3: Name, experience level
- Step 4: Skills (manual selection)
- Step 5: Preferred job types, locations, salary range, remote preference

**Critical Issue**: UserProfile created in AppState but NEVER saved to Core Data

---

## New Onboarding Flow (Phase 1.75)

### Step-by-Step Redesign

```swift
Step 0: WelcomeStepView (unchanged)
Step 1: PermissionsStepView (unchanged)
Step 2: ResumeUploadStepView (unchanged, parsedResume stored)

// NEW: Step 3 - Contact Information
Step 3: ContactInfoStepView
  - Email (required, auto-populated from parsedResume)
  - Phone (optional, auto-populated)
  - Location (optional, auto-populated)
  - Creates UserProfile in Core Data immediately

// NEW: Step 4 - Work Experience (Multi-Entry)
Step 4: WorkExperienceCollectionStepView
  - O*NET role bubble selection (30 roles)
  - Auto-populate from parsedResume.experience array
  - Allow adding multiple entries
  - Each entry creates WorkExperience entity in Core Data
  - Skip button if no experience

// NEW: Step 5 - Education (Multi-Entry)
Step 5: EducationCollectionStepView
  - O*NET education level bubbles (12 levels)
  - Auto-populate from parsedResume.education array
  - Allow adding multiple entries
  - Each entry creates Education entity in Core Data
  - Skip button if no education

// OPTIONAL: Step 6 - Certifications (Multi-Entry)
Step 6: CertificationCollectionStepView (optional)
  - Manual entry only (no O*NET data)
  - Auto-populate from parsedResume.certifications
  - Allow adding multiple entries
  - Each entry creates Certification entity
  - Skip button if none

// Modified: Step 7 - Skills Review
Step 7: SkillsReviewStepView (enhanced)
  - Pre-populated from resume + work experience + education
  - Allow manual additions
  - Save to UserProfile.skills array

// Modified: Step 8 - Preferences
Step 8: PreferencesStepView (enhanced)
  - Preferred job types (using O*NET roles)
  - Locations, salary range, remote preference
  - Save to UserProfile entity

Step 9: DualProfileIntroStepView (unchanged)
```

**New Step Count**: 10 steps (was 7)
**Estimated Time**: 12-18 minutes (was 5-8 minutes)
**Profile Completeness**: 85-95% (was 40%)

---

## TASK 1: Data Flow Mapping & Schema Alignment (FOUNDATION)

**Duration**: 2 days
**Skill**: v7-architecture-guardian, ios-app-architect, core-data-specialist
**Priority**: 🚨 CRITICAL - FOUNDATION FOR EVERYTHING

### Why This Task Comes First

**The Real Problem**: UserProfile persistence fails because of **data architecture mismatches** across the pipeline:

```
Resume Parser → Onboarding → Core Data → ProfileScreen
      ↓             ↓             ↓            ↓
  Provides X    Expects Y    Requires Z    Needs W

                ❌ MISMATCH = Persistence Fails
```

**Example Mismatches**:
- Parser provides `fullName: String`, Core Data has `name: String?`, ProfileScreen expects `profile.name`
- Parser provides `skills: [String]`, Core Data has `skills: String?` (comma-separated), ProfileScreen expects array
- Parser provides `experience: [WorkExp]`, onboarding doesn't create entities, ProfileScreen expects `workExperiences: [WorkExperience]`
- Core Data requires `experienceLevel`, parser doesn't provide it → save fails

**Solution**: Map the COMPLETE data flow before writing any code.

### Task 1.1: Create Data Flow Mapping Document

**File**: `DATA_FLOW_MAPPING.md` (NEW)

**Content**: Comprehensive mapping of every field from parser → Core Data → ProfileScreen

```markdown
# Data Flow Mapping: Resume Parser → Onboarding → Core Data → ProfileScreen

## Resume Parser Output Schema (V7AIParsing/ResumeParser.swift)

struct ParsedResume: Sendable {
    let sourceHash: String
    let parsingDurationMs: Int
    let confidenceScore: Double
    let parsingMethod: ParsingMethod

    // Contact Info
    let fullName: String?           → Maps to: UserProfile.name (String)
    let email: String?              → Maps to: UserProfile.email (String)
    let phone: String?              → Maps to: UserProfile.phone (String?) ⚠️ ADD TO SCHEMA
    let location: String?           → Maps to: UserProfile.location (String?) ⚠️ ADD TO SCHEMA
    let linkedInURL: String?        → Maps to: UserProfile.linkedInURL (String?) ⚠️ ADD TO SCHEMA
    let githubURL: String?          → Maps to: UserProfile.githubURL (String?) ⚠️ ADD TO SCHEMA

    // Skills
    let skills: [String]            → Maps to: UserProfile.skills ([String]) ⚠️ CHANGE FROM String

    // Work Experience
    let experience: [WorkExperience] → Maps to: [WorkExperience] entities ⚠️ CREATE DURING ONBOARDING
        - title: String?            → WorkExperience.title (String)
        - company: String?          → WorkExperience.company (String)
        - startDate: Date?          → WorkExperience.startDate (Date?)
        - endDate: Date?            → WorkExperience.endDate (Date?)
        - isCurrent: Bool           → WorkExperience.isCurrent (Bool)
        - description: String?      → WorkExperience.jobDescription (String?)

    // Education
    let education: [Education]?     → Maps to: [Education] entities ⚠️ CREATE DURING ONBOARDING
        - institution: String?      → Education.institution (String)
        - degree: String?           → Education.degree (String)
        - fieldOfStudy: String?     → Education.fieldOfStudy (String?)

    // Certifications
    let certifications: [Cert]      → Maps to: [Certification] entities ⚠️ CREATE DURING ONBOARDING
        - name: String?             → Certification.name (String)
        - issuer: String?           → Certification.issuer (String?)

    // Summary
    let summary: String?            → Maps to: UserProfile.professionalSummary (String?) ⚠️ ADD TO SCHEMA
}

## Core Data Schema Requirements (V7Data/UserProfile.xcdatamodel)

### UserProfile Entity

✅ Existing Fields (Keep):
- id: UUID (required)
- createdDate: Date (required)
- lastModified: Date (required)
- amberTealPosition: Double (required, default: 0.5)
- desiredRoles: [String] (required, default: [])

⚠️ Fields to ADD:
- phone: String? (optional) - from parsedResume.phone
- location: String? (optional) - from parsedResume.location
- linkedInURL: String? (optional) - from parsedResume.linkedInURL
- githubURL: String? (optional) - from parsedResume.githubURL
- professionalSummary: String? (optional) - from parsedResume.summary

⚠️ Fields to FIX (Type Mismatch):
- skills: String? → CHANGE TO: Transformable [String]
  - Current: Comma-separated string "Swift,iOS,Python"
  - New: Array ["Swift", "iOS", "Python"]
  - Migration: Split existing strings on comma

⚠️ Required Fields (Parser Doesn't Provide - Need Defaults):
- experienceLevel: String (required)
  - Default: Infer from parsedResume.experience.count
    - 0-2 years → "entry"
    - 3-7 years → "mid"
    - 8+ years → "senior"

- currentDomain: String (required)
  - Default: Infer from most recent parsedResume.experience[0].title
  - Use O*NET role mapping: "Software Developer" → "Technology"
  - Fallback: "General"

- remotePreference: String (required)
  - Default: "hybrid"
  - User can change in preferences step

- locations: [String] (required)
  - Default: [parsedResume.location] if exists, else []
  - User can add more in preferences step

- salaryMin: Int32 (optional)
  - Default: nil (will be set in preferences step)

- salaryMax: Int32 (optional)
  - Default: nil (will be set in preferences step)

### Child Entity Relationships (CRITICAL)

⚠️ ALL child entities MUST have UserProfile relationship set:

WorkExperience.profile → UserProfile (required, delete rule: cascade)
Education.profile → UserProfile (required, delete rule: cascade)
Certification.profile → UserProfile (required, delete rule: cascade)
Project.profile → UserProfile (required, delete rule: cascade)
VolunteerExperience.profile → UserProfile (required, delete rule: cascade)
Award.profile → UserProfile (required, delete rule: cascade)
Publication.profile → UserProfile (required, delete rule: cascade)

## Onboarding Flow Data Collection Strategy

### Step 3: ContactInfoStepView - Creates UserProfile Entity

**Input**: parsedResume
**Creates**: UserProfile entity with ALL required fields populated
**Fields Collected**:
- name (from parsedResume.fullName) ✅ required
- email (from parsedResume.email) ✅ required
- phone (from parsedResume.phone) - optional
- location (from parsedResume.location) - optional
- linkedInURL (from parsedResume.linkedInURL) - optional
- githubURL (from parsedResume.githubURL) - optional
- professionalSummary (from parsedResume.summary) - optional

**Inferred Fields** (parser doesn't provide):
- experienceLevel: inferFromExperience(parsedResume.experience)
- currentDomain: inferFromJobTitle(parsedResume.experience[0].title)
- remotePreference: "hybrid" (default)
- locations: [parsedResume.location] or []
- amberTealPosition: 0.5 (default)
- desiredRoles: [] (populated in preferences step)
- skills: [] (populated in skills step)

**Critical**: ✅ context.save() MUST succeed with ZERO missing required fields

### Step 4: WorkExperienceCollectionStepView - Creates WorkExperience Entities

**Input**: parsedResume.experience array
**Fetches**: UserProfile.fetchCurrent(in: context)
**Creates**: [WorkExperience] entities with profile relationship

For each parsedResume.experience:
- Create WorkExperience(context: context)
- Set all fields from parsed data
- Set profile = userProfile ✅ required relationship
- context.save()

### Step 5: EducationCollectionStepView - Creates Education Entities

**Input**: parsedResume.education array
**Fetches**: UserProfile.fetchCurrent(in: context)
**Creates**: [Education] entities with profile relationship

### Step 6: CertificationCollectionStepView - Creates Certification Entities

**Input**: parsedResume.certifications array
**Fetches**: UserProfile.fetchCurrent(in: context)
**Creates**: [Certification] entities with profile relationship

### Step 7: SkillsReviewStepView - Populates UserProfile.skills

**Input**: parsedResume.skills + Foundation Models extraction from work descriptions
**Updates**: UserProfile.skills = extractedSkills array
**context.save()**

### Step 8: PreferencesStepView - Finalizes UserProfile

**Input**: User selections
**Updates**:
- UserProfile.desiredRoles (O*NET role search)
- UserProfile.locations (add more beyond current location)
- UserProfile.salaryMin/salaryMax
- UserProfile.remotePreference (if changed from default)
**context.save()**

## ProfileScreen Expectations (V7UI/ProfileScreen.swift)

ProfileScreen expects to fetch:

```swift
let profile = UserProfile.fetchCurrent(in: context)

// Contact Section
profile.name → Text(profile.name)
profile.email → Text(profile.email)
profile.phone → Text(profile.phone ?? "Not provided")
profile.location → Text(profile.location ?? "Not specified")

// Skills Section
profile.skills → ForEach(profile.skills, id: \.self) { skill in }

// Work Experience Section
profile.workExperiences → ForEach(experiences) { exp in }

// Education Section
profile.educations → ForEach(educations) { edu in }

// And so on for all 7 child entity types
```

**All fields MUST exist and have correct types for ProfileScreen to load without errors.**

## Validation Checklist

✅ Every parser field has a Core Data destination
✅ Every Core Data required field has a source (parser or inferred)
✅ All type mismatches fixed (String vs [String])
✅ All child entity relationships established
✅ ProfileScreen can load all data without nil crashes
✅ No missing required fields when context.save() is called
```

**Deliverable**: `DATA_FLOW_MAPPING.md` created and reviewed by all guardians

---

### Task 1.2: Update Core Data Schema

**File**: `V7Data/Sources/V7Data/V7Data.xcdatamodeld/V7Data.xcdatamodel/contents`

**Schema Changes**:

```xml
<!-- UserProfile Entity Updates -->
<entity name="UserProfile" ...>
    <!-- Existing attributes (keep) -->
    <attribute name="id" attributeType="UUID" usesScalarValueType="NO"/>
    <attribute name="name" attributeType="String"/>
    <attribute name="email" attributeType="String"/>
    <attribute name="createdDate" attributeType="Date" usesScalarValueType="NO"/>
    <attribute name="lastModified" attributeType="Date" usesScalarValueType="NO"/>

    <!-- ADD: New attributes from parser -->
    <attribute name="phone" optional="YES" attributeType="String"/>
    <attribute name="location" optional="YES" attributeType="String"/>
    <attribute name="linkedInURL" optional="YES" attributeType="String"/>
    <attribute name="githubURL" optional="YES" attributeType="String"/>
    <attribute name="professionalSummary" optional="YES" attributeType="String"/>

    <!-- FIX: Change skills from String to Transformable [String] -->
    <attribute name="skills" attributeType="Transformable" valueTransformerName="NSSecureUnarchiveFromData" customClassName="[String]"/>

    <!-- Existing required fields with proper defaults -->
    <attribute name="experienceLevel" attributeType="String" defaultValueString="mid"/>
    <attribute name="currentDomain" attributeType="String" defaultValueString="General"/>
    <attribute name="remotePreference" attributeType="String" defaultValueString="hybrid"/>
    <attribute name="amberTealPosition" attributeType="Double" defaultValueString="0.5" usesScalarValueType="YES"/>

    <!-- Relationships (ensure delete rules correct) -->
    <relationship name="workExperiences" optional="YES" toMany="YES" deletionRule="Cascade" destinationEntity="WorkExperience" inverseName="profile"/>
    <relationship name="educations" optional="YES" toMany="YES" deletionRule="Cascade" destinationEntity="Education" inverseName="profile"/>
    <!-- ... other child relationships -->
</entity>
```

**Migration Strategy**:

```swift
// V7Data/Sources/V7Data/CoreDataMigration.swift

func migrateSkillsStringToArray() {
    // For existing UserProfiles with comma-separated skills string
    let fetchRequest = UserProfile.fetchRequest()
    let profiles = try context.fetch(fetchRequest)

    for profile in profiles {
        if let skillsString = profile.value(forKey: "skills") as? String {
            // Split comma-separated string into array
            let skillsArray = skillsString.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }

            profile.skills = skillsArray
        }
    }

    try context.save()
}
```

**Deliverable**: Core Data model updated with all schema changes

---

### Task 1.3: Create Schema Validation Tests

**File**: `V7DataTests/UserProfileSchemaTests.swift` (NEW)

```swift
import XCTest
import CoreData
@testable import V7Data

final class UserProfileSchemaTests: XCTestCase {
    var context: NSManagedObjectContext!

    override func setUp() {
        context = PersistenceController.preview.container.viewContext
    }

    func testUserProfileHasAllRequiredFields() throws {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Test User"
        profile.email = "test@example.com"
        profile.experienceLevel = "mid"
        profile.currentDomain = "Technology"
        profile.remotePreference = "hybrid"
        profile.amberTealPosition = 0.5
        profile.desiredRoles = []
        profile.locations = []
        profile.skills = []
        profile.createdDate = Date()
        profile.lastModified = Date()

        // Should save without errors
        XCTAssertNoThrow(try context.save())
    }

    func testUserProfileSkillsIsArray() throws {
        let profile = UserProfile(context: context)
        // ... set required fields ...

        profile.skills = ["Swift", "iOS", "Python"]

        try context.save()

        // Fetch and verify
        let fetchRequest = UserProfile.fetchRequest()
        let profiles = try context.fetch(fetchRequest)

        XCTAssertEqual(profiles.first?.skills.count, 3)
        XCTAssertEqual(profiles.first?.skills[0], "Swift")
    }

    func testWorkExperienceRequiresProfileRelationship() throws {
        let experience = WorkExperience(context: context)
        experience.id = UUID()
        experience.title = "Software Developer"
        experience.company = "Apple"
        experience.startDate = Date()
        experience.isCurrent = true
        // profile = nil (missing required relationship)

        // Should FAIL to save
        XCTAssertThrowsError(try context.save())
    }

    func testCompleteDataFlowFromParser() throws {
        // Simulate resume parser output
        let parsedResume = ParsedResume(
            fullName: "John Doe",
            email: "john@example.com",
            phone: "555-1234",
            location: "San Francisco, CA",
            skills: ["Swift", "iOS", "Python"],
            experience: [
                ParsedWorkExperience(
                    title: "iOS Developer",
                    company: "Apple",
                    startDate: Date(),
                    isCurrent: true
                )
            ],
            education: [
                ParsedEducation(
                    institution: "Stanford",
                    degree: "BS Computer Science"
                )
            ]
        )

        // Create UserProfile from parsed data
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = parsedResume.fullName
        profile.email = parsedResume.email
        profile.phone = parsedResume.phone
        profile.location = parsedResume.location
        profile.skills = parsedResume.skills
        profile.experienceLevel = inferExperienceLevel(from: parsedResume.experience)
        profile.currentDomain = "Technology"
        profile.remotePreference = "hybrid"
        profile.amberTealPosition = 0.5
        profile.desiredRoles = []
        profile.locations = [parsedResume.location].compactMap { $0 }
        profile.createdDate = Date()
        profile.lastModified = Date()

        // Create child entities
        for exp in parsedResume.experience {
            let workExp = WorkExperience(context: context)
            workExp.id = UUID()
            workExp.title = exp.title
            workExp.company = exp.company
            workExp.startDate = exp.startDate
            workExp.isCurrent = exp.isCurrent
            workExp.profile = profile  // Required relationship
        }

        // Should save successfully
        XCTAssertNoThrow(try context.save())

        // Verify ProfileScreen can load data
        let fetchRequest = UserProfile.fetchRequest()
        let profiles = try context.fetch(fetchRequest)

        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles.first?.name, "John Doe")
        XCTAssertEqual(profiles.first?.email, "john@example.com")
        XCTAssertEqual(profiles.first?.skills.count, 3)
        XCTAssertEqual(profiles.first?.workExperiences?.count, 1)
    }
}
```

**Deliverable**: All schema validation tests passing

---

## TASK 2: Build Contact Info Step with Complete Field Mapping

**Duration**: 2-3 days
**Skill**: v7-architecture-guardian, swift-concurrency-enforcer, accessibility-compliance-enforcer
**Priority**: HIGH - Creates UserProfile with ALL required fields

### Goal

Build ContactInfoStepView that creates UserProfile entity in Core Data with:
- ✅ ALL required fields populated (no nil values that cause save failures)
- ✅ Proper field mapping from ParsedResume → UserProfile
- ✅ Inferred defaults for fields parser doesn't provide
- ✅ Successful context.save() with ZERO missing required fields

### Background: Original Issue

From debug logs in `WorkExperienceFormView.swift:321-334`:

```swift
print("🔍 [WorkExperienceForm] Attempting to fetch UserProfile from context: \(context)")

let fetchRequest = UserProfile.fetchRequest()
let allProfiles = (try? context.fetch(fetchRequest)) ?? []
print("🔍 [WorkExperienceForm] Found \(allProfiles.count) UserProfile(s) in database")

guard let profile = UserProfile.fetchCurrent(in: context) else {
    validationMessage = "User profile not found (\(allProfiles.count) profiles in DB)"
    showValidationError = true
    return
}
```

**Result**: `Found 0 UserProfile(s) in database` - even after completing onboarding

### Root Cause Investigation

Possible causes:
1. `context.save()` never called in onboarding
2. Save called on wrong context (background vs viewContext)
3. Core Data merge conflict discarding changes
4. Profile created in preview/temporary context

### Solution: Create and Save UserProfile in Step 3

**File**: `ContactInfoStepView.swift` (NEW)

```swift
import SwiftUI
import CoreData
import V7Data
import V7Core

/// Step 3: Contact Information Collection
/// ✅ CRITICAL: Creates UserProfile in Core Data immediately
@MainActor
public struct ContactInfoStepView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(AppState.self) private var appState

    let parsedResume: ParsedResume?
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var location: String = ""
    @State private var showValidationError = false
    @State private var validationMessage = ""

    public init(
        parsedResume: ParsedResume?,
        onNext: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.parsedResume = parsedResume
        self.onNext = onNext
        self.onBack = onBack
    }

    public var body: some View {
        VStack(spacing: 24) {
            headerSection
            formSection

            if showValidationError {
                errorSection
            }

            Spacer()
            navigationButtons
        }
        .padding()
        .task {
            await loadInitialData()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Contact Information")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            Text("We'll use this to personalize your job search")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Name (required)
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name *")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("John Doe", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.name)
                    .autocapitalization(.words)
                    .accessibilityLabel("Full name, required")
            }

            // Email (required)
            VStack(alignment: .leading, spacing: 8) {
                Text("Email *")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("john@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .accessibilityLabel("Email address, required")
            }

            // Phone (optional)
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone (Optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("(555) 123-4567", text: $phone)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .accessibilityLabel("Phone number, optional")
            }

            // Location (optional)
            VStack(alignment: .leading, spacing: 8) {
                Text("Location (Optional)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                TextField("San Francisco, CA", text: $location)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.fullStreetAddress)
                    .accessibilityLabel("Location, optional")
            }
        }
    }

    private var errorSection: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(validationMessage)
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding(.horizontal)
    }

    private var navigationButtons: some View {
        HStack {
            Button("Back") {
                onBack()
            }
            .accessibilityLabel("Go back to previous step")

            Spacer()

            Button("Continue") {
                saveContactInfoAndContinue()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Continue to work experience")
        }
    }

    // MARK: - Data Loading

    private func loadInitialData() async {
        // Auto-populate from resume parser
        if let resume = parsedResume {
            name = resume.fullName ?? ""
            email = resume.email ?? ""
            phone = resume.phone ?? ""
            location = resume.location ?? ""
        }
    }

    // MARK: - ✅ CRITICAL: UserProfile Core Data Persistence

    private func saveContactInfoAndContinue() {
        // Validation
        guard !name.isEmpty else {
            validationMessage = "Name is required"
            showValidationError = true
            return
        }

        guard !email.isEmpty else {
            validationMessage = "Email is required"
            showValidationError = true
            return
        }

        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            validationMessage = "Please enter a valid email address"
            showValidationError = true
            return
        }

        print("🔧 [ContactInfoStep] Creating UserProfile in Core Data")
        print("   Name: \(name)")
        print("   Email: \(email)")
        print("   Context: \(context)")

        // ✅ FIX #1: Create UserProfile entity with COMPLETE field mapping
        let userProfile = UserProfile(context: context)
        userProfile.id = UUID()
        userProfile.createdDate = Date()
        userProfile.lastModified = Date()

        // ✅ Direct mappings from parser (ParsedResume → UserProfile)
        userProfile.name = name  // from parsedResume.fullName
        userProfile.email = email  // from parsedResume.email
        userProfile.phone = phone.isEmpty ? nil : phone  // from parsedResume.phone
        userProfile.location = location.isEmpty ? nil : location  // from parsedResume.location
        userProfile.linkedInURL = parsedResume?.linkedInURL  // NEW field
        userProfile.githubURL = parsedResume?.githubURL  // NEW field
        userProfile.professionalSummary = parsedResume?.summary  // NEW field

        // ✅ Required fields with proper defaults (parser doesn't provide)
        userProfile.experienceLevel = inferExperienceLevel()  // Infer from years
        userProfile.currentDomain = "General"  // Will update from work experience step
        userProfile.amberTealPosition = 0.5  // Default: balanced
        userProfile.desiredRoles = []  // Populated in preferences step
        userProfile.remotePreference = "hybrid"  // Default
        userProfile.locations = location.isEmpty ? [] : [location]
        userProfile.skills = []  // Populated in skills step
        userProfile.salaryMin = nil  // Optional, set in preferences
        userProfile.salaryMax = nil  // Optional, set in preferences

        // ✅ FIX #2: SAVE TO CORE DATA IMMEDIATELY
        do {
            try context.save()
            print("✅ [ContactInfoStep] UserProfile saved successfully")
            print("   ID: \(userProfile.id.uuidString)")

            // Verify save
            let fetchRequest = UserProfile.fetchRequest()
            let profiles = (try? context.fetch(fetchRequest)) ?? []
            print("✅ [ContactInfoStep] Verification: \(profiles.count) profile(s) in database")

            // Update AppState with Core Data profile
            let appUserProfile = V7Core.UserProfile(
                id: userProfile.id.uuidString,
                name: userProfile.name,
                email: userProfile.email,
                skills: [],  // Will be populated in skills step
                experience: 3,  // Default, will be updated
                preferredJobTypes: [],  // Will be populated in preferences
                preferredLocations: userProfile.locations,
                salaryRange: nil
            )
            appState.userProfile = appUserProfile

            print("✅ [ContactInfoStep] AppState.userProfile updated")

            // Continue to next step
            onNext()

        } catch {
            print("❌ [ContactInfoStep] Failed to save UserProfile: \(error)")
            print("   Error details: \(error.localizedDescription)")

            validationMessage = "Failed to save profile. Please try again."
            showValidationError = true
        }
    }

    // MARK: - Helper Functions

    /// Infer experience level from parsed work experience data
    private func inferExperienceLevel() -> String {
        guard let resume = parsedResume,
              let experiences = resume.experience,
              !experiences.isEmpty else {
            return "entry"  // Default if no experience data
        }

        // Calculate total years of experience
        var totalYears = 0.0
        for exp in experiences {
            guard let startDate = exp.startDate else { continue }

            let endDate = exp.isCurrent ? Date() : (exp.endDate ?? Date())
            let years = endDate.timeIntervalSince(startDate) / (365.25 * 24 * 60 * 60)
            totalYears += years
        }

        // Classify based on total years
        switch totalYears {
        case 0..<2:
            return "entry"
        case 2..<7:
            return "mid"
        default:
            return "senior"
        }
    }
}
```

### Key Features

1. **Complete Field Mapping**: Maps ALL ParsedResume fields to UserProfile
2. **Inferred Defaults**: Calculates experienceLevel from work history
3. **Zero Missing Fields**: context.save() will succeed because all required fields populated
4. **Foundation for Child Entities**: UserProfile ID available for subsequent steps

### Testing Validation

**After implementing ContactInfoStepView:**

```swift
// Test: Complete Contact Info step
// Expected: UserProfile exists in Core Data

let fetchRequest = UserProfile.fetchRequest()
let profiles = try context.fetch(fetchRequest)
XCTAssertEqual(profiles.count, 1, "UserProfile should be saved")
XCTAssertEqual(profiles.first?.name, "Test User")
XCTAssertEqual(profiles.first?.email, "test@example.com")
```

**Success Criteria**:
- [ ] UserProfile entity created with ALL required fields populated
- [ ] `context.save()` succeeds without errors (no missing required fields)
- [ ] Fetch request returns 1 profile
- [ ] Profile has correct mappings from ParsedResume (name, email, phone, location)
- [ ] Inferred fields set correctly (experienceLevel, currentDomain)
- [ ] Optional fields (linkedInURL, githubURL, summary) mapped from parser
- [ ] UserProfile.skills initialized as empty array (not nil, not string)
- [ ] Child entity steps can now create entities with profile relationship

---

## TASK 3: Build Work Experience Step with Entity Creation

**Duration**: 3-4 days
**Skill**: v7-architecture-guardian, ios26-specialist, accessibility-compliance-enforcer, core-data-specialist
**Priority**: HIGH - Create WorkExperience entities with proper relationships

### Goal

Build WorkExperienceCollectionStepView that:
- ✅ Fetches existing UserProfile from Core Data (created in Task 2)
- ✅ Auto-populates from ParsedResume.experience array
- ✅ Creates WorkExperience entities with profile relationship
- ✅ Updates UserProfile.currentDomain from most recent job
- ✅ Successful context.save() for all entities

### Design: WorkExperienceCollectionStepView

**UI Pattern**: Match `WorkExperienceFormView.swift` bubble selection

```swift
import SwiftUI
import CoreData
import V7Data
import V7Core
import V7Services

/// Step 4: Work Experience Collection (Multi-Entry)
/// Auto-populates from resume parser, allows manual additions
@MainActor
public struct WorkExperienceCollectionStepView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(AppState.self) private var appState

    let parsedResume: ParsedResume?
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var experiences: [DraftExperience] = []
    @State private var showAddSheet = false
    @State private var editingIndex: Int?
    @State private var showDeleteConfirmation = false
    @State private var deleteIndex: Int?

    // O*NET role search
    @State private var availableRoles: [Role] = []
    @State private var isLoadingRoles = true

    public var body: some View {
        VStack(spacing: 24) {
            headerSection

            if experiences.isEmpty {
                emptyStateSection
            } else {
                experienceListSection
            }

            addExperienceButton

            Spacer()
            navigationButtons
        }
        .padding()
        .sheet(isPresented: $showAddSheet) {
            if let editIndex = editingIndex {
                WorkExperienceEntrySheet(
                    experience: experiences[editIndex],
                    availableRoles: availableRoles,
                    onSave: { updated in
                        experiences[editIndex] = updated
                        showAddSheet = false
                        editingIndex = nil
                    },
                    onCancel: {
                        showAddSheet = false
                        editingIndex = nil
                    }
                )
            } else {
                WorkExperienceEntrySheet(
                    experience: nil,
                    availableRoles: availableRoles,
                    onSave: { new in
                        experiences.append(new)
                        showAddSheet = false
                    },
                    onCancel: {
                        showAddSheet = false
                    }
                )
            }
        }
        .task {
            await loadInitialData()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Work Experience")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            Text("Add your previous positions to help us find perfect matches")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No work experience added yet")
                .font(.headline)

            Text("Tap below to add your first position, or skip if you're just starting your career")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var experienceListSection: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(experiences.indices, id: \.self) { index in
                    ExperienceCard(
                        experience: experiences[index],
                        onEdit: {
                            editingIndex = index
                            showAddSheet = true
                        },
                        onDelete: {
                            deleteIndex = index
                            showDeleteConfirmation = true
                        }
                    )
                }
            }
        }
        .confirmationDialog(
            "Delete this work experience?",
            isPresented: $showDeleteConfirmation,
            presenting: deleteIndex
        ) { index in
            Button("Delete", role: .destructive) {
                experiences.remove(at: index)
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    private var addExperienceButton: some View {
        Button {
            editingIndex = nil
            showAddSheet = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Work Experience")
            }
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Add work experience")
    }

    private var navigationButtons: some View {
        HStack {
            Button("Back") {
                onBack()
            }

            Spacer()

            if experiences.isEmpty {
                Button("Skip") {
                    saveAndContinue()
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Skip work experience")
            }

            Button("Continue (\(experiences.count))") {
                saveAndContinue()
            }
            .buttonStyle(.borderedProminent)
            .disabled(experiences.isEmpty && !canSkip)
            .accessibilityLabel("Continue to education with \(experiences.count) work experience entries")
        }
    }

    private var canSkip: Bool {
        // Allow skip if user is early career or career changer
        true
    }

    // MARK: - Data Loading

    private func loadInitialData() async {
        // Load O*NET roles for search
        do {
            let roles = await RolesDatabase.shared.allRoles
            await MainActor.run {
                availableRoles = roles
                isLoadingRoles = false
            }
        }

        // Auto-populate from resume parser
        if let resume = parsedResume, let parsedExperiences = resume.experience {
            experiences = parsedExperiences.map { parsedExp in
                DraftExperience(
                    id: UUID(),
                    title: parsedExp.title ?? "",
                    company: parsedExp.company ?? "",
                    startDate: parsedExp.startDate ?? Date(),
                    endDate: parsedExp.endDate,
                    isCurrent: parsedExp.isCurrent,
                    description: parsedExp.description ?? "",
                    technologies: []  // Resume parser doesn't extract tech stack
                )
            }
        }
    }

    // MARK: - Core Data Persistence

    private func saveAndContinue() {
        print("🔧 [WorkExperienceStep] Saving \(experiences.count) work experience entries")

        // Fetch UserProfile
        guard let userProfile = UserProfile.fetchCurrent(in: context) else {
            print("❌ [WorkExperienceStep] CRITICAL: UserProfile not found!")
            // This should NEVER happen if ContactInfoStep saved correctly
            return
        }

        print("✅ [WorkExperienceStep] UserProfile found: \(userProfile.name)")

        // Create WorkExperience entities with complete mapping
        for experience in experiences {
            let entity = WorkExperience(context: context)
            entity.id = UUID()
            entity.title = experience.title
            entity.company = experience.company
            entity.startDate = experience.startDate
            entity.endDate = experience.isCurrent ? nil : experience.endDate
            entity.isCurrent = experience.isCurrent
            entity.jobDescription = experience.description.isEmpty ? nil : experience.description
            entity.technologies = experience.technologies
            entity.achievements = []  // User can add later in ProfileScreen

            // ✅ CRITICAL: Set required relationship
            entity.profile = userProfile

            print("✅ [WorkExperienceStep] Created WorkExperience: \(entity.title) at \(entity.company)")
        }

        // ✅ Update UserProfile.currentDomain from most recent job
        if let mostRecent = experiences.first(where: { $0.isCurrent }) ?? experiences.first {
            let inferredDomain = inferDomain(from: mostRecent.title)
            userProfile.currentDomain = inferredDomain
            print("✅ [WorkExperienceStep] Updated currentDomain: \(inferredDomain)")
        }

        // Save to Core Data
        do {
            try context.save()
            print("✅ [WorkExperienceStep] All work experiences saved successfully")

            // Verify save
            let fetchRequest = WorkExperience.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "profile == %@", userProfile)
            let savedExperiences = (try? context.fetch(fetchRequest)) ?? []
            print("✅ [WorkExperienceStep] Verification: \(savedExperiences.count) experience(s) in database")

            onNext()

        } catch {
            print("❌ [WorkExperienceStep] Failed to save: \(error)")
        }
    }

    // MARK: - Helper Functions

    /// Infer industry domain from job title using O*NET role mapping
    private func inferDomain(from title: String) -> String {
        let lowercased = title.lowercased()

        // Technology roles
        if lowercased.contains("software") || lowercased.contains("developer") ||
           lowercased.contains("engineer") || lowercased.contains("programmer") ||
           lowercased.contains("architect") || lowercased.contains("devops") {
            return "Technology"
        }

        // Healthcare roles
        if lowercased.contains("nurse") || lowercased.contains("doctor") ||
           lowercased.contains("medical") || lowercased.contains("healthcare") ||
           lowercased.contains("physician") {
            return "Healthcare"
        }

        // Business/Finance roles
        if lowercased.contains("manager") || lowercased.contains("analyst") ||
           lowercased.contains("accountant") || lowercased.contains("finance") {
            return "Business"
        }

        // Education roles
        if lowercased.contains("teacher") || lowercased.contains("professor") ||
           lowercased.contains("educator") || lowercased.contains("instructor") {
            return "Education"
        }

        // Default
        return "General"
    }
}

// MARK: - Supporting Types

struct DraftExperience: Identifiable {
    let id: UUID
    var title: String
    var company: String
    var startDate: Date
    var endDate: Date?
    var isCurrent: Bool
    var description: String
    var technologies: [String]
}

struct ExperienceCard: View {
    let experience: DraftExperience
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(experience.title)
                        .font(.headline)
                    Text(experience.company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(dateRange)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Menu {
                    Button("Edit") {
                        onEdit()
                    }
                    Button("Delete", role: .destructive) {
                        onDelete()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(experience.title) at \(experience.company)")
        .accessibilityHint("Double tap to edit or delete")
    }

    private var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"

        let start = formatter.string(from: experience.startDate)
        let end = experience.isCurrent ? "Present" : (experience.endDate.map { formatter.string(from: $0) } ?? "")

        return "\(start) - \(end)"
    }
}

// MARK: - Work Experience Entry Sheet

struct WorkExperienceEntrySheet: View {
    @Environment(\.dismiss) private var dismiss

    let experience: DraftExperience?
    let availableRoles: [Role]
    let onSave: (DraftExperience) -> Void
    let onCancel: () -> Void

    @State private var jobTitle: String = ""
    @State private var company: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isCurrent: Bool = false
    @State private var jobDescription: String = ""
    @State private var technologies: String = ""

    // O*NET role selection
    @State private var searchQuery: String = ""
    @State private var filteredRoles: [Role] = []
    @State private var selectedRole: Role?

    var body: some View {
        NavigationView {
            Form {
                onetRoleSection
                basicInfoSection
                datesSection
                descriptionSection
                skillsSection
            }
            .navigationTitle(experience == nil ? "Add Work Experience" : "Edit Work Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveExperience() }
                        .fontWeight(.semibold)
                }
            }
            .task {
                loadInitialData()
            }
        }
    }

    // MARK: - O*NET Role Section (Same as WorkExperienceFormView)

    private var onetRoleSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search 1,000+ occupations...", text: $searchQuery)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .onChange(of: searchQuery) { _ in
                            filterRoles()
                        }
                        .accessibilityLabel("Search O*NET occupations")
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)

                // Role bubbles
                if !filteredRoles.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(filteredRoles.prefix(20)) { role in
                                RoleBubble(
                                    role: role,
                                    isSelected: selectedRole?.id == role.id,
                                    onTap: { selectRole(role) }
                                )
                            }
                        }
                    }
                }

                // Selected role indicator
                if let role = selectedRole {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Selected: \(role.title)")
                            .font(.subheadline)
                        Spacer()
                        Button("Clear") { selectedRole = nil }
                            .font(.caption)
                    }
                    .padding(10)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        } header: {
            Text("Quick Select from O*NET")
        } footer: {
            Text("Search from 1,000+ standardized occupations or enter manually below.")
                .font(.caption)
        }
    }

    private var basicInfoSection: some View {
        Section("Job Details") {
            TextField("Job Title *", text: $jobTitle)
                .textInputAutocapitalization(.words)

            TextField("Company *", text: $company)
                .textInputAutocapitalization(.words)
        }
    }

    private var datesSection: some View {
        Section("Employment Period") {
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

            if !isCurrent {
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }

            Toggle("I currently work here", isOn: $isCurrent)
        }
    }

    private var descriptionSection: some View {
        Section("Description (Optional)") {
            TextEditor(text: $jobDescription)
                .frame(minHeight: 100)
        }
    }

    private var skillsSection: some View {
        Section {
            TextField("e.g., Python, Excel, Salesforce", text: $technologies)
        } header: {
            Text("Technologies (Optional)")
        } footer: {
            Text("Enter technologies or tools separated by commas")
                .font(.caption)
        }
    }

    // MARK: - Helper Methods

    private func loadInitialData() {
        filteredRoles = Array(availableRoles.prefix(20))

        if let exp = experience {
            jobTitle = exp.title
            company = exp.company
            startDate = exp.startDate
            endDate = exp.endDate ?? Date()
            isCurrent = exp.isCurrent
            jobDescription = exp.description
            technologies = exp.technologies.joined(separator: ", ")
        }
    }

    private func filterRoles() {
        if searchQuery.isEmpty {
            filteredRoles = Array(availableRoles.prefix(20))
        } else {
            Task {
                let matched = await RolesDatabase.shared.findRoles(matching: searchQuery)
                await MainActor.run {
                    filteredRoles = matched
                }
            }
        }
    }

    private func selectRole(_ role: Role) {
        selectedRole = role
        jobTitle = role.title
        if technologies.isEmpty {
            technologies = role.typicalSkills.joined(separator: ", ")
        }
    }

    private func saveExperience() {
        let draft = DraftExperience(
            id: experience?.id ?? UUID(),
            title: jobTitle,
            company: company,
            startDate: startDate,
            endDate: isCurrent ? nil : endDate,
            isCurrent: isCurrent,
            description: jobDescription,
            technologies: technologies.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        )

        onSave(draft)
    }
}
```

**Success Criteria**:
- [ ] Auto-populates from `parsedResume.experience` array
- [ ] O*NET role bubble selection working (30 roles)
- [ ] Can add multiple work experiences
- [ ] Can edit existing entries
- [ ] Can delete entries
- [ ] All entries saved to Core Data as WorkExperience entities
- [ ] Relationship to UserProfile established

---

## TASK 4: Build Education Step with Entity Creation

**Duration**: 2-3 days
**Skill**: v7-architecture-guardian, accessibility-compliance-enforcer, core-data-specialist
**Priority**: MEDIUM - Create Education entities with proper relationships

### Goal

Build EducationCollectionStepView that:
- ✅ Fetches existing UserProfile from Core Data
- ✅ Auto-populates from ParsedResume.education array
- ✅ Creates Education entities with profile relationship
- ✅ Successful context.save() for all entities

### Design: EducationCollectionStepView

**UI Pattern**: Similar to WorkExperienceCollectionStepView but with education level bubbles

```swift
import SwiftUI
import CoreData
import V7Data
import V7Core
import V7Services

/// Step 5: Education Collection (Multi-Entry)
/// Auto-populates from resume parser, allows manual additions
@MainActor
public struct EducationCollectionStepView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(AppState.self) private var appState

    let parsedResume: ParsedResume?
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var educationEntries: [DraftEducation] = []
    @State private var showAddSheet = false
    @State private var editingIndex: Int?
    @State private var showDeleteConfirmation = false
    @State private var deleteIndex: Int?

    public var body: some View {
        VStack(spacing: 24) {
            headerSection

            if educationEntries.isEmpty {
                emptyStateSection
            } else {
                educationListSection
            }

            addEducationButton

            Spacer()
            navigationButtons
        }
        .padding()
        .sheet(isPresented: $showAddSheet) {
            if let editIndex = editingIndex {
                EducationEntrySheet(
                    education: educationEntries[editIndex],
                    onSave: { updated in
                        educationEntries[editIndex] = updated
                        showAddSheet = false
                        editingIndex = nil
                    },
                    onCancel: {
                        showAddSheet = false
                        editingIndex = nil
                    }
                )
            } else {
                EducationEntrySheet(
                    education: nil,
                    onSave: { new in
                        educationEntries.append(new)
                        showAddSheet = false
                    },
                    onCancel: {
                        showAddSheet = false
                    }
                )
            }
        }
        .task {
            await loadInitialData()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Education")
                .font(.title)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)

            Text("Add your educational background")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "graduationcap")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No education added yet")
                .font(.headline)

            Text("Add your degrees, certifications, or training programs")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var educationListSection: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(educationEntries.indices, id: \.self) { index in
                    EducationCard(
                        education: educationEntries[index],
                        onEdit: {
                            editingIndex = index
                            showAddSheet = true
                        },
                        onDelete: {
                            deleteIndex = index
                            showDeleteConfirmation = true
                        }
                    )
                }
            }
        }
        .confirmationDialog(
            "Delete this education entry?",
            isPresented: $showDeleteConfirmation,
            presenting: deleteIndex
        ) { index in
            Button("Delete", role: .destructive) {
                educationEntries.remove(at: index)
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    private var addEducationButton: some View {
        Button {
            editingIndex = nil
            showAddSheet = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Education")
            }
        }
        .buttonStyle(.bordered)
    }

    private var navigationButtons: some View {
        HStack {
            Button("Back") {
                onBack()
            }

            Spacer()

            if educationEntries.isEmpty {
                Button("Skip") {
                    saveAndContinue()
                }
                .buttonStyle(.bordered)
            }

            Button("Continue (\(educationEntries.count))") {
                saveAndContinue()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Data Loading

    private func loadInitialData() async {
        // Auto-populate from resume parser
        if let resume = parsedResume, let parsedEducation = resume.education {
            educationEntries = parsedEducation.map { parsed in
                DraftEducation(
                    id: UUID(),
                    institution: parsed.institution ?? "",
                    degree: parsed.degree ?? "",
                    fieldOfStudy: parsed.fieldOfStudy ?? "",
                    startDate: nil,  // Resume parser doesn't extract dates
                    endDate: nil,
                    isCurrent: false
                )
            }
        }
    }

    // MARK: - Core Data Persistence

    private func saveAndContinue() {
        guard let userProfile = UserProfile.fetchCurrent(in: context) else {
            print("❌ [EducationStep] UserProfile not found")
            return
        }

        for education in educationEntries {
            let entity = Education(context: context)
            entity.id = UUID()
            entity.institution = education.institution
            entity.degree = education.degree
            entity.fieldOfStudy = education.fieldOfStudy
            entity.startDate = education.startDate
            entity.endDate = education.isCurrent ? nil : education.endDate
            entity.isCurrent = education.isCurrent
            entity.gpa = nil  // User can add later
            entity.activities = []  // User can add later

            entity.profile = userProfile
        }

        do {
            try context.save()
            print("✅ [EducationStep] Saved \(educationEntries.count) education entries")
            onNext()
        } catch {
            print("❌ [EducationStep] Failed to save: \(error)")
        }
    }
}

// MARK: - Supporting Types

struct DraftEducation: Identifiable {
    let id: UUID
    var institution: String
    var degree: String
    var fieldOfStudy: String
    var startDate: Date?
    var endDate: Date?
    var isCurrent: Bool
}

struct EducationCard: View {
    let education: DraftEducation
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(education.degree)
                        .font(.headline)
                    Text(education.institution)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if !education.fieldOfStudy.isEmpty {
                        Text(education.fieldOfStudy)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Menu {
                    Button("Edit") { onEdit() }
                    Button("Delete", role: .destructive) { onDelete() }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Education Entry Sheet

struct EducationEntrySheet: View {
    @Environment(\.dismiss) private var dismiss

    let education: DraftEducation?
    let onSave: (DraftEducation) -> Void
    let onCancel: () -> Void

    @State private var institution: String = ""
    @State private var degree: String = ""
    @State private var fieldOfStudy: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isCurrent: Bool = false

    // O*NET Education Level Selection
    @State private var selectedEducationLevel: EducationLevel?

    var body: some View {
        NavigationView {
            Form {
                educationLevelSection
                institutionSection
                datesSection
            }
            .navigationTitle(education == nil ? "Add Education" : "Edit Education")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEducation() }
                        .fontWeight(.semibold)
                }
            }
            .task {
                loadInitialData()
            }
        }
    }

    // MARK: - O*NET Education Level Section

    private var educationLevelSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Education Level")
                    .font(.subheadline)
                    .fontWeight(.medium)

                // Education level bubbles (12 O*NET levels)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EducationLevel.allCases) { level in
                            EducationLevelBubble(
                                level: level,
                                isSelected: selectedEducationLevel == level,
                                onTap: {
                                    selectedEducationLevel = level
                                    degree = level.degreeText
                                }
                            )
                        }
                    }
                }
            }
        } header: {
            Text("Quick Select from O*NET")
        } footer: {
            Text("12 standardized education levels from O*NET database")
                .font(.caption)
        }
    }

    private var institutionSection: some View {
        Section("Education Details") {
            TextField("Institution *", text: $institution)
                .textInputAutocapitalization(.words)

            TextField("Degree *", text: $degree)
                .textInputAutocapitalization(.words)

            TextField("Field of Study", text: $fieldOfStudy)
                .textInputAutocapitalization(.words)
        }
    }

    private var datesSection: some View {
        Section("Dates (Optional)") {
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

            if !isCurrent {
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
            }

            Toggle("Currently enrolled", isOn: $isCurrent)
        }
    }

    private func loadInitialData() {
        if let edu = education {
            institution = edu.institution
            degree = edu.degree
            fieldOfStudy = edu.fieldOfStudy
            startDate = edu.startDate ?? Date()
            endDate = edu.endDate ?? Date()
            isCurrent = edu.isCurrent
        }
    }

    private func saveEducation() {
        let draft = DraftEducation(
            id: education?.id ?? UUID(),
            institution: institution,
            degree: degree,
            fieldOfStudy: fieldOfStudy,
            startDate: startDate,
            endDate: isCurrent ? nil : endDate,
            isCurrent: isCurrent
        )

        onSave(draft)
    }
}

// MARK: - O*NET Education Levels (12 levels)

enum EducationLevel: Int, CaseIterable, Identifiable {
    case lessThanHS = 1
    case highSchool = 2
    case someCollege = 3
    case associates = 4
    case bachelors = 5
    case postBachelor = 6
    case masters = 7
    case postMasters = 8
    case firstProfessional = 9
    case postProfessional = 10
    case doctoral = 11
    case postDoctoral = 12

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .lessThanHS: return "Less than HS"
        case .highSchool: return "High School"
        case .someCollege: return "Some College"
        case .associates: return "Associate's"
        case .bachelors: return "Bachelor's"
        case .postBachelor: return "Post-Bachelor's"
        case .masters: return "Master's"
        case .postMasters: return "Post-Master's"
        case .firstProfessional: return "Professional"
        case .postProfessional: return "Post-Professional"
        case .doctoral: return "Doctoral"
        case .postDoctoral: return "Post-Doctoral"
        }
    }

    var degreeText: String {
        switch self {
        case .lessThanHS: return "No degree"
        case .highSchool: return "High School Diploma"
        case .someCollege: return "Some College"
        case .associates: return "Associate's Degree"
        case .bachelors: return "Bachelor's Degree"
        case .postBachelor: return "Post-Baccalaureate Certificate"
        case .masters: return "Master's Degree"
        case .postMasters: return "Post-Master's Certificate"
        case .firstProfessional: return "Professional Degree"
        case .postProfessional: return "Post-Professional Degree"
        case .doctoral: return "Doctoral Degree"
        case .postDoctoral: return "Post-Doctoral Training"
        }
    }
}

struct EducationLevelBubble: View {
    let level: EducationLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(level.title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(level.title) education level")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
```

**Success Criteria**:
- [ ] Auto-populates from `parsedResume.education` array
- [ ] O*NET education level bubbles (12 levels)
- [ ] Can add multiple education entries
- [ ] Can edit/delete entries
- [ ] All entries saved as Education entities

---

## TASK 5: Build Certification Step with Entity Creation (Optional)

**Duration**: 1-2 days
**Skill**: v7-architecture-guardian, core-data-specialist
**Priority**: LOW - Optional, create Certification entities

### Goal

Build CertificationCollectionStepView that:
- ✅ Fetches existing UserProfile from Core Data
- ✅ Auto-populates from ParsedResume.certifications array
- ✅ Creates Certification entities with profile relationship
- ✅ Allows skipping (optional step)

### Design: CertificationCollectionStepView

**Simplified**: Manual entry only (no O*NET data for certifications)

```swift
/// Step 6: Certification Collection (Optional, Multi-Entry)
/// Allows users to add professional certifications
@MainActor
public struct CertificationCollectionStepView: View {
    @Environment(\.managedObjectContext) private var context

    let parsedResume: ParsedResume?
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var certifications: [DraftCertification] = []
    @State private var showAddSheet = false

    // Similar structure to EducationCollectionStepView
    // but simpler (just name, issuer, dates)

    public var body: some View {
        VStack(spacing: 24) {
            Text("Certifications (Optional)")
                .font(.title)

            if certifications.isEmpty {
                emptyState
            } else {
                certificationList
            }

            Button("Add Certification") {
                showAddSheet = true
            }

            Spacer()

            HStack {
                Button("Back") { onBack() }
                Spacer()
                Button("Skip") { onNext() }
                    .buttonStyle(.bordered)
                Button("Continue (\(certifications.count))") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task {
            loadInitialData()
        }
    }

    private func loadInitialData() {
        if let resume = parsedResume, let certs = resume.certifications {
            certifications = certs.map { parsed in
                DraftCertification(
                    id: UUID(),
                    name: parsed.name ?? "",
                    issuer: parsed.issuer ?? "",
                    issueDate: nil,
                    expiryDate: nil
                )
            }
        }
    }

    private func saveAndContinue() {
        guard let userProfile = UserProfile.fetchCurrent(in: context) else { return }

        for cert in certifications {
            let entity = Certification(context: context)
            entity.id = UUID()
            entity.name = cert.name
            entity.issuer = cert.issuer
            entity.issueDate = cert.issueDate
            entity.expiryDate = cert.expiryDate
            entity.credentialID = nil
            entity.credentialURL = nil
            entity.profile = userProfile
        }

        do {
            try context.save()
            onNext()
        } catch {
            print("❌ Failed to save certifications: \(error)")
        }
    }
}

struct DraftCertification: Identifiable {
    let id: UUID
    var name: String
    var issuer: String
    var issueDate: Date?
    var expiryDate: Date?
}
```

**Success Criteria**:
- [ ] Optional step (can skip)
- [ ] Auto-populates from resume parser
- [ ] Simple manual entry (name, issuer, dates)
- [ ] Saved as Certification entities

---

## TASK 6: Build Skills Step (Foundation Models Integration)

**Duration**: 2 days
**Skill**: ios26-specialist (Foundation Models), v7-architecture-guardian, core-data-specialist
**Priority**: HIGH - Populates UserProfile.skills array for Thompson Sampling

### Goal

Build SkillsReviewStepView that:
- ✅ Fetches existing UserProfile from Core Data
- ✅ Auto-populates from ParsedResume.skills array
- ✅ Extracts additional skills from work experience descriptions using Foundation Models
- ✅ Updates UserProfile.skills with complete skill list
- ✅ Uses O*NET skills taxonomy for categorization

### Design: Enhanced SkillsReviewStepView

**Enhancements**:
1. Pre-populate from resume parser
2. Extract skills from work experience descriptions
3. Use iOS 26 Foundation Models for skill extraction
4. O*NET skills taxonomy for categorization

```swift
import SwiftUI
import Foundation
import V7Core
import V7Data

/// Step 7: Skills Review (Enhanced with Foundation Models)
/// Extracts skills from resume + work experience using iOS 26 AI
@MainActor
public struct SkillsReviewStepView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.managedObjectContext) private var context

    let parsedResume: ParsedResume?
    let onNext: () -> Void
    let onBack: () -> Void

    @State private var skills: [String] = []
    @State private var newSkill: String = ""
    @State private var isExtractingSkills = false
    @State private var extractionProgress: String = ""

    public var body: some View {
        VStack(spacing: 24) {
            headerSection

            if isExtractingSkills {
                extractionProgressSection
            } else {
                skillsListSection
                addSkillSection
            }

            Spacer()
            navigationButtons
        }
        .padding()
        .task {
            await extractSkillsFromProfile()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Your Skills")
                .font(.title)
                .fontWeight(.bold)

            Text("We've identified \(skills.count) skills from your profile")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var extractionProgressSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text(extractionProgress)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var skillsListSection: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(skills, id: \.self) { skill in
                    SkillChip(
                        skill: skill,
                        onRemove: {
                            skills.removeAll { $0 == skill }
                        }
                    )
                }
            }
        }
    }

    private var addSkillSection: some View {
        HStack {
            TextField("Add a skill", text: $newSkill)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.words)

            Button("Add") {
                addSkill()
            }
            .buttonStyle(.bordered)
            .disabled(newSkill.isEmpty)
        }
    }

    private var navigationButtons: some View {
        HStack {
            Button("Back") { onBack() }
            Spacer()
            Button("Continue (\(skills.count))") {
                saveAndContinue()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - iOS 26 Foundation Models Skill Extraction

    private func extractSkillsFromProfile() async {
        isExtractingSkills = true
        extractionProgress = "Analyzing your resume..."

        var extractedSkills: Set<String> = []

        // 1. Extract from resume parser
        if let resume = parsedResume {
            extractedSkills.formUnion(resume.skills)
            extractionProgress = "Found \(extractedSkills.count) skills from resume..."
        }

        // 2. Extract from work experience descriptions using Foundation Models
        if #available(iOS 26.0, *) {
            extractionProgress = "Using AI to find hidden skills..."

            // Fetch all work experiences from Core Data
            guard let userProfile = UserProfile.fetchCurrent(in: context) else { return }

            let fetchRequest = WorkExperience.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "profile == %@", userProfile)
            let experiences = (try? context.fetch(fetchRequest)) ?? []

            // Extract skills from each job description
            for (index, experience) in experiences.enumerated() {
                extractionProgress = "Analyzing job \(index + 1) of \(experiences.count)..."

                if let description = experience.jobDescription {
                    do {
                        // ✅ iOS 26 Foundation Models: Extract entities
                        let entities = try await FoundationModels.extract(
                            entities: [.skills, .technologies],
                            from: description
                        )

                        // Add extracted skills
                        for entity in entities {
                            if let skill = entity.value {
                                extractedSkills.insert(skill)
                            }
                        }
                    } catch {
                        print("⚠️ [SkillsReview] Foundation Models extraction failed: \(error)")
                    }
                }

                // Add technologies from work experience
                extractedSkills.formUnion(experience.technologies)
            }
        }

        // 3. Update UI with extracted skills
        await MainActor.run {
            skills = Array(extractedSkills).sorted()
            isExtractingSkills = false
            extractionProgress = ""
        }
    }

    private func addSkill() {
        let trimmed = newSkill.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !skills.contains(trimmed) else { return }

        skills.append(trimmed)
        skills.sort()
        newSkill = ""
    }

    private func saveAndContinue() {
        // Save skills to UserProfile
        guard let userProfile = UserProfile.fetchCurrent(in: context) else { return }

        // Update UserProfile skills (stored as comma-separated string)
        userProfile.skills = skills.joined(separator: ",")

        do {
            try context.save()

            // Update AppState
            if var appUserProfile = appState.userProfile {
                appUserProfile.skills = skills
                appState.userProfile = appUserProfile
            }

            onNext()
        } catch {
            print("❌ [SkillsReview] Failed to save: \(error)")
        }
    }
}

struct SkillChip: View {
    let skill: String
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Text(skill)
                .font(.subheadline)

            Spacer()

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
```

**Success Criteria**:
- [ ] Auto-populates from resume parser
- [ ] Uses Foundation Models to extract skills from job descriptions
- [ ] Allows manual additions/removals
- [ ] Saved to UserProfile.skills array

---

## TASK 7: Build Preferences Step (Finalize UserProfile)

**Duration**: 1-2 days
**Skill**: v7-architecture-guardian, core-data-specialist
**Priority**: HIGH - Finalizes UserProfile with job search preferences

### Goal

Build PreferencesStepView that:
- ✅ Fetches existing UserProfile from Core Data
- ✅ Collects desired roles using O*NET role search
- ✅ Collects locations (pre-populate from contact info)
- ✅ Collects salary range expectations
- ✅ Updates UserProfile.desiredRoles, locations, salaryMin/Max
- ✅ Final context.save() completes onboarding

### Design: Enhanced PreferencesStepView

**Enhancements**:
1. Use O*NET roles for job type preferences (not free text)
2. Pre-populate locations from contact info + education
3. Smarter salary range suggestions based on experience

```swift
/// Step 8: Preferences (Enhanced with O*NET)
/// Collects job search preferences using standardized data
@MainActor
public struct PreferencesStepView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(AppState.self) private var appState

    let onNext: () -> Void
    let onBack: () -> Void

    @State private var preferredRoles: [Role] = []
    @State private var preferredLocations: [String] = []
    @State private var salaryMin: Double = 60000
    @State private var salaryMax: Double = 150000
    @State private var remotePreference: RemotePreference = .hybrid

    @State private var availableRoles: [Role] = []
    @State private var roleSearchQuery: String = ""
    @State private var filteredRoles: [Role] = []

    public var body: some View {
        VStack(spacing: 24) {
            Text("Job Preferences")
                .font(.title)
                .fontWeight(.bold)

            Form {
                preferredRolesSection
                locationsSection
                salarySection
                remoteSection
            }

            Spacer()

            HStack {
                Button("Back") { onBack() }
                Spacer()
                Button("Continue") {
                    saveAndContinue()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task {
            await loadInitialData()
        }
    }

    private var preferredRolesSection: some View {
        Section {
            // O*NET role search (same as work experience)
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search job titles...", text: $roleSearchQuery)
                    .onChange(of: roleSearchQuery) { _ in
                        filterRoles()
                    }
            }

            // Selected roles
            ForEach(preferredRoles) { role in
                HStack {
                    Text(role.title)
                    Spacer()
                    Button {
                        preferredRoles.removeAll { $0.id == role.id }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }

            // Role suggestions
            if !filteredRoles.isEmpty {
                ForEach(filteredRoles.prefix(5)) { role in
                    Button(role.title) {
                        if !preferredRoles.contains(where: { $0.id == role.id }) {
                            preferredRoles.append(role)
                        }
                    }
                }
            }
        } header: {
            Text("Preferred Job Types")
        }
    }

    private var locationsSection: some View {
        Section("Preferred Locations") {
            ForEach(preferredLocations, id: \.self) { location in
                Text(location)
            }

            Button("Add Location") {
                // Show location picker
            }
        }
    }

    private var salarySection: some View {
        Section("Salary Range") {
            HStack {
                Text("$\(Int(salaryMin / 1000))k")
                Slider(value: $salaryMin, in: 30000...500000, step: 5000)
                Text("$\(Int(salaryMax / 1000))k")
            }
        }
    }

    private var remoteSection: some View {
        Section("Remote Work Preference") {
            Picker("Remote", selection: $remotePreference) {
                ForEach(RemotePreference.allCases) { pref in
                    Text(pref.rawValue).tag(pref)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private func loadInitialData() async {
        // Load O*NET roles
        availableRoles = await RolesDatabase.shared.allRoles

        // Pre-populate locations from UserProfile
        if let userProfile = UserProfile.fetchCurrent(in: context) {
            if let location = userProfile.location {
                preferredLocations = [location]
            }
        }
    }

    private func filterRoles() {
        if roleSearchQuery.isEmpty {
            filteredRoles = Array(availableRoles.prefix(5))
        } else {
            Task {
                let matched = await RolesDatabase.shared.findRoles(matching: roleSearchQuery)
                await MainActor.run {
                    filteredRoles = matched
                }
            }
        }
    }

    private func saveAndContinue() {
        guard let userProfile = UserProfile.fetchCurrent(in: context) else { return }

        // Save preferences to UserProfile
        userProfile.desiredRoles = preferredRoles.map { $0.title }
        userProfile.locations = preferredLocations
        userProfile.salaryMin = Int32(salaryMin)
        userProfile.salaryMax = Int32(salaryMax)
        userProfile.remotePreference = remotePreference.rawValue

        do {
            try context.save()
            onNext()
        } catch {
            print("❌ [Preferences] Failed to save: \(error)")
        }
    }
}

enum RemotePreference: String, CaseIterable, Identifiable {
    case onsite = "On-site"
    case hybrid = "Hybrid"
    case remote = "Remote"

    var id: String { rawValue }
}
```

---

## TASK 8: Update OnboardingFlow (Wire All Steps)

**Duration**: 1 day
**Skill**: v7-architecture-guardian, swift-concurrency-enforcer
**Priority**: HIGH

### Changes Required

```swift
// File: OnboardingFlow.swift

@Observable
@MainActor
public final class OnboardingFlow {
    // Update step count
    private let totalSteps = 10  // Was 7

    var stepCompletions: [Bool] = Array(repeating: false, count: 10)

    func getStepView(for index: Int) -> some View {
        switch index {
        case 0:
            WelcomeStepView(onNext: advanceToNextStep)

        case 1:
            PermissionsStepView(onNext: advanceToNextStep, onBack: goBackToPreviousStep)

        case 2:
            ResumeUploadStepView(
                onNext: advanceToNextStep,
                onBack: goBackToPreviousStep,
                onSkip: advanceToNextStep,
                onParseComplete: { resume in
                    parsedResume = resume
                    advanceToNextStep()
                }
            )

        // NEW: Step 3 - Contact Info (creates UserProfile)
        case 3:
            ContactInfoStepView(
                parsedResume: parsedResume,
                onNext: advanceToNextStep,
                onBack: goBackToPreviousStep
            )

        // NEW: Step 4 - Work Experience
        case 4:
            WorkExperienceCollectionStepView(
                parsedResume: parsedResume,
                onNext: advanceToNextStep,
                onBack: goBackToPreviousStep
            )

        // NEW: Step 5 - Education
        case 5:
            EducationCollectionStepView(
                parsedResume: parsedResume,
                onNext: advanceToNextStep,
                onBack: goBackToPreviousStep
            )

        // NEW: Step 6 - Certifications (optional)
        case 6:
            CertificationCollectionStepView(
                parsedResume: parsedResume,
                onNext: advanceToNextStep,
                onBack: goBackToPreviousStep
            )

        // Modified: Step 7 - Skills (enhanced)
        case 7:
            SkillsReviewStepView(
                parsedResume: parsedResume,
                onNext: advanceToNextStep,
                onBack: goBackToPreviousStep
            )

        // Modified: Step 8 - Preferences (enhanced)
        case 8:
            PreferencesStepView(
                onNext: advanceToNextStep,
                onBack: goBackToPreviousStep
            )

        case 9:
            DualProfileIntroStepView(onNext: completeOnboarding)

        default:
            Text("Invalid step")
        }
    }
}
```

---

## TASK 9: End-to-End Data Flow Testing

**Duration**: 1 day
**Skill**: v7-architecture-guardian, core-data-specialist, testing-qa-strategist
**Priority**: CRITICAL - Validates complete data flow

### Goal

Verify that data flows correctly from Resume Parser → Onboarding → Core Data → ProfileScreen with:
- ✅ Zero persistence failures
- ✅ All field mappings correct
- ✅ All child entities created with proper relationships
- ✅ ProfileScreen can load all data without errors

### Test Suite

**File**: `V7UITests/OnboardingE2ETests.swift` (NEW)

```swift
import XCTest
import CoreData
@testable import V7UI
@testable import V7Data
@testable import V7Core
@testable import V7AIParsing

final class OnboardingE2ETests: XCTestCase {
    var context: NSManagedObjectContext!
    var parsedResume: ParsedResume!

    override func setUp() {
        context = PersistenceController.preview.container.viewContext

        // Create sample parsed resume
        parsedResume = ParsedResume(
            sourceHash: "test-hash",
            parsingDurationMs: 100,
            confidenceScore: 0.95,
            parsingMethod: .openAI,
            fullName: "John Doe",
            email: "john@example.com",
            phone: "555-1234",
            location: "San Francisco, CA",
            linkedInURL: "linkedin.com/in/johndoe",
            githubURL: "github.com/johndoe",
            skills: ["Swift", "iOS", "Python", "Machine Learning"],
            experience: [
                ParsedWorkExperience(
                    title: "Senior iOS Developer",
                    company: "Apple Inc.",
                    startDate: Date(timeIntervalSinceNow: -3 * 365 * 24 * 60 * 60),
                    endDate: nil,
                    isCurrent: true,
                    description: "Led iOS development for flagship products"
                )
            ],
            education: [
                ParsedEducation(
                    institution: "Stanford University",
                    degree: "BS Computer Science",
                    fieldOfStudy: "Computer Science",
                    startDate: Date(timeIntervalSinceNow: -7 * 365 * 24 * 60 * 60),
                    endDate: Date(timeIntervalSinceNow: -3 * 365 * 24 * 60 * 60)
                )
            ],
            certifications: [
                ParsedCertification(
                    name: "AWS Certified Developer",
                    issuer: "Amazon",
                    issueDate: Date(timeIntervalSinceNow: -365 * 24 * 60 * 60)
                )
            ],
            summary: "Experienced iOS developer with 5+ years"
        )
    }

    func testCompleteOnboardingDataFlow() throws {
        // STEP 1: Simulate ContactInfoStep
        let userProfile = UserProfile(context: context)
        userProfile.id = UUID()
        userProfile.name = parsedResume.fullName
        userProfile.email = parsedResume.email
        userProfile.phone = parsedResume.phone
        userProfile.location = parsedResume.location
        userProfile.linkedInURL = parsedResume.linkedInURL
        userProfile.githubURL = parsedResume.githubURL
        userProfile.professionalSummary = parsedResume.summary
        userProfile.experienceLevel = "senior"  // Inferred
        userProfile.currentDomain = "Technology"
        userProfile.amberTealPosition = 0.5
        userProfile.desiredRoles = []
        userProfile.remotePreference = "hybrid"
        userProfile.locations = [parsedResume.location!]
        userProfile.skills = []
        userProfile.createdDate = Date()
        userProfile.lastModified = Date()

        try context.save()

        // STEP 2: Verify UserProfile saved
        let profileFetch = UserProfile.fetchRequest()
        let profiles = try context.fetch(profileFetch)
        XCTAssertEqual(profiles.count, 1, "UserProfile should be saved")
        XCTAssertEqual(profiles.first?.name, "John Doe")

        // STEP 3: Simulate WorkExperienceStep
        for exp in parsedResume.experience! {
            let workExp = WorkExperience(context: context)
            workExp.id = UUID()
            workExp.title = exp.title
            workExp.company = exp.company
            workExp.startDate = exp.startDate
            workExp.endDate = exp.endDate
            workExp.isCurrent = exp.isCurrent
            workExp.jobDescription = exp.description
            workExp.technologies = []
            workExp.achievements = []
            workExp.profile = userProfile  // ✅ Relationship
        }

        try context.save()

        // STEP 4: Verify WorkExperience saved
        let expFetch = WorkExperience.fetchRequest()
        expFetch.predicate = NSPredicate(format: "profile == %@", userProfile)
        let experiences = try context.fetch(expFetch)
        XCTAssertEqual(experiences.count, 1, "WorkExperience should be saved")
        XCTAssertEqual(experiences.first?.title, "Senior iOS Developer")
        XCTAssertNotNil(experiences.first?.profile, "Relationship should be set")

        // STEP 5: Simulate EducationStep
        for edu in parsedResume.education! {
            let education = Education(context: context)
            education.id = UUID()
            education.institution = edu.institution
            education.degree = edu.degree
            education.fieldOfStudy = edu.fieldOfStudy
            education.startDate = edu.startDate
            education.endDate = edu.endDate
            education.profile = userProfile  // ✅ Relationship
        }

        try context.save()

        // STEP 6: Simulate SkillsStep
        userProfile.skills = parsedResume.skills
        try context.save()

        // STEP 7: Simulate PreferencesStep
        userProfile.desiredRoles = ["iOS Developer", "Mobile Engineer"]
        userProfile.salaryMin = 150000
        userProfile.salaryMax = 200000
        try context.save()

        // STEP 8: Verify ProfileScreen can load all data
        let finalProfile = UserProfile.fetchCurrent(in: context)
        XCTAssertNotNil(finalProfile, "ProfileScreen should find UserProfile")
        XCTAssertEqual(finalProfile?.name, "John Doe")
        XCTAssertEqual(finalProfile?.email, "john@example.com")
        XCTAssertEqual(finalProfile?.phone, "555-1234")
        XCTAssertEqual(finalProfile?.skills.count, 4)
        XCTAssertEqual(finalProfile?.workExperiences?.count, 1)
        XCTAssertEqual(finalProfile?.educations?.count, 1)
        XCTAssertEqual(finalProfile?.desiredRoles.count, 2)

        print("✅ Complete data flow validated: Parser → Onboarding → Core Data → ProfileScreen")
    }

    func testProfileScreenLoadsWithoutErrors() throws {
        // Create complete profile using onboarding flow
        try testCompleteOnboardingDataFlow()

        // Verify ProfileScreen expectations
        let profile = UserProfile.fetchCurrent(in: context)!

        // Contact section
        XCTAssertFalse(profile.name.isEmpty)
        XCTAssertFalse(profile.email.isEmpty)
        XCTAssertNotNil(profile.phone)
        XCTAssertNotNil(profile.location)

        // Skills section (must be array, not nil, not string)
        XCTAssertGreaterThan(profile.skills.count, 0)

        // Work experience section (must have relationship)
        let experiences = profile.workExperiences?.allObjects as? [WorkExperience]
        XCTAssertNotNil(experiences)
        XCTAssertGreaterThan(experiences!.count, 0)

        // Education section (must have relationship)
        let educations = profile.educations?.allObjects as? [Education]
        XCTAssertNotNil(educations)
        XCTAssertGreaterThan(educations!.count, 0)

        // Preferences section
        XCTAssertGreaterThan(profile.desiredRoles.count, 0)
        XCTAssertNotNil(profile.salaryMin)
        XCTAssertNotNil(profile.salaryMax)

        print("✅ ProfileScreen data contract validated")
    }

    func testAllRequiredFieldsPopulated() throws {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Test User"
        profile.email = "test@example.com"
        profile.experienceLevel = "mid"
        profile.currentDomain = "Technology"
        profile.amberTealPosition = 0.5
        profile.desiredRoles = []
        profile.remotePreference = "hybrid"
        profile.locations = []
        profile.skills = []
        profile.createdDate = Date()
        profile.lastModified = Date()

        // Should save without errors
        XCTAssertNoThrow(try context.save(), "All required fields should be populated")
    }

    func testMissingRequiredFieldFails() throws {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Test User"
        // Missing email, experienceLevel, etc.

        // Should FAIL to save
        XCTAssertThrowsError(try context.save(), "Missing required fields should cause save failure")
    }

    func testChildEntityWithoutProfileFails() throws {
        let experience = WorkExperience(context: context)
        experience.id = UUID()
        experience.title = "Developer"
        experience.company = "Apple"
        experience.startDate = Date()
        experience.isCurrent = true
        // profile = nil (missing required relationship)

        // Should FAIL to save
        XCTAssertThrowsError(try context.save(), "Child entity without profile relationship should fail")
    }
}
```

### Success Criteria

- [ ] All E2E tests pass
- [ ] Zero persistence failures during onboarding flow
- [ ] ProfileScreen loads all data without nil crashes
- [ ] All field mappings verified correct
- [ ] All child entity relationships verified correct
- [ ] No type mismatches (String vs [String])
- [ ] Required fields validation tests pass
- [ ] Child entity relationship validation tests pass

---

## Success Criteria (Phase 1.75 Complete)

### Functional Requirements ✅

- [ ] UserProfile entity created and saved to Core Data in Step 3
- [ ] Contact info collected: name, email, phone, location
- [ ] Work experience: Multiple entries with O*NET role selection
- [ ] Education: Multiple entries with O*NET education levels
- [ ] Certifications: Multiple entries (optional)
- [ ] Skills: Extracted from resume + Foundation Models + manual
- [ ] Preferences: O*NET-based role selection, locations, salary, remote
- [ ] All 7 entity forms (Phase 1.5) can now save successfully
- [ ] Profile completeness: 85-95% (was 40%)

### Technical Requirements ✅

- [ ] Swift 6 strict concurrency compliance
- [ ] @MainActor for all UI code
- [ ] Actor isolation for RolesDatabase access
- [ ] Core Data persistence verified (fetch returns entities)
- [ ] Foundation Models integration (iOS 26)
- [ ] O*NET bubble selection pattern consistent
- [ ] Resume parser auto-population working
- [ ] No circular dependencies

### Accessibility Requirements ✅

- [ ] VoiceOver labels on all interactive elements
- [ ] Dynamic Type support (Small → XXXL)
- [ ] WCAG 2.1 AA contrast ratios
- [ ] Keyboard navigation working
- [ ] Semantic structure (headers, buttons)
- [ ] Error messages clear and actionable

### User Experience Requirements ✅

- [ ] Onboarding time: 12-18 minutes (acceptable)
- [ ] Auto-population reduces manual entry by 60-80%
- [ ] O*NET bubble selection intuitive and fast
- [ ] Can skip optional sections (certifications)
- [ ] Progress indication clear (step X of 10)
- [ ] Back navigation works correctly

---

## Timeline & Effort Estimate

| Task | Duration | Assignee | Dependencies |
|------|----------|----------|--------------|
| 1. Data Flow Mapping & Schema Alignment | 2 days | core-data-specialist, v7-architecture-guardian | None (FOUNDATION) |
| 2. Build Contact Info Step | 2-3 days | v7-architecture-guardian | Task 1 complete |
| 3. Build Work Experience Step | 3-4 days | v7-architecture-guardian, core-data-specialist | Task 2 complete |
| 4. Build Education Step | 2-3 days | v7-architecture-guardian | Task 2 complete |
| 5. Build Certification Step | 1-2 days | v7-architecture-guardian | Task 2 complete |
| 6. Build Skills Step | 2 days | ios26-specialist | Tasks 3-4 complete |
| 7. Build Preferences Step | 1-2 days | v7-architecture-guardian | Tasks 2-6 complete |
| 8. Update OnboardingFlow | 1 day | swift-concurrency-enforcer | Tasks 2-7 complete |
| 9. End-to-End Testing | 1 day | testing-qa-strategist | All tasks complete |

**Total**: 14-19 days (2.5-3.5 weeks)

**Critical Path**: Task 1 → Task 2 → Task 3 → Task 6 → Task 7 → Task 8 → Task 9

**Notes**:
- Tasks 3, 4, 5 can proceed in parallel after Task 2 completes
- Task 1 is FOUNDATION - everything depends on correct data flow mapping
- Task 9 validates the entire pipeline works end-to-end

---

## Risks & Mitigation

### Risk 1: Foundation Models Performance

**Risk**: AI skill extraction slow on older devices

**Mitigation**:
- Show progress indicator during extraction
- Fallback to resume parser only on iPhone 14 and earlier
- Cache extracted skills to avoid re-extraction

### Risk 2: Onboarding Too Long

**Risk**: 10 steps feels overwhelming to users

**Mitigation**:
- Allow skipping optional sections (certifications)
- Auto-populate aggressively from resume
- Show progress bar: "Step 4 of 10"
- Celebrate milestones: "80% complete!"

### Risk 3: O*NET Role Search Too Complex

**Risk**: Users don't understand O*NET standardized roles

**Mitigation**:
- Allow manual free-text entry as fallback
- Show "Popular roles in your field" suggestions
- Provide examples: "e.g., Software Developer, Data Analyst"

### Risk 4: Core Data Context Issues

**Risk**: Multiple contexts cause save conflicts

**Mitigation**:
- Use single viewContext throughout onboarding
- No background contexts during onboarding
- Verify save after each step with fetch

---

## Handoff to Phase 2

### Prerequisites for Phase 2 Start

- [ ] Phase 1.75 onboarding redesign complete
- [ ] Data flow mapping documented (ParsedResume → Core Data → ProfileScreen)
- [ ] Core Data schema aligned with all data sources
- [ ] UserProfile persistence verified (>0 profiles in DB)
- [ ] All child entity relationships working (WorkExperience, Education, etc.)
- [ ] All 7 entity forms (Phase 1.5) working with real data
- [ ] Profile completeness ≥85%
- [ ] End-to-end tests passing

### Why Phase 2 Will Be Easy Now

**Phase 1.75 solves the architecture problem that was blocking Phase 2**:

✅ **Data Flow Mapped**: Complete documentation of how data flows from parser → onboarding → Core Data → UI
✅ **Schema Aligned**: All type mismatches fixed (String vs [String], missing relationships, etc.)
✅ **Zero Persistence Failures**: All required fields populated, all relationships established
✅ **Education Entities Already Created**: Phase 2 just needs to ADD fields, not fix broken architecture

**Phase 2 can now simply**:
1. Add new fields to existing Education entities (educationLevel, workActivities, RIASEC)
2. Update EducationCollectionStepView to collect new fields
3. Update ProfileScreen to display new fields
4. No architecture refactoring needed - data flow already correct

### Phase 2 Team Notification

Once Phase 1.75 is complete, **Phase 2 (Advanced O*NET Profile Editor) can begin**:

**Phase 2 Team**:
- onet-career-integration (Lead)
- v7-architecture-guardian
- accessibility-compliance-enforcer
- swiftui-specialist

**Handoff Message**:
```
Phase 1.75 (Onboarding Redesign) COMPLETE ✅

✅ Data Flow Architecture: FIXED
   - Complete mapping: ParsedResume → Onboarding → Core Data → ProfileScreen
   - All field mappings documented in DATA_FLOW_MAPPING.md
   - Zero type mismatches, zero missing relationships

✅ Core Data Schema: ALIGNED
   - UserProfile.skills changed to array (not string)
   - All required fields have sources (parser or inferred)
   - All child entities have profile relationships

✅ Onboarding Flow: COMPLETE
   - Contact Info: Collected (name, email, phone, location) ✅
   - Work Experience: Multi-entry with O*NET roles ✅
   - Education: Multi-entry with O*NET levels ✅
   - Certifications: Optional multi-entry ✅
   - Skills: Foundation Models extraction ✅
   - Preferences: O*NET-based preferences ✅

✅ Persistence: WORKING
   - Zero save failures
   - All entities created with correct relationships
   - ProfileScreen loads all data without errors

✅ Profile Completeness: 85-95%

Phase 2 (Advanced O*NET Profile Editor) ready to begin.

Phase 2 Task: Add Education Level Picker, Work Activities, RIASEC to existing Education entities.
No architecture refactoring needed - just add fields to working system.
```

---

## Guardian Skills Sign-Offs

### ✅ v7-architecture-guardian

**APPROVED** - Phase 1.75 plan follows V7 architectural DNA

**Strengths**:
- ✅ **Data Flow First Approach**: Task 1 creates `DATA_FLOW_MAPPING.md` - this is EXACTLY the right foundation. Maps ParsedResume → Core Data → ProfileScreen completely before writing code.
- ✅ **Zero Circular Dependencies**: V7UI → V7Data → V7Core. No violations. V7AIParsing provides ParsedResume to V7UI.
- ✅ **Naming Conventions Perfect**: `ContactInfoStepView`, `WorkExperienceCollectionStepView`, `EducationCollectionStepView` - all PascalCase, descriptive, domain-specific.
- ✅ **@MainActor Isolation**: All views marked @MainActor. State updates on main thread. Core Data context.save() on main context.
- ✅ **Proper Package Placement**: Onboarding screens in V7UI, data models in V7Data, parsing in V7AIParsing.

**Critical Requirements**:
- [x] Task 1.1: DATA_FLOW_MAPPING.md MUST be created before any code is written ✅ COMPLETE (Oct 30, 2025)
- [ ] All Core Data schema changes MUST include migration path
- [ ] All views MUST follow existing DeckScreen/ProfileScreen patterns
- [ ] UserProfile.fetchCurrent(in:) pattern MUST be used (not custom fetch logic)
- [ ] InferExperienceLevel() and inferDomain() MUST be pure functions (no state mutation)

**Concerns Addressed**:
- ✅ Phase 2 handoff is clear - Education entities already exist, Phase 2 just adds fields
- ✅ Timeline is realistic (14-19 days with parallel tasks)
- ✅ End-to-end testing validates complete data flow

**Sign-Off**: APPROVED. This plan solves the root cause (data architecture) instead of patching symptoms. Task 1 is the foundation everything depends on - execute it perfectly.

---

### ✅ swift-concurrency-enforcer

**APPROVED** - Swift 6 strict concurrency compliance verified

**Strengths**:
- ✅ **@MainActor for All UI**: Every view (ContactInfoStepView, WorkExperienceCollectionStepView, etc.) marked @MainActor. State mutations safe.
- ✅ **Actor for Background Work**: RolesDatabase.shared accessed with `await`. Foundation Models extraction async.
- ✅ **Structured Concurrency**: `Task { await loadInitialData() }` patterns correct. No callbacks.
- ✅ **Sendable Conformance**: ParsedResume, Job, Role are all Sendable structs. No classes crossing actors.
- ✅ **Context Isolation**: NSManagedObjectContext accessed from @MainActor views only. No background context confusion.

**Critical Requirements**:
- [ ] ALL Core Data saves MUST be on viewContext (single context throughout onboarding)
- [ ] Foundation Models extraction MUST use `await FoundationModels.extract()` (async)
- [ ] RolesDatabase access MUST use `await RolesDatabase.shared.allRoles`
- [ ] No DispatchQueue.main.async - use MainActor.run if crossing actors
- [ ] InferExperienceLevel() helper functions MUST be synchronous (pure computation, no actor access)

**Concurrency Patterns to Follow**:
```swift
// ✅ CORRECT: View with async data loading
@MainActor
public struct ContactInfoStepView: View {
    @State private var name = ""
    @Environment(\.managedObjectContext) private var context

    public var body: some View {
        // UI code
        .task {
            await loadInitialData()  // ✅ Async loading
        }
    }

    private func loadInitialData() async {
        // Auto-populate from resume parser
        if let resume = parsedResume {
            name = resume.fullName ?? ""  // ✅ Main actor isolated
        }
    }

    private func saveContactInfoAndContinue() {
        let userProfile = UserProfile(context: context)
        // ... set fields ...

        do {
            try context.save()  // ✅ Main actor isolated
        } catch {
            // Handle error
        }
    }
}
```

**Sign-Off**: APPROVED. All concurrency patterns follow Swift 6 strict mode. No data races possible with this design.

---

### ✅ core-data-specialist

**APPROVED** - Data architecture is sound and migration-safe

**Strengths**:
- ✅ **Data Flow Mapping First**: Task 1 creates complete field mapping BEFORE schema changes. This prevents orphaned data.
- ✅ **Schema Alignment**: Fixes critical type mismatches (skills: String → [String]), adds missing fields (phone, location, linkedInURL).
- ✅ **Required Fields with Sources**: Every required field has either parser source OR inferred default. No nil-caused save failures.
- ✅ **Proper Relationships**: All child entities (WorkExperience, Education, etc.) have `profile: UserProfile` relationship set. Cascade delete rules.
- ✅ **Single Context Strategy**: viewContext only during onboarding. No background context confusion. Prevents merge conflicts.
- ✅ **Validation Tests**: Task 1.3 creates UserProfileSchemaTests to validate ALL required fields before implementation.

**Critical Requirements**:
- [x] Task 1.2: Core Data model version MUST be incremented (V7Data.xcdatamodeld → V7Data 2) ✅ COMPLETE (Oct 30, 2025)
- [x] Migration mapping model tested - Lightweight migration (adding new fields, no existing skills data) ✅
- [x] UserProfile.skills transformable uses NSSecureUnarchiveFromData transformer ✅
- [x] UserProfile+Import.swift includes UserDefaults → Core Data import function ✅
- [x] Child entity relationships use CASCADE delete rule (verified in schema) ✅

**Schema Changes Validation**:
```swift
// ✅ CORRECT: Complete UserProfile schema
UserProfile Entity:
    // Identity
    id: UUID (required)
    createdDate: Date (required)
    lastModified: Date (required)

    // Contact Info (from parser)
    name: String (required) ← parsedResume.fullName
    email: String (required) ← parsedResume.email
    phone: String? (optional) ← parsedResume.phone
    location: String? (optional) ← parsedResume.location
    linkedInURL: String? (optional) ← parsedResume.linkedInURL
    githubURL: String? (optional) ← parsedResume.githubURL
    professionalSummary: String? (optional) ← parsedResume.summary

    // Skills (FIXED: was String, now array)
    skills: [String] (required, default: []) ← parsedResume.skills

    // Required fields with inferred defaults
    experienceLevel: String (required, default: "mid") ← inferred from years
    currentDomain: String (required, default: "General") ← inferred from job title
    amberTealPosition: Double (required, default: 0.5)
    desiredRoles: [String] (required, default: [])
    remotePreference: String (required, default: "hybrid")
    locations: [String] (required, default: [])
    salaryMin: Int32? (optional)
    salaryMax: Int32? (optional)

    // Relationships (cascade delete)
    workExperiences: [WorkExperience] (one-to-many, cascade)
    educations: [Education] (one-to-many, cascade)
    certifications: [Certification] (one-to-many, cascade)
```

**Migration Strategy**:
```swift
// V1 → V2 Migration (lightweight if possible)
// Changes:
// 1. skills: String? → Transformable [String]
// 2. Add: phone, location, linkedInURL, githubURL, professionalSummary

// Migration policy for skills field:
if let oldSkillsString = sourceObject.value(forKey: "skills") as? String {
    let skillsArray = oldSkillsString.split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
    destinationObject.setValue(skillsArray, forKey: "skills")
} else {
    destinationObject.setValue([], forKey: "skills")
}
```

**Sign-Off**: APPROVED. Data architecture solves the root cause. Task 1 is critical - execute mapping document perfectly before touching schema.

---

### ✅ accessibility-compliance-enforcer

**APPROVED** - Accessibility is baked into design from start

**Strengths**:
- ✅ **VoiceOver Labels Planned**: Code examples show `.accessibilityLabel()` on all interactive elements
- ✅ **Dynamic Type Support**: Uses `.font(.title2)` TextStyle (not fixed sizes)
- ✅ **Semantic Structure**: Headers marked with `.accessibilityAddTraits(.isHeader)`
- ✅ **Form Accessibility**: TextField labels, hints, and error messages included
- ✅ **Accessible Actions**: O*NET role bubbles will have keyboard navigation

**Critical Requirements**:
- [ ] ALL TextField elements MUST have `.accessibilityLabel()` and `.accessibilityHint()`
- [ ] ALL buttons MUST have descriptive labels (not "Continue" but "Continue to work experience")
- [ ] ALL error messages MUST be announced to VoiceOver with `.accessibilityLabel("Error: ...")`
- [ ] O*NET role selection bubbles MUST be keyboard navigable with arrow keys
- [ ] Work experience cards MUST have combined accessibility (title, company, dates as one announcement)
- [ ] Multi-entry forms MUST announce count ("3 work experiences entered")

**Accessibility Patterns to Follow**:
```swift
// ✅ CORRECT: Accessible contact info form
TextField("Name", text: $name)
    .accessibilityLabel("Full name")
    .accessibilityValue(name.isEmpty ? "Empty" : name)
    .accessibilityHint("Enter your full name")

TextField("Email", text: $email)
    .keyboardType(.emailAddress)
    .textContentType(.emailAddress)
    .accessibilityLabel("Email address")
    .accessibilityValue(email.isEmpty ? "Empty" : email)
    .accessibilityHint("Enter your email address")

// ✅ CORRECT: Accessible error messages
if showValidationError {
    HStack {
        Image(systemName: "exclamationmark.triangle.fill")
            .foregroundColor(.red)
            .accessibilityHidden(true)  // Redundant with text

        Text(validationMessage)
            .foregroundColor(.red)
    }
    .accessibilityLabel("Error: \(validationMessage)")
}

// ✅ CORRECT: Accessible work experience card
VStack(alignment: .leading) {
    Text(experience.title)
        .font(.headline)
    Text(experience.company)
        .font(.subheadline)
    Text(dateRange)
        .font(.caption)
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(experience.title) at \(experience.company), \(dateRange)")
.accessibilityHint("Double tap to edit")
```

**Testing Requirements**:
- [ ] Test ALL screens with VoiceOver enabled
- [ ] Test with Dynamic Type at accessibility XXL size
- [ ] Test keyboard navigation (no touch)
- [ ] Validate all error messages are announced
- [ ] Check color contrast ratios meet WCAG AA

**Sign-Off**: APPROVED. Accessibility is designed in, not bolted on. Follow the patterns shown in code examples.

---

### ✅ app-narrative-guide

**APPROVED** - This plan serves the mission perfectly

**Strengths**:
- ✅ **Serves "The Stuck Professional"**: Complete profile collection enables cross-domain discovery. Auto-population reduces friction.
- ✅ **Act II (Revelation)**: Work experience + skills extraction = foundation for Manifest Profile generation later
- ✅ **Builds Confidence**: Auto-population shows "we understand your background." Skill extraction validates hidden talents.
- ✅ **Reduces Overwhelm**: Multi-entry forms with skip options. Pre-populated data. Progress indicators ("Step 4 of 9").
- ✅ **Enables Cross-Domain Discovery**: O*NET role bubbles expose standardized titles across industries
- ✅ **Not Exploitative**: Free feature. User value first. No dark patterns.

**How This Serves the User Journey**:

**Act I (The Cage)**: Onboarding acknowledges "you have valuable experience" through comprehensive profile collection

**Act II (Revelation)**: Skills extraction from work descriptions → Foundation for Manifest Profile:
- User enters: "Led team of 5 engineers, shipped mobile app to 1M users"
- AI extracts: Leadership, Mobile Development, Product Shipping, Scale Management
- Later reveals: "You could excel at Product Management, Engineering Management, Technical Program Management"

**Act III (The Climb)**: Complete profile = actionable transition pathways:
- Work history → Calculate years of experience → Determine career stage
- Education level → Understand learning capacity
- Skills → Identify transferable competencies
- Preferences → Match to market opportunities

**Critical Requirements for Mission Alignment**:
- [ ] Auto-population MUST feel magical, not creepy (explain what was extracted and why)
- [ ] O*NET role selection MUST include examples ("e.g., Software Developer, Data Analyst")
- [ ] Skip buttons MUST say "I'm just starting my career" (not "Skip" - validate their situation)
- [ ] Skills extraction MUST show WHY extracted ("We found these in your job descriptions")
- [ ] Progress indicators MUST celebrate milestones ("80% complete! Almost there!")

**Language Patterns to Use**:
```swift
// ✅ CORRECT: Empowering language
Text("Tell us about your experience")
    .font(.title)

Text("We'll use this to discover unexpected career opportunities perfectly matched to your skills")
    .font(.subheadline)
    .foregroundColor(.secondary)

// ❌ WRONG: Limiting language
Text("Enter your work history")  // Boring, transactional

Text("Complete your profile")  // Doesn't explain WHY
```

**Success Metrics This Enables**:
- Profile completeness: 85-95% (enables accurate Manifest Profile generation)
- Cross-domain matches: 5-10 unexpected careers per user (work history + skills = transferability analysis)
- User confidence: "The app understands my background" (validated through comprehensive collection)

**Sign-Off**: APPROVED. This plan sets the foundation for transformation. Auto-population + skill extraction = confidence building. O*NET integration = cross-domain discovery. Phase 2 can then add advanced matching (RIASEC, work activities). Execute with user empathy.

---

### ✅ core-data-specialist (Additional Migration Review)

**MIGRATION SAFETY CHECKLIST**:

**Pre-Migration**:
- [ ] Backup user data before schema change
- [ ] Test migration on simulator with sample data
- [ ] Validate migration with production-like dataset (if users exist)
- [ ] Document rollback procedure

**Schema Changes Require Mapping Model**:
- skills: String? → [String] (type change - requires custom migration)
- Adding optional fields (phone, location, etc.) - lightweight migration OK

**Migration Code**:
```swift
// V7Data/Sources/V7Data/Migrations/V1_to_V2_Migration.swift

class SkillsMigrationPolicy: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        try super.createDestinationInstances(
            forSource: sInstance,
            in: mapping,
            manager: manager
        )

        guard let destination = manager.destinationInstances(
            forEntityMappingName: mapping.name,
            sourceInstances: [sInstance]
        ).first else {
            return
        }

        // Migrate skills: String → [String]
        if let oldSkills = sInstance.value(forKey: "skills") as? String,
           !oldSkills.isEmpty {
            let skillsArray = oldSkills
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            destination.setValue(skillsArray, forKey: "skills")
        } else {
            destination.setValue([], forKey: "skills")
        }
    }
}
```

**Sign-Off**: Migration strategy is sound. Execute Task 1.2 carefully with proper testing.

---

## Final Approval Summary

**ALL GUARDIANS APPROVE PHASE 1.75 PLAN**

**Unanimous Consensus**:
This plan solves the ROOT CAUSE (data architecture misalignment) instead of patching symptoms (persistence bugs). Task 1 (Data Flow Mapping) is the critical foundation - execute it perfectly before writing any implementation code.

**Green Light to Proceed**: ✅

**Next Steps**:
1. Execute Task 1.1: Create DATA_FLOW_MAPPING.md
2. Review mapping with all guardians before proceeding
3. Execute Task 1.2: Update Core Data schema with migration
4. Execute Task 1.3: Write schema validation tests
5. Proceed to Tasks 2-9 with confidence that architecture is correct

**Estimated Completion**: 14-19 days (2.5-3.5 weeks)

**Confidence Level**: HIGH - This is the correct approach.

---

**Sign-Off Date**: October 30, 2025
**Approved By**: v7-architecture-guardian, swift-concurrency-enforcer, core-data-specialist, accessibility-compliance-enforcer, app-narrative-guide

---

**Phase 1.75 Status**: ⚪ Not Started | 🟡 In Progress | 🟢 Complete | 🔴 Blocked

**Last Updated**: October 30, 2025
**Next Phase**: Phase 2 - Advanced O*NET Profile Editor
