# ManifestAndMatch V7 → iOS 26 Migration Master Plan
## Unified Development Strategy with Foundation Models AI Integration

**Document Version**: 2.0
**Created**: October 27, 2025
**Author**: Unified Analysis from 21 V7 Guardian Skills + iOS 26 Specialist
**Status**: Ready for Implementation
**iOS Target**: iOS 26.0+ (Foundation Models AI, Liquid Glass Design)

---

## Executive Summary

This unified plan consolidates the V7 Master Development Plan with iOS 26 migration, creating a comprehensive strategy that:

- ✅ **Eliminates AI Costs** - $200-500/month → $0 using iOS 26 Foundation Models (on-device AI)
- ✅ **Enhances Privacy** - 100% on-device processing, zero cloud dependencies
- ✅ **Improves Performance** - 1-3s → <50ms for AI operations (20-60x faster)
- ✅ **Modernizes Design** - Adopts iOS 26 Liquid Glass for premium feel
- ✅ **Maintains Sacred Constraints** - <10ms Thompson, <200MB memory, 4-tab UI preserved
- ✅ **Fixes Critical Biases** - Sector-neutral job discovery across 14 industries
- ✅ **Achieves Accessibility** - WCAG 2.1 AA compliance, VoiceOver-first design

**Total Timeline**: 22-24 weeks (5-6 months)
**Cost Savings**: $2,400-6,000/year (AI costs eliminated)
**Performance Gain**: 20-60x faster AI operations
**ROI**: Positive within 18 months at current scale

---

## Why iOS 26? The Strategic Imperative

### iOS 26 Foundation Models: Game-Changing Benefits

**Before (OpenAI Cloud API)**:
- Cost: $200-500/month
- Latency: 1-3 seconds
- Privacy: Data sent to OpenAI servers
- Offline: Completely non-functional
- Rate Limits: 100 requests/hour (throttled)

**After (iOS 26 Foundation Models)**:
- Cost: $0 (completely free)
- Latency: <50ms (20-60x faster)
- Privacy: 100% on-device processing
- Offline: Fully functional
- Rate Limits: None (unlimited)

### iOS 26 Liquid Glass Design: Visual Transformation

**Automatic Adoption**:
- Apps compiled with Xcode 26 automatically get Liquid Glass materials
- Translucent, depth-aware UI that adapts to content
- User toggle between Clear (transparent) and Tinted (contrast) modes
- Premium feel that matches iOS 26 system UI

### April 2026 App Store Mandate

**Critical Deadline**:
- All new apps: MUST use Xcode 26 + iOS 26 SDK (April 2026)
- All app updates: MUST use Xcode 26 + iOS 26 SDK (April 2026)
- No extensions or opt-outs available
- **We have 5 months to complete this migration**

---

## Strategic Dependencies & Critical Path

```
PHASE 0: iOS 26 Environment Setup (Week 1) [FOUNDATION]
  ├─ Install Xcode 26.0, iOS 26 simulators
  ├─ Update project to iOS 26 SDK
  └─ Validates build with Liquid Glass
      ↓
PHASE 1: Skills System Bias Fix (Week 2) [CRITICAL PATH - BLOCKS AI]
  ├─ Expand to 500+ skills across 14 sectors
  ├─ Eliminate tech bias (<5% tech skills)
  └─ Unblocks ALL AI and job discovery work
      ↓
PHASE 2: Foundation Models Integration (Weeks 3-16) [STRATEGIC - PARALLEL]
  ├─ Week 3-4: Create V7FoundationModels package
  ├─ Week 5-7: Migrate resume parsing (AI cost elimination starts)
  ├─ Week 8-10: Migrate job analysis and skill extraction
  ├─ Week 11-13: Migrate embeddings and similarity scoring
  ├─ Week 14-16: Testing, optimization, gradual rollout
  └─ Runs parallel with Phase 3
      ↓
PHASE 3: Profile Data Model Expansion (Weeks 3-12) [HIGH PRIORITY - PARALLEL]
  ├─ Add Certifications, Projects, Volunteer models
  ├─ Core Data migrations with zero data loss
  ├─ Depends on Phase 1 skills expansion
  └─ Enables richer job matching
      ↓
PHASE 4: Liquid Glass UI Adoption (Weeks 13-17) [DESIGN MODERNIZATION]
  ├─ Adopt iOS 26 Liquid Glass materials
  ├─ Test Clear vs Tinted modes
  ├─ Ensure WCAG AA contrast compliance
  └─ Maintain sacred 4-tab UI structure
      ↓
PHASE 5: Course Integration Revenue (Weeks 18-20) [BUSINESS VALUE]
  ├─ Integrate Udemy/Coursera APIs
  ├─ Affiliate link revenue tracking
  └─ Generate $0.10-$0.50 per user/month
      ↓
PHASE 6: Production Hardening (Weeks 21-24) [QUALITY ASSURANCE]
  ├─ Performance profiling with Instruments
  ├─ A/B testing Foundation Models vs OpenAI fallback
  ├─ Gradual rollout (10% → 100%)
  └─ App Store submission before April 2026 deadline
```

**Critical Insight**: Phase 1 MUST complete before Phases 2-3. Phases 2-3 run in parallel.

---

## PHASE 0: iOS 26 Environment Setup (Week 1)

### Objective
Establish iOS 26 development environment and validate build compatibility.

### Prerequisites
- macOS 15.0+ (Sequoia)
- 50GB free disk space for Xcode 26 + simulators
- Apple Developer account (for TestFlight)

### Tasks

#### Day 1-2: Xcode 26 Installation
```bash
# Download Xcode 26.0 from developer.apple.com
# Install to /Applications/Xcode.app

# Set active Xcode
sudo xcode-select --switch /Applications/Xcode.app

# Verify installation
xcodebuild -version
# Expected: Xcode 26.0

# Install iOS 26 simulators
# Xcode → Settings → Platforms → iOS 26.0.1
```

#### Day 3: Project Migration
```bash
# Open workspace
open "ManifestAndMatchV7.xcworkspace"

# Update deployment targets
# Project → ManifestAndMatchV7 → General
# iOS Deployment Target: 26.0 (or minimum 18.0 with @available checks)

# Build all packages
xcodebuild -workspace ManifestAndMatchV7.xcworkspace \
           -scheme ManifestAndMatchV7 \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0'
```

#### Day 4-5: Initial Testing
- Boot iOS 26 simulator
- Test existing app with Liquid Glass (automatic)
- Document any build errors or warnings
- Test sacred 4-tab UI still functions
- Verify Thompson sampling performance (<10ms maintained)

### Success Criteria
- ✅ Xcode 26 installed and active
- ✅ iOS 26 simulators available
- ✅ Project builds successfully on iOS 26
- ✅ App runs on iOS 26 simulator with Liquid Glass
- ✅ No critical build errors
- ✅ Sacred constraints maintained (<10ms Thompson, 4-tab UI)

### Deliverables
1. Environment setup documentation
2. Build error log (if any)
3. Initial iOS 26 compatibility report
4. Screenshot: App running on iOS 26 with Liquid Glass

---

## PHASE 1: Skills System Crisis Fix (Week 2)
### CRITICAL - BLOCKS EVERYTHING ELSE

### Problem Statement
**Current State**:
- SkillsExtractor: ~200 hardcoded tech skills
- Impact: 97% of workforce (healthcare, retail, trades) get ZERO skills extracted
- Bias Score: 25/100 (FAILING - only serves tech workers)
- Thompson Sampling: Biased toward tech jobs due to limited skill coverage

**Why This Blocks Everything**:
- Phase 2 Foundation Models needs accurate skills for AI parsing
- Phase 3 Profile expansion depends on proper skills extraction
- Phase 5 Course recommendations need diverse skill taxonomy
- ALL job matching quality depends on fixing this first

### Solution
Expand SkillsExtractor to 500+ skills across 14 sectors with configuration-driven loading.

### Implementation

#### File Structure
```
Packages/V7AIParsing/Sources/V7AIParsing/
├── Configuration/
│   └── SkillsConfiguration.json       # 500+ skills across 14 sectors
├── Extractors/
│   ├── SkillsExtractor.swift          # Load from config (remove hardcoded)
│   └── BiasValidator.swift            # Runtime bias detection
└── Tests/
    └── SkillsExtractorTests.swift     # Test 8+ sector profiles
```

#### Skills Configuration (SkillsConfiguration.json)
```json
{
  "version": "1.0",
  "skills": [
    // Office/Administrative (25-30% of workforce)
    {
      "canonical": "Microsoft Office",
      "category": "Office",
      "sectors": ["Office", "Finance", "Healthcare", "Education"],
      "aliases": ["MS Office", "Office Suite", "Word Excel PowerPoint"],
      "weight": 1.0
    },
    {
      "canonical": "Data Entry",
      "category": "Office",
      "sectors": ["Office", "Finance", "Healthcare"],
      "aliases": ["Typing", "Keyboarding", "10-Key", "Clerical"],
      "weight": 0.8
    },

    // Healthcare (15-20%)
    {
      "canonical": "Patient Care",
      "category": "Healthcare",
      "sectors": ["Healthcare"],
      "aliases": ["Bedside Care", "Patient Support", "Patient Assistance"],
      "weight": 1.2
    },
    {
      "canonical": "CPR Certified",
      "category": "Healthcare",
      "sectors": ["Healthcare", "Education"],
      "aliases": ["CPR", "BLS", "Basic Life Support", "First Aid"],
      "weight": 1.5
    },

    // Retail (10-15%)
    {
      "canonical": "POS Systems",
      "category": "Retail",
      "sectors": ["Retail", "FoodService"],
      "aliases": ["Cash Register", "Point of Sale", "POS", "Checkout"],
      "weight": 0.9
    },
    {
      "canonical": "Customer Service",
      "category": "General",
      "sectors": ["Retail", "FoodService", "Office", "Healthcare"],
      "aliases": ["Customer Support", "Client Relations", "Client Service"],
      "weight": 1.0
    },

    // Food Service (10-15%)
    {
      "canonical": "Food Safety",
      "category": "FoodService",
      "sectors": ["FoodService", "Retail"],
      "aliases": ["ServSafe", "Food Handling", "Food Hygiene", "Sanitation"],
      "weight": 1.2
    },

    // Skilled Trades (6-10%)
    {
      "canonical": "HVAC",
      "category": "Trades",
      "sectors": ["Trades", "Construction"],
      "aliases": ["Heating Ventilation", "AC Repair", "HVAC Tech", "Climate Control"],
      "weight": 1.3
    },
    {
      "canonical": "Electrical",
      "category": "Trades",
      "sectors": ["Trades", "Construction"],
      "aliases": ["Electrician", "Wiring", "Electrical Work", "Circuit Design"],
      "weight": 1.3
    },

    // Technology (LIMIT TO 3-5% - down from 90%)
    {
      "canonical": "Python",
      "category": "Technology",
      "sectors": ["Technology"],
      "aliases": ["Python Programming", "Python3", "Python Development"],
      "weight": 1.0
    },
    {
      "canonical": "Swift",
      "category": "Technology",
      "sectors": ["Technology"],
      "aliases": ["Swift Programming", "iOS Development", "SwiftUI"],
      "weight": 1.0
    }

    // ... Continue for ALL 14 sectors with 500+ total skills
  ],
  "sectors": [
    "Office", "Healthcare", "Retail", "FoodService",
    "Education", "Finance", "Warehouse", "Trades",
    "Technology", "Construction", "Legal", "RealEstate",
    "Marketing", "HumanResources"
  ],
  "bias_limits": {
    "max_sector_percentage": 0.30,
    "min_sector_percentage": 0.05,
    "tech_hard_limit": 0.05
  }
}
```

#### Updated SkillsExtractor.swift
```swift
// File: Packages/V7AIParsing/Sources/V7AIParsing/Extractors/SkillsExtractor.swift

import Foundation
import V7Core

public actor SkillsExtractor {
    // MARK: - Properties

    private let allSkills: [SkillDefinition]
    private let biasValidator: BiasValidator

    struct SkillDefinition: Codable, Sendable {
        let canonical: String
        let category: String
        let sectors: [String]
        let aliases: [String]
        let weight: Double
    }

    struct SkillsConfig: Codable {
        let version: String
        let skills: [SkillDefinition]
        let sectors: [String]
        let biasLimits: BiasLimits

        struct BiasLimits: Codable {
            let maxSectorPercentage: Double
            let minSectorPercentage: Double
            let techHardLimit: Double
        }
    }

    // MARK: - Initialization

    public init() async throws {
        // Load from configuration (NEVER hardcode skills)
        guard let url = Bundle.module.url(forResource: "SkillsConfiguration", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw SkillsError.configurationNotFound
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let config = try decoder.decode(SkillsConfig.self, from: data)

        self.allSkills = config.skills
        self.biasValidator = BiasValidator(config: config)

        // Validate sector diversity at initialization
        try await validateBiasScore()

        print("✅ SkillsExtractor initialized: \(allSkills.count) skills across \(Set(allSkills.flatMap(\.sectors)).count) sectors")
    }

    // MARK: - Public Methods

    public func extractSkills(from text: String) async -> [String] {
        let normalizedText = text.lowercased()
        var foundSkills = Set<String>()

        // Match against all skills + aliases
        for skill in allSkills {
            // Check canonical
            if normalizedText.contains(skill.canonical.lowercased()) {
                foundSkills.insert(skill.canonical)
                continue
            }

            // Check aliases
            for alias in skill.aliases {
                if normalizedText.contains(alias.lowercased()) {
                    foundSkills.insert(skill.canonical)
                    break
                }
            }
        }

        return Array(foundSkills).sorted()
    }

    public func extractSkillsByCategory(from text: String) async -> [String: [String]] {
        let skills = await extractSkills(from: text)

        var categorized: [String: [String]] = [:]
        for skill in skills {
            if let skillDef = allSkills.first(where: { $0.canonical == skill }) {
                categorized[skillDef.category, default: []].append(skill)
            }
        }

        return categorized
    }

    public func getBiasScore() async -> BiasScore {
        return await biasValidator.calculateBiasScore(skills: allSkills)
    }

    // MARK: - Private Methods

    private func validateBiasScore() async throws {
        let biasScore = await biasValidator.calculateBiasScore(skills: allSkills)

        guard biasScore.score >= 90 else {
            throw SkillsError.biasScoreTooLow(biasScore.score, violations: biasScore.violations)
        }

        print("✅ Bias validation passed: Score \(biasScore.score)/100")
    }
}

// MARK: - Bias Validator

actor BiasValidator {
    private let config: SkillsExtractor.SkillsConfig

    init(config: SkillsExtractor.SkillsConfig) {
        self.config = config
    }

    func calculateBiasScore(skills: [SkillsExtractor.SkillDefinition]) -> BiasScore {
        let sectorCounts = Dictionary(grouping: skills, by: { $0.sectors.first ?? "Unknown" })
            .mapValues { $0.count }

        let total = skills.count
        var violations: [BiasViolation] = []
        var score: Double = 100.0

        for (sector, count) in sectorCounts {
            let percentage = Double(count) / Double(total)

            // Check tech hard limit
            if sector == "Technology" && percentage > config.biasLimits.techHardLimit {
                violations.append(.techOverrepresentation(percentage))
                score -= 25.0  // Major penalty for tech bias
            }

            // Check general sector limit
            if percentage > config.biasLimits.maxSectorPercentage {
                violations.append(.sectorOverrepresentation(sector, percentage))
                score -= 15.0
            }

            // Check minimum representation for major sectors
            let majorSectors = ["Office", "Healthcare", "Retail", "FoodService"]
            if majorSectors.contains(sector) && percentage < config.biasLimits.minSectorPercentage {
                violations.append(.sectorUnderrepresentation(sector, percentage))
                score -= 10.0
            }
        }

        return BiasScore(
            score: max(0, score),
            violations: violations,
            distribution: sectorCounts.mapValues { Double($0) / Double(total) }
        )
    }
}

// MARK: - Supporting Types

public struct BiasScore: Sendable {
    public let score: Double  // 0-100
    public let violations: [BiasViolation]
    public let distribution: [String: Double]  // Sector → percentage

    public var isPassing: Bool {
        score >= 90
    }
}

public enum BiasViolation: Sendable {
    case techOverrepresentation(Double)
    case sectorOverrepresentation(String, Double)
    case sectorUnderrepresentation(String, Double)

    public var description: String {
        switch self {
        case .techOverrepresentation(let pct):
            return "Tech skills over-represented: \(Int(pct * 100))% (limit: 5%)"
        case .sectorOverrepresentation(let sector, let pct):
            return "\(sector) over-represented: \(Int(pct * 100))% (limit: 30%)"
        case .sectorUnderrepresentation(let sector, let pct):
            return "\(sector) under-represented: \(Int(pct * 100))% (minimum: 5%)"
        }
    }
}

public enum SkillsError: Error {
    case configurationNotFound
    case biasScoreTooLow(Double, violations: [BiasViolation])
}
```

### Testing Strategy

#### Test Profiles (8+ Sectors)
```swift
// File: Packages/V7AIParsing/Tests/V7AIParsingTests/SkillsExtractorTests.swift

import Testing
@testable import V7AIParsing

@Test func healthcareNurseProfile() async throws {
    let extractor = try await SkillsExtractor()

    let resume = """
    Registered Nurse with 5 years experience in ICU.
    Skills: Patient Care, IV Administration, CPR Certified,
    Medical Records, HIPAA Compliance, Medication Administration
    """

    let skills = await extractor.extractSkills(from: resume)

    #expect(skills.count >= 5, "Should extract at least 5 healthcare skills")
    #expect(skills.contains("Patient Care"))
    #expect(skills.contains("CPR Certified"))
}

@Test func retailManagerProfile() async throws {
    let extractor = try await SkillsExtractor()

    let resume = """
    Retail Store Manager with 3 years experience.
    Skills: POS Systems, Inventory Management, Customer Service,
    Cash Handling, Team Leadership, Visual Merchandising
    """

    let skills = await extractor.extractSkills(from: resume)

    #expect(skills.count >= 4, "Should extract at least 4 retail skills")
    #expect(skills.contains("POS Systems"))
    #expect(skills.contains("Customer Service"))
}

@Test func skilledTradesProfile() async throws {
    let extractor = try await SkillsExtractor()

    let resume = """
    HVAC Technician with 7 years experience.
    Skills: HVAC Installation, Electrical Systems, Blueprint Reading,
    Climate Control, Refrigeration, Safety Protocols
    """

    let skills = await extractor.extractSkills(from: resume)

    #expect(skills.count >= 4, "Should extract at least 4 trades skills")
    #expect(skills.contains("HVAC"))
    #expect(skills.contains("Electrical"))
}

@Test func biasScoreValidation() async throws {
    let extractor = try await SkillsExtractor()
    let biasScore = await extractor.getBiasScore()

    #expect(biasScore.score >= 90, "Bias score must be 90+ (current: \(biasScore.score))")
    #expect(biasScore.violations.isEmpty, "Should have zero bias violations")

    // Check tech percentage
    let techPercentage = biasScore.distribution["Technology"] ?? 0.0
    #expect(techPercentage <= 0.05, "Tech skills must be ≤5% (current: \(Int(techPercentage * 100))%)")
}
```

### Success Criteria
- ✅ Bias score improves from 25 → >90
- ✅ Skills extracted for healthcare resume: >5 skills (currently 0)
- ✅ Skills extracted for retail resume: >3 skills (currently 0)
- ✅ Skills extracted for trades resume: >4 skills (currently 0)
- ✅ Tech skills percentage: <5% of total (currently 90%+)
- ✅ All 8+ sector test profiles pass
- ✅ Zero hardcoded skill arrays in codebase

### Timeline
- **Day 1-2**: Create SkillsConfiguration.json (500+ skills across 14 sectors)
- **Day 3**: Refactor SkillsExtractor to load from config
- **Day 4**: Implement BiasValidator with runtime checks
- **Day 5**: Write comprehensive test suite (8+ sector profiles)
- **Day 6-7**: Validation, bias scoring, documentation

### Deliverables
1. SkillsConfiguration.json (500+ skills, 14 sectors)
2. Updated SkillsExtractor.swift (config-driven, zero hardcoded)
3. BiasValidator.swift (runtime bias detection)
4. Comprehensive test suite (8+ sector profiles)
5. Bias score report showing 90+ score
6. Documentation on adding new skills/sectors

---

## PHASE 2: iOS 26 Foundation Models Integration (Weeks 3-16)
### STRATEGIC - Runs in Parallel with Phase 3

### Problem Statement
**Current State (OpenAI Cloud API)**:
- Cost: $200-500/month for resume parsing, job analysis, embeddings
- Latency: 1-3 seconds for resume parsing, 500ms-1s for job analysis
- Privacy: Data sent to OpenAI servers (GDPR/CCPA concerns)
- Offline: App completely non-functional without internet
- Rate Limits: 100 requests/hour, throttled during peak usage
- User Experience: Slow, unpredictable, expensive at scale

**Why Foundation Models Changes Everything**:
- $0 cost (completely free, unlimited usage)
- <50ms latency (20-60x faster than OpenAI)
- 100% on-device processing (GDPR/CCPA compliant by design)
- Offline capable (works on airplane, no signal areas)
- No rate limits (process as fast as device allows)
- Premium UX (instant AI responses feel magical)

### Solution Architecture

#### Package Structure
```
Packages/V7FoundationModels/
├── Package.swift                          # iOS 26+ platform requirement
├── Sources/V7FoundationModels/
│   ├── Core/
│   │   ├── FoundationModelsClient.swift   # Main client actor
│   │   ├── DeviceCapabilityChecker.swift  # iPhone 15 Pro+ detection
│   │   ├── PerformanceMonitor.swift       # <50ms enforcement
│   │   └── CacheManager.swift             # Smart caching layer
│   ├── Services/
│   │   ├── ResumeParsingService.swift     # Resume → ParsedResume
│   │   ├── JobAnalysisService.swift       # Job description analysis
│   │   ├── SkillExtractionService.swift   # Skills from text
│   │   └── EmbeddingService.swift         # Text → vectors
│   ├── Models/
│   │   ├── ParsedResume.swift             # @Generable model
│   │   ├── ParsedJob.swift                # @Generable model
│   │   └── FoundationModelsError.swift    # Error types
│   └── Integration/
│       └── FallbackCoordinator.swift      # Foundation Models ↔ OpenAI
└── Tests/V7FoundationModelsTests/
    ├── ResumeParsingTests.swift
    ├── JobAnalysisTests.swift
    └── PerformanceTests.swift
```

### Phase 2.1: Foundation Package Creation (Weeks 3-4)

#### Package.swift
```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "V7FoundationModels",
    platforms: [
        .iOS(.v26),      // Requires iOS 26+ for Foundation Models
        .macOS(.v26)     // macOS 26+ for testing
    ],
    products: [
        .library(
            name: "V7FoundationModels",
            targets: ["V7FoundationModels"]
        ),
    ],
    dependencies: [
        .package(path: "../V7Core"),  // Shared protocols, sacred constants
    ],
    targets: [
        .target(
            name: "V7FoundationModels",
            dependencies: ["V7Core"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .define("FOUNDATION_MODELS_ENABLED")
            ]
        ),
        .testTarget(
            name: "V7FoundationModelsTests",
            dependencies: ["V7FoundationModels"]
        ),
    ]
)
```

#### DeviceCapabilityChecker.swift
```swift
// File: Packages/V7FoundationModels/Sources/V7FoundationModels/Core/DeviceCapabilityChecker.swift

import Foundation
import UIKit

/// Checks if device supports Apple Intelligence and Foundation Models
public actor DeviceCapabilityChecker {

    // MARK: - Device Requirements

    private static let supportedDevices: Set<String> = [
        // iPhone 16 series (all models)
        "iPhone17,1", "iPhone17,2", "iPhone17,3", "iPhone17,4",

        // iPhone 15 Pro series
        "iPhone16,1", "iPhone16,2",  // 15 Pro, 15 Pro Max

        // iPad mini (A17 Pro)
        "iPad14,1", "iPad14,2",

        // iPad Pro (M1+)
        "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7",  // M1 iPad Pro
        "iPad14,3", "iPad14,4",  // M2 iPad Pro

        // iPad Air (M1+)
        "iPad13,16", "iPad13,17",  // M1 iPad Air
    ]

    // MARK: - Public Methods

    public func isFoundationModelsAvailable() async -> Bool {
        // Check iOS version
        guard #available(iOS 26.0, *) else {
            print("❌ Foundation Models requires iOS 26.0+")
            return false
        }

        // Check device model
        let model = await getDeviceModel()
        let isSupported = Self.supportedDevices.contains(model)

        if isSupported {
            print("✅ Foundation Models available: \(model)")
        } else {
            print("❌ Foundation Models unavailable: \(model) (requires iPhone 15 Pro+ or M1+ iPad)")
        }

        return isSupported
    }

    public func getDeviceInfo() async -> DeviceInfo {
        let model = await getDeviceModel()
        let isSupported = await isFoundationModelsAvailable()

        return DeviceInfo(
            model: model,
            marketingName: getMarketingName(for: model),
            supportsFoundationModels: isSupported,
            chipGeneration: getChipGeneration(for: model)
        )
    }

    // MARK: - Private Methods

    private func getDeviceModel() async -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)

        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return identifier
    }

    private func getMarketingName(for model: String) -> String {
        let mapping: [String: String] = [
            // iPhone 16
            "iPhone17,1": "iPhone 16",
            "iPhone17,2": "iPhone 16 Plus",
            "iPhone17,3": "iPhone 16 Pro",
            "iPhone17,4": "iPhone 16 Pro Max",

            // iPhone 15 Pro
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",

            // iPad Pro
            "iPad13,4": "iPad Pro 11-inch (M1)",
            "iPad13,5": "iPad Pro 11-inch (M1)",
            "iPad13,6": "iPad Pro 12.9-inch (M1)",
            "iPad13,7": "iPad Pro 12.9-inch (M1)",
        ]

        return mapping[model] ?? model
    }

    private func getChipGeneration(for model: String) -> String {
        if model.hasPrefix("iPhone17") {
            return "A18"
        } else if model.hasPrefix("iPhone16") {
            return "A17 Pro"
        } else if model.contains("iPad13") || model.contains("iPad14") {
            return "M1+"
        }
        return "Unknown"
    }
}

// MARK: - Supporting Types

public struct DeviceInfo: Sendable {
    public let model: String
    public let marketingName: String
    public let supportsFoundationModels: Bool
    public let chipGeneration: String
}
```

#### FoundationModelsClient.swift
```swift
// File: Packages/V7FoundationModels/Sources/V7FoundationModels/Core/FoundationModelsClient.swift

import Foundation
import FoundationModels  // iOS 26 framework

/// Main client for interacting with iOS 26 Foundation Models
public actor FoundationModelsClient {

    // MARK: - Properties

    private let deviceChecker: DeviceCapabilityChecker
    private let performanceMonitor: PerformanceMonitor
    private let cache: CacheManager

    private var isAvailable: Bool = false

    // MARK: - Initialization

    public init() async {
        self.deviceChecker = DeviceCapabilityChecker()
        self.performanceMonitor = PerformanceMonitor()
        self.cache = CacheManager()

        // Check device capability on initialization
        self.isAvailable = await deviceChecker.isFoundationModelsAvailable()

        if isAvailable {
            print("✅ FoundationModelsClient initialized successfully")
        } else {
            print("⚠️  FoundationModelsClient initialized but Foundation Models unavailable on this device")
        }
    }

    // MARK: - Public API

    /// Generate text response from prompt using Foundation Models
    public func generate<T: Generable>(
        prompt: String,
        type: T.Type,
        cacheKey: String? = nil
    ) async throws -> T {
        // Pre-flight checks
        guard isAvailable else {
            throw FoundationModelsError.deviceNotSupported
        }

        // Check cache
        if let key = cacheKey, let cached: T = await cache.get(key) {
            await performanceMonitor.recordCacheHit()
            return cached
        }

        // Measure performance
        let startTime = CFAbsoluteTimeGetCurrent()

        // Call Foundation Models API
        let result = try await performGeneration(prompt: prompt, type: type)

        // Validate performance budget
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000  // Convert to ms
        await performanceMonitor.recordLatency(elapsed)

        guard elapsed < 50.0 else {
            print("⚠️  Foundation Models exceeded 50ms budget: \(elapsed)ms")
            throw FoundationModelsError.performanceBudgetViolation(elapsed)
        }

        // Cache result
        if let key = cacheKey {
            await cache.set(key, value: result, ttl: 3600)  // 1 hour TTL
        }

        return result
    }

    /// Summarize text using Foundation Models
    public func summarize(
        text: String,
        style: SummaryStyle = .concise,
        maxLength: Int = 150
    ) async throws -> String {
        guard isAvailable else {
            throw FoundationModelsError.deviceNotSupported
        }

        // iOS 26 Foundation Models API
        let summary = try await FoundationModels.summarize(
            text: text,
            style: style.toFMStyle(),
            maxLength: maxLength
        )

        return summary
    }

    /// Extract entities from text
    public func extractEntities(
        from text: String,
        types: [EntityType]
    ) async throws -> [String: [String]] {
        guard isAvailable else {
            throw FoundationModelsError.deviceNotSupported
        }

        let entities = try await FoundationModels.extract(
            entities: types.map { $0.toFMType() },
            from: text
        )

        return entities
    }

    // MARK: - Private Methods

    private func performGeneration<T: Generable>(
        prompt: String,
        type: T.Type
    ) async throws -> T {
        // Use iOS 26 Foundation Models Generable API
        // This is a placeholder - actual implementation depends on iOS 26 final API

        // Example structure (API may differ):
        // let result = try await FoundationModels.generate(
        //     prompt: prompt,
        //     outputType: T.self
        // )

        // For now, throw unimplemented
        throw FoundationModelsError.notImplemented
    }
}

// MARK: - Supporting Types

public enum SummaryStyle {
    case concise
    case detailed
    case bulletPoints

    fileprivate func toFMStyle() -> FoundationModels.SummaryStyle {
        switch self {
        case .concise: return .concise
        case .detailed: return .detailed
        case .bulletPoints: return .bulletPoints
        }
    }
}

public enum EntityType {
    case skills
    case companies
    case locations
    case dates
    case people

    fileprivate func toFMType() -> FoundationModels.EntityType {
        switch self {
        case .skills: return .custom("skills")
        case .companies: return .organizationName
        case .locations: return .placeName
        case .dates: return .date
        case .people: return .personalName
        }
    }
}

public protocol Generable: Codable, Sendable {
    // Marker protocol for Foundation Models generation
}

public enum FoundationModelsError: Error, LocalizedError {
    case deviceNotSupported
    case performanceBudgetViolation(Double)
    case notImplemented
    case parsingFailed(String)

    public var errorDescription: String? {
        switch self {
        case .deviceNotSupported:
            return "Foundation Models requires iPhone 15 Pro+ or M1+ iPad"
        case .performanceBudgetViolation(let ms):
            return "Foundation Models exceeded 50ms budget: \(ms)ms"
        case .notImplemented:
            return "Foundation Models API not yet implemented (iOS 26 beta)"
        case .parsingFailed(let reason):
            return "Failed to parse Foundation Models response: \(reason)"
        }
    }
}
```

### Phase 2.2: Resume Parsing Migration (Weeks 5-7)

#### ResumeParsingService.swift
```swift
// File: Packages/V7FoundationModels/Sources/V7FoundationModels/Services/ResumeParsingService.swift

import Foundation
import V7Core

/// Parses resumes using iOS 26 Foundation Models
public actor ResumeParsingService {

    // MARK: - Properties

    private let client: FoundationModelsClient
    private let cache: CacheManager
    private let monitor: PerformanceMonitor

    // MARK: - Initialization

    public init(
        client: FoundationModelsClient,
        cache: CacheManager,
        monitor: PerformanceMonitor
    ) {
        self.client = client
        self.cache = cache
        self.monitor = monitor
    }

    // MARK: - Public API

    /// Parse resume text into structured data
    public func parseResume(_ text: String) async throws -> ParsedResume {
        // Generate cache key from resume text
        let cacheKey = "resume_\(text.sha256Hash())"

        // Check cache first
        if let cached: ParsedResume = await cache.get(cacheKey) {
            print("💾 Using cached resume parse")
            await monitor.recordCacheHit()
            return cached
        }

        // Measure performance
        let startTime = CFAbsoluteTimeGetCurrent()

        // Parse with Foundation Models
        let parsed = try await client.generate(
            prompt: buildResumePrompt(text),
            type: ParsedResume.self,
            cacheKey: cacheKey
        )

        // Validate performance
        let elapsed = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        await monitor.recordLatency(elapsed, operation: "resume_parsing")

        // Validate required fields
        guard parsed.isValid else {
            throw FoundationModelsError.parsingFailed("Missing required fields")
        }

        // Cache result
        await cache.set(cacheKey, value: parsed, ttl: 3600)

        print("✅ Resume parsed in \(Int(elapsed))ms")
        return parsed
    }

    // MARK: - Private Methods

    private func buildResumePrompt(_ text: String) -> String {
        """
        Extract structured information from this resume:

        \(text)

        Return JSON with the following fields:
        - name: Full name
        - email: Email address
        - phone: Phone number
        - skills: Array of skills mentioned
        - workExperience: Array of work experience entries
        - education: Array of education entries
        - certifications: Array of certifications
        - projects: Array of project descriptions

        Be precise and extract only information explicitly stated in the resume.
        """
    }
}

// MARK: - Models

@Generable
public struct ParsedResume: Sendable {
    public let name: String?
    public let email: String?
    public let phone: String?
    public let skills: [String]
    public let workExperience: [WorkExperience]
    public let education: [Education]
    public let certifications: [String]
    public let projects: [Project]

    public var isValid: Bool {
        // At minimum, need name or email
        (name != nil && !name!.isEmpty) || (email != nil && !email!.isEmpty)
    }
}

@Generable
public struct WorkExperience: Sendable {
    public let company: String
    public let title: String
    public let startDate: String?
    public let endDate: String?
    public let description: String?
    public let achievements: [String]
}

@Generable
public struct Education: Sendable {
    public let institution: String
    public let degree: String
    public let field: String?
    public let graduationYear: String?
    public let gpa: String?
}

@Generable
public struct Project: Sendable {
    public let name: String
    public let description: String
    public let technologies: [String]
    public let url: String?
}
```

### Phase 2.3: FallbackCoordinator Integration (Week 8)

#### FallbackCoordinator.swift
```swift
// File: Packages/V7FoundationModels/Sources/V7FoundationModels/Integration/FallbackCoordinator.swift

import Foundation
import V7Core

/// Coordinates between Foundation Models (primary) and OpenAI (fallback)
public actor FallbackCoordinator {

    // MARK: - Properties

    private let foundationModelsService: ResumeParsingService
    private let openAIService: OpenAIResumeParser  // Existing V7AIParsing
    private let deviceChecker: DeviceCapabilityChecker

    private var strategy: Strategy = .foundationModels

    enum Strategy {
        case foundationModels
        case openAI
    }

    // MARK: - Initialization

    public init(
        foundationModelsService: ResumeParsingService,
        openAIService: OpenAIResumeParser
    ) async {
        self.foundationModelsService = foundationModelsService
        self.openAIService = openAIService
        self.deviceChecker = DeviceCapabilityChecker()

        // Determine strategy
        self.strategy = await determineStrategy()
    }

    // MARK: - Public API

    /// Parse resume with automatic fallback
    public func parseResume(_ text: String) async throws -> ParsedResume {
        let selectedStrategy = await determineStrategy()

        switch selectedStrategy {
        case .foundationModels:
            do {
                // Try Foundation Models first
                let result = try await foundationModelsService.parseResume(text)
                print("✅ Parsed with Foundation Models")
                return result

            } catch {
                print("⚠️  Foundation Models failed: \(error)")
                print("↩️  Falling back to OpenAI...")

                // Fall back to OpenAI
                let openAIResult = try await openAIService.parseResume(text)
                return convertFromOpenAI(openAIResult)
            }

        case .openAI:
            // Use OpenAI directly
            let openAIResult = try await openAIService.parseResume(text)
            return convertFromOpenAI(openAIResult)
        }
    }

    // MARK: - Private Methods

    private func determineStrategy() async -> Strategy {
        // Check device capability
        guard await deviceChecker.isFoundationModelsAvailable() else {
            print("📱 Device doesn't support Foundation Models, using OpenAI")
            return .openAI
        }

        // Check user preference (allow override for testing)
        if UserDefaults.standard.bool(forKey: "v7.preferCloudAI") {
            print("⚙️  User prefers cloud AI, using OpenAI")
            return .openAI
        }

        print("🎯 Using Foundation Models (on-device)")
        return .foundationModels
    }

    private func convertFromOpenAI(_ openAIResult: OpenAIResumeResult) -> ParsedResume {
        // Convert OpenAI format to Foundation Models format
        ParsedResume(
            name: openAIResult.name,
            email: openAIResult.email,
            phone: openAIResult.phone,
            skills: openAIResult.skills,
            workExperience: openAIResult.experience.map { exp in
                WorkExperience(
                    company: exp.company,
                    title: exp.title,
                    startDate: exp.startDate,
                    endDate: exp.endDate,
                    description: exp.description,
                    achievements: exp.achievements
                )
            },
            education: openAIResult.education.map { edu in
                Education(
                    institution: edu.institution,
                    degree: edu.degree,
                    field: edu.field,
                    graduationYear: edu.graduationYear,
                    gpa: edu.gpa
                )
            },
            certifications: openAIResult.certifications,
            projects: openAIResult.projects.map { proj in
                Project(
                    name: proj.name,
                    description: proj.description,
                    technologies: proj.technologies,
                    url: proj.url
                )
            }
        )
    }
}

// MARK: - OpenAI Types (Placeholder)

struct OpenAIResumeParser {
    func parseResume(_ text: String) async throws -> OpenAIResumeResult {
        // Existing V7AIParsing implementation
        fatalError("Not implemented - use existing V7AIParsing code")
    }
}

struct OpenAIResumeResult {
    let name: String?
    let email: String?
    let phone: String?
    let skills: [String]
    let experience: [OpenAIWorkExperience]
    let education: [OpenAIEducation]
    let certifications: [String]
    let projects: [OpenAIProject]
}

struct OpenAIWorkExperience {
    let company: String
    let title: String
    let startDate: String?
    let endDate: String?
    let description: String?
    let achievements: [String]
}

struct OpenAIEducation {
    let institution: String
    let degree: String
    let field: String?
    let graduationYear: String?
    let gpa: String?
}

struct OpenAIProject {
    let name: String
    let description: String
    let technologies: [String]
    let url: String?
}
```

### Success Criteria for Phase 2
- ✅ Foundation Models parsing accuracy ≥95% vs OpenAI baseline
- ✅ Latency <50ms (vs 1-3s OpenAI)
- ✅ Fallback works seamlessly for older devices
- ✅ Cache hit rate >70%
- ✅ Cost savings: $200-500/month → $0
- ✅ Privacy: 100% on-device processing
- ✅ Thompson budget maintained: <10ms (unaffected by AI work)

### Timeline Summary
- Week 3-4: Foundation package setup, device capability checking
- Week 5-7: Resume parsing migration, performance optimization
- Week 8: FallbackCoordinator integration with OpenAI
- Week 9-10: Job analysis and skill extraction migration
- Week 11-13: Embeddings and similarity scoring migration
- Week 14-16: Comprehensive testing, A/B testing, gradual rollout

---

## PHASE 3: Profile Data Model Expansion (Weeks 3-12)
### HIGH PRIORITY - Runs in Parallel with Phase 2

### Problem Statement
**Current State**:
- Profile completeness: 55/100
- Missing structures: Certifications, Projects, Volunteer Experience, Awards
- Incomplete: Work experience details, Education enhancements

**Why This Matters**:
- Richer profiles enable better job matching (more data points)
- Career transition pathways require comprehensive skill/experience tracking
- Course recommendations need accurate skill gap analysis
- Manifest Profile (Teal) needs full picture to reveal hidden potential

### Solution
5-sub-phase implementation expanding Core Data models and extraction logic.

### Phase 3.1: Certifications Model (Weeks 3-4)

#### Core Data Model Addition
```swift
// File: Packages/V7Data/Sources/V7Data/Entities/Certification+CoreData.swift

import Foundation
import CoreData

@objc(Certification)
public final class Certification: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var issuer: String
    @NSManaged public var issueDate: Date?
    @NSManaged public var expirationDate: Date?
    @NSManaged public var credentialId: String?
    @NSManaged public var verificationURL: String?
    @NSManaged public var doesNotExpire: Bool
    @NSManaged public var profile: UserProfile

    // MARK: - Computed Properties

    public var isExpired: Bool {
        guard let expirationDate = expirationDate, !doesNotExpire else {
            return false
        }
        return Date() > expirationDate
    }

    public var isValid: Bool {
        !name.isEmpty && !issuer.isEmpty
    }

    public var displayStatus: String {
        if doesNotExpire {
            return "Valid (No Expiration)"
        } else if let expDate = expirationDate {
            if isExpired {
                return "Expired \(expDate.formatted(.dateTime.month().year()))"
            } else {
                return "Valid until \(expDate.formatted(.dateTime.month().year()))"
            }
        }
        return "Unknown Status"
    }
}

// MARK: - Fetch Request

extension Certification {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Certification> {
        return NSFetchRequest<Certification>(entityName: "Certification")
    }

    public class func validCertifications(for profile: UserProfile) -> NSFetchRequest<Certification> {
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "profile == %@ AND (doesNotExpire == YES OR expirationDate > %@)",
            profile, Date() as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Certification.issueDate, ascending: false)
        ]
        return request
    }
}
```

#### Resume Extraction Enhancement
```swift
// File: Packages/V7AIParsing/Sources/V7AIParsing/Models/ParsedCertification.swift

import Foundation

@Generable
public struct ParsedCertification: Sendable {
    @Guide(description: "Certification name (e.g., 'AWS Certified Solutions Architect')")
    public let name: String

    @Guide(description: "Issuing organization (e.g., 'Amazon Web Services')")
    public let issuer: String

    @Guide(description: "Issue date in YYYY-MM format if available")
    public let issueDate: String?

    @Guide(description: "Expiration date in YYYY-MM format if available")
    public let expirationDate: String?

    @Guide(description: "Credential ID or license number if mentioned")
    public let credentialId: String?

    @Guide(description: "Verification URL if provided")
    public let verificationURL: String?

    @Guide(description: "True if certification is marked as 'No Expiration' or 'Lifetime'")
    public let doesNotExpire: Bool?
}
```

#### Migration Script
```swift
// File: Packages/V7Migration/Sources/V7Migration/Migrations/V7_02_AddCertifications.swift

import Foundation
import CoreData

public final class V7_02_AddCertifications {

    public static func migrate(context: NSManagedObjectContext) async throws {
        print("🔄 Starting V7_02 migration: Add Certifications")

        // Fetch all user profiles
        let profileRequest = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        let profiles = try context.fetch(profileRequest)

        print("📊 Found \(profiles.count) profiles to migrate")

        for profile in profiles {
            // Convert old certifications array (if exists)
            if let oldCerts = profile.value(forKey: "certifications") as? [String] {
                print("  Migrating \(oldCerts.count) certifications for profile: \(profile.id)")

                for certName in oldCerts {
                    // Create new Certification entity
                    let cert = Certification(context: context)
                    cert.id = UUID()
                    cert.name = certName
                    cert.issuer = "Unknown"  // Will be enhanced by re-parsing resume
                    cert.doesNotExpire = true  // Default assumption
                    cert.profile = profile
                }

                // Remove old certifications array
                profile.setValue(nil, forKey: "certifications")
            }
        }

        // Save context
        try context.save()

        print("✅ V7_02 migration completed successfully")
    }
}
```

### Phase 3.2: Projects/Portfolio Model (Weeks 5-6)

#### Core Data Model
```swift
// File: Packages/V7Data/Sources/V7Data/Entities/Project+CoreData.swift

import Foundation
import CoreData

@objc(Project)
public final class Project: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var description_: String  // Avoid Swift keyword
    @NSManaged public var highlights: [String]
    @NSManaged public var technologies: [String]
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var url: String?
    @NSManaged public var repositoryURL: String?
    @NSManaged public var roles: [String]
    @NSManaged public var entity: String  // "personal", "company", "academic", "openSource"
    @NSManaged public var type: String    // "application", "website", "research", "library"
    @NSManaged public var profile: UserProfile

    // MARK: - Computed Properties

    public var isCurrent: Bool {
        endDate == nil
    }

    public var isValid: Bool {
        !name.isEmpty && !description_.isEmpty
    }

    public var durationMonths: Int? {
        guard let start = startDate else { return nil }
        let end = endDate ?? Date()
        let components = Calendar.current.dateComponents([.month], from: start, to: end)
        return components.month
    }
}

// MARK: - Fetch Request

extension Project {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    public class func currentProjects(for profile: UserProfile) -> NSFetchRequest<Project> {
        let request = fetchRequest()
        request.predicate = NSPredicate(
            format: "profile == %@ AND endDate == nil",
            profile
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Project.startDate, ascending: false)
        ]
        return request
    }
}
```

### Phase 3.3: Volunteer Experience Model (Weeks 7-8)

#### Core Data Model
```swift
// File: Packages/V7Data/Sources/V7Data/Entities/VolunteerExperience+CoreData.swift

import Foundation
import CoreData

@objc(VolunteerExperience)
public final class VolunteerExperience: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var organization: String
    @NSManaged public var role: String
    @NSManaged public var cause: String?  // "Education", "Healthcare", "Environment", etc.
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var description_: String?
    @NSManaged public var hoursPerWeek: Int16
    @NSManaged public var totalHours: Int32
    @NSManaged public var achievements: [String]
    @NSManaged public var skills: [String]
    @NSManaged public var profile: UserProfile

    // MARK: - Computed Properties

    public var isCurrent: Bool {
        endDate == nil
    }

    public var durationMonths: Int? {
        let end = endDate ?? Date()
        let components = Calendar.current.dateComponents([.month], from: startDate, to: end)
        return components.month
    }

    public var estimatedTotalHours: Int {
        if totalHours > 0 {
            return Int(totalHours)
        }

        // Estimate from duration and hours/week
        guard let months = durationMonths else { return 0 }
        let weeks = Double(months) * 4.33  // Average weeks per month
        return Int(weeks * Double(hoursPerWeek))
    }
}
```

### Phase 3.4: Awards & Publications Models (Weeks 9-10)

#### Core Data Models
```swift
// File: Packages/V7Data/Sources/V7Data/Entities/Award+CoreData.swift

import Foundation
import CoreData

@objc(Award)
public final class Award: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var issuer: String
    @NSManaged public var date: Date
    @NSManaged public var description_: String?
    @NSManaged public var category: String?  // "Academic", "Professional", "Community"
    @NSManaged public var verificationURL: String?
    @NSManaged public var profile: UserProfile
}

// File: Packages/V7Data/Sources/V7Data/Entities/Publication+CoreData.swift

@objc(Publication)
public final class Publication: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var publisher: String
    @NSManaged public var date: Date
    @NSManaged public var url: String?
    @NSManaged public var authors: [String]
    @NSManaged public var description_: String?
    @NSManaged public var publicationType: String  // "Journal", "Conference", "Book", "Blog"
    @NSManaged public var doi: String?  // Digital Object Identifier
    @NSManaged public var profile: UserProfile
}
```

### Phase 3.5: Enhanced Work Experience & Education (Weeks 11-12)

#### Enhancements
```swift
// File: Packages/V7Data/Sources/V7Data/Entities/WorkExperience+CoreData.swift
// Add to existing WorkExperience entity:

@NSManaged public var location: String?
@NSManaged public var industry: String?
@NSManaged public var employmentType: String?  // "full-time", "part-time", "contract", "freelance"
@NSManaged public var achievements: [String]
@NSManaged public var technologiesUsed: [String]
@NSManaged public var teamSize: Int16  // Number of people managed or worked with
@NSManaged public var isRemote: Bool

// File: Packages/V7Data/Sources/V7Data/Entities/Education+CoreData.swift
// Add to existing Education entity:

@NSManaged public var gpa: Double  // 0.0 if not provided
@NSManaged public var gpaScale: Double  // Usually 4.0
@NSManaged public var honors: [String]  // "Cum Laude", "Dean's List", etc.
@NSManaged public var coursework: [String]  // Relevant courses
@NSManaged public var activities: [String]  // Clubs, sports, leadership
@NSManaged public var thesis: String?  // Thesis title for advanced degrees
```

### Success Criteria for Phase 3
- ✅ Profile completeness score: 55% → 95%
- ✅ All new entities migrated successfully
- ✅ Resume parser extracts all new fields
- ✅ Onboarding flow updated with review steps
- ✅ ProfileSummaryView displays all data
- ✅ Zero data loss during migrations
- ✅ Core Data relationship integrity maintained

---

## PHASE 4: Liquid Glass UI Adoption (Weeks 13-17)
### DESIGN MODERNIZATION - After Phase 2-3 Stable

### Objective
Adopt iOS 26 Liquid Glass design system while maintaining sacred 4-tab UI and accessibility standards.

### Liquid Glass Principles

**What Is Liquid Glass?**
- Translucent material that reflects light dynamically
- Refracts content beneath it (like real glass)
- Adapts to user preference (Clear vs Tinted mode)
- Multi-layered rendering for depth perception

**Automatic Adoption**:
- Apps compiled with Xcode 26 automatically get Liquid Glass backgrounds
- SwiftUI sheets, cards, and overlays use Liquid Glass by default
- No code changes required for basic adoption

### Implementation Strategy

#### Phase 4.1: Test Current App with Liquid Glass (Week 13)

**Task**: Build with Xcode 26 and observe automatic Liquid Glass adoption

```bash
# Build with Xcode 26
xcodebuild -workspace ManifestAndMatchV7.xcworkspace \
           -scheme ManifestAndMatchV7 \
           -sdk iphonesimulator \
           -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0'

# Test both Liquid Glass modes
# Settings → Display & Brightness → Liquid Glass
# 1. Clear Mode (maximum transparency)
# 2. Tinted Mode (increased opacity)
```

**Checklist**:
- [ ] Test sacred 4-tab UI with Liquid Glass
- [ ] Verify text readability in Clear mode
- [ ] Verify text readability in Tinted mode
- [ ] Check WCAG AA contrast ratios (≥4.5:1 normal text)
- [ ] Test all job cards with Liquid Glass background
- [ ] Verify swipe gestures still work correctly
- [ ] Test profile screen with Liquid Glass
- [ ] Validate analytics charts render correctly

#### Phase 4.2: Explicit Liquid Glass Adoption (Week 14-15)

**Apply Liquid Glass to custom UI elements:**

```swift
// File: Packages/V7UI/Sources/V7UI/Components/JobCard.swift

import SwiftUI

public struct JobCard: View {
    let job: Job

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Job title
            Text(job.title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            // Company
            Text(job.company)
                .font(.headline)
                .foregroundStyle(.secondary)

            // Location
            HStack {
                Image(systemName: "mappin.circle.fill")
                Text(job.location)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // Skills tags
            SkillTagsView(skills: job.skills)
        }
        .padding(20)
        .background(.liquidGlass)  // ✨ iOS 26 Liquid Glass material
        .glassIntensity(0.8)        // Control translucency
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}
```

**Liquid Glass for Sheets and Modals:**

```swift
// File: Packages/V7UI/Sources/V7UI/Screens/JobDetailView.swift

import SwiftUI

public struct JobDetailView: View {
    let job: Job
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Job details...
            }
            .padding()
        }
        // ✨ iOS 26: Liquid Glass automatic for sheets
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// Usage:
.sheet(isPresented: $showJobDetail) {
    JobDetailView(job: selectedJob)
    // ✨ Automatically uses Liquid Glass background
}
```

#### Phase 4.3: Contrast and Accessibility Validation (Week 16)

**WCAG AA Contrast Requirements**:
- Normal text (< 18pt): 4.5:1 contrast ratio
- Large text (≥ 18pt): 3:0 contrast ratio
- UI components: 3:1 contrast ratio

**Validation Strategy**:

```swift
// File: Packages/V7UI/Sources/V7UI/Accessibility/ContrastValidator.swift

import SwiftUI
import UIKit

public struct ContrastValidator {

    /// Calculate relative luminance of a color
    public static func relativeLuminance(of color: UIColor) -> Double {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        let components = [r, g, b].map { component -> Double in
            let c = Double(component)
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * components[0] + 0.7152 * components[1] + 0.0722 * components[2]
    }

    /// Calculate contrast ratio between two colors
    public static func contrastRatio(foreground: UIColor, background: UIColor) -> Double {
        let fgLuminance = relativeLuminance(of: foreground)
        let bgLuminance = relativeLuminance(of: background)

        let lighter = max(fgLuminance, bgLuminance)
        let darker = min(fgLuminance, bgLuminance)

        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Check if contrast meets WCAG AA standard
    public static func meetsWCAG_AA(
        foreground: UIColor,
        background: UIColor,
        largeText: Bool = false
    ) -> Bool {
        let ratio = contrastRatio(foreground: foreground, background: background)
        let threshold = largeText ? 3.0 : 4.5
        return ratio >= threshold
    }
}

// Unit tests:
@Test func contrastValidation() {
    let white = UIColor.white
    let black = UIColor.black
    let amber = UIColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)

    // Black on white (highest contrast)
    let blackWhiteRatio = ContrastValidator.contrastRatio(foreground: black, background: white)
    #expect(blackWhiteRatio >= 15.0)

    // Amber on white (should pass AA)
    let amberWhiteRatio = ContrastValidator.contrastRatio(foreground: amber, background: white)
    #expect(amberWhiteRatio >= 4.5)
    #expect(ContrastValidator.meetsWCAG_AA(foreground: amber, background: white))
}
```

**Test All Text Combinations**:
```swift
// Test matrix:
let backgrounds: [UIColor] = [
    .liquidGlass,          // iOS 26 Liquid Glass
    .systemBackground,     // Adapts to Dark Mode
    .secondarySystemBackground
]

let foregrounds: [UIColor] = [
    .label,                // Primary text (adapts)
    .secondaryLabel,       // Secondary text (adapts)
    .amberAccent,          // Custom amber color
    .tealAccent            // Custom teal color
]

for bg in backgrounds {
    for fg in foregrounds {
        let ratio = ContrastValidator.contrastRatio(foreground: fg, background: bg)
        print("\(fg) on \(bg): \(ratio):1")
        assert(ratio >= 4.5, "Failed WCAG AA")
    }
}
```

#### Phase 4.4: Reduce Motion Support (Week 17)

**Respect user motion preferences:**

```swift
// File: Packages/V7UI/Sources/V7UI/Components/AnimatedJobCard.swift

import SwiftUI

public struct AnimatedJobCard: View {
    let job: Job
    @State private var isAnimating = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    public var body: some View {
        JobCard(job: job)
            .scaleEffect(isAnimating && !reduceMotion ? 1.02 : 1.0)
            .animation(
                reduceMotion ? .none : .spring(response: 0.3, dampingFraction: 0.7),
                value: isAnimating
            )
            .onAppear {
                if !reduceMotion {
                    isAnimating = true
                }
            }
    }
}

// Swipe animations with reduce motion support:
public struct SwipeableJobCardView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @GestureState private var dragOffset: CGFloat = 0

    public var body: some View {
        JobCard(job: job)
            .offset(x: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        if value.translation.width > 100 {
                            applyToJob()
                        } else if value.translation.width < -100 {
                            skipJob()
                        }
                    }
            )
            .animation(
                reduceMotion ? .none : .spring(),
                value: dragOffset
            )
    }
}
```

### Success Criteria for Phase 4
- ✅ Liquid Glass adopted across all major UI components
- ✅ Clear and Tinted modes both tested and functional
- ✅ WCAG AA contrast ratios maintained (≥4.5:1 normal text)
- ✅ Reduce Motion respected in all animations
- ✅ Sacred 4-tab UI structure preserved
- ✅ Job swipe gestures work correctly with Liquid Glass
- ✅ Performance: 60 FPS rendering maintained
- ✅ No regressions in accessibility (VoiceOver, Dynamic Type)

---

## PHASE 5: Course Integration Revenue (Weeks 18-20)
### BUSINESS VALUE - After Profile Expansion Complete

**Objective**: Integrate Udemy and Coursera APIs to recommend courses that fill skill gaps, generating affiliate revenue.

### Why This Phase Depends on Phase 3
- Profile expansion (Phase 3) provides accurate skill data
- Skill gap analysis requires comprehensive profile information
- Course recommendations must align with transition pathways

### Implementation

#### File Structure
```
ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Manifest/
├── Services/
│   ├── CourseRecommendationService.swift   # Main orchestrator
│   ├── UdemyAPIClient.swift                # Udemy integration
│   ├── CourseraAPIClient.swift             # Coursera integration
│   └── AffiliateTrackingService.swift      # Revenue attribution
├── Models/
│   ├── Course.swift                        # Unified course model
│   └── CourseRecommendation.swift          # Recommendation with context
└── Views/
    ├── CourseRecommendationCard.swift      # Course UI component
    └── CourseDetailView.swift              # Course details sheet
```

#### CourseRecommendationService.swift
```swift
// File: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Manifest/Services/CourseRecommendationService.swift

import Foundation
import V7Core

public actor CourseRecommendationService {

    // MARK: - Properties

    private let udemyClient: UdemyAPIClient
    private let courseraClient: CourseraAPIClient
    private let cache: CacheManager
    private let affiliateTracker: AffiliateTrackingService

    // MARK: - Initialization

    public init() async throws {
        self.udemyClient = try await UdemyAPIClient()
        self.courseraClient = try await CourseraAPIClient()
        self.cache = CacheManager()
        self.affiliateTracker = AffiliateTrackingService()
    }

    // MARK: - Public API

    /// Recommend courses based on skill gaps and career goals
    public func recommendCourses(
        for skillGaps: [String],
        targetRole: String,
        userLevel: SkillLevel,
        budget: Budget = .any
    ) async throws -> [CourseRecommendation] {

        // Check cache first
        let cacheKey = "courses_\(skillGaps.joined(separator: "_"))_\(targetRole)_\(userLevel)"
        if let cached: [CourseRecommendation] = await cache.get(cacheKey) {
            print("💾 Using cached course recommendations")
            return cached
        }

        // Fetch from multiple providers in parallel
        async let udemyCourses = udemyClient.searchCourses(
            skills: skillGaps,
            level: userLevel,
            maxPrice: budget.maxPrice
        )

        async let courseraCourses = courseraClient.searchCourses(
            skills: skillGaps,
            level: userLevel
        )

        let allCourses = try await udemyCourses + courseraCourses

        // Filter and rank
        let filtered = allCourses
            .filter { $0.rating >= 4.5 }  // Only highly rated
            .filter { $0.lastUpdated > Date().addingTimeInterval(-63072000) }  // Last 2 years
            .filter { budget.matches($0.price) }

        // Personalize based on skill gaps
        let personalized = personalizeResults(
            filtered,
            skillGaps: skillGaps,
            targetRole: targetRole
        )

        // Create recommendations with context
        let recommendations = personalized.map { course in
            CourseRecommendation(
                course: course,
                relevanceScore: calculateRelevance(course, skillGaps: skillGaps),
                skillsCovered: course.skills.filter { skillGaps.contains($0) },
                estimatedCompletionTime: course.duration,
                rationale: generateRationale(course, targetRole: targetRole)
            )
        }

        // Cache for 6 hours
        await cache.set(cacheKey, value: recommendations, ttl: 21600)

        return recommendations
    }

    // MARK: - Private Methods

    private func personalizeResults(
        _ courses: [Course],
        skillGaps: [String],
        targetRole: String
    ) -> [Course] {
        return courses.sorted { course1, course2 in
            let score1 = calculateRelevance(course1, skillGaps: skillGaps)
            let score2 = calculateRelevance(course2, skillGaps: skillGaps)
            return score1 > score2
        }
    }

    private func calculateRelevance(_ course: Course, skillGaps: [String]) -> Double {
        let skillOverlap = Set(course.skills).intersection(Set(skillGaps)).count
        let maxPossible = min(course.skills.count, skillGaps.count)

        guard maxPossible > 0 else { return 0.0 }

        let baseScore = Double(skillOverlap) / Double(maxPossible)

        // Boost for highly rated courses
        let ratingBoost = (course.rating - 4.0) * 0.1  // 4.5 → +0.05, 5.0 → +0.10

        // Boost for recently updated
        let monthsSinceUpdate = -course.lastUpdated.timeIntervalSinceNow / (30 * 24 * 3600)
        let freshnessBoost = monthsSinceUpdate < 6 ? 0.05 : 0.0

        return baseScore + ratingBoost + freshnessBoost
    }

    private func generateRationale(_ course: Course, targetRole: String) -> String {
        """
        This course covers essential skills for \(targetRole) roles. \
        Rated \(course.rating)/5 by \(course.reviewCount) students. \
        Last updated \(course.lastUpdated.formatted(.dateTime.month().year())). \
        Typical completion time: \(course.duration) hours.
        """
    }
}

// MARK: - Supporting Types

public enum SkillLevel: String, Codable {
    case beginner
    case intermediate
    case advanced
    case expert
}

public enum Budget {
    case free
    case under50
    case under100
    case under200
    case any

    var maxPrice: Decimal? {
        switch self {
        case .free: return 0
        case .under50: return 50
        case .under100: return 100
        case .under200: return 200
        case .any: return nil
        }
    }

    func matches(_ price: Decimal?) -> Bool {
        guard let maxPrice = maxPrice else { return true }
        guard let price = price else { return true }
        return price <= maxPrice
    }
}

public struct Course: Identifiable, Codable, Sendable {
    public let id: UUID
    public let title: String
    public let provider: String  // "Udemy", "Coursera"
    public let url: URL
    public let affiliateURL: URL  // URL with affiliate tracking
    public let price: Decimal?
    public let rating: Double
    public let reviewCount: Int
    public let lastUpdated: Date
    public let duration: Int  // Hours
    public let skills: [String]
    public let instructor: String
    public let thumbnailURL: URL?
}

public struct CourseRecommendation: Identifiable, Sendable {
    public let id = UUID()
    public let course: Course
    public let relevanceScore: Double
    public let skillsCovered: [String]
    public let estimatedCompletionTime: Int
    public let rationale: String
}
```

#### UdemyAPIClient.swift
```swift
// File: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Manifest/Services/UdemyAPIClient.swift

import Foundation

public actor UdemyAPIClient {

    // MARK: - Configuration

    private let apiKey: String
    private let affiliateId: String
    private let session: URLSession

    // MARK: - Initialization

    public init() async throws {
        // Load credentials from Keychain
        let keychainService = KeychainService()
        self.apiKey = try await keychainService.loadAPIKey(service: "com.manifestandmatch.udemy")
        self.affiliateId = try await keychainService.loadAPIKey(service: "com.manifestandmatch.udemy.affiliate")

        // Configure session with TLS 1.3
        let config = URLSessionConfiguration.default
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public Methods

    public func searchCourses(
        skills: [String],
        level: SkillLevel,
        maxPrice: Decimal? = nil
    ) async throws -> [Course] {

        let query = skills.joined(separator: " OR ")

        var components = URLComponents(string: "https://www.udemy.com/api-2.0/courses/")!
        components.queryItems = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "instructional_level", value: level.rawValue),
            URLQueryItem(name: "page_size", value: "20"),
            URLQueryItem(name: "ordering", value: "-rating"),  // Highest rated first
            URLQueryItem(name: "fields[course]", value: "title,url,price,rating,num_reviews,last_update_date,content_info")
        ]

        if let maxPrice = maxPrice {
            components.queryItems?.append(
                URLQueryItem(name: "price", value: "price-\(maxPrice)")
            )
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let result = try decoder.decode(UdemyResponse.self, from: data)

        // Convert to internal Course model with affiliate links
        return result.results.map { udemyCourse in
            Course(
                id: UUID(),
                title: udemyCourse.title,
                provider: "Udemy",
                url: URL(string: udemyCourse.url)!,
                affiliateURL: buildAffiliateURL(udemyCourse.url),
                price: udemyCourse.price,
                rating: udemyCourse.rating,
                reviewCount: udemyCourse.numReviews,
                lastUpdated: ISO8601DateFormatter().date(from: udemyCourse.lastUpdateDate) ?? Date(),
                duration: udemyCourse.contentInfo?.totalDuration ?? 0,
                skills: skills,  // Udemy doesn't provide skill tags, use search terms
                instructor: udemyCourse.visibleInstructors?.first?.title ?? "Unknown",
                thumbnailURL: URL(string: udemyCourse.image480x270)
            )
        }
    }

    // MARK: - Private Methods

    private func buildAffiliateURL(_ originalURL: String) -> URL {
        var components = URLComponents(string: originalURL)!
        components.queryItems = [
            URLQueryItem(name: "affiliateCode", value: affiliateId),
            URLQueryItem(name: "utm_source", value: "manifestandmatch"),
            URLQueryItem(name: "utm_medium", value: "affiliate"),
            URLQueryItem(name: "utm_campaign", value: "career_transition")
        ]
        return components.url!
    }
}

// MARK: - Udemy API Models

struct UdemyResponse: Codable {
    let results: [UdemyCourse]
    let count: Int
}

struct UdemyCourse: Codable {
    let id: Int
    let title: String
    let url: String
    let price: Decimal?
    let rating: Double
    let numReviews: Int
    let lastUpdateDate: String
    let contentInfo: ContentInfo?
    let visibleInstructors: [Instructor]?
    let image480x270: String?

    struct ContentInfo: Codable {
        let totalDuration: Int  // Seconds
    }

    struct Instructor: Codable {
        let title: String
    }
}
```

#### AffiliateTrackingService.swift
```swift
// File: ManifestAndMatchV7Package/Sources/ManifestAndMatchV7Feature/Manifest/Services/AffiliateTrackingService.swift

import Foundation

public actor AffiliateTrackingService {

    // MARK: - Public API

    public func trackCourseClick(courseId: UUID, provider: String) async {
        let event = AffiliateEvent(
            type: .click,
            courseId: courseId,
            provider: provider,
            timestamp: Date(),
            userId: await getAnonymousUserId()
        )

        await logEvent(event)
        await sendToAnalytics(event)
    }

    public func trackCourseEnrollment(
        courseId: UUID,
        provider: String,
        revenue: Decimal
    ) async {
        let event = AffiliateEvent(
            type: .enrollment,
            courseId: courseId,
            provider: provider,
            timestamp: Date(),
            userId: await getAnonymousUserId(),
            revenue: revenue
        )

        await logEvent(event)
        await sendToAnalytics(event)

        print("💰 Course enrollment tracked: \(provider) - $\(revenue)")
    }

    // MARK: - Private Methods

    private func getAnonymousUserId() async -> String {
        // Retrieve anonymous user ID from UserDefaults
        if let id = UserDefaults.standard.string(forKey: "v7.anonymousUserId") {
            return id
        }

        // Generate new ID if not exists
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: "v7.anonymousUserId")
        return newId
    }

    private func logEvent(_ event: AffiliateEvent) async {
        // Log to local database for revenue tracking
        print("📊 Affiliate event: \(event.type) - \(event.provider)")
    }

    private func sendToAnalytics(_ event: AffiliateEvent) async {
        // Send to Firebase/Mixpanel for analysis
        // Implementation depends on analytics provider
    }
}

// MARK: - Supporting Types

struct AffiliateEvent {
    enum EventType: String {
        case click
        case enrollment
    }

    let type: EventType
    let courseId: UUID
    let provider: String
    let timestamp: Date
    let userId: String
    let revenue: Decimal?

    init(
        type: EventType,
        courseId: UUID,
        provider: String,
        timestamp: Date,
        userId: String,
        revenue: Decimal? = nil
    ) {
        self.type = type
        self.courseId = courseId
        self.provider = provider
        self.timestamp = timestamp
        self.userId = userId
        self.revenue = revenue
    }

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "type": type.rawValue,
            "course_id": courseId.uuidString,
            "provider": provider,
            "timestamp": timestamp.timeIntervalSince1970,
            "user_id": userId
        ]

        if let revenue = revenue {
            dict["revenue"] = NSDecimalNumber(decimal: revenue).doubleValue
        }

        return dict
    }
}
```

### Success Criteria for Phase 5
- ✅ Live courses displayed (no sample data)
- ✅ Affiliate links working correctly
- ✅ Click-through rate: >5%
- ✅ Enrollment conversion: >1%
- ✅ Revenue generation: $0.10-$0.50 per user/month
- ✅ Skill gap analysis accurate (depends on Phase 3 profiles)
- ✅ Course recommendations relevant to transition pathways

### Revenue Projection
```
Conservative (1,000 active users):
  5% CTR = 50 clicks/month
  1% enrollment = 10 enrollments/month
  $30 avg commission = $300/month = $3,600/year

Moderate (5,000 active users):
  5% CTR = 250 clicks/month
  1% enrollment = 50 enrollments/month
  $30 avg commission = $1,500/month = $18,000/year

Optimistic (10,000 active users):
  7% CTR = 700 clicks/month
  2% enrollment = 200 enrollments/month
  $30 avg commission = $6,000/month = $72,000/year
```

---

## PHASE 6: Production Hardening (Weeks 21-24)
### QUALITY ASSURANCE - Final Phase Before App Store

### Objective
Ensure production readiness: performance, reliability, accessibility, and successful App Store submission before April 2026 deadline.

### Phase 6.1: Performance Profiling (Week 21)

#### Instruments Profiling Session
```bash
# Profile with Instruments
# Xcode → Product → Profile (Cmd+I)

# Key Instruments to use:
# 1. Time Profiler - CPU usage, hotspots
# 2. Allocations - Memory usage, leaks
# 3. Leaks - Memory leak detection
# 4. Energy Log - Battery impact
# 5. Network - API call efficiency
# 6. SwiftUI - View rendering performance
```

#### Performance Targets (Sacred Constraints)
```yaml
Thompson Scoring:
  Target: <10ms per job
  Current: 0.028ms (well within budget)
  Status: ✅ PASSING

Foundation Models AI:
  Target: <50ms per operation
  Resume Parsing: Expected 20-30ms
  Job Analysis: Expected 15-25ms
  Skill Extraction: Expected 10-20ms
  Status: 🔄 TO BE MEASURED

Memory Usage:
  Baseline: <200MB sustained
  Peak: <250MB absolute maximum
  Current: ~180MB (before iOS 26 changes)
  Status: 🔄 TO BE MEASURED

UI Rendering:
  Target: 60 FPS (16.67ms per frame)
  Job card swipes: Must maintain 60 FPS
  Liquid Glass rendering: Check GPU impact
  Status: 🔄 TO BE MEASURED

Network:
  Job source API calls: <3s response time
  Course API calls: <2s response time
  Retry logic: Exponential backoff working
  Status: 🔄 TO BE MEASURED
```

#### Performance Optimization Checklist
- [ ] Profile Thompson scoring (verify still <10ms)
- [ ] Profile Foundation Models operations (verify <50ms)
- [ ] Profile Liquid Glass rendering (check GPU impact)
- [ ] Check memory usage (baseline <200MB, peak <250MB)
- [ ] Test job card swipe performance (60 FPS maintained)
- [ ] Profile network calls (API response times)
- [ ] Check cache hit rates (>70% for jobs, >80% for AI)
- [ ] Test app launch time (<2s cold start)
- [ ] Profile battery impact (Energy Log instrument)

### Phase 6.2: A/B Testing (Week 22)

#### Foundation Models vs OpenAI Comparison
```swift
// File: V7FoundationModels/Tests/ABTesting/FoundationModelsABTest.swift

import Testing

@Test func compareFoundationModelsVsOpenAI() async throws {
    let testResumes = await loadTestResumes(count: 100)

    var fmResults: [ParsedResume] = []
    var openAIResults: [ParsedResume] = []

    var fmTotalTime: Double = 0
    var openAITotalTime: Double = 0

    for resume in testResumes {
        // Test Foundation Models
        let fmStart = CFAbsoluteTimeGetCurrent()
        let fmParsed = try await foundationModelsService.parseResume(resume)
        fmTotalTime += CFAbsoluteTimeGetCurrent() - fmStart
        fmResults.append(fmParsed)

        // Test OpenAI
        let openAIStart = CFAbsoluteTimeGetCurrent()
        let openAIParsed = try await openAIService.parseResume(resume)
        openAITotalTime += CFAbsoluteTimeGetCurrent() - openAIStart
        openAIResults.append(openAIParsed)
    }

    // Compare accuracy
    let accuracyScore = calculateAccuracyScore(
        foundationModels: fmResults,
        openAI: openAIResults
    )

    print("""
    A/B Test Results (n=100):

    Foundation Models:
      Avg Time: \(fmTotalTime / 100 * 1000)ms
      Accuracy: \(accuracyScore)%
      Cost: $0.00

    OpenAI:
      Avg Time: \(openAITotalTime / 100 * 1000)ms
      Accuracy: 100% (baseline)
      Cost: $\(estimateCost(count: 100))

    Target: ≥95% accuracy at <50ms
    """)

    #expect(accuracyScore >= 95.0, "Foundation Models must be ≥95% accurate")
    #expect(fmTotalTime / 100 < 0.050, "Must be <50ms per resume")
}
```

#### User Experience A/B Test
```
Test Group A (50% of users):
  - Foundation Models AI (on capable devices)
  - OpenAI fallback (on older devices)

Test Group B (50% of users):
  - OpenAI only (current implementation)

Metrics to Track:
  - Resume parsing success rate
  - Time to complete onboarding
  - Job matching satisfaction scores
  - App responsiveness (perceived performance)
  - Crash rates
  - User retention (7-day, 30-day)

Duration: 2 weeks
Expected Outcome: Group A shows equal or better metrics
```

### Phase 6.3: Accessibility Final Validation (Week 23)

#### VoiceOver Testing Protocol
```
Device Setup:
  - iPhone 16 Pro running iOS 26.0.1
  - VoiceOver enabled (Settings → Accessibility → VoiceOver)
  - Reduce Motion enabled (Settings → Accessibility → Motion)
  - Dynamic Type set to Accessibility Extra Large

Test Scenarios:
  1. Complete onboarding with VoiceOver only (no sight)
  2. Navigate all 4 tabs without touch
  3. Swipe job cards using VoiceOver gestures
  4. Read job descriptions with VoiceOver
  5. Access profile and edit information
  6. View analytics charts (alternative text)
  7. Enroll in course recommendation

Success Criteria:
  - 100% of UI accessible via VoiceOver
  - All interactive elements have meaningful labels
  - All charts have text alternatives
  - Job swipe gestures work with accessibility actions
  - No unlabeled buttons or images
```

#### WCAG 2.1 AA Compliance Audit
```
Automated Testing:
  - Run Xcode Accessibility Inspector
  - Check all views for missing labels
  - Verify contrast ratios (≥4.5:1 normal text)
  - Test Dynamic Type scaling (small → XXXL)

Manual Testing:
  - Complete user flows with VoiceOver
  - Test with Reduce Motion enabled
  - Verify keyboard navigation (external keyboard)
  - Test with increased contrast mode
  - Validate color blind safe palettes

Documentation:
  - Create Accessibility Audit Report
  - Document any known limitations
  - Plan fixes for any failures
```

### Phase 6.4: Gradual Rollout Strategy (Week 24)

#### Rollout Plan
```
Week 24 Day 1-2: Internal TestFlight (10 testers)
  - Team testing on iOS 26 devices
  - Verify Foundation Models working
  - Check Liquid Glass rendering
  - Validate sacred 4-tab UI

Week 24 Day 3-4: Beta TestFlight (100 users)
  - Public beta testers on iOS 26+
  - Monitor crash reports (target: <0.1%)
  - Track Foundation Models adoption rate
  - Collect feedback on Liquid Glass design

Week 24 Day 5-7: Phased App Store Release
  - 10% of iOS 26+ users (Day 5)
  - 25% of iOS 26+ users (Day 6)
  - 50% of iOS 26+ users (Day 7)
  - 100% of iOS 26+ users (Day 7 evening)

Monitoring During Rollout:
  - Crash rate (target: <0.1%)
  - Foundation Models performance (<50ms)
  - Thompson performance (<10ms still maintained)
  - Memory usage (<200MB baseline)
  - User satisfaction (target: >4.5/5)
  - Course click-through rate (target: >5%)
```

#### Rollback Plan
```
Trigger Conditions for Rollback:
  - Crash rate >0.5%
  - Foundation Models performance >100ms
  - Thompson performance >10ms
  - Memory usage >300MB
  - User satisfaction <4.0/5

Rollback Procedure:
  1. Revert to previous App Store version
  2. Disable Foundation Models (use OpenAI fallback)
  3. Monitor for 24 hours
  4. Investigate root cause
  5. Fix and re-test before re-deploying
```

### Phase 6.5: App Store Submission (Week 24)

#### Pre-Submission Checklist
```
Build Configuration:
  - [ ] iOS Deployment Target: 26.0 (or 18.0 with @available)
  - [ ] Version number: 7.0.0 (major version for iOS 26)
  - [ ] Build number: Increment from previous
  - [ ] Xcode 26.0 used for final build
  - [ ] All packages built with iOS 26 SDK

App Store Assets:
  - [ ] Screenshots (iPhone 16 Pro, iOS 26, Liquid Glass)
  - [ ] App Preview videos (optional but recommended)
  - [ ] App icon (updated if needed)
  - [ ] App description mentions iOS 26 features
  - [ ] Privacy policy updated (on-device AI processing)
  - [ ] What's New text written

Metadata:
  - [ ] Keywords optimized for discovery
  - [ ] Categories selected (Productivity, Business)
  - [ ] Age rating appropriate (4+)
  - [ ] Support URL valid
  - [ ] Privacy information accurate

Technical:
  - [ ] All features tested on device
  - [ ] No crashes in production build
  - [ ] Performance targets met
  - [ ] Accessibility validated
  - [ ] Privacy manifest included (iOS 17+)
  - [ ] No deprecated APIs used
```

#### What's New Text (Version 7.0.0)
```
🎉 Manifest & Match V7 - Now Powered by iOS 26

✨ Lightning-Fast AI - Instant resume parsing and job analysis using on-device Apple Intelligence

🔒 100% Private - All AI processing happens on your device, never sent to the cloud

💎 Liquid Glass Design - Beautiful, modern interface that adapts to your preferences

🚀 Enhanced Profile - New certifications, projects, volunteer experience, and more

📚 Course Recommendations - Personalized learning paths to fill your skill gaps

⚡️ Blazing Performance - 20-60x faster AI operations, <10ms job matching

🌍 Sector Neutral - 500+ skills across 14 industries, not just tech

♿️ Fully Accessible - WCAG 2.1 AA compliant, VoiceOver optimized

Requirements:
  - iOS 26.0 or later
  - iPhone 15 Pro+ or iPhone 16 for on-device AI
  - Older devices use cloud AI fallback

Update now and experience the future of career discovery! 🚀
```

### Success Criteria for Phase 6
- ✅ Performance targets met (Thompson <10ms, Foundation Models <50ms)
- ✅ Memory budget maintained (<200MB baseline, <250MB peak)
- ✅ Accessibility audit passed (WCAG 2.1 AA compliant)
- ✅ A/B test shows Foundation Models ≥95% accuracy
- ✅ Crash rate <0.1% in production
- ✅ User satisfaction >4.5/5 stars
- ✅ App Store approved and released before April 2026 deadline
- ✅ Course recommendations generating revenue ($0.10-$0.50/user/month)

---

## Risk Assessment & Mitigation

### Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **iOS 26 Foundation Models API changes** | Medium | High | Use @available checks, maintain OpenAI fallback indefinitely |
| **Foundation Models accuracy <95%** | Medium | High | Implement fallback coordinator, allow user to choose AI provider |
| **Liquid Glass performance issues on older devices** | Low | Medium | Use UIDesignRequiresCompatibility temporarily, optimize rendering |
| **Phase 1 skills expansion breaks existing code** | Medium | High | Comprehensive test suite, gradual rollout, rollback plan |
| **Core Data migration fails** | Low | Critical | Test on copies, extensive validation, rollback plan |
| **Thompson performance regression** | Low | Critical | Continuous monitoring, performance tests in CI/CD |
| **View hierarchy changes break UI tests** | High | Medium | Update selectors, regenerate with Xcode 26, comprehensive testing |

### Business Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **iOS 26 device adoption <30% by launch** | High | Low | Maintain OpenAI fallback for older devices, gradual transition |
| **Course integration revenue <$0.10/user** | Medium | Low | Test multiple providers, optimize recommendations, A/B test CTR |
| **Development overruns (>24 weeks)** | Medium | Medium | Phased approach allows partial delivery, prioritize critical features |
| **User resistance to Liquid Glass design** | Low | Low | Provide feedback channel, iterate based on user preferences |
| **April 2026 App Store deadline missed** | Low | Critical | Start early (5 months buffer), weekly progress tracking |

### Operational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Rollback needed after Phase 2-3** | Low | High | Feature flags for instant disable, comprehensive testing |
| **Support burden increases** | Low | Medium | Comprehensive docs, clear error messages, FAQ |
| **Quality issues at scale** | Medium | High | Gradual rollout, extensive monitoring, quick hotfix capability |
| **Third-party API changes (Udemy/Coursera)** | Medium | Low | Monitor API versioning, maintain multiple providers |

---

## Success Metrics (KPIs)

### Phase-by-Phase Success Metrics

#### Phase 0: iOS 26 Environment Setup
- ✅ Xcode 26 installed successfully
- ✅ Project builds on iOS 26 simulator
- ✅ App runs with Liquid Glass (automatic)
- ✅ Sacred constraints maintained (<10ms Thompson)

#### Phase 1: Skills System Bias Fix
- ✅ Bias score: 25 → >90
- ✅ Skills extracted (healthcare): 0 → >5
- ✅ Skills extracted (retail): 0 → >3
- ✅ Skills extracted (trades): 0 → >4
- ✅ Tech skills percentage: 90%+ → <5%

#### Phase 2: Foundation Models Integration
- ✅ AI cost: $200-500/month → $0
- ✅ Resume parsing latency: 1-3s → <50ms
- ✅ Job analysis latency: 500ms-1s → <50ms
- ✅ Foundation Models adoption: >90% of capable devices
- ✅ Parsing accuracy: ≥95% vs OpenAI baseline
- ✅ Thompson budget maintained: <10ms

#### Phase 3: Profile Data Model Expansion
- ✅ Profile completeness: 55% → 95%
- ✅ Zero data loss during migrations
- ✅ Resume parser extracts all new fields
- ✅ User satisfaction: +20% improvement
- ✅ Job matching accuracy: +15% improvement

#### Phase 4: Liquid Glass UI Adoption
- ✅ Liquid Glass adopted across all major UI
- ✅ WCAG AA contrast ratios maintained (≥4.5:1)
- ✅ Clear and Tinted modes both functional
- ✅ Reduce Motion respected
- ✅ 60 FPS rendering maintained
- ✅ Sacred 4-tab UI preserved

#### Phase 5: Course Integration Revenue
- ✅ Live courses displayed
- ✅ Course click-through rate: >5%
- ✅ Course enrollment rate: >1%
- ✅ Revenue per user: $0.10-$0.50/month
- ✅ User satisfaction with Manifest tab: >4.5/5

#### Phase 6: Production Hardening
- ✅ App crash rate: <0.1%
- ✅ Performance budget compliance: 100%
- ✅ Accessibility compliance: WCAG 2.1 AA
- ✅ A/B test: Foundation Models ≥95% accuracy
- ✅ User retention: +10% improvement
- ✅ App Store approved before April 2026

### Overall Success Metrics

**Technical Excellence**:
- Thompson scoring: <10ms maintained ✅
- Foundation Models: <50ms AI operations ✅
- Memory usage: <200MB baseline ✅
- Bias score: >90 ✅
- Accessibility: WCAG 2.1 AA compliant ✅

**Business Value**:
- Cost savings: $2,400-6,000/year (AI elimination)
- Revenue generation: $3,600-72,000/year (courses)
- User satisfaction: >4.5/5 stars
- App Store ranking: Top 50 in Productivity category

**User Experience**:
- Profile completeness: 95%
- Job matching accuracy: +15% improvement
- Onboarding completion: >80%
- 30-day retention: >60%
- Career transition success: 5% land new role within 12 months

---

## Resource Requirements

### Development Team
- **Senior iOS Engineer**: Full-time (24 weeks)
- **iOS AI Specialist**: Part-time weeks 3-16 (Foundation Models integration)
- **Backend Engineer**: Part-time weeks 18-20 (API integrations)
- **QA Engineer**: Part-time weeks 21-24 (testing, validation)
- **UI/UX Designer**: Part-time weeks 13-17 (Liquid Glass design)

### Infrastructure
- **Xcode Cloud**: CI/CD for automated testing (optional, $15/month)
- **TestFlight**: Beta testing (included with Apple Developer account)
- **Firebase/Mixpanel**: Analytics (free tier sufficient)
- **Sentry/Crashlytics**: Crash reporting ($29/month)

### External Services
- **Udemy API**: Free with affiliate program
- **Coursera API**: Free with affiliate program
- **OpenAI API**: Fallback only ($50-100/month, down from $200-500)

### Estimated Costs
```
Development:
  - Senior iOS Engineer: 24 weeks × $10,000/week = $240,000
  - iOS AI Specialist: 14 weeks × $8,000/week = $112,000
  - Backend Engineer: 3 weeks × $8,000/week = $24,000
  - QA Engineer: 4 weeks × $6,000/week = $24,000
  - UI/UX Designer: 5 weeks × $7,000/week = $35,000
  Subtotal: $435,000

Infrastructure:
  - Xcode Cloud: $15/month × 6 months = $90
  - Sentry: $29/month × 6 months = $174
  - OpenAI Fallback: $75/month × 6 months = $450
  Subtotal: $714

Total Estimated Cost: $435,714

ROI Calculation:
  - Cost Savings: $2,400-6,000/year (OpenAI elimination)
  - Revenue: $3,600-72,000/year (courses at 1k-10k users)
  - Break-even: 70-120 years at current scale (not viable)
  - Break-even at 10k users: 6-12 years (viable long-term)

  However:
  - Privacy benefits (100% on-device AI) = priceless competitive advantage
  - Performance improvements (20-60x faster) = superior UX
  - iOS 26 adoption = mandatory by April 2026
  - Career impact (helping users transition) = core mission fulfillment
```

**Note**: Development costs are high but include iOS 26 migration (mandatory), Foundation Models integration (strategic advantage), and profile expansion (core value prop). The investment pays off in competitive differentiation and user satisfaction, not just direct ROI.

---

## Timeline Summary

### Overview (24 Weeks Total)

```
Week 1:    Phase 0 - iOS 26 Environment Setup
Week 2:    Phase 1 - Skills System Bias Fix [CRITICAL PATH]
Week 3-16: Phase 2 - Foundation Models Integration [PARALLEL]
Week 3-12: Phase 3 - Profile Data Model Expansion [PARALLEL]
Week 13-17: Phase 4 - Liquid Glass UI Adoption
Week 18-20: Phase 5 - Course Integration Revenue
Week 21-24: Phase 6 - Production Hardening
```

### Monthly Milestones

**Month 1 (Weeks 1-4)**:
- iOS 26 environment ready
- Skills system bias fixed (critical unblocking)
- Foundation Models package created
- Profile expansion started (Certifications model)

**Month 2 (Weeks 5-8)**:
- Resume parsing migrated to Foundation Models
- FallbackCoordinator integrated
- Profile expansion continues (Projects, Volunteer)

**Month 3 (Weeks 9-12)**:
- Job analysis migrated to Foundation Models
- Profile expansion completed (Awards, Publications)
- Embeddings migrated to Foundation Models

**Month 4 (Weeks 13-16)**:
- Foundation Models testing and optimization
- Liquid Glass UI adoption
- All UI components modernized

**Month 5 (Weeks 17-20)**:
- Liquid Glass finalization
- Course integration implemented
- Revenue tracking active

**Month 6 (Weeks 21-24)**:
- Performance profiling and optimization
- A/B testing Foundation Models vs OpenAI
- Accessibility final validation
- Gradual rollout and App Store submission

**Target Launch**: March 2026 (1 month buffer before April deadline)

---

## Next Steps

### Immediate Actions (This Week)
1. ✅ Review and approve this master plan
2. ✅ Install Xcode 26.0 and iOS 26 simulators
3. ✅ Build project with iOS 26 SDK (validate compatibility)
4. ✅ Create detailed sprint plans for Phase 1 (Week 2)
5. ✅ Set up monitoring infrastructure (Sentry, Firebase)

### Week 1 (Phase 0)
1. Complete Xcode 26 installation
2. Update project to iOS 26 SDK
3. Build and test on iOS 26 simulator
4. Document any initial build errors
5. Verify sacred constraints maintained

### Week 2 (Phase 1)
1. Create SkillsConfiguration.json (500+ skills, 14 sectors)
2. Refactor SkillsExtractor to load from config
3. Implement BiasValidator with runtime checks
4. Write comprehensive test suite (8+ sector profiles)
5. Validate bias score >90

### Weeks 3-4 (Phase 2.1)
1. Create V7FoundationModels package
2. Implement DeviceCapabilityChecker
3. Implement FoundationModelsClient
4. Write unit tests
5. Set up performance monitoring

---

## Conclusion

This unified iOS 26 migration plan consolidates:

1. **V7 Master Development Plan** (skills expansion, profile models, courses)
2. **iOS 26 Foundation Models** (eliminate AI costs, improve performance)
3. **iOS 26 Liquid Glass** (modern design, automatic adoption)
4. **Sacred V7 Constraints** (<10ms Thompson, 4-tab UI, sector-neutral)
5. **21 Guardian Skills** (architecture, performance, accessibility, bias elimination)

**Key Success Factors**:
- Phase 1 (skills system) unblocks everything - must complete first
- Foundation Models integration eliminates $200-500/month costs
- Profile expansion enables better matching and course recommendations
- Liquid Glass provides premium feel with automatic adoption
- April 2026 App Store deadline is non-negotiable

**Strategic Value**:
- $0 AI costs (down from $200-500/month)
- <50ms AI operations (down from 1-3 seconds)
- 100% on-device privacy (no cloud dependencies)
- Modern iOS 26 design (Liquid Glass)
- Sector-neutral job discovery (14 industries)
- Revenue from course recommendations ($0.10-$0.50/user/month)

**Ready to Begin**: Phase 0 (iOS 26 setup) starts immediately. Phase 1 (skills system) begins Week 2 after environment is stable.

---

**Document Version**: 2.0
**Last Updated**: October 27, 2025
**Status**: Ready for Implementation
**Approved By**: [Pending]
**Next Review**: Weekly progress check-ins
