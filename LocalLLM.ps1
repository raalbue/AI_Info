#Requires -Version 5.1
<#
    LocalLLM.ps1 - Switch Claude Code between Anthropic subscription and a local LLM,
                   then launch it. Session scope only.
#>

function Show-EnvStatus {
    $url = $env:ANTHROPIC_BASE_URL
    $key = $env:ANTHROPIC_API_KEY
    Write-Host ""
    Write-Host "  Current env vars (this session):" -ForegroundColor Cyan
    Write-Host "    ANTHROPIC_BASE_URL : $(if ($url) { $url } else { '(not set)' })"
    Write-Host "    ANTHROPIC_API_KEY  : $(if ($key) { $key } else { '(not set)' })"
    Write-Host ""
}

function Clear-AnthropicEnv {
    Remove-Item Env:\ANTHROPIC_BASE_URL -ErrorAction SilentlyContinue
    Remove-Item Env:\ANTHROPIC_API_KEY  -ErrorAction SilentlyContinue
}

function Select-WorkingDirectory {
    $suggestion = (Get-Location).Path
    Write-Host "  Working directory" -ForegroundColor Cyan
    Write-Host "    Current: $suggestion"
    $userInput = Read-Host '    Enter path (leave blank to use current)'
    $path = if ($userInput -and $userInput.Trim()) { $userInput.Trim() } else { $suggestion }
    if (-not (Test-Path $path -PathType Container)) {
        Write-Host "  Path not found: $path" -ForegroundColor Red
        return $null
    }
    return $path
}

# ── Main ─────────────────────────────────────────────────────────────────────

Clear-Host
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Claude Code Launcher" -ForegroundColor Cyan
Write-Host "================================================"

Show-EnvStatus

Write-Host "  Choose mode:" -ForegroundColor Cyan
Write-Host "    [A]  Anthropic subscription  (clears local env vars)"
Write-Host "    [L]  Local LLM               (sets ANTHROPIC_BASE_URL, clears API key)"
Write-Host "    [S]  Status only             (show vars and exit)"
Write-Host "    [C]  Clear all               (remove vars and exit)"
Write-Host ""

$raw    = Read-Host '  Enter A / L / S / C'
$choice = if ($raw -and $raw.Trim()) { $raw.Trim().Substring(0, 1).ToUpper() } else { '' }

# Compare by ASCII code to avoid any hidden encoding issues with string literals.
# A=65  L=76  S=83  C=67
$code = if ($choice.Length -gt 0) { [int][char]$choice[0] } else { 0 }

if ($code -eq 65) {
    Clear-AnthropicEnv
    Write-Host ""
    Write-Host "  Anthropic subscription mode -- env vars cleared." -ForegroundColor Yellow
    Show-EnvStatus
    $workDir = Select-WorkingDirectory
    if (-not $workDir) { exit 1 }
    Push-Location $workDir
    claude
    Pop-Location
}
elseif ($code -eq 76) {
    # Clear ANTHROPIC_API_KEY so it doesn't conflict with the stored claude.ai session
    # token. ANTHROPIC_BASE_URL alone is sufficient to route all completions to the
    # local LLM; Claude Code uses the claude.ai token only for auth handshake.
    Remove-Item Env:\ANTHROPIC_API_KEY -ErrorAction SilentlyContinue

    $default = if ($env:ANTHROPIC_BASE_URL) { $env:ANTHROPIC_BASE_URL } else { 'http://localhost:1234/v1' }
    Write-Host ""
    $url = Read-Host ('  Local base URL (leave blank for ' + $default + ')')
    if (-not ($url -and $url.Trim())) { $url = $default }
    $env:ANTHROPIC_BASE_URL = $url.Trim()
    Write-Host ""
    Write-Host "  Local LLM mode -- ANTHROPIC_BASE_URL set, ANTHROPIC_API_KEY cleared." -ForegroundColor Green
    Show-EnvStatus
    $workDir = Select-WorkingDirectory
    if (-not $workDir) { exit 1 }
    Push-Location $workDir
    claude
    Pop-Location
}
elseif ($code -eq 83) {
    Show-EnvStatus
}
elseif ($code -eq 67) {
    Clear-AnthropicEnv
    Write-Host ""
    Write-Host "  All Anthropic env vars cleared." -ForegroundColor Magenta
    Show-EnvStatus
}
else {
    Write-Host ""
    Write-Host "  Invalid choice '$choice' (code $code). Expected A, L, S, or C." -ForegroundColor Red
    exit 1
}
