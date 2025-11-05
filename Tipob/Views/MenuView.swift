import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var buttonScale: CGFloat = 1.0
    @State private var isAnimating = false
    @State private var showingModeSheet = false
    @State private var showingLeaderboard = false
    @State private var showingDiscreetInfo = false
    @AppStorage("selectedGameMode") private var selectedModeRawValue: String = GameMode.tutorial.rawValue
    @AppStorage("discreetModeEnabled") private var discreetModeEnabled = false

    private var selectedMode: GameMode {
        return GameMode(rawValue: selectedModeRawValue) ?? .tutorial
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple, .pink]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("TIPOB")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.top, 60)

                // Combined Game Mode Pill + Discreet Toggle + Leaderboard
                HStack(spacing: 10) {
                    // Clickable Game Mode Pill
                    Button(action: {
                        HapticManager.shared.impact()
                        showingModeSheet = true
                    }) {
                        HStack(spacing: 8) {
                            Text(selectedMode.emoji)
                                .font(.system(size: 20))
                            Text(selectedMode.rawValue)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                        )
                    }

                    // Compact Discreet Mode Toggle
                    if selectedMode != .tutorial {
                        HStack(spacing: 6) {
                            Text("🤫")
                                .font(.system(size: 18))
                            Toggle("", isOn: $discreetModeEnabled)
                                .labelsHidden()
                                .tint(.white)

                            // Info button
                            Button(action: {
                                HapticManager.shared.impact()
                                showingDiscreetInfo = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                        )
                        .onChange(of: discreetModeEnabled) { _, newValue in
                            HapticManager.shared.impact()
                            viewModel.discreetModeEnabled = newValue
                        }
                    }

                    // Leaderboard Icon
                    Button(action: {
                        HapticManager.shared.impact()
                        showingLeaderboard = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.yellow.opacity(0.8), .orange.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)

                            Text("🏆")
                                .font(.system(size: 20))
                        }
                    }
                }
                .padding(.horizontal, 20)

                Button(action: {
                    HapticManager.shared.impact()
                    // Route based on selected mode
                    switch selectedMode {
                    case .tutorial:
                        viewModel.startTutorial()
                    case .classic:
                        viewModel.startClassicMode()
                    case .memory:
                        viewModel.startGame()
                    case .gameVsPlayerVsPlayer:
                        viewModel.startGameVsPlayerVsPlayer()
                    case .playerVsPlayer:
                        viewModel.startPlayerVsPlayer()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .white.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                        Text("Start\nPlaying")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            .multilineTextAlignment(.center)
                    }
                }
                .scaleEffect(buttonScale)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        buttonScale = 1.1
                    }
                }
            }
        }
        .sheet(isPresented: $showingModeSheet) {
            GameModeSheet(selectedMode: Binding(
                get: { selectedMode },
                set: { selectedModeRawValue = $0.rawValue }
            ))
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView()
        }
        .alert("Discreet Mode", isPresented: $showingDiscreetInfo) {
            Button("Got it!", role: .cancel) {}
        } message: {
            Text("Filters out physical motion gestures (raise, lower) and keeps only touch gestures (swipe, tap). Perfect for playing in public!")
        }
        .onAppear {
            // Initialize ViewModel's discreet mode setting on appear
            viewModel.discreetModeEnabled = discreetModeEnabled
        }
    }
}