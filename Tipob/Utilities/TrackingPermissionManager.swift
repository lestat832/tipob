import Foundation
import AppTrackingTransparency

/// Centralized manager for App Tracking Transparency (ATT) permission handling.
/// Triggers pre-prompt after 3 completed games for optimal opt-in rates.
final class TrackingPermissionManager {
    static let shared = TrackingPermissionManager()

    private let hasShownATTPromptKey = "hasShownATTPrompt"

    /// Number of games before showing ATT pre-prompt (industry best practice: 3 games)
    private let gamesBeforePrompt = 3

    private init() {}

    private var hasShownATTPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: hasShownATTPromptKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasShownATTPromptKey) }
    }

    /// Whether the pre-prompt should be shown to the user
    var shouldShowPrePrompt: Bool {
        guard !hasShownATTPrompt else { return false }

        let gameCount = UserDefaults.standard.integer(forKey: "totalGamesPlayed")
        guard gameCount >= gamesBeforePrompt else { return false }

        return ATTrackingManager.trackingAuthorizationStatus == .notDetermined
    }

    /// Mark that the prompt has been shown (user tapped "Continue" or "Not Now")
    func markPromptShown() {
        hasShownATTPrompt = true
    }

    /// Request tracking authorization from the system
    /// - Parameter completion: Called with the authorization status on main thread
    func requestTracking(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }

    /// Current tracking authorization status
    var currentStatus: ATTrackingManager.AuthorizationStatus {
        ATTrackingManager.trackingAuthorizationStatus
    }
}
