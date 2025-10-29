import Foundation
import CoreMotion
import Combine

/// Manages tilt gesture detection using device motion (roll axis)
class TiltGestureManager: ObservableObject {
    static let shared = TiltGestureManager()

    private let motionManager = CMMotionManager()
    private var tiltLeftCallback: (() -> Void)?
    private var tiltRightCallback: (() -> Void)?
    private var lastTiltTime: Date = .distantPast
    private var tiltStartTime: Date?
    private var currentTiltDirection: TiltDirection = .neutral

    // Tilt detection thresholds
    private let tiltAngleThreshold: Double = 0.52  // ~30 degrees in radians
    private let tiltDuration: TimeInterval = 0.3   // Must hold tilt for 300ms
    private let tiltCooldown: TimeInterval = 0.5   // Prevent rapid triggers
    private let updateInterval: TimeInterval = 0.05 // 20 Hz sampling for smooth detection

    private enum TiltDirection {
        case neutral
        case left
        case right
    }

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

    /// Start monitoring for tilt gestures
    func startMonitoring(onTiltLeft: @escaping () -> Void, onTiltRight: @escaping () -> Void) {
        tiltLeftCallback = onTiltLeft
        tiltRightCallback = onTiltRight

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }

            // Get roll angle (rotation around front-to-back axis)
            // Negative roll = tilting left, Positive roll = tilting right
            let roll = motion.attitude.roll

            self.processTiltAngle(roll)
        }
    }

    /// Stop monitoring tilt gestures
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        tiltLeftCallback = nil
        tiltRightCallback = nil
        currentTiltDirection = .neutral
        tiltStartTime = nil
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
        guard now.timeIntervalSince(lastTiltTime) > tiltCooldown else { return }

        // Trigger appropriate callback
        switch currentTiltDirection {
        case .left:
            lastTiltTime = now
            tiltStartTime = nil
            currentTiltDirection = .neutral
            tiltLeftCallback?()

        case .right:
            lastTiltTime = now
            tiltStartTime = nil
            currentTiltDirection = .neutral
            tiltRightCallback?()

        case .neutral:
            break
        }
    }

    deinit {
        stopMonitoring()
    }
}
