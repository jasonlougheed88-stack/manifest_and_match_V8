# O*NET Architecture Analysis for ManifestAndMatch V8
## Strategic Research: How O*NET Validates & Improves Our Approach

**Date:** October 27, 2025
**Purpose:** Analyze O*NET's proven occupational framework to validate and improve ManifestAndMatch's skills system and profile architecture
**Skills Engaged:** manifestandmatch-skills-guardian, professional-user-profile, app-narrative-guide, v7-architecture-guardian

---

## Executive Summary

**The Problem We're Solving:** We extracted 32,495 skills from O*NET (too many). We have 14 sectors. We need to know:
1. How to filter to usable skills
2. If our 14-sector taxonomy is robust enough
3. What we can learn from O*NET's 20+ years of occupational research
4. How to structure user profiles for maximum matching effectiveness

**The Answer:** O*NET's Content Model provides a 6-domain framework that separates **Skills** (learnable) from **Knowledge** (domain facts) from **Abilities** (innate traits). This distinction is CRITICAL for our Amber→Teal profile system.

---

## Part 1: O*NET Content Model Structure

### The 6-Domain Framework

O*NET organizes ALL occupational information into 6 hierarchical domains:

```
1. Worker Characteristics (WHO you are - innate)
   ├── Abilities (52 descriptors)
   ├── Interests (6 Holland codes)
   ├── Work Values (6 values)
   └── Work Styles (16 styles)

2. Worker Requirements (WHAT you've learned)
   ├── Skills (35 descriptors) ← OUR PRIMARY FOCUS
   ├── Knowledge (33 areas)
   └── Education (levels/training)

3. Experience Requirements
   ├── Experience & Training
   ├── Licensing
   └── Apprenticeships

4. Occupational Requirements (JOB characteristics)
   ├── Generalized Work Activities (42 activities)
   ├── Detailed Work Activities (2,000+ tasks)
   ├── Organizational Context
   └── Work Context (57 factors)

5. Occupation-Specific Information
   ├── Tasks (19,000+ statements)
   ├── Tools & Technology (10,000+ items)
   └── Occupation Data

6. Workforce Characteristics
   ├── Labor Market Info
   ├── Occupational Outlook
   └── Wages
```

### Critical Insight #1: Skills ≠ Knowledge ≠ Abilities

**O*NET's Definitions:**

**Skills (35 total)**
- *Definition:* "Developed capacities that facilitate learning or performance"
- *Categories:* Basic Skills (10) + Cross-Functional Skills (25)
  - Basic: Reading, Writing, Speaking, Listening, Math, Science, etc.
  - Cross-Functional: Critical Thinking, Problem Solving, Social Skills, Technical Skills, Systems Skills, Resource Management
- **Characteristic:** LEARNABLE through training/practice

**Knowledge (33 areas)**
- *Definition:* "Organized sets of principles and facts about specific domains"
- *Categories:* Business, Manufacturing, Arts/Humanities, Engineering/Technology, Education, Healthcare, Law/Public Safety, Communications, Transportation
- **Characteristic:** ACQUIRABLE through education/experience

**Abilities (52 descriptors)**
- *Definition:* "Enduring attributes that influence performance"
- *Categories:* Cognitive (21), Psychomotor (10), Physical (9), Sensory (12)
  - Examples: Oral Comprehension, Deductive Reasoning, Manual Dexterity, Stamina
- **Characteristic:** Relatively FIXED (harder to develop)

---

## Part 2: How This Applies to ManifestAndMatch

### Our Current System (Before O*NET Analysis)

```swift
// Current: Single "skills" array
struct UserProfile {
    var skills: [String]  // Mix of everything: "Python", "Patient Care", "Leadership"
}
```

**Problem:** We're mixing Skills, Knowledge, and Abilities into one bucket.

### O*NET-Informed Architecture (Recommended)

```swift
// Recommended: Separate by O*NET taxonomy
struct UserProfile {
    // Worker Requirements (Learnable)
    var skills: [Skill]          // 35 O*NET skills (learnable capacities)
    var knowledge: [Knowledge]   // 33 O*NET knowledge areas (domain facts)
    var education: Education     // Formal credentials

    // Worker Characteristics (Innate-ish)
    var abilities: [Ability]     // 52 O*NET abilities (harder to change)
    var workStyles: [WorkStyle]  // 16 O*NET work styles
    var interests: [Interest]    // 6 Holland codes (RIASEC)

    // Our Innovation: Amber→Teal Profiles
    var matchProfile: MatchProfile      // Current reality (Amber)
    var manifestProfile: ManifestProfile // Potential (Teal)
}
```

### Why This Matters for Amber→Teal System

**Amber Profile (Current Self):**
- **Skills:** Proven through work history
- **Knowledge:** Acquired through education/experience
- **Abilities:** Demonstrated strengths

**Teal Profile (Potential Self):**
- **Transferable Skills:** Core skills that work across domains
- **Adjacent Knowledge:** Related domains user could learn
- **Hidden Abilities:** Untapped strengths revealed by AI

**The Magic:** O*NET's taxonomy lets us identify *which* skills transfer across industries (cross-functional skills) vs domain-specific knowledge.

---

## Part 3: Solving the "32K Skills" Problem

### The Issue

We extracted from O*NET:
- 350 core skills (Skills.txt)
- 10,975 technology tools
- 21,170 specific tools
- **Total: 32,495 items**

### O*NET's Solution: Hierarchical Abstraction

O*NET doesn't list every tool. They organize hierarchically:

```
Level 1: Skill Category (35 total)
  └─ Example: "Equipment Selection"

Level 2: Generalized Work Activity (42 total)
  └─ Example: "Controlling Machines and Processes"

Level 3: Detailed Work Activity (2,000+ activities)
  └─ Example: "Operate industrial equipment"

Level 4: Tools & Technology (10,000+ specific items)
  └─ Example: "Siemens SIMATIC programmable logic controller"
```

**For User Profiles:** Store Level 1-2 (Skills + Work Activities)
**For Job Matching:** Match at Level 2-3 (Activities + specific tools)
**For Display:** Show Level 4 when relevant

### Recommended Filtering Strategy

**What to Store in skills.json:**

1. **All 35 O*NET Skills** ✅ (learnable, transferable)
2. **All 33 O*NET Knowledge Areas** ✅ (domain expertise)
3. **Top 200 Technology Categories** ✅ (not every specific tool)
4. **Sector-Specific Certifications** ✅ (~50 per sector)

**What NOT to Store:**
- ❌ Every software product version ("Adobe Acrobat v1", "v2", etc.)
- ❌ Every tool manufacturer variant
- ❌ Obsolete technologies

**Result:** ~2,800-3,500 skills (manageable, meaningful)

---

## Part 4: Validating Our 14-Sector Taxonomy

### O*NET's Classification: SOC Codes

O*NET uses **Standard Occupational Classification (SOC)**:
- 1,016 occupations
- 23 major groups (2-digit codes)
- 98 minor groups (3-digit)
- 459 broad occupations (5-digit)
- 867 detailed occupations (6-digit)

**Examples:**
- `11-0000`: Management Occupations
- `29-0000`: Healthcare Practitioners
- `15-0000`: Computer and Mathematical

### Our 14 Sectors vs O*NET's 23 Major Groups

**Our Sectors:**
1. Office/Administrative
2. Healthcare
3. Technology
4. Retail
5. Skilled Trades
6. Finance
7. Food Service
8. Warehouse/Logistics
9. Education
10. Construction
11. Legal
12. Real Estate
13. Marketing
14. Human Resources

**O*NET Major Groups (23):**
1. Management (11-)
2. Business/Financial (13-)
3. Computer/Mathematical (15-)
4. Architecture/Engineering (17-)
5. Life/Physical/Social Science (19-)
6. Community/Social Service (21-)
7. Legal (23-)
8. Education/Training/Library (25-)
9. Arts/Design/Entertainment/Sports/Media (27-)
10. Healthcare Practitioners (29-)
11. Healthcare Support (31-)
12. Protective Service (33-)
13. Food Preparation/Serving (35-)
14. Building/Grounds Cleaning/Maintenance (37-)
15. Personal Care/Service (39-)
16. Sales (41-)
17. Office/Administrative Support (43-)
18. Farming/Fishing/Forestry (45-)
19. Construction/Extraction (47-)
20. Installation/Maintenance/Repair (49-)
21. Production (51-)
22. Transportation/Material Moving (53-)
23. Military Specific (55-)

### Analysis: Are We Missing Critical Sectors?

**✅ Well Covered (Our 14 match O*NET):**
- Healthcare (29-, 31-)
- Technology (15-)
- Office/Admin (43-)
- Food Service (35-)
- Education (25-)
- Legal (23-)
- Retail/Sales (41-)
- Construction (47-)
- Warehouse/Logistics (53-)

**⚠️ Partially Covered (Could expand):**
- **Skilled Trades:** We have this, but O*NET separates into:
  - Installation/Maintenance/Repair (49-)
  - Production (51-)
  - Might need subcategories

**❌ Missing from Our Taxonomy:**
- **Arts/Design/Media** (27-) - Major sector!
- **Protective Service** (33-) - Police, firefighters, security
- **Science/Research** (19-) - Lab work, research roles
- **Social/Community Service** (21-) - Social workers, counselors
- **Personal Care** (39-) - Cosmetology, fitness, childcare

**Recommendation:** Expand to **19 sectors** minimum:

```swift
enum JobSector: String, CaseIterable {
    // Original 14
    case officeAdmin = "Office/Administrative"
    case healthcare = "Healthcare"
    case technology = "Technology"
    case retail = "Retail"
    case skilledTrades = "Skilled Trades"
    case finance = "Finance"
    case foodService = "Food Service"
    case warehouseLogistics = "Warehouse/Logistics"
    case education = "Education"
    case construction = "Construction"
    case legal = "Legal"
    case realEstate = "Real Estate"
    case marketing = "Marketing"
    case humanResources = "Human Resources"

    // NEW: Missing sectors
    case artsDesignMedia = "Arts/Design/Media"           // 27-
    case protectiveService = "Protective Service"        // 33- (Police, Fire, Security)
    case scienceResearch = "Science/Research"            // 19- (Lab, Research)
    case socialService = "Social/Community Service"      // 21- (Social workers, counseling)
    case personalCare = "Personal Care/Services"         // 39- (Beauty, fitness, childcare)
}
```

---

## Part 5: Profile Structure Recommendations

### Current V8 Profile (Simplified)

```swift
struct UserProfile {
    var name: String
    var skills: [String]
    var experience: [WorkExperience]
    var education: [Education]
}
```

### O*NET-Informed Profile (Professional-User-Profile Skill Applied)

```swift
// Based on O*NET Content Model + JSON Resume Standard
struct UserProfile: Codable, Sendable {

    // MARK: - Basics (Identity)
    var basics: BasicInfo

    // MARK: - Worker Requirements (Learnable)
    var skills: SkillsProfile          // 35 O*NET skills
    var knowledge: [KnowledgeArea]     // 33 O*NET knowledge domains
    var education: [Education]

    // MARK: - Worker Characteristics (Innate-ish)
    var abilities: [Ability]           // 52 O*NET abilities (optional)
    var workStyles: [WorkStyle]        // 16 O*NET work styles
    var interests: HollandCode         // RIASEC assessment

    // MARK: - Experience
    var work: [WorkExperience]
    var volunteer: [VolunteerExperience]
    var certifications: [Certification]

    // MARK: - Our Innovation: Dual Profiles
    var matchProfile: MatchProfile         // Amber: Current reality
    var manifestProfile: ManifestProfile   // Teal: AI-discovered potential

    // MARK: - Additional
    var projects: [Project]
    var awards: [Award]
    var publications: [Publication]
    var languages: [Language]
}

// Skills organized by O*NET taxonomy
struct SkillsProfile: Codable, Sendable {
    var basicSkills: [Skill]              // Reading, Writing, Math, Science
    var crossFunctional: [Skill]          // Problem solving, Critical thinking
    var technical: [TechnicalSkill]       // Domain-specific tech
    var certifications: [Certification]   // Professional credentials
}

// O*NET-aligned skill definition
struct Skill: Codable, Sendable, Identifiable {
    var id: String
    var name: String
    var category: SkillCategory        // O*NET's 7 categories
    var level: ProficiencyLevel        // Beginner → Expert
    var yearsExperience: Int?
    var lastUsed: Date?
    var transferability: Transferability  // How well it crosses domains
}

enum SkillCategory: String, Codable {
    // O*NET's 7 skill categories
    case content              // Reading, writing, speaking
    case process              // Critical thinking, active learning
    case social               // Coordination, persuasion, negotiation
    case problemSolving       // Complex problem solving
    case technical            // Equipment selection, programming, troubleshooting
    case systems              // Systems analysis, systems evaluation
    case resourceManagement   // Time, financial, material, personnel
}

enum Transferability: String, Codable {
    case universal      // Works in ANY industry (communication, problem-solving)
    case crossDomain    // Works in MANY industries (project management, data analysis)
    case sectorSpecific // Works in ONE sector (medical coding, real estate law)
    case toolSpecific   // Tied to specific tool (Adobe Photoshop, Salesforce)
}
```

### Why This Matters

**For Amber Profile (Match):**
- Show proven skills with evidence (work history)
- Highlight domain knowledge
- Display certifications

**For Teal Profile (Manifest):**
- Identify **universal** and **cross-domain** skills
- Suggest adjacent knowledge areas
- Map to new career possibilities

**For Job Matching:**
```swift
// Match at appropriate abstraction level
func matchJob(_ job: Job, to profile: UserProfile) -> MatchScore {
    // Level 1: Universal skills (high weight)
    let universalMatch = matchSkills(
        profile.skills.filter { $0.transferability == .universal },
        to: job.requiredSkills
    )

    // Level 2: Knowledge domains (medium weight)
    let knowledgeMatch = matchKnowledge(
        profile.knowledge,
        to: job.requiredKnowledge
    )

    // Level 3: Technical tools (lower weight - learnable)
    let technicalMatch = matchTechnical(
        profile.skills.technical,
        to: job.requiredTools
    )

    return MatchScore(
        universal: universalMatch,
        knowledge: knowledgeMatch,
        technical: technicalMatch,
        overall: weightedAverage(...)
    )
}
```

---

## Part 6: What We Can Directly Use from O*NET

### 1. The 35 Core Skills (Direct Import)

**O*NET provides standardized skill descriptors:**

**Basic Skills (10):**
- Reading Comprehension
- Active Listening
- Writing
- Speaking
- Mathematics
- Science
- Critical Thinking
- Active Learning
- Learning Strategies
- Monitoring

**Cross-Functional Skills (25):**
- Social Skills (7): Coordination, Persuasion, Negotiation, Instructing, Service Orientation, Social Perceptiveness, Coordination
- Complex Problem Solving (1): Complex Problem Solving
- Technical Skills (3): Operations Analysis, Technology Design, Equipment Selection
- Systems Skills (4): Judgment/Decision Making, Systems Analysis, Systems Evaluation
- Resource Management (4): Time Management, Management of Financial Resources, Management of Material Resources, Management of Personnel Resources

**Action:** Import all 35 as foundational skills in our database.

### 2. The 33 Knowledge Areas (Direct Import)

**O*NET Knowledge Categories:**

**Business & Management (6):**
- Administration and Management
- Customer and Personal Service
- Personnel and Human Resources
- Economics and Accounting
- Sales and Marketing
- Clerical

**Manufacturing & Production (6):**
- Production and Processing
- Food Production
- Computers and Electronics
- Engineering and Technology
- Design
- Building and Construction

**Arts, Humanities, Education (7):**
- Fine Arts
- History and Archeology
- Philosophy and Theology
- Public Safety and Security
- Law and Government
- Telecommunications
- Communications and Media

**Healthcare & Human Services (4):**
- Medicine and Dentistry
- Therapy and Counseling
- Psychology
- Sociology and Anthropology

**Math & Science (5):**
- Mathematics
- Physics
- Chemistry
- Biology
- Geography

**Other (5):**
- English Language
- Foreign Language
- Mechanical
- Transportation

**Action:** Import all 33 as knowledge domains for profile enrichment.

### 3. Work Activities (For Job Matching)

**42 Generalized Work Activities** - Use these for cross-domain matching:
- Information Input (4 activities)
- Mental Processes (10 activities)
- Work Output (9 activities)
- Interacting with Others (17 activities)
- Physical/Technical Activities (9 activities)

**Example:**
- User has: "Analyzing Data or Information" (work activity)
- Jobs requiring this: Data Analyst, Research Scientist, Market Researcher, Financial Analyst
- **Insight:** Same activity, different domains = career pivot opportunity

---

## Part 7: Implementation Recommendations

### Phase 1: Refactor Skills Database (Swift)

**Create O*NET-aligned enums:**

```swift
// Packages/V7Core/Sources/V7Core/Skills/ONetTaxonomy.swift

/// O*NET's 35 standardized skills
enum ONetSkill: String, CaseIterable, Codable {
    // Basic Skills
    case readingComprehension = "Reading Comprehension"
    case activeListening = "Active Listening"
    case writing = "Writing"
    case speaking = "Speaking"
    case mathematics = "Mathematics"
    case science = "Science"
    case criticalThinking = "Critical Thinking"
    case activeLearning = "Active Learning"
    case learningStrategies = "Learning Strategies"
    case monitoring = "Monitoring"

    // Social Skills
    case socialPerceptiveness = "Social Perceptiveness"
    case coordination = "Coordination"
    case persuasion = "Persuasion"
    case negotiation = "Negotiation"
    case instructing = "Instructing"
    case serviceOrientation = "Service Orientation"

    // Complex Problem Solving
    case complexProblemSolving = "Complex Problem Solving"

    // Technical Skills
    case operationsAnalysis = "Operations Analysis"
    case technologyDesign = "Technology Design"
    case equipmentSelection = "Equipment Selection"
    case installation = "Installation"
    case programming = "Programming"
    case qualityControlAnalysis = "Quality Control Analysis"
    case operationMonitoring = "Operation Monitoring"
    case operationAndControl = "Operation and Control"
    case equipmentMaintenance = "Equipment Maintenance"
    case troubleshooting = "Troubleshooting"
    case repairing = "Repairing"

    // Systems Skills
    case judgmentAndDecisionMaking = "Judgment and Decision Making"
    case systemsAnalysis = "Systems Analysis"
    case systemsEvaluation = "Systems Evaluation"

    // Resource Management
    case timeManagement = "Time Management"
    case managementOfFinancialResources = "Management of Financial Resources"
    case managementOfMaterialResources = "Management of Material Resources"
    case managementOfPersonnelResources = "Management of Personnel Resources"

    var category: SkillCategory {
        // Return appropriate category
    }

    var transferability: Transferability {
        // Classify how transferable each skill is
        switch self {
        case .readingComprehension, .criticalThinking, .problemSolving:
            return .universal
        case .socialPerceptiveness, .coordination, .persuasion:
            return .crossDomain
        case .programming, .equipmentMaintenance:
            return .technical
        default:
            return .crossDomain
        }
    }
}

/// O*NET's 33 knowledge areas
enum ONetKnowledge: String, CaseIterable, Codable {
    case administration = "Administration and Management"
    case customerService = "Customer and Personal Service"
    case personnel = "Personnel and Human Resources"
    case economics = "Economics and Accounting"
    case salesMarketing = "Sales and Marketing"
    case clerical = "Clerical"
    case production = "Production and Processing"
    case foodProduction = "Food Production"
    case computers = "Computers and Electronics"
    case engineering = "Engineering and Technology"
    case design = "Design"
    case construction = "Building and Construction"
    case mechanicalDevices = "Mechanical"
    case mathematics = "Mathematics"
    case physics = "Physics"
    case chemistry = "Chemistry"
    case biology = "Biology"
    case psychology = "Psychology"
    case sociology = "Sociology and Anthropology"
    case geography = "Geography"
    case medicine = "Medicine and Dentistry"
    case therapy = "Therapy and Counseling"
    case education = "Education and Training"
    case english = "English Language"
    case foreignLanguage = "Foreign Language"
    case fineArts = "Fine Arts"
    case history = "History and Archeology"
    case philosophy = "Philosophy and Theology"
    case publicSafety = "Public Safety and Security"
    case law = "Law and Government"
    case telecommunications = "Telecommunications"
    case communications = "Communications and Media"
    case transportation = "Transportation"

    var relatedSectors: [JobSector] {
        // Map knowledge to applicable sectors
    }
}
```

### Phase 2: Restructure skills.json

**New Structure:**

```json
{
  "version": "2.0",
  "source": "O*NET 30.0 + ManifestAndMatch Curation",
  "taxonomy": "O*NET Content Model",
  "last_updated": "2025-10-27",

  "onet_skills": {
    "basic_skills": [ /* 10 skills */ ],
    "cross_functional_skills": [ /* 25 skills */ ]
  },

  "onet_knowledge": [ /* 33 knowledge areas */ ],

  "sector_specific_skills": {
    "Healthcare": [ /* 200+ healthcare-specific skills */ ],
    "Technology": [ /* 200+ tech-specific skills */ ],
    ...
  },

  "technology_categories": [ /* 200 tool categories, not 10K tools */ ],

  "certifications": {
    "Healthcare": [ /* Industry certs */ ],
    "Finance": [ /* CPA, CFA, etc */ ],
    ...
  }
}
```

### Phase 3: Update Profile Model

**Modify UserProfile to align with O*NET:**

```swift
// Packages/V7Core/Sources/V7Core/Models/UserProfile.swift

@Observable
@MainActor
public final class UserProfile: Codable {

    // Worker Requirements (O*NET Domain 2)
    public var onetSkills: [ONetSkill]          // 35 standardized
    public var knowledgeAreas: [ONetKnowledge]  // 33 domains
    public var sectorSkills: [String]           // Domain-specific
    public var certifications: [Certification]

    // Worker Characteristics (O*NET Domain 1) - Optional
    public var workStyles: [WorkStyle]?
    public var interests: [Interest]?

    // Traditional fields
    public var workExperience: [WorkExperience]
    public var education: [Education]

    // Our Innovation: Dual profiles
    public var matchProfile: MatchProfile       // Amber
    public var manifestProfile: ManifestProfile // Teal
}
```

### Phase 4: Implement Transferability Scoring

```swift
// Packages/V7Core/Sources/V7Core/Matching/TransferabilityEngine.swift

public actor TransferabilityEngine {

    /// Calculate how well user's skills transfer to target role
    public func calculateTransferability(
        from currentRole: String,
        to targetRole: String,
        userSkills: [ONetSkill]
    ) async -> TransferabilityScore {

        // Get required skills for both roles
        let currentRequirements = await getONetRequirements(currentRole)
        let targetRequirements = await getONetRequirements(targetRole)

        // Calculate overlap at different levels
        let universalOverlap = userSkills.filter {
            $0.transferability == .universal &&
            targetRequirements.contains($0)
        }

        let crossDomainOverlap = userSkills.filter {
            $0.transferability == .crossDomain &&
            targetRequirements.contains($0)
        }

        // High transferability = many universal/cross-domain skills match
        return TransferabilityScore(
            universal: Double(universalOverlap.count) / Double(targetRequirements.count),
            crossDomain: Double(crossDomainOverlap.count) / Double(targetRequirements.count),
            overall: weightedAverage(...)
        )
    }
}
```

---

## Part 8: Key Takeaways

### ✅ What We're Doing Right

1. **14 Sectors are Good Foundation** - Cover major O*NET groups
2. **Skills-Based Matching** - Aligns with O*NET philosophy
3. **Transferability Focus** - Core to O*NET's cross-occupational comparisons
4. **Dual Profile System** - Innovative extension of O*NET

### ⚠️ What We Should Improve

1. **Separate Skills/Knowledge/Abilities** - Currently mixed in one array
2. **Add Missing Sectors** - Arts/Media, Protective Service, Science, Social Service, Personal Care (expand to 19)
3. **Use O*NET's 35 Core Skills** - Standardized, researched, proven
4. **Hierarchical Skill Organization** - Not flat list of 32K items
5. **Transferability Classification** - Tag skills as universal/cross-domain/sector-specific

### 🚀 What We Can Innovate Beyond O*NET

1. **Amber→Teal Visual System** - O*NET doesn't have this!
2. **AI-Powered Career Discovery** - O*NET is search-based, not AI-driven
3. **Real-Time Job Matching** - O*NET is reference data, not active matching
4. **Transition Pathways** - O*NET shows data, we guide action
5. **Mobile-First Experience** - O*NET is desktop-focused

---

## Part 9: Action Plan

### Immediate (This Week)

1. **Expand to 19 Sectors** - Add Arts/Media, Science, Protective Service, Social Service, Personal Care
2. **Import O*NET 35 Skills** - Create ONetSkill enum in V7Core
3. **Import O*NET 33 Knowledge** - Create ONetKnowledge enum
4. **Refactor skills.json** - Separate core skills, knowledge, sector-specific

### Short-Term (Next 2 Weeks)

5. **Update UserProfile Model** - Split skills into O*NET taxonomy
6. **Implement Transferability Engine** - Score how well skills transfer
7. **Create Skill Hierarchy** - Universal → Cross-Domain → Sector-Specific
8. **Filter 32K to 2.8K** - Keep categories, not every tool variant

### Medium-Term (Phase 2)

9. **Integrate with Thompson Sampling** - Weight universal skills higher
10. **Update UI to Show Transferability** - Visual indicators for skill portability
11. **Enhance Manifest Profile Generation** - Use transferability scores
12. **Test with Real Users** - Validate career suggestions

---

## Conclusion

**O*NET validates our core approach** while revealing specific improvements:

**Keep:**
- Skills-based matching philosophy
- Cross-domain career discovery
- Dual profile system (Amber→Teal)

**Add:**
- O*NET's 35 standardized skills
- Skills/Knowledge/Abilities separation
- Transferability classification
- 5 missing sectors (expand to 19)

**Fix:**
- Hierarchical organization (not flat 32K list)
- Proper skill taxonomy (not mixed bucket)

**Result:** More accurate matching, better career suggestions, proven by 20+ years of O*NET research.

---

**Next Steps:** Review with team, prioritize implementation, update Phase 1 checklist.
