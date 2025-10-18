import Foundation

enum GestureType: CaseIterable {
    case up
    case down
    case left
    case right
    case tap

    var symbol: String {
        switch self {
        case .up: return "↑"
        case .down: return "↓"
        case .left: return "←"
        case .right: return "→"
        case .tap: return "⊙"
        }
    }

    var color: String {
        switch self {
        case .up: return "blue"
        case .down: return "green"
        case .left: return "red"
        case .right: return "yellow"
        case .tap: return "purple"
        }
    }

    var displayName: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        case .left: return "Left"
        case .right: return "Right"
        case .tap: return "Tap"
        }
    }
}
