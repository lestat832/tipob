//
//  DevConfigManager.swift
//  Tipob
//
//  Created on 2025-11-13
//  Admin Dev Panel - Centralized Gesture Threshold Configuration (DEBUG ONLY)
//

#if DEBUG || TESTFLIGHT
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

    @Published var doubleTapWindow: TimeInterval = 0.35  // seconds (350ms detection window)
    @Published var longPressDuration: TimeInterval = 0.7  // seconds (700ms minimum hold)

    // MARK: - Pinch Detection

    @Published var pinchScaleThreshold: CGFloat = 0.85  // scale (15% reduction triggers) - STRICT (Tutorial)

    // MARK: - Pinch Intent Locking (Game Modes Only)

    @Published var pinchIntentLockDuration: TimeInterval = 0.15  // 150ms - suppress swipe when pinch begins
    @Published var pinchIntentLockEnabled: Bool = true  // Can disable for testing

    // MARK: - Lenient Pinch Detection (OR-based, Game Modes Only)

    @Published var pinchLenientScaleThreshold: CGFloat = 0.92  // 8% reduction (more lenient than Tutorial)
    @Published var pinchVelocityThreshold: CGFloat = -0.3  // negative = pinching inward
    @Published var pinchMinDuration: TimeInterval = 0.08  // 80ms sustained inward motion

    // MARK: - Pinch Grace Window

    @Published var pinchGraceWindow: TimeInterval = 0.1  // 100ms post-gesture forgiveness
    @Published var pinchGraceScaleThreshold: CGFloat = 0.94  // 6% reduction for grace window

    // MARK: - Timing Settings

    @Published var motionToTouchGracePeriod: TimeInterval = 0.5  // seconds (grace period for motion→touch transitions)

    // MARK: - Gameplay Logging

    @Published var gameplayLogs: [GameplayLogEntry] = []

    // MARK: - Sequence Replay Storage

    @Published var lastMemorySequence: [GestureType]? = nil
    @Published var lastClassicSequence: [GestureType]? = nil

    // MARK: - Raw Gesture Attempt Capture

    /// Buffer for capturing gesture attempts (accepted and rejected) during gameplay
    @Published var gestureAttempts: [GestureAttempt] = []

    // MARK: - Per-Gesture Test Mode

    @Published var testMode: GestureTestMode = .none
    @Published var activeTestResult: GestureTestResult? = nil
    @Published var testStartTime: Date? = nil

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
        tap: TapThresholds(doubleTapWindow: 0.35, longPressDuration: 0.7),
        pinch: PinchThresholds(
            scaleThreshold: 0.85,
            lenientScaleThreshold: 0.92,
            velocityThreshold: -0.3,
            minDuration: 0.08,
            intentLockDuration: 0.15,
            graceWindow: 0.1,
            graceScaleThreshold: 0.94
        ),
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
        pinchLenientScaleThreshold = defaults.pinch.lenientScaleThreshold
        pinchVelocityThreshold = defaults.pinch.velocityThreshold
        pinchMinDuration = defaults.pinch.minDuration
        pinchIntentLockDuration = defaults.pinch.intentLockDuration
        pinchGraceWindow = defaults.pinch.graceWindow
        pinchGraceScaleThreshold = defaults.pinch.graceScaleThreshold

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
                scaleThreshold: pinchScaleThreshold,
                lenientScaleThreshold: pinchLenientScaleThreshold,
                velocityThreshold: pinchVelocityThreshold,
                minDuration: pinchMinDuration,
                intentLockDuration: pinchIntentLockDuration,
                graceWindow: pinchGraceWindow,
                graceScaleThreshold: pinchGraceScaleThreshold
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

    /// Log a gesture attempt (expected vs detected) - Simple version
    /// For full diagnostic logging, use logGestureWithTiming
    func logGesture(expected: GestureType, detected: GestureType?, success: Bool) {
        // Create minimal timing for backward compatibility
        let timing = GestureTiming(
            gestureStartTime: Date(),
            allowedDuration: 3.0,  // Default
            timeoutOccurred: detected == nil
        )

        // Capture and clear gesture attempts
        let attempts = gestureAttempts.isEmpty ? nil : gestureAttempts
        gestureAttempts.removeAll()

        let entry = GestureLogEntry(
            expected: expected,
            detected: detected,
            timing: timing,
            gestureAttempts: attempts
        )
        gameplayLogs.append(entry)

        let attemptCount = attempts?.count ?? 0
        print("📋 Log: [\(entry.timestamp.logTimestamp)] Expected: \(expected.displayName) → Detected: \(detected?.displayName ?? "none") \(success ? "✓" : "✗") (\(attemptCount) attempts)")
    }

    /// Log a gesture attempt with full timing and sensor data
    func logGestureWithTiming(
        expected: GestureType,
        detected: GestureType?,
        timing: GestureTiming,
        sensorSnapshot: SensorData? = nil
    ) {
        // Capture and clear gesture attempts
        let attempts = gestureAttempts.isEmpty ? nil : gestureAttempts
        gestureAttempts.removeAll()

        let entry = GestureLogEntry(
            expected: expected,
            detected: detected,
            timing: timing,
            sensorSnapshot: sensorSnapshot,
            gestureAttempts: attempts
        )
        gameplayLogs.append(entry)
        let reactionStr = timing.actualDuration.map { String(format: "%.2fs", $0) } ?? "timeout"
        let attemptCount = attempts?.count ?? 0
        print("📋 Log: [\(entry.timestamp.logTimestamp)] Expected: \(expected.displayName) → Detected: \(detected?.displayName ?? "none") (\(reactionStr), \(attemptCount) attempts)")
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

    // MARK: - Gesture Attempt Capture Methods

    /// Log a gesture attempt (accepted or rejected)
    func logGestureAttempt(_ attempt: GestureAttempt) {
        gestureAttempts.append(attempt)
        let status = attempt.wasAccepted ? "✓" : "✗"
        let reason = attempt.rejectionReason.map { " (\($0))" } ?? ""
        print("📝 Attempt: \(attempt.gestureType) \(status)\(reason)")
    }

    /// Clear all gesture attempts (call when new gesture prompt starts)
    func clearGestureAttempts() {
        gestureAttempts.removeAll()
    }

    /// Get recent attempts since a given timestamp (for attaching to log entry)
    func getAttemptsSince(_ timestamp: Date) -> [GestureAttempt] {
        gestureAttempts.filter { $0.timestamp >= timestamp }
    }

    /// Get all attempts for the current gesture window
    var recentAttempts: [GestureAttempt] {
        gestureAttempts
    }

    // MARK: - Selection Logic

    /// Toggle selection state for a specific log entry
    func toggleSelection(for id: UUID) {
        if let index = gameplayLogs.firstIndex(where: { $0.id == id }) {
            gameplayLogs[index].isSelected.toggle()
            let state = gameplayLogs[index].isSelected ? "selected" : "deselected"
            print("✅ Log entry \(state)")
        }
    }

    /// Select all entries that are failures (not detected or wrong detection)
    func selectAllFailures() {
        for index in gameplayLogs.indices {
            if gameplayLogs[index].issueType != .success {
                gameplayLogs[index].isSelected = true
            }
        }
        print("✅ Selected all failures (\(selectedCount) entries)")
    }

    /// Clear all selections
    func clearSelection() {
        for index in gameplayLogs.indices {
            gameplayLogs[index].isSelected = false
        }
        print("✅ Cleared all selections")
    }

    /// Invert all selections
    func invertSelection() {
        for index in gameplayLogs.indices {
            gameplayLogs[index].isSelected.toggle()
        }
        print("✅ Inverted selections (\(selectedCount) now selected)")
    }

    /// Select all entries
    func selectAll() {
        for index in gameplayLogs.indices {
            gameplayLogs[index].isSelected = true
        }
        print("✅ Selected all (\(selectedCount) entries)")
    }

    /// Get all selected entries
    var selectedEntries: [GestureLogEntry] {
        gameplayLogs.filter { $0.isSelected }
    }

    /// Count of selected entries
    var selectedCount: Int {
        gameplayLogs.filter { $0.isSelected }.count
    }

    /// Count of failure entries
    var failureCount: Int {
        gameplayLogs.filter { $0.issueType != .success }.count
    }

    /// Filter logs by issue type
    func entries(for issueType: IssueType) -> [GestureLogEntry] {
        gameplayLogs.filter { $0.issueType == issueType }
    }

    /// Filter logs by gesture type
    func entries(for gestureType: GestureType) -> [GestureLogEntry] {
        gameplayLogs.filter { $0.expectedGesture == gestureType }
    }

    // MARK: - Per-Gesture Test Mode Methods

    /// Start a test session for a specific gesture
    func startTestMode(_ mode: GestureTestMode) {
        testMode = mode
        activeTestResult = nil
        testStartTime = Date()

        // Start sensor capture
        SensorCaptureBuffer.shared.startCapturing()

        print("🧪 Started test mode: \(mode.displayName)")
    }

    /// Exit test mode and clean up
    func exitTestMode() {
        testMode = .none
        activeTestResult = nil
        testStartTime = nil

        // Stop sensor capture
        SensorCaptureBuffer.shared.stopCapturing()

        print("🧪 Exited test mode")
    }

    /// Record the result of a gesture test
    func recordTestResult(_ result: GestureTestResult) {
        activeTestResult = result

        // Stop sensor capture
        SensorCaptureBuffer.shared.stopCapturing()

        let status = result.issueType == .success ? "✅" : "❌"
        print("🧪 Test result: \(status) Expected \(result.expected.displayName) → Detected \(result.detected?.displayName ?? "none")")
    }

    /// Save test result as a log entry (auto-selected for export)
    func saveTestResultAsLogEntry() {
        guard let result = activeTestResult else {
            print("❌ No test result to save")
            return
        }

        let entry = GestureLogEntry(
            expected: result.expected,
            detected: result.detected,
            timing: result.timing,
            sensorSnapshot: result.sensorSnapshot,
            thresholdsSnapshot: result.thresholdsSnapshot,
            deviceContext: result.deviceContext
        )

        // Auto-select for easy export
        var mutableEntry = entry
        mutableEntry.isSelected = true

        gameplayLogs.append(mutableEntry)

        print("📋 Saved test result as log entry (auto-selected)")

        // Clear active result after saving
        activeTestResult = nil
    }

    /// Get the expected gesture type for current test mode
    var expectedGestureForTestMode: GestureType? {
        testMode.gestureType
    }

    /// Check if currently in test mode
    var isInTestMode: Bool {
        testMode != .none
    }

    // MARK: - Export Selected Issues

    /// Export selected issues as JSON with full diagnostic data
    func exportSelectedIssues() -> URL? {
        let selected = selectedEntries
        guard !selected.isEmpty else {
            print("❌ No entries selected for export")
            return nil
        }

        let exportData = IssueExportData(
            exportDate: Date(),
            sessionInfo: SessionInfo.capture(),
            entries: selected
        )

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(exportData)

            let tempDir = FileManager.default.temporaryDirectory
            let timestamp = Date().exportTimestamp
            let fileURL = tempDir.appendingPathComponent("gesture_issues_\(timestamp).json")

            try jsonData.write(to: fileURL)

            print("✅ Exported \(selected.count) issues to: \(fileURL.path)")
            return fileURL

        } catch {
            print("❌ Failed to export issues: \(error.localizedDescription)")
            return nil
        }
    }

    /// Generate XCTest code for selected issues
    func generateXCTestCode() -> URL? {
        let selected = selectedEntries
        guard !selected.isEmpty else {
            print("❌ No entries selected for XCTest generation")
            return nil
        }

        var testCode = """
        //
        //  GestureIssueTests.swift
        //  TipobTests
        //
        //  Auto-generated from Dev Panel on \(Date().exportTimestamp)
        //

        import XCTest
        @testable import Tipob

        final class GestureIssueTests: XCTestCase {

            override func setUpWithError() throws {
                continueAfterFailure = false
            }

        """

        for (index, entry) in selected.enumerated() {
            let testName = "test_\(entry.expectedGesture.displayName.replacingOccurrences(of: " ", with: ""))_\(index + 1)"
            let expectedName = entry.expectedGesture.displayName
            let detectedName = entry.detectedGesture?.displayName ?? "nil"
            let issueType = entry.issueType.rawValue

            testCode += """

                /// Issue: \(entry.issueType.displayName)
                /// Expected: \(expectedName), Detected: \(detectedName)
                /// Timestamp: \(entry.timestamp.exportTimestamp)
                func \(testName)() throws {
                    // Setup thresholds from captured snapshot
                    let config = DevConfigManager.shared
                    config.shakeThreshold = \(entry.thresholdsSnapshot.shakeThreshold)
                    config.tiltAngleThreshold = \(entry.thresholdsSnapshot.tiltAngleThreshold)
                    config.minSwipeDistance = \(entry.thresholdsSnapshot.minSwipeDistance)
                    config.doubleTapWindow = \(entry.thresholdsSnapshot.doubleTapWindow)
                    config.longPressDuration = \(entry.thresholdsSnapshot.longPressDuration)

                    // Test gesture detection
                    // Expected: \(expectedName)
                    // Issue type: \(issueType)

                    // TODO: Add sensor data replay and assertion
                    // Sensor samples: \(entry.sensorSnapshot?.sampleCount ?? 0)

                    XCTFail("Gesture issue reproduced: \\(expectedName) → \\(detectedName)")
                }

            """
        }

        testCode += """
        }

        """

        do {
            let tempDir = FileManager.default.temporaryDirectory
            let timestamp = Date().exportTimestamp
            let fileURL = tempDir.appendingPathComponent("GestureIssueTests_\(timestamp).swift")

            try testCode.write(to: fileURL, atomically: true, encoding: .utf8)

            print("✅ Generated XCTest code for \(selected.count) issues: \(fileURL.path)")
            return fileURL

        } catch {
            print("❌ Failed to generate XCTest code: \(error.localizedDescription)")
            return nil
        }
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
    let scaleThreshold: CGFloat  // Strict (Tutorial)
    let lenientScaleThreshold: CGFloat  // Lenient (Game modes)
    let velocityThreshold: CGFloat
    let minDuration: TimeInterval
    let intentLockDuration: TimeInterval
    let graceWindow: TimeInterval
    let graceScaleThreshold: CGFloat
}

struct TimingThresholds: Codable {
    let motionToTouchGracePeriod: TimeInterval
}

// MARK: - Issue Types

/// Classification of gesture detection issues
enum IssueType: String, Codable, CaseIterable {
    case notDetected = "not_detected"      // Timeout - no gesture detected
    case wrongDetection = "wrong_detection" // Detected wrong gesture
    case success = "success"               // Correct detection

    var displayName: String {
        switch self {
        case .notDetected: return "Not Detected"
        case .wrongDetection: return "Wrong Detection"
        case .success: return "Success"
        }
    }

    var color: Color {
        switch self {
        case .notDetected: return .red
        case .wrongDetection: return .orange
        case .success: return .green
        }
    }
}

// MARK: - Sensor Sample Types

/// Single accelerometer reading
struct AccelerometerSample: Codable, Identifiable {
    let id: UUID
    let timestamp: TimeInterval
    let x: Double
    let y: Double
    let z: Double

    init(timestamp: TimeInterval, x: Double, y: Double, z: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.x = x
        self.y = y
        self.z = z
    }

    var magnitude: Double {
        sqrt(x * x + y * y + z * z)
    }
}

/// Single gyroscope reading
struct GyroscopeSample: Codable, Identifiable {
    let id: UUID
    let timestamp: TimeInterval
    let x: Double  // rotation rate around x-axis (rad/s)
    let y: Double  // rotation rate around y-axis (rad/s)
    let z: Double  // rotation rate around z-axis (rad/s)

    init(timestamp: TimeInterval, x: Double, y: Double, z: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.x = x
        self.y = y
        self.z = z
    }
}

/// Device motion sample (fused sensor data)
struct DeviceMotionSample: Codable, Identifiable {
    let id: UUID
    let timestamp: TimeInterval
    let pitch: Double  // rotation around x-axis
    let roll: Double   // rotation around y-axis
    let yaw: Double    // rotation around z-axis
    let userAccelX: Double  // acceleration without gravity
    let userAccelY: Double
    let userAccelZ: Double
    let gravityX: Double
    let gravityY: Double
    let gravityZ: Double

    init(timestamp: TimeInterval, pitch: Double, roll: Double, yaw: Double,
         userAccelX: Double, userAccelY: Double, userAccelZ: Double,
         gravityX: Double, gravityY: Double, gravityZ: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.pitch = pitch
        self.roll = roll
        self.yaw = yaw
        self.userAccelX = userAccelX
        self.userAccelY = userAccelY
        self.userAccelZ = userAccelZ
        self.gravityX = gravityX
        self.gravityY = gravityY
        self.gravityZ = gravityZ
    }
}

/// Touch event sample
struct TouchSample: Codable, Identifiable {
    let id: UUID
    let timestamp: TimeInterval
    let phase: String  // began, moved, ended, cancelled
    let x: CGFloat
    let y: CGFloat
    let force: CGFloat  // 0.0-1.0 normalized
    let majorRadius: CGFloat

    init(timestamp: TimeInterval, phase: String, x: CGFloat, y: CGFloat,
         force: CGFloat, majorRadius: CGFloat) {
        self.id = UUID()
        self.timestamp = timestamp
        self.phase = phase
        self.x = x
        self.y = y
        self.force = force
        self.majorRadius = majorRadius
    }
}

// MARK: - Gesture Attempt (Raw Gesture Data Capture)

/// Captures a single gesture attempt (accepted or rejected) for debugging
struct GestureAttempt: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let gestureType: String      // "swipe_up", "swipe_down", "pinch", "tap", etc.
    let wasAccepted: Bool
    let rejectionReason: String? // "edge_buffer", "distance", "velocity", "coordinator", "scale", etc.

    // Swipe-specific data
    let startPosition: CGPoint?
    let endPosition: CGPoint?
    let distance: CGFloat?
    let velocity: CGFloat?
    let screenSize: CGSize?

    // Pinch-specific data
    let initialScale: CGFloat?
    let finalScale: CGFloat?
    let scaleChange: CGFloat?
    let pinchVelocity: CGFloat?

    // Tap-specific data
    let tapCount: Int?

    /// Initialize for swipe gesture attempt
    static func swipe(
        direction: GestureType,
        wasAccepted: Bool,
        rejectionReason: String? = nil,
        startPosition: CGPoint,
        endPosition: CGPoint,
        distance: CGFloat,
        velocity: CGFloat,
        screenSize: CGSize
    ) -> GestureAttempt {
        GestureAttempt(
            id: UUID(),
            timestamp: Date(),
            gestureType: "swipe_\(direction.displayName.lowercased())",
            wasAccepted: wasAccepted,
            rejectionReason: rejectionReason,
            startPosition: startPosition,
            endPosition: endPosition,
            distance: distance,
            velocity: velocity,
            screenSize: screenSize,
            initialScale: nil,
            finalScale: nil,
            scaleChange: nil,
            pinchVelocity: nil,
            tapCount: nil
        )
    }

    /// Initialize for pinch gesture attempt
    static func pinch(
        wasAccepted: Bool,
        rejectionReason: String? = nil,
        initialScale: CGFloat,
        finalScale: CGFloat,
        scaleChange: CGFloat,
        pinchVelocity: CGFloat
    ) -> GestureAttempt {
        GestureAttempt(
            id: UUID(),
            timestamp: Date(),
            gestureType: "pinch",
            wasAccepted: wasAccepted,
            rejectionReason: rejectionReason,
            startPosition: nil,
            endPosition: nil,
            distance: nil,
            velocity: nil,
            screenSize: nil,
            initialScale: initialScale,
            finalScale: finalScale,
            scaleChange: scaleChange,
            pinchVelocity: pinchVelocity,
            tapCount: nil
        )
    }

    /// Initialize for tap gesture attempt
    static func tap(
        type: GestureType,
        wasAccepted: Bool,
        rejectionReason: String? = nil,
        tapCount: Int = 1
    ) -> GestureAttempt {
        GestureAttempt(
            id: UUID(),
            timestamp: Date(),
            gestureType: type.displayName.lowercased().replacingOccurrences(of: " ", with: "_"),
            wasAccepted: wasAccepted,
            rejectionReason: rejectionReason,
            startPosition: nil,
            endPosition: nil,
            distance: nil,
            velocity: nil,
            screenSize: nil,
            initialScale: nil,
            finalScale: nil,
            scaleChange: nil,
            pinchVelocity: nil,
            tapCount: tapCount
        )
    }
}

// MARK: - Sensor Data Container

/// Container for 500ms of sensor data around a gesture event
struct SensorData: Codable {
    var accelerometerSamples: [AccelerometerSample]
    var gyroscopeSamples: [GyroscopeSample]
    var deviceMotionSamples: [DeviceMotionSample]
    var touchSamples: [TouchSample]

    /// Time window in seconds (default 500ms)
    let windowDuration: TimeInterval

    init(windowDuration: TimeInterval = 0.5) {
        self.accelerometerSamples = []
        self.gyroscopeSamples = []
        self.deviceMotionSamples = []
        self.touchSamples = []
        self.windowDuration = windowDuration
    }

    var isEmpty: Bool {
        accelerometerSamples.isEmpty && gyroscopeSamples.isEmpty &&
        deviceMotionSamples.isEmpty && touchSamples.isEmpty
    }

    var sampleCount: Int {
        accelerometerSamples.count + gyroscopeSamples.count +
        deviceMotionSamples.count + touchSamples.count
    }
}

// MARK: - Threshold Snapshot

/// Snapshot of all threshold values at time of gesture
struct ThresholdSnapshot: Codable {
    // Shake
    let shakeThreshold: Double
    let shakeCooldown: TimeInterval

    // Tilt
    let tiltAngleThreshold: Double
    let tiltDuration: TimeInterval
    let tiltCooldown: TimeInterval

    // Raise/Lower
    let raiseLowerThreshold: Double
    let raiseLowerSpikeThreshold: Double
    let raiseLowerSustainedDuration: TimeInterval
    let raiseLowerCooldown: TimeInterval

    // Swipe
    let minSwipeDistance: CGFloat
    let minSwipeVelocity: CGFloat
    let edgeBufferDistance: CGFloat

    // Tap
    let doubleTapWindow: TimeInterval
    let longPressDuration: TimeInterval

    // Pinch
    let pinchScaleThreshold: CGFloat
    let pinchLenientScaleThreshold: CGFloat
    let pinchVelocityThreshold: CGFloat
    let pinchMinDuration: TimeInterval
    let pinchIntentLockDuration: TimeInterval
    let pinchGraceWindow: TimeInterval
    let pinchGraceScaleThreshold: CGFloat

    // Timing
    let motionToTouchGracePeriod: TimeInterval

    /// Create snapshot from current DevConfigManager values
    static func capture() -> ThresholdSnapshot {
        let config = DevConfigManager.shared
        return ThresholdSnapshot(
            shakeThreshold: config.shakeThreshold,
            shakeCooldown: config.shakeCooldown,
            tiltAngleThreshold: config.tiltAngleThreshold,
            tiltDuration: config.tiltDuration,
            tiltCooldown: config.tiltCooldown,
            raiseLowerThreshold: config.raiseLowerThreshold,
            raiseLowerSpikeThreshold: config.raiseLowerSpikeThreshold,
            raiseLowerSustainedDuration: config.raiseLowerSustainedDuration,
            raiseLowerCooldown: config.raiseLowerCooldown,
            minSwipeDistance: config.minSwipeDistance,
            minSwipeVelocity: config.minSwipeVelocity,
            edgeBufferDistance: config.edgeBufferDistance,
            doubleTapWindow: config.doubleTapWindow,
            longPressDuration: config.longPressDuration,
            pinchScaleThreshold: config.pinchScaleThreshold,
            pinchLenientScaleThreshold: config.pinchLenientScaleThreshold,
            pinchVelocityThreshold: config.pinchVelocityThreshold,
            pinchMinDuration: config.pinchMinDuration,
            pinchIntentLockDuration: config.pinchIntentLockDuration,
            pinchGraceWindow: config.pinchGraceWindow,
            pinchGraceScaleThreshold: config.pinchGraceScaleThreshold,
            motionToTouchGracePeriod: config.motionToTouchGracePeriod
        )
    }
}

// MARK: - Gesture Timing

/// Timing information for a gesture attempt
struct GestureTiming: Codable {
    let gestureStartTime: Date
    let gestureEndTime: Date?
    let allowedDuration: TimeInterval  // How much time was given
    let actualDuration: TimeInterval?  // How long until response
    let timeoutOccurred: Bool

    var reactionTime: TimeInterval? {
        actualDuration
    }

    init(gestureStartTime: Date, gestureEndTime: Date? = nil,
         allowedDuration: TimeInterval, actualDuration: TimeInterval? = nil,
         timeoutOccurred: Bool = false) {
        self.gestureStartTime = gestureStartTime
        self.gestureEndTime = gestureEndTime
        self.allowedDuration = allowedDuration
        self.actualDuration = actualDuration
        self.timeoutOccurred = timeoutOccurred
    }
}

// MARK: - Device Context

/// Device and environment information at time of gesture
struct DeviceContext: Codable {
    let deviceModel: String
    let osVersion: String
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let orientation: String  // portrait, landscapeLeft, landscapeRight, portraitUpsideDown
    let batteryLevel: Float  // 0.0-1.0
    let isLowPowerMode: Bool

    /// Capture current device context
    static func capture() -> DeviceContext {
        let device = UIDevice.current
        let screen = UIScreen.main

        // Get orientation string
        let orientationString: String
        switch device.orientation {
        case .portrait: orientationString = "portrait"
        case .portraitUpsideDown: orientationString = "portraitUpsideDown"
        case .landscapeLeft: orientationString = "landscapeLeft"
        case .landscapeRight: orientationString = "landscapeRight"
        case .faceUp: orientationString = "faceUp"
        case .faceDown: orientationString = "faceDown"
        default: orientationString = "unknown"
        }

        // Enable battery monitoring temporarily
        device.isBatteryMonitoringEnabled = true
        let batteryLevel = device.batteryLevel

        return DeviceContext(
            deviceModel: device.model,
            osVersion: device.systemVersion,
            screenWidth: screen.bounds.width,
            screenHeight: screen.bounds.height,
            orientation: orientationString,
            batteryLevel: batteryLevel,
            isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled
        )
    }
}

// MARK: - Gesture Log Entry

/// Enhanced log entry for gesture attempts with full diagnostic data
struct GestureLogEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let expectedGesture: GestureType
    let detectedGesture: GestureType?

    // Selection and classification
    var isSelected: Bool
    let issueType: IssueType

    // Diagnostic data
    var sensorSnapshot: SensorData?
    let thresholdsSnapshot: ThresholdSnapshot
    let timing: GestureTiming
    let deviceContext: DeviceContext

    // Raw gesture attempts (accepted and rejected) captured during this gesture window
    var gestureAttempts: [GestureAttempt]?

    // Computed properties
    var success: Bool {
        issueType == .success
    }

    var displayText: String {
        let expectedName = expectedGesture.displayName
        let detectedName = detectedGesture?.displayName ?? "(none)"
        let icon = success ? "✓" : "✗"
        let timeStr = timestamp.logTimestamp
        return "[\(timeStr)] \(icon) \(expectedName) → \(detectedName)"
    }

    var shortDisplayText: String {
        let expectedName = expectedGesture.displayName
        let detectedName = detectedGesture?.displayName ?? "none"
        return "\(expectedName) → \(detectedName)"
    }

    /// Initialize with automatic issue type detection
    init(
        expected: GestureType,
        detected: GestureType?,
        timing: GestureTiming,
        sensorSnapshot: SensorData? = nil,
        thresholdsSnapshot: ThresholdSnapshot? = nil,
        deviceContext: DeviceContext? = nil,
        gestureAttempts: [GestureAttempt]? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.expectedGesture = expected
        self.detectedGesture = detected
        self.isSelected = false

        // Determine issue type (with Stroop-aware comparison)
        if detected == nil {
            self.issueType = .notDetected
        } else if expected.isCorrectResponse(detected!) {
            self.issueType = .success
        } else {
            self.issueType = .wrongDetection
        }

        self.sensorSnapshot = sensorSnapshot
        self.thresholdsSnapshot = thresholdsSnapshot ?? ThresholdSnapshot.capture()
        self.timing = timing
        self.deviceContext = deviceContext ?? DeviceContext.capture()
        self.gestureAttempts = gestureAttempts
    }
}

// MARK: - Legacy Compatibility

/// Alias for backward compatibility with existing code
typealias GameplayLogEntry = GestureLogEntry

// MARK: - Export Data Structures

/// Complete export package for selected issues
struct IssueExportData: Codable {
    let exportDate: Date
    let sessionInfo: SessionInfo
    let entries: [GestureLogEntry]

    var issueCount: Int { entries.count }
    var failureCount: Int { entries.filter { $0.issueType != .success }.count }
}

/// Session information for export context
struct SessionInfo: Codable {
    let appVersion: String
    let buildNumber: String
    let deviceModel: String
    let osVersion: String
    let exportTimestamp: String

    /// Capture current session info
    static func capture() -> SessionInfo {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let device = UIDevice.current

        return SessionInfo(
            appVersion: appVersion,
            buildNumber: buildNumber,
            deviceModel: device.model,
            osVersion: device.systemVersion,
            exportTimestamp: Date().exportTimestamp
        )
    }
}

// MARK: - Gesture Test Mode

/// Test mode for isolated gesture testing
enum GestureTestMode: String, CaseIterable {
    case none
    case tap
    case doubleTap
    case longPress
    case swipeUp
    case swipeDown
    case swipeLeft
    case swipeRight
    case shake
    case tiltLeft
    case tiltRight
    case raisePhone
    case lowerPhone
    case pinch
    case stroop

    /// Display name for UI
    var displayName: String {
        switch self {
        case .none: return "None"
        case .tap: return "Tap"
        case .doubleTap: return "Double Tap"
        case .longPress: return "Long Press"
        case .swipeUp: return "Swipe Up"
        case .swipeDown: return "Swipe Down"
        case .swipeLeft: return "Swipe Left"
        case .swipeRight: return "Swipe Right"
        case .shake: return "Shake"
        case .tiltLeft: return "Tilt Left"
        case .tiltRight: return "Tilt Right"
        case .raisePhone: return "Raise Phone"
        case .lowerPhone: return "Lower Phone"
        case .pinch: return "Pinch"
        case .stroop: return "Stroop"
        }
    }

    /// Corresponding GestureType for this test mode
    var gestureType: GestureType? {
        switch self {
        case .none: return nil
        case .tap: return .tap
        case .doubleTap: return .doubleTap
        case .longPress: return .longPress
        case .swipeUp: return .up
        case .swipeDown: return .down
        case .swipeLeft: return .left
        case .swipeRight: return .right
        case .shake: return .shake
        case .tiltLeft: return .tiltLeft
        case .tiltRight: return .tiltRight
        case .raisePhone: return .raise
        case .lowerPhone: return .lower
        case .pinch: return .pinch
        case .stroop: return .randomStroop()
        }
    }

    /// Instruction text for the test
    var instructionText: String {
        switch self {
        case .none: return ""
        case .tap: return "Tap the screen once"
        case .doubleTap: return "Double tap the screen quickly"
        case .longPress: return "Press and hold the screen"
        case .swipeUp: return "Swipe up on the screen"
        case .swipeDown: return "Swipe down on the screen"
        case .swipeLeft: return "Swipe left on the screen"
        case .swipeRight: return "Swipe right on the screen"
        case .shake: return "Shake the phone"
        case .tiltLeft: return "Tilt the phone left"
        case .tiltRight: return "Tilt the phone right"
        case .raisePhone: return "Raise the phone up"
        case .lowerPhone: return "Lower the phone down"
        case .pinch: return "Pinch with two fingers"
        case .stroop: return "Swipe the color direction"
        }
    }

    /// SF Symbol for the gesture
    var symbolName: String {
        switch self {
        case .none: return "xmark"
        case .tap: return "hand.tap"
        case .doubleTap: return "hand.tap"
        case .longPress: return "hand.tap.fill"
        case .swipeUp: return "arrow.up"
        case .swipeDown: return "arrow.down"
        case .swipeLeft: return "arrow.left"
        case .swipeRight: return "arrow.right"
        case .shake: return "iphone.gen3.radiowaves.left.and.right"
        case .tiltLeft: return "iphone.gen3.landscape"
        case .tiltRight: return "iphone.gen3.landscape"
        case .raisePhone: return "arrow.up.circle"
        case .lowerPhone: return "arrow.down.circle"
        case .pinch: return "hand.pinch"
        case .stroop: return "paintpalette"
        }
    }

    /// All testable gestures (excluding .none)
    static var allTestable: [GestureTestMode] {
        allCases.filter { $0 != .none }
    }
}

// MARK: - Gesture Test Result

/// Result of a per-gesture test session
struct GestureTestResult: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let expected: GestureType
    let detected: GestureType?
    let issueType: IssueType
    let sensorSnapshot: SensorData
    let thresholdsSnapshot: ThresholdSnapshot
    let timing: GestureTiming
    let deviceContext: DeviceContext

    init(
        expected: GestureType,
        detected: GestureType?,
        sensorSnapshot: SensorData,
        timing: GestureTiming,
        thresholdsSnapshot: ThresholdSnapshot? = nil,
        deviceContext: DeviceContext? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.expected = expected
        self.detected = detected
        self.sensorSnapshot = sensorSnapshot
        self.timing = timing
        self.thresholdsSnapshot = thresholdsSnapshot ?? ThresholdSnapshot.capture()
        self.deviceContext = deviceContext ?? DeviceContext.capture()

        // Auto-determine issue type (with Stroop-aware comparison)
        if detected == nil {
            self.issueType = .notDetected
        } else if expected.isCorrectResponse(detected!) {
            self.issueType = .success
        } else {
            self.issueType = .wrongDetection
        }
    }

    /// Display text for the result
    var displayText: String {
        let detectedName = detected?.displayName ?? "None"
        return "\(expected.displayName) → \(detectedName)"
    }
}

// MARK: - Date Extensions

extension Date {
    /// Timestamp for export filenames (compact, filesystem-safe)
    var exportTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: self)
    }
}

#endif
