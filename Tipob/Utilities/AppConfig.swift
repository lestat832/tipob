import Foundation

// MARK: - AppConfig

/// Centralized app configuration constants
enum AppConfig {
    /// App Store ID for the app
    /// Used for Rate Us fallback and App Store deep links
    static let appStoreID: String? = "6756274838"

    /// App Store URL constructed from appStoreID
    static var appStoreURL: URL? {
        guard let id = appStoreID else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(id)")
    }

    /// App Store "Write a Review" URL (deep links to review sheet)
    static var appStoreReviewURL: URL? {
        guard let id = appStoreID else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(id)?action=write-review")
    }
}
