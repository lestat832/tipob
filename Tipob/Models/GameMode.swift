import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case memory = "Memory"
    case tutorial = "Tutorial"
    case gameVsPlayerVsPlayer = "Game vs Player vs Player"
    case playerVsPlayer = "Player vs Player"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .classic:
            return "⚡"
        case .memory:
            return "🧠"
        case .tutorial:
            return "🎓"
        case .gameVsPlayerVsPlayer:
            return "👥"
        case .playerVsPlayer:
            return "⚔️"
        }
    }

    var description: String {
        switch self {
        case .classic:
            return "React fast! Copy gestures before time runs out — it gets faster every few rounds."
        case .memory:
            return "Watch and repeat the growing sequence — how long can you remember?"
        case .tutorial:
            return "Learn the gestures"
        case .gameVsPlayerVsPlayer:
            return "Take turns repeating the growing gesture sequence. One mistake and the other wins!"
        case .playerVsPlayer:
            return "Take turns repeating and expanding a gesture chain. The first to mess up loses!"
        }
    }
}
