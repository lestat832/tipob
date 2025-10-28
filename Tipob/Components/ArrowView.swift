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
        switch gesture.animationStyle {
        case .doublePulse:
            animateDoublePulse()
        case .fillGlow:
            animateFillGlow()
        case .compress:
            animateCompress()
        case .expand:
            animateExpand()
        case .singlePulse:
            animateSinglePulse()
        }
    }

    private func animateSinglePulse() {
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

    private func animateDoublePulse() {
        // First pulse: 175ms
        withAnimation(.easeInOut(duration: 0.175)) {
            scale = 1.3
            opacity = 1.0
            glowRadius = 20
        }

        // Slight pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.175) {
            withAnimation(.easeInOut(duration: 0.025)) {
                scale = 1.1
                glowRadius = 10
            }
        }

        // Second pulse: 175ms
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.175)) {
                scale = 1.3
                glowRadius = 20
            }
        }

        // Fade out (total duration ~350ms)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.375) {
            withAnimation(.easeInOut(duration: GameConfiguration.sequenceGapDuration)) {
                scale = 1.0
                opacity = 0
                glowRadius = 0
            }
        }
    }

    private func animateFillGlow() {
        // Gradual fill/glow effect over 0.8s
        withAnimation(.easeInOut(duration: 0.8)) {
            scale = 1.2
            opacity = 1.0
            glowRadius = 30  // Higher glow than other gestures
        }

        // Quick flash on completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.scale = 1.4  // Quick pop
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeInOut(duration: GameConfiguration.sequenceGapDuration)) {
                self.scale = 1.0
                self.opacity = 0
                self.glowRadius = 0
            }
        }
    }

    private func animateCompress() {
        // Start large
        scale = 1.4
        opacity = 1.0
        glowRadius = 25

        // Compress inward animation (300ms - quick squeeze)
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0.7  // Shrink to 70% (visual pinch effect)
            glowRadius = 40  // Increase glow as it compresses
        }

        // Bounce back (200ms spring)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                scale = 1.0
                glowRadius = 20
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: GameConfiguration.sequenceGapDuration)) {
                scale = 1.0
                opacity = 0
                glowRadius = 0
            }
        }
    }

    private func animateExpand() {
        // Start small (opposite of compress)
        scale = 0.7
        opacity = 1.0
        glowRadius = 25

        // Expand outward animation (300ms - quick spread)
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.4  // Grow to 140% (visual spread effect)
            glowRadius = 40  // Increase glow as it expands
        }

        // Bounce back (200ms spring)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                scale = 1.0
                glowRadius = 20
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: GameConfiguration.sequenceGapDuration)) {
                scale = 1.0
                opacity = 0
                glowRadius = 0
            }
        }
    }

    private func colorForGesture(_ gesture: GestureType) -> Color {
        switch gesture.color {
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "magenta": return Color(red: 1.0, green: 0.0, blue: 1.0) // Magenta RGB
        case "indigo": return .indigo
        case "purple": return .purple
        default: return .gray
        }
    }
}