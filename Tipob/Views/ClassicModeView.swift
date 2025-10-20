import SwiftUI

struct ClassicModeView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            Color.white
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
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, 100)

                Spacer()

                // Large gesture display
                if let currentGesture = viewModel.classicModeModel.currentGesture {
                    Text(currentGesture.symbol)
                        .font(.system(size: 120))
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
                    .foregroundColor(.gray)
                    .padding(.top, 20)

                Spacer()

                // Reaction time indicator
                Text(String(format: "%.1fs", viewModel.classicModeModel.reactionTime))
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 50)
            }
        }
        .detectSwipes { gesture in
            viewModel.handleClassicModeGesture(gesture)
        }
        .detectTaps { gesture in
            viewModel.handleClassicModeGesture(gesture)
        }
    }
}
