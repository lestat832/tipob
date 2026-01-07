import Foundation

// MARK: - AppConfig

/// Centralized app configuration constants
enum AppConfig {
    /// App Store ID for the app (nil until app is published)
    /// Set this to your actual App Store ID once available
    static let appStoreID: String? = nil

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
