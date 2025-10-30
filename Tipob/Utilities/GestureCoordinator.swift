import Foundation

/// Coordinates gesture detection to prevent conflicting gestures from interfering
/// Used primarily in Tutorial Mode to suppress incidental motion during expected gestures
class GestureCoordinator {
    static let shared = GestureCoordinator()

    /// The gesture currently expected by the game (Tutorial Mode sets this)
    var expectedGesture: GestureType? = nil

    private init() {}

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
