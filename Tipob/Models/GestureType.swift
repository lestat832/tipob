import Foundation
import SwiftUI

enum GestureType: CaseIterable {
    // Directional Swipes
    case up
    case down
    case left
    case right

    // Touch Gestures
    case tap
    case doubleTap
    case longPress
    case twoFingerSwipe

    var symbol: String {
        switch self {
        case .up: return "↑"
        case .down: return "↓"
        case .left: return "←"
        case .right: return "→"
        case .tap: return "⊕"
        case .doubleTap: return "⊕⊕"
        case .longPress: return "⊙"
        case .twoFingerSwipe: return "↕↕"
        }
    }

    var color: String {
        switch self {
        case .up: return "blue"
        case .down: return "green"
        case .left: return "red"
        case .right: return "yellow"
        case .tap: return "purple"
        case .doubleTap: return "orange"
        case .longPress: return "cyan"
        case .twoFingerSwipe: return "pink"
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .up: return .blue
        case .down: return .green
        case .left: return .red
        case .right: return .yellow
        case .tap: return .purple
        case .doubleTap: return .orange
        case .longPress: return .cyan
        case .twoFingerSwipe: return .pink
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
        case .twoFingerSwipe: return "Two Finger Swipe"
        }
    }
}