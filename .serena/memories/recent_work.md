# Recent Work - December 29, 2025

## Ad Gating System (Simplified)
Replaced complex multi-condition ad gating with simple cooldown-based approach:
- `sessionMinAge`: 30s grace period after app launch
- `adCooldown`: 60s between any ads
- `AdTrigger` enum: .home and .playAgain cases
- Method: `shouldShowInterstitial(trigger:runDuration:)`

## UI Polish
- Custom `icon_repeat_default` asset for Play Again buttons
- Discreet Mode popup: "Hides all motion gestures. Only touch gestures remain — perfect for playing in public."
- Shortened game mode descriptions

## Version 3.8 Released
- Documentation updated: PRODUCT_OVERVIEW.md and feature-scoping-document.md
- Build 10 ready for TestFlight

## Patterns Learned
- AdManager uses test ads for DEBUG/TestFlight, production for App Store
- PvP views need to set lastRunDuration before clearing gameStartTime
- UI text should be punchy and clear (one sentence per mode)
