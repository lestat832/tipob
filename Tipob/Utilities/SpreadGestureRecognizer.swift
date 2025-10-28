import UIKit

/// Custom gesture recognizer for detecting spread gestures (two fingers moving apart)
/// Specifically designed to detect spreading motion starting with fingers close together
class SpreadGestureRecognizer: UIGestureRecognizer {

    // MARK: - Properties

    /// Initial distance between two fingers when gesture begins
    private var initialDistance: CGFloat?

    /// Threshold multiplier for spread detection (1.3 = 30% expansion required)
    private let spreadThreshold: CGFloat = 1.3

    /// Maximum initial distance to be considered a "close together" start
    /// If fingers start farther apart than this, gesture fails (not a spread from close position)
    private let maxInitialDistance: CGFloat = 100.0

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)

        guard let view = view else { return }

        // Get all touches currently on this view
        guard let allTouches = event.touches(for: view), allTouches.count == 2 else {
            state = .failed
            return
        }

        // Calculate initial distance between two fingers
        if let distance = calculateDistance(from: allTouches, in: view) {
            // Only proceed if fingers start close together
            if distance <= maxInitialDistance {
                initialDistance = distance
                state = .began
            } else {
                // Fingers too far apart at start - not a spread gesture from close position
                state = .failed
            }
        } else {
            state = .failed
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        guard let view = view,
              let initialDist = initialDistance else {
            state = .failed
            return
        }

        // Verify still exactly 2 touches
        guard let allTouches = event.touches(for: view), allTouches.count == 2 else {
            state = .failed
            return
        }

        // Calculate current distance
        guard let currentDist = calculateDistance(from: allTouches, in: view) else {
            state = .failed
            return
        }

        // Check if spread threshold exceeded
        let expansionRatio = currentDist / initialDist

        if expansionRatio >= spreadThreshold {
            // Spread detected! Fingers moved apart by 30%+
            state = .recognized
        }
        // Otherwise keep state as .began and continue tracking
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)

        // If gesture hasn't been recognized yet, it failed
        if state == .began {
            state = .failed
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        state = .cancelled
    }

    // MARK: - Gesture Lifecycle

    override func reset() {
        super.reset()
        initialDistance = nil
    }

    // MARK: - Helper Methods

    /// Calculate Euclidean distance between two touch points
    private func calculateDistance(from touches: Set<UITouch>, in view: UIView) -> CGFloat? {
        guard touches.count == 2 else { return nil }

        let touchArray = Array(touches)
        let point1 = touchArray[0].location(in: view)
        let point2 = touchArray[1].location(in: view)

        // Use hypot for accurate distance calculation
        return hypot(point2.x - point1.x, point2.y - point1.y)
    }
}
