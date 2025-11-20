# Out of Pocket Feature Scoping Document
**Date**: October 10, 2025 (Updated: November 20, 2025)
**Project**: Out of Pocket - iOS SwiftUI Bop-It Style Game
**Purpose**: Comprehensive feature planning and decision framework
**Status**: Phase 1 Complete with 14 Gestures + Performance Optimization + Monetization (TEST) + Audio System

---

## 📋 Table of Contents
1. [Gesture Expansion Options](#gesture-expansion-options)
2. [Audio System](#audio-system)
3. [Feature Roadmap](#feature-roadmap)
4. [Monetization Strategy](#monetization-strategy)
5. [Implementation Complexity Matrix](#implementation-complexity-matrix)
6. [Revenue Projections](#revenue-projections)
7. [Technical Requirements](#technical-requirements)
8. [Risk Assessment](#risk-assessment)
9. [Decision Framework](#decision-framework)

---

## 🎮 Gesture Expansion Options

### Currently Implemented ✅
| Gesture | Detection Method | Added | Status |
|---------|-----------------|-------|--------|
| Swipe Up ↑ | DragGesture + angle calculation | Original | ✅ Live |
| Swipe Down ↓ | DragGesture + angle calculation | Original | ✅ Live |
| Swipe Left ← | DragGesture + angle calculation | Original | ✅ Live |
| Swipe Right → | DragGesture + angle calculation | Original | ✅ Live |
| **Single Tap ⊙** | TapGesture (300ms window) | 2025-10-20 | ✅ Live |
| **Double Tap ◎** | TapGesture + DispatchWorkItem | 2025-10-20 | ✅ Live |
| **Long Press ⏺** | LongPressGesture (600ms) | 2025-10-20 | ✅ Live |
| **Pinch 🤏** | Native UIPinchGestureRecognizer | 2025-10-27 | ✅ Live |
| **Shake 📳** | CoreMotion accelerometer (2.0G) | 2025-10-28 | ✅ Live |
| **Tilt Left ◀** | CoreMotion roll detection (~25°) | 2025-10-28 | ✅ Live |
| **Tilt Right ▶** | CoreMotion roll detection (~25°) | 2025-10-28 | ✅ Live |
| **Raise ⬆️** | CoreMotion gravity projection (0.3G) | 2025-10-29 | ✅ Live |
| **Lower ⬇️** | CoreMotion gravity projection (0.3G) | 2025-10-29 | ✅ Live |
| **Stroop 🎨** | Color-word mismatch + swipe | 2025-10-31 | ✅ Live |

**Total Gestures**: 14 (4 swipes + 3 touch + 6 motion + 1 cognitive)
**Disabled**: Spread (detection issues with finger positioning)

---

## 🎮 Motion Gesture System (Implemented)

### MotionGestureManager - Centralized Detection
**Status**: ✅ Complete (November 4, 2025)  
**Architecture**: Singleton pattern, prevents CMMotionManager conflicts  
**File**: `Tipob/Utilities/MotionGestureManager.swift` (~650 lines)

**Motion Gestures Implemented:**

#### Shake Detection 📳
- Threshold: 2.0G (optimized from 2.5G)
- Update rate: 50 Hz (optimized from 10 Hz - 5x faster)
- Cooldown: 500ms
- Method: Magnitude-based acceleration detection

#### Tilt Detection ◀▶
- Threshold: 0.44 rad (~25°) (optimized from 0.52 rad)
- Directions: Left and Right
- Update rate: 60 Hz (optimized from 20 Hz - 3x faster)
- Sustained duration: 300ms
- Cooldown: 500ms

#### Raise/Lower Detection ⬆️⬇️
- Threshold: 0.3G (optimized from 0.4G)
- Update rate: 60 Hz (optimized from 30 Hz - 2x faster)
- Spike threshold: 0.8G (immediate detection)
- Sustained duration: 100ms
- Method: Gravity axis projection

#### Pinch Detection 🤏
- Implementation: Native UIPinchGestureRecognizer (UIViewRepresentable)
- Threshold: 0.85 (15% reduction) (optimized from 0.8)
- File: `PinchGestureView.swift`

---

## 🧠 Stroop Cognitive Gesture (Implemented October 31, 2025)

### How Stroop Mode Works
**Status**: ✅ Complete and integrated into all 4 game modes  
**Probability**: 1/14 chance per gesture prompt (equal to other gestures)

**Mechanism:**
1. Display color word (RED, BLUE, GREEN, YELLOW) in mismatched text color
2. Show 4 directional color labels (↑ Blue, ↓ Green, ← Red, → Yellow)
3. Player must swipe in direction matching the **TEXT color** (not word name)
4. Tests cognitive flexibility and inhibition control

**Example**: Word "RED" shown in BLUE text → Player must swipe UP (Blue direction)

**Implementation:**
- ColorType enum: 4 colors (red, blue, green, yellow)
- StroopPromptView.swift (~350 lines)
- Random color-to-direction mapping each instance
- Integrated gesture detection via SwipeGestureModifier

**File**: `Tipob/Models/ColorType.swift`, `Tipob/Components/StroopPromptView.swift`

---

## 🎭 Discreet Mode (Implemented November 3, 2025)

### Purpose
Toggle between **touch-only** vs. **full gesture set** for different social contexts

**Status**: ✅ Complete with menu toggle and persistence

### Two Gesture Sets

#### Discreet Mode (9 gestures) - Public-friendly
- 4 Swipes (Up, Down, Left, Right)
- 3 Taps (Tap, Double Tap, Long Press)
- 1 Pinch
- 1 Stroop

#### Unhinged Mode (14 gestures) - Full experience
All gestures including:
- Shake 📳 (requires vigorous motion)
- Tilt ◀▶ (requires device tilting)
- Raise ⬆️ / Lower ⬇️ (requires arm movement)

### Implementation
- **File**: `GesturePoolManager.swift` (~90 lines)
- **UI**: Menu toggle with info icon (ℹ️) explanation
- **Persistence**: UserDefaults (key: "isDiscreetModeEnabled")
- **Integration**: Respected across all 4 game modes
- **Tutorial**: Discreet toggle hidden in Tutorial mode

**User Control**: Toggle anytime via menu, takes effect next game

---

## 🏆 Leaderboard System (Implemented November 4, 2025)

### Features
**Status**: ✅ Complete MVP with per-mode tracking

- **Top 100 Entries**: Per game mode (Classic, Memory, PvP modes)
- **Persistence**: JSON file storage in Documents directory
- **Display**: Segmented control to switch between modes
- **New Records**: "NEW HIGH SCORE!" banner on achievement
- **Integration**: Accessible from menu via trophy button

### Implementation
- **File**: `LeaderboardManager.swift` (~260 lines)
- **Model**: `LeaderboardEntry.swift` (codable struct)
- **View**: `LeaderboardView.swift` with SwiftUI
- **Keys**: Separate UserDefaults keys per mode

**Menu Integration**: Trophy button in menu (top-right corner)

---

## 🔊 Audio System (Implemented November 18-20, 2025)

### Features
**Status**: ✅ Complete - Simplified architecture for reliability

- **Success Tick**: Short 45-70ms tick for correct gestures
- **Round Complete Chime**: 180-300ms celebration sound
- **Failure Sound**: SystemSoundID 1073 (clean, no interference)
- **Silent Mode**: Respects device silent switch
- **User Toggle**: Sound on/off setting with UserDefaults persistence

### Implementation
**File**: `AudioManager.swift` (~150 lines)

**Architecture (Simplified from original 419 lines):**
- AVAudioPlayer for success/round sounds (preloaded)
- Direct SystemSoundID for failure (no AVAudioEngine interference)
- AVAudioSession: `.ambient` category, `.mixWithOthers` option
- Lazy initialization pattern (prevents launch hang)

**Audio Session Configuration:**
- Category: `.ambient` (doesn't interrupt other apps)
- Options: `.mixWithOthers` (allows Spotify, podcasts, etc.)
- Respects silent mode automatically

**Sound Files (CAF format):**
- `gesture_success_tick.caf` - Volume: 0.35
- `round_complete_chime.caf` - Volume: 0.65

**Key Design Decision:**
Removed AVAudioEngine due to:
- Complex scheduling issues with countdown sounds
- Interference with SystemSoundID playback
- Launch blocking from synchronous initialization

**Integration Points:**
- `GameViewModel` calls `playSuccess()` on correct gesture
- `GameViewModel` calls `playRoundComplete()` on sequence completion
- `FailureFeedbackManager` calls `playFailure()` for unified failure feedback
- `ContentView` calls `AudioManager.shared.initialize()` after launch animation

---

### Tier 1: High Priority - Easy Implementation 🟢

#### Touch-Based Gestures
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Single Tap** | `.onTapGesture()` | Very Low | High | Excellent | P0 |
| **Double Tap** | `.onTapGesture(count: 2)` | Very Low | High | Good | P0 |
| **Long Press** | `.onLongPressGesture()` | Very Low | Medium | Excellent | P1 |
| **Two-Finger Swipe** | DragGesture with touch count | Low | Medium | Poor | P2 |

**Recommendation**: Implement all Tier 1 gestures in Phase 1
**Estimated Effort**: 2-4 hours total
**Risk**: Very Low

**Implementation Notes**:
```swift
// Single Tap Example
.onTapGesture {
    viewModel.handleGesture(.tap)
}

// Double Tap Example
.onTapGesture(count: 2) {
    viewModel.handleGesture(.doubleTap)
}

// Long Press Example
.onLongPressGesture(minimumDuration: 0.5) {
    viewModel.handleGesture(.longPress)
}
```

---

### Planned Gesture Roadmap 🎯

The following gestures have been evaluated and prioritized for future implementation:

#### Tier 1: High-Priority Multi-Touch Gestures 🟢
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Spread 🫱🫲** | Native UIPinchGestureRecognizer (inverse) | Low | High | Poor | P1 |
| **Rotate 🔄** | Native UIRotationGestureRecognizer | Low | High | Poor | P1 |

**Implementation Notes:**
- Use native UIKit gesture recognizers (proven reliable, following pinch implementation success)
- Spread: Same recognizer as pinch, detect `scale > 1.1`
- Rotate: `UIRotationGestureRecognizer`, detect angle change > 30°

#### Tier 2: Medium-Priority Motion Gestures 🟡
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Shake 📳** | CMMotionManager + acceleration threshold | Medium | Very High | Poor | P1 |
| **Tilt Left ↺** | CMMotionManager + device orientation | Medium | High | Poor | P2 |
| **Tilt Right ↻** | CMMotionManager + device orientation | Medium | High | Poor | P2 |
| **Flip 🔁** | CMMotionManager + gravity vector | Medium | Medium | Very Poor | P3 |
| **Raise ⬆️** | CMMotionManager + altitude change | High | Low | Very Poor | P4 |
| **Lower ⬇️** | CMMotionManager + altitude change | High | Low | Very Poor | P4 |
| **Freeze 🧊** | CMMotionManager + stillness detection | Medium | Medium | Poor | P3 |

**Recommendation**: Start with Shake only (most engaging, iconic Bop-It gesture)
**Estimated Effort**: 4-8 hours (includes CMMotionManager setup)
**Risk**: Medium (battery drain, device drop concerns)

**Implementation Notes**:
```swift
// Shake Detection
import CoreMotion

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let shakeThreshold = 2.5

    func startMonitoring(onShake: @escaping () -> Void) {
        guard motionManager.isAccelerometerAvailable else { return }

        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let acceleration = data?.acceleration else { return }

            let magnitude = sqrt(
                pow(acceleration.x, 2) +
                pow(acceleration.y, 2) +
                pow(acceleration.z, 2)
            )

            if magnitude > self.shakeThreshold {
                onShake()
            }
        }
    }
}
```

**Privacy Consideration**: Motion data requires `NSMotionUsageDescription` in Info.plist

---

### Tier 3: Advanced - Cognitive & Audio Gestures 🔴

#### Cognitive & Sensory Gestures 🎨🎤💨
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Blow 💨** | AVAudioRecorder + frequency analysis | High | High | Poor | P3 |
| **Whistle 🎵** | AVAudioRecorder + pitch detection | High | Medium | Poor | P3 |
| **Voice Commands 🎤** | Speech recognition framework | Medium | High | Excellent | P2 |
| **Color Recognition 🎨** | AVCaptureSession + color detection | High | Medium | Poor | P4 |
| **Cover Camera 📷** | AVCaptureSession + brightness detection | Medium | Low | Poor | P5 |

**Recommendation**:
- Voice commands for accessibility (P2)
- Blow/whistle as novelty features for later (P3)
- Color recognition experimental (P4)

**Estimated Effort**: 6-16 hours each
**Risk**: Medium (permissions, false positives, device compatibility)

#### Pattern Recognition (Deferred)
| Gesture | Implementation | Complexity | Priority |
|---------|---------------|------------|----------|
| **Draw Circle** | Vision + ML | Very High | P5 |
| **Draw Square** | Vision + ML | Very High | P5 |
| **Draw Triangle** | Vision + ML | Very High | P5 |

**Recommendation**: Defer indefinitely - too complex, low engagement/effort ratio

---

### Tier 4: Creative/Experimental 🎨

| Gesture | Implementation | Complexity | Engagement | Notes |
|---------|---------------|------------|------------|-------|
| **Swipe from Edge** | UIScreenEdgePanGestureRecognizer | Low | Medium | iOS native feel |
| **Triple Tap** | `.onTapGesture(count: 3)` | Very Low | Low | May be too fast |
| **Hold + Swipe Combo** | Simultaneous gesture detection | High | High | Advanced difficulty |
| **Pressure Touch** | Force touch (older devices only) | Low | Low | Limited device support |

**Recommendation**: Swipe from edge for premium feel, hold+swipe for advanced mode
**Priority**: P3 (post-launch enhancements)

---

### 🚫 Gestures NOT Recommended

| Gesture | Reason | Alternative |
|---------|--------|-------------|
| **Spin** | Unreliable detection, user confusion | Use rotate instead |
| **Physical device flip** | High drop risk, safety concern | Use tilt instead |
| **Screenshot gesture** | System conflict, confusing UX | Skip entirely |
| **Raise/Lower device** | Poor accuracy, awkward posture | Use tilt instead |

---

## 🎯 Feature Roadmap

### Phase 0: Foundation (Current State)
**Status**: ✅ Complete
**Features**:
- 4 directional swipes
- Basic game loop (sequence generation, validation, scoring)
- State machine (launch → menu → game → game over)
- Haptic feedback (success, error, impact)
- Persistence (best streak via UserDefaults)
- Visual feedback (countdown ring, progress dots, flash effects)

---

### Phase 1: MVP+ (Core Expansion)
**Timeline**: 2-3 weeks
**Goal**: Increase engagement and replayability
**Priority**: 🔴 Critical Path

---

## ⚡ Gesture Detection Optimization (Implemented November 9, 2025)

### Option 1: Quick Wins ✅ COMPLETE
**Goal**: Eliminate latency and improve detection accuracy for MVP  
**Status**: Shipped (commit c4642d3)  
**Expected Impact**: 20-30% faster gesture response

#### Changes Implemented

**Architecture Cleanup:**
- Deleted 6 old conflicting gesture managers (~400 lines removed)
- Centralized all motion detection to MotionGestureManager
- Eliminated CMMotionManager conflicts

**Sensor Update Rate Increases:**
| Gesture | Old Rate | New Rate | Improvement |
|---------|----------|----------|-------------|
| Shake | 10 Hz (0.1s) | 50 Hz (0.02s) | 5x faster |
| Tilt | 20 Hz (0.05s) | 60 Hz (0.016s) | 3x faster |
| Raise/Lower | 30 Hz (1/30s) | 60 Hz (1/60s) | 2x faster |

**Detection Threshold Relaxation:**
| Gesture | Old Threshold | New Threshold | Change |
|---------|---------------|---------------|--------|
| Shake | 2.5G | 2.0G | 20% more sensitive |
| Tilt | 0.52 rad (~30°) | 0.44 rad (~25°) | 17% easier angle |
| Raise/Lower | 0.4G | 0.3G | 25% more sensitive |
| Swipe velocity | 100 px/s | 80 px/s | 20% more forgiving |
| Pinch | 0.08 (8% reduction) | 0.06 (6% reduction) | 25% easier |

**Files Modified**: 7 files (MotionGestureManager, GameModel, PinchGestureView, TutorialView, GameViewModel, PlayerVsPlayerView, GameVsPlayerVsPlayerView)

---

### Option 2: Architecture Improvements 📋 PLANNED
**Goal**: Further performance gains through async processing  
**Estimated Effort**: 8-10 hours  
**Expected Impact**: 70-80% improvement over baseline

#### Proposed Changes
1. **Background Queue Processing**
   - Move sensor processing off main thread
   - Dedicated DispatchQueue for motion calculations
   - Reduce main thread blocking

2. **CADisplayLink Integration**
   - Replace Timer with CADisplayLink for countdown
   - 60 Hz precision (vs. 10-20 Hz with Timer)
   - Smoother visual updates

3. **Animation Consolidation**
   - Batch animation updates
   - Reduce withAnimation() calls
   - Minimize view re-renders

**When to Implement**: Post-MVP if broader user testing reveals remaining latency issues

---

### Option 3: Diagnostic Framework & Dev Panel 🎛️ P0 - CRITICAL
**Goal**: Comprehensive tuning and debugging infrastructure
**Estimated Effort**: 30-40 hours (expanded from 20+ based on expert feedback)
**Expected Impact**: Enables hundreds of small refinements through data-driven optimization
**Priority**: **P0 (Must-Have before v2.0)** - Expert feedback validates this as essential

> **Expert Validation**: "With WELDER we had a whole dev panel in the app to quickly tweak parameters between plays. Games like this live and die by tuning."

#### ScholarTrail Gesture Debug Panel (DEBUG ONLY)

**Access**: 3-finger triple-tap gesture
**Scope**: Wrapped in `#if DEBUG` - not included in production builds

---

##### Current Capabilities (Implemented)

**1. Gesture Log**
- Expected vs detected gesture comparison
- Timestamps for each attempt
- Color-coded success/failure indicators
- Session history tracking

**2. Sequence Replay**
- Replays last Memory/Classic mode sequences
- Useful for reproducing issues

**3. Threshold Tuning**
- 20 gesture thresholds adjustable via sliders:
  - Shake (G-force, cooldown, update rate)
  - Tilt (angle threshold, sustained duration)
  - Raise/Lower (G threshold, spike detection)
  - Swipe (distance, velocity, angle tolerance)
  - Tap (detection window, double-tap timing)
  - Pinch (scale threshold, minimum change)
  - Timing (per-gesture time, countdown durations)

**4. Action Buttons**
- **Apply & Play Again**: Apply current thresholds and restart game
- **Export Settings**: Export all thresholds as JSON
- **Reset to Defaults**: Restore factory thresholds

---

##### New Capabilities (Implement Now)

**1. Selectable Gesture Issues**

Each `GestureLogEntry` includes:
```swift
struct GestureLogEntry: Identifiable {
    let id: UUID
    let timestamp: Date
    let expected: GestureType
    let detected: GestureType?
    var isSelected: Bool
    let issueType: IssueType  // .notDetected, .wrongDetection, .success
    let sensorSnapshot: SensorData
    let thresholdsSnapshot: ThresholdSnapshot
    let timing: GestureTiming
    let deviceContext: DeviceContext
}
```

**Row Colors:**
- 🔴 Red = `.notDetected` (gesture not recognized)
- 🟠 Orange = `.wrongDetection` (wrong gesture detected)
- 🟢 Green = `.success` (correct detection)

**Filters:**
- All | Only Failures | Only Selected | Filter by gesture type

**Selection Helpers:**
- Select All Failures
- Clear Selection
- Invert Selection

**Badge**: "X issues selected" indicator

---

**2. Sensor Snapshot System**

**Circular Buffer Storage:**
- Last 500ms of sensor data continuously captured:
  - Accelerometer (x, y, z)
  - Gyroscope (rotation rates)
  - DeviceMotion (attitude, gravity, user acceleration)
  - Touch events (location, force, phase)

**Snapshot Capture:**
On gesture attempt completion → capture 500ms before + 500ms after

**Data Structures:**
```swift
struct SensorData {
    let accelerometer: [(timestamp: TimeInterval, x: Double, y: Double, z: Double)]
    let gyroscope: [(timestamp: TimeInterval, x: Double, y: Double, z: Double)]
    let deviceMotion: [(timestamp: TimeInterval, attitude: CMAttitude, gravity: CMAcceleration)]
    let touches: [(timestamp: TimeInterval, location: CGPoint, force: CGFloat, phase: UITouch.Phase)]
}

struct ThresholdSnapshot {
    // All 20 threshold values at time of gesture
}

struct GestureTiming {
    let latency: TimeInterval        // Detection delay
    let duration: TimeInterval       // Gesture duration
    let interTapDelays: [TimeInterval]?  // For double tap
}

struct DeviceContext {
    let model: String      // "iPhone 14 Pro"
    let osVersion: String  // "iOS 17.2"
    let timestamp: Date
}
```

---

**3. Export Selected Issues**

**New Button**: "Export Selected Issues"

**Output JSON Structure:**
```json
{
    "session": {
        "id": "UUID",
        "timestamp": "ISO8601",
        "appVersion": "3.2",
        "deviceModel": "iPhone 14 Pro",
        "osVersion": "iOS 17.2"
    },
    "selectedIssues": [
        {
            "expected": "swipeUp",
            "detected": "tiltLeft",
            "issueType": "wrongDetection",
            "thresholdsSnapshot": { ... },
            "sensorData": { ... },
            "timing": {
                "latency": 0.045,
                "duration": 0.320
            },
            "deviceContext": { ... }
        }
    ]
}
```

**Optional XCTest Generation:**
```swift
func testGesture_SessionXYZ_Issue1() {
    // Auto-generated test case from exported issue
    let expectedGesture = GestureType.swipeUp
    let sensorData = loadSensorData("session_xyz_issue1.json")
    // Replay sensor data through recognizer
    // Assert expected detection
}
```

**4. Maintain Existing "Export Settings"**
- Current threshold export functionality preserved
- Separate from issue export

---

##### Future Capabilities (Do Not Implement Yet)

1. **Gesture Replay Simulator**
   - Replay sensor snapshots through gesture recognizers
   - Test threshold changes against historical data
   - A/B compare detection results

2. **Threshold Profiles**
   - Conservative / Balanced / Aggressive presets
   - Custom profile save/load
   - Profile comparison mode

3. **Session Persistence**
   - Save gesture logs across app launches
   - Load previous sessions for analysis
   - Threshold history with timestamps

4. **Live Sensor Visualization**
   - Real-time graphs of accelerometer/gyroscope
   - Threshold indicator lines on graphs
   - Detection event markers

5. **A/B Threshold Testing Mode**
   - Split-test two threshold configurations
   - Track success rates per configuration
   - Statistical significance calculation

6. **Per-Gesture Test Buttons (Detailed Spec)**

   **Purpose**: Enable developers to test one gesture at a time (Double Tap, Swipe Left, Shake, etc.) without playing the full game. Each test captures expected vs detected results along with full diagnostic data (sensor snapshot, thresholds, timing, device info). Tests can be saved as log entries and exported like normal gesture issues.

   **New Section in DevPanel** - "Per-Gesture Testers" listing:
   - Test Double Tap
   - Test Long Press
   - Test Swipe Left / Right
   - Test Shake
   - Test Tilt Left / Right
   - Test Raise Phone / Lower Phone
   - Test Pinch

   **Workflow**:
   1. User taps a test button (e.g., "Test Double Tap")
   2. DevPanel enters single-gesture "test mode"
   3. User performs gesture (or timeout)
   4. System captures:
      - Expected gesture
      - Detected gesture
      - Auto issue type: notDetected / wrongDetection / success
      - SensorSnapshot (1 second: 500ms before + 500ms after)
      - ThresholdSnapshot
      - GestureTiming
      - DeviceContext
   5. Test result shown in a compact result view:
      - [ Save as Sample ] → converts into a normal GestureLogEntry (auto-selected)
      - [ Retest ]
      - [ Done ]

   **New Data Types**:
   ```swift
   enum GestureTestMode {
     none, doubleTap, longPress, swipeLeft, swipeRight,
     shake, tiltLeft, tiltRight, raisePhone, lowerPhone, pinch
   }

   struct GestureTestResult {
     id, timestamp
     expected: GestureType
     detected: GestureType?
     issueType: IssueType?
     sensorSnapshot: SensorData
     thresholdsSnapshot: ThresholdSnapshot
     timing: GestureTiming
     deviceContext: DeviceContext
   }
   ```

   **Integration Changes**:
   - DevConfigManager:
     - `@Published var testMode: GestureTestMode`
     - `startTestMode(_)`
     - `exitTestMode()`
     - `recordTestResult(_)`
   - DevPanelGestureRecognizer:
     - When in `.testMode`: only listen for that specific gesture
     - Auto-stop after detection or timeout
     - Capture sensor snapshot same as normal gesture logs
   - DevPanelView:
     - New "Per-Gesture Testers" section
     - New test-mode UI showing: "Perform [gesture] now…", "Detected: X"
     - Buttons: Save, Retest, Done

   **Export Behavior**: Saved test results become standard GestureLogEntries with `isSelected = true`, `issueType` auto-detected, and full `sensorSnapshot`. Then they can be exported via "Export Selected Issues."

   **Sub-Future Extensions** (Not Implemented Yet):
   - Auto-run full gesture test suite
   - Calibration mode (capture multiple samples → auto-tune thresholds)
   - Machine-driven gesture playback for regression testing

   **Estimated Effort**: 12-16 hours

7. **Persistent Badge/Indicator**
   - Show count of pending export issues
   - Visible outside dev panel
   - Quick access to review

---

##### Technical Requirements

**DEBUG Guard:**
- All dev panel code wrapped in `#if DEBUG`
- Zero impact on production binary size
- No debug data in App Store builds

**Memory Efficiency:**
- Circular buffer for sensor data (fixed 500ms window)
- Lazy snapshot capture (only on gesture completion)
- Compress JSON export where possible
- Clear old entries when buffer full

**Local-Only Operation:**
- No network uploads
- All data stays on device
- Export to Files app only

**Modular Architecture:**
- Clean separation for future capability plugins
- Protocol-based design for testability
- SwiftUI sheet presentation pattern

---

##### Implementation Approach

**Phase 1: Selectable Issues UI (8-10 hours)**
- GestureLogEntry model with selection state
- Row tap to select/deselect
- Filter controls
- Selection helpers
- Badge indicator

**Phase 2: Sensor Snapshot System (10-12 hours)**
- Circular buffer implementation
- Snapshot capture on gesture completion
- Data structure definitions
- Memory management

**Phase 3: Export System (8-10 hours)**
- JSON serialization
- File export via share sheet
- Optional XCTest generation
- Maintain existing settings export

**Phase 4: Integration & Testing (4-6 hours)**
- Wire up all components
- Test with real gesture failures
- Optimize memory usage
- Document usage patterns

**Total Estimated Effort**: 30-40 hours

**When to Implement**: **P0 - Before v2.0 launch**
Rationale: Expert feedback confirms tuning infrastructure is non-negotiable for quality. "The best games get there through hundreds of small refinements" — impossible without proper tooling.

---

### Testing Status (Current)

**Completed Testing:**
- ✅ All 14 gestures functional across 5 modes
- ✅ Gesture optimization deployed (Nov 9)
- ✅ No compiler errors or warnings

**Known Issues:**
- **Stroop alignment**: Build cache issue, needs clean build (Cmd+Shift+K)
- **Double tap false positives**: Collecting more data from user testing

**TestFlight Readiness:**
- ✅ Code stable and committed
- ✅ All modes functional
- 📋 Awaiting user decision to deploy beta

### Expert Feedback & Design Philosophy

**Source**: Video Game Industry Expert (November 2025)
**Context**: Feedback received after Phase 1 completion, informing v2.0 strategy

#### Core Insight: Tuning is Critical

> "Games like this live and die by tuning. It's never quite right the first time — the best ones get there through hundreds of small refinements in timing, feedback, and rhythm."

**Impact on Roadmap**: This feedback **elevates Option 3 from "nice-to-have" to "essential"**. Without proper tuning infrastructure, we risk shipping an unrefined experience.

#### Key Recommendations

**1. Real-Time Tuning System (Validates Option 3)**
- Reference: "With WELDER we had a whole dev panel in the app to quickly tweak parameters between plays"
- **Action**: Expand Option 3 to include comprehensive dev panel (see detailed spec below)
- **Priority**: P0 (must-have before v2.0 launch)

**2. Sound Design as Core Gameplay**
- Philosophy: "The rhythm between gesture, haptic, and sound should feel tight — like the player is playing an instrument"
- **Latency Target**: <50ms from gesture detection to sound playback
- **Design Goal**: Make every gesture feel like playing a musical instrument
- **References**: Geometry Dash, Beat Saber (satisfying loop of motion and feedback)

**3. User Testing Approach**
- Method: "Run short user tests, watch where they hesitate, where they laugh, and where they get frustrated"
- **Goal**: Not to make the game easier, but to make every failure feel fair and every success satisfying
- **Observation Points**:
  - Hesitation (unclear cues or confusing mechanics)
  - Laughter (moments of delight or surprise)
  - Frustration (unfair failures or unclear feedback)

**4. Game Design Balance**
- Principle: "Balance friction and empowerment — for every new obstacle or challenge you add, give players a tool, cue, or sense of mastery"
- **Application**: When adding difficult gestures (shake, tilt), provide clear visual/haptic cues for success

**5. "Just One More Try" Loop**
- Critical Metric: "Game over → replay time and taps will make or break"
- **Target**: <1 second from game over to restart
- **Current State**: ~2-3 seconds (needs optimization)
- **Reference Games**: Endless runners (Temple Run, Subway Surfers) - fast restarts, escalating tension

---

### Sound Design & Music Strategy 🎵

**Philosophy**: "The rhythm between gesture, haptic, and sound should feel tight — like the player is playing an instrument" (Expert Feedback)

#### Core Design Principles

**1. Gesture as Instrument**
- Every gesture triggers a unique sound signature
- Haptic + sound coordination creates satisfying feedback loop
- **Target Latency**: <50ms from gesture detection → sound playback
- **Reference**: Beat Saber, Geometry Dash (tight motion-feedback coupling)

**2. Multi-Sensory Harmony**
- **Haptic**: Physical confirmation (tap, buzz, vibration)
- **Visual**: Color flash, animation, particle effects
- **Audio**: Sound effect matching gesture character
- All three modalities fire simultaneously for coherent experience

#### Sound System Architecture

**Gesture → Sound Mapping:**
```
Touch Gestures (Percussive Sounds)
├── Tap ⊙: Short click (50ms, 1kHz tone)
├── Double Tap ◎: Double click (2× 40ms, 1.2kHz tone, 100ms gap)
├── Long Press ⏺: Rising tone (600ms, 400Hz → 800Hz sweep)

Swipe Gestures (Whoosh Sounds)
├── Up ↑: Ascending whoosh (200ms, pitch up)
├── Down ↓: Descending whoosh (200ms, pitch down)
├── Left ←: Left-panned whoosh (150ms)
├── Right →: Right-panned whoosh (150ms)

Motion Gestures (Impact/Mechanical Sounds)
├── Shake 📳: Rattle sound (300ms, layered impacts)
├── Pinch 🤏: Squish sound (200ms, compression effect)
├── Tilt L/R ◀▶: Tilt mechanism (150ms, metallic clink)
├── Raise/Lower ↟↡: Hydraulic lift (250ms, mechanical hum)

Cognitive Gesture (Melodic)
├── Stroop 🎨: Chime cascade (400ms, 3-note arpeggio)
```

**Success vs. Failure Sounds:**
- **Correct Gesture**: Consonant, pleasant sound (major chord, bright tone)
- **Wrong Gesture**: Dissonant, jarring sound (minor chord, dull thud)
- **Timeout**: Descending trombone (sad failure sound)
- **New Record**: Triumphant fanfare (celebratory jingle)

#### Audio Implementation Plan

**Phase 1: Core Sound Effects (6-8 hours)**
- Source or create 14 gesture sound effects
- Import as WAV/MP3 files (high quality, low latency)
- Integrate with AVAudioPlayer or AVAudioEngine
- Test latency (<50ms requirement)

**Phase 2: Haptic-Audio Coordination (4-6 hours)**
- Synchronize HapticManager with AudioManager
- Ensure haptic fires immediately before/with sound
- Test perceived simultaneity (human perception ~20ms window)
- Fine-tune delays per gesture type

**Phase 3: Music System (8-10 hours)**
- Background music tracks per game mode
  - **Classic Mode**: Upbeat, accelerating tempo (matches speed progression)
  - **Memory Mode**: Contemplative, puzzle-like (gives thinking space)
  - **PvP Mode**: Competitive, tension-building (head-to-head energy)
  - **Tutorial**: Friendly, instructional (welcoming tone)
  - **Stroop**: Cognitive challenge (quirky, brain-teaser vibe)
- Adaptive music system: tempo increases with difficulty
- Seamless looping (no jarring cuts)

**Phase 4: Audio Polish (4-6 hours)**
- Volume balancing (SFX vs. music ratio)
- Spatial audio for swipes (left/right panning)
- Audio ducking (lower music during critical moments)
- User settings: SFX volume, music volume, toggle on/off

**Phase 5: Advanced Features (Optional, 6-8 hours)**
- Procedural audio generation (algorithmic sound design)
- Dynamic mixing based on gameplay intensity
- Accessibility: Visual sound indicators for deaf/hard-of-hearing
- Export game session as audio file (shareable replay)

#### Sound Asset Sourcing

**Options:**
1. **Royalty-Free Libraries** (Fast, affordable)
   - Freesound.org (CC0 license)
   - Zapsplat.com (free tier)
   - Soundsnap.com (paid)

2. **Custom Sound Design** (Higher quality, unique identity)
   - Hire sound designer (Fiverr, Upwork)
   - Use Logic Pro/Ableton for synthesis
   - Record real-world sounds (Foley)

3. **Procedural Generation** (Technical, scalable)
   - AudioKit framework (Swift audio synthesis)
   - Generate sounds algorithmically
   - Infinite variations without asset files

**Recommended Approach**: Start with royalty-free libraries (Phase 1), upgrade to custom sounds post-launch if budget allows.

#### Critical Metrics

**Performance Targets:**
- **Gesture → Sound Latency**: <50ms (imperceptible delay)
- **Audio Buffer Size**: 256 samples @ 44.1kHz = 5.8ms (hardware minimum)
- **Processing Overhead**: <5% CPU usage for audio system
- **Memory Footprint**: <10MB for all sound assets (compressed)

**User Experience Targets:**
- **Satisfaction**: 90%+ of players rate sound/music positively
- **Toggle Usage**: <20% of players disable sound (indicates quality)
- **Perceived Responsiveness**: Players describe game as "snappy" or "tight"

#### Integration with Dev Panel (Option 3)

**Audio Tuning Controls:**
```
[Sound Design Panel]
├── Gesture Sound Volume: [0%] ←——●——→ [100%]  (current: 80%)
├── Music Volume: [0%] ←——●——→ [100%]  (current: 60%)
├── Audio Latency Compensation: [-50ms] ←●→ [+50ms]  (current: 0ms)
├── Haptic-Audio Sync Offset: [-20ms] ←●→ [+20ms]  (current: -5ms)
└── [Test Sound] [Reset Defaults] [Export Config]
```

**Live Audio Debugging:**
- Show waveform visualization during gameplay
- Display actual latency measurements (gesture → sound)
- A/B test different sound effects in real-time
- Record audio session with timestamped events

#### Timeline & Priority

**Priority**: **P1 (High Priority for v2.0)**
- Expert feedback elevates sound to core gameplay mechanic
- Geometry Dash/Beat Saber prove audio is make-or-break
- Target: Ship Phase 1-3 with v2.0 launch

**Estimated Total Effort**: 22-30 hours
**Dependencies**: Option 3 dev panel (for audio tuning)

---

### Game Design Philosophy & Competitive Analysis 🎮

**Core Principle**: "Balance friction and empowerment — for every new obstacle or challenge you add, give players a tool, cue, or sense of mastery that helps them overcome it. That's where the fun lives." (Expert Feedback)

#### Design Pillars

**1. Fair Failures**
- **Definition**: Every failure should feel preventable, not random or unfair
- **Application in Tipob**:
  - Clear visual cues before gesture prompt (200ms preview)
  - Consistent timing windows (no surprise speed-ups mid-gesture)
  - Generous grace periods for motion gestures (shake, tilt)
  - No hidden mechanics or undiscoverable interactions

**Anti-Pattern to Avoid**: Random difficulty spikes, unclear failure reasons, punishing player for game's lack of clarity

**2. Satisfying Successes**
- **Definition**: Every correct gesture should feel rewarding and empowering
- **Application in Tipob**:
  - Triple feedback: haptic + visual + audio (multi-sensory celebration)
  - Progression rewards: unlock new gestures, faster speeds, achievements
  - Visible skill growth: players see themselves improving over sessions
  - Celebration moments: new personal records, milestone rounds

**Anti-Pattern to Avoid**: Flat feedback (just advancing to next gesture), no sense of accomplishment, success feels trivial

**3. "Just One More Try" Loop**
- **Definition**: Players should always believe they can do better next time
- **Critical Metric**: Game over → replay time/taps (Expert: "will make or break")
- **Application in Tipob**:
  - **Current**: ~2-3 seconds (game over screen → tap to restart → countdown)
  - **Target**: <1 second (instant restart option)
  - **Implementation**: "Double tap to restart" immediately after failure
  - Show what went wrong briefly, but don't force long post-mortem

**Reference Games**: Endless runners (Temple Run, Subway Surfers) nail this with <1s restarts

**4. Friction vs. Empowerment Balance**
- **For Every Challenge, Provide a Tool**:

| Challenge (Friction) | Tool/Cue (Empowerment) |
|---------------------|------------------------|
| 14 different gestures (overwhelming) | Tutorial mode (teaches each gesture) |
| Increasing speed (Classic mode) | Visual countdown ring (time awareness) |
| Long sequences (Memory mode) | Color-coded gestures (visual memory aids) |
| Cognitive load (Stroop) | 4 directional labels (always visible) |
| Motion gestures in public (embarrassing) | Discreet Mode (removes motion gestures) |
| Difficult gestures (shake, tilt) | Visual feedback bar (shows detection progress) |
| Unfamiliar controls | Onboarding flow + practice rounds |

- **Rule of Thumb**: If adding a gesture that increases difficulty, also add a visual/audio cue that helps players master it

#### Competitive Analysis: What Makes Games Addictive

**Geometry Dash** (Rhythm + Reflexes)
- **What Works**:
  - Tight rhythm coupling (music drives gameplay)
  - Instant restarts (<0.5s from death to retry)
  - Clear feedback (you always know WHY you failed)
  - Practice mode (isolate difficult sections)
  - Satisfying progression (unlock new levels/icons)

- **Lessons for Tipob**:
  - Sound design is critical (music = gameplay mechanic)
  - Instant restarts are non-negotiable
  - Let players practice individual gestures (practice mode)
  - Visual customization (unlock gesture colors/effects)

**Beat Saber** (VR Rhythm)
- **What Works**:
  - Physical embodiment (gestures feel like playing instrument)
  - Multi-sensory feedback (slash sound + haptic + particle effects)
  - Escalating difficulty (faster songs unlock over time)
  - Clear visual cues (blocks approach with plenty of warning)
  - Leaderboards (social competition)

- **Lessons for Tipob**:
  - Make gestures feel physical and satisfying (we have haptics!)
  - Multi-sensory feedback is essential (audio + haptic + visual)
  - Progressive difficulty unlocking (don't overwhelm beginners)
  - Social features matter (we have leaderboards ✓)

**Temple Run / Subway Surfers** (Endless Runners)
- **What Works**:
  - Simple controls (swipe + tilt, easy to learn)
  - "Just one more try" loop perfected (<1s restarts)
  - Escalating tension (speed increases gradually)
  - Power-ups (temporary advantages)
  - Meta-progression (unlock characters, upgrades)

- **Lessons for Tipob**:
  - Fast restarts are scientifically proven to drive engagement
  - Escalating tension works (Classic mode already does this)
  - Consider power-ups (e.g., "slow time" for 3 gestures)
  - Meta-progression (unlock gesture customization, sound packs)

**Where They Fall Short** (Opportunities for Tipob):
- **Repetition**: Endless runners get stale after many plays
  - **Tipob Advantage**: 14 gestures + 5 modes = more variety
- **Unclear Feedback**: Sometimes deaths feel random
  - **Tipob Advantage**: Gesture-based = clear right/wrong
- **Lack of Skill Expression**: Limited ways to show mastery
  - **Tipob Advantage**: Speed modes + leaderboards showcase skill

#### User Testing Framework

**Observation Method** (Expert Advice):
> "Run short user tests, watch where they hesitate, where they laugh, and where they get frustrated. The goal isn't to make the game easier — it's to make every failure feel fair and every success satisfying."

**What to Watch For:**

**Hesitation Points** (Indicates confusion or unclear mechanics):
- Do they pause before attempting a gesture? (gesture not clear)
- Do they re-read instructions multiple times? (wording unclear)
- Do they try the wrong gesture first? (visual cue misleading)
- **Action**: Improve clarity of gesture prompts, add visual hints

**Laughter Moments** (Indicates delight or surprise):
- Which gestures make them smile or laugh? (fun factor)
- When do they react positively? (satisfying feedback)
- What moments do they want to share? (viral potential)
- **Action**: Amplify these moments, make them more frequent

**Frustration Points** (Indicates unfair difficulty or bad UX):
- Do they blame the game or themselves? (fairness perception)
- Do they quit after a specific gesture? (difficulty spike)
- Do they complain about timing windows? (calibration issue)
- Do they retry immediately or stop playing? (engagement)
- **Action**: Fix unfair mechanics, adjust difficulty curves

**Testing Protocol:**
1. **Recruit**: 5-10 users (mix of gamers and non-gamers)
2. **Setup**: Silent observation (don't guide them)
3. **Duration**: 10-15 minutes per user (first session only)
4. **Recording**: Screen + face recording (capture reactions)
5. **Debrief**: Ask open-ended questions after playing
   - "What was the hardest part?"
   - "What felt most satisfying?"
   - "Would you play again? Why/why not?"

**Metrics to Track:**
- Time to first failure (learning curve)
- Number of restarts (engagement indicator)
- Gesture miss rate per gesture type (difficulty balance)
- Session length (average play time)
- Retention: Do they return next day/week? (long-term engagement)

#### Implementation Priorities

**P0 (Must-Have before v2.0):**
- ✅ Fair failure feedback (already implemented)
- ⏳ Fast restart loop (<1s target)
- ⏳ Option 3 dev panel (for tuning fairness/difficulty)
- ⏳ Sound design Phase 1-3 (satisfying successes)

**P1 (High Priority for v2.0):**
- Practice mode (master individual gestures)
- Visual gesture progress bars (empowerment tool)
- Achievement system (milestone celebrations)
- Accessibility options (reduce difficulty for wider audience)

**P2 (Post-Launch Enhancements):**
- Power-ups (temporary advantages)
- Customization unlocks (gesture colors, sound packs)
- Social features (share scores, challenge friends)
- Meta-progression system (long-term goals)

---

### Expert-Validated Feature Priorities (v2.0 Roadmap) 🎯

**Context**: Following expert feedback, the roadmap has been re-prioritized to focus on quality, tuning, and retention mechanics. This section supersedes the granular Phase 1/Phase 2 breakdown below with expert-validated priorities.

#### P0 - Critical for v2.0 Launch (Must-Have)

**1. Option 3: Dev Panel & Tuning Infrastructure** (30-40 hours)
- **Why P0**: "Games like this live and die by tuning" — impossible to ship quality experience without it
- **Scope**: Threshold tuning interface, debugging overlay, analytics dashboard, config management
- **Success Metric**: Ability to tweak all gesture parameters between plays, export optimized configs
- **Blocking**: All other features depend on this for calibration

**2. Sound Design & Music Phase 1-3** (18-24 hours)
- **Why P0**: "The rhythm between gesture, haptic, and sound should feel tight — like playing an instrument"
- **Scope**: 14 gesture sound effects, haptic-audio sync, mode-specific music tracks, volume controls
- **Success Metric**: <50ms gesture-to-sound latency, 90%+ positive user feedback on audio
- **References**: Beat Saber, Geometry Dash (audio = core mechanic, not accessory)

**3. Fast Restart Loop Optimization** (4-6 hours)
- **Why P0**: "Game over → replay time and taps will make or break"
- **Current**: ~2-3 seconds from failure to restart
- **Target**: <1 second (double tap to instant restart)
- **Success Metric**: 80%+ of players restart within 1 second of failure
- **References**: Geometry Dash (<0.5s), Temple Run/Subway Surfers (<1s)

**4. User Testing & Iteration** (12-16 hours)
- **Why P0**: "Watch where they hesitate, laugh, and get frustrated" — critical before launch
- **Scope**: 5-10 user sessions, observation + debrief, identify pain points
- **Deliverable**: List of 10+ UX improvements based on real user behavior
- **Testing Protocol**: Documented in Game Design Philosophy section above

**P0 Total**: 64-86 hours (~2-3 weeks full-time)

---

#### P1 - High Priority for v2.0 (Strongly Recommended)

**5. Practice Mode** (8-12 hours)
- **Why P1**: Enables players to master individual gestures (empowerment tool)
- **Scope**: Select specific gestures to practice, no timer pressure, accuracy feedback
- **Success Metric**: Players who use practice mode have 30%+ higher retention
- **Reference**: Geometry Dash practice mode (isolate difficult sections)

**6. Visual Gesture Progress Bars** (6-8 hours)
- **Why P1**: "For every challenge, provide a tool" — show real-time detection progress
- **Scope**: Shake detection bar (shows 0G → 2.0G), tilt angle indicator, pinch % indicator
- **Success Metric**: Reduce motion gesture miss rate by 20%+
- **Empowerment**: Players see WHY they're failing (too soft, wrong angle, etc.)

**7. Achievement System - Foundation** (10-12 hours)
- **Why P1**: Milestone celebrations drive retention ("satisfying successes")
- **Scope**: 15-20 achievements (first game, reach round X, perfect round, mastery)
- **Success Metric**: Players with 3+ unlocked achievements have 50%+ higher retention
- **Monetization**: Foundation for future IAP (unlock achievements faster)

**8. Settings Menu Expansion** (8-10 hours)
- **Why P1**: Accessibility and player comfort (reduce friction)
- **Scope**: Volume sliders (SFX/music separate), haptic toggle, gesture pool toggle (Discreet Mode)
- **Success Metric**: <20% of players disable sound/haptics (indicates quality)
- **Accessibility**: Critical for public play and different user preferences

**9. Onboarding Flow Polish** (6-8 hours)
- **Why P1**: First-time user experience determines retention
- **Scope**: Interactive tutorial improvements, gesture practice rounds, skip option
- **Success Metric**: 80%+ of new users complete tutorial, 50%+ play 2nd session
- **Current State**: Tutorial exists but needs polish based on user testing findings

**P1 Total**: 38-50 hours (~1-1.5 weeks full-time)

---

#### P2 - Post-Launch Enhancements (Nice-to-Have)

**10. Daily Challenges** (14-16 hours)
- Habit-forming mechanic, global leaderboard, streak bonuses
- **Timing**: Launch with v2.1 (1-2 months post-launch)

**11. Power-Ups System** (12-16 hours)
- Slow time, extra life, gesture hint, double points
- **Timing**: v2.2 after balancing core gameplay

**12. Cosmetic System** (20-30 hours)
- Gesture color themes, particle effects, UI skins
- **Monetization**: IAP packs ($1.99-$3.99)
- **Timing**: v2.2-v2.3 after retention metrics validated

**13. Social Features** (16-20 hours)
- Share scores, challenge friends, friend leaderboards, push notifications
- **Timing**: v2.3 once core gameplay proven sticky

**14. Meta-Progression** (30-40 hours)
- Gesture unlock system, mastery ranks, progression rewards
- **Timing**: v3.0 major update (6+ months post-launch)

**15. Advanced Gestures** (15-20 hours per gesture)
- Spread, rotate, voice commands, blow/whistle
- **Timing**: v3.0+ based on demand and technical feasibility

**P2 Total**: 107-142 hours (spread over 6-12 months post-launch)

---

#### Updated Launch Timeline

**v2.0 Alpha** (Internal Testing):
- P0 features complete (dev panel, sound design, fast restarts, user testing)
- 1st round of user testing findings implemented
- **Timeline**: 3-4 weeks from now

**v2.0 Beta** (TestFlight):
- P0 + P1 features complete
- 2nd round of user testing complete
- Tuned and polished based on data from dev panel
- **Timeline**: 5-7 weeks from now

**v2.0 Production Launch**:
- All P0/P1 features shipped
- High confidence in quality from testing and tuning
- Marketing materials ready (trailer, screenshots, ASO)
- **Timeline**: 8-10 weeks from now

**v2.1-v3.0** (Post-Launch):
- Roll out P2 features based on user feedback and metrics
- Monetization experiments (IAP, ads, premium features)
- Platform expansion (iPad optimization, Apple Watch, macOS)
- **Timeline**: 3-12 months post-launch

---

**Key Insight from Expert Feedback**:
Shipping v2.0 without P0 features (especially dev panel and sound design) would be premature. The extra 2-3 weeks for tuning infrastructure will pay massive dividends in quality and player satisfaction. "The best games get there through hundreds of small refinements" — this requires proper tooling.

---

#### 1.1 Gesture Expansion ✅
- [x] **Tap gesture ⊙** (1 hour) - ✅ Completed 2025-10-20 (Actual: 0.5 hours)
- [x] **Double tap gesture ◎** (1 hour) - ✅ Completed 2025-10-20 (Actual: 0.5 hours)
- [x] **Long press gesture ⏺** (1 hour) - ✅ Completed 2025-10-20 (Actual: 0.5 hours)
- [x] **Pinch gesture 🤏** (6-8 hours) - ✅ Completed 2025-10-27 (Actual: 8 hours)
  - Native UIPinchGestureRecognizer implementation
  - UIViewRepresentable wrapper pattern
  - Gesture coexistence with tap/swipe
  - Indigo color + compress animation
  - Applied to all 5 game modes

**Implementation Notes**:
- **2025-10-20**: Created SwipeGestureModifier and TapGestureModifier for coexistence
- **2025-10-27**: Attempted SwiftUI MagnificationGesture (failed - 10% recognition rate)
- **2025-10-27**: Migrated to native UIKit UIPinchGestureRecognizer (success - 90%+ recognition)
- **Key Learning**: For complex multi-touch gestures, native UIKit recognizers are significantly more reliable than SwiftUI gesture APIs

**Acceptance Criteria** (Complete):
- [x] All 8 gestures detected reliably (4 swipes + 3 touch + 1 pinch)
- [x] Haptic feedback unique to each gesture type
- [x] Gestures coexist without conflicts
- [x] Tutorial mode includes all 8 gestures (2 rounds × 8 gestures)
- [x] Applied to all game modes (Classic ⚡, Memory 🧠, Tutorial, PvP 👥, Game vs PvP)
- [x] Unified failure feedback (sound + haptic)

**Status**: ✅ Phase 1 gesture expansion complete - 8 gestures total

**Next Gestures Roadmap** (in priority order):
1. **Spread 🫱🫲** (P1) - Use same UIKit recognizer as pinch
2. **Rotate 🔄** (P1) - UIRotationGestureRecognizer
3. **Shake 📳** (P1) - CMMotionManager (most requested)
4. **Tilt Left/Right ↺↻** (P2) - Device orientation
5. **Voice Commands 🎤** (P2) - Accessibility feature
6. **Blow/Whistle 💨** (P3) - Audio detection
7. **Freeze 🧊** (P3) - Stillness detection
8. **Color Reading 🎨** (P4) - Camera + ML

---

#### 1.2 Game Modes
- [x] **Memory Mode 🧠** (6 hours) - ✅ Completed 2025-10-20 (Actual: 4 hours)
  - Show sequence once, player must memorize
  - No visual indicators during input
  - Sequence grows by 1 gesture each round
  - Visual feedback after sequence completion
  - High score tracking and persistence

- [x] **Game vs Player vs Player 👥** (8 hours) - ✅ Completed 2025-10-20 (Actual: 6 hours)
  - 2-player pass-and-play competitive mode
  - Fair sequence replay (both players see same gestures)
  - Alternating turns with player identification
  - Individual score tracking
  - Game ends when either player fails
  - Winner determined by highest score

- [ ] **Endless Mode ⚡** (4 hours) - Deferred
  - No time limit initially
  - Time decreases 0.1s every 5 rounds
  - Minimum time floor: 1.5s

- [ ] **Zen Mode** (2 hours) - Deferred
  - 5s per gesture (vs. 3s standard)
  - No game over, practice mode
  - Stats tracking only

**Acceptance Criteria** (Partially Complete):
- [x] Mode selection in main menu
- [x] Independent high scores per mode
- [x] Persistent mode preference
- [ ] Independent leaderboards per mode (Game Center integration pending)

**Technical Notes**:
```swift
enum GameMode {
    case classic      // Bop-It style: react to prompts
    case memory       // Simon Says: memorize sequences
    case playerVsPlayer  // 2-player competitive

    var displayName: String {
        switch self {
        case .classic: return "Classic ⚡"
        case .memory: return "Memory 🧠"
        case .playerVsPlayer: return "Game vs Player vs Player 👥"
        }
    }
}
```

---

#### 1.3 Progression System - Foundation
- [ ] **Basic achievement system** (8 hours)
  - First game played
  - Reach round 5, 10, 25, 50, 100
  - Perfect round (all gestures on first try)
  - Close call (complete with <0.5s remaining)
  - Comeback (fail → continue → win 5 more rounds)

- [ ] **Streak tracking** (2 hours)
  - Daily play streak
  - Perfect streak (rounds with no mistakes)
  - Gesture-specific accuracy stats

**Acceptance Criteria**:
- Achievement notifications on unlock
- Achievement gallery in menu
- Progress tracking (e.g., "50/100 rounds reached")

---

#### 1.4 Leaderboards & Social
- [ ] **Game Center integration** (6 hours)
  - Global leaderboard (best streak)
  - Per-mode leaderboards
  - Friend leaderboards
  - Achievement sync

- [ ] **Share functionality** (3 hours)
  - Share score to social media
  - Custom share image with stats
  - "Challenge friend" link

**Acceptance Criteria**:
- One-tap share from game over screen
- Properly formatted share text
- Deep linking for challenges (future Phase 2)

---

#### 1.5 Polish & QOL
- [ ] **Sound effects** (4 hours)
  - Swipe whoosh (pitch varies by direction)
  - Success chime
  - Fail buzz
  - Countdown tick (last 1s)
  - Menu interactions

- [ ] **Settings menu** (6 hours)
  - Sound volume slider
  - Haptic toggle
  - Motion gesture toggle
  - Difficulty preset (time per gesture)
  - Color theme selection (3 themes)

- [ ] **Onboarding tutorial** (8 hours)
  - First-time user flow
  - Interactive gesture practice
  - Skippable for returning users
  - Tips system ("Swipe faster for combo bonus")

**Acceptance Criteria**:
- Settings persist across sessions
- Tutorial only shown once (unless reset)
- All sounds have volume control

---

**Phase 1 Total Effort**: 60-70 hours (~2 weeks full-time)
**Phase 1 Deliverable**: Engaging game with variety, ready for soft launch

---

### Phase 2: Progression & Monetization
**Timeline**: 3-4 weeks
**Goal**: Increase retention and establish revenue streams
**Priority**: 🟡 High Value

#### 2.1 Gesture Unlock System
- [ ] **Progression design** (12 hours)
  - Start with 4 swipes + tap only
  - Unlock schedule:
    - Round 5: Double tap
    - Round 10: Long press
    - Round 15: Shake
    - Round 25: Pinch
    - Round 35: Rotate
    - Round 50: Two-finger swipe
  - OR unlock via achievement completion
  - Practice mode for locked gestures (preview)

- [ ] **Gesture mastery system** (8 hours)
  - Track accuracy per gesture (bronze/silver/gold/platinum)
  - Mastery rewards: cosmetic unlocks
  - Mastery challenges (e.g., "Complete 10 rounds using only taps")

**Acceptance Criteria**:
- Clear unlock progress shown in menu
- Tutorial triggers on first encounter with new gesture
- Ability to re-lock gestures for challenge runs

**Monetization Hook**: Option to unlock all gestures early ($2.99 IAP)

---

#### 2.2 Daily Challenges
- [ ] **Challenge generation system** (10 hours)
  - Preset seed for daily sequence
  - Everyone gets same sequence globally
  - Bonus points for daily challenge completion
  - Streak bonuses (complete 7 days = reward)

- [ ] **Challenge leaderboard** (4 hours)
  - 24-hour global leaderboard
  - Friend rankings
  - Push notifications for friend beating your score

**Acceptance Criteria**:
- Challenges reset at midnight local time
- Rewards retroactive if played before claiming
- Clear countdown timer to next challenge

**Engagement**: Habit-forming daily ritual

---

#### 2.3 Cosmetic System - Foundation
- [ ] **Theme engine** (10 hours)
  - Arrow color customization
  - Background gradient presets
  - UI accent color
  - Particle effect styles

- [ ] **Initial cosmetic packs** (12 hours)
  - **Starter Pack** (default, free)
    - Classic arrows
    - Blue/purple gradient
    - Standard particles

  - **Neon Pack** ($1.99)
    - Glowing neon arrows
    - Black background + neon accents
    - Electric particle effects

  - **Retro Pack** ($1.99)
    - Pixel art arrows
    - CRT scanline effect
    - 8-bit sound pack

  - **Nature Pack** ($1.99)
    - Leaf/flower arrows
    - Earth tone gradients
    - Sparkle particles

- [ ] **Unlock system** (6 hours)
  - Purchase with real money
  - OR earn via in-game soft currency
  - Preview before purchase
  - Equip/unequip in settings

**Acceptance Criteria**:
- Themes persist across sessions
- No performance impact from cosmetics
- Accessible color contrast maintained

**Monetization**: $1.99 per pack, bundle of 3 for $4.99

---

#### 2.4 Advertising Integration
- [ ] **Ad SDK setup** (4 hours)
  - Google AdMob integration
  - IDFA permission handling (iOS 14.5+)
  - GDPR/CCPA compliance

- [ ] **Interstitial ads** (3 hours)
  - Show after round 5 (first game)
  - Then every 3 games or 10 minutes (whichever comes first)
  - Frequency cap: Max 1 per 3 minutes
  - Skip if user purchased remove ads

- [ ] **Rewarded ads** (4 hours)
  - "Continue playing" after game over
  - Watch ad → get one more chance (1.5x time)
  - Max 1 continue per game (prevents abuse)
  - Optional, never forced

**Acceptance Criteria**:
- Ads load in background, no lag on display
- Respect user's remove ads purchase completely
- Graceful fallback if no ad available
- Analytics tracking (impressions, clicks, revenue)

**Revenue Estimate**: $0.05-0.15 CPM, $0.50-2.00 per rewarded video

---

#### 2.5 First IAP Offering
- [ ] **IAP implementation** (8 hours)
  - StoreKit 2 integration
  - Receipt validation
  - Restore purchases flow

- [ ] **Remove Ads** ($4.99)
  - One-time purchase
  - Removes all interstitial ads
  - Keeps rewarded ads (for continue feature)
  - Prominent placement after 3rd ad shown

- [ ] **Gesture Unlock Bundle** ($2.99)
  - Unlock all current + future gestures
  - Skip progression system
  - For impatient players or accessibility

**Acceptance Criteria**:
- Purchase persists across devices (iCloud)
- Family Sharing supported
- Clear purchase confirmation
- Receipt stored securely

**Revenue Estimate**: 2-5% conversion rate on remove ads after 10 sessions

---

**Phase 2 Total Effort**: 80-90 hours (~3 weeks full-time)
**Phase 2 Deliverable**: Monetized game with progression hooks

---

### Phase 3: Social & Advanced Features
**Timeline**: 4-5 weeks
**Goal**: Viral growth and premium features
**Priority**: 🟢 Growth Driver

#### 3.1 Multiplayer - Pass & Play
- [ ] **Turn-based system** (16 hours)
  - 2-4 player support
  - Pass device between players
  - Score tracking per player
  - Winner celebration screen

- [ ] **Game mode: Alternating** (4 hours)
  - Players take turns on same sequence
  - Longest survivor wins
  - Elimination on first mistake

- [ ] **Game mode: Custom Challenge** (6 hours)
  - Player 1 creates sequence
  - Player 2 attempts to replicate
  - Role swap after each round
  - Best of 3/5/7

**Acceptance Criteria**:
- Clear whose turn it is
- Scores persist across turns
- Option to pause between turns
- Stats tracked per player profile (local)

**Engagement**: Couch co-op, party game appeal

---

#### 3.2 Multiplayer - Asynchronous
- [ ] **Challenge system** (20 hours)
  - Generate shareable link with sequence
  - Friend plays same sequence
  - Compare scores
  - Push notification when challenge completed

- [ ] **Cloud backend** (requires Firebase/Supabase)
  - Store challenge data
  - User authentication (Sign in with Apple)
  - Friend system
  - Challenge inbox

**Acceptance Criteria**:
- Works via SMS/WhatsApp/iMessage
- No account required for receiver
- Challenge expires after 7 days
- Rematch functionality

**Technical Complexity**: High (backend required)
**Consideration**: May require ongoing server costs

---

#### 3.3 Advanced Game Modes
- [ ] **Reverse Mode** (4 hours)
  - Perform sequence backwards
  - Bonus points multiplier
  - Unlocked at round 20

- [ ] **Mirror Mode** (6 hours)
  - Opposite gestures (up↔down, left↔right)
  - Tap→Double Tap, Pinch↔Spread
  - Brain-teaser difficulty

- [ ] **Chaos Mode** (8 hours)
  - Random time per gesture (1-5s)
  - Random gesture types each round
  - Power-up spawns (slow-mo, skip, rewind)

- [ ] **Boss Rush** (10 hours)
  - Every 5th round is "boss round"
  - 10+ gesture sequence
  - Reduced time (2s per gesture)
  - Special rewards on completion

**Acceptance Criteria**:
- Each mode has unique leaderboard
- Tutorial explains mode-specific rules
- Clear difficulty indication

---

#### 3.4 Power-Up System
- [ ] **Power-up design** (12 hours)
  - **Slow-Mo**: 2x time for next gesture
  - **Rewind**: Go back one gesture
  - **Skip**: Skip current gesture
  - **Shield**: Forgive one mistake
  - **Double Points**: 2x score next gesture

- [ ] **Earn mechanics** (6 hours)
  - Random spawn during gameplay (5% chance per gesture)
  - Purchase with soft currency
  - Rewarded ad grants 3 random power-ups
  - Daily login bonus

- [ ] **Usage limits** (2 hours)
  - Max 1 power-up use per round (prevents abuse)
  - Inventory system (hold up to 10)
  - Cooldown between uses

**Acceptance Criteria**:
- Power-ups don't break leaderboard fairness
- Clear visual indicator when available
- Can't be used in "Pure" mode (no power-ups)

**Monetization**: Sell power-up packs ($0.99 for 10)

---

#### 3.5 Subscription Tier
- [ ] **Subscription implementation** (10 hours)
  - StoreKit 2 auto-renewable subscription
  - Monthly ($4.99) and Annual ($39.99, 33% off)
  - Free 7-day trial
  - Cancel anytime

- [ ] **Premium benefits**
  - Ad-free experience
  - All gestures unlocked immediately
  - All current + future cosmetic packs
  - Exclusive "Premium" badge/frame
  - Early access to new features (1 week)
  - Cloud save (cross-device sync)
  - Priority support

**Acceptance Criteria**:
- Clear value proposition on paywall
- Subscription status visible in settings
- Manage subscription via App Store
- Graceful degradation on cancel

**Revenue Estimate**: 1-3% conversion, $3-5 LTV per subscriber

---

**Phase 3 Total Effort**: 100-120 hours (~4 weeks full-time)
**Phase 3 Deliverable**: Social features driving virality, premium tier

---

### Phase 4: Advanced & Experimental
**Timeline**: Ongoing post-launch
**Goal**: Differentiation and long-term engagement
**Priority**: 🔵 Innovation

#### 4.1 Motion Gestures Expansion
- [ ] Tilt left/right
- [ ] Voice commands (accessibility)
- [ ] Blow/whistle detection
- [ ] Custom gesture recording

#### 4.2 Competitive Features
- [ ] Ranked mode with ELO system
- [ ] Seasonal leaderboards
- [ ] Tournament mode
- [ ] Clan/team system

#### 4.3 Content Updates
- [ ] Monthly themed events
- [ ] Holiday cosmetic packs
- [ ] Limited-time game modes
- [ ] Crossover collaborations

#### 4.4 AI/ML Features
- [ ] Difficulty auto-adjust based on performance
- [ ] Personalized challenge recommendations
- [ ] Gesture pattern recognition for custom shapes

---

## 💰 Monetization Strategy

### Revenue Streams - Priority Ranked

#### Stream 1: Advertising (Primary Revenue - Month 1-6) 📊
**Target**: 60-70% of total revenue initially

| Ad Type | Placement | Frequency | Expected CPM | Priority |
|---------|-----------|-----------|--------------|----------|
| **Interstitial** | After game over | Every 3 games OR 10min | $5-15 | P0 |
| **Rewarded Video** | Continue after fail | User-initiated only | $15-40 | P0 |
| **Banner** | Menu screen | Persistent | $1-3 | P2 |

**Optimization**:
- Mediation platform (AdMob, IronSource)
- A/B test frequency caps
- Respect user attention (never interrupt gameplay)
- Premium placement for rewarded (70% take rate)

**Projections** (conservative):
- 10,000 DAU × 3 sessions/day × 1 ad/session × $0.01 revenue/ad = $300/day = $9K/month
- Rewarded: 10,000 DAU × 30% watch rate × $0.50/video = $1,500/day = $45K/month
- **Total Ad Revenue**: $50K+/month at scale

---

### IMPLEMENTED: AdMob Integration (November 11-12, 2025) ✅

**Status**: Complete - TEST Mode Active

**Implementation Details:**

#### SDK & Configuration
- **Framework**: Google Mobile Ads (GoogleMobileAds)
- **Ad Type**: Interstitial ads (full-screen)
- **TEST Credentials**:
  - Ad Unit ID: `ca-app-pub-3940256099942544/4411468910`
  - Application ID: `ca-app-pub-3940256099942544~1458002511`
- **Production Note**: TEST IDs only - never uses production credentials

#### Core Components

**AdManager.swift** (~165 lines)
- Singleton pattern for centralized ad lifecycle management
- Automatic ad preloading during gameplay
- Retry logic with 30-second backoff on failure
- Graceful degradation (game continues if ad unavailable)
- FullScreenContentDelegate conformance for ad events

**UIViewControllerHelper.swift** (~80 lines)
- SwiftUI/UIKit bridge for presenting UIKit ad controllers
- Extension on UIApplication to find top view controller
- Required because AdMob SDK is UIKit-based

#### Integration Points

**Ad Trigger Logic:**
- **Home Button**: All game over screens (GameOverView, PlayerVsPlayerView, GameVsPlayerVsPlayerView)
- **Play Again Button**: All game over screens
- **Frequency**: Shows on EVERY button tap if ad is loaded (testing mode)

**Original Logic (Nov 11):**
- 30-second cooldown between ads
- Every 2 games minimum
- 30-second launch protection (no ads in first 30s)

**Simplified Logic (Nov 12):**
- **All cooldowns removed** for testing purposes
- Ad shows immediately if loaded
- `incrementGameCount()` became no-op
- `shouldShowEndOfGameAd()` only checks if ad is loaded

#### Info.plist Configuration

**Added Entries:**
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>

<key>SKAdNetworkItems</key>
<array>
  <!-- 49 SKAdNetwork identifiers for iOS 14+ attribution -->
</array>

<key>UIRequiresFullScreen</key>
<true/>
```

**Configuration Fixes (Nov 12):**
- Removed UISceneDelegateClassName reference (SwiftUI apps don't need SceneDelegate)
- Added UIRequiresFullScreen key for portrait-only mode
- Added 49 SKAdNetwork identifiers for iOS 14+ ad attribution
- Updated Xcode project settings to match Info.plist

#### Ad Flow Sequence

1. **Initialization**: AdManager preloads first ad on app launch
2. **Gameplay**: Ad loads in background during game
3. **Game Over**: User taps Home or Play Again
4. **Check**: `shouldShowEndOfGameAd()` verifies ad is loaded
5. **Present**: Ad displays via UIViewController helper
6. **Completion**: Callback executes (navigates home or restarts game)
7. **Preload**: Next ad loads immediately after dismissal

#### Testing Observations

**Successful Tests:**
- ✅ Ads load reliably with TEST credentials
- ✅ Ad display does not interrupt gameplay
- ✅ Graceful fallback when ad unavailable
- ✅ Preloading works during gameplay
- ✅ All 5 game modes respect ad logic

**Known Behaviors:**
- TEST ads show immediately (no fill rate issues)
- Production ads may have lower fill rates
- Ad loading retry mechanism working (30s backoff)

#### Technical Decisions

**Why Singleton Pattern:**
- Prevents multiple CMMotionManager instances (iOS limitation)
- Centralized ad state management
- Consistent behavior across all views

**Why UIViewControllerHelper:**
- AdMob SDK requires UIViewController for presentation
- SwiftUI views don't have direct UIViewController access
- Helper finds topmost view controller in window hierarchy

**Why Aggressive Testing Mode:**
- User requested "show ads on EVERY tap" for validation
- Easier to test ad integration and UX flow
- Can dial back frequency before production launch

#### Future Production Transition

**Before App Store Submission:**
- [ ] Replace TEST Ad Unit IDs with production IDs
- [ ] Replace TEST Application ID with production ID
- [ ] Re-enable cooldown restrictions (recommended: 30s + every 2 games)
- [ ] Update AdManager comments to reflect production status
- [ ] Test fill rates with real production ads

**Recommended Production Logic:**
```swift
// Restore these constants:
private let minimumTimeBetweenAds: TimeInterval = 30.0
private let gamesPerAd: Int = 2
private let minimumTimeSinceLaunch: TimeInterval = 30.0

// Restore full shouldShowEndOfGameAd() checks:
- Time since app launch
- Time since last ad
- Games completed frequency
- Ad loaded and ready
```

#### File References
- `/Users/marcgeraldez/Projects/tipob/Tipob/Utilities/AdManager.swift`
- `/Users/marcgeraldez/Projects/tipob/Tipob/Utilities/UIViewControllerHelper.swift`
- `/Users/marcgeraldez/Projects/tipob/Tipob/Views/GameOverView.swift`
- `/Users/marcgeraldez/Projects/tipob/Tipob/Views/PlayerVsPlayerView.swift`
- `/Users/marcgeraldez/Projects/tipob/Tipob/Views/GameVsPlayerVsPlayerView.swift`
- `/Users/marcgeraldez/Projects/tipob/Tipob/Info.plist`

---

#### Stream 2: In-App Purchases (Growth - Month 3+) 💎

##### Remove Ads IAP
- **Price**: $4.99
- **Positioning**: After 3rd ad shown, or in settings
- **Value Prop**: "Enjoy Tipob ad-free forever"
- **Conversion**: 2-5% of users who see 10+ ads
- **Projection**: 10,000 users × 3% × $4.99 = $1,497 one-time + ongoing

##### Cosmetic Packs
- **Price**: $1.99 per pack, $4.99 for 3-pack bundle
- **Launch lineup**: Neon, Retro, Nature (Phase 2)
- **Expansion**: Monthly new packs
- **Conversion**: 5-10% of engaged users (>20 sessions)
- **Projection**: 10,000 engaged × 7% × $1.99 = $1,393/pack launch

##### Gesture Unlock Bundle
- **Price**: $2.99
- **Target**: Impatient users, accessibility needs
- **Positioning**: "Unlock all gestures now"
- **Conversion**: 1-2% of players stuck at unlock gate
- **Projection**: 10,000 users × 1.5% × $2.99 = $449

##### Power-Up Packs (Phase 3)
- **Price**: $0.99 for 10 power-ups
- **Target**: Competitive players, challenge runners
- **Conversion**: 3-5% of core players
- **Projection**: 5,000 core × 4% × $0.99 = $198/month (recurring)

**Total IAP Revenue**: $20-40K/month at scale

---

#### Stream 3: Subscription (Premium - Month 6+) 👑

##### Tipob Premium
| Tier | Price | Benefits | Target Audience |
|------|-------|----------|-----------------|
| **Monthly** | $4.99/mo | All Premium features | Casual trial |
| **Annual** | $39.99/yr | Same + 33% savings | Committed fans |

**Premium Benefits**:
- ✅ Ad-free experience
- ✅ All gestures unlocked
- ✅ All cosmetic packs (current + future)
- ✅ Exclusive Premium badge/theme
- ✅ Early access (1 week)
- ✅ Cloud save + cross-device sync
- ✅ Priority support

**Conversion Funnel**:
1. Free 7-day trial (requires credit card)
2. Paywall shown after 10 sessions OR when hitting unlock gate
3. Re-engagement campaigns (push notifications)

**Projections**:
- 10,000 users × 2% trial start = 200 trials/month
- 200 trials × 40% convert = 80 paying subscribers
- 80 subscribers × $4.99 = $399/month recurring
- With churn: $399 × 12 months × 60% retention = $2,875 ARR per cohort

**Year 1 Subscriber Target**: 500 subscribers = $30K ARR

---

### Monetization Roadmap

#### Phase 1 (Month 1-3): Ad Foundation
- ✅ Implement interstitial ads (COMPLETE - Nov 11, 2025)
- ✅ AdMob SDK integration with TEST credentials
- ⏳ Rewarded ads (next priority)
- ⏳ A/B test ad frequency (after production transition)
- ⏳ Launch "Remove Ads" IAP (requires production Ad IDs)
- Target: $5-10K/month revenue

#### Phase 2 (Month 4-6): IAP Expansion
- ✅ Launch cosmetic packs (3 initial)
- ✅ Gesture unlock bundle
- ✅ Optimize IAP conversion funnels
- Target: $20-30K/month revenue

#### Phase 3 (Month 7-12): Premium Tier
- ✅ Launch subscription
- ✅ Build subscriber retention programs
- ✅ Monthly cosmetic drops for subscribers
- Target: $50-80K/month revenue

---

### Pricing Strategy - Psychological Considerations

#### Price Anchoring
```
Remove Ads:     $4.99 ← Anchor (most common)
Cosmetic Pack:  $1.99 ← Feels affordable by comparison
3-Pack Bundle:  $4.99 ← Same as Remove Ads, better value perception
Subscription:   $4.99/mo ← Matches Remove Ads, but recurring value
```

#### Regional Pricing
- US: Standard pricing
- Tier 2 (Europe): -10% adjustment
- Tier 3 (Latin America, Asia): -30% adjustment
- Use App Store automatic pricing tiers

#### Limited-Time Offers
- Launch week: 50% off all IAPs
- Holiday sales: $2.99 Remove Ads (vs $4.99)
- Anniversary: Free cosmetic pack for all users

---

### Monetization KPIs

| Metric | Target | Measurement |
|--------|--------|-------------|
| **ARPU** (Avg Revenue Per User) | $0.50-1.00 | Total revenue ÷ MAU |
| **ARPPU** (Avg Revenue Per Paying User) | $5-10 | Total revenue ÷ paying users |
| **IAP Conversion** | 3-7% | Paying users ÷ total users |
| **Ad Engagement** | 70%+ rewarded, 100% interstitial | Views ÷ impressions |
| **LTV** (Lifetime Value) | $2-5 | Revenue per user over 180 days |
| **Payback Period** | <30 days | Time to recover UA cost |

---

## 🛠️ Implementation Complexity Matrix

### Effort Estimation Guide
- **XS** (1-4 hours): Simple UI, basic logic
- **S** (4-8 hours): Moderate feature, some complexity
- **M** (8-16 hours): Complex feature, integration needed
- **L** (16-40 hours): Major system, multiple components
- **XL** (40+ hours): Platform feature, ongoing maintenance

---

### Gestures - Complexity Breakdown

| Gesture | Effort | Technical Dependencies | Risk Level |
|---------|--------|------------------------|------------|
| Tap | XS | SwiftUI built-in | None |
| Double Tap | XS | SwiftUI built-in | None |
| Long Press | XS | SwiftUI built-in | None |
| Two-Finger Swipe | S | Existing swipe + touch count | Low |
| Pinch | S | SwiftUI MagnificationGesture | Low |
| Rotate | S | SwiftUI RotationGesture | Low |
| **Shake** | **M** | **CoreMotion framework** | **Medium** |
| Tilt | M | CoreMotion + orientation | Medium |
| Voice Commands | M | Speech framework + permissions | Medium |
| Blow/Whistle | L | AVFoundation + audio processing | High |
| Shape Drawing | XL | Vision framework + ML | High |

**Recommendation**: Stick to XS-M complexity for Phase 1-2

---

### Features - Complexity Breakdown

#### Game Modes
| Mode | Effort | Dependencies | Priority |
|------|--------|--------------|----------|
| Endless | S | Existing game loop | P0 |
| Memory | M | Sequence hiding logic | P1 |
| Zen | XS | Timer adjustment | P1 |
| Reverse | S | Sequence reversal | P2 |
| Mirror | M | Gesture mapping | P2 |
| Chaos | L | Randomization + power-ups | P3 |
| Boss Rush | M | Special round logic | P3 |

#### Social Features
| Feature | Effort | Dependencies | Priority |
|---------|--------|--------------|----------|
| Game Center | S | Apple API | P0 |
| Share Score | S | UIActivityViewController | P0 |
| Pass & Play | M | Turn management | P1 |
| Daily Challenges | L | Backend + push notifications | P1 |
| Async Multiplayer | XL | Backend + authentication | P3 |

#### Monetization
| Feature | Effort | Dependencies | Priority | Status |
|---------|--------|--------------|----------|--------|
| AdMob Integration | S | SDK + privacy | P0 | ✅ Complete (Nov 11) |
| Interstitial Ads | XS | AdMob | P0 | ✅ Complete (Nov 12) |
| Rewarded Ads | S | AdMob | P0 | ⏳ Next |
| IAP - Remove Ads | M | StoreKit 2 | P0 | ⏳ Pending |
| IAP - Cosmetics | L | Theme engine + IAP | P1 | ⏳ Pending |
| Subscription | L | StoreKit 2 + backend | P2 | ⏳ Pending |

---

## 📊 Revenue Projections

### Conservative Scenario (Base Case)

#### Assumptions
- Launch month: 1,000 DAU
- Month 3: 5,000 DAU (viral growth from App Store featuring)
- Month 6: 10,000 DAU (steady organic growth)
- Month 12: 15,000 DAU (word-of-mouth)

#### Revenue Model
| Month | DAU | Ad Revenue | IAP Revenue | Subscription | Total | Cumulative |
|-------|-----|------------|-------------|--------------|-------|------------|
| 1 | 1,000 | $600 | $0 | $0 | $600 | $600 |
| 2 | 2,000 | $1,800 | $200 | $0 | $2,000 | $2,600 |
| 3 | 5,000 | $6,000 | $1,500 | $0 | $7,500 | $10,100 |
| 6 | 10,000 | $15,000 | $5,000 | $2,000 | $22,000 | $75,000 |
| 12 | 15,000 | $25,000 | $10,000 | $5,000 | $40,000 | $250,000 |

**Year 1 Total Revenue**: $250K (conservative)

---

### Optimistic Scenario (With Featuring)

#### Assumptions
- App Store featuring Month 2
- Launch month: 5,000 DAU
- Month 3: 50,000 DAU (viral spike)
- Month 6: 75,000 DAU (sustained)
- Month 12: 100,000 DAU

#### Revenue Model
| Month | DAU | Ad Revenue | IAP Revenue | Subscription | Total | Cumulative |
|-------|-----|------------|-------------|--------------|-------|------------|
| 1 | 5,000 | $3,000 | $500 | $0 | $3,500 | $3,500 |
| 2 | 25,000 | $30,000 | $5,000 | $0 | $35,000 | $38,500 |
| 3 | 50,000 | $75,000 | $15,000 | $2,000 | $92,000 | $130,500 |
| 6 | 75,000 | $120,000 | $30,000 | $15,000 | $165,000 | $700,000 |
| 12 | 100,000 | $180,000 | $50,000 | $30,000 | $260,000 | $1.8M |

**Year 1 Total Revenue**: $1.8M (optimistic)

---

### Realistic Scenario (Expected)

#### Middle Ground
- Month 1: 2,000 DAU
- Month 3: 10,000 DAU
- Month 6: 20,000 DAU
- Month 12: 30,000 DAU

**Year 1 Total Revenue**: $500K-750K

---

### Cost Structure

#### Development Costs
- Solo indie dev: $0 (sweat equity)
- Freelance help (art, sound): $5,000
- Marketing: $10,000 (ASO, influencer outreach)
- **Total Dev Cost**: $15,000

#### Ongoing Costs (Monthly)
- Apple Developer Program: $99/year = $8/month
- AdMob (free)
- Backend (Firebase): $0-25 (Spark/Blaze plan)
- Cloud storage: $5-20/month
- **Total Monthly**: $15-50

#### User Acquisition (Optional)
- Apple Search Ads: $1-3 CPI
- Facebook/Instagram: $2-5 CPI
- If spending $5K/month → 1,000-2,500 installs
- Payback: 30-60 days at $2-3 LTV

**Recommendation**: Organic-first strategy, UA only after Product-Market Fit

---

## 🔧 Technical Requirements

### Phase 1 Dependencies

#### Frameworks & Libraries
```swift
// Core
import SwiftUI
import Combine

// Motion
import CoreMotion  // For shake gesture

// Audio
import AVFoundation  // For sound effects

// Persistence
import Foundation  // UserDefaults (current)

// Social
import GameKit  // Game Center leaderboards

// Analytics (recommended)
import Firebase  // Or Mixpanel
```

#### Info.plist Additions
```xml
<!-- Motion Usage -->
<key>NSMotionUsageDescription</key>
<string>Tipob uses motion detection for shake gestures in gameplay</string>

<!-- Microphone (if implementing blow gesture) -->
<key>NSMicrophoneUsageDescription</key>
<string>Tipob uses the microphone to detect blow gestures</string>

<!-- Speech Recognition (if implementing voice commands) -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>Tipob uses speech recognition for voice-controlled gestures</string>
```

---

### Phase 2 Dependencies

#### Monetization SDKs
```swift
// Ads - ✅ IMPLEMENTED (November 11, 2025)
import GoogleMobileAds  // AdMob - TEST mode active
// Files: AdManager.swift, UIViewControllerHelper.swift

// IAP - ⏳ PENDING
import StoreKit  // Native iOS

// Alternative: RevenueCat for subscription management
import RevenueCat
```

#### AdMob Implementation Notes (Current)
- **Status**: TEST credentials active
- **Ad Unit ID**: `ca-app-pub-3940256099942544/4411468910` (TEST)
- **App ID**: `ca-app-pub-3940256099942544~1458002511` (TEST)
- **Integration**: AdManager singleton, UIViewControllerHelper bridge
- **Triggers**: Home + Play Again buttons on all game over screens
- **Current Mode**: Aggressive testing (shows every tap if loaded)
- **Production Readiness**: Requires TEST → production ID swap

#### Backend Requirements
- **Option 1: Firebase** (recommended for indie)
  - Firestore: User data, challenges, leaderboards
  - Cloud Functions: Challenge generation
  - Authentication: Sign in with Apple
  - Cloud Messaging: Push notifications
  - Cost: Free tier → $25-100/month at scale

- **Option 2: Supabase** (alternative)
  - PostgreSQL database
  - Realtime subscriptions
  - Authentication
  - Cost: Free tier → $25/month Pro

- **Option 3: Serverless** (advanced)
  - AWS Lambda + DynamoDB
  - More complex, lower cost at scale
  - Requires DevOps knowledge

**Recommendation**: Firebase for Phase 2, consider migration if costs >$500/month

---

### Phase 3 Dependencies

#### Advanced Features
```swift
// ML/Vision (for shape drawing)
import Vision
import CoreML

// Speech
import Speech

// Background Audio Processing
import AVFoundation
```

#### CI/CD Setup
- **Fastlane**: Automate builds, screenshots, App Store submission
- **TestFlight**: Beta distribution
- **GitHub Actions**: Automated testing on push

---

### Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| **App Launch** | <2s | Time to interactive |
| **Frame Rate** | 60fps | During gameplay |
| **Memory** | <100MB | Peak usage |
| **Battery Drain** | <5%/hour | With motion enabled |
| **App Size** | <50MB | Download size |
| **Crash Rate** | <0.5% | Per session |

**Optimization Priorities**:
1. SwiftUI view caching
2. Motion sensor throttling (10Hz vs 60Hz)
3. Image compression for cosmetics
4. Lazy loading for packs

---

## ⚠️ Risk Assessment

### Technical Risks

#### High Risk 🔴
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Shake gesture battery drain** | High | Medium | Throttle to 10Hz, auto-disable after 5min idle |
| **Timer memory leaks** | Medium | High | Deinit cleanup, audit with Instruments |
| **IAP receipt fraud** | Medium | High | Server-side validation via RevenueCat |
| **Ad revenue volatility** | High | Medium | Diversify with IAP early |

#### Medium Risk 🟡
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **App Store rejection** | Low | High | Follow guidelines, test on device, review checklist |
| **Backend costs spike** | Medium | Medium | Implement rate limiting, usage caps |
| **Gesture false positives** | Medium | Low | Calibration settings, sensitivity adjustment |
| **Device fragmentation** | Low | Medium | Test on iPhone SE (2nd gen) as minimum |

---

### Business Risks

#### High Risk 🔴
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **No App Store featuring** | High | High | Organic growth via social sharing, influencer outreach |
| **Clone apps** | Medium | Medium | Build brand loyalty, fast iteration on feedback |
| **Market saturation** | Medium | Medium | Unique positioning (progression system, cosmetics) |

#### Medium Risk 🟡
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Low user retention** | Medium | High | Daily challenges, progression hooks, push notifications |
| **Negative reviews** | Low | High | Beta testing, polish before launch, responsive support |
| **Monetization backlash** | Low | Medium | Generous free experience, transparent pricing |

---

### Regulatory Risks

#### Privacy & Compliance
- **COPPA**: Don't collect data from <13yr olds (age gate on first launch)
- **GDPR**: Consent for ads (IDFA), data deletion requests
- **CCPA**: California privacy rights, opt-out of data sales
- **App Tracking Transparency**: Request permission for IDFA (iOS 14.5+)

**Implementation**:
```swift
import AppTrackingTransparency

func requestTrackingPermission() {
    ATTrackingManager.requestTrackingAuthorization { status in
        switch status {
        case .authorized:
            // Enable personalized ads
        case .denied:
            // Contextual ads only
        default:
            break
        }
    }
}
```

---

## 🎯 Decision Framework

### Feature Prioritization Matrix

#### Scoring System (0-10)
1. **User Value**: Does this delight users?
2. **Business Impact**: Does this drive revenue/retention?
3. **Implementation Ease**: Can we build this quickly?
4. **Competitive Advantage**: Does this differentiate us?

#### Priority Formula
```
Priority Score = (User Value × 2) + (Business Impact × 1.5) + (Ease × 1) + (Advantage × 1.5)
```

#### Example Scoring

| Feature | User Value | Business | Ease | Advantage | **Total** | Priority |
|---------|------------|----------|------|-----------|-----------|----------|
| Tap Gesture | 8 | 6 | 10 | 2 | **43** | P0 |
| Shake Gesture | 10 | 7 | 5 | 8 | **52** | P0 |
| Daily Challenges | 9 | 9 | 4 | 7 | **51.5** | P0 |
| Voice Commands | 6 | 3 | 5 | 9 | **38** | P2 |
| Shape Drawing | 5 | 2 | 1 | 10 | **30** | P4 |

---

### Phase Gate Criteria

#### Launch Phase 1 When:
- [ ] 5+ gestures implemented (swipes + 3 new)
- [ ] 2+ game modes beyond classic
- [ ] Game Center leaderboards live
- [ ] Sound effects + settings menu
- [ ] 0 crash rate in TestFlight (50+ testers)
- [ ] Privacy compliance verified
- [ ] App Store assets complete

#### Launch Phase 2 When:
- [ ] Phase 1 retention >40% D1, >15% D7
- [ ] Ads integrated and revenue >$1K/month
- [ ] 1+ cosmetic pack available
- [ ] Progression system live
- [ ] Daily challenge system tested
- [ ] IAP conversion >2%

#### Launch Phase 3 When:
- [ ] Phase 2 MAU >10,000
- [ ] Subscription tech validated (0 receipt issues)
- [ ] Multiplayer tested with real users
- [ ] Backend costs <20% of revenue
- [ ] Support volume manageable (<10 tickets/day)

---

## 📝 Next Steps Checklist

### Immediate (This Week)
- [x] Review this document, highlight questions ✅
- [x] Choose Phase 1 gesture additions (recommend: tap, double tap, shake) ✅ 14 gestures complete
- [x] Decide on 2 game modes to prioritize (recommend: Endless, Memory) ✅ All modes complete
- [ ] Set up Game Center in App Store Connect
- [ ] Create mockups for settings menu
- [x] Implement AdMob integration ✅ Complete (Nov 11-12, 2025)
- [ ] **CRITICAL**: Transition from TEST to production Ad IDs before launch
- [ ] Implement rewarded video ads (continue after game over)
- [ ] Build "Remove Ads" IAP ($4.99)

### Short-Term (This Month)
- [ ] Implement Priority 1 fixes from code analysis
- [ ] Build Phase 1 features
- [ ] Record sound effects or commission from Fiverr ($50-100)
- [ ] Set up Firebase project for analytics
- [ ] Create TestFlight beta group (friends & family)

### Medium-Term (Next 3 Months)
- [ ] Complete Phase 1 development
- [ ] Soft launch in 1-2 countries (e.g., Canada, Australia)
- [ ] Iterate based on feedback
- [ ] Prepare App Store marketing materials
- [ ] Plan Phase 2 monetization implementation

---

## 📚 Resources & References

### Development Resources
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Game Center Best Practices](https://developer.apple.com/game-center/)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)

### Monetization Resources
- [AdMob Integration Guide](https://developers.google.com/admob/ios/quick-start)
- [RevenueCat Subscription Guide](https://www.revenuecat.com/docs/)
- [App Store Pricing Matrix](https://developer.apple.com/app-store/pricing/)

### Analytics & Growth
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [ASO Best Practices](https://developer.apple.com/app-store/search/)
- [Mobile Game Benchmarks](https://www.gamesight.io/blog/mobile-game-benchmarks)

---

## 🔄 Document Revision History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-10-10 | Initial scoping document | Claude Code |
| 2.0 | 2025-10-21 | Updated implementation status: 7 gestures complete (4 swipes + 3 touch), Memory Mode 🧠 and Game vs Player vs Player 👥 complete | Claude Code |
| 3.0 | 2025-10-27 | Updated to 8 gestures (added Pinch 🤏 via native UIKit), Phase 1 MVP complete, added gesture roadmap with priorities | Claude Code |
| 4.0 | 2025-11-10 | Added 7 new gestures (shake, tilt L/R, raise, lower, Stroop), implemented Discreet Mode, Leaderboard System, MotionGestureManager, completed gesture optimization (Option 1), documented Options 2 & 3 | Claude Code |
| 4.1 | 2025-11-12 | Added Google AdMob integration (TEST mode), AdManager singleton, UIViewControllerHelper, Info.plist configuration, 49 SKAdNetwork identifiers, aggressive testing mode (ads on every tap), updated monetization roadmap | Claude Code |

---

**Document Status**: ✅ Phase 1 Complete with Performance Optimization + Monetization (TEST)
**Document Version**: 4.1
**Last Updated**: 2025-11-12
**Next Review Date**: Before production Ad ID transition
**Owner**: Marc Geraldez

---

## 💬 Questions for Decision Making

Use this section to track open questions as you review:

1. **Gesture Priority**: Which 3 gestures for Phase 1?
   - [ ] Decision: __________

2. **Monetization First**: Ads or IAP first? Or both simultaneously?
   - [ ] Decision: __________

3. **Backend Choice**: Firebase vs. Supabase vs. delay until Phase 3?
   - [ ] Decision: __________

4. **Target Launch Date**: Soft launch target?
   - [ ] Decision: __________

5. **Marketing Budget**: Self-funded or seeking investment?
   - [ ] Decision: __________

---

**END OF DOCUMENT**
