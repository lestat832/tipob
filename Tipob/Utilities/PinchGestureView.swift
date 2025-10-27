import SwiftUI
import UIKit

/// UIKit-based pinch gesture recognizer wrapper for reliable pinch detection
/// Uses native UIPinchGestureRecognizer instead of SwiftUI's MagnificationGesture
struct PinchGestureView: UIViewRepresentable {
    let onPinch: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // Create native iOS pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(_:))
        )

        view.addGestureRecognizer(pinchGesture)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onPinch: onPinch)
    }

    class Coordinator: NSObject {
        let onPinch: () -> Void
        var hasTriggered = false

        init(onPinch: @escaping () -> Void) {
            self.onPinch = onPinch
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .changed:
                // Trigger when pinched inward below threshold
                // scale < 1.0 = pinching inward
                // scale > 1.0 = spreading outward
                if gesture.scale < 0.9 && !hasTriggered {
                    hasTriggered = true
                    onPinch()

                    // Provide haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }

            case .ended, .cancelled, .failed:
                // Reset for next gesture
                hasTriggered = false

            default:
                break
            }
        }
    }
}

extension View {
    /// Adds native UIKit pinch gesture detection
    /// More reliable than SwiftUI's MagnificationGesture
    func detectPinchNative(onPinch: @escaping () -> Void) -> some View {
        self.background(
            PinchGestureView(onPinch: onPinch)
                .allowsHitTesting(true)  // Capture pinch gestures
        )
    }
}
