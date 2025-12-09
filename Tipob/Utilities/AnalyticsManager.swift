import Foundation

/// Centralized analytics manager for tracking game events.
/// Currently logs to console only. Firebase/other SDKs will be integrated later.
final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}
}

// MARK: - Analytics Event Definitions
private extension AnalyticsManager {
    enum AnalyticsEvent: String {
        case startGame           = "start_game"
        case endGame             = "end_game"
        case replayGame          = "replay_game"
        case discreetModeToggled = "discreet_mode_toggled"
        case tutorialContinue    = "tutorial_continue"
        case gesturePrompted     = "gesture_prompted"
        case gestureCompleted    = "gesture_completed"
        case gestureFailed       = "gesture_failed"
        case adRequested         = "ad_requested"
        case adLoaded            = "ad_loaded"
        case adFailedToLoad      = "ad_failed_to_load"
        case adShown             = "ad_shown"
        case adDismissed         = "ad_dismissed"
    }
}

// MARK: - Public API (Type-Safe Event Methods)
extension AnalyticsManager {
    /// Logs when a new game session starts.
    /// - Parameters:
    ///   - mode: The game mode being started
    ///   - discreetMode: Whether discreet mode is enabled
    func logStartGame(mode: GameMode, discreetMode: Bool) {
        let params: [String: Any] = [
            "mode": mode.analyticsValue,
            "discreet_mode": discreetMode
        ]
        log(.startGame, parameters: params)
    }
}

// MARK: - Private Logging Implementation
private extension AnalyticsManager {
    func log(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        #if DEBUG
        print("📊 Analytics Event → \(event.rawValue) | params: \(parameters ?? [:])")
        #endif

        // NOTE: Firebase (or any other analytics SDK) will be plugged in here later.
        // Example future implementation:
        // Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}
