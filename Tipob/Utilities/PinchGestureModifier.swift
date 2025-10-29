import SwiftUI

struct PinchGestureModifier: ViewModifier {
    let onPinch: () -> Void

    @State private var currentScale: CGFloat = 1.0
    @State private var initialScale: CGFloat = 1.0
    @State private var gestureStarted: Bool = false
    @State private var isPinching: Bool = false
    @State private var lastScale: CGFloat = 1.0
    @State private var lastUpdateTime: Date = Date()
    @State private var velocitySum: CGFloat = 0.0
    @State private var velocityCount: Int = 0

    // Configuration - Hybrid detection: lower threshold + velocity
    private let minimumChangeAmount: CGFloat = 0.08  // 8% change threshold (more forgiving)
    private let minimumVelocity: CGFloat = 0.5  // Minimum pinch velocity for deliberate motion
    private let debounceDelay: TimeInterval = 0.3  // Prevent multiple triggers

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        guard !isPinching else { return }

                        // Capture initial scale when gesture starts
                        if !gestureStarted {
                            initialScale = value
                            lastScale = value
                            lastUpdateTime = Date()
                            gestureStarted = true
                        } else {
                            // Track velocity for deliberate motion detection
                            let now = Date()
                            let timeDelta = now.timeIntervalSince(lastUpdateTime)

                            if timeDelta > 0 {
                                let scaleDelta = lastScale - value  // Positive = pinching inward
                                let velocity = scaleDelta / timeDelta

                                // Accumulate velocity for averaging
                                if velocity > 0 {  // Only count inward motion
                                    velocitySum += velocity
                                    velocityCount += 1
                                }

                                lastScale = value
                                lastUpdateTime = now
                            }
                        }

                        currentScale = value
                    }
                    .onEnded { value in
                        // Calculate change from initial scale (not from 1.0)
                        let changeAmount = abs(initialScale - value)

                        // Calculate average velocity
                        let averageVelocity = velocityCount > 0 ? velocitySum / CGFloat(velocityCount) : 0.0

                        // Hybrid detection: require inward motion AND (large change OR fast motion)
                        // 1. Inward motion (value < initialScale) - fingers moved closer
                        // 2a. Large change (changeAmount >= 0.08) - 8% reduction OR
                        // 2b. Fast motion (averageVelocity >= 0.5) - deliberate pinch
                        let hasInwardMotion = value < initialScale
                        let hasLargeChange = changeAmount >= minimumChangeAmount
                        let hasFastMotion = averageVelocity >= minimumVelocity

                        if hasInwardMotion && (hasLargeChange || hasFastMotion) && !isPinching {
                            isPinching = true
                            onPinch()

                            // Reset after debounce delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + debounceDelay) {
                                self.isPinching = false
                                self.currentScale = 1.0
                                self.initialScale = 1.0
                                self.gestureStarted = false
                                self.lastScale = 1.0
                                self.lastUpdateTime = Date()
                                self.velocitySum = 0.0
                                self.velocityCount = 0
                            }
                        } else {
                            // Reset if conditions not met
                            currentScale = 1.0
                            initialScale = 1.0
                            gestureStarted = false
                            lastScale = 1.0
                            lastUpdateTime = Date()
                            velocitySum = 0.0
                            velocityCount = 0
                        }
                    }
            )
    }
}

/*  // DUPLICATE: Extension moved to PinchGestureView.swift (UIKit-based)
extension View {
    func detectPinch(onPinch: @escaping () -> Void) -> some View {
        modifier(PinchGestureModifier(onPinch: onPinch))
    }
}
*/
