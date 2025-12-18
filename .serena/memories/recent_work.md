# Recent Work - December 2025

## Gesture Helper Text Feature
Implemented comprehensive helper text system showing gesture names below icons:
- `gesture.displayName` used for all regular gestures
- Special Stroop instruction: "Swipe toward the TEXT color (not the word)"
- Controlled via `UserSettings.showGestureNames` (default: true)
- PvP mode exempted (competitive fairness)

## Reusable Toggle Components
Created frosted glass toggle UI system:
- `SettingToggleRow` for full-width setting rows
- `FrostedToggle` with cyan neon accent when ON
- `DiscreetModeCompactToggle` with dynamic emoji (🤫/🤪)
- Uses `.ultraThinMaterial` for frosted glass effect
- Spring animations on toggle state changes

## Pattern Learned
- Files created via CLI need manual Xcode project target addition
- Parameter defaults (`var showHelperText: Bool = false`) allow backward compatibility
- Opacity-based hiding (vs conditional rendering) prevents layout shifts
