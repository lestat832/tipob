import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .launch
    @Published var gameModel = GameModel()
    @Published var classicModeModel = ClassicModeModel()
    @Published var showingGestureIndex = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var flashColor: Color = .clear
    @Published var isClassicMode: Bool = false
    @Published var discreetModeEnabled: Bool = false
    @Published var isNewHighScore: Bool = false

    // MARK: - Post-Ad Countdown State
    /// Current countdown value: nil = not counting, 3/2/1 = counting, 0 = "START"
    @Published var countdownValue: Int? = nil
    /// True when countdown overlay should be displayed
    @Published var isCountdownActive: Bool = false

    // MARK: - Gesture Buffer (Memory Mode transition)
    /// Buffer for gestures detected during state transitions
    private var pendingGesture: GestureType? = nil
    /// True when gesture buffer is active (during transition from playback to input)
    private var isGestureBufferEnabled: Bool = false

    // MARK: - Analytics timing
    var gameStartTime: Date?
    /// Timestamp when current gesture was prompted (for reaction time calculation)
    var gesturePromptTime: Date?
    /// Reason for game ending - set before gameOver() is called
    private var endedByReason: String = "timeout"

    private var timer: Timer?
    var randomNumberGenerator: RandomNumberGenerator = SystemRandomNumberGenerator()

    #if DEBUG || TESTFLIGHT
    private var classicGestureHistory: [GestureType] = []
    private var classicModeReplaySequence: [GestureType]? = nil
    private var classicModeReplayIndex: Int = 0
    private var isMemoryModeReplay: Bool = false
    #endif

    init() {
        gameModel.bestStreak = PersistenceManager.shared.loadBestStreak()
        classicModeModel.bestScore = PersistenceManager.shared.loadClassicBestScore()
    }

    deinit {
        timer?.invalidate()
    }

    func transitionToMenu() {
        gameState = .menu
    }

    // MARK: - Post-Ad Countdown

    /// Start countdown (3, 2, 1, START) after ad dismisses, then execute completion
    /// - Parameter completion: Called after countdown completes to start the actual game
    func startCountdown(then completion: @escaping () -> Void) {
        gameState = .countdownToStart
        isCountdownActive = true
        countdownValue = 3

        // Play tick for "3"
        AudioManager.shared.playCountdownTick()
        HapticManager.shared.impact()

        // Schedule "2"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.countdownValue = 2
            AudioManager.shared.playCountdownTick()
            HapticManager.shared.impact()
        }

        // Schedule "1"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.countdownValue = 1
            AudioManager.shared.playCountdownTick()
            HapticManager.shared.impact()
        }

        // Schedule "START"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.countdownValue = 0  // 0 represents "START"
            AudioManager.shared.playCountdownStart()
            HapticManager.shared.success()
        }

        // After START flashes (~250ms), trigger completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.25) { [weak self] in
            self?.isCountdownActive = false
            self?.countdownValue = nil
            completion()
        }
    }

    func startTutorial() {
        gameStartTime = Date()
        AnalyticsManager.shared.logStartGame(mode: .tutorial, discreetMode: false)
        gameState = .tutorial
    }

    func startClassic(isReplay: Bool = false) {
        gameStartTime = Date()
        gesturePromptTime = nil
        if !isReplay {
            AnalyticsManager.shared.logStartGame(mode: .classic, discreetMode: discreetModeEnabled)
        }
        isClassicMode = true
        classicModeModel.reset()

        #if DEBUG || TESTFLIGHT
        DevConfigManager.shared.clearLogs()
        classicGestureHistory.removeAll()
        #endif

        // Preload ad for game over screen
        AdManager.shared.preloadIfNeeded()

        gameState = .classicMode
        showNextClassicGesture()
    }

    func startGameVsPlayerVsPlayer(isReplay: Bool = false) {
        gameStartTime = Date()
        if !isReplay {
            AnalyticsManager.shared.logStartGame(mode: .gameVsPlayerVsPlayer, discreetMode: discreetModeEnabled)
        }
        // Preload ad for game over screen
        AdManager.shared.preloadIfNeeded()
        gameState = .gameVsPlayerVsPlayer
    }

    func startPlayerVsPlayer(isReplay: Bool = false) {
        gameStartTime = Date()
        if !isReplay {
            AnalyticsManager.shared.logStartGame(mode: .playerVsPlayer, discreetMode: discreetModeEnabled)
        }
        // Preload ad for game over screen
        AdManager.shared.preloadIfNeeded()
        gameState = .playerVsPlayer
    }

    func startMemory(isReplay: Bool = false) {
        gameStartTime = Date()
        gesturePromptTime = nil
        if !isReplay {
            AnalyticsManager.shared.logStartGame(mode: .memory, discreetMode: discreetModeEnabled)
        }
        isClassicMode = false
        gameModel.reset()
        // Reset gesture buffer for new game
        isGestureBufferEnabled = false
        pendingGesture = nil

        #if DEBUG || TESTFLIGHT
        DevConfigManager.shared.clearLogs()
        isMemoryModeReplay = false  // Reset replay flag for normal game
        #endif

        // Preload ad for game over screen
        AdManager.shared.preloadIfNeeded()

        // Deactivate motion detector during sequence playback to prevent false failures
        MotionGestureManager.shared.deactivateAllDetectors()

        gameModel.startNewRound(with: &randomNumberGenerator, discreetMode: discreetModeEnabled)
        gameState = .showSequence
        showingGestureIndex = 0

        // Brief delay before showing sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showNextGestureInSequence()
        }
    }

    private func showNextGestureInSequence() {
        guard showingGestureIndex < gameModel.sequence.count else {
            #if DEBUG || TESTFLIGHT
            if isMemoryModeReplay {
                print("🔄 REPLAY DEBUG: Finished showing all \(gameModel.sequence.count) gestures")
            }
            #endif

            // Enable gesture buffer during transition - gestures detected here will be replayed
            isGestureBufferEnabled = true
            pendingGesture = nil
            print("[\(Date().logTimestamp)] 📦 Gesture buffer enabled during transition")

            DispatchQueue.main.asyncAfter(deadline: .now() + GameConfiguration.transitionDelay) {
                self.transitionToAwaitInput()
            }
            return
        }

        #if DEBUG || TESTFLIGHT
        if isMemoryModeReplay {
            let gesture = gameModel.sequence[showingGestureIndex]
            print("🔄 REPLAY DEBUG: Showing gesture \(showingGestureIndex + 1)/\(gameModel.sequence.count): \(gesture.displayName)")
        }
        #endif

        // Wait for arrow animation to complete: show duration + gap duration
        let displayDuration = GameConfiguration.sequenceShowDuration + GameConfiguration.sequenceGapDuration

        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
            self.showingGestureIndex += 1
            self.showNextGestureInSequence()
        }
    }

    private func transitionToAwaitInput() {
        gameState = .awaitInput
        gameModel.currentGestureIndex = 0
        timeRemaining = GameConfiguration.perGestureTime

        // Log first expected gesture for analytics
        if gameModel.currentGestureIndex < gameModel.sequence.count {
            let expectedGesture = gameModel.sequence[gameModel.currentGestureIndex]
            AnalyticsManager.shared.logGesturePrompted(gesture: expectedGesture, mode: .memory)
            gesturePromptTime = Date()
        }

        #if DEBUG || TESTFLIGHT
        // Apply grace period if transitioning from motion to touch gesture
        if gameModel.currentGestureIndex < gameModel.sequence.count {
            let currentGesture = gameModel.sequence[gameModel.currentGestureIndex]
            if !currentGesture.isMotionGesture && MotionGestureManager.shared.lastDetectedWasMotion {
                let gracePeriod = DevConfigManager.shared.motionToTouchGracePeriod
                timeRemaining += gracePeriod
                print("[\(Date().logTimestamp)] ⏱️ Grace period applied: +\(String(format: "%.1f", gracePeriod))s for motion→touch transition (Memory Mode - first gesture)")
            }
        }
        #endif

        // Activate motion detector for first expected gesture
        activateMemoryModeDetector()

        startCountdown()

        // Replay buffered gesture if any was detected during transition
        isGestureBufferEnabled = false
        if let buffered = pendingGesture {
            pendingGesture = nil
            print("[\(Date().logTimestamp)] 🔄 Replaying buffered gesture: \(buffered.displayName)")
            // Use async to ensure state is fully ready before processing
            DispatchQueue.main.async {
                self.handleGesture(buffered)
            }
        }
    }

    private func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.timeRemaining -= 0.1
            if self.timeRemaining <= 0 {
                // Log gesture_failed for timeout
                self.endedByReason = "timeout"
                if let _ = self.gesturePromptTime,
                   self.gameModel.currentGestureIndex < self.gameModel.sequence.count {
                    let expectedGesture = self.gameModel.sequence[self.gameModel.currentGestureIndex]
                    AnalyticsManager.shared.logGestureFailed(gesture: expectedGesture, mode: .memory, reason: "timeout")
                    self.gesturePromptTime = nil
                }
                self.gameOver()
            }
        }
    }

    func handleGesture(_ gesture: GestureType) {
        // Buffer gesture if in transition period (between playback end and awaitInput)
        if isGestureBufferEnabled && gameState != .awaitInput {
            if pendingGesture == nil {
                pendingGesture = gesture
                print("[\(Date().logTimestamp)] 📦 Gesture buffered: \(gesture.displayName)")
                // Immediate haptic feedback so player knows input was received
                HapticManager.shared.impact()
            }
            return
        }

        guard gameState == .awaitInput else { return }

        // Check timeout FIRST - if time already expired, log timeout not wrong_gesture
        // This fixes race condition where gesture fires at same instant as timeout
        if timeRemaining <= 0 {
            timer?.invalidate()
            endedByReason = "timeout"
            if let _ = gesturePromptTime,
               gameModel.currentGestureIndex < gameModel.sequence.count {
                let expectedGesture = gameModel.sequence[gameModel.currentGestureIndex]
                AnalyticsManager.shared.logGestureFailed(gesture: expectedGesture, mode: .memory, reason: "timeout")
                gesturePromptTime = nil
            }
            gameOver()
            return
        }

        #if DEBUG || TESTFLIGHT
        // Log expected vs detected gesture
        if gameModel.currentGestureIndex < gameModel.sequence.count {
            let expectedGesture = gameModel.sequence[gameModel.currentGestureIndex]
            let isCorrect = gameModel.isCurrentGestureCorrect(gesture)
            DevConfigManager.shared.logGesture(expected: expectedGesture, detected: gesture, success: isCorrect)
        }
        #endif

        if gameModel.isCurrentGestureCorrect(gesture) {
            // Log gesture completion with reaction time (before advancing to next)
            let completedGesture = gameModel.sequence[gameModel.currentGestureIndex]
            if let promptTime = gesturePromptTime {
                let reactionTimeMs = Int(Date().timeIntervalSince(promptTime) * 1000)
                AnalyticsManager.shared.logGestureCompleted(
                    gesture: completedGesture,
                    mode: .memory,
                    reactionTimeMs: reactionTimeMs
                )
            }
            gesturePromptTime = nil

            gameModel.addUserGesture(gesture)
            gameModel.moveToNextGesture()
            HapticManager.shared.impact()
            AudioManager.shared.playSuccess()

            if gameModel.hasCompletedSequence() {
                successfulRound()
            } else {
                // Move to next gesture - update detector for next expected gesture
                activateMemoryModeDetector()
                timeRemaining = GameConfiguration.perGestureTime

                // Log next expected gesture for analytics
                if gameModel.currentGestureIndex < gameModel.sequence.count {
                    let expectedGesture = gameModel.sequence[gameModel.currentGestureIndex]
                    AnalyticsManager.shared.logGesturePrompted(gesture: expectedGesture, mode: .memory)
                    gesturePromptTime = Date()
                }

                #if DEBUG || TESTFLIGHT
                // Apply grace period if transitioning from motion to touch gesture
                if gameModel.currentGestureIndex < gameModel.sequence.count {
                    let currentGesture = gameModel.sequence[gameModel.currentGestureIndex]
                    if !currentGesture.isMotionGesture && MotionGestureManager.shared.lastDetectedWasMotion {
                        let gracePeriod = DevConfigManager.shared.motionToTouchGracePeriod
                        timeRemaining += gracePeriod
                        print("[\(Date().logTimestamp)] ⏱️ Grace period applied: +\(String(format: "%.1f", gracePeriod))s for motion→touch transition (Memory Mode - next gesture)")
                    }
                }
                #endif
            }
        } else {
            // Log gesture_failed for wrong gesture
            endedByReason = "wrong_gesture"
            if let _ = gesturePromptTime,
               gameModel.currentGestureIndex < gameModel.sequence.count {
                let expectedGesture = gameModel.sequence[gameModel.currentGestureIndex]
                AnalyticsManager.shared.logGestureFailed(gesture: expectedGesture, mode: .memory, reason: "wrong_gesture")
                gesturePromptTime = nil
            }
            gameOver()
        }
    }

    private func successfulRound() {
        timer?.invalidate()
        gameState = .judge
        flashColor = .toyBoxSuccess
        HapticManager.shared.success()
        AudioManager.shared.playRoundComplete()

        withAnimation(.easeInOut(duration: GameConfiguration.flashAnimationDuration)) {
            flashColor = .clear
        }

        #if DEBUG || TESTFLIGHT
        // In replay mode, end after completing the stored sequence instead of adding new gestures
        if isMemoryModeReplay {
            print("✅ Replay completed successfully!")
            isMemoryModeReplay = false
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConfiguration.transitionDelay) {
                // Go back to menu after successful replay
                self.gameState = .menu
            }
            return
        }
        #endif

        DispatchQueue.main.asyncAfter(deadline: .now() + GameConfiguration.transitionDelay) {
            // Deactivate motion detector during sequence playback to prevent false failures
            MotionGestureManager.shared.deactivateAllDetectors()

            self.gameModel.startNewRound(with: &self.randomNumberGenerator, discreetMode: self.discreetModeEnabled)
            self.gameState = .showSequence
            self.showingGestureIndex = 0
            self.showNextGestureInSequence()
        }
    }

    private func gameOver() {
        // Guard: Only trigger game over during awaitInput (prevents false failures during sequence playback)
        guard gameState == .awaitInput else {
            #if DEBUG || TESTFLIGHT
            print("⚠️ gameOver() ignored - not in awaitInput state (current: \(gameState))")
            #endif
            return
        }

        timer?.invalidate()

        #if DEBUG || TESTFLIGHT
        // Log timeout if applicable (no gesture detected before time ran out)
        if gameModel.currentGestureIndex < gameModel.sequence.count {
            let expectedGesture = gameModel.sequence[gameModel.currentGestureIndex]
            DevConfigManager.shared.logGesture(expected: expectedGesture, detected: nil, success: false)
        }

        // Only capture sequence for replay if NOT already in replay mode
        // (don't overwrite stored sequence with itself)
        if !isMemoryModeReplay {
            DevConfigManager.shared.captureMemorySequence(gameModel.sequence)
        }
        isMemoryModeReplay = false  // Reset replay flag
        #endif

        // Calculate final score (Memory Mode uses round number)
        let finalScore = gameModel.round

        // Log end_game BEFORE state changes
        let durationSec = Int(Date().timeIntervalSince(gameStartTime ?? Date()))
        AnalyticsManager.shared.logEndGame(
            mode: .memory,
            score: finalScore,
            bestScore: gameModel.bestStreak,
            durationSec: durationSec,
            endedBy: endedByReason,
            discreetMode: discreetModeEnabled
        )
        gameStartTime = nil  // Clear to prevent reuse

        // Check if new high score and add to leaderboard
        isNewHighScore = LeaderboardManager.shared.isNewHighScore(finalScore, mode: .memory)
        LeaderboardManager.shared.addScore(finalScore, for: .memory)

        gameModel.updateBestStreak()
        PersistenceManager.shared.saveBestStreak(gameModel.bestStreak)
        flashColor = .toyBoxError
        FailureFeedbackManager.shared.playFailureFeedback()

        withAnimation(.easeInOut(duration: GameConfiguration.flashAnimationDuration)) {
            flashColor = .clear
        }

        // Deactivate all motion detectors
        MotionGestureManager.shared.deactivateAllDetectors()

        gameState = .gameOver
    }

    func resetToMenu() {
        gameState = .menu
        gameModel.reset()
        classicModeModel.reset()
        flashColor = .clear
        isNewHighScore = false
        // Reset gesture buffer and timing
        isGestureBufferEnabled = false
        pendingGesture = nil
        gesturePromptTime = nil
        MotionGestureManager.shared.deactivateAllDetectors()
    }

    // MARK: - Memory Mode Methods

    private func activateMemoryModeDetector() {
        // Get current expected gesture from sequence
        guard gameModel.currentGestureIndex < gameModel.sequence.count else { return }
        let expectedGesture = gameModel.sequence[gameModel.currentGestureIndex]

        // Activate motion detector if motion gesture expected
        if expectedGesture.isMotionGesture {
            MotionGestureManager.shared.activateDetector(
                for: expectedGesture,
                onDetected: { [weak self] in
                    self?.handleGesture(expectedGesture)
                },
                onWrongGesture: { [weak self] in
                    // Guard: Only fail if still awaiting input (prevents false failures during sequence playback)
                    guard self?.gameState == .awaitInput else { return }
                    // Log gesture_failed for wrong motion gesture
                    self?.endedByReason = "wrong_gesture"
                    if let _ = self?.gesturePromptTime {
                        AnalyticsManager.shared.logGestureFailed(gesture: expectedGesture, mode: .memory, reason: "wrong_gesture")
                        self?.gesturePromptTime = nil
                    }
                    self?.gameOver()
                }
            )
        } else {
            // Touch gesture expected - deactivate motion detectors
            MotionGestureManager.shared.deactivateAllDetectors()
        }
    }

    // MARK: - Classic Mode Methods

    private func showNextClassicGesture() {
        // Generate gesture
        classicModeModel.generateRandomGesture(discreetMode: discreetModeEnabled)

        // Log gesture prompt for analytics
        if let gesture = classicModeModel.currentGesture {
            AnalyticsManager.shared.logGesturePrompted(gesture: gesture, mode: .classic)
            gesturePromptTime = Date()
        }

        // Activate motion detector if motion gesture expected
        if let currentGesture = classicModeModel.currentGesture,
           currentGesture.isMotionGesture {
            MotionGestureManager.shared.activateDetector(
                for: currentGesture,
                onDetected: { [weak self] in
                    self?.handleClassicModeGesture(currentGesture)
                },
                onWrongGesture: { [weak self] in
                    // Log gesture_failed for wrong motion gesture
                    self?.endedByReason = "wrong_gesture"
                    if let _ = self?.gesturePromptTime {
                        AnalyticsManager.shared.logGestureFailed(gesture: currentGesture, mode: .classic, reason: "wrong_gesture")
                        self?.gesturePromptTime = nil
                    }
                    self?.classicModeGameOver()
                }
            )
        } else {
            // Touch gesture expected - deactivate motion detectors
            MotionGestureManager.shared.deactivateAllDetectors()
        }

        // Start countdown
        timeRemaining = classicModeModel.reactionTime

        #if DEBUG || TESTFLIGHT
        // Apply grace period if transitioning from motion to touch gesture
        if let currentGesture = classicModeModel.currentGesture,
           !currentGesture.isMotionGesture,
           MotionGestureManager.shared.lastDetectedWasMotion {
            let gracePeriod = DevConfigManager.shared.motionToTouchGracePeriod
            timeRemaining += gracePeriod
            print("[\(Date().logTimestamp)] ⏱️ Grace period applied: +\(String(format: "%.1f", gracePeriod))s for motion→touch transition (Classic Mode)")
        }
        #endif

        startClassicModeCountdown()
    }

    private func startClassicModeCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.timeRemaining -= 0.1
            if self.timeRemaining <= 0 {
                // Log gesture_failed for timeout
                self.endedByReason = "timeout"
                if let _ = self.gesturePromptTime,
                   let expectedGesture = self.classicModeModel.currentGesture {
                    AnalyticsManager.shared.logGestureFailed(gesture: expectedGesture, mode: .classic, reason: "timeout")
                    self.gesturePromptTime = nil
                }
                self.classicModeGameOver()
            }
        }
    }

    func handleClassicModeGesture(_ gesture: GestureType) {
        guard gameState == .classicMode else { return }
        guard let currentGesture = classicModeModel.currentGesture else { return }

        // Check timeout FIRST - if time already expired, log timeout not wrong_gesture
        // This fixes race condition where gesture fires at same instant as timeout
        if timeRemaining <= 0 {
            timer?.invalidate()
            endedByReason = "timeout"
            if let _ = gesturePromptTime {
                AnalyticsManager.shared.logGestureFailed(gesture: currentGesture, mode: .classic, reason: "timeout")
                gesturePromptTime = nil
            }
            classicModeGameOver()
            return
        }

        timer?.invalidate()

        #if DEBUG || TESTFLIGHT
        // Log expected vs detected gesture
        let isCorrect = isGestureCorrect(gesture, expected: currentGesture)
        DevConfigManager.shared.logGesture(expected: currentGesture, detected: gesture, success: isCorrect)

        // Track gesture in history for replay
        classicGestureHistory.append(currentGesture)
        #endif

        if isGestureCorrect(gesture, expected: currentGesture) {
            // Correct gesture
            classicModeModel.recordSuccess()
            flashColor = .toyBoxSuccess
            HapticManager.shared.success()
            AudioManager.shared.playSuccess()

            // Play round complete milestone every 3 gestures
            if classicModeModel.score % 3 == 0 {
                AudioManager.shared.playRoundComplete()
            }

            // Log gesture completion with reaction time
            if let promptTime = gesturePromptTime {
                let reactionTimeMs = Int(Date().timeIntervalSince(promptTime) * 1000)
                AnalyticsManager.shared.logGestureCompleted(
                    gesture: currentGesture,
                    mode: .classic,
                    reactionTimeMs: reactionTimeMs
                )
            }
            gesturePromptTime = nil

            // Generate next gesture IMMEDIATELY so it's visible right away
            showNextClassicGesture()

            withAnimation(.easeInOut(duration: 0.2)) {
                flashColor = .clear
            }
        } else {
            // Wrong gesture - log failure before game over
            endedByReason = "wrong_gesture"
            if let _ = gesturePromptTime {
                AnalyticsManager.shared.logGestureFailed(gesture: currentGesture, mode: .classic, reason: "wrong_gesture")
                gesturePromptTime = nil
            }
            classicModeGameOver()
        }
    }

    /// Validates if a gesture matches the expected gesture, handling Stroop special logic
    private func isGestureCorrect(_ userGesture: GestureType, expected: GestureType) -> Bool {
        // For Stroop gestures: find which direction the text color is assigned to
        if case .stroop(_, let textColor, let upColor, let downColor, let leftColor, let rightColor) = expected {
            // Find which direction has the text color and check if user swiped that way
            if textColor == upColor {
                return userGesture == .up
            } else if textColor == downColor {
                return userGesture == .down
            } else if textColor == leftColor {
                return userGesture == .left
            } else if textColor == rightColor {
                return userGesture == .right
            }
            return false
        }

        // For all other gestures: direct equality check
        return userGesture == expected
    }

    private func classicModeGameOver() {
        timer?.invalidate()

        #if DEBUG || TESTFLIGHT
        // Log timeout if applicable (no gesture detected before time ran out)
        if let currentGesture = classicModeModel.currentGesture {
            DevConfigManager.shared.logGesture(expected: currentGesture, detected: nil, success: false)
        }

        // Capture sequence for replay debugging (always capture to replace previous)
        DevConfigManager.shared.captureClassicSequence(classicGestureHistory)
        #endif

        // Calculate final score (Classic Mode uses score)
        let finalScore = classicModeModel.score

        // Log end_game BEFORE state changes
        let durationSec = Int(Date().timeIntervalSince(gameStartTime ?? Date()))
        AnalyticsManager.shared.logEndGame(
            mode: .classic,
            score: finalScore,
            bestScore: classicModeModel.bestScore,
            durationSec: durationSec,
            endedBy: endedByReason,
            discreetMode: discreetModeEnabled
        )
        gameStartTime = nil  // Clear to prevent reuse

        // Check if new high score and add to leaderboard
        isNewHighScore = LeaderboardManager.shared.isNewHighScore(finalScore, mode: .classic)
        LeaderboardManager.shared.addScore(finalScore, for: .classic)

        classicModeModel.updateBestScore()
        PersistenceManager.shared.saveClassicBestScore(classicModeModel.bestScore)
        flashColor = .toyBoxError
        FailureFeedbackManager.shared.playFailureFeedback()

        withAnimation(.easeInOut(duration: GameConfiguration.flashAnimationDuration)) {
            flashColor = .clear
        }

        gameState = .gameOver
    }

    // MARK: - Replay Methods (DEBUG ONLY)

    #if DEBUG || TESTFLIGHT
    /// Replay the last played Memory Mode sequence for debugging
    func replayLastMemorySequence() {
        guard let storedSequence = DevConfigManager.shared.lastMemorySequence else {
            print("❌ No Memory sequence to replay")
            return
        }

        // Diagnostic: Log what we're about to replay
        print("🔄 REPLAY DEBUG: Stored sequence from DevConfigManager:")
        print("   Count: \(storedSequence.count)")
        print("   Gestures: \(storedSequence.map { $0.displayName }.joined(separator: ", "))")

        isClassicMode = false
        isMemoryModeReplay = true  // Track that we're in replay mode
        gameModel.reset()

        // Inject stored sequence instead of generating new one
        gameModel.sequence = storedSequence
        gameModel.round = storedSequence.count

        // Diagnostic: Verify assignment
        print("🔄 REPLAY DEBUG: After assignment to gameModel:")
        print("   Count: \(gameModel.sequence.count)")
        print("   Gestures: \(gameModel.sequence.map { $0.displayName }.joined(separator: ", "))")
        print("   Round: \(gameModel.round)")

        DevConfigManager.shared.clearLogs()

        gameState = .showSequence
        showingGestureIndex = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showNextGestureInSequence()
        }

        print("🔄 Replaying Memory sequence (\(storedSequence.count) gestures): \(storedSequence.map { $0.displayName }.joined(separator: ", "))")
    }

    /// Replay the last played Classic Mode sequence for debugging
    func replayLastClassicSequence() {
        guard let storedSequence = DevConfigManager.shared.lastClassicSequence,
              !storedSequence.isEmpty else {
            print("❌ No Classic sequence to replay")
            return
        }

        isClassicMode = true
        classicModeModel.reset()

        DevConfigManager.shared.clearLogs()
        classicGestureHistory.removeAll()

        // Set up replay state
        classicModeReplaySequence = storedSequence
        classicModeReplayIndex = 0

        gameState = .classicMode
        showNextClassicReplayGesture()

        print("🔄 Replaying Classic sequence (\(storedSequence.count) gestures): \(storedSequence.map { $0.displayName }.joined(separator: ", "))")
    }

    /// Show next gesture in Classic Mode replay sequence
    private func showNextClassicReplayGesture() {
        guard let replaySequence = classicModeReplaySequence,
              classicModeReplayIndex < replaySequence.count else {
            // Replay finished - switch to normal generation
            classicModeReplaySequence = nil
            showNextClassicGesture()
            return
        }

        // Use stored gesture instead of generating random
        classicModeModel.currentGesture = replaySequence[classicModeReplayIndex]
        classicModeReplayIndex += 1

        // Activate motion detector if needed
        if let currentGesture = classicModeModel.currentGesture,
           currentGesture.isMotionGesture {
            MotionGestureManager.shared.activateDetector(
                for: currentGesture,
                onDetected: { [weak self] in
                    self?.handleClassicModeGesture(currentGesture)
                },
                onWrongGesture: { [weak self] in
                    self?.classicModeGameOver()
                }
            )
        } else {
            MotionGestureManager.shared.deactivateAllDetectors()
        }

        // Start countdown
        timeRemaining = classicModeModel.reactionTime

        // Apply grace period if transitioning from motion to touch gesture
        if let currentGesture = classicModeModel.currentGesture,
           !currentGesture.isMotionGesture,
           MotionGestureManager.shared.lastDetectedWasMotion {
            let gracePeriod = DevConfigManager.shared.motionToTouchGracePeriod
            timeRemaining += gracePeriod
            print("[\(Date().logTimestamp)] ⏱️ Grace period applied: +\(String(format: "%.1f", gracePeriod))s for motion→touch transition (Classic Replay)")
        }

        startClassicModeCountdown()
    }
    #endif
}
