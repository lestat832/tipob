import Foundation
import FirebaseAnalytics

/// Centralized analytics manager for tracking game events.
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

    /// Logs when the user toggles discreet mode.
    /// - Parameter isOn: Whether discreet mode was turned on or off
    func logDiscreetModeToggled(isOn: Bool) {
        let params: [String: Any] = [
            "state": isOn ? "on" : "off"
        ]
        log(.discreetModeToggled, parameters: params)
    }

    /// Logs when user taps "Play Again" after game over.
    /// - Parameters:
    ///   - mode: The game mode being replayed
    ///   - discreetMode: Whether discreet mode is enabled
    func logReplayGame(mode: GameMode, discreetMode: Bool) {
        let params: [String: Any] = [
            "mode": mode.analyticsValue,
            "discreet_mode": discreetMode
        ]
        log(.replayGame, parameters: params)
    }

    /// Logs when user taps "Keep Practicing" to continue the tutorial
    func logTutorialContinue() {
        log(.tutorialContinue, parameters: nil)
    }

    /// Logs when a gesture becomes the next required player input.
    /// - Parameters:
    ///   - gesture: The gesture the player needs to perform
    ///   - mode: The game mode (Classic or Memory only)
    func logGesturePrompted(gesture: GestureType, mode: GameMode) {
        let params: [String: Any] = [
            "gesture": gesture.analyticsValue,
            "mode": mode.analyticsValue
        ]
        log(.gesturePrompted, parameters: params)
    }
}

// MARK: - Private Logging Implementation
private extension AnalyticsManager {
    func log(_ event: AnalyticsEvent, parameters: [String: Any]?) {
        #if DEBUG
        print("📊 Analytics Event → \(event.rawValue) | params: \(parameters ?? [:])")
        #endif

        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}
