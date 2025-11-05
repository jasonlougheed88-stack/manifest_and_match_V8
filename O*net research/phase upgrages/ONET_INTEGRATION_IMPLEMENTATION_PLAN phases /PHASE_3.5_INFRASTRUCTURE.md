# Phase 3.5: Phase 4-6 Infrastructure

**Part of**: O*NET Integration Implementation Plan  
**Document Version**: 1.0  
**Created**: October 29, 2025  
**Project**: ManifestAndMatch V8 (iOS 26)  
**Duration**: Week 7 (3 hours)  
**Priority**: P1 (Infrastructure for Phases 4-6)

---

## Phase 3.5: Phase 4-6 Infrastructure (Week 7)

**Purpose**: Build supporting infrastructure needed for Phases 4-6 O*NET integration
**Context**: Audit revealed 3 of 4 proposed components already exist (see `PHASE_3.5_CODEBASE_AUDIT_RESULTS.md`)
**Duration**: 3 hours (**REDUCED from 9 hours** - most components already implemented)
**Risk**: Low (isolated component, no core system changes)

### What Already Exists ✅

1. **ThompsonONetPerformanceTests** - Complete test suite (413 lines)
   - Location: `Packages/V7Thompson/Tests/V7ThompsonTests/ThompsonONetPerformanceTests.swift`
   - Tests all 5 O*NET factors + complete pipeline
   - Enforces P95 < 10ms, P50 < 6ms (sacred constraint)
   - Production-ready, CI/CD integrated

2. **A/B Testing Infrastructure** - Feature flag implemented
   - Location: `Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift:74`
   - `isONetScoringEnabled: Bool = false`
   - Validated in Phase 4 testing

3. **ONetCodeMapper** - Production-ready actor (894 occupations)
   - Location: `Packages/V7Services/Sources/V7Services/ONet/ONetCodeMapper.swift`
   - Singleton pattern (`ONetCodeMapper.shared`)
   - 4-tier matching strategy (exact → normalized → fuzzy → keyword)
   - Performance: <5ms cached, <50ms initial load
   - Accuracy: 85%+ on standard job titles
   - V7 architecture compliant (actor isolation, zero circular deps)

### What Needs to Be Built ⚙️

#### Task 1: ProfileCompletenessCard (3 hours) **ONLY REMAINING COMPONENT**

**Why**: Phase 4 Week 14 optional feature to help users understand profile completeness
**File**: `Packages/V7UI/Sources/V7UI/Cards/ProfileCompletenessCard.swift`

**Note on ONetCodeMapper**: Originally planned for Phase 3.5 (6 hours), but **already exists** in production-ready state. See `Packages/V7Services/Sources/V7Services/ONet/ONetCodeMapper.swift` for implementation.

**Implementation** (All 5 V7 Guardians Approved ✅):

```swift
import SwiftUI
import V7Core

/// Profile completeness card showing user profile field population
/// Helps users understand profile completion progress
/// Liquid Glass design (iOS 26)
///
/// **Architecture Notes**:
/// - Uses V7Core AppState environment (not custom \.userProfile key)
/// - Dual-profile color system (Amber→Teal gradient)
/// - Full accessibility support (VoiceOver)
/// - Completeness based on actual UserProfile schema
///
/// **Sacred Constraints**:
/// - v7-architecture-guardian: Uses AppState from V7Core, zero circular deps
/// - accessibility-compliance-enforcer: WCAG 2.1 AA, VoiceOver labels
/// - swift-concurrency-enforcer: @MainActor for UI thread safety
@available(iOS 26.0, *)
@MainActor
public struct ProfileCompletenessCard: View {

    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Completeness Calculation

    private var completenessPercentage: Double {
        guard let profile = appState.userProfile else { return 0.0 }

        var filledCount = 0
        let totalFields = 5

        // Field 1: Skills (any skills entered)
        if !profile.skills.isEmpty {
            filledCount += 1
        }

        // Field 2: Experience (years of experience)
        if profile.experience > 0 {
            filledCount += 1
        }

        // Field 3: Preferred Job Types
        if !profile.preferredJobTypes.isEmpty {
            filledCount += 1
        }

        // Field 4: Preferred Locations
        if !profile.preferredLocations.isEmpty {
            filledCount += 1
        }

        // Field 5: Salary Range
        if profile.salaryRange != nil {
            filledCount += 1
        }

        return Double(filledCount) / Double(totalFields)
    }

    private var completenessScore: Int {
        Int(completenessPercentage * 100)
    }

    private var missingFields: [String] {
        guard let profile = appState.userProfile else {
            return ["Skills", "Experience", "Job Types", "Locations", "Salary Range"]
        }

        var missing: [String] = []

        if profile.skills.isEmpty {
            missing.append("Skills")
        }
        if profile.experience == 0 {
            missing.append("Experience Level")
        }
        if profile.preferredJobTypes.isEmpty {
            missing.append("Preferred Job Types")
        }
        if profile.preferredLocations.isEmpty {
            missing.append("Preferred Locations")
        }
        if profile.salaryRange == nil {
            missing.append("Salary Range")
        }

        return missing
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(completenessGradient)
                    .font(.title3)

                Text("Profile Completeness")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(completenessScore)%")
                    .font(.title2.bold())
                    .foregroundStyle(completenessColor)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Profile completeness: \(completenessScore) percent")

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                        .frame(height: 12)

                    // Progress fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(completenessGradient)
                        .frame(width: geometry.size.width * completenessPercentage, height: 12)
                        .animation(.smooth(duration: 0.6), value: completenessPercentage)
                }
            }
            .frame(height: 12)
            .accessibilityHidden(true)  // Redundant with header percentage

            // Missing fields (if any)
            if !missingFields.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Complete your profile to improve matches:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ForEach(missingFields, id: \.self) { field in
                        HStack(spacing: 8) {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(field)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Missing field: \(field)")
                    }
                }
            } else {
                // Complete state
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)

                    Text("Your profile is complete!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Profile is complete")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Computed Styles

    /// Use V7 dual-profile color system (Amber→Teal)
    private var completenessColor: Color {
        DualProfileColorSystem.profileColor(blendRatio: completenessPercentage)
    }

    private var completenessGradient: LinearGradient {
        // Amber (0%) to Teal (100%)
        let startColor = DualProfileColorSystem.profileColor(blendRatio: 0.0)
        let endColor = DualProfileColorSystem.profileColor(blendRatio: completenessPercentage)

        return LinearGradient(
            colors: [startColor.opacity(0.8), endColor],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 26.0, *)
#Preview("Profile Completeness - 80%") {
    @Previewable @State var appState = AppState()

    ProfileCompletenessCard()
        .padding()
        .environment(appState)
        .onAppear {
            appState.userProfile = mockUserProfile(completeness: 0.8)
        }
}

@available(iOS 26.0, *)
#Preview("Profile Completeness - 40%") {
    @Previewable @State var appState = AppState()

    ProfileCompletenessCard()
        .padding()
        .environment(appState)
        .onAppear {
            appState.userProfile = mockUserProfile(completeness: 0.4)
        }
}

@available(iOS 26.0, *)
#Preview("Profile Completeness - 100%") {
    @Previewable @State var appState = AppState()

    ProfileCompletenessCard()
        .padding()
        .environment(appState)
        .onAppear {
            appState.userProfile = mockUserProfile(completeness: 1.0)
        }
}

private func mockUserProfile(completeness: Double) -> UserProfile {
    UserProfile(
        id: UUID().uuidString,
        name: "Test User",
        email: "test@example.com",
        skills: completeness >= 0.2 ? ["Swift", "iOS Development", "SwiftUI"] : [],
        experience: completeness >= 0.4 ? 5 : 0,
        preferredJobTypes: completeness >= 0.6 ? ["Full-time", "Contract"] : [],
        preferredLocations: completeness >= 0.8 ? ["Remote", "San Francisco"] : [],
        salaryRange: completeness >= 1.0 ? SalaryRange(min: 120000, max: 180000) : nil
    )
}
#endif
```

---

### Phase 3.5 Summary

**Total Time**: 3 hours (Week 7)
**Components Built**: 1 (ProfileCompletenessCard only)
**Components Already Exist**: 3 (ThompsonONetPerformanceTests, isONetScoringEnabled, ONetCodeMapper)
**Files Created**: 1 new file (ProfileCompletenessCard.swift)
**Audit Reference**: `PHASE_3.5_CODEBASE_AUDIT_RESULTS.md`

**Key Architectural Decisions**:
- **@MainActor isolation** for Swift 6 strict concurrency compliance
- **V7Core AppState** environment (not custom \.userProfile)
- **DualProfileColorSystem** integration (Amber→Teal gradient)
- **WCAG 2.1 AA** accessibility compliance (100% validated)
- **Zero Thompson impact** (not on critical path)

**Guardian Approvals**: 5/5 ✅
- V7 Architecture Guardian ✅
- Swift Concurrency Enforcer ✅
- Thompson Performance Guardian ✅ (10/10)
- Privacy & Security Guardian ✅ (zero risk)
- Accessibility Compliance Enforcer ✅ (10/10)

**Implementation Documentation**:
- Complete code: `PHASE_3.5_CORRECTED_IMPLEMENTATION.md`
- Guardian reviews: `PHASE_3.5_GUARDIAN_SIGN_OFFS.md`
- Audit findings: `PHASE_3.5_CODEBASE_AUDIT_RESULTS.md`
- Completion summary: `PHASE_3.5_COMPLETION_SUMMARY.md`


---

## Reference Documents

- Main plan: `ONET_INTEGRATION_IMPLEMENTATION_PLAN.md`
- Phase 3: `PHASE_3_CAREER_JOURNEY_FEATURES.md`
- Codebase audit: `PHASE_3.5_CODEBASE_AUDIT_RESULTS.md`
- Guardian sign-offs: `PHASE_3.5_GUARDIAN_SIGN_OFFS.md`
- Corrected implementation: `PHASE_3.5_CORRECTED_IMPLEMENTATION.md`
- Completion summary: `PHASE_3.5_COMPLETION_SUMMARY.md`

---

**Document Status**: ✅ Complete
**Last Updated**: October 29, 2025
**Ready for Implementation**: Yes (requires Phase 3 completion first)
**All 5 Guardians**: ✅ APPROVED
