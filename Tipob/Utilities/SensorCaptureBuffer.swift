//
//  SensorCaptureBuffer.swift
//  Tipob
//
//  Created on 2025-11-20
//  Circular buffer for capturing sensor data during gesture attempts (DEBUG ONLY)
//

#if DEBUG || TESTFLIGHT
import Foundation
import CoreMotion
import UIKit

/// Circular buffer that captures 500ms of sensor data around gesture events
/// Used for debugging and diagnosing gesture detection issues
class SensorCaptureBuffer {

    // MARK: - Singleton

    static let shared = SensorCaptureBuffer()

    // MARK: - Configuration

    /// Window duration in seconds (500ms)
    let windowDuration: TimeInterval = 0.5

    /// Sensor update interval (60 Hz)
    let updateInterval: TimeInterval = 1.0 / 60.0

    // MARK: - CoreMotion

    private let motionManager = CMMotionManager()

    // MARK: - Circular Buffers

    private var accelerometerBuffer: [AccelerometerSample] = []
    private var gyroscopeBuffer: [GyroscopeSample] = []
    private var deviceMotionBuffer: [DeviceMotionSample] = []
    private var touchBuffer: [TouchSample] = []

    /// Maximum samples to keep (500ms at 60Hz = 30 samples)
    private var maxSamples: Int {
        Int(windowDuration / updateInterval)
    }

    // MARK: - State

    private var isCapturing = false
    private let bufferLock = NSLock()

    // MARK: - Initialization

    private init() {
        print("✅ SensorCaptureBuffer initialized (DEBUG mode)")
    }

    // MARK: - Public API

    /// Start capturing sensor data
    func startCapturing() {
        guard !isCapturing else { return }
        isCapturing = true

        clearBuffers()
        startAccelerometer()
        startGyroscope()
        startDeviceMotion()

        print("🔴 SensorCaptureBuffer: Started capturing")
    }

    /// Stop capturing sensor data
    func stopCapturing() {
        guard isCapturing else { return }
        isCapturing = false

        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        motionManager.stopDeviceMotionUpdates()

        print("⏹️ SensorCaptureBuffer: Stopped capturing")
    }

    /// Record a touch event
    func recordTouch(phase: UITouch.Phase, location: CGPoint, force: CGFloat, majorRadius: CGFloat) {
        guard isCapturing else { return }

        let phaseString: String
        switch phase {
        case .began: phaseString = "began"
        case .moved: phaseString = "moved"
        case .ended: phaseString = "ended"
        case .cancelled: phaseString = "cancelled"
        case .stationary: phaseString = "stationary"
        case .regionEntered: phaseString = "regionEntered"
        case .regionMoved: phaseString = "regionMoved"
        case .regionExited: phaseString = "regionExited"
        @unknown default: phaseString = "unknown"
        }

        let sample = TouchSample(
            timestamp: Date().timeIntervalSince1970,
            phase: phaseString,
            x: location.x,
            y: location.y,
            force: force,
            majorRadius: majorRadius
        )

        bufferLock.lock()
        touchBuffer.append(sample)
        trimBuffer(&touchBuffer)
        bufferLock.unlock()
    }

    /// Capture current buffer state as SensorData snapshot
    func captureSnapshot() -> SensorData {
        bufferLock.lock()
        let snapshot = SensorData(windowDuration: windowDuration)
        var mutableSnapshot = snapshot

        mutableSnapshot.accelerometerSamples = accelerometerBuffer
        mutableSnapshot.gyroscopeSamples = gyroscopeBuffer
        mutableSnapshot.deviceMotionSamples = deviceMotionBuffer
        mutableSnapshot.touchSamples = touchBuffer

        bufferLock.unlock()

        print("📸 SensorCaptureBuffer: Captured snapshot (\(mutableSnapshot.sampleCount) samples)")
        return mutableSnapshot
    }

    /// Clear all buffers
    func clearBuffers() {
        bufferLock.lock()
        accelerometerBuffer.removeAll()
        gyroscopeBuffer.removeAll()
        deviceMotionBuffer.removeAll()
        touchBuffer.removeAll()
        bufferLock.unlock()
    }

    // MARK: - Private Methods

    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else {
            print("⚠️ Accelerometer not available")
            return
        }

        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }

            let sample = AccelerometerSample(
                timestamp: data.timestamp,
                x: data.acceleration.x,
                y: data.acceleration.y,
                z: data.acceleration.z
            )

            self.bufferLock.lock()
            self.accelerometerBuffer.append(sample)
            self.trimBuffer(&self.accelerometerBuffer)
            self.bufferLock.unlock()
        }
    }

    private func startGyroscope() {
        guard motionManager.isGyroAvailable else {
            print("⚠️ Gyroscope not available")
            return
        }

        motionManager.gyroUpdateInterval = updateInterval
        motionManager.startGyroUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }

            let sample = GyroscopeSample(
                timestamp: data.timestamp,
                x: data.rotationRate.x,
                y: data.rotationRate.y,
                z: data.rotationRate.z
            )

            self.bufferLock.lock()
            self.gyroscopeBuffer.append(sample)
            self.trimBuffer(&self.gyroscopeBuffer)
            self.bufferLock.unlock()
        }
    }

    private func startDeviceMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device motion not available")
            return
        }

        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }

            let sample = DeviceMotionSample(
                timestamp: data.timestamp,
                pitch: data.attitude.pitch,
                roll: data.attitude.roll,
                yaw: data.attitude.yaw,
                userAccelX: data.userAcceleration.x,
                userAccelY: data.userAcceleration.y,
                userAccelZ: data.userAcceleration.z,
                gravityX: data.gravity.x,
                gravityY: data.gravity.y,
                gravityZ: data.gravity.z
            )

            self.bufferLock.lock()
            self.deviceMotionBuffer.append(sample)
            self.trimBuffer(&self.deviceMotionBuffer)
            self.bufferLock.unlock()
        }
    }

    /// Trim buffer to maintain circular buffer size
    private func trimBuffer<T>(_ buffer: inout [T]) {
        while buffer.count > maxSamples {
            buffer.removeFirst()
        }
    }

    // MARK: - Cleanup

    deinit {
        stopCapturing()
    }
}

#endif
