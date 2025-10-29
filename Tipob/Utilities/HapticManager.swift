import UIKit

class HapticManager {
    static let shared = HapticManager()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)

    private init() {
        notificationGenerator.prepare()
        impactGenerator.prepare()
        lightImpactGenerator.prepare()
        heavyImpactGenerator.prepare()
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

    // Pinch gesture: medium-soft impact (feels like compression)
    func pinch() {
        impactGenerator.impactOccurred(intensity: 0.65)
    }

    /*  // SPREAD: Temporarily disabled - detection issues
    // Spread gesture: two expanding pulses (light → medium)
    // Creates opposite feeling to pinch (expansion vs compression)
    func spread() {
        lightImpactGenerator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) { [weak self] in
            self?.impactGenerator.impactOccurred(intensity: 0.8)
        }
    }
    */

    // Shake gesture: rapid succession of pulses (simulates vibration)
    func shake() {
        // Quick succession of light impacts (3 quick pulses)
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) { [weak self] in
                self?.lightImpactGenerator.impactOccurred()
            }
        }
        // Final strong pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.impactGenerator.impactOccurred(intensity: 1.0)
        }
    }

    // Tilt Left gesture: medium impact (steering sensation)
    func tiltLeft() {
        impactGenerator.impactOccurred(intensity: 0.75)
    }

    // Tilt Right gesture: medium impact (steering sensation)
    func tiltRight() {
        impactGenerator.impactOccurred(intensity: 0.75)
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
        case .pinch:
            pinch()
        // case .spread:  // SPREAD: Temporarily disabled
        //     spread()
        case .shake:
            shake()
        case .tiltLeft:
            tiltLeft()
        case .tiltRight:
            tiltRight()
        default:
            impact()
        }
    }

    // Failure feedback: two strong pulses with 100ms gap
    // Creates distinct "buzz" pattern that's clearly different from success
    func playFailureFeedback() {
        heavyImpactGenerator.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.heavyImpactGenerator.impactOccurred(intensity: 1.0)
        }
    }
}