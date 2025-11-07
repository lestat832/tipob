# Recent Work Highlights - January 2025

## Latest Accomplishments (Jan 6)

### UI/UX Improvements
- Fixed menu alignment issues (game mode pill, discreet toggle, leaderboard)
- Removed instruction text clues that broke memory challenge gameplay
- Improved Stroop screen consistency (arrow/label ordering)

### Gesture Detection Analysis
- Completed comprehensive pipeline analysis (44 files surveyed)
- Identified dual root cause: 60% timing issues, 40% tolerance issues
- Documented 13+ tolerance parameters and 50+ timing delays
- Created 3-tier improvement plan (quick wins → architecture → framework)

## Patterns Learned

### SwiftUI Layout Fixes
- `.fixedSize(horizontal: true, vertical: false)` - Prevents text truncation while maintaining height constraints
- `.frame(height: 44)` - Standard for consistent button/pill alignment
- Order matters: fixedSize → padding → frame → background

### Gesture Detection Architecture
- **Centralized management wins**: Old independent managers create conflicts
- **Sensor rate matters**: iOS supports 50-60 Hz, using only 10-30 Hz leaves performance on table
- **Main thread is precious**: Move sensor processing to background queue
- **Timing vs Tolerance**: Measure before tuning - timing issues mask tolerance problems

### Debugging Complex Systems
- Use comprehensive analysis before quick fixes
- Instrument pipeline to identify bottlenecks
- Consider both code (tolerance) and timing (latency) issues
- Build diagnostic tools to make problems visible

## Key Technical Insights

1. **CMMotionManager conflicts**: Only one instance should exist per app, multiple compete for hardware
2. **SwiftUI rendering lag**: 16-33ms per render cycle affects gesture detection on main thread
3. **Animation overhead**: 24+ scheduled animations per gesture congests main thread
4. **Timer precision**: 100ms granularity insufficient for sub-second countdowns

## Common Pitfalls Avoided

- ❌ Don't give UI clues during memory challenges (defeats purpose)
- ❌ Don't tune tolerance before fixing timing issues (masks root cause)
- ❌ Don't delete code still referenced elsewhere (check dependencies first)
- ✅ Do use generic encouraging text ("Go!") instead of revealing hints
- ✅ Do measure before optimizing (instrumentation reveals truth)
- ✅ Do fix architecture before fine-tuning parameters

## Next Focus Areas

1. Gesture detection optimization (user to choose quick vs comprehensive approach)
2. Physical device testing (motion gestures require real hardware)
3. Metrics collection (measure improvement objectively)
