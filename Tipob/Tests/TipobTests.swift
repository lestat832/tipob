import XCTest
@testable import Tipob

class TipobTests: XCTestCase {

    func testGestureDirection() {
        let testCases: [(angle: CGFloat, expected: GestureType)] = [
            (0, .right),
            (30 * .pi / 180, .right),
            (90 * .pi / 180, .down),
            (180 * .pi / 180, .left),
            (-90 * .pi / 180, .up),
            (-45 * .pi / 180, .up),
            (45 * .pi / 180, .down)
        ]

        for testCase in testCases {
            let result = determineGestureFromAngle(testCase.angle)
            XCTAssertEqual(result, testCase.expected, "Angle \(testCase.angle) should map to \(testCase.expected)")
        }
    }

    func testSequenceComparison() {
        var model = GameModel()
        model.sequence = [.up, .down, .left, .right]
        model.currentGestureIndex = 0

        XCTAssertTrue(model.isCurrentGestureCorrect(.up))
        model.moveToNextGesture()

        XCTAssertTrue(model.isCurrentGestureCorrect(.down))
        model.moveToNextGesture()

        XCTAssertTrue(model.isCurrentGestureCorrect(.left))
        model.moveToNextGesture()

        XCTAssertTrue(model.isCurrentGestureCorrect(.right))
        model.moveToNextGesture()

        XCTAssertTrue(model.hasCompletedSequence())
    }

    func testDeterministicSequence() {
        struct TestRandomNumberGenerator: RandomNumberGenerator {
            var seed: UInt64
            mutating func next() -> UInt64 {
                seed = (seed &* 1103515245 &+ 12345) & 0x7fffffff
                return seed
            }
        }

        var rng1 = TestRandomNumberGenerator(seed: 42)
        var rng2 = TestRandomNumberGenerator(seed: 42)

        var model1 = GameModel()
        var model2 = GameModel()

        model1.startNewRound(with: &rng1)
        model2.startNewRound(with: &rng2)

        XCTAssertEqual(model1.sequence, model2.sequence)
    }

    func testBestStreakPersistence() {
        let persistence = PersistenceManager.shared
        persistence.saveBestStreak(10)
        let loaded = persistence.loadBestStreak()
        XCTAssertEqual(loaded, 10)
    }

    func testConfigurableTimeouts() {
        let originalTime = GameConfiguration.perGestureTime
        GameConfiguration.perGestureTime = 5.0
        XCTAssertEqual(GameConfiguration.perGestureTime, 5.0)
        GameConfiguration.perGestureTime = originalTime
    }

    func testSwipeThresholds() {
        let originalDistance = GameConfiguration.minSwipeDistance
        let originalVelocity = GameConfiguration.minSwipeVelocity

        GameConfiguration.minSwipeDistance = 100.0
        GameConfiguration.minSwipeVelocity = 200.0

        XCTAssertEqual(GameConfiguration.minSwipeDistance, 100.0)
        XCTAssertEqual(GameConfiguration.minSwipeVelocity, 200.0)

        GameConfiguration.minSwipeDistance = originalDistance
        GameConfiguration.minSwipeVelocity = originalVelocity
    }

    private func determineGestureFromAngle(_ angle: CGFloat) -> GestureType {
        let degrees = angle * 180 / .pi
        switch degrees {
        case -45...45:
            return .right
        case 45...135:
            return .down
        case -135...(-45):
            return .up
        default:
            return .left
        }
    }
}