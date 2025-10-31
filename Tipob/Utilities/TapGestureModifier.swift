import SwiftUI

// Press detection with single tap, double tap, and long press differentiation
// Tap: single press
// Double tap: two taps within 300ms
// Long press: hold for 700ms
extension View {
    func detectTaps(onTap: @escaping (GestureType) -> Void) -> some View {
        self.modifier(TapDetectionModifier(onTap: onTap))
    }
}

struct TapDetectionModifier: ViewModifier {
    let onTap: (GestureType) -> Void

    @State private var tapCount: Int = 0
    @State private var singleTapTimer: DispatchWorkItem?
    @State private var longPressDetected: Bool = false

    private let doubleTapWindow: TimeInterval = 0.3 // 300ms
    private let longPressDuration: TimeInterval = 0.7 // 700ms

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                LongPressGesture(minimumDuration: longPressDuration)
                    .onEnded { _ in
                        // Long press detected - cancel any pending taps
                        singleTapTimer?.cancel()
                        tapCount = 0
                        longPressDetected = true

                        // Check gesture coordinator before triggering
                        if GestureCoordinator.shared.shouldAllowGesture(.longPress) {
                            print("[\(Date().logTimestamp)] 🎯 Long Press detected")
                            onTap(.longPress)
                        } else {
                            print("[\(Date().logTimestamp)] ⏸️ Long Press suppressed by coordinator")
                        }

                        // Reset flag after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.longPressDetected = false
                        }
                    }
            )
            .onTapGesture {
                // Ignore taps if long press was just detected
                guard !longPressDetected else { return }

                tapCount += 1
                print("[\(Date().logTimestamp)] 🔍 Tap count: \(tapCount)")

                // Cancel any pending single tap
                singleTapTimer?.cancel()

                if tapCount == 1 {
                    // Wait to see if a second tap comes
                    let workItem = DispatchWorkItem { [tapCount] in
                        if tapCount == 1 {
                            // Only one tap received - check if allowed
                            if GestureCoordinator.shared.shouldAllowGesture(.tap) {
                                print("[\(Date().logTimestamp)] 🎯 Single Tap detected")
                                onTap(.tap)
                            } else {
                                print("[\(Date().logTimestamp)] ⏸️ Single Tap suppressed by coordinator")
                            }
                        }
                        self.tapCount = 0
                    }
                    singleTapTimer = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + doubleTapWindow, execute: workItem)
                } else if tapCount == 2 {
                    // Second tap received - check if allowed
                    singleTapTimer?.cancel()
                    if GestureCoordinator.shared.shouldAllowGesture(.doubleTap) {
                        print("[\(Date().logTimestamp)] 🎯 Double Tap detected")
                        onTap(.doubleTap)
                    } else {
                        print("[\(Date().logTimestamp)] ⏸️ Double Tap suppressed by coordinator")
                    }
                    tapCount = 0
                }
            }
    }
}
