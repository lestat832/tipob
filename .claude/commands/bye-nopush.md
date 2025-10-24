---
description: End session with context save (local commits only, no push)
tags: [session, workflow, gitignored]
---

# End Session Protocol (No Push)

You are ending a work session. Follow these steps in order:

## 1. Save Session Context to Serena Memory

Use Serena MCP tools to persist session state:

```javascript
// Save current session summary
await mcp__serena__write_memory({
    memory_name: 'current_session.md',
    content: `
# Session Summary - ${new Date().toISOString().split('T')[0]}

## Completed Tasks
- [List completed work]

## In Progress
- [Current status of ongoing tasks]

## Next Session
- [Priority tasks for next time]

## Key Decisions
- [Important decisions made]

## Blockers/Issues
- [Any blockers encountered]
`
})

// Save recent work highlights
await mcp__serena__write_memory({
    memory_name: 'recent_work.md',
    content: '[Brief summary of recent accomplishments and patterns learned]'
})
```

## 2. Optimize Reference Loading for Next Session

For projects with `.claude/references/`, update project CLAUDE.md based on today's work:

**Work Type → Keep Loaded:**
- **UI/Component work** → Uncomment `component-patterns.md`, comment others
- **Subscription/Payment** → Uncomment `subscription-patterns.md`, comment others
- **API/Backend** → Uncomment `api-patterns.md`
- **Form building** → Uncomment `form-patterns.md`
- **Mobile/Responsive** → Uncomment `mobile-responsive.md` + `component-patterns.md`
- **General dev** → Comment all references (core CLAUDE.md sufficient)

**Action:** Edit project CLAUDE.md "Reference Documentation" section to optimize for next session.

## 3. Quick Context Health Check

**Only report if issues found:**

```bash
# Check CLAUDE.md size (if project has one)
wc -c CLAUDE.md 2>/dev/null
# ✅ <15K: Optimal | ⚠️ 15K-20K: Consider extraction | 🚨 >20K: Immediate extraction needed

# Check for deprecated patterns
grep -r "DEPRECATED\|TODO: remove\|OUTDATED" .claude/references/ CLAUDE.md 2>/dev/null
```

**Report Format:**
- All checks pass: "✅ Context health: Optimal"
- Issues found: List specific warnings with recommendations
- No CLAUDE.md: Skip silently

## 4. Commit Changes Locally (NO PUSH)

If there are any changes in the git working directory:

```bash
git status  # Review changes first

git add .

git commit -m "$(cat <<'EOF'
[type]: [description]

[optional detailed changes]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# DO NOT PUSH - Keep commits local only
```

## 5. Friendly Goodbye

Provide a warm, encouraging sign-off:

```
🎉 Great work today!

✅ Completed:
- [key accomplishments]

⏭️  Next session:
- [next tasks]

💾 Session saved and changes committed locally (not pushed to remote)

🌙 Rest well! Your progress is saved and ready to pick up exactly where you left off.

Use /hello when you return! 👋
```

Keep it warm, concise, and motivating!
