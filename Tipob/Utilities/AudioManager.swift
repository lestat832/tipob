import AVFoundation
import AudioToolbox
import SwiftUI

/// AudioManager - Complete audio system for Out of Pocket game
/// Handles 4 sound types: success, round complete, countdown, failure
/// Features: pitch shifting, interruption handling, AVAudioSession configuration
class AudioManager {

    // MARK: - Singleton

    static let shared = AudioManager()

    // MARK: - Audio Engine (for pitch-shifted countdown)

    private let audioEngine = AVAudioEngine()
    private let countdownPlayerNode = AVAudioPlayerNode()
    private let timePitch = AVAudioUnitTimePitch()

    // MARK: - Audio Players (for success and round complete)

    private var successPlayer: AVAudioPlayer?
    private var roundCompletePlayer: AVAudioPlayer?

    // MARK: - Audio Files

    private var countdownAudioFile: AVAudioFile?

    // MARK: - System Sound (for failure)

    private let failureSoundID: SystemSoundID = 1073 // SMS Alert 3

    // MARK: - State Tracking

    private var isCountdownPlaying = false
    private var isInitialized = false
    private let initQueue = DispatchQueue(label: "com.outofpocket.audio.init")

    // MARK: - Initialization

    private init() {
        // Lazy initialization - setup happens on first use to avoid blocking app launch
    }

    /// Ensure AudioManager is initialized before use (lazy initialization pattern)
    private func ensureInitialized() {
        guard !isInitialized else { return }

        initQueue.sync {
            guard !isInitialized else { return }

            configureAudioSession()
            setupAudioEngine()
            preloadSoundFiles()

            isInitialized = true
        }
    }

    // MARK: - AVAudioSession Configuration

    /// Configure audio session for game audio
    /// - category: .ambient (doesn't interrupt other apps)
    /// - options: .mixWithOthers (allow Spotify, etc. to play)
    /// - respects silent mode
    /// - ducks under phone calls/Siri
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers, .duckOthers])
            try audioSession.setActive(true)
        } catch {
            #if DEBUG
            print("AudioManager: Failed to configure audio session: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Audio Engine Setup

    /// Setup AVAudioEngine with player node and pitch shifter for countdown
    private func setupAudioEngine() {
        // Attach nodes to engine
        audioEngine.attach(countdownPlayerNode)
        audioEngine.attach(timePitch)

        // Connect: playerNode -> timePitch -> mainMixerNode -> output
        audioEngine.connect(countdownPlayerNode, to: timePitch, format: nil)
        audioEngine.connect(timePitch, to: audioEngine.mainMixerNode, format: nil)

        // Start the engine
        do {
            try audioEngine.start()
        } catch {
            #if DEBUG
            print("AudioManager: Failed to start audio engine: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Preload Sound Files

    /// Preload all sound files on initialization
    /// Files expected in Bundle: gesture_success_tick.caf, round_complete_chime.caf, countdown_beep.caf
    /// Gracefully handles missing files without crashing
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

        // Load countdown sound file
        if let countdownURL = Bundle.main.url(forResource: "countdown_beep", withExtension: "caf") {
            do {
                countdownAudioFile = try AVAudioFile(forReading: countdownURL)
            } catch {
                #if DEBUG
                print("AudioManager: Failed to load countdown_beep.caf: \(error.localizedDescription)")
                #endif
            }
        } else {
            #if DEBUG
            print("AudioManager: countdown_beep.caf not found in bundle")
            #endif
        }
    }

    // MARK: - Public API

    /// Play success sound (gesture correct)
    /// Duration: 45-70ms, Volume: 0.3-0.4
    /// Interruptible: Yes (by next success sound)
    /// Use: After every correct gesture
    func playSuccess() {
        ensureInitialized()
        guard UserSettings.soundEnabled else { return }
        guard let player = successPlayer else { return }

        // Success interrupts previous success
        if player.isPlaying {
            player.stop()
        }

        player.currentTime = 0
        player.play()

        // Test: Rapid success sounds (10 in 1 sec) - should handle cleanly
    }

    /// Play round complete sound
    /// Duration: 180-300ms, Volume: 0.6-0.7
    /// Can overlap: Yes (with success sound)
    /// Must be overridden by: Failure sound
    /// Use: Classic every 3 gestures, Memory full sequence, PvP player finishes turn
    func playRoundComplete() {
        ensureInitialized()
        guard UserSettings.soundEnabled else { return }
        guard let player = roundCompletePlayer else { return }

        // Round complete can overlap with success, so don't stop if playing
        // Just restart it
        player.currentTime = 0
        player.play()
    }

    /// Play countdown step with pitch shifting
    /// Duration: 120-150ms each, Volume: 0.5-0.6
    /// Interruptible: No (countdown cannot be interrupted)
    /// Pitch shifting:
    /// - step 3 → 600 Hz
    /// - step 2 → 650 Hz
    /// - step 1 → 700 Hz
    /// - step 0 (GO) → 850 Hz
    /// - Parameter step: Countdown step (3, 2, 1, 0 for GO)
    func playCountdownStep(step: Int) {
        ensureInitialized()
        guard UserSettings.soundEnabled else { return }
        guard let audioFile = countdownAudioFile else { return }

        isCountdownPlaying = true

        // Calculate pitch shift in cents (100 cents = 1 semitone)
        // Base frequency ~440 Hz (A4)
        // We want specific target frequencies
        let targetFrequency: Float
        switch step {
        case 3: targetFrequency = 600
        case 2: targetFrequency = 650
        case 1: targetFrequency = 700
        case 0: targetFrequency = 850 // GO
        default: targetFrequency = 600
        }

        // Calculate cents shift from base frequency (assuming base ~500 Hz)
        // cents = 1200 * log2(targetFreq / baseFreq)
        let baseFrequency: Float = 500
        let centsShift = 1200 * log2(targetFrequency / baseFrequency)

        timePitch.pitch = centsShift

        // Set volume for countdown
        countdownPlayerNode.volume = 0.55 // 0.5-0.6 range

        // Schedule the audio file
        countdownPlayerNode.scheduleFile(audioFile, at: nil) {
            // Callback when playback completes
            self.isCountdownPlaying = false
        }

        // Start playing if not already playing
        if !countdownPlayerNode.isPlaying {
            countdownPlayerNode.play()
        }

        // Test: Failure during countdown - should interrupt
    }

    /// Play failure sound (wrong gesture or timeout)
    /// Uses SystemSoundID 1073 (SMS Alert 3)
    /// Volume: 0.7-0.8 (system controlled)
    /// Interrupts: Everything (success, round complete, countdown)
    /// Use: Wrong gesture, timeout, game over
    func playFailure() {
        ensureInitialized()
        guard UserSettings.soundEnabled else { return }

        // FAILURE PREEMPTION: Stop all other sounds immediately

        // Stop success player
        if let successPlayer = successPlayer, successPlayer.isPlaying {
            successPlayer.stop()
        }

        // Stop round complete player
        if let roundCompletePlayer = roundCompletePlayer, roundCompletePlayer.isPlaying {
            roundCompletePlayer.stop()
        }

        // Stop countdown (if playing)
        if isCountdownPlaying {
            countdownPlayerNode.stop()
            isCountdownPlaying = false
        }

        // Play system failure sound
        AudioServicesPlaySystemSound(failureSoundID)

        // Test: Failure during countdown - should interrupt immediately
    }

    /// Enable or disable sound effects
    /// - Parameter enabled: Whether sound should be enabled
    func setSoundEnabled(_ enabled: Bool) {
        UserSettings.soundEnabled = enabled
    }

    // MARK: - Cleanup

    deinit {
        // Stop audio engine
        audioEngine.stop()

        // Stop all players
        successPlayer?.stop()
        roundCompletePlayer?.stop()
        countdownPlayerNode.stop()
    }
}

// MARK: - Example Integration Code

/*
 EXAMPLE USAGE IN GameViewModel:

 // 1. Success sound after correct gesture
 func handleGestureSuccess() {
     AudioManager.shared.playSuccess()

     if UserSettings.hapticsEnabled {
         HapticManager.shared.playSuccessFeedback()
     }
 }

 // 2. Round complete sound
 func completeRound() {
     AudioManager.shared.playRoundComplete()
 }

 // 3. Countdown sequence at game start
 func startGame() async {
     for step in [3, 2, 1, 0] {
         AudioManager.shared.playCountdownStep(step: step)
         try? await Task.sleep(nanoseconds: 350_000_000) // 350ms between beeps
     }
     // Game starts after "GO"
 }

 // 4. Failure sound
 func handleFailure() {
     AudioManager.shared.playFailure()

     if UserSettings.hapticsEnabled {
         HapticManager.shared.playFailureFeedback()
     }
 }
 */

// MARK: - SwiftUI Preview Example

#if DEBUG
struct AudioManagerPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Manager Test")
                .font(.largeTitle)

            Button("Play Success") {
                AudioManager.shared.playSuccess()
            }
            .buttonStyle(.borderedProminent)

            Button("Play Round Complete") {
                AudioManager.shared.playRoundComplete()
            }
            .buttonStyle(.borderedProminent)

            Button("Play Countdown Sequence") {
                Task {
                    for step in [3, 2, 1, 0] {
                        AudioManager.shared.playCountdownStep(step: step)
                        try? await Task.sleep(nanoseconds: 350_000_000)
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Play Failure") {
                AudioManager.shared.playFailure()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

            Divider()

            // Test: Rapid success sounds (10 in 1 sec)
            Button("Test: Rapid Success (10x)") {
                for _ in 0..<10 {
                    AudioManager.shared.playSuccess()
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }

            // Test: Failure during countdown
            Button("Test: Failure During Countdown") {
                Task {
                    // Start countdown
                    Task {
                        for step in [3, 2, 1, 0] {
                            AudioManager.shared.playCountdownStep(step: step)
                            try? await Task.sleep(nanoseconds: 350_000_000)
                        }
                    }

                    // Interrupt with failure after 500ms
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    AudioManager.shared.playFailure()
                }
            }

            Text("Test in silent mode and with Spotify playing in background")
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
