import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    #if DEBUG
    @State private var showDevPanel = false
    #endif

    var body: some View {
        ZStack {
            switch viewModel.gameState {
            case .launch:
                LaunchView {
                    // Initialize audio after launch animation completes
                    AudioManager.shared.initialize()
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
                #if DEBUG
                GameOverView(viewModel: viewModel, showDevPanel: $showDevPanel)
                    .transition(.slide)
                #else
                GameOverView(viewModel: viewModel)
                    .transition(.slide)
                #endif

            case .leaderboard:
                LeaderboardView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: viewModel.gameState)
        #if DEBUG
        .sheet(isPresented: $showDevPanel) {
            DevPanelView(viewModel: viewModel)
        }
        #endif
    }
}