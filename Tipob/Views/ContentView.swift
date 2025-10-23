import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            switch viewModel.gameState {
            case .launch:
                LaunchView {
                    viewModel.transitionToMenu()
                }

            case .menu:
                MenuView(viewModel: viewModel)
                    .transition(.opacity)

            case .tutorial:
                TutorialView(viewModel: viewModel)
                    .transition(.opacity)

            case .classicMode:
                ClassicModeView(viewModel: viewModel)
                    .transition(.opacity)

            case .gameVsPlayerVsPlayer:
                GameVsPlayerVsPlayerView(viewModel: viewModel)
                    .transition(.opacity)

            case .playerVsPlayer:
                PlayerVsPlayerView(viewModel: viewModel)
                    .transition(.opacity)

            case .showSequence:
                SequenceDisplayView(viewModel: viewModel)
                    .transition(.slide)

            case .awaitInput, .judge:
                GamePlayView(viewModel: viewModel)
                    .transition(.opacity)

            case .gameOver:
                GameOverView(viewModel: viewModel)
                    .transition(.slide)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gameState)
    }
}