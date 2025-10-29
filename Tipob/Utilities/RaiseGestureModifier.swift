import SwiftUI

/// View modifier for detecting raise and lower gestures
struct RaiseGestureModifier: ViewModifier {
    let onRaise: () -> Void
    let onLower: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                RaiseGestureManager.shared.startMonitoring(
                    onRaise: onRaise,
                    onLower: onLower
                )
            }
            .onDisappear {
                RaiseGestureManager.shared.stopMonitoring()
            }
    }
}

extension View {
    /// Adds raise and lower gesture detection to the view
    /// - Parameters:
    ///   - onRaise: Callback when device is lifted upward (userAcceleration.y > +0.6)
    ///   - onLower: Callback when device is pushed downward (userAcceleration.y < -0.6)
    func detectRaise(onRaise: @escaping () -> Void, onLower: @escaping () -> Void) -> some View {
        modifier(RaiseGestureModifier(onRaise: onRaise, onLower: onLower))
    }
}
