# Recent Work - November 2025

## Latest Session (2025-11-03)

### Crisis Recovery and Strategic Reset
**Problem**: Touch gesture detection completely broke after attempting to fix partial screen blocking
- Added `.allowsHitTesting(false)` to 10+ locations across 8 files
- Lost track of cause and effect
- "System gesture gate timed out" errors - nothing detecting
- Overcomplicated solution broke working baseline

**Solution**: Strategic git reset to commit 304ce8d (last working build)
- Reverted 3 commits (23e7242, 35f4a59, 0cb3166)
- Lost MotionGestureManager but regained working baseline
- Verified all 14 gestures working correctly

### Critical Lessons for Future Development
1. **Incremental Testing is Non-Negotiable**
   - Test after EACH change, not batch changes
   - Don't assume fixes work - verify immediately
   - Physical device testing for motion gestures

2. **Hit Testing Complexity**
   - `.allowsHitTesting(false)` on visual elements = touches pass through
   - UIKit gesture recognizers need `.allowsHitTesting(true)` on their container
   - Making children transparent doesn't require transparent parent
   - Container transparency when all children transparent = total failure

3. **When to Revert vs Fix Forward**
   - If lost track of changes: REVERT
   - If baseline broke: REVERT IMMEDIATELY
   - Preserve working state over preserving broken complexity

### Rebuild Strategy Defined
**Phase 1**: MotionGestureManager rebuild (full rewrite with lessons learned)
**Phase 2**: Classic Mode integration only (single mode first)
**Phase 3**: Expand to other modes one at a time (Memory, PvP, etc.)
**Phase 4**: Layout polish (optional, low priority)

### Key Patterns Learned
- MotionGestureManager architecture was solid (354 lines of good design)
- Centralized motion isolation prevents gesture conflicts
- stopAllOldGestureManagers() essential for CMMotionManager cleanup
- Touch gestures should remain always-active
- Wrong gesture type during motion expectation = immediate fail

## Previous Sessions

### October 2025 Highlights
- Added 7 new gestures (shake, tilt, raise, lower, pinch, stroop, discreet mode)
- Implemented 3 complete game modes (Classic, Memory, PvP)
- Created comprehensive product documentation
- Established session management workflow with Serena MCP
- Fixed double-tap detection (300ms window with DispatchWorkItem)

### Architecture Strengths
- MVVM pattern clean and maintainable
- CaseIterable auto-integration for new gestures
- Separate model files per game mode (good separation)
- Custom view modifiers for gesture composability

### Known Working Baseline (304ce8d)
- 14 gestures all functional
- 3 game modes operational
- Tutorial mode working
- No CMMotionManager conflicts at this commit
- Touch gestures detect reliably
