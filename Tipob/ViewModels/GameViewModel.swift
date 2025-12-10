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

    // MARK: - Analytics timing
    var gameStartTime: Date?

    private var timer: Timer?
    var randomNumberGenerator: RandomNumberGenerator = SystemRandomNumberGenerator()

    #if DEBUG
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

    func startTutorial() {
        gameStartTime = Date()
        AnalyticsManager.shared.logStartGame(mode: .tutorial, discreetMode: false)
        gameState = .tutorial
    }

    func startClassic(isReplay: Bool = false) {
        gameStartTime = Date()
        if !isReplay {
            AnalyticsManager.shared.logStartGame(mode: .classic, discreetMode: discreetModeEnabled)
        }
        isClassicMode = true
        classicModeModel.reset()

        #if DEBUG
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
        if !isReplay {
            AnalyticsManager.shared.logStartGame(mode: .memory, discreetMode: discreetModeEnabled)
        }
        isClassicMode = false
        gameModel.reset()

        #if DEBUG
        DevConfigManager.shared.clearLogs()
        isMemoryModeReplay = false  // Reset replay flag for normal game
        #endif

        // Preload ad for game over screen
        AdManager.shared.preloadIfNeeded()

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
            #if DEBUG
            if isMemoryModeReplay {
                print("🔄 REPLAY DEBUG: Finished showing all \(gameModel.sequence.count) gestures")
            }
            #endif
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConfiguration.transitionDelay) {
                self.transitionToAwaitInput()
            }
            return
        }

        #if DEBUG
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

        #if DEBUG
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
    }

    private func startCountdown() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.timeRemaining -= 0.1
            if self.timeRemaining <= 0 {
                self.gameOver()
            }
        }
    }

    func handleGesture(_ gesture: GestureType) {
        guard gameState == .awaitInput else { return }

        #if DEBUG
        // Log expected vs detected gesture
        if gameModel.currentGestureIndex < gameModel.sequence.count {
            let expectedGesture = gameModel.sequence[gameModel.currentGestureIndex]
            let isCorrect = gameModel.isCurrentGestureCorrect(gesture)
            DevConfigManager.shared.logGesture(expected: expectedGesture, detected: gesture, success: isCorrect)
        }
        #endif

        if gameModel.isCurrentGestureCorrect(gesture) {
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

                #if DEBUG
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

        #if DEBUG
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
            self.gameModel.startNewRound(with: &self.randomNumberGenerator, discreetMode: self.discreetModeEnabled)
            self.gameState = .showSequence
            self.showingGestureIndex = 0
            self.showNextGestureInSequence()
        }
    }

    private func gameOver() {
        timer?.invalidate()

        #if DEBUG
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

        // Activate motion detector if motion gesture expected
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
            // Touch gesture expected - deactivate motion detectors
            MotionGestureManager.shared.deactivateAllDetectors()
        }

        // Start countdown
        timeRemaining = classicModeModel.reactionTime

        #if DEBUG
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
                self.classicModeGameOver()
            }
        }
    }

    func handleClassicModeGesture(_ gesture: GestureType) {
        guard gameState == .classicMode else { return }
        guard let currentGesture = classicModeModel.currentGesture else { return }

        timer?.invalidate()

        #if DEBUG
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

            // Generate next gesture IMMEDIATELY so it's visible right away
            showNextClassicGesture()

            withAnimation(.easeInOut(duration: 0.2)) {
                flashColor = .clear
            }
        } else {
            // Wrong gesture
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

        #if DEBUG
        // Log timeout if applicable (no gesture detected before time ran out)
        if let currentGesture = classicModeModel.currentGesture {
            DevConfigManager.shared.logGesture(expected: currentGesture, detected: nil, success: false)
        }

        // Capture sequence for replay debugging (always capture to replace previous)
        DevConfigManager.shared.captureClassicSequence(classicGestureHistory)
        #endif

        // Calculate final score (Classic Mode uses score)
        let finalScore = classicModeModel.score

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

    #if DEBUG
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
