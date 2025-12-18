import Foundation

/// Centralized UserDefaults wrapper for game settings
/// Provides clean API for sound and haptics preferences
class UserSettings {

    // MARK: - Keys

    private enum Keys {
        static let soundEnabled = "soundEnabled"
        static let hapticsEnabled = "hapticsEnabled"
        static let showGestureNames = "showGestureNames"
    }

    // MARK: - Sound Settings

    /// Whether sound effects are enabled
    /// Default: true
    static var soundEnabled: Bool {
        get {
            // If key doesn't exist yet, return default value (true)
            if UserDefaults.standard.object(forKey: Keys.soundEnabled) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Keys.soundEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.soundEnabled)
        }
    }

    // MARK: - Haptics Settings

    /// Whether haptic feedback is enabled
    /// Default: true
    static var hapticsEnabled: Bool {
        get {
            // If key doesn't exist yet, return default value (true)
            if UserDefaults.standard.object(forKey: Keys.hapticsEnabled) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Keys.hapticsEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hapticsEnabled)
        }
    }

    // MARK: - Show Gesture Names Settings

    /// Whether gesture helper text is displayed during gameplay
    /// Default: true (ON) - Shows gesture names below icons
    static var showGestureNames: Bool {
        get {
            // If key doesn't exist yet, return default value (true - enabled by default)
            if UserDefaults.standard.object(forKey: Keys.showGestureNames) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Keys.showGestureNames)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.showGestureNames)
        }
    }
}
