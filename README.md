# Tipob - iOS SwiftUI Game

A touch-based Bop-It style game built with SwiftUI for iOS 15+.

## Features

- Pure SwiftUI implementation with no third-party dependencies
- Gesture-based gameplay (swipe up/down/left/right)
- Visual feedback with animated arrows and color-coded gestures
- Haptic feedback for game events
- Persistent high score tracking
- Configurable game parameters

## Project Structure

```
Tipob/
├── TipobApp.swift                 # Main app entry
├── Models/
│   ├── GestureType.swift          # Gesture enumeration
│   ├── GameModel.swift            # Core game logic
│   └── GameState.swift            # Game state enum
├── Views/
│   ├── ContentView.swift          # Main container
│   ├── LaunchView.swift           # Splash screen
│   ├── MenuView.swift             # Start menu
│   ├── SequenceDisplayView.swift  # Shows gesture sequence
│   ├── GamePlayView.swift         # Gameplay with swipe input
│   └── GameOverView.swift         # Game over screen
├── ViewModels/
│   └── GameViewModel.swift        # Game state management
├── Utilities/
│   ├── SwipeGestureModifier.swift # Custom swipe detection
│   ├── HapticManager.swift        # Haptic feedback
│   └── PersistenceManager.swift   # UserDefaults storage
├── Components/
│   ├── ArrowView.swift            # Arrow display component
│   └── CountdownRing.swift        # Countdown timer ring
└── Tests/
    └── TipobTests.swift           # Unit tests
```

## Configuration

### Adjusting Game Parameters

All configurable parameters are in `GameModel.swift` under the `GameConfiguration` struct:

```swift
struct GameConfiguration {
    static var perGestureTime: TimeInterval = 3.0      // Time per gesture (seconds)
    static var minSwipeDistance: CGFloat = 50.0        // Minimum swipe distance (points)
    static var minSwipeVelocity: CGFloat = 100.0       // Minimum swipe velocity (points/second)
    static var edgeBufferDistance: CGFloat = 24.0      // Edge detection buffer (points)
    static var sequenceShowDuration: TimeInterval = 0.6 // Arrow display duration
    static var sequenceGapDuration: TimeInterval = 0.2  // Gap between arrows
}
```

### Modifying Swipe Detection Thresholds

To adjust swipe sensitivity:
1. Open `GameModel.swift`
2. Modify `minSwipeDistance` for distance threshold
3. Modify `minSwipeVelocity` for speed threshold
4. Modify `edgeBufferDistance` to change edge detection zone

### Adding New Gestures

To add new gesture types:
1. Add new case to `GestureType` enum in `GestureType.swift`
2. Add corresponding symbol and color properties
3. Update `determineGesture` method in `SwipeGestureModifier.swift`
4. Add visual representation in relevant views

## Testing

The app includes testing hooks for:
- Deterministic random sequences (inject custom `RandomNumberGenerator`)
- Configurable timing parameters
- Unit tests for gesture mapping and sequence logic

Run tests with:
```bash
xcodebuild test -scheme Tipob -destination 'platform=iOS Simulator,name=iPhone 15'
```

## How to Play

1. Launch the app - see colorful splash screen
2. Tap "Start Playing" button on menu
3. Watch and memorize the arrow sequence
4. Swipe in the shown directions on the blank screen
5. Complete sequences correctly to progress
6. Game ends on wrong swipe or timeout
7. Try to beat your best streak!

## Build Requirements

- Xcode 13+
- iOS 15+ deployment target
- Swift 5.5+

## Installation

1. Open `Tipob.xcodeproj` in Xcode
2. Select your development team
3. **Set up Firebase** (see below)
4. Build and run on simulator or device

## Firebase Setup (Required)

The `GoogleService-Info.plist` file is not included in the repository for security reasons.

**To set up Firebase:**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the **out-of-pocket-c21ae** project (or create one)
3. Go to **Project Settings** (gear icon)
4. Under "Your apps", select the iOS app
5. Click **Download GoogleService-Info.plist**
6. Place the downloaded file in the `Tipob/` directory

**Important:** The `GoogleService-Info.plist` is gitignored and should never be committed to version control.