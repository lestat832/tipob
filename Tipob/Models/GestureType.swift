import Foundation

enum GestureType: CaseIterable {
    case up
    case down
    case left
    case right
    case tap
    case doubleTap
    case longPress
    case pinch
    // case spread  // SPREAD: Temporarily disabled - detection issues with close finger start
    case shake
    case tiltLeft
    case tiltRight
    case raise
    case lower

    var symbol: String {
        switch self {
        case .up: return "↑"
        case .down: return "↓"
        case .left: return "←"
        case .right: return "→"
        case .tap: return "⊙"
        case .doubleTap: return "◎"
        case .longPress: return "⏺"
        case .pinch: return "🤏"
        // case .spread: return "🫱🫲"  // SPREAD: Temporarily disabled
        case .shake: return "📳"
        case .tiltLeft: return "◀"
        case .tiltRight: return "▶"
        case .raise: return "⬆️"
        case .lower: return "⬇️"
        }
    }

    var color: String {
        switch self {
        case .up: return "blue"
        case .down: return "green"
        case .left: return "red"
        case .right: return "orange"
        case .tap: return "yellow"
        case .doubleTap: return "cyan"
        case .longPress: return "magenta"
        case .pinch: return "indigo"
        // case .spread: return "purple"  // SPREAD: Temporarily disabled
        case .shake: return "teal"
        case .tiltLeft: return "purple"
        case .tiltRight: return "brown"
        case .raise: return "mint"  // Light green
        case .lower: return "orange"
        }
    }

    var displayName: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        case .left: return "Left"
        case .right: return "Right"
        case .tap: return "Tap"
        case .doubleTap: return "Double Tap"
        case .longPress: return "Long Press"
        case .pinch: return "Pinch"
        // case .spread: return "Spread"  // SPREAD: Temporarily disabled
        case .shake: return "Shake"
        case .tiltLeft: return "Tilt Left"
        case .tiltRight: return "Tilt Right"
        case .raise: return "Raise"
        case .lower: return "Lower"
        }
    }

    var animationStyle: AnimationStyle {
        switch self {
        case .tap: return .singlePulse
        case .doubleTap: return .doublePulse
        case .longPress: return .fillGlow
        case .pinch: return .compress
        // case .spread: return .expand  // SPREAD: Temporarily disabled
        case .shake: return .vibrate
        case .tiltLeft: return .tiltLeft
        case .tiltRight: return .tiltRight
        case .raise: return .raiseUp
        case .lower: return .lowerDown
        default: return .singlePulse
        }
    }

    enum AnimationStyle {
        case singlePulse
        case doublePulse
        case fillGlow
        case compress
        // case expand  // SPREAD: Temporarily disabled
        case vibrate
        case tiltLeft
        case tiltRight
        case raiseUp
        case lowerDown
    }
}
