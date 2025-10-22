# Tipob Feature Scoping Document
**Date**: October 10, 2025 (Updated: October 21, 2025)
**Project**: Tipob - iOS SwiftUI Bop-It Style Game
**Purpose**: Comprehensive feature planning and decision framework
**Status**: Phase 1 Partially Complete

---

## 📋 Table of Contents
1. [Gesture Expansion Options](#gesture-expansion-options)
2. [Feature Roadmap](#feature-roadmap)
3. [Monetization Strategy](#monetization-strategy)
4. [Implementation Complexity Matrix](#implementation-complexity-matrix)
5. [Revenue Projections](#revenue-projections)
6. [Technical Requirements](#technical-requirements)
7. [Risk Assessment](#risk-assessment)
8. [Decision Framework](#decision-framework)

---

## 🎮 Gesture Expansion Options

### Currently Implemented ✅
| Gesture | Detection Method | Difficulty | Status |
|---------|-----------------|------------|--------|
| Swipe Up ↑ | DragGesture + angle calculation | Easy | ✅ Live |
| Swipe Down ↓ | DragGesture + angle calculation | Easy | ✅ Live |
| Swipe Left ← | DragGesture + angle calculation | Easy | ✅ Live |
| Swipe Right → | DragGesture + angle calculation | Easy | ✅ Live |
| **Single Tap ⊙** | TapGesture with disambiguation | Easy | ✅ Implemented 2025-10-20 |
| **Double Tap ◎** | TapGesture with timing window | Easy | ✅ Implemented 2025-10-20 |
| **Long Press ⏺** | LongPressGesture (600ms) | Easy | ✅ Implemented 2025-10-20 |

**Total Gestures**: 7 (4 swipes + 3 touch gestures)

### Tier 1: High Priority - Easy Implementation 🟢

#### Touch-Based Gestures
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Single Tap** | `.onTapGesture()` | Very Low | High | Excellent | P0 |
| **Double Tap** | `.onTapGesture(count: 2)` | Very Low | High | Good | P0 |
| **Long Press** | `.onLongPressGesture()` | Very Low | Medium | Excellent | P1 |
| **Two-Finger Swipe** | DragGesture with touch count | Low | Medium | Poor | P2 |

**Recommendation**: Implement all Tier 1 gestures in Phase 1
**Estimated Effort**: 2-4 hours total
**Risk**: Very Low

**Implementation Notes**:
```swift
// Single Tap Example
.onTapGesture {
    viewModel.handleGesture(.tap)
}

// Double Tap Example
.onTapGesture(count: 2) {
    viewModel.handleGesture(.doubleTap)
}

// Long Press Example
.onLongPressGesture(minimumDuration: 0.5) {
    viewModel.handleGesture(.longPress)
}
```

---

### Tier 2: Medium Priority - Moderate Complexity 🟡

#### Multi-Touch Gestures
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Pinch** | `MagnificationGesture()` | Low | High | Poor | P1 |
| **Rotate** | `RotationGesture()` | Low | High | Poor | P1 |
| **Spread** | MagnificationGesture (inverse pinch) | Low | Medium | Poor | P2 |

**Implementation Notes**:
```swift
// Pinch/Spread Example
.gesture(
    MagnificationGesture()
        .onEnded { scale in
            if scale < 0.9 {
                viewModel.handleGesture(.pinch)
            } else if scale > 1.1 {
                viewModel.handleGesture(.spread)
            }
        }
)

// Rotate Example
.gesture(
    RotationGesture()
        .onEnded { angle in
            if abs(angle.degrees) > 30 {
                viewModel.handleGesture(.rotate)
            }
        }
)
```

#### Motion-Based Gestures
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Shake** | CMMotionManager + acceleration threshold | Medium | Very High | Poor | P0 |
| **Tilt Left/Right** | CMMotionManager + device orientation | Medium | High | Poor | P1 |
| **Flip** | CMMotionManager + gravity vector | Medium | Medium | Very Poor | P3 |
| **Raise/Lower** | CMMotionManager + altitude change | High | Low | Very Poor | P4 |

**Recommendation**: Start with Shake only (most engaging, iconic Bop-It gesture)
**Estimated Effort**: 4-8 hours (includes CMMotionManager setup)
**Risk**: Medium (battery drain, device drop concerns)

**Implementation Notes**:
```swift
// Shake Detection
import CoreMotion

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let shakeThreshold = 2.5

    func startMonitoring(onShake: @escaping () -> Void) {
        guard motionManager.isAccelerometerAvailable else { return }

        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let acceleration = data?.acceleration else { return }

            let magnitude = sqrt(
                pow(acceleration.x, 2) +
                pow(acceleration.y, 2) +
                pow(acceleration.z, 2)
            )

            if magnitude > self.shakeThreshold {
                onShake()
            }
        }
    }
}
```

**Privacy Consideration**: Motion data requires `NSMotionUsageDescription` in Info.plist

---

### Tier 3: Advanced - High Complexity 🔴

#### Pattern Recognition
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Draw Circle** | Vision framework + shape recognition | High | Medium | Poor | P3 |
| **Draw Square** | Vision framework + shape recognition | High | Medium | Poor | P3 |
| **Draw Triangle** | Vision framework + shape recognition | High | Medium | Poor | P3 |
| **Custom Path** | Path tracking + ML model | Very High | Low | Very Poor | P5 |

**Recommendation**: Defer until post-launch, requires ML expertise
**Estimated Effort**: 40-80 hours (includes ML model training)
**Risk**: High (recognition accuracy issues)

#### Sensor-Based
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Blow/Whistle** | AVAudioRecorder + frequency analysis | High | High | Poor | P2 |
| **Cover Camera** | AVCaptureSession + brightness detection | Medium | Medium | Poor | P4 |
| **Volume Buttons** | Hardware button monitoring | Low | Low | Good | P5 |
| **3D Touch** | `.onLongPressGesture` with pressure | Low | Medium | Poor | P3 |

**Recommendation**: Blow/Whistle could be fun novelty feature for later
**Estimated Effort**: 8-16 hours
**Risk**: Medium (microphone permission, false positives)

#### Accessibility Gestures
| Gesture | Implementation | Complexity | Engagement | Accessibility | Priority |
|---------|---------------|------------|------------|---------------|----------|
| **Voice Commands** | Speech recognition framework | Medium | High | Excellent | P1 |
| **Switch Control** | iOS accessibility API integration | High | Low | Excellent | P2 |

**Recommendation**: Voice commands essential for accessibility compliance
**Estimated Effort**: 6-12 hours
**Risk**: Low (Apple provides good APIs)

---

### Tier 4: Creative/Experimental 🎨

| Gesture | Implementation | Complexity | Engagement | Notes |
|---------|---------------|------------|------------|-------|
| **Swipe from Edge** | UIScreenEdgePanGestureRecognizer | Low | Medium | iOS native feel |
| **Triple Tap** | `.onTapGesture(count: 3)` | Very Low | Low | May be too fast |
| **Hold + Swipe Combo** | Simultaneous gesture detection | High | High | Advanced difficulty |
| **Pressure Touch** | Force touch (older devices only) | Low | Low | Limited device support |

**Recommendation**: Swipe from edge for premium feel, hold+swipe for advanced mode
**Priority**: P3 (post-launch enhancements)

---

### 🚫 Gestures NOT Recommended

| Gesture | Reason | Alternative |
|---------|--------|-------------|
| **Spin** | Unreliable detection, user confusion | Use rotate instead |
| **Physical device flip** | High drop risk, safety concern | Use tilt instead |
| **Screenshot gesture** | System conflict, confusing UX | Skip entirely |
| **Raise/Lower device** | Poor accuracy, awkward posture | Use tilt instead |

---

## 🎯 Feature Roadmap

### Phase 0: Foundation (Current State)
**Status**: ✅ Complete
**Features**:
- 4 directional swipes
- Basic game loop (sequence generation, validation, scoring)
- State machine (launch → menu → game → game over)
- Haptic feedback (success, error, impact)
- Persistence (best streak via UserDefaults)
- Visual feedback (countdown ring, progress dots, flash effects)

---

### Phase 1: MVP+ (Core Expansion)
**Timeline**: 2-3 weeks
**Goal**: Increase engagement and replayability
**Priority**: 🔴 Critical Path

#### 1.1 Gesture Expansion
- [x] **Tap gesture ⊙** (1 hour) - ✅ Completed 2025-10-20 (Actual: 0.5 hours)
- [x] **Double tap gesture ◎** (1 hour) - ✅ Completed 2025-10-20 (Actual: 0.5 hours)
- [x] **Long press gesture ⏺** (1 hour) - ✅ Completed 2025-10-20 (Actual: 0.5 hours)
- [ ] **Shake gesture** (6-8 hours) - Deferred
  - CMMotionManager integration
  - Threshold calibration
  - Battery optimization
  - Privacy permission handling

**Implementation Notes (2025-10-20)**:
- Created SwipeGestureModifier for swipe detection with angle calculation
- Implemented tap disambiguation (300ms window for double-tap detection)
- All touch gestures working via SwiftUI native gesture recognizers (.simultaneousGesture() for coexistence)
- Total implementation time: ~2.5 hours (vs estimated 4 hours)

**Acceptance Criteria** (Complete):
- [x] Tap, double tap, long press detected reliably
- [x] Haptic feedback unique to each gesture type (using existing system)
- [x] Gestures coexist without conflicts (simultaneousGesture() implementation)
- [ ] Tutorial screens for new gestures (deferred)
- [ ] Shake gesture implementation (deferred)
- [ ] Settings to disable motion gestures (deferred)

**Status**: 3 of 3 touch gestures complete. Shake gesture deferred to focus on touch-based gestures first.

---

#### 1.2 Game Modes
- [x] **Memory Mode 🧠** (6 hours) - ✅ Completed 2025-10-20 (Actual: 4 hours)
  - Show sequence once, player must memorize
  - No visual indicators during input
  - Sequence grows by 1 gesture each round
  - Visual feedback after sequence completion
  - High score tracking and persistence

- [x] **Game vs Player vs Player 👥** (8 hours) - ✅ Completed 2025-10-20 (Actual: 6 hours)
  - 2-player pass-and-play competitive mode
  - Fair sequence replay (both players see same gestures)
  - Alternating turns with player identification
  - Individual score tracking
  - Game ends when either player fails
  - Winner determined by highest score

- [ ] **Endless Mode ⚡** (4 hours) - Deferred
  - No time limit initially
  - Time decreases 0.1s every 5 rounds
  - Minimum time floor: 1.5s

- [ ] **Zen Mode** (2 hours) - Deferred
  - 5s per gesture (vs. 3s standard)
  - No game over, practice mode
  - Stats tracking only

**Acceptance Criteria** (Partially Complete):
- [x] Mode selection in main menu
- [x] Independent high scores per mode
- [x] Persistent mode preference
- [ ] Independent leaderboards per mode (Game Center integration pending)

**Technical Notes**:
```swift
enum GameMode {
    case classic      // Bop-It style: react to prompts
    case memory       // Simon Says: memorize sequences
    case playerVsPlayer  // 2-player competitive

    var displayName: String {
        switch self {
        case .classic: return "Classic ⚡"
        case .memory: return "Memory 🧠"
        case .playerVsPlayer: return "Game vs Player vs Player 👥"
        }
    }
}
```

---

#### 1.3 Progression System - Foundation
- [ ] **Basic achievement system** (8 hours)
  - First game played
  - Reach round 5, 10, 25, 50, 100
  - Perfect round (all gestures on first try)
  - Close call (complete with <0.5s remaining)
  - Comeback (fail → continue → win 5 more rounds)

- [ ] **Streak tracking** (2 hours)
  - Daily play streak
  - Perfect streak (rounds with no mistakes)
  - Gesture-specific accuracy stats

**Acceptance Criteria**:
- Achievement notifications on unlock
- Achievement gallery in menu
- Progress tracking (e.g., "50/100 rounds reached")

---

#### 1.4 Leaderboards & Social
- [ ] **Game Center integration** (6 hours)
  - Global leaderboard (best streak)
  - Per-mode leaderboards
  - Friend leaderboards
  - Achievement sync

- [ ] **Share functionality** (3 hours)
  - Share score to social media
  - Custom share image with stats
  - "Challenge friend" link

**Acceptance Criteria**:
- One-tap share from game over screen
- Properly formatted share text
- Deep linking for challenges (future Phase 2)

---

#### 1.5 Polish & QOL
- [ ] **Sound effects** (4 hours)
  - Swipe whoosh (pitch varies by direction)
  - Success chime
  - Fail buzz
  - Countdown tick (last 1s)
  - Menu interactions

- [ ] **Settings menu** (6 hours)
  - Sound volume slider
  - Haptic toggle
  - Motion gesture toggle
  - Difficulty preset (time per gesture)
  - Color theme selection (3 themes)

- [ ] **Onboarding tutorial** (8 hours)
  - First-time user flow
  - Interactive gesture practice
  - Skippable for returning users
  - Tips system ("Swipe faster for combo bonus")

**Acceptance Criteria**:
- Settings persist across sessions
- Tutorial only shown once (unless reset)
- All sounds have volume control

---

**Phase 1 Total Effort**: 60-70 hours (~2 weeks full-time)
**Phase 1 Deliverable**: Engaging game with variety, ready for soft launch

---

### Phase 2: Progression & Monetization
**Timeline**: 3-4 weeks
**Goal**: Increase retention and establish revenue streams
**Priority**: 🟡 High Value

#### 2.1 Gesture Unlock System
- [ ] **Progression design** (12 hours)
  - Start with 4 swipes + tap only
  - Unlock schedule:
    - Round 5: Double tap
    - Round 10: Long press
    - Round 15: Shake
    - Round 25: Pinch
    - Round 35: Rotate
    - Round 50: Two-finger swipe
  - OR unlock via achievement completion
  - Practice mode for locked gestures (preview)

- [ ] **Gesture mastery system** (8 hours)
  - Track accuracy per gesture (bronze/silver/gold/platinum)
  - Mastery rewards: cosmetic unlocks
  - Mastery challenges (e.g., "Complete 10 rounds using only taps")

**Acceptance Criteria**:
- Clear unlock progress shown in menu
- Tutorial triggers on first encounter with new gesture
- Ability to re-lock gestures for challenge runs

**Monetization Hook**: Option to unlock all gestures early ($2.99 IAP)

---

#### 2.2 Daily Challenges
- [ ] **Challenge generation system** (10 hours)
  - Preset seed for daily sequence
  - Everyone gets same sequence globally
  - Bonus points for daily challenge completion
  - Streak bonuses (complete 7 days = reward)

- [ ] **Challenge leaderboard** (4 hours)
  - 24-hour global leaderboard
  - Friend rankings
  - Push notifications for friend beating your score

**Acceptance Criteria**:
- Challenges reset at midnight local time
- Rewards retroactive if played before claiming
- Clear countdown timer to next challenge

**Engagement**: Habit-forming daily ritual

---

#### 2.3 Cosmetic System - Foundation
- [ ] **Theme engine** (10 hours)
  - Arrow color customization
  - Background gradient presets
  - UI accent color
  - Particle effect styles

- [ ] **Initial cosmetic packs** (12 hours)
  - **Starter Pack** (default, free)
    - Classic arrows
    - Blue/purple gradient
    - Standard particles

  - **Neon Pack** ($1.99)
    - Glowing neon arrows
    - Black background + neon accents
    - Electric particle effects

  - **Retro Pack** ($1.99)
    - Pixel art arrows
    - CRT scanline effect
    - 8-bit sound pack

  - **Nature Pack** ($1.99)
    - Leaf/flower arrows
    - Earth tone gradients
    - Sparkle particles

- [ ] **Unlock system** (6 hours)
  - Purchase with real money
  - OR earn via in-game soft currency
  - Preview before purchase
  - Equip/unequip in settings

**Acceptance Criteria**:
- Themes persist across sessions
- No performance impact from cosmetics
- Accessible color contrast maintained

**Monetization**: $1.99 per pack, bundle of 3 for $4.99

---

#### 2.4 Advertising Integration
- [ ] **Ad SDK setup** (4 hours)
  - Google AdMob integration
  - IDFA permission handling (iOS 14.5+)
  - GDPR/CCPA compliance

- [ ] **Interstitial ads** (3 hours)
  - Show after round 5 (first game)
  - Then every 3 games or 10 minutes (whichever comes first)
  - Frequency cap: Max 1 per 3 minutes
  - Skip if user purchased remove ads

- [ ] **Rewarded ads** (4 hours)
  - "Continue playing" after game over
  - Watch ad → get one more chance (1.5x time)
  - Max 1 continue per game (prevents abuse)
  - Optional, never forced

**Acceptance Criteria**:
- Ads load in background, no lag on display
- Respect user's remove ads purchase completely
- Graceful fallback if no ad available
- Analytics tracking (impressions, clicks, revenue)

**Revenue Estimate**: $0.05-0.15 CPM, $0.50-2.00 per rewarded video

---

#### 2.5 First IAP Offering
- [ ] **IAP implementation** (8 hours)
  - StoreKit 2 integration
  - Receipt validation
  - Restore purchases flow

- [ ] **Remove Ads** ($4.99)
  - One-time purchase
  - Removes all interstitial ads
  - Keeps rewarded ads (for continue feature)
  - Prominent placement after 3rd ad shown

- [ ] **Gesture Unlock Bundle** ($2.99)
  - Unlock all current + future gestures
  - Skip progression system
  - For impatient players or accessibility

**Acceptance Criteria**:
- Purchase persists across devices (iCloud)
- Family Sharing supported
- Clear purchase confirmation
- Receipt stored securely

**Revenue Estimate**: 2-5% conversion rate on remove ads after 10 sessions

---

**Phase 2 Total Effort**: 80-90 hours (~3 weeks full-time)
**Phase 2 Deliverable**: Monetized game with progression hooks

---

### Phase 3: Social & Advanced Features
**Timeline**: 4-5 weeks
**Goal**: Viral growth and premium features
**Priority**: 🟢 Growth Driver

#### 3.1 Multiplayer - Pass & Play
- [ ] **Turn-based system** (16 hours)
  - 2-4 player support
  - Pass device between players
  - Score tracking per player
  - Winner celebration screen

- [ ] **Game mode: Alternating** (4 hours)
  - Players take turns on same sequence
  - Longest survivor wins
  - Elimination on first mistake

- [ ] **Game mode: Custom Challenge** (6 hours)
  - Player 1 creates sequence
  - Player 2 attempts to replicate
  - Role swap after each round
  - Best of 3/5/7

**Acceptance Criteria**:
- Clear whose turn it is
- Scores persist across turns
- Option to pause between turns
- Stats tracked per player profile (local)

**Engagement**: Couch co-op, party game appeal

---

#### 3.2 Multiplayer - Asynchronous
- [ ] **Challenge system** (20 hours)
  - Generate shareable link with sequence
  - Friend plays same sequence
  - Compare scores
  - Push notification when challenge completed

- [ ] **Cloud backend** (requires Firebase/Supabase)
  - Store challenge data
  - User authentication (Sign in with Apple)
  - Friend system
  - Challenge inbox

**Acceptance Criteria**:
- Works via SMS/WhatsApp/iMessage
- No account required for receiver
- Challenge expires after 7 days
- Rematch functionality

**Technical Complexity**: High (backend required)
**Consideration**: May require ongoing server costs

---

#### 3.3 Advanced Game Modes
- [ ] **Reverse Mode** (4 hours)
  - Perform sequence backwards
  - Bonus points multiplier
  - Unlocked at round 20

- [ ] **Mirror Mode** (6 hours)
  - Opposite gestures (up↔down, left↔right)
  - Tap→Double Tap, Pinch↔Spread
  - Brain-teaser difficulty

- [ ] **Chaos Mode** (8 hours)
  - Random time per gesture (1-5s)
  - Random gesture types each round
  - Power-up spawns (slow-mo, skip, rewind)

- [ ] **Boss Rush** (10 hours)
  - Every 5th round is "boss round"
  - 10+ gesture sequence
  - Reduced time (2s per gesture)
  - Special rewards on completion

**Acceptance Criteria**:
- Each mode has unique leaderboard
- Tutorial explains mode-specific rules
- Clear difficulty indication

---

#### 3.4 Power-Up System
- [ ] **Power-up design** (12 hours)
  - **Slow-Mo**: 2x time for next gesture
  - **Rewind**: Go back one gesture
  - **Skip**: Skip current gesture
  - **Shield**: Forgive one mistake
  - **Double Points**: 2x score next gesture

- [ ] **Earn mechanics** (6 hours)
  - Random spawn during gameplay (5% chance per gesture)
  - Purchase with soft currency
  - Rewarded ad grants 3 random power-ups
  - Daily login bonus

- [ ] **Usage limits** (2 hours)
  - Max 1 power-up use per round (prevents abuse)
  - Inventory system (hold up to 10)
  - Cooldown between uses

**Acceptance Criteria**:
- Power-ups don't break leaderboard fairness
- Clear visual indicator when available
- Can't be used in "Pure" mode (no power-ups)

**Monetization**: Sell power-up packs ($0.99 for 10)

---

#### 3.5 Subscription Tier
- [ ] **Subscription implementation** (10 hours)
  - StoreKit 2 auto-renewable subscription
  - Monthly ($4.99) and Annual ($39.99, 33% off)
  - Free 7-day trial
  - Cancel anytime

- [ ] **Premium benefits**
  - Ad-free experience
  - All gestures unlocked immediately
  - All current + future cosmetic packs
  - Exclusive "Premium" badge/frame
  - Early access to new features (1 week)
  - Cloud save (cross-device sync)
  - Priority support

**Acceptance Criteria**:
- Clear value proposition on paywall
- Subscription status visible in settings
- Manage subscription via App Store
- Graceful degradation on cancel

**Revenue Estimate**: 1-3% conversion, $3-5 LTV per subscriber

---

**Phase 3 Total Effort**: 100-120 hours (~4 weeks full-time)
**Phase 3 Deliverable**: Social features driving virality, premium tier

---

### Phase 4: Advanced & Experimental
**Timeline**: Ongoing post-launch
**Goal**: Differentiation and long-term engagement
**Priority**: 🔵 Innovation

#### 4.1 Motion Gestures Expansion
- [ ] Tilt left/right
- [ ] Voice commands (accessibility)
- [ ] Blow/whistle detection
- [ ] Custom gesture recording

#### 4.2 Competitive Features
- [ ] Ranked mode with ELO system
- [ ] Seasonal leaderboards
- [ ] Tournament mode
- [ ] Clan/team system

#### 4.3 Content Updates
- [ ] Monthly themed events
- [ ] Holiday cosmetic packs
- [ ] Limited-time game modes
- [ ] Crossover collaborations

#### 4.4 AI/ML Features
- [ ] Difficulty auto-adjust based on performance
- [ ] Personalized challenge recommendations
- [ ] Gesture pattern recognition for custom shapes

---

## 💰 Monetization Strategy

### Revenue Streams - Priority Ranked

#### Stream 1: Advertising (Primary Revenue - Month 1-6) 📊
**Target**: 60-70% of total revenue initially

| Ad Type | Placement | Frequency | Expected CPM | Priority |
|---------|-----------|-----------|--------------|----------|
| **Interstitial** | After game over | Every 3 games OR 10min | $5-15 | P0 |
| **Rewarded Video** | Continue after fail | User-initiated only | $15-40 | P0 |
| **Banner** | Menu screen | Persistent | $1-3 | P2 |

**Optimization**:
- Mediation platform (AdMob, IronSource)
- A/B test frequency caps
- Respect user attention (never interrupt gameplay)
- Premium placement for rewarded (70% take rate)

**Projections** (conservative):
- 10,000 DAU × 3 sessions/day × 1 ad/session × $0.01 revenue/ad = $300/day = $9K/month
- Rewarded: 10,000 DAU × 30% watch rate × $0.50/video = $1,500/day = $45K/month
- **Total Ad Revenue**: $50K+/month at scale

---

#### Stream 2: In-App Purchases (Growth - Month 3+) 💎

##### Remove Ads IAP
- **Price**: $4.99
- **Positioning**: After 3rd ad shown, or in settings
- **Value Prop**: "Enjoy Tipob ad-free forever"
- **Conversion**: 2-5% of users who see 10+ ads
- **Projection**: 10,000 users × 3% × $4.99 = $1,497 one-time + ongoing

##### Cosmetic Packs
- **Price**: $1.99 per pack, $4.99 for 3-pack bundle
- **Launch lineup**: Neon, Retro, Nature (Phase 2)
- **Expansion**: Monthly new packs
- **Conversion**: 5-10% of engaged users (>20 sessions)
- **Projection**: 10,000 engaged × 7% × $1.99 = $1,393/pack launch

##### Gesture Unlock Bundle
- **Price**: $2.99
- **Target**: Impatient users, accessibility needs
- **Positioning**: "Unlock all gestures now"
- **Conversion**: 1-2% of players stuck at unlock gate
- **Projection**: 10,000 users × 1.5% × $2.99 = $449

##### Power-Up Packs (Phase 3)
- **Price**: $0.99 for 10 power-ups
- **Target**: Competitive players, challenge runners
- **Conversion**: 3-5% of core players
- **Projection**: 5,000 core × 4% × $0.99 = $198/month (recurring)

**Total IAP Revenue**: $20-40K/month at scale

---

#### Stream 3: Subscription (Premium - Month 6+) 👑

##### Tipob Premium
| Tier | Price | Benefits | Target Audience |
|------|-------|----------|-----------------|
| **Monthly** | $4.99/mo | All Premium features | Casual trial |
| **Annual** | $39.99/yr | Same + 33% savings | Committed fans |

**Premium Benefits**:
- ✅ Ad-free experience
- ✅ All gestures unlocked
- ✅ All cosmetic packs (current + future)
- ✅ Exclusive Premium badge/theme
- ✅ Early access (1 week)
- ✅ Cloud save + cross-device sync
- ✅ Priority support

**Conversion Funnel**:
1. Free 7-day trial (requires credit card)
2. Paywall shown after 10 sessions OR when hitting unlock gate
3. Re-engagement campaigns (push notifications)

**Projections**:
- 10,000 users × 2% trial start = 200 trials/month
- 200 trials × 40% convert = 80 paying subscribers
- 80 subscribers × $4.99 = $399/month recurring
- With churn: $399 × 12 months × 60% retention = $2,875 ARR per cohort

**Year 1 Subscriber Target**: 500 subscribers = $30K ARR

---

### Monetization Roadmap

#### Phase 1 (Month 1-3): Ad Foundation
- ✅ Implement interstitial + rewarded ads
- ✅ A/B test ad frequency
- ✅ Launch "Remove Ads" IAP
- Target: $5-10K/month revenue

#### Phase 2 (Month 4-6): IAP Expansion
- ✅ Launch cosmetic packs (3 initial)
- ✅ Gesture unlock bundle
- ✅ Optimize IAP conversion funnels
- Target: $20-30K/month revenue

#### Phase 3 (Month 7-12): Premium Tier
- ✅ Launch subscription
- ✅ Build subscriber retention programs
- ✅ Monthly cosmetic drops for subscribers
- Target: $50-80K/month revenue

---

### Pricing Strategy - Psychological Considerations

#### Price Anchoring
```
Remove Ads:     $4.99 ← Anchor (most common)
Cosmetic Pack:  $1.99 ← Feels affordable by comparison
3-Pack Bundle:  $4.99 ← Same as Remove Ads, better value perception
Subscription:   $4.99/mo ← Matches Remove Ads, but recurring value
```

#### Regional Pricing
- US: Standard pricing
- Tier 2 (Europe): -10% adjustment
- Tier 3 (Latin America, Asia): -30% adjustment
- Use App Store automatic pricing tiers

#### Limited-Time Offers
- Launch week: 50% off all IAPs
- Holiday sales: $2.99 Remove Ads (vs $4.99)
- Anniversary: Free cosmetic pack for all users

---

### Monetization KPIs

| Metric | Target | Measurement |
|--------|--------|-------------|
| **ARPU** (Avg Revenue Per User) | $0.50-1.00 | Total revenue ÷ MAU |
| **ARPPU** (Avg Revenue Per Paying User) | $5-10 | Total revenue ÷ paying users |
| **IAP Conversion** | 3-7% | Paying users ÷ total users |
| **Ad Engagement** | 70%+ rewarded, 100% interstitial | Views ÷ impressions |
| **LTV** (Lifetime Value) | $2-5 | Revenue per user over 180 days |
| **Payback Period** | <30 days | Time to recover UA cost |

---

## 🛠️ Implementation Complexity Matrix

### Effort Estimation Guide
- **XS** (1-4 hours): Simple UI, basic logic
- **S** (4-8 hours): Moderate feature, some complexity
- **M** (8-16 hours): Complex feature, integration needed
- **L** (16-40 hours): Major system, multiple components
- **XL** (40+ hours): Platform feature, ongoing maintenance

---

### Gestures - Complexity Breakdown

| Gesture | Effort | Technical Dependencies | Risk Level |
|---------|--------|------------------------|------------|
| Tap | XS | SwiftUI built-in | None |
| Double Tap | XS | SwiftUI built-in | None |
| Long Press | XS | SwiftUI built-in | None |
| Two-Finger Swipe | S | Existing swipe + touch count | Low |
| Pinch | S | SwiftUI MagnificationGesture | Low |
| Rotate | S | SwiftUI RotationGesture | Low |
| **Shake** | **M** | **CoreMotion framework** | **Medium** |
| Tilt | M | CoreMotion + orientation | Medium |
| Voice Commands | M | Speech framework + permissions | Medium |
| Blow/Whistle | L | AVFoundation + audio processing | High |
| Shape Drawing | XL | Vision framework + ML | High |

**Recommendation**: Stick to XS-M complexity for Phase 1-2

---

### Features - Complexity Breakdown

#### Game Modes
| Mode | Effort | Dependencies | Priority |
|------|--------|--------------|----------|
| Endless | S | Existing game loop | P0 |
| Memory | M | Sequence hiding logic | P1 |
| Zen | XS | Timer adjustment | P1 |
| Reverse | S | Sequence reversal | P2 |
| Mirror | M | Gesture mapping | P2 |
| Chaos | L | Randomization + power-ups | P3 |
| Boss Rush | M | Special round logic | P3 |

#### Social Features
| Feature | Effort | Dependencies | Priority |
|---------|--------|--------------|----------|
| Game Center | S | Apple API | P0 |
| Share Score | S | UIActivityViewController | P0 |
| Pass & Play | M | Turn management | P1 |
| Daily Challenges | L | Backend + push notifications | P1 |
| Async Multiplayer | XL | Backend + authentication | P3 |

#### Monetization
| Feature | Effort | Dependencies | Priority |
|---------|--------|--------------|----------|
| AdMob Integration | S | SDK + privacy | P0 |
| Interstitial Ads | XS | AdMob | P0 |
| Rewarded Ads | S | AdMob | P0 |
| IAP - Remove Ads | M | StoreKit 2 | P0 |
| IAP - Cosmetics | L | Theme engine + IAP | P1 |
| Subscription | L | StoreKit 2 + backend | P2 |

---

## 📊 Revenue Projections

### Conservative Scenario (Base Case)

#### Assumptions
- Launch month: 1,000 DAU
- Month 3: 5,000 DAU (viral growth from App Store featuring)
- Month 6: 10,000 DAU (steady organic growth)
- Month 12: 15,000 DAU (word-of-mouth)

#### Revenue Model
| Month | DAU | Ad Revenue | IAP Revenue | Subscription | Total | Cumulative |
|-------|-----|------------|-------------|--------------|-------|------------|
| 1 | 1,000 | $600 | $0 | $0 | $600 | $600 |
| 2 | 2,000 | $1,800 | $200 | $0 | $2,000 | $2,600 |
| 3 | 5,000 | $6,000 | $1,500 | $0 | $7,500 | $10,100 |
| 6 | 10,000 | $15,000 | $5,000 | $2,000 | $22,000 | $75,000 |
| 12 | 15,000 | $25,000 | $10,000 | $5,000 | $40,000 | $250,000 |

**Year 1 Total Revenue**: $250K (conservative)

---

### Optimistic Scenario (With Featuring)

#### Assumptions
- App Store featuring Month 2
- Launch month: 5,000 DAU
- Month 3: 50,000 DAU (viral spike)
- Month 6: 75,000 DAU (sustained)
- Month 12: 100,000 DAU

#### Revenue Model
| Month | DAU | Ad Revenue | IAP Revenue | Subscription | Total | Cumulative |
|-------|-----|------------|-------------|--------------|-------|------------|
| 1 | 5,000 | $3,000 | $500 | $0 | $3,500 | $3,500 |
| 2 | 25,000 | $30,000 | $5,000 | $0 | $35,000 | $38,500 |
| 3 | 50,000 | $75,000 | $15,000 | $2,000 | $92,000 | $130,500 |
| 6 | 75,000 | $120,000 | $30,000 | $15,000 | $165,000 | $700,000 |
| 12 | 100,000 | $180,000 | $50,000 | $30,000 | $260,000 | $1.8M |

**Year 1 Total Revenue**: $1.8M (optimistic)

---

### Realistic Scenario (Expected)

#### Middle Ground
- Month 1: 2,000 DAU
- Month 3: 10,000 DAU
- Month 6: 20,000 DAU
- Month 12: 30,000 DAU

**Year 1 Total Revenue**: $500K-750K

---

### Cost Structure

#### Development Costs
- Solo indie dev: $0 (sweat equity)
- Freelance help (art, sound): $5,000
- Marketing: $10,000 (ASO, influencer outreach)
- **Total Dev Cost**: $15,000

#### Ongoing Costs (Monthly)
- Apple Developer Program: $99/year = $8/month
- AdMob (free)
- Backend (Firebase): $0-25 (Spark/Blaze plan)
- Cloud storage: $5-20/month
- **Total Monthly**: $15-50

#### User Acquisition (Optional)
- Apple Search Ads: $1-3 CPI
- Facebook/Instagram: $2-5 CPI
- If spending $5K/month → 1,000-2,500 installs
- Payback: 30-60 days at $2-3 LTV

**Recommendation**: Organic-first strategy, UA only after Product-Market Fit

---

## 🔧 Technical Requirements

### Phase 1 Dependencies

#### Frameworks & Libraries
```swift
// Core
import SwiftUI
import Combine

// Motion
import CoreMotion  // For shake gesture

// Audio
import AVFoundation  // For sound effects

// Persistence
import Foundation  // UserDefaults (current)

// Social
import GameKit  // Game Center leaderboards

// Analytics (recommended)
import Firebase  // Or Mixpanel
```

#### Info.plist Additions
```xml
<!-- Motion Usage -->
<key>NSMotionUsageDescription</key>
<string>Tipob uses motion detection for shake gestures in gameplay</string>

<!-- Microphone (if implementing blow gesture) -->
<key>NSMicrophoneUsageDescription</key>
<string>Tipob uses the microphone to detect blow gestures</string>

<!-- Speech Recognition (if implementing voice commands) -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>Tipob uses speech recognition for voice-controlled gestures</string>
```

---

### Phase 2 Dependencies

#### Monetization SDKs
```swift
// Ads
import GoogleMobileAds  // AdMob

// IAP
import StoreKit  // Native iOS

// Alternative: RevenueCat for subscription management
import RevenueCat
```

#### Backend Requirements
- **Option 1: Firebase** (recommended for indie)
  - Firestore: User data, challenges, leaderboards
  - Cloud Functions: Challenge generation
  - Authentication: Sign in with Apple
  - Cloud Messaging: Push notifications
  - Cost: Free tier → $25-100/month at scale

- **Option 2: Supabase** (alternative)
  - PostgreSQL database
  - Realtime subscriptions
  - Authentication
  - Cost: Free tier → $25/month Pro

- **Option 3: Serverless** (advanced)
  - AWS Lambda + DynamoDB
  - More complex, lower cost at scale
  - Requires DevOps knowledge

**Recommendation**: Firebase for Phase 2, consider migration if costs >$500/month

---

### Phase 3 Dependencies

#### Advanced Features
```swift
// ML/Vision (for shape drawing)
import Vision
import CoreML

// Speech
import Speech

// Background Audio Processing
import AVFoundation
```

#### CI/CD Setup
- **Fastlane**: Automate builds, screenshots, App Store submission
- **TestFlight**: Beta distribution
- **GitHub Actions**: Automated testing on push

---

### Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| **App Launch** | <2s | Time to interactive |
| **Frame Rate** | 60fps | During gameplay |
| **Memory** | <100MB | Peak usage |
| **Battery Drain** | <5%/hour | With motion enabled |
| **App Size** | <50MB | Download size |
| **Crash Rate** | <0.5% | Per session |

**Optimization Priorities**:
1. SwiftUI view caching
2. Motion sensor throttling (10Hz vs 60Hz)
3. Image compression for cosmetics
4. Lazy loading for packs

---

## ⚠️ Risk Assessment

### Technical Risks

#### High Risk 🔴
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Shake gesture battery drain** | High | Medium | Throttle to 10Hz, auto-disable after 5min idle |
| **Timer memory leaks** | Medium | High | Deinit cleanup, audit with Instruments |
| **IAP receipt fraud** | Medium | High | Server-side validation via RevenueCat |
| **Ad revenue volatility** | High | Medium | Diversify with IAP early |

#### Medium Risk 🟡
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **App Store rejection** | Low | High | Follow guidelines, test on device, review checklist |
| **Backend costs spike** | Medium | Medium | Implement rate limiting, usage caps |
| **Gesture false positives** | Medium | Low | Calibration settings, sensitivity adjustment |
| **Device fragmentation** | Low | Medium | Test on iPhone SE (2nd gen) as minimum |

---

### Business Risks

#### High Risk 🔴
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **No App Store featuring** | High | High | Organic growth via social sharing, influencer outreach |
| **Clone apps** | Medium | Medium | Build brand loyalty, fast iteration on feedback |
| **Market saturation** | Medium | Medium | Unique positioning (progression system, cosmetics) |

#### Medium Risk 🟡
| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Low user retention** | Medium | High | Daily challenges, progression hooks, push notifications |
| **Negative reviews** | Low | High | Beta testing, polish before launch, responsive support |
| **Monetization backlash** | Low | Medium | Generous free experience, transparent pricing |

---

### Regulatory Risks

#### Privacy & Compliance
- **COPPA**: Don't collect data from <13yr olds (age gate on first launch)
- **GDPR**: Consent for ads (IDFA), data deletion requests
- **CCPA**: California privacy rights, opt-out of data sales
- **App Tracking Transparency**: Request permission for IDFA (iOS 14.5+)

**Implementation**:
```swift
import AppTrackingTransparency

func requestTrackingPermission() {
    ATTrackingManager.requestTrackingAuthorization { status in
        switch status {
        case .authorized:
            // Enable personalized ads
        case .denied:
            // Contextual ads only
        default:
            break
        }
    }
}
```

---

## 🎯 Decision Framework

### Feature Prioritization Matrix

#### Scoring System (0-10)
1. **User Value**: Does this delight users?
2. **Business Impact**: Does this drive revenue/retention?
3. **Implementation Ease**: Can we build this quickly?
4. **Competitive Advantage**: Does this differentiate us?

#### Priority Formula
```
Priority Score = (User Value × 2) + (Business Impact × 1.5) + (Ease × 1) + (Advantage × 1.5)
```

#### Example Scoring

| Feature | User Value | Business | Ease | Advantage | **Total** | Priority |
|---------|------------|----------|------|-----------|-----------|----------|
| Tap Gesture | 8 | 6 | 10 | 2 | **43** | P0 |
| Shake Gesture | 10 | 7 | 5 | 8 | **52** | P0 |
| Daily Challenges | 9 | 9 | 4 | 7 | **51.5** | P0 |
| Voice Commands | 6 | 3 | 5 | 9 | **38** | P2 |
| Shape Drawing | 5 | 2 | 1 | 10 | **30** | P4 |

---

### Phase Gate Criteria

#### Launch Phase 1 When:
- [ ] 5+ gestures implemented (swipes + 3 new)
- [ ] 2+ game modes beyond classic
- [ ] Game Center leaderboards live
- [ ] Sound effects + settings menu
- [ ] 0 crash rate in TestFlight (50+ testers)
- [ ] Privacy compliance verified
- [ ] App Store assets complete

#### Launch Phase 2 When:
- [ ] Phase 1 retention >40% D1, >15% D7
- [ ] Ads integrated and revenue >$1K/month
- [ ] 1+ cosmetic pack available
- [ ] Progression system live
- [ ] Daily challenge system tested
- [ ] IAP conversion >2%

#### Launch Phase 3 When:
- [ ] Phase 2 MAU >10,000
- [ ] Subscription tech validated (0 receipt issues)
- [ ] Multiplayer tested with real users
- [ ] Backend costs <20% of revenue
- [ ] Support volume manageable (<10 tickets/day)

---

## 📝 Next Steps Checklist

### Immediate (This Week)
- [ ] Review this document, highlight questions
- [ ] Choose Phase 1 gesture additions (recommend: tap, double tap, shake)
- [ ] Decide on 2 game modes to prioritize (recommend: Endless, Memory)
- [ ] Set up Game Center in App Store Connect
- [ ] Create mockups for settings menu

### Short-Term (This Month)
- [ ] Implement Priority 1 fixes from code analysis
- [ ] Build Phase 1 features
- [ ] Record sound effects or commission from Fiverr ($50-100)
- [ ] Set up Firebase project for analytics
- [ ] Create TestFlight beta group (friends & family)

### Medium-Term (Next 3 Months)
- [ ] Complete Phase 1 development
- [ ] Soft launch in 1-2 countries (e.g., Canada, Australia)
- [ ] Iterate based on feedback
- [ ] Prepare App Store marketing materials
- [ ] Plan Phase 2 monetization implementation

---

## 📚 Resources & References

### Development Resources
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Game Center Best Practices](https://developer.apple.com/game-center/)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)

### Monetization Resources
- [AdMob Integration Guide](https://developers.google.com/admob/ios/quick-start)
- [RevenueCat Subscription Guide](https://www.revenuecat.com/docs/)
- [App Store Pricing Matrix](https://developer.apple.com/app-store/pricing/)

### Analytics & Growth
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [ASO Best Practices](https://developer.apple.com/app-store/search/)
- [Mobile Game Benchmarks](https://www.gamesight.io/blog/mobile-game-benchmarks)

---

## 🔄 Document Revision History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2025-10-10 | Initial scoping document | Claude Code |
| 2.0 | 2025-10-21 | Updated implementation status: 7 gestures complete (4 swipes + 3 touch), Memory Mode 🧠 and Game vs Player vs Player 👥 complete | Claude Code |

---

**Document Status**: ✅ Ready for Review
**Document Version**: 2.0
**Last Updated**: 2025-10-21
**Next Review Date**: After Phase 1 completion
**Owner**: Marc Geraldez

---

## 💬 Questions for Decision Making

Use this section to track open questions as you review:

1. **Gesture Priority**: Which 3 gestures for Phase 1?
   - [ ] Decision: __________

2. **Monetization First**: Ads or IAP first? Or both simultaneously?
   - [ ] Decision: __________

3. **Backend Choice**: Firebase vs. Supabase vs. delay until Phase 3?
   - [ ] Decision: __________

4. **Target Launch Date**: Soft launch target?
   - [ ] Decision: __________

5. **Marketing Budget**: Self-funded or seeking investment?
   - [ ] Decision: __________

---

**END OF DOCUMENT**
