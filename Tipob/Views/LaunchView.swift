import SwiftUI

struct LaunchView: View {
    @State private var viewOpacity: Double = 1.0
    @State private var rotationAngle: Double = 0
    @State private var minimumTimeElapsed: Bool = false
    @State private var startTime: Date = Date()

    var onComplete: () -> Void

    private let minimumDisplayTime: TimeInterval = 2.0

    var body: some View {
        ZStack {
            // Gradient background matching main app
            Color.toyBoxClassicGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Out of Pocket")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotationAngle))

                Text("React Fast to Survive")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
        }
        .opacity(viewOpacity)
        .onAppear {
            startTime = Date()

            // Rotate title
            withAnimation(.easeInOut(duration: 1.0)) {
                rotationAngle = 360
            }

            // Transition after minimum display time
            DispatchQueue.main.asyncAfter(deadline: .now() + minimumDisplayTime) {
                minimumTimeElapsed = true
                transitionOut()
            }
        }
    }

    private func transitionOut() {
        let elapsed = Date().timeIntervalSince(startTime)
        print("🎬 Ready to transition after \(String(format: "%.2f", elapsed))s")

        withAnimation(.easeOut(duration: 0.3)) {
            viewOpacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
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
