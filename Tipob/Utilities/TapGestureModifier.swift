import SwiftUI

// Tap detection with single vs double tap differentiation
// Two taps within 300ms = double tap, otherwise single tap
extension View {
    func detectTaps(onTap: @escaping (GestureType) -> Void) -> some View {
        self.modifier(TapDetectionModifier(onTap: onTap))
    }
}

struct TapDetectionModifier: ViewModifier {
    let onTap: (GestureType) -> Void

    @State private var tapCount: Int = 0
    @State private var singleTapTimer: DispatchWorkItem?

    private let doubleTapWindow: TimeInterval = 0.3 // 300ms

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                tapCount += 1

                // Cancel any pending single tap
                singleTapTimer?.cancel()

                if tapCount == 1 {
                    // Wait to see if a second tap comes
                    let workItem = DispatchWorkItem { [tapCount] in
                        if tapCount == 1 {
                            // Only one tap received - it's a single tap
                            onTap(.tap)
                        }
                        self.tapCount = 0
                    }
                    singleTapTimer = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + doubleTapWindow, execute: workItem)
                } else if tapCount == 2 {
                    // Second tap received - it's a double tap
                    singleTapTimer?.cancel()
                    onTap(.doubleTap)
                    tapCount = 0
                }
            }
    }
}
