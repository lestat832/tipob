//
//  HomeIconField.swift
//  Tipob
//
//  Created on 2026-01-05
//  Animated gesture icon background layer for MenuView
//

import SwiftUI
import Combine

// MARK: - FloatingIcon Model

/// Individual floating icon with position and animation state
class FloatingIcon: Identifiable, ObservableObject {
    let id: UUID
    let assetName: String
    let anchor: CGPoint                        // Base position (stable, immutable)
    @Published var interactionOffset: CGSize   // Tap scatter offset
    @Published var rotation: Double            // Current rotation (degrees)
    @Published var scale: CGFloat              // Current scale
    @Published var opacity: Double             // 0.85-0.95
    @Published var shouldShake: Bool = false   // Triggered by ViewModel

    init(id: UUID = UUID(), assetName: String, anchor: CGPoint) {
        self.id = id
        self.assetName = assetName
        self.anchor = anchor
        self.interactionOffset = .zero
        self.rotation = 0
        self.scale = 1.0
        self.opacity = Double.random(in: 0.85...0.95)
    }

    /// Trigger shake animation (called by ViewModel)
    func triggerShake() {
        shouldShake = true
        // Reset after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.shouldShake = false
        }
    }
}

// MARK: - HomeIconFieldViewModel

/// Manages floating icons state and interactions
class HomeIconFieldViewModel: ObservableObject {
    @Published var icons: [FloatingIcon] = []

    private var shakeTimer: Timer?

    private let iconAssets = [
        "gesture_tap_default",
        "gesture_double_tap_default",
        "gesture_long_press_default",
        "gesture_pinch_default",
        "gesture_swipe_up_default",
        "gesture_swipe_down_default",
        "gesture_swipe_left_default",
        "gesture_swipe_right_default",
        "gesture_shake_default",
        "gesture_tilt_left_default",
        "gesture_tilt_right_default",
        "gesture_raise_phone_default",
        "gesture_lower_phone_default"
    ]

    private let iconCount = 8  // Optimal density with reshuffling
    private let iconSize: CGFloat = 44  // Icon display size
    private let gridSpacing: CGFloat = 80  // Grid spacing GUARANTEES no bunching

    /// Initialize icons using grid-based placement (guarantees spacing)
    func initializeIcons(in size: CGSize, safeInsets: EdgeInsets) {
        icons.removeAll()

        // Build grid of valid positions
        var validPositions: [CGPoint] = []

        let centerX = size.width / 2
        let centerY = size.height / 2
        let centerExclusionRadius: CGFloat = 150  // Avoid center button (200/2 + margin)

        let minY = safeInsets.top + 80   // Below top bar
        let maxY = size.height - safeInsets.bottom - 50
        let minX: CGFloat = 30
        let maxX = size.width - 30

        // Generate grid positions
        var y = minY
        while y < maxY {
            var x = minX
            while x < maxX {
                // Check 1: Center button (circular exclusion)
                let distanceFromCenter = sqrt(pow(x - centerX, 2) + pow(y - centerY, 2))
                let inCenterButtonZone = distanceFromCenter < centerExclusionRadius

                // Check 2: Control bar - MODE selector + Discreet toggle (rectangular exclusion)
                let controlBarMinY = centerY - 180
                let controlBarMaxY = centerY - 80
                let controlBarMinX = centerX - 180
                let controlBarMaxX = centerX + 180
                let inControlBarZone = y > controlBarMinY && y < controlBarMaxY && x > controlBarMinX && x < controlBarMaxX

                // Only add if outside BOTH exclusion zones
                if !inCenterButtonZone && !inControlBarZone {
                    validPositions.append(CGPoint(x: x, y: y))
                }
                x += gridSpacing
            }
            y += gridSpacing
        }

        // Shuffle and pick positions for icons
        let selectedPositions = Array(validPositions.shuffled().prefix(iconCount))
        let shuffledAssets = iconAssets.shuffled()

        // Create icons at grid positions
        for (index, position) in selectedPositions.enumerated() {
            let icon = FloatingIcon(
                assetName: shuffledAssets[index % shuffledAssets.count],
                anchor: position
            )
            icons.append(icon)
        }
    }

    /// Scatter icons away from tap point
    func scatterFrom(point: CGPoint) {
        let maxDistance: CGFloat = 150  // Full impulse within this radius
        let maxImpulse: CGFloat = 40    // Maximum scatter distance

        for icon in icons {
            // Calculate vector from tap to icon
            let dx = icon.anchor.x - point.x
            let dy = icon.anchor.y - point.y
            let distance = sqrt(dx * dx + dy * dy)

            // Calculate impulse with falloff
            let falloff = max(0, 1 - distance / maxDistance)
            let impulse = maxImpulse * falloff

            guard impulse > 0 else { continue }

            // Normalize direction
            let normalizedDx = distance > 0 ? dx / distance : 0
            let normalizedDy = distance > 0 ? dy / distance : 0

            // Apply impulse
            let targetOffset = CGSize(
                width: normalizedDx * impulse,
                height: normalizedDy * impulse
            )

            // Animate scatter
            withAnimation(.easeOut(duration: 0.2)) {
                icon.interactionOffset = targetOffset
            }

            // Animate settle back with spring
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    icon.interactionOffset = .zero
                }
            }
        }
    }

    /// Simple opacity pulse for accessibility (reduce motion)
    func pulseOpacity() {
        for icon in icons {
            let originalOpacity = icon.opacity

            withAnimation(.easeInOut(duration: 0.15)) {
                icon.opacity = 0.5
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    icon.opacity = originalOpacity
                }
            }
        }
    }

    // MARK: - Centralized Shake Control

    /// Start the shake scheduler (called once when icons initialized)
    func startShakeScheduler() {
        scheduleNextShake()
    }

    /// Stop the shake scheduler
    func stopShakeScheduler() {
        shakeTimer?.invalidate()
        shakeTimer = nil
    }

    private func scheduleNextShake() {
        let interval = Double.random(in: 8.0...15.0)
        shakeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.triggerRandomShake()
            self?.scheduleNextShake()
        }
    }

    private func triggerRandomShake() {
        guard !icons.isEmpty else { return }

        // Pick 1-2 random icons to shake
        let count = Int.random(in: 1...2)
        let iconsToShake = icons.shuffled().prefix(count)

        for icon in iconsToShake {
            icon.triggerShake()
        }
    }
}

// MARK: - FloatingIconView

/// Individual floating icon with drift animation
struct FloatingIconView: View {
    @ObservedObject var icon: FloatingIcon
    let reduceMotion: Bool

    @State private var driftOffset: CGSize = .zero
    @State private var driftRotation: Double = 0
    @State private var driftScale: CGFloat = 1.0
    @State private var shakeOffset: CGFloat = 0

    var body: some View {
        Image(icon.assetName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 44, height: 44)
            .rotationEffect(.degrees(driftRotation + icon.rotation))
            .scaleEffect(driftScale * icon.scale)
            .offset(x: shakeOffset)  // Shake offset applied separately
            .position(
                x: icon.anchor.x + driftOffset.width + icon.interactionOffset.width,
                y: icon.anchor.y + driftOffset.height + icon.interactionOffset.height
            )
            .opacity(icon.opacity)
            .onAppear {
                if !reduceMotion {
                    startDriftAnimation()
                }
            }
            .onChange(of: icon.shouldShake) { _, shouldShake in
                if shouldShake && !reduceMotion {
                    performShake()
                }
            }
    }

    private func startDriftAnimation() {
        // Seeded animation parameters based on icon.id for deterministic variation
        let seed = icon.id.hashValue

        // Bob animation (Y offset): 2.5-4.0s duration, ±3-6pt amplitude
        let bobDuration = 2.5 + Double(abs(seed % 15)) / 10.0
        let bobAmplitude = CGFloat(3 + abs(seed % 4))

        // Rotation animation: 3.0-5.0s duration, ±3-8° amplitude
        let rotateDuration = 3.0 + Double(abs(seed % 20)) / 10.0
        let rotateAmplitude = Double(3 + abs(seed % 6))

        // Scale animation: 2.5-4.0s duration, 0.98-1.02 range
        let scaleDuration = 2.5 + Double(abs(seed % 15)) / 10.0
        let scaleVariation = CGFloat(0.02 + Double(abs(seed % 2)) * 0.01)

        // Start animations with slight delays to avoid synchronized motion
        let delay = Double(abs(seed % 10)) / 20.0  // 0-0.5s stagger

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: bobDuration).repeatForever(autoreverses: true)) {
                driftOffset = CGSize(width: 0, height: bobAmplitude)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.1) {
            withAnimation(.easeInOut(duration: rotateDuration).repeatForever(autoreverses: true)) {
                driftRotation = rotateAmplitude
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.2) {
            withAnimation(.easeInOut(duration: scaleDuration).repeatForever(autoreverses: true)) {
                driftScale = 1.0 + scaleVariation
            }
        }
    }

    private func performShake() {
        // Quick shake animation: 3 oscillations over 0.4 seconds
        let shakeDuration = 0.05
        let shakeAmount: CGFloat = 4

        // Shake sequence: right, left, right, left, center
        withAnimation(.linear(duration: shakeDuration)) {
            shakeOffset = shakeAmount
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + shakeDuration) {
            withAnimation(.linear(duration: shakeDuration)) {
                shakeOffset = -shakeAmount
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + shakeDuration * 2) {
            withAnimation(.linear(duration: shakeDuration)) {
                shakeOffset = shakeAmount * 0.6
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + shakeDuration * 3) {
            withAnimation(.linear(duration: shakeDuration)) {
                shakeOffset = -shakeAmount * 0.6
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + shakeDuration * 4) {
            withAnimation(.easeOut(duration: shakeDuration)) {
                shakeOffset = 0
            }
        }
    }
}

// MARK: - HomeIconField

/// Animated gesture icon background layer
struct HomeIconField: View {
    @ObservedObject var viewModel: HomeIconFieldViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var hasInitialized = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(viewModel.icons) { icon in
                    FloatingIconView(icon: icon, reduceMotion: reduceMotion)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: geometry.size) { oldSize, newSize in
                // Re-initialize on significant size change (device rotation)
                if !hasInitialized || abs(oldSize.width - newSize.width) > 50 {
                    viewModel.initializeIcons(in: newSize, safeInsets: geometry.safeAreaInsets)
                    hasInitialized = true
                }
            }
            .onAppear {
                // Always re-initialize for fresh random positions on every home screen visit
                viewModel.initializeIcons(in: geometry.size, safeInsets: geometry.safeAreaInsets)
                hasInitialized = true

                // Start centralized shake scheduler (respects reduce motion)
                if !reduceMotion {
                    viewModel.startShakeScheduler()
                }
            }
            .onDisappear {
                viewModel.stopShakeScheduler()
            }
        }
        .allowsHitTesting(false)  // Don't block UI interactions
    }
}
