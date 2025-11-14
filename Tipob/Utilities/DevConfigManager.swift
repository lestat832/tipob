//
//  DevConfigManager.swift
//  Tipob
//
//  Created on 2025-11-13
//  Admin Dev Panel - Centralized Gesture Threshold Configuration (DEBUG ONLY)
//

#if DEBUG
import Foundation
import SwiftUI
import Combine

/// Centralized manager for gesture detection thresholds
/// Allows live tuning via Admin Dev Panel without rebuilding
/// DEBUG ONLY - Release builds use hardcoded constants
class DevConfigManager: ObservableObject {

    // MARK: - Singleton

    static let shared = DevConfigManager()

    private init() {
        print("✅ DevConfigManager initialized (DEBUG mode)")
    }

    // MARK: - Shake Detection

    @Published var shakeThreshold: Double = 2.0  // G-force
    @Published var shakeCooldown: TimeInterval = 0.5  // seconds
    @Published var shakeUpdateInterval: TimeInterval = 0.02  // 50 Hz

    // MARK: - Tilt Detection

    @Published var tiltAngleThreshold: Double = 0.44  // radians (~25°)
    @Published var tiltDuration: TimeInterval = 0.3  // seconds (sustained hold time)
    @Published var tiltCooldown: TimeInterval = 0.5  // seconds
    @Published var tiltUpdateInterval: TimeInterval = 0.016  // 60 Hz

    // MARK: - Raise/Lower Detection

    @Published var raiseLowerThreshold: Double = 0.3  // G-force
    @Published var raiseLowerSpikeThreshold: Double = 0.8  // G-force (immediate trigger)
    @Published var raiseLowerSustainedDuration: TimeInterval = 0.1  // seconds
    @Published var raiseLowerCooldown: TimeInterval = 0.5  // seconds
    @Published var raiseLowerUpdateInterval: TimeInterval = 1.0/60.0  // 60 Hz

    // MARK: - Swipe Detection

    @Published var minSwipeDistance: CGFloat = 50.0  // pixels
    @Published var minSwipeVelocity: CGFloat = 80.0  // pixels per second
    @Published var edgeBufferDistance: CGFloat = 24.0  // pixels (prevents accidental edge swipes)
    @Published var dragMinimumDistance: CGFloat = 20.0  // pixels (DragGesture minimum)

    // MARK: - Tap Detection

    @Published var doubleTapWindow: TimeInterval = 0.3  // seconds (300ms detection window)
    @Published var longPressDuration: TimeInterval = 0.7  // seconds (700ms minimum hold)

    // MARK: - Pinch Detection

    @Published var pinchScaleThreshold: CGFloat = 0.85  // scale (15% reduction triggers)

    // MARK: - Timing Settings

    @Published var motionToTouchGracePeriod: TimeInterval = 0.5  // seconds (grace period for motion→touch transitions)

    // MARK: - Gameplay Logging

    @Published var gameplayLogs: [GameplayLogEntry] = []

    // MARK: - Sequence Replay Storage

    @Published var lastMemorySequence: [GestureType]? = nil
    @Published var lastClassicSequence: [GestureType]? = nil

    // MARK: - Default Values Storage

    private let defaults = GestureThresholds(
        shake: ShakeThresholds(threshold: 2.0, cooldown: 0.5, updateInterval: 0.02),
        tilt: TiltThresholds(angleThreshold: 0.44, duration: 0.3, cooldown: 0.5, updateInterval: 0.016),
        raiseLower: RaiseLowerThresholds(
            threshold: 0.3,
            spikeThreshold: 0.8,
            sustainedDuration: 0.1,
            cooldown: 0.5,
            updateInterval: 1.0/60.0
        ),
        swipe: SwipeThresholds(
            minDistance: 50.0,
            minVelocity: 80.0,
            edgeBuffer: 24.0,
            dragMinimum: 20.0
        ),
        tap: TapThresholds(doubleTapWindow: 0.3, longPressDuration: 0.7),
        pinch: PinchThresholds(scaleThreshold: 0.85),
        timing: TimingThresholds(motionToTouchGracePeriod: 0.5)
    )

    // MARK: - Public Methods

    /// Reset all thresholds to default values
    func resetToDefaults() {
        // Shake
        shakeThreshold = defaults.shake.threshold
        shakeCooldown = defaults.shake.cooldown
        shakeUpdateInterval = defaults.shake.updateInterval

        // Tilt
        tiltAngleThreshold = defaults.tilt.angleThreshold
        tiltDuration = defaults.tilt.duration
        tiltCooldown = defaults.tilt.cooldown
        tiltUpdateInterval = defaults.tilt.updateInterval

        // Raise/Lower
        raiseLowerThreshold = defaults.raiseLower.threshold
        raiseLowerSpikeThreshold = defaults.raiseLower.spikeThreshold
        raiseLowerSustainedDuration = defaults.raiseLower.sustainedDuration
        raiseLowerCooldown = defaults.raiseLower.cooldown
        raiseLowerUpdateInterval = defaults.raiseLower.updateInterval

        // Swipe
        minSwipeDistance = defaults.swipe.minDistance
        minSwipeVelocity = defaults.swipe.minVelocity
        edgeBufferDistance = defaults.swipe.edgeBuffer
        dragMinimumDistance = defaults.swipe.dragMinimum

        // Tap
        doubleTapWindow = defaults.tap.doubleTapWindow
        longPressDuration = defaults.tap.longPressDuration

        // Pinch
        pinchScaleThreshold = defaults.pinch.scaleThreshold

        // Timing
        motionToTouchGracePeriod = defaults.timing.motionToTouchGracePeriod

        print("✅ DevConfigManager reset to defaults")
    }

    /// Export current threshold values to JSON file
    /// Returns URL to the generated file for sharing
    func exportToJSON() -> URL? {
        let thresholds = GestureThresholds(
            shake: ShakeThresholds(
                threshold: shakeThreshold,
                cooldown: shakeCooldown,
                updateInterval: shakeUpdateInterval
            ),
            tilt: TiltThresholds(
                angleThreshold: tiltAngleThreshold,
                duration: tiltDuration,
                cooldown: tiltCooldown,
                updateInterval: tiltUpdateInterval
            ),
            raiseLower: RaiseLowerThresholds(
                threshold: raiseLowerThreshold,
                spikeThreshold: raiseLowerSpikeThreshold,
                sustainedDuration: raiseLowerSustainedDuration,
                cooldown: raiseLowerCooldown,
                updateInterval: raiseLowerUpdateInterval
            ),
            swipe: SwipeThresholds(
                minDistance: minSwipeDistance,
                minVelocity: minSwipeVelocity,
                edgeBuffer: edgeBufferDistance,
                dragMinimum: dragMinimumDistance
            ),
            tap: TapThresholds(
                doubleTapWindow: doubleTapWindow,
                longPressDuration: longPressDuration
            ),
            pinch: PinchThresholds(
                scaleThreshold: pinchScaleThreshold
            ),
            timing: TimingThresholds(
                motionToTouchGracePeriod: motionToTouchGracePeriod
            )
        )

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(thresholds)

            // Write to temporary directory
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("gesture_thresholds.json")

            try jsonData.write(to: fileURL)

            print("✅ Exported gesture thresholds to: \(fileURL.path)")
            return fileURL

        } catch {
            print("❌ Failed to export gesture thresholds: \(error.localizedDescription)")
            return nil
        }
    }

    /// Log a gesture attempt (expected vs detected)
    func logGesture(expected: GestureType, detected: GestureType?, success: Bool) {
        let timestamp = Date().logTimestamp
        let entry = GameplayLogEntry(
            timestamp: timestamp,
            expectedGesture: expected,
            detectedGesture: detected,
            success: success
        )
        gameplayLogs.append(entry)
        print("📋 Log: [\(timestamp)] Expected: \(expected.displayName) → Detected: \(detected?.displayName ?? "none") \(success ? "✓" : "✗")")
    }

    /// Clear all gameplay logs (call at start of new game)
    func clearLogs() {
        gameplayLogs.removeAll()
        print("📋 Gameplay logs cleared")
    }

    /// Store the last played sequence for replay debugging
    func captureMemorySequence(_ sequence: [GestureType]) {
        lastMemorySequence = sequence
        print("🔄 Captured Memory sequence (\(sequence.count) gestures): \(sequence.map { $0.displayName }.joined(separator: ", "))")
    }

    /// Store the last played Classic Mode gesture series for replay debugging
    func captureClassicSequence(_ sequence: [GestureType]) {
        lastClassicSequence = sequence
        print("🔄 Captured Classic sequence (\(sequence.count) gestures): \(sequence.map { $0.displayName }.joined(separator: ", "))")
    }

    /// Clear stored sequences
    func clearStoredSequences() {
        lastMemorySequence = nil
        lastClassicSequence = nil
        print("🔄 Cleared stored sequences")
    }
}

// MARK: - Codable Structures for JSON Export

/// Complete gesture thresholds configuration
struct GestureThresholds: Codable {
    let shake: ShakeThresholds
    let tilt: TiltThresholds
    let raiseLower: RaiseLowerThresholds
    let swipe: SwipeThresholds
    let tap: TapThresholds
    let pinch: PinchThresholds
    let timing: TimingThresholds
}

struct ShakeThresholds: Codable {
    let threshold: Double
    let cooldown: TimeInterval
    let updateInterval: TimeInterval
}

struct TiltThresholds: Codable {
    let angleThreshold: Double
    let duration: TimeInterval
    let cooldown: TimeInterval
    let updateInterval: TimeInterval
}

struct RaiseLowerThresholds: Codable {
    let threshold: Double
    let spikeThreshold: Double
    let sustainedDuration: TimeInterval
    let cooldown: TimeInterval
    let updateInterval: TimeInterval
}

struct SwipeThresholds: Codable {
    let minDistance: CGFloat
    let minVelocity: CGFloat
    let edgeBuffer: CGFloat
    let dragMinimum: CGFloat
}

struct TapThresholds: Codable {
    let doubleTapWindow: TimeInterval
    let longPressDuration: TimeInterval
}

struct PinchThresholds: Codable {
    let scaleThreshold: CGFloat
}

struct TimingThresholds: Codable {
    let motionToTouchGracePeriod: TimeInterval
}

// MARK: - Gameplay Logging

/// Log entry for gesture attempts (expected vs detected)
struct GameplayLogEntry: Identifiable {
    let id = UUID()
    let timestamp: String
    let expectedGesture: GestureType
    let detectedGesture: GestureType?
    let success: Bool

    var displayText: String {
        let expectedName = expectedGesture.displayName
        let detectedName = detectedGesture?.displayName ?? "(none)"
        let icon = success ? "✓" : "✗"
        return "[\(timestamp)] \(icon) \(expectedName) → \(detectedName)"
    }
}

#endif
