# Impact Analysis: Core Data Schema Changes for Phase 1.75

**Created**: October 30, 2025
**Scope**: UserProfile.skills String? → Transformable [String] migration
**Risk Level**: 🟡 MODERATE (requires code updates across 18+ files)

---

## Executive Summary

### 🔍 Critical Discovery

**The UserProfile Core Data entity DOES NOT have a `skills` attribute!**

Current Core Data schema (V7DataModel.xcdatamodel/contents lines 5-30):
```xml
<entity name="UserProfile" representedClassName="UserProfile" syncable="YES">
    <attribute name="id" attributeType="UUID"/>
    <attribute name="name" attributeType="String"/>
    <attribute name="email" attributeType="String"/>
    <!-- ... other attributes ... -->
    <!-- ❌ NO SKILLS ATTRIBUTE -->
</entity>
```

**But** the codebase treats skills as if they exist:
- SkillsReviewStepView.swift:774 saves `profile.skills = skillsArray`
- This saves to AppState UserProfile struct (in-memory)
- Skills persist to UserDefaults, NOT Core Data
- **This is why UserProfile persistence is failing**

### Root Cause

**Two Different UserProfile Models**:
1. **AppState.userProfile** (struct) - Has `skills: [String]` property
2. **Core Data UserProfile** (entity) - Does NOT have skills attribute

**Data Flow Disconnect**:
```
Resume Parser → AppState.userProfile.skills → UserDefaults ✅
                                             ↓
                        Core Data UserProfile ❌ (no skills field)
                                             ↓
                        ProfileScreen        ❌ (can't fetch skills)
```

---

## Impact Analysis: Adding Skills to Core Data

### ✅ What We're Actually Doing

**Not a migration - It's an ADDITION**:
- We're adding a NEW `skills` attribute that never existed before
- No String → [String] migration needed (there's no old data to migrate!)
- This is a **lightweight migration** (adding optional field)

**Correct Schema Change**:
```xml
<entity name="UserProfile">
    <!-- Existing attributes -->
    <attribute name="id" attributeType="UUID"/>
    <attribute name="name" attributeType="String"/>
    <attribute name="email" attributeType="String"/>

    <!-- ✅ ADD NEW ATTRIBUTE -->
    <attribute name="skills"
               attributeType="Transformable"
               valueTransformerName="NSSecureUnarchiveFromData"
               optional="YES"
               defaultValueString="[]"/>
</entity>
```

### 📊 Files Affected (18 files found)

#### 1. **SkillsReviewStepView.swift** (CRITICAL)
**Location**: `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/Steps/`
**Current Code** (line 774):
```swift
profile.skills = skillsArray  // Saves to AppState struct
```

**Needs**: Update to save to Core Data
```swift
// After Core Data schema update:
if let coreDataProfile = UserProfile.fetchCurrent(in: context) {
    coreDataProfile.skills = skillsArray
    try context.save()
}
```

**Impact**: 🔴 HIGH - Core onboarding functionality

#### 2. **ProfileScreen / ProfileSettingsView**
**Location**: `ManifestAndMatchV7Feature/Screens/ProfileSubviews/`
**Current**: Fetches skills from AppState
**Needs**: Update to fetch from Core Data

**Impact**: 🔴 HIGH - User-facing profile display

#### 3. **DataExportView.swift**
**Location**: `ManifestAndMatchV7Feature/Settings/Views/`
**Current**: Exports skills from AppState
**Needs**: Update to export from Core Data

**Impact**: 🟡 MEDIUM - Data export functionality

#### 4. **ExplainFitSheet.swift / MLInsightsEngine.swift**
**Location**: `ManifestAndMatchV7Feature/AI/`
**Current**: Uses skills for AI-generated job fit explanations
**Needs**: Update to fetch skills from Core Data

**Impact**: 🟡 MEDIUM - AI features

#### 5. **CoverLetterEngine.swift**
**Location**: `ManifestAndMatchV7Feature/AI/CoverLetter/`
**Current**: Uses skills for cover letter generation
**Needs**: Update skills source to Core Data

**Impact**: 🟡 MEDIUM - Cover letter AI

#### 6. **OnboardingFlow.swift**
**Location**: `ManifestAndMatchV7Feature/Onboarding/`
**Current**: Passes parsedResume.skills through flow
**Needs**: Verify skills persist to Core Data at end

**Impact**: 🔴 HIGH - Onboarding completion

#### 7. **ResumeUploadStepView.swift**
**Location**: `ManifestAndMatchV7Feature/Onboarding/Steps/`
**Current**: Extracts skills from resume
**Needs**: Ensure skills flow to Core Data

**Impact**: 🟡 MEDIUM - Resume parsing

#### 8. **Phase6IntegrationTests.swift**
**Location**: `Tests/Integration/`
**Current**: Tests skills persistence to AppState
**Needs**: Update to test Core Data persistence

**Impact**: 🟢 LOW - Test updates

#### 9. **SkillsPersistenceTest.swift**
**Location**: `Validation_Scripts/`
**Current**: Validates UserDefaults persistence
**Needs**: Update to validate Core Data persistence

**Impact**: 🟢 LOW - Validation script

#### 10. **AccessibilityTests.swift / ExplainFitSheetTests.swift**
**Location**: `ManifestAndMatchV7Package/Tests/ManifestAndMatchV7FeatureTests/`
**Current**: Mock skills data in tests
**Needs**: Update mocks to use Core Data

**Impact**: 🟢 LOW - Test mocks

---

## O*NET Integration Analysis

### How O*NET Works with Skills

**O*NET Skills Database**:
- Location: `Data/ONET_Skills/` (9 files)
- Contains sector-neutral skill categorization
- 14 major industries represented
- MergeSkills.swift integrates O*NET data with V8 skills.json

**Current O*NET Flow**:
```
O*NET Parsers → skills.json (V7Core/Resources/)
                     ↓
         SkillsDatabase.shared.getSkillDetails(name: "Swift")
                     ↓
         Returns: { category: "Technology", keywords: [...] }
                     ↓
         SkillsReviewStepView displays categorized skills
```

**Integration Point with Phase 1.75**:
1. **Resume Parser** extracts raw skills → `ParsedResume.skills: [String]`
2. **O*NET SkillsDatabase** categorizes each skill → Healthcare, Technology, Finance, etc.
3. **SkillsReviewStepView** displays skills grouped by O*NET categories
4. **User** selects/deselects skills
5. **Core Data** (Phase 1.75) will persist final selected skills array
6. **Thompson Sampling** uses skills for job matching via ProfileConverter

**O*NET Impact from Schema Change**: ✅ **ZERO**

- O*NET reads from `skills.json` (unchanged)
- SkillsReviewStepView categorization logic (unchanged)
- Only persistence layer changes (AppState → Core Data)

---

## Migration Strategy (REVISED)

### ❌ Original Plan (INCORRECT)
```
Migrate skills: String? → Transformable [String]
- Write SkillsMigrationPolicy to split comma-separated strings
- Handle edge cases: "Swift, , iOS" → ["Swift", "iOS"]
```

### ✅ Actual Plan (CORRECT)
```
Add NEW skills attribute to Core Data:
- attribute name: "skills"
- type: Transformable
- transformer: NSSecureUnarchiveFromData
- optional: YES
- default: []
```

**Why No Migration Needed**:
- Skills attribute doesn't exist in current Core Data model
- No existing data to migrate
- This is a **lightweight migration** (Core Data handles automatically)
- UserDefaults has skills data → one-time import on first launch

### One-Time Import Strategy

**On app launch after schema update**:
```swift
// V7Data/Sources/V7Data/UserProfile+CoreData.swift

extension UserProfile {
    static func importSkillsFromUserDefaults(context: NSManagedObjectContext) throws {
        // Check if import already done
        if UserDefaults.standard.bool(forKey: "skillsImportedToCoreData") {
            return
        }

        // Get skills from UserDefaults
        guard let savedSkills = UserDefaults.standard.stringArray(forKey: "selectedSkills"),
              !savedSkills.isEmpty else {
            return
        }

        // Get or create UserProfile
        guard let profile = UserProfile.fetchCurrent(in: context) else {
            print("⚠️ No UserProfile found, cannot import skills")
            return
        }

        // Import skills
        profile.skills = savedSkills
        try context.save()

        // Mark import complete
        UserDefaults.standard.set(true, forKey: "skillsImportedToCoreData")

        print("✅ Imported \(savedSkills.count) skills from UserDefaults to Core Data")
    }
}
```

---

## Code Updates Required

### Priority 1: MUST FIX (Before Testing)

**1. Update Core Data Model**
- File: `Packages/V7Data/Sources/V7Data/V7DataModel.xcdatamodeld/V7DataModel.xcdatamodel/contents`
- Add skills attribute to UserProfile entity
- Set transformer to NSSecureUnarchiveFromData

**2. SkillsReviewStepView.swift:saveSkillsToProfile()**
- Line 764-806
- Change from: `appState.userProfile.skills = skillsArray`
- Change to: Save to Core Data UserProfile entity

**3. OnboardingFlow Completion**
- Ensure Core Data save happens at onboarding end
- Verify skills persisted before navigation

**4. Add One-Time Import**
- Create UserProfile+Import.swift extension
- Import UserDefaults skills on first launch after update

### Priority 2: Should Fix (Before Production)

**5. ProfileScreen / ProfileSettingsView**
- Update to fetch skills from Core Data
- Remove AppState dependency for skills

**6. DataExportView**
- Update skills export to use Core Data

**7. AI Features (ExplainFitSheet, CoverLetterEngine, MLInsightsEngine)**
- Update to fetch skills from Core Data

### Priority 3: Can Fix Later (Technical Debt)

**8. Test Files**
- Update mocks to use Core Data
- Update assertions for array type

**9. Validation Scripts**
- Update SkillsPersistenceTest.swift

---

## Testing Checklist

### Schema Update Tests
- [ ] Core Data model compiles without errors
- [ ] App launches without crashing
- [ ] UserDefaults skills import successfully
- [ ] Skills attribute accepts [String] array
- [ ] Skills attribute defaults to empty array []

### Onboarding Flow Tests
- [ ] Resume upload extracts skills
- [ ] SkillsReviewStepView displays O*NET categorized skills
- [ ] User can select/deselect skills
- [ ] Selected skills save to Core Data
- [ ] Skills persist after app restart

### Profile Display Tests
- [ ] ProfileScreen fetches skills from Core Data
- [ ] Skills display as array of chips (not comma string)
- [ ] Empty skills array shows "No skills added"
- [ ] Skills count displayed correctly

### AI Features Tests
- [ ] ExplainFitSheet uses Core Data skills
- [ ] CoverLetterEngine uses Core Data skills
- [ ] MLInsightsEngine uses Core Data skills

### Edge Cases
- [ ] New user (no UserDefaults skills) → []
- [ ] Existing user (UserDefaults skills) → imports to Core Data
- [ ] Import runs only once (flag set)
- [ ] Skills array handles 0 skills
- [ ] Skills array handles 30+ skills

---

## Rollback Strategy

**If migration fails**:
1. Revert Core Data model to previous version
2. Skills remain in UserDefaults (no data loss)
3. App continues using AppState for skills
4. UserProfile persistence still broken (pre-existing issue)

**If issues found post-deployment**:
1. Feature flag: `enableCoreDataSkills = false`
2. Fall back to UserDefaults for skills
3. Fix issues in patch release
4. Re-enable Core Data skills

---

## Risk Assessment

### 🟢 Low Risk Areas
- O*NET integration (unchanged)
- SkillsDatabase categorization (unchanged)
- Resume parsing (unchanged)
- Skills display UI (mostly unchanged)

### 🟡 Medium Risk Areas
- One-time import from UserDefaults
- AI features fetching skills (3 files)
- Data export using new source

### 🔴 High Risk Areas
- SkillsReviewStepView save logic (core persistence change)
- OnboardingFlow completion (must persist to Core Data)
- ProfileScreen fetching (user-facing impact)

### Mitigation Strategies

**For High Risk**:
1. Add comprehensive logging at each step
2. Add validation after Core Data save
3. Add error recovery (fall back to UserDefaults)
4. Add monitoring for save failures

**For Medium Risk**:
1. Add tests for one-time import
2. Add feature flag for Core Data skills
3. Add metrics for import success rate

**For Low Risk**:
1. Standard testing procedures
2. Verify O*NET categorization still works

---

## Success Criteria

### Phase 1.75 Task 1.2 Complete When:

1. ✅ Core Data model updated with skills attribute
2. ✅ SkillsReviewStepView saves to Core Data (not AppState)
3. ✅ One-time import from UserDefaults works
4. ✅ ProfileScreen fetches skills from Core Data
5. ✅ All tests pass (unit + integration)
6. ✅ O*NET categorization still functional
7. ✅ AI features use Core Data skills
8. ✅ Data export uses Core Data skills
9. ✅ App launches without crashes
10. ✅ Skills persist across app restarts

---

## Timeline Estimate (REVISED)

### Original Estimate: 3-4 days (heavyweight migration)
### Revised Estimate: 1-2 days (lightweight addition)

**Day 1**:
- Update Core Data schema (30 min)
- Add one-time import (1 hour)
- Update SkillsReviewStepView (2 hours)
- Update ProfileScreen (1 hour)
- Unit tests (2 hours)

**Day 2**:
- Update AI features (2 hours)
- Update DataExportView (1 hour)
- Integration tests (2 hours)
- End-to-end testing (2 hours)
- Bug fixes (1 hour)

---

## Next Steps

1. **Confirm Approach** with user
2. **Update Core Data schema** (Task 1.2)
3. **Create one-time import** function
4. **Update SkillsReviewStepView** save logic
5. **Test thoroughly** before proceeding to Task 2

---

## Appendix: O*NET Skills Taxonomy

**O*NET provides skills across 14 major sectors**:
1. Business/Management
2. Manufacturing/Production
3. Engineering/Technology
4. Transportation
5. Arts/Humanities
6. Education/Training
7. Health/Science
8. Public Safety/Law
9. Communications
10. Finance/Accounting
11. Healthcare
12. Legal
13. Retail/Sales
14. Food Service/Hospitality

**Integration**:
- SkillsDatabase reads from `V7Core/Resources/skills.json`
- Each skill has: `{ id, name, category, keywords, relatedSkills }`
- SkillsReviewStepView queries: `SkillsDatabase.shared.getSkillDetails(name: "Swift")`
- Returns O*NET category for display grouping

**Phase 1.75 Enhancement**:
- Core Data persistence ensures skills survive app restarts
- Thompson Sampling uses persisted skills for accurate job matching
- ProfileScreen displays complete skill profile from Core Data

---

**Document Status**: ✅ Impact Analysis Complete
**Next Action**: Await user confirmation before proceeding with schema changes
