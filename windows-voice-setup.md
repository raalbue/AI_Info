# Voice Interface for Claude CLI on Windows

Two independent capabilities: **voice input** (you talk) and **voice output** (Claude talks back).
Enable either, both, or neither.

---

## 1. Voice Input (Speech-to-Text)

### Option A: Built-in `/voice` Command (Recommended)

Native voice input since Claude Code v2.1.69 (March 2026).
No extra installation needed.

**Requirements:**

- Claude Code v2.1.69+
- Claude.ai account (not API keys, Bedrock, or Vertex)
- Microphone

**Setup:**

```powershell
# Make sure Claude Code is up to date
claude update

# Launch Claude Code, then type:
/voice
```

**Usage modes:**

- **Hold mode** (default): Hold Space to record, release to submit
- **Tap mode**: Tap Space once to start, tap again to send

**Configuration** (`~/.claude/settings.json`):

```json
{
  "voice": {
    "enabled": true,
    "mode": "tap",
    "autoSubmit": true
  }
}
```

**Debugging:**

- If `/voice` doesn't appear, check your version with `claude --version` - need 2.1.69+
- Only works with Claude.ai auth, not API keys
- Make sure your microphone is not muted at the OS level
- On WSL2, you need WSLg enabled for microphone passthrough

### Option B: Wispr Flow (System-Wide Dictation)

Works in Claude Code and every other app.

1. Download from [wisprflow.ai](https://wisprflow.ai)
2. Install and sign in
3. Default hotkey: hold `Ctrl+Shift` to dictate
4. If text doesn't appear in Claude Code, use `Alt+Shift+Z` to paste last transcript

### Option C: Whisperstream (Offline, One-Time $29)

Runs locally, no cloud dependency, works with any Claude auth method.

1. Download from [whisperstream.io](https://whisperstream.io)
2. Install (downloads ~600MB model on first run, needs ~4GB RAM)
3. Push-to-talk dictation into any app including Claude Code

---

## 2. Voice Output (Text-to-Speech)

### Option A: Windows TTS MCP Server (Recommended - Free, Native)

Uses Windows built-in Speech API.
No API costs.

**Prerequisites:**

- Python 3.10+ and `uv` or `pip` installed

**Install:**

```powershell
pip install windows-tts-mcp
# or
uvx windows-tts-mcp
```

**Configure Claude Code** - add to `~/.claude/settings.json` under `mcpServers`:

```json
{
  "mcpServers": {
    "windows-tts": {
      "command": "uvx",
      "args": ["windows-tts-mcp"]
    }
  }
}
```

Restart Claude Code.
You can then ask Claude to speak responses aloud.

**Debugging:**

- Run `uvx windows-tts-mcp` standalone to check for errors
- Make sure Windows Speech is enabled in Settings > Time & Language > Speech
- Check that speakers/headphones are not muted

### Option B: Edge TTS MCP (Free, Cloud-Based, Better Voice Quality)

Uses Microsoft's Edge TTS service - better sounding voices than Windows SAPI.

```powershell
pip install edge-tts-mcp
```

**Configure:**

```json
{
  "mcpServers": {
    "edge-tts-mcp": {
      "command": "uvx",
      "args": ["edge_tts_mcp"]
    }
  }
}
```

Requires internet connection.

### Option C: Claude Code TTS (OpenAI Voices, Best Quality, Paid)

High-quality voices via OpenAI API.
Costs ~$0.015 per 1,000 characters.

**Prerequisites:**

- Go 1.21+
- OpenAI API key

**Install:**

```powershell
git clone https://github.com/ybouhjira/claude-code-tts.git
cd claude-code-tts
go build -o claude-code-tts.exe .
```

**Set environment variable:**

```powershell
$env:OPENAI_API_KEY = "sk-..."
```

Voices available: alloy, echo, fable, onyx, nova, shimmer.

---

## 3. Bidirectional (STT + TTS in One Package)

### Voice MCP by jochiang (Local, Free, Windows-Native)

Both input and output using local models (~720MB download on first use).

```powershell
git clone https://github.com/jochiang/voice-mcp.git
cd voice-mcp
pip install uv
uv sync
```

**Configure** (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "voice": {
      "command": "uv",
      "args": ["run", "--directory", "C:\\path\\to\\voice-mcp", "voice-mcp"]
    }
  }
}
```

---

## 4. Quick Decision Guide

| What you want | Recommended setup | Cost |
|---|---|---|
| Talk to Claude only | Built-in `/voice` | Free |
| Claude talks back only | Windows TTS MCP | Free |
| Both directions, simple | `/voice` + Windows TTS MCP | Free |
| Both directions, one tool | Voice MCP (jochiang) | Free |
| Best voice quality output | Claude Code TTS (OpenAI) | ~$0.015/1k chars |
| Offline everything | Whisperstream + Windows TTS MCP | $29 one-time |

---

## 5. General Debugging Checklist

1. **Claude Code version**: `claude --version` - update with `claude update` if old
2. **MCP servers not loading**: Run `claude mcp list` to see registered servers.
   Restart Claude Code after config changes.
3. **Microphone issues**: Check Windows Settings > Privacy > Microphone - make sure your terminal app has permission
4. **No audio output**: Check default playback device in Windows Sound settings
5. **MCP server crashes**: Run the server command manually in PowerShell to see error output (e.g., `uvx windows-tts-mcp`)
6. **WSL2 audio**: If running Claude Code in WSL2, ensure WSLg is enabled (`wsl --update`) for audio passthrough
