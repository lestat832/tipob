import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let bestStreakKey = "TipobBestStreak"
    private let classicBestScoreKey = "TipobClassicBestScore"

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
}