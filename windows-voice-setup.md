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
2. Install and sign inAll rights reserved.
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

> **Status on this machine:** configured. `~/.claude/settings.json` has:
> ```json
> "mcpServers": {
>   "windows-tts": {
>     "command": "uvx",
>     "args": ["windows-tts-mcp"]
>   }
> }
> ```
> Confirmed working by calling `mcp__text-to-speech__speak_text` directly and hearing audio. If you stop hearing anything after this worked before, check (in order): Windows volume mixer (the `uvx`/python process may be muted independently of the system volume), the default playback device in Settings > System > Sound, and whether any voices are installed (`Add-Type -AssemblyName System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | % {$_.VoiceInfo.Name}` — an empty result means no SAPI voice is installed).

### Option B: Edge TTS MCP (Free, Cloud-Based, Better Voice Quality)

Uses Microsoft Edge's neural TTS service — much more natural than the legacy Windows SAPI voices (`David`/`Zira`/`Mark`) that `windows-tts-mcp` and `System.Speech` are stuck with. Zero API key.

> **Watch out — two different packages share the "edge tts mcp" name:**
>
> | Package | PyPI name | Behavior |
> |---|---|---|
> | by `eraincc` | `edge-tts-mcp` | Only **writes an MP3 file** and returns its path (`tts` tool) — does **not** play audio. Needs a separate playback step. |
> | by `s-n-n` | `mcp-edge-tts` | Has a `speak` tool that **plays audio directly** (PowerShell MediaPlayer on Windows) — drop-in equivalent to `windows-tts-mcp`'s `speak_text`. |
>
> Use **`mcp-edge-tts`** (the second one) unless you specifically want files on disk instead of audio.

**Install:**

```powershell
pip install mcp-edge-tts
```

**Known bug (as of `mcp-edge-tts` 0.1.1, August 2026):** it depends on `mcp>=1.0.0` with no upper bound, but the `mcp` SDK hit a breaking `2.0.0` release that removed `mcp.server.fastmcp.FastMCP` (moved/renamed). Installing normally resolves the latest `mcp` and the server crashes with:
```
ModuleNotFoundError: No module named 'mcp.server.fastmcp'
```
**Fix:** pin `mcp<2.0.0` when launching it. Via `uvx`, use `--with`:

**Configure** (`~/.claude/settings.json`):

```json
{
  "mcpServers": {
    "edge-tts": {
      "command": "uvx",
      "args": ["--with", "mcp<2.0.0", "mcp-edge-tts"]
    }
  }
}
```

> **Status on this machine:** configured (2026-08-20), registered alongside `windows-tts` in the same `mcpServers` block. Exposes tools `speak`, `list_available_voices`, and `get_config`. Good starting voices: `en-US-AvaNeural` (warm, natural), `en-US-AndrewNeural` (male, natural) — pass as the `voice` parameter, e.g. `speak("hello", voice="en-US-AvaNeural")`. Requires a Claude Code restart (or new session) to pick up, since MCP servers register at startup — see the reload caveat at the end of §4.
>
> If it still fails to start after a restart, re-run the failing command by hand to see the real error:
> ```powershell
> uvx --with "mcp<2.0.0" mcp-edge-tts
> ```

Requires internet connection (the neural voices are synthesized by Microsoft's cloud service, even though no API key is needed).

### Setting the voice

**Per-request (no config change):** pass `voice` as an argument when asking Claude to speak, or directly to the tool:
```
speak("Hello, world!", voice="en-US-AvaNeural")
```
If omitted, it falls back to the configured default (`en-US-AriaNeural` unless overridden — see below), or `EDGE_TTS_VOICE` if set.

**Set a default for every call**, so you don't have to name a voice each time — add an `env` block to the `edge-tts` entry in `~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "edge-tts": {
      "command": "uvx",
      "args": ["--with", "mcp<2.0.0", "mcp-edge-tts"],
      "env": {
        "EDGE_TTS_VOICE": "en-US-AvaNeural",
        "EDGE_TTS_RATE": "+0%",
        "EDGE_TTS_VOLUME": "+0%",
        "EDGE_TTS_PITCH": "+0Hz"
      }
    }
  }
}
```
`rate`/`volume`/`pitch` accept a signed percentage (`+20%`, `-10%`) except `pitch`, which is in Hz (`+5Hz`). Restart Claude Code after editing `env` — MCP server config, including env vars, is only read at startup.

Ask `get_config` (one of the server's tools) to see the currently active defaults and detected audio player.

### Listing available voices

**Ask Claude** — call the `list_available_voices` tool, optionally filtered by language: `list_available_voices("uk")` for just Ukrainian voices, or with no argument for the full list.

**Or list them yourself**, without going through Claude at all, since `edge-tts` (the underlying Python package, already installed as `mcp-edge-tts`'s dependency) ships a CLI:
```powershell
edge-tts --list-voices
```

Edge TTS has 322 voices total across 142 locales; only the English ones are listed below (47 voices, 14 English locales) since that's what's relevant here. Run `edge-tts --list-voices` yourself for the full multilingual list. Pick the `Voice` value and pass it as the `voice` parameter or `EDGE_TTS_VOICE` env var.

<details>
<summary>Click to expand all 47 English voices, grouped by locale</summary>

**en-AU - English (Australia)**

| Voice | Gender | Personality |
|---|---|---|
| `en-AU-NatashaNeural` | Female | Friendly, Positive |
| `en-AU-WilliamMultilingualNeural` | Male | Friendly, Positive |

**en-CA - English (Canada)**

| Voice | Gender | Personality |
|---|---|---|
| `en-CA-ClaraNeural` | Female | Friendly, Positive |
| `en-CA-LiamNeural` | Male | Friendly, Positive |

**en-GB - English (United Kingdom)**

| Voice | Gender | Personality |
|---|---|---|
| `en-GB-LibbyNeural` | Female | Friendly, Positive |
| `en-GB-MaisieNeural` | Female | Friendly, Positive |
| `en-GB-RyanNeural` | Male | Friendly, Positive |
| `en-GB-SoniaNeural` | Female | Friendly, Positive |
| `en-GB-ThomasNeural` | Male | Friendly, Positive |

**en-HK - English (Hong Kong SAR)**

| Voice | Gender | Personality |
|---|---|---|
| `en-HK-SamNeural` | Male | Friendly, Positive |
| `en-HK-YanNeural` | Female | Friendly, Positive |

**en-IE - English (Ireland)**

| Voice | Gender | Personality |
|---|---|---|
| `en-IE-ConnorNeural` | Male | Friendly, Positive |
| `en-IE-EmilyNeural` | Female | Friendly, Positive |

**en-IN - English (India)**

| Voice | Gender | Personality |
|---|---|---|
| `en-IN-NeerjaExpressiveNeural` | Female | Friendly, Positive |
| `en-IN-NeerjaNeural` | Female | Friendly, Positive |
| `en-IN-PrabhatNeural` | Male | Friendly, Positive |

**en-KE - English (Kenya)**

| Voice | Gender | Personality |
|---|---|---|
| `en-KE-AsiliaNeural` | Female | Friendly, Positive |
| `en-KE-ChilembaNeural` | Male | Friendly, Positive |

**en-NG - English (Nigeria)**

| Voice | Gender | Personality |
|---|---|---|
| `en-NG-AbeoNeural` | Male | Friendly, Positive |
| `en-NG-EzinneNeural` | Female | Friendly, Positive |

**en-NZ - English (New Zealand)**

| Voice | Gender | Personality |
|---|---|---|
| `en-NZ-MitchellNeural` | Male | Friendly, Positive |
| `en-NZ-MollyNeural` | Female | Friendly, Positive |

**en-PH - English (Philippines)**

| Voice | Gender | Personality |
|---|---|---|
| `en-PH-JamesNeural` | Male | Friendly, Positive |
| `en-PH-RosaNeural` | Female | Friendly, Positive |

**en-SG - English (Singapore)**

| Voice | Gender | Personality |
|---|---|---|
| `en-SG-LunaNeural` | Female | Friendly, Positive |
| `en-SG-WayneNeural` | Male | Friendly, Positive |

**en-TZ - English (Tanzania)**

| Voice | Gender | Personality |
|---|---|---|
| `en-TZ-ElimuNeural` | Male | Friendly, Positive |
| `en-TZ-ImaniNeural` | Female | Friendly, Positive |

**en-US - English (United States)**

| Voice | Gender | Personality |
|---|---|---|
| `en-US-AnaNeural` | Female | Cute |
| `en-US-AndrewMultilingualNeural` | Male | Warm, Confident, Authentic, Honest |
| `en-US-AndrewNeural` | Male | Warm, Confident, Authentic, Honest |
| `en-US-AriaNeural` | Female | Positive, Confident |
| `en-US-AvaMultilingualNeural` | Female | Expressive, Caring, Pleasant, Friendly |
| `en-US-AvaNeural` | Female | Expressive, Caring, Pleasant, Friendly |
| `en-US-BrianMultilingualNeural` | Male | Approachable, Casual, Sincere |
| `en-US-BrianNeural` | Male | Approachable, Casual, Sincere |
| `en-US-ChristopherNeural` | Male | Reliable, Authority |
| `en-US-EmmaMultilingualNeural` | Female | Cheerful, Clear, Conversational |
| `en-US-EmmaNeural` | Female | Cheerful, Clear, Conversational |
| `en-US-EricNeural` | Male | Rational |
| `en-US-GuyNeural` | Male | Passion |
| `en-US-JennyNeural` | Female | Friendly, Considerate, Comfort |
| `en-US-MichelleNeural` | Female | Friendly, Pleasant |
| `en-US-RogerNeural` | Male | Lively |
| `en-US-SteffanNeural` | Male | Rational |

**en-ZA - English (South Africa)**

| Voice | Gender | Personality |
|---|---|---|
| `en-ZA-LeahNeural` | Female | Friendly, Positive |
| `en-ZA-LukeNeural` | Male | Friendly, Positive |

</details>

### Switching between `windows-tts` and `edge-tts`

Claude Code's `settings.json` is parsed as strict JSON — no `//` or `/* */` comments are supported, so there's no way to "comment out" one server and "uncomment" the other to toggle between them.

The simpler fix: **register both servers at once** (as done above) and just say which one you want per request — "read that using edge tts" vs "use windows tts". No file edits needed to switch, and no restart needed after the first time both are registered. This also sidesteps needing a disable mechanism entirely, since MCP has no per-server enable/disable flag in `settings.json` — an entry under `mcpServers` is either present (and will be launched) or absent.

If you actually want only one active (e.g. to reduce tool-list clutter), the only real option is deleting the unwanted entry from `mcpServers` and re-adding it later from this doc.

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

## 4. Auto-Speak Every Response (Stop Hook)

The MCP tool (`mcp__text-to-speech__speak_text` / `windows-tts`) only speaks when Claude explicitly decides to call it — asking "read that aloud" each time. To have **every** response spoken automatically, without Claude choosing to, a `Stop` hook is required, since automated behavior on an event needs a hook, not a tool call the model has to remember to make.

### Why this isn't just an `mcp_tool` hook calling `speak_text`

Claude Code hooks support an `mcp_tool` hook type that can call an MCP tool directly, with its `input` fields interpolated from the hook's own stdin JSON (`${path}` syntax). The `Stop` event's stdin JSON only contains `session_id`, `transcript_path`, and `hook_event_name` — it does **not** include the assistant's response text. There's no mechanism to pipe one hook's extracted text into another hook's `mcp_tool` input. So calling `speak_text` on Stop isn't directly wireable.

The `agent`/`prompt` hook types (which *could* read the transcript and then call a tool) are restricted by Claude Code to `PreToolUse` / `PostToolUse` / `PermissionRequest` only — not available on `Stop`.

### The working approach

A single `command`-type `Stop` hook, in PowerShell, that:

1. Reads `transcript_path` from its own stdin JSON.
2. Reads the session's `.jsonl` transcript file and finds the last entry where `type == "assistant"` and `isSidechain` is not true (skips subagent turns).
3. Concatenates that message's `text`-type content blocks.
4. Strips markdown noise (`*`, `_`, backtick, `#`) and collapses newlines.
5. Speaks the result via `System.Speech.Synthesis.SpeechSynthesizer` (Windows SAPI) directly — **not** through the MCP server. This is a separate code path from `windows-tts-mcp`, but uses the same underlying Windows speech engine, so it sounds the same and needs no extra dependency.

**Location:** `~/.claude/settings.json` → `hooks.Stop`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "shell": "powershell",
            "command": "$stdin=[Console]::In.ReadToEnd(); try { $hi=$stdin|ConvertFrom-Json; $tp=$hi.transcript_path; if($tp -and (Test-Path -LiteralPath $tp)){ $lines=Get-Content -LiteralPath $tp; $lastText=$null; foreach($ln in $lines){ if(-not $ln){continue}; try{$o=$ln|ConvertFrom-Json}catch{continue}; if($o.type -eq 'assistant' -and -not $o.isSidechain){ $blocks=$o.message.content | Where-Object { $_.type -eq 'text' -and $_.text }; if($blocks){ $lastText=($blocks | ForEach-Object { $_.text }) -join ' ' } } }; if($lastText){ $clean=$lastText -replace '[*_`#]','' -replace '[\\r\\n]+',' . '; Add-Type -AssemblyName System.Speech; $synth=New-Object System.Speech.Synthesis.SpeechSynthesizer; $synth.Speak($clean) } } } catch {}",
            "timeout": 180,
            "statusMessage": "Speaking response..."
          }
        ]
      }
    ]
  }
}
```

`timeout: 180` gives long responses room to finish speaking before Claude Code kills the hook (`Speak()` blocks synchronously until playback completes).

### Verifying it after any edit

1. **Syntax check:**
   ```powershell
   Get-Content -Raw "$env:USERPROFILE\.claude\settings.json" | ConvertFrom-Json | Out-Null
   ```
   Throws on malformed JSON.

2. **Pipe-test against a real transcript** (find the latest one under `~/.claude/projects/<encoded-cwd>/*.jsonl`):
   ```powershell
   $cmd = (Get-Content -Raw "$env:USERPROFILE\.claude\settings.json" | ConvertFrom-Json).hooks.Stop[0].hooks[0].command
   $payload = @{ transcript_path = "C:\path\to\session.jsonl" } | ConvertTo-Json -Compress
   $payload | pwsh -NoProfile -NonInteractive -Command $cmd
   ```
   Should speak the last assistant message from that transcript out loud.

### Modifying it

- **Change what gets skipped/included** (e.g. also skip messages that are only tool calls with no text): edit the `if($o.type -eq 'assistant' ...)` filter block.
- **Route through the MCP server instead of SAPI directly**: not currently possible via hooks for the reason above — would require either a Claude Code feature change (Stop hook exposing message text) or having Claude itself call `speak_text` each turn (defeats the "automatic" point).
- **Change voice/rate**: add `$synth.Rate = <int -10 to 10>` or `$synth.SelectVoice("<voice name>")` before `$synth.Speak($clean)` in the command string. List installed voices with:
  ```powershell
  Add-Type -AssemblyName System.Speech
  (New-Object System.Speech.Synthesis.SpeechSynthesizer).GetInstalledVoices() | % { $_.VoiceInfo.Name }
  ```

### Turning off auto-speak

**Status on this machine: OFF** (removed 2026-08-20). The `hooks.Stop` block below was deleted from `~/.claude/settings.json`; the `windows-tts` MCP server entry under `mcpServers` was left in place, so Claude can still speak on request ("read that aloud") — it just no longer speaks automatically after every response.

To turn it off again in the future (or on another machine), either:

- **Ask Claude**: "turn off auto-speak" / "remove the Stop hook" — it can edit the file directly.
- **Do it manually**:
  1. Open `~/.claude/settings.json` (`C:\Users\<you>\.claude\settings.json`) in an editor.
  2. Delete the entire `"hooks": { "Stop": [ ... ] }` block (the `hooks` key and everything inside it, unless you have other hooks configured elsewhere in the file — in that case delete only the `Stop` entry from the `hooks` object, or just the one object inside `hooks.Stop[0].hooks` that has `"statusMessage": "Speaking response..."`).
  3. Validate the JSON is still well-formed:
     ```powershell
     Get-Content -Raw "$env:USERPROFILE\.claude\settings.json" | ConvertFrom-Json | Out-Null
     ```
     No output/error = valid.
  4. Run `/hooks` in Claude Code (or start a new session) to force the change to take effect immediately.

To also remove the ability to speak on request (fully uninstall TTS), additionally delete the `mcpServers.windows-tts` block and restart Claude Code — see [Option A under Voice Output](#2-voice-output-text-to-speech) for the config that adds it back.

### Caveat: hook reload timing

Claude Code's settings-file watcher only watches directories that already had a settings file when the session started. If you edit `hooks.Stop` mid-session, run `/hooks` once to force a reload, or start a new session — otherwise the change may not take effect until then.

---

## 5. Quick Decision Guide

| What you want             | Recommended setup               | Cost             |
| ------------------------- | ------------------------------- | ---------------- |
| Talk to Claude only       | Built-in `/voice`               | Free             |
| Claude talks back only    | Windows TTS MCP                 | Free             |
| Both directions, simple   | `/voice` + Windows TTS MCP      | Free             |
| Both directions, one tool | Voice MCP (jochiang)            | Free             |
| Best voice quality output | Claude Code TTS (OpenAI)        | ~$0.015/1k chars |
| Offline everything        | Whisperstream + Windows TTS MCP | $29 one-time     |

---

## 6. General Debugging Checklist

1. **Claude Code version**: `claude --version` - update with `claude update` if old
2. **MCP servers not loading**: Run `claude mcp list` to see registered servers.
  Restart Claude Code after config changes.
3. **Microphone issues**: Check Windows Settings > Privacy > Microphone - make sure your terminal app has permission
4. **No audio output**: Check default playback device in Windows Sound settings
5. **MCP server crashes**: Run the server command manually in PowerShell to see error output (e.g., `uvx windows-tts-mcp`)
6. **WSL2 audio**: If running Claude Code in WSL2, ensure WSLg is enabled (`wsl --update`) for audio passthrough
