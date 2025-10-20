import SwiftUI

struct MenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var buttonScale: CGFloat = 1.0
    @State private var isAnimating = false
    @State private var showingModeSheet = false
    @AppStorage("selectedGameMode") private var selectedModeRawValue: String = GameMode.classic.rawValue

    private var selectedMode: GameMode {
        GameMode(rawValue: selectedModeRawValue) ?? .classic
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

                if viewModel.gameModel.bestStreak > 0 {
                    Text("Best Streak: \(viewModel.gameModel.bestStreak)")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }

                Text("\(selectedMode.emoji) \(selectedMode.rawValue)")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )

                Button(action: {
                    HapticManager.shared.impact()
                    // Route to tutorial if selected, otherwise start normal game
                    if selectedMode == .tutorial {
                        viewModel.startTutorial()
                    } else {
                        viewModel.startGame()
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

            // Floating Game Mode Menu Icon
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        HapticManager.shared.impact()
                        showingModeSheet = true
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
                                .frame(width: 60, height: 60)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)

                            Text("🎮")
                                .font(.system(size: 32))
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingModeSheet) {
            GameModeSheet(selectedMode: Binding(
                get: { selectedMode },
                set: { selectedModeRawValue = $0.rawValue }
            ))
        }
    }
}