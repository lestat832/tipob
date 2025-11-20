# Recent Work - November 2025

## Gesture Detection System Architecture (Key Discovery)

**Two different detection systems in the app:**

1. **Real Gameplay** (ClassicModeView, GamePlayView)
   - Uses `SwipeGestureModifier`
   - Velocity check: 80 px/s minimum
   - Edge buffer: 24px
   - GestureCoordinator filtering
   - More strict validation

2. **GestureTestView** 
   - Uses `applyTestGestures` modifier
   - Simple DragGesture with only distance check
   - No velocity, edge, or coordinator checks
   - More forgiving

**Implication:** Gestures passing in tester may fail in real gameplay due to stricter validation.

## Debug Tips for Gesture Issues
- Check Xcode console for "⏸️ Swipe suppressed" (GestureCoordinator)
- Check for "🎯 Swipe detected" (successful detection)
- If neither appears, swipe failed distance/velocity/edge checks
- Dev Panel has sliders to adjust thresholds in real-time

## Common Issues
- Slow swipes rejected (velocity < 80px/s)
- Swipes near screen edge rejected (within 24px)
- GestureCoordinator stale state from Tutorial mode
- Race conditions when isRecording state not properly initialized
