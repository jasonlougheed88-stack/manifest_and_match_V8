# Step 8: Job Title Selection - Visual Design

## iPhone Screen (375 × 812 pt)

```
╔═══════════════════════════════════════════════════════════╗
║  < Back                                    Step 8 of 8    ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║                                                           ║
║    What roles interest you?                               ║
║    Select roles below or search for specific titles       ║
║                                                           ║
║                                                           ║
║   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   ║
║   ┃ 🔍 Search job titles...                          ┃   ║
║   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   ║
║                                                           ║
║   Popular Roles                                           ║
║                                                           ║
║   ┏━━━━━━━━━━━━━━━━┓  ┏━━━━━━━━━━━━━━━━┓               ║
║   ┃  💼            ┃  ┃  💼            ┃               ║
║   ┃  Software     ┃  ┃  Sales         ┃  ← Selected   ║
║   ┃  Engineer     ┃  ┃  Manager       ┃  (Blue)       ║
║   ┃               ┃  ┃               ┃               ║
║   ┗━━━━━━━━━━━━━━━━┛  ┗━━━━━━━━━━━━━━━━┛               ║
║                                                           ║
║   ┌────────────────┐  ┌────────────────┐               ║
║   │  💼            │  │  💼            │               ║
║   │  Product       │  │  Account       │  ← Unselected ║
║   │  Manager       │  │  Executive     │  (Gray)       ║
║   │                │  │                │               ║
║   └────────────────┘  └────────────────┘               ║
║                                                           ║
║   ┌────────────────┐  ┌────────────────┐               ║
║   │  🎓            │  │  ⚕️             │               ║
║   │  Teacher       │  │  Nurse         │               ║
║   │                │  │                │               ║
║   │                │  │                │               ║
║   └────────────────┘  └────────────────┘               ║
║                                                           ║
║   ┌────────────────┐  ┌────────────────┐               ║
║   │  📊            │  │  📈            │               ║
║   │  Data          │  │  Marketing     │               ║
║   │  Analyst       │  │  Manager       │               ║
║   │                │  │                │               ║
║   └────────────────┘  └────────────────┘               ║
║                                                           ║
║   ┌────────────────┐  ┌────────────────┐               ║
║   │  📋            │  │  🎯            │               ║
║   │  Project       │  │  Customer      │               ║
║   │  Manager       │  │  Success       │               ║
║   │                │  │                │               ║
║   └────────────────┘  └────────────────┘               ║
║                                                           ║
║                                                           ║
║   Your Selections (2)                                     ║
║                                                           ║
║   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                       ║
║   ┃  Software Engineer      ✕  ┃                       ║
║   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                       ║
║                                                           ║
║   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓                       ║
║   ┃  Sales Manager          ✕  ┃                       ║
║   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛                       ║
║                                                           ║
║                                                           ║
║                                                           ║
║                                                           ║
║             ┏━━━━━━━━━━━━━━━━━━━━━━━┓                    ║
║             ┃   Continue  →        ┃                    ║
║             ┗━━━━━━━━━━━━━━━━━━━━━━━┛                    ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## Design Specifications

### Header Section
```
┌─────────────────────────────────────────────┐
│  < Back                    Step 8 of 8      │  ← Navigation bar
└─────────────────────────────────────────────┘

Spacing: 20pt top padding

┌─────────────────────────────────────────────┐
│  What roles interest you?                   │  ← Title (28pt, Bold)
│  Select roles below or search for specific  │  ← Subtitle (15pt, Regular)
│  titles                                     │     Color: .secondary
└─────────────────────────────────────────────┘

Spacing: 24pt below subtitle
```

### Search Bar
```
┌─────────────────────────────────────────────┐
│  🔍 Search job titles...                    │
└─────────────────────────────────────────────┘

Height: 44pt
Corner Radius: 10pt
Background: .systemGray6 (light mode) / .systemGray5 (dark mode)
Border: none
Padding: 12pt horizontal
Font: 17pt System
Icon: SF Symbol "magnifyingglass" (18pt)

Spacing: 24pt below search
```

### Section Header
```
Popular Roles
─────────────

Font: 20pt, Semibold
Color: .primary
Spacing: 16pt below header
```

### Role Cards (Grid)

**Selected State (Blue):**
```
┏━━━━━━━━━━━━━━━━┓
┃  💼            ┃  ← Icon (32pt) centered
┃  Software      ┃  ← Text (15pt, Medium)
┃  Engineer      ┃     Centered, white color
┃                ┃
┗━━━━━━━━━━━━━━━━┛

Width: 165pt (2 columns with 15pt gap)
Height: 100pt
Background: Color.blue
Corner Radius: 12pt
Shadow: 0pt offset, 4pt blur, black 0.1 opacity
```

**Unselected State (Gray):**
```
┌────────────────┐
│  💼            │  ← Icon (32pt) centered
│  Product       │  ← Text (15pt, Medium)
│  Manager       │     Centered, .primary color
│                │
└────────────────┘

Width: 165pt
Height: 100pt
Background: Color(.systemGray6)
Corner Radius: 12pt
Border: 1pt solid Color(.systemGray4)
Shadow: none
```

**Grid Layout:**
- 2 columns
- 15pt gap between columns
- 15pt gap between rows
- 20pt horizontal padding
- Scrollable if needed

---

## When User Taps Search Bar

```
╔═══════════════════════════════════════════════════════════╗
║  < Back                                    Step 8 of 8    ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║                                                           ║
║    What roles interest you?                               ║
║    Select roles below or search for specific titles       ║
║                                                           ║
║                                                           ║
║   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   ║
║   ┃ 🔍 account ex|                                  ┃   ║  ← User typing
║   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   ║
║                                                           ║
║   ┌─────────────────────────────────────────────────┐   ║
║   │  Account Executive                     Sales    │   ║  ← Suggestion 1
║   ├─────────────────────────────────────────────────┤   ║
║   │  Accounting Manager                    Finance  │   ║  ← Suggestion 2
║   ├─────────────────────────────────────────────────┤   ║
║   │  Account Manager                       Sales    │   ║  ← Suggestion 3
║   └─────────────────────────────────────────────────┘   ║
║                                                           ║
║                                                           ║
║   Popular Roles                                           ║
║                                                           ║
║   (Grid appears below, slightly dimmed)                   ║
║                                                           ║
║   ...                                                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝

Suggestions Box:
- Background: .systemBackground (elevated)
- Border Radius: 8pt
- Shadow: 0pt offset, 8pt blur, black 0.15 opacity
- Each row: 48pt height
- Divider: 1px hairline between rows
- Tap anywhere to select
```

---

## Selected Roles Section

```
Your Selections (2)     ← Section header (17pt, Semibold)
───────────────────

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  Software Engineer      ✕  ┃  ← Chip 1
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃  Sales Manager          ✕  ┃  ← Chip 2
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

Chip Specifications:
- Height: 44pt
- Full width minus 40pt (20pt padding each side)
- Background: Color.blue
- Text: 15pt, Medium, white
- Remove button: SF Symbol "xmark.circle.fill" (20pt)
- Corner Radius: 22pt (pill shape)
- Spacing: 12pt between chips
```

---

## Continue Button

```
┏━━━━━━━━━━━━━━━━━━━━━━━┓
┃   Continue  →        ┃
┗━━━━━━━━━━━━━━━━━━━━━━━┛

Width: 200pt (centered)
Height: 50pt
Background: Color.blue
Text: 17pt, Semibold, white
Corner Radius: 25pt
Shadow: 0pt offset, 4pt blur, blue 0.3 opacity
Disabled state: .gray with 0.5 opacity (if no selections)

Position: 32pt from bottom (above safe area)
```

---

## States & Interactions

### Initial Load
```
✓ Search bar empty
✓ 10 popular roles displayed (all unselected/gray)
✓ "Your Selections" section hidden (or shows "No selections yet")
✓ Continue button disabled/gray
```

### User Taps Popular Role Card
```
1. Card background: .systemGray6 → .blue (animated 0.2s)
2. Card text color: .primary → .white (animated 0.2s)
3. Card shadow appears (animated 0.2s)
4. Haptic feedback: .light
5. Scroll to "Your Selections" section (animated)
6. New chip appears in "Your Selections" (slide in from bottom)
7. Continue button becomes enabled/blue (animated)
```

### User Taps Selected Role Card (to deselect)
```
1. Card background: .blue → .systemGray6 (animated 0.2s)
2. Card text color: .white → .primary (animated 0.2s)
3. Card shadow disappears (animated 0.2s)
4. Haptic feedback: .light
5. Chip in "Your Selections" removed (slide out, fade)
6. If no selections remain: Continue button disabled/gray
```

### User Types in Search
```
1. Keyboard appears
2. After 2 characters: Suggestions box appears (slide down 0.2s)
3. Popular roles grid slightly dimmed (opacity 0.7)
4. Suggestions update in real-time as user types
5. Tap suggestion: Same behavior as tapping popular role card
```

### User Taps X on Selection Chip
```
1. Chip scales down slightly (0.9x)
2. Chip fades out (0.2s)
3. Chip slides left and disappears
4. Corresponding role card updates (blue → gray)
5. Haptic feedback: .light
```

---

## Accessibility

### VoiceOver Labels
```
- Search bar: "Search job titles"
- Popular role cards: "Software Engineer. Button. Double tap to select"
- Selected popular role cards: "Software Engineer. Selected. Button. Double tap to deselect"
- Selection chips: "Software Engineer. Selected role. Button. Double tap to remove"
- Continue button: "Continue to deck screen. Button. Requires at least one role selection"
```

### Dynamic Type Support
```
Small (default):   15pt role text
Large:            17pt role text
Accessibility 1:  19pt role text
Accessibility 2:  21pt role text
Accessibility 3:  23pt role text
```

### Color Contrast
```
Selected card background: Blue (#007AFF)
Selected card text: White (#FFFFFF)
Contrast ratio: 4.5:1 (WCAG AA compliant)

Unselected card background: SystemGray6 (adapts to dark mode)
Unselected card text: Primary (adapts to dark mode)
Border: SystemGray4 for definition
```

---

## Comparison: Before vs After

### Before (Sectors)
```
┌─────────────────────────────────────────┐
│  Career Fields                          │
│                                         │
│  🔍 Search sectors...                   │
│                                         │
│  [Business/Management] [Finance]        │  ← Abstract
│  [Technology] [Engineering]             │  ← Confusing
│  [Science/Research] [Healthcare]        │  ← Ugly layout
│  [Education] [Legal] [Sales]            │
│  [Office/Administrative] [Food Service] │
│  [Skilled Trades] [Personal Services]   │
│  [Public Service] [Manufacturing]       │
│  [Warehouse/Logistics] [Construction]   │
│  [Other]                                │
│                                         │
└─────────────────────────────────────────┘
```

### After (Job Titles)
```
┌─────────────────────────────────────────┐
│  What roles interest you?               │
│                                         │
│  🔍 Search job titles...                │
│                                         │
│  ┏━━━━━━━━━━━┓  ┏━━━━━━━━━━━┓         │  ← Clear cards
│  ┃ Software  ┃  ┃ Sales     ┃         │  ← Concrete titles
│  ┃ Engineer  ┃  ┃ Manager   ┃         │  ← Professional
│  ┗━━━━━━━━━━━┛  ┗━━━━━━━━━━━┛         │
│                                         │
│  (8 more popular roles...)              │
│                                         │
│  Your Selections (2)                    │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━┓            │
│  ┃ Software Engineer  ✕ ┃            │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━┛            │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━┓            │
│  ┃ Sales Manager      ✕ ┃            │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━┛            │
└─────────────────────────────────────────┘
```

---

## Dark Mode

### Popular Role Cards
```
Unselected:
- Background: .systemGray5 (darker gray in dark mode)
- Border: .systemGray3 (lighter border for contrast)
- Text: .primary (white in dark mode)

Selected:
- Background: .blue (same blue in both modes)
- Text: .white (same in both modes)
- Shadow: More prominent in dark mode
```

### Search Bar
```
Light Mode:
- Background: .systemGray6 (very light gray)
- Text: .primary (black)
- Placeholder: .secondary (gray)

Dark Mode:
- Background: .systemGray5 (medium gray)
- Text: .primary (white)
- Placeholder: .secondary (light gray)
```

---

## Animation Timings

```
Card selection:        0.2s ease-in-out
Chip appearance:       0.3s spring (damping: 0.7)
Chip removal:          0.2s ease-in
Search suggestions:    0.2s ease-out
Scroll to selections:  0.4s ease-in-out
Button state change:   0.15s linear
```

---

## Final Layout Summary

**Vertical Stack:**
1. Navigation bar (44pt + safe area)
2. Title + subtitle (80pt)
3. Search bar (44pt + 24pt spacing)
4. "Popular Roles" header (28pt + 16pt spacing)
5. Role cards grid (10 cards = ~220pt)
6. "Your Selections" header (28pt + 16pt spacing)
7. Selection chips (dynamic height, 44pt each + 12pt spacing)
8. Spacer (flexible)
9. Continue button (50pt + 32pt bottom padding)

**Total estimated height:** ~620pt (scrollable on standard iPhone)
