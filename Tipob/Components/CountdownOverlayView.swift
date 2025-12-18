import SwiftUI

/// Full-screen overlay displaying countdown after ad dismisses (3, 2, 1, START)
/// Blocks all touch interaction during countdown
struct CountdownOverlayView: View {
    /// Current countdown value: 3, 2, 1, or 0 ("START")
    let countdownValue: Int?

    var body: some View {
        ZStack {
            // Semi-transparent background blocks all interaction
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            // Countdown number or START text
            if let value = countdownValue {
                if value > 0 {
                    // Display number (3, 2, 1)
                    Text("\(value)")
                        .font(.system(size: 120, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .cyan.opacity(0.8), radius: 20)
                        .scaleEffect(1.0)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    // Display "START"
                    Text("START")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.8), radius: 20)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .allowsHitTesting(true)  // Blocks all touch interaction
        .animation(.easeInOut(duration: 0.2), value: countdownValue)
    }
}

// MARK: - Preview

#Preview("Countdown 3") {
    CountdownOverlayView(countdownValue: 3)
}

#Preview("Countdown 2") {
    CountdownOverlayView(countdownValue: 2)
}

#Preview("Countdown 1") {
    CountdownOverlayView(countdownValue: 1)
}

#Preview("START") {
    CountdownOverlayView(countdownValue: 0)
}
