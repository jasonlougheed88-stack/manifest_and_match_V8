# ManifestAndMatch V8 - Phase 5 Checklist
## Course Integration & Revenue Generation (Weeks 18-20)

**Phase Duration**: 3 weeks
**Timeline**: Weeks 18-20 (Days 86-100)
**Priority**: 💰 **BUSINESS VALUE - Revenue Generation**
**Skills Coordinated**: api-integration-builder (Lead), career-data-integration, app-narrative-guide, privacy-security-guardian
**Status**: Not Started
**Last Updated**: October 27, 2025

---

## Phase Timeline Overview

| Phase | Status | Timeline | Dependencies |
|-------|--------|----------|--------------|
| Phase 2 | ⚪ Not Started | Weeks 3-16 (14 weeks) | Phase 1 Complete |
| Phase 3 | ⚪ Not Started | Weeks 3-12 (10 weeks) | Phase 1 Complete |
| Phase 4 | ⚪ Not Started | Weeks 13-17 (5 weeks) | Phase 2 Complete |
| **Phase 5 (This Document)** | ⚪ Not Started | Weeks 18-20 (3 weeks) | Phase 3 Complete |
| Phase 6 | ⚪ Not Started | Weeks 21-24 (4 weeks) | All Phases Complete |

**Current Week**: Not Started
**Progress**: 0% (0/3 weeks complete)

---

## Objective

Integrate Udemy and Coursera APIs with affiliate links to generate revenue ($0.10-$0.50 per user/month) while helping users upskill for career transitions.

---

## Business Case

### Current State
- Manifest tab: 90% production-ready
- Course recommendations: Showing sample data only
- Revenue: $0 (no monetization)

### Target State
- Live course recommendations from Udemy & Coursera
- Personalized based on user profile + skill gaps
- Affiliate revenue: $0.10-$0.50 per user/month
- Annual revenue projection: $1,200-6,000 (at 1000 users)

### User Value Alignment
- Help users identify skill gaps (Manifest Profile)
- Recommend courses to close gaps
- Enable career transitions with education
- NOT exploitative - user-first design

---

## Prerequisites

### Phase 3 Complete ✅
- [ ] Profile expansion complete (95% completeness)
- [ ] Skills, certifications, projects tracked
- [ ] Skill gap analysis possible

### Phase 1 Complete ✅
- [ ] Skills system expanded (500+ skills, 14 sectors)
- [ ] Sector-neutral skill taxonomy

### Developer Accounts
- [ ] Udemy Affiliate Program account approved
- [ ] Coursera Affiliate Program account approved
- [ ] API keys secured in Keychain

---

## WEEK 18: API Integration Scaffold

### Skill: api-integration-builder (Lead)

#### Day 1-2: Udemy API Client

- [ ] Create `Packages/V8Services/Sources/V8Services/CourseProviders/`
- [ ] Create `UdemyAPIClient.swift`
- [ ] Implement actor isolation
- [ ] Add rate limiting (100 requests/hour)
- [ ] Add circuit breaker pattern
- [ ] Implement exponential backoff

**API Client Structure**:
```swift
public actor UdemyAPIClient {
    private let apiKey: String
    private let affiliateId: String
    private let session: URLSession
    private let rateLimiter: RateLimiter
    private let circuitBreaker: CircuitBreaker

    public init() async throws {
        // Load from Keychain
        let keychain = KeychainService()
        self.apiKey = try await keychain.loadAPIKey(
            service: "com.manifestandmatch.udemy"
        )
        self.affiliateId = try await keychain.loadAPIKey(
            service: "com.manifestandmatch.udemy.affiliate"
        )

        // Configure session (TLS 1.3)
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        self.session = URLSession(configuration: config)

        self.rateLimiter = RateLimiter(maxRequests: 100, per: .hour)
        self.circuitBreaker = CircuitBreaker(failureThreshold: 5)
    }

    public func searchCourses(
        skills: [String],
        level: SkillLevel
    ) async throws -> [Course] {
        // Rate limiting
        try await rateLimiter.checkLimit()

        // Circuit breaker
        guard await circuitBreaker.isOperational else {
            throw CourseAPIError.serviceUnavailable
        }

        // Build request
        let query = skills.joined(separator: " OR ")
        var components = URLComponents(
            string: "https://www.udemy.com/api-2.0/courses/"
        )!
        components.queryItems = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "instructional_level", value: level.rawValue),
            URLQueryItem(name: "page_size", value: "20"),
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // Execute with circuit breaker protection
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  http.statusCode == 200 else {
                await circuitBreaker.recordFailure()
                throw CourseAPIError.invalidResponse
            }

            await circuitBreaker.recordSuccess()

            let result = try JSONDecoder().decode(UdemyResponse.self, from: data)
            return result.results.map { $0.toCourse(affiliateId: affiliateId) }
        } catch {
            await circuitBreaker.recordFailure()
            throw error
        }
    }
}
```

**Deliverables**:
- [ ] UdemyAPIClient.swift implemented
- [ ] Rate limiting working (100/hour)
- [ ] Circuit breaker pattern implemented
- [ ] Unit tests written

#### Day 3-4: Coursera API Client

- [ ] Create `CourseraAPIClient.swift`
- [ ] Similar structure to Udemy client
- [ ] Implement rate limiting
- [ ] Add circuit breaker
- [ ] Affiliate link generation

**Deliverables**:
- [ ] CourseraAPIClient.swift implemented
- [ ] Integration tested
- [ ] Unit tests written

#### Day 5-7: Course Recommendation Service

- [ ] Create `CourseRecommendationService.swift`
- [ ] Implement skill gap analysis
- [ ] Parallel API calls (Udemy + Coursera)
- [ ] Merge and rank results
- [ ] Personalization logic

**Skill Gap Analysis**:
```swift
public actor CourseRecommendationService {
    private let udemyClient: UdemyAPIClient
    private let courseraClient: CourseraAPIClient
    private let cache: CacheManager

    public func recommendCourses(
        for profile: UserProfile,
        targetRole: String?
    ) async throws -> [Course] {
        // 1. Analyze skill gaps
        let skillGaps = await analyzeSkillGaps(profile: profile, targetRole: targetRole)

        // 2. Fetch courses in parallel
        async let udemyCourses = udemyClient.searchCourses(
            skills: skillGaps,
            level: profile.skillLevel
        )
        async let courseraCourses = courseraClient.searchCourses(
            skills: skillGaps,
            level: profile.skillLevel
        )

        let allCourses = try await udemyCourses + courseraCourses

        // 3. Filter and rank
        return allCourses
            .filter { $0.rating >= 4.5 }
            .filter { $0.lastUpdated > Date().addingTimeInterval(-63072000) }  // 2 years
            .sorted { rankCourse($0, for: profile) > rankCourse($1, for: profile) }
            .prefix(10)
            .map { $0 }
    }

    private func analyzeSkillGaps(
        profile: UserProfile,
        targetRole: String?
    ) async -> [String] {
        // Get current skills
        let currentSkills = Set(profile.skills)

        // Get target role required skills
        let targetSkills = await getRequiredSkills(for: targetRole)

        // Calculate gap
        let gaps = targetSkills.subtracting(currentSkills)

        return Array(gaps).prefix(5).map { $0 }  // Top 5 gaps
    }
}
```

**Deliverables**:
- [ ] CourseRecommendationService.swift implemented
- [ ] Skill gap analysis working
- [ ] Course ranking algorithm implemented
- [ ] Cache integration (6 hour TTL)

---

### **🔗 O*NET INTEGRATION: Enhanced Course Recommendations (Optional)**

**Cross-Reference**: `ONET_INTEGRATION_REMAINING_WORK.md` (Nice-to-Have)
**Skill**: career-data-integration, onet-career-integration

#### Day 5-7 (Optional Enhancement): O*NET-Based Course Recommendations

**Note**: This is an **optional enhancement** to make course recommendations more intelligent using O*NET occupation data.

**Current Approach** (Good):
- Analyze skill gaps based on user skills vs target role skills
- Recommend courses to close gaps
- Works well for skills-based recommendations

**Enhanced Approach with O*NET** (Better):
- Use O*NET occupation knowledge requirements
- Use O*NET work activities to recommend courses
- Use O*NET education requirements to prioritize courses
- Recommend courses based on career transition paths

**Implementation**:

```swift
// Enhance CourseRecommendationService with O*NET data
public actor CourseRecommendationService {
    private let onetService = ONetDataService.shared

    private func analyzeSkillGaps(
        profile: UserProfile,
        targetRole: String?
    ) async -> [String] {
        // Enhanced with O*NET knowledge requirements
        if let targetOccupation = await findONetOccupation(for: targetRole) {
            // Get O*NET knowledge areas for target occupation
            let knowledge = try? await onetService.loadKnowledge()
            let occupationKnowledge = knowledge?.occupations.first {
                $0.onetCode == targetOccupation
            }

            // Extract top knowledge areas (these become course topics)
            let topKnowledge = occupationKnowledge?.knowledge
                .filter { $0.importance > 5.0 }  // Important knowledge only
                .sorted { $0.importance > $1.importance }
                .prefix(5)
                .map { $0.name }  // E.g., "Customer and Personal Service", "English Language"

            // Combine with existing skill gaps
            let skillGaps = Set(profile.skills).symmetricDifference(targetSkills)
            let knowledgeGaps = topKnowledge ?? []

            return Array(skillGaps) + knowledgeGaps
        }

        // Fallback to existing skill-based approach
        return Array(targetSkills.subtracting(currentSkills))
    }

    private func rankCourse(
        _ course: Course,
        for profile: ProfessionalProfile
    ) -> Double {
        var score = 0.0

        // Base ranking (existing)
        score += (course.rating - 4.0) * 20  // Rating bonus (max 20)
        score += course.enrollmentCount > 1000 ? 10 : 0  // Popularity

        // NEW: O*NET education level matching
        if let educationLevel = profile.educationLevel {
            // Match course difficulty to user's education level
            let courseLevelMap: [String: Int] = [
                "beginner": 6,      // Some college
                "intermediate": 8,   // Bachelor's
                "advanced": 10,      // Master's
                "expert": 12         // Doctoral
            ]

            if let courseLevel = courseLevelMap[course.level],
               abs(courseLevel - educationLevel) <= 2 {
                score += 15  // Course matches user's education level
            }
        }

        // NEW: O*NET work activities alignment
        if let workActivities = profile.workActivities {
            // If course teaches activities user already does, boost score
            // (Deepening existing skills is valuable)
            let courseActivities = extractWorkActivities(from: course.description)
            let overlap = Set(workActivities.keys).intersection(courseActivities)
            score += Double(overlap.count) * 5  // 5 points per overlapping activity
        }

        return score
    }
}
```

**Benefits**:
- More intelligent course recommendations (not just keyword matching)
- Courses aligned with user's education level (no PhD courses for high school grads)
- Career transition paths informed by O*NET occupation data
- Deepens existing strengths (e.g., "You do data analysis, here are advanced courses")

**Deliverables** (If Implemented):
- [ ] O*NET knowledge areas integrated into skill gap analysis
- [ ] Course ranking uses education level matching
- [ ] Work activities inform course recommendations
- [ ] Testing: 5 user profiles with diverse backgrounds

**Recommendation**: **Phase 2 enhancement** - implement after basic course integration works. Not critical for launch.

---

## WEEK 19: UI Integration & Tracking

### Skill: career-data-integration (Lead)

#### Day 8-10: Manifest Tab Integration

- [ ] Update ManifestScreen to use CourseRecommendationService
- [ ] Replace sample data with real API calls
- [ ] Add loading states
- [ ] Add error handling
- [ ] Display affiliate links correctly

**UI Updates**:
```swift
struct ManifestScreen: View {
    @StateObject var viewModel: ManifestViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Current Profile (Amber)
                CurrentProfileCard(profile: viewModel.currentProfile)

                // Manifest Profile (Teal)
                ManifestProfileCard(profile: viewModel.manifestProfile)

                // Skill Gaps
                SkillGapsView(gaps: viewModel.skillGaps)

                // Recommended Courses
                if viewModel.isLoadingCourses {
                    ProgressView("Finding courses...")
                } else if let courses = viewModel.recommendedCourses {
                    CourseRecommendationsView(courses: courses)
                } else if let error = viewModel.courseError {
                    ErrorView(error: error)
                }
            }
        }
        .task {
            await viewModel.loadRecommendations()
        }
    }
}
```

**Deliverables**:
- [ ] ManifestScreen updated
- [ ] Real courses displayed
- [ ] Loading/error states working

#### Day 11-12: Affiliate Tracking Service

**Skill**: privacy-security-guardian

- [ ] Create `AffiliateTrackingService.swift`
- [ ] Implement click tracking (anonymous)
- [ ] Implement enrollment tracking
- [ ] Revenue attribution
- [ ] Privacy-compliant (no PII)

**Tracking Implementation**:
```swift
public actor AffiliateTrackingService {
    func trackCourseClick(
        courseId: UUID,
        provider: String
    ) async {
        let event = AffiliateEvent(
            courseId: courseId,
            provider: provider,
            timestamp: Date(),
            userId: AppState.shared.anonymousUserId  // No PII
        )

        await AnalyticsService.shared.trackEvent(
            "course_click",
            properties: event.toDictionary()
        )
    }

    func trackCourseEnrollment(
        courseId: UUID,
        provider: String,
        revenue: Double
    ) async {
        let event = AffiliateEvent(
            courseId: courseId,
            provider: provider,
            timestamp: Date(),
            userId: AppState.shared.anonymousUserId,
            revenue: revenue
        )

        await AnalyticsService.shared.trackEvent(
            "course_enrollment",
            properties: event.toDictionary()
        )

        print("💰 Affiliate revenue: $\(revenue)")
    }
}
```

**Privacy Requirements**:
- [ ] No PII sent to analytics
- [ ] Anonymous user IDs only
- [ ] No course titles in tracking (just IDs)
- [ ] Opt-out mechanism available

**Deliverables**:
- [ ] AffiliateTrackingService.swift
- [ ] Click tracking working
- [ ] Revenue attribution working
- [ ] Privacy policy updated

#### Day 13-14: Course Detail View

- [ ] Create CourseDetailView
- [ ] Display course information
- [ ] "Enroll Now" button with affiliate link
- [ ] Track clicks

**Deliverables**:
- [ ] CourseDetailView implemented
- [ ] Affiliate links working
- [ ] Tracking integrated

---

## WEEK 20: Testing & Optimization

### Skill: app-narrative-guide (Lead)

#### Day 15-16: User Value Validation

- [ ] Test skill gap analysis accuracy
- [ ] Verify course recommendations are helpful
- [ ] Ensure not exploitative (user-first)
- [ ] Test with 5 real user profiles

**Validation Questions**:
- Do recommended courses actually close skill gaps?
- Are course recommendations diverse (not all tech)?
- Is pricing transparent?
- Is user value clear?
- Would we recommend this to a friend?

**Deliverables**:
- [ ] User value validated
- [ ] Not exploitative (passes narrative test)
- [ ] Recommendations helpful

#### Day 17-19: Performance & Load Testing

**Skill**: api-integration-builder

- [ ] Load test: 100 concurrent course searches
- [ ] Measure API latency
- [ ] Test rate limiting
- [ ] Test circuit breaker
- [ ] Test cache hit rate

**Performance Targets**:
- [ ] API response time: <2s
- [ ] Cache hit rate: >60%
- [ ] Rate limiter prevents overages
- [ ] Circuit breaker opens after 5 failures

**Deliverables**:
- [ ] Load testing report
- [ ] Performance targets met
- [ ] Rate limiting validated
- [ ] Circuit breaker tested

#### Day 20: Final Integration Testing

- [ ] End-to-end test: Profile → Skill Gaps → Courses → Click → Track
- [ ] Test error scenarios
- [ ] Test offline behavior
- [ ] Verify privacy compliance

**Deliverables**:
- [ ] All integration tests passing
- [ ] Error handling working
- [ ] Privacy validated

---

## Success Criteria

### API Integration ✅
- [ ] Udemy API working (affiliate links correct)
- [ ] Coursera API working (affiliate links correct)
- [ ] Rate limiting preventing overages (100/hour)
- [ ] Circuit breaker preventing cascading failures

### Course Recommendations ✅
- [ ] Skill gap analysis accurate
- [ ] Courses relevant to user profile
- [ ] Top-rated courses (≥4.5 stars)
- [ ] Recent courses (last 2 years)
- [ ] Diverse sectors (not just tech)

### User Experience ✅
- [ ] Manifest tab shows real courses
- [ ] Loading states smooth
- [ ] Error handling graceful
- [ ] Affiliate links work correctly

### Privacy & Security ✅
- [ ] No PII sent to course APIs
- [ ] API keys secured in Keychain
- [ ] TLS 1.3 enforced
- [ ] Anonymous tracking only

### Revenue Generation ✅
- [ ] Click-through rate: >5%
- [ ] Enrollment conversion: >1%
- [ ] Revenue per user: $0.10-$0.50/month
- [ ] Tracking accurate

---

## Revenue Projections

| Users | CTR (5%) | Enrollment (1%) | Revenue/User/Month | Monthly Revenue | Annual Revenue |
|-------|----------|-----------------|-------------------|-----------------|----------------|
| 1,000 | 50 clicks | 0.5 enrollments | $0.30 | $300 | $3,600 |
| 5,000 | 250 clicks | 2.5 enrollments | $0.30 | $1,500 | $18,000 |
| 10,000 | 500 clicks | 5 enrollments | $0.30 | $3,000 | $36,000 |

---

## Deliverables Checklist

### Code Files
- [ ] UdemyAPIClient.swift
- [ ] CourseraAPIClient.swift
- [ ] CourseRecommendationService.swift
- [ ] AffiliateTrackingService.swift
- [ ] CourseDetailView.swift
- [ ] Updated ManifestScreen.swift

### Documentation
- [ ] COURSE_API_INTEGRATION.md
- [ ] REVENUE_MODEL.md
- [ ] PRIVACY_POLICY_UPDATED.md

### Test Reports
- [ ] API integration test results
- [ ] Load testing report
- [ ] User value validation report
- [ ] Revenue projection model

---

## Handoff to Phase 6

### Prerequisites for Phase 6 Start (Production Hardening)
- [ ] Phase 5 course integration complete
- [ ] Revenue tracking working
- [ ] User value validated

### Phase 6 Team Notification
Once Phase 5 is complete, **Phase 6 (Production Hardening) begins**:

**Phase 6 Team**:
- performance-regression-detector (Lead)
- thompson-performance-guardian
- accessibility-compliance-enforcer
- ios-app-architect

**Handoff Message**:
```
Phase 5 (Course Integration & Revenue) COMPLETE ✅

Course APIs: Udemy + Coursera integrated ✅
Recommendations: Personalized skill gap-based ✅
Tracking: Affiliate clicks/enrollments tracked ✅
Revenue: $0.10-$0.50 per user/month ✅
User Value: Validated (helps career transitions) ✅
Privacy: No PII, Keychain-secured ✅

Phase 6 (Production Hardening) ready to begin.
```

---

**Phase 5 Status**: ⚪ Not Started | 🟡 In Progress | 🟢 Complete | 🔴 Blocked

**Last Updated**: October 27, 2025
**Next Phase**: Phase 6 - Production Hardening & App Store Launch
