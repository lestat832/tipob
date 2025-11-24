import SwiftUI
import Lottie

/// Simple play mode enum to avoid exposing Lottie types
enum LottiePlayMode {
    case once
    case loop

    var lottieMode: LottieLoopMode {
        switch self {
        case .once: return .playOnce
        case .loop: return .loop
        }
    }
}

/// SwiftUI wrapper for Lottie animations
struct LottieView: UIViewRepresentable {
    let animationName: String
    let playMode: LottiePlayMode
    let animationSpeed: CGFloat
    var onComplete: (() -> Void)?

    init(
        animationName: String,
        playMode: LottiePlayMode = .once,
        animationSpeed: CGFloat = 1.0,
        onComplete: (() -> Void)? = nil
    ) {
        self.animationName = animationName
        self.playMode = playMode
        self.animationSpeed = animationSpeed
        self.onComplete = onComplete
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)

        // Load animation by name (Lottie searches bundle automatically)
        let animationView = LottieAnimationView(name: animationName)

        // Check if animation loaded successfully
        if let animation = animationView.animation {
            print("✅ Animation loaded: \(animationName)")
            print("📊 Duration: \(animation.duration)s, Frames: \(animation.startFrame)-\(animation.endFrame)")
        } else {
            print("❌ Failed to load animation: \(animationName)")
            // Call completion immediately so app doesn't hang
            DispatchQueue.main.async {
                onComplete?()
            }
            return containerView
        }

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = playMode.lottieMode
        animationView.animationSpeed = animationSpeed
        animationView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Play animation with EXPLICIT progress range (0 to 1)
        // This ensures the full animation plays even if there are keyframe issues
        print("🎬 Starting animation playback (0 → 1)...")
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: playMode.lottieMode) { completed in
            print("🎬 Animation finished - completed: \(completed)")
            if completed {
                DispatchQueue.main.async {
                    onComplete?()
                }
            }
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
}
