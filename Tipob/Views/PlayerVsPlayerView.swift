import SwiftUI

struct PlayerVsPlayerView: View {
    @ObservedObject var viewModel: GameViewModel

    // Game phases
    @State private var gamePhase: PvPGamePhase = .nameEntry

    // Player info
    @State private var player1Name: String = "Player 1"
    @State private var player2Name: String = "Player 2"

    // Game state
    @State private var sequence: [GestureType] = []
    @State private var currentRound: Int = 1
    @State private var currentPlayer: Int = 1
    @State private var gameOver: Bool = false
    @State private var winner: String? = nil

    // Input tracking
    @State private var userBuffer: [GestureType] = []
    @State private var currentGestureIndex: Int = 0

    // Visual state for showing gestures
    @State private var showGestureAnimation: Bool = false
    @State private var animatedGesture: GestureType? = nil

    // Repeat phase state
    @State private var isAddingGesture: Bool = false

    // Timing
    @State private var timeRemaining: TimeInterval = 3.0
    @State private var perGestureTime: TimeInterval = 3.0
    @State private var timer: Timer? = nil

    // Visuals
    @State private var flashColor: Color = .clear

    // Stats
    @State private var longestSequence: Int = 0
    @State private var player1Wins: Int = 0
    @State private var player2Wins: Int = 0

    enum PvPGamePhase {
        case nameEntry
        case firstGesture
        case repeatPhase
        case addGesture
        case results
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple, .pink]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Flash overlay
            if flashColor != .clear {
                flashColor
                    .ignoresSafeArea()
                    .opacity(0.5)
                    .allowsHitTesting(false)
            }

            // Main content based on phase
            Group {
                switch gamePhase {
                case .nameEntry:
                    nameEntryView
                case .firstGesture:
                    firstGestureView
                case .repeatPhase:
                    repeatPhaseView
                case .addGesture:
                    addGestureView
                case .results:
                    resultsView
                }
            }
        }
        .detectSwipes { gesture in
            handleGesture(gesture)
        }
        .detectTaps { gesture in
            handleGesture(gesture)
        }
        .detectPinch(
            onPinch: { handleGesture(.pinch) }
        )
        .detectShake(
            onShake: { handleGesture(.shake) }
        )
        .detectTilts(
            onTiltLeft: { handleGesture(.tiltLeft) },
            onTiltRight: { handleGesture(.tiltRight) }
        )
    }

    // MARK: - Name Entry View

    private var nameEntryView: some View {
        VStack(spacing: 40) {
            Text("Player vs Player ⚔️")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 60)

            VStack(spacing: 25) {
                // Player 1 name
                VStack(spacing: 8) {
                    Text("Player 1 Name")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Player 1", text: $player1Name)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                        )
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                }

                // Player 2 name
                VStack(spacing: 8) {
                    Text("Player 2 Name")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Player 2", text: $player2Name)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                        )
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            // Start Game button
            Button(action: startGame) {
                Text("Start Game")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.3))
                    )
            }
            .padding(.horizontal, 30)

            // Back to Menu button
            Button(action: {
                viewModel.resetToMenu()
            }) {
                Text("Back to Menu")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 15)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - First Gesture View

    private var firstGestureView: some View {
        VStack(spacing: 40) {
            Text("\(player1Name): Create First Gesture")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 80)

            Spacer()

            // Show gesture animation if performed, otherwise show instruction
            if showGestureAnimation, let gesture = animatedGesture {
                ArrowView(gesture: gesture, isAnimating: true)
                    .transition(.scale.combined(with: .opacity))
            } else {
                VStack(spacing: 20) {
                    Text("Perform any gesture to start the chain!")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Gesture hint
                    Text("↑ ↓ ← → ⊙ ◎ ⏺")
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()
        }
    }

    // MARK: - Repeat Phase View

    private var repeatPhaseView: some View {
        VStack(spacing: 30) {
            // Current player indicator - changes based on mode
            Text(isAddingGesture ? "\(currentPlayerName): Now Add Gesture #\(sequence.count + 1)!" : "\(currentPlayerName): Repeat the Chain")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 80)

            Text("Round \(currentRound)")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity)

            Spacer()

            // Countdown timer
            CountdownRing(
                totalTime: perGestureTime,
                timeRemaining: $timeRemaining
            )

            // Progress indicator - changes based on mode
            if isAddingGesture {
                Text("Add your gesture")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 20)
            } else if currentGestureIndex < sequence.count {
                Text("Gesture \(currentGestureIndex + 1) of \(sequence.count)")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 20)
            }

            Spacer()

            // Progress dots - shows extra dot when in adding mode
            HStack(spacing: 10) {
                let totalDots = isAddingGesture ? sequence.count + 1 : sequence.count
                ForEach(0..<totalDots, id: \.self) { index in
                    Circle()
                        .fill(index < currentGestureIndex ? Color.green : Color.white.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.bottom, 60)
        }
    }

    // MARK: - Add Gesture View

    private var addGestureView: some View {
        VStack(spacing: 40) {
            Text("\(currentPlayerName): Add Your Gesture!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 80)

            Spacer()

            // Show gesture animation if just added, otherwise show instruction
            if showGestureAnimation, let gesture = animatedGesture {
                ArrowView(gesture: gesture, isAnimating: true)
                    .transition(.scale.combined(with: .opacity))
            } else {
                VStack(spacing: 20) {
                    Text("Perform any gesture to extend the chain")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Current sequence length
                    Text("Current Chain: \(sequence.count) gestures")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))

                    // Gesture hint
                    Text("↑ ↓ ← → ⊙ ◎ ⏺")
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()
        }
    }

    // MARK: - Results View

    private var resultsView: some View {
        VStack(spacing: 40) {
            Text("Game Over!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 60)

            Spacer()

            // Winner announcement
            VStack(spacing: 20) {
                if let winner = winner {
                    Text("\(winner)")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)

                    Text("Wins!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                } else {
                    Text("Draw!")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                }

                Text("Round: \(currentRound)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 10)

                Text("Chain Length: \(sequence.count)")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            // Stats
            VStack(spacing: 15) {
                Text("Session Best: \(longestSequence)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 30) {
                    VStack(spacing: 5) {
                        Text("\(player1Name)")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(player1Wins) Wins")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    VStack(spacing: 5) {
                        Text("\(player2Name)")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(player2Wins) Wins")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.top, 10)
            }

            Spacer()

            VStack(spacing: 20) {
                // Play Again button
                Button(action: playAgain) {
                    Text("Play Again")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.3))
                        )
                }
                .padding(.horizontal, 30)

                // Back to Menu button
                Button(action: {
                    viewModel.resetToMenu()
                }) {
                    Text("Back to Menu")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 15)
                }
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Game Logic

    private var currentPlayerName: String {
        currentPlayer == 1 ? player1Name : player2Name
    }

    // Unified gesture handler - routes to appropriate phase handler
    private func handleGesture(_ gesture: GestureType) {
        switch gamePhase {
        case .firstGesture:
            handleFirstGesture(gesture)
        case .repeatPhase:
            handleRepeatGesture(gesture)  // Now handles both repeat and add
        case .addGesture:
            handleAddGesture(gesture)  // Only used for Round 1 Player 1
        default:
            break  // Ignore gestures in nameEntry/results
        }
    }

    private func startGame() {
        // Load stats
        longestSequence = PersistenceManager.shared.loadPvPLongestSequence()
        player1Wins = PersistenceManager.shared.loadPvPPlayer1Wins()
        player2Wins = PersistenceManager.shared.loadPvPPlayer2Wins()

        // Reset game state
        sequence = []
        currentRound = 1
        currentPlayer = 1
        gameOver = false
        winner = nil
        showGestureAnimation = false
        animatedGesture = nil

        // Player 1 creates first gesture
        gamePhase = .firstGesture
    }

    private func handleFirstGesture(_ gesture: GestureType) {
        guard gamePhase == .firstGesture && !showGestureAnimation else { return }

        // Add gesture to sequence
        sequence.append(gesture)
        HapticManager.shared.impact()

        // Show success flash
        flashColor = .green
        withAnimation(.easeInOut(duration: 0.3)) {
            flashColor = .clear
        }

        // Show the gesture animation immediately
        animatedGesture = gesture
        withAnimation {
            showGestureAnimation = true
        }

        // Wait for animation, then transition to Player 2's turn
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showGestureAnimation = false
            animatedGesture = nil
            currentPlayer = 2
            perGestureTime = calculatePerGestureTime(round: currentRound)
            startRepeatPhase()
        }
    }

    private func startRepeatPhase() {
        currentGestureIndex = 0
        userBuffer = []
        timeRemaining = perGestureTime
        isAddingGesture = false  // Reset adding mode
        gamePhase = .repeatPhase
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                handleTimeout()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func handleRepeatGesture(_ gesture: GestureType) {
        guard gamePhase == .repeatPhase else { return }

        if !isAddingGesture {
            // Still repeating sequence
            if currentGestureIndex < sequence.count && sequence[currentGestureIndex] == gesture {
                // Correct gesture
                userBuffer.append(gesture)
                currentGestureIndex += 1
                HapticManager.shared.impact()

                if currentGestureIndex >= sequence.count {
                    // Player completed repeat - transition to add mode
                    stopTimer()
                    showSuccessAndTransitionToAdd()
                } else {
                    // Reset timer for next gesture
                    timeRemaining = perGestureTime
                }
            } else {
                // Wrong gesture - immediate loss
                handleWrongGesture()
            }
        } else {
            // Player is adding new gesture
            sequence.append(gesture)
            currentGestureIndex += 1
            HapticManager.shared.impact()

            // Immediately exit adding mode to prevent title flash
            isAddingGesture = false

            // Update session best if needed
            if sequence.count > longestSequence {
                longestSequence = sequence.count
                PersistenceManager.shared.savePvPLongestSequence(longestSequence)
            }

            // Show success and switch player
            stopTimer()
            showSuccessAndSwitchPlayer()
        }
    }

    private func showSuccessAndTransitionToAdd() {
        flashColor = .green
        HapticManager.shared.success()

        withAnimation(.easeInOut(duration: 0.3)) {
            flashColor = .clear
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Player 2 NEVER adds - only Player 1 builds the sequence
            if currentPlayer == 2 {
                switchToNextPlayer()
            } else {
                // Player 1: Transition to adding mode (stay on repeat screen)
                isAddingGesture = true
                timeRemaining = perGestureTime
                startTimer()
            }
        }
    }

    private func showSuccessAndSwitchPlayer() {
        flashColor = .green
        HapticManager.shared.success()

        withAnimation(.easeInOut(duration: 0.3)) {
            flashColor = .clear
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            switchToNextPlayer()
        }
    }

    private func handleAddGesture(_ gesture: GestureType) {
        guard gamePhase == .addGesture && !showGestureAnimation else { return }

        // Add gesture to sequence
        sequence.append(gesture)
        HapticManager.shared.impact()

        // Show success flash
        flashColor = .green
        withAnimation(.easeInOut(duration: 0.3)) {
            flashColor = .clear
        }

        // Update session best if needed
        if sequence.count > longestSequence {
            longestSequence = sequence.count
            PersistenceManager.shared.savePvPLongestSequence(longestSequence)
        }

        // Show the gesture animation immediately
        animatedGesture = gesture
        withAnimation {
            showGestureAnimation = true
        }

        // Wait for animation, then switch to other player
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showGestureAnimation = false
            animatedGesture = nil
            switchToNextPlayer()
        }
    }

    private func switchToNextPlayer() {
        currentPlayer = currentPlayer == 1 ? 2 : 1

        // Only increment round when completing a full cycle (P2 → P1)
        if currentPlayer == 1 {
            currentRound += 1
        }

        // Update difficulty
        perGestureTime = calculatePerGestureTime(round: currentRound)

        // Go directly to repeat phase (skip watch sequence)
        startRepeatPhase()
    }

    private func handleWrongGesture() {
        stopTimer()

        // Other player wins
        winner = currentPlayer == 1 ? player2Name : player1Name
        updateWinStats(winningPlayer: currentPlayer == 1 ? 2 : 1)

        // Show error flash and failure feedback
        flashColor = .red
        FailureFeedbackManager.shared.playFailureFeedback()

        withAnimation(.easeInOut(duration: 0.3)) {
            flashColor = .clear
        }

        // Show results
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            gameOver = true
            gamePhase = .results
        }
    }

    private func handleTimeout() {
        stopTimer()

        // Other player wins
        winner = currentPlayer == 1 ? player2Name : player1Name
        updateWinStats(winningPlayer: currentPlayer == 1 ? 2 : 1)

        // Show error flash and failure feedback
        flashColor = .red
        FailureFeedbackManager.shared.playFailureFeedback()

        withAnimation(.easeInOut(duration: 0.3)) {
            flashColor = .clear
        }

        // Show results
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            gameOver = true
            gamePhase = .results
        }
    }

    private func updateWinStats(winningPlayer: Int) {
        if winningPlayer == 1 {
            player1Wins += 1
            PersistenceManager.shared.savePvPPlayer1Wins(player1Wins)
        } else {
            player2Wins += 1
            PersistenceManager.shared.savePvPPlayer2Wins(player2Wins)
        }
    }

    private func calculatePerGestureTime(round: Int) -> TimeInterval {
        let baseTime: TimeInterval = 3.0
        let reduction = TimeInterval(round / 3) * 0.2
        let minTime: TimeInterval = 1.5
        return max(baseTime - reduction, minTime)
    }

    private func playAgain() {
        gamePhase = .nameEntry
        sequence = []
        currentRound = 0
        currentPlayer = 1
        gameOver = false
        winner = nil
        currentGestureIndex = 0
        userBuffer = []
        showGestureAnimation = false
        animatedGesture = nil
        stopTimer()
    }
}
