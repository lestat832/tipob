OUT OF POCKET - PRODUCT OVERVIEW

Last Updated: December 29, 2025
Version: 3.8
Status: Phase 1 Complete - 14 Gestures + Performance Optimized + AdMob Production + Audio System + Firebase Analytics + Settings Screen + Unified End Cards + Ad Gating

========================================

PRODUCT OVERVIEW

Product Description
Fast-paced mobile gesture game for iOS
Tests players' reflexes, memory, and cognitive flexibility
Players respond using 14 gestures: swipes, taps, motion gestures, and Stroop cognitive challenges
Includes Discreet Mode for public/private gesture sets

Core Value Proposition
Simple to Learn: Intuitive gesture controls anyone can pick up
Hard to Master: Progressive difficulty keeps players engaged
14 Diverse Gestures: Touch, motion, and cognitive challenges
Discreet Mode: Toggle between public-friendly vs full gesture set
Performance Optimized: 20-30% faster gesture response (Nov 2025)
Audio Feedback: Success ticks, round complete chimes, and failure sounds
Monetization Ready: Google AdMob integration with PRODUCTION credentials (awaiting ad fill)
Triple Game Modes: Three distinct gameplay experiences (Classic, Memory, and PvP)
Visual Polish: Beautiful gradient UI with color-coded gestures

Target Audience
Casual mobile gamers looking for quick play sessions
Players who enjoy reflex-based challenges
Fans of Bop-It, Simon Says, and similar reaction games
Groups looking for pass-and-play competitive games

========================================

GAME MODES

Classic Mode (DEFAULT)
Genre: Reflex/Reaction Game (Bop-It style)
Icon: Lightning bolt ⚡
Status: Complete

Gameplay:
- Game shows a random gesture prompt
- Player must perform that gesture before time runs out
- Each successful gesture generates a new random prompt
- Speed increases progressively as player succeeds

Progression System:
- Starting Speed: 3.0 seconds per gesture
- Speed Increase: Every 3 successful gestures
- Speed Reduction: -0.2 seconds per increase
- Minimum Speed: 1.5 seconds (hard cap, allows Long Press completion)

Scoring:
- Points awarded: 1 point per successful gesture
- Game Over: Wrong gesture OR timeout
- High Score: Best score persisted locally

Visual Design:
- Purple/blue gradient background
- Large color-coded gesture arrows
- Countdown ring showing time remaining
- Real-time score display
- Current reaction time indicator

========================================

Memory Mode
Genre: Memory/Sequence Game (Simon Says style)
Icon: Brain 🧠
Status: Complete (Implemented October 20, 2025)

Gameplay:
- Game shows a sequence of gestures (starts with 1)
- Player must memorize the sequence
- Player repeats the entire sequence from memory
- Sequence grows by 1 gesture each round

Progression System:
- Round 1: 1 gesture
- Round 2: 2 gestures
- Round 3: 3 gestures
- Continues until player fails

Scoring:
- Rounds completed (streak): Number of successful rounds
- Game Over: Wrong gesture in sequence OR timeout
- Best Streak: Longest streak persisted locally

Timing:
- 3.0 seconds per gesture to input
- Timer resets after each correct gesture in sequence

Gesture Buffer (Implemented December 2025):
- Prevents missed inputs during sequence→input transition
- Captures gestures during 0.3-0.5s transition delay
- Immediate haptic feedback when gesture is buffered
- Buffered gesture replays automatically when entering awaitInput state
- Implementation: pendingGesture tracking in GameViewModel

Visual Design:
- Purple/blue gradient background
- Animated gesture display during sequence showing
- Color-coded gesture arrows
- Round counter
- "Watch the sequence" instruction
- Visual feedback after sequence completion

========================================

Game vs Player vs Player Mode (Pass & Play)
Genre: Competitive Pass-and-Play
Icon: Two people 👥
Status: Complete (Implemented October 20, 2025, Enhanced December 2025)

Gameplay:
- 2-player competitive mode
- Players take turns on the same device
- Fair sequence replay (both players see identical gestures)
- Game ends when either player fails

Features:
- Alternating turns with clear player identification
- Individual score tracking for each player
- Fair gameplay with consistent sequence replay
- Winner determined by highest score
- Player indicators: "Player 1's Turn" / "Player 2's Turn"

Gesture Drawer System (Implemented December 2025):
- Slide-up drawer for gesture selection in PvP modes
- Category-grouped gestures (Touch, Motion, Cognitive)
- Respects Discreet Mode filtering
- Randomized playful header titles ("Pick Your Poison", "Your Move", etc.)
- 50% screen height with swipe-to-dismiss
- Pulsing animation on tab for first 2 appearances
- Files: GestureDrawerView.swift, GestureDrawerTabView.swift

Auto-Start Bypass (Implemented December 2025):
- Skips name entry on "Play Again" replay
- shouldAutoStartGameVsPvP and shouldAutoStartPvP flags in GameViewModel
- Enables seamless rapid rematches without re-entering player names
- Countdown timer (3, 2, 1, START) leads directly into gameplay

Scoring:
- Points awarded per successful gesture
- Scores tracked separately for each player
- Winner announcement at game over

Visual Design:
- Player turn indicators
- Individual score displays
- Same visual polish as other modes
- Winner celebration screen
- Unified End Card with trophy banner for new high scores

========================================

Tutorial Mode
Purpose: Onboarding for first-time players
Icon: Graduation cap
Status: Implemented

Flow:
- Introduction screen explaining game concept
- Gesture training for each gesture type
- Practice rounds with guidance
- Completion celebration

========================================

Future Modes (Planned)
Endless Mode ⚡: Progressive speed increase with no upper limit
Zen Mode: Practice mode with relaxed timing
Additional Multiplayer Variations: Extended PvP features

========================================

STROOP MODE (Cognitive Challenge)

Integration: Embedded within all 4 game modes
Probability: 1/14 chance per gesture prompt
Status: Complete (Implemented October 31, 2025)

How It Works:
1. Display color word (RED, BLUE, GREEN, YELLOW) in mismatched text color
2. Show 4 directional color labels around screen (↑ Blue, ↓ Green, ← Red, → Yellow)
3. Player must swipe in direction matching the TEXT color, NOT the word name
4. Tests cognitive flexibility and Stroop effect resistance

Example:
- Word displayed: "RED" in BLUE text
- Correct response: Swipe UP (toward Blue label)
- Incorrect: Swipe LEFT (toward Red label, reading the word)

Color System:
- ColorType enum: red, blue, green, yellow
- Random color-to-direction mapping each instance
- Arrow colors match directional labels for clarity

Visual Design:
- Large centered color word
- Four corner color labels with arrows
- Symmetrical layout (all 4 sides consistent)
- StroopPromptView.swift (~350 lines)

Testing Notes:
- Fixed alignment issues (commit 0c1bc76)
- Consistent arrow→label ordering across all directions
- Integrated into Tutorial, Classic, Memory, PvP modes

========================================

DISCREET MODE SYSTEM

Purpose: Social Context Adaptability
Status: Complete (Implemented November 3, 2025)

Concept:
Allow players to choose gesture set based on environment:
- Public spaces: Discreet mode (no vigorous motion)
- Private spaces: Unhinged mode (full experience)

Gesture Sets:

Discreet Mode (9 gestures):
- 4 Swipes: Up, Down, Left, Right
- 3 Taps: Tap, Double Tap, Long Press
- 1 Pinch: Two-finger pinch
- 1 Stroop: Cognitive challenge
(Excludes: Shake, Tilt, Raise, Lower)

Unhinged Mode (14 gestures):
- All 9 Discreet gestures
- Plus: Shake, Tilt Left, Tilt Right, Raise, Lower

Implementation:
- Menu toggle with info icon (ℹ️) explanation
- UserDefaults persistence (key: "isDiscreetModeEnabled")
- GesturePoolManager.swift (~90 lines) for pool management
- Tutorial mode hides toggle (teaches all gestures)

User Flow:
Menu → Toggle Discreet Mode → Start Game → Only selected gestures appear

File: Tipob/Utilities/GesturePoolManager.swift

========================================

LEADERBOARD SYSTEM

Status: Complete MVP (Implemented November 4, 2025)

Features:
- Top 100 entries per game mode
- Mode-specific leaderboards (Classic, Memory, PvP modes)
- Segmented control to switch between modes
- "NEW HIGH SCORE!" banner on achievement
- Trophy button in menu for quick access

Persistence:
- JSON file storage in Documents directory
- Separate LeaderboardEntry codable structs
- Per-mode UserDefaults keys for best scores

Display:
- Rank, score/streak, date timestamp
- Current session highlighted if in top 100
- Scrollable list with SwiftUI List

Files:
- LeaderboardManager.swift (~260 lines)
- LeaderboardEntry.swift (model)
- LeaderboardView.swift (UI)

Integration:
Accessible from menu via trophy icon (top-right)

========================================

SETTINGS SCREEN

Status: Complete (Implemented December 2025)

Features:
- Gesture Names Toggle: Show/hide helper text below gesture icons (default: ON)
- Sound Effects Toggle: Enable/disable game sounds (default: ON)
- Haptics Toggle: Enable/disable vibration feedback (default: ON)

Implementation:
- SettingsView.swift - SwiftUI settings UI with gradient background
- UserSettings.swift - Persistence layer using UserDefaults
- Real-time toggle updates without restart required

Visual Design:
- Gradient background matching GameModeSheet aesthetic
- SettingToggleRow component for consistent toggle styling
- Icon assets: icon_settings, icon_chat_default, icon_sound_default

Integration:
Accessible from menu via gear icon (top-left)

========================================

FIREBASE ANALYTICS

Status: Complete (Implemented December 2025)

Overview:
Comprehensive event tracking using Firebase Analytics SDK

Events Tracked:

Game Events:
- start_game: Game session begins (includes mode, discreet_mode flag)
- end_game: Game session ends (includes mode, score, duration, endedBy reason)
- replay_game: Player taps "Play Again" button
- tutorial_continue: Player progresses through tutorial

Gesture Events:
- gesture_prompted: Gesture shown to player (includes gesture type)
- gesture_completed: Correct gesture performed (includes reaction_time_ms)
- gesture_failed: Incorrect/timeout (includes fail_reason: "timeout" or "wrong_gesture")

Ad Events:
- ad_requested: Interstitial ad load initiated
- ad_loaded: Ad successfully loaded
- ad_failed_to_load: Ad load failed
- ad_shown: Ad displayed to user
- ad_dismissed: User closed ad

Settings Events:
- discreet_mode_toggled: Discreet mode changed (includes new state)

Implementation:
- File: Tipob/Utilities/AnalyticsManager.swift
- Type-safe event logging with Swift enums
- Mode-specific analytics values (classic, memory, gvpvp, pvp)

========================================

GESTURE VISUAL SYSTEM

Status: Complete (Gesture Pack V2 - December 2025)

Gesture Pack V2 (Image-Based):
- 14 gesture image assets at standardized 56x56 resolution
- Provider: GestureVisualProvider.swift
- Asset location: Tipob/Assets2.xcassets/

Asset List:
- gesture_swipe_up_default, gesture_swipe_down_default
- gesture_swipe_left_default, gesture_swipe_right_default
- gesture_tap_default, gesture_double_tap_default, gesture_long_press_default
- gesture_pinch_default, gesture_shake_default
- gesture_tilt_left_default, gesture_tilt_right_default
- gesture_raise_phone_default, gesture_lower_phone_default

Additional Icon Assets (56x56):
- icon_trophy (leaderboard access)
- icon_settings (settings screen access)
- icon_chat_default (gesture names helper)
- icon_sound_default (sound settings)

Debug Features:
- V1/V2 toggle available in Dev Panel (DEBUG/TESTFLIGHT only)
- V2 enforced in production App Store builds

========================================

POST-AD COUNTDOWN TIMER

Status: Complete (Implemented December 2025)

Purpose:
Provides smooth transition after interstitial ads with "3, 2, 1, START" countdown

Visual Design:
- Full-screen semi-transparent black overlay
- Large centered numbers (120pt) with cyan glow
- "START" text (72pt) with green glow
- Scale and opacity transitions between numbers

Timing:
- Each number displays for 1.0 second
- "START" displays for 0.25 seconds
- Total duration: ~3.25 seconds

Audio/Haptic Integration:
- Tick sound plays on each number (3, 2, 1)
- Impact haptic on each number
- Start sound plays on "START"
- Success haptic on "START"

Implementation:
- CountdownOverlayView.swift - SwiftUI component
- GameViewModel.countdownValue - Current countdown state
- GameViewModel.isCountdownActive - Overlay visibility flag
- Blocks all touch interaction during countdown

Integration Flow:
1. User taps "Play Again" on Game Over screen
2. Ad displays (if available)
3. After ad dismisses: prepareForCountdown() activates black overlay
4. beginCountdown() executes 3, 2, 1, START sequence
5. Auto-start flags set, game begins immediately

========================================

DEV PANEL (DEBUG/TESTFLIGHT ONLY)

Status: Complete (Enhanced December 2025)

Purpose:
Advanced debugging and tuning interface for gesture detection optimization

Availability:
- DEBUG builds: Full access
- TESTFLIGHT builds: Full access (#if DEBUG || TESTFLIGHT)
- App Store builds: Hidden

Features:

Gameplay Logs:
- Records all gesture attempts with timestamps
- Selection/filtering (select all, select failures, clear, invert)
- Issue classification: not_detected, wrong_detection, success

Sequence Replay:
- Stores last Memory/Classic mode sequences
- Replay sequences for debugging and reproduction

Export Functions:
- Export selected issues as JSON
- Auto-generate XCTest code from failed gestures
- Share via iOS share sheet

Per-Gesture Testers (GestureTestView.swift):
- Individual gesture test modes with 3-second timeout
- Full sensor capture during test (accelerometer, gyroscope, device motion, touch)
- Records motion/touch data for issue reproduction

Live Threshold Tuning (DevConfigManager.swift):
Adjustable parameters without rebuild:
- Shake: threshold (2.0G), cooldown (0.5s), update interval (50Hz)
- Tilt: angle threshold (0.44 rad/~25°), duration (0.3s), update interval (60Hz)
- Raise/Lower: threshold (0.3G), spike threshold (0.8G), sustained duration (0.1s)
- Swipe: min distance (50px), min velocity (80px/s), edge buffer (24px)
- Tap: double-tap window (350ms), long press (700ms)
- Pinch: strict (0.85), lenient (0.92), velocity threshold (-0.3)
- Intent Locking: Pinch suppresses swipe (150ms), Hold suppresses swipe (700ms)
- One-click reset to production values

Sensor Capture (SensorCaptureBuffer.swift):
- Circular buffer keeping last 30 samples at 60Hz (~500ms)
- Captures: acceleration, gyroscope, device motion, touch phases
- Device context: model, OS version, orientation, battery level, low power mode
- Threshold snapshots at gesture time

Files:
- DevPanelView.swift - Main dev panel UI
- DevConfigManager.swift - Threshold configuration (~200 lines)
- GestureTestView.swift - Per-gesture testers
- SensorCaptureBuffer.swift - Sensor data logging
- DevPanelGestureRecognizer.swift - Dev panel access gesture

========================================

UNIFIED END CARD SYSTEM

Status: Complete (Implemented December 2025)

Purpose:
Consistent game over screen layout across all game modes

Layout Structure:

Top Section (New High Score Banner):
- Trophy icon (56x56) - only if isNewHighScore
- "NEW HIGH SCORE!" text with yellow color and orange shadow

Hero Section (Centered, No "GAME OVER" Header):
- Mode-specific primary display:
  - Classic Mode: "Score: X"
  - Memory Mode: "Round: X"
  - PvP Modes: "PlayerName Wins!" or "Draw!"
- Secondary display: "Best: X" or "Round: X"
- Large 48pt bold text with white color

Action Buttons (Bottom, Equal Width):
- Primary: "Play Again" (green capsule with icon)
- Secondary Row: "Home" + "High Scores" (semi-transparent)

Animations:
- Scale and opacity on view appear
- Spring animation (dampingFraction: 0.6)

Files Modified:
- GameOverView.swift (Classic & Memory modes)
- GameVsPlayerVsPlayerView.swift (Game vs PvP)
- PlayerVsPlayerView.swift (PvP)

========================================

GESTURES & CONTROLS

Supported Gestures (14 Total)

Touch Gestures (7):
- Up ↑ (Blue arrow): Swipe up
- Down ↓ (Green arrow): Swipe down
- Left ← (Red arrow): Swipe left
- Right → (Orange arrow): Swipe right
- Tap ⊙ (Yellow circle): Single tap anywhere
- Double Tap ◎ (Cyan double circle): Two quick taps (300ms window)
- Long Press ⏺ (Magenta filled circle): Press and hold (600ms)

Motion Gestures (6) - Added October 27-29, 2025:
- Pinch 🤏 (Indigo): Two-finger pinch inward (15% reduction)
- Shake 📳 (Teal): Vigorous device shake (2.0G threshold)
- Tilt Left ◀ (Purple): Tilt device left (~25° angle, 300ms sustained)
- Tilt Right ▶ (Brown): Tilt device right (~25° angle, 300ms sustained)
- Raise ⬆️ (Mint): Lift device upward (0.3G threshold, 100ms sustained)
- Lower ⬇️ (Orange): Lower device downward (0.3G threshold, 100ms sustained)

Cognitive Gestures (1) - Added October 31, 2025:
- Stroop 🎨 (Rainbow): Color word in mismatched color + directional swipe
  Example: Word "RED" in BLUE text → Swipe toward Blue label (Up ↑)

Disabled Gestures:
- Spread 🫱🫲: Two-finger spread outward (detection issues, temporarily disabled)

Discreet Mode (Added November 3, 2025):
Toggle between gesture sets for different social contexts:
- Discreet (9 gestures): Touch gestures + Pinch + Stroop (no vigorous motion)
- Unhinged (14 gestures): All gestures including Shake, Tilt, Raise, Lower
Menu toggle with UserDefaults persistence

Gesture Detection Parameters (Optimized November 9, 2025):
- Minimum Swipe Distance: 50 pixels
- Minimum Swipe Velocity: 80 pts/sec (optimized from 100)
- Edge Buffer: 24 pixels
- Double Tap Window: 350ms
- Long Press Duration: 600ms
- Pinch Threshold: 0.85 scale (15% reduction)
- Shake Threshold: 2.0G (optimized from 2.5G)
- Tilt Threshold: 0.44 rad / ~25° (optimized from 0.52 rad / ~30°)
- Raise/Lower Threshold: 0.3G (optimized from 0.4G)
- Sensor Update Rates: 50-60 Hz (optimized from 10-30 Hz)

Motion Gesture System:
- MotionGestureManager: Centralized singleton preventing CMMotionManager conflicts
- Gesture Coordinator: Prevents conflicting gesture false positives
- Activation: One motion detector active at a time
- File: Tipob/Utilities/MotionGestureManager.swift (~650 lines)

Gesture Coexistence:
- Touch gestures use .simultaneousGesture() for conflict-free detection
- Motion gestures use centralized MotionGestureManager
- GestureCoordinator prevents Tutorial mode conflicts (Up/Down ↔ Tilt, etc.)
- Hold intent lock: gives long press priority over swipe (700ms window)
- Pinch intent lock: gives pinch priority over swipe (150ms window)

Haptic Feedback:
- Success: Success haptic
- Failure: Error haptic + unified feedback system
- Button Tap: Impact haptic
- Manager: FailureFeedbackManager with sound + haptic coordination

Audio Feedback (Implemented November 18-20, 2025):
- Success tick: Short 45-70ms tick for correct gestures (AVAudioPlayer)
- Round complete chime: 180-300ms celebration sound (AVAudioPlayer)
- Failure sound: SystemSoundID 1073 (clean, no interference)
- Audio session: .ambient category, .mixWithOthers (doesn't interrupt Spotify)
- Respects silent mode and user sound toggle
- Lazy initialization: AudioManager.initialize() called after launch animation
- Files: gesture_success_tick.caf, round_complete_chime.caf

Performance Optimization (November 9, 2025):
- 20-30% faster gesture response time
- Sensor rates increased 2-5x
- Detection thresholds relaxed 17-25%
- 400 lines of conflicting code removed

========================================

GAME DESIGN PHILOSOPHY & EXPERT FEEDBACK

Source: Video Game Industry Expert (November 2025)
Context: Post-MVP feedback informing v2.0 strategy

Core Design Pillars

1. Fair Failures
Every failure should feel preventable, not random or unfair.
- Clear visual cues before gesture prompts
- Consistent timing windows (no surprise speed changes)
- Generous grace periods for motion gestures
- No hidden mechanics or undiscoverable patterns

2. Satisfying Successes
Every correct gesture should feel rewarding and empowering.
- Triple feedback: haptic + visual + audio
- Progression rewards and visible skill growth
- Celebration moments for milestones
- Multi-sensory confirmation of success

3. "Just One More Try" Loop
Critical Metric: Game over → replay time/taps
- Current: ~2-3 seconds
- Target: <1 second (double tap to instant restart)
- Reference: Endless runners (Temple Run, Subway Surfers)
- Goal: Players always believe they can do better

4. Friction vs. Empowerment Balance
For every challenge, provide a tool or cue:
- 14 gestures (overwhelming) → Tutorial mode
- Increasing speed → Visual countdown ring
- Long sequences → Color-coded gestures
- Cognitive load (Stroop) → Directional labels
- Motion gestures in public → Discreet Mode
- Difficult gestures → Visual feedback bars

Expert Insights

Tuning is Critical:
"Games like this live and die by tuning. It's never quite right the first time — the best ones get there through hundreds of small refinements in timing, feedback, and rhythm."

Impact: Elevates dev panel (Option 3) from nice-to-have to must-have. Without proper tuning infrastructure, shipping a refined experience is impossible.

Sound as Core Gameplay:
"The rhythm between gesture, haptic, and sound should feel tight — like the player is playing an instrument."

Target Latency: <50ms from gesture detection to sound playback
References: Beat Saber, Geometry Dash (satisfying motion-feedback loop)
Philosophy: Make every gesture feel like playing a musical instrument

User Testing Approach:
"Run short user tests, watch where they hesitate, where they laugh, and where they get frustrated. The goal isn't to make the game easier — it's to make every failure feel fair and every success satisfying."

Observation Points:
- Hesitation → unclear mechanics (improve visual cues)
- Laughter → moments of delight (amplify these)
- Frustration → unfair difficulty (fix calibration)

Competitive Analysis

Geometry Dash (Rhythm + Reflexes):
Strengths: Tight rhythm coupling, instant restarts (<0.5s), clear feedback, practice mode, satisfying progression
Lessons: Sound design critical, instant restarts non-negotiable, let players practice individual sections

Beat Saber (VR Rhythm):
Strengths: Physical embodiment, multi-sensory feedback, escalating difficulty, clear visual cues, leaderboards
Lessons: Make gestures feel physical, multi-sensory feedback essential, progressive difficulty, social features matter

Temple Run / Subway Surfers (Endless Runners):
Strengths: Simple controls, perfected "just one more try" loop (<1s restarts), escalating tension, power-ups, meta-progression
Lessons: Fast restarts scientifically proven to drive engagement, consider power-ups and unlocks

Tipob Advantages:
- More variety (14 gestures + 5 modes vs. repetitive endless runners)
- Clear right/wrong feedback (vs. sometimes random deaths)
- Multiple ways to showcase skill (speed modes + leaderboards)

v2.0 Priority Features (Expert-Validated)

P0 - Must-Have:
- Dev panel & tuning infrastructure (30-40 hours)
- Sound design & music (18-24 hours)
- Fast restart loop (<1s target) (4-6 hours)
- User testing & iteration (12-16 hours)

P1 - Strongly Recommended:
- Practice mode (8-12 hours)
- Visual gesture progress bars (6-8 hours)
- Achievement system foundation (10-12 hours)
- Settings menu expansion (8-10 hours)
- Onboarding flow polish (6-8 hours)

P2 - Post-Launch:
- Daily challenges, power-ups, cosmetics, social features, meta-progression

Key Insight:
Shipping v2.0 without P0 features (especially dev panel and sound design) would be premature. The extra 2-3 weeks for tuning infrastructure will pay massive dividends in quality and player satisfaction.

========================================

TECHNICAL ARCHITECTURE

Technology Stack
- Language: Swift
- Framework: SwiftUI
- Platform: iOS
- Architecture Pattern: MVVM (Model-View-ViewModel)
- State Management: @Published properties with ObservableObject
- Persistence: UserDefaults
- Monetization: Google AdMob (PRODUCTION mode, awaiting ad fill)

Project Structure

Models - Data models and business logic
- GameMode.swift - Game mode enum (5 modes: Tutorial, Classic, Memory, GameVsPvP, PvP)
- GameState.swift - App state machine
- GameModel.swift - Memory mode game logic + GameConfiguration
- ClassicModeModel.swift - Classic mode game logic
- GestureType.swift - Gesture definitions (14 gestures)
- ColorType.swift - Stroop color system (4 colors)

ViewModels - View logic and state management
- GameViewModel.swift - Central game coordinator

Views - UI screens
- LaunchView.swift - App launch splash screen
- MenuView.swift - Main menu with mode selection
- GameModeSheet.swift - Mode selection modal
- ClassicModeView.swift - Classic mode gameplay
- SequenceDisplayView.swift - Memory mode sequence display
- GamePlayView.swift - Memory mode gameplay
- GameOverView.swift - Game over screen (unified end card)
- TutorialView.swift - Tutorial screens
- TutorialCompletionView.swift - Tutorial completion
- SettingsView.swift - Settings screen with toggles
- DevPanelView.swift - Developer panel (DEBUG/TESTFLIGHT only)
- GestureTestView.swift - Per-gesture test interface
- LeaderboardView.swift - High scores display

Components - Reusable UI components
- ArrowView.swift - Animated gesture arrows
- CountdownRing.swift - Circular countdown timer
- CountdownOverlayView.swift - Post-ad 3,2,1,START overlay
- StroopPromptView.swift - Stroop display (~350 lines)
- PinchGestureView.swift - Native pinch wrapper (~200 lines)
- GestureDrawerView.swift - PvP gesture selection drawer
- GestureDrawerTabView.swift - Drawer tab with pulsing animation
- SettingToggleRow.swift - Settings toggle component
- ExpandingSegmentedControl.swift - Custom mode selector
- GestureCellView.swift - Gesture list cell

Utilities - Helper classes
- MotionGestureManager.swift - Centralized motion detection (~650 lines)
- GestureCoordinator.swift - Conflict prevention (~80 lines)
- GesturePoolManager.swift - Discreet/Unhinged mode pools (~90 lines)
- GestureVisualProvider.swift - Gesture Pack V2 image provider
- HapticManager.swift - Haptic feedback
- FailureFeedbackManager.swift - Unified failure feedback
- AudioManager.swift - Simplified audio system (~150 lines, AVAudioPlayer + SystemSoundID)
- PersistenceManager.swift - Local storage
- LeaderboardManager.swift - High score tracking (~260 lines)
- SwipeGestureModifier.swift - Swipe detection
- TapGestureModifier.swift - Tap detection
- PinchGestureModifier.swift - Pinch detection wrapper
- AdManager.swift - Google AdMob singleton manager (~150 lines)
- UIViewControllerHelper.swift - SwiftUI/UIKit presentation bridge (~80 lines)
- AnalyticsManager.swift - Firebase Analytics event tracking
- UserSettings.swift - User preferences persistence
- DevConfigManager.swift - Debug threshold configuration (~200 lines)
- SensorCaptureBuffer.swift - Motion sensor data logging (DEBUG only)
- ErrorLogger.swift - Error tracking and logging

State Machine
Flow: Launch → Menu → [Tutorial/Classic/Memory/PvP] → Game Over → Menu

States:
- .launch - Initial splash screen (1 second)
- .menu - Main menu with mode selection
- .tutorial - Tutorial flow
- .classicMode - Classic mode gameplay
- .showSequence - Memory mode sequence display
- .awaitInput - Memory mode player input
- .judge - Memory mode evaluation
- .gameOver - End screen with retry option

========================================

DATA PERSISTENCE

Stored Data:
- TipobBestStreak (Int) - Memory mode best streak
- TipobClassicBestScore (Int) - Classic mode high score
- TipobPvPPlayer1BestScore (Int) - PvP Player 1 best
- TipobPvPPlayer2BestScore (Int) - PvP Player 2 best
- selectedGameMode (String) - Last selected mode
- isDiscreetModeEnabled (Bool) - Discreet/Unhinged mode toggle
- Leaderboards (JSON) - Top 100 per mode in Documents directory
- hasCompletedTutorial (Bool) - Tutorial completion flag

Persistence Implementation
- Storage Method: UserDefaults
- Load Timing: App initialization in GameViewModel.init()
- Save Timing: Game over in respective mode functions
- Scope: Local device only (no cloud sync)

========================================

USER INTERFACE

Design System

Color Palette:
- Primary Gradient: Purple → Blue → Cyan
- Menu Gradient: Blue → Purple → Pink
- Success Flash: Green (0.5 opacity overlay)
- Error Flash: Red (0.5 opacity overlay)

Typography:
- Font Family: System Rounded
- Title: 64pt, Black weight
- Headings: 32-36pt, Bold weight
- Body: 18-24pt, Medium-Semibold weight
- Captions: 14-18pt, Medium weight

Gesture Colors:
- Up ↑: Blue
- Down ↓: Green
- Left ←: Red
- Right →: Yellow
- Tap ⊙: Purple
- Double Tap ◎: Purple
- Long Press ⏺: Purple

Screen Layouts

Launch Screen:
- Stacked title animation: "OUT OF" (48pt) above "POCKET" (64pt)
- Spring scale animation (0.3 → 1.0)
- "Swipe to Survive" tagline fades in after title
- Fade-out transition before menu (smooth crossfade)
- ~1.6 second duration total
- AudioManager initialization after animation completes

Menu Screen:
- App title
- Mode-specific best score display
- Selected mode indicator with emoji (⚡, 🧠, 👥)
- Large circular "Start Playing" button
- Floating mode selection button (game controller icon, bottom-right)

Gameplay Screens:
- Full-screen gradient background
- Centered gesture display (120pt)
- Countdown ring
- Score/round display
- Mode-specific UI elements
- Player indicators (for PvP mode)

Game Over Screen:
- Final score/streak
- Best score comparison
- Winner announcement (PvP mode)
- "Try Again" button
- "Back to Menu" button

========================================

GAME CONFIGURATION

Timing Parameters
- perGestureTime: 3.0 seconds
- sequenceShowDuration: 0.6 seconds
- sequenceGapDuration: 0.2 seconds
- transitionDelay: 0.5 seconds
- flashAnimationDuration: 0.3 seconds
- doubleTapWindow: 0.35 seconds
- longPressDuration: 0.6 seconds

Classic Mode Parameters
- initialReactionTime: 3.0 seconds
- minimumReactionTime: 1.5 seconds (raised from 1.0s to ensure Long Press detection)
- speedUpInterval: 3 gestures
- speedUpAmount: 0.2 seconds

Gesture Detection Parameters (Optimized November 9, 2025):
- minSwipeDistance: 50.0 pixels
- minSwipeVelocity: 80.0 pts/sec (optimized from 100.0)
- edgeBufferDistance: 24.0 pixels
- pinchMinimumChange: 0.06 (6% reduction) (optimized from 0.08)
- pinchScaleThreshold: 0.85 (15% reduction) (optimized from 0.8)

Motion Gesture Parameters (Optimized November 9, 2025):
- shakeThreshold: 2.0G (optimized from 2.5G)
- shakeUpdateInterval: 0.02s (50 Hz) (optimized from 0.1s / 10 Hz)
- tiltAngleThreshold: 0.44 rad (~25°) (optimized from 0.52 rad / ~30°)
- tiltUpdateInterval: 0.016s (60 Hz) (optimized from 0.05s / 20 Hz)
- raiseLowerThreshold: 0.3G (optimized from 0.4G)
- raiseLowerUpdateInterval: 1/60s (60 Hz) (optimized from 1/30s / 30 Hz)

========================================

CURRENT IMPLEMENTATION STATUS

Completed Features:
- 14 gesture types (4 swipes + 3 touch + 6 motion + 1 cognitive)
- 5 game modes (Tutorial, Classic, Memory, Game vs PvP, PvP)
- Stroop cognitive challenge system (color-word mismatch)
- Discreet Mode (9 vs 14 gesture toggle)
- Leaderboard system (top 100 per mode)
- MotionGestureManager (centralized motion detection)
- GestureCoordinator (conflict prevention)
- Gesture detection optimization (20-30% faster response)
- Tutorial/onboarding flow (all 14 gestures)
- High score persistence (per mode + leaderboards)
- Mode selection UI (5 modes with icons)
- Launch animation
- Haptic + sound feedback (unified failure system)
- Visual feedback (flash animations)
- Countdown timers
- Progressive difficulty (Classic and Memory modes)
- Color-coded gesture display
- Game over screens
- Menu navigation
- Gesture coexistence (simultaneous detection)
- PvP turn management
- Fair sequence replay (PvP modes)
- Portrait orientation lock
- Google AdMob integration (PRODUCTION mode, interstitial ads, awaiting ad fill)
- Ad triggers on game over screens (Home/Play Again buttons)
- Ad preloading during gameplay
- 49 SKAdNetwork identifiers for iOS 14+ attribution

Known Issues:
- Stroop alignment: Build cache issue (needs Cmd+Shift+K clean build)
- Double tap false positives: Collecting more testing data
- Spread gesture: Disabled due to finger positioning detection issues

Testing Status:
- All 14 gestures functional across all modes
- Gesture optimization deployed (November 9, 2025)
- Zero compiler warnings
- TestFlight deployment ready (awaiting user decision)

Planned Features:
- Gesture detection Option 2 (architecture improvements, 8-10 hours)
- Gesture detection Option 3 (diagnostic framework, 20+ hours)
- Additional game modes (Endless, Zen, Custom)
- Difficulty level selection (Easy/Medium/Hard)
- Statistics dashboard
- Achievement system
- Re-enable Spread gesture with improved detection
- Cloud save and global leaderboards
- Share scores to social media
- Monetization expansion (rewarded ads, banner ads, IAP, subscription)
- Remove Ads IAP ($4.99)

========================================

MONETIZATION SYSTEM

Status: PRODUCTION Mode (Updated November 30, 2025, Awaiting Ad Fill)

Google AdMob Integration
SDK: Google Mobile Ads (GoogleMobileAds framework)
Configuration: PRODUCTION credentials active
Ad Type: Interstitial ads (full-screen)

PRODUCTION Credentials (Updated November 30, 2025):
- Ad Unit ID: ca-app-pub-8372563313053067/2149863647
- Application ID: ca-app-pub-8372563313053067~4654955095
- Status: Awaiting ad fill (new ad units take 24-48 hours to start serving)

Implementation Architecture:
- AdManager.swift: Singleton managing ad lifecycle (~180 lines)
  - `preloadIfNeeded()` method for game start preloading (Nov 30, 2025)
  - `isLoading` flag prevents duplicate load requests (Nov 30, 2025)
  - Race condition fix: removed premature loadInterstitialAd() call (Nov 30, 2025)
- UIViewControllerHelper.swift: SwiftUI/UIKit bridge for presenting ads (~80 lines)
- Ad initialization in TipobApp.swift (SDK startup)
- Integration in game over views (GameOverView, PlayerVsPlayerView, GameVsPlayerVsPlayerView)
- GameViewModel calls `preloadIfNeeded()` on all game start methods

Ad Display Logic (Updated December 29, 2025):
- Trigger Types: `AdTrigger` enum with `.home` and `.playAgain` cases
- Buttons: "Home" and "Play Again" both check gating logic
- Session Grace Period: 30 seconds (no ads during first 30s after app launch)
- Cooldown: 60 seconds between any ads (unified for all triggers)
- Graceful Degradation: Game continues if ad fails to load or gating not met

Previous Logic (November 12, 2025):
- No cooldowns (full testing mode)
- Ad on EVERY button tap

Rationale for Current Gating:
Simplified from complex multi-condition logic (90s session, 120s cooldown, 3 games, 20s run duration) to user-friendly 30s+60s approach that balances monetization with player experience.

Ad Flow:
1. User completes game (success or failure)
2. Reaches game over screen
3. Taps "Home" or "Play Again"
4. Ad loads (if available)
5. Ad displays as full-screen interstitial
6. User closes ad
7. Navigation continues (home/restart)

Technical Details:
- Preloading: Ads preload in background during gameplay
- Thread Safety: Main thread presentation via UIViewControllerHelper
- Error Handling: Silent failures, logs errors without blocking UX
- Memory Management: Singleton pattern prevents duplicate managers

iOS Configuration (Info.plist):
- GADApplicationIdentifier: TEST app ID configured
- SKAdNetworkItems: 49 identifiers for iOS 14+ ad attribution
- UIRequiresFullScreen: YES (portrait-only mode)
- UISceneDelegateClassName: Removed (fixed warning)

Files Modified:
- AdManager.swift (new)
- UIViewControllerHelper.swift (new)
- TipobApp.swift (AdMob SDK initialization)
- GameOverView.swift (ad trigger integration)
- PlayerVsPlayerView.swift (ad trigger integration)
- GameVsPlayerVsPlayerView.swift (ad trigger integration)
- Info.plist (49 SKAdNetwork IDs, portrait lock, scene delegate fix)

Production Readiness (Updated December 29, 2025):
- Current: PRODUCTION mode with real AdMob credentials + ad gating
- Status: Ad gating implemented (30s session + 60s cooldown)
- Completed: Production IDs, race condition fix, preload pattern, AdTrigger enum, simplified gating
- Pending: Monitor ad fill rates and user experience feedback

Performance Impact:
- Preloading during gameplay: Minimal (background thread)
- Ad display: 300-500ms additional latency before navigation
- Memory: ~10-20MB additional for ad SDK
- User Experience: Testing phase to gather feedback

Future Enhancements:
- Rewarded video ads (continue playing after game over)
- Banner ads (menu screen)
- Ad frequency optimization based on user retention data
- Remove Ads IAP ($4.99)

========================================

USER FLOWS

First-Time User Flow
App Launch → Tutorial Mode → Completion → Menu → Select Mode → Play

Returning User Flow
App Launch → Menu (Classic selected by default) → Play → Game Over → Retry/Menu

Mode Switching Flow
Menu → Tap game controller button → Mode selection sheet → Select mode (⚡ Classic, 🧠 Memory, 👥 PvP) → Tap outside to close → Menu updates → Play

PvP Mode Flow
Menu → Select PvP Mode → Start Playing → Player 1 Turn → Success/Fail → Player 2 Turn → Success/Fail → Continue alternating → Game Over → Winner Announcement → Retry/Menu

========================================

PERFORMANCE & OPTIMIZATION

Performance Targets
- Launch time: Less than 1 second to menu
- Gesture response time: Less than 100ms
- Frame rate: 60 FPS sustained
- Memory usage: Less than 100MB

SwiftUI Optimizations
- @Published properties for reactive updates
- Explicit objectWillChange.send() for struct mutations
- Efficient gesture modifiers
- Minimal view re-renders
- Gesture coexistence without conflicts

========================================

CODE QUALITY & STANDARDS

Architecture Principles
- MVVM Pattern: Clean separation of concerns
- Single Responsibility: Each component has one clear purpose
- SwiftUI Best Practices: Declarative UI, state-driven rendering
- Value Types: Prefer structs over classes for models

Code Organization
- Models: Pure data structures and business logic
- ViewModels: State management and coordination
- Views: UI presentation only
- Utilities: Reusable helpers and extensions
- Components: Reusable UI elements

Naming Conventions
- Files: PascalCase (e.g., GameViewModel.swift)
- Types: PascalCase (e.g., GameMode, ClassicModeModel)
- Functions: camelCase (e.g., startClassicMode())
- Properties: camelCase (e.g., bestScore, reactionTime)
- Constants: camelCase (e.g., initialReactionTime)

========================================

FUTURE CONSIDERATIONS

Scalability
- Cloud save infrastructure for leaderboards
- Backend service for online multiplayer
- Analytics integration
- A/B testing framework

Localization
- Multi-language support
- Cultural considerations for gestures
- RTL language support

Advanced Features
- Additional Multiplayer Modes:
  - Online PvP with matchmaking
  - Tournament mode
  - Team competitions
- Social Features:
  - Friend challenges
  - Global leaderboards
  - Social media integration
- Customization:
  - Theme packs
  - Custom gesture sets
  - Difficulty presets

========================================

PROJECT INFORMATION

Project Location
/Users/marcgeraldez/Projects/tipob

Key Files
- Main Entry: TipobApp.swift
- Core Logic: GameViewModel.swift
- Models: Tipob/Models/
- Views: Tipob/Views/
- Components: Tipob/Components/
- Utilities: Tipob/Utilities/

Total Swift Files
23 files across the project

Recent Updates (December 29, 2025):
- Ad gating simplification: 30s session delay + 60s cooldown (removed complex multi-condition logic)
- Custom repeat icon: Replaced SF Symbol with icon_repeat_default asset for Play Again buttons
- UI text updates: Discreet Mode popup and game mode descriptions shortened and clarified
- AdTrigger enum: .home and .playAgain triggers with unified gating logic

Recent Updates (December 28, 2025):
- Long Press timing fix: raised Classic Mode minimumReactionTime from 1.0s to 1.5s
- Comprehensive documentation update with all December features

Recent Updates (December 22, 2025):
- Unified End Card System: consistent layout across all game modes
- Removed "GAME OVER" headers, added trophy + "NEW HIGH SCORE!" banners
- Equal-width CTAs with Settings icons
- Gesture Pack V2 with standardized 56x56 image-based visuals

Recent Updates (December 20, 2025):
- PvP auto-start bypass: skip name entry on replay
- Post-ad countdown timer: 3, 2, 1, START sequence
- Gesture helper text toggle in Settings
- Settings screen with Sound/Haptics toggles
- Reusable SettingToggleRow component

Recent Updates (December 15, 2025):
- Gesture detection improvements:
  - Double tap window increased: 300ms → 350ms (more reliable detection)
  - Long press grace window reduced: 100ms → 50ms (faster response)
  - Hold intent lock system: gives long press priority over accidental swipes
  - Stroop gesture fix: added .contentShape(Rectangle()) for full-screen detection
  - Pinch detection fix: moved before contentShape in modifier chain
- Firebase Analytics integration complete:
  - AnalyticsManager.swift for type-safe event logging
  - Game events: start_game, end_game, replay_game
  - Gesture events: gesture_prompted, gesture_completed, gesture_failed
  - Ad events: ad_requested, ad_loaded, ad_shown, ad_dismissed
  - Added gesture_failed event with fail_reason: "timeout" or "wrong_gesture"
  - Fixed timeout race condition: gestures at timer expiration now log correctly
- Dev Panel enhancements:
  - Per-gesture test buttons with sensor capture
  - XCTest code generation from failed gestures
  - Enabled for TestFlight builds
- Blocked tap logging for debugging tap detection issues

Recent Updates (November 30, 2025):
- AdMob switched from TEST to PRODUCTION credentials
- Production Ad Unit ID: ca-app-pub-8372563313053067/2149863647
- Production App ID: ca-app-pub-8372563313053067~4654955095
- Fixed race condition: removed premature loadInterstitialAd() from showInterstitialAd()
- Added preloadIfNeeded() method called on all game starts
- Added isLoading flag to prevent duplicate ad load requests
- Status: Awaiting ad fill (new ad units take 24-48 hours)

Recent Updates (November 18-20, 2025):
- App rebranded from "TIPOB" to "Out of Pocket"
- New launch animation with spring scale and fade-out transition
- Simplified audio system implemented (success tick, round complete chime, failure sound)
- Removed AVAudioEngine complexity - direct AVAudioPlayer + SystemSoundID
- Fixed launch hang by deferring AudioManager initialization
- StroopPromptView center word size reduced (70pt → 50pt)
- Menu title removed (only shown on launch screen)

Recent Updates (November 11-12, 2025):
- Google AdMob integration complete (TEST credentials)
- AdManager singleton for ad lifecycle management
- UIViewControllerHelper for SwiftUI ad presentation
- Ad triggers on all game over screens (Home/Play Again)
- Initial logic: 30s cooldowns + every 2 games
- Updated logic (Nov 12): Show ads on EVERY button tap (testing mode)
- Info.plist fixes: SKAdNetwork IDs, portrait lock, scene delegate removal

Recent Updates (November 10, 2025):
- Gesture detection optimization complete (Option 1 Quick Wins)
- 6 old gesture managers deleted (~400 lines removed)
- Sensor update rates increased 2-5x (10-30 Hz → 50-60 Hz)
- Detection thresholds relaxed 17-25% (more forgiving)
- Expected: 20-30% faster gesture response time
- Options 2 & 3 documented for future optimization iterations

Recent Updates (November 4, 2025):
- MotionGestureManager implemented (centralized motion detection)
- Leaderboard system complete (top 100 per mode)
- Menu UI improvements (compact layout)

Recent Updates (November 3, 2025):
- Discreet Mode implemented (9 vs 14 gesture toggle)
- GesturePoolManager for gesture set management

Recent Updates (October 31, 2025):
- Stroop cognitive gesture complete
- StroopPromptView with color-word mismatch
- Integrated into all 4 game modes

Recent Updates (October 27-29, 2025):
- 6 motion gestures added (Pinch, Shake, Tilt L/R, Raise, Lower)
- CoreMotion framework integration
- Native UIPinchGestureRecognizer implementation
- GestureCoordinator for conflict prevention
- Portrait orientation lock

Recent Updates (October 20, 2025):
- 3 touch gestures added (Tap, Double Tap, Long Press)
- Memory Mode 🧠 complete
- Game vs Player vs Player 👥 mode complete
- Gesture coexistence support

========================================

REVISION HISTORY

Version 1.0 | October 10, 2025 | Initial product overview
Version 2.0 | October 21, 2025 | Updated with 7 gestures, Memory Mode, and PvP Mode
Version 3.0 | November 10, 2025 | Updated with 14 gestures, Stroop Mode, Discreet Mode, Leaderboard System, MotionGestureManager, gesture optimization complete
Version 3.1 | November 12, 2025 | Added Google AdMob integration (TEST mode), AdManager, UIViewControllerHelper, Info.plist configuration
Version 3.2 | November 20, 2025 | Rebranded to "Out of Pocket", new launch animation, simplified audio system (AVAudioPlayer + SystemSoundID)
Version 3.3 | November 30, 2025 | AdMob production mode: production credentials, race condition fix, preloadIfNeeded() pattern
Version 3.4 | December 15, 2025 | Gesture detection improvements: double tap window (350ms), hold intent lock, Stroop fix, pinch fix; Firebase Analytics integration; Dev Panel enhancements with per-gesture testers
Version 3.5 | December 20, 2025 | Settings screen with Sound/Haptics/Gesture Names toggles; Post-ad countdown timer (3,2,1,START); PvP auto-start bypass on replay; Gesture helper text feature
Version 3.6 | December 22, 2025 | Unified End Card System across all modes; Gesture Pack V2 with 56x56 image-based visuals; standardized icons; removed GAME OVER headers
Version 3.7 | December 28, 2025 | Long Press timing fix (minimumReactionTime 1.0s→1.5s); Comprehensive documentation update covering all December features
Version 3.8 | December 29, 2025 | Ad gating simplification (30s + 60s cooldown); custom icon_repeat_default asset; UI text updates for Discreet Mode and game mode descriptions

========================================

END OF DOCUMENT
