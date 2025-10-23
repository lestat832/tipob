# SwiftUI & MVVM Patterns Reference

**When to load this reference:**
- Working on view architecture or MVVM structure
- Implementing state management patterns
- Creating new SwiftUI views or view modifiers
- Debugging reactive state issues

**Load command:** Uncomment `@.claude/references/swiftui-patterns.md` in project CLAUDE.md

---

## MVVM Architecture Pattern

**Pattern**: Models (Data & Logic) → ViewModels (Orchestration) → Views (UI)

### Core Components Structure

**Models Layer:**
- `GameMode.swift` - Mode definitions and metadata
- `GameState.swift` - Runtime game state
- `GameModel.swift` - Memory Mode game logic
- `ClassicModeModel.swift` - Classic Mode game logic
- `GestureType.swift` - Gesture enumeration

**Views Layer:**
- `ContentView.swift` - Main coordinator and mode router
- `MenuView.swift` - Mode selection and settings
- `GamePlayView.swift` - Memory Mode gameplay UI
- `ClassicModeView.swift` - Classic Mode gameplay UI
- `GameOverView.swift` - Memory Mode completion UI
- `LaunchView.swift` - Splash screen
- `TutorialView.swift` - Onboarding experience

**ViewModels Layer:**
- `GameViewModel.swift` - Game orchestration and state management

**Utilities Layer:**
- `HapticManager.swift` - Haptic feedback coordination
- `PersistenceManager.swift` - Data persistence utilities
- `TapGestureModifier.swift` - Custom tap gesture handling
- `SwipeGestureModifier.swift` - Custom swipe gesture handling

**Components Layer:**
- `CountdownRing.swift` - Circular timer visualization
- `ArrowView.swift` - Directional indicator components

## State Management Patterns

### AppStorage Pattern (UserDefaults Wrapper)
```swift
@AppStorage("isClassicMode") private var isClassicMode = false
@AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false
```

**Best Practices:**
- Use for simple types only (Bool, Int, String)
- Scope: Mode selection, tutorial completion, settings
- Automatic persistence without manual save calls

### ObservableObject + @Published Pattern
```swift
class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var gameModel: GameModel
    @Published var classicModel: ClassicModeModel
}
```

**Pattern**: Single source of truth with computed properties for derived state

### User Preference Migration Pattern

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

**Benefits:**
- Existing users automatically upgraded without data loss
- No manual migration prompts needed
- Backward compatible with old preference keys
- Simple implementation for binary flags

## View Patterns

### Mode-Based Conditional Rendering

**Pattern**: Single boolean flag drives all mode-specific logic

```swift
if viewModel.gameState.isClassicMode {
    ClassicModeView(viewModel: viewModel)
} else {
    GamePlayView(viewModel: viewModel)
}
```

**Benefits:**
- Clean separation of mode logic
- Easy to extend with additional modes
- Single source of truth prevents state desync

**Scaling Consideration**: Can migrate to enum-based routing if >2 modes needed

### Custom View Modifiers Pattern

**Pattern**: Composable, reusable, testable gesture detection

```swift
view
    .modifier(TapGestureModifier { handleTap() })
    .modifier(SwipeGestureModifier { direction in handleSwipe(direction) })
```

**Benefits:**
- Separation of concerns (tap vs swipe)
- Reusable across multiple views
- Testable in isolation
- Composable gesture stacks

## SwiftUI Auto-Integration Patterns

### CaseIterable Power Pattern

**Discovery**: Enum-driven architecture with automatic propagation

```swift
enum GestureType: String, CaseIterable {
    case swipeUp, swipeDown, swipeLeft, swipeRight
    case tap, doubleTap
}
```

**Benefits:**
- New gestures added to enum automatically propagate to Classic/Memory modes
- Zero-config feature additions
- Gradient generation adapts automatically via enum iteration
- Extension-based color definitions maintain clean separation

**Exceptions:**
- Tutorial mode requires explicit sequence for pedagogical ordering
- Practice mode would need custom gesture subset selection logic

## State Management Best Practices

### Single Source of Truth
- One ViewModel coordinates all game state
- Views are stateless consumers
- Computed properties for derived values

### Reactivity Pattern
- @Published properties trigger UI updates automatically
- Use objectWillChange.send() for manual control when needed
- Avoid nested @Published (causes double updates)

### Persistence Strategy
- AppStorage for user preferences (boolean flags, simple values)
- ViewModel for runtime state (sequences, scores, timers)
- Never persist computed values (always derive from source)

## Code Quality Standards

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

### Documentation Philosophy
- Code comments: Explain **why**, not what
- Implementation rationale over obvious descriptions
- Session docs: Comprehensive context preservation

## Common Issues & Solutions

### Issue: Mode State Desync
**Symptom**: UI shows wrong mode after switching
**Solution**: Single source of truth pattern
```swift
// Always check: viewModel.gameState.isClassicMode
```

### Issue: Unused Variable Warning
**Symptom**: Compiler warning about unused parameter
**Solution**: Use underscore for unused closures
```swift
// Before: .onEnded { gesture in
// After: .onEnded { _ in
```

---

**Last Updated**: October 21, 2025
**Extracted From**: project_knowledge_base.md
