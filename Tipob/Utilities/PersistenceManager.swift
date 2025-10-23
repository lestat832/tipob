import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let bestStreakKey = "TipobBestStreak"
    private let classicBestScoreKey = "TipobClassicBestScore"
    private let pvpLongestSequenceKey = "TipobPvPLongestSequence"
    private let pvpPlayer1WinsKey = "TipobPvPPlayer1Wins"
    private let pvpPlayer2WinsKey = "TipobPvPPlayer2Wins"

    private init() {}

    func saveBestStreak(_ streak: Int) {
        UserDefaults.standard.set(streak, forKey: bestStreakKey)
    }

    func loadBestStreak() -> Int {
        return UserDefaults.standard.integer(forKey: bestStreakKey)
    }

    func saveClassicBestScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: classicBestScoreKey)
    }

    func loadClassicBestScore() -> Int {
        return UserDefaults.standard.integer(forKey: classicBestScoreKey)
    }

    // MARK: - Player vs Player Stats

    func savePvPLongestSequence(_ length: Int) {
        UserDefaults.standard.set(length, forKey: pvpLongestSequenceKey)
    }

    func loadPvPLongestSequence() -> Int {
        return UserDefaults.standard.integer(forKey: pvpLongestSequenceKey)
    }

    func savePvPPlayer1Wins(_ wins: Int) {
        UserDefaults.standard.set(wins, forKey: pvpPlayer1WinsKey)
    }

    func loadPvPPlayer1Wins() -> Int {
        return UserDefaults.standard.integer(forKey: pvpPlayer1WinsKey)
    }

    func savePvPPlayer2Wins(_ wins: Int) {
        UserDefaults.standard.set(wins, forKey: pvpPlayer2WinsKey)
    }

    func loadPvPPlayer2Wins() -> Int {
        return UserDefaults.standard.integer(forKey: pvpPlayer2WinsKey)
    }
}