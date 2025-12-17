import Foundation

/// Coordinates gesture detection to prevent conflicting gestures from interfering
/// Used primarily in Tutorial Mode to suppress incidental motion during expected gestures
/// Also manages pinch intent locking to give pinch priority over swipe in game modes
class GestureCoordinator {
    static let shared = GestureCoordinator()

    /// The gesture currently expected by the game (Tutorial Mode sets this)
    var expectedGesture: GestureType? = nil

    /// True when strict gesture detection is active (Tutorial mode)
    /// Use this instead of checking `expectedGesture != nil` for cleaner semantics
    var isStrictGestureMode: Bool {
        expectedGesture != nil
    }

    // MARK: - Pinch Intent Locking (Game Modes Only)

    /// Whether pinch intent is currently locked (suppresses swipe)
    private var isPinchIntentLocked: Bool = false

    /// When pinch intent lock started (for timeout)
    private var pinchIntentLockTime: Date? = nil

    // MARK: - Hold Intent Locking (Long Press Priority)

    /// Whether hold intent is currently locked (suppresses swipe during potential long press)
    private var isHoldIntentLocked: Bool = false

    /// When hold intent lock started (for timeout)
    private var holdIntentLockTime: Date? = nil

    private init() {}

    // MARK: - Pinch Intent Methods

    /// Called when UIPinchGestureRecognizer enters .began state
    /// Locks pinch intent to give pinch priority over swipe for a short window
    func beginPinchIntent() {
        // Strict mode (Tutorial) uses strict detection - skip locking
        guard !isStrictGestureMode else { return }

        #if DEBUG || TESTFLIGHT
        guard DevConfigManager.shared.pinchIntentLockEnabled else { return }
        #endif

        isPinchIntentLocked = true
        pinchIntentLockTime = Date()
        print("[\(Date().logTimestamp)] 🔒 Pinch intent locked")
    }

    /// Called when pinch gesture ends or triggers successfully
    func endPinchIntent() {
        guard isPinchIntentLocked else { return }
        isPinchIntentLocked = false
        pinchIntentLockTime = nil
        print("[\(Date().logTimestamp)] 🔓 Pinch intent released")
    }

    // MARK: - Hold Intent Methods

    /// Called when a touch begins (potential long press)
    /// Locks hold intent to give long press priority over swipe
    func beginHoldIntent() {
        // Strict mode (Tutorial) uses strict detection - skip locking
        guard !isStrictGestureMode else { return }

        #if DEBUG || TESTFLIGHT
        guard DevConfigManager.shared.holdIntentLockEnabled else { return }
        #endif

        isHoldIntentLocked = true
        holdIntentLockTime = Date()
        print("[\(Date().logTimestamp)] 🔒 Hold intent locked (long press priority)")
    }

    /// Called when long press completes or touch ends
    func endHoldIntent() {
        guard isHoldIntentLocked else { return }
        isHoldIntentLocked = false
        holdIntentLockTime = nil
        print("[\(Date().logTimestamp)] 🔓 Hold intent released")
    }

    // MARK: - Reset All Intents

    /// Resets all intent locks - call on mode/phase transitions
    /// Prevents stale locks from blocking gestures after navigation
    func resetAllIntents() {
        isHoldIntentLocked = false
        holdIntentLockTime = nil
        isPinchIntentLocked = false
        pinchIntentLockTime = nil
        expectedGesture = nil
        print("[\(Date().logTimestamp)] 🔄 GestureCoordinator: All intents reset")
    }

    /// Called by SwipeGestureModifier before triggering swipe
    /// Returns false if swipe should be suppressed due to hold intent
    func shouldAllowSwipeDuringHold() -> Bool {
        // CRITICAL: Never block swipe when swipe is the expected gesture
        if let expected = expectedGesture, expected.isSwipeGesture {
            return true
        }

        // Strict mode (Tutorial) - allow swipe
        guard !isStrictGestureMode else { return true }

        // Not locked - allow swipe
        guard isHoldIntentLocked else { return true }

        // Check if lock has expired (matches long press duration)
        if let lockTime = holdIntentLockTime {
            #if DEBUG || TESTFLIGHT
            let lockDuration = DevConfigManager.shared.holdIntentLockDuration
            #else
            let lockDuration: TimeInterval = 0.7  // Match long press duration
            #endif

            let elapsed = Date().timeIntervalSince(lockTime)
            if elapsed > lockDuration {
                endHoldIntent()
                return true
            }
        }

        return false  // Suppress swipe while hold intent is locked
    }

    /// Called by SwipeGestureModifier before triggering swipe
    /// Returns false if swipe should be suppressed due to pinch intent
    func shouldAllowSwipeDuringPinch() -> Bool {
        // CRITICAL: Never block swipe when swipe is the expected gesture
        // This must come FIRST to ensure swipes always work when expected
        if let expected = expectedGesture, expected.isSwipeGesture {
            return true
        }

        // Strict mode (Tutorial) - allow swipe (strict behavior preserved)
        guard !isStrictGestureMode else { return true }

        // Not locked - allow swipe
        guard isPinchIntentLocked else { return true }

        // Check if lock has expired
        if let lockTime = pinchIntentLockTime {
            #if DEBUG || TESTFLIGHT
            let lockDuration = DevConfigManager.shared.pinchIntentLockDuration
            #else
            let lockDuration: TimeInterval = 0.15
            #endif

            let elapsed = Date().timeIntervalSince(lockTime)
            if elapsed > lockDuration {
                endPinchIntent()
                return true
            }
        }

        return false  // Suppress swipe while pinch intent is locked
    }

    // MARK: - Gesture Filtering

    /// Determines if a detected gesture should be allowed to trigger
    /// - Parameter detected: The gesture type that was just detected
    /// - Returns: true if gesture should fire, false if it should be suppressed
    func shouldAllowGesture(_ detected: GestureType) -> Bool {
        // If no expected gesture is set, allow everything (real game modes)
        guard let expected = expectedGesture else {
            return true
        }

        // Always allow the expected gesture
        if detected == expected {
            return true
        }

        // Block gestures that conflict with the expected gesture
        if conflictsWith(detected, expected) {
            print("🚫 Gesture suppressed: \(detected.displayName) (expecting \(expected.displayName))")
            return false
        }

        // Allow non-conflicting gestures
        return true
    }

    /// Defines which gesture pairs conflict with each other
    /// - Parameters:
    ///   - detected: The gesture that was just detected
    ///   - expected: The gesture that is currently expected
    /// - Returns: true if these gestures conflict (one should suppress the other)
    private func conflictsWith(_ detected: GestureType, _ expected: GestureType) -> Bool {
        // Swipe Down/Up can accidentally trigger Tilt due to natural phone movement
        if (expected == .down || expected == .up) && (detected == .tiltLeft || detected == .tiltRight) {
            return true
        }

        // Tilt Left/Right can accidentally trigger Swipe Down/Up
        if (expected == .tiltLeft || expected == .tiltRight) && (detected == .down || detected == .up) {
            return true
        }

        // Swipe Left/Right can accidentally trigger Raise/Lower
        if (expected == .left || expected == .right) && (detected == .raise || detected == .lower) {
            return true
        }

        // Raise/Lower can accidentally trigger Swipe Left/Right
        if (expected == .raise || expected == .lower) && (detected == .left || detected == .right) {
            return true
        }

        // Shake can accidentally trigger Raise/Lower due to vigorous motion
        if expected == .shake && (detected == .raise || detected == .lower) {
            return true
        }

        // Raise/Lower can accidentally trigger Shake
        if (expected == .raise || expected == .lower) && detected == .shake {
            return true
        }

        // No conflict
        return false
    }

    /// Clears the expected gesture (call after gesture is successfully detected)
    func clearExpectedGesture() {
        expectedGesture = nil
    }
}
