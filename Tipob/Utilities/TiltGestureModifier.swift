import SwiftUI

/// View modifier for detecting tilt gestures
struct TiltGestureModifier: ViewModifier {
    let onTiltLeft: () -> Void
    let onTiltRight: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                TiltGestureManager.shared.startMonitoring(
                    onTiltLeft: onTiltLeft,
                    onTiltRight: onTiltRight
                )
            }
            .onDisappear {
                TiltGestureManager.shared.stopMonitoring()
            }
    }
}

extension View {
    /// Adds tilt gesture detection to the view
    /// - Parameters:
    ///   - onTiltLeft: Callback when device tilts left (>30 degrees)
    ///   - onTiltRight: Callback when device tilts right (>30 degrees)
    func detectTilts(onTiltLeft: @escaping () -> Void, onTiltRight: @escaping () -> Void) -> some View {
        modifier(TiltGestureModifier(onTiltLeft: onTiltLeft, onTiltRight: onTiltRight))
    }
}
