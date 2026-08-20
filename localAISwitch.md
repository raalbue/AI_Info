# localAISwitch — Plan & Implementation Notes

## Why the previous scripts failed

Both `LocalAI.ps1` and `LocalLLM1.ps1` had the same critical flaw:

**They set `ANTHROPIC_BASE_URL` when switching to Local mode, but never cleared it when switching back to Anthropic mode.**

If the variable was already in the session, skipping the assignment did nothing — the old value survived. Claude Code inherited the stale local URL and kept routing there.

A secondary issue: some local LLM servers require a non-empty `ANTHROPIC_API_KEY` header even though the value doesn't matter. Neither script handled this consistently.

---

## Root cause: where env vars live on Windows

There are three scopes, each more persistent than the last:

| Scope | Set with | Cleared with | Survives new terminal? |
|---|---|---|---|
| Current session only | `$env:VAR = "x"` | `Remove-Item Env:\VAR` | No |
| Current user (registry) | `[Environment]::SetEnvironmentVariable("VAR","x","User")` | `[Environment]::SetEnvironmentVariable("VAR",$null,"User")` | Yes |
| Machine-wide (registry) | `...("VAR","x","Machine")` | `...("VAR",$null,"Machine")` | Yes, all users |

**Scope implemented:** Session only. Registry scopes deferred — add later if vars need to survive terminal restarts.

---

## What was built: `LocalLLM.ps1`

### Functions

| Function | What it does |
|---|---|
| `Show-EnvStatus` | Prints current session values of `ANTHROPIC_BASE_URL` and `ANTHROPIC_API_KEY` |
| `Clear-AnthropicEnv` | Calls `Remove-Item Env:\...` on both vars (removes entirely, not set to empty) |
| `Select-WorkingDirectory` | Prompts for a path, defaults to cwd, validates it exists |

### Menu options

| Key | Behavior |
|---|---|
| **A** | Calls `Clear-AnthropicEnv`, shows status, prompts for working dir, launches `claude` |
| **L** | Prompts for base URL (defaults to current value or `http://localhost:1234/v1`), sets `ANTHROPIC_BASE_URL` and `ANTHROPIC_API_KEY = "local-key"`, shows status, prompts for working dir, launches `claude` |
| **S** | Shows status and exits — no changes, no launch |
| **C** | Calls `Clear-AnthropicEnv`, shows status, exits without launching |

### Key implementation decisions

**`Remove-Item` instead of setting to `$null` or `""`**
Setting to empty string is not the same as unset — some processes treat an empty string as a value. `Remove-Item Env:\VAR` removes the variable entirely from the session.

**Fixed bogus key for local mode**
`ANTHROPIC_API_KEY = "local-key"` — no prompt needed. The local server doesn't validate the value; it just needs the header present.

**`Push-Location` / `Pop-Location` instead of `Set-Location`**
`Set-Location` permanently changes the terminal's working directory. `Push-Location` saves the original and `Pop-Location` restores it after `claude` exits.

**Status shown before and after changes**
The opening status panel lets the user see what's already set before choosing. Each branch shows status again after applying changes so the result is confirmed before launch.

---

## Failure modes addressed

| Scenario | Guard |
|---|---|
| Stale `ANTHROPIC_BASE_URL` from previous session run | Option A explicitly removes it; option C does the same without launching |
| Empty string instead of removed var | `Remove-Item` used — removes the var entirely |
| User picks Local but enters no URL | Defaults to `http://localhost:1234/v1` (or current value if already set) |
| Script changes terminal's working directory | `Push-Location` / `Pop-Location` preserves caller's cwd |
| Invalid menu choice | `default` branch in `switch` prints error and exits with code 1 |

---

## Acceptance criteria

- [x] Choosing **A** leaves both vars absent from the session
- [x] Choosing **L** sets both vars; Claude Code routes to the local server
- [x] Running L then A successfully clears the local settings
- [x] Choosing **C** clears everything without launching Claude
- [x] Status panel shown before and after any change
- [ ] User-level registry scope — deferred, not implemented

---

## Possible future additions

- Persist vars to user-level registry (for vars that need to survive new terminals)
- Detect whether the local server is reachable before launching (`Test-NetConnection`)
- Save the last-used local URL so it pre-fills on next run
