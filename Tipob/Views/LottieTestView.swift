import SwiftUI
import Lottie

/// Test view to diagnose Lottie animation issues
struct LottieTestView: View {
    @State private var playbackProgress: AnimationProgressTime = 0
    @State private var isPlaying: Bool = false
    @State private var animationInfo: String = "Loading..."
    
    var body: some View {
        ZStack {
            // Yellow background to match animation
            Color(red: 1.0, green: 0.8, blue: 0.0)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Test 1: Basic LottieView
                Text("Test 1: Basic LottieView")
                    .foregroundColor(.black)
                
                LottieView(
                    animationName: "LaunchAnimation",
                    playMode: .once,
                    animationSpeed: 1.0
                ) {
                    print("✅ Test 1 completed")
                }
                .frame(height: 300)
                .background(Color.black.opacity(0.1))
                
                // Test 2: Direct UIViewRepresentable
                Text("Test 2: Direct Implementation")
                    .foregroundColor(.black)
                
                DirectLottieView(
                    animationName: "LaunchAnimation",
                    playbackProgress: $playbackProgress,
                    isPlaying: $isPlaying,
                    animationInfo: $animationInfo
                )
                .frame(height: 300)
                .background(Color.black.opacity(0.1))
                
                // Debug info
                VStack(alignment: .leading, spacing: 5) {
                    Text("Progress: \(String(format: "%.2f", playbackProgress))")
                    Text("Playing: \(isPlaying ? "Yes" : "No")")
                    Text(animationInfo)
                }
                .foregroundColor(.black)
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
                
                // Manual controls
                HStack {
                    Button("Play") {
                        isPlaying = true
                    }
                    Button("Stop") {
                        isPlaying = false
                    }
                    Button("Reset") {
                        playbackProgress = 0
                    }
                }
                .foregroundColor(.white)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

/// Direct Lottie implementation for testing
struct DirectLottieView: UIViewRepresentable {
    let animationName: String
    @Binding var playbackProgress: AnimationProgressTime
    @Binding var isPlaying: Bool
    @Binding var animationInfo: String
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        // Load animation
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.0
        animationView.tag = 1001

        // Get animation info
        if let animation = animationView.animation {
            DispatchQueue.main.async {
                animationInfo = """
                Loaded: ✅
                Duration: \(animation.duration)s
                Frames: \(animation.startFrame)-\(animation.endFrame)
                FPS: \(animation.framerate)
                """
            }
        } else {
            DispatchQueue.main.async {
                animationInfo = "❌ Animation data is nil"
            }
        }

        containerView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // Set up progress observer
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            DispatchQueue.main.async {
                playbackProgress = animationView.currentProgress
                isPlaying = animationView.isAnimationPlaying
            }

            if !animationView.isAnimationPlaying && animationView.currentProgress >= 1.0 {
                timer.invalidate()
            }
        }
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = uiView.viewWithTag(1001) as? LottieAnimationView else { return }
        
        if isPlaying && !animationView.isAnimationPlaying {
            animationView.play()
        } else if !isPlaying && animationView.isAnimationPlaying {
            animationView.pause()
        }
    }
}

#if DEBUG
struct LottieTestView_Previews: PreviewProvider {
    static var previews: some View {
        LottieTestView()
    }
}
#endif
