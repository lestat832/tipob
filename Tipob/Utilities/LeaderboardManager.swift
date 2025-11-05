import Foundation

/// Manages local leaderboards for all game modes
/// Handles persistence, scoring, and leaderboard queries using UserDefaults + JSON
class LeaderboardManager {
    static let shared = LeaderboardManager()

    // MARK: - UserDefaults Keys

    private let classicLeaderboardKey = "TipobLeaderboard_Classic"
    private let memoryLeaderboardKey = "TipobLeaderboard_Memory"
    private let gameVsPlayerVsPlayerLeaderboardKey = "TipobLeaderboard_GameVsPlayerVsPlayer"
    private let playerVsPlayerLeaderboardKey = "TipobLeaderboard_PlayerVsPlayer"

    // MARK: - In-Memory Cache

    private var classicLeaderboard: [LeaderboardEntry] = []
    private var memoryLeaderboard: [LeaderboardEntry] = []
    private var gameVsPlayerVsPlayerLeaderboard: [LeaderboardEntry] = []
    private var playerVsPlayerLeaderboard: [LeaderboardEntry] = []

    // MARK: - Configuration

    /// Maximum number of entries to keep per leaderboard
    private let maxEntriesPerLeaderboard = 100

    // MARK: - Initialization

    private init() {
        loadAllLeaderboards()
    }

    // MARK: - Public API

    /// Add a score to the appropriate leaderboard
    /// - Parameters:
    ///   - score: The score to add
    ///   - mode: The game mode this score belongs to
    ///   - playerName: Optional player name
    func addScore(_ score: Int, for mode: GameMode, playerName: String? = nil) {
        let entry = LeaderboardEntry(score: score, playerName: playerName)

        switch mode {
        case .classic:
            classicLeaderboard.append(entry)
            sortAndTrim(&classicLeaderboard)
            saveLeaderboard(classicLeaderboard, key: classicLeaderboardKey)

        case .memory:
            memoryLeaderboard.append(entry)
            sortAndTrim(&memoryLeaderboard)
            saveLeaderboard(memoryLeaderboard, key: memoryLeaderboardKey)

        case .gameVsPlayerVsPlayer:
            gameVsPlayerVsPlayerLeaderboard.append(entry)
            sortAndTrim(&gameVsPlayerVsPlayerLeaderboard)
            saveLeaderboard(gameVsPlayerVsPlayerLeaderboard, key: gameVsPlayerVsPlayerLeaderboardKey)

        case .playerVsPlayer:
            playerVsPlayerLeaderboard.append(entry)
            sortAndTrim(&playerVsPlayerLeaderboard)
            saveLeaderboard(playerVsPlayerLeaderboard, key: playerVsPlayerLeaderboardKey)

        case .tutorial:
            // Tutorial mode does not use leaderboard
            return
        }
    }

    /// Get top scores for a game mode
    /// - Parameters:
    ///   - mode: The game mode to query
    ///   - limit: Maximum number of entries to return (default: all)
    /// - Returns: Array of leaderboard entries, sorted highest to lowest
    func topScores(for mode: GameMode, limit: Int? = nil) -> [LeaderboardEntry] {
        let leaderboard: [LeaderboardEntry]

        switch mode {
        case .classic:
            leaderboard = classicLeaderboard
        case .memory:
            leaderboard = memoryLeaderboard
        case .gameVsPlayerVsPlayer:
            leaderboard = gameVsPlayerVsPlayerLeaderboard
        case .playerVsPlayer:
            leaderboard = playerVsPlayerLeaderboard
        case .tutorial:
            return []
        }

        if let limit = limit {
            return Array(leaderboard.prefix(limit))
        }
        return leaderboard
    }

    /// Check if a score would be a new high score (beats current #1)
    /// - Parameters:
    ///   - score: The score to check
    ///   - mode: The game mode
    /// - Returns: True if this score beats the current high score
    func isNewHighScore(_ score: Int, mode: GameMode) -> Bool {
        let currentTopScores = topScores(for: mode, limit: 1)

        // If leaderboard is empty, any score is a high score
        guard let currentHighScore = currentTopScores.first else {
            return true
        }

        return score > currentHighScore.score
    }

    /// Get the current high score for a mode
    /// - Parameter mode: The game mode
    /// - Returns: The highest score, or 0 if no scores exist
    func getHighScore(for mode: GameMode) -> Int {
        return topScores(for: mode, limit: 1).first?.score ?? 0
    }

    /// Reset leaderboard for a specific mode
    /// - Parameter mode: The game mode to reset
    func resetLeaderboard(for mode: GameMode) {
        switch mode {
        case .classic:
            classicLeaderboard = []
            saveLeaderboard(classicLeaderboard, key: classicLeaderboardKey)

        case .memory:
            memoryLeaderboard = []
            saveLeaderboard(memoryLeaderboard, key: memoryLeaderboardKey)

        case .gameVsPlayerVsPlayer:
            gameVsPlayerVsPlayerLeaderboard = []
            saveLeaderboard(gameVsPlayerVsPlayerLeaderboard, key: gameVsPlayerVsPlayerLeaderboardKey)

        case .playerVsPlayer:
            playerVsPlayerLeaderboard = []
            saveLeaderboard(playerVsPlayerLeaderboard, key: playerVsPlayerLeaderboardKey)

        case .tutorial:
            // Tutorial mode does not use leaderboard
            return
        }
    }

    /// Reset all leaderboards
    func resetAllLeaderboards() {
        classicLeaderboard = []
        memoryLeaderboard = []
        gameVsPlayerVsPlayerLeaderboard = []
        playerVsPlayerLeaderboard = []

        saveLeaderboard(classicLeaderboard, key: classicLeaderboardKey)
        saveLeaderboard(memoryLeaderboard, key: memoryLeaderboardKey)
        saveLeaderboard(gameVsPlayerVsPlayerLeaderboard, key: gameVsPlayerVsPlayerLeaderboardKey)
        saveLeaderboard(playerVsPlayerLeaderboard, key: playerVsPlayerLeaderboardKey)
    }

    // MARK: - Private Methods

    /// Sort leaderboard by score (highest first) and trim to max entries
    /// - Parameter leaderboard: The leaderboard array to sort and trim
    private func sortAndTrim(_ leaderboard: inout [LeaderboardEntry]) {
        // Sort by score descending, then by timestamp descending (most recent first for ties)
        leaderboard.sort { entry1, entry2 in
            if entry1.score == entry2.score {
                return entry1.timestamp > entry2.timestamp
            }
            return entry1.score > entry2.score
        }

        // Trim to max entries
        if leaderboard.count > maxEntriesPerLeaderboard {
            leaderboard = Array(leaderboard.prefix(maxEntriesPerLeaderboard))
        }
    }

    /// Save leaderboard to UserDefaults using JSON encoding
    /// - Parameters:
    ///   - entries: The leaderboard entries to save
    ///   - key: The UserDefaults key
    private func saveLeaderboard(_ entries: [LeaderboardEntry], key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    /// Load leaderboard from UserDefaults using JSON decoding
    /// - Parameter key: The UserDefaults key
    /// - Returns: Array of leaderboard entries, or empty array if none exist
    private func loadLeaderboard(key: String) -> [LeaderboardEntry] {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? decoder.decode([LeaderboardEntry].self, from: data) {
            return decoded
        }
        return []
    }

    /// Load all leaderboards from persistence on init
    private func loadAllLeaderboards() {
        classicLeaderboard = loadLeaderboard(key: classicLeaderboardKey)
        memoryLeaderboard = loadLeaderboard(key: memoryLeaderboardKey)
        gameVsPlayerVsPlayerLeaderboard = loadLeaderboard(key: gameVsPlayerVsPlayerLeaderboardKey)
        playerVsPlayerLeaderboard = loadLeaderboard(key: playerVsPlayerLeaderboardKey)
    }
}
