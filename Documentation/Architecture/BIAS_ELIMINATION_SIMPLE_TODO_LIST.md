# Bias Elimination Simple TODO List
*Ready-to-Execute Task List*

**Format**: Each task is one line that can be added to TodoWrite
**Total**: 89 tasks across 6 phases

---

## PHASE 1: IMMEDIATE CRITICAL FIXES (8 hours)

### P1.1 - Remove "Software Engineer" Default (30 min)
**Agent**: backend-ios-expert
**Task**: Remove "Software Engineer" fallback in JobDiscoveryCoordinator.swift line 769
**File**: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
**Todo**: Remove 'Software Engineer' default query from buildSearchQuery()

### P1.2 - Remove Thompson Tech Bias (1 hour)
**Agent**: ml-engineering-specialist
**Task**: Remove tech skills array from calculateBasicProfessionalScore()
**File**: Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift lines 391-401
**Todo**: Remove +10% tech keyword bonus from Thompson Sampling algorithm

### P1.3 - Neutral Thompson Priors (30 min)
**Agent**: algorithm-math-expert
**Task**: Change Beta parameters from 1.5/2.0 to 1.0 for neutral priors
**File**: Packages/V7Thompson/Sources/V7Thompson/V7Thompson.swift lines 342-349
**Todo**: Change Thompson Sampling to use Beta(1,1) neutral priors

### P1.4 - Replace iOS RSS Feeds (1 hour)
**Agent**: backend-ios-expert
**Task**: Replace iOS/Swift RSS feeds with diverse job feeds
**File**: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift lines 1948-1952
**Todo**: Replace iOS-specific RSS feeds with diverse sector feeds

### P1.5 - Remove Default Industries (30 min)
**Agent**: ios-app-architect
**Task**: Remove ["Technology", "Software"] from default profile
**File**: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift lines 94-106
**Todo**: Remove default tech industries from createDefaultUserProfile()

### P1.6 - Remove Core Data Defaults (45 min)
**Agent**: ios-app-architect
**Task**: Change currentDomain from "technology" to nil in Core Data
**File**: Packages/V7Data/Sources/V7Data/Entities/UserProfile+CoreData.swift lines 97-106
**Todo**: Remove 'technology' default domain from Core Data awakeFromInsert()

### P1.FINAL - Phase 1 Integration Test (2 hours)
**Agent**: testing-qa-strategist
**Task**: Validate all Phase 1 changes with comprehensive testing
**Todo**: Run Phase 1 integration tests and validate bias elimination

---

## PHASE 2: PROFILE COMPLETION GATE (6 hours)

### P2.1 - Add Profile Completion Check (2 hours)
**Agent**: ios-app-architect
**Task**: Add guard statement to block job loading without profile
**File**: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/ContentView.swift lines 887-949
**Todo**: Add profile completion gate before loadInitialJobs()

### P2.2 - Wire Onboarding to Coordinator (4 hours)
**Agent**: backend-ios-expert
**Task**: Update job coordinator when onboarding completes
**File**: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Onboarding/OnboardingFlow.swift lines 816-875
**Todo**: Call jobCoordinator.updateFromCoreProfile() after onboarding

### P2.FINAL - Phase 2 Integration Test (1 hour)
**Agent**: testing-qa-strategist
**Task**: Test profile gating and coordinator updates
**Todo**: Validate Phase 2 profile completion gate works correctly

---

## PHASE 3: EXTERNALIZE CONFIGURATION (40 hours)

### P3.1 - Configuration Architecture (4 hours)
**Agent**: backend-ios-expert
**Task**: Create ConfigurationProvider protocol and types
**File**: Packages/V7Services/Sources/V7Services/Configuration/ConfigurationProvider.swift (NEW)
**Todo**: Create configuration service architecture with protocols and types

### P3.2 - Create JSON Files (8 hours)
**Agent**: general-purpose
**Task**: Create skills.json, roles.json, companies.json, rss_feeds.json, benefits.json
**Files**: Packages/V7Services/Resources/*.json (NEW)
**Todo**: Create comprehensive JSON configuration files (500+ skills, 100+ roles, 100+ companies, 30+ feeds)

### P3.3 - Local Configuration Service (4 hours)
**Agent**: backend-ios-expert
**Task**: Implement LocalConfigurationService to load JSON files
**File**: Packages/V7Services/Sources/V7Services/Configuration/LocalConfigurationService.swift (NEW)
**Todo**: Implement LocalConfigurationService with JSON loading and caching

### P3.4 - Update SkillsDatabase (4 hours)
**Agent**: backend-ios-expert
**Task**: Replace 500+ hardcoded skills with dynamic configuration loading
**File**: Packages/V7JobParsing/Sources/V7JobParsing/Core/SkillsDatabase.swift (REPLACE ENTIRE FILE)
**Todo**: Replace hardcoded SkillsDatabase with dynamic configuration loading

### P3.5.1 - Update GreenhouseAPIClient (4 hours)
**Agent**: backend-ios-expert
**Task**: Replace hardcoded companies and skills in Greenhouse client
**File**: Packages/V7Services/Sources/V7Services/CompanyAPIs/GreenhouseAPIClient.swift
**Todo**: Update GreenhouseAPIClient to use configuration service

### P3.5.2 - Update LeverAPIClient (4 hours)
**Agent**: backend-ios-expert
**Task**: Replace hardcoded companies and skills in Lever client
**File**: Packages/V7Services/Sources/V7Services/CompanyAPIs/LeverAPIClient.swift
**Todo**: Update LeverAPIClient to use configuration service

### P3.5.3 - Update RSS Parsing (4 hours)
**Agent**: backend-ios-expert
**Task**: Load RSS feeds from configuration, remove tech filtering
**File**: Packages/V7Services/Sources/V7Services/JobDiscoveryCoordinator.swift
**Todo**: Update RSS feed loading to use configuration service

### P3.5.4 - Update Other Job Sources (4 hours)
**Agent**: backend-ios-expert
**Task**: Update remaining job sources to use configuration
**Files**: Various job source files
**Todo**: Update all remaining job sources to use configuration

### P3.FINAL - Phase 3 Integration Test (4 hours)
**Agent**: testing-qa-strategist
**Task**: Validate configuration system and data diversity
**Todo**: Test configuration loading and verify 20+ sectors represented

---

## PHASE 4: EXPAND JOB SOURCES (40 hours)

### P4.1 - Integrate Adzuna API (8 hours)
**Agent**: backend-ios-expert
**Task**: Create Adzuna API client for all sectors
**File**: Packages/V7Services/Sources/V7Services/JobAPIs/AdzunaAPIClient.swift (NEW)
**Todo**: Implement Adzuna API integration (25 req/min, all sectors)

### P4.2 - Integrate Jobicy API (8 hours)
**Agent**: backend-ios-expert
**Task**: Create Jobicy API client for all categories
**File**: Packages/V7Services/Sources/V7Services/JobAPIs/JobicyAPIClient.swift (NEW)
**Todo**: Implement Jobicy API integration (public API, all sectors)

### P4.3 - Integrate USAJobs API (8 hours)
**Agent**: backend-ios-expert
**Task**: Create USAJobs API client for government positions
**File**: Packages/V7Services/Sources/V7Services/JobAPIs/USAJobsAPIClient.swift (NEW)
**Todo**: Implement USAJobs API integration (government jobs)

### P4.4 - Add Sector RSS Feeds (8 hours)
**Agent**: general-purpose
**Task**: Research and add 20+ RSS feeds across all sectors
**File**: Packages/V7Services/Resources/rss_feeds.json
**Todo**: Add healthcare, finance, education, legal RSS feeds to configuration

### P4.5 - Smart Source Rotation (8 hours)
**Agent**: ml-engineering-specialist
**Task**: Implement source selector to enforce sector diversity
**File**: Packages/V7Services/Sources/V7Services/JobDiscovery/SmartSourceSelector.swift (NEW)
**Todo**: Create SmartSourceSelector to enforce 30% max per sector

### P4.FINAL - Phase 4 Integration Test (8 hours)
**Agent**: testing-qa-strategist
**Task**: Test all new APIs and sector distribution
**Todo**: Validate 30+ job sources and sector diversity achieved

---

## PHASE 5: BIAS DETECTION & MONITORING (24 hours)

### P5.1 - Bias Detection Service (8 hours)
**Agent**: ml-engineering-specialist
**Task**: Create service to detect and score bias in job feed
**File**: Packages/V7Performance/Sources/V7Performance/BiasDetection/BiasDetectionService.swift (NEW)
**Todo**: Implement BiasDetectionService with statistical analysis

### P5.2 - Monitoring Dashboard (8 hours)
**Agent**: xcode-ux-designer
**Task**: Create SwiftUI dashboard to display bias metrics
**File**: Packages/V7UI/Sources/V7UI/Analytics/BiasMonitoringView.swift (NEW)
**Todo**: Create bias monitoring dashboard UI with real-time updates

### P5.3 - Automated Bias Tests (8 hours)
**Agent**: testing-qa-strategist
**Task**: Create comprehensive test suite for bias detection
**File**: Tests/V7PerformanceTests/BiasDetectionTests.swift (NEW)
**Todo**: Create automated tests for bias detection and scoring

### P5.FINAL - Phase 5 Integration Test (4 hours)
**Agent**: testing-qa-strategist
**Task**: Validate bias detection system end-to-end
**Todo**: Test bias detection service and dashboard functionality

---

## PHASE 6: VALIDATION & TESTING (40 hours)

### P6.1 - Integration Test Suite (16 hours)
**Agent**: testing-qa-strategist
**Task**: Create full integration tests for bias elimination
**File**: Tests/IntegrationTests/BiasEliminationIntegrationTests.swift (NEW)
**Todo**: Create comprehensive integration test suite for all profile types

### P6.2 - Manual Testing Campaign (16 hours)
**Agent**: testing-qa-strategist
**Task**: Execute manual testing across all scenarios
**Todo**: Execute manual test plan for nurse, accountant, developer, teacher, sales profiles

### P6.3 - Performance Validation (8 hours)
**Agent**: performance-engineer
**Task**: Validate all performance budgets maintained
**Todo**: Run performance tests and verify Thompson <10ms, memory <200MB

### P6.FINAL - Project Sign-Off (4 hours)
**Agent**: testing-qa-strategist
**Task**: Final validation and project completion
**Todo**: Verify all objectives met, create final report, sign off project

---

## QUICK REFERENCE: Copy-Paste TODO Items

```
PHASE 1 (Priority: P0 - CRITICAL, 8 hours):
1. Remove 'Software Engineer' default query from buildSearchQuery() [backend-ios-expert, 30min]
2. Remove +10% tech keyword bonus from Thompson Sampling algorithm [ml-engineering-specialist, 1h]
3. Change Thompson Sampling to use Beta(1,1) neutral priors [algorithm-math-expert, 30min]
4. Replace iOS-specific RSS feeds with diverse sector feeds [backend-ios-expert, 1h]
5. Remove default tech industries from createDefaultUserProfile() [ios-app-architect, 30min]
6. Remove 'technology' default domain from Core Data awakeFromInsert() [ios-app-architect, 45min]
7. Run Phase 1 integration tests and validate bias elimination [testing-qa-strategist, 2h]

PHASE 2 (Priority: P1 - HIGH, 6 hours):
8. Add profile completion gate before loadInitialJobs() [ios-app-architect, 2h]
9. Call jobCoordinator.updateFromCoreProfile() after onboarding [backend-ios-expert, 4h]
10. Validate Phase 2 profile completion gate works correctly [testing-qa-strategist, 1h]

PHASE 3 (Priority: P1 - HIGH, 40 hours):
11. Create configuration service architecture with protocols and types [backend-ios-expert, 4h]
12. Create comprehensive JSON configuration files (500+ skills, 100+ roles, 100+ companies, 30+ feeds) [general-purpose, 8h]
13. Implement LocalConfigurationService with JSON loading and caching [backend-ios-expert, 4h]
14. Replace hardcoded SkillsDatabase with dynamic configuration loading [backend-ios-expert, 4h]
15. Update GreenhouseAPIClient to use configuration service [backend-ios-expert, 4h]
16. Update LeverAPIClient to use configuration service [backend-ios-expert, 4h]
17. Update RSS feed loading to use configuration service [backend-ios-expert, 4h]
18. Update all remaining job sources to use configuration [backend-ios-expert, 4h]
19. Test configuration loading and verify 20+ sectors represented [testing-qa-strategist, 4h]

PHASE 4 (Priority: P2 - MEDIUM, 40 hours):
20. Implement Adzuna API integration (25 req/min, all sectors) [backend-ios-expert, 8h]
21. Implement Jobicy API integration (public API, all sectors) [backend-ios-expert, 8h]
22. Implement USAJobs API integration (government jobs) [backend-ios-expert, 8h]
23. Add healthcare, finance, education, legal RSS feeds to configuration [general-purpose, 8h]
24. Create SmartSourceSelector to enforce 30% max per sector [ml-engineering-specialist, 8h]
25. Validate 30+ job sources and sector diversity achieved [testing-qa-strategist, 8h]

PHASE 5 (Priority: P1 - HIGH, 24 hours):
26. Implement BiasDetectionService with statistical analysis [ml-engineering-specialist, 8h]
27. Create bias monitoring dashboard UI with real-time updates [xcode-ux-designer, 8h]
28. Create automated tests for bias detection and scoring [testing-qa-strategist, 8h]
29. Test bias detection service and dashboard functionality [testing-qa-strategist, 4h]

PHASE 6 (Priority: P0 - CRITICAL, 40 hours):
30. Create comprehensive integration test suite for all profile types [testing-qa-strategist, 16h]
31. Execute manual test plan for nurse, accountant, developer, teacher, sales profiles [testing-qa-strategist, 16h]
32. Run performance tests and verify Thompson <10ms, memory <200MB [performance-engineer, 8h]
33. Verify all objectives met, create final report, sign off project [testing-qa-strategist, 4h]
```

---

## FOR TodoWrite TOOL

### Immediate Phase 1 Tasks (can be added to TodoWrite now):

```json
[
  {
    "content": "Remove 'Software Engineer' default query from buildSearchQuery()",
    "activeForm": "Removing 'Software Engineer' default query",
    "status": "pending"
  },
  {
    "content": "Remove +10% tech keyword bonus from Thompson Sampling",
    "activeForm": "Removing tech keyword bonus from Thompson Sampling",
    "status": "pending"
  },
  {
    "content": "Change Thompson Sampling to use Beta(1,1) neutral priors",
    "activeForm": "Changing Thompson to neutral Beta(1,1) priors",
    "status": "pending"
  },
  {
    "content": "Replace iOS-specific RSS feeds with diverse sector feeds",
    "activeForm": "Replacing iOS RSS feeds with diverse feeds",
    "status": "pending"
  },
  {
    "content": "Remove default tech industries from user profile",
    "activeForm": "Removing default tech industries",
    "status": "pending"
  },
  {
    "content": "Remove 'technology' default from Core Data",
    "activeForm": "Removing Core Data technology default",
    "status": "pending"
  },
  {
    "content": "Run Phase 1 integration tests",
    "activeForm": "Running Phase 1 integration tests",
    "status": "pending"
  }
]
```

---

**Total Tasks**: 33 major tasks (89 sub-tasks)
**Format**: Ready for TodoWrite tool or task management systems
**Structure**: One clear action per line with agent, file, duration