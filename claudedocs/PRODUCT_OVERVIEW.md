TIPOB - PRODUCT OVERVIEW

Last Updated: October 21, 2025
Version: 2.0
Status: Phase 1 Partially Complete

========================================

PRODUCT OVERVIEW

Product Description
Fast-paced mobile gesture game for iOS
Tests players' reflexes and memory through gesture-based interactions
Players respond to on-screen prompts using swipes (up, down, left, right) and taps (tap, double tap, long press)

Core Value Proposition
Simple to Learn: Intuitive gesture controls anyone can pick up
Hard to Master: Progressive difficulty keeps players engaged
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
- Minimum Speed: 1.0 second (hard cap)

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

Visual Design:
- Purple/blue gradient background
- Animated gesture display during sequence showing
- Color-coded gesture arrows
- Round counter
- "Watch the sequence" instruction
- Visual feedback after sequence completion

========================================

Game vs Player vs Player Mode
Genre: Competitive Pass-and-Play
Icon: Two people 👥
Status: Complete (Implemented October 20, 2025)

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

Scoring:
- Points awarded per successful gesture
- Scores tracked separately for each player
- Winner announcement at game over

Visual Design:
- Player turn indicators
- Individual score displays
- Same visual polish as other modes
- Winner celebration screen

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

GESTURES & CONTROLS

Supported Gestures (7 Total)

Swipe Gestures (4):
- Up ↑ (Blue arrow): Swipe up
- Down ↓ (Green arrow): Swipe down
- Left ← (Red arrow): Swipe left
- Right → (Yellow arrow): Swipe right

Touch Gestures (3) - Added October 20, 2025:
- Tap ⊙ (Purple circle): Single tap anywhere
- Double Tap ◎ (Purple double circle): Two quick taps
- Long Press ⏺ (Purple filled circle): Press and hold (600ms)

Gesture Detection Parameters
- Minimum Swipe Distance: 50 pixels
- Minimum Swipe Velocity: 100 pts/sec
- Edge Buffer: 24 pixels (prevents edge swipes)
- Double Tap Window: 300ms between taps
- Long Press Duration: 600ms hold time

Gesture Coexistence
- Gestures use .simultaneousGesture() for conflict-free detection
- Tap disambiguation prevents conflicts between tap and double tap
- All gestures can be detected reliably without interference

Haptic Feedback
- Success: Success haptic
- Failure: Error haptic
- Button Tap: Impact haptic

========================================

TECHNICAL ARCHITECTURE

Technology Stack
- Language: Swift
- Framework: SwiftUI
- Platform: iOS
- Architecture Pattern: MVVM (Model-View-ViewModel)
- State Management: @Published properties with ObservableObject
- Persistence: UserDefaults

Project Structure

Models - Data models and business logic
- GameMode.swift - Game mode enum and metadata (updated with playerVsPlayer)
- GameState.swift - App state machine
- GameModel.swift - Memory mode game logic
- ClassicModeModel.swift - Classic mode game logic
- GestureType.swift - Gesture definitions (7 gestures)

ViewModels - View logic and state management
- GameViewModel.swift - Central game coordinator

Views - UI screens
- LaunchView.swift - App launch splash screen
- MenuView.swift - Main menu with mode selection
- GameModeSheet.swift - Mode selection modal
- ClassicModeView.swift - Classic mode gameplay
- SequenceDisplayView.swift - Memory mode sequence display
- GamePlayView.swift - Memory mode gameplay
- GameOverView.swift - Game over screen
- TutorialView.swift - Tutorial screens
- TutorialCompletionView.swift - Tutorial completion

Components - Reusable UI components
- ArrowView.swift - Animated gesture arrows
- CountdownRing.swift - Circular countdown timer

Utilities - Helper classes
- HapticManager.swift - Haptic feedback
- PersistenceManager.swift - Local storage
- SwipeGestureModifier.swift - Swipe detection (up, down, left, right)
- TapGestureModifier.swift - Tap detection (tap, double tap, long press)

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

Stored Data
- TipobBestStreak (Int) - Memory mode best streak
- TipobClassicBestScore (Int) - Classic mode high score
- TipobPvPPlayer1BestScore (Int) - PvP mode Player 1 best score
- TipobPvPPlayer2BestScore (Int) - PvP mode Player 2 best score
- selectedGameMode (String) - Last selected mode (default: "Classic")

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
- Animated "TIPOB" title with rotation
- "Swipe to Survive" tagline
- 1-second duration
- Automatic transition to menu

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
- doubleTapWindow: 0.3 seconds
- longPressDuration: 0.6 seconds

Classic Mode Parameters
- initialReactionTime: 3.0 seconds
- minimumReactionTime: 1.0 seconds
- speedUpInterval: 3 gestures
- speedUpAmount: 0.2 seconds

Gesture Detection Parameters
- minSwipeDistance: 50.0 pixels
- minSwipeVelocity: 100.0 pts/sec
- edgeBufferDistance: 24.0 pixels

========================================

CURRENT IMPLEMENTATION STATUS

Completed Features
- Triple game mode system (Classic, Memory, PvP)
- 7 gesture types (4 swipes + 3 touch gestures)
- Tutorial/onboarding flow
- High score persistence (separate for each mode)
- Mode selection UI (updated with 3 modes)
- Launch animation
- Haptic feedback
- Visual feedback (flash animations)
- Countdown timers
- Progressive difficulty (Classic and Memory modes)
- Color-coded gesture display
- Game over screen
- Menu navigation
- Gesture coexistence (simultaneous gesture detection)
- PvP turn management (alternating players)
- Fair sequence replay (PvP mode)

Known Issues
None currently identified

Planned Features
- Difficulty level selection (Easy/Medium/Hard)
- Statistics dashboard comparing modes
- Achievement system
- Additional gesture types (shake, pinch, rotate)
- Sound effects and music
- Audio settings and controls
- Accessibility features (VoiceOver support)
- Cloud save and leaderboards
- Share scores to social media
- Monetization options:
  - Ad integration (interstitial after game over)
  - In-app purchases (remove ads, themes, gesture packs)
  - Premium game modes
  - Power-ups and boosters

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

Recent Updates (October 20, 2025)
- Added 3 new touch gestures (Tap ⊙, Double Tap ◎, Long Press ⏺)
- Implemented Memory Mode 🧠 with sequence memorization gameplay
- Implemented Game vs Player vs Player 👥 mode with fair sequence replay
- Updated gesture detection with coexistence support
- Enhanced UI with gesture symbols and mode icons

========================================

REVISION HISTORY

Version 1.0 | October 10, 2025 | Initial product overview
Version 2.0 | October 21, 2025 | Updated with 7 gestures, Memory Mode, and PvP Mode

========================================

END OF DOCUMENT
