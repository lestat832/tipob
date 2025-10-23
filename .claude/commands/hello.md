# Start Session Protocol

You are starting a new work session. Follow these steps in order:

## 1. Load Session Context

**Priority 1: Read Session Index**
```
Read: claudedocs/SESSION_INDEX.md
```

This provides:
- Latest session summary
- Current implementation status
- Recent commits
- Next steps priority
- Quick reference to key files

**Priority 2: Check Git Status**
```bash
git status && git branch
```

Verify:
- Current branch
- Any uncommitted changes
- Working directory clean/dirty state

## 2. Serena Safety Check

**Check if Serena MCP is available:**

If Serena is active:
- Session memory available ✅
- Can use /sc:save and /sc:load ✅
- Automatic context persistence enabled ✅

If Serena is NOT available:
- ⚠️ Manual session tracking only
- Use local SESSION_INDEX.md for context
- Update SESSION_INDEX.md manually at session end

## 3. Smart Reference Loading

**After context loads, tell Claude what you're working on today:**

Examples:
- "Working on gesture detection features"
- "Adding new game mode"
- "Debugging animations"
- "Implementing user settings"

**Claude will automatically load appropriate reference files:**

- **Gestures** → `gesture-implementation.md`
- **Game modes** → `game-mode-patterns.md` + `swiftui-patterns.md`
- **UI/Animations** → `ui-animation-patterns.md`
- **Settings/Data** → `persistence-patterns.md` + `swiftui-patterns.md`
- **Architecture** → `swiftui-patterns.md`

**Available references** (see project CLAUDE.md for full list):
- `.claude/references/swiftui-patterns.md`
- `.claude/references/gesture-implementation.md`
- `.claude/references/game-mode-patterns.md`
- `.claude/references/ui-animation-patterns.md`
- `.claude/references/persistence-patterns.md`

## 4. Friendly Greeting

Provide a warm, helpful greeting:

```
👋 Welcome back to Tipob!

📍 Current Status:
- [Brief status from SESSION_INDEX.md]

🎯 Ready to work on:
- [User's stated goal or suggested next steps]

💡 Available references loaded based on your work focus.

Let's make progress! 🚀
```

Keep it warm, concise, and action-oriented!
