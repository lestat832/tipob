# Recent Work Highlights

## November 14, 2025 - Landing Page Deployment (Root Strategy)

**Accomplishment:** Successfully deployed Out of Pocket landing page to GitHub Pages using root directory deployment.

**Key Learning:** GitHub Pages folder restrictions - only `/` (root) or `/docs` are supported. The `/dist` folder (Vite's default output) is not an option. This is a common gotcha when deploying Vite/React apps to GitHub Pages.

**Solution Patterns:**
1. **Root Deployment** (chosen): Copy `dist/*` to repository root → Deploy from `/`
   - Pros: Simple, no config changes
   - Cons: Mixes build files with source files
   
2. **Docs Deployment** (alternative): Configure Vite to build to `docs/` → Deploy from `/docs`
   - Pros: Cleaner separation
   - Cons: Requires vite.config.ts changes

**Technical Challenge Resolved:** Git rebase conflict when remote had auto-updates from Lovable platform. Successfully handled with `git pull --rebase` and re-pushed.

## Session Pattern: Motion-to-Touch Grace Period (Previous Session)

Implemented DEBUG-only grace period feature in Tipob iOS game for motion gesture → touch gesture transitions:
- Added `motionToTouchGracePeriod` (0.5s) to DevConfigManager
- Applied in all game modes (Memory, Classic, PvP)
- Tracked via `MotionGestureManager.shared.lastDetectedWasMotion` flag
- Live-tunable via Admin Dev Panel

**Key Insight:** Grace periods compensate for inherent latency when switching input modalities (accelerometer → touchscreen).
