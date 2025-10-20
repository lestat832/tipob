# MCP Configuration for Claude Code (VS Code)

**Date**: 2025-10-19
**Status**: ✅ Configured for Claude Code
**Environment**: Claude Code extension in VS Code/Cursor

---

## Important Distinction

### Claude Desktop vs Claude Code
- **Claude Desktop**: Standalone desktop app → Uses `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Claude Code**: VS Code extension → Uses `~/.claude/mcp.json`

**You are using Claude Code**, so configuration must be in `~/.claude/mcp.json`

---

## Configuration File Created

**Location**: `~/.claude/mcp.json`

**Contents**:
```json
{
  "mcpServers": {
    "serena": {
      "command": "/opt/homebrew/bin/uvx",
      "args": [
        "--from",
        "git+https://github.com/oraios/serena",
        "serena",
        "start-mcp-server"
      ]
    }
  }
}
```

---

## How to Verify Serena MCP is Working

### Method 1: Check Available Tools
In a Claude Code session, look for these Serena MCP tools:
- `write_memory` - Save session context
- `read_memory` - Retrieve saved context
- `list_memories` - List all saved memories
- `delete_memory` - Remove old memories
- `think_about_collected_information` - Analyze session data
- `activate_project` - Load project context

### Method 2: Test Memory Operations
Ask Claude to run:
```
Can you write a memory called "test" with value "MCP is working!"?
```

If successful, Serena MCP is active.

### Method 3: VS Code Command Palette
1. Open Command Palette (Cmd+Shift+P)
2. Type "MCP: List Servers"
3. Should see "serena" in the list
4. Select it and choose "Show Output" to see logs

---

## Reload Required

After creating/modifying `~/.claude/mcp.json`, you must:

**Option A: Reload VS Code Window**
1. Open Command Palette (Cmd+Shift+P)
2. Type "Developer: Reload Window"
3. Press Enter

**Option B: Restart VS Code/Cursor**
1. Quit VS Code/Cursor completely
2. Wait 5 seconds
3. Reopen

---

## Using Serena MCP in Claude Code

### Save Session Context
Use the `/sc:save` slash command:
```
/sc:save
```

This will:
1. Use `write_memory` to save session discoveries
2. Create checkpoints with `think_about_collected_information`
3. Persist project learnings across sessions

### Load Session Context
Use the `/sc:load` slash command:
```
/sc:load
```

This will:
1. Use `list_memories` to find saved context
2. Use `read_memory` to restore session state
3. Use `activate_project` to load project understanding

---

## Benefits for Tipob Project

### Cross-Session Memory
- Remember where you left off
- Restore full context automatically
- No need to re-explain project structure

### Code Understanding
- Semantic search across Swift files
- Symbol renaming with LSP integration
- Cross-file dependency tracking
- Smart refactoring operations

### Pattern Learning
- Accumulate lessons learned
- Remember bug fixes and solutions
- Track architectural decisions over time

---

## Troubleshooting

### If Serena Doesn't Load

**Check 1: Config File Exists**
```bash
cat ~/.claude/mcp.json
```
Should show the Serena configuration.

**Check 2: uvx is Accessible**
```bash
which uvx
```
Should show: `/opt/homebrew/bin/uvx`

**Check 3: VS Code Reloaded**
- Must reload VS Code window after config changes
- Command Palette → "Developer: Reload Window"

**Check 4: Check MCP Server Status**
- Command Palette → "MCP: List Servers"
- Should see "serena" listed
- Select it → "Show Output" for logs

### If Memory Operations Fail

**Check Serena Dashboard**
- URL: http://localhost:24282/dashboard/index.html
- View logs and connection status

**Manual Server Test**
```bash
uvx --from git+https://github.com/oraios/serena serena start-mcp-server
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "MCP server not found" | Reload VS Code window |
| "Command not found: uvx" | Install uv: `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| "Permission denied" | Check uvx permissions: `chmod +x $(which uvx)` |
| "Connection refused" | Serena may not be running, check logs |

---

## Configuration Files Summary

### ❌ NOT Used (Claude Desktop)
```
~/Library/Application Support/Claude/claude_desktop_config.json
```
This is for Claude Desktop app only, NOT Claude Code.

### ✅ USED (Claude Code)
```
~/.claude/mcp.json
```
This is the correct location for Claude Code in VS Code/Cursor.

---

## Alternative MCP Servers (Optional)

You can add more MCP servers to `~/.claude/mcp.json`:

```json
{
  "mcpServers": {
    "serena": {
      "command": "/opt/homebrew/bin/uvx",
      "args": ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

---

## Next Steps

1. ✅ **Configuration created** at `~/.claude/mcp.json`
2. ⏳ **Reload VS Code** - Command Palette → "Developer: Reload Window"
3. ⏳ **Verify Serena loads** - Check MCP: List Servers
4. ⏳ **Test memory ops** - Try `/sc:save` and `/sc:load`

---

## References

- **Serena GitHub**: https://github.com/oraios/serena
- **MCP Specification**: https://spec.modelcontextprotocol.io/
- **VS Code MCP Docs**: https://code.visualstudio.com/docs/copilot/chat/mcp-servers
- **MCP Server Registry**: https://github.com/modelcontextprotocol/servers

---

**Status**: Configured and ready for Claude Code
**Config Location**: `~/.claude/mcp.json`
**Action Required**: Reload VS Code window to activate
