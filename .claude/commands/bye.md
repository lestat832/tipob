# End Session Protocol

You are ending a work session. Follow these steps in order:

## 1. Optimize Context

### 1a. Review and Update Todos
- Mark any completed items as done
- Create/update session summary in `claudedocs/` if significant work was done
- Document key decisions and issues resolved

### 1b. Optimize Reference File Loading
- If you loaded multiple references this session, note which were actually useful
- Suggest removing unused references from CLAUDE.md if they weren't needed

### 1c. Daily Context Health Check
Run lightweight health checks every session (only report issues):

**Quick File Size Audit:**
```bash
wc -c CLAUDE.md
```

- ✅ <15K: Optimal
- ⚠️ 15K-20K: "Consider extracting more patterns to references"
- 🚨 >20K: "CLAUDE.md bloat detected - immediate extraction recommended"

**Check reference file sizes:**
```bash
wc -c .claude/references/*.md
```

- ⚠️ If any single reference >10K: "Consider splitting [filename] into smaller references"

**Deprecated Pattern Detection:**
```bash
grep -r "DEPRECATED\|TODO: remove\|OUTDATED" .claude/references/ CLAUDE.md
```

- If found: "⚠️ Found deprecated patterns - schedule cleanup"

**Report Format:**
- If all checks pass: "✅ Context health: Optimal"
- If issues found: List specific warnings with file names and recommendations

### 1d. Monthly Deep Maintenance Audit
Every ~30 sessions, run comprehensive context audit:

**Session Counter Check:**
1. Read session count from Serena memory: `read_memory("tipob_context_health_session_count")`
2. Increment counter by 1
3. If counter >= 30, trigger deep audit and reset counter to 0
4. Store updated counter: `write_memory("tipob_context_health_session_count", new_count)`

**Deep Audit Tasks (when counter >= 30):**

**1. Reference File Analysis:**
- List all files in `.claude/references/` with line counts
- Flag files >500 lines for potential splitting
- Check for duplicate patterns across files (similar section headers)

**2. CLAUDE.md Bloat Detection:**
- Analyze sections that could be extracted to references
- Suggest extraction candidates if core file >12K

**3. Framework Version Check:**
- Search for outdated version references (e.g., "Swift 4", "iOS 14")
- Flag patterns that reference old framework versions

**4. Cross-Reference Validation:**
- Check if references link to each other appropriately
- Suggest adding links where patterns relate

**5. Unused Pattern Detection:**
- Review which references were loaded in recent sessions
- Flag references never loaded in last 30 sessions as "rarely used"

**Audit Report Format:**
```
🔍 MONTHLY CONTEXT AUDIT (Session #30)

📊 Reference Health:
- swiftui-patterns.md: [line count] ✅/⚠️
- gesture-implementation.md: [line count] ✅/⚠️
- [Any files >500 lines with recommendations]

🎯 Optimization Opportunities:
- [Specific extraction suggestions]
- [Duplicate pattern cleanup]
- [Framework update recommendations]

📅 Next audit: Session #60
```

**Update Tracking:**
```
write_memory("tipob_context_health_last_deep_audit", current_date)
write_memory("tipob_context_health_session_count", "0")
```

## 2. Commit and Push Changes

If there are any changes in the git working directory:

```bash
git status
git add [relevant files]
git commit -m "$(cat <<'EOF'
[type]: [description]

[optional detailed changes]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
git push
```

## 3. Save Session

Execute `/sc:save` to persist session state to Serena MCP

## 4. Friendly Goodbye

Provide a warm, encouraging sign-off message:

```
🎉 Great work today!

✅ Completed:
- [key accomplishments]

⏭️  Next session:
- [next tasks]

🌙 Rest well! Your progress is saved and ready to pick up exactly where you left off.

Use `/hello` when you return! 👋
```

Keep it warm, concise, and motivating!
