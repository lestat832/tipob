import Foundation

enum GameMode: String, CaseIterable, Identifiable {
    case tutorial = "Tutorial"
    case classic = "Classic"
    case memory = "Memory"
    case gameVsPlayerVsPlayer = "Pass & Play"
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

    /// Short display name for compact UI (segmented controls)
    var shortName: String {
        switch self {
        case .tutorial: return "Tutorial"
        case .classic: return "Classic"
        case .memory: return "Memory"
        case .gameVsPlayerVsPlayer: return "Pass & Play"
        case .playerVsPlayer: return "PvP"
        }
    }

    /// Analytics-friendly lowercase string for event parameters
    var analyticsValue: String {
        switch self {
        case .tutorial: return "tutorial"
        case .classic: return "classic"
        case .memory: return "memory"
        case .gameVsPlayerVsPlayer: return "gvpvp"
        case .playerVsPlayer: return "pvp"
        }
    }
}
