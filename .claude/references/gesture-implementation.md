# Gesture Implementation Reference

**When to load this reference:**
- Implementing or debugging gesture detection
- Adding new gesture types
- Troubleshooting gesture conflicts or timing
- Working on haptic feedback

**Load command:** Uncomment `@.claude/references/gesture-implementation.md` in project CLAUDE.md

---

## Gesture System Overview

### Supported Gestures (7 Total)

```swift
enum GestureType: String, CaseIterable {
    case swipeUp      // Blue ↑
    case swipeDown    // Green ↓
    case swipeLeft    // Red ←
    case swipeRight   // Yellow →
    case tap          // Purple ⊙
    case doubleTap    // Purple ◎
    case longPress    // Purple ⏺
}
```

### Color Scheme (Visual Differentiation)

| Gesture | Color | Symbol | Detection Method |
|---------|-------|--------|------------------|
| Up | Blue | ↑ | DragGesture + angle calc |
| Down | Green | ↓ | DragGesture + angle calc |
| Left | Red | ← | DragGesture + angle calc |
| Right | Yellow | → | DragGesture + angle calc |
| Tap | Purple | ⊙ | TapGesture with disambiguation |
| Double Tap | Purple | ◎ | TapGesture with 300ms window |
| Long Press | Purple | ⏺ | LongPressGesture (600ms) |

**Design Notes:**
- Unique colors per gesture critical for recognition
- Tap, Double Tap, Long Press share color (differentiated by animation/timing)
- Gradient generation adapts automatically via enum iteration

## Double Tap Detection Implementation

### Core Pattern: DispatchWorkItem for Cancellable Delayed Execution

```swift
private func handleTap() {
    tapWorkItem?.cancel()
    tapCount += 1

    if tapCount == 1 {
        // Wait 300ms to see if second tap arrives
        tapWorkItem = DispatchWorkItem { [weak self] in
            self?.processSingleTap()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: tapWorkItem!)
    } else if tapCount == 2 {
        // Second tap detected - cancel single tap and process double
        tapWorkItem?.cancel()
        processDoubleTap()
        tapCount = 0  // Reset for next sequence
    }
}
```

### Key Design Decisions

**Detection Window: 300ms (Optimal Balance)**
- **Shorter (200ms)**: Misses legitimate double taps
- **Longer (400ms+)**: Creates sluggish single tap response
- **300ms**: Sweet spot for accuracy and responsiveness

**Cancellation Pattern:**
- DispatchWorkItem allows clean cancellation
- Prevents race conditions between single and double tap processing
- Weak self prevents retain cycles

**State Management:**
- `tapCount` tracks taps within detection window
- Reset to 0 after processing double tap
- Shared state requires careful management

### Scaling Pattern

Pattern scales well for triple tap or multi-tap gestures:
```swift
if tapCount == 3 {
    tapWorkItem?.cancel()
    processTripleTap()
    tapCount = 0
}
```

## Swipe Detection Implementation

### SwipeGestureModifier Pattern

**Detection Method**: DragGesture with angle calculation

```swift
.gesture(
    DragGesture(minimumDistance: 50)
        .onEnded { value in
            let angle = atan2(value.translation.height, value.translation.width)
            let degrees = angle * 180 / .pi

            if degrees >= -45 && degrees < 45 {
                handleSwipe(.right)
            } else if degrees >= 45 && degrees < 135 {
                handleSwipe(.down)
            } else if degrees >= -135 && degrees < -45 {
                handleSwipe(.up)
            } else {
                handleSwipe(.left)
            }
        }
)
```

**Parameters:**
- **Minimum Distance**: 50 pixels
- **Angle Zones**: 90° quadrants for 4 directions
- **Edge Buffer**: 24 pixels (prevents accidental edge swipes)

## Gesture Coexistence Pattern

### Problem: Gesture Conflicts

Tap and swipe gestures can conflict without proper coordination.

### Solution: `.simultaneousGesture()`

```swift
view
    .simultaneousGesture(
        TapGesture()
            .onEnded { handleTap() }
    )
    .simultaneousGesture(
        DragGesture(minimumDistance: 50)
            .onEnded { value in handleSwipe(detectDirection(value)) }
    )
```

**Benefits:**
- Both gestures can detect without blocking each other
- System intelligently routes to appropriate handler
- No false positives from gesture interference

## Haptic Feedback Patterns

### Centralized Pattern: HapticManager

```swift
// Single Tap: 1 pulse
HapticManager.shared.playSuccessFeedback()

// Double Tap: 2 pulses with 75ms gap
HapticManager.shared.playDoubleTapFeedback()
```

### Timing Rationale

**75ms Gap (Optimal for Double Tap):**
- **50ms**: Feels like single pulse (too short)
- **75ms**: Clear differentiation, responsive feel ✓
- **100ms**: Feels disconnected (too long)

### Haptic-Visual Harmony Principle

**Discovery**: Animation timing should mirror haptic feedback patterns

- Users perceive haptic timing differently than visual timing
- 75ms haptic gap feels equivalent to 25ms visual gap
- Coherent multi-sensory feedback improves gesture recognition
- Testing revealed perception differences between modalities

## Visual Animation Patterns

### Single Tap Animation
**Duration**: 600ms total
**Pulse Pattern**: 175ms + 250ms + 175ms

```swift
withAnimation(.easeInOut(duration: 0.6)) {
    opacity = 1.0
}
```

### Double Tap Animation
**Duration**: 375ms total
**Pulse Pattern**: 175ms + 25ms gap + 175ms

```swift
withAnimation(.easeInOut(duration: 0.175)) {
    opacity = 1.0
}
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    withAnimation(.easeInOut(duration: 0.175)) {
        opacity = 1.0
    }
}
```

**Design Notes:**
- 25ms gap provides visual separation without perceived delay
- Animation timing mirrors haptic pattern for coherent UX
- Shorter than haptic gap due to visual perception differences

## Long Press Implementation

### Detection Parameters

```swift
.onLongPressGesture(minimumDuration: 0.6) {
    handleLongPress()
}
```

**Timing: 600ms (0.6 seconds)**
- Short enough to feel responsive
- Long enough to avoid accidental triggers
- Balances with double tap 300ms window

## Common Issues & Solutions

### Issue: Double Tap Not Detected

**Symptoms:**
- Second tap not registering as double tap
- Always processing as two single taps

**Solutions:**
1. **Check detection window** (300ms is optimal)
2. **Verify DispatchWorkItem cancellation** logic
3. **Reset tapCount** after processing double tap
4. **Test on physical device** (simulator timing differs)

```swift
// Ensure proper reset
else if tapCount == 2 {
    tapWorkItem?.cancel()
    processDoubleTap()
    tapCount = 0  // ← Critical reset
}
```

### Issue: Single Tap Feels Sluggish

**Symptom**: Noticeable delay before single tap registers

**Cause**: Detection window too long (>300ms)

**Solution**: Keep window at 300ms or reduce slightly to 250ms

**Trade-off**: Shorter window increases missed double taps

### Issue: Haptic Feedback Unclear

**Symptom**: Can't distinguish single vs double tap haptics

**Solution**: Check HapticManager gap timing (75ms optimal)

**Testing**: Physical device required (simulator doesn't support haptics)

### Issue: Gesture Conflicts

**Symptom**: Swipes triggering as taps or vice versa

**Solution**: Use `.simultaneousGesture()` for coexistence

**Alternative**: Adjust minimum swipe distance if too sensitive

### Issue: Fast Alternating Taps

**Symptoms:**
- Rapid single/double tap sequences causing confusion
- Triple+ taps not resetting properly

**Solution**: Implement timeout reset for tap sequences

```swift
// Reset tapCount after 500ms of no taps
resetWorkItem = DispatchWorkItem { [weak self] in
    self?.tapCount = 0
}
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: resetWorkItem!)
```

## Edge Cases & Boundary Conditions

### Testing Checklist

- [ ] **Fast alternating single/double taps** - No state confusion
- [ ] **Rapid tap sequences** (triple+ taps) - Proper reset
- [ ] **Interrupted double taps** - Single tap after 300ms works
- [ ] **Boundary conditions** - Exactly 300ms tap spacing handled
- [ ] **Gesture conflicts** - Tap + swipe coexistence
- [ ] **Physical device testing** - Simulator timing differs from hardware

## Performance Considerations

### Gesture Detection Latency
- Target: <100ms response time
- SwiftUI gestures are hardware-accelerated
- Avoid heavy computation in gesture handlers

### Memory Management
- Use `[weak self]` in DispatchWorkItem closures
- Cancel pending work items when view disappears
- Clean up gesture recognizers on view dealloc

---

**Last Updated**: October 21, 2025
**Extracted From**: project_knowledge_base.md, session implementation docs
