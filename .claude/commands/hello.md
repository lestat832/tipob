---
description: Start session with friendly greeting and context load
tags: [session, workflow, gitignored]
---

# Start Session Protocol

You are beginning a new work session. Follow these steps in order:

## 1. Warm Greeting
Provide a friendly, energetic welcome message

## 2. Load Previous Session Context
Use Serena MCP tools to restore previous session state:

```javascript
// List available session memories
const memories = await mcp__serena__list_memories()

// Read relevant session context
const sessionMemory = await mcp__serena__read_memory({ memory_file_name: 'current_session.md' })
const recentWork = await mcp__serena__read_memory({ memory_file_name: 'recent_work.md' })
```

**If memories are found:**
- Restore previous session context
- Identify where we left off
- Load task progress

**If no memories found:**
- This is a fresh start
- Fallback to reading claudedocs/SESSION_INDEX.md
- Initialize new session context

## 3. Session Briefing
After loading completes, provide:
- Quick recap of where we left off (if applicable)
- Current status/progress
- What's next on the agenda
- Ask what the user wants to work on

**Smart Reference Loading:**
For Tipob project with `.claude/references/`, ask user what they're working on:
- "Working on gestures" → Load gesture-implementation.md
- "Working on game modes" → Load game-mode-patterns.md + swiftui-patterns.md
- "Working on UI/animations" → Load ui-animation-patterns.md
- "Working on settings/data" → Load persistence-patterns.md + swiftui-patterns.md
- "General dev/bug fixes" → Core CLAUDE.md is sufficient

**Available references** (see project CLAUDE.md for full list):
- `.claude/references/swiftui-patterns.md`
- `.claude/references/gesture-implementation.md`
- `.claude/references/game-mode-patterns.md`
- `.claude/references/ui-animation-patterns.md`
- `.claude/references/persistence-patterns.md`

## Example Hello Format

```
👋 Welcome back to Tipob!

🔄 Loading your previous session...

[Check Serena memories or SESSION_INDEX.md]

📍 Where we left off:
- [brief context from session memory]

✅ Completed: [X/Y tasks]
⏳ In Progress: [current phase]

🎯 Ready to continue with:
- [next logical task]

What would you like to work on today?
```

Keep it energetic, clear, and action-oriented!
