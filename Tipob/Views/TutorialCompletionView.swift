import SwiftUI

struct TutorialCompletionView: View {
    @ObservedObject var viewModel: GameViewModel
    let onKeepPracticing: () -> Void
    let onComplete: () -> Void

    @State private var textScale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var buttonScale: CGFloat = 0.8

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Completion card
            VStack(spacing: 35) {
                // Celebration emoji
                Text("🎓✨")
                    .font(.system(size: 80))
                    .scaleEffect(textScale)
                    .opacity(opacity)

                // Main title
                Text("You've Mastered\nthe Basics!")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .scaleEffect(textScale)
                    .opacity(opacity)

                // Subtitle
                Text("Great job! You completed 2 rounds")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)

                Spacer()
                    .frame(height: 20)

                // Buttons
                VStack(spacing: 15) {
                    // Keep Practicing button (primary)
                    Button(action: {
                        AnalyticsManager.shared.logTutorialContinue()
                        HapticManager.shared.impact()
                        onKeepPracticing()
                    }) {
                        HStack(spacing: 10) {
                            Text("Keep Practicing")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Text("🔄")
                                .font(.system(size: 20))
                        }
                        .foregroundColor(Color.toyBoxButtonText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.toyBoxButtonBg)
                        .cornerRadius(15)
                        .shadow(color: Color.toyBoxButtonBg.opacity(0.4), radius: 10, x: 0, y: 5)
                    }

                    // I'm Done button (secondary)
                    Button(action: {
                        HapticManager.shared.success()
                        onComplete()
                    }) {
                        HStack(spacing: 10) {
                            Text("I'm Done")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                            Text("✓")
                                .font(.system(size: 20))
                        }
                        .foregroundColor(Color.toyBoxButtonBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .white.opacity(0.9)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 30)
                .scaleEffect(buttonScale)
                .opacity(opacity)
            }
            .padding(.vertical, 60)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.toyBoxMenuGradient)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
        }
        .onAppear {
            // Animate entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                textScale = 1.0
                opacity = 1.0
            }

            // Slight delay for button animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                buttonScale = 1.0
            }
        }
    }
}
