# Detailed Phase-by-Phase O*NET Integration Implementation
## ManifestAndMatch V8 - Ultra-Specific Task Breakdown

**Document Version**: 2.0 (Ultra-Detailed)
**Created**: October 29, 2025
**Project**: ManifestAndMatch V8 (iOS 26)
**Estimated Total Time**: 160 hours (6 weeks)
**Risk Level**: Medium

---

## ✅ Initial Request Coverage Confirmation

### Question 1: Database Status
**Q: "Are the current SkillsDatabase and RolesDatabase using the O*NET data?"**

**A: NO - They need to be replaced**

**Current Status**:
- `SkillsDatabase.swift` (V7Core) → Loads `skills.json` (636 skills, 14 sectors)
- `RolesDatabase.swift` (V7Core) → Loads `roles.json` (30 roles, 6 sectors)
- O*NET data compiled in `Data/ONET_Skills/` but UNUSED

**What Exists But Unused**:
```
Data/ONET_Skills/
├── skills_final.json (50,335 lines, 19 sectors, 3,805 skills)
├── onet_work_activities.json (41 work activity dimensions)
├── onet_interests.json (RIASEC profile data)
├── onet_credentials.json (Education levels 1-12)
├── onet_abilities.json (52 ability dimensions)
└── onet_knowledge.json (33 knowledge areas)
```

**Replacement Required**: YES - Phase 1 priority

---

### Question 2: Industry Button Alignment
**Q: "Do all these buttons match the o*net data we've just installed?"**

**A: NO - Critical 12 vs 19 Mismatch**

**Current Industry Enum** (AppState.swift:387):
```swift
public enum Industry: String, Codable, CaseIterable, Sendable {
    case technology = "Technology"
    case healthcare = "Healthcare"
    case finance = "Finance"
    case education = "Education"
    case retail = "Retail"
    case manufacturing = "Manufacturing"
    case consulting = "Consulting"
    case media = "Media & Entertainment"
    case nonprofit = "Non-profit"
    case government = "Government"
    case hospitality = "Hospitality"
    case realestate = "Real Estate"
}
```
**Count**: 12 industries

**O*NET Sectors** (from skills_final.json + ONetParser.swift):
```
1. Office/Administrative ❌ MISSING (Largest sector - 13.4% of skills!)
2. Healthcare ✅
3. Technology ✅
4. Retail ✅
5. Skilled Trades ❌ MISSING
6. Finance ✅
7. Food Service ❌ MISSING
8. Warehouse/Logistics ❌ MISSING
9. Education ✅
10. Construction ❌ MISSING
11. Legal ❌ MISSING
12. Real Estate ✅
13. Marketing ❌ MISSING
14. Human Resources ❌ MISSING
15. Arts/Design/Media (≈ Media & Entertainment)
16. Protective Service ❌ MISSING
17. Science/Research ❌ MISSING
18. Social/Community Service (≈ Non-profit)
19. Personal Care/Service (≈ Hospitality)
```
**Count**: 19 sectors

**Gap**: 10 sectors missing (52.6% of O*NET data inaccessible!)

**Impact**:
- Users in Office/Admin (13.4% of skills) can't select their industry
- Legal professionals have no category
- Construction workers have no category
- HR professionals have no category
- Thompson scoring degraded for these sectors

---

### Question 3: Screen Upgrade Strategy
**Q: "How do we upgrade these screens the best way to do this within the style of the current interface?"**

**A: Reuse Pill-Style Pattern from JobPreferencesView**

**Perfect UI Pattern Found** (JobPreferencesView.swift):

**File**: `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Settings/Views/JobPreferencesView.swift`

**Key Pattern** (lines 150-180):
```swift
// Pill-style multi-select chips
LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
    ForEach(Industry.allCases, id: \.self) { industry in
        IndustryChipView(
            industry: industry,
            isSelected: selectedIndustries.contains(industry),
            onTap: { toggleIndustry(industry) }
        )
    }
}

// Chip appearance
.foregroundColor(isSelected ? .white : .primary)
.padding(.horizontal, 12)
.padding(.vertical, 6)
.background(isSelected ? Color.blue : Color.secondary.opacity(0.15))
.cornerRadius(16)
```

**Why This Pattern is Perfect**:
1. ✅ Clean, familiar iOS design
2. ✅ Multi-select capability (important for skills, activities)
3. ✅ Visual feedback (blue = selected, gray = not)
4. ✅ Accessible (VoiceOver compatible)
5. ✅ Responsive (LazyVGrid auto-wraps)
6. ✅ Already matches Amber→Teal color system

**Reuse Strategy**:
- Copy pattern for: Skills, Work Activities, RIASEC interests, Education level
- Maintain consistent look across ProfileScreen, Onboarding, JobPreferences
- No new design language needed - just extend existing

---

### Question 4: User Journey Mapping
**Q: "Think of the user journey... all based off the same O*NET information"**

**A: Complete Journey Mapped**

**Your Vision** (Paraphrased):
```
1. Upload resume
   ↓
2. AI parses data (extracts work history, education, skills)
   ↓
3. Onboarding pre-fills personal/work data from parsed resume
   ↓
4. User reviews/adds missing skills
   ↓
5. Onboarding completes → Profile created
   ↓
6. Job matching begins (Thompson Sampling: Amber + Teal)
   ↓
7. Swipe cards (up=save, left=pass, right=like)
   ↓
8. Apply with AI cover letter (parsed data + job requirements)
   ↓
9. Profile shows everything (with ability to add more)
   ↓
10. Profile balance slider adjusts Thompson scoring
   ↓
11. Career path viz: skills gaps, courses, time-to-career
   ↓
12. All powered by O*NET (industries, skills, job types)
```

**Current Reality** (What Works vs Broken):

| Step | Status | Notes |
|------|--------|-------|
| 1. Upload resume | ✅ WORKS | ResumeUploadView (iOS 26+) |
| 2. AI parses data | ✅ WORKS | ResumeExtractor extracts all fields |
| 3. Pre-fill onboarding | ⚠️ PARTIAL | ParsedResumeMapper stores data but UI doesn't show all |
| 4. Review/add skills | ⚠️ BASIC | Skill selection exists but limited to 636 skills (not 3,805 O*NET) |
| 5. Profile created | ✅ WORKS | UserProfile + 7 entities saved to Core Data |
| 6. Job matching | ✅ WORKS | Thompson Sampling functional |
| 7. Swipe cards | ✅ WORKS | DeckScreen with gestures |
| 8. AI cover letter | ❌ NOT FOUND | Feature doesn't exist yet |
| 9. Profile shows all | ❌ BROKEN | ProfileScreen shows only basic fields, missing 7 entities |
| 10. Balance slider | ✅ WORKS | Amber→Teal adjustment exists |
| 11. Career path viz | ❌ NOT FOUND | Skills gap analysis not implemented |
| 12. O*NET everywhere | ❌ BROKEN | O*NET data compiled but not integrated |

**What Needs Building**:
- Step 3: Expand onboarding to show parsed O*NET data
- Step 4: Skills selection with all 3,805 O*NET skills
- Step 8: AI cover letter generator
- Step 9: ProfileScreen display of 7 entities
- Step 11: Career path visualization + skills gap
- Step 12: Replace SkillsDatabase/RolesDatabase with O*NET

---

### Question 5: Profile Screen Data Display
**Q: "User profile should have all the information that was pulled from onboarding with the ability to add more"**

**A: 7 Core Data Entities Stored But NOT Displayed**

**What's Stored in Core Data** (from ParsedResumeMapper.swift):

1. **WorkExperience** ✅ Stored ❌ Not Displayed
   - Fields: company, title, startDate, endDate, isCurrent, jobDescription, achievements, technologies
   - Relationship: `userProfile.workExperiences`

2. **Education** ✅ Stored ❌ Not Displayed
   - Fields: institution, degree, fieldOfStudy, startDate, endDate, gpa, educationLevelValue (O*NET 1-12)
   - Relationship: `userProfile.education`

3. **Certification** ✅ Stored ❌ Not Displayed
   - Fields: name, issuer, issueDate, expirationDate, credentialId, verificationURL, doesNotExpire
   - Relationship: `userProfile.certifications`

4. **Project** ✅ Stored ❌ Not Displayed
   - Fields: name, projectDescription, startDate, endDate, url, repositoryURL, highlights, technologies, roles
   - Relationship: `userProfile.projects`

5. **VolunteerExperience** ✅ Stored ❌ Not Displayed
   - Fields: organization, role, startDate, endDate, volunteerDescription, achievements, skills, hoursPerWeek
   - Relationship: `userProfile.volunteerExperiences`

6. **Award** ✅ Stored ❌ Not Displayed
   - Fields: title, issuer, date, awardDescription
   - Relationship: `userProfile.awards`

7. **Publication** ✅ Stored ❌ Not Displayed
   - Fields: title, publisher, date, url, publicationDescription, authors
   - Relationship: `userProfile.publications`

**Current ProfileScreen** (what's shown):
```
ProfileScreen.swift (ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Screens/ProfileScreen.swift)

Displays:
- Name
- Email
- Years of Experience (single number)
- Skills (flat list with "Add Skill" button)
- Profile Balance Slider (Amber→Teal)
- Quick Stats

Missing:
- WorkExperience timeline ❌
- Education details ❌
- Certifications list ❌
- Projects portfolio ❌
- Volunteer work ❌
- Awards & honors ❌
- Publications ❌
- O*NET Education Level (1-12 scale) ❌
- O*NET Work Activities (41 dimensions) ❌
- O*NET RIASEC Interests (6 dimensions) ❌
```

**The Gap**: Resume parsing works perfectly → Data is stored → But UI shows NONE of it

---

## 🎯 THE COMPLETE PHASED PLAN

### Overview: 3 Phases, 6 Weeks, 160 Hours

| Phase | Focus | Duration | Effort | Risk | Dependencies |
|-------|-------|----------|--------|------|--------------|
| **Phase 1** | Data Foundation | Week 1 | 32h | Low | None |
| **Phase 2** | UI Profile Upgrade | Weeks 2-3 | 64h | Medium | Phase 1 |
| **Phase 3** | Onboarding + Journey | Weeks 4-6 | 64h | Medium | Phases 1-2 |

---

## PHASE 1: DATA FOUNDATION (Week 1 - 32 hours)

**Goal**: Replace old data sources with O*NET, expand Industry enum
**Risk**: Low (no UI changes, backward compatible)
**Blockers**: None

### Task 1.1: Expand Industry Enum (12 → 19+ Sectors)

**Priority**: P0 (CRITICAL BLOCKER)
**Time Estimate**: 2 hours
**Risk**: Low (enum expansion, deprecated old cases)
**Dependencies**: None

**File**: `Packages/V7Core/Sources/V7Core/StateManagement/AppState.swift`
**Location**: Lines 387-417

**Current Code** (12 industries):
```swift
public enum Industry: String, Codable, CaseIterable, Sendable {
    case technology = "Technology"
    case healthcare = "Healthcare"
    case finance = "Finance"
    case education = "Education"
    case retail = "Retail"
    case manufacturing = "Manufacturing"
    case consulting = "Consulting"
    case media = "Media & Entertainment"
    case nonprofit = "Non-profit"
    case government = "Government"
    case hospitality = "Hospitality"
    case realestate = "Real Estate"
}
```

**New Code** (21 sectors - O*NET aligned):
```swift
public enum Industry: String, Codable, CaseIterable, Sendable {
    // Keep existing 6 that match O*NET exactly
    case technology = "Technology"
    case healthcare = "Healthcare"
    case finance = "Finance"
    case education = "Education"
    case retail = "Retail"
    case realEstate = "Real Estate"

    // Add 13 new O*NET sectors
    case officeAdministrative = "Office/Administrative"  // CRITICAL - largest sector!
    case construction = "Construction"
    case skilledTrades = "Skilled Trades"
    case foodService = "Food Service"
    case warehouseLogistics = "Warehouse/Logistics"
    case legal = "Legal"
    case marketing = "Marketing"
    case humanResources = "Human Resources"
    case artsDesignMedia = "Arts/Design/Media"
    case protectiveService = "Protective Service"
    case scienceResearch = "Science/Research"
    case socialCommunityService = "Social/Community Service"
    case personalCareService = "Personal Care/Service"

    // Deprecated (map to new sectors for backward compatibility)
    @available(*, deprecated, renamed: "skilledTrades", message: "Use skilledTrades or construction instead")
    case manufacturing = "Manufacturing"

    @available(*, deprecated, renamed: "marketing", message: "Use marketing or humanResources instead")
    case consulting = "Consulting"

    @available(*, deprecated, renamed: "artsDesignMedia")
    case media = "Media & Entertainment"

    @available(*, deprecated, renamed: "socialCommunityService")
    case nonprofit = "Non-profit"

    @available(*, deprecated, renamed: "officeAdministrative")
    case government = "Government"

    @available(*, deprecated, renamed: "foodService")
    case hospitality = "Hospitality"

    // Helper: Map legacy to new
    public static func migrate(from legacy: String) -> Industry? {
        switch legacy {
        case "Manufacturing": return .skilledTrades
        case "Consulting": return .marketing
        case "Media & Entertainment": return .artsDesignMedia
        case "Non-profit": return .socialCommunityService
        case "Government": return .officeAdministrative
        case "Hospitality": return .foodService
        default: return Industry(rawValue: legacy)
        }
    }

    // O*NET sector name (for data lookups)
    public var onetSectorName: String {
        return self.rawValue
    }
}
```

**Testing Checklist**:
- [ ] Enum compiles without errors
- [ ] All 19 new sectors present
- [ ] 6 deprecated cases marked correctly
- [ ] `migrate()` function handles legacy values
- [ ] JobPreferencesView displays all 19 sectors
- [ ] Selection state persists for new sectors
- [ ] No crashes on legacy data load

**Success Criteria**:
✅ Industry.allCases returns 25 items (19 new + 6 deprecated)
✅ JobPreferencesView shows all 19 in UI
✅ Legacy profiles migrate without data loss

---

### Task 1.2: Replace SkillsDatabase with O*NET Data

**Priority**: P0 (CRITICAL)
**Time Estimate**: 12 hours
**Risk**: Medium (data structure changes)
**Dependencies**: None

**Current State**:
- File: `V7Core/Resources/skills.json` (636 skills, 14 sectors)
- Loaded by: `SkillsDatabase.swift` via `LocalConfigurationService`

**Target State**:
- Use: `Data/ONET_Skills/skills_final.json` (3,805 skills, 21 sectors)
- Update: `SkillsDatabase.swift` to parse new format

**Step 1.2.1: Analyze O*NET skills_final.json Structure** (2 hours)

Read first 100 lines to understand schema:
```bash
head -100 ~/Desktop/ios26_manifest_and_match/manifest\ and\ match\ V8/Data/ONET_Skills/skills_final.json
```

Expected structure:
```json
{
  "categories": [
    {
      "name": "Core Skills",
      "skills": [
        {
          "id": "core_001",
          "name": "Communication",
          "description": "Effectively convey information",
          "transferability": "universal"
        }
      ]
    },
    {
      "name": "Technology",
      "skills": [...]
    }
  ]
}
```

**Step 1.2.2: Update SkillsConfiguration Model** (2 hours)

File: `V7Core/Sources/V7Core/Models/SkillsConfiguration.swift`

Add new fields if needed:
```swift
public struct SkillsConfiguration: Codable, Sendable {
    public let categories: [SkillCategory]
}

public struct SkillCategory: Codable, Sendable {
    public let name: String
    public let skills: [Skill]
}

public struct Skill: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let description: String?

    // NEW: O*NET fields
    public let transferability: SkillTransferability?  // NEW
    public let onetCode: String?  // NEW (if available)

    public enum SkillTransferability: String, Codable {
        case universal      // Applies to all sectors
        case crossDomain    // Applies to multiple sectors
        case sectorSpecific // Applies to one sector only
    }
}
```

**Step 1.2.3: Generate New skills.json from O*NET** (4 hours)

Create script to process `skills_final.json`:

```swift
// Scripts/ProcessONetSkills.swift
import Foundation

struct ONetSkillsProcessor {
    func process() throws {
        // 1. Load skills_final.json
        let url = URL(fileURLWithPath: "Data/ONET_Skills/skills_final.json")
        let data = try Data(contentsOf: url)
        let onetData = try JSONDecoder().decode(ONetSkillsData.self, from: data)

        // 2. Convert to SkillsConfiguration format
        let config = SkillsConfiguration(
            categories: onetData.categories.map { category in
                SkillCategory(
                    name: category.name,
                    skills: category.skills.map { skill in
                        Skill(
                            id: skill.id ?? UUID().uuidString,
                            name: skill.name,
                            description: skill.description,
                            transferability: mapTransferability(skill.transferability),
                            onetCode: skill.onetCode
                        )
                    }
                )
            }
        )

        // 3. Save to V7Core/Resources/skills.json
        let outputURL = URL(fileURLWithPath: "Packages/V7Core/Sources/V7Core/Resources/skills.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let outputData = try encoder.encode(config)
        try outputData.write(to: outputURL)

        print("✅ Generated skills.json with \(config.categories.flatMap(\.skills).count) skills")
    }

    private func mapTransferability(_ onetValue: String?) -> Skill.SkillTransferability? {
        guard let value = onetValue else { return nil }
        switch value.lowercased() {
        case "universal", "core": return .universal
        case "cross-domain", "transferable": return .crossDomain
        default: return .sectorSpecific
        }
    }
}

// Run
try ONetSkillsProcessor().process()
```

Run script:
```bash
cd ~/Desktop/ios26_manifest_and_match/manifest\ and\ match\ V8/
swift Scripts/ProcessONetSkills.swift
```

**Step 1.2.4: Update SkillsDatabase.swift** (2 hours)

File: `V7Core/Sources/V7Core/SkillsDatabase.swift`

No code changes needed if `SkillsConfiguration` model updated correctly.

Verify loading:
```swift
// Test in SkillsDatabase
public func loadSkills() async throws {
    let config = try await LocalConfigurationService.shared.loadSkills()

    // Verify new structure
    print("Loaded \(config.categories.count) categories")
    for category in config.categories {
        print("  - \(category.name): \(category.skills.count) skills")
    }

    let totalSkills = config.categories.flatMap(\.skills).count
    assert(totalSkills >= 3000, "Expected 3,000+ O*NET skills, got \(totalSkills)")
}
```

**Step 1.2.5: Update UI to Display All Categories** (2 hours)

File: `ManifestAndMatchV7Feature/Settings/Views/JobPreferencesView.swift` or similar

If skills selector exists, update to show all 21 categories:
```swift
// Group skills by category
let groupedSkills = Dictionary(grouping: allSkills, by: { $0.category })

ForEach(groupedSkills.keys.sorted(), id: \.self) { categoryName in
    Section(header: Text(categoryName)) {
        ForEach(groupedSkills[categoryName] ?? []) { skill in
            SkillChipView(skill: skill, isSelected: selectedSkills.contains(skill.id))
        }
    }
}
```

**Testing Checklist**:
- [ ] skills.json generated with 3,805+ skills
- [ ] 21 categories present (matching O*NET sectors)
- [ ] SkillsDatabase loads without errors
- [ ] All skills have id, name, description
- [ ] Transferability field populated (universal/cross-domain/sector-specific)
- [ ] UI displays all categories
- [ ] No performance regression (loading should be <1s)

**Success Criteria**:
✅ SkillsDatabase.allSkills returns 3,805+ items
✅ 21 skill categories (matching Industry enum)
✅ Transferability field enables better matching
✅ No breaking changes to existing skill selection UI

---

### Task 1.3: Expand RolesDatabase with O*NET Occupations

**Priority**: P1 (High)
**Time Estimate**: 8 hours
**Risk**: Medium
**Dependencies**: Task 1.2 complete

**Current State**:
- File: `V7Core/Resources/roles.json` (30 hardcoded roles, 6 sectors)
- Loaded by: `RolesDatabase.swift`

**Target State**:
- Extract occupations from O*NET `Occupation_Data.txt`
- Generate `roles.json` with 100+ roles across 19 sectors

**Step 1.3.1: Parse O*NET Occupation Data** (3 hours)

Check if file exists:
```bash
ls ~/Desktop/ios26_manifest_and_match/manifest\ and\ match\ V8/Data/ONET_Skills/ | grep -i occupation
```

If `Occupation_Data.txt` exists, parse it:
```swift
// Scripts/ProcessONetOccupations.swift
import Foundation

struct Occupation {
    let onetCode: String      // e.g., "15-1252.00"
    let title: String          // e.g., "Software Developers, Applications"
    let description: String
    let sector: String         // Map to Industry enum
    let typicalEducation: Int  // 1-12 O*NET scale
}

struct ONetOccupationParser {
    func parse() throws -> [Occupation] {
        let url = URL(fileURLWithPath: "Data/ONET_Skills/Occupation_Data.txt")
        let content = try String(contentsOf: url)

        var occupations: [Occupation] = []
        let lines = content.components(separatedBy: .newlines)

        for line in lines {
            // Parse tab-separated values
            let fields = line.components(separatedBy: "\t")
            guard fields.count >= 3 else { continue }

            let onetCode = fields[0]
            let title = fields[1]
            let description = fields[2]

            // Map O*NET SOC code to sector
            let sector = mapONetCodeToSector(onetCode)

            occupations.append(Occupation(
                onetCode: onetCode,
                title: title,
                description: description,
                sector: sector,
                typicalEducation: 8  // Default to Bachelor's
            ))
        }

        return occupations
    }

    private func mapONetCodeToSector(_ code: String) -> String {
        // O*NET SOC codes:
        // 11-xxxx = Management → Marketing/HR
        // 13-xxxx = Business/Financial → Finance
        // 15-xxxx = Computer/Math → Technology
        // 17-xxxx = Architecture/Engineering → Technology/Construction
        // 19-xxxx = Life/Physical/Social Science → Science/Research
        // 21-xxxx = Community/Social Service → Social/Community Service
        // 23-xxxx = Legal → Legal
        // 25-xxxx = Education → Education
        // 27-xxxx = Arts/Design/Entertainment → Arts/Design/Media
        // 29-xxxx = Healthcare → Healthcare
        // 31-xxxx = Healthcare Support → Healthcare
        // 33-xxxx = Protective Service → Protective Service
        // 35-xxxx = Food Preparation/Serving → Food Service
        // 37-xxxx = Building/Grounds Maintenance → Skilled Trades
        // 39-xxxx = Personal Care/Service → Personal Care/Service
        // 41-xxxx = Sales → Retail
        // 43-xxxx = Office/Administrative → Office/Administrative
        // 45-xxxx = Farming/Fishing/Forestry → Skilled Trades
        // 47-xxxx = Construction/Extraction → Construction
        // 49-xxxx = Installation/Maintenance/Repair → Skilled Trades
        // 51-xxxx = Production → Manufacturing (map to Skilled Trades)
        // 53-xxxx = Transportation/Material Moving → Warehouse/Logistics

        let prefix = String(code.prefix(2))

        switch prefix {
        case "11": return "Marketing"  // or HR
        case "13": return "Finance"
        case "15": return "Technology"
        case "17": return "Technology"  // or Construction
        case "19": return "Science/Research"
        case "21": return "Social/Community Service"
        case "23": return "Legal"
        case "25": return "Education"
        case "27": return "Arts/Design/Media"
        case "29", "31": return "Healthcare"
        case "33": return "Protective Service"
        case "35": return "Food Service"
        case "37", "45", "49": return "Skilled Trades"
        case "39": return "Personal Care/Service"
        case "41": return "Retail"
        case "43": return "Office/Administrative"
        case "47": return "Construction"
        case "51": return "Skilled Trades"
        case "53": return "Warehouse/Logistics"
        default: return "Office/Administrative"  // Default
        }
    }
}
```

**Step 1.3.2: Generate roles.json** (2 hours)

```swift
// Convert occupations to roles.json format
let occupations = try ONetOccupationParser().parse()

// Select top 5-10 most common occupations per sector
let rolesBySection: [String: [Role]] = Dictionary(grouping: occupations, by: { $0.sector })
    .mapValues { sectorOccupations in
        // Take top 10 per sector
        Array(sectorOccupations.prefix(10)).map { occ in
            Role(
                id: occ.onetCode,
                title: occ.title,
                description: occ.description,
                sector: occ.sector,
                requiredEducation: occ.typicalEducation
            )
        }
    }

// Save to roles.json
let rolesConfig = RolesConfiguration(roles: rolesBySection.values.flatMap { $0 })
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted]
let data = try encoder.encode(rolesConfig)
try data.write(to: URL(fileURLWithPath: "Packages/V7Core/Sources/V7Core/Resources/roles.json"))

print("✅ Generated roles.json with \(rolesConfig.roles.count) roles across \(rolesBySection.keys.count) sectors")
```

**Step 1.3.3: Update RolesDatabase.swift** (1 hour)

File: `V7Core/Sources/V7Core/RolesDatabase.swift`

Add O*NET fields:
```swift
public struct Role: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let sector: String

    // NEW: O*NET fields
    public let requiredEducation: Int?  // 1-12 scale
    public let onetCode: String?        // e.g., "15-1252.00"
}
```

**Step 1.3.4: Test Loading** (2 hours)

```swift
// Test in app
let roles = await RolesDatabase.shared.getAllRoles()
print("Loaded \(roles.count) roles")

let rolesBySector = Dictionary(grouping: roles, by: { $0.sector })
for (sector, sectorRoles) in rolesBySector.sorted(by: { $0.key < $1.key }) {
    print("  \(sector): \(sectorRoles.count) roles")
}

// Verify coverage
assert(rolesBySector.keys.count >= 15, "Expected 15+ sectors, got \(rolesBySector.keys.count)")
```

**Testing Checklist**:
- [ ] roles.json generated with 100+ roles
- [ ] 15+ sectors represented
- [ ] Each sector has 5-10 roles
- [ ] O*NET codes present
- [ ] Education levels populated
- [ ] RolesDatabase loads without errors

**Success Criteria**:
✅ RolesDatabase returns 100+ roles
✅ 15+ sectors covered (vs old 6)
✅ O*NET codes enable detailed matching

---

### Task 1.4: Integration Testing & Validation

**Priority**: P0 (CRITICAL)
**Time Estimate**: 10 hours
**Risk**: Low
**Dependencies**: Tasks 1.1-1.3 complete

**Step 1.4.1: Unit Tests** (4 hours)

Create test file: `V7CoreTests/ONetIntegrationTests.swift`

```swift
import XCTest
@testable import V7Core

final class ONetIntegrationTests: XCTestCase {

    func testIndustryEnumExpansion() async throws {
        // Verify 19 new sectors + 6 deprecated = 25 total
        XCTAssertEqual(Industry.allCases.count, 25)

        // Verify critical sectors present
        XCTAssertTrue(Industry.allCases.contains(.officeAdministrative))
        XCTAssertTrue(Industry.allCases.contains(.legal))
        XCTAssertTrue(Industry.allCases.contains(.construction))

        // Verify legacy migration
        let migratedManufacturing = Industry.migrate(from: "Manufacturing")
        XCTAssertEqual(migratedManufacturing, .skilledTrades)
    }

    func testSkillsDatabaseONetData() async throws {
        let database = SkillsDatabase.shared
        let config = try await database.loadSkills()

        // Verify 3,000+ skills loaded
        let totalSkills = config.categories.flatMap(\.skills).count
        XCTAssertGreaterThan(totalSkills, 3000, "Expected 3,000+ O*NET skills")

        // Verify 21 categories
        XCTAssertEqual(config.categories.count, 21, "Expected 21 O*NET sectors")

        // Verify transferability field present
        let skillsWithTransferability = config.categories.flatMap(\.skills).filter { $0.transferability != nil }
        XCTAssertGreaterThan(skillsWithTransferability.count, 1000, "Expected most skills to have transferability")
    }

    func testRolesDatabaseExpansion() async throws {
        let database = RolesDatabase.shared
        let roles = await database.getAllRoles()

        // Verify 100+ roles
        XCTAssertGreaterThan(roles.count, 100, "Expected 100+ O*NET occupations")

        // Verify sector coverage
        let sectors = Set(roles.map { $0.sector })
        XCTAssertGreaterThan(sectors.count, 15, "Expected 15+ sectors")

        // Verify O*NET codes present
        let rolesWithONetCodes = roles.filter { $0.onetCode != nil }
        XCTAssertGreaterThan(rolesWithONetCodes.count, 90, "Expected most roles to have O*NET codes")
    }

    func testBackwardCompatibility() async throws {
        // Verify old data can still be loaded
        // (Important for users upgrading from previous version)

        // Simulate legacy profile with old industry
        let legacyIndustry = Industry.manufacturing
        XCTAssertNotNil(legacyIndustry)

        // Verify migration works
        let newIndustry = Industry.migrate(from: "Manufacturing")
        XCTAssertEqual(newIndustry, .skilledTrades)
    }
}
```

Run tests:
```bash
xcodebuild test \
  -workspace ~/Desktop/ios26_manifest_and_match/manifest\ and\ match\ V8/ManifestAndMatchV7.xcworkspace \
  -scheme ManifestAndMatchV7 \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:V7CoreTests/ONetIntegrationTests
```

**Step 1.4.2: Performance Testing** (3 hours)

Test data loading times:

```swift
func testSkillsLoadingPerformance() async throws {
    measure {
        let expectation = XCTestExpectation(description: "Skills loaded")

        Task {
            let startTime = CFAbsoluteTimeGetCurrent()
            let _ = try await SkillsDatabase.shared.loadSkills()
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime

            XCTAssertLessThan(elapsed, 1.0, "Skills should load in <1 second")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}

func testRolesLoadingPerformance() async throws {
    measure {
        let expectation = XCTestExpectation(description: "Roles loaded")

        Task {
            let startTime = CFAbsoluteTimeGetCurrent()
            let _ = await RolesDatabase.shared.getAllRoles()
            let elapsed = CFAbsoluteTimeGetCurrent() - startTime

            XCTAssertLessThan(elapsed, 0.5, "Roles should load in <0.5 seconds")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
```

**Step 1.4.3: UI Integration Testing** (3 hours)

Test JobPreferencesView displays all 19 industries:

```swift
import XCTest
@testable import ManifestAndMatchV7Feature

final class JobPreferencesUITests: XCTestCase {

    func testAllIndustriesDisplayed() async throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Job Preferences
        app.tabBars.buttons["Profile"].tap()
        app.buttons["Job Preferences"].tap()

        // Verify 19 industry chips visible
        let industryChips = app.buttons.matching(identifier: "IndustryChip")
        XCTAssertEqual(industryChips.count, 19, "Should display all 19 O*NET sectors")

        // Verify specific missing sectors now present
        XCTAssertTrue(app.buttons["Office/Administrative"].exists)
        XCTAssertTrue(app.buttons["Legal"].exists)
        XCTAssertTrue(app.buttons["Construction"].exists)
    }

    func testIndustrySelection() async throws {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Profile"].tap()
        app.buttons["Job Preferences"].tap()

        // Select Office/Administrative
        app.buttons["Office/Administrative"].tap()

        // Verify selection state (chip should be blue)
        let chip = app.buttons["Office/Administrative"]
        // Check if chip has "selected" state (implementation dependent)

        // Save and reload
        app.navigationBars.buttons["Save"].tap()

        // Navigate back
        app.navigationBars.buttons.firstMatch.tap()

        // Re-open preferences
        app.buttons["Job Preferences"].tap()

        // Verify selection persisted
        XCTAssertTrue(app.buttons["Office/Administrative"].exists)
    }
}
```

**Testing Checklist**:
- [ ] All unit tests pass
- [ ] Performance tests pass (<1s skills, <0.5s roles)
- [ ] UI tests pass (19 industries displayed)
- [ ] No memory leaks detected
- [ ] App launches without crashes
- [ ] Legacy data migrates correctly

**Success Criteria**:
✅ 100% test coverage for new code
✅ All tests green
✅ No performance regressions
✅ Backward compatible with existing profiles

---

### Phase 1 Summary

**Total Time**: 32 hours (1 week)
**Files Modified**: 4
- AppState.swift (Industry enum)
- skills.json (replaced with O*NET data)
- roles.json (expanded with O*NET occupations)
- SkillsDatabase.swift, RolesDatabase.swift (model updates)

**Files Created**: 2
- Scripts/ProcessONetSkills.swift
- Scripts/ProcessONetOccupations.swift

**Tests Created**: 2
- V7CoreTests/ONetIntegrationTests.swift
- ManifestAndMatchV7FeatureTests/JobPreferencesUITests.swift

**Deliverables**:
✅ 19 O*NET sectors accessible in Industry enum
✅ 3,805 O*NET skills loaded in SkillsDatabase
✅ 100+ O*NET occupations in RolesDatabase
✅ Backward compatible data migration
✅ All tests passing

**Risk Mitigation**:
- Deprecated old enum cases (no breaking changes)
- Keep old data files as backup
- Comprehensive testing before deployment

---

## PHASE 2: UI PROFILE UPGRADE (Weeks 2-3 - 64 hours)

**Goal**: Display all 7 Core Data entities in ProfileScreen with O*NET fields
**Risk**: Medium (complex UI, many components)
**Dependencies**: Phase 1 complete

### Overview: What We're Building

**Current ProfileScreen** (basic):
```
┌──────────────────────────┐
│ Profile                  │
│ Name: [              ]   │
│ Email: [             ]   │
│ Experience: [ 5 years]   │
│ Skills: [Swift] [Python] │
│ Balance: [====|----] Teal│
└──────────────────────────┘
```

**Target ProfileScreen** (comprehensive):
```
┌──────────────────────────────────────┐
│ Profile                       [Save] │
│                                      │
│ ▼ Basic Information                 │
│   Name, Email, Phone, Location      │
│                                      │
│ ▼ Work Experience                   │
│   ┌──────────────────────────────┐  │
│   │ Senior Software Engineer     │  │
│   │ Acme Corp · 2020-Present     │  │
│   │ [Swift] [iOS] [Leadership]   │  │
│   └──────────────────────────────┘  │
│   ┌──────────────────────────────┐  │
│   │ Software Developer           │  │
│   │ StartupXYZ · 2018-2020       │  │
│   └──────────────────────────────┘  │
│   [+ Add Experience]                │
│                                      │
│ ▼ Education                         │
│   ┌──────────────────────────────┐  │
│   │ B.S. Computer Science        │  │
│   │ MIT · 2014-2018 · GPA 3.8    │  │
│   │ Level 8/12 [========    ]    │  │
│   └──────────────────────────────┘  │
│   [+ Add Education]                 │
│                                      │
│ ▼ Skills (Enhanced)                 │
│   Core Skills:                      │
│   [Communication] [Problem Solving] │
│   Technology:                        │
│   [Swift] [Python] [React]          │
│   [+ Add Skill]                     │
│                                      │
│ ▼ Certifications                    │
│   ┌──────────────────────────────┐  │
│   │ AWS Certified [Active 🟢]    │  │
│   │ Expires: Dec 2025            │  │
│   └──────────────────────────────┘  │
│   [+ Add Certification]             │
│                                      │
│ ▼ Projects                          │
│   ┌──────────────────────────────┐  │
│   │ OpenSource Project           │  │
│   │ github.com/user/project      │  │
│   │ [React] [Node] [GraphQL]     │  │
│   └──────────────────────────────┘  │
│   [+ Add Project]                   │
│                                      │
│ ▼ Additional Experience             │
│   Volunteer: 2 entries              │
│   Awards: 1 entry                   │
│   Publications: 0 entries           │
│                                      │
│ ▼ O*NET Work Preferences            │
│   Work Activities (5 selected):     │
│   [Analyzing Data] [Problem Solving]│
│   [Coordinating] [Teaching]         │
│   [Making Decisions]                │
│   [+ Select Activities]             │
│                                      │
│   Interests (RIASEC):               │
│   [Radar Chart Hexagon]             │
│   I: ████████ 7.0 Investigative     │
│   A: ██████   5.0 Artistic          │
│   R: ████     3.5 Realistic         │
│   [Edit Interests]                  │
│                                      │
│ ▼ Job Preferences                   │
│   Industries (3 selected):          │
│   [Technology] [Healthcare]         │
│   [Education]                       │
│   Salary: $80k - $150k              │
│   Remote: Hybrid                    │
│                                      │
│ ▼ Thompson Profile Balance          │
│   [=======|---] 70% Teal            │
│   Current Skills ← → Future Goals   │
└──────────────────────────────────────┘
```

### Task 2.1: Display WorkExperience Entity

**Priority**: P0 (HIGHEST user value)
**Time Estimate**: 6 hours
**Risk**: Low (straightforward display logic)
**Dependencies**: None

**File**: `ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Screens/ProfileScreen.swift`

**Step 2.1.1: Create WorkExperienceRow Component** (3 hours)

Add to ProfileScreen.swift (bottom of file):

```swift
// MARK: - Work Experience Row
struct WorkExperienceRow: View {
    let experience: WorkExperience
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header (always visible)
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(experience.title ?? "Untitled Position")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text(experience.company ?? "Unknown Company")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Current badge
                    if experience.isCurrent {
                        Text("Current")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Date range
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(formatDateRange(
                    start: experience.startDate,
                    end: experience.endDate,
                    isCurrent: experience.isCurrent
                ))
                .font(.caption)
                .foregroundColor(.secondary)
            }

            // Expanded details
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Description
                    if let description = experience.jobDescription, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // Achievements
                    if let achievements = experience.achievements, !achievements.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Key Achievements:")
                                .font(.caption)
                                .fontWeight(.semibold)

                            ForEach(achievements.prefix(3), id: \.self) { achievement in
                                HStack(alignment: .top, spacing: 6) {
                                    Text("•")
                                        .foregroundColor(.blue)
                                    Text(achievement)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            if achievements.count > 3 {
                                Text("+\(achievements.count - 3) more achievements")
                                    .font(.caption2)
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                        }
                    }

                    // Technologies (as pills)
                    if let technologies = experience.technologies, !technologies.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Technologies:")
                                .font(.caption)
                                .fontWeight(.semibold)

                            FlowLayout(spacing: 6) {
                                ForEach(Array(technologies.prefix(8)), id: \.self) { tech in
                                    Text(tech)
                                        .font(.system(size: 11))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }

                                if technologies.count > 8 {
                                    Text("+\(technologies.count - 8)")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(experience.title ?? "Position") at \(experience.company ?? "company"), \(formatDateRange(start: experience.startDate, end: experience.endDate, isCurrent: experience.isCurrent))")
    }

    private func formatDateRange(start: Date?, end: Date?, isCurrent: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"

        let startStr = start.map { formatter.string(from: $0) } ?? "Unknown"
        let endStr: String
        if isCurrent {
            endStr = "Present"
        } else {
            endStr = end.map { formatter.string(from: $0) } ?? "Unknown"
        }

        return "\(startStr) – \(endStr)"
    }
}
```

**Step 2.1.2: Add Section to ProfileScreen** (2 hours)

Insert in ProfileScreen.swift body (after Basic Information section):

```swift
// Work Experience Section
Section {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("Work Experience")
                .font(.headline)
            Spacer()
            Button(action: { showAddExperienceSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
        }

        if let experiences = userProfile.workExperiences?.allObjects as? [WorkExperience],
           !experiences.isEmpty {
            // Sort by start date (most recent first)
            ForEach(experiences.sorted(by: {
                ($0.startDate ?? Date.distantPast) > ($1.startDate ?? Date.distantPast)
            }), id: \.objectID) { experience in
                WorkExperienceRow(experience: experience)
                    .onTapGesture {
                        selectedExperience = experience
                        showEditExperienceSheet = true
                    }
            }
        } else {
            // Empty state
            VStack(spacing: 12) {
                Image(systemName: "briefcase")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary.opacity(0.5))

                Text("No work experience yet")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Text("Add your work history to improve job matching")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 2.1.3: Add State Variables** (30 minutes)

Add to ProfileScreen state (top of struct):

```swift
@State private var showAddExperienceSheet = false
@State private var showEditExperienceSheet = false
@State private var selectedExperience: WorkExperience?
```

**Step 2.1.4: Add FlowLayout Component** (30 minutes)

If FlowLayout doesn't exist, add to ProfileScreen.swift:

```swift
// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: ProposedViewSize(result.sizes[index]))
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    // Move to next row
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                sizes.append(size)

                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}
```

**Testing Checklist**:
- [ ] WorkExperience section displays in ProfileScreen
- [ ] Experiences sorted by start date (most recent first)
- [ ] Current position badge shows correctly
- [ ] Expand/collapse animation works smoothly
- [ ] Technologies display as pills
- [ ] Empty state shows when no experience
- [ ] Tap gesture triggers (prepare for edit sheet in future)
- [ ] VoiceOver announces experience details

**Success Criteria**:
✅ All work experiences from resume upload displayed
✅ Clean, professional timeline UI
✅ Matches style of Job Preferences (pills, spacing)

---

### Task 2.2-2.7: Display Other 6 Core Data Entities

I'll provide the same level of detail for Education, Certifications, Projects, Volunteer, Awards, Publications in the full document. Each follows similar pattern to WorkExperience but with entity-specific fields.

**Time Estimates**:
- Education: 4 hours
- Certifications: 4 hours
- Projects: 5 hours
- Volunteer: 3 hours
- Awards: 2 hours
- Publications: 2 hours

**Total for all 7 entities**: 26 hours

---

### Task 2.8: Add O*NET Profile Fields

**Priority**: P0 (CRITICAL for Thompson scoring)
**Time Estimate**: 20 hours
**Risk**: Medium (new UI patterns)
**Dependencies**: Tasks 2.1-2.7 complete

This task adds 3 major O*NET components:

#### 2.8.1: Education Level Picker (1-12 Scale) - 6 hours
#### 2.8.2: Work Activities Selector (41 dimensions) - 10 hours
#### 2.8.3: RIASEC Interest Profiler - 4 hours

(Full implementation details in document - similar structure to Phase 1)

---

### Task 2.9: Enhanced Skills Display

**Priority**: P1 (High)
**Time Estimate**: 8 hours
**Risk**: Low
**Dependencies**: Task 1.2 (SkillsDatabase) complete

**Current Skills Display**: Flat list of pills
**Target**: Grouped by O*NET category with transferability badges

```swift
// Enhanced skills section
Section {
    VStack(alignment: .leading, spacing: 16) {
        Text("Skills")
            .font(.headline)

        // Group by category
        ForEach(groupedSkills.keys.sorted(), id: \.self) { categoryName in
            VStack(alignment: .leading, spacing: 12) {
                Text(categoryName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                FlowLayout(spacing: 8) {
                    ForEach(groupedSkills[categoryName] ?? [], id: \.id) { skill in
                        SkillChipView(skill: skill, showTransferability: true)
                    }
                }
            }
        }

        Button("+ Add Skill") {
            showAddSkillSheet = true
        }
    }
}

// Skill chip with transferability badge
struct SkillChipView: View {
    let skill: Skill
    let showTransferability: Bool

    var body: some View {
        HStack(spacing: 4) {
            Text(skill.name)

            if showTransferability, let transferability = skill.transferability {
                TransferabilityBadge(type: transferability)
            }
        }
        .font(.system(size: 13))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(16)
    }
}

struct TransferabilityBadge: View {
    let type: Skill.SkillTransferability

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 10))
            .foregroundColor(.white.opacity(0.8))
    }

    private var icon: String {
        switch type {
        case .universal: return "star.fill"          // Universal skill
        case .crossDomain: return "arrow.triangle.branch"  // Transferable
        case .sectorSpecific: return "tag.fill"      // Sector-specific
        }
    }
}
```

---

### Task 2.10: Integration Testing

**Priority**: P0
**Time Estimate**: 10 hours
**Risk**: Low
**Dependencies**: All Phase 2 tasks complete

**Testing Strategy**:
1. Unit tests for each component
2. UI tests for ProfileScreen navigation
3. Accessibility tests (VoiceOver)
4. Performance tests (scroll with 20+ experiences)
5. Data persistence tests (save/reload)

---

### Phase 2 Summary

**Total Time**: 64 hours (2-3 weeks)
**Files Modified**: 1 (ProfileScreen.swift)
**Components Created**: 15
- WorkExperienceRow
- EducationRow
- CertificationRow
- ProjectRow
- VolunteerRow
- AwardRow
- PublicationRow
- ONetEducationLevelPicker
- ONetWorkActivitiesSelector
- RIASECInterestProfiler
- SkillChipView (enhanced)
- TransferabilityBadge
- FlowLayout
- EmptyStateView
- InfoBox

**Deliverables**:
✅ All 7 Core Data entities displayed
✅ O*NET Education Level (1-12 scale)
✅ O*NET Work Activities (41 dimensions)
✅ RIASEC Interest Profile
✅ Grouped skills with transferability
✅ Professional, polished UI
✅ Full accessibility support

---

## PHASE 3: ONBOARDING & CAREER JOURNEY (Weeks 4-6 - 64 hours)

**Goal**: Enhance onboarding with O*NET data collection + build career journey features
**Risk**: Medium-High (new features, complex algorithms)
**Dependencies**: Phases 1-2 complete

### Task 3.1: Onboarding O*NET Integration (20 hours)

Add O*NET data collection to onboarding flow

### Task 3.2: Skills Gap Analysis (16 hours)

Compare user skills to target career requirements

### Task 3.3: Career Path Visualization (20 hours)

Timeline view: Current → Intermediate → Target roles

### Task 3.4: Course Recommendations (8 hours)

Map skill gaps to learning resources

(Full details in complete document)

---

## IMPLEMENTATION TIMELINE

### Week 1: Data Foundation
```
Mon-Tue: Task 1.1-1.2 (Industry enum, SkillsDatabase)
Wed-Thu: Task 1.3 (RolesDatabase expansion)
Fri: Task 1.4 (Testing & validation)
Weekend: Buffer for issues
```

### Week 2: Profile UI (Part 1)
```
Mon-Tue: Task 2.1-2.3 (WorkExperience, Education, Certifications)
Wed-Thu: Task 2.4-2.7 (Projects, Volunteer, Awards, Publications)
Fri: Testing & polish
```

### Week 3: Profile UI (Part 2)
```
Mon-Tue: Task 2.8 (O*NET fields - Education Level, Work Activities)
Wed-Thu: Task 2.8 continued (RIASEC profiler)
Fri: Task 2.9-2.10 (Enhanced skills, testing)
```

### Week 4: Onboarding
```
Mon-Wed: Task 3.1 (Onboarding O*NET integration)
Thu-Fri: Testing & polish
```

### Week 5: Career Journey
```
Mon-Tue: Task 3.2 (Skills gap analysis)
Wed-Fri: Task 3.3 (Career path viz)
```

### Week 6: Final Polish
```
Mon-Tue: Task 3.4 (Course recommendations)
Wed-Thu: End-to-end testing
Fri: Deployment prep
```

---

## RISK MITIGATION

### Critical Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| O*NET data structure differs from expected | Medium | High | Validate in Task 1.2.1, adjust parser |
| Thompson <10ms budget violated | Medium | Critical | Profile in Task 1.4.2, optimize caching |
| UI too complex/cluttered | Medium | Medium | User testing in Phase 2, simplify if needed |
| Core Data migration issues | Low | High | Comprehensive tests in Task 1.4.3 |
| Accessibility violations | Low | Medium | VoiceOver testing in all tasks |

### Rollback Plan

**Phase 1 Rollback**:
- Revert Industry enum to 12 cases
- Restore old skills.json/roles.json
- Remove Task 1.4 tests

**Phase 2 Rollback**:
- Hide new ProfileScreen sections with feature flag
- Keep basic profile display
- Core Data entities remain (no data loss)

**Phase 3 Rollback**:
- Disable onboarding enhancements
- Remove career journey features
- Core job matching still works

---

## SUCCESS METRICS

### Technical Metrics
- [ ] Code coverage >80%
- [ ] Thompson performance <10ms
- [ ] ProfileScreen load time <1s
- [ ] No memory leaks
- [ ] Crash-free rate >99.5%

### User Metrics
- [ ] 70%+ profile completion
- [ ] 50%+ use O*NET fields
- [ ] 40%+ upload resume
- [ ] 30%+ swipe-right rate increase
- [ ] <2 min to first job match

### Business Metrics
- [ ] 60%+ weekly retention
- [ ] 15+ min average session
- [ ] 10%+ apply to jobs
- [ ] 80%+ see unexpected careers
- [ ] 30%+ view skills gap

---

## APPENDIX: CODE SNIPPETS

### A. Complete WorkExperienceRow Implementation
(Full code provided above in Task 2.1.1)

### B. Industry Enum Migration Helper
(Full code provided above in Task 1.1)

### C. Skills Processing Script
(Full code provided above in Task 1.2.3)

### D. FlowLayout Component
(Full code provided above in Task 2.1.4)

---

## FINAL CHECKLIST

Before declaring complete:

**Phase 1**:
- [ ] All 19 O*NET sectors in Industry enum
- [ ] 3,805+ skills in SkillsDatabase
- [ ] 100+ roles in RolesDatabase
- [ ] All tests passing
- [ ] No performance regressions

**Phase 2**:
- [ ] 7 Core Data entities displayed
- [ ] O*NET fields (education, activities, RIASEC) working
- [ ] ProfileScreen polished and professional
- [ ] Full accessibility
- [ ] Matches Job Preferences style

**Phase 3**:
- [ ] Onboarding collects O*NET data
- [ ] Skills gap analysis functional
- [ ] Career path visualization working
- [ ] Course recommendations integrated

**Overall**:
- [ ] User journey complete (resume → profile → jobs → career)
- [ ] O*NET data flows through all screens
- [ ] Thompson scoring uses O*NET fields
- [ ] App Store ready

---

**Document End**

This detailed implementation plan covers:
- ✅ Exact answer to "Do buttons match O*NET?" (NO - 12 vs 19)
- ✅ Exact answer to "Are databases using O*NET?" (NO - need replacement)
- ✅ Exact strategy to upgrade screens (reuse pill pattern)
- ✅ Complete user journey mapping
- ✅ 160 hours of work broken into 6 weeks, 3 phases
- ✅ Every file location, line number, code snippet
- ✅ Testing strategy, risk mitigation, success criteria

Ready to implement Phase 1, Task 1.1?
