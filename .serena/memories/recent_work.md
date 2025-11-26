# Recent Work - Out of Pocket (Tipob)

## November 2025 Highlights

### Raw Gesture Data Capture System (Nov 26)
- Implemented comprehensive gesture attempt logging for debugging "not_detected" failures
- `GestureAttempt` struct captures: position, distance, velocity, scale, rejection reason
- Static factory methods: `.swipe()`, `.pinch()`, `.tap()` for type-safe creation
- Auto-attaches to `GestureLogEntry` on log, included in JSON export
- Key insight: `GestureType` uses `displayName` property, not `rawValue`

### AdMob Production Integration (Nov 26)
- Configured production App ID and Interstitial Ad Unit ID
- Implemented ATT (App Tracking Transparency) permission request
- Added SKAdNetwork identifiers to Info.plist
- Ready for live testing

### Patterns Learned
- SwiftUI gesture modifiers use `#if DEBUG` for dev-only logging
- `GestureCoordinator` manages gesture suppression during state transitions
- `DevConfigManager` is the central hub for debug configuration and logging
- Gesture attempts buffer pattern: accumulate → attach → clear
