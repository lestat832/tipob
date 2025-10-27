import AVFoundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()

    // System sound IDs for failure feedback
    // Using built-in iOS system sounds that don't require audio files
    // SystemSoundID 1073 (SMS Alert 3) - More distinct and audible than 1053
    private let failureSoundID: SystemSoundID = 1073  // SMS Alert 3 - clear "wrong" indication

    private init() {
        // Prepare audio session for sound playback
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    // Play failure sound - short, distinct "wrong" tone
    func playFailureSound() {
        AudioServicesPlaySystemSound(failureSoundID)
    }
}
