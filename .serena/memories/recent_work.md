# Recent Work - Tipob Project

## Latest Session Accomplishments

### Gesture Detection Fixes (Oct 30, 2025)
- **Raise/Lower Gestures:** Successfully implemented gravity-based detection that works in any phone orientation
- **Gesture Suppression:** Built GestureCoordinator system to prevent conflicts in Tutorial Mode
- **Tutorial UX:** Reduced from 2 rounds to 1 for better first-time experience

### Critical Discovery: View Architecture Impact on Gestures
**Problem Pattern:** Gestures work in some views but not others despite identical modifier calls
**Root Cause:** Modifier placement matters - apply to content layer (VStack), not container layer (ZStack)
**Lesson Learned:** When debugging gesture issues, check WHERE modifiers are applied, not just WHAT modifiers are used

### SwiftUI Patterns Learned
1. **Gesture Layer Targeting:**
   - ✅ Correct: `VStack { content }.frame(...).detectPinch()`
   - ❌ Wrong: `ZStack { background + VStack }.frame(...).detectPinch()`
   
2. **Full-Screen Touch Reception:**
   - `.frame(maxWidth: .infinity, maxHeight: .infinity)` required on gesture-detecting view
   - Ensures touches received anywhere on screen, not just over visible UI

3. **iOS 17.0 Deprecation:**
   - Old: `.onChange(of: value) { newValue in ... }`
   - New: `.onChange(of: value) { ... }` (newValue accessible via closure scope)

## Ongoing Work
- Standardizing view architecture across all game modes
- Ensuring consistent gesture detection behavior

## Project Context
- **Phase:** MVP Feature Complete - Gesture System Refinement
- **Gestures:** 13 total (4 swipes, 3 taps, 1 pinch, 1 shake, 2 tilts, 2 raise/lower)
- **Game Modes:** Tutorial, Classic, Memory, PvP
- **Architecture:** MVVM with SwiftUI
