import SwiftUI

/// Small capsule tab at bottom-center that opens the gesture drawer
/// Features pulsing animation for first 2 appearances to draw attention
struct GestureDrawerTabView: View {
    let onExpand: () -> Void

    @AppStorage("gestureDrawerShowCount") private var showCount: Int = 0
    @State private var isPulsing: Bool = false

    private var shouldPulse: Bool {
        showCount < 2
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.impact()
            // Increment show count (stops pulsing after 2 taps)
            if showCount < 2 {
                showCount += 1
            }
            onExpand()
        }) {
            HStack(spacing: 6) {
                Text("Gestures")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Image(systemName: "chevron.up")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
            )
            .scaleEffect(isPulsing && shouldPulse ? 1.08 : 1.0)
            .shadow(color: .white.opacity(0.2), radius: isPulsing && shouldPulse ? 8 : 0)
        }
        .onAppear {
            if shouldPulse {
                startPulseAnimation()
            }
        }
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            isPulsing = true
        }
    }
}

#Preview {
    ZStack {
        Color.toyBoxClassicGradient.ignoresSafeArea()
        VStack {
            Spacer()
            GestureDrawerTabView {
                print("Expand tapped")
            }
            .padding(.bottom, 40)
        }
    }
}
