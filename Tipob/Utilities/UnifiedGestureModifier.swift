import SwiftUI

struct UnifiedGestureModifier: ViewModifier {
    let onGesture: (GestureType) -> Void

    // Drag tracking
    @State private var dragStartLocation: CGPoint = .zero
    @State private var dragStartTime: Date = Date()

    // Tap tracking
    @State private var lastTapTime: Date = Date.distantPast
    @State private var tapCount: Int = 0

    // Long press tracking
    @State private var longPressTimer: Timer?
    @State private var isLongPressing = false
    @State private var longPressStartLocation: CGPoint = .zero

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                // Drag gesture for swipes and two-finger swipes
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            if dragStartLocation == .zero {
                                dragStartLocation = value.startLocation
                                dragStartTime = Date()
                            }
                        }
                        .onEnded { value in
                            let fingerCount = 1 // Single finger drag
                            handleDragEnd(from: value.startLocation, to: value.location, in: geometry.size, fingerCount: fingerCount)
                            dragStartLocation = .zero
                        }
                )
                // Two-finger drag gesture
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .local)
                        .onChanged { value in
                            // Two-finger drag detection
                        }
                        .onEnded { value in
                            let fingerCount = 2
                            handleDragEnd(from: value.startLocation, to: value.location, in: geometry.size, fingerCount: fingerCount)
                        }
                )
                // Tap gesture
                .simultaneousGesture(
                    TapGesture()
                        .onEnded { _ in
                            handleTap()
                        }
                )
                // Long press gesture
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: GameConfiguration.longPressMinDuration)
                        .onEnded { _ in
                            handleLongPress()
                        }
                )
        }
    }

    // MARK: - Drag/Swipe Handling

    private func handleDragEnd(from start: CGPoint, to end: CGPoint, in size: CGSize, fingerCount: Int) {
        // Skip edge swipes
        guard !isNearEdge(start, in: size) else { return }

        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        let timeDelta = Date().timeIntervalSince(dragStartTime)
        let velocity = timeDelta > 0 ? distance / CGFloat(timeDelta) : 0

        // Check if it's a swipe (sufficient distance and velocity)
        let minDistance = fingerCount == 2 ? GameConfiguration.twoFingerSwipeMinDistance : GameConfiguration.minSwipeDistance

        guard distance >= minDistance,
              velocity >= GameConfiguration.minSwipeVelocity else {
            return
        }

        // Two-finger swipe detected
        if fingerCount == 2 {
            onGesture(.twoFingerSwipe)
            return
        }

        // Single-finger directional swipe
        let angle = atan2(deltaY, deltaX)
        let gesture = determineSwipeDirection(from: angle)
        onGesture(gesture)
    }

    private func isNearEdge(_ point: CGPoint, in size: CGSize) -> Bool {
        let buffer = GameConfiguration.edgeBufferDistance

        return point.x < buffer ||
               point.x > size.width - buffer ||
               point.y < buffer ||
               point.y > size.height - buffer
    }

    private func determineSwipeDirection(from angle: CGFloat) -> GestureType {
        let degrees = angle * 180 / .pi

        switch degrees {
        case -45...45:
            return .right
        case 45...135:
            return .down
        case -135...(-45):
            return .up
        default:
            return .left
        }
    }

    // MARK: - Tap Handling

    private func handleTap() {
        let now = Date()
        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)

        // Check if this is a double tap
        if timeSinceLastTap <= GameConfiguration.doubleTapMaxInterval && tapCount == 1 {
            // Double tap detected
            onGesture(.doubleTap)
            tapCount = 0
            lastTapTime = Date.distantPast
        } else {
            // First tap, wait to see if double tap follows
            tapCount = 1
            lastTapTime = now

            // Set a timer to trigger single tap if no second tap comes
            DispatchQueue.main.asyncAfter(deadline: .now() + GameConfiguration.doubleTapMaxInterval) {
                if self.tapCount == 1 && now.timeIntervalSince(self.lastTapTime) >= GameConfiguration.doubleTapMaxInterval {
                    // Single tap confirmed
                    self.onGesture(.tap)
                    self.tapCount = 0
                }
            }
        }
    }

    // MARK: - Long Press Handling

    private func handleLongPress() {
        onGesture(.longPress)
    }
}

extension View {
    func detectGestures(onGesture: @escaping (GestureType) -> Void) -> some View {
        modifier(UnifiedGestureModifier(onGesture: onGesture))
    }
}
