# Serena MCP Setup Guide
**Date**: 2025-10-16
**Status**: ✅ Configured - Restart Required

---

## What is Serena MCP?

Serena is a Model Context Protocol (MCP) server that provides:
- **Session Persistence**: Save and restore session context across conversations
- **Memory Management**: Store project-specific knowledge and learnings
- **Semantic Code Understanding**: Advanced code analysis and editing capabilities
- **Cross-Session Learning**: Accumulate insights over time

---

## Installation Status

### ✅ Prerequisites Met
- `uv` installed at: `/opt/homebrew/bin/uvx`
- Claude Desktop configured
- Config file location: `/Users/marcgeraldez/Library/Application Support/Claude/claude_desktop_config.json`

### ✅ Configuration Added

```json
{
  "globalShortcut": "",
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

## Next Steps to Complete Setup

### 1. Restart Claude Desktop
**IMPORTANT**: You must restart Claude Desktop for the MCP server to load.

**How to Restart:**
1. Quit Claude Desktop completely (Cmd+Q)
2. Wait 5 seconds
3. Reopen Claude Desktop
4. Start a new conversation or continue this one

### 2. Verify Serena is Running
After restart, you should see Serena MCP tools available:
- `write_memory` - Save session context
- `read_memory` - Retrieve saved context
- `list_memories` - List all saved memories
- `delete_memory` - Remove old memories
- `think_about_collected_information` - Analyze session data

### 3. Test Memory Operations
Try a simple test:
```
Can you write a memory called "test" with value "Serena MCP is working!"?
```

If successful, you'll see confirmation that the memory was written.

---

## How to Use Serena for Session Persistence

### Saving Session Context
When ending a session:
```
/sc:save
```

This will:
1. Analyze current session discoveries
2. Write session context to Serena memory
3. Create checkpoint for recovery
4. Prepare for seamless continuation

### Loading Session Context
When starting a session:
```
/sc:load
```

This will:
1. List available memories
2. Read relevant session context
3. Restore project understanding
4. Resume where you left off

---

## Serena MCP Features Available

### Memory Operations
- **write_memory(key, value)** - Store information
- **read_memory(key)** - Retrieve information
- **list_memories()** - See all stored memories
- **delete_memory(key)** - Remove old data

### Code Understanding
- **Semantic Search** - Find code by meaning, not just text
- **Symbol Operations** - Rename, extract, refactor with LSP
- **Cross-File Analysis** - Understand dependencies
- **Code Navigation** - Smart go-to-definition

### Project Management
- **activate_project(path)** - Load project context
- **Session Checkpoints** - Save progress points
- **Pattern Learning** - Accumulate best practices
- **Cross-Session Insights** - Build knowledge over time

---

## Troubleshooting

### If Serena Doesn't Load After Restart
1. Check logs: Look for MCP server errors in Claude Desktop
2. Verify `uv` path:
   ```bash
   which uvx
   # Should show: /opt/homebrew/bin/uvx
   ```
3. Test manual start:
   ```bash
   uvx --from git+https://github.com/oraios/serena serena start-mcp-server
   ```

### If Memory Operations Fail
1. Check Serena dashboard: http://localhost:24282/dashboard/index.html
2. Look for errors in server logs
3. Try restarting Serena MCP server

### Common Issues
- **"MCP server not found"**: Restart Claude Desktop
- **"Permission denied"**: Check uv/uvx permissions
- **"Connection refused"**: Serena may not be running

---

## Serena Dashboard

After Serena starts, access the web dashboard:
- URL: http://localhost:24282/dashboard/index.html
- Features:
  - View logs
  - Monitor memory usage
  - Shutdown server
  - Debug MCP connections

---

## Benefits for Tipob Project

### Session Continuity
- Remember where you left off each session
- Restore context without re-explaining
- Build on previous decisions

### Knowledge Accumulation
- Store lessons learned
- Remember bug fixes and solutions
- Track architectural decisions

### Code Understanding
- Semantic search across Swift files
- Symbol renaming with LSP
- Cross-file dependency analysis
- Smart refactoring operations

---

## Configuration Reference

### Claude Desktop Config Location
```
/Users/marcgeraldez/Library/Application Support/Claude/claude_desktop_config.json
```

### Serena Repository
```
https://github.com/oraios/serena
```

### Installation Command
```bash
uvx --from git+https://github.com/oraios/serena serena start-mcp-server
```

---

## Next Actions

1. ✅ Configuration added to Claude Desktop
2. ⏳ **ACTION REQUIRED**: Restart Claude Desktop
3. ⏳ Verify Serena MCP loads successfully
4. ⏳ Test memory operations
5. ⏳ Use `/sc:save` to persist current session

---

**Status**: Configured, awaiting restart
**Required Action**: Quit and restart Claude Desktop to activate Serena MCP
**Documentation**: Complete setup guide created
