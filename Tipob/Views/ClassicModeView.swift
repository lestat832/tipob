import SwiftUI

struct ClassicModeView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.8), .blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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

                // Large gesture display with color-coded arrows
                if let currentGesture = viewModel.classicModeModel.currentGesture {
                    ArrowView(gesture: currentGesture, isAnimating: false)
                        .transition(.scale)
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

                // Reaction time indicator
                Text(String(format: "%.1fs", viewModel.classicModeModel.reactionTime))
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 50)
            }
        }
        .detectSwipes { gesture in
            viewModel.handleClassicModeGesture(gesture)
        }
        .detectTaps { gesture in
            viewModel.handleClassicModeGesture(gesture)
        }
        .detectPinchNative {
            viewModel.handleClassicModeGesture(.pinch)
        }
    }
}
