# Persistence & Data Management Patterns Reference

**When to load this reference:**
- Working on data persistence or UserDefaults
- Implementing high score tracking
- Managing user preferences or settings
- Debugging data migration or storage issues

**Load command:** Uncomment `@.claude/references/persistence-patterns.md` in project CLAUDE.md

---

## Persistence Strategy

### AppStorage Pattern (Recommended for Simple Types)

**Best Use Cases:**
- User preferences (boolean flags, simple values)
- Mode selection
- Tutorial completion status
- Settings toggles

**Example Implementation:**
```swift
@AppStorage("isClassicMode") private var isClassicMode = false
@AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false
@AppStorage("selectedGameMode") private var selectedMode: String = "Classic"
```

**Benefits:**
- Automatic persistence without manual save calls
- SwiftUI integration with automatic UI updates
- Type-safe property wrappers
- Direct UserDefaults wrapper with cleaner syntax

**Limitations:**
- Simple types only (Bool, Int, String, Double, Data)
- No complex object graphs
- Local device only (no iCloud sync built-in)

## High Score Persistence Patterns

### Per-Mode Score Tracking

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
- Mode-specific tracking prevents score confusion
- Easy to add new mode scores
- Clear naming convention (Tipob prefix prevents key collisions)
- Independent persistence per mode

**Naming Convention:**
- Prefix: `Tipob` (prevents conflicts with other apps)
- Descriptor: Mode name or feature
- Suffix: Type of data (BestScore, BestStreak, etc.)

### Score Update Pattern

```swift
func updateHighScore(newScore: Int) {
    if newScore > classicBestScore {
        classicBestScore = newScore
        // AppStorage automatically persists
        showNewRecordAnimation()
    }
}
```

**Best Practices:**
- Check if new score beats existing before updating
- Trigger celebration animations for new records
- No manual save call needed (AppStorage handles it)

## User Preference Migration Pattern

### Problem: Legacy Key Support

**Scenario**: App version 1 used different preference keys than version 2

### Solution: Computed Property Migration

**Pattern**: Transparent backward-compatible migration via computed properties

```swift
// Legacy storage
@AppStorage("isClassicMode") private var isClassicMode = false

// New computed property for cleaner API
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
- Zero user intervention required

**Trade-offs:**
- Maintains legacy key structure
- Accepted: Binary flags simple enough for this approach

**When to Use:**
- Simple boolean → enum migrations
- Backward compatibility required
- No complex data transformations needed

**When NOT to Use:**
- Complex object graph migrations
- Data structure fundamentally changes
- Need to track migration status

## PersistenceManager Pattern

### Centralized Persistence Logic

**Location**: `Tipob/Utilities/PersistenceManager.swift`

**Purpose**: Centralize UserDefaults access and provide helper methods

```swift
class PersistenceManager {
    static let shared = PersistenceManager()

    private let defaults = UserDefaults.standard

    // Keys
    private let bestStreakKey = "TipobBestStreak"
    private let classicBestScoreKey = "TipobClassicBestScore"

    // Getters
    func getBestStreak() -> Int {
        defaults.integer(forKey: bestStreakKey)
    }

    func getClassicBestScore() -> Int {
        defaults.integer(forKey: classicBestScoreKey)
    }

    // Setters
    func saveBestStreak(_ streak: Int) {
        defaults.set(streak, forKey: bestStreakKey)
    }

    func saveClassicBestScore(_ score: Int) {
        defaults.set(score, forKey: classicBestScoreKey)
    }

    // Reset
    func resetAllScores() {
        defaults.set(0, forKey: bestStreakKey)
        defaults.set(0, forKey: classicBestScoreKey)
    }
}
```

**Benefits:**
- Single source of truth for keys (prevents typos)
- Testable persistence layer
- Easy to add new persistence features
- Centralized reset functionality

**Best Practices:**
- Use singleton pattern (`shared` instance)
- Private key constants (prevents external modification)
- Type-safe methods (Int for scores, not Any)

## Data Persistence Scope

### What to Persist

**User Preferences:**
- Game mode selection
- Tutorial completion status
- Sound/haptic settings
- Difficulty preferences

**Progress Data:**
- High scores per mode
- Best streaks
- Unlocked achievements (future)

**What NOT to Persist:**

**Runtime State:**
- Current game sequence (regenerate on restart)
- Active countdown timers
- Temporary UI state

**Computed Values:**
- Derived scores
- Calculated statistics
- Formatted strings

**Rationale**: Always derive from source data, never persist computed values

## Common Persistence Patterns

### Tutorial Completion Flag

```swift
@AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false

// On tutorial completion
func completeTutorial() {
    hasCompletedTutorial = true
    // Automatically persisted, no manual save
}

// Check on app launch
if !hasCompletedTutorial {
    showTutorial()
}
```

### Settings Toggle Persistence

```swift
@AppStorage("soundEnabled") private var soundEnabled = true
@AppStorage("hapticsEnabled") private var hapticsEnabled = true

Toggle("Sound Effects", isOn: $soundEnabled)
Toggle("Haptic Feedback", isOn: $hapticsEnabled)
```

**Automatic Behavior:**
- Toggle changes immediately persist
- State restored on app relaunch
- No custom persistence code needed

### Last Selected Mode

```swift
@AppStorage("selectedGameMode") private var selectedModeRawValue: String = "Classic"

var selectedMode: GameMode {
    get {
        GameMode(rawValue: selectedModeRawValue) ?? .classic
    }
    set {
        selectedModeRawValue = newValue.rawValue
    }
}
```

**Pattern**: Store enum raw value as String for AppStorage compatibility

## Testing Persistence

### Manual Testing Checklist

- [ ] **Mode selection** - Persists across app restarts
- [ ] **High scores** - Saved correctly per mode
- [ ] **Tutorial completion** - Only shown once
- [ ] **Settings** - Sound/haptic preferences persist
- [ ] **App deletion** - Fresh install shows defaults

### Reset Testing

```swift
// For development/testing
func resetAllUserData() {
    UserDefaults.standard.removePersistentDomain(
        forName: Bundle.main.bundleIdentifier!
    )
    UserDefaults.standard.synchronize()
}
```

**Use Cases:**
- Development testing
- QA validation
- User-requested data reset

**Warning**: This deletes ALL UserDefaults data for the app

## Common Issues & Solutions

### Issue: Preferences Not Persisting

**Symptoms:**
- Settings reset on app restart
- Scores lost after closing app

**Solutions:**
1. **Check AppStorage property wrapper** - Correct key name?
2. **Verify UserDefaults.standard** - Using correct domain?
3. **Call synchronize()** - Force immediate write (rarely needed)

```swift
// Force immediate persistence (use sparingly)
UserDefaults.standard.synchronize()
```

### Issue: Migration Not Working

**Symptom**: Old users seeing default values instead of migrated data

**Solution**: Check computed property logic

```swift
// Ensure get/set properly access legacy keys
var selectedMode: GameMode {
    get {
        // Must read from actual legacy key
        if isClassicMode { .classic } else { .memorySequence }
    }
    set {
        // Must write to actual legacy key
        isClassicMode = (newValue == .classic)
    }
}
```

### Issue: Defaults Not Loading on First Launch

**Symptom**: Nil values instead of expected defaults

**Solution**: Provide default values in AppStorage declaration

```swift
// Correct: Default value provided
@AppStorage("bestScore") private var bestScore: Int = 0

// Incorrect: Optional without default
@AppStorage("bestScore") private var bestScore: Int?
```

## Future Enhancement Ideas

### Cloud Sync (iCloud + UserDefaults)

```swift
// Use NSUbiquitousKeyValueStore for iCloud sync
let iCloudStore = NSUbiquitousKeyValueStore.default

// Set
iCloudStore.set(bestScore, forKey: "TipobBestScore")
iCloudStore.synchronize()

// Get
let syncedScore = iCloudStore.longLong(forKey: "TipobBestScore")
```

**Benefits:**
- Cross-device score sync
- Automatic cloud backup
- No custom backend needed

**Considerations:**
- Requires iCloud entitlements
- Size limits (1MB total)
- Conflict resolution strategy needed

### Codable Persistence (for Complex Objects)

```swift
struct GameStatistics: Codable {
    var totalGamesPlayed: Int
    var averageScore: Double
    var gestureAccuracy: [GestureType: Double]
}

// Save
if let encoded = try? JSONEncoder().encode(stats) {
    UserDefaults.standard.set(encoded, forKey: "gameStats")
}

// Load
if let data = UserDefaults.standard.data(forKey: "gameStats"),
   let decoded = try? JSONDecoder().decode(GameStatistics.self, from: data) {
    return decoded
}
```

**Use Cases:**
- Complex statistics
- Detailed progress tracking
- Achievement systems

---

**Last Updated**: October 21, 2025
**Extracted From**: project_knowledge_base.md, implementation docs
