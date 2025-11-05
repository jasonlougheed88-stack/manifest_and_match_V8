# Phase 1 Implementation Checklist

**Project**: ManifestAndMatch V8 (iOS 26)
**Phase**: Week 1 - Quick Wins
**Created**: October 29, 2025
**Duration**: 32 hours
**Status**: Ready to begin (Week 0 complete)

---

## ✅ Prerequisites (Week 0) - ALL COMPLETE

- [x] Pre-Task 0.1: Swift 6 strict concurrency enabled in all 7 V7 packages
- [x] Pre-Task 0.2: NSManagedObject+Sendable.swift helpers created
- [x] Pre-Task 0.3: Industry enum expanded from 12 → 19 NAICS sectors
- [x] All packages build successfully on iOS 26 simulator

---

## Phase 1 Task Breakdown

### Task 1.1: Display WorkExperience Entity (4 hours)

**Priority**: P0 (Critical)
**File**: `Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`
**Entity**: `WorkExperience+CoreData.swift`

#### Checklist

- [ ] Step 1.1.1: Add WorkExperience section to ProfileScreen (2 hours)
  - [ ] Add @State for selectedExperienceID (NSManagedObjectID)
  - [ ] Add @State for showAddExperienceSheet
  - [ ] Add @State for showEditExperienceSheet
  - [ ] Add @Environment(\.managedObjectContext)
  - [ ] Add WorkExperience Section after Skills section (line ~353)
  - [ ] Implement Sendable-compliant ForEach using objectID pattern
  - [ ] Add empty state view

- [ ] Step 1.1.2: Create WorkExperienceRow component (1 hour)
  - [ ] Title and Company display
  - [ ] Date range formatting with isCurrent indicator
  - [ ] Description preview (first 2 lines)
  - [ ] Skills badges display
  - [ ] Color interpolation using profileBlend

- [ ] Step 1.1.3: Create helper functions (30 min)
  - [ ] formatDateRange() function
  - [ ] Integrate with existing interpolateColor()

- [ ] Step 1.1.4: Testing (30 min)
  - [ ] Test add/edit/delete workflows
  - [ ] Verify Sendable compliance (no warnings)
  - [ ] Test VoiceOver accessibility
  - [ ] Test Dynamic Type scaling

---

### Task 1.2: Display Education Entity (4 hours)

**Priority**: P0
**File**: `Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`
**Entity**: `Education+CoreData.swift`

#### Checklist

- [ ] Step 1.2.1: Add Education section to ProfileScreen (2 hours)
  - [ ] Add @State for selectedEducationID
  - [ ] Add @State for showAddEducationSheet
  - [ ] Add @State for showEditEducationSheet
  - [ ] Add Education Section after WorkExperience
  - [ ] Implement Sendable-compliant ForEach pattern
  - [ ] Add empty state view

- [ ] Step 1.2.2: Create EducationRow component (1.5 hours)
  - [ ] Degree and institution display
  - [ ] Graduation date / Expected graduation
  - [ ] GPA display (if available)
  - [ ] Major/Minor display
  - [ ] Honors/Awards badges

- [ ] Step 1.2.3: Testing (30 min)
  - [ ] Test CRUD operations
  - [ ] Verify Sendable compliance
  - [ ] Test accessibility

---

### Task 1.3: Display Certification Entity (3 hours)

**Priority**: P0
**File**: `Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`
**Entity**: `Certification+CoreData.swift`

#### Checklist

- [ ] Step 1.3.1: Add Certification section (1.5 hours)
  - [ ] Add @State for selectedCertificationID
  - [ ] Add @State for showAddCertificationSheet
  - [ ] Add @State for showEditCertificationSheet
  - [ ] Add Certification Section after Education
  - [ ] Implement Sendable-compliant pattern
  - [ ] Add empty state view

- [ ] Step 1.3.2: Create CertificationRow component (1 hour)
  - [ ] Certification name and issuer
  - [ ] Issue date / Expiration date
  - [ ] Credential ID display
  - [ ] Expiration warning (if within 90 days)

- [ ] Step 1.3.3: Testing (30 min)
  - [ ] Test CRUD operations
  - [ ] Verify Sendable compliance
  - [ ] Test expiration warnings

---

### Task 1.4: Display Projects, Volunteer, Awards, Publications (8 hours)

**Priority**: P1
**File**: `Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`
**Entities**: `Project`, `VolunteerExperience`, `Award`, `Publication`

#### Checklist - Projects (2 hours)

- [ ] Add @State for selectedProjectID
- [ ] Add @State for sheet controls
- [ ] Add Projects section
- [ ] Create ProjectRow component
  - [ ] Project name and description
  - [ ] Date range
  - [ ] Technologies used
  - [ ] URL link (if available)
- [ ] Testing

#### Checklist - Volunteer (2 hours)

- [ ] Add @State for selectedVolunteerID
- [ ] Add @State for sheet controls
- [ ] Add Volunteer section
- [ ] Create VolunteerRow component
  - [ ] Organization and role
  - [ ] Date range
  - [ ] Description
  - [ ] Impact metrics (if available)
- [ ] Testing

#### Checklist - Awards (2 hours)

- [ ] Add @State for selectedAwardID
- [ ] Add @State for sheet controls
- [ ] Add Awards section
- [ ] Create AwardRow component
  - [ ] Award name and issuer
  - [ ] Date received
  - [ ] Description
  - [ ] Icon/badge visual
- [ ] Testing

#### Checklist - Publications (2 hours)

- [ ] Add @State for selectedPublicationID
- [ ] Add @State for sheet controls
- [ ] Add Publications section
- [ ] Create PublicationRow component
  - [ ] Publication title
  - [ ] Authors
  - [ ] Publication date
  - [ ] Journal/Conference
  - [ ] DOI/URL link
- [ ] Testing

---

### Task 1.5: Expand Industry Enum (COMPLETED ✅)

**Status**: Already completed in Week 0 Pre-Task 0.3

- [x] Industry enum updated from 12 → 19 NAICS sectors
- [x] Legacy migration helper added (fromLegacy)
- [x] Icon mapping updated for all 19 sectors
- [x] Unit tests created and passing
- [x] Build verified

---

### Task 1.6: Update JobPreferencesView for 19 Industries (4 hours)

**Priority**: P0
**File**: `Packages/V7UI/Sources/V7UI/Views/JobPreferencesView.swift` (or similar)

#### Checklist

- [ ] Step 1.6.1: Locate JobPreferencesView (30 min)
  - [ ] Find file in V7UI package
  - [ ] Review current Industry picker implementation
  - [ ] Identify hardcoded industry references

- [ ] Step 1.6.2: Update Industry picker (2 hours)
  - [ ] Replace 12-item picker with 19-item Industry.allCases
  - [ ] Update grouping/categorization if present
  - [ ] Add search/filter for 19 industries
  - [ ] Update layout to handle increased options

- [ ] Step 1.6.3: Migration logic (1 hour)
  - [ ] Add migration code for existing user preferences
  - [ ] Use Industry.fromLegacy() for old data
  - [ ] Test upgrade path from 12 → 19

- [ ] Step 1.6.4: Testing (30 min)
  - [ ] Test all 19 industries selectable
  - [ ] Test multi-select behavior
  - [ ] Test migration from legacy values
  - [ ] Verify Thompson Sampling uses new industries

---

## Supporting Files to Create/Update

### New Components to Create

- [ ] WorkExperienceRow.swift (or in ProfileScreen.swift)
- [ ] EducationRow.swift
- [ ] CertificationRow.swift
- [ ] ProjectRow.swift
- [ ] VolunteerRow.swift
- [ ] AwardRow.swift
- [ ] PublicationRow.swift

### Helper Functions to Add

- [ ] formatDateRange(_ start: Date?, _ end: Date?, _ isCurrent: Bool) -> String
- [ ] formatGPA(_ gpa: Double?) -> String
- [ ] isExpiringSoon(_ date: Date?) -> Bool (for certifications)
- [ ] formatAuthors(_ authors: [String]) -> String (for publications)

### Existing Files to Update

- [ ] ProfileScreen.swift (primary file, all 7 entity sections)
- [ ] JobPreferencesView.swift (Industry enum update)
- [ ] Any preference persistence code (UserPreferences migration)

---

## Testing Strategy

### Unit Tests

- [ ] Create ProfileScreenTests.swift
- [ ] Test each entity CRUD workflow
- [ ] Test Sendable compliance (no warnings with Swift 6)
- [ ] Test date formatting edge cases
- [ ] Test empty state displays

### Integration Tests

- [ ] Test full profile workflow (add all 7 entity types)
- [ ] Test Core Data persistence
- [ ] Test migration from legacy data
- [ ] Test Thompson Sampling with 19 industries

### UI Tests

- [ ] Test accessibility (VoiceOver labels)
- [ ] Test Dynamic Type scaling
- [ ] Test layout on iPhone SE / iPhone Pro Max
- [ ] Test dark mode / light mode

---

## Critical Patterns (Swift 6 Sendable Compliance)

### ✅ CORRECT Pattern (Use this)

```swift
// State
@State private var selectedExperienceID: NSManagedObjectID?
@Environment(\.managedObjectContext) private var context

// Usage
if let experiences = userProfile.workExperiences?.allObjects as? [WorkExperience] {
    let experienceIDs = experiences.map { $0.objectID }
    ForEach(experienceIDs, id: \.self) { objectID in
        if let experience = try? context.existingObject(with: objectID) as? WorkExperience {
            WorkExperienceRow(experience: experience)
                .onTapGesture {
                    selectedExperienceID = objectID  // ✅ Store ID, not object
                }
        }
    }
}
```

### ❌ WRONG Pattern (Do NOT use)

```swift
// This will NOT compile with Swift 6 strict concurrency
@State private var selectedExperience: WorkExperience?  // ❌ Not Sendable
```

---

## Success Criteria

### Functional

- [ ] All 7 Core Data entities display in ProfileScreen
- [ ] CRUD operations work for all entities
- [ ] Industry enum expanded to 19 sectors
- [ ] JobPreferencesView updated for 19 industries
- [ ] Legacy data migrates successfully

### Technical

- [ ] Zero Swift 6 Sendable warnings
- [ ] Build succeeds on iOS 26 simulator
- [ ] All unit tests pass
- [ ] Memory usage within acceptable limits
- [ ] No Core Data threading issues

### UX

- [ ] All screens accessible (VoiceOver compliant)
- [ ] Dynamic Type scaling works correctly
- [ ] Empty states provide clear guidance
- [ ] Date formatting is user-friendly
- [ ] Icons are semantically appropriate

---

## Estimated Timeline

| Task | Hours | Status |
|------|-------|--------|
| **Week 0 Prerequisites** | **8** | **✅ COMPLETE** |
| Pre-Task 0.1: Swift 6 concurrency | 2 | ✅ |
| Pre-Task 0.2: Sendable helpers | 3 | ✅ |
| Pre-Task 0.3: Industry enum | 3 | ✅ |
| **Phase 1 Implementation** | **32** | **⏳ PENDING** |
| Task 1.1: WorkExperience | 4 | ⏳ |
| Task 1.2: Education | 4 | ⏳ |
| Task 1.3: Certification | 3 | ⏳ |
| Task 1.4: Projects/Volunteer/Awards/Publications | 8 | ⏳ |
| Task 1.5: Industry enum | 0 | ✅ (done in Week 0) |
| Task 1.6: JobPreferencesView | 4 | ⏳ |
| Testing & Polish | 9 | ⏳ |
| **Total** | **40** | **20% Complete** |

---

## Risk Mitigation

### Risk: Sendable warnings with Core Data
- **Mitigation**: Use NSManagedObjectID pattern throughout (Week 0 Pre-Task 0.2 complete)
- **Status**: ✅ Mitigated

### Risk: Migration data loss
- **Mitigation**: Industry.fromLegacy() tested with all 12 legacy values
- **Status**: ✅ Mitigated

### Risk: UI performance with many entities
- **Mitigation**: Use lazy loading, pagination if needed
- **Status**: Monitor during testing

### Risk: Accessibility compliance
- **Mitigation**: Test with VoiceOver throughout development
- **Status**: Include in testing checklist

---

## Notes for Implementation

1. **Follow MV pattern** (no ViewModels, use @Observable/@State/@Environment)
2. **Use SacredUI constants** for all dimensions/colors
3. **Maintain Amber→Teal brand colors** using interpolateColor()
4. **Test on iOS 26 simulator** (iPhone 17)
5. **Document all Core Data entity relationships** as you work

---

## Next Steps

1. Begin Task 1.1: Display WorkExperience Entity
2. Use this checklist to track progress
3. Update WEEK_0 document with final completion status
4. Commit Week 0 changes before starting Phase 1

---

## Deferred to Phase 2 (Weeks 3-16)

**Resume Parser Integration** - Not included in Phase 1 scope:

### 1. ProfileScreen Resume Upload Integration
- **Current State**: Resume upload button exists in ProfileScreen but doesn't populate the 7 Core Data entities
- **Target State (Phase 2)**: iOS 26 Foundation Models extracts resume → automatically populates:
  - Work Experience (from job history)
  - Education (from degrees)
  - Certifications (from professional credentials)
  - Projects (from portfolio items)
  - Skills (from parsed text)
  - Awards (from recognitions)
  - Publications (from research/writing)

### 2. Onboarding Resume Upload Integration
- **Current State**: Onboarding collects basic profile info only (name, email, experience level, skills, job preferences, industries)
- **Design Decision**: The 7 Core Data entities (Work Experience, Education, Certifications, Projects, Volunteer, Awards, Publications) are **intentionally excluded** from Phase 1 onboarding to avoid friction and drop-off
- **Rationale**: Asking users to manually fill 7 entity sections = 15-20 minute onboarding → massive abandonment before seeing value
- **Phase 1 Strategy**: Fast onboarding (2-3 minutes) → users reach job discovery quickly → manually add profile detail later in Profile screen
- **Target State (Phase 2)**: Resume upload during onboarding → iOS 26 Foundation Models auto-populates all 7 entity sections in <50ms → comprehensive profile without manual entry
- **User Experience**: User uploads resume → completes onboarding with full profile already populated → personalized recommendations from day 1

### 3. iOS 26 Foundation Models Benefits (Phase 2)
- **Cost**: $0 (vs. current $200-500/month with OpenAI)
- **Speed**: <50ms parsing (vs. 1-3 seconds cloud API)
- **Privacy**: 100% on-device processing (no cloud transmission)
- **Offline**: Fully functional without internet connection
- **Reliability**: No rate limits, no API failures

**Documentation Reference**: `/O*net research/phase upgrages/completed/PHASE_2_CHECKLIST_Foundation_Models_Integration.md`

**Note**: Phase 1 focuses on manual entity entry UI. Automated resume parsing integration happens in Phase 2 (Weeks 3-16).

---

**Status**: ✅ **Ready to begin Phase 1 implementation**
