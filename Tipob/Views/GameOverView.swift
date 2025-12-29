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

            VStack(spacing: 0) {
                // High Score Banner (if new high score) - NOT a header
                if viewModel.isNewHighScore {
                    VStack(spacing: 8) {
                        Image("icon_trophy_default")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 56, height: 56)

                        Text("NEW HIGH SCORE!")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: .orange, radius: 8)
                    }
                    .scaleEffect(textScale)
                    .opacity(opacity)
                    .padding(.top, 60)
                }

                Spacer()

                // HERO - Score or Round (no "GAME OVER" header)
                VStack(spacing: 20) {
                    if viewModel.isClassicMode {
                        // Classic Mode - Score as hero
                        Text("Score: \(viewModel.classicModeModel.score)")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(textScale)
                            .opacity(opacity)

                        // Stat line: Best score (if exists)
                        if viewModel.classicModeModel.bestScore > 0 {
                            Text("Best: \(viewModel.classicModeModel.bestScore)")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .opacity(opacity)
                        }
                    } else {
                        // Memory Mode - Round as hero
                        Text("Round: \(viewModel.gameModel.round)")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(textScale)
                            .opacity(opacity)

                        // Stat line: Best streak
                        Text("Best: \(viewModel.gameModel.bestStreak)")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .opacity(opacity)
                    }
                }

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

                    // Secondary CTAs (equal width)
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
                                Image("icon_home_default")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 40, height: 40)
                                    .padding(.vertical, -12)
                                Text("Home")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)
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
                                    .frame(width: 40, height: 40)
                                    .padding(.vertical, -12)
                                Text("High Scores")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.3))
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .opacity(opacity)
                .padding(.bottom, 40)
            }
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