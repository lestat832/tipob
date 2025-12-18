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
                    let currentGesture = viewModel.gameModel.sequence[viewModel.showingGestureIndex]
                    if case .stroop(let wordColor, let textColor, let upColor, let downColor, let leftColor, let rightColor) = currentGesture {
                        StroopPromptView(
                            wordColor: wordColor,
                            textColor: textColor,
                            upColor: upColor,
                            downColor: downColor,
                            leftColor: leftColor,
                            rightColor: rightColor,
                            isAnimating: true,
                            showHelperText: UserSettings.showGestureNames
                        )
                        .id(viewModel.showingGestureIndex)
                    } else {
                        ArrowView(
                            gesture: currentGesture,
                            isAnimating: true,
                            showHelperText: UserSettings.showGestureNames
                        )
                        .id(viewModel.showingGestureIndex)
                    }
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