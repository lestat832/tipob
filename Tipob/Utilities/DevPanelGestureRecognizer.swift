//
//  DevPanelGestureRecognizer.swift
//  Tipob
//
//  Created on 2025-11-13
//  Admin Dev Panel - 3-Finger Triple-Tap Access Gesture (DEBUG ONLY)
//

#if DEBUG
import SwiftUI
import UIKit

/// SwiftUI overlay view that detects 3-finger triple-tap to open Dev Panel
struct DevPanelGestureOverlay: UIViewRepresentable {

    @Binding var isPresented: Bool

    func makeUIView(context: Context) -> DevPanelGestureView {
        let view = DevPanelGestureView()
        view.onTripleTapDetected = {
            DispatchQueue.main.async {
                isPresented = true
            }
        }
        return view
    }

    func updateUIView(_ uiView: DevPanelGestureView, context: Context) {
        // No updates needed
    }
}

/// UIView that captures 3-finger triple-tap gestures
class DevPanelGestureView: UIView {

    var onTripleTapDetected: (() -> Void)?

    private var tapGestureRecognizer: UITapGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizer()
    }

    private func setupGestureRecognizer() {
        // Create 3-finger triple-tap recognizer
        tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTripleTap)
        )
        tapGestureRecognizer.numberOfTapsRequired = 3
        tapGestureRecognizer.numberOfTouchesRequired = 3

        addGestureRecognizer(tapGestureRecognizer)

        // Make view invisible but interactive
        backgroundColor = .clear
        isUserInteractionEnabled = true

        print("✅ DevPanelGestureView initialized (3-finger triple-tap active)")
    }

    @objc private func handleTripleTap() {
        print("🎛️ Dev Panel triggered (3-finger triple-tap detected)")
        HapticManager.shared.impact()
        onTripleTapDetected?()
    }

    // Allow touches to pass through to views below
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Only intercept if gesture recognizer would recognize
        for gestureRecognizer in gestureRecognizers ?? [] {
            if gestureRecognizer.state != .possible {
                return true
            }
        }
        return false
    }
}

#endif
