# Game Mode Patterns Reference

**When to load this reference:**
- Implementing new game modes
- Working on Classic, Memory, or PvP mode logic
- Debugging game flow or state transitions
- Balancing difficulty progression

**Load command:** Uncomment `@.claude/references/game-mode-patterns.md` in project CLAUDE.md

---

## Game Mode Architecture

### Mode Separation Pattern

**Pattern**: Separate model files prevent coupling, enable easy mode additions

**Structure:**
- `GameModel.swift` - Memory Mode game logic
- `ClassicModeModel.swift` - Classic Mode game logic
- Each mode owns its specific logic and state

**Benefits:**
- Clear ownership of mode-specific logic
- Easy to add new modes without refactoring existing code
- Scalable architecture for mode expansion
- Clear testing boundaries

## Memory Mode (🧠) - "Simon Says"

### Concept
Memorize and repeat increasingly long gesture sequences

### Mechanics
- System shows sequence of gestures
- Player must repeat sequence exactly
- Sequence grows by one gesture per round
- Mistake ends game

### Implementation Files
- **Model**: `GameModel.swift`
- **View**: `GamePlayView.swift`
- **Game Over**: `GameOverView.swift`

### State Management
```swift
struct GameModel {
    var currentSequence: [GestureType]  // Gesture array to remember
    var playerSequence: [GestureType]   // User input tracking
    var currentRound: Int               // Progress indicator
}
```

### Game Flow
```
Show Sequence → Wait for Memorization → Accept Input → Judge → Next Round or Game Over
```

**State Transitions:**
- `.showSequence` - Display gestures one by one
- `.awaitInput` - Player repeats sequence
- `.judge` - Validate player input
- `.gameOver` - End condition reached

## Classic Mode (⚡) - "Bop-It Style"

### Concept
React quickly to random gesture prompts with increasing speed

### Mechanics
- System shows single random gesture
- Player must perform gesture before timer expires
- Speed increases with each round
- Timeout or wrong gesture ends game

### Implementation Files
- **Model**: `ClassicModeModel.swift`
- **View**: `ClassicModeView.swift`
- **Game Over**: Integrated in ClassicModeView

### State Management
```swift
struct ClassicModeModel {
    var currentGesture: GestureType  // Active gesture prompt
    var currentRound: Int            // Progress/difficulty indicator
    var baseTime: TimeInterval       // Dynamic countdown duration
}
```

### Speed Progression System

**Pattern**: Linear progression with hard floor

```swift
let baseTime = max(1.0, 3.0 - Double(currentRound) * 0.1)
```

**Progression Table:**
- Round 1: 3.0s
- Round 10: 2.0s
- Round 20+: 1.0s (minimum)

**Design Rationale:**
- **Predictable difficulty curve** - Easy to understand and debug
- **Hard floor prevents impossible speeds** - <1.0s unreasonable for human reaction
- **Reaches minimum at round 20** - Significant achievement milestone
- **Eventually plateaus** - Accepted trade-off (20 rounds is substantial)

### Speed Calibration Pattern

**General Formula:**
```swift
max(minimumValue, baseValue - increment * rounds)
```

**Benefits:**
- Prevents impossible difficulty
- Predictable UX
- Easy to tune with constants

## Game vs Player vs Player Mode (👥)

### Concept
2-player competitive pass-and-play

### Mechanics
- Players take turns on same device
- Fair sequence replay (both players see identical gestures)
- Game ends when either player fails
- Winner determined by highest score

### Implementation Details
- **Turn Management**: Alternating player indicators
- **Fair Sequence**: State-driven sequence replay ensures identical challenges
- **Score Tracking**: Individual scores per player
- **Player Indicators**: "Player 1's Turn" / "Player 2's Turn"

### State Management
```swift
struct PvPModeModel {
    var currentPlayer: Int           // 1 or 2
    var player1Score: Int
    var player2Score: Int
    var currentSequence: [GestureType]  // Shared sequence
}
```

### Fair Sequence Replay Pattern

**Critical Design**: Both players must see exactly the same gestures for fairness

```swift
// Generate sequence once at start of turn
let sequence = generateRandomSequence()

// Player 1 attempts
processPlayerAttempt(player: 1, sequence: sequence)

// Player 2 gets SAME sequence
processPlayerAttempt(player: 2, sequence: sequence)
```

## Mode Selection Pattern

### Boolean vs Enum Trade-off

**Current Implementation**: Boolean flag for mode storage

```swift
@AppStorage("isClassicMode") private var isClassicMode = false
```

**Rationale:**
- Simpler migration from previous implementation
- Adequate for binary choice (2-3 modes)
- Direct AppStorage support without custom encoding
- Can migrate to enum later if needed

**Trade-off:**
- Less extensible if >3 modes added
- Accepted: Binary/ternary choice sufficient for current MVP

### Future Enum Pattern (for 4+ modes)

```swift
enum GameMode: String, Codable {
    case classic
    case memory
    case pvp
    case practice  // Future mode
}

@AppStorage("selectedMode") private var selectedMode: GameMode = .classic
```

## Common Patterns Across Modes

### Random Gesture Generation

```swift
func randomGesture() -> GestureType {
    GestureType.allCases.randomElement()!
}
```

**Benefits of CaseIterable:**
- Auto-updates when new gestures added to enum
- No manual array maintenance
- Single source of truth

### Game Over Conditions

**Memory Mode:**
- Wrong gesture in sequence
- Timeout during input

**Classic Mode:**
- Wrong gesture selected
- Timer expires

**PvP Mode:**
- Either player fails
- Winner = highest score

### High Score Persistence

**Pattern**: Separate UserDefaults keys per mode

```swift
// Memory Mode
@AppStorage("TipobBestStreak") private var bestStreak = 0

// Classic Mode
@AppStorage("TipobClassicBestScore") private var classicBestScore = 0

// PvP Mode
@AppStorage("TipobPvPPlayer1BestScore") private var pvpP1Best = 0
@AppStorage("TipobPvPPlayer2BestScore") private var pvpP2Best = 0
```

**Benefits:**
- Mode-specific tracking
- No score confusion between modes
- Easy to add new mode scores

## Testing Recommendations

### Mode-Specific Testing

**Memory Mode:**
- [ ] Sequence accuracy verification (all 7 gestures)
- [ ] Sequence length progression (grows by 1 each round)
- [ ] Input validation (exact sequence match required)
- [ ] Very long sequences (20+ gestures)

**Classic Mode:**
- [ ] Speed progression feel (should get noticeably harder)
- [ ] Hard floor enforcement (never below 1.0s)
- [ ] Very high rounds (20+ rounds at minimum speed)
- [ ] Timeout accuracy

**PvP Mode:**
- [ ] Fair sequence replay (both players get same gestures)
- [ ] Turn alternation (clear player indicators)
- [ ] Score tracking accuracy (separate scores)
- [ ] Winner determination (highest score wins)

### Cross-Mode Testing

- [ ] Mode switching (state properly reset between modes)
- [ ] Persistence (preferences saved across launches)
- [ ] All gestures working in all modes

## Future Roadmap Ideas

### High Priority
1. **Practice Mode**: Custom gesture subset practice
2. **High Score Persistence**: Enhanced stats per mode
3. **Statistics Dashboard**: Performance tracking over time

### Medium Priority
4. **Difficulty Levels**: Easy/Medium/Hard variants per mode
5. **Achievement System**: Mode-specific milestones
6. **Endless Mode**: No upper speed limit variant of Classic

### Low Priority
7. **Online Multiplayer**: Extended PvP with matchmaking
8. **Tournament Mode**: Competitive PvP brackets
9. **Team Competitions**: Multi-player cooperative modes

---

**Last Updated**: October 21, 2025
**Extracted From**: project_knowledge_base.md, PRODUCT_OVERVIEW.md
