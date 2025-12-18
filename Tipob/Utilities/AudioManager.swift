import AVFoundation
import SwiftUI

/// Simplified AudioManager - Success and Failure sounds only
/// Removed: AVAudioEngine, countdown, pitch shifting
class AudioManager {

    // MARK: - Singleton

    static let shared = AudioManager()

    // MARK: - Audio Players

    private var successPlayer: AVAudioPlayer?
    private var roundCompletePlayer: AVAudioPlayer?
    private var failurePlayer: AVAudioPlayer?
    private var failurePlayer2: AVAudioPlayer?  // Second player for rapid double-play
    private var countdownPlayer: AVAudioPlayer?  // Countdown beep for 3, 2, 1, START

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
    /// Files expected in Bundle: gesture_success_tick.caf, round_complete_chime.caf, countdown_beep.caf
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

        // Load failure sound (custom error tone)
        if let failureURL = Bundle.main.url(forResource: "failure", withExtension: "caf") {
            do {
                failurePlayer = try AVAudioPlayer(contentsOf: failureURL)
                failurePlayer?.prepareToPlay()
                failurePlayer?.volume = 0.5
            } catch {
                #if DEBUG
                print("AudioManager: Failed to load failure.caf: \(error.localizedDescription)")
                #endif
            }

            // Load second player for rapid double-play
            do {
                failurePlayer2 = try AVAudioPlayer(contentsOf: failureURL)
                failurePlayer2?.prepareToPlay()
                failurePlayer2?.volume = 0.5
            } catch {
                #if DEBUG
                print("AudioManager: Failed to load failure.caf for player2")
                #endif
            }
        } else {
            #if DEBUG
            print("AudioManager: failure.caf not found in bundle")
            #endif
        }

        // Load countdown beep sound
        if let countdownURL = Bundle.main.url(forResource: "countdown_beep", withExtension: "caf") {
            do {
                countdownPlayer = try AVAudioPlayer(contentsOf: countdownURL)
                countdownPlayer?.prepareToPlay()
                countdownPlayer?.volume = 0.5
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
    /// Plays twice in rapid succession using two players (~1.3s overlapping)
    func playFailure() {
        #if DEBUG
        print("AudioManager: playFailure() called")
        #endif

        guard isInitialized else {
            #if DEBUG
            print("AudioManager: ❌ Not initialized")
            #endif
            return
        }

        guard UserSettings.soundEnabled else {
            #if DEBUG
            print("AudioManager: ⏸️ Sound disabled")
            #endif
            return
        }

        guard let player1 = failurePlayer, let player2 = failurePlayer2 else {
            #if DEBUG
            print("AudioManager: ❌ failurePlayer is nil")
            #endif
            return
        }

        // Play first immediately
        player1.currentTime = 0
        player1.play()

        // Play second with tiny delay (0.08s = distinct but immediate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            player2.currentTime = 0
            player2.play()
        }

        #if DEBUG
        print("AudioManager: ✅ Playing failure sound 2x rapid")
        #endif
    }

    /// Play countdown tick sound (for 3, 2, 1)
    func playCountdownTick() {
        guard isInitialized else { return }
        guard UserSettings.soundEnabled else { return }
        guard let player = countdownPlayer else { return }

        if player.isPlaying {
            player.stop()
        }

        player.currentTime = 0
        player.play()
    }

    /// Play countdown start sound (for "START")
    func playCountdownStart() {
        guard isInitialized else { return }
        guard UserSettings.soundEnabled else { return }
        guard let player = countdownPlayer else { return }

        if player.isPlaying {
            player.stop()
        }

        player.currentTime = 0
        player.play()
    }

    /// Enable or disable sound effects
    func setSoundEnabled(_ enabled: Bool) {
        UserSettings.soundEnabled = enabled
    }

    // MARK: - Cleanup

    deinit {
        successPlayer?.stop()
        roundCompletePlayer?.stop()
        failurePlayer?.stop()
        failurePlayer2?.stop()
        countdownPlayer?.stop()
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
