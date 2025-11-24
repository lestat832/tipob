import SwiftUI
import Lottie

/// Alternative Lottie wrapper with manual progress control
struct ManagedLottieView: UIViewRepresentable {
    let animationName: String
    let duration: TimeInterval
    var onComplete: (() -> Void)?
    
    @State private var animationView: LottieAnimationView?
    
    class Coordinator: NSObject {
        var parent: ManagedLottieView
        var displayLink: CADisplayLink?
        var startTime: CFTimeInterval = 0
        var animationView: LottieAnimationView?
        
        init(_ parent: ManagedLottieView) {
            self.parent = parent
        }
        
        @objc func updateAnimation(displayLink: CADisplayLink) {
            guard let animationView = animationView else { return }
            
            if startTime == 0 {
                startTime = displayLink.timestamp
            }
            
            let elapsed = displayLink.timestamp - startTime
            let progress = min(elapsed / parent.duration, 1.0)
            
            animationView.currentProgress = progress
            
            if progress >= 1.0 {
                displayLink.invalidate()
                self.displayLink = nil
                DispatchQueue.main.async {
                    self.parent.onComplete?()
                }
            }
        }
        
        deinit {
            displayLink?.invalidate()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        let animationView = LottieAnimationView(name: animationName)

        guard animationView.animation != nil else {
            print("❌ Failed to load animation: \(animationName)")
            return containerView
        }
        
        // Configure animation view
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // Important: Don't auto-play
        animationView.currentProgress = 0
        
        // Log animation details
        if let animation = animationView.animation {
            print("✅ ManagedLottie loaded: \(animationName)")
            print("📊 Animation duration: \(animation.duration)s")
            print("📊 Frames: \(animation.startFrame) to \(animation.endFrame)")
        }
        
        containerView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Store animation view in coordinator
        context.coordinator.animationView = animationView
        
        // Start manual animation using CADisplayLink
        let displayLink = CADisplayLink(target: context.coordinator, selector: #selector(Coordinator.updateAnimation))
        displayLink.add(to: .main, forMode: .common)
        context.coordinator.displayLink = displayLink
        
        print("🎬 Started manual animation control")
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
}

/// Updated LaunchView using manual control
struct LaunchViewFixed: View {
    @State private var viewOpacity: Double = 1.0
    @State private var animationComplete: Bool = false
    @State private var minimumTimeElapsed: Bool = false
    @State private var startTime: Date = Date()
    @State private var useManualControl: Bool = true // Toggle for testing

    var onComplete: () -> Void

    private let minimumDisplayTime: TimeInterval = 1.5
    private let animationDuration: TimeInterval = 1.0 // 60 frames at 60fps

    var body: some View {
        ZStack {
            // Background color to match animation
            Color(red: 1.0, green: 0.8, blue: 0.0) // #FFCC00
                .ignoresSafeArea()

            if useManualControl {
                // Use manual control version
                ManagedLottieView(
                    animationName: "LaunchAnimation",
                    duration: animationDuration
                ) {
                    print("🎬 Manual animation completed")
                    animationComplete = true
                    checkReadyToTransition()
                }
                .ignoresSafeArea()
            } else {
                // Use original version for comparison
                LottieView(
                    animationName: "LaunchAnimation",
                    playMode: .once,
                    animationSpeed: 1.0
                ) {
                    print("🎬 Standard animation completed")
                    animationComplete = true
                    checkReadyToTransition()
                }
                .ignoresSafeArea()
            }
            
            // Debug overlay
            #if DEBUG
            VStack {
                Spacer()
                HStack {
                    Text(useManualControl ? "Manual Control" : "Standard")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                    Spacer()
                }
                .padding()
            }
            #endif
        }
        .opacity(viewOpacity)
        .onAppear {
            startTime = Date()
            print("🎬 LaunchViewFixed appeared, using \(useManualControl ? "manual" : "standard") control")

            // Ensure minimum display time
            DispatchQueue.main.asyncAfter(deadline: .now() + minimumDisplayTime) {
                print("🎬 Minimum time elapsed")
                minimumTimeElapsed = true
                checkReadyToTransition()
            }
        }
    }

    private func checkReadyToTransition() {
        // Only transition when both animation is done AND minimum time has passed
        guard animationComplete && minimumTimeElapsed else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        print("🎬 Ready to transition after \(String(format: "%.2f", elapsed))s")

        withAnimation(.easeOut(duration: 0.3)) {
            viewOpacity = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onComplete()
        }
    }
}

#if DEBUG
struct LaunchViewFixed_Previews: PreviewProvider {
    static var previews: some View {
        LaunchViewFixed(onComplete: {})
    }
}
#endif
