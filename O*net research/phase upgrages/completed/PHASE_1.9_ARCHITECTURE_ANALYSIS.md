# Phase 1.9 Architecture Analysis: Type Disambiguation Deep Dive

**Document Version:** 1.0
**Date:** October 30, 2025
**Status:** 🔴 CRITICAL - Type Conflict Blocking Build
**Author:** V7 Architecture Guardian + Swift Concurrency Enforcer

---

## Executive Summary

### Problem Statement
Phase 1.9 implementation of `EducationAndCertificationsStepView` fails compilation due to **EducationLevel enum type ambiguity** between V7Data and V7AIParsing packages. This document provides comprehensive analysis of:

1. **Why Skills implementation works** (primitive types)
2. **Why Education implementation fails** (enum type conflicts)
3. **Root cause of type ambiguity** (module/struct naming collision)
4. **Correct architectural solution** (primitive types in UI models)

### Key Findings

| Component | Type Used | Status | Reason |
|-----------|-----------|--------|---------|
| **Skills** | `String` (primitive) | ✅ **WORKS** | No enum conflicts possible |
| **Work Experience** | Struct fields (primitives) | ✅ **WORKS** | No enum dependencies |
| **Education** | `EducationLevel` enum | ❌ **FAILS** | Type ambiguity + missing members |
| **Certifications** | Struct fields (primitives) | ✅ **WORKS** | No enum dependencies |

### Critical Discovery
**V7Data module has a FATAL design flaw:**
- Module name: `V7Data`
- Contains struct: `V7Data`
- Result: `V7Data.EducationLevel` fails (Swift looks for struct member, not module member)

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Working Pattern: Skills Implementation](#2-working-pattern-skills-implementation)
3. [Broken Pattern: Education Implementation](#3-broken-pattern-education-implementation)
4. [Root Cause Analysis](#4-root-cause-analysis)
5. [EducationLevel Type Comparison](#5-educationlevel-type-comparison)
6. [Correct Solution: Primitive Types](#6-correct-solution-primitive-types)
7. [Implementation Plan](#7-implementation-plan)
8. [Appendix: Code Examples](#8-appendix-code-examples)

---

## 1. Architecture Overview

### 1.1 Onboarding Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    RESUME PARSING (V7AIParsing)                  │
├─────────────────────────────────────────────────────────────────┤
│  ParsedResume {                                                  │
│    skills: [String]                    ← PRIMITIVE              │
│    experience: [WorkExperience]        ← STRUCT                 │
│    education: [Education]              ← STRUCT + ENUM          │
│    certifications: [Certification]     ← STRUCT                 │
│  }                                                               │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│              ONBOARDING UI MODELS (ManifestAndMatchV7Feature)    │
├─────────────────────────────────────────────────────────────────┤
│  @State selectedSkills: Set<String>              ✅ PRIMITIVE    │
│  @State selectedExperiences: [WorkExperienceItem] ✅ STRUCT      │
│  @State selectedEducation: [EducationItem]        ❌ HAS ENUM    │
│  @State selectedCertifications: [CertificationItem] ✅ STRUCT    │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                  CORE DATA PERSISTENCE (V7Data)                  │
├─────────────────────────────────────────────────────────────────┤
│  UserProfile.skills: [String]                    ← ARRAY        │
│  WorkExperience: NSManagedObject                 ← ENTITY       │
│  Education: NSManagedObject + educationLevelValue: Int16         │
│  Certification: NSManagedObject                  ← ENTITY       │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Package Dependencies

```
V7AIParsing (Parsing Layer)
    ├── Defines: ParsedResume, Education struct, EducationLevel enum
    └── Purpose: AI-driven resume parsing

V7Data (Persistence Layer)
    ├── Defines: Education NSManagedObject, EducationLevel enum
    ├── PROBLEM: Contains "struct V7Data" (namespace collision)
    └── Purpose: Core Data persistence

ManifestAndMatchV7Feature (UI Layer)
    ├── Imports: V7Data, V7AIParsing
    └── CONFLICT: Both packages export EducationLevel
```

---

## 2. Working Pattern: Skills Implementation

### 2.1 Complete Data Flow

**File:** `SkillsReviewStepView.swift`

```swift
// ✅ STEP 1: Parse (V7AIParsing)
let parsedResume: ParsedResume?
parsedResume.skills: [String]  // Primitive type array

// ✅ STEP 2: UI State (Primitive)
@State private var selectedSkills: Set<String> = []

// ✅ STEP 3: Auto-fill (Primitive → Primitive)
private func loadInitialSkills() {
    guard let resume = parsedResume else { return }
    // Direct assignment - no type conversion needed
    selectedSkills = Set(resume.skills)
}

// ✅ STEP 4: Save to Core Data (String → String array)
private func saveSkillsToProfile() {
    guard let userProfile = UserProfile.fetchCurrent(in: context) else { return }

    // Convert Set<String> → [String]
    let skillsArray = Array(selectedSkills)

    // Save to UserProfile.skills property
    userProfile.skills = skillsArray

    try? context.save()
}
```

### 2.2 Why This Works

| Aspect | Implementation | Result |
|--------|----------------|--------|
| **Parsing Type** | `[String]` | ✅ Simple primitive |
| **UI State Type** | `Set<String>` | ✅ Simple primitive collection |
| **Conversion** | `Set → Array` | ✅ No enum conversion needed |
| **Core Data Type** | `[String]` | ✅ Direct storage |
| **Type Conflicts** | None | ✅ String is String everywhere |

**Key Success Factor:** No enums involved at any layer - only primitive String type.

---

## 3. Broken Pattern: Education Implementation

### 3.1 Current Implementation (FAILS)

**File:** `EducationAndCertificationsStepView.swift`

```swift
// ❌ STEP 1: Parse (V7AIParsing)
let parsedResume: ParsedResume?
parsedResume.education: [V7AIParsing.Education]
    ↳ .level: V7AIParsing.EducationLevel  // Enum from V7AIParsing

// ❌ STEP 2: UI State (ENUM from V7AIParsing)
private typealias CoreDataEducationLevel = V7AIParsing.EducationLevel  // PRIVATE

struct EducationItem: Identifiable {
    var educationLevel: CoreDataEducationLevel?  // ❌ PRIVATE TYPE
}

// ❌ STEP 3: Auto-fill (Enum → Enum)
private func autoFillFromParsedResume() {
    selectedEducation = resume.education.map { parsedEdu in
        EducationItem(
            educationLevel: parsedEdu.level  // V7AIParsing.EducationLevel
        )
    }
}

// ❌ STEP 4: Display (MISSING MEMBER)
if let level = education.educationLevel {
    Text(level.displayName)  // ❌ ERROR: V7AIParsing.EducationLevel has no displayName
}

// ❌ STEP 5: Picker (TYPE MISMATCH)
Picker("Education Level", selection: $education.educationLevel) {
    ForEach([CoreDataEducationLevel.highSchool, .associate, ...]) { level in
        // ❌ ERROR: Cannot convert [EducationLevel] to Binding<C>
    }
}

// ❌ STEP 6: Save to Core Data (Enum → Int16)
education.educationLevelValue = Int16(eduItem.educationLevel?.rawValue ?? 0)
```

### 3.2 Compilation Errors

**Error 1: Private Type (Line 606)**
```
error: Property must be declared fileprivate because its type uses a private type
var educationLevel: CoreDataEducationLevel?
```
**Cause:** Private typealias makes property private

---

**Error 2: Missing Member (Line 713)**
```
error: Value of type 'CoreDataEducationLevel' (aka 'EducationLevel') has no member 'displayName'
Text(level.displayName)
```
**Cause:** V7AIParsing.EducationLevel lacks displayName (only V7Data version has it)

---

**Error 3: Type Mismatch (Line 891)**
```
error: Cannot convert value of type '[EducationLevel]' to expected argument type 'Binding<C>'
ForEach([CoreDataEducationLevel.highSchool, .associate, ...]) { level in
```
**Cause:** ForEach expects data collection, not enum cases array

---

**Error 4: Binding Conversion (Line 892)**
```
error: Cannot convert value of type 'Binding<C.Element>' to expected argument type 'CoreDataEducationLevel'
```
**Cause:** Picker binding type mismatch

---

## 4. Root Cause Analysis

### 4.1 The Dual EducationLevel Problem

#### V7Data.EducationLevel (Persistence Layer)

**File:** `Packages/V7Data/Sources/V7Data/Entities/Education+CoreData.swift`
**Lines:** 264-285

```swift
/// Education level classification (1-5 scale)
public enum EducationLevel: Int, Codable, Comparable, Sendable {
    case highSchool = 1
    case associate = 2
    case bachelor = 3
    case master = 4
    case doctorate = 5

    public static func < (lhs: EducationLevel, rhs: EducationLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    /// Display name for education level
    public var displayName: String {  // ✅ HAS displayName
        switch self {
        case .highSchool: return "High School"
        case .associate: return "Associate Degree"
        case .bachelor: return "Bachelor's Degree"
        case .master: return "Master's Degree"
        case .doctorate: return "Doctorate"
        }
    }
}
```

**Purpose:** Used by Core Data Education entity for persistence and UI display

---

#### V7AIParsing.EducationLevel (Parsing Layer)

**File:** `Packages/V7AIParsing/Sources/V7AIParsing/Models/ParsedResume.swift`
**Lines:** 622-657

```swift
/// Education level classification
@available(iOS 18.0, macOS 14.0, *)
public enum EducationLevel: Int, Codable, Comparable, Sendable {
    case highSchool = 1
    case associate = 2
    case bachelor = 3
    case master = 4
    case doctorate = 5

    /// Compare education levels
    public static func < (lhs: EducationLevel, rhs: EducationLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    /// Detect education level from degree string
    public static func detect(from degree: String) -> EducationLevel? {
        // ✅ HAS detect() method
        // ❌ NO displayName property
        let lowercased = degree.lowercased()

        if lowercased.contains("ph.d") || lowercased.contains("doctorate") {
            return .doctorate
        } else if lowercased.contains("master") || lowercased.contains("m.s") {
            return .master
        }
        // ... etc
    }
}
```

**Purpose:** Used for AI parsing to detect education level from text

---

### 4.2 Type Comparison Table

| Feature | V7Data.EducationLevel | V7AIParsing.EducationLevel |
|---------|----------------------|---------------------------|
| **RawValue** | Int | Int |
| **Cases** | highSchool, associate, bachelor, master, doctorate | highSchool, associate, bachelor, master, doctorate |
| **Comparable** | ✅ Yes | ✅ Yes |
| **Sendable** | ✅ Yes | ✅ Yes |
| **displayName** | ✅ **YES** | ❌ **NO** |
| **detect(from:)** | ❌ **NO** | ✅ **YES** |
| **Purpose** | UI Display + Persistence | AI Text Parsing |
| **Layer** | Persistence Layer | Parsing Layer |

**Critical Difference:** Same structure, different capabilities for different purposes.

---

### 4.3 The V7Data Module/Struct Naming Flaw

**File:** `Packages/V7Data/Sources/V7Data/V7Data.swift`
**Lines:** 19-89

```swift
@available(iOS 17.0, *)
public struct V7Data {  // ❌ STRUCT named same as MODULE

    public static let version = "7.0.0"
    public static let identifier = "com.manifest.match.v7.data"

    // Utility methods...
}
```

**Problem Breakdown:**

```
Module Hierarchy:
V7Data (module)
├── V7Data.swift
│   └── public struct V7Data { }  ← Namespace collision
└── Education+CoreData.swift
    └── public enum EducationLevel { }  ← Module-level export

When you write: V7Data.EducationLevel
Swift resolves:   V7Data (module) → V7Data (struct) → EducationLevel (member?)
                                                            ↑
                                                          NOT FOUND
```

**Why It Fails:**
1. Swift first finds the module `V7Data`
2. Then finds the struct `V7Data` inside it
3. Looks for `EducationLevel` as a struct member (static property or nested type)
4. **Fails:** EducationLevel is at module level, not struct level

**Compiler Error:**
```
'EducationLevel' is not a member type of struct 'V7Data.V7Data'
                                                  ↑        ↑
                                               module   struct
```

---

### 4.4 Why V7AIParsing Can Be Qualified

**File:** `Packages/V7AIParsing/Package.swift`
**No internal struct named V7AIParsing**

```swift
// V7AIParsing module exports EducationLevel at module level
// No struct named V7AIParsing exists
// Therefore: V7AIParsing.EducationLevel works correctly

import V7AIParsing

let level: V7AIParsing.EducationLevel = .bachelor  // ✅ WORKS
```

**Resolution Path:**
```
V7AIParsing (module) → EducationLevel (module-level type) ✅ FOUND
```

---

## 5. EducationLevel Type Comparison

### 5.1 Structural Comparison

Both enums are **STRUCTURALLY IDENTICAL** for data storage:

```swift
// IDENTICAL rawValues and cases
case highSchool = 1
case associate = 2
case bachelor = 3
case master = 4
case doctorate = 5

// IDENTICAL conformances
: Int, Codable, Comparable, Sendable

// IDENTICAL comparison logic
public static func < (lhs: EducationLevel, rhs: EducationLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
```

### 5.2 Functional Differences

**V7Data.EducationLevel:**
- **Designed for:** UI display and Core Data persistence
- **Capabilities:** Display names for user-facing text
- **Usage:** `education.educationLevel?.displayName` → "Bachelor's Degree"

**V7AIParsing.EducationLevel:**
- **Designed for:** AI text parsing and classification
- **Capabilities:** Detect level from degree string
- **Usage:** `EducationLevel.detect(from: "MBA")` → `.master`

### 5.3 Layer Separation Rationale

**Why Two Enums Exist:**

1. **Separation of Concerns**
   - Parsing layer shouldn't depend on UI strings
   - Persistence layer shouldn't depend on AI parsing logic

2. **Independent Evolution**
   - V7AIParsing can add more detection logic without affecting V7Data
   - V7Data can change display names without affecting parsing

3. **Clean Architecture**
   - Each layer has exactly what it needs
   - No unnecessary dependencies

**Trade-off:** Type ambiguity when both are imported (current problem)

---

## 6. Correct Solution: Primitive Types

### 6.1 The "Primitive Types in UI Models" Pattern

**Principle:** UI models should use **primitive types** only, matching the Skills implementation.

### 6.2 Corrected EducationItem Structure

```swift
/// Transient UI model for education (before Core Data persistence)
struct EducationItem: Identifiable {
    let id: UUID
    var institution: String
    var degree: String?
    var fieldOfStudy: String?
    var startDate: Date?
    var endDate: Date?
    var gpa: Double
    var educationLevelValue: Int?  // ✅ PRIMITIVE TYPE (like Skills uses String)

    init(
        id: UUID = UUID(),
        institution: String = "",
        degree: String? = nil,
        fieldOfStudy: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        gpa: Double = 0.0,
        educationLevelValue: Int? = nil  // ✅ Store rawValue directly
    ) {
        self.id = id
        self.institution = institution
        self.degree = degree
        self.fieldOfStudy = fieldOfStudy
        self.startDate = startDate
        self.endDate = endDate
        self.gpa = gpa
        self.educationLevelValue = educationLevelValue
    }
}
```

### 6.3 Complete Corrected Data Flow

```swift
// ✅ STEP 1: Parse (V7AIParsing.EducationLevel)
private func autoFillFromParsedResume() {
    guard let resume = parsedResume else { return }

    // Extract rawValue immediately - convert enum to Int
    selectedEducation = resume.education.map { parsedEdu in
        EducationItem(
            institution: parsedEdu.institution,
            degree: parsedEdu.degree,
            fieldOfStudy: parsedEdu.fieldOfStudy,
            educationLevelValue: parsedEdu.level?.rawValue  // ✅ Int?
        )
    }
}

// ✅ STEP 2: Display with Helper Function
private func educationLevelDisplayName(_ value: Int?) -> String {
    guard let value = value else { return "Not specified" }

    switch value {
    case 1: return "High School"
    case 2: return "Associate Degree"
    case 3: return "Bachelor's Degree"
    case 4: return "Master's Degree"
    case 5: return "Doctorate"
    default: return "Not specified"
    }
}

// Use in UI:
Text(educationLevelDisplayName(education.educationLevelValue))

// ✅ STEP 3: Picker with Int Values
Picker("Education Level", selection: $education.educationLevelValue) {
    Text("Not specified").tag(Int?.none)
    Text("High School").tag(Int?.some(1))
    Text("Associate Degree").tag(Int?.some(2))
    Text("Bachelor's Degree").tag(Int?.some(3))
    Text("Master's Degree").tag(Int?.some(4))
    Text("Doctorate").tag(Int?.some(5))
}

// ✅ STEP 4: Save to Core Data (Int? → Int16)
education.educationLevelValue = Int16(eduItem.educationLevelValue ?? 0)
```

### 6.4 Why This Works

| Aspect | Implementation | Result |
|--------|----------------|--------|
| **UI Type** | `Int?` | ✅ Primitive, no conflicts |
| **Parsing Conversion** | `.rawValue` extraction | ✅ Simple, type-safe |
| **Display** | Local helper function | ✅ No enum dependency |
| **Picker** | Direct Int values | ✅ Type-safe binding |
| **Core Data** | `Int16()` cast | ✅ Direct conversion |
| **Type Conflicts** | None | ✅ No enums in UI layer |

---

## 7. Implementation Plan

### 7.1 Changes Required

**File:** `EducationAndCertificationsStepView.swift`

#### Change 1: Remove Typealias (Lines 36-47)
```diff
- // MARK: - Type Disambiguation
- /// [documentation about typealias]
- private typealias CoreDataEducationLevel = V7AIParsing.EducationLevel
```

#### Change 2: Update EducationItem (Line 606, 616)
```diff
  struct EducationItem: Identifiable {
      let id: UUID
      var institution: String
      var degree: String?
      var fieldOfStudy: String?
      var startDate: Date?
      var endDate: Date?
      var gpa: Double
-     var educationLevel: CoreDataEducationLevel?
+     var educationLevelValue: Int?

      init(
          id: UUID = UUID(),
          institution: String = "",
          degree: String? = nil,
          fieldOfStudy: String? = nil,
          startDate: Date? = nil,
          endDate: Date? = nil,
          gpa: Double = 0.0,
-         educationLevel: CoreDataEducationLevel? = nil
+         educationLevelValue: Int? = nil
      ) {
          self.id = id
          self.institution = institution
          self.degree = degree
          self.fieldOfStudy = fieldOfStudy
          self.startDate = startDate
          self.endDate = endDate
          self.gpa = gpa
-         self.educationLevel = educationLevel
+         self.educationLevelValue = educationLevelValue
      }
  }
```

#### Change 3: Update Auto-fill (Line 456)
```diff
  private func autoFillFromParsedResume() {
      guard let resume = parsedResume else { return }

      selectedEducation = resume.education.map { parsedEdu in
          EducationItem(
              id: UUID(),
              institution: parsedEdu.institution,
              degree: parsedEdu.degree,
              fieldOfStudy: parsedEdu.fieldOfStudy,
              startDate: parsedEdu.startDate,
              endDate: parsedEdu.endDate,
              gpa: parsedEdu.gpa ?? 0.0,
-             educationLevel: parsedEdu.level
+             educationLevelValue: parsedEdu.level?.rawValue
          )
      }
  }
```

#### Change 4: Add Display Helper (New function)
```swift
/// Convert education level Int value to display name
private func educationLevelDisplayName(_ value: Int?) -> String {
    guard let value = value else { return "Not specified" }

    switch value {
    case 1: return "High School"
    case 2: return "Associate Degree"
    case 3: return "Bachelor's Degree"
    case 4: return "Master's Degree"
    case 5: return "Doctorate"
    default: return "Not specified"
    }
}
```

#### Change 5: Update Display (Line 713)
```diff
- if let level = education.educationLevel {
-     Text(level.displayName)
+ if let levelValue = education.educationLevelValue {
+     Text(educationLevelDisplayName(levelValue))
          .font(.caption2)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Color.blue.opacity(0.1))
          .foregroundColor(.blue)
          .cornerRadius(8)
+ }
```

#### Change 6: Update Picker (Lines 887-892)
```diff
- Picker("Education Level", selection: $education.educationLevel) {
-     Text("Not specified").tag(CoreDataEducationLevel?.none)
-     ForEach([CoreDataEducationLevel.highSchool, .associate, .bachelor, .master, .doctorate], id: \.self) { level in
-         Text(level.displayName).tag(CoreDataEducationLevel?.some(level))
-     }
+ Picker("Education Level", selection: $education.educationLevelValue) {
+     Text("Not specified").tag(Int?.none)
+     Text("High School").tag(Int?.some(1))
+     Text("Associate Degree").tag(Int?.some(2))
+     Text("Bachelor's Degree").tag(Int?.some(3))
+     Text("Master's Degree").tag(Int?.some(4))
+     Text("Doctorate").tag(Int?.some(5))
  }
```

#### Change 7: Update Save Logic (Line 539)
```diff
  // Map EducationItem → V7Data.Education
  education.institution = eduItem.institution.trimmingCharacters(in: .whitespacesAndNewlines)
  education.degree = eduItem.degree?.trimmingCharacters(in: .whitespacesAndNewlines)
  education.fieldOfStudy = eduItem.fieldOfStudy?.trimmingCharacters(in: .whitespacesAndNewlines)
  education.startDate = eduItem.startDate
  education.endDate = eduItem.endDate
  education.gpa = eduItem.gpa
- education.educationLevelValue = Int16(eduItem.educationLevel?.rawValue ?? 0)
+ education.educationLevelValue = Int16(eduItem.educationLevelValue ?? 0)
```

### 7.2 Testing Checklist

- [ ] Build succeeds without errors
- [ ] Auto-fill populates education level from parsed resume
- [ ] Picker displays correct education levels
- [ ] Selected level displays correct name in card view
- [ ] Save operation creates Core Data entities with correct rawValue
- [ ] Retrieved education entities display correct level names

---

## 8. Appendix: Code Examples

### 8.1 Complete Working EducationItem

```swift
/// Transient UI model for education (before Core Data persistence)
/// ✅ Uses primitive Int? for education level (matches Skills pattern of using String)
struct EducationItem: Identifiable {
    let id: UUID
    var institution: String
    var degree: String?
    var fieldOfStudy: String?
    var startDate: Date?
    var endDate: Date?
    var gpa: Double
    var educationLevelValue: Int?  // ✅ PRIMITIVE TYPE

    init(
        id: UUID = UUID(),
        institution: String = "",
        degree: String? = nil,
        fieldOfStudy: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        gpa: Double = 0.0,
        educationLevelValue: Int? = nil
    ) {
        self.id = id
        self.institution = institution
        self.degree = degree
        self.fieldOfStudy = fieldOfStudy
        self.startDate = startDate
        self.endDate = endDate
        self.gpa = gpa
        self.educationLevelValue = educationLevelValue
    }
}
```

### 8.2 Complete Display Helper

```swift
/// Convert education level Int value to display name
/// Maps rawValue (1-5) to user-friendly strings
private func educationLevelDisplayName(_ value: Int?) -> String {
    guard let value = value else { return "Not specified" }

    switch value {
    case 1: return "High School"
    case 2: return "Associate Degree"
    case 3: return "Bachelor's Degree"
    case 4: return "Master's Degree"
    case 5: return "Doctorate"
    default: return "Not specified"
    }
}
```

### 8.3 Complete Picker Implementation

```swift
Section("Degree & Field") {
    TextField("Degree (Optional)", text: Binding(
        get: { education.degree ?? "" },
        set: { education.degree = $0.isEmpty ? nil : $0 }
    ))
    .focused($focusedField, equals: .degree)

    TextField("Field of Study (Optional)", text: Binding(
        get: { education.fieldOfStudy ?? "" },
        set: { education.fieldOfStudy = $0.isEmpty ? nil : $0 }
    ))
    .focused($focusedField, equals: .field)

    Picker("Education Level", selection: $education.educationLevelValue) {
        Text("Not specified").tag(Int?.none)
        Text("High School").tag(Int?.some(1))
        Text("Associate Degree").tag(Int?.some(2))
        Text("Bachelor's Degree").tag(Int?.some(3))
        Text("Master's Degree").tag(Int?.some(4))
        Text("Doctorate").tag(Int?.some(5))
    }
}
```

### 8.4 Complete Card Display

```swift
private struct EducationCardView: View {
    let education: EducationItem
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SacredUI.Spacing.compact) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(education.institution)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)

                    if let degree = education.degree, !degree.isEmpty {
                        Text(degree)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let field = education.fieldOfStudy, !field.isEmpty {
                        Text(field)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // ✅ Display education level using helper function
                    if let levelValue = education.educationLevelValue {
                        Text(educationLevelDisplayName(levelValue))
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }

                Spacer()
            }

            // Action buttons
            HStack {
                Button("Edit") { onEdit() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                Button("Delete") { onDelete() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.red)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(education.institution), \(education.degree ?? "degree unknown")")
    }

    /// Convert education level Int value to display name
    private func educationLevelDisplayName(_ value: Int) -> String {
        switch value {
        case 1: return "High School"
        case 2: return "Associate Degree"
        case 3: return "Bachelor's Degree"
        case 4: return "Master's Degree"
        case 5: return "Doctorate"
        default: return "Not specified"
        }
    }
}
```

---

## Conclusion

### Key Takeaways

1. **Primitive Types Win**: UI models should use primitive types (Int, String, Bool) not enums
2. **Skills Pattern**: The working Skills implementation proves this approach is correct
3. **Enum Conflicts**: Dual enum definitions + module/struct naming collision = compilation failure
4. **Correct Pattern**: Extract `.rawValue` immediately, use Int in UI, display with helper functions
5. **Type Safety**: Still maintained - Core Data validates range, UI validates selection

### Guardian Sign-Off

**v7-architecture-guardian:** ✅ Primitive types in UI models approved
**swift-concurrency-enforcer:** ✅ No data race concerns with Int
**swiftui-specialist:** ✅ Picker binding pattern correct
**core-data-specialist:** ✅ Int16 storage pattern validated
**accessibility-compliance-enforcer:** ✅ Display names maintain VoiceOver support

---

**Document Status:** Ready for implementation
**Next Action:** Apply changes to EducationAndCertificationsStepView.swift
**Estimated Time:** 30 minutes implementation + 15 minutes testing
