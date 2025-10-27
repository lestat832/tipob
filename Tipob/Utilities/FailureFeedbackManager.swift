import Foundation

/// Unified failure feedback manager that coordinates sound and haptic feedback
/// Provides consistent "wrong gesture" feedback across all game modes
class FailureFeedbackManager {
    static let shared = FailureFeedbackManager()

    private init() {}

    /// Play combined failure feedback (sound + haptic)
    /// Called whenever player makes a wrong gesture or times out
    func playFailureFeedback() {
        // Fire both simultaneously for maximum impact
        SoundManager.shared.playFailureSound()
        HapticManager.shared.playFailureFeedback()
    }
}
