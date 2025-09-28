import SwiftUI

struct SequenceDisplayView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.8), .blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                Text("Watch the sequence!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 50)

                Spacer()

                if viewModel.showingGestureIndex < viewModel.gameModel.sequence.count {
                    ArrowView(
                        gesture: viewModel.gameModel.sequence[viewModel.showingGestureIndex],
                        isAnimating: true
                    )
                    .id(viewModel.showingGestureIndex)
                }

                Spacer()

                Text("Round \(viewModel.gameModel.round)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 50)
            }
        }
    }
}