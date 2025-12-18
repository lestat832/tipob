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
        guard UserSettings.hapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    func error() {
        guard UserSettings.hapticsEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }

    func impact() {
        guard UserSettings.hapticsEnabled else { return }
        impactGenerator.impactOccurred()
    }

    // Single tap: one short pulse
    func singleTap() {
        guard UserSettings.hapticsEnabled else { return }
        lightImpactGenerator.impactOccurred()
    }

    // Double tap: two quick pulses with 75ms gap
    func doubleTap() {
        guard UserSettings.hapticsEnabled else { return }
        lightImpactGenerator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) { [weak self] in
            self?.lightImpactGenerator.impactOccurred()
        }
    }

    // Long press: one medium-duration pulse
    func longPress() {
        guard UserSettings.hapticsEnabled else { return }
        impactGenerator.impactOccurred(intensity: 0.7)
    }

    // Pinch gesture: medium-soft impact (feels like compression)
    func pinch() {
        guard UserSettings.hapticsEnabled else { return }
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
        guard UserSettings.hapticsEnabled else { return }
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
        guard UserSettings.hapticsEnabled else { return }
        impactGenerator.impactOccurred(intensity: 0.75)
    }

    // Tilt Right gesture: medium impact (steering sensation)
    func tiltRight() {
        guard UserSettings.hapticsEnabled else { return }
        impactGenerator.impactOccurred(intensity: 0.75)
    }

    // Raise gesture: light impact (uplifting sensation)
    func raise() {
        guard UserSettings.hapticsEnabled else { return }
        lightImpactGenerator.impactOccurred()
    }

    // Lower gesture: medium impact (grounding sensation)
    func lower() {
        guard UserSettings.hapticsEnabled else { return }
        impactGenerator.impactOccurred(intensity: 0.75)
    }

    // Helper to trigger appropriate haptic based on gesture type
    func gestureHaptic(for gesture: GestureType) {
        guard UserSettings.hapticsEnabled else { return }
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
        case .raise:
            raise()
        case .lower:
            lower()
        default:
            impact()
        }
    }

    // Failure feedback: two strong pulses with 100ms gap
    // Creates distinct "buzz" pattern that's clearly different from success
    func playFailureFeedback() {
        guard UserSettings.hapticsEnabled else { return }
        heavyImpactGenerator.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.heavyImpactGenerator.impactOccurred(intensity: 1.0)
        }
    }
}