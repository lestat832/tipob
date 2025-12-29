import SwiftUI

struct GameVsPlayerVsPlayerView: View {
    @ObservedObject var viewModel: GameViewModel
    @AppStorage("discreetModeEnabled") private var discreetModeEnabled = false

    // Game phases
    @State private var gamePhase: PvPGamePhase = .nameEntry

    // Player info
    @State private var player1Name: String = "Player 1"
    @State private var player2Name: String = "Player 2"

    // Game state
    @State private var sequence: [GestureType] = []
    @State private var currentRound: Int = 0
    @State private var currentPlayer: Int = 1
    @State private var player1Result: Bool? = nil
    @State private var player2Result: Bool? = nil
    @State private var winner: String? = nil
    @State private var gameOver: Bool = false

    // Gesture tracking
    @State private var currentGestureIndex: Int = 0
    @State private var userBuffer: [GestureType] = []
    @State private var showingSequence: Bool = false
    @State private var showingGestureIndex: Int = 0

    // Timing
    @State private var timeRemaining: TimeInterval = 3.0
    @State private var perGestureTime: TimeInterval = 3.0
    @State private var timer: Timer? = nil

    // Visual feedback
    @State private var flashColor: Color = .clear

    // Track which player should go next after sequence
    @State private var nextPlayer: Int = 1

    // Leaderboard
    @State private var isNewHighScore: Bool = false
    @State private var showingLeaderboard: Bool = false

    // Dev panel
    #if DEBUG || TESTFLIGHT
    @State private var showDevPanel: Bool = false
    #endif

    enum PvPGamePhase {
        case nameEntry
        case watchSequence
        case playerTurn
        case results
    }

    var body: some View {
        ZStack {
            // Background gradient
            Color.toyBoxMenuGradient
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
                case .watchSequence:
                    watchSequenceView
                case .playerTurn:
                    playerTurnView
                case .results:
                    resultsView
                }
            }
        }
        .onAppear {
            // Auto-start game if coming from "Play Again" countdown
            if viewModel.shouldAutoStartGameVsPvP {
                viewModel.shouldAutoStartGameVsPvP = false
                startGame()  // Bypass name entry, go straight to gameplay
            }
        }
    }

    // MARK: - Name Entry View

    private var nameEntryView: some View {
        VStack(spacing: 40) {
            Text("Pass & Play")
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

    // MARK: - Watch Sequence View

    private var watchSequenceView: some View {
        VStack(spacing: 40) {
            // Player turn indicator
            Text("\(nextPlayerName)'s Turn Up Next!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
                .padding(.top, 60)

            Text("Watch the Sequence!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 10)

            Text("Round \(currentRound)")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))

            Spacer()

            // Gesture display (conditionally render Stroop or ArrowView)
            if showingGestureIndex < sequence.count {
                let currentGesture = sequence[showingGestureIndex]
                if case .stroop(let wordColor, let textColor, let upColor, let downColor, let leftColor, let rightColor) = currentGesture {
                    StroopPromptView(
                        wordColor: wordColor,
                        textColor: textColor,
                        upColor: upColor,
                        downColor: downColor,
                        leftColor: leftColor,
                        rightColor: rightColor,
                        isAnimating: true,
                        showHelperText: UserSettings.showGestureNames
                    )
                    .id(showingGestureIndex)
                } else {
                    ArrowView(
                        gesture: currentGesture,
                        isAnimating: true,
                        showHelperText: UserSettings.showGestureNames
                    )
                    .id(showingGestureIndex)
                }
            }

            Spacer()

            // Progress dots
            HStack(spacing: 10) {
                ForEach(0..<sequence.count, id: \.self) { index in
                    Circle()
                        .fill(index < showingGestureIndex ? Color.green : Color.white.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.bottom, 60)
        }
    }

    // MARK: - Player Turn View

    private var playerTurnView: some View {
        VStack(spacing: 30) {
            // Current player indicator
            Text("\(currentPlayerName)'s Turn")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
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
            .allowsHitTesting(false)

            // Progress indicator
            if currentGestureIndex < sequence.count {
                Text("Gesture \(currentGestureIndex + 1) of \(sequence.count)")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 20)
            }

            Spacer()

            // Progress dots
            HStack(spacing: 10) {
                ForEach(0..<sequence.count, id: \.self) { index in
                    Circle()
                        .fill(index < currentGestureIndex ? Color.green : Color.white.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .detectSwipes { gesture in
            handleGesture(gesture)
        }
        .detectTaps { gesture in
            handleGesture(gesture)
        }
        .detectPinch(
            onPinch: { handleGesture(.pinch) }
        )
    }

    // MARK: - Results View

    private var resultsView: some View {
        VStack(spacing: 0) {
            // High Score Banner (if new high score) - NOT a header
            if isNewHighScore {
                VStack(spacing: 8) {
                    Image("icon_trophy_default")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 56, height: 56)

                    Text("NEW HIGH SCORE!")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                        .shadow(color: .orange, radius: 8)
                }
                .padding(.top, 60)
            }

            Spacer()

            // HERO - Winner announcement (no "Game Over!" header)
            VStack(spacing: 20) {
                if let winner = winner {
                    Text("\(winner) Wins!")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Draw!")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                }

                // Stat line: Round
                Text("Round: \(currentRound)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }

            Spacer()

            VStack(spacing: 20) {
                // Play Again button
                Button(action: {
                    // Log replay_game analytics
                    AnalyticsManager.shared.logReplayGame(mode: .gameVsPlayerVsPlayer, discreetMode: viewModel.discreetModeEnabled)

                    // Check if we should show an ad (Play Again trigger)
                    if AdManager.shared.shouldShowInterstitial(trigger: .playAgain, runDuration: viewModel.lastRunDuration) {
                        // Get top view controller and show ad
                        if let viewController = UIApplication.topViewController() {
                            // Prepare countdown BEFORE showing ad (hides Game Over screen immediately)
                            viewModel.prepareForCountdown()

                            AdManager.shared.showInterstitialAd(from: viewController) {
                                // After ad dismisses, begin countdown then start new game
                                viewModel.beginCountdown {
                                    viewModel.shouldAutoStartGameVsPvP = true  // Flag for auto-start on view appear
                                    viewModel.startGameVsPlayerVsPlayer(isReplay: true)
                                    // Note: startGame() is called via .onAppear since view gets recreated
                                }
                            }
                        } else {
                            // No view controller - start game immediately (no ad shown)
                            playAgain()
                        }
                    } else {
                        // No ad - start game immediately
                        playAgain()
                    }
                }) {
                    HStack {
                        Image("icon_repeat_default")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 40, height: 40)
                            .padding(.vertical, -12)
                        Text("Play Again")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.green)
                    )
                }
                .padding(.horizontal, 30)

                // Secondary CTAs (equal width)
                HStack(spacing: 15) {
                    // Back to Menu button
                    Button(action: {
                        // Show ad if available, then go home (Home trigger)
                        if AdManager.shared.shouldShowInterstitial(trigger: .home, runDuration: 0) {
                            if let viewController = UIApplication.topViewController() {
                                AdManager.shared.showInterstitialAd(from: viewController) {
                                    viewModel.resetToMenu()
                                }
                            } else {
                                viewModel.resetToMenu()
                            }
                        } else {
                            viewModel.resetToMenu()
                        }
                    }) {
                        HStack {
                            Image("icon_home_default")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 40, height: 40)
                                .padding(.vertical, -12)
                            Text("Home")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                        )
                    }

                    // Leaderboard button
                    Button(action: {
                        showingLeaderboard = true
                    }) {
                        HStack {
                            Image("icon_trophy_default")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 40, height: 40)
                                .padding(.vertical, -12)
                            Text("High Scores")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showingLeaderboard) {
            LeaderboardView()
        }
        #if DEBUG || TESTFLIGHT
        .sheet(isPresented: $showDevPanel) {
            DevPanelView(viewModel: viewModel)
        }
        #endif
        .overlay(alignment: .topTrailing) {
            #if DEBUG || TESTFLIGHT
            Button(action: {
                HapticManager.shared.impact()
                showDevPanel = true
            }) {
                Image("icon_settings_default")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 56, height: 56)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .padding(8)
            }
            #endif
        }
        .onAppear {
            // Increment game count when results appear
            AdManager.shared.incrementGameCount()
        }
    }

    // MARK: - Game Logic

    private var currentPlayerName: String {
        currentPlayer == 1 ? player1Name : player2Name
    }

    private var nextPlayerName: String {
        nextPlayer == 1 ? player1Name : player2Name
    }

    private func startGame() {
        // Reset everything
        sequence = []
        currentRound = 0
        player1Result = nil
        player2Result = nil
        winner = nil
        gameOver = false

        // Start first round
        startNewRound()
    }

    private func startNewRound() {
        currentRound += 1

        // Get appropriate gesture pool based on discreet mode (excludes Stroop for Game vs PvP)
        let gesturePool = GesturePoolManager.gesturesWithoutStroop(discreetMode: discreetModeEnabled)
        let newGesture = gesturePool.randomElement() ?? .up
        sequence.append(newGesture)

        // Reset player results
        player1Result = nil
        player2Result = nil

        // Calculate difficulty
        perGestureTime = calculatePerGestureTime(round: currentRound)

        // Player 1 always goes first in a new round
        nextPlayer = 1

        // Show sequence
        showSequenceToPlayers()
    }

    private func calculatePerGestureTime(round: Int) -> TimeInterval {
        let baseTime: TimeInterval = 3.0
        let reduction = TimeInterval(round / 3) * 0.3
        let minTime: TimeInterval = 1.5
        return max(baseTime - reduction, minTime)
    }

    private func showSequenceToPlayers() {
        gamePhase = .watchSequence
        showingGestureIndex = 0

        // Deactivate motion detector during sequence playback to prevent false failures
        MotionGestureManager.shared.deactivateAllDetectors()

        // Add initial delay so players can read "Watch the Sequence!" message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showGesturesRecursively()
        }
    }

    private func showGesturesRecursively() {
        guard showingGestureIndex < sequence.count else {
            // Sequence complete, start the next player's turn
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startPlayerTurn(player: nextPlayer)
            }
            return
        }

        let displayDuration = GameConfiguration.sequenceShowDuration + GameConfiguration.sequenceGapDuration

        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
            showingGestureIndex += 1
            showGesturesRecursively()
        }
    }

    private func startPlayerTurn(player: Int) {
        currentPlayer = player
        currentGestureIndex = 0
        userBuffer = []
        timeRemaining = perGestureTime
        gamePhase = .playerTurn

        #if DEBUG || TESTFLIGHT
        // Apply grace period if transitioning from motion to touch gesture
        if currentGestureIndex < sequence.count {
            let currentGesture = sequence[currentGestureIndex]
            if !currentGesture.isMotionGesture && MotionGestureManager.shared.lastDetectedWasMotion {
                let gracePeriod = DevConfigManager.shared.motionToTouchGracePeriod
                timeRemaining += gracePeriod
                print("[\(Date().logTimestamp)] ⏱️ Grace period applied: +\(String(format: "%.1f", gracePeriod))s for motion→touch transition (Game vs PvP - start turn)")
            }
        }
        #endif

        // Activate motion detector for first expected gesture
        activateGameVsPvPDetector()

        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            timeRemaining -= 0.1
            if timeRemaining <= 0 {
                #if DEBUG || TESTFLIGHT
                // Log timeout as failure (no gesture detected in time)
                if currentGestureIndex < sequence.count {
                    let expectedGesture = sequence[currentGestureIndex]
                    DevConfigManager.shared.logGesture(expected: expectedGesture, detected: nil, success: false)
                }
                #endif
                recordPlayerFailure()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func handleGesture(_ gesture: GestureType) {
        #if DEBUG || TESTFLIGHT
        print("""
        🎮 GvPvP GESTURE INPUT:
           gesture: \(gesture.displayName)
           gamePhase: \(gamePhase)
           currentPlayer: \(currentPlayer)
           currentGestureIndex: \(currentGestureIndex)
           sequence.count: \(sequence.count)
           expectedGesture: \(currentGestureIndex < sequence.count ? sequence[currentGestureIndex].displayName : "none")
        """)
        #endif

        guard gamePhase == .playerTurn else {
            #if DEBUG || TESTFLIGHT
            print("❌ REJECTED: gamePhase != .playerTurn")
            #endif
            return
        }

        if currentGestureIndex < sequence.count && isGestureCorrect(gesture, expected: sequence[currentGestureIndex]) {
            // Correct gesture
            #if DEBUG || TESTFLIGHT
            let expectedGesture = sequence[currentGestureIndex]
            DevConfigManager.shared.logGesture(expected: expectedGesture, detected: gesture, success: true)
            #endif

            userBuffer.append(gesture)
            currentGestureIndex += 1
            HapticManager.shared.impact()

            if currentGestureIndex >= sequence.count {
                // Player completed sequence successfully
                recordPlayerSuccess()
            } else {
                // Move to next gesture - update detector for next expected gesture
                activateGameVsPvPDetector()
                timeRemaining = perGestureTime

                #if DEBUG || TESTFLIGHT
                // Apply grace period if transitioning from motion to touch gesture
                if currentGestureIndex < sequence.count {
                    let currentGesture = sequence[currentGestureIndex]
                    if !currentGesture.isMotionGesture && MotionGestureManager.shared.lastDetectedWasMotion {
                        let gracePeriod = DevConfigManager.shared.motionToTouchGracePeriod
                        timeRemaining += gracePeriod
                        print("[\(Date().logTimestamp)] ⏱️ Grace period applied: +\(String(format: "%.1f", gracePeriod))s for motion→touch transition (Game vs PvP - next gesture)")
                    }
                }
                #endif
            }
        } else {
            // Wrong gesture
            #if DEBUG || TESTFLIGHT
            if currentGestureIndex < sequence.count {
                let expectedGesture = sequence[currentGestureIndex]
                DevConfigManager.shared.logGesture(expected: expectedGesture, detected: gesture, success: false)
            }
            #endif
            recordPlayerFailure()
        }
    }

    /// Validates if a gesture matches the expected gesture, handling Stroop special logic
    private func isGestureCorrect(_ userGesture: GestureType, expected: GestureType) -> Bool {
        // For Stroop gestures: find which direction the text color is assigned to
        if case .stroop(_, let textColor, let upColor, let downColor, let leftColor, let rightColor) = expected {
            // Find which direction has the text color and check if user swiped that way
            if textColor == upColor {
                return userGesture == .up
            } else if textColor == downColor {
                return userGesture == .down
            } else if textColor == leftColor {
                return userGesture == .left
            } else if textColor == rightColor {
                return userGesture == .right
            }
            return false
        }

        // For all other gestures: direct equality check
        return userGesture == expected
    }

    private func recordPlayerSuccess() {
        // Guard: Only record success during player turn
        guard gamePhase == .playerTurn else { return }

        stopTimer()

        if currentPlayer == 1 {
            player1Result = true
        } else {
            player2Result = true
        }

        flashColor = .green
        HapticManager.shared.success()

        withAnimation(.easeInOut(duration: GameConfiguration.flashAnimationDuration)) {
            flashColor = .clear
        }

        if currentPlayer == 1 {
            // Player 1 succeeded, show sequence again for Player 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                nextPlayer = 2
                showSequenceToPlayers()
            }
        } else {
            // Player 2 finished, evaluate round
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                evaluateRound()
            }
        }
    }

    private func recordPlayerFailure() {
        // Guard: Only record failure during player turn (prevents false failures during sequence playback)
        guard gamePhase == .playerTurn else {
            #if DEBUG || TESTFLIGHT
            print("⚠️ recordPlayerFailure() ignored - not in playerTurn phase (current: \(gamePhase))")
            #endif
            return
        }

        stopTimer()

        if currentPlayer == 1 {
            player1Result = false
        } else {
            player2Result = false
        }

        flashColor = .red
        FailureFeedbackManager.shared.playFailureFeedback()

        withAnimation(.easeInOut(duration: GameConfiguration.flashAnimationDuration)) {
            flashColor = .clear
        }

        if currentPlayer == 1 {
            // Player 1 failed, show sequence again for Player 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                nextPlayer = 2
                showSequenceToPlayers()
            }
        } else {
            // Player 2 finished, evaluate
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                evaluateRound()
            }
        }
    }

    private func evaluateRound() {
        if player1Result == true && player2Result == true {
            // Both passed, continue to next round
            startNewRound()
        } else {
            // Game ends - someone failed
            // Calculate final score (Game vs PvP uses currentRound)
            let finalScore = currentRound

            // Log end_game BEFORE leaderboard updates
            let durationSec = Int(Date().timeIntervalSince(viewModel.gameStartTime ?? Date()))

            // Determine ended_by based on who failed
            let endReason: String
            if player1Result == false && player2Result == false {
                endReason = "wrong_gesture"  // Both failed (draw)
            } else {
                endReason = "opponent_win"  // One player won, one lost
            }

            AnalyticsManager.shared.logEndGame(
                mode: .gameVsPlayerVsPlayer,
                score: finalScore,
                bestScore: LeaderboardManager.shared.getHighScore(for: .gameVsPlayerVsPlayer),
                durationSec: durationSec,
                endedBy: endReason,
                discreetMode: viewModel.discreetModeEnabled
            )
            // Save run duration for ad gating before clearing
            viewModel.lastRunDuration = Date().timeIntervalSince(viewModel.gameStartTime ?? Date())
            viewModel.gameStartTime = nil

            // Check if new high score and add to leaderboard
            isNewHighScore = LeaderboardManager.shared.isNewHighScore(finalScore, mode: .gameVsPlayerVsPlayer)
            LeaderboardManager.shared.addScore(finalScore, for: .gameVsPlayerVsPlayer)

            if player1Result == false && player2Result == false {
                // Both failed, it's a draw
                winner = nil
                gameOver = true
                gamePhase = .results
            } else if player1Result == true && player2Result == false {
                // Player 1 wins
                winner = player1Name
                gameOver = true
                gamePhase = .results
            } else if player1Result == false && player2Result == true {
                // Player 2 wins
                winner = player2Name
                gameOver = true
                gamePhase = .results
            }
        }
    }

    private func playAgain() {
        gamePhase = .nameEntry
        sequence = []
        currentRound = 0
        player1Result = nil
        player2Result = nil
        winner = nil
        gameOver = false
        isNewHighScore = false
        currentGestureIndex = 0
        userBuffer = []
        showingSequence = false
        showingGestureIndex = 0
        stopTimer()
    }

    // MARK: - Motion Gesture Integration

    private func activateGameVsPvPDetector() {
        // Get current expected gesture from sequence
        guard currentGestureIndex < sequence.count else { return }
        let expectedGesture = sequence[currentGestureIndex]

        // Activate motion detector if motion gesture expected
        if expectedGesture.isMotionGesture {
            MotionGestureManager.shared.activateDetector(
                for: expectedGesture,
                onDetected: {
                    self.handleGesture(expectedGesture)
                },
                onWrongGesture: {
                    // Guard: Only fail if still in player turn (prevents false failures during sequence playback)
                    guard self.gamePhase == .playerTurn else { return }
                    self.recordPlayerFailure()
                }
            )
        } else {
            // Touch gesture expected - deactivate motion detectors
            MotionGestureManager.shared.deactivateAllDetectors()
        }
    }
}
