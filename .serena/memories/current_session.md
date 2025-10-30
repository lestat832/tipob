# Session Summary - 2025-10-30

## Completed Tasks
- ✅ Fixed raise/lower gesture detection using gravity-based projection (works in any phone orientation)
- ✅ Implemented gesture suppression system for Tutorial Mode (GestureCoordinator)
- ✅ Reduced tutorial rounds from 2 to 1
- ✅ Fixed iOS 17.0 deprecation warning for `.onChange` modifier in TutorialView

## In Progress
- 🔄 **CRITICAL ISSUE:** Pinch and shake gestures work in Tutorial Mode but NOT in Classic/Memory/PvP modes
- 🔄 Root cause identified: Gesture modifiers applied to different view layers
  - TutorialView (working): Modifiers on **VStack** (content layer)
  - Other modes (broken): Modifiers on **ZStack** (container layer)

## Next Session - PRIORITY FIX
**Move gesture modifiers from ZStack to VStack in all game mode views:**

1. **ClassicModeView.swift** (line 58-79)
   - Move `.frame(maxWidth: .infinity, maxHeight: .infinity)` from ZStack to VStack
   - Move ALL gesture modifiers from ZStack to VStack

2. **GamePlayView.swift** (line 49-69)
   - Same restructuring as ClassicModeView

3. **PlayerVsPlayerView.swift** (line 85-105)
   - Move modifiers from ZStack to Group container

4. **GameVsPlayerVsPlayerView.swift** (line 252-270)
   - Move modifiers to inner VStack

**Target Architecture (match TutorialView):**
```swift
ZStack {
    Background
    Flash overlay
    VStack {
        content
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .detectSwipes { ... }
    .detectPinch { ... }
    .detectShake { ... }
    // ... all other gesture modifiers
}
```

## Key Decisions
- **Raise/Lower Detection:** Switched from device-relative `userAcceleration.y` to gravity-projected acceleration using dot product formula
- **Gesture Suppression:** Tutorial Mode only (real game modes need all gesture detection active)
- **Tutorial Length:** Reduced to 1 round (13 gestures total) for better UX
- **Pinch Implementation:** Reverted to original `.background()` approach (overlay approach blocked swipes)

## Blockers/Issues
- **BLOCKER:** Pinch and shake gestures not working in Classic/Memory/PvP modes
- **Root Cause:** Architectural inconsistency - gesture modifiers applied to wrong view layer
- **Impact:** Users cannot complete pinch/shake gestures in actual game modes
- **Status:** Solution identified, ready to implement next session

## Files Modified (Uncommitted)
1. `RaiseGestureManager.swift` - Gravity-based detection
2. `GestureCoordinator.swift` - NEW FILE for gesture suppression
3. `TutorialView.swift` - Rounds reduced, `.onChange` fixed, suppression wiring
4. `TiltGestureManager.swift` - Coordinator check added
5. `ShakeGestureManager.swift` - Coordinator check added
6. `SwipeGestureModifier.swift` - Coordinator check added
7. `TapGestureModifier.swift` - Coordinator checks added
8. `PinchGestureView.swift` - Reverted to original `.background()` implementation
9. `ClassicModeView.swift` - Added `.frame()` to ZStack (WRONG - needs to be on VStack)
10. `GamePlayView.swift` - Added `.frame()` to ZStack (WRONG - needs to be on VStack)
11. `PlayerVsPlayerView.swift` - Added `.frame()` to ZStack (WRONG - needs to be on container)
12. `GameVsPlayerVsPlayerView.swift` - Added `.frame()` (WRONG - needs repositioning)

## Technical Insights
- **Gravity Projection Math:** `accelAlongGravity = (ax·gx + ay·gy + az·gz) / |gravity|`
- **SwiftUI Gesture Layer:** Gesture modifiers must be on interactive content layer, not container layer
- **Frame Modifier Impact:** `.frame(maxWidth: .infinity, maxHeight: .infinity)` required for full-screen touch reception
- **View Layer Hierarchy:** ZStack children can block gesture detection on parent modifiers
