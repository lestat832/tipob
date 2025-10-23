# Tipob Project - iOS Gesture Game

**Quick Context:** SwiftUI iOS game with 7 gestures, 3 game modes (Classic ⚡, Memory 🧠, PvP 👥), MVVM architecture

---

## Project Overview

**Tipob** is an iOS gesture-based game combining memory challenges and reflex testing.

### Current Status
- **Phase**: MVP Complete - Ready for Partner Review
- **Gestures**: 7 total (Up ↑, Down ↓, Left ←, Right →, Tap ⊙, Double Tap ◎, Long Press ⏺)
- **Game Modes**: 3 complete (Classic, Memory, PvP)
- **Platform**: iOS (SwiftUI)
- **Architecture**: MVVM

### Tech Stack
- **Language**: Swift
- **Framework**: SwiftUI
- **Pattern**: MVVM (Model-View-ViewModel)
- **State**: @Published + ObservableObject
- **Persistence**: UserDefaults / AppStorage
- **Platform**: iOS

### Game Modes
1. **Classic Mode** ⚡ - Bop-It style reflex testing with progressive speed
2. **Memory Mode** 🧠 - Simon Says sequence memorization
3. **Game vs Player vs Player** 👥 - 2-player competitive pass-and-play

---

## Key Files & Directories

### Core Implementation
- **ViewModel**: `Tipob/ViewModels/GameViewModel.swift` - Central game coordinator
- **Models**: `Tipob/Models/` - GameMode, GestureType, game logic
- **Views**: `Tipob/Views/` - SwiftUI UI screens
- **Utilities**: `Tipob/Utilities/` - HapticManager, PersistenceManager, gesture modifiers

### Documentation
- **Product Overview**: `claudedocs/PRODUCT_OVERVIEW.md` - Partner-ready documentation
- **Feature Planning**: `claudedocs/feature-scoping-document.md` - Product roadmap (v2.0)
- **Session Index**: `claudedocs/SESSION_INDEX.md` - Quick reference and session history

### Project Organization
```
Tipob/
├── Models/          (Data structures, game logic)
├── Views/           (SwiftUI UI components)
├── ViewModels/      (State orchestration)
├── Utilities/       (Helpers, gesture modifiers)
└── Components/      (Reusable UI - CountdownRing, ArrowView)
```

---

## Reference Documentation

**Load these on-demand based on your current work:**

All references are initially commented out to save tokens. Uncomment as needed:

### SwiftUI & Architecture Patterns
# @.claude/references/swiftui-patterns.md
**When to load:** Working on view architecture, MVVM structure, state management, or creating new SwiftUI views

### Gesture Implementation
# @.claude/references/gesture-implementation.md
**When to load:** Implementing gestures, debugging tap/swipe detection, working on gesture timing or haptic feedback

### Game Mode Logic
# @.claude/references/game-mode-patterns.md
**When to load:** Working on Classic/Memory/PvP mode logic, game flow, difficulty progression, or adding new modes

### UI & Animations
# @.claude/references/ui-animation-patterns.md
**When to load:** Creating animations, visual feedback, countdown timers, or working on UI components

### Data Persistence
# @.claude/references/persistence-patterns.md
**When to load:** Working on UserDefaults, high scores, user preferences, or data migration

---

## Smart Reference Loading

When you tell Claude what you're working on, appropriate references load automatically:

**Example:**
- "Working on gesture detection" → loads gesture-implementation.md
- "Adding new game mode" → loads game-mode-patterns.md + swiftui-patterns.md
- "Debugging animations" → loads ui-animation-patterns.md
- "Implementing settings" → loads persistence-patterns.md + swiftui-patterns.md

---

## Quick Context Restoration

### Latest Session Info
**File**: `claudedocs/SESSION_INDEX.md`

Contains:
- Current implementation status
- Recent work summary
- Git commit history
- Next steps priority
- How to resume guide

**Always read SESSION_INDEX.md first when resuming work**

### Recent Achievements (October 2025)
- Oct 21: Created product overview for partner collaboration
- Oct 21: Fixed slash command configuration
- Oct 20: Implemented PvP mode with fair sequence replay
- Oct 20: Added 3 touch gestures (Tap, Double Tap, Long Press)
- Oct 20: Implemented Memory Mode with sequence memorization

---

## Development Patterns

### Code Quality Standards
- ✅ Zero warnings policy
- ✅ SwiftUI best practices
- ✅ MVVM separation of concerns
- ✅ Conventional commit messages (feat:/fix:/docs:)

### Gesture System
- 7 gestures with unique color coding
- Custom view modifiers for composability
- 300ms double-tap detection window
- Gesture coexistence via `.simultaneousGesture()`

### State Management
- Single ViewModel as source of truth
- @Published for reactive updates
- AppStorage for user preferences
- Computed properties for derived state

---

## Common Tasks

### Starting New Feature
1. Read `SESSION_INDEX.md` for current context
2. Load relevant reference file(s) based on feature type
3. Check existing patterns in references
4. Implement following established conventions

### Debugging Issues
1. Check appropriate reference for known issues
2. Review session docs for similar problems
3. Verify against code quality standards
4. Test on physical device (especially gestures/haptics)

### Adding New Game Mode
1. Load `game-mode-patterns.md` reference
2. Create new model file in `Models/`
3. Create view in `Views/`
4. Update GameMode enum
5. Add persistence keys in PersistenceManager

---

## Next Steps Priority

### Immediate
- Share PRODUCT_OVERVIEW.md with partner
- Gather feedback on current implementation
- Prioritize next features based on collaboration

### Planned Features
- Sound effects and music
- Achievement system
- Additional gestures (shake, pinch, rotate)
- Difficulty level selection
- Statistics dashboard

---

## Project Conventions

### Git Commits
**Format**: `<type>: <description>`
**Types**: feat, fix, docs, refactor, test, chore

**Co-authorship**: All commits include:
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Code Comments
**Philosophy**: Explain **why**, not what
**Good**: `// Hard floor prevents impossible speeds`
**Bad**: `// Set baseTime to 1.0`

---

**Project Status**: ✅ Phase 1 Partially Complete
**Documentation**: ✅ Partner-Ready
**Next Session**: Use `/hello` to load context automatically
