<<<<<<< HEAD
# AI

Personal notes and tooling for local LLM setups, AI-assisted dev workflows, and an AI-driven pentesting lab (Claude + Metasploit via MCP).

## Contents

| File                                                           | What it is                                                                                                         |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| [`00-AI.md`](00-AI.md)                                         | LM Studio / Ollama setup, hardware profile, VRAM sizing guide, recommended local models                            |
| [`LocalLLM.ps1`](LocalLLM.ps1)                                 | PowerShell launcher — switches Claude Code between Anthropic subscription and a local LLM, then launches it        |
| [`localAISwitch.md`](localAISwitch.md)                         | Design notes for `LocalLLM.ps1` — root cause of the env-var bug it fixes, env scope reference, acceptance criteria |
| [`LocalLLMDebug.md`](LocalLLMDebug.md)                         | Debug log from building the launcher script                                                                        |
| [`AI Pentesting with MCP.md`](AI%20Pentesting%20with%20MCP.md) | Full lab guide: Claude + Metasploit via MetasploitMCP, setup steps, and 11 graded exercises                        |

## Local LLM setup

Hardware: i9 / 64GB RAM / RTX 4090 (16GB VRAM). See [`00-AI.md`](00-AI.md) for the VRAM sizing table and model picks (Gemma 3 27B for general use, Qwen2.5-Coder-32B for coding).

Switch Claude Code between modes:

```powershell
.\LocalLLM.ps1
```

| Key | Mode                                                        |
| --- | ----------------------------------------------------------- |
| `A` | Anthropic subscription — clears local env vars              |
| `L` | Local LLM — prompts for base URL, sets `ANTHROPIC_BASE_URL` |
| `S` | Status only                                                 |
| `C` | Clear all env vars and exit                                 |

Env vars are session-scoped only (not persisted to the registry). Details in [`localAISwitch.md`](localAISwitch.md).

## AI-assisted dev workflow

**humanlayer** — [github.com/humanlayer/humanlayer](https://github.com/humanlayer/humanlayer) · [humanlayer.dev](https://www.humanlayer.dev/)

Run `wsl bash ../../setup-humanlayer.sh` in the project directory to set up.

Original 4-step flow:

1. Research — `/research_codebase '<what you want info on>'`
2. Plan — `/create_plan @./thoughts/shared/research/* '<what you want it to do>'`
3. Implement — `/implement_plan @./thoughts/shared/plans/* <phase #>`
4. Validate — `/validate_plan @./thoughts/shared/plans/*`

### QRSPI workflow (8 steps)

Own slash-command family (`/qrspi:*`, project-scoped) — separate from the humanlayer commands above, not built on top of them.

1. **Questions** — `/qrspi:1_question` — decompose the task into neutral research questions.
2. **Research** — `/qrspi:2_research` — objective codebase research driven by those questions; facts only, no opinions.
3. **Design** — `/qrspi:3_design` — design discussion; align on where you're going before planning how.
4. **Structure** — `/qrspi:4_structure` — turn the design into concrete shape (files touched, phases, order).
5. **Plan** — `/qrspi:5_plan` — tactical implementation plan; the agent's working document.
6. **Worktree** — `/qrspi:6_worktree` — create an isolated git worktree for implementation.
7. **Implement** — `/qrspi:7_implement` — execute the plan phase by phase, with verification checkpoints.
8. **Validate** — `/qrspi:7b_validate` — validate the implementation against design intent, codebase patterns, and code quality.

Follow-on command once validation passes: `/qrspi:8_pr` — create a pull request with context from the design discussion.

Working notes:

- When Claude's context hits ~60%, dump progress into an `.md` file, reset the session, and have the new session read it back to resume.
- Go phase by phase on multi-phase plans — implement phase 1, review the diff for unnecessary/destructive changes, test it, then move to phase 2.
- Demo app's intentional SQLi test route: `/manage/demo/sqli/vulnerable/`

**caveman** (terse-output mode for Claude):

```powershell
irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex
```

Requires Node.js if the installer fails: `winget install OpenJS.NodeJS.LTS`

## AI pentesting lab (Claude + Metasploit)

See [`AI Pentesting with MCP.md`](AI%20Pentesting%20with%20MCP.md) for the complete guide — connects Claude to Metasploit via [MetasploitMCP](https://github.com), letting Claude scan, exploit, and run post-exploitation over MCP tool calls instead of raw `msfconsole`.

- Lab architecture, msfrpcd + MetasploitMCP setup, Claude Code/Desktop registration
- 11 graded exercises against Metasploitable 2 and Windows 10 (recon → FTP/SMB/IRC backdoors → Tomcat/distcc/SSH → EternalBlue → post-exploitation chain)
- Safety rules and a quick-reference appendix (all 12 MCP tools, troubleshooting)

Authorized lab use only — isolated VMs, no external targets.
=======
# Artificial Intelligence

I downloaded LM Studio, where I created a virtual AI helper.

I connected my virtual AI chat to talk to my claude code. where it would pull directly from it's own intelligence instead of surfing the web

# DataBase

I downloaded DBeaver, MySQL, and PostGreSQL

I connected the MySQL and PostGreSQL to my DBeaver where they can now be accessed

## humanlayer

[https://github.com/humanlayer/humanlayer](https://github.com/humanlayer/humanlayer)  
[https://www.humanlayer.dev/](https://www.humanlayer.dev/)  
In order to start the process of workflow, you need to run a setup-humanlayer.sh in project directory

## AI Worflow = humanlayer

The workflow for this is 4 steps

1. Research    /research_codebase 'what information you want to specify'
2. Plan        /create_plan  @./thoughts/shared/research/*  'what you want it to do'
3. Implement      /implement_plan @./thoughts/shared/plans/* phase #
4. Validate Plan  /validate_plan @./thoughts/shared/plans/*

## Updated AI Workflow: QRSPI

The updated workflow is now 8ish steps

1. Questions
2. Research
3. Design
4. Structure
5. Plan
6. Worktree
7. Implement
8. Validate

need to run setup-humanlayer in wsl

runs the humanlayer command

```
wsl bash ../../setup-humanlayer.sh
```

When your claude Context reaches around 60% you want to put the context you have gained into an md file, reset claude, then make the new claude read the md file to start where you left off.

For this web app I just created via giving claude inputs and information on how I wanted this app to be made. I then checked what the ai was doing to validate if it was a valid change or if it deleted or did stuff that was unnecessary. Lastly I tested the web app to see if it worked well.

Go step by step. Claude will give you a multi phase process on building the web app, so go implement phase 1, then phase 2, and so on till it is done.

On the web app, if you ever want to test vulnerabilities go to this route

```
/manage/demo/sqli/vulnerable/
```

install caveman into claude  
irm [https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1](https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1) | iex

if that doesnt work, install node.js  
 winget install OpenJS.NodeJS.LTS
>>>>>>> 04dec4208b2da26642482fea1e09803e67e852f5
