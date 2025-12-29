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
        case .tutorial:
            return "Learn the basics"
        case .classic:
            return "React fast! Speed increases every round."
        case .memory:
            return "Memorize and repeat. How far can you go?"
        case .gameVsPlayerVsPlayer:
            return "Copy what the game shows. Miss one and your friend wins!"
        case .playerVsPlayer:
            return "Head-to-head. One mistake ends it all."
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
