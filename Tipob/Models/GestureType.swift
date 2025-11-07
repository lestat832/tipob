import Foundation

enum GestureType: Equatable {
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
    case stroop(
        wordColor: ColorType,      // The word to display (e.g., "RED")
        textColor: ColorType,      // The color the word is displayed in
        upColor: ColorType,        // Which color is assigned to UP direction
        downColor: ColorType,      // Which color is assigned to DOWN direction
        leftColor: ColorType,      // Which color is assigned to LEFT direction
        rightColor: ColorType      // Which color is assigned to RIGHT direction
    )

    /// All basic gestures (excluding Stroop) for random selection
    static var allBasicGestures: [GestureType] {
        return [.up, .down, .left, .right, .tap, .doubleTap, .longPress,
                .pinch, .shake, .tiltLeft, .tiltRight, .raise, .lower]
    }

    /// Generates a random Stroop gesture with mismatched word and text colors
    /// and randomly assigns the 4 colors to the 4 directions
    static func randomStroop() -> GestureType {
        let allColors = ColorType.allCases
        let wordColor = allColors.randomElement()!
        var textColor = allColors.randomElement()!

        // Ensure word and text colors are different (creates the Stroop effect)
        while textColor == wordColor {
            textColor = allColors.randomElement()!
        }

        // Shuffle all 4 colors and assign to the 4 directions
        let shuffledColors = allColors.shuffled()

        return .stroop(
            wordColor: wordColor,
            textColor: textColor,
            upColor: shuffledColors[0],
            downColor: shuffledColors[1],
            leftColor: shuffledColors[2],
            rightColor: shuffledColors[3]
        )
    }

    /// Returns a random gesture with equal distribution across all 14 types
    /// Each gesture (13 basic + 1 Stroop) has 1/14 (~7.14%) probability
    static func random() -> GestureType {
        var pool = allBasicGestures  // 13 basic gestures
        pool.append(.randomStroop()) // Add 1 Stroop instance
        return pool.randomElement()! // Equal 1/14 chance for each
    }

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
        case .stroop: return "🎨"
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
        case .stroop: return "rainbow"
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
        case .stroop: return "Color-Swipe"
        }
    }

    var instructionText: String {
        switch self {
        case .up, .down, .left, .right:
            return "Swipe!"
        case .tap:
            return "Tap!"
        case .doubleTap:
            return "Double Tap!"
        case .longPress:
            return "Long Press!"
        case .pinch:
            return "Pinch!"
        case .shake:
            return "Shake!"
        case .tiltLeft, .tiltRight:
            return "Tilt!"
        case .raise:
            return "Raise!"
        case .lower:
            return "Lower!"
        case .stroop:
            return "Swipe Color!"
        }
    }

    /// Returns true if this gesture requires motion detection (shake, tilt, raise, lower)
    var isMotionGesture: Bool {
        switch self {
        case .shake, .tiltLeft, .tiltRight, .raise, .lower:
            return true
        default:
            return false
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
        case .stroop: return .stroopFlash
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
        case stroopFlash
    }
}
