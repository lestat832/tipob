import SwiftUI

/// Individual gesture cell for the gesture drawer grid
/// Displays gesture symbol, color, and name with Y2K/Gen-Z styling
struct GestureCellView: View {
    let gesture: GestureType
    let size: CGFloat

    init(gesture: GestureType, size: CGFloat = 64) {
        self.gesture = gesture
        self.size = size
    }

    var body: some View {
        VStack(spacing: 6) {
            // Gesture visual with vibrant styling
            gestureVisual
                .frame(width: size, height: size * 0.75)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(gesture.color.opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            gesture.color.opacity(0.8),
                                            gesture.color.opacity(0.4)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: gesture.color.opacity(0.3), radius: 6, x: 0, y: 3)
                )

            // Gesture name
            Text(gesture.displayName)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(width: size + 10)
    }

    // MARK: - Gesture Visual

    @ViewBuilder
    private var gestureVisual: some View {
        let displaySize = size * 0.45
        if GestureVisualProvider.useV2Images,
           let assetName = GestureVisualProvider.v2AssetName(for: gesture) {
            // V2: Image from Assets2.xcassets
            Image(assetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: displaySize, height: displaySize)
        } else {
            // V1: Symbol
            Text(gesture.symbol)
                .font(.system(size: displaySize))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 20) {
            GestureCellView(gesture: .up)
            GestureCellView(gesture: .tap)
            GestureCellView(gesture: .shake)
        }
    }
}
