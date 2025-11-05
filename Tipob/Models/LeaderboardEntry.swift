import Foundation

/// Represents a single entry in a game mode leaderboard
/// Stores score, timestamp, and optional player identification
struct LeaderboardEntry: Identifiable, Codable, Equatable {
    /// Unique identifier for this entry
    let id: UUID

    /// The score achieved in this game
    let score: Int

    /// When this score was achieved
    let timestamp: Date

    /// Optional player name (for future multiplayer support)
    let playerName: String?

    /// Initialize a new leaderboard entry
    /// - Parameters:
    ///   - score: The score achieved
    ///   - playerName: Optional player name
    init(score: Int, playerName: String? = nil) {
        self.id = UUID()
        self.score = score
        self.timestamp = Date()
        self.playerName = playerName
    }

    /// Formatted date string for display (e.g., "Jan 4, 2025")
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }

    /// Short formatted date string for compact display (e.g., "1/4/25")
    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: timestamp)
    }
}
