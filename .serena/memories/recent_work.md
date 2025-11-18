# Recent Work - Audio System Implementation

## Session: November 18, 2025

### Major Achievement: Complete Audio System

Successfully implemented comprehensive audio system for Out of Pocket game:

**Sound Types Implemented (4 total):**
1. Success tick (45-70ms) - After each correct gesture
2. Round complete chime (180-300ms) - Sequence completion/milestones
3. Countdown beeps (3-2-1-GO) - Pitch-shifted (600-850Hz)
4. Failure sound (SystemSoundID 1073) - Wrong gesture/timeout

**Key Learning: Audio Integration Performance**

**Problem encountered:** Initial implementation caused app launch hang (0.28-0.43s)
- AudioManager singleton initialized during app launch
- AVAudioSession + AVAudioEngine + file preloading blocked main thread

**Solution:** Lazy initialization pattern
- Empty init() - no blocking on launch
- ensureInitialized() called on first use
- Thread-safe with DispatchQueue

**Lesson:** Always consider lazy initialization for singletons that perform expensive setup (audio, networking, ML models).

**Key Learning: Audio Session Conflicts**

**Problem encountered:** Failure sound quality changed after integration
- Two classes (SoundManager + AudioManager) configuring same shared AVAudioSession
- Conflicting options: .mixWithOthers vs .mixWithOthers + .duckOthers
- SystemSoundID playback affected by session state

**Solution:** Consolidate to single audio system
- Delete redundant SoundManager
- AudioManager as single source of truth for audio session config

**Lesson:** Only one class should configure AVAudioSession in an app. Multiple configs create unpredictable behavior.

## Patterns Learned

**SwiftUI Layout Debugging:**
- Large center elements can push side elements off screen
- Always consider element size relative to screen width
- Test on smallest target device (iPhone SE) first

**Audio File Management:**
- CAF format preferred for iOS (native Core Audio Format)
- Preload small files (<1MB) for zero-latency playback
- Use AVAudioEngine for effects (pitch shifting, reverb, etc.)
- Use AVAudioPlayer for simple playback
- Use SystemSoundID for system sounds (respects silent mode)

**Swift Concurrency:**
- Task {} for async operations without blocking
- await Task.sleep() for delays in async context
- MainActor.run {} for UI updates from async context