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
        var hasPinchTriggered = false

        // MARK: - Tracking for OR-based Detection (Game Modes)

        /// When gesture started (for duration-based detection)
        var gestureStartTime: Date?

        /// Whether any inward motion was detected during this gesture
        var hasInwardMotion = false

        /// Lowest scale reached during this gesture (for grace window)
        var peakInwardScale: CGFloat = 1.0

        /// Fastest inward velocity during this gesture
        var peakInwardVelocity: CGFloat = 0

        /// Tracks last logged scale bucket for throttled debug logging
        var lastLoggedScaleBucket: Int = 100

        init(onPinch: @escaping () -> Void) {
            self.onPinch = onPinch
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            switch gesture.state {
            case .began:
                // Start tracking for OR-based detection
                gestureStartTime = Date()
                hasInwardMotion = false
                peakInwardScale = gesture.scale
                peakInwardVelocity = 0
                hasPinchTriggered = false
                lastLoggedScaleBucket = 100  // Reset log throttle

                // Lock pinch intent (suppresses swipe in game modes)
                GestureCoordinator.shared.beginPinchIntent()

                print("[\(Date().logTimestamp)] 🔍 Pinch: Began - scale=\(String(format: "%.2f", gesture.scale))")

            case .changed:
                // Track peak values for grace window evaluation
                if gesture.scale < peakInwardScale {
                    peakInwardScale = gesture.scale
                }
                if gesture.velocity < peakInwardVelocity {
                    peakInwardVelocity = gesture.velocity
                }
                if gesture.velocity < 0 {
                    hasInwardMotion = true
                }

                // Debug logging - throttled to only log on scale bucket changes
                let currentBucket = Int(gesture.scale * 100)
                if currentBucket != lastLoggedScaleBucket && gesture.scale < 0.95 {
                    print("[\(Date().logTimestamp)] 🔍 Pinch: scale=\(String(format: "%.2f", gesture.scale)) vel=\(String(format: "%.2f", gesture.velocity)) triggered=\(hasPinchTriggered)")
                    lastLoggedScaleBucket = currentBucket
                }

                guard !hasPinchTriggered else { return }

                // Check if in strict mode (Tutorial) vs lenient mode (game modes)
                let inStrictMode = GestureCoordinator.shared.isStrictGestureMode

                let shouldTrigger: Bool

                if inStrictMode {
                    // STRICT: Original scale-only detection for Tutorial
                    #if DEBUG || TESTFLIGHT
                    let threshold = DevConfigManager.shared.pinchScaleThreshold
                    #else
                    let threshold: CGFloat = 0.85
                    #endif
                    shouldTrigger = gesture.scale < threshold

                } else {
                    // LENIENT: OR-based detection for game modes
                    #if DEBUG || TESTFLIGHT
                    let scaleThreshold = DevConfigManager.shared.pinchLenientScaleThreshold
                    let velocityThreshold = DevConfigManager.shared.pinchVelocityThreshold
                    let durationThreshold = DevConfigManager.shared.pinchMinDuration
                    #else
                    let scaleThreshold: CGFloat = 0.92
                    let velocityThreshold: CGFloat = -0.3
                    let durationThreshold: TimeInterval = 0.08
                    #endif

                    let scaleQualifies = gesture.scale <= scaleThreshold
                    // Velocity check: must have inward motion AND magnitude exceeds threshold
                    let velocityQualifies = hasInwardMotion && abs(gesture.velocity) >= abs(velocityThreshold)
                    let durationQualifies = gestureStartTime.map {
                        Date().timeIntervalSince($0) >= durationThreshold && hasInwardMotion
                    } ?? false

                    shouldTrigger = scaleQualifies || velocityQualifies || durationQualifies

                    #if DEBUG || TESTFLIGHT
                    if shouldTrigger {
                        let reasons = [
                            scaleQualifies ? "scale(\(String(format: "%.2f", gesture.scale)))" : nil,
                            velocityQualifies ? "velocity(\(String(format: "%.2f", gesture.velocity)))" : nil,
                            durationQualifies ? "duration" : nil
                        ].compactMap { $0 }.joined(separator: "+")
                        print("[\(Date().logTimestamp)] 🎯 Pinch qualified via: \(reasons)")
                    }
                    #endif
                }

                if shouldTrigger {
                    // Check with GestureCoordinator for intelligent filtering
                    guard GestureCoordinator.shared.shouldAllowGesture(.pinch) else {
                        print("[\(Date().logTimestamp)] ⏸️ Pinch suppressed by coordinator")
                        return
                    }

                    print("[\(Date().logTimestamp)] ✅ Pinch detected!")
                    hasPinchTriggered = true
                    // Note: endPinchIntent() is called in .ended case, not here (avoids redundant calls)
                    onPinch()
                }

            case .ended, .cancelled, .failed:
                let finalScale = gesture.scale
                print("[\(Date().logTimestamp)] 🔍 Pinch: Ended - final scale=\(String(format: "%.2f", finalScale)) peak=\(String(format: "%.2f", peakInwardScale))")

                // Grace window: Check if nearly qualified (lenient game modes only)
                if !hasPinchTriggered {
                    let inStrictMode = GestureCoordinator.shared.isStrictGestureMode

                    if !inStrictMode && hasInwardMotion {
                        #if DEBUG || TESTFLIGHT
                        let graceScaleThreshold = DevConfigManager.shared.pinchGraceScaleThreshold
                        #else
                        let graceScaleThreshold: CGFloat = 0.94
                        #endif

                        // Check if peaked close to threshold with inward motion
                        let peakScaleQualifiesForGrace = peakInwardScale <= graceScaleThreshold
                        let graceConditionsMet = peakScaleQualifiesForGrace && hasInwardMotion

                        if graceConditionsMet {
                            // Check with coordinator before grace-triggering
                            if GestureCoordinator.shared.shouldAllowGesture(.pinch) {
                                print("[\(Date().logTimestamp)] 🎁 Grace window: Pinch succeeded (peak scale=\(String(format: "%.2f", peakInwardScale)))")
                                hasPinchTriggered = true
                                onPinch()
                            }
                        }
                    }
                }

                // Release intent lock
                GestureCoordinator.shared.endPinchIntent()

                // Reset for next gesture
                gestureStartTime = nil
                hasInwardMotion = false
                peakInwardScale = 1.0
                peakInwardVelocity = 0
                hasPinchTriggered = false

            default:
                break
            }
        }

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
