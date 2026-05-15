#Requires -Version 5.1
<#
    LocalAI.ps1  —  Configure environment, then launch Claude Code
#>

# ── Helpers ──────────────────────────────────────────────────────────────────

function Select-WorkingDirectory {
    $suggestion = (Get-Location).Path
    Write-Host ""
    Write-Host "Working directory" -ForegroundColor Cyan
    Write-Host "  Current: $suggestion"
    $userInput = Read-Host "  Enter path (leave blank to use current)"
    $path      = if ($userInput.Trim()) { $userInput.Trim() } else { $suggestion }
    if (-not (Test-Path $path -PathType Container)) {
        Write-Host "  Path not found: $path" -ForegroundColor Red
        return $null
    }
    return $path
}

# ── Main ──────────────────────────────────────────────────────────────────────

Clear-Host
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Claude Code Launcher" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# 1. API host
Write-Host ""
Write-Host "API Host" -ForegroundColor Cyan
$currentHost = $env:ANTHROPIC_BASE_URL
Write-Host "  Current: $(if ($currentHost) { $currentHost } else { '(default — api.anthropic.com)' })"
$newHost = Read-Host "  Enter base URL to override (leave blank to keep current)"
if ($newHost.Trim()) {
    $env:ANTHROPIC_BASE_URL = $newHost.Trim()
}

# 2. Working directory

$workDir = Select-WorkingDirectory
if (-not $workDir) {
    Write-Host "Aborting — no valid directory selected." -ForegroundColor Red
    exit 1
}

# 3. Launch
Write-Host ""
Write-Host "Launching Claude Code in: $workDir" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Set-Location $workDir
claude
