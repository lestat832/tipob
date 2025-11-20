import AVFoundation
import AudioToolbox
import SwiftUI

/// Simplified AudioManager - Success and Failure sounds only
/// Removed: AVAudioEngine, countdown, pitch shifting
class AudioManager {

    // MARK: - Singleton

    static let shared = AudioManager()

    // MARK: - Audio Players (for success and round complete)

    private var successPlayer: AVAudioPlayer?
    private var roundCompletePlayer: AVAudioPlayer?

    // MARK: - System Sound (for failure)

    private let failureSoundID: SystemSoundID = 1073 // SMS Alert 3

    // MARK: - State Tracking

    private var isInitialized = false

    // MARK: - Initialization

    private init() {
        // Empty - call initialize() after launch animation completes
    }

    /// Initialize audio system - call after launch animation completes
    /// This prevents blocking during app launch
    func initialize() {
        guard !isInitialized else { return }
        isInitialized = true

        configureAudioSession()
        preloadSoundFiles()
    }

    // MARK: - AVAudioSession Configuration

    /// Configure audio session for game audio
    /// - category: .ambient (doesn't interrupt other apps)
    /// - options: .mixWithOthers (allow Spotify, etc. to play)
    /// - respects silent mode
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            #if DEBUG
            print("AudioManager: Failed to configure audio session: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Preload Sound Files

    /// Preload sound files on initialization
    /// Files expected in Bundle: gesture_success_tick.caf, round_complete_chime.caf
    private func preloadSoundFiles() {
        // Load success sound
        if let successURL = Bundle.main.url(forResource: "gesture_success_tick", withExtension: "caf") {
            do {
                successPlayer = try AVAudioPlayer(contentsOf: successURL)
                successPlayer?.prepareToPlay()
                successPlayer?.volume = 0.35 // 0.3-0.4 range
            } catch {
                #if DEBUG
                print("AudioManager: Failed to load gesture_success_tick.caf: \(error.localizedDescription)")
                #endif
            }
        } else {
            #if DEBUG
            print("AudioManager: gesture_success_tick.caf not found in bundle")
            #endif
        }

        // Load round complete sound
        if let roundCompleteURL = Bundle.main.url(forResource: "round_complete_chime", withExtension: "caf") {
            do {
                roundCompletePlayer = try AVAudioPlayer(contentsOf: roundCompleteURL)
                roundCompletePlayer?.prepareToPlay()
                roundCompletePlayer?.volume = 0.65 // 0.6-0.7 range
            } catch {
                #if DEBUG
                print("AudioManager: Failed to load round_complete_chime.caf: \(error.localizedDescription)")
                #endif
            }
        } else {
            #if DEBUG
            print("AudioManager: round_complete_chime.caf not found in bundle")
            #endif
        }
    }

    // MARK: - Public API

    /// Play success sound (gesture correct)
    /// Duration: 45-70ms, Volume: 0.3-0.4
    func playSuccess() {
        guard isInitialized else { return }
        guard UserSettings.soundEnabled else { return }
        guard let player = successPlayer else { return }

        // Success interrupts previous success
        if player.isPlaying {
            player.stop()
        }

        player.currentTime = 0
        player.play()
    }

    /// Play round complete sound
    /// Duration: 180-300ms, Volume: 0.6-0.7
    func playRoundComplete() {
        guard isInitialized else { return }
        guard UserSettings.soundEnabled else { return }
        guard let player = roundCompletePlayer else { return }

        player.currentTime = 0
        player.play()
    }

    /// Play failure sound (wrong gesture or timeout)
    /// Uses SystemSoundID 1073 (SMS Alert 3)
    /// Direct system sound - no AVAudioEngine interference
    func playFailure() {
        guard UserSettings.soundEnabled else { return }
        // Play system sound directly - clean, no interference
        AudioServicesPlaySystemSound(failureSoundID)
    }

    /// Enable or disable sound effects
    func setSoundEnabled(_ enabled: Bool) {
        UserSettings.soundEnabled = enabled
    }

    // MARK: - Cleanup

    deinit {
        successPlayer?.stop()
        roundCompletePlayer?.stop()
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
struct AudioManagerPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Manager Test")
                .font(.largeTitle)

            Button("Initialize Audio") {
                AudioManager.shared.initialize()
            }
            .buttonStyle(.bordered)

            Button("Play Success") {
                AudioManager.shared.playSuccess()
            }
            .buttonStyle(.borderedProminent)

            Button("Play Round Complete") {
                AudioManager.shared.playRoundComplete()
            }
            .buttonStyle(.borderedProminent)

            Button("Play Failure") {
                AudioManager.shared.playFailure()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

            Divider()

            // Test: Rapid success sounds
            Button("Test: Rapid Success (10x)") {
                for _ in 0..<10 {
                    AudioManager.shared.playSuccess()
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }

            Text("Test in silent mode and with Spotify playing")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    AudioManagerPreview()
}
#endif
