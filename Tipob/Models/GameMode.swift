import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case gameVsPlayerVsPlayer = "Game vs Player vs Player"
    case playerVsPlayer = "Player vs Player"
    case practice = "Practice"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .classic:
            return "🎯"
        case .gameVsPlayerVsPlayer:
            return "🎮"
        case .playerVsPlayer:
            return "👥"
        case .practice:
            return "🏋️"
        }
    }

    var description: String {
        switch self {
        case .classic:
            return "Beat your best streak"
        case .gameVsPlayerVsPlayer:
            return "Coming soon"
        case .playerVsPlayer:
            return "Coming soon"
        case .practice:
            return "Coming soon"
        }
    }
}
