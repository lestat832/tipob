import SwiftUI

struct GamePlayView: View {
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
                Text("Swipe!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, GameConfiguration.headerTopPadding)

                Spacer()

                CountdownRing(
                    totalTime: GameConfiguration.perGestureTime,
                    timeRemaining: .constant(viewModel.timeRemaining)
                )

                Text("Gesture \(viewModel.gameModel.currentGestureIndex + 1) of \(viewModel.gameModel.sequence.count)")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.top, 20)

                Spacer()

                HStack(spacing: GameConfiguration.progressDotSpacing) {
                    ForEach(0..<viewModel.gameModel.sequence.count, id: \.self) { index in
                        Circle()
                            .fill(index < viewModel.gameModel.currentGestureIndex ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: GameConfiguration.progressDotSize, height: GameConfiguration.progressDotSize)
                    }
                }
                .padding(.bottom, GameConfiguration.bottomPadding)
            }
        }
        .detectGestures { gesture in
            viewModel.handleSwipe(gesture)
        }
    }
}