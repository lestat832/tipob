import SwiftUI
import UIKit

/// UIKit-based pinch gesture recognizer wrapper for reliable detection
/// Uses native UIPinchGestureRecognizer for pinch
struct PinchGestureView: UIViewRepresentable {
    let onPinch: () -> Void
    // let onSpread: () -> Void  // SPREAD: Temporarily disabled

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // CRITICAL: Enable multi-touch for 2-finger gestures
        view.isMultipleTouchEnabled = true

        // Pinch gesture: Native iOS recognizer for fingers moving together
        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(_:))
        )
        pinchGesture.delegate = context.coordinator

        /*  // SPREAD: Temporarily disabled - detection issues
        // Spread gesture: Pan recognizer configured for 2-finger distance tracking
        let spreadGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleSpreadPan(_:))
        )
        spreadGesture.minimumNumberOfTouches = 2
        spreadGesture.maximumNumberOfTouches = 2
        spreadGesture.delegate = context.coordinator
        view.addGestureRecognizer(spreadGesture)
        */

        view.addGestureRecognizer(pinchGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onPinch: onPinch)  // Removed onSpread parameter
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let onPinch: () -> Void
        // let onSpread: () -> Void  // SPREAD: Temporarily disabled
        var hasPinchTriggered = false

        /*  // SPREAD: Temporarily disabled
        // Distance tracking for spread gesture
        var spreadInitialDistance: CGFloat?
        var hasSpreadTriggered = false
        */

        init(onPinch: @escaping () -> Void) {  // Removed onSpread parameter
            self.onPinch = onPinch
            // self.onSpread = onSpread  // SPREAD: Temporarily disabled
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                print("[\(Date().logTimestamp)] 🔍 Pinch: Began - scale=\(String(format: "%.2f", gesture.scale))")

            case .changed:
                // Debug logging for scale tracking
                if gesture.scale < 0.9 {
                    print("[\(Date().logTimestamp)] 🔍 Pinch: Scale=\(String(format: "%.2f", gesture.scale)) - triggered=\(hasPinchTriggered)")
                }

                // Detect pinch when scale drops below threshold (default 0.85 = 15% reduction)
                #if DEBUG
                let pinchThreshold = DevConfigManager.shared.pinchScaleThreshold
                #else
                let pinchThreshold: CGFloat = 0.85
                #endif

                if gesture.scale < pinchThreshold && !hasPinchTriggered {
                    // Check with GestureCoordinator for intelligent filtering
                    guard GestureCoordinator.shared.shouldAllowGesture(.pinch) else {
                        print("[\(Date().logTimestamp)] ⏸️ Pinch suppressed by coordinator")
                        return
                    }
                    print("[\(Date().logTimestamp)] 🎯 Pinch detected! Scale=\(String(format: "%.2f", gesture.scale))")
                    hasPinchTriggered = true
                    onPinch()
                }

            case .ended, .cancelled, .failed:
                print("[\(Date().logTimestamp)] 🔍 Pinch: Ended - final scale=\(String(format: "%.2f", gesture.scale))")
                // Reset for next gesture
                hasPinchTriggered = false

            default:
                break
            }
        }

        /*  // SPREAD: Temporarily disabled - detection issues
        @objc func handleSpreadPan(_ gesture: UIPanGestureRecognizer) {
            // Verify exactly 2 touches
            guard gesture.numberOfTouches == 2 else { return }

            guard let view = gesture.view else { return }

            // Get positions of both touches
            let touch1 = gesture.location(ofTouch: 0, in: view)
            let touch2 = gesture.location(ofTouch: 1, in: view)
            let currentDistance = hypot(touch2.x - touch1.x, touch2.y - touch1.y)

            switch gesture.state {
            case .began:
                spreadInitialDistance = currentDistance
                hasSpreadTriggered = false

            case .changed:
                guard let initialDist = spreadInitialDistance else { return }

                let ratio = currentDistance / initialDist

                // Trigger spread when distance increases by 30%
                if !hasSpreadTriggered && ratio >= 1.3 {
                    hasSpreadTriggered = true
                    onSpread()
                }

            case .ended, .cancelled, .failed:
                spreadInitialDistance = nil
                hasSpreadTriggered = false

            default:
                break
            }
        }
        */

        // MARK: - UIGestureRecognizerDelegate

        /// Allow multiple gestures to be recognized simultaneously
        /// This prevents one gesture from blocking the other
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
    }
}

extension View {
    /// Adds native UIKit pinch gesture detection
    /// Pinch: UIPinchGestureRecognizer (fingers moving together, scale < 0.8)
    func detectPinch(onPinch: @escaping () -> Void) -> some View {
        self.background(
            PinchGestureView(onPinch: onPinch)
                .allowsHitTesting(true)
        )
    }
}
