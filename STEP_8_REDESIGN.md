# Step 8 Onboarding Redesign: Job Title Selection

## Current Problem
- Users select abstract sectors ("Construction", "Technology")
- Doesn't reflect how people think about jobs
- Ugly UI with sector chips
- Doesn't help Thompson Sampling match better

## Proposed Solution: "What roles interest you?"

---

## Visual Design

```
┌─────────────────────────────────────────────┐
│  Step 8 of 8                                │
│                                             │
│  What roles interest you?                   │
│  Select common roles or add specific titles │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  Popular Roles (tap to select)              │
│                                             │
│  ┌─────────────┐ ┌─────────────┐          │
│  │ Software    │ │ Sales       │          │
│  │ Engineer    │ │ Manager     │ (blue)  │
│  └─────────────┘ └─────────────┘          │
│                                             │
│  ┌─────────────┐ ┌─────────────┐          │
│  │ Product     │ │ Account     │          │
│  │ Manager     │ │ Executive   │          │
│  └─────────────┘ └─────────────┘          │
│                                             │
│  ┌─────────────┐ ┌─────────────┐          │
│  │ Teacher     │ │ Nurse       │          │
│  │             │ │             │          │
│  └─────────────┘ └─────────────┘          │
│                                             │
│  ┌─────────────┐ ┌─────────────┐          │
│  │ Data        │ │ Marketing   │          │
│  │ Analyst     │ │ Manager     │          │
│  └─────────────┘ └─────────────┘          │
│                                             │
│  ┌─────────────┐ ┌─────────────┐          │
│  │ Project     │ │ Customer    │          │
│  │ Manager     │ │ Success     │          │
│  └─────────────┘ └─────────────┘          │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  Add Specific Role                          │
│  ┌─────────────────────────────────────┐  │
│  │ Search 1016 job titles...           │  │
│  └─────────────────────────────────────┘  │
│                                             │
│  Recent/Suggested:                          │
│  • Executive Assistant                      │
│  • Operations Manager                       │
│  • Financial Analyst                        │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│  Selected Roles (3):                        │
│  ┌───────────────────┐                     │
│  │ Sales Manager  ✕  │                     │
│  └───────────────────┘                     │
│  ┌───────────────────┐                     │
│  │ Software Engineer ✕│                     │
│  └───────────────────┘                     │
│  ┌───────────────────┐                     │
│  │ Product Manager ✕  │                     │
│  └───────────────────┘                     │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│           [Continue →]                      │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Interaction Flow

### 1. Quick Select (Popular Roles)
- 10 pre-defined popular roles shown as large chips
- Tap to toggle selection (blue = selected, gray = unselected)
- Instant visual feedback

### 2. Search (Specific Roles)
- Search bar with autocomplete from 1016 O*NET titles
- As user types "Account Ex..." → Shows "Account Executive" suggestion
- Tap suggestion to add to selected roles
- Recent searches persist for quick re-access

### 3. Selected Roles Display
- Bottom section shows all selected roles
- Each chip has X to remove
- Minimum 1 role required
- Maximum 10 roles (prevents analysis paralysis)

---

## Popular Roles List (Pre-defined)

**Top 10 roles covering all sectors:**
1. Software Engineer (Technology)
2. Sales Manager (Sales)
3. Product Manager (Business/Management)
4. Account Executive (Sales)
5. Teacher (Education)
6. Nurse (Healthcare)
7. Data Analyst (Technology)
8. Marketing Manager (Marketing)
9. Project Manager (Business/Management)
10. Customer Success Manager (Sales)

**Selection criteria:**
- High-demand roles (lots of job postings)
- Diverse sectors (not all tech)
- Clear titles (no ambiguity)
- Recognizable to most users

---

## Technical Implementation

### Data Flow
```
User selects "Sales Manager"
    ↓
Look up in RolesDatabase (O*NET 1016 titles)
    ↓
Find: "Sales Managers" (O*NET code: 11-2022.00)
    ↓
Extract:
  - Title: "Sales Managers"
  - Sector: "Sales" (mapped)
  - Skills: ["Negotiation", "Persuasion", "Sales", ...]
    ↓
Store in AppState.preferences.preferredJobTypes: ["Sales Managers"]
    ↓
Auto-derive sectors in background:
  AppState.preferences.industries: ["Sales"]
    ↓
Thompson Sampling uses:
  - Title matching (boost jobs with "Sales Manager" in title)
  - Skills matching (boost jobs requiring sales skills)
  - Sector matching (boost jobs in Sales sector)
```

### Code Structure

**New State:**
```swift
// PreferencesStepView.swift
@State private var selectedJobTitles: Set<String> = []  // User selections
@State private var popularRoles: [String] = [...]       // Pre-defined 10
@State private var searchQuery: String = ""             // Search input
@State private var searchResults: [Role] = []           // O*NET matches
```

**Search Logic:**
```swift
func searchRoles(_ query: String) async {
    guard query.count >= 2 else { return }

    let results = await RolesDatabase.shared.findRoles(matching: query)
    searchResults = Array(results.prefix(10))  // Top 10 matches
}
```

**Save Logic:**
```swift
func saveJobTitles() {
    // Store selected titles
    prefs.preferredJobTypes = Array(selectedJobTitles)

    // Auto-derive sectors from titles
    let sectors = selectedJobTitles.compactMap { title in
        roles.first(where: { $0.title == title })?.sector
    }
    prefs.industries = Set(sectors)

    // Save to AppState
    appState.preferences = prefs
}
```

---

## Advantages vs Current Design

| Current (Sectors) | Proposed (Job Titles) |
|-------------------|----------------------|
| Abstract categories | Concrete job titles |
| "Construction" | "Construction Manager", "Electrician" |
| Ugly sector chips | Clean job title cards |
| No Thompson benefit | Direct title matching |
| 18 sectors to choose | 1016+ titles available |
| Users confused | Users understand |

---

## UI Components

### PopularRoleCard
```swift
struct PopularRoleCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.15))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
```

### SearchableRoleField
```swift
struct SearchableRoleField: View {
    @Binding var query: String
    let suggestions: [Role]
    let onSelect: (Role) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search 1016 job titles...", text: $query)
                .textFieldStyle(.roundedBorder)
                .onChange(of: query) { _, new in
                    Task { await searchRoles(new) }
                }

            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(suggestions) { role in
                        Button(action: { onSelect(role) }) {
                            HStack {
                                Text(role.title)
                                Spacer()
                                Text(role.sector)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
```

### SelectedRoleChip
```swift
struct SelectedRoleChip: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15))

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(20)
    }
}
```

---

## Migration Plan

1. ✅ Keep existing O*NET infrastructure (RolesDatabase, 1016 titles)
2. ✅ Replace Career Fields UI with Job Titles UI
3. ✅ Keep AppState.preferences.industries for backward compatibility
4. ✅ Auto-derive sectors from selected job titles
5. ✅ Thompson Sampling gets better data (actual job titles vs vague sectors)

---

## Open Questions

1. **How many popular roles?** (Proposed: 10)
2. **Should we group by sector?** (Proposed: No, flat list)
3. **Min/max selections?** (Proposed: 1 min, 10 max)
4. **Should sectors still be visible?** (Proposed: No, derived in background)
5. **Search behavior?** (Proposed: Autocomplete with fuzzy matching)

---

## Estimated Implementation

- Remove sector grid code: 50 lines
- Add popular roles cards: 100 lines
- Add searchable role field: 150 lines
- Add selected chips display: 50 lines
- Update save logic: 30 lines
- **Total: ~380 lines, ~2 hours**

---

**Next Steps:**
1. Get approval on design
2. Implement UI components
3. Update save/load logic
4. Test with real user flow
5. Verify Thompson Sampling uses job titles properly
