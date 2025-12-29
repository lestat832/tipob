import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var buttonScale: CGFloat = 1.0
    @State private var isAnimating = false
    @State private var showingModeSheet = false
    @State private var showingLeaderboard = false
    @State private var showingDiscreetInfo = false
    @State private var showingSettings = false
    @AppStorage("selectedGameMode") private var selectedModeRawValue: String = GameMode.tutorial.rawValue
    @AppStorage("discreetModeEnabled") private var discreetModeEnabled = false

    private var selectedMode: GameMode {
        return GameMode(rawValue: selectedModeRawValue) ?? .tutorial
    }

    var body: some View {
        ZStack {
            Color.toyBoxMenuGradient
            .ignoresSafeArea()

            // Layer 1: Top icon bar (Trophy left, Settings right)
            VStack {
                HStack {
                    // Leaderboard Trophy (top-left)
                    Button(action: {
                        HapticManager.shared.impact()
                        showingLeaderboard = true
                    }) {
                        Image("icon_trophy_default")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 56, height: 56)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }

                    Spacer()

                    // Settings button (top-right)
                    Button(action: {
                        HapticManager.shared.impact()
                        showingSettings = true
                    }) {
                        Image("icon_settings_default")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 56, height: 56)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Settings")
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Spacer()
            }

            // Layer 2: Centered content (Mode selector + Start button)
            VStack(spacing: 40) {
                // Mode selector + Discreet mode
                HStack(spacing: 10) {
                        // Clickable Game Mode Pill
                        Button(action: {
                            HapticManager.shared.impact()
                            showingModeSheet = true
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("MODE")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                HStack(spacing: 6) {
                                    Text(selectedMode.emoji)
                                        .font(.system(size: 18))
                                    Text(selectedMode.rawValue)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))

                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .frame(height: 50)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.25))
                            )
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Game Mode")
                            .accessibilityValue(selectedMode.rawValue)
                            .accessibilityHint("Double tap to change game mode")
                            .accessibilityAddTraits(.isButton)
                        }

                        // Compact Discreet Mode Toggle
                        if selectedMode != .tutorial {
                            DiscreetModeCompactToggle(
                                isOn: $discreetModeEnabled,
                                onInfoTapped: {
                                    HapticManager.shared.impact()
                                    showingDiscreetInfo = true
                                }
                            )
                            .onChange(of: discreetModeEnabled) { _, newValue in
                                HapticManager.shared.impact()
                                viewModel.discreetModeEnabled = newValue
                                AnalyticsManager.shared.logDiscreetModeToggled(isOn: newValue)
                            }
                        }
                    }

                // Start Playing button
                Button(action: {
                    HapticManager.shared.impact()
                    // Route based on selected mode
                    switch selectedMode {
                    case .tutorial:
                        viewModel.startTutorial()
                    case .classic:
                        viewModel.startClassic()
                    case .memory:
                        viewModel.startMemory()
                    case .gameVsPlayerVsPlayer:
                        viewModel.startGameVsPlayerVsPlayer()
                    case .playerVsPlayer:
                        viewModel.startPlayerVsPlayer()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.toyBoxButtonBg)
                            .frame(width: 200, height: 200)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                        Text("Start\nPlaying")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color.toyBoxButtonText)
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
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert("Discreet Mode", isPresented: $showingDiscreetInfo) {
            Button("Got it!", role: .cancel) {}
        } message: {
            Text("Hides all motion gestures. Only touch gestures remain — perfect for playing in public.")
        }
        .onAppear {
            // Initialize ViewModel's discreet mode setting on appear
            viewModel.discreetModeEnabled = discreetModeEnabled
        }
    }
}