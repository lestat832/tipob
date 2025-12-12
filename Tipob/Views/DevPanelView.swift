//
//  DevPanelView.swift
//  Tipob
//
//  Created on 2025-11-13
//  Admin Dev Panel - Live Gesture Threshold Tuning UI (DEBUG ONLY)
//

#if DEBUG || TESTFLIGHT
import SwiftUI

/// Wrapper to make URL identifiable for sheet presentation
private struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct DevPanelView: View {

    @ObservedObject var viewModel: GameViewModel
    @ObservedObject private var config = DevConfigManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showingExportSheet = false
    @State private var exportURL: URL?
    @State private var showingResetAlert = false

    // Export issues (using Identifiable wrapper for reliable sheet presentation)
    @State private var exportIssuesItem: IdentifiableURL?

    // Per-gesture testing
    @State private var showingGestureTest = false
    @State private var activeTestMode: GestureTestMode = .none
    @State private var showingTestResult = false

    // Section expansion state (Gameplay Logs expanded by default)
    @State private var isLogsExpanded = true
    @State private var isReplayExpanded = false
    @State private var isGestureTestExpanded = false
    @State private var isThresholdTuningExpanded = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Info
                    infoHeader

                    // Gameplay Logs (expanded by default)
                    CollapsibleSection(
                        title: "📋 Gameplay Logs",
                        badge: config.selectedCount > 0 ? "\(config.selectedCount)" : nil,
                        subtitle: "\(config.gameplayLogs.count) entries",
                        isExpanded: $isLogsExpanded
                    ) {
                        logsContent
                    }

                    // Sequence Replay (moved above gesture tester)
                    CollapsibleSection(
                        title: "🔄 Sequence Replay",
                        isExpanded: $isReplayExpanded
                    ) {
                        replayContent
                    }

                    // Per-Gesture Testing
                    CollapsibleSection(
                        title: "🧪 Per-Gesture Testers",
                        isExpanded: $isGestureTestExpanded
                    ) {
                        gestureTestContent
                    }

                    // Gesture Threshold Tuning (parent section)
                    CollapsibleSection(
                        title: "🎛️ Gesture Threshold Tuning",
                        isExpanded: $isThresholdTuningExpanded
                    ) {
                        VStack(spacing: 12) {
                            shakeSection
                            tiltSection
                            raiseLowerSection
                            swipeSection
                            tapSection
                            pinchSection
                            timingSection
                        }
                    }

                    // Action Buttons
                    actionButtons
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationTitle("Admin Dev Panel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert("Reset to Defaults", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    config.resetToDefaults()
                }
            } message: {
                Text("Reset all gesture thresholds to default values?")
            }
        }
    }

    // MARK: - Info Header

    private var infoHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎛️ Gesture Threshold Tuning")
                .font(.headline)
            Text("Adjust thresholds and tap 'Apply & Play Again' to test changes immediately.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Gameplay Logs Content

    private var logsContent: some View {
        VStack(spacing: 12) {
            // Selection helper buttons
            HStack(spacing: 8) {
                Button("Select All") {
                    config.selectAll()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)

                Button("Select Failures") {
                    config.selectAllFailures()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .cornerRadius(6)

                Button("Clear") {
                    config.clearSelection()
                }
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(6)

                Spacer()
            }

            // Log entries list
            if config.gameplayLogs.isEmpty {
                Text("No logs yet - play a game to see gesture detection logs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(config.gameplayLogs.reversed()) { log in
                            LogEntryRow(log: log) {
                                config.toggleSelection(for: log.id)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 300)
            }
        }
    }

    // MARK: - Per-Gesture Test Content

    private var gestureTestContent: some View {
        VStack(spacing: 12) {
            Text("Test individual gestures with full sensor capture")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Test buttons grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(GestureTestMode.allTestable, id: \.self) { mode in
                    Button(action: {
                        activeTestMode = mode
                        config.startTestMode(mode)
                        showingGestureTest = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: mode.symbolName)
                                .font(.system(size: 14))
                            Text(mode.displayName)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.purple.opacity(0.15))
                        .foregroundColor(.purple)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingGestureTest) {
            GestureTestView(testMode: activeTestMode) {
                showingGestureTest = false
                showingTestResult = true
            }
        }
        .sheet(isPresented: $showingTestResult) {
            GestureTestResultView(
                onRetest: {
                    showingTestResult = false
                    config.startTestMode(activeTestMode)
                    showingGestureTest = true
                },
                onDone: {
                    showingTestResult = false
                    activeTestMode = .none
                }
            )
        }
    }

    // MARK: - Sequence Replay Content

    private var replayContent: some View {
        VStack(spacing: 12) {
            Text("Replay the last game sequence with updated threshold settings")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let memorySeq = config.lastMemorySequence, !memorySeq.isEmpty {
                Button(action: {
                    HapticManager.shared.impact()
                    dismiss()
                    viewModel.replayLastMemorySequence()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Replay Memory Sequence")
                                .fontWeight(.semibold)
                            Text("\(memorySeq.count) gestures: \(memorySeq.prefix(3).map { $0.displayName }.joined(separator: ", "))\(memorySeq.count > 3 ? "..." : "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }

            if let classicSeq = config.lastClassicSequence, !classicSeq.isEmpty {
                Button(action: {
                    HapticManager.shared.impact()
                    dismiss()
                    viewModel.replayLastClassicSequence()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Replay Classic Sequence")
                                .fontWeight(.semibold)
                            Text("\(classicSeq.count) gestures: \(classicSeq.prefix(3).map { $0.displayName }.joined(separator: ", "))\(classicSeq.count > 3 ? "..." : "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                }
            }

            // Show message if no sequences available (nil or empty)
            let hasMemorySeq = config.lastMemorySequence?.isEmpty == false
            let hasClassicSeq = config.lastClassicSequence?.isEmpty == false
            if !hasMemorySeq && !hasClassicSeq {
                Text("Play a game to enable sequence replay")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Shake Detection Section

    private var shakeSection: some View {
        DisclosureGroup("📳 Shake Detection") {
            VStack(spacing: 16) {
                SliderRow(
                    label: "Shake Threshold",
                    value: $config.shakeThreshold,
                    range: 0.5...4.0,
                    unit: "G",
                    step: 0.1,
                    subtitle: "↑ Harder shake required | ↓ Easier to trigger"
                )

                SliderRow(
                    label: "Shake Cooldown",
                    value: $config.shakeCooldown,
                    range: 0.1...2.0,
                    unit: "s",
                    step: 0.1,
                    subtitle: "↑ Longer wait between shakes | ↓ Can shake faster"
                )

                SliderRow(
                    label: "Update Interval",
                    value: $config.shakeUpdateInterval,
                    range: 0.01...0.1,
                    unit: "s",
                    step: 0.01,
                    subtitle: "\(Int(1.0 / config.shakeUpdateInterval)) Hz | ↑ Less responsive | ↓ More responsive"
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Tilt Detection Section

    private var tiltSection: some View {
        DisclosureGroup("◀▶ Tilt Detection") {
            VStack(spacing: 16) {
                SliderRow(
                    label: "Angle Threshold",
                    value: $config.tiltAngleThreshold,
                    range: 0.1...1.57,
                    unit: "rad",
                    step: 0.05,
                    subtitle: "\(Int(config.tiltAngleThreshold * 180 / .pi))° | ↑ More tilt required | ↓ Less tilt required"
                )

                SliderRow(
                    label: "Sustained Duration",
                    value: $config.tiltDuration,
                    range: 0.1...1.0,
                    unit: "s",
                    step: 0.1,
                    subtitle: "↑ Must hold tilt longer | ↓ Quick tilt works"
                )

                SliderRow(
                    label: "Tilt Cooldown",
                    value: $config.tiltCooldown,
                    range: 0.1...2.0,
                    unit: "s",
                    step: 0.1,
                    subtitle: "↑ Longer wait between tilts | ↓ Can tilt faster"
                )

                SliderRow(
                    label: "Update Interval",
                    value: $config.tiltUpdateInterval,
                    range: 0.01...0.1,
                    unit: "s",
                    step: 0.01,
                    subtitle: "\(Int(1.0 / config.tiltUpdateInterval)) Hz | ↑ Less responsive | ↓ More responsive"
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Raise/Lower Detection Section

    private var raiseLowerSection: some View {
        DisclosureGroup("⬆️⬇️ Raise/Lower Detection") {
            VStack(spacing: 16) {
                SliderRow(
                    label: "Normal Threshold",
                    value: $config.raiseLowerThreshold,
                    range: 0.1...1.0,
                    unit: "G",
                    step: 0.05,
                    subtitle: "↑ Harder motion required | ↓ Easier to trigger"
                )

                SliderRow(
                    label: "Spike Threshold",
                    value: $config.raiseLowerSpikeThreshold,
                    range: 0.5...2.0,
                    unit: "G",
                    step: 0.1,
                    subtitle: "Immediate trigger | ↑ Harder instant | ↓ Easier instant"
                )

                SliderRow(
                    label: "Sustained Duration",
                    value: $config.raiseLowerSustainedDuration,
                    range: 0.05...0.5,
                    unit: "s",
                    step: 0.05,
                    subtitle: "↑ Must sustain longer | ↓ Quick motion works"
                )

                SliderRow(
                    label: "Cooldown",
                    value: $config.raiseLowerCooldown,
                    range: 0.1...2.0,
                    unit: "s",
                    step: 0.1,
                    subtitle: "↑ Longer wait between moves | ↓ Can move faster"
                )

                SliderRow(
                    label: "Update Interval",
                    value: $config.raiseLowerUpdateInterval,
                    range: 0.01...0.1,
                    unit: "s",
                    step: 0.01,
                    subtitle: "\(Int(1.0 / config.raiseLowerUpdateInterval)) Hz | ↑ Less responsive | ↓ More responsive"
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Swipe Detection Section

    private var swipeSection: some View {
        DisclosureGroup("↔️ Swipe Detection") {
            VStack(spacing: 16) {
                SliderRow(
                    label: "Minimum Distance",
                    value: $config.minSwipeDistance,
                    range: 20...150,
                    unit: "px",
                    step: 5,
                    subtitle: "↑ Longer swipe required | ↓ Shorter swipe works"
                )

                SliderRow(
                    label: "Minimum Velocity",
                    value: $config.minSwipeVelocity,
                    range: 30...200,
                    unit: "px/s",
                    step: 10,
                    subtitle: "↑ Faster swipe required | ↓ Slower swipe works"
                )

                SliderRow(
                    label: "Edge Buffer",
                    value: $config.edgeBufferDistance,
                    range: 0...100,
                    unit: "px",
                    step: 4,
                    subtitle: "↑ Larger screen margin | ↓ Smaller margin | Prevents edge swipes"
                )

                SliderRow(
                    label: "Drag Minimum",
                    value: $config.dragMinimumDistance,
                    range: 10...50,
                    unit: "px",
                    step: 2,
                    subtitle: "DragGesture | ↑ More initial movement | ↓ Less initial movement"
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Tap Detection Section

    private var tapSection: some View {
        DisclosureGroup("⊙◎ Tap Detection") {
            VStack(spacing: 16) {
                SliderRow(
                    label: "Double Tap Window",
                    value: $config.doubleTapWindow,
                    range: 0.1...0.6,
                    unit: "s",
                    step: 0.05,
                    subtitle: "\(Int(config.doubleTapWindow * 1000)) ms | ↑ More time for 2nd tap | ↓ Taps must be quicker"
                )

                SliderRow(
                    label: "Long Press Duration",
                    value: $config.longPressDuration,
                    range: 0.3...1.5,
                    unit: "s",
                    step: 0.1,
                    subtitle: "↑ Must hold longer | ↓ Shorter hold triggers"
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Pinch Detection Section

    private var pinchSection: some View {
        DisclosureGroup("🤏 Pinch Detection") {
            VStack(spacing: 16) {
                SliderRow(
                    label: "Scale Threshold",
                    value: $config.pinchScaleThreshold,
                    range: 0.5...0.95,
                    unit: "",
                    step: 0.05,
                    subtitle: "\(Int((1.0 - config.pinchScaleThreshold) * 100))% | ↑ Less pinch needed | ↓ More pinch needed"
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Timing Settings Section

    private var timingSection: some View {
        DisclosureGroup("⏱️ Timing Settings") {
            VStack(spacing: 16) {
                SliderRow(
                    label: "Motion→Touch Grace Period",
                    value: $config.motionToTouchGracePeriod,
                    range: 0.0...1.0,
                    unit: "s",
                    step: 0.05,
                    subtitle: "Extra time when switching from motion to touch gesture | ↑ More time | ↓ Less time"
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("What is this?")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Text("When a motion gesture (Raise, Shake, etc.) is followed by a touch gesture (Tap, Swipe, etc.), this adds extra time to account for the physical transition of moving your hand back to the screen.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary: Apply & Play Again
            Button(action: {
                HapticManager.shared.impact()
                dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Apply & Play Again")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            // Export Selected Issues (JSON)
            if config.selectedCount > 0 {
                Button(action: {
                    if let url = config.exportSelectedIssues() {
                        exportIssuesItem = IdentifiableURL(url: url)
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.badge.arrow.up")
                        Text("Export \(config.selectedCount) Selected Issues")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .foregroundColor(.orange)
                    .cornerRadius(12)
                }

            }

            // Export Settings
            Button(action: {
                if let url = config.exportToJSON() {
                    exportURL = url
                    showingExportSheet = true
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Gesture Settings")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(12)
            }

            // Destructive: Reset
            Button(action: {
                showingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset to Defaults")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.2))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
        }
        .sheet(item: $exportIssuesItem) { item in
            ShareSheet(activityItems: [item.url])
        }
    }
}

// MARK: - Slider Row Component

private struct SliderRow<T: BinaryFloatingPoint>: View where T.Stride: BinaryFloatingPoint {

    let label: String
    @Binding var value: T
    let range: ClosedRange<T>
    let unit: String
    let step: T.Stride
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(String(format: "%.2f", Double(value))) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Slider(value: $value, in: range, step: step)
                .accentColor(.blue)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Share Sheet Wrapper

private struct ShareSheet: UIViewControllerRepresentable {

    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Collapsible Section Component

private struct CollapsibleSection<Content: View>: View {
    let title: String
    var badge: String? = nil
    var subtitle: String? = nil
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible, tappable)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let badge = badge {
                        Text(badge)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Spacer()

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.secondary.opacity(0.05))
            }
            .buttonStyle(PlainButtonStyle())

            // Content (collapsible)
            if isExpanded {
                content()
                    .padding()
                    .background(Color.secondary.opacity(0.02))
            }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Log Entry Row Component

private struct LogEntryRow: View {
    let log: GestureLogEntry
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Selection indicator
                Image(systemName: log.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(log.isSelected ? .blue : .secondary)
                    .font(.system(size: 16))

                // Issue type indicator
                Circle()
                    .fill(log.issueType.color)
                    .frame(width: 8, height: 8)

                // Gesture info
                VStack(alignment: .leading, spacing: 2) {
                    Text(log.shortDisplayText)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Text(log.timestamp.logTimestamp)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)

                        if let reactionTime = log.timing.actualDuration {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(String(format: "%.2fs", reactionTime))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Issue type badge
                Text(log.issueType.displayName)
                    .font(.system(size: 9, weight: .medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(log.issueType.color.opacity(0.2))
                    .foregroundColor(log.issueType.color)
                    .cornerRadius(4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(log.isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#endif
