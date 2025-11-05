# C4 CONTEXT DIAGRAM
## Manifest & Match V8 - System Context View

---

## Diagram Overview

This Context Diagram shows how Manifest & Match V8 fits into the broader ecosystem, including users, external systems, and third-party services.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         ECOSYSTEM CONTEXT                                │
└─────────────────────────────────────────────────────────────────────────┘


    ┌──────────────┐                          ┌──────────────────┐
    │  Job Seeker  │────────uses──────────────│  Manifest &      │
    │              │                          │  Match V8 App    │
    │ (Primary     │◄────provides jobs────────│                  │
    │  User)       │       & insights         │  (iOS 26 App)    │
    └──────────────┘                          └──────────────────┘
           │                                           │
           │                                           │
           │                                           │
           └───────creates profile                    ├──────fetches jobs─────┐
                   uploads resume                     │                        │
                   swipes jobs                        │                        ▼
                   answers questions                  │           ┌────────────────────┐
                                                      │           │  JOB SOURCE APIs   │
                                                      │           │                    │
                                                      │           │  • Adzuna API      │
    ┌──────────────────────┐                         │           │  • Greenhouse API  │
    │  Apple Foundation    │◄───on-device AI─────────┤           │  • Lever API       │
    │  Models (iOS 26)     │                         │           │  • LinkedIn API    │
    │                      │                         │           │  • Jobicy API      │
    │  • Career Questions  │                         │           │  • USAJobs API     │
    │  • Skills Analysis   │                         │           │  • RSS Feeds       │
    │  • Behavior Patterns │                         │           └────────────────────┘
    └──────────────────────┘                         │
                                                      │
                                                      │
                                                      ├───────stores data─────┐
                                                      │                        │
                                                      │                        ▼
    ┌─────────────────────┐                          │           ┌──────────────────┐
    │  O*NET Database     │◄────career taxonomy──────┤           │  Core Data       │
    │  (JSON Bundle)      │                          │           │  (SQLite)        │
    │                     │                          │           │                  │
    │  • 1,016 Roles      │                          │           │  • UserProfile   │
    │  • Work Activities  │                          │           │  • WorkExperience│
    │  • Skills Taxonomy  │                          │           │  • SwipeHistory  │
    │  • RIASEC Profiles  │                          │           │  • JobCache      │
    └─────────────────────┘                          │           │  • UserTruths    │
                                                      │           │  • ThompsonArm   │
                                                      │           └──────────────────┘
    ┌──────────────────┐                             │
    │  Google AdMob    │◄────ad requests─────────────┤
    │  (Optional)      │                             │
    │                  │                             │
    │  • Native Ads    │─────ads───────────────────►│
    └──────────────────┘                             │
                                                      │
                                                      │
    ┌──────────────────────┐                         │
    │  Apple Services      │◄────uses────────────────┘
    │                      │
    │  • iCloud Storage    │
    │  • Keychain (Creds)  │
    │  • CloudKit (Ads)    │
    │  • App Tracking      │
    │    Transparency      │
    └──────────────────────┘
```

---

## Actors & External Systems

### 1. PRIMARY USER: Job Seeker

**Profile:**
- Career explorers seeking job discovery
- Professionals considering transitions
- Recent graduates entering workforce
- Career changers exploring new paths

**Interactions with App:**
- ✅ Creates comprehensive professional profile (7 Core Data entities)
- ✅ Uploads resume (PDF/DOCX) for auto-parsing
- ✅ Swipes job cards (Right=Interested, Left=Pass, Up=Save)
- ✅ Answers career discovery questions
- ✅ Adjusts Amber/Teal dual-profile slider
- ✅ Views job history and saved listings
- ✅ Generates AI-powered cover letters

**Data Provided:**
- Work experience, education, certifications
- Skills (self-identified + AI-extracted)
- Career preferences (location, salary, remote)
- Behavioral signals (swipe patterns, dwell time)
- Career aspirations and work values

---

### 2. EXTERNAL SYSTEM: Job Source APIs (7 Integrations)

**Purpose:** Aggregate job listings from multiple sources

**API Integrations:**

#### A. **Adzuna API**
- **Type:** Global job aggregator
- **Authentication:** API Key + App ID
- **Rate Limit:** 60 req/min, 100 req/hour (free tier)
- **Data:** Job title, company, location, salary, description
- **Normalization:** Maps to RawJobData struct

#### B. **Greenhouse API**
- **Type:** Company job boards (50+ companies)
- **Authentication:** None (public boards)
- **Rate Limit:** 60 req/min
- **Data:** Job postings from tech companies
- **Smart Selection:** Uses SmartCompanySelector for optimal company routing

#### C. **Lever API**
- **Type:** Company job boards (50+ companies)
- **Authentication:** Optional headers
- **Rate Limit:** 100 req/min
- **Data:** Job postings from startups/tech companies
- **Fallback Companies:** 20 researched companies (Spotify, Netflix, Uber, etc.)

#### D. **LinkedIn API** (Planned)
- **Type:** Professional network jobs
- **Authentication:** OAuth 2.0
- **Rate Limit:** 300 req/month
- **Status:** Infrastructure ready, not yet enabled

#### E. **Jobicy API**
- **Type:** Remote jobs aggregator
- **Authentication:** None (public)
- **Rate Limit:** 10 req/min
- **Data:** Remote-first job listings
- **Specialty:** 100% remote positions

#### F. **USAJobs API**
- **Type:** U.S. Government jobs
- **Authentication:** API Key + User-Agent (email)
- **Rate Limit:** 10 req/min (recommended)
- **Data:** Federal government positions across all sectors
- **Specialty:** Public sector career paths

#### G. **RSS Feeds**
- **Type:** Custom RSS/Atom feed aggregation
- **Authentication:** None
- **Rate Limit:** 20 req/min
- **Data:** Configurable company/sector RSS feeds
- **Flexibility:** Supports any RSS 2.0 or Atom format

**Data Flow:** APIs → RawJobData → Thompson Scoring → JobCache → UI

---

### 3. EXTERNAL SYSTEM: Apple Foundation Models (iOS 26)

**Purpose:** On-device AI for career discovery without external API costs

**Capabilities:**
- ✅ Career question processing (<50ms per question)
- ✅ Behavioral pattern analysis from swipe history
- ✅ RIASEC personality dimension inference
- ✅ Work style preference extraction
- ✅ Skills categorization and validation

**Integration Points:**
- **FastBehavioralLearning:** Real-time swipe pattern analysis
- **DeepBehavioralAnalysis:** Background batch analysis (every 10 swipes)
- **SmartQuestionGenerator:** Contextual question generation based on confidence gaps
- **UserTruths Discovery:** Automated preference extraction

**Privacy Benefits:**
- 100% on-device processing (no cloud APIs)
- Zero AI API costs ($0/month)
- GDPR/CCPA compliant (no external transmission)
- No token usage or rate limiting

**Performance:**
- Question processing: <50ms target
- Deep analysis: ~2s for 10-job batch
- Memory efficient: Uses iOS 26 Neural Engine

---

### 4. EXTERNAL SYSTEM: O*NET Database (U.S. Department of Labor)

**Purpose:** Comprehensive career taxonomy and occupational data

**Data Included (JSON Bundle):**
- ✅ 1,016 O*NET occupational roles
- ✅ 41 Work Activity dimensions (0.0-7.0 importance scores)
- ✅ RIASEC personality profiles (6 Holland Code dimensions)
- ✅ 12 Education levels (O*NET scale 1-12)
- ✅ Work styles and values
- ✅ Skills taxonomy (636 skills across 14 sectors)

**Integration:**
- Embedded as JSON resource (no API calls)
- Loaded via SkillTaxonomyLoader (actor-based caching)
- Used for:
  - Work experience O*NET role selection
  - Education level mapping
  - Thompson scoring enhancement (30% weight)
  - Cross-domain career discovery

**Performance:**
- Initial load: <500ms (cached thereafter)
- Lookup: O(1) hash table access
- Memory: ~5MB uncompressed

---

### 5. EXTERNAL SYSTEM: Google AdMob (Optional/Placeholder)

**Purpose:** Native ad monetization (currently disabled)

**Status:** **PLACEHOLDER MODE**
- Google Mobile Ads SDK commented out in Package.swift
- Using placeholder types for development
- Infrastructure ready but not enabled

**If Enabled:**
- Native ad cards interleaved in job deck (1 ad per 10 jobs)
- ATT consent flow (App Tracking Transparency)
- CloudKit ad performance tracking
- IDFA-based targeting (with user consent)

**Performance Targets:**
- <350KB memory per ad
- <500ms ad load time
- 60fps animation

---

### 6. EXTERNAL SYSTEM: Apple Services

**A. iCloud Storage (Optional)**
- **Purpose:** Cross-device profile sync
- **Status:** Infrastructure ready, not yet enabled
- **Data:** UserProfile, preferences, job history

**B. Keychain (Active)**
- **Purpose:** Secure credential storage
- **Usage:** API keys for job sources
- **Encryption:** Hardware-backed security

**C. CloudKit (Partial)**
- **Purpose:** Ad performance metrics sync
- **Status:** Only for ad analytics (if ads enabled)

**D. App Tracking Transparency (ATT)**
- **Purpose:** User consent for IDFA tracking
- **Required by:** Google AdMob (if enabled)
- **Consent Flow:** ConsentFlowCoordinator

---

## Data Flows (Directional)

### INBOUND to App:
1. **Job Listings:** APIs → App (6 job sources + RSS)
2. **Career Taxonomy:** O*NET Bundle → App (embedded JSON)
3. **AI Processing:** Foundation Models → App (on-device)
4. **Ads:** AdMob → App (optional, native ads)

### OUTBOUND from App:
1. **API Requests:** App → Job Source APIs (search queries)
2. **Ad Requests:** App → AdMob (optional, ad placements)
3. **Analytics:** App → CloudKit (ad performance, optional)

### BIDIRECTIONAL:
1. **User Profile:** User ↔ App ↔ Core Data ↔ iCloud (optional)
2. **Behavioral Data:** User → App → Thompson Engine → Updated Scores

---

## Security & Privacy Architecture

### On-Device Processing (Privacy-First)
- ✅ Resume parsing (local PDFKit + NaturalLanguage framework)
- ✅ Thompson Sampling (<10ms, local computation)
- ✅ AI career questions (Foundation Models, no cloud)
- ✅ Skills matching (local SkillTaxonomy)

### Secure Storage
- ✅ Core Data (encrypted SQLite)
- ✅ Keychain (API credentials)
- ✅ UserDefaults (preferences only, non-sensitive)

### No External AI APIs
- ❌ No OpenAI API calls
- ❌ No Anthropic Claude API
- ❌ No embedding APIs
- ✅ 100% on-device AI via Foundation Models

### User Consent
- ✅ ATT consent for ad tracking (if ads enabled)
- ✅ Explicit onboarding flow
- ✅ Clear data usage explanations

---

## System Boundaries

### INSIDE the App (Manifest & Match V8):
- User profile management
- Job discovery engine
- Thompson Sampling algorithm
- AI career question system
- Resume parsing
- Cover letter generation
- Behavioral learning
- Data persistence (Core Data)

### OUTSIDE the App (External Dependencies):
- Job listing APIs (Adzuna, Greenhouse, Lever, etc.)
- O*NET career database (bundled, but external origin)
- Apple Foundation Models (iOS 26 system framework)
- Google AdMob (optional)
- Apple Services (iCloud, Keychain, CloudKit)

---

## Non-Functional Requirements

### Performance
- Thompson Sampling: <10ms per job (357x faster than alternatives)
- API response: <2s per job source
- Memory baseline: <200MB
- UI responsiveness: 60fps animations

### Scalability
- Supports 8,000+ jobs in single session
- 50-job cache with LRU eviction
- Streaming pipeline for large datasets
- Background job prefetching

### Availability
- Offline mode: Cached jobs available
- Graceful API degradation (circuit breakers)
- Fallback job sources if primary fails
- Rate limit handling with exponential backoff

### Security
- HTTPS for all API calls
- Keychain for credential storage
- No plain-text API keys in code
- Certificate pinning ready

---

## Technology Stack (External Systems)

| System | Technology | Protocol | Auth |
|--------|-----------|----------|------|
| Job APIs | REST | HTTPS | API Key / None |
| O*NET | JSON Bundle | File I/O | None |
| Foundation Models | Native iOS | In-Process | None |
| AdMob | SDK | HTTPS | API Key |
| Core Data | SQLite | Local DB | None |
| iCloud | CloudKit | HTTPS | Apple ID |
| Keychain | Secure Enclave | Hardware | None |

---

## Summary

**Primary Actor:** Job Seeker using iPhone/iPad running iOS 26+

**External Systems:**
- 7 Job Source APIs (real-time job aggregation)
- O*NET Database (career taxonomy, bundled)
- Apple Foundation Models (on-device AI)
- Google AdMob (optional monetization)
- Apple Services (iCloud, Keychain, CloudKit)

**Data Sovereignty:**
- All AI processing on-device (privacy-first)
- User data stored locally in Core Data
- No external AI APIs (zero cost, zero data leakage)
- Optional iCloud sync for multi-device

**Competitive Advantage:**
- 357x faster Thompson Sampling (<10ms vs 3570ms)
- On-device AI (no cloud costs)
- Multi-source job aggregation (7 sources)
- Behavioral learning from swipe patterns
