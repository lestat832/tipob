import Foundation
import CoreMotion
import Combine

/// Manages raise and lower gesture detection using gravity-projected acceleration
/// Detects vertical hand movement (up/down) regardless of phone orientation
class RaiseGestureManager: ObservableObject {
    static let shared = RaiseGestureManager()

    private let motionManager = CMMotionManager()
    private var raiseCallback: (() -> Void)?
    private var lowerCallback: (() -> Void)?
    private var lastGestureTime: Date = .distantPast

    // Gesture detection state
    private var sustainedRaiseStartTime: Date?
    private var sustainedLowerStartTime: Date?

    // Detection thresholds (gravity-projected acceleration)
    private let accelerationThreshold: Double = 0.4  // Tunable threshold (gravity-projected values are typically smaller)
    private let spikeThreshold: Double = 0.8         // Single spike detection
    private let sustainedDuration: TimeInterval = 0.1 // 100ms (80-120ms range)
    private let gestureCooldown: TimeInterval = 0.5   // Prevent rapid triggers
    private let updateInterval: TimeInterval = 1.0 / 30.0  // 30 Hz sampling

    private init() {
        setupMotionManager()
    }

    private func setupMotionManager() {
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device Motion not available on this device")
            return
        }

        motionManager.deviceMotionUpdateInterval = updateInterval
    }

    /// Start monitoring for raise and lower gestures
    func startMonitoring(onRaise: @escaping () -> Void, onLower: @escaping () -> Void) {
        raiseCallback = onRaise
        lowerCallback = onLower

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            // Get acceleration and gravity vectors (both in device coordinate system)
            let ax = motion.userAcceleration.x
            let ay = motion.userAcceleration.y
            let az = motion.userAcceleration.z
            let gx = motion.gravity.x
            let gy = motion.gravity.y
            let gz = motion.gravity.z

            // Calculate gravity magnitude for normalization
            let gravityMagnitude = sqrt(gx*gx + gy*gy + gz*gz)

            // Project acceleration onto gravity axis using dot product
            // This gives acceleration along vertical axis (world coordinates)
            // Positive = moving AGAINST gravity (upward) = RAISE
            // Negative = moving WITH gravity (downward) = LOWER
            let accelAlongGravity = (ax*gx + ay*gy + az*gz) / gravityMagnitude

            // Debug logging for threshold tuning
            if abs(accelAlongGravity) > self.accelerationThreshold {
                print("🔍 RaiseGesture: accelAlongGravity = \(String(format: "%.2f", accelAlongGravity))")
            }

            // Process gravity-projected acceleration
            self.processAcceleration(accelAlongGravity)
        }
    }

    /// Stop monitoring raise and lower gestures
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        raiseCallback = nil
        lowerCallback = nil
        sustainedRaiseStartTime = nil
        sustainedLowerStartTime = nil
    }

    private func processAcceleration(_ accelY: Double) {
        let now = Date()

        // Check cooldown period
        guard now.timeIntervalSince(lastGestureTime) > gestureCooldown else {
            return
        }

        // RAISE DETECTION
        if accelY > accelerationThreshold {
            // Spike detection: immediate trigger if strong enough
            if accelY > spikeThreshold {
                print("✅ Raise detected (spike): \(String(format: "%.2f", accelY))")
                handleRaiseDetected()
                return
            }

            // Sustained detection: track duration
            if sustainedRaiseStartTime == nil {
                sustainedRaiseStartTime = now
            } else if let startTime = sustainedRaiseStartTime {
                let duration = now.timeIntervalSince(startTime)
                if duration >= sustainedDuration {
                    print("✅ Raise detected (sustained): \(String(format: "%.2f", accelY)) for \(Int(duration * 1000))ms")
                    handleRaiseDetected()
                    sustainedRaiseStartTime = nil
                }
            }

            // Reset lower tracking
            sustainedLowerStartTime = nil

        // LOWER DETECTION
        } else if accelY < -accelerationThreshold {
            // Spike detection: immediate trigger if strong enough
            if accelY < -spikeThreshold {
                print("✅ Lower detected (spike): \(String(format: "%.2f", accelY))")
                handleLowerDetected()
                return
            }

            // Sustained detection: track duration
            if sustainedLowerStartTime == nil {
                sustainedLowerStartTime = now
            } else if let startTime = sustainedLowerStartTime {
                let duration = now.timeIntervalSince(startTime)
                if duration >= sustainedDuration {
                    print("✅ Lower detected (sustained): \(String(format: "%.2f", accelY)) for \(Int(duration * 1000))ms")
                    handleLowerDetected()
                    sustainedLowerStartTime = nil
                }
            }

            // Reset raise tracking
            sustainedRaiseStartTime = nil

        } else {
            // Below threshold - reset tracking
            sustainedRaiseStartTime = nil
            sustainedLowerStartTime = nil
        }
    }

    private func handleRaiseDetected() {
        guard GestureCoordinator.shared.shouldAllowGesture(.raise) else {
            // Suppressed - reset and don't trigger
            sustainedRaiseStartTime = nil
            return
        }
        lastGestureTime = Date()
        sustainedRaiseStartTime = nil
        raiseCallback?()
    }

    private func handleLowerDetected() {
        guard GestureCoordinator.shared.shouldAllowGesture(.lower) else {
            // Suppressed - reset and don't trigger
            sustainedLowerStartTime = nil
            return
        }
        lastGestureTime = Date()
        sustainedLowerStartTime = nil
        lowerCallback?()
    }

    deinit {
        stopMonitoring()
    }
}
