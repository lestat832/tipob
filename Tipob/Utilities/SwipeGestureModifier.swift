import SwiftUI

struct SwipeGestureModifier: ViewModifier {
    let onSwipe: (GestureType) -> Void
    @State private var dragStartLocation: CGPoint = .zero
    @State private var dragStartTime: Date = Date()

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if dragStartLocation == .zero {
                                dragStartLocation = value.startLocation
                                dragStartTime = Date()
                            }
                        }
                        .onEnded { value in
                            handleSwipe(from: value.startLocation, to: value.location, in: geometry.size)
                            dragStartLocation = .zero
                        }
                )
        }
    }

    private func handleSwipe(from start: CGPoint, to end: CGPoint, in size: CGSize) {
        guard !isNearEdge(start, in: size) else { return }

        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        let timeDelta = Date().timeIntervalSince(dragStartTime)
        let velocity = timeDelta > 0 ? distance / CGFloat(timeDelta) : 0

        guard distance >= GameConfiguration.minSwipeDistance,
              velocity >= GameConfiguration.minSwipeVelocity else { return }

        let angle = atan2(deltaY, deltaX)
        let gesture = determineGesture(from: angle)
        onSwipe(gesture)
    }

    private func isNearEdge(_ point: CGPoint, in size: CGSize) -> Bool {
        let buffer = GameConfiguration.edgeBufferDistance

        return point.x < buffer ||
               point.x > size.width - buffer ||
               point.y < buffer ||
               point.y > size.height - buffer
    }

    private func determineGesture(from angle: CGFloat) -> GestureType {
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
}

extension View {
    func detectSwipes(onSwipe: @escaping (GestureType) -> Void) -> some View {
        modifier(SwipeGestureModifier(onSwipe: onSwipe))
    }
}
