#!/usr/bin/env bash

# Save current terminal settings
orig_settings=$(stty -g)

# Function to restore terminal state
cleanup() {
    # Restore original stty settings
    stty "$orig_settings"
    # Disable all common mouse reporting modes
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l'
    # Reset terminal screen if needed
    tput rmcup
}

# Trap signals so cleanup runs even on Ctrl+C or kill
trap cleanup EXIT INT TERM

# Run opencode with any arguments passed to the script
opencode "$@"

