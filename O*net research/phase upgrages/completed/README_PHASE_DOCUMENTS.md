# O*NET Integration - Phase Documents

**Created**: October 29, 2025  
**Source**: ONET_INTEGRATION_IMPLEMENTATION_PLAN.md  
**Total Phases**: 5 (Week 0 + Phases 1-3.5)

---

## Document Structure

The O*NET Integration Implementation Plan has been broken into separate phase documents for easier navigation and implementation tracking.

### Phase Documents

| Document | Duration | Lines | Size | Priority | Description |
|----------|----------|-------|------|----------|-------------|
| **WEEK_0_PRE_IMPLEMENTATION_FIXES.md** | 8 hours | 513 | 14K | P0 | Critical Swift 6 setup, Sendable compliance |
| **PHASE_1_QUICK_WINS.md** | 32 hours | 978 | 34K | P0 | Display Core Data entities, expand industries |
| **PHASE_2_ONET_PROFILE_EDITOR.md** | 76 hours | 1,368 | 47K | P0 | O*NET profile editing, work activities, RIASEC |
| **PHASE_3_CAREER_JOURNEY_FEATURES.md** | 64 hours | 141 | 4.1K | P1 | Skills gap, career paths, recommendations |
| **PHASE_3.5_INFRASTRUCTURE.md** | 3 hours | 347 | 12K | P1 | ProfileCompletenessCard (guardian-validated) |

**Total**: 183 hours across 6.5 weeks

---

## Implementation Order

**CRITICAL**: Phases must be executed sequentially in this exact order:

1. **Week 0** → Pre-implementation fixes (Swift 6, Sendable, Industry enum)
2. **Phase 1** → Quick wins (Core Data display, industries)
3. **Phase 2** → O*NET profile editor
4. **Phase 3** → Career journey features
5. **Phase 3.5** → Infrastructure for Phases 4-6

**Do not skip Week 0** - it contains P0 fixes required for all subsequent phases.

---

## Phase Details

### Week 0: Pre-Implementation Fixes (8 hours)

**File**: `WEEK_0_PRE_IMPLEMENTATION_FIXES.md`

**Critical Tasks**:
- Enable Swift 6 strict concurrency in all V7 packages
- Add Sendable compliance helpers (NSManagedObject+Sendable)
- Validate Industry enum (correct 21 → 19 sectors)
- Prepare test data for Phase 1

**Why Critical**: Without these fixes, Phase 1 will not compile.

---

### Phase 1: Quick Wins (32 hours, Week 1)

**File**: `PHASE_1_QUICK_WINS.md`

**Tasks** (6 total):
1. Display WorkExperience entity (4h)
2. Display Education entity (3h)
3. Display Certifications (2.5h)
4. Display Projects/Volunteer/Awards/Publications (6h)
5. Expand Industry enum 12 → 19 sectors (12h)
6. Enhance Skills display (5h)

**Impact**: 40% of total value - unlocks data already parsed and stored

**Swift 6 Pattern**: All code uses `NSManagedObjectID` instead of Core Data objects in `@State`

---

### Phase 2: O*NET Profile Editor (76 hours, Weeks 2-3)

**File**: `PHASE_2_ONET_PROFILE_EDITOR.md`

**Tasks** (4 total):
1. Education Level editor (20h) - 12-point O*NET scale
2. Work Activities editor (24h) - 41 O*NET work dimensions
3. RIASEC Interests editor (20h) - 6 Holland Code types
4. Thompson validation + async loading + accessibility (12h)

**Impact**: 30% of total value - enables full O*NET scoring

**Sacred Constraint**: Thompson P95 latency must remain <10ms (357x advantage)

---

### Phase 3: Career Journey Features (64 hours, Weeks 4-6)

**File**: `PHASE_3_CAREER_JOURNEY_FEATURES.md`

**Tasks** (3 total):
1. Skills gap analysis (24h)
2. Career path visualization with radar charts (24h)
3. Course recommendations integration (16h)

**Impact**: 30% of total value - long-term career growth

**Dependencies**: Phase 2 O*NET data, external course APIs

---

### Phase 3.5: Phase 4-6 Infrastructure (3 hours, Week 7)

**File**: `PHASE_3.5_INFRASTRUCTURE.md`

**Component to Build**: ProfileCompletenessCard (3 hours only)

**Components Already Exist** (3/4):
- ✅ ThompsonONetPerformanceTests (413 lines, production-ready)
- ✅ isONetScoringEnabled flag (A/B testing)
- ✅ ONetCodeMapper (894 occupations, 85%+ accuracy)

**Guardian Approvals**: 5/5 ✅
- V7 Architecture Guardian
- Swift Concurrency Enforcer
- Thompson Performance Guardian (10/10)
- Privacy & Security Guardian (zero risk)
- Accessibility Compliance Enforcer (WCAG 2.1 AA 100%)

**Special Notes**: 
- Original proposal: 16 hours (4 components)
- After codebase audit: 3 hours (1 component)
- Savings: 13 hours (81% reduction)

---

## Supporting Documents

### Phase 3.5 Reference Files

Created during Phase 3.5 planning with full guardian validation:

- `PHASE_3.5_CODEBASE_AUDIT_RESULTS.md` - What exists vs. what needs building
- `PHASE_3.5_CORRECTED_IMPLEMENTATION.md` - Guardian-validated ProfileCompletenessCard code
- `PHASE_3.5_GUARDIAN_SIGN_OFFS.md` - All 5 guardian approvals
- `PHASE_3.5_COMPLETION_SUMMARY.md` - Executive summary of Phase 3.5

### Main Implementation Plan

- `ONET_INTEGRATION_IMPLEMENTATION_PLAN.md` - Complete unified plan (3,002 lines)

---

## Key Architectural Patterns

### Swift 6 Sendable Compliance

**Pattern for ALL Core Data operations**:

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

### Sacred Constraints

1. **Thompson P95 < 10ms** - Cannot be violated (357x competitive advantage)
2. **Swift 6 strict concurrency** - All code must compile with no warnings
3. **WCAG 2.1 AA accessibility** - 100% compliance required
4. **Zero circular dependencies** - V7 architecture pattern
5. **On-device processing** - Privacy-first (no PII to network)

### Color System

**Dual-Profile Gradient**: Amber (Hue 0.083) → Teal (Hue 0.528)

Used throughout for progress indicators, selection states, and completeness visualization.

---

## Timeline Summary

| Week | Phase | Hours | Cumulative |
|------|-------|-------|------------|
| 0 | Pre-implementation | 8 | 8 |
| 1 | Phase 1 | 32 | 40 |
| 2-3 | Phase 2 | 76 | 116 |
| 4-6 | Phase 3 | 64 | 180 |
| 7 | Phase 3.5 | 3 | **183** |

**Total**: 183 hours (6.5 weeks)

**Increase from original**: +23 hours (14.4%)
- Week 0 P0 fixes: +8 hours
- Phase 2 enhancements: +12 hours  
- Phase 3.5 infrastructure: +3 hours (reduced from +16 via audit)

---

## Quality Assurance

### Guardian Skills Used

All V7 architecture guardian skills were invoked during planning:

1. **v7-architecture-guardian** - Zero circular dependencies, proper patterns
2. **swift-concurrency-enforcer** - Swift 6 strict concurrency compliance
3. **thompson-performance-guardian** - <10ms sacred constraint enforcement
4. **privacy-security-guardian** - On-device processing, no PII leaks
5. **accessibility-compliance-enforcer** - WCAG 2.1 AA 100% compliance

### Testing Requirements

Each phase includes:
- ✅ Unit tests (≥90% coverage)
- ✅ Manual testing checklists
- ✅ Accessibility validation (VoiceOver)
- ✅ Performance benchmarks
- ✅ Success criteria verification

---

## How to Use These Documents

### For Implementation

1. Start with `WEEK_0_PRE_IMPLEMENTATION_FIXES.md`
2. Complete all Week 0 tasks before proceeding
3. Follow phases sequentially (1 → 2 → 3 → 3.5)
4. Use checklists in each document to track progress

### For Planning

Each document contains:
- Task breakdown with time estimates
- Complete code examples (copy-paste ready)
- Testing strategies
- Success criteria
- Integration points with other phases

### For Review

- Main plan: `ONET_INTEGRATION_IMPLEMENTATION_PLAN.md`
- Individual phases: `PHASE_X_*.md` files
- Phase 3.5 validation: `PHASE_3.5_GUARDIAN_SIGN_OFFS.md`

---

## Document Status

**All phase documents**: ✅ Complete  
**Last Updated**: October 29, 2025  
**Ready for Implementation**: Yes  
**Guardian Validation**: Complete (Phase 3.5)

---

## Next Steps

1. ✅ **Phase documents created** (this step)
2. ⏭️ **Begin Week 0** - Pre-implementation fixes
3. ⏭️ **Execute phases 1-3.5** - Sequential implementation
4. ⏭️ **Proceed to Phase 4** - Liquid Glass UI Adoption (separate plan)

---

**Total Lines Across All Phase Documents**: 3,347 lines  
**Total Size**: 111K  
**Source Lines Preserved**: 100% (no dilution of detail)
