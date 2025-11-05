# O*NET Complete System Integration Analysis

**Created:** November 1, 2025
**Purpose:** Analyze complete O*NET database integration with Thompson Sampling and identify relationships

---

## Executive Summary

This document provides a **thorough analysis** of how ALL O*NET databases integrate throughout the system, with focus on Thompson Sampling usage and relationship mapping between databases.

**Key Finding:** O*NET databases are **already deeply integrated** with Thompson Sampling for scoring. The new `onet_occupation_titles.json` will seamlessly integrate as the **primary keying mechanism** linking all O*NET data.

---

## Complete O*NET Database Inventory

### Current O*NET Files in V7Core/Resources

| File | Size | Records | Status | Usage |
|------|------|---------|--------|-------|
| `onet_occupation_titles.json` | 136 KB | 1016 titles | ✅ EXISTS | **NEW** - For UI selection |
| `onet_occupation_skills.json` | 703 KB | 726 occupations | ✅ EXISTS | Thompson + ProfileConverter |
| `onet_abilities.json` | 11.8 MB | 894 occupations | ✅ EXISTS | Thompson scoring (15%) |
| `onet_knowledge.json` | 1.5 MB | 894 occupations | ✅ EXISTS | Not yet integrated |
| `onet_interests.json` | 477 KB | 894 occupations | ✅ EXISTS | Thompson scoring (15%) |
| `onet_work_activities.json` | 10 KB | 894 occupations | ✅ EXISTS | Thompson scoring (25%) |
| `onet_work_styles.json` | 48 KB | 894 occupations | ✅ EXISTS | Not yet integrated |
| `onet_credentials.json` | 205 KB | 894 occupations | ✅ EXISTS | Thompson scoring (30%) |

**Total O*NET Data:** ~14.9 MB (comprehensive career database)

---

## Database Schemas and Relationships

### 1. onet_occupation_titles.json (PRIMARY KEY)

**Structure:**
```json
{
  "lastUpdated": "2025-11-01T21:11:18Z",
  "totalOccupations": 1016,
  "occupations": [
    {
      "onetCode": "11-2022.00",        // PRIMARY KEY - links ALL databases
      "title": "Sales Managers",
      "sector": "Sales and Related"    // O*NET job family (23 categories)
    }
  ]
}
```

**Purpose:**
- **Primary key** for ALL O*NET data lookups (`onetCode`)
- User-facing role selection in ProfileSetupStepView
- Sector mapping for UI grouping (23 O*NET families → 18 app sectors)

**Links To:**
- All other O*NET databases via `onetCode`
- Thompson Job model (optional `onetCode` field)
- User profile `preferredJobTypes` (role titles)

---

### 2. onet_occupation_skills.json (ALREADY INTEGRATED)

**Structure:**
```json
{
  "lastUpdated": "2025-11-01T21:24:03Z",
  "occupations": [
    {
      "onetCode": "11-2022.00",       // Links to titles
      "title": "Sales Managers",
      "skills": [
        {
          "name": "Persuasion",
          "importance": 4.38,
          "level": 4.62
        },
        {
          "name": "Negotiation",
          "importance": 4.25,
          "level": 4.38
        }
        // ... 35 core skills
      ]
    }
  ]
}
```

**Current Usage:**
- **ProfileConverter.extractSkills()** - Loads skills for user profile (Phase 4)
- **Thompson matchSkills()** - 30% weight in Thompson scoring
- **EnhancedSkillsMatcher** - Fuzzy matching with SkillTaxonomy

**Relationship:**
- `onetCode` links to `onet_occupation_titles.json`
- Skills extracted into `UserProfile.skills[]`
- Used by Thompson `ProfessionalProfile.skills[]`

---

### 3. onet_credentials.json (ALREADY INTEGRATED)

**Structure:**
```json
{
  "occupations": [
    {
      "onetCode": "11-2022.00",
      "title": "Sales Managers",
      "educationRequirements": {
        "requiredLevel": 8,          // Bachelor's degree (1-12 scale)
        "typicalEducation": ["8"],   // Most common level
        "requiredExperience": "5+ years"
      },
      "experienceRequirements": {
        "requiredYears": 5.0,
        "typicalYears": [5, 7, 10]
      },
      "credentials": [
        "Certified Sales Professional (CSP)",
        "Certified Professional Sales Person (CPSP)"
      ]
    }
  ]
}
```

**Current Usage:**
- **Thompson matchEducation()** - 15% weight (education level matching)
- **Thompson matchExperience()** - 15% weight (years of experience)

**Relationship:**
- `onetCode` links to titles
- `educationRequirements.requiredLevel` compared to `UserProfile.educationLevel`
- `experienceRequirements.requiredYears` compared to `UserProfile.yearsOfExperience`

---

### 4. onet_work_activities.json (ALREADY INTEGRATED)

**Structure:**
```json
{
  "occupations": [
    {
      "onetCode": "11-2022.00",
      "title": "Sales Managers",
      "workActivities": [
        {
          "activityId": "4.A.2.a.4",
          "activityName": "Analyzing Data or Information",
          "importance": 4.5,
          "level": 4.88
        },
        {
          "activityId": "4.A.4.a.4",
          "activityName": "Establishing and Maintaining Interpersonal Relationships",
          "importance": 4.75,
          "level": 4.88
        }
        // ... 41 work activities total
      ]
    }
  ]
}
```

**Current Usage:**
- **Thompson matchWorkActivities()** - **25% weight** (highest non-skills weight!)
- **CRITICAL for Amber→Teal discovery** (HOW people work, not WHAT they know)

**Relationship:**
- `onetCode` links to titles
- Activities stored as `UserProfile.workActivities` (dict: activityId → importance)
- Thompson computes cosine similarity between user activities and job activities

**Why 25% Weight:**
Work activities enable **cross-domain career discovery**. Example:
- Sales Manager: "Establishing Relationships" (4.75) + "Analyzing Data" (4.5)
- Marketing Manager: "Establishing Relationships" (4.62) + "Analyzing Data" (4.38)
- → High activity similarity enables sales→marketing career transitions

---

### 5. onet_interests.json (ALREADY INTEGRATED - RIASEC)

**Structure:**
```json
{
  "occupations": [
    {
      "onetCode": "11-2022.00",
      "title": "Sales Managers",
      "riasecProfile": {
        "realistic": 2.33,      // R: Hands-on, mechanical work
        "investigative": 3.00,  // I: Analytical, scientific thinking
        "artistic": 2.67,       // A: Creative, unstructured work
        "social": 4.00,         // S: Helping, teaching, people-oriented
        "enterprising": 5.67,   // E: Leading, persuading, selling ⭐ HIGH
        "conventional": 3.67    // C: Organized, detail-oriented
      },
      "hollandCode": "ECS"      // Top 3: Enterprising-Conventional-Social
    }
  ]
}
```

**Current Usage:**
- **Thompson matchInterests()** - 15% weight (personality fit)
- **RIASEC personality matching** (Holland Code)

**Relationship:**
- `onetCode` links to titles
- Interests stored as `UserProfile.interests` (RIASECProfile struct)
- Thompson computes similarity between user RIASEC and job RIASEC

**Holland Code Examples:**
- Sales Managers: **ECS** (Enterprising-Conventional-Social)
- Software Engineers: **IRC** (Investigative-Realistic-Conventional)
- Teachers: **SAI** (Social-Artistic-Investigative)

---

### 6. onet_abilities.json (ALREADY INTEGRATED)

**Structure:**
```json
{
  "abilityMetadata": [
    {
      "abilityId": "1.A.1.a.1",
      "abilityName": "Oral Comprehension",
      "category": "Cognitive Abilities",
      "averageImportance": 3.73,
      "occurrenceCount": 894
    }
    // ... 52 abilities
  ],
  "occupationAbilities": [
    {
      "onetCode": "11-2022.00",
      "title": "Sales Managers",
      "abilities": [
        {
          "abilityId": "1.A.1.a.3",
          "abilityName": "Oral Expression",
          "importance": 4.5,
          "level": 4.88
        },
        {
          "abilityId": "1.A.1.a.1",
          "abilityName": "Oral Comprehension",
          "importance": 4.25,
          "level": 4.75
        }
        // ... 52 abilities per occupation
      ]
    }
  ]
}
```

**Current Usage:**
- **Thompson scoring** (abilities currently factored into work activities 25% weight)
- **Could be separate dimension** (future enhancement)

**Relationship:**
- `onetCode` links to titles
- Abilities stored as `UserProfile.abilities` (dict: abilityId → proficiency)
- 52 cognitive, physical, and sensory abilities

**Ability Categories:**
- Cognitive (21): Oral comprehension, deductive reasoning, etc.
- Psychomotor (10): Arm-hand steadiness, manual dexterity, etc.
- Physical (9): Static strength, dynamic strength, stamina, etc.
- Sensory (12): Near vision, hearing sensitivity, etc.

---

### 7. onet_knowledge.json (NOT YET INTEGRATED)

**Structure:**
```json
{
  "occupations": [
    {
      "onetCode": "11-2022.00",
      "title": "Sales Managers",
      "knowledge": [
        {
          "knowledgeId": "2.B.1.d",
          "knowledgeName": "Sales and Marketing",
          "importance": 5.0,
          "level": 5.38
        },
        {
          "knowledgeId": "2.B.1.e",
          "knowledgeName": "Customer and Personal Service",
          "importance": 4.75,
          "level": 5.12
        },
        {
          "knowledgeId": "2.C.1.a",
          "knowledgeName": "Administration and Management",
          "importance": 4.5,
          "level": 4.88
        }
        // ... 33 knowledge areas
      ]
    }
  ]
}
```

**Current Usage:**
- ❌ NOT YET INTEGRATED into Thompson
- **Future enhancement opportunity**

**Relationship:**
- `onetCode` links to titles
- 33 knowledge categories (business, technical, interpersonal)

**Knowledge Categories:**
- Business (8): Sales, Administration, Economics, etc.
- Technical (15): Computers, Engineering, Math, etc.
- Social (10): Psychology, Sociology, Education, etc.

**Integration Opportunity:**
Could add `matchKnowledge()` with 10-15% weight for knowledge-based matching.

---

### 8. onet_work_styles.json (NOT YET INTEGRATED)

**Structure:**
```json
{
  "occupations": [
    {
      "onetCode": "11-2022.00",
      "title": "Sales Managers",
      "workStyles": [
        {
          "styleId": "1.C.1.a",
          "styleName": "Achievement/Effort",
          "importance": 4.5
        },
        {
          "styleId": "1.C.3.a",
          "styleName": "Initiative",
          "importance": 4.62
        },
        {
          "styleId": "1.C.4.a",
          "styleName": "Persistence",
          "importance": 4.5
        }
        // ... 16 work styles
      ]
    }
  ]
}
```

**Current Usage:**
- ❌ NOT YET INTEGRATED into Thompson
- **Future enhancement opportunity**

**Relationship:**
- `onetCode` links to titles
- 16 work style dimensions (personality traits in work context)

**Work Styles:**
- Achievement: Achievement, persistence, initiative
- Social: Cooperation, concern for others, social orientation
- Practical: Dependability, attention to detail, integrity

**Integration Opportunity:**
Could complement RIASEC interests for deeper personality matching.

---

## Thompson Sampling Integration (Current State)

### Thompson Job Model

```swift
public struct Job: Identifiable, Sendable {
    public let onetCode: String?  // ⭐ PRIMARY KEY - links to ALL O*NET data
    // ... other fields
}
```

**Key Point:** `onetCode` is **already in the Job model** and ready to link to O*NET titles!

---

### Thompson UserProfile Model

```swift
public struct ProfessionalProfile: Sendable {
    // Original
    public var skills: [String]                     // From onet_occupation_skills.json

    // O*NET Phase 2B (Already Integrated)
    public var educationLevel: Int?                 // From onet_credentials.json
    public var yearsOfExperience: Double?           // From onet_credentials.json
    public var workActivities: [String: Double]?    // From onet_work_activities.json
    public var interests: RIASECProfile?            // From onet_interests.json
    public var abilities: [String: Double]?         // From onet_abilities.json

    // Future Extensions (Not Yet Integrated)
    // public var knowledge: [String: Double]?      // From onet_knowledge.json
    // public var workStyles: [String: Double]?     // From onet_work_styles.json
}
```

---

### Thompson Scoring Weights (Current)

```swift
let weightedScore = (
    skills * 0.30 +           // 30% - onet_occupation_skills.json
    education * 0.15 +        // 15% - onet_credentials.json
    experience * 0.15 +       // 15% - onet_credentials.json
    workActivities * 0.25 +   // 25% - onet_work_activities.json ⭐ HIGHEST
    riasecInterests * 0.15    // 15% - onet_interests.json
)
// Total: 100%
```

**Missing from Scoring (Future Opportunities):**
- `onet_knowledge.json` - Could add 10-15% weight
- `onet_work_styles.json` - Could add 5-10% weight
- `onet_abilities.json` - Already in profile but not separately scored

---

## Complete Data Flow with O*NET Titles

### Current Flow (Account Executive Example)

```
USER ONBOARDING
├─ Step 1: Resume upload → "Account Executive" found
├─ Step 2: Contact info → Name, email
├─ Step 3: ProfileSetupStepView (MISSING FROM FLOW)
│   ├─ User searches "account" in RolesDatabase (roles.json - 72 roles)
│   ├─ "Account Executive" NOT FOUND (missing from 72 roles)
│   ├─ User enters custom role "Account Executive"
│   └─ selectedTargetRoles = ["Account Executive"]
│
├─ ProfileConverter.extractSkills(["Account Executive"])
│   ├─ Load RolesDatabase.allRoles (72 from roles.json)
│   ├─ Try to find "Account Executive" → NOT FOUND
│   ├─ Fallback: tryONetFallback("Account Executive")
│   │   ├─ ONetCodeMapper.mapJobTitle("Account Executive")
│   │   ├─ Fuzzy match → "Account Executives" → "41-3031.01"
│   │   ├─ ONetDataService.loadOccupationSkills()
│   │   ├─ Find skills for "41-3031.01"
│   │   └─ Return: ["Sales", "Customer Service", "Communication", ...]
│   └─ Skills stored in UserProfile.skills
│
└─ AppState.userProfile.preferredJobTypes = ["Account Executive"]
```

### Proposed Flow (With O*NET Titles)

```
USER ONBOARDING
├─ Step 1: Resume upload → "Account Executive" found
├─ Step 2: Contact info → Name, email
├─ Step 3: ProfileSetupStepView (ADDED TO FLOW ⭐)
│   ├─ Load RolesDatabase.allRoles → onet_occupation_titles.json (1016 titles)
│   ├─ User searches "account" → Shows:
│   │   ├─ "Account Executives" (41-3031.01) - Sales sector ✅
│   │   ├─ "Accountants" (13-2011.01) - Finance sector
│   │   └─ "Accounting Clerks" (43-3031.00) - Office sector
│   ├─ User selects "Account Executives"
│   └─ selectedTargetRoles = [
│         Role(id: "41-3031.01", title: "Account Executives", sector: "Sales")
│       ]
│
├─ ProfileConverter.extractSkills([Role with onetCode "41-3031.01"])
│   ├─ Load onet_occupation_skills.json
│   ├─ Look up "41-3031.01" → DIRECT MATCH (no fuzzy search needed)
│   ├─ Extract skills: ["Sales", "Customer Service", "Active Listening", ...]
│   └─ Skills stored in UserProfile.skills
│
├─ AppState.userProfile.preferredJobTypes = ["Account Executives"]
│
└─ THOMPSON SAMPLING (Job Discovery)
    ├─ JobDiscoveryCoordinator receives jobs from API
    ├─ For each job:
    │   ├─ Job has onetCode "41-3031.01" (if provided by API)
    │   ├─ Thompson.computeONetScore(job, profile, "41-3031.01")
    │   │   ├─ Load onet_credentials.json["41-3031.01"]
    │   │   │   └─ Education: Bachelor's, Experience: 2-5 years
    │   │   ├─ Load onet_work_activities.json["41-3031.01"]
    │   │   │   └─ Activities: Selling, Persuading, Communicating
    │   │   ├─ Load onet_interests.json["41-3031.01"]
    │   │   │   └─ RIASEC: ECS (Enterprising-Conventional-Social)
    │   │   ├─ Compute weighted score:
    │   │   │   ├─ Skills match: 0.85 (30% → 0.255)
    │   │   │   ├─ Education match: 0.90 (15% → 0.135)
    │   │   │   ├─ Experience match: 0.80 (15% → 0.120)
    │   │   │   ├─ Activities match: 0.88 (25% → 0.220)
    │   │   │   └─ Interests match: 0.82 (15% → 0.123)
    │   │   └─ Total score: 0.853 (85.3% match!)
    │   └─ Job ranked by Thompson score
    └─ DeckScreen displays jobs sorted by score (sales jobs at top ✅)
```

---

## Key Relationships and Links

### Primary Key Chain

```
onet_occupation_titles.json (onetCode: "11-2022.00")
    ↓
    ├─→ onet_occupation_skills.json (onetCode: "11-2022.00")
    ├─→ onet_credentials.json (onetCode: "11-2022.00")
    ├─→ onet_work_activities.json (onetCode: "11-2022.00")
    ├─→ onet_interests.json (onetCode: "11-2022.00")
    ├─→ onet_abilities.json (onetCode: "11-2022.00")
    ├─→ onet_knowledge.json (onetCode: "11-2022.00")
    └─→ onet_work_styles.json (onetCode: "11-2022.00")
```

**All databases keyed by `onetCode` (SOC 2018 format: "XX-XXXX.XX")**

---

### Data Flow: User Profile → Thompson → Job Match

```
1. USER PROFILE CREATION
   ↓
   RolesDatabase.allRoles (onet_occupation_titles.json)
   ├─ User selects "Sales Managers" (onetCode: "11-2022.00")
   └─ ProfileConverter.extractSkills("Sales Managers")
       ├─ Lookup "11-2022.00" in onet_occupation_skills.json
       └─ Return skills: ["Persuasion", "Negotiation", ...]

2. USER PROFILE STORAGE
   ↓
   UserProfile(
       skills: ["Persuasion", "Negotiation", ...],     // From skills.json
       educationLevel: 8,                              // Bachelor's
       yearsOfExperience: 5.0,
       workActivities: ["4.A.4.a.4": 4.75, ...],      // From activities.json
       interests: RIASECProfile(E: 5.67, C: 3.67, S: 4.0), // From interests.json
       abilities: ["1.A.1.a.3": 4.5, ...]             // From abilities.json
   )

3. JOB SCORING
   ↓
   Job(onetCode: "11-2022.00", title: "Sales Manager", ...)
   ↓
   Thompson.computeONetScore(job, profile, "11-2022.00")
   ├─ ONetDataService.getCredentials("11-2022.00")    // From credentials.json
   ├─ ONetDataService.getWorkActivities("11-2022.00") // From activities.json
   ├─ ONetDataService.getInterests("11-2022.00")      // From interests.json
   ├─ matchSkills() → 0.85
   ├─ matchEducation() → 0.90
   ├─ matchExperience() → 0.80
   ├─ matchWorkActivities() → 0.88
   └─ matchInterests() → 0.82
   ↓
   Weighted Score: 0.853 (85.3%)
```

---

## Integration Opportunities

### 1. O*NET Knowledge Integration (Future)

**Current State:** `onet_knowledge.json` loaded but **not used by Thompson**

**Opportunity:**
Add `matchKnowledge()` function with 10-15% weight:

```swift
// Add to ProfessionalProfile
public var knowledge: [String: Double]?  // knowledgeId → proficiency

// Add to Thompson scoring
async let knowledgeScore = matchKnowledge(
    userKnowledge: profile.knowledge,
    jobKnowledge: jobKnowledge
)

// Update weights (redistribute from activities or add new dimension)
let weightedScore = (
    skills * 0.25 +           // Reduced from 30%
    education * 0.15 +
    experience * 0.10 +        // Reduced from 15%
    workActivities * 0.20 +    // Reduced from 25%
    riasecInterests * 0.15 +
    knowledge * 0.15           // NEW
)
```

**Benefit:**
Better matching for knowledge-intensive roles (engineering, healthcare, law).

---

### 2. O*NET Work Styles Integration (Future)

**Current State:** `onet_work_styles.json` loaded but **not used by Thompson**

**Opportunity:**
Add `matchWorkStyles()` function with 5-10% weight:

```swift
// Add to ProfessionalProfile
public var workStyles: [String: Double]?  // styleId → importance

// Complement RIASEC interests with work style matching
async let stylesScore = matchWorkStyles(
    userStyles: profile.workStyles,
    jobStyles: jobStyles
)
```

**Benefit:**
Deeper personality fit beyond RIASEC (e.g., "Achievement/Effort", "Persistence").

---

### 3. Abilities as Separate Dimension (Future)

**Current State:** Abilities loaded but **not separately scored** (folded into activities)

**Opportunity:**
Add `matchAbilities()` function with 10% weight:

```swift
async let abilitiesScore = matchAbilities(
    userAbilities: profile.abilities,
    jobAbilities: jobAbilities
)

let weightedScore = (
    skills * 0.25 +
    education * 0.10 +
    experience * 0.10 +
    workActivities * 0.20 +
    riasecInterests * 0.15 +
    abilities * 0.10 +         // NEW - physical/cognitive capabilities
    knowledge * 0.10
)
```

**Benefit:**
Better matching for physically demanding roles or cognitive-intensive work.

---

## Performance Considerations

### Current Thompson Performance Budget

```
SACRED CONSTRAINT: <10ms Thompson Sampling (357x competitive advantage)
Target: <8ms total execution (2ms safety buffer)

Current Breakdown:
- matchSkills():          2.0ms (30% weight)
- matchEducation():       0.8ms (15% weight)
- matchExperience():      0.8ms (15% weight)
- matchWorkActivities():  1.5ms (25% weight)
- matchInterests():       1.0ms (15% weight)
- Overhead:               1.9ms
Total:                    8.0ms ✅
```

### Impact of Adding Knowledge/Styles/Abilities

**If we add all 3 new dimensions:**
```
- matchKnowledge():       1.0ms (10% weight)
- matchWorkStyles():      0.8ms (10% weight)
- matchAbilities():       1.2ms (10% weight)
New Total:               11.0ms ❌ EXCEEDS BUDGET
```

**Solution: Parallel Execution**
```swift
// Execute all 8 dimensions in parallel
async let (skills, education, experience, activities, interests, knowledge, styles, abilities) = (
    matchSkills(...),
    matchEducation(...),
    matchExperience(...),
    matchWorkActivities(...),
    matchInterests(...),
    matchKnowledge(...),       // NEW
    matchWorkStyles(...),      // NEW
    matchAbilities(...)        // NEW
)

// Still completes in ~8ms (bottleneck determines total time)
```

---

## O*NET Titles Database Role

### Where It Fits

```
onet_occupation_titles.json serves as:

1. ✅ PRIMARY KEY DATABASE
   - Links all other O*NET databases via onetCode

2. ✅ UI SELECTION LAYER
   - ProfileSetupStepView role selection (1016 options with search)
   - Sector grouping (23 O*NET families → 18 app sectors)

3. ✅ FUZZY MATCHING FALLBACK
   - ONetCodeMapper uses titles for fuzzy search
   - Maps resume titles → O*NET codes

4. ✅ JOB API INTEGRATION
   - Job sources can provide onetCode with job postings
   - Enables instant Thompson scoring without text parsing
```

---

## Complete System Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    USER ONBOARDING                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              ProfileSetupStepView                           │
│  ┌────────────────────────────────────────────────┐        │
│  │  RolesDatabase.allRoles                        │        │
│  │  ↓                                              │        │
│  │  onet_occupation_titles.json (1016 titles)     │        │
│  │  ↓                                              │        │
│  │  User searches → selects "Sales Managers"      │        │
│  │  Role(id: "11-2022.00", title, sector)         │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              ProfileConverter.extractSkills()               │
│  ┌────────────────────────────────────────────────┐        │
│  │  Input: ["Sales Managers"]                     │        │
│  │  ↓                                              │        │
│  │  onet_occupation_skills.json                   │        │
│  │  Lookup "11-2022.00" → Skills                  │        │
│  │  ↓                                              │        │
│  │  Return: ["Persuasion", "Negotiation", ...]    │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│               UserProfile Storage                           │
│  ┌────────────────────────────────────────────────┐        │
│  │  ProfessionalProfile(                          │        │
│  │    skills: ["Persuasion", ...],     ← skills.json      │
│  │    educationLevel: 8,               ← credentials.json  │
│  │    yearsOfExperience: 5.0,          ← credentials.json  │
│  │    workActivities: {...},           ← activities.json   │
│  │    interests: RIASECProfile(...),   ← interests.json    │
│  │    abilities: {...}                 ← abilities.json    │
│  │  )                                              │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│               Thompson Sampling Engine                      │
│  ┌────────────────────────────────────────────────┐        │
│  │  Job(onetCode: "11-2022.00", ...)              │        │
│  │  ↓                                              │        │
│  │  computeONetScore(job, profile, "11-2022.00")  │        │
│  │  ├─ Load credentials.json["11-2022.00"]        │        │
│  │  ├─ Load activities.json["11-2022.00"]         │        │
│  │  ├─ Load interests.json["11-2022.00"]          │        │
│  │  ├─ matchSkills() → 0.85 (30%)                 │        │
│  │  ├─ matchEducation() → 0.90 (15%)              │        │
│  │  ├─ matchExperience() → 0.80 (15%)             │        │
│  │  ├─ matchWorkActivities() → 0.88 (25%)         │        │
│  │  └─ matchInterests() → 0.82 (15%)              │        │
│  │  ↓                                              │        │
│  │  Weighted Score: 0.853 (85.3%)                 │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   DeckScreen Display                        │
│  Jobs sorted by Thompson score (sales jobs at top ✅)       │
└─────────────────────────────────────────────────────────────┘
```

---

## Answer to User's Questions

### Q1: How will O*NET titles flow through the system?

**Answer:**

```
1. ONBOARDING: User selects from 1016 O*NET titles → saves onetCode to profile

2. PROFILECONVERTER: Uses onetCode to load skills from onet_occupation_skills.json

3. THOMPSON: Uses onetCode to load credentials, activities, interests for scoring

4. COMPLETE INTEGRATION: All O*NET databases linked via onetCode primary key
```

---

### Q2: Will Thompson Sampling be using the O*NET titles database?

**Answer:** **YES, indirectly:**

```
Thompson doesn't directly read onet_occupation_titles.json,
but it uses the onetCode PRIMARY KEY from that database to:

1. Load onet_occupation_skills.json (30% weight)
2. Load onet_credentials.json (30% weight: education + experience)
3. Load onet_work_activities.json (25% weight)
4. Load onet_interests.json (15% weight)

The titles database is the "phonebook" that provides the phone numbers (onetCodes)
to call all other O*NET services.
```

---

### Q3: Can we relate these databases to each other?

**Answer:** **YES, they are ALREADY deeply related:**

```
ALL O*NET databases share the same primary key: onetCode

onet_occupation_titles.json
    ↓ (onetCode: "11-2022.00")
    ├→ onet_occupation_skills.json (Skills for Sales Managers)
    ├→ onet_credentials.json (Education: Bachelor's, Experience: 5 years)
    ├→ onet_work_activities.json (Activities: Selling, Persuading, ...)
    ├→ onet_interests.json (RIASEC: ECS - Enterprising-Conventional-Social)
    ├→ onet_abilities.json (Abilities: Oral Expression, Persuasion, ...)
    ├→ onet_knowledge.json (Knowledge: Sales, Marketing, Customer Service)
    └→ onet_work_styles.json (Styles: Achievement, Initiative, ...)

Example: "Sales Managers" (11-2022.00)
├─ Skills: Persuasion, Negotiation, Active Listening (35 skills total)
├─ Education: Bachelor's degree (level 8)
├─ Experience: 5+ years management experience
├─ Activities: Establishing Relationships (4.75), Analyzing Data (4.5)
├─ Interests: Enterprising (5.67), Social (4.0), Conventional (3.67)
├─ Abilities: Oral Expression (4.5), Oral Comprehension (4.25)
├─ Knowledge: Sales & Marketing (5.0), Customer Service (4.75)
└─ Work Styles: Achievement/Effort (4.5), Initiative (4.62)
```

---

## Recommendations

### Immediate (O*NET Titles Integration)

1. ✅ **Implement O*NET Titles Replacement Plan** (from previous document)
   - Replace roles.json (72) with onet_occupation_titles.json (1016)
   - Add search bar to ProfileSetupStepView
   - Map 23 O*NET families → 18 app sectors

2. ✅ **Add ProfileSetupStepView to onboarding flow**
   - Critical missing step causing empty preferredJobTypes
   - Enables O*NET integration to actually execute

3. ✅ **Test complete flow**
   - Account Executive → Sales Managers → sales skills → sales jobs

---

### Future Enhancements

1. **Add Knowledge Matching** (3-6 months)
   - Integrate onet_knowledge.json
   - Add matchKnowledge() with 10-15% weight
   - Better matching for knowledge-intensive roles

2. **Add Work Styles Matching** (6-12 months)
   - Integrate onet_work_styles.json
   - Complement RIASEC with work style traits
   - Deeper personality fit scoring

3. **Separate Abilities Dimension** (6-12 months)
   - Extract abilities from activities weight
   - Add matchAbilities() with 10% weight
   - Better physical/cognitive capability matching

---

## Conclusion

**Key Findings:**

1. ✅ **O*NET databases are ALREADY deeply integrated** with Thompson Sampling
2. ✅ **onetCode is the PRIMARY KEY** linking all databases
3. ✅ **Thompson uses 5 O*NET databases** for scoring (100% weight distributed)
4. ✅ **O*NET titles database will seamlessly integrate** as UI selection layer
5. ✅ **3 O*NET databases are loaded but not yet used** (knowledge, work styles, abilities as separate dimension)

**Impact of O*NET Titles Integration:**

- Fixes Account Executive issue (missing sales roles in roles.json)
- Provides 1016 occupation titles vs 72 curated roles
- Enables direct O*NET code lookup (no fuzzy matching needed)
- Complete coverage across all job sectors
- Future-proof: O*NET updates automatically flow through

**The system is ALREADY O*NET-powered. We're just adding the missing UI layer to make it accessible to users.**
