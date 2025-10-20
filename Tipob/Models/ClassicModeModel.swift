import Foundation

struct ClassicModeModel {
    var currentGesture: GestureType?
    var score: Int = 0
    var reactionTime: TimeInterval = ClassicModeModel.initialReactionTime
    var gesturesSinceSpeedUp: Int = 0

    static let initialReactionTime: TimeInterval = 3.0
    static let minimumReactionTime: TimeInterval = 1.0
    static let speedUpInterval: Int = 3
    static let speedUpAmount: TimeInterval = 0.2

    mutating func reset() {
        currentGesture = nil
        score = 0
        reactionTime = ClassicModeModel.initialReactionTime
        gesturesSinceSpeedUp = 0
    }

    mutating func generateRandomGesture() -> GestureType {
        let allGestures = GestureType.allCases
        let randomGesture = allGestures.randomElement()!
        currentGesture = randomGesture
        return randomGesture
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
}
