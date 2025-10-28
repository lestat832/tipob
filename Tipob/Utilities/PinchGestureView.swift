import SwiftUI
import UIKit

/// UIKit-based pinch/spread gesture recognizer wrapper for reliable detection
/// Uses single native UIPinchGestureRecognizer to detect both pinch (inward) and spread (outward)
struct PinchSpreadGestureView: UIViewRepresentable {
    let onPinch: () -> Void
    let onSpread: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // Create native iOS pinch gesture recognizer
        // This recognizer handles both pinch and spread gestures
        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinchSpread(_:))
        )

        view.addGestureRecognizer(pinchGesture)
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
        var hasTriggered = false

        // Direction-based detection properties
        var previousScale: CGFloat?
        var consistentDirectionCount: Int = 0

        init(onPinch: @escaping () -> Void, onSpread: @escaping () -> Void) {
            self.onPinch = onPinch
            self.onSpread = onSpread
        }

        @objc func handlePinchSpread(_ gesture: UIPinchGestureRecognizer) {
            let currentScale = gesture.scale

            switch gesture.state {
            case .began:
                // Initialize tracking for new gesture
                previousScale = currentScale
                consistentDirectionCount = 0
                print("[PinchSpread] ✋ Gesture BEGAN - initial scale: \(String(format: "%.3f", currentScale))")

            case .changed:
                guard let prevScale = previousScale else { return }

                // Calculate scale change (velocity)
                let scaleChange = currentScale - prevScale

                print("[PinchSpread] 📊 Scale: \(String(format: "%.3f", currentScale)) | Change: \(String(format: "%+.3f", scaleChange)) | Direction count: \(consistentDirectionCount)")

                // Direction-based detection with reversal support:
                // Positive change = spreading (fingers moving apart)
                // Negative change = pinching (fingers moving together)
                // Allow direction changes before gesture triggers

                if scaleChange > 0.01 {
                    // Spreading motion detected
                    if consistentDirectionCount < 0 {
                        // Was pinching, now spreading - reset counter
                        print("[PinchSpread] 🔄 Direction REVERSED from pinch to spread | Resetting counter")
                        consistentDirectionCount = 0
                    }

                    consistentDirectionCount += 1
                    print("[PinchSpread] ↗️ Spreading motion | Count: \(consistentDirectionCount)")

                    if consistentDirectionCount >= 3 && !hasTriggered {
                        hasTriggered = true
                        print("[PinchSpread] 🫱🫲 SPREAD TRIGGERED after \(consistentDirectionCount) consistent frames at scale \(String(format: "%.3f", currentScale))")
                        onSpread()
                    }

                } else if scaleChange < -0.01 {
                    // Pinching motion detected
                    if consistentDirectionCount > 0 {
                        // Was spreading, now pinching - reset counter
                        print("[PinchSpread] 🔄 Direction REVERSED from spread to pinch | Resetting counter")
                        consistentDirectionCount = 0
                    }

                    consistentDirectionCount -= 1
                    print("[PinchSpread] ↘️ Pinching motion | Count: \(consistentDirectionCount)")

                    if consistentDirectionCount <= -3 && !hasTriggered {
                        hasTriggered = true
                        print("[PinchSpread] 🤏 PINCH TRIGGERED after \(abs(consistentDirectionCount)) consistent frames at scale \(String(format: "%.3f", currentScale))")
                        onPinch()
                    }

                } else {
                    // Scale change too small (noise/jitter), don't update counter
                    print("[PinchSpread] ⏸️ No significant movement (change: \(String(format: "%.3f", scaleChange)))")
                }

                previousScale = currentScale

            case .ended, .cancelled, .failed:
                // Reset for next gesture
                print("[PinchSpread] ✅ Gesture ENDED - final scale: \(String(format: "%.3f", currentScale)) | Direction count: \(consistentDirectionCount)")
                hasTriggered = false
                previousScale = nil
                consistentDirectionCount = 0

            default:
                break
            }
        }
    }
}

extension View {
    /// Adds native UIKit pinch and spread gesture detection
    /// More reliable than SwiftUI's MagnificationGesture
    /// Uses single recognizer to detect both inward (pinch) and outward (spread) motions
    func detectPinchSpread(onPinch: @escaping () -> Void, onSpread: @escaping () -> Void) -> some View {
        self.background(
            PinchSpreadGestureView(onPinch: onPinch, onSpread: onSpread)
                .allowsHitTesting(true)  // Capture pinch/spread gestures
        )
    }
}
