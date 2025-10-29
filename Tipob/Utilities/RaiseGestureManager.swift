import Foundation
import CoreMotion
import Combine

/// Manages raise and lower gesture detection using device accelerometer
class RaiseGestureManager: ObservableObject {
    static let shared = RaiseGestureManager()

    private let motionManager = CMMotionManager()
    private var raiseCallback: (() -> Void)?
    private var lowerCallback: (() -> Void)?
    private var lastGestureTime: Date = .distantPast

    // Gesture detection state
    private var sustainedRaiseStartTime: Date?
    private var sustainedLowerStartTime: Date?

    // Detection thresholds (user spec)
    private let accelerationThreshold: Double = 0.6  // Tunable threshold
    private let spikeThreshold: Double = 1.0         // Single spike detection
    private let sustainedDuration: TimeInterval = 0.1 // 100ms (80-120ms range)
    private let gestureCooldown: TimeInterval = 0.5   // Prevent rapid triggers
    private let updateInterval: TimeInterval = 1.0 / 60.0  // 60 Hz sampling

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

    /// Start monitoring for raise and lower gestures
    func startMonitoring(onRaise: @escaping () -> Void, onLower: @escaping () -> Void) {
        raiseCallback = onRaise
        lowerCallback = onLower

        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }

            // Get user acceleration (device motion minus gravity)
            // Positive Y = device moving upward, Negative Y = device moving downward
            let accelY = data.acceleration.y

            // Debug logging for threshold tuning
            if abs(accelY) > self.accelerationThreshold {
                print("🔍 RaiseGesture: accelY = \(String(format: "%.2f", accelY))")
            }

            // Process acceleration data
            self.processAcceleration(accelY)
        }
    }

    /// Stop monitoring raise and lower gestures
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
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
        lastGestureTime = Date()
        sustainedRaiseStartTime = nil
        raiseCallback?()
    }

    private func handleLowerDetected() {
        lastGestureTime = Date()
        sustainedLowerStartTime = nil
        lowerCallback?()
    }

    deinit {
        stopMonitoring()
    }
}
