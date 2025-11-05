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

    private var timer: Timer?
    var randomNumberGenerator: RandomNumberGenerator = SystemRandomNumberGenerator()

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
        gameState = .tutorial
    }

    func startClassicMode() {
        isClassicMode = true
        classicModeModel.reset()
        gameState = .classicMode
        showNextClassicGesture()
    }

    func startGameVsPlayerVsPlayer() {
        gameState = .gameVsPlayerVsPlayer
    }

    func startPlayerVsPlayer() {
        gameState = .playerVsPlayer
    }

    func startGame() {
        isClassicMode = false
        gameModel.reset()
        gameModel.startNewRound(with: &randomNumberGenerator, discreetMode: discreetModeEnabled)
        gameState = .showSequence
        showingGestureIndex = 0

        // Stop old gesture managers (cleanup from Tutorial/other modes)
        MotionGestureManager.shared.stopAllOldGestureManagers()

        // Add initial delay so player can read "Watch the sequence!" message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showNextGestureInSequence()
        }
    }

    private func showNextGestureInSequence() {
        guard showingGestureIndex < gameModel.sequence.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConfiguration.transitionDelay) {
                self.transitionToAwaitInput()
            }
            return
        }

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

        if gameModel.isCurrentGestureCorrect(gesture) {
            gameModel.addUserGesture(gesture)
            gameModel.moveToNextGesture()
            HapticManager.shared.impact()

            if gameModel.hasCompletedSequence() {
                successfulRound()
            } else {
                // Move to next gesture - update detector for next expected gesture
                activateMemoryModeDetector()
                timeRemaining = GameConfiguration.perGestureTime
            }
        } else {
            gameOver()
        }
    }

    private func successfulRound() {
        timer?.invalidate()
        gameState = .judge
        flashColor = .green
        HapticManager.shared.success()

        withAnimation(.easeInOut(duration: GameConfiguration.flashAnimationDuration)) {
            flashColor = .clear
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + GameConfiguration.transitionDelay) {
            self.gameModel.startNewRound(with: &self.randomNumberGenerator, discreetMode: self.discreetModeEnabled)
            self.gameState = .showSequence
            self.showingGestureIndex = 0
            self.showNextGestureInSequence()
        }
    }

    private func gameOver() {
        timer?.invalidate()

        // Calculate final score (Memory Mode uses round number)
        let finalScore = gameModel.round

        // Check if new high score and add to leaderboard
        isNewHighScore = LeaderboardManager.shared.isNewHighScore(finalScore, mode: .memory)
        LeaderboardManager.shared.addScore(finalScore, for: .memory)

        gameModel.updateBestStreak()
        PersistenceManager.shared.saveBestStreak(gameModel.bestStreak)
        flashColor = .red
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

        // Stop old gesture managers (cleanup from Tutorial/other modes)
        MotionGestureManager.shared.stopAllOldGestureManagers()

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

        if isGestureCorrect(gesture, expected: currentGesture) {
            // Correct gesture
            classicModeModel.recordSuccess()
            flashColor = .green
            HapticManager.shared.success()

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

        // Calculate final score (Classic Mode uses score)
        let finalScore = classicModeModel.score

        // Check if new high score and add to leaderboard
        isNewHighScore = LeaderboardManager.shared.isNewHighScore(finalScore, mode: .classic)
        LeaderboardManager.shared.addScore(finalScore, for: .classic)

        classicModeModel.updateBestScore()
        PersistenceManager.shared.saveClassicBestScore(classicModeModel.bestScore)
        flashColor = .red
        FailureFeedbackManager.shared.playFailureFeedback()

        withAnimation(.easeInOut(duration: GameConfiguration.flashAnimationDuration)) {
            flashColor = .clear
        }

        gameState = .gameOver
    }
}
