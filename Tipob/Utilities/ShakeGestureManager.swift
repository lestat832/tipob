import Foundation
import CoreMotion
import Combine

/// Manages shake gesture detection using device accelerometer
class ShakeGestureManager: ObservableObject {
    static let shared = ShakeGestureManager()

    private let motionManager = CMMotionManager()
    private var shakeCallback: (() -> Void)?
    private var lastShakeTime: Date = .distantPast
    private let shakeCooldown: TimeInterval = 0.5  // Prevent rapid triggers

    // Shake detection thresholds
    private let accelerationThreshold: Double = 2.5  // G-force threshold
    private let updateInterval: TimeInterval = 0.1   // 10 Hz sampling

    private init() {
        setupMotionManager()
    }

    private func setupMotionManager() {
        guard motionManager.isAccelerometerAvailable else {
            print("⚠️ Accelerometer not available on this device")
            return
        }

        motionManager.accelerometerUpdateInterval = updateInterval
    }

    /// Start monitoring for shake gestures
    func startMonitoring(onShake: @escaping () -> Void) {
        shakeCallback = onShake

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }

            // Calculate acceleration magnitude
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let magnitude = sqrt(x*x + y*y + z*z)

            // Detect shake (sharp acceleration change)
            if magnitude > self.accelerationThreshold {
                print("[\(Date().logTimestamp)] 🔍 Shake magnitude: \(String(format: "%.2f", magnitude))G (threshold: \(self.accelerationThreshold)G)")
                self.handleShakeDetected()
            }
        }
    }

    /// Stop monitoring shake gestures
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        shakeCallback = nil
    }

    private func handleShakeDetected() {
        // Apply cooldown to prevent multiple triggers
        let now = Date()
        guard now.timeIntervalSince(lastShakeTime) > shakeCooldown else {
            print("[\(Date().logTimestamp)] ⏸️ Shake suppressed (cooldown: \(String(format: "%.1f", now.timeIntervalSince(lastShakeTime)))s / \(shakeCooldown)s)")
            return
        }

        // Check gesture coordinator before triggering
        guard GestureCoordinator.shared.shouldAllowGesture(.shake) else {
            print("[\(Date().logTimestamp)] ⏸️ Shake suppressed by coordinator")
            return
        }

        print("[\(Date().logTimestamp)] 🎯 Shake detected")
        lastShakeTime = now
        shakeCallback?()
    }

    deinit {
        stopMonitoring()
    }
}
