import UIKit

class HapticManager {
    static let shared = HapticManager()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)

    private init() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
        lightImpactGenerator.prepare()
    }

    func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    func impact() {
        impactGenerator.impactOccurred()
    }

    // Single tap: one short pulse
    func singleTap() {
        lightImpactGenerator.impactOccurred()
    }

    // Double tap: two quick pulses with 75ms gap
    func doubleTap() {
        lightImpactGenerator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) { [weak self] in
            self?.lightImpactGenerator.impactOccurred()
        }
    }

    // Long press: one medium-duration pulse
    func longPress() {
        impactGenerator.impactOccurred(intensity: 0.7)
    }

    // Helper to trigger appropriate haptic based on gesture type
    func gestureHaptic(for gesture: GestureType) {
        switch gesture {
        case .tap:
            singleTap()
        case .doubleTap:
            doubleTap()
        case .longPress:
            longPress()
        default:
            impact()
        }
    }
}