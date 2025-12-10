# Recent Work - Firebase Analytics & Crashlytics Integration

## December 2025
- Integrated Firebase Analytics with type-safe AnalyticsManager
- Added Crashlytics for crash reporting
- Implemented `start_game`, `replay_game`, `discreet_mode_toggled` events
- Fixed duplicate event firing with `isReplay` parameter pattern

## Key Pattern: Analytics Event Deduplication
When calling a method that already logs an event, use a boolean parameter to skip:
```swift
func startClassic(isReplay: Bool = false) {
    if !isReplay {
        AnalyticsManager.shared.logStartGame(...)
    }
    // ... rest of method
}
```

## Architecture Note
Classic/Memory modes: State in ViewModel (correct)
PvP modes: State in View (needs refactor - see FUTURE_TASKS.md)
