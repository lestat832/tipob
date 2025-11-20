# Recent Work - Audio Simplification & Rebranding

## Session: November 19, 2025

### Major Achievement: Audio System Overhaul

**Problem Solved:** Multiple audio issues (hang, warbled failure sound, no countdown)

**Root Causes Identified:**
1. AVAudioEngine + stop-all-before-failure logic caused warbled system sounds
2. initQueue.sync was blocking main thread
3. Countdown timing was off and not desired

**Solution: Dramatic Simplification**
- Removed AVAudioEngine entirely
- Removed countdown feature
- Direct SystemSoundID for failure (no interference)
- Explicit initialize() pattern

**Key Lesson:** Sometimes the solution is to remove complexity, not add more fixes. The original SoundManager worked because it was simple. We over-engineered with AVAudioEngine and broke what worked.

### Rebranding: TIPOB → Out of Pocket

**Launch Screen:**
- Stacked title: "OUT OF" / "POCKET"
- Spring scale animation
- Smooth fade-out before transition

**Menu Screen:**
- Removed title (shown on launch)
- Improved fade transition (0.6s)

### Patterns Learned

**Audio Session Conflicts:**
- Only ONE class should configure AVAudioSession
- System sounds (SystemSoundID) are affected by AVAudioSession state
- Simpler is often better for audio

**SwiftUI Transition Timing:**
- Animation duration must match state change timing
- Coordinated fade-out before state change creates smooth transitions
- 0.3s is too fast for launch transitions, 0.6s feels natural

**Debugging Approach:**
- When fixes don't work, question the entire approach
- User feedback about "just use what worked before" is valuable
- Sometimes you need to undo complexity to fix issues