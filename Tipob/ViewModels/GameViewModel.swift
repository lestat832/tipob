import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState = .launch
    @Published var gameModel = GameModel()
    @Published var showingGestureIndex = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var flashColor: Color = .clear

    private var timer: Timer?
    private var sequenceTimer: Timer?
    var randomNumberGenerator: RandomNumberGenerator = SystemRandomNumberGenerator()

    init() {
        gameModel.bestStreak = PersistenceManager.shared.loadBestStreak()
    }

    func transitionToMenu() {
        gameState = .menu
    }

    func startGame() {
        gameModel.reset()
        gameModel.startNewRound(with: &randomNumberGenerator)
        gameState = .showSequence
        showingGestureIndex = 0
        showNextGestureInSequence()
    }

    private func showNextGestureInSequence() {
        guard showingGestureIndex < gameModel.sequence.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.transitionToAwaitInput()
            }
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (GameConfiguration.sequenceShowDuration + GameConfiguration.sequenceGapDuration)) {
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

    func handleSwipe(_ gesture: GestureType) {
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

        withAnimation(.easeInOut(duration: 0.3)) {
            flashColor = .clear
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
        HapticManager.shared.error()

        withAnimation(.easeInOut(duration: 0.3)) {
            flashColor = .clear
        }

        gameState = .gameOver
    }

    func resetToMenu() {
        gameState = .menu
        gameModel.reset()
        flashColor = .clear
    }
}