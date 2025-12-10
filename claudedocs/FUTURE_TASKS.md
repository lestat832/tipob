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
