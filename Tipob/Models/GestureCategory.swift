import Foundation

/// Categories for grouping gestures in the gesture drawer
enum GestureCategory: String, CaseIterable {
    case touch = "TOUCH GESTURES"
    case motion = "MOTION GESTURES"
    case cognitive = "COGNITIVE GESTURES"

    var emoji: String {
        switch self {
        case .touch: return "👆"
        case .motion: return "📱"
        case .cognitive: return "🧠"
        }
    }

    /// Returns gestures for this category (basic gestures only, no Stroop variants)
    var gestures: [GestureType] {
        switch self {
        case .touch:
            return [.up, .down, .left, .right, .tap, .doubleTap, .longPress, .pinch]
        case .motion:
            return [.shake, .tiltLeft, .tiltRight, .raise, .lower]
        case .cognitive:
            // Return a placeholder Stroop for display purposes
            return [.stroop(
                wordColor: .red,
                textColor: .blue,
                upColor: .blue,
                downColor: .yellow,
                leftColor: .red,
                rightColor: .green
            )]
        }
    }

    /// Returns gestures grouped by category, filtered by mode settings
    /// - Parameters:
    ///   - discreetMode: When true, excludes motion gestures (touch-only)
    ///   - includeStroop: When true, includes cognitive/stroop category
    /// - Returns: Array of tuples containing category and its gestures
    static func filteredGestures(
        forDiscreetMode discreetMode: Bool,
        includeStroop: Bool
    ) -> [(category: GestureCategory, gestures: [GestureType])] {
        var result: [(category: GestureCategory, gestures: [GestureType])] = []

        // Touch gestures - always included (8 gestures)
        result.append((.touch, GestureCategory.touch.gestures))

        // Motion gestures - excluded in discreet mode (5 gestures)
        if !discreetMode {
            result.append((.motion, GestureCategory.motion.gestures))
        }

        // Cognitive gestures - optional, controlled by includeStroop (1 gesture)
        if includeStroop {
            result.append((.cognitive, GestureCategory.cognitive.gestures))
        }

        return result
    }
}
