import SwiftUI

struct ClassicModeView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            Color.toyBoxGameOverGradient
            .ignoresSafeArea()

            if viewModel.flashColor != .clear {
                viewModel.flashColor
                    .ignoresSafeArea()
                    .opacity(0.5)
                    .allowsHitTesting(false)
            }

            VStack {
                Text("React Fast!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 100)

                Spacer()

                // Large gesture display with color-coded arrows or Stroop prompt
                if let currentGesture = viewModel.classicModeModel.currentGesture {
                    if case .stroop(let wordColor, let textColor, let upColor, let downColor, let leftColor, let rightColor) = currentGesture {
                        StroopPromptView(
                            wordColor: wordColor,
                            textColor: textColor,
                            upColor: upColor,
                            downColor: downColor,
                            leftColor: leftColor,
                            rightColor: rightColor,
                            isAnimating: false,
                            showHelperText: UserSettings.showGestureNames
                        )
                        .transition(.scale)
                    } else {
                        ArrowView(gesture: currentGesture, isAnimating: false, showHelperText: UserSettings.showGestureNames)
                            .transition(.scale)
                    }
                }

                Spacer()

                // Countdown ring
                CountdownRing(
                    totalTime: viewModel.classicModeModel.reactionTime,
                    timeRemaining: .constant(viewModel.timeRemaining)
                )

                // Score display
                Text("Score: \(viewModel.classicModeModel.score)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .detectPinch(
                onPinch: { viewModel.handleClassicModeGesture(.pinch) }
            )
            .contentShape(Rectangle())  // Forces full area to accept gestures (fixes Stroop detection)
            .detectSwipes { gesture in
                viewModel.handleClassicModeGesture(gesture)
            }
            .detectTaps { gesture in
                viewModel.handleClassicModeGesture(gesture)
            }
        }
    }
}
