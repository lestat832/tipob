import Foundation
import CoreMotion
import Combine

/// Centralized motion gesture detection manager
/// Ensures only ONE motion gesture detector is active at a time to prevent conflicts
class MotionGestureManager: ObservableObject {
    static let shared = MotionGestureManager()

    private let motionManager = CMMotionManager()
    private var activeGesture: GestureType?
    private var onDetectedCallback: (() -> Void)?
    private var onWrongGestureCallback: (() -> Void)?

    // Shake detection state
    private var lastShakeTime: Date = .distantPast
    private let shakeCooldown: TimeInterval = 0.5
    private let shakeThreshold: Double = 2.0  // 2.0G (was 2.5G - 20% more sensitive)
    private let shakeUpdateInterval: TimeInterval = 0.02  // 50 Hz (was 0.1s / 10 Hz)

    // Tilt detection state
    private var lastTiltTime: Date = .distantPast
    private var tiltStartTime: Date?
    private var currentTiltDirection: TiltDirection = .neutral
    private let tiltAngleThreshold: Double = 0.44  // ~25 degrees (was 0.52 / ~30° - 17% easier)
    private let tiltDuration: TimeInterval = 0.3
    private let tiltCooldown: TimeInterval = 0.5
    private let tiltUpdateInterval: TimeInterval = 0.016  // 60 Hz (was 0.05s / 20 Hz)

    // Raise/Lower detection state
    private var lastRaiseLowerTime: Date = .distantPast
    private var sustainedRaiseStartTime: Date?
    private var sustainedLowerStartTime: Date?
    private let raiseLowerThreshold: Double = 0.3  // 0.3G (was 0.4G - 25% more sensitive)
    private let raiseLowerSpikeThreshold: Double = 0.8
    private let raiseLowerSustainedDuration: TimeInterval = 0.1
    private let raiseLowerCooldown: TimeInterval = 0.5
    private let raiseLowerUpdateInterval: TimeInterval = 1.0 / 60.0  // 60 Hz (was 1/30s / 30 Hz)

    private enum TiltDirection {
        case neutral
        case left
        case right
    }

    private init() {
        // Initialize motion manager settings
        setupMotionManager()
    }

    private func setupMotionManager() {
        // Motion manager setup is done per-gesture type when activating
    }

    // MARK: - Public API

    /// Activate motion detector for a specific gesture type
    /// Only ONE motion detector will be active at a time
    func activateDetector(
        for gesture: GestureType,
        onDetected: @escaping () -> Void,
        onWrongGesture: @escaping () -> Void
    ) {
        // Deactivate current detector if any
        deactivateAllDetectors()

        // Store callbacks and active gesture
        activeGesture = gesture
        onDetectedCallback = onDetected
        onWrongGestureCallback = onWrongGesture

        // Activate the specific detector
        switch gesture {
        case .shake:
            startShakeDetection()
        case .tiltLeft, .tiltRight:
            startTiltDetection()
        case .raise:
            startRaiseDetection()
        case .lower:
            startLowerDetection()
        default:
            // Not a motion gesture - deactivate all
            deactivateAllDetectors()
        }
    }

    /// Deactivate all motion detectors
    func deactivateAllDetectors() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        activeGesture = nil
        onDetectedCallback = nil
        onWrongGestureCallback = nil

        // Reset state
        tiltStartTime = nil
        currentTiltDirection = .neutral
        sustainedRaiseStartTime = nil
        sustainedLowerStartTime = nil
    }

    // MARK: - Shake Detection

    private func startShakeDetection() {
        guard motionManager.isAccelerometerAvailable else {
            print("⚠️ Accelerometer not available on this device")
            return
        }

        motionManager.accelerometerUpdateInterval = shakeUpdateInterval

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }

            // Calculate acceleration magnitude
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let magnitude = sqrt(x*x + y*y + z*z)

            // Detect shake (sharp acceleration change)
            if magnitude > self.shakeThreshold {
                print("[\(Date().logTimestamp)] 🔍 Shake magnitude: \(String(format: "%.2f", magnitude))G (threshold: \(self.shakeThreshold)G)")
                self.handleShakeDetected()
            }
        }
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
        onDetectedCallback?()
    }

    // MARK: - Tilt Detection

    private func startTiltDetection() {
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device Motion not available on this device")
            return
        }

        motionManager.deviceMotionUpdateInterval = tiltUpdateInterval

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            // Get roll angle (rotation around front-to-back axis)
            // Negative roll = tilting left, Positive roll = tilting right
            let roll = motion.attitude.roll

            self.processTiltAngle(roll)
        }
    }

    private func processTiltAngle(_ roll: Double) {
        let now = Date()

        // Determine current tilt direction based on threshold
        let newDirection: TiltDirection
        if roll < -tiltAngleThreshold {
            newDirection = .left
        } else if roll > tiltAngleThreshold {
            newDirection = .right
        } else {
            newDirection = .neutral
        }

        // Handle direction changes
        if newDirection != currentTiltDirection {
            currentTiltDirection = newDirection
            tiltStartTime = newDirection != .neutral ? now : nil
        }

        // Check if tilt has been held long enough
        guard let startTime = tiltStartTime else { return }
        let tiltHoldDuration = now.timeIntervalSince(startTime)

        // Verify tilt duration and cooldown
        guard tiltHoldDuration >= tiltDuration else { return }
        guard now.timeIntervalSince(lastTiltTime) > tiltCooldown else {
            print("[\(Date().logTimestamp)] ⏸️ Tilt suppressed (cooldown)")
            return
        }

        // Convert roll to degrees for logging
        let degrees = roll * 180 / .pi

        // Check if detected tilt matches expected gesture
        switch currentTiltDirection {
        case .left:
            if activeGesture == .tiltLeft {
                guard GestureCoordinator.shared.shouldAllowGesture(.tiltLeft) else {
                    print("[\(Date().logTimestamp)] ⏸️ Tilt Left suppressed by coordinator")
                    tiltStartTime = nil
                    return
                }
                print("[\(Date().logTimestamp)] 🎯 Tilt Left detected - angle: \(String(format: "%.1f", degrees))°")
                lastTiltTime = now
                tiltStartTime = nil
                currentTiltDirection = .neutral
                onDetectedCallback?()
            } else if activeGesture == .tiltRight {
                print("[\(Date().logTimestamp)] ❌ Wrong tilt direction (expected right, got left)")
                onWrongGestureCallback?()
            }

        case .right:
            if activeGesture == .tiltRight {
                guard GestureCoordinator.shared.shouldAllowGesture(.tiltRight) else {
                    print("[\(Date().logTimestamp)] ⏸️ Tilt Right suppressed by coordinator")
                    tiltStartTime = nil
                    return
                }
                print("[\(Date().logTimestamp)] 🎯 Tilt Right detected - angle: \(String(format: "%.1f", degrees))°")
                lastTiltTime = now
                tiltStartTime = nil
                currentTiltDirection = .neutral
                onDetectedCallback?()
            } else if activeGesture == .tiltLeft {
                print("[\(Date().logTimestamp)] ❌ Wrong tilt direction (expected left, got right)")
                onWrongGestureCallback?()
            }

        case .neutral:
            break
        }
    }

    // MARK: - Raise Detection

    private func startRaiseDetection() {
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device Motion not available on this device")
            return
        }

        motionManager.deviceMotionUpdateInterval = raiseLowerUpdateInterval

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            // Get acceleration and gravity vectors
            let ax = motion.userAcceleration.x
            let ay = motion.userAcceleration.y
            let az = motion.userAcceleration.z
            let gx = motion.gravity.x
            let gy = motion.gravity.y
            let gz = motion.gravity.z

            // Calculate gravity magnitude for normalization
            let gravityMagnitude = sqrt(gx*gx + gy*gy + gz*gz)

            // Project acceleration onto gravity axis
            // Positive = moving AGAINST gravity (upward) = RAISE
            let accelAlongGravity = (ax*gx + ay*gy + az*gz) / gravityMagnitude

            // Debug logging
            if abs(accelAlongGravity) > self.raiseLowerThreshold {
                print("[\(Date().logTimestamp)] 🔍 Raise: accel = \(String(format: "%.2f", accelAlongGravity))G (threshold: \(self.raiseLowerThreshold)G)")
            }

            self.processRaiseAcceleration(accelAlongGravity)
        }
    }

    private func processRaiseAcceleration(_ accelY: Double) {
        let now = Date()

        // Check cooldown period
        guard now.timeIntervalSince(lastRaiseLowerTime) > raiseLowerCooldown else {
            return
        }

        // RAISE DETECTION (positive acceleration)
        if accelY > raiseLowerThreshold {
            // Spike detection: immediate trigger if strong enough
            if accelY > raiseLowerSpikeThreshold {
                print("[\(Date().logTimestamp)] ✅ Raise detected (spike): \(String(format: "%.2f", accelY))")
                handleRaiseDetected()
                return
            }

            // Sustained detection: track duration
            if sustainedRaiseStartTime == nil {
                sustainedRaiseStartTime = now
            } else if let startTime = sustainedRaiseStartTime {
                let duration = now.timeIntervalSince(startTime)
                if duration >= raiseLowerSustainedDuration {
                    print("[\(Date().logTimestamp)] ✅ Raise detected (sustained): \(String(format: "%.2f", accelY)) for \(Int(duration * 1000))ms")
                    handleRaiseDetected()
                    sustainedRaiseStartTime = nil
                }
            }
        } else {
            // Below threshold - reset tracking
            sustainedRaiseStartTime = nil
        }
    }

    private func handleRaiseDetected() {
        guard GestureCoordinator.shared.shouldAllowGesture(.raise) else {
            sustainedRaiseStartTime = nil
            return
        }
        lastRaiseLowerTime = Date()
        sustainedRaiseStartTime = nil
        onDetectedCallback?()
    }

    // MARK: - Lower Detection

    private func startLowerDetection() {
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device Motion not available on this device")
            return
        }

        motionManager.deviceMotionUpdateInterval = raiseLowerUpdateInterval

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            // Get acceleration and gravity vectors
            let ax = motion.userAcceleration.x
            let ay = motion.userAcceleration.y
            let az = motion.userAcceleration.z
            let gx = motion.gravity.x
            let gy = motion.gravity.y
            let gz = motion.gravity.z

            // Calculate gravity magnitude for normalization
            let gravityMagnitude = sqrt(gx*gx + gy*gy + gz*gz)

            // Project acceleration onto gravity axis
            // Negative = moving WITH gravity (downward) = LOWER
            let accelAlongGravity = (ax*gx + ay*gy + az*gz) / gravityMagnitude

            // Debug logging
            if abs(accelAlongGravity) > self.raiseLowerThreshold {
                print("[\(Date().logTimestamp)] 🔍 Lower: accel = \(String(format: "%.2f", accelAlongGravity))G (threshold: \(self.raiseLowerThreshold)G)")
            }

            self.processLowerAcceleration(accelAlongGravity)
        }
    }

    private func processLowerAcceleration(_ accelY: Double) {
        let now = Date()

        // Check cooldown period
        guard now.timeIntervalSince(lastRaiseLowerTime) > raiseLowerCooldown else {
            return
        }

        // LOWER DETECTION (negative acceleration)
        if accelY < -raiseLowerThreshold {
            // Spike detection: immediate trigger if strong enough
            if accelY < -raiseLowerSpikeThreshold {
                print("[\(Date().logTimestamp)] ✅ Lower detected (spike): \(String(format: "%.2f", accelY))")
                handleLowerDetected()
                return
            }

            // Sustained detection: track duration
            if sustainedLowerStartTime == nil {
                sustainedLowerStartTime = now
            } else if let startTime = sustainedLowerStartTime {
                let duration = now.timeIntervalSince(startTime)
                if duration >= raiseLowerSustainedDuration {
                    print("[\(Date().logTimestamp)] ✅ Lower detected (sustained): \(String(format: "%.2f", accelY)) for \(Int(duration * 1000))ms")
                    handleLowerDetected()
                    sustainedLowerStartTime = nil
                }
            }
        } else {
            // Below threshold - reset tracking
            sustainedLowerStartTime = nil
        }
    }

    private func handleLowerDetected() {
        guard GestureCoordinator.shared.shouldAllowGesture(.lower) else {
            sustainedLowerStartTime = nil
            return
        }
        lastRaiseLowerTime = Date()
        sustainedLowerStartTime = nil
        onDetectedCallback?()
    }

    deinit {
        deactivateAllDetectors()
    }
}
