import SwiftUI

// Press detection with single tap, double tap, and long press differentiation
// Tap: single press
// Double tap: two taps within 350ms
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

    #if DEBUG
    private var doubleTapWindow: TimeInterval { DevConfigManager.shared.doubleTapWindow }
    private var longPressDuration: TimeInterval { DevConfigManager.shared.longPressDuration }
    #else
    private let doubleTapWindow: TimeInterval = 0.35 // 350ms
    private let longPressDuration: TimeInterval = 0.7 // 700ms
    #endif

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
                            #if DEBUG
                            DevConfigManager.shared.logGestureAttempt(.tap(
                                type: .longPress,
                                wasAccepted: true,
                                rejectionReason: nil
                            ))
                            #endif
                            onTap(.longPress)
                        } else {
                            print("[\(Date().logTimestamp)] ⏸️ Long Press suppressed by coordinator")
                            #if DEBUG
                            DevConfigManager.shared.logGestureAttempt(.tap(
                                type: .longPress,
                                wasAccepted: false,
                                rejectionReason: "coordinator_suppressed"
                            ))
                            #endif
                        }

                        // Reset flag after a delay (50ms grace window)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            self.longPressDetected = false
                        }
                    }
            )
            .onTapGesture {
                // Log and ignore taps if long press was just detected
                if longPressDetected {
                    print("[\(Date().logTimestamp)] ⚠️ Tap blocked by longPressDetected flag (tapCount was: \(tapCount))")
                    #if DEBUG
                    DevConfigManager.shared.logGestureAttempt(.tap(
                        type: .tap,
                        wasAccepted: false,
                        rejectionReason: "long_press_blocking",
                        tapCount: tapCount
                    ))
                    #endif
                    return
                }

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
                                #if DEBUG
                                DevConfigManager.shared.logGestureAttempt(.tap(
                                    type: .tap,
                                    wasAccepted: true,
                                    rejectionReason: nil,
                                    tapCount: 1
                                ))
                                #endif
                                onTap(.tap)
                            } else {
                                print("[\(Date().logTimestamp)] ⏸️ Single Tap suppressed by coordinator")
                                #if DEBUG
                                DevConfigManager.shared.logGestureAttempt(.tap(
                                    type: .tap,
                                    wasAccepted: false,
                                    rejectionReason: "coordinator_suppressed",
                                    tapCount: 1
                                ))
                                #endif
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
                        #if DEBUG
                        DevConfigManager.shared.logGestureAttempt(.tap(
                            type: .doubleTap,
                            wasAccepted: true,
                            rejectionReason: nil,
                            tapCount: 2
                        ))
                        #endif
                        onTap(.doubleTap)
                    } else {
                        print("[\(Date().logTimestamp)] ⏸️ Double Tap suppressed by coordinator")
                        #if DEBUG
                        DevConfigManager.shared.logGestureAttempt(.tap(
                            type: .doubleTap,
                            wasAccepted: false,
                            rejectionReason: "coordinator_suppressed",
                            tapCount: 2
                        ))
                        #endif
                    }
                    tapCount = 0
                }
            }
    }
}
