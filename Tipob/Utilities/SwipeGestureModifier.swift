import SwiftUI

struct SwipeGestureModifier: ViewModifier {
    let onSwipe: (GestureType) -> Void
    @State private var dragStartLocation: CGPoint = .zero
    @State private var dragStartTime: Date = Date()

    func body(content: Content) -> some View {
        #if DEBUG
        let dragMinDistance = DevConfigManager.shared.dragMinimumDistance
        #else
        let dragMinDistance: CGFloat = 20
        #endif

        return GeometryReader { geometry in
            content
                .simultaneousGesture(
                    DragGesture(minimumDistance: dragMinDistance)
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
        let deltaX = end.x - start.x
        let deltaY = end.y - start.y
        let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
        let timeDelta = Date().timeIntervalSince(dragStartTime)
        let velocity = timeDelta > 0 ? distance / CGFloat(timeDelta) : 0
        let angle = atan2(deltaY, deltaX)
        let potentialGesture = determineGesture(from: angle)

        // Check edge proximity
        guard !isNearEdge(start, in: size) else {
            #if DEBUG
            print("[\(Date().logTimestamp)] ⚠️ Swipe \(potentialGesture.displayName) rejected - started near edge (start: \(Int(start.x)),\(Int(start.y)) screen: \(Int(size.width))x\(Int(size.height)))")
            // Log rejection for raw gesture data capture
            DevConfigManager.shared.logGestureAttempt(.swipe(
                direction: potentialGesture,
                wasAccepted: false,
                rejectionReason: "edge_buffer",
                startPosition: start,
                endPosition: end,
                distance: distance,
                velocity: velocity,
                screenSize: size
            ))
            #endif
            return
        }

        // Check distance and velocity thresholds
        guard distance >= GameConfiguration.minSwipeDistance,
              velocity >= GameConfiguration.minSwipeVelocity else {
            #if DEBUG
            let distOK = distance >= GameConfiguration.minSwipeDistance
            let velOK = velocity >= GameConfiguration.minSwipeVelocity
            let reason = !distOK && !velOK ? "distance_and_velocity" : (!distOK ? "distance" : "velocity")
            print("[\(Date().logTimestamp)] ⚠️ Swipe \(potentialGesture.displayName) rejected - distance: \(Int(distance))px (min: \(Int(GameConfiguration.minSwipeDistance)), \(distOK ? "✓" : "✗")), velocity: \(Int(velocity))px/s (min: \(Int(GameConfiguration.minSwipeVelocity)), \(velOK ? "✓" : "✗"))")
            // Log rejection for raw gesture data capture
            DevConfigManager.shared.logGestureAttempt(.swipe(
                direction: potentialGesture,
                wasAccepted: false,
                rejectionReason: reason,
                startPosition: start,
                endPosition: end,
                distance: distance,
                velocity: velocity,
                screenSize: size
            ))
            #endif
            return
        }

        // Check gesture coordinator before triggering
        guard GestureCoordinator.shared.shouldAllowGesture(potentialGesture) else {
            print("[\(Date().logTimestamp)] ⏸️ Swipe \(potentialGesture.displayName) suppressed by coordinator")
            #if DEBUG
            // Log coordinator suppression
            DevConfigManager.shared.logGestureAttempt(.swipe(
                direction: potentialGesture,
                wasAccepted: false,
                rejectionReason: "coordinator_suppressed",
                startPosition: start,
                endPosition: end,
                distance: distance,
                velocity: velocity,
                screenSize: size
            ))
            #endif
            return
        }

        print("[\(Date().logTimestamp)] 🎯 Swipe \(potentialGesture.displayName) detected - distance: \(Int(distance))px, velocity: \(Int(velocity))px/s")
        #if DEBUG
        // Log successful swipe
        DevConfigManager.shared.logGestureAttempt(.swipe(
            direction: potentialGesture,
            wasAccepted: true,
            rejectionReason: nil,
            startPosition: start,
            endPosition: end,
            distance: distance,
            velocity: velocity,
            screenSize: size
        ))
        #endif
        onSwipe(potentialGesture)
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
