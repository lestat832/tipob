import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let bestStreakKey = "TipobBestStreak"

    private init() {}

    func saveBestStreak(_ streak: Int) {
        UserDefaults.standard.set(streak, forKey: bestStreakKey)
    }

    func loadBestStreak() -> Int {
        return UserDefaults.standard.integer(forKey: bestStreakKey)
    }
}