import SwiftUI

struct LaunchView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("TIPOB")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation))

                HStack(spacing: 20) {
                    ForEach(GestureType.allCases, id: \.self) { gesture in
                        Text(gesture.symbol)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(opacity)
                            .scaleEffect(scale)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: scale)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }

            withAnimation(.easeInOut(duration: 2.0)) {
                rotation = 360
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onComplete()
            }
        }
    }
}