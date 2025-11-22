import SwiftUI

struct LaunchView: View {
    @State private var viewOpacity: Double = 1.0
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0.0

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .cyan]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("TIPOB")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(titleScale)
                    .opacity(titleOpacity)

                Text("Swipe to Survive")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(titleOpacity)
            }
        }
        .opacity(viewOpacity)
        .onAppear {
            // Animate title in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }

            // Transition to menu after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    viewOpacity = 0.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
    }
}

#if DEBUG
struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(onComplete: {})
    }
}
#endif
