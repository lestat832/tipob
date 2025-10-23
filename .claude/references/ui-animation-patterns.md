# UI & Animation Patterns Reference

**When to load this reference:**
- Working on visual animations or transitions
- Implementing countdown timers or progress indicators
- Creating gesture feedback animations
- Debugging animation timing or visual states

**Load command:** Uncomment `@.claude/references/ui-animation-patterns.md` in project CLAUDE.md

---

## Visual Animation Patterns

### Single Tap Animation Pattern

**Duration**: 600ms total
**Pulse Pattern**: 175ms + 250ms + 175ms

```swift
withAnimation(.easeInOut(duration: 0.6)) {
    opacity = 1.0
}

// Fade sequence
DispatchQueue.main.asyncAfter(deadline: .now() + 0.175) {
    withAnimation(.easeOut(duration: 0.25)) {
        opacity = 0.5
    }
}
DispatchQueue.main.asyncAfter(deadline: .now() + 0.425) {
    withAnimation(.easeIn(duration: 0.175)) {
        opacity = 0.0
    }
}
```

**Design Notes:**
- Quick fade provides instant visual feedback
- 600ms total duration feels responsive
- Three-phase animation (in → hold → out)

### Double Tap Animation Pattern

**Duration**: 375ms total
**Pulse Pattern**: 175ms + 25ms gap + 175ms

```swift
// First pulse
withAnimation(.easeInOut(duration: 0.175)) {
    opacity = 1.0
}

// 25ms gap for visual separation
DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    // Second pulse
    withAnimation(.easeInOut(duration: 0.175)) {
        opacity = 1.0
    }
}
```

**Design Notes:**
- 25ms gap provides visual separation without perceived delay
- Animation timing mirrors haptic pattern for coherent UX
- Shorter than haptic gap (75ms) due to visual perception differences
- Dual pulse clearly distinguishes from single tap

### Haptic-Visual Harmony Principle

**Discovery**: Animation timing should mirror haptic feedback patterns

**Key Insights:**
- Users perceive haptic timing differently than visual timing
- 75ms haptic gap feels equivalent to 25ms visual gap
- Coherent multi-sensory feedback improves gesture recognition
- Testing revealed perception differences between modalities

**Application:**
- Double tap: 75ms haptic gap, 25ms visual gap
- Both feel synchronized to user
- Reinforces gesture identity through multiple senses

## Component Patterns

### CountdownRing Component

**Purpose**: Circular timer visualization

**Implementation**: SwiftUI Canvas with arc drawing

```swift
struct CountdownRing: View {
    let progress: Double  // 0.0 to 1.0

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }
}
```

**Visual Features:**
- Smooth countdown animation
- Gradient coloring for visual appeal
- Line cap rounded for polished appearance
- Rotation starts from top (12 o'clock position)

### ArrowView Component

**Purpose**: Directional gesture indicators

```swift
struct ArrowView: View {
    let direction: GestureType
    let size: CGFloat

    var body: some View {
        Image(systemName: arrowSystemName)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(direction.color)
            .rotationEffect(direction.rotation)
    }

    private var arrowSystemName: String {
        switch direction {
        case .swipeUp, .swipeDown, .swipeLeft, .swipeRight:
            return "arrow.up"
        case .tap:
            return "circle.fill"
        case .doubleTap:
            return "circle.circle"
        case .longPress:
            return "circle.fill"
        }
    }
}
```

**Design Notes:**
- SF Symbols for consistent iOS appearance
- Color-coded per gesture type
- Rotation applied for directional arrows
- Symbol variations for touch gestures

## Flash Animation Patterns

### Success Flash (Green Overlay)

```swift
.overlay(
    Color.green
        .opacity(showSuccessFlash ? 0.5 : 0.0)
        .animation(.easeInOut(duration: 0.3), value: showSuccessFlash)
)
```

**Usage:**
- Correct gesture response
- Sequence completion
- Round advancement

**Duration**: 300ms (quick confirmation)

### Error Flash (Red Overlay)

```swift
.overlay(
    Color.red
        .opacity(showErrorFlash ? 0.5 : 0.0)
        .animation(.easeInOut(duration: 0.3), value: showErrorFlash)
)
```

**Usage:**
- Wrong gesture
- Timeout
- Game over

**Duration**: 300ms (immediate feedback)

## Color System Architecture

### Gesture Color Mapping

```swift
extension GestureType {
    var color: Color {
        switch self {
        case .swipeUp: return .blue
        case .swipeDown: return .green
        case .swipeLeft: return .red
        case .swipeRight: return .yellow
        case .tap, .doubleTap, .longPress: return .purple
        }
    }
}
```

**Design Principles:**
- **Unique colors for swipes** - Critical for directional recognition
- **Shared color for touch gestures** - Differentiated by animation/symbol
- **Auto-integration** - Extension-based definitions maintain clean separation
- **Gradient generation** - Adapts automatically via enum iteration

### Gradient Generation Pattern

```swift
var menuGradient: LinearGradient {
    LinearGradient(
        gradient: Gradient(colors: [.blue, .purple, .pink]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

var gameGradient: LinearGradient {
    LinearGradient(
        gradient: Gradient(colors: [.purple, .blue, .cyan]),
        startPoint: .top,
        endPoint: .bottom
    )
}
```

**Application:**
- Menu screen: Blue → Purple → Pink diagonal
- Game screen: Purple → Blue → Cyan vertical
- Consistent visual identity across views

## Screen Layout Patterns

### Launch Screen

```swift
VStack(spacing: 20) {
    Text("TIPOB")
        .font(.system(size: 64, weight: .black))
        .rotationEffect(.degrees(rotationAngle))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                rotationAngle = 360
            }
        }

    Text("Swipe to Survive")
        .font(.system(size: 24, weight: .medium))
        .opacity(0.8)
}
.background(gameGradient)
```

**Features:**
- Animated title rotation (1 second)
- Tagline for immediate context
- Auto-transition to menu after 1 second
- Gradient background for visual polish

### Gameplay Screen Layout

```swift
ZStack {
    // Full-screen gradient background
    gameGradient
        .ignoresSafeArea()

    VStack {
        // Score/round display (top)
        HStack {
            Text("Round: \(currentRound)")
            Spacer()
            Text("Score: \(score)")
        }
        .padding()

        Spacer()

        // Centered gesture display (120pt)
        GestureDisplayView(gesture: currentGesture)
            .frame(width: 120, height: 120)

        Spacer()

        // Countdown ring (bottom)
        CountdownRing(progress: timeRemaining / totalTime)
            .frame(width: 80, height: 80)
            .padding(.bottom, 40)
    }
}
```

**Design Principles:**
- **Full-screen immersion** - Gradient background fills entire screen
- **Centered focus** - Gesture display at visual center (120pt)
- **Clear HUD** - Score/round at top, countdown at bottom
- **Spacer distribution** - Even vertical spacing

## Animation Timing Standards

### Flash Animations
- **Duration**: 300ms (0.3 seconds)
- **Easing**: .easeInOut
- **Opacity**: 0.5 for visibility without complete obstruction

### Gesture Feedback
- **Single Tap**: 600ms total
- **Double Tap**: 375ms total
- **Transition Delay**: 500ms between states

### State Transitions
- **Sequence Display**: 600ms per gesture
- **Sequence Gap**: 200ms between gestures
- **Mode Transition**: 500ms fade

## Accessibility Considerations

### Visual Feedback
- High contrast colors for gesture differentiation
- Multiple feedback mechanisms (color + animation + haptic)
- Clear visual states for time remaining

### Animation Preferences
- Respect user's "Reduce Motion" settings
- Provide alternative static indicators if motion disabled
- Haptic feedback as non-visual alternative

## Performance Best Practices

### Animation Optimization
- Use `.animation()` modifier over explicit `withAnimation()` when possible
- Avoid nested animations (causes performance issues)
- Batch state changes to trigger single animation update

### Memory Management
- Cancel pending animations when view disappears
- Don't retain strong references in animation closures
- Use `[weak self]` in delayed animation blocks

---

**Last Updated**: October 21, 2025
**Extracted From**: project_knowledge_base.md, session implementation docs
