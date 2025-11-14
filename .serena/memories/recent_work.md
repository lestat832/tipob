# Recent Work Highlights

## November 14, 2025 - Landing Page Deployment

**Accomplishment:** Successfully deployed Out of Pocket landing page to GitHub Pages using local build workflow.

**Key Learning:** Vite/React apps require compilation before GitHub Pages deployment - can't serve source files directly. The `base` path configuration in vite.config.ts is critical for subpath deployments.

**Pattern Established:** 
- Local build workflow: Clone → Update config → Install → Build → Commit → Push → Configure Pages
- Alternative to GitHub Actions when simpler manual approach preferred

## Recent Pattern: Motion-to-Touch Grace Period (Previous Session)

Implemented DEBUG-only grace period feature in Tipob iOS game for motion gesture → touch gesture transitions:
- Added `motionToTouchGracePeriod` (0.5s) to DevConfigManager
- Applied in all game modes (Memory, Classic, PvP) 
- Tracked via `MotionGestureManager.shared.lastDetectedWasMotion` flag
- Live-tunable via Admin Dev Panel

**Key Insight:** Grace periods help with inherent latency when switching input modalities (accelerometer → touchscreen).
