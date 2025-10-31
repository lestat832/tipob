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

        // Equal distribution: 1/14 chance for each gesture type
        var pool = GestureType.allBasicGestures  // 13 basic gestures
        pool.append(.randomStroop())  // Add 1 Stroop instance
        let newGesture = pool.randomElement(using: &randomNumberGenerator) ?? .up

        sequence.append(newGesture)
        timeRemaining = Double(sequence.count) * GameConfiguration.perGestureTime
    }

    mutating func addUserGesture(_ gesture: GestureType) {
        userBuffer.append(gesture)
    }

    func isCurrentGestureCorrect(_ gesture: GestureType) -> Bool {
        guard currentGestureIndex < sequence.count else { return false }
        let expectedGesture = sequence[currentGestureIndex]

        // For Stroop gestures: find which direction the text color is assigned to
        if case .stroop(_, let textColor, let upColor, let downColor, let leftColor, let rightColor) = expectedGesture {
            // Find which direction has the text color and check if user swiped that way
            if textColor == upColor {
                return gesture == .up
            } else if textColor == downColor {
                return gesture == .down
            } else if textColor == leftColor {
                return gesture == .left
            } else if textColor == rightColor {
                return gesture == .right
            }
            return false
        }

        // For all other gestures: direct equality check
        return expectedGesture == gesture
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
    static var pinchMinimumChange: CGFloat = 0.08  // 8% inward change for hybrid pinch detection (threshold + velocity)
}