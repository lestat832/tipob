import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case tutorial = "Tutorial"
    case gameVsPlayerVsPlayer = "Game vs Player vs Player"
    case playerVsPlayer = "Player vs Player"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .classic:
            return "🎯"
        case .tutorial:
            return "🎓"
        case .gameVsPlayerVsPlayer:
            return "🎮"
        case .playerVsPlayer:
            return "👥"
        }
    }

    var description: String {
        switch self {
        case .classic:
            return "Beat your best streak"
        case .tutorial:
            return "Learn the gestures"
        case .gameVsPlayerVsPlayer:
            return "Coming soon"
        case .playerVsPlayer:
            return "Coming soon"
        }
    }
}
