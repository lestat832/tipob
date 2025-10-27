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
        gameModel.startNewRound(with: &randomNumberGenerator)
        gameState = .showSequence
        showingGestureIndex = 0

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
            self.gameModel.startNewRound(with: &self.randomNumberGenerator)
            self.gameState = .showSequence
            self.showingGestureIndex = 0
            self.showNextGestureInSequence()
        }
    }

    private func gameOver() {
        timer?.invalidate()
        gameModel.updateBestStreak()
        PersistenceManager.shared.saveBestStreak(gameModel.bestStreak)
        flashColor = .red
        FailureFeedbackManager.shared.playFailureFeedback()

        withAnimation(.easeInOut(duration: GameConfiguration.flashAnimationDuration)) {
            flashColor = .clear
        }

        gameState = .gameOver
    }

    func resetToMenu() {
        gameState = .menu
        gameModel.reset()
        classicModeModel.reset()
        flashColor = .clear
    }

    // MARK: - Classic Mode Methods

    private func showNextClassicGesture() {
        classicModeModel.generateRandomGesture()
        timeRemaining = classicModeModel.reactionTime
        startClassicModeCountdown()
        // Explicitly notify SwiftUI of the change
        objectWillChange.send()
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

        if gesture == currentGesture {
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

    private func classicModeGameOver() {
        timer?.invalidate()
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
