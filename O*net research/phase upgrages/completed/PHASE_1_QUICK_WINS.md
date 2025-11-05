# Phase 1: Quick Wins

**Part of**: O*NET Integration Implementation Plan  
**Document Version**: 1.0  
**Created**: October 29, 2025  
**Project**: ManifestAndMatch V8 (iOS 26)  
**Duration**: Week 1 (32 hours)  
**Priority**: P0 (40% of total value)

---

## Phase 1: Quick Wins (Week 1)

**Goal**: Display existing Core Data entities and expand industry coverage
**Impact**: 40% of total value
**Effort**: 20% of total work (32 hours)
**Risk**: Very Low
**Dependencies**: Week 0 (Pre-implementation fixes)

### ⚠️ CRITICAL: Swift 6 Sendable Compliance

**ALL Phase 1 code MUST use NSManagedObjectID instead of Core Data objects in @State.**

Swift 6 strict concurrency requires Sendable types in @State. Core Data NSManagedObject subclasses are NOT Sendable.

**Pattern to follow**:
```swift
// ❌ WRONG - Won't compile with Swift 6
@State private var selectedExperience: WorkExperience?

// ✅ CORRECT - Sendable-compliant
@State private var selectedExperienceID: NSManagedObjectID?
@Environment(\.managedObjectContext) private var context

// Usage:
if let id = selectedExperienceID,
   let exp = try? context.existingObject(with: id) as? WorkExperience {
    // Use exp
}
```

**This pattern applies to ALL 7 entities**: WorkExperience, Education, Certification, Project, VolunteerExperience, Award, Publication.

### Task 1.1: Display WorkExperience Entity

**Priority**: P0 (Critical - highest user value)
**Estimated Time**: 4 hours
**File**: `Packages/V7UI/Sources/V7UI/Views/ProfileScreen.swift`
**Insert Location**: After Skills section (line 353)

#### Implementation Steps

**Step 1.1.1: Add WorkExperience Section to ProfileScreen** (2 hours)

```swift
// Add after Skills section (line 353)
// ⚠️ Swift 6 Sendable-compliant: Uses NSManagedObjectID, NOT WorkExperience objects
Section {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("Work Experience")
                .font(.headline)
            Spacer()
            Button(action: { showAddExperienceSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(interpolateColor(ratio: profileBlend))
            }
        }

        // ✅ SENDABLE-COMPLIANT: Get IDs, not objects
        if let experiences = userProfile.workExperiences?.allObjects as? [WorkExperience],
           !experiences.isEmpty {
            let experienceIDs = experiences
                .sorted(by: { ($0.startDate ?? Date.distantPast) > ($1.startDate ?? Date.distantPast) })
                .map { $0.objectID }

            ForEach(experienceIDs, id: \.self) { objectID in
                // ✅ Fetch object from context using ID
                if let experience = try? context.existingObject(with: objectID) as? WorkExperience {
                    WorkExperienceRow(experience: experience, profileBlend: profileBlend)
                        .onTapGesture {
                            selectedExperienceID = objectID  // ✅ Store ID, not object
                            showEditExperienceSheet = true
                        }
                }
            }
        } else {
            EmptyStateView(
                icon: "briefcase",
                title: "No work experience yet",
                message: "Add your work history to improve job matching"
            )
            .padding(.vertical)
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 1.1.2: Create WorkExperienceRow Component** (1 hour)

Add to ProfileScreen.swift (bottom of file):

```swift
// MARK: - WorkExperience Row Component
struct WorkExperienceRow: View {
    let experience: WorkExperience
    let profileBlend: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title and Company
            VStack(alignment: .leading, spacing: 4) {
                Text(experience.title ?? "Untitled Position")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(experience.company ?? "Unknown Company")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Date Range
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

                if experience.isCurrent {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text("Current")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(interpolateColor(ratio: profileBlend))
                }
            }

            // Description (first 2 lines)
            if let description = experience.jobDescription, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }

            // Technologies/Skills tags
            if let technologies = experience.technologies, !technologies.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(Array(technologies.prefix(5)), id: \.self) { tech in
                        Text(tech)
                            .font(.system(size: 11))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                    }

                    if technologies.count > 5 {
                        Text("+\(technologies.count - 5)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var label = "\(experience.title ?? "Position") at \(experience.company ?? "company")"
        label += ", \(formatDateRange(start: experience.startDate, end: experience.endDate, isCurrent: experience.isCurrent))"
        if experience.isCurrent {
            label += ", Current position"
        }
        return label
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

**Step 1.1.3: Add State Variables** (30 minutes)

Add to ProfileScreen state (top of struct, around line 40):

```swift
// ✅ Swift 6 Sendable-compliant state variables
@State private var showAddExperienceSheet = false
@State private var showEditExperienceSheet = false
@State private var selectedExperienceID: NSManagedObjectID?  // ✅ NOT WorkExperience object
@Environment(\.managedObjectContext) private var context      // ✅ Required for object fetching
```

**Step 1.1.4: Create EmptyStateView Component** (30 minutes)

```swift
// MARK: - Empty State Component
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
    }
}
```

**Success Criteria**:
- [ ] WorkExperience entities displayed in ProfileScreen
- [ ] Sorted by start date (most recent first)
- [ ] Shows company, title, date range, current status
- [ ] Technologies displayed as chips (max 5 + count)
- [ ] Empty state shown when no experience exists
- [ ] Accessible with VoiceOver
- [ ] Tappable for future edit functionality

---

### Task 1.2: Display Education Entity

**Priority**: P0 (Critical)
**Estimated Time**: 3 hours
**File**: `ProfileScreen.swift`
**Insert Location**: After WorkExperience section

#### Implementation Steps

**Step 1.2.1: Add Education Section** (1.5 hours)

```swift
// Add after WorkExperience section
Section {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("Education")
                .font(.headline)
            Spacer()
            Button(action: { showAddEducationSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(interpolateColor(ratio: profileBlend))
            }
        }

        if let educationRecords = userProfile.education?.allObjects as? [Education],
           !educationRecords.isEmpty {
            ForEach(educationRecords.sorted(by: {
                ($0.startDate ?? Date.distantPast) > ($1.startDate ?? Date.distantPast)
            }), id: \.self) { education in
                EducationRow(education: education, profileBlend: profileBlend)
                    .onTapGesture {
                        selectedEducation = education
                        showEditEducationSheet = true
                    }
            }
        } else {
            EmptyStateView(
                icon: "graduationcap",
                title: "No education added yet",
                message: "Add your educational background to improve matches"
            )
            .padding(.vertical)
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 1.2.2: Create EducationRow Component** (1 hour)

```swift
// MARK: - Education Row Component
struct EducationRow: View {
    let education: Education
    let profileBlend: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Degree and Field
            VStack(alignment: .leading, spacing: 4) {
                if let degree = education.degree, !degree.isEmpty {
                    Text(degree)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                if let field = education.fieldOfStudy, !field.isEmpty {
                    Text(field)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Institution
            if let institution = education.institution {
                HStack(spacing: 4) {
                    Image(systemName: "building.columns")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(institution)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Date Range and GPA
            HStack {
                // Date range
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text(formatDateRange(
                        start: education.startDate,
                        end: education.endDate
                    ))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                // GPA if present
                if let gpa = education.gpa, gpa > 0 {
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    HStack(spacing: 2) {
                        Text("GPA:")
                        Text(String(format: "%.2f", gpa))
                            .fontWeight(.medium)
                            .foregroundColor(interpolateColor(ratio: profileBlend))
                    }
                    .font(.caption)
                }
            }

            // O*NET Education Level Badge
            if education.educationLevelValue > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 10))
                    Text("Level \(education.educationLevelValue)/12")
                        .font(.system(size: 11))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(interpolateColor(ratio: profileBlend))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var label = ""
        if let degree = education.degree {
            label += degree
        }
        if let field = education.fieldOfStudy {
            label += " in \(field)"
        }
        if let institution = education.institution {
            label += " from \(institution)"
        }
        if let gpa = education.gpa, gpa > 0 {
            label += ", GPA \(String(format: "%.2f", gpa))"
        }
        return label
    }

    private func formatDateRange(start: Date?, end: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"

        let startStr = start.map { formatter.string(from: $0) } ?? "Unknown"
        let endStr = end.map { formatter.string(from: $0) } ?? "Unknown"

        return "\(startStr) – \(endStr)"
    }
}
```

**Step 1.2.3: Add State Variables** (30 minutes)

```swift
@State private var showAddEducationSheet = false
@State private var showEditEducationSheet = false
@State private var selectedEducation: Education?
```

**Success Criteria**:
- [ ] Education entities displayed in ProfileScreen
- [ ] Shows degree, field of study, institution
- [ ] Date range formatted as years
- [ ] GPA displayed if present (>0)
- [ ] O*NET education level badge shown (1-12 scale)
- [ ] Empty state for no education
- [ ] Accessible with VoiceOver

---

### Task 1.3: Display Certification Entity

**Priority**: P1 (High)
**Estimated Time**: 2.5 hours
**File**: `ProfileScreen.swift`

#### Implementation Steps

**Step 1.3.1: Add Certification Section** (1.5 hours)

```swift
Section {
    VStack(alignment: .leading, spacing: 16) {
        HStack {
            Text("Certifications & Credentials")
                .font(.headline)
            Spacer()
            Button(action: { showAddCertificationSheet = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(interpolateColor(ratio: profileBlend))
            }
        }

        if let certifications = userProfile.certifications?.allObjects as? [Certification],
           !certifications.isEmpty {
            ForEach(certifications.sorted(by: {
                ($0.issueDate ?? Date.distantPast) > ($1.issueDate ?? Date.distantPast)
            }), id: \.self) { cert in
                CertificationRow(certification: cert, profileBlend: profileBlend)
            }
        } else {
            EmptyStateView(
                icon: "checkmark.seal",
                title: "No certifications yet",
                message: "Add professional certifications to stand out"
            )
            .padding(.vertical)
        }
    }
    .padding(.vertical, 8)
}
.listRowBackground(Color.clear)
```

**Step 1.3.2: Create CertificationRow Component** (1 hour)

```swift
// MARK: - Certification Row Component
struct CertificationRow: View {
    let certification: Certification
    let profileBlend: Double

    private var isExpired: Bool {
        guard !certification.doesNotExpire,
              let expirationDate = certification.expirationDate else {
            return false
        }
        return expirationDate < Date()
    }

    private var expiresWithin90Days: Bool {
        guard !certification.doesNotExpire,
              let expirationDate = certification.expirationDate else {
            return false
        }
        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return daysUntilExpiration > 0 && daysUntilExpiration <= 90
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Name and Status Badge
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(certification.name ?? "Unnamed Certification")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    if let issuer = certification.issuer {
                        Text(issuer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Status Badge
                Group {
                    if isExpired {
                        StatusBadge(text: "Expired", color: .red)
                    } else if expiresWithin90Days {
                        StatusBadge(text: "Expiring Soon", color: .orange)
                    } else {
                        StatusBadge(text: "Active", color: .green)
                    }
                }
            }

            // Dates
            VStack(alignment: .leading, spacing: 4) {
                if let issueDate = certification.issueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.caption2)
                        Text("Issued: \(formatDate(issueDate))")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }

                if !certification.doesNotExpire {
                    if let expirationDate = certification.expirationDate {
                        HStack(spacing: 4) {
                            Image(systemName: isExpired ? "calendar.badge.exclamationmark" : "calendar.badge.clock")
                                .font(.caption2)
                            Text(isExpired ? "Expired: " : "Expires: ")
                            Text(formatDate(expirationDate))
                                .foregroundColor(isExpired ? .red : expiresWithin90Days ? .orange : .secondary)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }

            // Credential ID
            if let credentialId = certification.credentialId, !credentialId.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "number")
                        .font(.caption2)
                    Text("ID: \(credentialId)")
                }
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.8))
            }

            // Verification Link
            if let verificationURL = certification.verificationURL,
               let url = URL(string: verificationURL) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                        Text("Verify Credential")
                    }
                    .font(.caption)
                    .foregroundColor(interpolateColor(ratio: profileBlend))
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}

// Status Badge Component
struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(6)
    }
}
```

**Success Criteria**:
- [ ] Certifications displayed with name, issuer, dates
- [ ] Active/Expired/Expiring Soon status badges
- [ ] Credential ID shown if present
- [ ] Verification link clickable
- [ ] Sorted by issue date
- [ ] Empty state displayed

---

### Task 1.4: Display Projects, Volunteer, Awards, Publications

**Priority**: P1 (High)
**Estimated Time**: 2 hours each (8 hours total)
**File**: `ProfileScreen.swift`

Follow similar pattern to WorkExperience/Education/Certification sections.

**Components to Create**:
1. ProjectRow - Shows name, description, technologies, links
2. VolunteerRow - Shows organization, role, hours/week, dates
3. AwardRow - Shows title, issuer, date, description
4. PublicationRow - Shows title, publisher, authors, date, URL

**Success Criteria** (per entity):
- [ ] Section added to ProfileScreen
- [ ] Custom row component created
- [ ] Empty state displayed
- [ ] Sorted appropriately (by date)
- [ ] Key fields visible
- [ ] Accessible

---

### Task 1.5: Expand Industry Enum from 12 to 19 (**CORRECTED**)

**Priority**: P0 (Critical - unlocks O*NET integration)
**Estimated Time**: 2 hours (**+1 hour** for proper O*NET sector mapping)
**File**: `Packages/V7Core/Sources/V7Core/StateManagement/AppState.swift`
**Location**: Lines 387-417

**⚠️ CRITICAL FIX**: Original plan incorrectly included 21 industries with "Core Skills" and "Knowledge Areas" (these are skill categories, NOT industries). O*NET has exactly **19 sectors** aligned with NAICS taxonomy.

#### Implementation Steps

**Step 1.5.1: Update Industry Enum** (1 hour - **CORRECTED**)

**Current Code**:
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

**New Code** (**CORRECTED - 19 O*NET Sectors, NO meta-categories**):
```swift
/// O*NET Industry Sectors (19 sectors aligned with NAICS taxonomy)
/// ⚠️ CRITICAL: Does NOT include "Core Skills" or "Knowledge Areas" (those are skill categories, not industries)
public enum Industry: String, Codable, CaseIterable, Sendable, Identifiable {
    public var id: String { rawValue }

    // 19 O*NET Industry Sectors (NAICS-aligned)
    case agricultureForestryFishing = "Agriculture, Forestry, Fishing"
    case miningQuarrying = "Mining, Quarrying, Oil & Gas"
    case utilities = "Utilities"
    case construction = "Construction"
    case manufacturing = "Manufacturing"
    case wholesaleTrade = "Wholesale Trade"
    case retailTrade = "Retail Trade"
    case transportationWarehousing = "Transportation and Warehousing"
    case information = "Information"                     // includes Technology, Media
    case financeInsurance = "Finance and Insurance"
    case realEstate = "Real Estate and Rental"
    case professionalScientificTechnical = "Professional, Scientific, Technical"
    case managementOfCompanies = "Management of Companies"
    case administrativeSupport = "Administrative and Support Services"
    case educationalServices = "Educational Services"
    case healthcareSocialAssistance = "Healthcare and Social Assistance"
    case artsEntertainment = "Arts, Entertainment, Recreation"
    case accommodationFoodServices = "Accommodation and Food Services"
    case otherServices = "Other Services (except Public Administration)"
    case publicAdministration = "Public Administration"

    /// O*NET sector code (NAICS-based)
    public var sectorCode: String {
        switch self {
        case .agricultureForestryFishing: return "11"
        case .miningQuarrying: return "21"
        case .utilities: return "22"
        case .construction: return "23"
        case .manufacturing: return "31-33"
        case .wholesaleTrade: return "42"
        case .retailTrade: return "44-45"
        case .transportationWarehousing: return "48-49"
        case .information: return "51"
        case .financeInsurance: return "52"
        case .realEstate: return "53"
        case .professionalScientificTechnical: return "54"
        case .managementOfCompanies: return "55"
        case .administrativeSupport: return "56"
        case .educationalServices: return "61"
        case .healthcareSocialAssistance: return "62"
        case .artsEntertainment: return "71"
        case .accommodationFoodServices: return "72"
        case .otherServices: return "81"
        case .publicAdministration: return "92"
        }
    }

    /// SF Symbol icon for industry
    public var icon: String {
        switch self {
        case .agricultureForestryFishing: return "leaf.fill"
        case .miningQuarrying: return "mountain.2.fill"
        case .utilities: return "bolt.fill"
        case .construction: return "hammer.fill"
        case .manufacturing: return "gearshape.fill"
        case .wholesaleTrade: return "shippingbox.fill"
        case .retailTrade: return "cart.fill"
        case .transportationWarehousing: return "truck.box.fill"
        case .information: return "antenna.radiowaves.left.and.right"
        case .financeInsurance: return "dollarsign.circle.fill"
        case .realEstate: return "house.fill"
        case .professionalScientificTechnical: return "flask.fill"
        case .managementOfCompanies: return "building.2.fill"
        case .administrativeSupport: return "folder.fill"
        case .educationalServices: return "book.fill"
        case .healthcareSocialAssistance: return "cross.case.fill"
        case .artsEntertainment: return "theatermasks.fill"
        case .accommodationFoodServices: return "fork.knife"
        case .otherServices: return "wrench.and.screwdriver.fill"
        case .publicAdministration: return "building.columns.fill"
        }
    }
}
```

**Step 1.5.2: Add Migration Helper** (1 hour - **UPDATED**)

Add to AppState.swift (below Industry enum):

```swift
// MARK: - Industry Migration
extension Industry {
    /// Migrates old 12-industry app values to new 19 O*NET sectors
    /// Maps legacy app industries to proper NAICS-aligned sectors
    public static func fromLegacy(_ legacy: String) -> Industry {
        switch legacy.lowercased() {
        // Direct mappings (app industry → O*NET sector)
        case "technology", "tech", "it", "software":
            return .information  // NAICS 51
        case "healthcare", "medical", "health":
            return .healthcareSocialAssistance  // NAICS 62
        case "finance", "banking", "fintech":
            return .financeInsurance  // NAICS 52
        case "education", "teaching", "academia":
            return .educationalServices  // NAICS 61
        case "retail", "ecommerce", "sales":
            return .retailTrade  // NAICS 44-45
        case "manufacturing", "industrial":
            return .manufacturing  // NAICS 31-33
        case "consulting", "professional services":
            return .professionalScientificTechnical  // NAICS 54
        case "media & entertainment", "media", "entertainment":
            return .artsEntertainment  // NAICS 71
        case "non-profit", "nonprofit", "charity":
            return .otherServices  // NAICS 81
        case "government", "public sector":
            return .publicAdministration  // NAICS 92
        case "hospitality", "food service", "restaurant":
            return .accommodationFoodServices  // NAICS 72
        case "real estate", "property":
            return .realEstate  // NAICS 53

        // Additional O*NET sectors
        case "construction", "building":
            return .construction
        case "transportation", "logistics":
            return .transportationWarehousing
        case "utilities":
            return .utilities
        case "agriculture", "farming", "forestry":
            return .agricultureForestryFishing

        default:
            return .otherServices  // Fallback for unknown
        }
    }

    /// Check if legacy data needs migration
    public static func needsMigration(from oldEnum: String) -> Bool {
        // Return true if old app had 12 industries
        let legacyIndustries = [
            "Technology", "Healthcare", "Finance", "Education",
            "Retail", "Manufacturing", "Consulting",
            "Media & Entertainment", "Non-profit", "Government",
            "Hospitality", "Real Estate"
        ]
        return legacyIndustries.contains(oldEnum)
    }
}
```

**Success Criteria**:
- [ ] Enum expanded from 12 to **19 cases** (**CORRECTED** - NOT 21)
- [ ] **NO** "coreSkills" or "knowledgeAreas" cases (these are skill categories, not industries)
- [ ] Migration helper function added (`fromLegacy()`)
- [ ] All 19 O*NET sectors represented with NAICS codes
- [ ] Backward compatibility maintained via migration
- [ ] SF Symbol icons added for each sector
- [ ] Compiles without errors

---

### Task 1.6: Update JobPreferencesView for 19 Industries (**CORRECTED**)

**Priority**: P0 (Critical)
**Estimated Time**: 1 hour
**File**: Location TBD (find JobPreferencesView file)

#### Implementation Steps

**Step 1.6.1: Find JobPreferencesView** (5 minutes)

```bash
# Search for JobPreferencesView
find ~/Desktop/ios26_manifest_and_match/manifest\ and\ match\ V8/Packages -name "*JobPreferences*"
```

**Step 1.6.2: Update Industry Display Logic** (55 minutes)

The existing FlowLayout should automatically handle 19 industries (it wraps dynamically).

**Changes needed**:
1. No code changes required for layout (FlowLayout handles it)
2. Test that all 19 display correctly
3. Optional: Add grouping by sector category if UI becomes cluttered

**Optional Enhancement - Grouped Display**:

```swift
// Group industries by category
let groupedIndustries = Dictionary(grouping: Industry.allCases, by: { $0.group })

ForEach(IndustryGroup.allCases, id: \.self) { group in
    if let industries = groupedIndustries[group], !industries.isEmpty {
        VStack(alignment: .leading, spacing: 12) {
            Text(group.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .padding(.leading, 4)

            FlowLayout(spacing: 8) {
                ForEach(industries, id: \.self) { industry in
                    industryChip(industry)
                }
            }
        }
        .padding(.bottom, 16)
    }
}
```

**Success Criteria**:
- [ ] All **19 industries** display in JobPreferencesView (**CORRECTED**)
- [ ] FlowLayout wraps correctly
- [ ] Selection state works for all industries
- [ ] No UI clipping or overflow
- [ ] Accessible with VoiceOver
- [ ] Industry icons display correctly (SF Symbols)

---

### Phase 1 Summary & Testing

**Total Time**: ~32 hours (1 week)
**Files Modified**: 2 (ProfileScreen.swift, AppState.swift)
**New Components**: 7 (WorkExperienceRow, EducationRow, CertificationRow, ProjectRow, VolunteerRow, AwardRow, PublicationRow)

#### Phase 1 Testing Checklist

**ProfileScreen Display Tests**:
- [ ] Upload resume with all 7 entity types
- [ ] Verify each section displays parsed data
- [ ] Test empty states for each section
- [ ] Test tap gestures (prepare for Phase 2 edit sheets)
- [ ] Verify sorting (most recent first for time-based)
- [ ] Test accessibility with VoiceOver
- [ ] Test on iPhone SE (small screen), iPhone 16 Pro Max (large screen)
- [ ] Test in Light Mode and Dark Mode
- [ ] Test with Liquid Glass Clear and Tinted modes

**Industry Expansion Tests**:
- [ ] Select each of **19 industries** in JobPreferencesView (**CORRECTED**)
- [ ] Verify selection state persists
- [ ] Test legacy industry migration (load old profile with "Technology", verify migrates to "Information" sector)
- [ ] Verify Thompson scoring uses all 19 sectors
- [ ] Test accessibility for all industry chips
- [ ] Verify NAICS sector codes display correctly

**Performance Tests**:
- [ ] ProfileScreen loads in <1 second with 10+ work experiences
- [ ] Scrolling is smooth (60 FPS)
- [ ] No memory leaks when navigating to/from ProfileScreen
- [ ] Thompson scoring still <10ms with 21 sectors

**Success Metrics**:
- ✅ Users can see their complete work history
- ✅ Users can see their education background
- ✅ Users can see certifications with expiration status
- ✅ Users in all 21 O*NET sectors can select their industry
- ✅ No breaking changes to existing functionality

---


---

## Reference Documents

- Main plan: `ONET_INTEGRATION_IMPLEMENTATION_PLAN.md`
- Week 0: `WEEK_0_PRE_IMPLEMENTATION_FIXES.md`
- Phase 2: `PHASE_2_ONET_PROFILE_EDITOR.md`

---

**Document Status**: ✅ Complete
**Last Updated**: October 29, 2025
**Ready for Implementation**: Yes (requires Week 0 completion first)
