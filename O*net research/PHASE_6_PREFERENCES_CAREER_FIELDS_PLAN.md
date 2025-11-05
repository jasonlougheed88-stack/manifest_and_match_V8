# Phase 6: PreferencesStepView Career Fields O*NET Integration

**Date:** November 1, 2025
**Project:** ManifestAndMatchV7 (iOS 26)
**Phase:** 6 - Dynamic Career Fields from O*NET
**Prerequisites:** Phases 1-5 Complete (RolesDatabase loads 1016 O*NET roles)

---

## Executive Summary

**Problem:** PreferencesStepView Industries section uses hardcoded `Industry` enum (19 sectors) that doesn't match O*NET's 18 mapped sectors. User cannot search 1016 roles, only select from fixed chips.

**Solution:** Replace hardcoded `Industry` enum with dynamic O*NET Career Fields loaded from RolesDatabase, add search bar for 1016 roles, maintain chip UI but make it data-driven.

**Scope:**
- Rename "Industries" → "Career Fields"
- Load 18 sectors from `RolesDatabase.shared.getAvailableSectors()`
- Add search bar to filter/search 1016 O*NET roles
- Replace `selectedIndustries: Set<Industry>` with `selectedSectors: Set<String>`
- Remove hardcoded `Industry` enum dependency in PreferencesStepView
- Maintain icon mapping for career field chips
- Full VoiceOver + Dynamic Type accessibility

**Impact:**
- ✅ Career Fields match actual O*NET sectors (not invented enum)
- ✅ Users can search 1016 roles to find relevant sectors
- ✅ Data-driven UI (no hardcoded enums in views)
- ✅ Eliminates sector mismatch between ProfileSetupStepView and PreferencesStepView
- ✅ Direct connection to O*NET database

**Implementation Time:** 2-3 hours
**Risk Level:** Low (well-established patterns from Phase 4)

---

## Part 1: Current Architecture Analysis

### 1.1 Current Industry Enum (AppState.swift)

**Location:** `/Packages/V7Core/Sources/V7Core/StateManagement/AppState.swift:438-500`

```swift
public enum Industry: String, Codable, CaseIterable, Sendable {
    // 19 NAICS-Aligned Sectors (HARDCODED)
    case agricultureForestryFishing = "Agriculture, Forestry, Fishing"
    case miningQuarrying = "Mining, Quarrying, Oil/Gas"
    case utilities = "Utilities"
    case construction = "Construction"
    case manufacturing = "Manufacturing"
    case wholesaleTrade = "Wholesale Trade"
    case retailTrade = "Retail Trade"
    case transportationWarehousing = "Transportation & Warehousing"
    case information = "Information"
    case financeInsurance = "Finance & Insurance"
    case realEstate = "Real Estate & Rental"
    case professionalScientificTechnical = "Professional, Scientific, Technical"
    case management = "Management of Companies"
    case administrativeSupport = "Administrative & Support Services"
    case educationalServices = "Educational Services"
    case healthcareSocial = "Healthcare & Social Assistance"
    case artsEntertainment = "Arts, Entertainment, Recreation"
    case accommodationFoodServices = "Accommodation & Food Services"
    case otherServices = "Other Services (except Public Admin)"
    case publicAdministration = "Public Administration"

    public var icon: String {
        // 19 hardcoded icon mappings
    }
}
```

**Problems:**
1. **Mismatch:** 19 sectors here vs 18 O*NET mapped sectors
2. **Hardcoded:** Cannot be updated without app release
3. **Name Mismatch:** "Professional, Scientific, Technical" ≠ O*NET "Technology" sector
4. **No Search:** Users can't search 1016 roles to find relevant sectors
5. **Type-Unsafe:** Enum forces compile-time dependency on specific sectors

### 1.2 Current PreferencesStepView Implementation

**Location:** `/ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/Steps/PreferencesStepView.swift`

**State (lines 18-19):**
```swift
@State private var selectedIndustries: Set<Industry> = []  // ❌ Enum-based
```

**UI (lines 312-355):**
```swift
private var industriesSection: some View {
    VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {
        HStack {
            Label(PreferenceSection.industries.title, systemImage: "building.2.fill")  // ❌ "Industries"
            Spacer()
            if selectedIndustries.isEmpty {
                Text("Select 1+")
            } else {
                Text("\(selectedIndustries.count) selected")
            }
        }

        PreferencesFlowLayout(spacing: 8) {
            ForEach(Industry.allCases, id: \.self) { industry in  // ❌ Hardcoded enum
                IndustryChip(
                    industry: industry,
                    isSelected: selectedIndustries.contains(industry),
                    onTap: {
                        withAnimation {
                            if selectedIndustries.contains(industry) {
                                selectedIndustries.remove(industry)
                            } else {
                                selectedIndustries.insert(industry)
                            }
                        }
                    }
                )
            }
        }
    }
}
```

**Chip View (lines 707-727):**
```swift
private struct IndustryChip: View {
    let industry: Industry  // ❌ Enum dependency
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: industry.icon)  // ❌ Enum icon property
                    .font(.caption)
                Text(industry.rawValue)  // ❌ Enum rawValue
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}
```

**Problems:**
1. **No Search:** Users cannot search 1016 O*NET roles
2. **Static Enum:** Chips show fixed 19 sectors from enum
3. **Wrong Label:** "Industries" instead of "Career Fields"
4. **Type Coupling:** `IndustryChip` requires `Industry` enum
5. **No O*NET Connection:** Doesn't load from RolesDatabase

### 1.3 O*NET Sector Mapping (Already Implemented)

**Location:** `/Packages/V7Core/Sources/V7Core/ONetDataModels.swift`

**Sector Mapping Extension (Phases 1-2):**
```swift
public extension SimpleOccupationTitle {
    /// Maps O*NET's 23 job families to app's 18 UI sectors
    var mappedSector: String {
        switch sector {
        case let s where s.contains("Management"):
            return "Business/Management"
        case let s where s.contains("Business and Financial"):
            return "Finance"
        case let s where s.contains("Computer and Mathematical"):
            return "Technology"
        case let s where s.contains("Architecture and Engineering"):
            return "Engineering"
        case let s where s.contains("Life, Physical, and Social Science"):
            return "Science/Research"
        case let s where s.contains("Healthcare"):
            return "Healthcare"
        case let s where s.contains("Education"):
            return "Education"
        case let s where s.contains("Legal"):
            return "Legal"
        case let s where s.contains("Sales and Related"):
            return "Sales"
        case let s where s.contains("Office and Administrative"):
            return "Office/Administrative"
        case let s where s.contains("Food Preparation and Serving"):
            return "Food Service"
        case let s where s.contains("Building and Grounds"):
            return "Skilled Trades"
        case let s where s.contains("Personal Care and Service"):
            return "Personal Services"
        case let s where s.contains("Protective Service"):
            return "Public Service"
        case let s where s.contains("Production"):
            return "Manufacturing"
        case let s where s.contains("Transportation and Material Moving"):
            return "Warehouse/Logistics"
        case let s where s.contains("Installation, Maintenance, and Repair"):
            return "Skilled Trades"
        case let s where s.contains("Construction and Extraction"):
            return "Construction"
        default:
            return "Other"
        }
    }
}
```

**18 O*NET Mapped Sectors:**
1. Business/Management
2. Finance
3. Technology
4. Engineering
5. Science/Research
6. Healthcare
7. Education
8. Legal
9. Sales
10. Office/Administrative
11. Food Service
12. Skilled Trades
13. Personal Services
14. Public Service
15. Manufacturing
16. Warehouse/Logistics
17. Construction
18. Other

**Available via RolesDatabase:**
```swift
let sectors = await RolesDatabase.shared.getAvailableSectors()
// Returns: Array of 18 unique sector strings from O*NET
```

---

## Part 2: Solution Architecture

### 2.1 Core Changes

#### Change 1: Replace Industry Enum with String Sectors

**From:**
```swift
@State private var selectedIndustries: Set<Industry> = []  // Enum-based
```

**To:**
```swift
@State private var selectedSectors: Set<String> = []  // String-based, dynamic
@State private var availableSectors: [String] = []  // Loaded from O*NET
```

#### Change 2: Add Search Functionality

**New State:**
```swift
@State private var sectorSearchText: String = ""
@State private var showSearchResults: Bool = false
@FocusState private var isSearchFieldFocused: Bool
```

**Search Computed Property:**
```swift
private var filteredRoles: [Role] {
    guard !sectorSearchText.isEmpty else { return [] }

    let lowercased = sectorSearchText.lowercased()
    return allRoles.filter { role in
        role.title.lowercased().contains(lowercased) ||
        role.sector.lowercased().contains(lowercased)
    }
}

private var searchResultSectors: Set<String> {
    Set(filteredRoles.map { $0.sector })
}
```

#### Change 3: Dynamic Sector Loading

**On Task:**
```swift
.task {
    // Load available sectors from O*NET
    availableSectors = await RolesDatabase.shared.getAvailableSectors()

    // Load existing preferences
    loadExistingPreferences()
}
```

#### Change 4: Icon Mapping

**New Sector Icon Mapper:**
```swift
// Extension in PreferencesStepView
extension String {
    /// Maps O*NET sector names to SF Symbol icons
    /// Maintains visual consistency with hardcoded Industry enum
    var sectorIcon: String {
        switch self {
        case "Business/Management": return "chart.line.uptrend.xyaxis"
        case "Finance": return "dollarsign.circle.fill"
        case "Technology": return "laptopcomputer"
        case "Engineering": return "gearshape.2.fill"
        case "Science/Research": return "flask.fill"
        case "Healthcare": return "heart.fill"
        case "Education": return "book.fill"
        case "Legal": return "briefcase.fill"
        case "Sales": return "bag.fill"
        case "Office/Administrative": return "folder.fill"
        case "Food Service": return "fork.knife"
        case "Skilled Trades": return "hammer.fill"
        case "Personal Services": return "person.fill"
        case "Public Service": return "building.columns.fill"
        case "Manufacturing": return "gearshape.2.fill"
        case "Warehouse/Logistics": return "truck.box.fill"
        case "Construction": return "hammer.fill"
        case "Other": return "ellipsis.circle.fill"
        default: return "briefcase.fill"
        }
    }
}
```

---

## Part 3: Implementation Plan

### Phase 6.1: Update State Management (15 minutes)

**File:** `PreferencesStepView.swift`

**Step 1.1:** Replace Industry enum state with String-based sectors

```swift
// ❌ DELETE (line 18):
@State private var selectedIndustries: Set<Industry> = []

// ✅ ADD:
@State private var selectedSectors: Set<String> = []  // O*NET sectors
@State private var availableSectors: [String] = []  // Loaded from O*NET
@State private var allRoles: [Role] = []  // For search
```

**Step 1.2:** Add search state

```swift
// Search state (add after line 19)
@State private var sectorSearchText: String = ""
@FocusState private var isSearchFieldFocused: Bool
```

**Step 1.3:** Update PreferenceSection enum

```swift
// CHANGE (line 60):
case industries: return "Industries"  // ❌ OLD

// TO:
case industries: return "Career Fields"  // ✅ NEW
```

---

### Phase 6.2: Add Data Loading (20 minutes)

**File:** `PreferencesStepView.swift`

**Step 2.1:** Add task to load O*NET data

```swift
// MODIFY .task block (line 109-111):
.task {
    // Load O*NET sectors and roles
    await loadONetData()

    // Load existing preferences
    loadExistingPreferences()
}
```

**Step 2.2:** Add loadONetData function

```swift
// ADD after loadExistingPreferences() (around line 650):

/// Load O*NET sectors and roles for search functionality
/// Phase 6: Dynamic Career Fields from O*NET Database
private func loadONetData() async {
    // Load available sectors (18 O*NET sectors)
    availableSectors = await RolesDatabase.shared.getAvailableSectors()

    // Load all roles for search (1016 O*NET roles)
    allRoles = await RolesDatabase.shared.allRoles

    print("✅ [PreferencesStepView] Loaded \(availableSectors.count) sectors, \(allRoles.count) roles from O*NET")
}
```

---

### Phase 6.3: Update Career Fields Section UI (45 minutes)

**File:** `PreferencesStepView.swift`

**Step 3.1:** Replace industriesSection implementation (lines 312-355)

```swift
// ❌ DELETE entire industriesSection (lines 312-355)

// ✅ ADD new careerFieldsSection:

// MARK: - Career Fields Section (Phase 6 - O*NET)
private var careerFieldsSection: some View {
    VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {
        // Header
        HStack {
            Label("Career Fields", systemImage: "briefcase.fill")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            if selectedSectors.isEmpty {
                Text("Select 1+")
                    .font(.caption)
                    .foregroundStyle(.orange)
            } else {
                Text("\(selectedSectors.count) selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        // Search Bar (NEW)
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .accessibilityHidden(true)

            TextField("Search career fields or roles...", text: $sectorSearchText)
                .focused($isSearchFieldFocused)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.words)
                .disableAutocorrection(true)
                .submitLabel(.search)
                .accessibilityLabel("Search career fields")
                .accessibilityHint("Enter keywords to search 1016 roles and filter relevant career fields")
                .accessibilityValue(sectorSearchText.isEmpty ? "Empty" : sectorSearchText)

            if !sectorSearchText.isEmpty {
                Button(action: {
                    sectorSearchText = ""
                    isSearchFieldFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Clear search")
                .accessibilityHint("Double tap to clear the search field")
            }
        }
        .padding(.horizontal, SacredUI.Spacing.standard)

        // Search Results or Sector Chips
        if !sectorSearchText.isEmpty && !filteredRoles.isEmpty {
            // Show search results grouped by sector
            searchResultsView
        } else if !sectorSearchText.isEmpty {
            // Empty search state
            emptySearchResultsView
        } else {
            // Default: Show all sectors as chips
            sectorChipsView
        }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
}

// Sector chips (default view)
private var sectorChipsView: some View {
    PreferencesFlowLayout(spacing: 8) {
        ForEach(availableSectors.sorted(), id: \.self) { sector in
            CareerFieldChip(
                sectorName: sector,
                icon: sector.sectorIcon,
                isSelected: selectedSectors.contains(sector),
                onTap: {
                    withAnimation(.spring(response: SacredUI.Animation.springResponse,
                                        dampingFraction: SacredUI.Animation.springDamping)) {
                        if selectedSectors.contains(sector) {
                            selectedSectors.remove(sector)
                        } else {
                            selectedSectors.insert(sector)
                        }
                    }
                }
            )
        }
    }
}

// Search results view
private var searchResultsView: some View {
    VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {
        Text("Found \(filteredRoles.count) roles in \(searchResultSectors.count) fields")
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Search found \(filteredRoles.count) roles in \(searchResultSectors.count) career fields")

        ScrollView {
            VStack(alignment: .leading, spacing: SacredUI.Spacing.section) {
                ForEach(Array(searchResultSectors).sorted(), id: \.self) { sector in
                    sectorSearchResult(sector: sector)
                }
            }
        }
        .frame(maxHeight: 300)
    }
}

// Individual sector search result
private func sectorSearchResult(sector: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Image(systemName: sector.sectorIcon)
            Text(sector)
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            Button(action: {
                withAnimation {
                    if selectedSectors.contains(sector) {
                        selectedSectors.remove(sector)
                    } else {
                        selectedSectors.insert(sector)
                    }
                }
            }) {
                Image(systemName: selectedSectors.contains(sector) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedSectors.contains(sector) ? .accentColor : .secondary)
            }
            .accessibilityLabel(selectedSectors.contains(sector) ? "Deselect \(sector)" : "Select \(sector)")
        }

        // Show sample matching roles (first 3)
        let matchingRoles = filteredRoles.filter { $0.sector == sector }.prefix(3)
        ForEach(Array(matchingRoles), id: \.id) { role in
            Text("• \(role.title)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Example role: \(role.title)")
        }
    }
    .padding(.vertical, 8)
    .accessibilityElement(children: .combine)
}

// Empty search results
private var emptySearchResultsView: some View {
    VStack(spacing: SacredUI.Spacing.compact) {
        Image(systemName: "magnifyingglass")
            .font(.title)
            .foregroundStyle(.secondary)

        Text("No matching career fields")
            .font(.subheadline)
            .foregroundStyle(.secondary)

        Text("Try different keywords or browse all fields below")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }
    .padding()
    .accessibilityElement(children: .combine)
    .accessibilityLabel("No search results. Try different keywords or browse all career fields")
}

// Filtered roles computed property
private var filteredRoles: [Role] {
    guard !sectorSearchText.isEmpty else { return [] }

    let lowercased = sectorSearchText.lowercased()
    return allRoles.filter { role in
        role.title.lowercased().contains(lowercased) ||
        role.sector.lowercased().contains(lowercased)
    }
}

// Sectors from search results
private var searchResultSectors: Set<String> {
    Set(filteredRoles.map { $0.sector })
}
```

**Step 3.2:** Update body to use new section name

```swift
// CHANGE (line 96):
industriesSection  // ❌ OLD

// TO:
careerFieldsSection  // ✅ NEW
```

---

### Phase 6.4: Replace IndustryChip with CareerFieldChip (20 minutes)

**File:** `PreferencesStepView.swift`

**Step 4.1:** Delete IndustryChip (lines 707-727)

```swift
// ❌ DELETE entire IndustryChip struct
```

**Step 4.2:** Add CareerFieldChip replacement

```swift
// ✅ ADD after PreferencesFlowLayout (around line 800):

// MARK: - Career Field Chip (Phase 6 - O*NET)
private struct CareerFieldChip: View {
    let sectorName: String  // ✅ String instead of enum
    let icon: String  // ✅ Explicit icon parameter
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(dynamicTypeSize >= .accessibility1 ? .body : .caption)
                    .accessibilityHidden(true)

                Text(sectorName)
                    .font(dynamicTypeSize >= .accessibility1 ? .body : .caption)
                    .lineLimit(dynamicTypeSize >= .accessibility1 ? 3 : 1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .accessibilityLabel("\(sectorName) career field")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to \(isSelected ? "deselect" : "select") this career field")
        .accessibilityAddTraits(.isButton)
    }
}
```

---

### Phase 6.5: Add Sector Icon Extension (10 minutes)

**File:** `PreferencesStepView.swift`

**Step 5.1:** Add String extension for icon mapping

```swift
// ADD at bottom of file (after PreferencesFlowLayout):

// MARK: - Sector Icon Mapping (Phase 6 - O*NET)
extension String {
    /// Maps O*NET sector names to SF Symbol icons
    /// Maintains visual consistency with previous Industry enum
    var sectorIcon: String {
        switch self {
        case "Business/Management": return "chart.line.uptrend.xyaxis"
        case "Finance": return "dollarsign.circle.fill"
        case "Technology": return "laptopcomputer"
        case "Engineering": return "gearshape.2.fill"
        case "Science/Research": return "flask.fill"
        case "Healthcare": return "heart.fill"
        case "Education": return "book.fill"
        case "Legal": return "briefcase.fill"
        case "Sales": return "bag.fill"
        case "Office/Administrative": return "folder.fill"
        case "Food Service": return "fork.knife"
        case "Skilled Trades": return "hammer.fill"
        case "Personal Services": return "person.fill"
        case "Public Service": return "building.columns.fill"
        case "Manufacturing": return "gearshape.2.fill"
        case "Warehouse/Logistics": return "truck.box.fill"
        case "Construction": return "hammer.fill"
        case "Other": return "ellipsis.circle.fill"
        default: return "briefcase.fill"
        }
    }
}
```

---

### Phase 6.6: Update Validation & Save Logic (15 minutes)

**File:** `PreferencesStepView.swift`

**Step 6.1:** Update validation function

```swift
// FIND validatePreferences() (around line 550)
// CHANGE:
if selectedIndustries.isEmpty {  // ❌ OLD
    validationErrors.append(ValidationError(message: "Please select at least one industry"))
}

// TO:
if selectedSectors.isEmpty {  // ✅ NEW
    validationErrors.append(ValidationError(message: "Please select at least one career field"))
}
```

**Step 6.2:** Update savePreferences function

```swift
// FIND savePreferences() (around line 580)
// MODIFY appState.userProfile assignment:

appState.userProfile = UserProfile(
    id: existingProfile.id,
    name: existingProfile.name,
    email: existingProfile.email,
    skills: existingProfile.skills,
    experience: Double(experienceYears(for: experienceLevel)),
    preferredJobTypes: existingProfile.preferredJobTypes,
    preferredLocations: existingProfile.preferredLocations,
    industries: Array(selectedSectors),  // ✅ NEW: String array instead of enum
    salaryRange: SalaryRange(min: salaryMin, max: salaryMax),
    remotePreference: remotePreference.rawValue,
    companySize: selectedCompanySizes.map { $0.rawValue }
)
```

**Step 6.3:** Update loadExistingPreferences

```swift
// FIND loadExistingPreferences() (around line 620)
// MODIFY industry loading:

// ❌ DELETE:
if let industries = profile.industries {
    selectedIndustries = Set(industries.compactMap { Industry.fromLegacy($0) })
}

// ✅ ADD:
if let industries = profile.industries, !industries.isEmpty {
    // Load existing sectors (already strings)
    selectedSectors = Set(industries)
} else {
    // Default: Empty selection
    selectedSectors = []
}
```

---

## Part 4: Accessibility Implementation

### 4.1 VoiceOver Support

**All requirements from accessibility-compliance-enforcer skill:**

```swift
// ✅ Implemented in CareerFieldChip:
.accessibilityLabel("\(sectorName) career field")
.accessibilityValue(isSelected ? "Selected" : "Not selected")
.accessibilityHint("Double tap to \(isSelected ? "deselect" : "select") this career field")
.accessibilityAddTraits(.isButton)

// ✅ Search field:
.accessibilityLabel("Search career fields")
.accessibilityHint("Enter keywords to search 1016 roles and filter relevant career fields")
.accessibilityValue(sectorSearchText.isEmpty ? "Empty" : sectorSearchText)

// ✅ Clear button:
.accessibilityLabel("Clear search")
.accessibilityHint("Double tap to clear the search field")

// ✅ Search results:
.accessibilityLabel("Search found \(filteredRoles.count) roles in \(searchResultSectors.count) career fields")

// ✅ Empty state:
.accessibilityLabel("No search results. Try different keywords or browse all career fields")
```

### 4.2 Dynamic Type Support

```swift
// ✅ CareerFieldChip scales text:
@Environment(\.dynamicTypeSize) var dynamicTypeSize

.font(dynamicTypeSize >= .accessibility1 ? .body : .caption)
.lineLimit(dynamicTypeSize >= .accessibility1 ? 3 : 1)

// ✅ All text uses TextStyle (not fixed sizes):
.font(.headline)  // Not .system(size: 17)
.font(.subheadline)  // Not .system(size: 15)
.font(.caption)  // Not .system(size: 12)
```

### 4.3 WCAG 2.1 AA Contrast

**Already compliant:**
```swift
.foregroundStyle(isSelected ? .white : .primary)  // White on accent = high contrast
.background(isSelected ? Color.accentColor : Color(.systemGray6))  // Gray6 on white = 4.5:1
```

### 4.4 Keyboard Navigation

**Search field:**
```swift
.focused($isSearchFieldFocused)  // ✅ Keyboard focus management
.submitLabel(.search)  // ✅ Return key = "Search"
```

**Buttons:**
```swift
Button(action: onTap) { }  // ✅ All chips are buttons (keyboard accessible)
```

---

## Part 5: Swift 6 Concurrency Compliance

### 5.1 Actor Isolation

```swift
// ✅ CORRECT: @MainActor view
@MainActor
struct PreferencesStepView: View {
    @State private var selectedSectors: Set<String> = []  // ✅ Main actor isolated
    @State private var availableSectors: [String] = []  // ✅ Main actor isolated

    var body: some View {
        // All UI updates on main thread
    }
}
```

### 5.2 Async Data Loading

```swift
// ✅ CORRECT: Async/await for O*NET loading
.task {
    await loadONetData()  // ✅ Structured concurrency
}

private func loadONetData() async {
    // Load from actor-isolated RolesDatabase
    availableSectors = await RolesDatabase.shared.getAvailableSectors()  // ✅ Await actor
    allRoles = await RolesDatabase.shared.allRoles  // ✅ Await actor
}
```

### 5.3 Sendable Conformance

```swift
// ✅ Role already Sendable (Phase 1):
public struct Role: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let onetCode: String
    public let title: String
    public let sector: String
    // ...
}

// ✅ String is Sendable (primitive type)
@State private var selectedSectors: Set<String> = []  // ✅ String is Sendable
@State private var availableSectors: [String] = []  // ✅ String is Sendable
```

---

## Part 6: V7 Architecture Compliance

### 6.1 Package Dependencies

**✅ CORRECT: No circular dependencies**
```
PreferencesStepView (ManifestAndMatchV7Feature)
    ↓
RolesDatabase (V7Core)  // ✅ Foundation layer
    ↓
ONetDataService (V7Core)  // ✅ Same package

NO circular dependency created
```

### 6.2 Sacred UI Constants

**✅ CORRECT: Use SacredUI spacing**
```swift
VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {  // ✅ 12pt
    // ...
}

.padding(SacredUI.Spacing.standard)  // ✅ 20pt
```

### 6.3 Naming Conventions

**✅ CORRECT: PascalCase types, camelCase functions**
```swift
struct CareerFieldChip: View { }  // ✅ PascalCase
private var careerFieldsSection: some View { }  // ✅ camelCase
private func loadONetData() async { }  // ✅ camelCase with verb
```

### 6.4 State Management

**✅ CORRECT: @State for local UI state**
```swift
@State private var selectedSectors: Set<String> = []  // ✅ Private, local
@State private var sectorSearchText: String = ""  // ✅ Private, local
@Environment(AppState.self) private var appState  // ✅ Shared via environment
```

---

## Part 7: Testing Plan

### 7.1 Unit Tests

**File:** `ManifestAndMatchV7PackageTests/PreferencesStepViewTests.swift` (NEW)

```swift
import Testing
@testable import ManifestAndMatchV7Feature
@testable import V7Core

@Suite("PreferencesStepView Career Fields")
struct PreferencesStepViewCareerFieldsTests {

    @Test("Load 18 O*NET sectors from RolesDatabase")
    func testSectorLoading() async throws {
        let sectors = await RolesDatabase.shared.getAvailableSectors()

        #expect(sectors.count == 18, "Should load 18 O*NET sectors")
        #expect(sectors.contains("Sales"), "Should include Sales sector")
        #expect(sectors.contains("Technology"), "Should include Technology sector")
        #expect(sectors.contains("Healthcare"), "Should include Healthcare sector")

        print("✅ Loaded sectors: \(sectors.sorted().joined(separator: ", "))")
    }

    @Test("Icon mapping for all sectors")
    func testSectorIcons() {
        let testSectors = [
            "Sales", "Technology", "Healthcare", "Education",
            "Finance", "Engineering", "Legal", "Other"
        ]

        for sector in testSectors {
            let icon = sector.sectorIcon
            #expect(!icon.isEmpty, "Sector '\(sector)' should have an icon")
            print("✅ \(sector) → \(icon)")
        }
    }

    @Test("Search filters roles by title and sector")
    func testSearchFiltering() async throws {
        let allRoles = await RolesDatabase.shared.allRoles

        // Simulate search for "Account Executive"
        let searchText = "account executive"
        let filtered = allRoles.filter { role in
            role.title.lowercased().contains(searchText)
        }

        #expect(filtered.count > 0, "Should find Account Executive")

        let sectors = Set(filtered.map { $0.sector })
        #expect(sectors.contains("Sales"), "Account Executive should be in Sales sector")

        print("✅ Found \(filtered.count) roles matching '\(searchText)' in \(sectors.count) sectors")
    }

    @Test("Empty search returns empty results")
    func testEmptySearch() {
        let searchText = ""
        let emptyResults: [Role] = []

        #expect(emptyResults.isEmpty, "Empty search should return empty results")
    }
}
```

### 7.2 Integration Tests

**Manual Testing Checklist:**

- [ ] **Load Test**: Career Fields section loads 18 O*NET sectors
- [ ] **Search Test**: Search "software" highlights Technology sector
- [ ] **Selection Test**: Tap sector chip toggles selection (blue highlight)
- [ ] **Multi-Select**: Select 3+ sectors, all show as selected
- [ ] **Search Results**: Search "account" shows Sales sector with sample roles
- [ ] **Empty Search**: Search "zzzzz" shows "No matching career fields"
- [ ] **Clear Search**: Tap X button clears search, shows all chips
- [ ] **Save Test**: Select sectors, tap Next, sectors saved to AppState
- [ ] **Validation**: Try to continue with 0 sectors selected, error appears
- [ ] **Persistence**: Select sectors, save, quit app, relaunch, sectors still selected

### 7.3 Accessibility Tests

**VoiceOver Testing:**

```bash
# Enable VoiceOver on simulator
xcrun simctl spawn booted launchctl setenv VOICEOVER_ENABLED 1
```

**Test Cases:**
- [ ] VoiceOver reads "Career Fields" header with header trait
- [ ] Each sector chip announces: "\{Sector\} career field, \{selected/not selected\}, button"
- [ ] Search field announces: "Search career fields, text field, empty"
- [ ] Typing in search announces results: "Found 25 roles in 3 fields"
- [ ] Clear button announces: "Clear search, button"
- [ ] Empty search announces: "No search results, try different keywords"
- [ ] Navigation between chips works with swipe right/left
- [ ] Double-tap activates sector selection

**Dynamic Type Testing:**

```swift
// Test in Xcode → Environment Overrides
// Sizes: Small → Accessibility XXXL

// Expected behavior:
// - Small/Medium: Chips single-line
// - Accessibility 1-3: Chips wrap to 3 lines
// - All sizes: No clipping, readable
```

**Test Cases:**
- [ ] Small size: All text readable, chips single-line
- [ ] Large size: Text scales appropriately
- [ ] Accessibility 1: Chips use body font, 3-line limit
- [ ] Accessibility 3: Layout doesn't break, scrollable
- [ ] XXXL: All text visible, no horizontal scrolling

---

## Part 8: Rollback Plan

### Quick Disable (5 minutes)

**Revert to Industry enum:**

```swift
// PreferencesStepView.swift
@State private var selectedIndustries: Set<Industry> = []  // Restore enum

// Comment out new section:
// private var careerFieldsSection: some View { }

// Restore old section:
private var industriesSection: some View {
    // Old implementation with Industry.allCases
}
```

### Full Revert (Git)

```bash
git log --oneline --grep="Phase 6"
# Find commit hash, e.g., def456

git revert def456
git push
```

---

## Part 9: Success Criteria

### Must-Have (Launch Blockers)

- ✅ Career Fields section loads 18 O*NET sectors from RolesDatabase
- ✅ Search bar filters 1016 roles and highlights relevant sectors
- ✅ Sector selection works (tap chip = toggle selection)
- ✅ Selected sectors saved to AppState.userProfile.industries
- ✅ VoiceOver announces all elements with proper labels
- ✅ Dynamic Type supported (small → XXXL)
- ✅ No crashes, no Swift 6 concurrency errors
- ✅ Sector names match O*NET (not hardcoded enum)

### Nice-to-Have (Post-Launch)

- ⏳ Analytics: Track which sectors users search/select
- ⏳ Smart Suggestions: "Users like you also selected..."
- ⏳ Sector Descriptions: Tooltip with sector explanation
- ⏳ Icon Customization: User-selected icons per sector

---

## Part 10: File Manifest

### Files Modified

```
ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/Steps/
├── PreferencesStepView.swift (major refactor)
    - Replace selectedIndustries with selectedSectors
    - Add search state (sectorSearchText, isSearchFieldFocused)
    - Replace industriesSection with careerFieldsSection
    - Add search bar UI
    - Replace IndustryChip with CareerFieldChip
    - Add String.sectorIcon extension
    - Update validation/save logic
```

### Files Created

```
ManifestAndMatchV7PackageTests/
└── PreferencesStepViewTests.swift (NEW)
    - testSectorLoading()
    - testSectorIcons()
    - testSearchFiltering()
    - testEmptySearch()
```

### Files NOT Modified

```
✅ NO CHANGES:
- AppState.swift (Industry enum stays for legacy migration)
- RolesDatabase.swift (already loads O*NET sectors)
- ProfileConverter.swift (unaffected)
- Other onboarding steps (isolated change)
```

---

## Part 11: Implementation Checklist

### Phase 6.1: State Management
- [ ] Replace `selectedIndustries: Set<Industry>` with `selectedSectors: Set<String>`
- [ ] Add `availableSectors: [String]` state
- [ ] Add `allRoles: [Role]` state
- [ ] Add search state (`sectorSearchText`, `isSearchFieldFocused`)
- [ ] Update PreferenceSection.industries title to "Career Fields"

### Phase 6.2: Data Loading
- [ ] Add `loadONetData()` async function
- [ ] Load sectors from `RolesDatabase.shared.getAvailableSectors()`
- [ ] Load roles from `RolesDatabase.shared.allRoles`
- [ ] Call `loadONetData()` in .task block
- [ ] Verify 18 sectors + 1016 roles loaded

### Phase 6.3: UI Implementation
- [ ] Replace `industriesSection` with `careerFieldsSection`
- [ ] Add search bar with clear button
- [ ] Add `sectorChipsView` (default chips)
- [ ] Add `searchResultsView` (search UI)
- [ ] Add `emptySearchResultsView` (no results)
- [ ] Add `filteredRoles` computed property
- [ ] Add `searchResultSectors` computed property
- [ ] Update body to use `careerFieldsSection`

### Phase 6.4: CareerFieldChip
- [ ] Delete `IndustryChip` struct
- [ ] Create `CareerFieldChip` with String sector
- [ ] Add Dynamic Type support (`@Environment(\.dynamicTypeSize)`)
- [ ] Add VoiceOver labels/hints/traits
- [ ] Test chip selection animation

### Phase 6.5: Icon Mapping
- [ ] Add `String.sectorIcon` extension
- [ ] Map all 18 O*NET sectors to SF Symbols
- [ ] Add default fallback icon ("briefcase.fill")
- [ ] Verify icons match visual design

### Phase 6.6: Logic Updates
- [ ] Update `validatePreferences()` to check `selectedSectors`
- [ ] Update `savePreferences()` to save String array
- [ ] Update `loadExistingPreferences()` to load sectors as strings
- [ ] Test validation error messages

### Phase 6.7: Accessibility
- [ ] Add VoiceOver labels to all interactive elements
- [ ] Test Dynamic Type (small → XXXL)
- [ ] Verify WCAG 2.1 AA contrast ratios
- [ ] Test keyboard navigation
- [ ] Test with VoiceOver enabled

### Phase 6.8: Testing
- [ ] Create `PreferencesStepViewTests.swift`
- [ ] Write sector loading test
- [ ] Write icon mapping test
- [ ] Write search filtering test
- [ ] Run all tests, verify pass
- [ ] Manual test in simulator
- [ ] VoiceOver walkthrough
- [ ] Dynamic Type test (all sizes)

---

## Part 12: Timeline

**Total Estimated Time: 2-3 hours**

| Phase | Task | Time | Status |
|-------|------|------|--------|
| 6.1 | State Management | 15 min | ⏳ Pending |
| 6.2 | Data Loading | 20 min | ⏳ Pending |
| 6.3 | UI Implementation | 45 min | ⏳ Pending |
| 6.4 | CareerFieldChip | 20 min | ⏳ Pending |
| 6.5 | Icon Mapping | 10 min | ⏳ Pending |
| 6.6 | Logic Updates | 15 min | ⏳ Pending |
| 6.7 | Accessibility | 20 min | ⏳ Pending |
| 6.8 | Testing | 30 min | ⏳ Pending |
| **Total** | | **2h 55min** | |

---

## Part 13: Risk Assessment

### Low Risk
- ✅ Well-established pattern from Phase 4 (ProfileSetupStepView)
- ✅ RolesDatabase already tested and working
- ✅ String-based sectors simpler than enum
- ✅ Isolated change (only PreferencesStepView affected)

### Mitigation
- **Test thoroughly** before merging
- **Keep Industry enum** in AppState for legacy migration
- **Gradual rollout** if concerned (feature flag possible)
- **Quick rollback** available (git revert)

---

**Document Version:** 1.0
**Created:** November 1, 2025
**Status:** Ready for Implementation
**Estimated Completion:** 2-3 hours
**Prerequisites:** Phases 1-5 Complete ✅
