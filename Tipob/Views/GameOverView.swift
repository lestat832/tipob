import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var textScale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.red.opacity(0.8), .orange.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("GAME OVER")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(textScale)
                    .opacity(opacity)

                VStack(spacing: 15) {
                    if viewModel.isClassicMode {
                        // Classic Mode - show Score
                        HStack {
                            Text("Score:")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(viewModel.classicModeModel.score)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    } else {
                        // Memory Mode - show Round
                        HStack {
                            Text("Round:")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(viewModel.gameModel.round)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }

                        HStack {
                            Text("Best Streak:")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            Text("\(viewModel.gameModel.bestStreak)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .opacity(opacity)

                Spacer()

                Text("Tap anywhere to continue")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 50)
                    .opacity(opacity)
            }
            .padding(.top, 100)
        }
        .onTapGesture {
            HapticManager.shared.impact()
            viewModel.resetToMenu()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                textScale = 1.0
                opacity = 1.0
            }
        }
    }
}