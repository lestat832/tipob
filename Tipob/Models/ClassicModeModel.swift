import Foundation

struct ClassicModeModel {
    var currentGesture: GestureType?
    var score: Int = 0
    var bestScore: Int = 0
    var reactionTime: TimeInterval = ClassicModeModel.initialReactionTime
    var gesturesSinceSpeedUp: Int = 0

    static let initialReactionTime: TimeInterval = 3.0
    static let minimumReactionTime: TimeInterval = 1.0
    static let speedUpInterval: Int = 3
    static let speedUpAmount: TimeInterval = 0.2

    mutating func reset() {
        score = 0
        reactionTime = ClassicModeModel.initialReactionTime
        gesturesSinceSpeedUp = 0
        // Generate initial gesture immediately so it's ready when view renders
        generateRandomGesture()
    }

    mutating func generateRandomGesture() {
        // Equal distribution: 1/14 chance for each gesture type
        currentGesture = GestureType.random()
    }

    mutating func recordSuccess() {
        score += 1
        gesturesSinceSpeedUp += 1

        // Speed up every 3 successful gestures
        if gesturesSinceSpeedUp >= ClassicModeModel.speedUpInterval {
            gesturesSinceSpeedUp = 0
            let newTime = reactionTime - ClassicModeModel.speedUpAmount
            reactionTime = max(newTime, ClassicModeModel.minimumReactionTime)
        }
    }

    mutating func updateBestScore() {
        if score > bestScore {
            bestScore = score
        }
    }
}
