# Out of Pocket - Design Style Guide

**Version:** 1.0
**Last Updated:** January 2026
**Platform:** iOS (SwiftUI)

---

## Table of Contents
1. [Color System](#color-system)
2. [Typography](#typography)
3. [Spacing & Layout](#spacing--layout)
4. [Components](#components)
5. [Icons & Assets](#icons--assets)
6. [Animation](#animation)
7. [Design Principles](#design-principles)

---

## Color System

### Gesture Color Palette

Each gesture has a unique, vibrant color for instant recognition. This "Toy Box" palette uses saturated, playful colors.

| Gesture | Color Name | Hex | RGB | Symbol |
|---------|-----------|-----|-----|--------|
| Swipe Up | Toy Blue | `#0066FF` | 0, 102, 255 | ↑ |
| Swipe Down | Toy Green | `#00CC00` | 0, 204, 0 | ↓ |
| Swipe Left | Toy Red | `#FF0000` | 255, 0, 0 | ← |
| Swipe Right | Safety Orange | `#FF6600` | 255, 102, 0 | → |
| Tap | Toy Yellow | `#FFCC00` | 255, 204, 0 | ⊙ |
| Double Tap | Purple Pop | `#9900FF` | 153, 0, 255 | ◎ |
| Long Press | Bubble Pink | `#FF0099` | 255, 0, 153 | ⏺ |
| Pinch | Sky Blue | `#0099FF` | 0, 153, 255 | 🤏 |
| Shake | Mint Fresh | `#00FFCC` | 0, 255, 204 | 📳 |
| Tilt Left | Coral Red | `#FF3366` | 255, 51, 102 | ◀ |
| Tilt Right | Lime Blast | `#66FF00` | 102, 255, 0 | ▶ |
| Raise Phone | Electric Cyan | `#00CCFF` | 0, 204, 255 | ⬆️ |
| Lower Phone | Tangerine | `#FF9900` | 255, 153, 0 | ⬇️ |

### Background Gradients

| Name | Colors | Direction | Usage |
|------|--------|-----------|-------|
| Menu Gradient | Toy Blue → Toy Red → Toy Yellow | Vertical | Home/Menu screen |
| Launch Gradient | Purple Pop → Toy Blue → Mint Fresh | Diagonal (↘) | Launch screen |
| Classic Mode | Toy Red → Toy Blue | Diagonal (↘) | Classic gameplay |
| Game Over | Safety Orange → Toy Red | Diagonal (↘) | Game over screen |

### UI Colors

| Element | Color | Opacity | Usage |
|---------|-------|---------|-------|
| Button Background | Toy Blue `#0066FF` | 100% | Primary buttons |
| Button Text | White | 100% | Button labels |
| Success Flash | Toy Green `#00CC00` | 50% | Correct action feedback |
| Error Flash | Toy Red `#FF0000` | 50% | Wrong action feedback |
| Neon Toggle Accent | Cyan | RGB(0.4, 0.8, 1.0) | Active toggle state |
| Icon Backgrounds | White | 25% | Home screen icon circles |

### Text Opacity Hierarchy

| Level | Opacity | Usage |
|-------|---------|-------|
| Primary | 100% | Main headings, important text |
| Secondary | 85% | Quote text, descriptions |
| Tertiary | 60% | Subtitles, helper text |
| Disabled | 40% | Inactive states |
| Hint | 30% | Placeholder text |

---

## Typography

### Font Family
**SF Pro Rounded** (System Rounded Design)
All text uses the rounded variant of Apple's system font for a friendly, playful appearance.

### Type Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Display | 120pt | Bold/Black | 1.0 | Countdown numbers |
| Large Title | 72pt | Black | 1.1 | "START" text, splash |
| Title 1 | 50pt | Bold | 1.1 | Stroop words |
| Title 2 | 48pt | Bold | 1.1 | Major numbers |
| Title 3 | 28-32pt | Semibold/Bold | 1.2 | Section headers |
| Headline | 20-22pt | Semibold | 1.3 | Card titles |
| Body | 17-18pt | Medium/Semibold | 1.4 | Primary content |
| Callout | 16pt | Medium | 1.4 | Instructions |
| Subheadline | 14pt | Semibold | 1.4 | Mode labels |
| Caption | 13pt | Medium/Regular | 1.4 | Subtitles |
| Footnote | 10pt | Semibold | 1.3 | Gesture names |

### Text Styling

```
Primary Text:    White, 100% opacity
Secondary Text:  White, 60% opacity
Accent Text:     Gesture color (context-dependent)
```

---

## Spacing & Layout

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| `space-2` | 2pt | Component internals |
| `space-4` | 4pt | Tight spacing |
| `space-6` | 6pt | Related elements |
| `space-8` | 8pt | Small gaps |
| `space-10` | 10pt | Standard small |
| `space-12` | 12pt | Standard medium |
| `space-14` | 14pt | Row padding (vertical) |
| `space-16` | 16pt | Container padding |
| `space-20` | 20pt | Screen margins |
| `space-24` | 24pt | Section spacing |
| `space-40` | 40pt | Large sections |
| `space-60` | 60pt | Screen top/bottom |

### Common Padding Patterns

| Pattern | Horizontal | Vertical |
|---------|------------|----------|
| Screen Container | 20pt | 16pt |
| Settings Row | 16pt | 14pt |
| Quote Bar | 12pt | 10pt |
| Compact Elements | 10pt | 8pt |

### Corner Radius Scale

| Size | Radius | Usage |
|------|--------|-------|
| Small | 8pt | Badges, tags |
| Medium | 12pt | Quote bar, cards |
| Large | 14pt | Settings rows, cells |
| XL | 24pt | Drawers, sheets |
| Capsule | 50% | Pills, toggles |

---

## Components

### 1. CountdownRing
Circular timer visualization

- **Size:** 200 × 200pt
- **Line Width:** 10pt
- **Gradient:** Toy Blue → Purple Pop
- **Animation:** Linear, synced with timer

### 2. ArrowView / GestureIndicator
Central gesture prompt display

- **Size:** 120 × 120pt
- **Font:** 120pt Bold (for symbols)
- **Glow:** Color-matched shadow, 20-45pt radius
- **Animation:** Multiple styles (pulse, compress, vibrate, tilt)

### 3. GestureCellView
Individual gesture card in menus

- **Size:** 64pt (customizable)
- **Padding:** 10pt
- **Background:** Gesture color at 25% opacity
- **Border:** 2pt gradient stroke
- **Corner Radius:** 14pt

### 4. SettingToggleRow
Settings screen toggle item

- **Height:** Auto (content-based)
- **Padding:** 16pt horizontal, 14pt vertical
- **Corner Radius:** 14pt
- **Background:** .ultraThinMaterial (frosted glass)
- **Icon Size:** 56 × 56pt (optional)
- **Toggle Track:** 51 × 31pt
- **Toggle Thumb:** 27pt

### 5. SettingActionRow
Settings screen tappable item

- **Padding:** 16pt horizontal, 14pt vertical
- **Icon Size:** 32 × 32pt
- **Corner Radius:** 14pt
- **Background:** .ultraThinMaterial
- **Trailing:** Chevron indicator

### 6. QuoteBarView
Daily quote display at bottom of home screen

- **Padding:** 12pt horizontal, 10pt vertical
- **Corner Radius:** 12pt
- **Background:** .ultraThinMaterial
- **Text:** Footnote, white 85%
- **Shadow:** Black 20%, 4pt radius

### 7. GestureDrawerView
Bottom sheet with gesture reference

- **Height:** 50% of screen
- **Corner Radius:** 24pt (top corners)
- **Background:** .ultraThickMaterial
- **Drag Handle:** 40 × 5pt, gray 50%
- **Dismiss Threshold:** 80pt drag

### 8. Home Screen Icon Buttons
Trophy and Settings buttons on home screen

- **Circle Background:** 64 × 64pt, white 25% opacity
- **Icon Size:** 44 × 44pt
- **Shadow:** Black 30%, 4pt radius, 2pt Y offset

---

## Icons & Assets

### Gesture Icons (13 total)
All icons available at 1x, 2x, 3x resolutions in PNG format.

| Asset Name | Gesture |
|------------|---------|
| `gesture_swipe_up_default` | Swipe Up ↑ |
| `gesture_swipe_down_default` | Swipe Down ↓ |
| `gesture_swipe_left_default` | Swipe Left ← |
| `gesture_swipe_right_default` | Swipe Right → |
| `gesture_tap_default` | Tap ⊙ |
| `gesture_double_tap_default` | Double Tap ◎ |
| `gesture_long_press_default` | Long Press ⏺ |
| `gesture_pinch_default` | Pinch 🤏 |
| `gesture_shake_default` | Shake 📳 |
| `gesture_tilt_left_default` | Tilt Left ◀ |
| `gesture_tilt_right_default` | Tilt Right ▶ |
| `gesture_raise_phone_default` | Raise Phone ⬆️ |
| `gesture_lower_phone_default` | Lower Phone ⬇️ |

### UI Icons (10 total)

| Asset Name | Usage |
|------------|-------|
| `icon_home_default` | Home/Menu navigation |
| `icon_play_default` | Start/Play button |
| `icon_settings_default` | Settings access |
| `icon_share_default` | Share functionality |
| `icon_sound_default` | Sound toggle |
| `icon_trophy_default` | Leaderboard |
| `icon_question_default` | Support/Help |
| `icon_repeat_default` | Replay/Retry |
| `icon_rate_default` | Rate app (star) |
| `icon_chat_default` | Gesture names toggle |

### Icon Specifications
- **Format:** PNG with transparency
- **Sizes:** 1x, 2x, 3x (Retina)
- **Style:** Filled, colorful, playful
- **Standard Size:** 32 × 32pt (Settings), 44 × 44pt (Home)

---

## Animation

### Timing Standards

| Type | Duration | Easing |
|------|----------|--------|
| Flash (success/error) | 0.3s | ease-in-out |
| Single Pulse | 0.6s | ease-in-out |
| Double Pulse | 0.375s | ease-in-out |
| Gesture Transition | 0.5s | ease-in-out |
| Spring (UI controls) | 0.35s | spring(0.7) |

### Gesture Animation Styles

| Gesture | Animation |
|---------|-----------|
| Tap | Scale to 1.3× with glow pulse |
| Double Tap | Two 175ms pulses with 25ms gap |
| Long Press | 0.8s fill with expanding glow |
| Pinch | Shrink to 0.7× then spring bounce |
| Shake | 4 oscillations of ±10pt over 0.4s |
| Tilt | 30° rotation with spring recovery |
| Raise/Lower | Vertical slide with spring pop |

### Glow Effects

| Type | Radius | Opacity |
|------|--------|---------|
| Standard Glow | 20pt | Color at 60% |
| Intense Glow | 45pt | Color at 80% |
| Shadow | 4pt | Black at 20-30% |
| Deep Shadow | 20pt | Black at 30% |

---

## Microinteractions (Build 11+)

### Home Screen

#### 1. Floating Background Icons
Decorative gesture icons float behind the main UI layer.

| Property | Value |
|----------|-------|
| Icon Count | 8 icons |
| Icon Size | 44pt |
| Grid Spacing | 80pt (prevents bunching) |
| Opacity Range | 85-95% |
| Drift Animation | Gentle continuous float |
| Center Exclusion | 150pt radius (avoids Start button) |

#### 2. Tap-to-Scatter Effect
Tapping the home screen background causes icons to scatter outward.

| Property | Value |
|----------|-------|
| Trigger | Background tap |
| Scatter Distance | Proportional to tap distance |
| Scatter Direction | Radial from tap point |
| Animation | Spring with 0.5s duration |
| Recovery | Icons drift back over 2s |
| A11y Fallback | Opacity pulse (for Reduce Motion) |

#### 3. Start Button Breathing
The "Start Playing" button pulses continuously to draw attention.

| Property | Value |
|----------|-------|
| Animation | Scale 1.0× → 1.1× → 1.0× |
| Duration | 1.5s per cycle |
| Easing | ease-in-out |
| Repeat | Forever (autoreverses) |

#### 4. Random Icon Shake
Individual icons randomly shake to add life.

| Property | Value |
|----------|-------|
| Trigger | Timer (periodic) |
| Animation | Rotation wiggle |
| Duration | 0.3s |

### Settings Screen

#### 5. Toggle Switch Animation
Custom frosted glass toggle with neon accent.

| Property | Value |
|----------|-------|
| Track Size | 51 × 31pt |
| Thumb Size | 27pt |
| Animation | Spring (0.3s response, 0.7 damping) |
| On State | Neon cyan glow, thumb slides right |
| Off State | Gray track, thumb slides left |

#### 6. Action Row Tap Feedback
Tapping settings rows triggers haptic + visual feedback.

| Property | Value |
|----------|-------|
| Haptic | Medium impact |
| Visual | System highlight |

### Gameplay

#### 7. Countdown Overlay
3-2-1-START countdown before gameplay begins.

| Property | Value |
|----------|-------|
| Number Size | 120pt, black weight |
| Animation | Scale in with fade |
| Number Shadow | Cyan glow, 120pt radius |
| "START" Color | Toy Green |
| "START" Shadow | Green glow, 120pt radius |

#### 8. Gesture Success Flash
Green overlay flashes on correct gesture.

| Property | Value |
|----------|-------|
| Color | Toy Green (#00CC00) |
| Opacity | 50% |
| Duration | 0.3s |
| Easing | ease-in-out |

#### 9. Gesture Error Flash
Red overlay flashes on wrong gesture or timeout.

| Property | Value |
|----------|-------|
| Color | Toy Red (#FF0000) |
| Opacity | 50% |
| Duration | 0.3s |
| Easing | ease-in-out |

---

## Design Principles

### 1. Color = Recognition
Every gesture has ONE unique color. Users learn to associate colors with gestures instantly.

### 2. Playful & Vibrant
"Toy Box" aesthetic - bright, saturated, joyful colors that feel like playing.

### 3. Instant Feedback
Every action gets visual + haptic response within 100ms.

### 4. High Contrast
White text on colored/dark backgrounds. Always legible.

### 5. Consistent Materials
Frosted glass (ultraThinMaterial) for interactive overlays. Creates depth without distraction.

### 6. Motion with Purpose
Animations reinforce the gesture being performed (pulse for tap, vibrate for shake, etc.)

### 7. Accessibility First
- Minimum 44pt touch targets
- High contrast text
- Reduced motion fallbacks
- VoiceOver labels on all controls

---

## Screen Reference

### Main Screens
1. **Launch Screen** - Animated logo with gradient
2. **Home/Menu** - Mode selector, Start button, floating icons
3. **Settings** - Toggle rows and action rows
4. **Leaderboard** - High scores display
5. **Gameplay** - Gesture prompts with countdown
6. **Game Over** - Score summary, share, replay

### Settings Screen Order
1. Gesture Names (toggle)
2. Sound Effects (toggle)
3. Haptics (toggle)
4. Share Out of Pocket (action)
5. Rate Out of Pocket (action)
6. Support (action)

---

## Export Instructions

### To export icons from Xcode:
1. Open `Assets2.xcassets` in Xcode
2. Select the icon imageset
3. Right-click → "Show in Finder"
4. Copy the PNG files (1x, 2x, 3x)

### To capture screenshots:
1. Run app in iOS Simulator
2. Press `Cmd + S` to save screenshot
3. Or use `Cmd + Shift + 4` for macOS screenshot tool

### Recommended screenshot devices:
- iPhone 15 Pro (6.1")
- iPhone 15 Pro Max (6.7")

---

---

## Cross-Platform: getoutofpocket.com

**Repository:** `github.com/lestat832/oop-door-b59dd403`
**Live URL:** https://getoutofpocket.com

The website uses the **same design system** as the iOS app.

### Current Web Implementation

| Element | Value | Notes |
|---------|-------|-------|
| Background | `linear-gradient(135deg, #9900FF, #0066FF, #00FFCC)` | Purple Pop → Toy Blue → Mint Fresh |
| Primary Font | Inter (900 weight) | System fallbacks |
| Heading Size | `clamp(48px, 12vw, 120px)` | Responsive |
| Accent Colors | All 9 gesture colors as CSS variables | Same hex values as iOS |

### CSS Color Variables (already implemented)
```css
--toy-blue: #0066FF;
--toy-green: #00CC00;
--toy-red: #FF0000;
--safety-orange: #FF6600;
--toy-yellow: #FFCC00;
--purple-pop: #9900FF;
--bubble-pink: #FF0099;
--sky-blue: #0099FF;
--mint-fresh: #00FFCC;
```

### Web Features
- Floating animated dots (gesture color palette)
- Frosted glass "Coming Soon" badge
- Email capture form with confetti animation
- Colored accent bars at bottom

### Brand Consistency (Verified)

| Element | iOS | Web | Status |
|---------|-----|-----|--------|
| Gradient | Purple → Blue → Mint | Purple → Blue → Mint | ✅ Matches |
| Colors | 13 gesture colors | 9 colors (expandable) | ✅ Core matches |
| Font | SF Pro Rounded | Inter | ✅ Similar feel |
| Effects | Frosted glass | Frosted glass | ✅ Matches |

---

*This style guide documents the current implementation as of Build 12. For questions, reference the codebase or contact the development team.*
