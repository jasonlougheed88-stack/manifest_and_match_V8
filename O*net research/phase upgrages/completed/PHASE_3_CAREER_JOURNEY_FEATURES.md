# Phase 3: Career Journey Features

**Part of**: O*NET Integration Implementation Plan  
**Document Version**: 1.0  
**Created**: October 29, 2025  
**Project**: ManifestAndMatch V8 (iOS 26)  
**Duration**: Weeks 4-6 (64 hours)  
**Priority**: P1 (30% of total value)

---

## Phase 3: Career Journey Features (Weeks 4-6)

**Goal**: Complete career discovery and growth features
**Impact**: 30% of total value
**Effort**: 40% of total work (64 hours)
**Risk**: Medium-High
**Dependencies**: Phases 1 & 2 complete

### Task 3.1: Skills Gap Analysis

**Priority**: P1 (High - core value proposition)
**Estimated Time**: 16 hours
**Files**:
- New: `Packages/V7UI/Sources/V7UI/Views/SkillsGapAnalysisView.swift`
- New: `Packages/V7Services/Sources/V7Services/Career/SkillsGapAnalyzer.swift`

#### Implementation Plan

**Compare user skills to target career O*NET requirements**:
1. User selects target career (from O*NET occupation list)
2. App fetches O*NET skill requirements for that occupation
3. Compare user's current skills to required skills
4. Visualize:
   - ✅ Transferable skills (user has, job needs)
   - ⚠️ Skill gaps (job needs, user doesn't have)
   - 💎 Bonus skills (user has, job doesn't require - differentiators)

**Success Criteria**:
- [ ] Target career selection UI
- [ ] Skills comparison algorithm
- [ ] Visual gap analysis (charts/lists)
- [ ] Prioritized learning recommendations

---

### Task 3.2: Career Path Visualization

**Priority**: P1 (High - "realistic transition pathways")
**Estimated Time**: 20 hours
**Files**:
- New: `Packages/V7UI/Sources/V7UI/Views/CareerPathVisualizationView.swift`
- New: `Packages/V7Services/Sources/V7Services/Career/CareerPathFinder.swift`

#### Implementation Plan

**Timeline view: Current → Intermediate → Target roles**:
1. Analyze user's current skills/experience
2. Identify 2-3 intermediate stepping-stone roles
3. Show progression timeline with skill acquisition checkpoints
4. Estimate time to each milestone (6 months, 1 year, 2 years)

**Success Criteria**:
- [ ] Multi-step career path visualization
- [ ] Timeline with milestones
- [ ] Skill acquisition checkpoints
- [ ] Time estimates based on learning rates

---

### Task 3.3: Course Recommendations

**Priority**: P2 (Medium - monetization opportunity)
**Estimated Time**: 12 hours
**Files**:
- New: `Packages/V7Services/Sources/V7Services/Learning/CourseRecommender.swift`
- New: `Packages/V7UI/Sources/V7UI/Views/CourseRecommendationsView.swift`

#### Implementation Plan

**Map skill gaps to learning resources**:
1. For each identified skill gap
2. Search course APIs (Coursera, Udemy, LinkedIn Learning)
3. Rank by relevance, cost, duration, ratings
4. Display as actionable "Next Steps"

**Success Criteria**:
- [ ] Course API integration
- [ ] Relevance ranking algorithm
- [ ] Course cards with details (cost, duration, provider)
- [ ] Direct enrollment links

---

### Task 3.4: AI Cover Letter Generator

**Priority**: P2 (Medium - completes application workflow)
**Estimated Time**: 16 hours
**Files**:
- New: `Packages/V7Services/Sources/V7Services/Application/CoverLetterGenerator.swift`
- New: `Packages/V7UI/Sources/V7UI/Views/CoverLetterEditorView.swift`

#### Implementation Plan

**Generate cover letters from parsed resume + job description**:
1. Extract key requirements from job description
2. Match to user's resume data (work experience, education, skills)
3. Use Foundation Models (iOS 26 on-device AI) to generate draft
4. Allow user editing before saving/copying

**Success Criteria**:
- [ ] Job description parsing
- [ ] Resume data extraction
- [ ] Foundation Models integration
- [ ] Editable cover letter output
- [ ] Copy/export functionality

---

### Phase 3 Summary

**Total Time**: ~64 hours (3 weeks)
**Files Created**: 8 new files
**Files Modified**: 4 (integration points)

---


---

## Reference Documents

- Main plan: `ONET_INTEGRATION_IMPLEMENTATION_PLAN.md`
- Phase 2: `PHASE_2_ONET_PROFILE_EDITOR.md`
- Phase 3.5: `PHASE_3.5_INFRASTRUCTURE.md`

---

**Document Status**: ✅ Complete
**Last Updated**: October 29, 2025
**Ready for Implementation**: Yes (requires Phase 2 completion first)
