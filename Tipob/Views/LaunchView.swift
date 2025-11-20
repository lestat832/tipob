import SwiftUI

struct LaunchView: View {
    @State private var titleScale: CGFloat = 0.3
    @State private var titleOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var viewOpacity: Double = 1.0

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.toyBoxLaunchGradient
                .ignoresSafeArea()

            VStack(spacing: 8) {
                // Main title - stacked for impact
                VStack(spacing: -8) {
                    Text("OUT OF")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))

                    Text("POCKET")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

                // Tagline
                Text("Swipe to Survive")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(taglineOpacity)
                    .padding(.top, 16)
            }
        }
        .opacity(viewOpacity)
        .onAppear {
            // Title animation - spring scale up
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }

            // Tagline fades in slightly after title
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                taglineOpacity = 1.0
            }

            // Fade out before transitioning
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.4)) {
                    viewOpacity = 0.0
                }
            }

            // Transition to menu after fade completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                onComplete()
            }
        }
    }
}