import Foundation
import SwiftUI

enum GestureType: Equatable, Hashable, Codable {
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

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case type
        case wordColor, textColor, upColor, downColor, leftColor, rightColor
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "up": self = .up
        case "down": self = .down
        case "left": self = .left
        case "right": self = .right
        case "tap": self = .tap
        case "doubleTap": self = .doubleTap
        case "longPress": self = .longPress
        case "pinch": self = .pinch
        case "shake": self = .shake
        case "tiltLeft": self = .tiltLeft
        case "tiltRight": self = .tiltRight
        case "raise": self = .raise
        case "lower": self = .lower
        case "stroop":
            let wordColor = try container.decode(ColorType.self, forKey: .wordColor)
            let textColor = try container.decode(ColorType.self, forKey: .textColor)
            let upColor = try container.decode(ColorType.self, forKey: .upColor)
            let downColor = try container.decode(ColorType.self, forKey: .downColor)
            let leftColor = try container.decode(ColorType.self, forKey: .leftColor)
            let rightColor = try container.decode(ColorType.self, forKey: .rightColor)
            self = .stroop(wordColor: wordColor, textColor: textColor, upColor: upColor,
                          downColor: downColor, leftColor: leftColor, rightColor: rightColor)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container,
                                                    debugDescription: "Unknown gesture type: \(type)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .up: try container.encode("up", forKey: .type)
        case .down: try container.encode("down", forKey: .type)
        case .left: try container.encode("left", forKey: .type)
        case .right: try container.encode("right", forKey: .type)
        case .tap: try container.encode("tap", forKey: .type)
        case .doubleTap: try container.encode("doubleTap", forKey: .type)
        case .longPress: try container.encode("longPress", forKey: .type)
        case .pinch: try container.encode("pinch", forKey: .type)
        case .shake: try container.encode("shake", forKey: .type)
        case .tiltLeft: try container.encode("tiltLeft", forKey: .type)
        case .tiltRight: try container.encode("tiltRight", forKey: .type)
        case .raise: try container.encode("raise", forKey: .type)
        case .lower: try container.encode("lower", forKey: .type)
        case .stroop(let wordColor, let textColor, let upColor, let downColor, let leftColor, let rightColor):
            try container.encode("stroop", forKey: .type)
            try container.encode(wordColor, forKey: .wordColor)
            try container.encode(textColor, forKey: .textColor)
            try container.encode(upColor, forKey: .upColor)
            try container.encode(downColor, forKey: .downColor)
            try container.encode(leftColor, forKey: .leftColor)
            try container.encode(rightColor, forKey: .rightColor)
        }
    }

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

    var color: Color {
        switch self {
        case .up: return .toyBoxUp
        case .down: return .toyBoxDown
        case .left: return .toyBoxLeft
        case .right: return .toyBoxRight
        case .tap: return .toyBoxTap
        case .doubleTap: return .toyBoxDoubleTap
        case .longPress: return .toyBoxLongPress
        case .pinch: return .toyBoxPinch
        // case .spread: return .purple  // SPREAD: Temporarily disabled
        case .shake: return .toyBoxShake
        case .tiltLeft: return .toyBoxTiltLeft
        case .tiltRight: return .toyBoxTiltRight
        case .raise: return .toyBoxRaise
        case .lower: return .toyBoxLower
        case .stroop: return .toyBoxUp  // Stroop uses directional color based on context
        }
    }

    var displayName: String {
        switch self {
        case .up: return "Swipe Up"
        case .down: return "Swipe Down"
        case .left: return "Swipe Left"
        case .right: return "Swipe Right"
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
        case .stroop: return "Stroop"
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

    /// Returns true if this gesture is a swipe direction (up, down, left, right)
    var isSwipeGesture: Bool {
        switch self {
        case .up, .down, .left, .right:
            return true
        default:
            return false
        }
    }

    /// For Stroop gestures, returns the correct swipe direction based on textColor
    /// Returns nil for non-Stroop gestures
    var stroopCorrectAnswer: GestureType? {
        guard case .stroop(_, let textColor, let upColor, let downColor, let leftColor, let rightColor) = self else {
            return nil
        }

        if textColor == upColor { return .up }
        if textColor == downColor { return .down }
        if textColor == leftColor { return .left }
        if textColor == rightColor { return .right }

        return nil  // Should never happen if Stroop is properly configured
    }

    /// Checks if a detected gesture is the correct response for this expected gesture
    /// Handles Stroop specially by checking if the swipe matches the textColor direction
    func isCorrectResponse(_ detected: GestureType) -> Bool {
        // Special handling for Stroop
        if case .stroop = self {
            return detected == stroopCorrectAnswer
        }

        // For all other gestures, simple equality check
        return detected == self
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

    /// Analytics-friendly string for event parameters
    var analyticsValue: String {
        switch self {
        case .up: return "up"
        case .down: return "down"
        case .left: return "left"
        case .right: return "right"
        case .tap: return "tap"
        case .doubleTap: return "double_tap"
        case .longPress: return "long_press"
        case .pinch: return "pinch"
        case .shake: return "shake"
        case .tiltLeft: return "tilt_left"
        case .tiltRight: return "tilt_right"
        case .raise: return "raise"
        case .lower: return "lower"
        case .stroop: return "stroop"
        }
    }
}
