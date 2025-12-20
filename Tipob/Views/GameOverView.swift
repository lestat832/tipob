import SwiftUI

struct GameOverView: View {
    @ObservedObject var viewModel: GameViewModel

    #if DEBUG || TESTFLIGHT
    @Binding var showDevPanel: Bool
    #endif

    @State private var textScale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var showingLeaderboard = false

    var body: some View {
        ZStack {
            Color.toyBoxGameOverGradient
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // High Score Banner (if new high score)
                if viewModel.isNewHighScore {
                    VStack(spacing: 8) {
                        Image("icon_trophy_default")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 56, height: 56)

                        Text("NEW HIGH SCORE!")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.toyBoxTap)
                            .shadow(color: .orange, radius: 10)
                    }
                    .scaleEffect(textScale)
                    .opacity(opacity)
                    .padding(.bottom, 10)
                }

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
                                .foregroundColor(.toyBoxTap)
                        }
                    }
                }
                .opacity(opacity)

                Spacer()

                // Action Buttons
                VStack(spacing: 20) {
                    // Play Again Button
                    Button(action: {
                        // Log replay_game analytics
                        let mode: GameMode = viewModel.isClassicMode ? .classic : .memory
                        AnalyticsManager.shared.logReplayGame(mode: mode, discreetMode: viewModel.discreetModeEnabled)

                        HapticManager.shared.impact()

                        // Check if we should show an ad
                        if AdManager.shared.shouldShowEndOfGameAd() {
                            // Get top view controller and show ad
                            if let viewController = UIApplication.topViewController() {
                                // Prepare countdown BEFORE showing ad (hides Game Over screen immediately)
                                viewModel.prepareForCountdown()

                                AdManager.shared.showInterstitialAd(from: viewController) {
                                    // After ad dismisses, begin countdown then start new game
                                    viewModel.beginCountdown {
                                        if viewModel.isClassicMode {
                                            viewModel.startClassic(isReplay: true)
                                        } else {
                                            viewModel.startMemory(isReplay: true)
                                        }
                                    }
                                }
                            } else {
                                // No view controller - start game immediately (no ad shown)
                                if viewModel.isClassicMode {
                                    viewModel.startClassic(isReplay: true)
                                } else {
                                    viewModel.startMemory(isReplay: true)
                                }
                            }
                        } else {
                            // No ad - start game immediately
                            if viewModel.isClassicMode {
                                viewModel.startClassic(isReplay: true)
                            } else {
                                viewModel.startMemory(isReplay: true)
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title2)
                            Text("Play Again")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(Color.toyBoxButtonText)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(Color.toyBoxButtonBg)
                                .shadow(radius: 5)
                        )
                    }

                    HStack(spacing: 15) {
                        // Home Button
                        Button(action: {
                            HapticManager.shared.impact()

                            // Show ad if available, then go home
                            if AdManager.shared.shouldShowEndOfGameAd() {
                                if let viewController = UIApplication.topViewController() {
                                    AdManager.shared.showInterstitialAd(from: viewController) {
                                        viewModel.resetToMenu()
                                    }
                                } else {
                                    viewModel.resetToMenu()
                                }
                            } else {
                                viewModel.resetToMenu()
                            }
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Home")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                            )
                        }

                        // Leaderboard Button
                        Button(action: {
                            HapticManager.shared.impact()
                            showingLeaderboard = true
                        }) {
                            HStack {
                                Image("icon_trophy_default")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 56, height: 56)
                                Text("High Scores")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.toyBoxTap.opacity(0.4))
                            )
                        }
                    }
                }
                .opacity(opacity)
                .padding(.bottom, 50)
            }
            .padding(.top, 100)
        }
        .overlay(alignment: .topTrailing) {
            #if DEBUG || TESTFLIGHT
            Button(action: {
                HapticManager.shared.impact()
                showDevPanel = true
            }) {
                Image("icon_settings_default")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .padding(8)
            }
            #endif
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView()
        }
        .onAppear {
            // Increment game count when game over screen appears
            AdManager.shared.incrementGameCount()

            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                textScale = 1.0
                opacity = 1.0
            }
        }
    }
}