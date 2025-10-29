import SwiftUI

/// View modifier for detecting shake gestures
struct ShakeGestureModifier: ViewModifier {
    let onShake: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear {
                ShakeGestureManager.shared.startMonitoring(onShake: onShake)
            }
            .onDisappear {
                ShakeGestureManager.shared.stopMonitoring()
            }
    }
}

extension View {
    /// Adds shake gesture detection to the view
    /// - Parameter onShake: Callback when shake is detected
    func detectShake(onShake: @escaping () -> Void) -> some View {
        modifier(ShakeGestureModifier(onShake: onShake))
    }
}
