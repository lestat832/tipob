import SwiftUI

struct TutorialView: View {
    @ObservedObject var viewModel: GameViewModel

    // State management for tutorial flow
    @State private var currentGestureIndex: Int = 0
    @State private var completedRounds: Int = 0
    @State private var showRetry: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showCompletionSheet: Bool = false

    // Persistence for tutorial completion
    @AppStorage("hasCompletedTutorial") private var hasCompletedTutorial = false

    // Tutorial gesture sequence (fixed order)
    let tutorialGestures: [GestureType] = [.up, .down, .left, .right, .tap, .doubleTap, .longPress, .pinch, .shake, .tiltLeft, .tiltRight, .raise, .lower]

    var currentGesture: GestureType {
        tutorialGestures[currentGestureIndex]
    }

    var body: some View {
        ZStack {
            // Gradient background matching main game
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple, .pink]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Tutorial content
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 10) {
                    Text("Tutorial")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Round \(completedRounds + 1) of 2")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)

                Spacer()

                // Main gesture prompt area
                VStack(spacing: 30) {
                    // Large gesture symbol
                    Text(currentGesture.symbol)
                        .font(.system(size: 120))
                        .foregroundColor(gestureColor(for: currentGesture))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                    // Instruction text
                    Text(instructionText(for: currentGesture))
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    // Success message overlay
                    if showSuccess {
                        VStack(spacing: 15) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.green)

                            Text("Nice!")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Retry message
                    if showRetry && !showSuccess {
                        Text("Try Again!")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                            .transition(.opacity)
                    }
                }

                Spacer()

                // Progress indicators
                VStack(spacing: 15) {
                    Text("Gesture \(currentGestureIndex + 1) of \(tutorialGestures.count)")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))

                    // Gesture completion dots
                    HStack(spacing: 12) {
                        ForEach(0..<tutorialGestures.count, id: \.self) { index in
                            Circle()
                                .fill(index < currentGestureIndex ? Color.green : Color.white.opacity(0.3))
                                .frame(width: 14, height: 14)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .detectSwipes { gesture in
                handleGesture(gesture)
            }
            .detectTaps { gesture in
                handleGesture(gesture)
            }
            .detectPinch(
                onPinch: { handleGesture(.pinch) }
            )
            .detectShake(
                onShake: { handleGesture(.shake) }
            )
            .detectTilts(
                onTiltLeft: { handleGesture(.tiltLeft) },
                onTiltRight: { handleGesture(.tiltRight) }
            )
            .detectRaise(
                onRaise: { handleGesture(.raise) },
                onLower: { handleGesture(.lower) }
            )

            // Completion view overlay
            if showCompletionSheet {
                TutorialCompletionView(
                    viewModel: viewModel,
                    onKeepPracticing: {
                        restartTutorial()
                    },
                    onComplete: {
                        completeTutorial()
                    }
                )
                .transition(.opacity)
            }
        }
    }

    // MARK: - Gesture Handling

    private func handleGesture(_ gesture: GestureType) {
        // Ignore gestures during success animation
        guard !showSuccess else { return }

        if gesture == currentGesture {
            // Correct gesture!
            handleCorrectGesture()
        } else {
            // Incorrect gesture
            handleIncorrectGesture()
        }
    }

    private func handleCorrectGesture() {
        // Hide retry message if showing
        showRetry = false

        // Show success animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            showSuccess = true
        }

        // Haptic feedback
        HapticManager.shared.success()

        // Move to next gesture after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showSuccess = false
            }

            // Advance to next gesture or complete round
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                advanceToNextGesture()
            }
        }
    }

    private func handleIncorrectGesture() {
        // Show retry message
        withAnimation {
            showRetry = true
        }

        // Failure feedback (sound + haptic)
        FailureFeedbackManager.shared.playFailureFeedback()

        // Hide retry message after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                showRetry = false
            }
        }
    }

    private func advanceToNextGesture() {
        if currentGestureIndex < tutorialGestures.count - 1 {
            // Move to next gesture in sequence
            withAnimation {
                currentGestureIndex += 1
            }
        } else {
            // Completed all 7 gestures
            completeRound()
        }
    }

    private func completeRound() {
        completedRounds += 1

        if completedRounds >= 2 {
            // Show completion sheet after 2 rounds
            showCompletionSheet = true
        } else {
            // Start next round
            withAnimation {
                currentGestureIndex = 0
            }
        }
    }

    private func restartTutorial() {
        withAnimation {
            showCompletionSheet = false
            completedRounds = 0
            currentGestureIndex = 0
            showRetry = false
            showSuccess = false
        }
    }

    private func completeTutorial() {
        hasCompletedTutorial = true
        viewModel.resetToMenu()
    }

    // MARK: - Helper Functions

    private func instructionText(for gesture: GestureType) -> String {
        switch gesture {
        case .up:
            return "Swipe Up"
        case .down:
            return "Swipe Down"
        case .left:
            return "Swipe Left"
        case .right:
            return "Swipe Right"
        case .tap:
            return "Tap the screen"
        case .doubleTap:
            return "Double tap quickly"
        case .longPress:
            return "Press and hold"
        case .pinch:
            return "Pinch inward with two fingers"
        // case .spread:  // SPREAD: Temporarily disabled
        //     return "Spread outward with two fingers"
        case .shake:
            return "Shake your device"
        case .tiltLeft:
            return "Tilt your phone to the left"
        case .tiltRight:
            return "Tilt your phone to the right"
        case .raise:
            return "Lift the phone upward"
        case .lower:
            return "Move the phone downward"
        }
    }

    private func gestureColor(for gesture: GestureType) -> Color {
        switch gesture.color {
        case "blue":
            return .blue
        case "green":
            return .green
        case "red":
            return .red
        case "orange":
            return .orange
        case "yellow":
            return .yellow
        case "cyan":
            return .cyan
        case "magenta":
            return Color(red: 1.0, green: 0.0, blue: 1.0) // Magenta RGB
        case "indigo":
            return .indigo
        case "purple":
            return .purple
        case "teal":
            return .teal
        case "brown":
            return .brown
        case "mint":
            return .mint  // Light green for raise
        default:
            return .white
        }
    }
}
