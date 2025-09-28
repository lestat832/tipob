import SwiftUI

struct ArrowView: View {
    let gesture: GestureType
    let isAnimating: Bool
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var glowRadius: CGFloat = 0

    var body: some View {
        Text(gesture.symbol)
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(colorForGesture(gesture))
            .scaleEffect(scale)
            .opacity(opacity)
            .shadow(color: colorForGesture(gesture).opacity(0.6), radius: glowRadius)
            .onAppear {
                if isAnimating {
                    animateIn()
                } else {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }

    private func animateIn() {
        withAnimation(.easeInOut(duration: GameConfiguration.sequenceShowDuration)) {
            scale = 1.3
            opacity = 1.0
            glowRadius = 20
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + GameConfiguration.sequenceShowDuration) {
            withAnimation(.easeInOut(duration: GameConfiguration.sequenceGapDuration)) {
                scale = 1.0
                opacity = 0
                glowRadius = 0
            }
        }
    }

    private func colorForGesture(_ gesture: GestureType) -> Color {
        switch gesture {
        case .up: return .blue
        case .down: return .green
        case .left: return .red
        case .right: return .yellow
        }
    }
}