# Recent Work - January 2026

## Build 11 Features
- Home screen microinteractions with floating gesture icons
- Share Score MVP with proper player name display

## Key Patterns Learned
- Grid-based placement prevents icon bunching
- Centralized Timer in ViewModel better than per-view timers
- App icons require Info.plist bundle lookup, not UIImage(named:)
- ObservableObject class pattern for individual icon animation state

## Files Modified
- `Tipob/Components/HomeIconField.swift` - New animated background
- `Tipob/Views/MenuView.swift` - Integrated HomeIconField
- `Tipob/Utilities/ShareSheet.swift` - Fixed app icon loading
- `Tipob/Views/GameVsPlayerVsPlayerView.swift` - Fixed winner name
- `Tipob/Views/PlayerVsPlayerView.swift` - Fixed winner name
