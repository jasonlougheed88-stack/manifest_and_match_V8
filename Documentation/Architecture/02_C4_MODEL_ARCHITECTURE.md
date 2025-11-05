# C4 Model Architecture: Manifest and Match V7

**Document Version:** 1.0
**Last Updated:** October 17, 2025
**Status:** Production
**iOS Target:** iOS 18.0+
**Swift Version:** 6.1

---

## Table of Contents

1. [Introduction](#introduction)
2. [C4 Level 1: Context Diagram](#c4-level-1-context-diagram)
3. [C4 Level 2: Container Diagram](#c4-level-2-container-diagram)
4. [C4 Level 3: Component Diagram](#c4-level-3-component-diagram)
5. [C4 Level 4: Code Diagram](#c4-level-4-code-diagram)
6. [Package Dependencies](#package-dependencies)
7. [Data Flow Patterns](#data-flow-patterns)

---

## Introduction

This document provides comprehensive C4 Model architecture documentation for Manifest and Match V7, an AI-powered iOS job matching application. The architecture employs Thompson Sampling for intelligent job recommendations, integrates with 28+ job sources (18 Greenhouse companies, 10 Lever companies, RSS feeds), and implements strict performance budgets for production reliability.

**Architecture Philosophy:**
- **Modular Design:** 12-package architecture with clear separation of concerns
- **Swift 6 Concurrency:** Full @MainActor, Sendable compliance for type safety
- **Performance-First:** Real-time monitoring, memory budgets, production health checks
- **AI Transparency:** Explainable AI with Thompson Sampling explanations
- **Accessibility:** WCAG 2.1 AAA compliance throughout

---

## C4 Level 1: Context Diagram

The Context Diagram shows Manifest and Match V7 within its ecosystem, including external systems, users, and infrastructure dependencies.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        EXTERNAL JOB SOURCES                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐          │
│  │  Greenhouse API  │  │    Lever API     │  │   RSS Feeds      │          │
│  │  (18 companies)  │  │  (10 companies)  │  │  - RemoteOK      │          │
│  │                  │  │                  │  │  - WeWorkRemotely│          │
│  │  Rate Limited:   │  │  Rate Limited:   │  │  - RemoteWoman   │          │
│  │  100 req/min     │  │  60 req/min      │  │  - Remotive      │          │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘          │
│           │                     │                     │                     │
│           │ HTTPS/JSON          │ HTTPS/JSON          │ HTTPS/XML           │
│           └─────────────────────┴─────────────────────┘                     │
│                                 │                                           │
└─────────────────────────────────┼───────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      MANIFEST AND MATCH V7                                  │
│                      iOS Application                                        │
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                    CORE RESPONSIBILITIES                           │    │
│  ├────────────────────────────────────────────────────────────────────┤    │
│  │  • AI-Powered Job Matching (Thompson Sampling)                     │    │
│  │  • Multi-Source Job Aggregation (28+ sources)                      │    │
│  │  • Real-Time Performance Monitoring                                │    │
│  │  • Resume Analysis & Skill Extraction                              │    │
│  │  • Application Tracking & History                                  │    │
│  │  • Semantic Job-Resume Matching                                    │    │
│  │  • Production Health Monitoring                                    │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
           │                    │                    │
           │                    │                    │
           ▼                    ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│   iOS Keychain   │  │   Core Data      │  │   URLSession     │
│                  │  │   (SQLite)       │  │   (Networking)   │
│  Stores:         │  │                  │  │                  │
│  • API Keys      │  │  Stores:         │  │  Features:       │
│  • Auth Tokens   │  │  • User Profile  │  │  • Rate Limiting │
│  • Credentials   │  │  • Job History   │  │  • Circuit Break │
│                  │  │  • Thompson Arms │  │  • Request Pool  │
└──────────────────┘  │  • Applications  │  └──────────────────┘
                      │  • Cache Data    │
                      └──────────────────┘
           │
           │
           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                             END USERS                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │  Job Seekers (iOS 18+ Users)                                       │    │
│  ├────────────────────────────────────────────────────────────────────┤    │
│  │  • Upload resume (PDF)                                             │    │
│  │  • Swipe through AI-matched jobs                                   │    │
│  │  • View match explanations                                         │    │
│  │  • Track applications                                              │    │
│  │  • Monitor system performance                                      │    │
│  │  • Accessible via VoiceOver, Dynamic Type                          │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### External Systems

| System | Type | Purpose | Rate Limits | Authentication |
|--------|------|---------|-------------|----------------|
| **Greenhouse API** | REST API | Job listings from 18 companies | 100 req/min | API Key (Keychain) |
| **Lever API** | REST API | Job listings from 10 companies | 60 req/min | API Key (Keychain) |
| **RemoteOK** | RSS Feed | Remote job aggregator | No limit | None |
| **WeWorkRemotely** | RSS Feed | Remote job board | No limit | None |
| **RemoteWoman** | RSS Feed | Diversity-focused jobs | No limit | None |
| **Remotive** | RSS Feed | Remote job listings | No limit | None |
| **iOS Keychain** | System Service | Secure credential storage | N/A | System |
| **Core Data** | Framework | Local persistence | N/A | System |
| **URLSession** | Framework | Network communication | N/A | System |

### User Interactions

**Primary User:** Job Seeker (iOS 18+ device owner)

**User Actions:**
1. Upload resume (PDF format)
2. Swipe jobs (left = pass, right = interested)
3. View AI match explanations
4. Track application history
5. Monitor system performance
6. Access all features via VoiceOver

---

## C4 Level 2: Container Diagram

The Container Diagram shows the major architectural containers within the iOS application.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     MANIFEST AND MATCH V7 iOS APP                           │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        PRESENTATION LAYER                             │  │
│  │                          (V7UI Package)                               │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • 4-Tab Sacred Navigation (Deck, History, Profile, Analytics)       │  │
│  │  • SwiftUI Views with @MainActor compliance                          │  │
│  │  • Accessibility: VoiceOver, Dynamic Type, Reduce Motion             │  │
│  │  • Real-Time Performance Overlay                                     │  │
│  │  • ExplainFitSheet (AI Transparency)                                 │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        AI/ML ENGINE                                   │  │
│  │                      (V7Thompson Package)                             │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Thompson Sampling Algorithm (Bayesian optimization)               │  │
│  │  • OptimizedThompsonEngine (SIMD acceleration)                       │  │
│  │  • FastBetaSampler (Beta distribution sampling)                      │  │
│  │  • ThompsonCache (3-tier caching: hot, warm, cold)                   │  │
│  │  • ThompsonExplanationEngine (AI transparency)                       │  │
│  │  • SwipePatternAnalyzer (user behavior learning)                     │  │
│  │  • RealTimeScoring (sub-100ms scoring)                               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        SERVICE LAYER                                  │  │
│  │                      (V7Services Package)                             │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • JobDiscoveryCoordinator (28+ job source orchestration)            │  │
│  │  • Greenhouse API Client (18 companies)                              │  │
│  │  • Lever API Client (10 companies)                                   │  │
│  │  • RSSFeedJobSource (4 RSS feeds)                                    │  │
│  │  • NetworkOptimizer (rate limiting, circuit breaker)                 │  │
│  │  • RequestCoalescer (deduplication)                                  │  │
│  │  • ApplicationTracker (job application management)                   │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        PARSING & ANALYSIS                             │  │
│  │             (V7JobParsing, V7AIParsing, V7Embeddings)                 │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • JobDescriptionParser (extract skills, seniority)                  │  │
│  │  • ResumeParser (PDF text extraction)                                │  │
│  │  • SkillExtractor (NLP-based skill identification)                   │  │
│  │  • VectorEmbedder (semantic embeddings)                              │  │
│  │  • SemanticMatcher (job-resume similarity)                           │  │
│  │  • SeniorityDetector (experience level classification)               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        DATA LAYER                                     │  │
│  │                  (V7Data, V7Migration Packages)                       │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • PersistenceController (Core Data stack)                           │  │
│  │  • V7DataModel (entities: UserProfile, Job, ThompsonArm, etc.)       │  │
│  │  • V7MigrationCoordinator (schema migrations)                        │  │
│  │  • Job Cache (LRU eviction, 1000-job capacity)                       │  │
│  │  • Thompson State Persistence                                        │  │
│  │  • Application History Storage                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                    PERFORMANCE MONITORING                             │  │
│  │                     (V7Performance Package)                           │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • PerformanceMonitor (real-time metrics)                            │  │
│  │  • MemoryBudgetManager (100MB Thompson, 200MB total limits)          │  │
│  │  • ProductionHealthMonitor (SLA tracking)                            │  │
│  │  • FPSTracker (60 FPS enforcement)                                   │  │
│  │  • ContinuousPerformanceMonitor (24/7 validation)                    │  │
│  │  • EmergencyRecoveryProtocol (automatic failover)                    │  │
│  │  • BiasDetection (fairness monitoring)                               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                        CORE UTILITIES                                 │  │
│  │                       (V7Core Package)                                │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Shared Protocols (Monitorable, Cacheable, etc.)                   │  │
│  │  • Common Types (Result builders, type aliases)                      │  │
│  │  • Error Handling (V7Error hierarchy)                                │  │
│  │  • Logging Infrastructure                                            │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Container Responsibilities

| Container | Primary Responsibility | Key Technologies | Performance Target |
|-----------|------------------------|------------------|-------------------|
| **Presentation Layer** | User interface, accessibility | SwiftUI, @MainActor | 60 FPS |
| **AI/ML Engine** | Job ranking, Thompson Sampling | SIMD, Beta distributions | <100ms scoring |
| **Service Layer** | External API integration | URLSession, Circuit Breaker | 100% uptime |
| **Parsing & Analysis** | Text extraction, semantic matching | NLP, Vector embeddings | <500ms parsing |
| **Data Layer** | Persistence, caching | Core Data, SQLite | <50ms queries |
| **Performance Monitoring** | Real-time metrics, health checks | MetricKit, custom monitors | <1% overhead |
| **Core Utilities** | Shared infrastructure | Protocols, error handling | N/A |

---

## C4 Level 3: Component Diagram

The Component Diagram breaks down each container into its constituent packages and major components.

### 3.1 V7Thompson Package (AI/ML Engine)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           V7Thompson Package                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ThompsonSamplingEngine                                               │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Core Thompson Sampling implementation                             │  │
│  │  • Beta distribution parameter management (α, β)                     │  │
│  │  • Multi-armed bandit algorithm                                      │  │
│  │  • Success/failure update logic                                      │  │
│  │  • Exploration vs exploitation balancing                             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  OptimizedThompsonEngine                                              │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • SIMD-accelerated sampling (4x faster)                             │  │
│  │  • Vectorized Beta distribution operations                           │  │
│  │  • Parallel arm evaluation                                           │  │
│  │  • Memory pool optimization                                          │  │
│  │  • Cache-friendly data structures                                    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  FastBetaSampler                                                      │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Optimized Beta(α, β) distribution sampling                        │  │
│  │  • Cheng's algorithm implementation                                  │  │
│  │  • Pre-computed lookup tables                                        │  │
│  │  • Statistical validation (Kolmogorov-Smirnov)                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ThompsonCache                                                        │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • 3-Tier Caching Strategy:                                          │  │
│  │    - Hot: Recent samples (LRU, 100 items)                            │  │
│  │    - Warm: Frequent arms (usage-based, 500 items)                    │  │
│  │    - Cold: All arms (disk-backed)                                    │  │
│  │  • Cache coherency validation                                        │  │
│  │  • TTL management (5-minute expiry)                                  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ThompsonExplanationEngine                                            │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • AI transparency: "Why this job?"                                  │  │
│  │  • Human-readable explanations                                       │  │
│  │  • Confidence scores (0-100%)                                        │  │
│  │  • Feature attribution (skills, seniority, location)                │  │
│  │  • Exploration vs exploitation reasoning                             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  SwipePatternAnalyzer                                                 │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • User behavior pattern recognition                                 │  │
│  │  • Swipe velocity analysis                                           │  │
│  │  • Time-of-day preferences                                           │  │
│  │  • Job category affinity scoring                                     │  │
│  │  • Feedback loop to Thompson engine                                  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  RealTimeScoring                                                      │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Sub-100ms job scoring guarantee                                   │  │
│  │  • Asynchronous score computation                                    │  │
│  │  • Pre-computation for upcoming jobs                                 │  │
│  │  • Score caching and invalidation                                    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Types:**
- `ThompsonArm`: Represents a job category arm (α, β parameters)
- `ThompsonScore`: Contains score value + explanation
- `SamplingResult`: Outcome of Thompson sampling operation
- `ExplorationStrategy`: Enum for exploration modes

**Dependencies:**
- V7Core (protocols: ThompsonMonitorable, Cacheable)

---

### 3.2 V7Services Package (Service Layer)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          V7Services Package                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  JobDiscoveryCoordinator                                              │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Orchestrates 28+ job sources                                      │  │
│  │  • SmartCompanySelector (Thompson-based selection)                   │  │
│  │  • Parallel job fetching (10 concurrent requests)                    │  │
│  │  • Source priority management                                        │  │
│  │  • Duplicate detection (title + company hash)                        │  │
│  │  • Freshness tracking (24-hour refresh)                              │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│              ┌─────────────────────┼─────────────────────┐                  │
│              ▼                     ▼                     ▼                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐          │
│  │ Greenhouse API   │  │   Lever API      │  │  RSSFeedJob      │          │
│  │    Client        │  │    Client        │  │    Source        │          │
│  ├──────────────────┤  ├──────────────────┤  ├──────────────────┤          │
│  │ • 18 companies   │  │ • 10 companies   │  │ • RemoteOK       │          │
│  │ • Rate: 100/min  │  │ • Rate: 60/min   │  │ • WeWorkRemotely │          │
│  │ • Pagination     │  │ • Pagination     │  │ • RemoteWoman    │          │
│  │ • JSON parsing   │  │ • JSON parsing   │  │ • Remotive       │          │
│  │ • Auth: API Key  │  │ • Auth: API Key  │  │ • XML parsing    │          │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘          │
│              │                     │                     │                  │
│              └─────────────────────┼─────────────────────┘                  │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  NetworkOptimizer                                                     │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Rate Limiting (token bucket algorithm)                            │  │
│  │  • Circuit Breaker (fail-fast on errors)                             │  │
│  │  • Exponential Backoff (retry strategy)                              │  │
│  │  • Connection Pooling (reuse URLSession)                             │  │
│  │  • Timeout Management (30s default)                                  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  RequestCoalescer                                                     │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Deduplicates identical requests                                   │  │
│  │  • Batches similar requests                                          │  │
│  │  • Request merging (combine company queries)                         │  │
│  │  • Response fanout to multiple callers                               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ApplicationTracker                                                   │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Track job applications                                            │  │
│  │  • Application status (applied, interviewing, rejected, etc.)        │  │
│  │  • Timeline visualization                                            │  │
│  │  • Notes and follow-up reminders                                     │  │
│  │  • Export to CSV                                                     │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Types:**
- `JobSource`: Protocol for all job sources
- `APIClient`: Base protocol for API integrations
- `JobListing`: Unified job representation
- `RateLimitState`: Token bucket state
- `CircuitBreakerState`: Open/Half-Open/Closed states

**Dependencies:**
- V7Core (error handling, logging)
- V7Thompson (SmartCompanySelector)
- V7JobParsing (job parsing)

---

### 3.3 V7Data Package (Data Layer)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            V7Data Package                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  PersistenceController                                                │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • NSPersistentContainer management                                  │  │
│  │  • Core Data stack initialization                                    │  │
│  │  • Background context handling                                       │  │
│  │  • View context (@MainActor bound)                                   │  │
│  │  • Batch operations (efficient bulk updates)                         │  │
│  │  • Error recovery and retry logic                                    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  V7DataModel (Core Data Schema)                                       │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  Entities:                                                            │  │
│  │  • UserProfile: User preferences, resume, skills                     │  │
│  │  • Job: Job listings (title, company, description, etc.)             │  │
│  │  • ThompsonArm: Thompson Sampling state (α, β, category)             │  │
│  │  • Application: Job application tracking                             │  │
│  │  • SwipeHistory: User swipe decisions                                │  │
│  │  • JobCache: Cached job data                                         │  │
│  │  • PerformanceMetric: Performance monitoring data                    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  JobCache                                                             │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • LRU eviction policy (1000-job capacity)                           │  │
│  │  • TTL management (24-hour expiry)                                   │  │
│  │  • Cache hit/miss metrics                                            │  │
│  │  • Preload upcoming jobs                                             │  │
│  │  • Invalidation on user preference change                            │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Relationships:**
- UserProfile (1) → (N) Application
- Job (1) → (N) Application
- ThompsonArm (1) → (N) Job (category-based)
- UserProfile (1) → (N) SwipeHistory

**Dependencies:**
- V7Core (error handling)
- V7Migration (schema migrations)

---

### 3.4 V7UI Package (Presentation Layer)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                             V7UI Package                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  MainTabView (4-Tab Sacred Navigation)                                │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  Tab 1: Deck (Job Swiping)                                           │  │
│  │  Tab 2: History (Application Tracking)                               │  │
│  │  Tab 3: Profile (User Settings)                                      │  │
│  │  Tab 4: Analytics (Performance & Insights)                           │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│              │                │                │                │           │
│              ▼                ▼                ▼                ▼           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │  DeckScreen  │  │   History    │  │   Profile    │  │  Analytics   │    │
│  │              │  │   Screen     │  │   Screen     │  │   Screen     │    │
│  ├──────────────┤  ├──────────────┤  ├──────────────┤  ├──────────────┤    │
│  │ • Job cards  │  │ • Timeline   │  │ • Resume     │  │ • ML Insights│    │
│  │ • Swipe UI   │  │ • Filters    │  │ • Settings   │  │ • Charts     │    │
│  │ • Match %    │  │ • Export     │  │ • API keys   │  │ • Real-time  │    │
│  │ • "Explain"  │  │ • Search     │  │ • Privacy    │  │   metrics    │    │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘    │
│         │                                                                   │
│         ▼                                                                   │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ExplainFitSheet                                                      │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • "Why this job?" explanation                                       │  │
│  │  • Skill match breakdown                                             │  │
│  │  • Seniority alignment                                               │  │
│  │  • Thompson Sampling confidence                                      │  │
│  │  • Feature attribution visualization                                 │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  Accessibility Components                                             │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • VoiceOver labels (100% coverage)                                  │  │
│  │  • Dynamic Type support (all text scales)                            │  │
│  │  • Reduce Motion responders                                          │  │
│  │  • High Contrast mode                                                │  │
│  │  • Keyboard navigation                                               │  │
│  │  • WCAG 2.1 AAA compliance                                           │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  Performance Overlay (Debug/Production)                               │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Real-time FPS display                                             │  │
│  │  • Memory usage (current/budget)                                     │  │
│  │  • Thompson scoring time                                             │  │
│  │  • Network request counts                                            │  │
│  │  • Cache hit rates                                                   │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Views:**
- `DeckScreen`: Main job swiping interface
- `JobCardView`: Individual job card
- `ExplainFitSheet`: AI explanation modal
- `HistoryScreen`: Application timeline
- `ProfileScreen`: User settings
- `AnalyticsScreen`: ML insights dashboard

**Dependencies:**
- V7Core (shared UI components)
- V7Thompson (explanation data)
- V7Data (Core Data @FetchRequest)
- V7Performance (performance metrics)

---

### 3.5 V7JobParsing Package (Job Analysis)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        V7JobParsing Package                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  JobDescriptionParser                                                 │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Extract structured data from job descriptions                     │  │
│  │  • Requirements vs responsibilities separation                       │  │
│  │  • Compensation extraction (regex-based)                             │  │
│  │  • Benefits parsing                                                  │  │
│  │  • Location detection (remote, hybrid, onsite)                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  SkillExtractor                                                       │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • NLP-based skill identification                                    │  │
│  │  • Skill taxonomy (programming, tools, soft skills)                  │  │
│  │  • Synonym matching (React === ReactJS)                              │  │
│  │  • Skill importance weighting                                        │  │
│  │  • 500+ skill dictionary                                             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  SeniorityDetector                                                    │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Experience level classification                                   │  │
│  │  • Levels: Entry, Junior, Mid, Senior, Lead, Principal               │  │
│  │  • Years of experience extraction                                    │  │
│  │  • Title-based heuristics                                            │  │
│  │  • Confidence scoring                                                │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Dependencies:**
- V7Core (shared utilities)
- NaturalLanguage framework (Apple NLP)

---

### 3.6 V7AIParsing Package (Resume Analysis)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         V7AIParsing Package                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ResumeParser                                                         │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • PDF resume processing                                             │  │
│  │  • Multi-column layout handling                                      │  │
│  │  • Section detection (Education, Experience, Skills)                 │  │
│  │  • Date parsing (various formats)                                    │  │
│  │  • Contact information extraction                                    │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  PDFTextExtractor                                                     │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • PDFKit-based text extraction                                      │  │
│  │  • OCR fallback for scanned PDFs                                     │  │
│  │  • Layout preservation                                               │  │
│  │  • Table extraction                                                  │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  SkillMatcher                                                         │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Resume skills → Job requirements matching                         │  │
│  │  • Skill gap analysis                                                │  │
│  │  • Match percentage calculation                                      │  │
│  │  • Transferable skills detection                                     │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Dependencies:**
- V7Core
- V7JobParsing (shared skill extraction)
- PDFKit (Apple framework)
- Vision framework (OCR)

---

### 3.7 V7Embeddings Package (Semantic Matching)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        V7Embeddings Package                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  VectorEmbedder                                                       │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Text → Vector embedding conversion                                │  │
│  │  • NLEmbedding (Apple's on-device embeddings)                        │  │
│  │  • Dimensionality: 768-dimensional vectors                           │  │
│  │  • Caching for repeated text                                         │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  SemanticMatcher                                                      │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Cosine similarity calculation                                     │  │
│  │  • Job description ↔ Resume semantic matching                        │  │
│  │  • Similarity scoring (0-1 range)                                    │  │
│  │  • Accelerate framework (SIMD optimization)                          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Dependencies:**
- V7Core
- NaturalLanguage framework (NLEmbedding)
- Accelerate framework (SIMD)

---

### 3.8 V7Performance Package (Monitoring)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       V7Performance Package                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  PerformanceMonitor                                                   │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Real-time metric collection                                       │  │
│  │  • Thompson scoring time tracking                                    │  │
│  │  • Network request monitoring                                        │  │
│  │  • UI responsiveness tracking                                        │  │
│  │  • Metric aggregation (1-minute windows)                             │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  MemoryBudgetManager                                                  │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Budget Enforcement:                                               │  │
│  │    - Thompson engine: 100MB limit                                    │  │
│  │    - Total app: 200MB limit                                          │  │
│  │    - Cache: 50MB limit                                               │  │
│  │  • Memory pressure handling                                          │  │
│  │  • Automatic cache eviction                                          │  │
│  │  • Emergency cleanup procedures                                      │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ProductionHealthMonitor                                              │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • SLA tracking (99.9% uptime target)                                │  │
│  │  • Error rate monitoring (<1% target)                                │  │
│  │  • Latency percentiles (P50, P95, P99)                               │  │
│  │  • Crash detection and reporting                                     │  │
│  │  • Health score calculation                                          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  FPSTracker                                                           │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • 60 FPS enforcement                                                │  │
│  │  • Frame drop detection                                              │  │
│  │  • CADisplayLink-based measurement                                   │  │
│  │  • Alerts when FPS < 55                                              │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  ContinuousPerformanceMonitor                                         │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • 24/7 validation in production                                     │  │
│  │  • Background monitoring                                             │  │
│  │  • Anomaly detection (statistical)                                   │  │
│  │  • Trend analysis (7-day rolling average)                            │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  EmergencyRecoveryProtocol                                            │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Automatic failover on critical errors                             │  │
│  │  • Graceful degradation strategies                                   │  │
│  │  • Fallback to cached data                                           │  │
│  │  • User notification on recovery                                     │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  BiasDetection (Fairness Monitoring)                                  │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Thompson Sampling fairness validation                             │  │
│  │  • Category distribution analysis                                    │  │
│  │  • Demographic parity checks                                         │  │
│  │  • Bias alert system                                                 │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Dependencies:**
- V7Core (monitoring protocols)
- MetricKit (Apple framework)

---

### 3.9 V7Migration Package (Data Migration)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        V7Migration Package                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  V7MigrationCoordinator                                               │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • Core Data schema migration orchestration                          │  │
│  │  • Version detection (V6 → V7)                                        │  │
│  │  • Migration plan execution                                          │  │
│  │  • Rollback on failure                                               │  │
│  │  • Progress reporting                                                │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Dependencies:**
- V7Data (Core Data models)
- V7Core

---

### 3.10 V7Core Package (Shared Infrastructure)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           V7Core Package                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  Shared Protocols                                                     │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • ThompsonMonitorable: Performance monitoring contract              │  │
│  │  • Cacheable: Cache behavior contract                                │  │
│  │  • Parseable: Parsing contract                                       │  │
│  │  • Loggable: Logging contract                                        │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  Error Handling                                                       │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • V7Error hierarchy (NetworkError, ParseError, etc.)                │  │
│  │  • Error recovery strategies                                         │  │
│  │  • User-friendly error messages                                      │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  Logging Infrastructure                                               │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • OSLog-based structured logging                                    │  │
│  │  • Log levels (debug, info, warning, error, critical)                │  │
│  │  • Privacy-preserving logging                                        │  │
│  │  • Performance-optimized (conditional logging)                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Dependencies:** None (base package)

---

### 3.11 V7ResumeAnalysis Package

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      V7ResumeAnalysis Package                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │  Resume Analysis Coordinator                                          │  │
│  ├───────────────────────────────────────────────────────────────────────┤  │
│  │  • High-level resume analysis orchestration                          │  │
│  │  • Integrates parsing, skill extraction, experience detection        │  │
│  │  • Resume quality scoring                                            │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Dependencies:**
- V7AIParsing (resume parsing)
- V7JobParsing (skill extraction)

---

## C4 Level 4: Code Diagram

The Code Diagram shows naming conventions, file organization, Swift 6 patterns, and critical class responsibilities.

### 4.1 Swift 6 Concurrency Patterns

```swift
// PATTERN 1: @MainActor for UI Components
@MainActor
final class DeckViewModel: ObservableObject {
    @Published var currentJob: Job?
    @Published var matchScore: Double = 0.0

    func loadNextJob() async {
        // Safe to update @Published from async context
        currentJob = await jobService.fetchNext()
    }
}

// PATTERN 2: Sendable for Data Transfer
struct JobListing: Sendable {
    let id: UUID
    let title: String
    let company: String
    let description: String
}

// PATTERN 3: Actor for Thread-Safe State
actor ThompsonCache {
    private var hotCache: [String: CachedArm] = [:]
    private var warmCache: [String: CachedArm] = [:]

    func get(_ key: String) -> CachedArm? {
        // Thread-safe access
        hotCache[key] ?? warmCache[key]
    }
}

// PATTERN 4: Structured Concurrency
func fetchAllJobs() async throws -> [Job] {
    try await withThrowingTaskGroup(of: [Job].self) { group in
        // Parallel fetching from multiple sources
        group.addTask { try await fetchGreenhouseJobs() }
        group.addTask { try await fetchLeverJobs() }
        group.addTask { try await fetchRSSJobs() }

        var allJobs: [Job] = []
        for try await jobs in group {
            allJobs.append(contentsOf: jobs)
        }
        return allJobs
    }
}
```

### 4.2 Naming Conventions

```
TYPE NAMING (PascalCase):
├─ Classes:          ThompsonSamplingEngine, JobDiscoveryCoordinator
├─ Structs:          JobListing, ThompsonScore, UserProfile
├─ Protocols:        ThompsonMonitorable, Cacheable, JobSource
├─ Enums:            ExplorationStrategy, CircuitBreakerState
├─ Actors:           ThompsonCache, NetworkOptimizer

METHOD NAMING (camelCase):
├─ Actions:          fetchJobs(), updateThompsonArm(), parseResume()
├─ Computations:     calculateScore(), computeSimilarity(), extractSkills()
├─ Boolean queries:  isValid(), hasExpired(), canFetch()
├─ Async methods:    loadNextJob(), fetchAllSources() (async suffix implied)

PROPERTY NAMING (camelCase):
├─ Instance vars:    currentJob, matchScore, userProfile
├─ Constants:        maxCacheSize, defaultTimeout, thompsonBudgetMB

FILE NAMING (PascalCase.swift):
├─ Main types:       ThompsonSamplingEngine.swift
├─ Extensions:       ThompsonSamplingEngineExtensions.swift
├─ Tests:            ThompsonSamplingEngineTests.swift
```

### 4.3 File Organization

```
Package Structure:
V7Thompson/
├─ Package.swift
├─ Sources/
│  └─ V7Thompson/
│     ├─ V7Thompson.swift                    # Public API
│     ├─ ThompsonSamplingEngine.swift        # Core algorithm
│     ├─ OptimizedThompsonEngine.swift       # SIMD optimized
│     ├─ FastBetaSampler.swift               # Beta sampling
│     ├─ ThompsonCache.swift                 # Caching layer
│     ├─ ThompsonExplanationEngine.swift     # AI transparency
│     ├─ SwipePatternAnalyzer.swift          # User behavior
│     ├─ RealTimeScoring.swift               # Performance
│     ├─ ThompsonTypes.swift                 # Shared types
│     └─ Utilities/
│        ├─ BetaDistribution.swift
│        └─ StatisticalValidation.swift
└─ Tests/
   └─ V7ThompsonTests/
      ├─ ThompsonSamplingEngineTests.swift
      ├─ CacheTests.swift
      └─ PerformanceTests.swift
```

### 4.4 Critical Classes and Responsibilities

#### ThompsonSamplingEngine

```swift
/// Core Thompson Sampling implementation for multi-armed bandit job selection
public final class ThompsonSamplingEngine: ThompsonMonitorable {
    // MARK: - Properties
    private var arms: [String: ThompsonArm]      // Job category arms
    private let cache: ThompsonCache              // 3-tier caching
    private let explainer: ThompsonExplanationEngine

    // MARK: - Core Algorithm
    /// Samples from Beta distribution for each arm and selects best
    /// - Returns: Selected job category with explanation
    /// - Complexity: O(n) where n = number of arms
    /// - Performance: <100ms for 1000 arms
    public func selectArm() async -> (category: String, explanation: String)

    /// Updates arm parameters based on user feedback
    /// - Parameters:
    ///   - category: Job category that was shown
    ///   - success: Whether user swiped right (success) or left (failure)
    public func updateArm(category: String, success: Bool) async

    // MARK: - Monitoring
    public var currentMemoryUsage: Int64 { /* MetricKit integration */ }
    public var scoringTimeMs: Double { /* Performance tracking */ }
}
```

#### JobDiscoveryCoordinator

```swift
/// Orchestrates job fetching from 28+ sources with intelligent scheduling
@MainActor
public final class JobDiscoveryCoordinator: ObservableObject {
    // MARK: - Properties
    private let greenhouseClient: GreenhouseAPIClient     // 18 companies
    private let leverClient: LeverAPIClient               // 10 companies
    private let rssFeedSource: RSSFeedJobSource           // 4 RSS feeds
    private let companySelector: SmartCompanySelector     // Thompson-based
    private let networkOptimizer: NetworkOptimizer        // Rate limiting

    // MARK: - Job Discovery
    /// Fetches jobs from all sources in parallel
    /// - Returns: Deduplicated job listings
    /// - Complexity: O(n) where n = total jobs
    /// - Performance: <5s for 10,000 jobs
    public func discoverJobs() async throws -> [JobListing]

    /// Intelligent company selection using Thompson Sampling
    /// - Returns: Top N companies to query based on historical success
    public func selectCompaniesToQuery(count: Int) async -> [String]
}
```

#### PersistenceController

```swift
/// Manages Core Data stack with background context handling
public final class PersistenceController: Sendable {
    // MARK: - Properties
    public let container: NSPersistentContainer

    @MainActor
    public var viewContext: NSManagedObjectContext { container.viewContext }

    // MARK: - Context Management
    /// Creates background context for async operations
    public func newBackgroundContext() -> NSManagedObjectContext

    /// Performs batch save with error recovery
    public func save() async throws

    // MARK: - Queries
    /// Optimized job fetch with predicates
    /// - Complexity: O(log n) with proper indexes
    public func fetchJobs(
        matching predicate: NSPredicate,
        limit: Int
    ) async throws -> [Job]
}
```

#### PerformanceMonitor

```swift
/// Real-time performance monitoring with budget enforcement
public actor PerformanceMonitor {
    // MARK: - Budgets
    private let thompsonBudgetMB: Int = 100
    private let totalAppBudgetMB: Int = 200
    private let targetFPS: Double = 60.0

    // MARK: - Monitoring
    /// Collects metrics every 1 second
    public func startMonitoring() async

    /// Checks if budget is exceeded
    /// - Returns: true if within budget, false otherwise
    public func isWithinBudget() -> Bool

    /// Emergency cleanup when budget exceeded
    public func emergencyCleanup() async

    // MARK: - Metrics
    public func currentMetrics() -> PerformanceMetrics
}
```

#### DeckScreen

```swift
/// Main job swiping interface with real-time Thompson Sampling
@MainActor
public struct DeckScreen: View {
    // MARK: - Properties
    @StateObject private var viewModel: DeckViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // MARK: - Body
    public var body: some View {
        ZStack {
            jobCardsStack
            explanationButton
            performanceOverlay
        }
        .gesture(swipeGesture)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Job deck with \(viewModel.remainingJobs) jobs")
    }

    // MARK: - Gestures
    private var swipeGesture: some Gesture {
        DragGesture()
            .onEnded { value in
                handleSwipe(translation: value.translation)
            }
    }
}
```

### 4.5 Key Design Patterns

| Pattern | Usage | Example |
|---------|-------|---------|
| **Repository** | Data access abstraction | `JobRepository` wraps Core Data |
| **Observer** | Reactive updates | `@Published` properties in ViewModels |
| **Strategy** | Algorithm selection | `ExplorationStrategy` enum |
| **Factory** | Object creation | `JobSourceFactory` creates API clients |
| **Singleton** | Shared resources | `PersistenceController.shared` |
| **Circuit Breaker** | Fault tolerance | `NetworkOptimizer` protects APIs |
| **Cache-Aside** | Performance | `ThompsonCache` 3-tier strategy |
| **Actor** | Thread safety | `ThompsonCache` actor isolation |

### 4.6 Swift 6 Strict Concurrency Compliance

All packages compile with `StrictConcurrency` enabled:

```swift
// Package.swift
swiftSettings: [
    .enableExperimentalFeature("StrictConcurrency")
]
```

**Compliance Requirements:**
1. All UI types are `@MainActor`
2. All data transfer types are `Sendable`
3. Mutable shared state uses `actor` isolation
4. No implicit global state
5. All async functions properly marked
6. Task groups for structured concurrency

---

## Package Dependencies

```
Dependency Graph (12 packages):

V7Core (base package)
  ↑
  ├─ V7Thompson
  │   ↑
  │   └─ V7Services
  │        ↑
  │        └─ V7UI
  ├─ V7Data
  │   ↑
  │   ├─ V7Migration
  │   └─ V7UI
  ├─ V7JobParsing
  │   ↑
  │   ├─ V7Services
  │   └─ V7ResumeAnalysis
  ├─ V7AIParsing
  │   ↑
  │   └─ V7ResumeAnalysis
  ├─ V7Embeddings
  │   ↑
  │   └─ V7Services
  ├─ V7Performance
  │   ↑
  │   └─ V7UI
  └─ V7UI (presentation layer)

Circular Dependency Prevention:
- V7Services depends on V7Core (NOT V7Performance)
- V7Services implements ThompsonMonitorable from V7Core
- Monitoring data flows: V7Services → V7Performance → V7UI
```

### External Dependencies

| Package | External Dependency | Purpose |
|---------|-------------------|---------|
| V7Data | Core Data | Persistence |
| V7UI | SwiftUI | User interface |
| V7JobParsing | NaturalLanguage | NLP |
| V7AIParsing | PDFKit, Vision | PDF parsing, OCR |
| V7Embeddings | NaturalLanguage | Embeddings |
| V7Performance | MetricKit | System metrics |
| All | Foundation | Base functionality |

---

## Data Flow Patterns

### Job Discovery Flow

```
User Opens App
     │
     ▼
DeckScreen (V7UI)
     │
     ▼
DeckViewModel.loadJobs()
     │
     ▼
JobDiscoveryCoordinator (V7Services)
     │
     ├─ SmartCompanySelector (Thompson-based selection)
     │      │
     │      ▼
     │  ThompsonSamplingEngine (V7Thompson)
     │      │
     │      └─ Returns: Top 10 companies
     │
     ├─ Parallel Fetch (10 concurrent)
     │   ├─ GreenhouseAPIClient → API Request
     │   ├─ LeverAPIClient → API Request
     │   └─ RSSFeedJobSource → RSS Fetch
     │
     ▼
NetworkOptimizer (rate limiting)
     │
     ▼
JobDescriptionParser (V7JobParsing)
     │
     ├─ SkillExtractor
     ├─ SeniorityDetector
     └─ CompensationParser
     │
     ▼
SemanticMatcher (V7Embeddings)
     │
     └─ VectorEmbedder → Similarity score
     │
     ▼
ThompsonSamplingEngine (scoring)
     │
     └─ Returns: Ranked jobs
     │
     ▼
JobCache (V7Data) → Store for future
     │
     ▼
DeckScreen → Display to user
```

### User Swipe Flow

```
User Swipes Right/Left
     │
     ▼
DeckScreen.handleSwipe()
     │
     ├─ Right (Interested)
     │   │
     │   ├─ ApplicationTracker.markInterested()
     │   │
     │   └─ ThompsonSamplingEngine.updateArm(success: true)
     │       │
     │       └─ Increase α (success count)
     │
     └─ Left (Pass)
         │
         ├─ SwipeHistory.recordPass()
         │
         └─ ThompsonSamplingEngine.updateArm(success: false)
             │
             └─ Increase β (failure count)
     │
     ▼
PersistenceController.save()
     │
     └─ Core Data → Persist state
```

### Performance Monitoring Flow

```
Every 1 Second (Background Task)
     │
     ▼
ContinuousPerformanceMonitor
     │
     ├─ MemoryBudgetManager.checkBudget()
     │   │
     │   ├─ Thompson: 100MB limit
     │   ├─ Total: 200MB limit
     │   └─ If exceeded → emergencyCleanup()
     │
     ├─ FPSTracker.currentFPS()
     │   │
     │   └─ If <55 FPS → Alert developer
     │
     ├─ ProductionHealthMonitor.calculateHealth()
     │   │
     │   ├─ Error rate
     │   ├─ Latency percentiles
     │   └─ Crash frequency
     │
     └─ MetricsAggregator.aggregate()
         │
         └─ Store in Core Data
     │
     ▼
ProductionMonitoringView (V7UI)
     │
     └─ Real-time dashboard display
```

---

## Summary

This C4 Model documentation provides a complete architectural view of Manifest and Match V7:

- **Level 1 (Context):** Shows the app in its ecosystem with 28+ job sources, iOS infrastructure, and end users
- **Level 2 (Container):** Breaks down into 7 major containers (Presentation, AI/ML, Services, Parsing, Data, Performance, Core)
- **Level 3 (Component):** Details 12 packages with specific responsibilities and dependencies
- **Level 4 (Code):** Demonstrates Swift 6 patterns, naming conventions, and critical class implementations

**Key Architectural Principles:**
1. **Modularity:** 12-package structure with clear boundaries
2. **Performance:** Real-time monitoring, budgets, and optimization
3. **Concurrency:** Full Swift 6 compliance with @MainActor, Sendable, actors
4. **Transparency:** Explainable AI with Thompson Sampling explanations
5. **Accessibility:** WCAG 2.1 AAA compliance
6. **Reliability:** Circuit breakers, rate limiting, emergency recovery

**Production Targets:**
- 60 FPS UI
- <100ms Thompson scoring
- 100MB Thompson memory budget
- 200MB total app memory budget
- 99.9% uptime SLA
- <1% error rate

This architecture supports a production-ready iOS application with sophisticated AI/ML capabilities, robust performance monitoring, and enterprise-grade reliability.
