import SwiftUI
import UIKit

/// UIKit-based pinch/spread gesture recognizer wrapper for reliable detection
/// Uses native UIPinchGestureRecognizer for pinch and custom SpreadGestureRecognizer for spread
struct PinchSpreadGestureView: UIViewRepresentable {
    let onPinch: () -> Void
    let onSpread: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // Pinch gesture: Native iOS recognizer for fingers moving together
        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(_:))
        )

        // Spread gesture: Custom recognizer for fingers moving apart from close position
        let spreadGesture = SpreadGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleSpread(_:))
        )

        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(spreadGesture)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onPinch: onPinch, onSpread: onSpread)
    }

    class Coordinator: NSObject {
        let onPinch: () -> Void
        let onSpread: () -> Void
        var hasPinchTriggered = false

        init(onPinch: @escaping () -> Void, onSpread: @escaping () -> Void) {
            self.onPinch = onPinch
            self.onSpread = onSpread
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .changed:
                // Detect pinch when scale drops below 0.7 (30% reduction)
                if gesture.scale < 0.7 && !hasPinchTriggered {
                    hasPinchTriggered = true
                    onPinch()
                }

            case .ended, .cancelled, .failed:
                // Reset for next gesture
                hasPinchTriggered = false

            default:
                break
            }
        }

        @objc func handleSpread(_ gesture: SpreadGestureRecognizer) {
            // Spread gesture recognizer handles all detection logic
            // Simply trigger callback when gesture is recognized
            if gesture.state == .recognized {
                onSpread()
            }
        }
    }
}

extension View {
    /// Adds native UIKit pinch and spread gesture detection
    /// Pinch: Native UIPinchGestureRecognizer (fingers moving together)
    /// Spread: Custom SpreadGestureRecognizer (fingers moving apart from close position)
    func detectPinchSpread(onPinch: @escaping () -> Void, onSpread: @escaping () -> Void) -> some View {
        self.background(
            PinchSpreadGestureView(onPinch: onPinch, onSpread: onSpread)
                .allowsHitTesting(true)
        )
    }
}
