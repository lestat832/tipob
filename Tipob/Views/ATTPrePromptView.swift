import SwiftUI

/// Pre-prompt view shown before the system ATT dialog.
/// Explains the value of tracking to improve opt-in rates.
struct ATTPrePromptView: View {
    let onContinue: () -> Void
    let onNotNow: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { } // Prevent tap-through

            // Card content
            VStack(spacing: 24) {
                // Icon
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.white)
                    .padding(.top, 8)

                // Title
                Text("Help Support Out of Pocket")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Body text
                Text("Allow tracking to see more relevant ads and support free gameplay. Your data helps keep the game free!")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)

                // Buttons
                VStack(spacing: 12) {
                    // Continue button (primary)
                    Button(action: {
                        HapticManager.shared.impact()
                        onContinue()
                    }) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(14)
                    }

                    // Not Now button (secondary)
                    Button(action: {
                        HapticManager.shared.impact()
                        onNotNow()
                    }) {
                        Text("Not Now")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(14)
                    }
                }
                .padding(.top, 8)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.4, green: 0.2, blue: 0.6),
                                Color(red: 0.2, green: 0.3, blue: 0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ATTPrePromptView(
        onContinue: { print("Continue tapped") },
        onNotNow: { print("Not now tapped") }
    )
}
