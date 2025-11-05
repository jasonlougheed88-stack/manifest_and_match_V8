# Week 14: FALLBACK System Implementation

**V8-Omniscient-Guardian Active** 🛡️

## Implementation Status

### ✅ Prerequisites Complete
- Week 13 Day 18-20: DeckScreen integration with BehavioralEventLog
- Swift 6 strict concurrency compilation passing
- Phase 3.5 foundation validated

### ✅ Component 1: COMPLETE
- **CareerQuestion+CoreData.swift**: Created with Sendable conformance
- **V7DataModel.xcdatamodel**: CareerQuestion entity added
- **Status**: Ready for lightweight migration

### ✅ Component 2: COMPLETE
- **AICareerProfileBuilder.swift**: iOS 26 Foundation Models service
- **Features**: Retry logic, rule-based fallback, <100ms performance target
- **Status**: Guardian-validated (@MainActor, error handling, privacy)

### ✅ Component 3: COMPLETE
- **CareerQuestionsSeed.swift**: 15 seed questions with O*NET mappings
- **Categories**: Education (3), WorkStyle (4), Interests (4), Skills (2), Values (2)
- **Status**: All questions have AI processing hints and complete O*NET metadata

### ✅ Component 4: COMPLETE
- **FallbackQuestionCard.swift**: SwiftUI card view for legacy device questions
- **FallbackQuestionCoordinator.swift**: Manages question flow and answer processing
- **DeckScreen.swift Integration**: Device capability detection, conditional card insertion (every 5 jobs)
- **Status**: Fully integrated with AICareerProfileBuilder, ready for testing

### 🎯 Week 14 Goals (FALLBACK Only - Legacy Devices)

**Target Devices**: iPhone 14 and older (no iOS 26 Foundation Models)

**Components to Create**:
1. CareerQuestion Core Data entity
2. AICareerProfileBuilder service (cloud AI fallback)
3. 15 seed questions with O*NET mappings
4. Runtime device capability check

---

## Component 1: CareerQuestion Core Data Entity

**File**: `V7Data/Sources/V7Data/Entities/CareerQuestion+CoreData.swift`

**Core Data Schema Addition** (add to V7DataModel.xcdatamodel):
```xml
<!-- CareerQuestion Entity - Phase 3.5 FALLBACK System -->
<entity name="CareerQuestion" representedClassName="CareerQuestion" syncable="YES">
    <attribute name="id" attributeType="UUID" usesScalarValueType="NO"/>
    <attribute name="text" attributeType="String"/>
    <attribute name="category" attributeType="String"/>

    <!-- O*NET mapping metadata -->
    <attribute name="onetEducationSignal" optional="YES" attributeType="Integer 16" defaultValueString="0" usesScalarValueType="YES"/>
    <attribute name="onetWorkActivitiesJSON" attributeType="String"/>
    <attribute name="onetRIASECDimensionsJSON" attributeType="String"/>

    <!-- AI processing -->
    <attribute name="aiProcessingHints" attributeType="String"/>
    <attribute name="displayOrder" attributeType="Integer 16" usesScalarValueType="YES"/>
    <attribute name="conditionalLogic" optional="YES" attributeType="String"/>

    <!-- Timestamps -->
    <attribute name="createdAt" attributeType="Date" usesScalarValueType="NO"/>
    <attribute name="updatedAt" attributeType="Date" usesScalarValueType="NO"/>

    <fetchIndex name="byDisplayOrderIndex">
        <fetchIndexElement property="displayOrder" type="Binary" order="ascending"/>
    </fetchIndex>
</entity>
```

**Swift Wrapper** (Car

eerQuestion+CoreData.swift):
- NSManagedObject subclass
- JSON decoding for arrays
- Sendable conformance for Swift 6

---

## Component 2: AICareerProfileBuilder Service

**File**: `V7Services/Sources/V7Services/AI/AICareerProfileBuilder.swift`

**Key Features**:
- @MainActor (not actor) per swift-concurrency-enforcer
- Retry logic with exponential backoff
- Rule-based fallback when AI fails
- iOS 26 Foundation Models API integration
- Performance target: <100ms per question

**Architecture**:
```
User Answer → AI Processing (3 retries) → O*NET Inference → Core Data Update
              ↓ (if fails)
              Rule-Based Fallback
```

---

## Component 3: 15 Seed Questions

**File**: `V7Data/Sources/V7Data/Seed/CareerQuestionsSeed.swift`

**Question Categories**:
1. Education (3 questions)
2. Work Style (4 questions)
3. Interests (4 questions)
4. Skills (2 questions)
5. Values (2 questions)

**O*NET Mappings**:
- Education Level (1-12 scale)
- Work Activities (41 O*NET IDs)
- RIASEC Dimensions (6 Holland Codes)

---

## Component 4: Device Capability Check

**Integration Point**: DeckScreen / ProfileCreationFlow

```swift
// Only show questions on legacy devices
if !FoundationModelsDetector.shared.isAvailable {
    showCareerQuestions = true
}
```

---

## Guardian Sign-Offs Required

- [ ] **v7-architecture-guardian**: Core Data (not SwiftData), proper package deps
- [ ] **swift-concurrency-enforcer**: @MainActor, Sendable conformance
- [ ] **ai-error-handling-enforcer**: Retry + fallback implemented
- [ ] **accessibility-compliance-enforcer**: VoiceOver labels, Dynamic Type
- [ ] **privacy-security-guardian**: No PII in logs, sanitized error messages

---

## Validation Checklist

### Core Data
- [ ] CareerQuestion entity added to model
- [ ] Lightweight migration works
- [ ] CRUD operations tested

### AICareerProfileBuilder
- [ ] Compiles without errors
- [ ] Retry logic tested (simulated failures)
- [ ] Rule-based fallback produces valid O*NET values
- [ ] Performance <100ms average

### Seed Questions
- [ ] All 15 questions seed correctly
- [ ] JSON encoding works
- [ ] O*NET mappings verified
- [ ] Display order correct (1-15)

### Integration
- [ ] Device detection works (simulator + real device)
- [ ] Questions only show on legacy devices
- [ ] Profile updates correctly
- [ ] No UI blocking

---

## Next Steps (After Week 14)

**Week 15**: AdaptiveQuestionEngine (PRIMARY system - iOS 26+ devices)
**Week 16**: Question Cards in DeckScreen
**Week 17**: ThompsonBridge behavioral insights integration
**Week 18**: ProfileBalanceAdapter
**Week 19**: Validation & performance optimization

---

**Status**: Ready for implementation
**Guardian**: v8-omniscient-guardian supervising
**Est. Time**: 8-10 hours
