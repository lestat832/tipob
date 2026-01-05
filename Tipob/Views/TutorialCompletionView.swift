import SwiftUI

struct TutorialCompletionView: View {
    @ObservedObject var viewModel: GameViewModel
    let onPlayNow: () -> Void
    let onKeepPracticing: () -> Void
    let onComplete: () -> Void

    @State private var textScale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var buttonScale: CGFloat = 0.8

    var body: some View {
        ZStack {
            // Full-screen gradient background
            Color.toyBoxGameOverGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // HERO (no header - hero is first element)
                Text("You've Mastered the Basics!")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .scaleEffect(textScale)
                    .opacity(opacity)

                // STAT LINE
                Text("Gestures: 14 / 14")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(opacity)
                    .padding(.top, 20)

                Spacer()

                // BOTTOM: Buttons
                VStack(spacing: 20) {
                    // Primary CTA - Play Now
                    Button(action: {
                        HapticManager.shared.impact()
                        onPlayNow()
                    }) {
                        HStack {
                            Image("icon_play_default")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 40, height: 40)
                                .padding(.vertical, -12)
                            Text("Play Now")
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
                    .scaleEffect(buttonScale)
                    .opacity(opacity)

                    // Secondary CTAs (HStack)
                    HStack(spacing: 15) {
                        // Home button
                        Button(action: {
                            HapticManager.shared.impact()
                            onComplete()
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

                        // Repeat button
                        Button(action: {
                            AnalyticsManager.shared.logTutorialContinue()
                            HapticManager.shared.impact()
                            onKeepPracticing()
                        }) {
                            HStack {
                                Image("icon_repeat_default")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 40, height: 40)
                                    .padding(.vertical, -12)
                                Text("Repeat")
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
                    .scaleEffect(buttonScale)
                    .opacity(opacity)
                }
                .padding(.bottom, 40)
            }
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
