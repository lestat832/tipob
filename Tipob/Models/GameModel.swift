import Foundation

struct GameModel {
    var sequence: [GestureType] = []
    var userBuffer: [GestureType] = []
    var round: Int = 0
    var bestStreak: Int = 0
    var timeRemaining: Double = 0.0
    var currentGestureIndex: Int = 0

    mutating func reset() {
        sequence = []
        userBuffer = []
        round = 0
        timeRemaining = 0.0
        currentGestureIndex = 0
    }

    mutating func startNewRound(with randomNumberGenerator: inout RandomNumberGenerator) {
        round += 1
        userBuffer = []
        currentGestureIndex = 0
        sequence.append(GestureType.allCases.randomElement(using: &randomNumberGenerator) ?? .up)
        timeRemaining = Double(sequence.count) * GameConfiguration.perGestureTime
    }

    mutating func addUserGesture(_ gesture: GestureType) {
        userBuffer.append(gesture)
    }

    func isCurrentGestureCorrect(_ gesture: GestureType) -> Bool {
        guard currentGestureIndex < sequence.count else { return false }
        return sequence[currentGestureIndex] == gesture
    }

    mutating func moveToNextGesture() {
        currentGestureIndex += 1
    }

    func hasCompletedSequence() -> Bool {
        return currentGestureIndex >= sequence.count
    }

    mutating func updateBestStreak() {
        if round > bestStreak {
            bestStreak = round
        }
    }
}

struct GameConfiguration {
    static var perGestureTime: TimeInterval = 3.0
    static var minSwipeDistance: CGFloat = 50.0
    static var minSwipeVelocity: CGFloat = 100.0
    static var edgeBufferDistance: CGFloat = 24.0
    static var sequenceShowDuration: TimeInterval = 0.6
    static var sequenceGapDuration: TimeInterval = 0.2
    static var transitionDelay: TimeInterval = 0.5
    static var flashAnimationDuration: TimeInterval = 0.3
}