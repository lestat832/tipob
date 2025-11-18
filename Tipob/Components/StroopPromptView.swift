import SwiftUI

/// Displays a Stroop Color-Swipe prompt with directional color labels
/// Shows a color word in a mismatched text color, with arrows indicating which color maps to which direction
struct StroopPromptView: View {
    let wordColor: ColorType
    let textColor: ColorType
    let upColor: ColorType
    let downColor: ColorType
    let leftColor: ColorType
    let rightColor: ColorType
    let isAnimating: Bool

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var glowRadius: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var rotationAngle: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            // Top: ↑ COLOR
            VStack(spacing: 4) {
                Text("↑")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                Text(upColor.displayName)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(upColor.uiColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(upColor.uiColor, lineWidth: 3)
                            )
                    )
                    .fixedSize()
                    .frame(minWidth: 80)
            }
            .padding(.top, 40)

            Spacer()

            // Middle row: Left, Center word, Right
            HStack {
                // Left: ← COLOR (vertical)
                VStack(spacing: 4) {
                    Text("←")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                    Text(leftColor.displayName)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(leftColor.uiColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(leftColor.uiColor, lineWidth: 3)
                                )
                        )
                        .fixedSize()
                        .frame(minWidth: 80)
                }
                .padding(.leading, 10)

                Spacer()

                // Center word (with white stroke for visibility)
                ZStack {
                    // White stroke (background layer)
                    Text(wordColor.displayName)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(x: -2, y: -2)
                    Text(wordColor.displayName)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(x: 2, y: -2)
                    Text(wordColor.displayName)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(x: -2, y: 2)
                    Text(wordColor.displayName)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(x: 2, y: 2)

                    // Main colored word (foreground layer)
                    Text(wordColor.displayName)
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(textColor.uiColor)
                        .shadow(color: textColor.uiColor.opacity(0.6), radius: glowRadius)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                .offset(offset)
                .rotationEffect(.degrees(rotationAngle))
                .fixedSize()
                .onAppear {
                    if isAnimating {
                        animateStroopFlash()
                    } else {
                        scale = 1.0
                        opacity = 1.0
                    }
                }

                Spacer()

                // Right: → COLOR (vertical)
                VStack(spacing: 4) {
                    Text("→")
                        .font(.system(size: 40, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                    Text(rightColor.displayName)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundColor(rightColor.uiColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(rightColor.uiColor, lineWidth: 3)
                                )
                        )
                        .fixedSize()
                        .frame(minWidth: 80)
                }
                .padding(.trailing, 10)
            }

            Spacer()

            // Bottom: ↓ COLOR
            VStack(spacing: 4) {
                Text("↓")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                Text(downColor.displayName)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(downColor.uiColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(downColor.uiColor, lineWidth: 3)
                            )
                    )
                    .fixedSize()
                    .frame(minWidth: 80)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Stroop flash animation - brief color pulse
    private func animateStroopFlash() {
        // Quick fade in with slight scale up
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 1.2
            opacity = 1.0
            glowRadius = 30
        }

        // Pulse the glow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                glowRadius = 45  // Intense color flash
                scale = 1.3
            }
        }

        // Return to normal
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                glowRadius = 20
                scale = 1.0
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
}

/// Extension for using Stroop in game views
extension View {
    /// Displays a Stroop prompt with success/error animations
    func stroopPrompt(
        wordColor: ColorType,
        textColor: ColorType,
        upColor: ColorType,
        downColor: ColorType,
        leftColor: ColorType,
        rightColor: ColorType,
        showSuccess: Bool = false,
        showError: Bool = false
    ) -> some View {
        ZStack {
            StroopPromptView(
                wordColor: wordColor,
                textColor: textColor,
                upColor: upColor,
                downColor: downColor,
                leftColor: leftColor,
                rightColor: rightColor,
                isAnimating: false
            )
            .modifier(StroopFeedbackModifier(showSuccess: showSuccess, showError: showError))
        }
    }
}

/// Modifier for success/error feedback animations
struct StroopFeedbackModifier: ViewModifier {
    let showSuccess: Bool
    let showError: Bool

    @State private var successOffset: CGSize = .zero
    @State private var errorShake: CGFloat = 0
    @State private var flashOpacity: Double = 0

    func body(content: Content) -> some View {
        content
            .offset(successOffset)
            .offset(x: errorShake, y: 0)
            .overlay(
                // Error flash overlay
                Color.red
                    .opacity(flashOpacity * 0.5)
                    .allowsHitTesting(false)
            )
            .onChange(of: showSuccess) {
                if showSuccess {
                    animateSuccess()
                }
            }
            .onChange(of: showError) {
                if showError {
                    animateError()
                }
            }
    }

    /// Success animation - slide in direction
    private func animateSuccess() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            successOffset = CGSize(width: 0, height: -60)
        }

        // Fade back
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.2)) {
                successOffset = .zero
            }
        }
    }

    /// Error animation - shake left-right with red flash
    private func animateError() {
        // Red flash
        withAnimation(.easeInOut(duration: 0.1)) {
            flashOpacity = 1.0
        }

        // Shake sequence
        for i in 0..<4 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: 0.05)) {
                    errorShake = i % 2 == 0 ? 10 : -10
                }
            }
        }

        // Return to center and clear flash
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                errorShake = 0
            }
            withAnimation(.easeOut(duration: 0.2)) {
                flashOpacity = 0
            }
        }
    }
}
