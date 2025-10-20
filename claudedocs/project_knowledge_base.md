# Tipob Project Knowledge Base

**Last Updated**: January 20, 2025
**Project Status**: Active Development - Dual Game Mode Implementation Complete

## Project Overview

### Concept
**Tipob**: iOS gesture-based game combining memory challenges and reflex testing
- Dual game modes targeting different cognitive skills
- SwiftUI-native implementation
- Persistent user preferences and progress tracking

### Current Version
- **Stage**: MVP Development
- **Modes**: 2 (Memory Mode 🧠, Classic Mode ⚡)
- **Platform**: iOS (SwiftUI)
- **Status**: Ready for User Testing

## Architecture

### Design Pattern
**MVVM (Model-View-ViewModel)**
```
Models (Data & Logic) → ViewModels (Orchestration) → Views (UI)
```

### Core Components

#### Models Layer
1. **GameMode.swift**: Mode definitions and metadata
2. **GameState.swift**: Runtime game state
3. **GameModel.swift**: Memory Mode game logic
4. **ClassicModeModel.swift**: Classic Mode game logic
5. **GestureType.swift**: Gesture enumeration

#### Views Layer
1. **ContentView.swift**: Main coordinator and mode router
2. **MenuView.swift**: Mode selection and settings
3. **GamePlayView.swift**: Memory Mode gameplay UI
4. **ClassicModeView.swift**: Classic Mode gameplay UI
5. **GameOverView.swift**: Memory Mode completion UI
6. **LaunchView.swift**: Splash screen
7. **TutorialView.swift**: Onboarding experience

#### ViewModels Layer
1. **GameViewModel.swift**: Game orchestration and state management

#### Utilities Layer
1. **HapticManager.swift**: Haptic feedback coordination
2. **PersistenceManager.swift**: Data persistence utilities
3. **TapGestureModifier.swift**: Custom tap gesture handling
4. **SwipeGestureModifier.swift**: Custom swipe gesture handling

#### Components Layer
1. **CountdownRing.swift**: Circular timer visualization
2. **ArrowView.swift**: Directional indicator components

### State Management Strategy

**Persistence**: AppStorage (UserDefaults wrapper)
```swift
@AppStorage("isClassicMode") private var isClassicMode = false
@AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false
```

**Reactivity**: ObservableObject + @Published
```swift
class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var gameModel: GameModel
    @Published var classicModel: ClassicModeModel
}
```

**Pattern**: Single source of truth with computed properties for derived state

## Game Modes

### Memory Mode (🧠) - "Simon Says"
**Concept**: Memorize and repeat increasingly long gesture sequences

**Mechanics**:
- System shows sequence of gestures
- Player must repeat sequence exactly
- Sequence grows by one gesture per round
- Mistake ends game

**Implementation**:
- Model: `GameModel.swift`
- View: `GamePlayView.swift`
- Game Over: `GameOverView.swift`

**State**:
- `currentSequence`: Gesture array to remember
- `playerSequence`: User input tracking
- `currentRound`: Progress indicator

### Classic Mode (⚡) - "Bop-It Style"
**Concept**: React quickly to random gesture prompts with increasing speed

**Mechanics**:
- System shows single random gesture
- Player must perform gesture before timer expires
- Speed increases with each round
- Timeout or wrong gesture ends game

**Implementation**:
- Model: `ClassicModeModel.swift`
- View: `ClassicModeView.swift`
- Game Over: Integrated in ClassicModeView

**State**:
- `currentGesture`: Active gesture prompt
- `currentRound`: Progress/difficulty indicator
- `baseTime`: Dynamic countdown duration

**Speed Progression**:
```swift
// Linear with hard floor at 1.0 second
let baseTime = max(1.0, 3.0 - Double(currentRound) * 0.1)
```
- Round 1: 3.0s
- Round 10: 2.0s
- Round 20+: 1.0s (minimum)

## Gesture System

### Supported Gestures
```swift
enum GestureType {
    case swipeUp
    case swipeDown
    case swipeLeft
    case swipeRight
    case tap
}
```

### Implementation Pattern
**Custom View Modifiers** (composable, reusable)
- `TapGestureModifier`: Tap detection anywhere on screen
- `SwipeGestureModifier`: Directional swipe detection

**Usage**:
```swift
view
    .modifier(TapGestureModifier { handleTap() })
    .modifier(SwipeGestureModifier { direction in handleSwipe(direction) })
```

## Critical Design Patterns

### User Preference Migration
**Pattern**: Transparent backward-compatible migration via computed properties

```swift
var selectedMode: GameMode {
    get {
        if isClassicMode { .classic } else { .memorySequence }
    }
    set {
        isClassicMode = (newValue == .classic)
    }
}
```

**Benefit**: Existing users automatically upgraded without data loss

### Mode-Based Conditional Rendering
**Pattern**: Single boolean flag drives all mode-specific logic

```swift
if viewModel.gameState.isClassicMode {
    ClassicModeView(viewModel: viewModel)
} else {
    GamePlayView(viewModel: viewModel)
}
```

**Benefit**: Clean separation, easy to extend with additional modes

### Speed Calibration
**Pattern**: Linear progression with hard floor

```swift
max(1.0, baseValue - increment * rounds)
```

**Rationale**: Prevents impossible difficulty, predictable UX

## Code Quality Standards

### Compilation
- ✅ Zero warnings policy
- ✅ No unused variables/imports
- ✅ All Swift 5+ best practices

### Naming Conventions
- **Files**: PascalCase (GameViewModel.swift)
- **Types**: PascalCase (GameMode, GestureType)
- **Variables**: camelCase (isClassicMode, currentRound)
- **Functions**: camelCase with descriptive verbs (showNextClassicGesture)

### File Organization
```
Tipob/
├── Models/          (Data structures, game logic)
├── Views/           (SwiftUI UI components)
├── ViewModels/      (State orchestration)
├── Utilities/       (Helpers, managers)
└── Components/      (Reusable UI elements)
```

### Documentation Standards
- Code comments: Why, not what (implementation rationale)
- Session docs: Comprehensive context preservation
- Git commits: Conventional format (feat:/fix:/docs:)

## Development Learnings

### Session 2025-01-20 Discoveries

**1. AppStorage Migration Pattern**
- Computed properties enable transparent user data migration
- No database migrations needed for simple boolean flags
- Backward compatibility without user intervention

**2. Mode Separation Architecture**
- Separate model files prevent coupling
- Easy to add new modes without refactoring existing code
- Clear ownership of mode-specific logic

**3. Speed Progression Design**
- Hard floors prevent infinite difficulty
- Linear progression easy to understand and debug
- UX testing needed to validate difficulty curve

**4. SwiftUI Conditional Views**
- Boolean flags work well for binary mode selection
- Can scale to enums if >2 modes needed
- Single source of truth prevents state desync

## Technical Decisions Log

### Decision: Boolean vs Enum for Mode Storage
**Context**: Need to persist user's selected game mode
**Options**:
1. Boolean flag (`isClassicMode`)
2. Enum with Codable conformance

**Chosen**: Boolean flag

**Rationale**:
- Simpler migration from previous implementation
- Adequate for binary choice (2 modes)
- Direct AppStorage support without custom encoding
- Can migrate to enum later if needed

**Trade-offs**:
- Less extensible if >3 modes added
- Accepted: Binary choice sufficient for MVP

### Decision: Separate Model Files per Mode
**Context**: Classic Mode needs different logic than Memory Mode
**Options**:
1. Single GameModel with mode switching
2. Separate ClassicModeModel and GameModel

**Chosen**: Separate model files

**Rationale**:
- Separation of concerns
- Easy to maintain mode-specific logic
- Scalable for additional modes
- Clear ownership and testing boundaries

**Trade-offs**:
- More files in codebase
- Accepted: Benefits outweigh complexity

### Decision: Linear Speed Progression with Hard Floor
**Context**: Classic Mode needs increasing difficulty
**Options**:
1. Linear progression: `3.0 - rounds * 0.1`
2. Exponential progression: `3.0 * 0.9^rounds`
3. Linear with floor: `max(1.0, 3.0 - rounds * 0.1)`

**Chosen**: Linear with hard floor at 1.0s

**Rationale**:
- Predictable difficulty curve
- Prevents impossible speeds (<1.0s unreasonable)
- Easy to understand and debug
- Reaches minimum at round 20 (reasonable challenge)

**Trade-offs**:
- Eventually plateaus (rounds 20+)
- Accepted: 20 rounds is significant achievement

### Decision: Auto-Migration vs Manual Migration
**Context**: Existing users have old preference key
**Options**:
1. Manual migration prompt on first launch
2. Transparent auto-migration via computed property

**Chosen**: Transparent auto-migration

**Rationale**:
- Better UX - no user action required
- Backward compatible - old key still works
- Simple implementation - computed property pattern
- Low risk - binary flag easy to migrate

**Trade-offs**:
- No explicit migration tracking
- Accepted: Binary flag simple enough for transparent migration

## Known Patterns & Best Practices

### Haptic Feedback
**Pattern**: Centralized through HapticManager
**Usage**: Gesture confirmations, game events
**Best Practice**: Subtle feedback, not overwhelming

### Persistence
**Pattern**: AppStorage for user preferences
**Scope**: Mode selection, tutorial completion, settings
**Best Practice**: Simple types only (Bool, Int, String)

### Gesture Detection
**Pattern**: Custom view modifiers
**Benefit**: Composable, reusable, testable
**Best Practice**: Separate concerns (tap vs swipe)

### State Management
**Pattern**: Single ViewModel as source of truth
**Reactivity**: @Published properties trigger UI updates
**Best Practice**: Computed properties for derived state

## Testing Recommendations

### Manual Testing Checklist
- [ ] Memory Mode: Sequence accuracy verification
- [ ] Classic Mode: Speed progression feel
- [ ] Mode switching: State properly reset
- [ ] Tutorial: First-time user experience
- [ ] Persistence: Preferences saved across launches
- [ ] Gestures: All 5 gestures register correctly

### Performance Testing
- [ ] Gesture response latency
- [ ] UI frame rate during gameplay
- [ ] Memory usage over long sessions
- [ ] Battery impact

### Edge Cases
- [ ] Rapid mode switching
- [ ] Backgrounding during gameplay
- [ ] Very long sequences (Memory Mode)
- [ ] Very high rounds (Classic Mode)

## Future Roadmap Ideas

### High Priority
1. **High Score Persistence**: Save best scores per mode
2. **Statistics Dashboard**: Performance tracking over time
3. **Difficulty Levels**: Easy/Medium/Hard for Classic Mode

### Medium Priority
4. **Achievement System**: Milestones and rewards
5. **Sound Effects**: Audio feedback for gestures
6. **Themes**: Visual customization

### Low Priority
7. **Multiplayer**: Challenge friends
8. **Leaderboards**: Global competition
9. **Additional Modes**: New game variations

## Common Issues & Solutions

### Issue: Unused Variable Warning
**Symptom**: Compiler warning about unused `gesture` variable
**Solution**: Remove parameter if unused in closure
```swift
// Before: .onEnded { gesture in
// After: .onEnded { _ in
```

### Issue: Mode State Desync
**Symptom**: UI shows wrong mode after switching
**Solution**: Single source of truth pattern
```swift
// Always check: viewModel.gameState.isClassicMode
```

### Issue: Speed Too Fast
**Symptom**: Classic Mode unplayable at high rounds
**Solution**: Hard floor at reasonable minimum
```swift
max(1.0, baseValue - increment * rounds)
```

## Project Conventions

### Git Commit Messages
**Format**: `<type>: <description>`
**Types**: feat, fix, docs, refactor, test, chore

**Examples**:
- `feat: Add Classic Mode reflex gameplay`
- `fix: Remove unused gesture variable`
- `docs: Update session context`

### Code Comments
**Philosophy**: Explain why, not what
**Good**: `// Hard floor prevents impossible speeds`
**Bad**: `// Set baseTime to maximum of 1.0 and calculated value`

### File Creation
**Location Decisions**:
- Models → game logic and data structures
- Views → UI components
- ViewModels → orchestration
- Utilities → helpers and managers
- Components → reusable UI elements

## Session Context Links

### Recent Sessions
- [2025-01-20: Game Mode Refactoring](session_2025_01_20_context.md)
  - Memory Mode branding
  - Classic Mode implementation
  - User migration logic

### Key Documentation
- `/claudedocs/session_summary_game_mode_refactoring.md`
- `/claudedocs/session_2025_01_20_context.md`
- This file: `/claudedocs/project_knowledge_base.md`

---

**Knowledge Base Status**: Active and Maintained
**Last Major Update**: Game Mode Refactoring (2025-01-20)
**Next Review**: After user testing phase
