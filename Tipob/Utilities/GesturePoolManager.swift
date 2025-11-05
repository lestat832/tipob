import Foundation

/// Manages gesture pools for different play modes
/// Provides filtered gesture sets based on discreet mode setting
class GesturePoolManager {

    // MARK: - Gesture Pools

    /// Returns discreet gestures (touch-only, no physical device movement)
    /// Includes: swipes, taps, pinch, and stroop
    /// Excludes: shake, tilt, raise, lower
    static func discreetGestures() -> [GestureType] {
        let gestures: [GestureType] = [
            .up,
            .down,
            .left,
            .right,
            .tap,
            .doubleTap,
            .longPress,
            .pinch,
            .randomStroop()  // Stroop included in discreet mode
        ]

        // Note: Spread is temporarily disabled in GestureType
        // If re-enabled, add it here: gestures.append(.spread)

        return gestures
    }

    /// Returns all gestures (unhinged mode)
    /// Includes ALL gesture types including physical device movements
    static func unhingedGestures() -> [GestureType] {
        var gestures = GestureType.allBasicGestures  // All 13 basic gestures
        gestures.append(.randomStroop())  // Add Stroop
        return gestures
    }

    /// Returns filtered gestures based on discreet mode setting
    /// - Parameter discreetMode: Whether discreet mode is enabled
    /// - Returns: Appropriate gesture pool
    static func gestures(forDiscreetMode discreetMode: Bool) -> [GestureType] {
        return discreetMode ? discreetGestures() : unhingedGestures()
    }

    /// Returns filtered gestures without Stroop
    /// Used for Memory Mode, Game vs PvP Mode, and PvP Build Mode
    /// Excludes Stroop gesture regardless of discreet mode setting
    /// - Parameter discreetMode: Whether discreet mode is enabled
    /// - Returns: Gesture pool without Stroop
    static func gesturesWithoutStroop(discreetMode: Bool) -> [GestureType] {
        let baseGestures = gestures(forDiscreetMode: discreetMode)
        // Filter out Stroop gestures
        return baseGestures.filter { gesture in
            if case .stroop = gesture {
                return false
            }
            return true
        }
    }

    // MARK: - Helper Methods

    /// Checks if a gesture is a Stroop gesture
    /// - Parameter gesture: The gesture to check
    /// - Returns: True if the gesture is a Stroop gesture
    static func isStroop(_ gesture: GestureType) -> Bool {
        if case .stroop = gesture {
            return true
        }
        return false
    }

    /// Returns all gestures for Tutorial mode (always uses full set)
    /// Tutorial mode ignores discreet mode setting
    static func tutorialGestures() -> [GestureType] {
        // Tutorial always teaches all gestures
        return [
            .up, .down, .left, .right,
            .tap, .doubleTap, .longPress,
            .pinch,
            .shake,
            .tiltLeft, .tiltRight,
            .raise, .lower,
            .randomStroop()
        ]
    }
}
