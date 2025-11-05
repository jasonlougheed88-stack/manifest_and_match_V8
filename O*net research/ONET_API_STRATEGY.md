# O*NET API Integration Strategy
## Real-Time vs Embedded Data Analysis for ManifestAndMatch V8

**Date:** October 27, 2025
**Question:** Can we use O*NET API live in the app instead of embedding data?
**Answer:** **Hybrid approach recommended** - Embed core data, use API for enrichment

---

## O*NET Web Services API Overview

### What's Available

**API Type:** REST API (JSON/XML responses)
**Authentication:** HTTP Basic Auth (username/password from registration)
**Cost:** FREE (must register at services.onetcenter.org)
**License:** CC BY 4.0 (same as database)
**Current Version:** O*NET 30.0
**Rate Limits:** Not publicly documented (revealed after registration)

### Available Endpoints

1. **Career/Occupation Search** - Keyword search for occupations
2. **Occupation Details** - Full occupation data (skills, knowledge, tasks)
3. **Browse Services** - By industry, career cluster, job zone
4. **Interest Profiler** - 60-question and 30-question assessments
5. **Crosswalk Services** - Map between SOC versions, DOT codes, military codes
6. **Database Services** - Direct table access to O*NET data

### Sample API Call

```swift
// GET occupation details
GET https://services.onetcenter.org/ws/online/occupations/15-1252.00
Authorization: Basic base64(username:password)
Accept: application/json

// Response: Full occupation data including skills, knowledge, tasks, etc.
```

---

## Critical Performance Analysis

### Thompson Sampling Budget: <10ms Per Job

**Your Sacred Constraint:**
```swift
// From thompson-performance-guardian skill
assert(elapsed < 10.0, "Thompson budget violated")
```

**Problem with Real-Time API:**
```
Network latency: 50-200ms (typical REST API)
Thompson budget: 10ms
Result: 5-20x TOO SLOW ❌
```

### Network Latency Breakdown

**Best Case (WiFi, US server):**
- DNS lookup: 10-20ms
- TCP handshake: 20-40ms
- TLS handshake: 40-80ms
- Request/Response: 30-100ms
- **Total: 100-240ms minimum**

**Worst Case (Cellular, congested):**
- Network latency: 200-500ms
- **Total: 500-1000ms**

**Conclusion:** Real-time API calls are **incompatible** with <10ms Thompson budget.

---

## The Three Approaches

### Approach 1: ❌ Pure API (Real-Time)

**Strategy:** No embedded data, query O*NET API for every match

```swift
// WRONG: API call for every job match
func scoreJob(_ job: Job, profile: UserProfile) async -> Double {
    // Network call: 100-500ms ❌
    let requiredSkills = try await onetAPI.getOccupationSkills(job.onetCode)

    // Match: 1ms ✅
    let score = matcher.calculate(profile.skills, requiredSkills)

    return score
}
```

**Pros:**
- ✅ Always current data (O*NET updates quarterly)
- ✅ Minimal app size (~5MB smaller)
- ✅ No bundled data to maintain

**Cons:**
- ❌ **VIOLATES <10ms Thompson budget** (100-500ms latency)
- ❌ Requires internet connection (kills offline use)
- ❌ API rate limits unknown (could hit limits with heavy use)
- ❌ Battery drain from constant network calls
- ❌ User data exposure (every query goes to O*NET servers)
- ❌ Dependency on O*NET uptime

**Verdict:** **DO NOT USE** - Incompatible with performance requirements

---

### Approach 2: ✅ Pure Embedded (Bundled Data)

**Strategy:** Bundle curated O*NET data in app, zero network calls

```swift
// CORRECT: Local data lookup
func scoreJob(_ job: Job, profile: UserProfile) -> Double {
    // Local lookup: <1ms ✅
    let requiredSkills = skillsDatabase.getRequiredSkills(job.onetCode)

    // Match: <1ms ✅
    let score = matcher.calculate(profile.skills, requiredSkills)

    return score  // Total: <2ms ✅ (well under 10ms budget)
}
```

**Pros:**
- ✅ **MEETS <10ms Thompson budget** (<1ms local lookup)
- ✅ Works offline (critical for career exploration anywhere)
- ✅ No rate limits
- ✅ No network battery drain
- ✅ User privacy (no data leaves device)
- ✅ Predictable performance

**Cons:**
- ⚠️ App size increases (~5-10MB for curated data)
- ⚠️ Data becomes stale (O*NET updates quarterly)
- ⚠️ Must update with app releases

**Verdict:** **RECOMMENDED for Thompson Sampling**

---

### Approach 3: 🎯 Hybrid (Best of Both)

**Strategy:** Embed core data for performance, use API for enrichment

```swift
// HYBRID: Fast local data + optional API enrichment

// Core matching: Local data (FAST)
func scoreJobs(_ jobs: [Job], profile: UserProfile) async -> [ScoredJob] {
    let startTime = CFAbsoluteTimeGetCurrent()

    // Use bundled O*NET data for Thompson scoring
    let scoredJobs = jobs.map { job in
        let skills = skillsDatabase.getRequiredSkills(job.onetCode)  // <1ms
        let score = matcher.calculate(profile.skills, skills)         // <1ms
        return ScoredJob(job: job, score: score)
    }

    let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
    assert(elapsed / Double(jobs.count) < 10.0, "Budget met: \(elapsed)ms")

    return scoredJobs
}

// Optional enrichment: API calls (SLOW, but non-blocking)
func enrichOccupationDetails(_ occupation: Occupation) async {
    // Background task: Does NOT block Thompson scoring
    Task.detached {
        do {
            // API call for latest data (100-500ms)
            let latestData = try await onetAPI.getOccupationDetails(occupation.code)

            // Update local cache
            await skillsDatabase.updateFromAPI(latestData)

            // Notify UI if currently viewing this occupation
            await notifyOccupationUpdated(occupation)
        } catch {
            // Fail silently - bundled data is still valid
            print("API enrichment failed: \(error)")
        }
    }
}
```

**What's Bundled (Embedded in App):**
- ✅ 35 O*NET core skills (mandatory)
- ✅ 33 O*NET knowledge areas (mandatory)
- ✅ ~2,800 curated sector skills (our Phase 1 goal)
- ✅ Occupation → Skills mappings for top 500 occupations
- ✅ Basic occupation metadata (title, sector, SOC code)

**What's API-Fetched (Optional, Background):**
- 🌐 Full occupation details (when user taps job)
- 🌐 Latest salary data (updated quarterly)
- 🌐 Job outlook trends (employment projections)
- 🌐 Detailed task statements (19,000+ tasks)
- 🌐 Technology tools (10,000+ specific tools)
- 🌐 Interest Profiler results (assessment integration)

**Pros:**
- ✅ **MEETS <10ms Thompson budget** (local data for scoring)
- ✅ Works offline (core functionality)
- ✅ Always fresh details (when online)
- ✅ Smaller initial bundle (API provides 80% of verbose data)
- ✅ Best user experience (fast + comprehensive)

**Cons:**
- ⚠️ Complexity (manage both local data + API)
- ⚠️ Still need to handle API failures gracefully

**Verdict:** **OPTIMAL SOLUTION** - Recommended implementation

---

## Recommended Architecture

### Swift Implementation (iOS 26)

```swift
// Packages/V7Services/Sources/V7Services/ONet/ONetService.swift

/// Hybrid O*NET data service
/// Local data for performance, API for enrichment
@MainActor
public final class ONetService {

    // MARK: - Local Database (FAST - for Thompson)

    private let localDatabase: SkillsDatabase

    /// Get required skills for occupation (LOCAL - <1ms)
    public func getRequiredSkills(_ onetCode: String) -> [ONetSkill] {
        // Look up in bundled data
        return localDatabase.getSkillsForOccupation(onetCode)
    }

    /// Get knowledge areas for occupation (LOCAL - <1ms)
    public func getRequiredKnowledge(_ onetCode: String) -> [ONetKnowledge] {
        return localDatabase.getKnowledgeForOccupation(onetCode)
    }

    // MARK: - API Enrichment (SLOW - background only)

    private let apiClient: ONetAPIClient?

    /// Fetch latest occupation details from API (BACKGROUND - 100-500ms)
    public func enrichOccupation(_ code: String) async throws -> OccupationDetails {
        guard let api = apiClient else {
            throw ONetError.apiNotConfigured
        }

        // Network call - NEVER block Thompson scoring
        let details = try await api.getOccupationDetails(code)

        // Update local cache for future queries
        await localDatabase.updateCache(code, details: details)

        return details
    }

    /// Perform Interest Profiler assessment via API
    public func performInterestAssessment(
        answers: [Int]
    ) async throws -> InterestProfilerResult {
        guard let api = apiClient else {
            throw ONetError.apiNotConfigured
        }

        // API call for assessment scoring
        return try await api.submitInterestProfiler(answers: answers)
    }
}

// MARK: - API Client (Network Layer)

actor ONetAPIClient {

    private let baseURL = "https://services.onetcenter.org/ws"
    private let credentials: APICredentials

    struct APICredentials {
        let username: String
        let password: String
    }

    init(credentials: APICredentials) {
        self.credentials = credentials
    }

    /// GET occupation details
    func getOccupationDetails(_ code: String) async throws -> OccupationDetails {
        let url = URL(string: "\(baseURL)/online/occupations/\(code)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // HTTP Basic Auth
        let auth = "\(credentials.username):\(credentials.password)"
        let authData = auth.data(using: .utf8)!.base64EncodedString()
        request.setValue("Basic \(authData)", forHTTPHeaderField: "Authorization")

        // Network call
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ONetError.invalidResponse
        }

        guard http.statusCode == 200 else {
            throw ONetError.httpError(http.statusCode)
        }

        // Parse response
        return try JSONDecoder().decode(OccupationDetails.self, from: data)
    }

    /// Search occupations by keyword
    func searchOccupations(keyword: String) async throws -> [OccupationSearchResult] {
        let url = URL(string: "\(baseURL)/online/search")!
            .appending(queryItems: [URLQueryItem(name: "keyword", value: keyword)])

        // Similar request pattern...
        // Returns: Matching occupations
    }
}
```

### Usage in Thompson Scoring

```swift
// Packages/V7Thompson/Sources/V7Thompson/OptimizedThompsonEngine.swift

@MainActor
public final class OptimizedThompsonEngine {

    private let onetService: ONetService

    /// Score jobs using LOCAL O*NET data (FAST)
    public func scoreJobs(
        _ jobs: [Job],
        userProfile: UserProfile
    ) async -> [ScoredJob] {
        let startTime = CFAbsoluteTimeGetCurrent()

        // Precompute user's skills once
        let userSkills = userProfile.onetSkills
        let userKnowledge = userProfile.knowledgeAreas

        // Score each job (using LOCAL data only)
        var scoredJobs: [ScoredJob] = []

        for job in jobs {
            // LOCAL lookups: <1ms each
            let requiredSkills = onetService.getRequiredSkills(job.onetCode)
            let requiredKnowledge = onetService.getRequiredKnowledge(job.onetCode)

            // Calculate match: <1ms
            let skillMatch = calculateSkillMatch(userSkills, requiredSkills)
            let knowledgeMatch = calculateKnowledgeMatch(userKnowledge, requiredKnowledge)

            // Thompson sampling: <1ms
            let thompsonScore = sampleThompson(skillMatch, knowledgeMatch)

            scoredJobs.append(ScoredJob(job: job, score: thompsonScore))
        }

        // Performance validation
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        let avgPerJob = elapsed / Double(jobs.count)

        assert(avgPerJob < 10.0, "Thompson budget met: \(avgPerJob)ms/job")

        return scoredJobs.sorted { $0.score > $1.score }
    }
}
```

### Usage in Job Details Screen (API Enrichment)

```swift
// Packages/V7UI/Sources/V7UI/Screens/JobDetailsScreen.swift

@MainActor
public struct JobDetailsScreen: View {

    let job: Job
    @State private var enrichedDetails: OccupationDetails?
    @State private var isLoadingDetails = false

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Basic info: Always available (bundled data)
                Text(job.title).font(.largeTitle)
                Text(job.company).font(.title3)

                // Required skills: Always available (bundled data)
                SkillsSection(skills: job.requiredSkills)

                // Enriched details: Loaded from API
                if let details = enrichedDetails {
                    DetailedTasksSection(tasks: details.tasks)
                    SalarySection(salary: details.salary)
                    OutlookSection(outlook: details.outlook)
                } else if isLoadingDetails {
                    ProgressView("Loading latest details...")
                } else {
                    // Fallback: Show what we have from bundled data
                    Text("Connect to internet for latest details")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .task {
            // Background API enrichment (does NOT block UI)
            await loadEnrichedDetails()
        }
    }

    private func loadEnrichedDetails() async {
        isLoadingDetails = true
        defer { isLoadingDetails = false }

        do {
            // API call: 100-500ms (non-blocking)
            enrichedDetails = try await ONetService.shared.enrichOccupation(job.onetCode)
        } catch {
            // Fail silently - bundled data is sufficient
            print("API enrichment failed: \(error)")
        }
    }
}
```

---

## Data Size Analysis

### Bundled Data (Embedded in App)

**Current V8 skills.json:** 26,403 lines = ~1.5 MB

**Recommended Hybrid Bundle:**
```
35 O*NET core skills           ~5 KB
33 O*NET knowledge areas       ~3 KB
2,800 curated sector skills    ~150 KB
500 occupation mappings        ~500 KB
Basic occupation metadata      ~300 KB
--------------------------------
Total:                         ~1 MB (compressed: ~300 KB)
```

**App Size Impact:**
- Current app: ~15 MB (estimated)
- With hybrid O*NET data: ~15.3 MB
- **Increase: 0.3 MB (negligible)**

### API Data (Fetched On-Demand)

**Not bundled, fetched as needed:**
```
19,000 task statements         ~5 MB (if all loaded)
10,000 technology tools        ~3 MB
Salary data (all occupations)  ~2 MB
Employment outlook             ~1 MB
```

**User never loads all at once** - only what they view:
- View 10 jobs → ~50 KB API data
- Explore 50 occupations → ~200 KB API data

---

## Implementation Roadmap

### Phase 1: Local Data (Current - Phase 1 Checklist)

```
✅ Extract 35 O*NET core skills
✅ Extract 33 O*NET knowledge areas
✅ Curate 2,800 sector skills
✅ Map skills to 19 sectors
✅ Bundle in skills.json
✅ Implement SkillsDatabase actor
```

### Phase 2: API Registration & Setup

```
1. Register for O*NET Web Services
   - Visit: services.onetcenter.org
   - Get username/password credentials

2. Store credentials securely
   - Use Keychain (NOT hardcoded in app)
   - Environment variable for development

3. Create ONetAPIClient actor
   - HTTP Basic Auth
   - JSON parsing
   - Error handling
```

### Phase 3: API Integration (Background Enrichment)

```
1. Implement occupation details fetching
2. Add Interest Profiler API integration
3. Cache API responses locally (Core Data)
4. Add refresh mechanism (quarterly updates)
5. Handle offline gracefully
```

### Phase 4: Testing & Optimization

```
1. Verify Thompson budget (<10ms with local data)
2. Test API enrichment performance
3. Test offline functionality
4. Monitor API rate limits
5. Implement exponential backoff for API failures
```

---

## API Registration Details

**Sign Up:** https://services.onetcenter.org/
**What You Need:**
- Name
- Email
- Organization (ManifestAndMatch)
- Use case description

**What You Get:**
- Username
- Password
- Access to full API documentation
- Rate limit information
- Terms of Service

**Cost:** FREE
**Time to Approval:** Typically immediate

---

## Answers to Your Questions

### Q: "Can we reference O*NET direct code to save on size?"

**A: Not directly in real-time for Thompson scoring.**
- ❌ API calls are 100-500ms (violates <10ms budget)
- ✅ Hybrid approach: Embed core data (~1 MB), use API for enrichment

### Q: "Can we do that live on the app?"

**A: Yes, but NOT for performance-critical paths.**
- ✅ Background enrichment (job details screens)
- ✅ Interest Profiler assessment
- ✅ Career search/discovery
- ❌ Thompson Sampling (must use local data)

### Q: "Within the time frames?"

**A: Yes for enrichment, NO for Thompson scoring.**
- Thompson scoring: <10ms ✅ (local data only)
- Job details: 100-500ms ✅ (acceptable for user-initiated action)
- Interest assessment: 500-2000ms ✅ (one-time survey)

---

## Recommended Decision

**Use Hybrid Approach:**

1. **Bundle Core Data** (~1 MB)
   - 35 O*NET skills
   - 33 O*NET knowledge
   - 2,800 sector skills
   - Top 500 occupation mappings

2. **Thompson Sampling: 100% Local**
   - Meets <10ms budget
   - Works offline
   - Predictable performance

3. **API Enrichment: Background Only**
   - Job details screens
   - Interest Profiler
   - Latest salary/outlook data
   - Non-blocking, graceful failures

**Result:**
- ✅ Meets all performance requirements
- ✅ Always works (even offline)
- ✅ Enhanced with latest data (when online)
- ✅ Minimal app size impact (+0.3 MB)
- ✅ Best user experience

---

**Next Steps:**
1. Complete Phase 1 (embed curated O*NET data)
2. Register for O*NET Web Services API
3. Implement ONetAPIClient (Phase 2+)
4. Test hybrid approach with real users

**Recommendation:** Start with pure embedded approach (Phase 1), add API enrichment later (Phase 2+).
