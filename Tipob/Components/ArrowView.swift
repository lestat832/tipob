import SwiftUI

struct ArrowView: View {
    let gesture: GestureType
    let isAnimating: Bool
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var glowRadius: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var rotationAngle: Double = 0.0

    var body: some View {
        Text(gesture.symbol)
            .font(.system(size: 120, weight: .bold))
            .foregroundColor(colorForGesture(gesture))
            .scaleEffect(scale)
            .opacity(opacity)
            .shadow(color: colorForGesture(gesture).opacity(0.6), radius: glowRadius)
            .offset(offset)
            .rotationEffect(.degrees(rotationAngle))
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
        // case .expand:  // SPREAD: Temporarily disabled
        //     animateExpand()
        case .vibrate:
            animateVibrate()
        case .tiltLeft:
            animateTiltLeft()
        case .tiltRight:
            animateTiltRight()
        case .raiseUp:
            animateRaiseUp()
        case .lowerDown:
            animateLowerDown()
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

    /*  // SPREAD: Temporarily disabled - detection issues
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
    */

    private func animateVibrate() {
        // Rapid side-to-side shake animation
        opacity = 1.0
        scale = 1.0
        glowRadius = 20

        // Quick vibrate sequence (4 shakes in 400ms)
        for i in 0..<4 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: 0.05)) {
                    self.offset = CGSize(width: i % 2 == 0 ? 10 : -10, height: 0)
                }
            }
        }

        // Return to center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                self.offset = .zero
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.opacity = 0
                self.glowRadius = 0
            }
        }
    }

    private func animateTiltLeft() {
        // Tilt left animation - rotate counterclockwise
        opacity = 1.0
        scale = 1.2
        glowRadius = 25

        // Tilt to the left (negative rotation)
        withAnimation(.easeInOut(duration: 0.4)) {
            rotationAngle = -30  // 30 degrees counterclockwise
            scale = 1.3
            glowRadius = 35
        }

        // Return to upright
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                rotationAngle = 0
                scale = 1.0
                glowRadius = 20
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
                glowRadius = 0
            }
        }
    }

    private func animateTiltRight() {
        // Tilt right animation - rotate clockwise
        opacity = 1.0
        scale = 1.2
        glowRadius = 25

        // Tilt to the right (positive rotation)
        withAnimation(.easeInOut(duration: 0.4)) {
            rotationAngle = 30  // 30 degrees clockwise
            scale = 1.3
            glowRadius = 35
        }

        // Return to upright
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                rotationAngle = 0
                scale = 1.0
                glowRadius = 20
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
                glowRadius = 0
            }
        }
    }

    private func animateRaiseUp() {
        // Raise animation - upward slide with spring pop
        opacity = 1.0
        scale = 1.0
        glowRadius = 20
        offset = CGSize(width: 0, height: 40)  // Start below

        // Slide upward with overshoot
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            offset = CGSize(width: 0, height: -20)  // Move up and overshoot
            scale = 1.3
            glowRadius = 30
        }

        // Settle back to center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                offset = .zero
                scale = 1.0
                glowRadius = 20
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
                glowRadius = 0
            }
        }
    }

    private func animateLowerDown() {
        // Lower animation - downward slide with settle
        opacity = 1.0
        scale = 1.0
        glowRadius = 20
        offset = CGSize(width: 0, height: -40)  // Start above

        // Slide downward
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            offset = CGSize(width: 0, height: 20)  // Move down and overshoot
            scale = 1.3
            glowRadius = 30
        }

        // Settle back to center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                offset = .zero
                scale = 1.0
                glowRadius = 20
            }
        }

        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
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
        case "teal": return .teal
        case "brown": return .brown
        case "mint": return .mint  // Light green for raise
        default: return .gray
        }
    }
}