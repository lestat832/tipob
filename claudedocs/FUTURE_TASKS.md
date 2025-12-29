# Future Tasks & Technical Debt

## High Priority Refactor: PvP State Management

### Problem
PvP modes (GameVsPlayerVsPlayerView, PlayerVsPlayerView) manage game state locally in the View using `@State`, while Classic/Memory modes correctly use ViewModel state. This architectural inconsistency causes:
- State scattered across views
- Harder to test
- Analytics calls in Views instead of ViewModel
- Inconsistent patterns across codebase

### Current State
- **Classic/Memory (correct)**: State lives in `GameViewModel` via `classicModeModel` and `gameModel`
- **PvP modes (needs refactor)**: State lives locally in Views via `@State` properties

### Recommended Fix
1. Create `PvPModeModel` struct in `Models/`
2. Create `GameVsPvPModeModel` struct in `Models/`
3. Add `@Published var pvpModeModel: PvPModeModel` to GameViewModel
4. Add `@Published var gameVsPvpModeModel: GameVsPvPModeModel` to GameViewModel
5. Migrate local `@State` from PvP views to these models
6. Update PvP views to read from ViewModel instead of local state

### Files Affected
- `Tipob/Views/GameVsPlayerVsPlayerView.swift` (~700 lines)
- `Tipob/Views/PlayerVsPlayerView.swift` (~800 lines)
- `Tipob/ViewModels/GameViewModel.swift`
- New: `Tipob/Models/PvPModeModel.swift`
- New: `Tipob/Models/GameVsPvPModeModel.swift`

### Effort Estimate
Medium-Large refactor - involves moving significant state logic

### Added
December 10, 2025

---

## Monetization: Rewarded Ad Continue

### Feature
Add a "Continue (Watch Ad)" button on game over that lets players revive and keep playing.

### Value Proposition
Turns frustration into optional value exchange instead of forced interruption.

### Details
- **Button**: "Continue (Watch Ad)" appears on game over screen
- **Reward**: 1 revive to continue the current run
- **Limit**: Max 1 continue per run (prevents infinite continues)

### Mode-Specific Mechanics (TBD)
- **Classic**: Reset timer for current round
- **Memory**: Retry the failed gesture (sequence stays same)
- **PvP modes**: May not be applicable (competitive fairness)

### Implementation Requirements
1. Add Google AdMob rewarded ad integration (separate from interstitial)
2. Track `hasUsedContinue` flag per run in GameViewModel
3. Add Continue button to GameOverView (conditional on flag)
4. Implement revive logic per mode
5. Hide button after first use in a run

### Files Affected
- `Tipob/Utilities/AdManager.swift` - Add rewarded ad loading/showing
- `Tipob/Views/GameOverView.swift` - Add Continue button
- `Tipob/ViewModels/GameViewModel.swift` - Track continue usage, revive logic
- `Tipob/Models/ClassicModeModel.swift` - Revive state handling
- `Tipob/Models/GameModel.swift` - Revive state handling

### Effort Estimate
Medium - Requires new ad format integration + game state revive logic

### Added
December 29, 2025
