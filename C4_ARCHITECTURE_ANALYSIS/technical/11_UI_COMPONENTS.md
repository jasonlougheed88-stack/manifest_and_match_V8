# 11. UI Components

**Complete SwiftUI View Catalog for Manifest & Match V8**

## Overview

The application uses **28 primary SwiftUI views** following the **Model-View (MV) architecture pattern** (no ViewModels). All views are in `V7UI` package and follow strict @MainActor isolation for thread safety.

## View Hierarchy

```
AppRootView
├── HomeScreen (tab 1)
│   ├── DeckScreen
│   │   ├── JobCard
│   │   ├── SwipeOverlay
│   │   └── ExplainFitSheet
│   ├── QuestionCardView
│   └── StarredJobsView
├── ProfileScreen (tab 2)
│   ├── ProfileCreationFlow
│   │   ├── PersonalInfoStepView
│   │   ├── WorkExperienceCollectionStepView [🚨 BUG]
│   │   ├── EducationAndCertificationsStepView [🚨 BUG]
│   │   └── SkillsSelectionStepView
│   └── ProfileDetailView
├── CareerPathScreen (tab 3)
│   ├── CareerPathCard
│   ├── CareerPathDetailView
│   └── RecommendedJobsView
└── SettingsScreen (tab 4)
    ├── NotificationSettingsView
    ├── PrivacySettingsView
    └── AboutView
```

---

## Core Views

### 1. AppRootView
**Location**: `V7UI/Sources/V7UI/AppRootView.swift`
**Purpose**: Root container with TabView navigation

```swift
@MainActor
struct AppRootView: View {
    @StateObject private var dataManager = V7DataManager.shared
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, profile, careerPath, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
                .tag(Tab.home)

            ProfileScreen()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(Tab.profile)

            CareerPathScreen()
                .tabItem {
                    Label("Career Path", systemImage: "map")
                }
                .tag(Tab.careerPath)

            SettingsScreen()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .environment(\.managedObjectContext, dataManager.viewContext)
    }
}
```

**Lines**: 45
**Complexity**: Low

---

### 2. DeckScreen
**Location**: `V7UI/Sources/V7UI/JobDiscovery/DeckScreen.swift`
**Purpose**: Primary job discovery interface (swipeable card deck)

**Critical Sections**:
- Lines 89-145: Job fetching & Thompson scoring
- Lines 665-853: Swipe handling with 7-layer persistence

```swift
@MainActor
struct DeckScreen: View {
    @StateObject private var discoveryCoordinator = JobDiscoveryCoordinator()
    @State private var jobs: [RawJobData] = []
    @State private var currentIndex = 0
    @State private var swipeOffset: CGSize = .zero

    var body: some View {
        ZStack {
            ForEach(jobs.indices, id: \.self) { index in
                if index >= currentIndex {
                    JobCard(job: jobs[index])
                        .offset(x: index == currentIndex ? swipeOffset.width : 0)
                        .rotationEffect(.degrees(Double(swipeOffset.width / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    swipeOffset = gesture.translation
                                }
                                .onEnded { gesture in
                                    handleSwipe(gesture: gesture)
                                }
                        )
                }
            }
        }
        .task {
            await loadJobs()
        }
    }

    private func handleSwipe(gesture: DragGesture.Value) async {
        // 🔥 CRITICAL: 7-layer persistence (lines 665-853)
        let direction: SwipeDirection
        if gesture.translation.width > 100 {
            direction = .right
        } else if gesture.translation.width < -100 {
            direction = .left
        } else if gesture.translation.height < -100 {
            direction = .super
        } else {
            withAnimation { swipeOffset = .zero }
            return
        }

        // Create swipe record
        let swipe = SwipeRecord(context: dataManager.viewContext)
        swipe.id = UUID()
        swipe.jobID = jobs[currentIndex].id
        swipe.swipeDirection = direction.rawValue
        swipe.timestamp = Date()
        swipe.thompsonScore = thompsonScore
        swipe.sessionID = currentSessionID
        swipe.cardPosition = Int16(currentIndex)

        // Update Thompson arm (Bayesian update)
        if direction == .right || direction == .super {
            arm.alpha += 1
            arm.successCount += 1
        } else {
            arm.beta += 1
            arm.failureCount += 1
        }

        // Persist all changes atomically
        try? dataManager.viewContext.save()

        // Behavioral analysis
        await behavioralAnalyst.analyzeSession()

        // Advance to next card
        withAnimation {
            currentIndex += 1
            swipeOffset = .zero
        }
    }
}
```

**Lines**: 1,800+
**Complexity**: Very High
**Performance**: <60fps (16.67ms per frame)

**Sacred Constraints**:
- Thompson scoring: <10ms
- Swipe animation: 60fps
- Persistence: Atomic (all 7 layers)

---

### 3. JobCard
**Location**: `V7UI/Sources/V7UI/JobDiscovery/JobCard.swift`
**Purpose**: Individual job card with company, title, location, salary

```swift
@MainActor
struct JobCard: View {
    let job: RawJobData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Company logo placeholder
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(job.company.prefix(1))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(job.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .accessibilityLabel("Job title: \(job.title)")

                Text(job.company)
                    .font(.headline)
                    .foregroundColor(.secondary)

                if let location = job.location {
                    Label(location, systemImage: "mappin.circle")
                        .font(.subheadline)
                }

                if let salary = job.salary {
                    Label(salary.displayString, systemImage: "dollarsign.circle")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }

            Divider()

            Text(job.description)
                .font(.body)
                .lineLimit(5)
                .foregroundColor(.secondary)

            Spacer()

            HStack {
                Button("Details") {
                    // Show full job details
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Explain Fit") {
                    // Show AI explanation
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 350, height: 600)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
```

**Lines**: 120
**Complexity**: Low
**Accessibility**: ✅ Full VoiceOver support

---

### 4. ProfileScreen
**Location**: `V7UI/Sources/V7UI/Profile/ProfileScreen.swift`
**Purpose**: User profile display and editing

**Critical Bug** (Lines 148-183): Dual persistence to Core Data + SwiftData

```swift
@MainActor
struct ProfileScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var profiles: FetchedResults<UserProfile>

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)

                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }

                Section("Work Experience") {
                    NavigationLink("Edit Experience") {
                        WorkExperienceCollectionStepView()
                    }
                }

                Section("Education") {
                    NavigationLink("Edit Education") {
                        EducationAndCertificationsStepView()
                    }
                }

                Section("Skills") {
                    NavigationLink("Edit Skills") {
                        SkillsSelectionStepView()
                    }
                }

                Section {
                    Button("Save Profile") {
                        saveProfile()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
    }

    private func saveProfile() {
        // 🔥 CRITICAL: Lines 148-183 (dual persistence)
        let profile = UserProfile(context: viewContext)
        profile.userID = UUID()
        profile.firstName = firstName
        profile.lastName = lastName
        profile.email = email
        profile.createdAt = Date()
        profile.updatedAt = Date()

        try? viewContext.save()  // Core Data

        // Also save to SwiftData (migration support)
        let profileSD = UserProfileSD()
        profileSD.firstName = firstName
        profileSD.lastName = lastName
        profileSD.email = email

        // TODO: Save profileSD to SwiftData context
    }
}
```

**Lines**: 280
**Complexity**: Medium

---

### 5. WorkExperienceCollectionStepView
**Location**: `V7UI/Sources/V7UI/ProfileCreation/WorkExperienceCollectionStepView.swift`
**Purpose**: Multi-step work experience collection

**🚨 CRITICAL BUG** (Line 145): Data only saved to @State, NOT Core Data

```swift
@MainActor
struct WorkExperienceCollectionStepView: View {
    @State private var experiences: [WorkExperienceData] = []  // ❌ Only in-memory
    @State private var isAddingNew = false

    var body: some View {
        List {
            ForEach(experiences) { exp in
                WorkExperienceRow(experience: exp)
            }
            .onDelete(perform: deleteExperience)

            Button("Add Experience") {
                isAddingNew = true
            }
        }
        .sheet(isPresented: $isAddingNew) {
            WorkExperienceForm { newExp in
                experiences.append(newExp)  // ❌ NEVER PERSISTED
            }
        }
    }

    private func deleteExperience(at offsets: IndexSet) {
        experiences.remove(atOffsets: offsets)  // ❌ ONLY @State
    }
}
```

**FIX REQUIRED**:
```swift
private func addExperience(_ exp: WorkExperienceData) {
    let context = dataManager.viewContext
    let entity = WorkExperience(context: context)
    entity.id = UUID()
    entity.jobTitle = exp.title
    entity.company = exp.company
    entity.startDate = exp.startDate
    entity.endDate = exp.endDate
    entity.isCurrent = exp.isCurrent
    entity.profile = currentUserProfile

    try? context.save()  // ✅ PERSIST TO CORE DATA
    experiences.append(exp)
}
```

**Lines**: 350
**Complexity**: High
**Bug Impact**: 🔴 CRITICAL (data loss)

---

### 6-28. Remaining Views (Summary)

| # | View | Location | Lines | Purpose | Bugs |
|---|------|----------|-------|---------|------|
| 6 | EducationAndCertificationsStepView | ProfileCreation/ | 280 | Education input | 🔴 Same bug as #5 |
| 7 | SkillsSelectionStepView | ProfileCreation/ | 420 | Skills picker | ✅ Working |
| 8 | QuestionCardView | CareerQuestions/ | 310 | AI question display | ✅ Working |
| 9 | ExplainFitSheet | JobDiscovery/ | 180 | Job fit explanation | ✅ Working |
| 10 | StarredJobsView | JobDiscovery/ | 220 | Saved jobs list | ✅ Working |
| 11 | CareerPathScreen | CareerPath/ | 380 | Career transitions | ✅ Working |
| 12 | CareerPathCard | CareerPath/ | 150 | Path summary card | ✅ Working |
| 13 | CareerPathDetailView | CareerPath/ | 420 | Path details | ✅ Working |
| 14 | SettingsScreen | Settings/ | 280 | App settings | 🟡 11 empty buttons |
| 15 | NotificationSettingsView | Settings/ | 190 | Notification prefs | ✅ Working |
| 16 | PrivacySettingsView | Settings/ | 230 | Privacy controls | ✅ Working |
| 17 | AboutView | Settings/ | 140 | App info | ✅ Working |
| 18 | SwipeOverlay | JobDiscovery/ | 95 | Swipe feedback | ✅ Working |
| 19 | JobDetailView | JobDiscovery/ | 520 | Full job details | ✅ Working |
| 20 | ResumeUploadView | Profile/ | 280 | PDF upload | ✅ Working |
| 21 | ResumeParseResultView | Profile/ | 190 | Parse results | ✅ Working |
| 22 | SkillBadge | Common/ | 45 | Skill pill UI | ✅ Working |
| 23 | LoadingView | Common/ | 60 | Loading spinner | ✅ Working |
| 24 | ErrorView | Common/ | 85 | Error display | ✅ Working |
| 25 | EmptyStateView | Common/ | 110 | Empty state | ✅ Working |
| 26 | OnboardingView | Onboarding/ | 450 | First-time flow | ✅ Working |
| 27 | WelcomeScreen | Onboarding/ | 180 | Welcome message | ✅ Working |
| 28 | PermissionsRequestView | Onboarding/ | 220 | System permissions | ✅ Working |

---

## Sacred UI Constants

**Location**: `V7UI/Sources/V7UI/Constants/SacredUI.swift`

```swift
public enum SacredUI {
    // Colors
    public static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    public static let secondaryTeal = Color(red: 0.0, green: 0.78, blue: 0.75)
    public static let accentGreen = Color(red: 0.2, green: 0.78, blue: 0.35)

    // Spacing
    public static let spacing8: CGFloat = 8
    public static let spacing16: CGFloat = 16
    public static let spacing24: CGFloat = 24
    public static let spacing32: CGFloat = 32

    // Corner Radius
    public static let cornerRadius12: CGFloat = 12
    public static let cornerRadius20: CGFloat = 20

    // Fonts
    public static let titleFont: Font = .system(size: 28, weight: .bold)
    public static let bodyFont: Font = .system(size: 16, weight: .regular)
    public static let captionFont: Font = .system(size: 12, weight: .regular)

    // Animation
    public static let standardDuration: TimeInterval = 0.3
    public static let swipeDuration: TimeInterval = 0.4
    public static let cardSpringResponse: Double = 0.5
    public static let cardSpringDamping: Double = 0.7
}
```

---

## Accessibility Implementation

All views follow **WCAG 2.1 AA standards**:

### VoiceOver Labels

```swift
Text(job.title)
    .accessibilityLabel("Job title: \(job.title)")
    .accessibilityHint("Swipe right to like, left to pass")

Button("Save") {
    saveProfile()
}
.accessibilityLabel("Save profile button")
.accessibilityHint("Double tap to save your changes")
```

### Dynamic Type Support

```swift
Text(job.description)
    .font(.body)  // ✅ Automatically scales
    .lineLimit(nil)  // ✅ No truncation with large text
```

### Minimum Touch Targets

```swift
Button("X") {
    dismiss()
}
.frame(minWidth: 44, minHeight: 44)  // ✅ WCAG minimum
```

### Color Contrast

All text meets **4.5:1 contrast ratio** (WCAG AA):
```swift
Text(content)
    .foregroundColor(.primary)  // ✅ Adapts to light/dark mode
    .background(Color(.systemBackground))  // ✅ Sufficient contrast
```

---

## Performance Optimization

### LazyVStack for Long Lists

```swift
// ✅ GOOD: Lazy loading
ScrollView {
    LazyVStack {
        ForEach(jobs) { job in
            JobRow(job: job)
        }
    }
}

// ❌ BAD: Renders all at once
VStack {
    ForEach(jobs) { job in
        JobRow(job: job)
    }
}
```

### View Identity for Animations

```swift
// ✅ GOOD: Stable identity
ForEach(jobs) { job in
    JobCard(job: job)
        .id(job.id)  // Explicit ID
}

// ❌ BAD: Array indices (unstable)
ForEach(jobs.indices, id: \.self) { index in
    JobCard(job: jobs[index])
}
```

---

## State Management Patterns

### @State for Local UI State

```swift
struct DeckScreen: View {
    @State private var swipeOffset: CGSize = .zero  // ✅ Ephemeral UI state
    @State private var currentIndex = 0            // ✅ Local to view
}
```

### @FetchRequest for Core Data

```swift
struct ProfileScreen: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserProfile.updatedAt, ascending: false)]
    ) var profiles: FetchedResults<UserProfile>

    var currentProfile: UserProfile? {
        profiles.first  // ✅ Automatically updates when Core Data changes
    }
}
```

### @Environment for Dependency Injection

```swift
struct ProfileScreen: View {
    @Environment(\.managedObjectContext) private var viewContext  // ✅ Injected

    func saveProfile() {
        let profile = UserProfile(context: viewContext)
        // ...
        try? viewContext.save()
    }
}
```

---

## Common Bugs & Anti-Patterns

### 🔴 Bug: Missing Persistence

```swift
// ❌ WRONG: Only updates @State
@State private var experiences: [WorkExperienceData] = []

func addExperience(_ exp: WorkExperienceData) {
    experiences.append(exp)  // Lost on restart
}
```

```swift
// ✅ CORRECT: Persist to Core Data
func addExperience(_ exp: WorkExperienceData) {
    let entity = WorkExperience(context: viewContext)
    entity.jobTitle = exp.title
    // ... set fields
    try? viewContext.save()  // Persisted
}
```

---

### 🟡 Bug: Empty Button Actions

Found in **SettingsScreen** (11 buttons):

```swift
// ❌ WRONG: No action
Button("Change Theme") {
    // TODO: Implement
}

// ✅ CORRECT: Action or disable
Button("Change Theme") {
    isShowingThemeSheet = true
}
```

---

## Testing Strategy

### SwiftUI Previews

```swift
struct JobCard_Previews: PreviewProvider {
    static var previews: some View {
        JobCard(job: mockJob)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        JobCard(job: mockJob)
            .preferredColorScheme(.dark)

        JobCard(job: mockJob)
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
    }
}
```

### UI Tests

```swift
class DeckScreenTests: XCTestCase {
    func testSwipeRight() throws {
        let app = XCUIApplication()
        app.launch()

        let card = app.otherElements["JobCard"]
        card.swipeRight()

        XCTAssertTrue(app.staticTexts["Next Job"].exists)
    }

    func testAccessibility() throws {
        let app = XCUIApplication()
        app.launch()

        let jobTitle = app.staticTexts.matching(identifier: "JobTitle").firstMatch
        XCTAssertTrue(jobTitle.isAccessibilityElement)
        XCTAssertNotNil(jobTitle.label)
    }
}
```

---

## Documentation References

- **SwiftUI Guide**: `Documentation/SWIFTUI_GUIDE.md`
- **Accessibility Checklist**: `Documentation/ACCESSIBILITY.md`
- **UI Testing**: `Documentation/UI_TESTING.md`
- **Sacred UI Constants**: `V7UI/Sources/V7UI/Constants/SacredUI.swift`
