//
//  GestureTestView.swift
//  Tipob
//
//  Created on 2025-11-20
//  Per-gesture test view for isolated gesture testing (DEBUG ONLY)
//

#if DEBUG
import SwiftUI
import CoreMotion
import Combine

/// Full-screen view for testing individual gestures
struct GestureTestView: View {
    @ObservedObject private var config = DevConfigManager.shared
    @Environment(\.dismiss) private var dismiss

    let testMode: GestureTestMode
    let onComplete: () -> Void

    // State
    @State private var timeRemaining: Double = 3.0
    @State private var isRecording = true
    @State private var detectedGesture: GestureType? = nil
    @State private var testStartTime: Date = Date()
    @State private var actualGesture: GestureType? = nil  // Generated once on appear

    // Gesture detection state
    @State private var tapCount = 0
    @State private var tapWorkItem: DispatchWorkItem?
    @State private var longPressActive = false

    // Motion manager for motion gestures
    @StateObject private var motionDetector = TestMotionDetector()

    // Timer
    @State private var timer: Timer?

    private let testDuration: Double = 3.0

    var body: some View {
        ZStack {
            // Background - match classic mode gradient
            Color.toyBoxClassicGradient
                .ignoresSafeArea()
                .contentShape(Rectangle())

            VStack(spacing: 40) {
                // Header
                HStack {
                    Button("Cancel") {
                        cancelTest()
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Text(String(format: "%.1fs", timeRemaining))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(timeRemaining < 1.0 ? .red : .white)
                }
                .padding(.horizontal)

                Spacer()

                // Gesture display - use same components as gameplay
                if let gesture = actualGesture {
                    if case .stroop(let wordColor, let textColor, let upColor, let downColor, let leftColor, let rightColor) = gesture {
                        StroopPromptView(
                            wordColor: wordColor,
                            textColor: textColor,
                            upColor: upColor,
                            downColor: downColor,
                            leftColor: leftColor,
                            rightColor: rightColor,
                            isAnimating: false
                        )
                    } else {
                        ArrowView(gesture: gesture, isAnimating: false)
                    }
                } else {
                    // Loading state
                    ProgressView()
                        .tint(.white)
                }

                Spacer()

                // Recording indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .opacity(isRecording ? 1.0 : 0.3)

                    Text("Recording Sensors")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Gesture hint
                Text("Test: \(testMode.displayName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
        }
        // Apply gesture recognizers based on test mode
        .applyTestGestures(
            testMode: testMode,
            onTap: handleTap,
            onDoubleTap: handleDoubleTap,
            onLongPress: handleLongPress,
            onSwipe: handleSwipe,
            onPinch: handlePinch
        )
        .onAppear {
            startTest()
        }
        .onDisappear {
            cleanup()
        }
        .onChange(of: motionDetector.detectedMotion) { _, newMotion in
            if let motion = newMotion {
                handleMotionDetected(motion)
            }
        }
    }

    // MARK: - Test Lifecycle

    private func startTest() {
        testStartTime = Date()
        timeRemaining = testDuration
        isRecording = true

        // Generate the actual gesture once (important for Stroop which is random)
        actualGesture = testMode.gestureType

        // Start motion detection if needed
        if actualGesture?.isMotionGesture == true {
            motionDetector.startDetecting(for: testMode)
        }

        // Start countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                handleTimeout()
            }
        }
    }

    private func cancelTest() {
        cleanup()
        config.exitTestMode()
        dismiss()
    }

    private func cleanup() {
        timer?.invalidate()
        timer = nil
        tapWorkItem?.cancel()
        motionDetector.stopDetecting()
    }

    private func handleTimeout() {
        guard isRecording else { return }
        isRecording = false
        cleanup()

        // Create result with no detection
        recordResult(detected: nil)
    }

    // MARK: - Gesture Handlers

    private func handleTap() {
        guard isRecording, testMode == .tap || testMode == .doubleTap else { return }

        tapWorkItem?.cancel()
        tapCount += 1

        if testMode == .tap {
            // For single tap test, register immediately
            recordResult(detected: .tap)
        } else if testMode == .doubleTap {
            if tapCount == 1 {
                // Wait for potential second tap
                tapWorkItem = DispatchWorkItem { [self] in
                    // Single tap when expecting double
                    recordResult(detected: .tap)
                }
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + config.doubleTapWindow,
                    execute: tapWorkItem!
                )
            } else if tapCount >= 2 {
                tapWorkItem?.cancel()
                recordResult(detected: .doubleTap)
            }
        }
    }

    private func handleDoubleTap() {
        guard isRecording else { return }
        recordResult(detected: .doubleTap)
    }

    private func handleLongPress() {
        guard isRecording, testMode == .longPress else { return }
        recordResult(detected: .longPress)
    }

    private func handleSwipe(_ direction: GestureType) {
        guard isRecording else { return }
        // Allow swipes for swipe tests and Stroop (Stroop is answered with a swipe)
        guard [.swipeUp, .swipeDown, .swipeLeft, .swipeRight, .stroop].contains(testMode) else { return }
        recordResult(detected: direction)
    }

    private func handlePinch(_ scale: CGFloat) {
        guard isRecording, testMode == .pinch else { return }
        if scale < config.pinchScaleThreshold {
            recordResult(detected: .pinch)
        }
    }

    private func handleMotionDetected(_ motion: GestureType) {
        guard isRecording else { return }
        recordResult(detected: motion)
    }

    // MARK: - Result Recording

    private func recordResult(detected: GestureType?) {
        isRecording = false
        cleanup()

        // Use actualGesture (generated once) to ensure Stroop uses same instance
        guard let expected = actualGesture else { return }

        // Capture sensor snapshot
        let sensorSnapshot = SensorCaptureBuffer.shared.captureSnapshot()

        // Calculate timing
        let endTime = Date()
        let actualDuration = detected != nil ? endTime.timeIntervalSince(testStartTime) : nil

        let timing = GestureTiming(
            gestureStartTime: testStartTime,
            gestureEndTime: endTime,
            allowedDuration: testDuration,
            actualDuration: actualDuration,
            timeoutOccurred: detected == nil
        )

        // Create result
        let result = GestureTestResult(
            expected: expected,
            detected: detected,
            sensorSnapshot: sensorSnapshot,
            timing: timing
        )

        // Record in config manager
        config.recordTestResult(result)

        // Notify completion
        onComplete()
    }
}

// MARK: - Gesture Modifiers Extension

extension View {
    @ViewBuilder
    func applyTestGestures(
        testMode: GestureTestMode,
        onTap: @escaping () -> Void,
        onDoubleTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void,
        onSwipe: @escaping (GestureType) -> Void,
        onPinch: @escaping (CGFloat) -> Void
    ) -> some View {
        self
            // Tap gestures
            .simultaneousGesture(
                TapGesture()
                    .onEnded { onTap() }
            )
            // Long press
            .simultaneousGesture(
                LongPressGesture(minimumDuration: DevConfigManager.shared.longPressDuration)
                    .onEnded { _ in onLongPress() }
            )
            // Swipe gestures
            .simultaneousGesture(
                DragGesture(minimumDistance: DevConfigManager.shared.minSwipeDistance)
                    .onEnded { value in
                        let direction = detectSwipeDirection(from: value)
                        onSwipe(direction)
                    }
            )
            // Pinch gesture
            .simultaneousGesture(
                MagnificationGesture()
                    .onEnded { scale in
                        onPinch(scale)
                    }
            )
    }

    private func detectSwipeDirection(from value: DragGesture.Value) -> GestureType {
        let horizontal = value.translation.width
        let vertical = value.translation.height

        if abs(horizontal) > abs(vertical) {
            return horizontal > 0 ? .right : .left
        } else {
            return vertical > 0 ? .down : .up
        }
    }
}

// MARK: - Motion Detector for Tests

/// Dedicated motion detector for gesture tests
class TestMotionDetector: ObservableObject {
    @Published var detectedMotion: GestureType? = nil

    private let motionManager = CMMotionManager()
    private var testMode: GestureTestMode = .none
    private var config: DevConfigManager { DevConfigManager.shared }

    // Detection state
    private var tiltStartTime: Date?
    private var raiseLowerStartTime: Date?

    func startDetecting(for mode: GestureTestMode) {
        testMode = mode
        detectedMotion = nil

        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device motion not available")
            return
        }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            self.processMotionData(data)
        }

        print("🧪 Started motion detection for: \(mode.displayName)")
    }

    func stopDetecting() {
        motionManager.stopDeviceMotionUpdates()
        testMode = .none
        tiltStartTime = nil
        raiseLowerStartTime = nil
        print("🧪 Stopped motion detection")
    }

    private func processMotionData(_ data: CMDeviceMotion) {
        switch testMode {
        case .shake:
            checkShake(data)
        case .tiltLeft, .tiltRight:
            checkTilt(data)
        case .raisePhone, .lowerPhone:
            checkRaiseLower(data)
        default:
            break
        }
    }

    private func checkShake(_ data: CMDeviceMotion) {
        let accel = data.userAcceleration
        let magnitude = sqrt(accel.x * accel.x + accel.y * accel.y + accel.z * accel.z)

        if magnitude > config.shakeThreshold {
            detectedMotion = .shake
        }
    }

    private func checkTilt(_ data: CMDeviceMotion) {
        let roll = data.attitude.roll

        let tiltLeft = roll < -config.tiltAngleThreshold
        let tiltRight = roll > config.tiltAngleThreshold

        let expectedTilt = testMode == .tiltLeft ? tiltLeft : tiltRight

        if expectedTilt {
            if tiltStartTime == nil {
                tiltStartTime = Date()
            } else if Date().timeIntervalSince(tiltStartTime!) >= config.tiltDuration {
                detectedMotion = testMode == .tiltLeft ? .tiltLeft : .tiltRight
            }
        } else {
            tiltStartTime = nil
        }
    }

    private func checkRaiseLower(_ data: CMDeviceMotion) {
        let zAccel = data.userAcceleration.z

        let isRaising = zAccel > config.raiseLowerThreshold
        let isLowering = zAccel < -config.raiseLowerThreshold

        let expectedMotion = testMode == .raisePhone ? isRaising : isLowering

        // Check for spike (immediate trigger)
        let spikeThreshold = config.raiseLowerSpikeThreshold
        if testMode == .raisePhone && zAccel > spikeThreshold {
            detectedMotion = .raise
            return
        } else if testMode == .lowerPhone && zAccel < -spikeThreshold {
            detectedMotion = .lower
            return
        }

        // Check for sustained motion
        if expectedMotion {
            if raiseLowerStartTime == nil {
                raiseLowerStartTime = Date()
            } else if Date().timeIntervalSince(raiseLowerStartTime!) >= config.raiseLowerSustainedDuration {
                detectedMotion = testMode == .raisePhone ? .raise : .lower
            }
        } else {
            raiseLowerStartTime = nil
        }
    }
}

// MARK: - Test Result View

/// View displayed after a gesture test completes
struct GestureTestResultView: View {
    @ObservedObject private var config = DevConfigManager.shared
    @Environment(\.dismiss) private var dismiss

    let onRetest: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Test Result")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    config.exitTestMode()
                    onDone()
                }
            }
            .padding(.horizontal)

            if let result = config.activeTestResult {
                // Result icon
                Image(systemName: result.issueType == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(result.issueType.color)

                // Result details
                VStack(spacing: 12) {
                    HStack {
                        Text("Expected:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(result.expected.displayName)
                            .fontWeight(.medium)
                    }

                    HStack {
                        Text("Detected:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(result.detected?.displayName ?? "None")
                            .fontWeight(.medium)
                            .foregroundColor(result.detected == nil ? .red : .primary)
                    }

                    HStack {
                        Text("Issue Type:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(result.issueType.displayName)
                            .fontWeight(.medium)
                            .foregroundColor(result.issueType.color)
                    }

                    if let duration = result.timing.actualDuration {
                        HStack {
                            Text("Reaction Time:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "%.2fs", duration))
                                .fontWeight(.medium)
                        }
                    }

                    HStack {
                        Text("Sensor Samples:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(result.sensorSnapshot.sampleCount)")
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)

                // Action buttons
                VStack(spacing: 12) {
                    // Save as sample
                    Button(action: {
                        config.saveTestResultAsLogEntry()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save as Sample")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    // Retest
                    Button(action: onRetest) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Retest")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                    }
                }
            } else {
                Text("No result available")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
    }
}

#endif
